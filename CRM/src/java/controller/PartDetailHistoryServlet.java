package controller;

import dal.PartDetailHistoryDAO;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Account;
import model.PartDetailHistory;

/**
 * Servlet xử lý lịch sử thay đổi PartDetail
 * @author Admin
 */
public class PartDetailHistoryServlet extends HttpServlet {
    
    private final PartDetailHistoryDAO dao = new PartDetailHistoryDAO();
    private final DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        System.out.println("=== PartDetailHistoryServlet: doGet() ===");
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        System.out.println("=== PartDetailHistoryServlet: doPost() ===");
        processRequest(request, response);
    }

    private void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            // Kiểm tra đăng nhập
            HttpSession session = request.getSession();
            Account acc = (Account) session.getAttribute("session_login");
            
            if (acc == null) {
                System.out.println("⚠️ User not logged in, redirecting to login");
                response.sendRedirect("login");
                return;
            }
            
            System.out.println("✅ User logged in: " + acc.getFullName());
            
            // Lấy parameters từ request
            String fromDateStr = request.getParameter("fromDate");
            String toDateStr = request.getParameter("toDate");
            String actionType = request.getParameter("actionType");
            String keyword = request.getParameter("keyword");
            
            // Set default dates if empty
            LocalDate toDate = LocalDate.now();
            LocalDate fromDate = toDate.withDayOfMonth(1); // First day of current month
            
            if (fromDateStr != null && !fromDateStr.isEmpty()) {
                try {
                    fromDate = LocalDate.parse(fromDateStr);
                    System.out.println("✅ Parsed fromDate: " + fromDate);
                } catch (Exception e) {
                    System.out.println("⚠️ Invalid fromDate format, using default");
                }
            }
            
            if (toDateStr != null && !toDateStr.isEmpty()) {
                try {
                    toDate = LocalDate.parse(toDateStr);
                    System.out.println("✅ Parsed toDate: " + toDate);
                } catch (Exception e) {
                    System.out.println("⚠️ Invalid toDate format, using default");
                }
            }
            
            // Default action type
            if (actionType == null || actionType.isEmpty()) {
                actionType = "all";
            }
            
            // Format dates for SQL
            String fromDateFormatted = fromDate.format(formatter);
            String toDateFormatted = toDate.format(formatter);
            
            System.out.println("========== Request Parameters ==========");
            System.out.println("From Date: " + fromDateFormatted);
            System.out.println("To Date: " + toDateFormatted);
            System.out.println("Action Type: " + actionType);
            System.out.println("Keyword: " + (keyword != null ? keyword : "NULL"));
            System.out.println("=======================================");
            
            // 1. Lấy thống kê tổng quan
            System.out.println("\n📊 Getting overview statistics...");
            PartDetailHistory overview = dao.getOverview(fromDateFormatted, toDateFormatted);
            request.setAttribute("overview", overview);
            System.out.println("✅ Overview: Total=" + overview.getTotalCount() + 
                             ", Added=" + overview.getAddedCount() + 
                             ", Changed=" + overview.getChangedCount());
            
            // 2. Lấy danh sách lịch sử
            System.out.println("\n📋 Getting history list...");
            List<PartDetailHistory> historyList = dao.getAllHistory(
                fromDateFormatted, 
                toDateFormatted, 
                actionType, 
                keyword
            );
            request.setAttribute("historyList", historyList);
            System.out.println("✅ Loaded " + historyList.size() + " history records");
            
            // 3. Đếm tổng số bản ghi
            System.out.println("\n🔢 Counting total records...");
            int totalCount = dao.countHistory(fromDateFormatted, toDateFormatted, actionType, keyword);
            request.setAttribute("totalCount", totalCount);
            System.out.println("✅ Total count: " + totalCount);
            
            // 4. Set lại parameters để giữ giá trị trong form
            request.setAttribute("fromDate", fromDateFormatted);
            request.setAttribute("toDate", toDateFormatted);
            request.setAttribute("actionType", actionType);
            request.setAttribute("keyword", keyword);
            
            System.out.println("\n✅ All data loaded successfully!");
            System.out.println("➡️ Forwarding to partDetailHistory.jsp...\n");
            
            // Forward đến JSP
            request.getRequestDispatcher("partDetailHistory.jsp").forward(request, response);
            
        } catch (Exception e) {
            System.out.println("\n❌❌❌ ERROR in PartDetailHistoryServlet ❌❌❌");
            System.out.println("Error message: " + e.getMessage());
            System.out.println("Stack trace:");
            e.printStackTrace();
            
            // Hiển thị lỗi cho người dùng
            response.setContentType("text/html;charset=UTF-8");
            response.getWriter().println("<!DOCTYPE html>");
            response.getWriter().println("<html>");
            response.getWriter().println("<head>");
            response.getWriter().println("<title>Error</title>");
            response.getWriter().println("<style>");
            response.getWriter().println("body { font-family: Arial; padding: 40px; background: #f5f5f5; }");
            response.getWriter().println(".error-box { background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }");
            response.getWriter().println("h2 { color: #dc3545; }");
            response.getWriter().println("pre { background: #f8f9fa; padding: 15px; border-radius: 5px; overflow-x: auto; }");
            response.getWriter().println("</style>");
            response.getWriter().println("</head>");
            response.getWriter().println("<body>");
            response.getWriter().println("<div class='error-box'>");
            response.getWriter().println("<h2>❌ Đã xảy ra lỗi khi tải lịch sử thiết bị</h2>");
            response.getWriter().println("<p><strong>Lỗi:</strong> " + e.getMessage() + "</p>");
            response.getWriter().println("<pre>");
            e.printStackTrace(response.getWriter());
            response.getWriter().println("</pre>");
            response.getWriter().println("<br><a href='partDetailHistory' style='background: #007bff; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;'>← Quay lại</a>");
            response.getWriter().println("</div>");
            response.getWriter().println("</body>");
            response.getWriter().println("</html>");
        }
    }

    @Override
    public String getServletInfo() {
        return "Part Detail History Servlet - Manages PartDetail change history tracking";
    }
}