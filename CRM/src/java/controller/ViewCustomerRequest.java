package controller;

import dal.ServiceRequestDAO;
import dal.AccountDAO;
import dal.ContractDAO;
import dal.EquipmentDAO;
import model.ServiceRequest;
import model.Account;
import model.Contract;
import model.Equipment;
import service.AccountRoleService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.Date;
import java.util.List;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonPrimitive;
import com.google.gson.JsonSerializer;
import dto.Response;
import jakarta.servlet.annotation.MultipartConfig;
import java.time.LocalDate;
import model.AccountProfile;
import service.AccountService;
import java.util.logging.Logger;

/**
 * Servlet for CSS (Customer Support Staff) to manage customer service requests.
 */
@MultipartConfig
@WebServlet(name = "ViewCustomerRequest", urlPatterns = {
    "/viewCustomerRequest", "/createServiceRequest", "/loadContractsAndEquipment"
})
public class ViewCustomerRequest extends HttpServlet {

    private static final Logger logger = Logger.getLogger(ViewCustomerRequest.class.getName());

    private ServiceRequestDAO serviceRequestDAO;
    private AccountDAO accountDAO;
    private ContractDAO contractDAO;
    private EquipmentDAO equipmentDAO;
    private AccountRoleService accountRoleService;

    @Override
    public void init() throws ServletException {
        serviceRequestDAO = new ServiceRequestDAO();
        accountDAO = new AccountDAO();
        contractDAO = new ContractDAO();
        equipmentDAO = new EquipmentDAO();
        accountRoleService = new AccountRoleService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Account sessionAccount = (Account) session.getAttribute("session_login");

        if (sessionAccount == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // Only CSS (Customer Support Staff) can access
        if (!accountRoleService.isCustomerSupportStaff(sessionAccount.getAccountId())) {
            response.sendRedirect("home.jsp");
            return;
        }

        String servletPath = request.getServletPath();

        try {
            switch (servletPath) {
                case "/viewCustomerRequest":
                    handleListOrSearch(request, response);
                    break;
                case "/loadContractsAndEquipment":
                    handleLoadContractsAndEquipment(request, response);
                    break;
                default:
                    handleListOrSearch(request, response);
                    break;
            }
        } catch (SQLException e) {
            throw new ServletException("Database error in ViewCustomerRequest", e);
        }
    }

    private void handleListOrSearch(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        String keyword = request.getParameter("keyword");
        String status = request.getParameter("status");
        String priority = request.getParameter("priorityLevel");
        String requestType = request.getParameter("requestType");
        String fromDate = request.getParameter("fromDate");
        String toDate = request.getParameter("toDate");

        int page = 1;
        int recordsPerPage = 10;

        if (request.getParameter("page") != null) {
            try {
                page = Integer.parseInt(request.getParameter("page").trim());
                if (page < 1) {
                    page = 1;
                }
            } catch (NumberFormatException e) {
                page = 1;
            }
        }

        List<ServiceRequest> requestList;
        int totalRecords = 0;
        boolean hasFilter = (keyword != null && !keyword.trim().isEmpty())
                || (status != null && !status.trim().isEmpty())
                || (priority != null && !priority.trim().isEmpty())
                || (requestType != null && !requestType.trim().isEmpty())
                || (fromDate != null && !fromDate.trim().isEmpty())
                || (toDate != null && !toDate.trim().isEmpty());

        if (hasFilter) {
            requestList = serviceRequestDAO.filterRequestsPaged(
                    keyword != null ? keyword.trim() : null,
                    status, requestType, priority, fromDate, toDate,
                    (page - 1) * recordsPerPage,
                    recordsPerPage
            );
            totalRecords = serviceRequestDAO.countFilteredRequests(keyword, status, requestType, priority, fromDate, toDate);
        } else {
            requestList = serviceRequestDAO.getAllRequestsPaged(
                    (page - 1) * recordsPerPage,
                    recordsPerPage
            );
            totalRecords = serviceRequestDAO.countAllRequests();
        }

        int totalPages = (int) Math.ceil((double) totalRecords / recordsPerPage);
        if (totalPages == 0) {
            totalPages = 1;
        }

        List<Account> customerList = accountDAO.getAccountsByRole("Customer");

        request.setAttribute("requestList", requestList);
        request.setAttribute("customerList", customerList);

        request.setAttribute("paramKeyword", keyword);
        request.setAttribute("paramStatus", status);
        request.setAttribute("paramRequestType", requestType);
        request.setAttribute("paramPriority", priority);
        request.setAttribute("paramFromDate", fromDate);
        request.setAttribute("paramToDate", toDate);

        request.setAttribute("currentPageNumber", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("currentPageSection", "requests");

        request.getRequestDispatcher("/viewCustomerRequest.jsp").forward(request, response);
    }

    /**
     * Return JSON (contracts + equipment) for given customerId
     */
    private void handleLoadContractsAndEquipment(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String customerIdStr = request.getParameter("customerId");
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();

        try {
            int customerId = Integer.parseInt(customerIdStr.trim());
            List<Contract> contracts = contractDAO.getContractsByCustomer(customerId);
            List<Equipment> equipment = equipmentDAO.getEquipmentByCustomerContracts(customerId);

            Gson gson = new GsonBuilder()
                    .registerTypeAdapter(LocalDate.class,
                            (JsonSerializer<LocalDate>) (date, type, context) -> new JsonPrimitive(date.toString()))
                    .create();

            String json = gson.toJson(new ResponseWrapper(contracts, equipment));
            out.print(json);
            out.flush();

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\": \"" + e.getMessage() + "\"}");
        }
    }

    /**
     * Handle creating new service request from CSS modal
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false); // 👈 không tự tạo session mới
        if (session == null || session.getAttribute("session_login") == null) {
            // ❗ Quan trọng: Trả JSON thay vì redirect
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().print("{\"success\":false,\"message\":\"Session expired, please login again.\"}");
            return;
        }

        String servletPath = request.getServletPath();
        System.out.println("🟩 [DEBUG] doPost servletPath = " + servletPath);

        try {
            if ("/viewCustomerRequest".equals(servletPath)) {
                handleEditCustomer(request, response);
                return;
            }

            if ("/createServiceRequest".equals(servletPath)) {
                handleCreateRequest(request, response, session);
                return;
            }

            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().print("{\"success\":false,\"message\":\"Invalid POST path.\"}");

        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().print("{\"success\":false,\"message\":\"Server error: "
                    + (e.getMessage() != null ? e.getMessage().replace("\"", "\\\"") : "unknown") + "\"}");
        }
    }

    /**
     * Process creating new service request
     */
//    private void handleCreateRequest(HttpServletRequest request, HttpServletResponse response, HttpSession session)
//            throws IOException, SQLException {
//
//        try {
//            int customerId = Integer.parseInt(request.getParameter("customerId"));
//            int contractId = Integer.parseInt(request.getParameter("contractId"));
//            int equipmentId = Integer.parseInt(request.getParameter("equipmentId"));
//            String requestType = request.getParameter("requestType");
//            String priorityLevel = request.getParameter("priorityLevel");
//            String description = request.getParameter("description");
//
//            // --- Validate trước khi insert ---
//            if (!serviceRequestDAO.isValidContract(contractId, customerId)) {
//                session.setAttribute("error", "Hợp đồng không hợp lệ hoặc không thuộc khách hàng này!");
//                response.sendRedirect("viewCustomerRequest");
//                return;
//            }
//            if (!serviceRequestDAO.isValidEquipment(equipmentId)) {
//                session.setAttribute("error", "Thiết bị không tồn tại!");
//                response.sendRedirect("viewCustomerRequest");
//                return;
//            }
//            if (!serviceRequestDAO.isEquipmentInContract(contractId, equipmentId)) {
//                session.setAttribute("error", "Thiết bị không thuộc hợp đồng đã chọn!");
//                response.sendRedirect("viewCustomerRequest");
//                return;
//            }
//
//            // --- Tạo object request ---
//            ServiceRequest newRequest = new ServiceRequest();
//            newRequest.setCreatedBy(customerId);
//            newRequest.setContractId(contractId);
//            newRequest.setEquipmentId(equipmentId);
//            newRequest.setRequestType(requestType);
//            newRequest.setPriorityLevel(priorityLevel);
//            newRequest.setDescription(description);
//            newRequest.setStatus("Pending");
//            newRequest.setRequestDate(new Date());
//
//            int newId = serviceRequestDAO.createServiceRequest(newRequest);
//
//            if (newId > 0) {
//                session.setAttribute("success", "✅ Tạo yêu cầu dịch vụ thành công! (Mã: #" + newId + ")");
//            } else {
//                session.setAttribute("error", "❌ Không thể tạo yêu cầu. Vui lòng thử lại.");
//            }
//        } catch (NumberFormatException e) {
//            session.setAttribute("error", "❌ Dữ liệu đầu vào không hợp lệ!");
//        } catch (Exception e) {
//            e.printStackTrace();
//            session.setAttribute("error", "❌ Lỗi không xác định khi tạo yêu cầu!");
//        }
//
//        response.sendRedirect("viewCustomerRequest");
//    }
    /**
     * Process creating one or multiple service requests (support multiple
     * equipment)
     */
    private void handleCreateRequest(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws IOException, SQLException {

        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        try {
            int customerId = Integer.parseInt(request.getParameter("customerId"));
            String equipmentIdsParam = request.getParameter("equipmentIds");
            String requestType = request.getParameter("requestType");
            String priorityLevel = request.getParameter("priorityLevel");
            String description = request.getParameter("description");

            if (equipmentIdsParam == null || equipmentIdsParam.trim().isEmpty()) {
                out.print("{\"success\":false, \"message\":\"Vui lòng chọn ít nhất một thiết bị!\"}");
                return;
            }

            String[] equipmentIds = equipmentIdsParam.split(",");
            Account creator = (Account) session.getAttribute("session_login");

            // ✅ CSS tạo => trạng thái chờ duyệt
            String status = (creator != null && accountRoleService.isCustomerSupportStaff(creator.getAccountId()))
                    ? "Awaiting Approval"
                    : "Pending";

            int successCount = 0;
            int failCount = 0;

            for (String eqStr : equipmentIds) {
                try {
                    int eqId = Integer.parseInt(eqStr.trim());

                    // --- Lấy hợp đồng tương ứng thiết bị ---
                    Integer contractId = contractDAO.getContractIdByEquipmentAndCustomer(eqId, customerId);
                    String contractType = null;
                    String contractStatus = null;

                    if (contractId != null) {
                        contractType = contractDAO.getContractType(contractId);
                        contractStatus = contractDAO.getContractStatus(contractId);
                    }

                    // --- Tạo request object ---
                    ServiceRequest req = new ServiceRequest();
                    req.setCreatedBy(customerId);
                    req.setEquipmentId(eqId);
                    req.setContractId(contractId);   // ✅ tự động điền
                    req.setRequestType(requestType);
                    req.setPriorityLevel(priorityLevel);
                    req.setDescription(description);
                    req.setStatus(status);
                    req.setRequestDate(new Date());
                    req.setContractType(contractType);
                    req.setContractStatus(contractStatus);

                    int newId = serviceRequestDAO.createServiceRequest(req);

                    if (newId > 0) {
                        successCount++;
                    } else {
                        failCount++;
                    }

                } catch (Exception e) {
                    e.printStackTrace();
                    failCount++;
                }
            }

            if (successCount > 0) {
                out.print("{\"success\":true, \"message\":\"Tạo thành công " + successCount
                        + " yêu cầu dịch vụ. " + (failCount > 0 ? failCount + " thiết bị bị bỏ qua.\"}" : "\"}"));
            } else {
                out.print("{\"success\":false, \"message\":\"Không thể tạo yêu cầu nào.\"}");
            }

        } catch (Exception e) {
            e.printStackTrace();
            String safeMsg = e.getMessage() != null ? e.getMessage().replace("\"", "\\\"") : "Lỗi không xác định";
            out.print("{\"success\":false, \"message\":\"Lỗi khi tạo yêu cầu: " + safeMsg + "\"}");
        } finally {
            out.flush();
        }
    }

    /**
     * Handle editing customer info + auto update request status
     */
    private void handleEditCustomer(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        // 🔹 Các biểu thức regex giống hệt bên CustomerManagement
        final String FULLNAME_REGEX = "^[A-Za-zÀ-ỹ\\s]{2,50}$";
        final String EMAIL_REGEX = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$";
        final String PHONE_REGEX = "^(03|05|07|08|09)[0-9]{8}$";
        final String PASSWORD_REGEX = "^(?=.*[A-Za-z0-9])[A-Za-z0-9!@#$%^&*()_+=-]{6,30}$";
        final String URL_REGEX = "^(https?:\\/\\/.*\\.(?:png|jpg|jpeg|gif|webp|svg))$";
        final String NATIONALID_REGEX = "^[0-9]{9,12}$";

        try {
            int editId = Integer.parseInt(request.getParameter("id"));
            String username = request.getParameter("username");
            String fullName = request.getParameter("fullName");
            String email = request.getParameter("email");
            String phone = request.getParameter("phone");
            String status = request.getParameter("status");
            String password = request.getParameter("password");

            String address = request.getParameter("address");
            String dateOfBirthStr = request.getParameter("dateOfBirth");
            String avatarUrl = request.getParameter("avatarUrl");
            String nationalId = request.getParameter("nationalId");
            String verifiedStr = request.getParameter("verified");
            String extraData = request.getParameter("extraData");

            // ✅ NEW: Lấy requestId từ form ẩn (để cập nhật trạng thái request)
            String requestIdParam = request.getParameter("requestId");

            logger.info("===== [DEBUG] handleEditCustomer() INPUT =====");
            logger.info("editId: " + editId);
            logger.info("username: " + username);
            logger.info("fullName: " + fullName);
            logger.info("email: " + email);
            logger.info("phone: " + phone);
            logger.info("status: " + status);
            logger.info("password: " + password);
            logger.info("address: " + address);
            logger.info("dateOfBirthStr: " + dateOfBirthStr);
            logger.info("avatarUrl: " + avatarUrl);
            logger.info("nationalId: " + nationalId);
            logger.info("verifiedStr: " + verifiedStr);
            logger.info("extraData: " + extraData);
            logger.info("requestIdParam: " + requestIdParam);
            logger.info("============================================");

            // 🔹 Validate định dạng cơ bản
            if (fullName == null || !fullName.matches(FULLNAME_REGEX)
                    || email == null || !email.matches(EMAIL_REGEX)
                    || phone == null || !phone.matches(PHONE_REGEX)
                    || (password != null && !password.trim().isEmpty() && !password.matches(PASSWORD_REGEX))) {

                out.print("{\"success\":false, \"message\":\"Dữ liệu không hợp lệ. Vui lòng kiểm tra lại các trường bắt buộc!\"}");
                return;
            }

            // 🔹 Validate ngày sinh
            LocalDate dateOfBirth = null;
            if (dateOfBirthStr != null && !dateOfBirthStr.trim().isEmpty() && !"null".equalsIgnoreCase(dateOfBirthStr)) {
                try {
                    dateOfBirth = LocalDate.parse(dateOfBirthStr);
                    if (dateOfBirth.isAfter(LocalDate.now())) {
                        out.print("{\"success\":false, \"message\":\"Ngày sinh không được ở tương lai!\"}");
                        return;
                    }
                    if (LocalDate.now().getYear() - dateOfBirth.getYear() < 10) {
                        out.print("{\"success\":false, \"message\":\"Tuổi phải từ 10 trở lên!\"}");
                        return;
                    }
                } catch (Exception e) {
                    out.print("{\"success\":false, \"message\":\"Ngày sinh không hợp lệ!\"}");
                    return;
                }
            } else {
                dateOfBirth = null;
            }

            // 🔹 Validate URL ảnh đại diện
            if (avatarUrl != null && !avatarUrl.trim().isEmpty() && !avatarUrl.matches(URL_REGEX)) {
                out.print("{\"success\":false, \"message\":\"URL ảnh đại diện không hợp lệ!\"}");
                return;
            }

            // 🔹 Validate CCCD/CMND
            if (nationalId != null && !nationalId.trim().isEmpty() && !nationalId.matches(NATIONALID_REGEX)) {
                out.print("{\"success\":false, \"message\":\"CCCD/CMND không hợp lệ!\"}");
                return;
            }

            // 🔹 Validate trạng thái xác thực
            if (verifiedStr == null || (!verifiedStr.equals("0") && !verifiedStr.equals("1"))) {
                out.print("{\"success\":false, \"message\":\"Trạng thái xác thực không hợp lệ!\"}");
                return;
            }

            // 🔹 Validate trạng thái tài khoản
            if (status == null || (!status.equals("Active") && !status.equals("Inactive"))) {
                out.print("{\"success\":false, \"message\":\"Trạng thái tài khoản không hợp lệ!\"}");
                return;
            }

            // 🔹 Chuẩn hoá password
            if (password != null) {
                password = password.trim();
                if (password.isEmpty()) {
                    password = null;
                }
            }

            // 🔹 Chuyển đổi verified
            boolean verified = "true".equalsIgnoreCase(verifiedStr)
                    || "1".equals(verifiedStr)
                    || "on".equalsIgnoreCase(verifiedStr);

            // 🔹 Tạo đối tượng Account & Profile
            Account account = new Account();
            account.setAccountId(editId);
            account.setUsername(username);
            account.setFullName(fullName);
            account.setEmail(email);
            account.setPhone(phone);
            account.setStatus(status);
            account.setPasswordHash(password);

            AccountProfile profile = new AccountProfile();
            profile.setAccountId(editId);
            profile.setAddress(address);
            profile.setDateOfBirth(dateOfBirth);
            profile.setAvatarUrl(avatarUrl);
            profile.setNationalId(nationalId);
            profile.setVerified(verified);
            profile.setExtraData(extraData);

            // 🔹 Gọi service cập nhật
            AccountService accountService = new AccountService();
            Response<Account> updateRes = accountService.updateCustomerAccount(account, profile);

            if (updateRes.isSuccess()) {
                // ✅ Nếu có requestId thì cập nhật trạng thái request sang Completed
                if (requestIdParam != null && !requestIdParam.trim().isEmpty()) {
                    try {
                        int requestId = Integer.parseInt(requestIdParam);
                        ServiceRequestDAO rdao = new ServiceRequestDAO();
                        rdao.updateStatus(requestId, "Completed");
                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }
                }

                out.print("{\"success\":true, \"message\":\"Cập nhật người dùng và trạng thái yêu cầu thành công!\"}");
            } else {
                out.print("{\"success\":false, \"message\":\"" + updateRes.getMessage() + "\"}");
            }

        } catch (Exception e) {
            e.printStackTrace();
            String safeMsg = e.getMessage() != null ? e.getMessage().replace("\"", "\\\"") : "Lỗi không xác định";
            out.print("{\"success\":false, \"message\":\"Lỗi hệ thống khi cập nhật người dùng: " + safeMsg + "\"}");
        } finally {
            out.flush();
        }
    }

    /**
     * Small wrapper for JSON response
     */
    private static class ResponseWrapper {

        List<Contract> contracts;
        List<Equipment> equipment;

        public ResponseWrapper(List<Contract> contracts, List<Equipment> equipment) {
            this.contracts = contracts;
            this.equipment = equipment;
        }
    }
}
