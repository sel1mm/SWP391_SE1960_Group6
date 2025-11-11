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
import java.time.LocalDateTime;
import java.util.ArrayList;
import model.AccountProfile;
import service.AccountService;
import java.util.logging.Logger;

/**
 * Servlet for CSS (Customer Support Staff) to manage customer service requests.
 */
@MultipartConfig
@WebServlet(name = "ViewCustomerRequest", urlPatterns = {
    "/viewCustomerRequest", "/createServiceRequest", "/loadContractsAndEquipment", "/cancelPendingRequest"
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
                case "/cancelPendingRequest":
                    handleCancelPendingRequest(request, response);
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
     * Return JSON (contracts + equipment) for given customerId Bao gồm cả thiết
     * bị từ hợp đồng chính và phụ lục
     */
    /**
     * Load equipment list for customer (only ACTIVE equipment) Exclude
     * equipment in Repair or Maintenance status
     */
    private void handleLoadContractsAndEquipment(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String customerIdStr = request.getParameter("customerId");
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        try {
            if (customerIdStr == null || customerIdStr.trim().isEmpty()) {
                out.print("{\"error\": \"Customer ID không được để trống\"}");
                return;
            }

            int customerId = Integer.parseInt(customerIdStr.trim());

            // Lấy hợp đồng của khách hàng
            List<Contract> contracts = contractDAO.getContractsByCustomer(customerId);

            // ✅ Lấy thiết bị từ hợp đồng chính VÀ phụ lục
            List<Equipment> allEquipment = equipmentDAO.getEquipmentByCustomerContractsAndAppendix(customerId);

            // ✅ LỌC CHỈ LẤY THIẾT BỊ ACTIVE
            List<Equipment> activeEquipment = new ArrayList<>();

            for (Equipment eq : allEquipment) {
                // Kiểm tra trạng thái thiết bị
                String equipmentStatus = equipmentDAO.getEquipmentStatus(eq.getEquipmentId());

                System.out.println("🔍 Equipment " + eq.getEquipmentId() + " (" + eq.getModel() + "): Status = " + equipmentStatus);

                // ✅ CHỈ THÊM THIẾT BỊ CÓ TRẠNG THÁI ACTIVE
                if ("Active".equals(equipmentStatus)) {
                    activeEquipment.add(eq);
                    System.out.println("✅ Added equipment " + eq.getEquipmentId() + " to list");
                } else {
                    System.out.println("⚠️ Skipped equipment " + eq.getEquipmentId() + " - Status: " + equipmentStatus);
                }
            }

            System.out.println("📦 Total equipment: " + allEquipment.size());
            System.out.println("✅ Active equipment: " + activeEquipment.size());

            Gson gson = new GsonBuilder()
                    .registerTypeAdapter(LocalDate.class,
                            (JsonSerializer<LocalDate>) (date, type, ctx)
                            -> date == null ? null : new JsonPrimitive(date.toString()))
                    .registerTypeAdapter(LocalDateTime.class,
                            (JsonSerializer<LocalDateTime>) (dt, type, ctx)
                            -> dt == null ? null : new JsonPrimitive(dt.toString()))
                    .serializeNulls()
                    .create();

            // ✅ TRẢ VỀ DANH SÁCH CHỈ CÓ THIẾT BỊ ACTIVE
            String json = gson.toJson(new ResponseWrapper(contracts, activeEquipment));
            out.print(json);
            out.flush();

        } catch (NumberFormatException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"Customer ID không hợp lệ\"}");
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\": \"" + e.getMessage().replace("\"", "\\\"") + "\"}");
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

            if ("/cancelPendingRequest".equals(servletPath)) {
                handleCancelPendingRequest(request, response);
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

            // CSS tạo => trạng thái chờ duyệt
            String status = (creator != null && accountRoleService.isCustomerSupportStaff(creator.getAccountId()))
                    ? "Awaiting Approval"
                    : "Pending";

            int successCount = 0;
            int failCount = 0;
            List<String> skippedEquipment = new ArrayList<>();

            for (String eqStr : equipmentIds) {
                try {
                    int eqId = Integer.parseInt(eqStr.trim());

                    // ✅ Kiểm tra trạng thái thiết bị
                    String equipmentStatus = equipmentDAO.getEquipmentStatus(eqId);

                    if (!"Active".equals(equipmentStatus)) {
                        System.out.println("⚠️ Skipping equipment " + eqId + " - Status: " + equipmentStatus);
                        skippedEquipment.add("Thiết bị #" + eqId + " (trạng thái: " + equipmentStatus + ")");
                        failCount++;
                        continue;
                    }

                    // ✅ Lấy contractId (kiểm tra cả hợp đồng chính và phụ lục)
                    Integer contractId = contractDAO.getContractIdForEquipment(eqId, customerId);

                    if (contractId == null || contractId == 0) {
                        System.out.println("⚠️ Equipment " + eqId + " không thuộc hợp đồng nào của khách hàng " + customerId);
                        skippedEquipment.add("Thiết bị #" + eqId + " (không tìm thấy hợp đồng)");
                        failCount++;
                        continue;
                    }

                    String contractType = contractDAO.getContractType(contractId);
                    String contractStatus = contractDAO.getContractStatus(contractId);

                    System.out.println("📝 Creating request for equipment " + eqId + " with contract " + contractId);

                    // --- Tạo request object ---
                    ServiceRequest req = new ServiceRequest();
                    req.setCreatedBy(customerId);
                    req.setEquipmentId(eqId);
                    req.setContractId(contractId); // ✅ Đảm bảo có contractId hợp lệ
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
                        System.out.println("✅ Created request #" + newId + " for equipment " + eqId + " with contract " + contractId);
                    } else {
                        failCount++;
                        System.out.println("❌ Failed to create request for equipment " + eqId);
                    }

                } catch (NumberFormatException e) {
                    System.err.println("❌ Invalid equipment ID: " + eqStr);
                    failCount++;
                } catch (Exception e) {
                    e.printStackTrace();
                    System.err.println("❌ Error processing equipment " + eqStr + ": " + e.getMessage());
                    failCount++;
                }
            }

            // ✅ Tạo message phù hợp
            StringBuilder message = new StringBuilder();

            if (successCount > 0) {
                message.append("Tạo thành công ").append(successCount).append(" yêu cầu dịch vụ.");
            }

            if (failCount > 0) {
                message.append(" ").append(failCount).append(" thiết bị bị bỏ qua.");
            }

            if (!skippedEquipment.isEmpty()) {
                message.append("<br><small class='text-warning'>Thiết bị bị bỏ qua: ");
                message.append(String.join(", ", skippedEquipment));
                message.append("</small>");
            }

            if (successCount > 0) {
                out.print("{\"success\":true, \"message\":\"" + message.toString() + "\"}");
            } else {
                out.print("{\"success\":false, \"message\":\"Không thể tạo yêu cầu nào. " + message.toString() + "\"}");
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
                // Kiểm tra xem có requestId không
                if (requestIdParam != null && !requestIdParam.trim().isEmpty()) {
                    try {
                        int requestId = Integer.parseInt(requestIdParam);

                        // LẤY LOẠI REQUEST
                        ServiceRequestDAO rdao = new ServiceRequestDAO();
                        ServiceRequest req = rdao.getRequestById(requestId);

                        if (req != null) {
                            String requestType = req.getRequestType();

                            // CHỈ UPDATE COMPLETED CHO InformationUpdate
                            if ("InformationUpdate".equals(requestType)) {
                                rdao.updateStatus(requestId, "Completed");
                                System.out.println("✅ InformationUpdate request #" + requestId
                                        + " completed by CSS after account update.");
                            } else {
                                // Service/Warranty → không làm gì, để WorkTask tự động xử lý
                                System.out.println("ℹ️ Request #" + requestId
                                        + " is " + requestType
                                        + ". Status will be updated when all WorkTasks are completed.");
                            }
                        }

                    } catch (Exception ex) {
                        ex.printStackTrace();
                        System.err.println("⚠️ Failed to update request status: " + ex.getMessage());
                    }
                }

                out.print("{\"success\":true, \"message\":\"Cập nhật người dùng thành công!\"}");
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
     * Handle cancelling pending request
     */
    private void handleCancelPendingRequest(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        try {
            String requestIdParam = request.getParameter("requestId");

            if (requestIdParam == null || requestIdParam.trim().isEmpty()) {
                out.print("{\"success\":false, \"message\":\"Request ID không được để trống!\"}");
                return;
            }

            int requestId = Integer.parseInt(requestIdParam.trim());

            //  Lấy thông tin request
            ServiceRequest serviceRequest = serviceRequestDAO.getRequestById(requestId);

            if (serviceRequest == null) {
                out.print("{\"success\":false, \"message\":\"Không tìm thấy yêu cầu #" + requestId + "!\"}");
                return;
            }

            //  Kiểm tra status có phải Pending không
            if (!"Pending".equals(serviceRequest.getStatus())) {
                out.print("{\"success\":false, \"message\":\"Chỉ có thể hủy yêu cầu đang ở trạng thái Pending. Trạng thái hiện tại: "
                        + serviceRequest.getStatus() + "\"}");
                return;
            }

            //  Cập nhật status sang Cancelled (updateStatus là void)
            try {
                serviceRequestDAO.updateStatus(requestId, "Cancelled");
                logger.info("✅ Request #" + requestId + " đã được hủy bởi CSS");
                out.print("{\"success\":true, \"message\":\"Yêu cầu #" + requestId + " đã được hủy thành công.\"}");
            } catch (SQLException e) {
                logger.severe("❌ Lỗi khi cập nhật status request #" + requestId + ": " + e.getMessage());
                out.print("{\"success\":false, \"message\":\"Không thể cập nhật trạng thái yêu cầu.\"}");
            }

        } catch (NumberFormatException e) {
            out.print("{\"success\":false, \"message\":\"Request ID không hợp lệ!\"}");
        } catch (Exception e) {
            e.printStackTrace();
            String safeMsg = e.getMessage() != null ? e.getMessage().replace("\"", "\\\"") : "Lỗi không xác định";
            out.print("{\"success\":false, \"message\":\"Lỗi hệ thống: " + safeMsg + "\"}");
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
