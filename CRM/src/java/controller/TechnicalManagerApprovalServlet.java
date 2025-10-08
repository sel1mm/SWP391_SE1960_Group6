package controller;

import dal.ServiceRequestDAO;
import dal.RequestApprovalDAO;
import model.ServiceRequest;
import model.RequestApproval;
import model.Account;
import service.AccountRoleService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.sql.SQLException;
import java.util.Date;

@WebServlet(name = "TechnicalManagerApprovalServlet", urlPatterns = {"/technicalManagerApproval"})
public class TechnicalManagerApprovalServlet extends HttpServlet {

    private ServiceRequestDAO serviceRequestDAO;
    private RequestApprovalDAO requestApprovalDAO;
    private AccountRoleService accountRoleService;

    @Override
    public void init() throws ServletException {
        serviceRequestDAO = new ServiceRequestDAO();
        requestApprovalDAO = new RequestApprovalDAO();
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
            } else {
                displayPendingRequests(request, response, accountId);
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
     * Display pending service requests for approval
     */
    private void displayPendingRequests(HttpServletRequest request, HttpServletResponse response, int managerId)
            throws ServletException, IOException, SQLException {

        // Get pending requests with enhanced information
        List<ServiceRequest> requests = serviceRequestDAO.getPendingRequestsForApproval();

        // Get statistics
        int pendingCount = serviceRequestDAO.getRequestCountByStatus("Pending");
        int urgentCount = serviceRequestDAO.getRequestCountByPriority("Urgent");
        int todayCount = serviceRequestDAO.getRequestsCreatedToday();
        int approvedToday = requestApprovalDAO.getApprovalsToday(managerId);

        // Set attributes for JSP
        request.setAttribute("requests", requests);
        request.setAttribute("pendingCount", pendingCount);
        request.setAttribute("urgentCount", urgentCount);
        request.setAttribute("todayCount", todayCount);
        request.setAttribute("approvedToday", approvedToday);

        request.getRequestDispatcher("/TechnicalManagerApproval.jsp").forward(request, response);
    }

    /**
     * Handle search functionality
     */
    private void handleSearch(HttpServletRequest request, HttpServletResponse response, int managerId)
            throws ServletException, IOException, SQLException {

        String keyword = request.getParameter("keyword");

        if (keyword == null || keyword.trim().isEmpty()) {
            displayPendingRequests(request, response, managerId);
            return;
        }

        List<ServiceRequest> requests = serviceRequestDAO.searchPendingRequests(keyword.trim());

        // Get statistics - use correct method signatures
        int pendingCount = serviceRequestDAO.getRequestCountByStatus("Pending");
        int urgentCount = serviceRequestDAO.getRequestCountByPriority("Urgent");
        int todayCount = serviceRequestDAO.getRequestsCreatedToday();
        int approvedToday = requestApprovalDAO.getApprovalsToday(managerId);

        request.setAttribute("requests", requests);
        request.setAttribute("pendingCount", pendingCount);
        request.setAttribute("urgentCount", urgentCount);
        request.setAttribute("todayCount", todayCount);
        request.setAttribute("approvedToday", approvedToday);
        request.setAttribute("keyword", keyword);
        request.setAttribute("searchMode", true);

        request.getRequestDispatcher("/TechnicalManagerApproval.jsp").forward(request, response);
    }

    /**
     * Handle filter functionality
     */
    private void handleFilter(HttpServletRequest request, HttpServletResponse response, int managerId)
            throws ServletException, IOException, SQLException {

        String priority = request.getParameter("priority");
        String urgency = request.getParameter("urgency");

        List<ServiceRequest> requests;

        if ((priority == null || priority.trim().isEmpty()) &&
            (urgency == null || urgency.trim().isEmpty())) {
            requests = serviceRequestDAO.getPendingRequestsForApproval();
        } else {
            requests = serviceRequestDAO.filterPendingRequests(priority, urgency);
        }

        // Get statistics - use the correct method signatures
        int pendingCount = serviceRequestDAO.getRequestCountByStatus("Pending");
        int urgentCount = serviceRequestDAO.getRequestCountByPriority("Urgent");
        int todayCount = serviceRequestDAO.getRequestsCreatedToday();
        int approvedToday = requestApprovalDAO.getApprovalsToday(managerId);

        request.setAttribute("requests", requests);
        request.setAttribute("pendingCount", pendingCount);
        request.setAttribute("urgentCount", urgentCount);
        request.setAttribute("todayCount", todayCount);
        request.setAttribute("approvedToday", approvedToday);
        request.setAttribute("filterPriority", priority);
        request.setAttribute("filterUrgency", urgency);
        request.setAttribute("filterMode", true);

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

        try {
            requestId = Integer.parseInt(requestIdStr.trim());
            estimatedEffort = Double.parseDouble(estimatedEffortStr.trim());
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

        // Check if request exists and is pending
        ServiceRequest serviceRequest = serviceRequestDAO.getRequestById(requestId);
        if (serviceRequest == null) {
            session.setAttribute("error", "Request not found!");
            response.sendRedirect(request.getContextPath() + "/technicalManagerApproval");
            return;
        }

        if (!"Pending".equals(serviceRequest.getStatus())) {
            session.setAttribute("error", "This request has already been processed!");
            response.sendRedirect(request.getContextPath() + "/technicalManagerApproval");
            return;
        }

        // Create approval record
        RequestApproval approval = new RequestApproval();
        approval.setRequestId(requestId);
        approval.setApprovedBy(managerId);
        approval.setApprovalDate(java.time.LocalDate.now());
        approval.setDecision("Approved");
        approval.setNote(approvalNotes != null ? approvalNotes.trim() : "");

        // Set additional fields for approval
        // Note: These would need to be added to the RequestApproval model
        // approval.setEstimatedEffort(estimatedEffort);
        // approval.setRecommendedSkills(recommendedSkills);
        // approval.setUrgencyNotes(internalNotes);

        // Update service request status
        boolean updateSuccess = serviceRequestDAO.updateServiceRequestStatus(requestId, "Approved", internalNotes);

        if (updateSuccess) {
            // Create approval record
            int approvalId = requestApprovalDAO.createApproval(approval);

            if (approvalId > 0) {
                session.setAttribute("success", "Request #" + requestId + " approved successfully!");
            } else {
                session.setAttribute("error", "Error saving approval information!");
            }
        } else {
            session.setAttribute("error", "Error updating request status!");
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

        // Check if request exists and is pending
        ServiceRequest serviceRequest = serviceRequestDAO.getRequestById(requestId);
        if (serviceRequest == null) {
            session.setAttribute("error", "Request not found!");
            response.sendRedirect(request.getContextPath() + "/technicalManagerApproval");
            return;
        }

        if (!"Pending".equals(serviceRequest.getStatus())) {
            session.setAttribute("error", "This request has already been processed!");
            response.sendRedirect(request.getContextPath() + "/technicalManagerApproval");
            return;
        }

        // Create approval record for rejection
        RequestApproval approval = new RequestApproval();
        approval.setRequestId(requestId);
        approval.setApprovedBy(managerId);
        approval.setApprovalDate(java.time.LocalDate.now());
        approval.setDecision("Rejected");
        approval.setNote(rejectionNotes != null ? rejectionNotes.trim() : "");

        // Update service request status
        boolean updateSuccess = serviceRequestDAO.updateServiceRequestStatus(requestId, "Rejected", internalNotes);

        if (updateSuccess) {
            // Create approval record
            int approvalId = requestApprovalDAO.createApproval(approval);

            if (approvalId > 0) {
                session.setAttribute("success", "Request #" + requestId + " rejected successfully!");
            } else {
                session.setAttribute("error", "Error saving rejection information!");
            }
        } else {
            session.setAttribute("error", "Error updating request status!");
        }

        response.sendRedirect(request.getContextPath() + "/technicalManagerApproval");
    }
}