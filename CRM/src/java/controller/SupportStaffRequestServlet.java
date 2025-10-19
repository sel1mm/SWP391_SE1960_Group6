package controller;

import dal.ServiceRequestDAO;
import dal.AccountDAO;
import model.ServiceRequest;
import model.Account;
import service.AccountRoleService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet(name = "SupportStaffRequestServlet", urlPatterns = {"/supportStaffRequests"})
public class SupportStaffRequestServlet extends HttpServlet {
    
    private ServiceRequestDAO serviceRequestDAO;
    private AccountDAO accountDAO;
    private AccountRoleService accountRoleService;
    
    @Override
    public void init() throws ServletException {
        serviceRequestDAO = new ServiceRequestDAO();
        accountDAO = new AccountDAO();
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
        
        // Check if user is Support Staff
        if (!accountRoleService.isCustomerSupportStaff(sessionAccount.getAccountId())) {
            response.sendRedirect("home.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }
        
        try {
            switch (action) {
                case "list":
                    displayPendingRequests(request, response);
                    break;
                case "search":
                    handleSearch(request, response);
                    break;
                case "filter":
                    handleFilter(request, response);
                    break;
                default:
                    displayPendingRequests(request, response);
                    break;
            }
        } catch (SQLException e) {
            throw new ServletException("Database error", e);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Account sessionAccount = (Account) session.getAttribute("session_login");
        
        if (sessionAccount == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        // Check if user is Support Staff
        if (!accountRoleService.isCustomerSupportStaff(sessionAccount.getAccountId())) {
            response.sendRedirect("home.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        
        try {
            switch (action) {
                case "forward":
                    handleForwardRequest(request, response);
                    break;
                default:
                    displayPendingRequests(request, response);
                    break;
            }
        } catch (SQLException e) {
            throw new ServletException("Database error", e);
        }
    }
    
    /**
     * Display pending service requests for Support Staff
     */
    private void displayPendingRequests(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        
        // Get pending requests (status = 'Pending')
        List<ServiceRequest> requests = serviceRequestDAO.getRequestsByStatus("Pending");
        
        // Get available technicians (users with Technical Manager role)
        List<Account> technicians = accountDAO.getAccountsByRole("Technical Manager");
        
        // Get statistics
        int pendingCount = serviceRequestDAO.getRequestCountByStatus("Pending");
        int awaitingApprovalCount = serviceRequestDAO.getRequestCountByStatus("Awaiting Approval");
        int approvedCount = serviceRequestDAO.getRequestCountByStatus("Approved");
        int rejectedCount = serviceRequestDAO.getRequestCountByStatus("Rejected");
        
        // Set attributes for JSP
        request.setAttribute("requests", requests);
        request.setAttribute("technicians", technicians);
        request.setAttribute("pendingCount", pendingCount);
        request.setAttribute("awaitingApprovalCount", awaitingApprovalCount);
        request.setAttribute("approvedCount", approvedCount);
        request.setAttribute("rejectedCount", rejectedCount);
        
        request.getRequestDispatcher("/SupportStaffRequests.jsp").forward(request, response);
    }
    
    /**
     * Handle search functionality
     */
    private void handleSearch(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        
        String keyword = request.getParameter("keyword");
        
        List<ServiceRequest> requests;
        if (keyword == null || keyword.trim().isEmpty()) {
            requests = serviceRequestDAO.getRequestsByStatus("Pending");
        } else {
            requests = serviceRequestDAO.searchRequestsByStatusAndKeyword("Pending", keyword.trim());
        }
        
        // Get available technicians
        List<Account> technicians = accountDAO.getAccountsByRole("Technical Manager");
        
        // Get statistics
        int pendingCount = serviceRequestDAO.getRequestCountByStatus("Pending");
        int awaitingApprovalCount = serviceRequestDAO.getRequestCountByStatus("Awaiting Approval");
        int approvedCount = serviceRequestDAO.getRequestCountByStatus("Approved");
        int rejectedCount = serviceRequestDAO.getRequestCountByStatus("Rejected");
        
        request.setAttribute("requests", requests);
        request.setAttribute("technicians", technicians);
        request.setAttribute("pendingCount", pendingCount);
        request.setAttribute("awaitingApprovalCount", awaitingApprovalCount);
        request.setAttribute("approvedCount", approvedCount);
        request.setAttribute("rejectedCount", rejectedCount);
        request.setAttribute("keyword", keyword);
        request.setAttribute("searchMode", true);
        
        request.getRequestDispatcher("/SupportStaffRequests.jsp").forward(request, response);
    }
    
    /**
     * Handle filter functionality
     */
    private void handleFilter(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        
        String priority = request.getParameter("priority");
        
        List<ServiceRequest> requests;
        if (priority == null || priority.trim().isEmpty()) {
            requests = serviceRequestDAO.getRequestsByStatus("Pending");
        } else {
            requests = serviceRequestDAO.getRequestsByStatusAndPriority("Pending", priority);
        }
        
        // Get available technicians
        List<Account> technicians = accountDAO.getAccountsByRole("Technical Manager");
        
        // Get statistics
        int pendingCount = serviceRequestDAO.getRequestCountByStatus("Pending");
        int awaitingApprovalCount = serviceRequestDAO.getRequestCountByStatus("Awaiting Approval");
        int approvedCount = serviceRequestDAO.getRequestCountByStatus("Approved");
        int rejectedCount = serviceRequestDAO.getRequestCountByStatus("Rejected");
        
        request.setAttribute("requests", requests);
        request.setAttribute("technicians", technicians);
        request.setAttribute("pendingCount", pendingCount);
        request.setAttribute("awaitingApprovalCount", awaitingApprovalCount);
        request.setAttribute("approvedCount", approvedCount);
        request.setAttribute("rejectedCount", rejectedCount);
        request.setAttribute("filterPriority", priority);
        request.setAttribute("filterMode", true);
        
        request.getRequestDispatcher("/SupportStaffRequests.jsp").forward(request, response);
    }
    
    /**
     * Handle forwarding request to technician
     */
    private void handleForwardRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        
        HttpSession session = request.getSession();
        
        String requestIdStr = request.getParameter("requestId");
        String technicianIdStr = request.getParameter("technicianId");
        
        if (requestIdStr == null || requestIdStr.trim().isEmpty()) {
            session.setAttribute("error", "Request ID is required!");
            response.sendRedirect(request.getContextPath() + "/supportStaffRequests");
            return;
        }
        
        if (technicianIdStr == null || technicianIdStr.trim().isEmpty()) {
            session.setAttribute("error", "Please select a technician!");
            response.sendRedirect(request.getContextPath() + "/supportStaffRequests");
            return;
        }
        
        try {
            int requestId = Integer.parseInt(requestIdStr.trim());
            int technicianId = Integer.parseInt(technicianIdStr.trim());
            
            // Update request status to 'Awaiting Approval' and assign technician
            boolean success = serviceRequestDAO.forwardRequestToTechnician(requestId, technicianId);
            
            if (success) {
                session.setAttribute("success", "Request forwarded successfully to technician!");
            } else {
                session.setAttribute("error", "Failed to forward request. Please try again.");
            }
            
        } catch (NumberFormatException e) {
            session.setAttribute("error", "Invalid request or technician ID!");
        }
        
        response.sendRedirect(request.getContextPath() + "/supportStaffRequests");
    }
}