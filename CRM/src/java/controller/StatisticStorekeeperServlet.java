package controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Account;

/**
 * StorekeeperServlet - Trang chủ quản lý cho Storekeeper
 * Hiển thị các navigation cards để truy cập nhanh các chức năng
 */

public class StatisticStorekeeperServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Account acc = (Account) session.getAttribute("session_login");
        
        // Kiểm tra đăng nhập
        if (acc == null) {
            response.sendRedirect("login");
            return;
        }
        
        // Kiểm tra role (optional - nếu cần)
        // if (acc.getRoleId() != 3) { // 3 = Storekeeper
        //     response.sendRedirect("accessDenied");
        //     return;
        // }
        
        System.out.println("=== STOREKEEPER DASHBOARD ===");
        System.out.println("User: " + acc.getUsername());
     
        
        // Set thông tin user vào session (nếu chưa có)
        if (session.getAttribute("username") == null) {
            session.setAttribute("username", acc.getUsername());
        }
        
        // Forward đến trang storekeeper.jsp
        request.getRequestDispatcher("partStatistics").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Storekeeper Dashboard Servlet";
    }
}