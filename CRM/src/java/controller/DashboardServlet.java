/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dal.AccountDAO;
import dal.ContractDAO;
import dal.ServiceRequestDAO;
import java.io.IOException;
import java.sql.SQLException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.HashMap;
import java.util.Map;

/**
 *
 * @author MY PC
 */
public class DashboardServlet extends HttpServlet {

    private AccountDAO accountDAO;
    private ContractDAO contractDAO;
    private ServiceRequestDAO requestDAO;

    @Override
    public void init() throws ServletException {
        accountDAO = new AccountDAO();
        contractDAO = new ContractDAO();
        requestDAO = new ServiceRequestDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        System.out.println("===== DASHBOARD SERVLET CALLED =====");

        // Check authentication
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("session_login") == null) {
            System.out.println("❌ No session, redirecting to login");
            response.sendRedirect("login.jsp");
            return;
        }

        String role = (String) session.getAttribute("session_role");
        System.out.println("✓ User role: " + role);

        if (!"Customer Support Staff".equals(role) && !"Admin".equals(role)) {
            System.out.println("❌ Access denied");
            response.sendRedirect("accessDenied.jsp");
            return;
        }

        try {
            System.out.println("\n=== FETCHING DATA ===");

            // 1. Tổng số tài khoản
            System.out.println("1. Getting total accounts...");
            int totalAccounts = accountDAO.getTotalCustomerCount();
            System.out.println("   Result: " + totalAccounts);
            request.setAttribute("totalAccounts", totalAccounts);

            // 2. Số đơn pending
            System.out.println("2. Getting pending requests...");
            int pendingRequests = requestDAO.countByStatus("Pending");
            System.out.println("   Result: " + pendingRequests);
            request.setAttribute("pendingRequests", pendingRequests);

            // 3. Tổng hợp đồng
            System.out.println("3. Getting total contracts...");
            int totalContracts = contractDAO.getTotalContractCount();
            System.out.println("   Result: " + totalContracts);
            request.setAttribute("totalContracts", totalContracts);

            // 4. Khách hàng có nhiều hợp đồng nhất
            // ✅ DÙNG METHOD ĐÃ CÓ SẴN
            System.out.println("4. Getting top customer...");
            Map<String, Object> topCustomer = contractDAO.getCustomerWithMostContracts();

            if (topCustomer != null) {
                System.out.println("   Top Customer: " + topCustomer.get("fullName")
                        + " (" + topCustomer.get("contractCount") + " contracts)");
                request.setAttribute("topCustomer", topCustomer);
            } else {
                System.out.println("   No top customer found, using default");
                Map<String, Object> defaultCustomer = new HashMap<>();
                defaultCustomer.put("fullName", "Chưa có dữ liệu");
                defaultCustomer.put("contractCount", 0);
                request.setAttribute("topCustomer", defaultCustomer);
            }

            System.out.println("=== DATA FETCHED SUCCESSFULLY ===\n");
            System.out.println("✓ Forwarding to dashboard.jsp");
            request.getRequestDispatcher("/dashboard.jsp").forward(request, response);

        } catch (SQLException e) {
            System.err.println("❌ SQL ERROR in DashboardServlet:");
            e.printStackTrace();
            response.sendRedirect("error.jsp");
        } catch (Exception e) {
            System.err.println("❌ ERROR in DashboardServlet:");
            e.printStackTrace();
            response.sendRedirect("error.jsp");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
    }
}
