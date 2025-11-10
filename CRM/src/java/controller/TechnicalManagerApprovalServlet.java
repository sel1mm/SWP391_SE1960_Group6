package controller;

import dal.ServiceRequestDAO;
import dal.RequestApprovalDAO;
import dal.AccountDAO;
import dal.ContractDAO;
import dal.NotificationDAO;
import dal.WorkTaskDAO;

import model.ServiceRequest;
import model.ServiceRequestDetailDTO2;
import model.RequestApproval;
import model.Account;
import dto.ServiceRequestUpdateResult;
import service.AccountRoleService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.ArrayList;
import java.sql.SQLException;
import java.util.Date;
import java.util.stream.Collectors;
import model.Notification;
import model.WorkTask;

@WebServlet(name = "TechnicalManagerApprovalServlet", urlPatterns = {"/technicalManagerApproval"})
public class TechnicalManagerApprovalServlet extends HttpServlet {

    private ServiceRequestDAO serviceRequestDAO;
    private RequestApprovalDAO requestApprovalDAO;
    private AccountDAO accountDAO;
    private AccountRoleService accountRoleService;
    private NotificationDAO notificationDAO;
private ContractDAO contractDAO;
    private static final int RECORDS_PER_PAGE = 10;

    @Override
    public void init() throws ServletException {
        serviceRequestDAO = new ServiceRequestDAO();
        requestApprovalDAO = new RequestApprovalDAO();
        accountDAO = new AccountDAO();
        accountRoleService = new AccountRoleService();
            notificationDAO = new NotificationDAO();  // ✅ THÊM DÒNG NÀY
    contractDAO = new ContractDAO();          // ✅ THÊM DÒNG NÀY
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        // Check if user is logged in and is a Technical Manager
        HttpSession session = request.getSession();
        Account loggedInAccount = (Account) session.getAttribute("session_login");
        Integer accountId = (Integer) session.getAttribute("session_login_id");
        String userRole = (String) session.getAttribute("session_role");

        if (accountId == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        if (!accountRoleService.isTechnicalManager(accountId)) {
            session.setAttribute("error", "You do not have permission to access this page!");
            response.sendRedirect(request.getContextPath() + "/home.jsp");
            return;
        }

        String action = request.getParameter("action");

        try {
            if ("search".equals(action)) {
                handleSearch(request, response, accountId);
            } else if ("filter".equals(action)) {
                handleFilter(request, response, accountId);
            } else if ("history".equals(action)) {
                handleHistory(request, response, accountId);
            } else {
                displayAssignedRequests(request, response, accountId);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            session.setAttribute("error", "Database query error: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/technicalManagerApproval");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        Account loggedInAccount = (Account) session.getAttribute("session_login");
        Integer accountId = (Integer) session.getAttribute("session_login_id");
        String userRole = (String) session.getAttribute("session_role");

        if (accountId == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        if (!accountRoleService.isTechnicalManager(accountId)) {
            session.setAttribute("error", "You do not have permission to perform this action!");
            response.sendRedirect(request.getContextPath() + "/home.jsp");
            return;
        }

        String action = request.getParameter("action");

        try {
            if ("approve".equals(action)) {
                handleApproveRequest(request, response, accountId, session);
            } else if ("reject".equals(action)) {
                handleRejectRequest(request, response, accountId, session);
            } else if ("getRequestDetails".equals(action)) {
                handleGetRequestDetails(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/technicalManagerApproval");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            session.setAttribute("error", "Request processing error: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/technicalManagerApproval");
        }
    }

    /**
     * Display pending service requests for Technical Manager approval with pagination
     */
  private void displayAssignedRequests(HttpServletRequest request, HttpServletResponse response, int managerId)
        throws ServletException, IOException, SQLException {

    // Lấy các tham số filter và search
    String keyword = request.getParameter("keyword");
    String priority = request.getParameter("priority");
    String urgency = request.getParameter("urgency");

    // Lấy số trang
    int page = 1;
    String pageParam = request.getParameter("page");
    if (pageParam != null && !pageParam.isEmpty()) {
        try {
            page = Integer.parseInt(pageParam);
            if (page < 1) page = 1;
        } catch (NumberFormatException e) {
            page = 1;
        }
    }

    // Lấy toàn bộ yêu cầu
    List<ServiceRequest> allRequests = serviceRequestDAO.getPendingRequestsWithDetails();

    // Áp dụng search
    List<ServiceRequest> filteredRequests = allRequests;
    if (keyword != null && !keyword.trim().isEmpty()) {
        String keywordLower = keyword.trim().toLowerCase();
        filteredRequests = filteredRequests.stream()
                .filter(req -> req.getDescription().toLowerCase().contains(keywordLower)
                        || String.valueOf(req.getRequestId()).contains(keyword.trim())
                        || (req.getCustomerName() != null && req.getCustomerName().toLowerCase().contains(keywordLower))
                        || (req.getEquipmentName() != null && req.getEquipmentName().toLowerCase().contains(keywordLower)))
                .collect(Collectors.toList());
    }

    // Áp dụng filter
    List<ServiceRequest> finalFilteredRequests = new ArrayList<>();
    for (ServiceRequest req : filteredRequests) {
        boolean matchesPriority = (priority == null || priority.trim().isEmpty() ||
                priority.equalsIgnoreCase(req.getPriorityLevel()));

        boolean matchesUrgency = true;
        if (urgency != null && !urgency.trim().isEmpty()) {
            int daysPending = req.getDaysPending();
            switch (urgency) {
                case "Urgent":
                    matchesUrgency = daysPending >= 7;
                    break;
                case "High":
                    matchesUrgency = daysPending >= 3 && daysPending < 7;
                    break;
                case "Normal":
                    matchesUrgency = daysPending < 3;
                    break;
            }
        }

        if (matchesPriority && matchesUrgency) {
            finalFilteredRequests.add(req);
        }
    }

    // Tính toán phân trang
    int totalRecords = finalFilteredRequests.size();
    int totalPages = (int) Math.ceil((double) totalRecords / RECORDS_PER_PAGE);

    if (totalPages > 0 && page > totalPages) {
        page = totalPages;
    }

    int startIndex = (page - 1) * RECORDS_PER_PAGE;
    int endIndex = Math.min(startIndex + RECORDS_PER_PAGE, totalRecords);

    List<ServiceRequest> requests = new ArrayList<>();
    if (startIndex < totalRecords) {
        requests = finalFilteredRequests.subList(startIndex, endIndex);
    }

    // Lấy các thống kê
    int awaitingApprovalCount = serviceRequestDAO.getRequestCountByStatus("Awaiting Approval");
    int urgentCount = serviceRequestDAO.getRequestCountByPriority("Urgent", "Awaiting Approval");
    int todayCount = serviceRequestDAO.getRequestsCreatedTodayByStatus("Awaiting Approval");
    int approvedToday = requestApprovalDAO.getApprovalsToday(managerId);

    // Lấy danh sách kỹ thuật viên
    List<Account> technicians = accountDAO.getAccountsByRole("Technician");

    // Gửi dữ liệu sang JSP
    request.setAttribute("requests", requests);
    request.setAttribute("awaitingApprovalCount", awaitingApprovalCount);
    request.setAttribute("urgentCount", urgentCount);
    request.setAttribute("todayCount", todayCount);
    request.setAttribute("approvedToday", approvedToday);
    request.setAttribute("technicians", technicians);
    request.setAttribute("viewMode", "assigned");
    request.setAttribute("currentPage", page);
    request.setAttribute("totalPages", totalPages);
    request.setAttribute("totalRecords", totalRecords);
    
    // Giữ lại các tham số filter
    request.setAttribute("keyword", keyword);
    request.setAttribute("filterPriority", priority);
    request.setAttribute("filterUrgency", urgency);
    
    // Đánh dấu có filter/search
    boolean hasFilters = (keyword != null && !keyword.trim().isEmpty()) ||
                        (priority != null && !priority.trim().isEmpty()) ||
                        (urgency != null && !urgency.trim().isEmpty());
    request.setAttribute("searchMode", hasFilters);
    request.setAttribute("filterMode", hasFilters);

    request.getRequestDispatcher("/TechnicalManagerApproval.jsp").forward(request, response);
}


    /**
     * Handle history view with pagination and new filters
     */
  /**
 * Handle history view with pagination and filters
 * ✅ ENHANCED: Hide requests that have ANY WorkTask (even if Completed)
 */
/**
 * Handle history view with pagination and filters
 * ✅ ENHANCED: Hide requests that have ANY WorkTask (even if Completed)
 * ✅ NEW: Added requestType filter
 */
/**
 * Handle history view with pagination and filters
 * ✅ ENHANCED: Hide requests that have ANY WorkTask (even if Completed)
 * ✅ NEW: Added requestType filter
 */
private void handleHistory(HttpServletRequest request, HttpServletResponse response, int managerId)
        throws ServletException, IOException, SQLException {

    // Lấy các tham số filter và search
    String keyword = request.getParameter("keyword");
    String priority = request.getParameter("priority");
    String statusFilter = request.getParameter("statusFilter");
    String requestTypeFilter = request.getParameter("requestTypeFilter"); // ✅ NEW

    // Lấy số trang
    int page = 1;
    String pageParam = request.getParameter("page");
    if (pageParam != null && !pageParam.isEmpty()) {
        try {
            page = Integer.parseInt(pageParam);
            if (page < 1) page = 1;
        } catch (NumberFormatException e) {
            page = 1;
        }
    }

    // ✅ BƯỚC 1: Lấy toàn bộ request lịch sử (không phải Awaiting Approval)
    List<ServiceRequest> allRequests = serviceRequestDAO.getAllRequestsHistory();
    List<ServiceRequest> filteredRequests = allRequests.stream()
            .filter(req -> !"Awaiting Approval".equalsIgnoreCase(req.getStatus()))
            .collect(Collectors.toList());

    // ✅ BƯỚC 2: ẨN CÁC REQUEST ĐÃ CÓ WORKTASK (dù Completed hay Active)
    WorkTaskDAO workTaskDAO = new WorkTaskDAO();
    List<ServiceRequest> visibleRequests = new ArrayList<>();
    
    for (ServiceRequest req : filteredRequests) {
        List<WorkTask> existingTasks = workTaskDAO.findByRequestId(req.getRequestId());
        if (existingTasks.isEmpty()) {
            visibleRequests.add(req);
        }
    }

    // ✅ BƯỚC 3: Áp dụng search trên danh sách đã lọc
    if (keyword != null && !keyword.trim().isEmpty()) {
        String keywordLower = keyword.trim().toLowerCase();
        visibleRequests = visibleRequests.stream()
                .filter(req -> req.getDescription().toLowerCase().contains(keywordLower)
                        || String.valueOf(req.getRequestId()).contains(keyword.trim())
                        || (req.getCustomerName() != null && req.getCustomerName().toLowerCase().contains(keywordLower))
                        || (req.getEquipmentName() != null && req.getEquipmentName().toLowerCase().contains(keywordLower)))
                .collect(Collectors.toList());
    }

    // ✅ BƯỚC 4: Áp dụng filter Priority, Status & RequestType
    List<ServiceRequest> finalFilteredRequests = new ArrayList<>();
    for (ServiceRequest req : visibleRequests) {
        boolean matchesPriority = (priority == null || priority.trim().isEmpty() ||
                priority.equalsIgnoreCase(req.getPriorityLevel()));

        boolean matchesStatus = true;
        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            matchesStatus = statusFilter.equalsIgnoreCase(req.getStatus());
        }

        // ✅ NEW: Filter by requestType
        boolean matchesRequestType = true;
        if (requestTypeFilter != null && !requestTypeFilter.trim().isEmpty()) {
            matchesRequestType = requestTypeFilter.equalsIgnoreCase(req.getRequestType());
        }

        if (matchesPriority && matchesStatus && matchesRequestType) {
            finalFilteredRequests.add(req);
        }
    }

    // ✅ BƯỚC 5: Tính toán phân trang
    int totalRecords = finalFilteredRequests.size();
    int totalPages = (int) Math.ceil((double) totalRecords / RECORDS_PER_PAGE);

    if (totalPages > 0 && page > totalPages) {
        page = totalPages;
    }

    int startIndex = (page - 1) * RECORDS_PER_PAGE;
    int endIndex = Math.min(startIndex + RECORDS_PER_PAGE, totalRecords);

    List<ServiceRequest> requests = new ArrayList<>();
    if (startIndex < totalRecords) {
        requests = finalFilteredRequests.subList(startIndex, endIndex);
    }

    // ✅ BƯỚC 6: Thống kê (dựa trên danh sách đã lọc)
    int totalRequests = finalFilteredRequests.size();
    int approvedCount = (int) finalFilteredRequests.stream()
            .filter(req -> "Approved".equalsIgnoreCase(req.getStatus())).count();
    int rejectedCount = (int) finalFilteredRequests.stream()
            .filter(req -> "Rejected".equalsIgnoreCase(req.getStatus())).count();

    // ✅ BƯỚC 7: Gửi dữ liệu sang JSP
    request.setAttribute("requests", requests);
    request.setAttribute("totalCount", totalRequests);
    request.setAttribute("approvedCount", approvedCount);
    request.setAttribute("rejectedCount", rejectedCount);
    request.setAttribute("viewMode", "history");
    request.setAttribute("currentPage", page);
    request.setAttribute("totalPages", totalPages);
    request.setAttribute("totalRecords", totalRecords);
    
    // Giữ lại các tham số filter
    request.setAttribute("keyword", keyword);
    request.setAttribute("filterPriority", priority);
    request.setAttribute("statusFilter", statusFilter);
    request.setAttribute("requestTypeFilter", requestTypeFilter); // ✅ NEW
    
    // Đánh dấu có filter/search
    boolean hasFilters = (keyword != null && !keyword.trim().isEmpty()) ||
                        (priority != null && !priority.trim().isEmpty()) ||
                        (statusFilter != null && !statusFilter.trim().isEmpty()) ||
                        (requestTypeFilter != null && !requestTypeFilter.trim().isEmpty()); // ✅ NEW
    request.setAttribute("searchMode", hasFilters);
    request.setAttribute("filterMode", hasFilters);

    request.getRequestDispatcher("/TechnicalManagerApproval.jsp").forward(request, response);
}


    /**
     * Handle search with pagination
     */
   private void handleSearch(HttpServletRequest request, HttpServletResponse response, int managerId)
        throws ServletException, IOException, SQLException {

    String keyword = request.getParameter("keyword");
    String viewMode = request.getParameter("viewMode");

    // Get page number
    int page = 1;
    String pageParam = request.getParameter("page");
    if (pageParam != null && !pageParam.isEmpty()) {
        try {
            page = Integer.parseInt(pageParam);
            if (page < 1) page = 1;
        } catch (NumberFormatException e) {
            page = 1;
        }
    }

    if (keyword == null || keyword.trim().isEmpty()) {
        if ("history".equalsIgnoreCase(viewMode)) {
            handleHistory(request, response, managerId);
        } else {
            displayAssignedRequests(request, response, managerId);
        }
        return;
    }

    // ✅ Get data based on view mode
    List<ServiceRequest> allRequests;
    if ("history".equalsIgnoreCase(viewMode)) {
        allRequests = serviceRequestDAO.getAllRequestsHistory().stream()
                .filter(req -> !"Awaiting Approval".equalsIgnoreCase(req.getStatus()))
                .collect(Collectors.toList());
    } else {
        allRequests = serviceRequestDAO.getPendingRequestsWithDetails();
    }

    // ✅ FILTER OUT REQUESTS WITH WORKTASK (for history view only)
    if ("history".equalsIgnoreCase(viewMode)) {
        WorkTaskDAO workTaskDAO = new WorkTaskDAO();
        List<ServiceRequest> visibleRequests = new ArrayList<>();
        
        for (ServiceRequest req : allRequests) {
            List<WorkTask> existingTasks = workTaskDAO.findByRequestId(req.getRequestId());
            if (existingTasks.isEmpty()) {
                visibleRequests.add(req);
            }
        }
        allRequests = visibleRequests;
    }

    // Filter by keyword
    String keywordLower = keyword.trim().toLowerCase();
    List<ServiceRequest> filteredRequests = allRequests.stream()
            .filter(req -> req.getDescription().toLowerCase().contains(keywordLower)
                    || String.valueOf(req.getRequestId()).contains(keyword.trim())
                    || (req.getCustomerName() != null && req.getCustomerName().toLowerCase().contains(keywordLower))
                    || (req.getEquipmentName() != null && req.getEquipmentName().toLowerCase().contains(keywordLower)))
            .collect(Collectors.toList());

    // Calculate pagination
    int totalRecords = filteredRequests.size();
    int totalPages = (int) Math.ceil((double) totalRecords / RECORDS_PER_PAGE);
    
    if (totalPages > 0 && page > totalPages) {
        page = totalPages;
    }
    
    int startIndex = (page - 1) * RECORDS_PER_PAGE;
    int endIndex = Math.min(startIndex + RECORDS_PER_PAGE, totalRecords);
    
    List<ServiceRequest> requests = new ArrayList<>();
    if (startIndex < totalRecords) {
        requests = filteredRequests.subList(startIndex, endIndex);
    }

    // Set statistics based on view mode
    if ("history".equalsIgnoreCase(viewMode)) {
        int totalCount = filteredRequests.size();
        int approvedCount = (int) filteredRequests.stream()
                .filter(r -> "Approved".equalsIgnoreCase(r.getStatus())).count();
        int rejectedCount = (int) filteredRequests.stream()
                .filter(r -> "Rejected".equalsIgnoreCase(r.getStatus())).count();

        request.setAttribute("totalCount", totalCount);
        request.setAttribute("approvedCount", approvedCount);
        request.setAttribute("rejectedCount", rejectedCount);
    } else {
        int awaitingApprovalCount = serviceRequestDAO.getRequestCountByStatus("Awaiting Approval");
        int urgentCount = serviceRequestDAO.getRequestCountByPriority("Urgent", "Awaiting Approval");
        int todayCount = serviceRequestDAO.getRequestsCreatedTodayByStatus("Awaiting Approval");
        int approvedToday = requestApprovalDAO.getApprovalsToday(managerId);

        request.setAttribute("awaitingApprovalCount", awaitingApprovalCount);
        request.setAttribute("urgentCount", urgentCount);
        request.setAttribute("todayCount", todayCount);
        request.setAttribute("approvedToday", approvedToday);
    }

    request.setAttribute("requests", requests);
    request.setAttribute("keyword", keyword);
    request.setAttribute("searchMode", true);
    request.setAttribute("viewMode", viewMode);
    request.setAttribute("currentPage", page);
    request.setAttribute("totalPages", totalPages);
    request.setAttribute("totalRecords", totalRecords);

    request.getRequestDispatcher("/TechnicalManagerApproval.jsp").forward(request, response);
}

/**
 * Handle filter with pagination and new status/requestType filters for history
 * ✅ UPDATED: Support requestType filter
 */
private void handleFilter(HttpServletRequest request, HttpServletResponse response, int managerId)
        throws ServletException, IOException, SQLException {

    String priority = request.getParameter("priority");
    String urgency = request.getParameter("urgency");
    String statusFilter = request.getParameter("statusFilter");
    String requestTypeFilter = request.getParameter("requestTypeFilter"); // ✅ NEW
    String viewMode = request.getParameter("viewMode");

    // Get page number
    int page = 1;
    String pageParam = request.getParameter("page");
    if (pageParam != null && !pageParam.isEmpty()) {
        try {
            page = Integer.parseInt(pageParam);
            if (page < 1) page = 1;
        } catch (NumberFormatException e) {
            page = 1;
        }
    }

    // ✅ Get data based on view mode
    List<ServiceRequest> allRequests;
    if ("history".equalsIgnoreCase(viewMode)) {
        allRequests = serviceRequestDAO.getAllRequestsHistory().stream()
                .filter(req -> !"Awaiting Approval".equalsIgnoreCase(req.getStatus()))
                .collect(Collectors.toList());
    } else {
        allRequests = serviceRequestDAO.getPendingRequestsWithDetails();
    }

    // ✅ FILTER OUT REQUESTS WITH WORKTASK (for history view only)
    if ("history".equalsIgnoreCase(viewMode)) {
        WorkTaskDAO workTaskDAO = new WorkTaskDAO();
        List<ServiceRequest> visibleRequests = new ArrayList<>();
        
        for (ServiceRequest req : allRequests) {
            List<WorkTask> existingTasks = workTaskDAO.findByRequestId(req.getRequestId());
            if (existingTasks.isEmpty()) {
                visibleRequests.add(req);
            }
        }
        allRequests = visibleRequests;
    }

    // Apply filters
    List<ServiceRequest> filteredRequests = new ArrayList<>();
    for (ServiceRequest req : allRequests) {
        boolean matchesPriority = (priority == null || priority.trim().isEmpty() ||
                priority.equalsIgnoreCase(req.getPriorityLevel()));

        boolean matchesUrgency = true;
        // Only apply urgency filter for non-history view
        if (!"history".equalsIgnoreCase(viewMode) && urgency != null && !urgency.trim().isEmpty()) {
            int daysPending = req.getDaysPending();
            switch (urgency) {
                case "Urgent":
                    matchesUrgency = daysPending >= 7;
                    break;
                case "High":
                    matchesUrgency = daysPending >= 3 && daysPending < 7;
                    break;
                case "Normal":
                    matchesUrgency = daysPending < 3;
                    break;
            }
        }

        boolean matchesStatus = true;
        // Apply status filter for history view
        if ("history".equalsIgnoreCase(viewMode) && statusFilter != null && !statusFilter.trim().isEmpty()) {
            matchesStatus = statusFilter.equalsIgnoreCase(req.getStatus());
        }

        // ✅ NEW: Apply requestType filter for history view
        boolean matchesRequestType = true;
        if ("history".equalsIgnoreCase(viewMode) && requestTypeFilter != null && !requestTypeFilter.trim().isEmpty()) {
            matchesRequestType = requestTypeFilter.equalsIgnoreCase(req.getRequestType());
        }

        if (matchesPriority && matchesUrgency && matchesStatus && matchesRequestType) {
            filteredRequests.add(req);
        }
    }

    // Calculate pagination
    int totalRecords = filteredRequests.size();
    int totalPages = (int) Math.ceil((double) totalRecords / RECORDS_PER_PAGE);
    
    if (totalPages > 0 && page > totalPages) {
        page = totalPages;
    }
    
    int startIndex = (page - 1) * RECORDS_PER_PAGE;
    int endIndex = Math.min(startIndex + RECORDS_PER_PAGE, totalRecords);
    
    List<ServiceRequest> requests = new ArrayList<>();
    if (startIndex < totalRecords) {
        requests = filteredRequests.subList(startIndex, endIndex);
    }

    // Set statistics based on view mode
    if ("history".equalsIgnoreCase(viewMode)) {
        int totalCount = filteredRequests.size();
        int approvedCount = (int) filteredRequests.stream()
                .filter(r -> "Approved".equalsIgnoreCase(r.getStatus())).count();
        int rejectedCount = (int) filteredRequests.stream()
                .filter(r -> "Rejected".equalsIgnoreCase(r.getStatus())).count();

        request.setAttribute("totalCount", totalCount);
        request.setAttribute("approvedCount", approvedCount);
        request.setAttribute("rejectedCount", rejectedCount);
        request.setAttribute("statusFilter", statusFilter);
        request.setAttribute("requestTypeFilter", requestTypeFilter); // ✅ NEW
    } else {
        int awaitingApprovalCount = serviceRequestDAO.getRequestCountByStatus("Awaiting Approval");
        int urgentCount = serviceRequestDAO.getRequestCountByPriority("Urgent", "Awaiting Approval");
        int todayCount = serviceRequestDAO.getRequestsCreatedTodayByStatus("Awaiting Approval");
        int approvedToday = requestApprovalDAO.getApprovalsToday(managerId);

        request.setAttribute("awaitingApprovalCount", awaitingApprovalCount);
        request.setAttribute("urgentCount", urgentCount);
        request.setAttribute("todayCount", todayCount);
        request.setAttribute("approvedToday", approvedToday);
        request.setAttribute("filterUrgency", urgency);
    }

    request.setAttribute("requests", requests);
    request.setAttribute("filterPriority", priority);
    request.setAttribute("filterMode", true);
    request.setAttribute("viewMode", viewMode);
    request.setAttribute("currentPage", page);
    request.setAttribute("totalPages", totalPages);
    request.setAttribute("totalRecords", totalRecords);

    request.getRequestDispatcher("/TechnicalManagerApproval.jsp").forward(request, response);
}

    /**
     * Handle request approval
     */
 private void handleApproveRequest(HttpServletRequest request, HttpServletResponse response, 
                                  int managerId, HttpSession session)
        throws ServletException, IOException, SQLException {

    String requestIdStr = request.getParameter("requestId");
    String estimatedEffortStr = request.getParameter("estimatedEffort");
    String recommendedSkills = request.getParameter("recommendedSkills");
    String approvalNotes = request.getParameter("approvalNotes");
    String internalNotes = request.getParameter("internalNotes");
    String assignedTechnicianIdStr = request.getParameter("assignedTechnicianId");

    if (requestIdStr == null || requestIdStr.trim().isEmpty()) {
        session.setAttribute("error", "Invalid request ID!");
        response.sendRedirect(request.getContextPath() + "/technicalManagerApproval");
        return;
    }

    if (estimatedEffortStr == null || estimatedEffortStr.trim().isEmpty()) {
        session.setAttribute("error", "Please enter estimated time!");
        response.sendRedirect(request.getContextPath() + "/technicalManagerApproval");
        return;
    }

    int requestId;
    double estimatedEffort;
    Integer assignedTechnicianId = null;

    try {
        requestId = Integer.parseInt(requestIdStr.trim());
        estimatedEffort = Double.parseDouble(estimatedEffortStr.trim());
        
        if (assignedTechnicianIdStr != null && !assignedTechnicianIdStr.trim().isEmpty() && 
            !"0".equals(assignedTechnicianIdStr.trim())) {
            assignedTechnicianId = Integer.parseInt(assignedTechnicianIdStr.trim());
        }
    } catch (NumberFormatException e) {
        session.setAttribute("error", "Invalid data!");
        response.sendRedirect(request.getContextPath() + "/technicalManagerApproval");
        return;
    }

    if (estimatedEffort <= 0 || estimatedEffort > 1000) {
        session.setAttribute("error", "Estimated time must be between 0.5 and 1000 hours!");
        response.sendRedirect(request.getContextPath() + "/technicalManagerApproval");
        return;
    }

    // ✅ KHÔNG LƯU GHI CHÚ NỘI BỘ VÀO DB (vì ServiceRequest không có cột notes)
    // Chỉ log ra console để manager theo dõi
    if (internalNotes != null && !internalNotes.trim().isEmpty()) {
        System.out.println("📝 Internal Notes for Request #" + requestId + ": " + internalNotes.trim());
    }
    
    dto.ServiceRequestUpdateResult result = serviceRequestDAO.updateServiceRequestStatusWithResult(
        requestId, "Approved", 
        "",  // ✅ Để trống vì không có cột notes
        managerId, assignedTechnicianId
    );

    if (result.isSuccess()) {
        session.setAttribute("success", "Duyệt yêu cầu thành công" + 
            (assignedTechnicianId != null ? " và đã phân công kỹ thuật viên!" : "!"));

        // ✅ GỬI THÔNG BÁO CHO KHÁCH HÀNG VỚI GHI CHÚ DUYỆT + THỜI GIAN DỰ KIẾN
        try {
            ServiceRequestDetailDTO2 detail = serviceRequestDAO.getRequestDetailById(requestId);
            if (detail != null) {
                int customerId = detail.getCreatedBy();
                Integer contractEquipmentId = contractDAO.getContractEquipmentIdByContractAndEquipment(
                    detail.getContractId(), detail.getEquipmentId());
                
                Account tm = accountDAO.getAccountById(managerId);
                String tmName = (tm != null && tm.getFullName() != null) ? 
                               tm.getFullName() : "Technical Manager";

                String equipInfo = (detail.getEquipmentModel() != null ? 
                                   detail.getEquipmentModel() : "Equipment") +
                                   (detail.getSerialNumber() != null ? 
                                   (" (" + detail.getSerialNumber() + ")") : "");
                
                // ✅ TẠO MESSAGE CHO KHÁCH HÀNG VỚI GHI CHÚ DUYỆT + THỜI GIAN DỰ KIẾN
                StringBuilder message = new StringBuilder();
                message.append("Yêu cầu dịch vụ #").append(requestId)
                       .append(" cho thiết bị ").append(equipInfo)
                       .append(" đã được phê duyệt bởi ").append(tmName).append(".");
                
                // ✅ THÊM THỜI GIAN DỰ KIẾN
                message.append("\n\nThời gian dự kiến hoàn thành: ").append(estimatedEffort).append(" giờ");
                
                // ✅ THÊM GHI CHÚ DUYỆT VÀO MESSAGE
                if (approvalNotes != null && !approvalNotes.trim().isEmpty()) {
                    message.append("\n\nGhi chú: ").append(approvalNotes.trim());
                }
                
                if (recommendedSkills != null && !recommendedSkills.trim().isEmpty()) {
                    message.append("\n\nKỹ năng yêu cầu: ").append(recommendedSkills.trim());
                }

                // Tạo notification
                Notification n = new Notification();
                n.setAccountId(customerId);
                n.setNotificationType("System");
                n.setContractEquipmentId(contractEquipmentId != null ? contractEquipmentId : 0);
                n.setStatus("Unread");
                n.setMessage(message.toString());
                
                notificationDAO.createNotification(n);
                
                System.out.println("✅ Notification sent to customer #" + customerId + 
                                 " for approved request #" + requestId + 
                                 " (Estimated: " + estimatedEffort + "h)");
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            session.setAttribute("warning", "Yêu cầu đã được duyệt nhưng có lỗi khi gửi thông báo.");
        }
    } else {
        session.setAttribute("error", result.getMessage());
    }

    response.sendRedirect(request.getContextPath() + "/technicalManagerApproval");
}

// ========================================================================
// ✅ HÀM 2: HANDLE REJECT REQUEST - WITHOUT INTERNAL NOTES STORAGE
// ========================================================================
private void handleRejectRequest(HttpServletRequest request, HttpServletResponse response, 
                                 int managerId, HttpSession session)
        throws ServletException, IOException, SQLException {

    String requestIdStr = request.getParameter("requestId");
    String rejectionReason = request.getParameter("rejectionReason");
    String rejectionNotes = request.getParameter("rejectionNotes");
    String internalNotes = request.getParameter("internalNotes");

    // Validation
    if (requestIdStr == null || requestIdStr.trim().isEmpty()) {
        session.setAttribute("error", "Mã yêu cầu không hợp lệ!");
        response.sendRedirect(request.getContextPath() + "/technicalManagerApproval");
        return;
    }

    if (rejectionReason == null || rejectionReason.trim().isEmpty()) {
        session.setAttribute("error", "Please select a rejection reason!");
        response.sendRedirect(request.getContextPath() + "/technicalManagerApproval");
        return;
    }

    int requestId;
    try {
        requestId = Integer.parseInt(requestIdStr.trim());
    } catch (NumberFormatException e) {
        session.setAttribute("error", "Invalid request ID!");
        response.sendRedirect(request.getContextPath() + "/technicalManagerApproval");
        return;
    }

    // ✅ KHÔNG LƯU GHI CHÚ NỘI BỘ VÀO DB (vì ServiceRequest không có cột notes)
    // Chỉ log ra console để manager theo dõi
    if (internalNotes != null && !internalNotes.trim().isEmpty()) {
        System.out.println("📝 Internal Notes for Rejected Request #" + requestId + ": " + internalNotes.trim());
    }
    
    dto.ServiceRequestUpdateResult result = serviceRequestDAO.updateServiceRequestStatusWithResult(
        requestId, "Rejected", 
        "",  // ✅ Để trống vì không có cột notes
        managerId, null
    );

    if (result.isSuccess()) {
        session.setAttribute("success", "Yêu cầu đã được từ chối thành công!");

        // ✅ GỬI THÔNG BÁO CHO KHÁCH HÀNG VỚI LÝ DO VÀ GHI CHÚ TỪ CHỐI
        try {
            ServiceRequestDetailDTO2 detail = serviceRequestDAO.getRequestDetailById(requestId);
            if (detail != null) {
                int customerId = detail.getCreatedBy();
                Integer contractEquipmentId = contractDAO.getContractEquipmentIdByContractAndEquipment(
                    detail.getContractId(), detail.getEquipmentId());
                
                Account tm = accountDAO.getAccountById(managerId);
                String tmName = (tm != null && tm.getFullName() != null) ? 
                               tm.getFullName() : "Technical Manager";

                String equipInfo = (detail.getEquipmentModel() != null ? 
                                   detail.getEquipmentModel() : "Equipment") +
                                   (detail.getSerialNumber() != null ? 
                                   (" (" + detail.getSerialNumber() + ")") : "");
                
                // ✅ TẠO MESSAGE CHO KHÁCH HÀNG VỚI LÝ DO VÀ GHI CHÚ TỪ CHỐI
                StringBuilder message = new StringBuilder();
                message.append("Yêu cầu dịch vụ #").append(requestId)
                       .append(" cho thiết bị ").append(equipInfo)
                       .append(" đã bị từ chối bởi ").append(tmName).append(".");
                
                // ✅ THÊM LÝ DO TỪ CHỐI
                if (rejectionReason != null && !rejectionReason.trim().isEmpty()) {
                    message.append("\n\nLý do: ").append(rejectionReason.trim());
                }
                
                // ✅ THÊM GHI CHÚ TỪ CHỐI (HIỂN thị cho khách hàng)
                if (rejectionNotes != null && !rejectionNotes.trim().isEmpty()) {
                    message.append("\n\nGhi chú: ").append(rejectionNotes.trim());
                }

                // Tạo notification
                Notification n = new Notification();
                n.setAccountId(customerId);
                n.setNotificationType("System");
                n.setContractEquipmentId(contractEquipmentId != null ? contractEquipmentId : 0);
                n.setStatus("Unread");
                n.setMessage(message.toString());
                
                notificationDAO.createNotification(n);
                
                System.out.println("✅ Notification sent to customer #" + customerId + 
                                 " for rejected request #" + requestId);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            session.setAttribute("warning", "Yêu cầu đã được từ chối nhưng có lỗi khi gửi thông báo.");
        }
    } else {
        session.setAttribute("error", result.getMessage());
    }

    response.sendRedirect(request.getContextPath() + "/technicalManagerApproval");
}

    /**
     * Handle AJAX request to get request details
     */
    private void handleGetRequestDetails(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        String requestIdStr = request.getParameter("requestId");
        
        if (requestIdStr == null || requestIdStr.trim().isEmpty()) {
            response.getWriter().write("{\"error\": \"Request ID is required\"}");
            return;
        }
        
        try {
            int requestId = Integer.parseInt(requestIdStr);
            ServiceRequestDetailDTO2 requestDetail = serviceRequestDAO.getRequestDetailById(requestId);
            
            if (requestDetail != null) {
                StringBuilder json = new StringBuilder();
                json.append("{");
                json.append("\"requestId\": ").append(requestDetail.getRequestId()).append(",");
                json.append("\"requestDate\": \"").append(requestDetail.getRequestDate() != null ? requestDetail.getRequestDate().toString() : "").append("\",");
                json.append("\"status\": \"").append(escapeJson(requestDetail.getStatus())).append("\",");
                json.append("\"priorityLevel\": \"").append(escapeJson(requestDetail.getPriorityLevel())).append("\",");
                json.append("\"customerName\": \"").append(escapeJson(requestDetail.getCustomerName())).append("\",");
                json.append("\"customerEmail\": \"").append(escapeJson(requestDetail.getCustomerEmail())).append("\",");
                json.append("\"customerPhone\": \"").append(escapeJson(requestDetail.getCustomerPhone())).append("\",");
                json.append("\"equipmentId\": ").append(requestDetail.getEquipmentId()).append(",");
                json.append("\"equipmentName\": \"").append(escapeJson(requestDetail.getEquipmentModel())).append("\",");
                json.append("\"serialNumber\": \"").append(escapeJson(requestDetail.getSerialNumber())).append("\",");
                json.append("\"requestType\": \"").append(escapeJson(requestDetail.getRequestType())).append("\",");
                json.append("\"description\": \"").append(escapeJson(requestDetail.getDescription())).append("\"");
                json.append("}");
                
                response.getWriter().write(json.toString());
            } else {
                response.getWriter().write("{\"error\": \"Request not found\"}");
            }
        } catch (NumberFormatException e) {
            response.getWriter().write("{\"error\": \"Invalid request ID format\"}");
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"error\": \"Error retrieving request details\"}");
        }
    }
    
    /**
     * Escape special characters for JSON
     */
    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r")
                  .replace("\t", "\\t");
    }
}