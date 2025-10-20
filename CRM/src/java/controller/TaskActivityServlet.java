package controller;

import dal.WorkTaskDAO;
import dal.WorkTaskDAO.TaskRow;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

/**
 * Handles Task Activity page for technicians - shows recent task activities and status changes.
 */
public class TaskActivityServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        Integer sessionId = session != null ? (Integer) session.getAttribute("session_login_id") : null;
        String userRole = session != null ? (String) session.getAttribute("session_role") : null;
        String dev = req.getParameter("dev");

        if (sessionId == null || !isTechnicianOrAdmin(userRole)) {
            if ("true".equalsIgnoreCase(dev)) {
                loadTaskActivity(req, resp, 1L, dev); // Mock technician ID 1
            } else {
                resp.sendRedirect(req.getContextPath() + "/login.jsp");
                return;
            }
        } else {
            long technicianId = sessionId.longValue();
            loadTaskActivity(req, resp, technicianId, dev);
        }
    }

    private void loadTaskActivity(HttpServletRequest req, HttpServletResponse resp, long technicianId, String dev)
            throws ServletException, IOException {
        WorkTaskDAO workTaskDao = new WorkTaskDAO();

        try {
            // Get recent tasks for activity feed
            List<TaskRow> recentTasks = workTaskDao.listAssigned(technicianId, 0, 20);
            
            req.setAttribute("recentTasks", recentTasks);
            req.setAttribute("pageTitle", "Task Activity");
            req.setAttribute("contentView", "/WEB-INF/technician/technician-task-activity.jsp");
            req.setAttribute("activePage", "task-activity");
            req.getRequestDispatcher("/WEB-INF/technician/technician-layout.jsp").forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException("Database error while loading task activity", e);
        }
    }

    private boolean isTechnicianOrAdmin(String role) {
        if (role == null) return false;
        String r = role.toLowerCase();
        return r.contains("technician") || r.equals("admin");
    }
}
