package controller;

import dal.TaskDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

/**
 * Handle task status updates via form POST.
 */
public class TaskStatusUpdateServlet extends HttpServlet {
    private static final Set<String> ALLOWED = new HashSet<>(Arrays.asList("Pending","In Progress","Completed","On Hold"));

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        Integer sessionId = session != null ? (Integer) session.getAttribute("session_login_id") : null;
        String userRole = session != null ? (String) session.getAttribute("session_role") : null;
        if (sessionId == null || !isTechnicianOrAdmin(userRole)) { resp.sendRedirect(req.getContextPath()+"/login.jsp"); return; }

        long taskId = parseLong(req.getParameter("taskId"), 0L);
        String status = req.getParameter("status");
        String comment = req.getParameter("comment");
        if (taskId <= 0 || status == null || !ALLOWED.contains(status)) {
            resp.sendRedirect(req.getContextPath()+"/technician/tasks");
            return;
        }
        boolean dev = "true".equalsIgnoreCase(req.getParameter("dev"));
        TaskDao dao = new TaskDao(dev);
        try {
            dao.updateStatus(taskId, status);
            dao.addStatusChangeLog(taskId, sessionId.longValue(), comment);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
        resp.sendRedirect(req.getContextPath()+"/technician/task?id="+taskId+"&updated=1");
    }

    private long parseLong(String s, long def){
        try { return Long.parseLong(s); } catch(Exception e){ return def; }
    }
    private boolean isTechnicianOrAdmin(String role){
        if (role == null) return false;
        String r = role.toLowerCase();
        return r.contains("technician") || r.equals("admin");
    }
}


