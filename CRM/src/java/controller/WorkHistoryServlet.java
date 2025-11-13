package controller;

import dal.WorkTaskDAO;
import dal.RepairReportDAO;
import model.WorkTask;
import model.RepairReport;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

/**
 * Work history servlet for technician.
 * Shows completed tasks and reports.
 */
public class WorkHistoryServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        Integer sessionId = session != null ? (Integer) session.getAttribute("session_login_id") : null;
        String userRole = session != null ? (String) session.getAttribute("session_role") : null;
        
        // Check authentication
        if (sessionId == null || !isTechnicianOrAdmin(userRole)) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        
        int technicianId = sessionId.intValue();
        
        try {
            // Get pagination parameters
            String searchQuery = sanitize(req.getParameter("q"));
            String statusFilter = sanitize(req.getParameter("status"));
            int page = parseInt(req.getParameter("page"), 1);
            int pageSize = Math.min(parseInt(req.getParameter("pageSize"), 10), 100);
            
            // Fetch all tasks (not just completed)
            WorkTaskDAO taskDAO = new WorkTaskDAO();
            List<WorkTask> allTasks = taskDAO.findByTechnicianId(technicianId, searchQuery, statusFilter, page, pageSize);
            int totalTasks = taskDAO.getTaskCountForTechnician(technicianId, statusFilter);
            
            // Fetch submitted reports
            RepairReportDAO reportDAO = new RepairReportDAO();
            List<RepairReport> submittedReports = reportDAO.findSubmittedReportsByTechnician(technicianId, searchQuery, page, pageSize);
            int totalSubmittedReports = reportDAO.getSubmittedReportCountForTechnician(technicianId, searchQuery);
            
            // Set attributes
            req.setAttribute("allTasks", allTasks);
            req.setAttribute("totalTasks", totalTasks);
            req.setAttribute("submittedReports", submittedReports);
            req.setAttribute("totalSubmittedReports", totalSubmittedReports);
            req.setAttribute("currentPage", page);
            req.setAttribute("pageSize", pageSize);
            req.setAttribute("totalPages", (int) Math.ceil((double) Math.max(totalTasks, totalSubmittedReports) / pageSize));
            req.setAttribute("searchQuery", searchQuery);
            req.setAttribute("statusFilter", statusFilter);
            req.setAttribute("pageTitle", "Lịch sử công việc");
            req.setAttribute("contentView", "/WEB-INF/technician/work-history.jsp");
            req.setAttribute("activePage", "work");
            
            // Forward to layout
            req.getRequestDispatcher("/WEB-INF/technician/technician-layout.jsp").forward(req, resp);
            
        } catch (SQLException e) {
            throw new ServletException("Database error: " + e.getMessage(), e);
        }
    }

    private String sanitize(String s) {
        if (s == null) return null;
        String t = s.trim();
        return t.isEmpty() ? null : t;
    }

    private int parseInt(String s, int def) {
        try {
            return Integer.parseInt(s);
        } catch (Exception e) {
            return def;
        }
    }

    private boolean isTechnicianOrAdmin(String role) {
        if (role == null) return false;
        String r = role.toLowerCase();
        return r.contains("technician") || r.equals("admin");
    }
}