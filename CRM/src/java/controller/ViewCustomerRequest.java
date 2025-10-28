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
import java.time.LocalDate;

/**
 * Servlet for CSS (Customer Support Staff) to manage customer service requests.
 */
@WebServlet(name = "ViewCustomerRequest", urlPatterns = {
    "/viewCustomerRequest", "/createServiceRequest", "/loadContractsAndEquipment"
})
public class ViewCustomerRequest extends HttpServlet {

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

        String servletPath = request.getServletPath();
        HttpSession session = request.getSession();
        Account sessionAccount = (Account) session.getAttribute("session_login");

        if (sessionAccount == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        try {
            switch (servletPath) {
                case "/createServiceRequest":
                    handleCreateRequest(request, response, session);
                    break;
                default:
                    handleListOrSearch(request, response);
                    break;
            }
        } catch (SQLException e) {
            throw new ServletException("Database error in ViewCustomerRequest (POST)", e);
        }
    }

    /**
     * Process creating new service request
     */
    private void handleCreateRequest(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws IOException, SQLException {

        try {
            int customerId = Integer.parseInt(request.getParameter("customerId"));
            int contractId = Integer.parseInt(request.getParameter("contractId"));
            int equipmentId = Integer.parseInt(request.getParameter("equipmentId"));
            String requestType = request.getParameter("requestType");
            String priorityLevel = request.getParameter("priorityLevel");
            String description = request.getParameter("description");

            // --- Validate trước khi insert ---
            if (!serviceRequestDAO.isValidContract(contractId, customerId)) {
                session.setAttribute("error", "Hợp đồng không hợp lệ hoặc không thuộc khách hàng này!");
                response.sendRedirect("viewCustomerRequest");
                return;
            }
            if (!serviceRequestDAO.isValidEquipment(equipmentId)) {
                session.setAttribute("error", "Thiết bị không tồn tại!");
                response.sendRedirect("viewCustomerRequest");
                return;
            }
            if (!serviceRequestDAO.isEquipmentInContract(contractId, equipmentId)) {
                session.setAttribute("error", "Thiết bị không thuộc hợp đồng đã chọn!");
                response.sendRedirect("viewCustomerRequest");
                return;
            }

            // --- Tạo object request ---
            ServiceRequest newRequest = new ServiceRequest();
            newRequest.setCreatedBy(customerId);
            newRequest.setContractId(contractId);
            newRequest.setEquipmentId(equipmentId);
            newRequest.setRequestType(requestType);
            newRequest.setPriorityLevel(priorityLevel);
            newRequest.setDescription(description);
            newRequest.setStatus("Pending");
            newRequest.setRequestDate(new Date());

            int newId = serviceRequestDAO.createServiceRequest(newRequest);

            if (newId > 0) {
                session.setAttribute("success", "✅ Tạo yêu cầu dịch vụ thành công! (Mã: #" + newId + ")");
            } else {
                session.setAttribute("error", "❌ Không thể tạo yêu cầu. Vui lòng thử lại.");
            }
        } catch (NumberFormatException e) {
            session.setAttribute("error", "❌ Dữ liệu đầu vào không hợp lệ!");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("error", "❌ Lỗi không xác định khi tạo yêu cầu!");
        }

        response.sendRedirect("viewCustomerRequest");
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
