package controller;

import dal.WorkHistoryDao;
import model.TechTask;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.List;

/**
 * Handle Work History page for technicians
 */
public class WorkHistoryServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        Integer sessionId = session != null ? (Integer) session.getAttribute("session_login_id") : null;
        String userRole = session != null ? (String) session.getAttribute("session_role") : null;
        String dev = req.getParameter("dev");
        
        if (sessionId != null && isTechnicianOrAdmin(userRole)) {
            // Real user - get their work history
            long techId = sessionId.longValue();
            loadWorkHistory(req, resp, techId, dev);
        } else if ("true".equalsIgnoreCase(dev)) {
            // Dev mode - use mock data
            loadWorkHistory(req, resp, 1L, dev);
        } else {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
    }

    private void loadWorkHistory(HttpServletRequest req, HttpServletResponse resp, long techId, String dev) 
            throws ServletException, IOException {
        
        String status = sanitize(req.getParameter("status"));
        LocalDate startDate = parseDate(req.getParameter("startDate"));
        LocalDate endDate = parseDate(req.getParameter("endDate"));
        int page = parseInt(req.getParameter("page"), 1);
        int pageSize = Math.min(parseInt(req.getParameter("pageSize"), 10), 50);

        boolean isDevMode = "true".equalsIgnoreCase(dev);
        WorkHistoryDao dao = new WorkHistoryDao(isDevMode);
        
        try {
            List<TechTask> workHistory = dao.findByTechnicianId(techId, status, startDate, endDate, page, pageSize);
            int totalCount = dao.getTotalCount(techId, status, startDate, endDate);
            
            req.setAttribute("workHistory", workHistory);
            req.setAttribute("totalCount", totalCount);
            req.setAttribute("currentPage", page);
            req.setAttribute("pageSize", pageSize);
            req.setAttribute("totalPages", (int) Math.ceil((double) totalCount / pageSize));
            req.setAttribute("pageTitle", "Work History");
            req.setAttribute("contentView", "/WEB-INF/technician/technician-work-history.jsp");
            req.setAttribute("activePage", "work");
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
    
    private LocalDate parseDate(String s) {
        try {
            return s == null || s.trim().isEmpty() ? null : LocalDate.parse(s);
        } catch (DateTimeParseException e) {
            return null;
        }
    }
    
    private boolean isTechnicianOrAdmin(String role){ 
        if (role == null) return false; 
        String r = role.toLowerCase(); 
        return r.contains("technician") || r.equals("admin"); 
    }
}
