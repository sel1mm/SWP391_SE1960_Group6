package controller;

import dal.ReportDao;
import model.TechRepairReport;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.sql.SQLException;

/**
 * Handle repair report creation with optional file upload.
 */
@MultipartConfig
public class TechnicianReportServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setAttribute("pageTitle", "Submit Report");
        req.setAttribute("contentView", "/WEB-INF/technician/technician-report-form.jsp");
        req.setAttribute("activePage", "reports");
        req.getRequestDispatcher("/WEB-INF/technician/technician-layout.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        Integer sessionId = session != null ? (Integer) session.getAttribute("session_login_id") : null;
        String userRole = session != null ? (String) session.getAttribute("session_role") : null;
        if (sessionId == null || !isTechnicianOrAdmin(userRole)) { resp.sendRedirect(req.getContextPath()+"/login.jsp"); return; }

        long taskId = parseLong(req.getParameter("taskId"), 0L);
        String summary = trim(req.getParameter("summary"));
        String description = trim(req.getParameter("description"));
        if (taskId <= 0 || summary == null || description == null) {
            resp.sendRedirect(req.getContextPath()+"/technician/reports?error=1");
            return;
        }

        String uploadPath = getServletContext().getRealPath("/uploads");
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) uploadDir.mkdirs();
        String storedPath = null;
        Part filePart = req.getPart("attachment");
        if (filePart != null && filePart.getSize() > 0) {
            String submittedName = Path.of(filePart.getSubmittedFileName()).getFileName().toString();
            String unique = System.currentTimeMillis() + "_" + submittedName;
            Path dest = new File(uploadDir, unique).toPath();
            try {
                Files.copy(filePart.getInputStream(), dest, StandardCopyOption.REPLACE_EXISTING);
                storedPath = "uploads/" + unique;
            } finally {
                filePart.delete();
            }
        }

        TechRepairReport r = new TechRepairReport();
        r.setTaskId(taskId);
        r.setSummary(summary);
        r.setDescription(description);
        r.setFilePath(storedPath);

        boolean dev = "true".equalsIgnoreCase(req.getParameter("dev"));
        ReportDao dao = new ReportDao(dev);
        try {
            long id = dao.save(r);
            resp.sendRedirect(req.getContextPath()+"/technician/task?id="+taskId+"&reportCreated=1");
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    private String trim(String s){ if(s==null) return null; String t=s.trim(); return t.isEmpty()?null:t; }
    private long parseLong(String s, long def){ try{ return Long.parseLong(s); }catch(Exception e){ return def; } }
    private boolean isTechnicianOrAdmin(String role){ if(role==null) return false; String r=role.toLowerCase(); return r.contains("technician")||r.equals("admin"); }
}


