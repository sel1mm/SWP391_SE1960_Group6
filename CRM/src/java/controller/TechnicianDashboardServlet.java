package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

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