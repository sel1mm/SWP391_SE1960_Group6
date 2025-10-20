package controller;

import dal.TaskDao;
import model.TechTask;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

/**
 * Render assigned technician tasks list
 */
public class TechnicianTasksServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        Integer sessionId = session != null ? (Integer) session.getAttribute("session_login_id") : null;
        String userRole = session != null ? (String) session.getAttribute("session_role") : null;
        String dev = req.getParameter("dev");
        String q = sanitize(req.getParameter("q"));
        String status = sanitize(req.getParameter("status"));
        int page = parseInt(req.getParameter("page"), 1);
        int pageSize = Math.min(parseInt(req.getParameter("pageSize"), 10), 100);

        long techId;
        if (sessionId != null && isTechnicianOrAdmin(userRole)) {
            techId = sessionId.longValue();
        } else if ("true".equalsIgnoreCase(dev) && req.getParameter("devTechId") != null) {
            techId = parseLong(req.getParameter("devTechId"), 1L);
        } else {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        TaskDao dao = new TaskDao("true".equalsIgnoreCase(dev));
        try {
            List<TechTask> tasks = dao.findByTechnicianId(techId, q, status, page, pageSize);
            req.setAttribute("tasks", tasks);
            req.setAttribute("pageTitle", "Technician Tasks");
            req.setAttribute("contentView", "/WEB-INF/technician/technician-tasks.jsp");
            req.setAttribute("activePage", "tasks");
            req.getRequestDispatcher("/WEB-INF/technician/technician-layout.jsp").forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    private String sanitize(String s){
        if (s == null) return null;
        String t = s.trim();
        return t.isEmpty() ? null : t;
    }

    private int parseInt(String s, int def){
        try { return Integer.parseInt(s); } catch(Exception e){ return def; }
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


