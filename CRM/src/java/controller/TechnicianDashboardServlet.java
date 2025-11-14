package controller;

import dal.AccountDAO;
import dal.WorkTaskDAO;
import dal.WorkTaskDAO.TaskStats;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import model.Account;

/**
 * Dashboard servlet for technician.
 * Shows technician dashboard with quick actions and stats.
 */
public class TechnicianDashboardServlet extends HttpServlet {

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

        String technicianName = "Kỹ thuật viên";
        try {
            AccountDAO accountDAO = new AccountDAO();
            Account account = accountDAO.getAccountById(technicianId);
            if (account != null && account.getFullName() != null && !account.getFullName().trim().isEmpty()) {
                technicianName = account.getFullName().trim();
            }
        } catch (Exception e) {
            System.err.println("Unable to load technician name: " + e.getMessage());
        }

        TaskStats stats = new TaskStats();
        try {
            WorkTaskDAO taskDAO = new WorkTaskDAO();
            stats = taskDAO.getTaskStatsForTechnician(technicianId);
        } catch (Exception e) {
            System.err.println("Unable to load task stats: " + e.getMessage());
        }

        String currentDateTime = LocalDateTime.now()
                .format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));

        req.setAttribute("technicianName", technicianName);
        req.setAttribute("technicianId", technicianId);
        req.setAttribute("currentDateTime", currentDateTime);
        req.setAttribute("taskStats", stats);

        // Set attributes for the dashboard page
        req.setAttribute("pageTitle", "Technician Dashboard");
        req.setAttribute("contentView", "/WEB-INF/technician/technician-dashboard.jsp");
        req.setAttribute("activePage", "dashboard");
        
        // Forward to layout
        req.getRequestDispatcher("/WEB-INF/technician/technician-layout.jsp").forward(req, resp);
    }

    private boolean isTechnicianOrAdmin(String role) {
        if (role == null) return false;
        String r = role.toLowerCase();
        return r.contains("technician") || r.equals("admin");
    }
}