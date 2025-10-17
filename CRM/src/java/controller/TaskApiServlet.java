package controller;

import com.google.gson.Gson;
import dal.TaskDao;
import model.TechTask;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * JSON API for listing assigned tasks.
 */
@WebServlet(name = "TaskApiServlet", urlPatterns = {"/api/technician/tasks"})
public class TaskApiServlet extends HttpServlet {
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json");
        HttpSession session = req.getSession(false);
        Integer sessionId = session != null ? (Integer) session.getAttribute("session_login_id") : null;
        String dev = req.getParameter("dev");
        long techId;
        if (sessionId != null) techId = sessionId.longValue();
        else if ("true".equalsIgnoreCase(dev)) techId = parseLong(req.getParameter("techId"), 1L);
        else { resp.setStatus(401); write(resp, mapOf("error","Unauthorized")); return; }

        String q = trim(req.getParameter("q"));
        String status = trim(req.getParameter("status"));
        int page = parseInt(req.getParameter("page"), 1);
        int pageSize = Math.min(parseInt(req.getParameter("pageSize"), 10), 100);

        TaskDao dao = new TaskDao("true".equalsIgnoreCase(dev));
        try {
            List<TechTask> tasks = dao.findByTechnicianId(techId, q, status, page, pageSize);
            write(resp, mapOf("tasks", tasks));
        } catch (SQLException e) {
            resp.setStatus(500);
            write(resp, mapOf("error", e.getMessage()));
        }
    }

    private void write(HttpServletResponse resp, Map obj) throws IOException {
        try (PrintWriter out = resp.getWriter()){
            out.print(gson.toJson(obj));
        }
    }
    private String trim(String s){ if(s==null) return null; String t=s.trim(); return t.isEmpty()?null:t; }
    private int parseInt(String s, int def){ try{ return Integer.parseInt(s); }catch(Exception e){ return def; } }
    private long parseLong(String s, long def){ try{ return Long.parseLong(s); }catch(Exception e){ return def; } }
    private Map<String,Object> mapOf(Object... kv){ Map<String,Object> m=new HashMap<>(); for(int i=0;i<kv.length-1;i+=2)m.put(kv[i].toString(),kv[i+1]); return m; }
}


