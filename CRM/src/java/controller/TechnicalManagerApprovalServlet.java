package controller;

import dal.ServiceRequestDAO;
import dal.RequestApprovalDAO;
import dal.AccountDAO;
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

@WebServlet(name = "TechnicalManagerApprovalServlet", urlPatterns = {"/technicalManagerApproval"})
public class TechnicalManagerApprovalServlet extends HttpServlet {

    private ServiceRequestDAO serviceRequestDAO;
    private RequestApprovalDAO requestApprovalDAO;
    private AccountDAO accountDAO;
    private AccountRoleService accountRoleService;

    @Override
    public void init() throws ServletException {
        serviceRequestDAO = new ServiceRequestDAO();
        requestApprovalDAO = new RequestApprovalDAO();
        accountDAO = new AccountDAO();
        accountRoleService = new AccountRoleService();
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
     * Display pending service requests for Technical Manager approval
     */
    private void displayAssignedRequests(HttpServletRequest request, HttpServletResponse response, int managerId)
            throws ServletException, IOException, SQLException {

        // Get all pending requests for Technical Manager approval
        List<ServiceRequest> requests = serviceRequestDAO.getPendingRequestsWithDetails();
        
        // Debug logging
        System.out.println("DEBUG - Total requests retrieved: " + requests.size());
        for (ServiceRequest req : requests) {
            System.out.println("DEBUG - Request ID: " + req.getRequestId() + 
                             ", Status: " + req.getStatus() + 
                             ", Customer: " + req.getCustomerName());
        }

        // Get statistics for Technical Manager dashboard
        int awaitingApprovalCount = serviceRequestDAO.getRequestCountByStatus("Awaiting Approval");
        int urgentCount = serviceRequestDAO.getRequestCountByPriority("Urgent", "Awaiting Approval");
        int todayCount = serviceRequestDAO.getRequestsCreatedTodayByStatus("Awaiting Approval");
        int approvedToday = requestApprovalDAO.getApprovalsToday(managerId);

        // Get available technicians for assignment dropdown
        List<Account> technicians = accountDAO.getAccountsByRole("Technician");

        // Set attributes for JSP
        request.setAttribute("requests", requests);
        request.setAttribute("awaitingApprovalCount", awaitingApprovalCount);
        request.setAttribute("urgentCount", urgentCount);
        request.setAttribute("todayCount", todayCount);
        request.setAttribute("approvedToday", approvedToday);
        request.setAttribute("technicians", technicians);
        request.setAttribute("viewMode", "assigned");

        request.getRequestDispatcher("/TechnicalManagerApproval.jsp").forward(request, response);
    }

    /**
     * Handle history view functionality for technical managers
     */
    private void handleHistory(HttpServletRequest request, HttpServletResponse response, int managerId)
            throws ServletException, IOException, SQLException {

        // Get all requests history for technical managers
        List<ServiceRequest> requests = serviceRequestDAO.getAllRequestsHistory();

        // Get statistics
        int totalRequests = requests.size();
        int approvedCount = (int) requests.stream().filter(req -> "Approved".equals(req.getStatus())).count();
        int rejectedCount = (int) requests.stream().filter(req -> "Rejected".equals(req.getStatus())).count();
        int pendingCount = (int) requests.stream().filter(req -> "Pending".equals(req.getStatus())).count();
        int awaitingApprovalCount = (int) requests.stream().filter(req -> "Awaiting Approval".equals(req.getStatus())).count();

        // Set attributes for JSP
        request.setAttribute("requests", requests);
        request.setAttribute("totalRequests", totalRequests);
        request.setAttribute("approvedCount", approvedCount);
        request.setAttribute("rejectedCount", rejectedCount);
        request.setAttribute("pendingCount", pendingCount);
        request.setAttribute("awaitingApprovalCount", awaitingApprovalCount);
        request.setAttribute("viewMode", "history");

        request.getRequestDispatcher("/TechnicalManagerApproval.jsp").forward(request, response);
    }

    /**
     * Handle search functionality for requests with status >= 'Awaiting Approval'
     */
    private void handleSearch(HttpServletRequest request, HttpServletResponse response, int managerId)
            throws ServletException, IOException, SQLException {

        String keyword = request.getParameter("keyword");

        if (keyword == null || keyword.trim().isEmpty()) {
            displayAssignedRequests(request, response, managerId);
            return;
        }

        // Get all requests with status >= 'Awaiting Approval' and filter by keyword
        List<ServiceRequest> allRequests = serviceRequestDAO.getPendingRequestsWithDetails();
        List<ServiceRequest> requests = new ArrayList<>();
        
        // Filter by keyword (description, requestId, or customer name if available)
        String keywordLower = keyword.trim().toLowerCase();
        for (ServiceRequest req : allRequests) {
            if (req.getDescription().toLowerCase().contains(keywordLower) ||
                String.valueOf(req.getRequestId()).contains(keyword.trim()) ||
                (req.getCustomerName() != null && req.getCustomerName().toLowerCase().contains(keywordLower))) {
                requests.add(req);
            }
        }

        // Get statistics
        int awaitingApprovalCount = serviceRequestDAO.getRequestCountByStatus("Awaiting Approval");
        int urgentCount = serviceRequestDAO.getRequestCountByPriority("Urgent", "Awaiting Approval");
        int todayCount = serviceRequestDAO.getRequestsCreatedTodayByStatus("Awaiting Approval");
        int approvedToday = requestApprovalDAO.getApprovalsToday(managerId);

        request.setAttribute("requests", requests);
        request.setAttribute("awaitingApprovalCount", awaitingApprovalCount);
        request.setAttribute("urgentCount", urgentCount);
        request.setAttribute("todayCount", todayCount);
        request.setAttribute("approvedToday", approvedToday);
        request.setAttribute("keyword", keyword);
        request.setAttribute("searchMode", true);
        request.setAttribute("viewMode", "assigned");

        request.getRequestDispatcher("/TechnicalManagerApproval.jsp").forward(request, response);
    }

    /**
     * Handle filter functionality for requests with status >= 'Awaiting Approval'
     */
    private void handleFilter(HttpServletRequest request, HttpServletResponse response, int managerId)
            throws ServletException, IOException, SQLException {

        String priority = request.getParameter("priority");
        String urgency = request.getParameter("urgency");

        // Get all requests with status >= 'Awaiting Approval'
        List<ServiceRequest> allRequests = serviceRequestDAO.getPendingRequestsWithDetails();
        List<ServiceRequest> requests = new ArrayList<>();

        // Apply client-side filtering
        for (ServiceRequest req : allRequests) {
            boolean matchesPriority = (priority == null || priority.trim().isEmpty() || 
                                     priority.equals(req.getPriorityLevel()));
            
            boolean matchesUrgency = true;
            if (urgency != null && !urgency.trim().isEmpty()) {
                int daysPending = req.getDaysPending();
                switch (urgency) {
                    case "Urgent":
                        matchesUrgency = daysPending >= 7;
                        break;
                    case "High":
                        matchesUrgency = daysPending >= 3;
                        break;
                    case "Normal":
                        matchesUrgency = daysPending < 3;
                        break;
                }
            }
            
            if (matchesPriority && matchesUrgency) {
                requests.add(req);
            }
        }

        // Get statistics
        int awaitingApprovalCount = serviceRequestDAO.getRequestCountByStatus("Awaiting Approval");
        int urgentCount = serviceRequestDAO.getRequestCountByPriority("Urgent", "Awaiting Approval");
        int todayCount = serviceRequestDAO.getRequestsCreatedTodayByStatus("Awaiting Approval");
        int approvedToday = requestApprovalDAO.getApprovalsToday(managerId);

        request.setAttribute("requests", requests);
        request.setAttribute("awaitingApprovalCount", awaitingApprovalCount);
        request.setAttribute("urgentCount", urgentCount);
        request.setAttribute("todayCount", todayCount);
        request.setAttribute("approvedToday", approvedToday);
        request.setAttribute("filterPriority", priority);
        request.setAttribute("filterUrgency", urgency);
        request.setAttribute("filterMode", true);
        request.setAttribute("viewMode", "assigned");

        request.getRequestDispatcher("/TechnicalManagerApproval.jsp").forward(request, response);
    }

    /**
     * Handle request approval
     */
    private void handleApproveRequest(HttpServletRequest request, HttpServletResponse response, int managerId, HttpSession session)
            throws ServletException, IOException, SQLException {

        String requestIdStr = request.getParameter("requestId");
        String estimatedEffortStr = request.getParameter("estimatedEffort");
        String recommendedSkills = request.getParameter("recommendedSkills");
        String approvalNotes = request.getParameter("approvalNotes");
        String internalNotes = request.getParameter("internalNotes");
        String assignedTechnicianIdStr = request.getParameter("assignedTechnicianId");

        // Validation
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
            
            // Parse technician ID if provided
            if (assignedTechnicianIdStr != null && !assignedTechnicianIdStr.trim().isEmpty() && !"0".equals(assignedTechnicianIdStr.trim())) {
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

        // Update service request status and create approval record with technician assignment
        // All validation is now handled within the DAO transaction for thread safety
        dto.ServiceRequestUpdateResult result = serviceRequestDAO.updateServiceRequestStatusWithResult(requestId, "Approved", 
            (approvalNotes != null ? approvalNotes.trim() : "") + 
            (internalNotes != null ? " | Internal: " + internalNotes : ""), managerId, assignedTechnicianId);

        if (result.isSuccess()) {
            session.setAttribute("success", "Request approved successfully" + 
                (assignedTechnicianId != null ? " and technician assigned!" : "!"));
        } else {
            session.setAttribute("error", result.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/technicalManagerApproval");
    }

    /**
     * Handle request rejection
     */
    private void handleRejectRequest(HttpServletRequest request, HttpServletResponse response, int managerId, HttpSession session)
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

        // Update service request status and create approval record
        // All validation is now handled within the DAO transaction for thread safety
        dto.ServiceRequestUpdateResult result = serviceRequestDAO.updateServiceRequestStatusWithResult(requestId, "Rejected", 
            (rejectionNotes != null ? rejectionNotes.trim() : "") + 
            (internalNotes != null ? " | Internal: " + internalNotes : ""), managerId, null);

        if (result.isSuccess()) {
            session.setAttribute("success", "Request rejected successfully!");
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
                // Convert to JSON manually (simple approach)
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
                json.append("\"equipmentModel\": \"").append(escapeJson(requestDetail.getEquipmentModel())).append("\",");
                json.append("\"serialNumber\": \"").append(escapeJson(requestDetail.getSerialNumber())).append("\",");
                json.append("\"contractType\": \"").append(escapeJson(requestDetail.getContractType())).append("\",");
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