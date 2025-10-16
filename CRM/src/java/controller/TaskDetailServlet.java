package controller;

import dal.TaskDao;
import model.TechTask;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

/**
 * Render task detail page.
 */
@WebServlet(name = "TaskDetailServlet", urlPatterns = {"/technician/task"})
public class TaskDetailServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");
        String dev = req.getParameter("dev");
        String userRole = (String)(req.getSession(false) != null ? req.getSession(false).getAttribute("session_role") : null);
        if ((req.getSession(false) == null || req.getSession(false).getAttribute("session_login_id") == null || !isTechnicianOrAdmin(userRole)) && !"true".equalsIgnoreCase(dev)) {
            resp.sendRedirect(req.getContextPath()+"/login.jsp");
            return;
        }
        long id = parseLong(req.getParameter("id"), 0L);
        if (id <= 0) {
            resp.sendRedirect(req.getContextPath() + "/technician/tasks");
            return;
        }
        TaskDao dao = new TaskDao("true".equalsIgnoreCase(dev));
        try {
            TechTask task = dao.findById(id);
            req.setAttribute("task", task);
            req.setAttribute("pageTitle", "Task Detail");
            req.setAttribute("contentView", "/WEB-INF/technician/technician-task-detail.jsp");
            req.setAttribute("activePage", "tasks");
            req.getRequestDispatcher("/WEB-INF/technician/technician-layout.jsp").forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
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


