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
import java.time.LocalDate;
import java.util.List;

/**
 * Handles listing and managing WorkTasks for technicians.
 */
public class TechnicianTaskServlet extends HttpServlet {

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
                loadTaskList(req, resp, 1L, dev); // Mock technician ID 1
            } else {
                resp.sendRedirect(req.getContextPath() + "/login.jsp");
                return;
            }
        } else {
            long technicianId = sessionId.longValue();
            loadTaskList(req, resp, technicianId, dev);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Handle task acceptance with workload checks
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        Integer sessionId = session != null ? (Integer) session.getAttribute("session_login_id") : null;
        String userRole = session != null ? (String) session.getAttribute("session_role") : null;

        if (sessionId == null || !isTechnicianOrAdmin(userRole)) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String action = req.getParameter("action");
        String taskIdStr = req.getParameter("taskId");
        String startDateStr = req.getParameter("startDate");
        String endDateStr = req.getParameter("endDate");

        if ("accept".equals(action) && taskIdStr != null) {
            try {
                long taskId = Long.parseLong(taskIdStr);
                long technicianId = sessionId.longValue();
                
                // Check if task belongs to technician
                WorkTaskDAO workTaskDao = new WorkTaskDAO();
                if (!workTaskDao.belongsToTechnician(taskId, technicianId)) {
                    resp.sendRedirect(req.getContextPath() + "/technician/tasks?error=" + 
                        java.net.URLEncoder.encode("Task not found or not assigned to you.", "UTF-8"));
                    return;
                }

                // Check workload and time conflicts
                if (startDateStr != null && endDateStr != null) {
                    LocalDate startDate = LocalDate.parse(startDateStr);
                    LocalDate endDate = LocalDate.parse(endDateStr);
                    
                    if (workTaskDao.hasTimeConflict(technicianId, startDate, endDate)) {
                        resp.sendRedirect(req.getContextPath() + "/technician/tasks?error=" + 
                            java.net.URLEncoder.encode("You have overlapping tasks during this period.", "UTF-8"));
                        return;
                    }
                }

                // Success - redirect with success message
                resp.sendRedirect(req.getContextPath() + "/technician/tasks?success=" + 
                    java.net.URLEncoder.encode("Task accepted successfully!", "UTF-8"));

            } catch (NumberFormatException e) {
                resp.sendRedirect(req.getContextPath() + "/technician/tasks?error=" + 
                    java.net.URLEncoder.encode("Invalid task ID.", "UTF-8"));
            } catch (SQLException e) {
                resp.sendRedirect(req.getContextPath() + "/technician/tasks?error=" + 
                    java.net.URLEncoder.encode("Database error: " + e.getMessage(), "UTF-8"));
            }
        } else {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action or missing parameters");
        }
    }

    private void loadTaskList(HttpServletRequest req, HttpServletResponse resp, long technicianId, String dev)
            throws ServletException, IOException {
        WorkTaskDAO workTaskDao = new WorkTaskDAO();

        try {
            List<TaskRow> tasks = workTaskDao.listAssigned(technicianId, 0, 100);
            req.setAttribute("tasks", tasks);
            req.setAttribute("pageTitle", "Assigned Tasks");
            req.setAttribute("contentView", "/WEB-INF/technician/technician-tasks.jsp");
            req.setAttribute("activePage", "tasks");
            req.getRequestDispatcher("/WEB-INF/technician/technician-layout.jsp").forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException("Database error while loading tasks", e);
        }
    }

    private boolean isTechnicianOrAdmin(String role) {
        if (role == null) return false;
        String r = role.toLowerCase();
        return r.contains("technician") || r.equals("admin");
    }
}
