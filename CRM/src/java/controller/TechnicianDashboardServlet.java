package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Renders Technician Dashboard with shared technician layout
 */
public class TechnicianDashboardServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        String userRole = session != null ? (String) session.getAttribute("session_role") : null;
        if (session == null || session.getAttribute("session_login_id") == null || !isTechnicianOrAdmin(userRole)) {
            resp.sendRedirect(req.getContextPath()+"/login.jsp");
            return;
        }

        String uri = req.getRequestURI();
        String view = "/WEB-INF/technician/technician-dashboard.jsp";
        String active = "dashboard";
        if (uri.endsWith("/storekeeper")) { view = "/WEB-INF/technician/technician-dashboard.jsp"; active = "storekeeper"; }
        else if (uri.endsWith("/approved-request")) { view = "/WEB-INF/technician/technician-dashboard.jsp"; active = "approved"; }
        else if (uri.endsWith("/contract-history")) { view = "/WEB-INF/technician/technician-dashboard.jsp"; active = "contract"; }

        req.setAttribute("pageTitle", "Technician");
        req.setAttribute("contentView", view);
        req.setAttribute("activePage", active);
        req.getRequestDispatcher("/WEB-INF/technician/technician-layout.jsp").forward(req, resp);
    }

    private boolean isTechnicianOrAdmin(String role){ if(role==null) return false; String r=role.toLowerCase(); return r.contains("technician")||r.equals("admin"); }
}


