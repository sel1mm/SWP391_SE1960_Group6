package controller;

import dal.TechContractDao;
import model.TechContract;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDate;

/**
 * Create equipment contracts for tasks.
 */
public class TechnicianContractServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setAttribute("pageTitle", "Create Contract");
        req.setAttribute("contentView", "/WEB-INF/technician/technician-contract-form.jsp");
        req.setAttribute("activePage", "contracts");
        req.getRequestDispatcher("/WEB-INF/technician/technician-layout.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        Integer sessionId = session != null ? (Integer) session.getAttribute("session_login_id") : null;
        String userRole = session != null ? (String) session.getAttribute("session_role") : null;
        if (sessionId == null || !isTechnicianOrAdmin(userRole)) { resp.sendRedirect(req.getContextPath()+"/login.jsp"); return; }

        String equipmentName = trim(req.getParameter("equipmentName"));
        int quantity = parseInt(req.getParameter("quantity"), 0);
        Double unitPrice = parseDoubleOrNull(req.getParameter("unitPrice"));
        String description = trim(req.getParameter("description"));
        LocalDate date = parseDate(req.getParameter("date"));
        Long taskId = parseLongOrNull(req.getParameter("taskId"));

        if (equipmentName == null || equipmentName.length() > 255 || quantity <= 0) {
            resp.sendRedirect(req.getContextPath()+"/technician/contracts?error=1");
            return;
        }

        TechContract c = new TechContract();
        c.setEquipmentName(equipmentName);
        c.setQuantity(quantity);
        c.setUnitPrice(unitPrice);
        c.setDescription(description);
        c.setDate(date);
        c.setTechnicianId(sessionId.longValue());
        c.setTaskId(taskId);

        boolean dev = "true".equalsIgnoreCase(req.getParameter("dev"));
        TechContractDao dao = new TechContractDao(dev);
        try {
            long id = dao.save(c);
            if (taskId != null && taskId > 0) {
                resp.sendRedirect(req.getContextPath()+"/technician/task?id="+taskId+"&contractCreated=1");
            } else {
                resp.sendRedirect(req.getContextPath()+"/technician/tasks?contractCreated=1");
            }
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    private String trim(String s){ if(s==null) return null; String t=s.trim(); return t.isEmpty()?null:t; }
    private int parseInt(String s, int def){ try{ return Integer.parseInt(s); }catch(Exception e){ return def; } }
    private Double parseDoubleOrNull(String s){ try{ return s==null||s.trim().isEmpty()?null:Double.parseDouble(s); }catch(Exception e){ return null; } }
    private LocalDate parseDate(String s){ try{ return s==null||s.trim().isEmpty()?null:LocalDate.parse(s); }catch(Exception e){ return null; } }
    private Long parseLongOrNull(String s){ try{ return s==null||s.trim().isEmpty()?null:Long.parseLong(s); }catch(Exception e){ return null; } }
    private boolean isTechnicianOrAdmin(String role){ if(role==null) return false; String r=role.toLowerCase(); return r.contains("technician")||r.equals("admin"); }
}


