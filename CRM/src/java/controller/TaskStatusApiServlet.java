package controller;

import com.google.gson.Gson;
import dal.TaskDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

/**
 * JSON API for updating task status.
 */
@WebServlet(name = "TaskStatusApiServlet", urlPatterns = {"/api/technician/tasks/*/status"})
public class TaskStatusApiServlet extends HttpServlet {
    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json");
        HttpSession session = req.getSession(false);
        Integer sessionId = session != null ? (Integer) session.getAttribute("session_login_id") : null;
        String userRole = session != null ? (String) session.getAttribute("session_role") : null;
        if (sessionId == null || !isTechnicianOrAdmin(userRole)) { resp.setStatus(401); writeJson(resp, mapOf("success", false, "error", "Unauthorized")); return; }

        String requestUri = req.getRequestURI();
        String[] parts = requestUri.split("/");
        long taskId = 0L;
        for (int i = 0; i < parts.length; i++) {
            if ("tasks".equals(parts[i]) && i + 1 < parts.length) {
                try { taskId = Long.parseLong(parts[i+1]); } catch(Exception ignored) {}
            }
        }
        if (taskId <= 0) { resp.setStatus(400); writeJson(resp, mapOf("success", false, "error", "Invalid task id")); return; }

        Map body = parseBody(req);
        String status = body.get("status") != null ? body.get("status").toString() : null;
        String comment = body.get("comment") != null ? body.get("comment").toString() : null;
        if (status == null) { resp.setStatus(400); writeJson(resp, mapOf("success", false, "error", "Missing status")); return; }

        boolean dev = "true".equalsIgnoreCase(req.getParameter("dev"));
        TaskDao dao = new TaskDao(dev);
        try {
            dao.updateStatus(taskId, status);
            dao.addStatusChangeLog(taskId, sessionId.longValue(), comment);
        } catch (SQLException e) {
            resp.setStatus(500); writeJson(resp, mapOf("success", false, "error", e.getMessage())); return;
        }
        writeJson(resp, mapOf("success", true, "status", status));
    }

    private Map parseBody(HttpServletRequest req) throws IOException {
        StringBuilder sb = new StringBuilder();
        try (BufferedReader br = req.getReader()){
            String line; while((line = br.readLine()) != null){ sb.append(line); }
        }
        try { return gson.fromJson(sb.toString(), Map.class); } catch(Exception e){ return new HashMap(); }
    }

    private void writeJson(HttpServletResponse resp, Map obj) throws IOException {
        try (PrintWriter out = resp.getWriter()){
            out.print(gson.toJson(obj));
        }
    }

    private Map<String,Object> mapOf(Object... kv){
        Map<String,Object> m = new HashMap<>();
        for (int i = 0; i < kv.length - 1; i+=2) m.put(kv[i].toString(), kv[i+1]);
        return m;
    }
    private boolean isTechnicianOrAdmin(String role){ if(role==null) return false; String r=role.toLowerCase(); return r.contains("technician")||r.equals("admin"); }
}


