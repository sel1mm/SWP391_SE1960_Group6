package controller;

import dal.WorkTaskDAO;
import model.WorkTask;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

/**
 * Servlet for handling technician task operations.
 * Updated to work with the new WorkTask table structure.
 */
public class TechnicianTaskServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        Integer sessionId = session != null ? (Integer) session.getAttribute("session_login_id") : null;
        String userRole = session != null ? (String) session.getAttribute("session_role") : null;
        
        String action = req.getParameter("action");
        String taskIdParam = req.getParameter("taskId");
        
        // Check authentication
        if (sessionId == null || !isTechnicianOrAdmin(userRole)) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        
        int technicianId = sessionId.intValue();
        
        try {
            WorkTaskDAO taskDAO = new WorkTaskDAO();
            
            if ("detail".equals(action) && taskIdParam != null) {
                // Show task detail
                int taskId = Integer.parseInt(taskIdParam);
                WorkTask task = taskDAO.findById(taskId);
                
                if (task != null && task.getTechnicianId() == technicianId) {
                    req.setAttribute("task", task);
                    req.setAttribute("pageTitle", "Task Detail");
                    req.setAttribute("contentView", "/WEB-INF/technician/task-detail.jsp");
                    req.setAttribute("activePage", "tasks");
                    req.getRequestDispatcher("/WEB-INF/technician/technician-layout.jsp").forward(req, resp);
                } else {
                    req.setAttribute("error", "Task not found or not assigned to you");
                    doGetTaskList(req, resp, technicianId);
                }
            } else {
                // Show task list
                doGetTaskList(req, resp, technicianId);
            }
            
        } catch (SQLException e) {
            throw new ServletException("Database error: " + e.getMessage(), e);
        } catch (NumberFormatException e) {
            req.setAttribute("error", "Invalid task ID");
            doGetTaskList(req, resp, technicianId);
        }
    }
    
    private void doGetTaskList(HttpServletRequest req, HttpServletResponse resp, int technicianId) 
            throws ServletException, IOException {
        try {
            String searchQuery = sanitize(req.getParameter("q"));
            String statusFilter = sanitize(req.getParameter("status"));
            int page = parseInt(req.getParameter("page"), 1);
            int pageSize = Math.min(parseInt(req.getParameter("pageSize"), 10), 100);
            
            WorkTaskDAO taskDAO = new WorkTaskDAO();
            List<WorkTask> tasks = taskDAO.findByTechnicianId(technicianId, searchQuery, statusFilter, page, pageSize);
            int totalTasks = taskDAO.getTaskCountForTechnician(technicianId, statusFilter);
            
            req.setAttribute("tasks", tasks);
            req.setAttribute("totalTasks", totalTasks);
            req.setAttribute("currentPage", page);
            req.setAttribute("pageSize", pageSize);
            req.setAttribute("totalPages", (int) Math.ceil((double) totalTasks / pageSize));
            req.setAttribute("pageTitle", "My Tasks");
            req.setAttribute("contentView", "/WEB-INF/technician/technician-tasks.jsp");
            req.setAttribute("activePage", "tasks");
            req.getRequestDispatcher("/WEB-INF/technician/technician-layout.jsp").forward(req, resp);
            
        } catch (SQLException e) {
            throw new ServletException("Database error: " + e.getMessage(), e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
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
        
        String action = req.getParameter("action");
        String taskIdParam = req.getParameter("taskId");
        
        if ("updateStatus".equals(action) && taskIdParam != null) {
            try {
                int taskId = Integer.parseInt(taskIdParam);
                String newStatus = req.getParameter("status");
                
                if (newStatus == null || newStatus.trim().isEmpty()) {
                    req.setAttribute("error", "Status is required");
                    doGet(req, resp);
                    return;
                }
                
                WorkTaskDAO taskDAO = new WorkTaskDAO();
                WorkTask task = taskDAO.findById(taskId);
                
                if (task != null && task.getTechnicianId() == sessionId.intValue()) {
                    boolean updated = taskDAO.updateTaskStatus(taskId, newStatus.trim());
                    if (updated) {
                        req.setAttribute("success", "Task status updated successfully");
                    } else {
                        req.setAttribute("error", "Failed to update task status");
                    }
                } else {
                    req.setAttribute("error", "Task not found or not assigned to you");
                }
                
                doGet(req, resp);
                
            } catch (SQLException e) {
                throw new ServletException("Database error: " + e.getMessage(), e);
            } catch (NumberFormatException e) {
                req.setAttribute("error", "Invalid task ID");
                doGet(req, resp);
            }
        } else {
            req.setAttribute("error", "Invalid action");
            doGet(req, resp);
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
