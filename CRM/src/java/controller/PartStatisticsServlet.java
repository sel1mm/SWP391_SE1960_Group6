package controller;

import dal.PartDetailStatisticsDAO;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import model.Account;
import model.PartDetailStatistics;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Servlet xử lý thống kê PartDetail từ lịch sử
 * @author Admin
 */
public class PartStatisticsServlet extends HttpServlet {

  private static final Logger LOGGER = Logger.getLogger(PartStatisticsServlet.class.getName());
    private final PartDetailStatisticsDAO dao = new PartDetailStatisticsDAO();
    private final DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    private void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            // Kiểm tra đăng nhập
            HttpSession session = request.getSession();
            Account acc = (Account) session.getAttribute("session_login");
            if (acc == null) {
                LOGGER.warning("⚠️ Người dùng chưa đăng nhập, redirect về login");
                response.sendRedirect("login");
                return;
            }

            // Lấy parameters
            String statusFilter = request.getParameter("status");
            String timeFilter = request.getParameter("timeFilter");
            String fromDateStr = request.getParameter("fromDate");
            String toDateStr = request.getParameter("toDate");
            String viewType = request.getParameter("viewType");

            // Default values
            if (statusFilter == null || statusFilter.isEmpty()) {
                statusFilter = "InUse";
            }

            if (timeFilter == null || timeFilter.isEmpty()) {
                timeFilter = "month"; // Mặc định là tháng này
            }

            if (viewType == null || viewType.isEmpty()) {
                viewType = "detail";
            }

            // Xử lý ngày tháng
            LocalDate fromDate;
            LocalDate toDate = LocalDate.now();

            if ("custom".equals(timeFilter) && fromDateStr != null && !fromDateStr.isEmpty()
                    && toDateStr != null && !toDateStr.isEmpty()) {
                fromDate = LocalDate.parse(fromDateStr);
                toDate = LocalDate.parse(toDateStr);
            } else {
                switch (timeFilter) {
                    case "day":
                        fromDate = toDate;
                        break;
                    case "week":
                        fromDate = toDate.minusWeeks(1);
                        break;
                    case "month":
                        fromDate = toDate.withDayOfMonth(1);
                        break;
                    case "year":
                        fromDate = toDate.withDayOfYear(1);
                        break;
                    default:
                        fromDate = toDate.minusMonths(1);
                }
            }

            String fromDateFormatted = fromDate.format(formatter);
            String toDateFormatted = toDate.format(formatter);

LOGGER.info(String.format(
        "=== Statistics Request ===%n" +
        "Status: %s%n" +
        "Time Filter: %s%n" +
        "From: %s%n" +
        "To: %s%n" +
        "View Type: %s",
        statusFilter, timeFilter, fromDateFormatted, toDateFormatted, viewType));

            // Lấy thống kê tổng quan
            PartDetailStatistics overview = dao.getOverviewStatistics(fromDateFormatted, toDateFormatted);
            request.setAttribute("overview", overview);

            if ("summary".equals(viewType)) {
                List<PartDetailStatistics> techStats =
                        dao.getStatisticsByTechnician(statusFilter, fromDateFormatted, toDateFormatted);
                request.setAttribute("techStats", techStats);
                LOGGER.info("✅ Lấy dữ liệu thống kê theo technician thành công");
            } else {
                List<PartDetailStatistics> detailList =
                        dao.getDetailsByStatusAndDate(statusFilter, fromDateFormatted, toDateFormatted);
                request.setAttribute("detailList", detailList);

                int totalCount = dao.countByStatus(statusFilter, fromDateFormatted, toDateFormatted);
                request.setAttribute("totalCount", totalCount);
                LOGGER.info("✅ Lấy dữ liệu chi tiết và tổng số lượng thành công");
            }

            // Set lại parameters để giữ form
            request.setAttribute("statusFilter", statusFilter);
            request.setAttribute("timeFilter", timeFilter);
            request.setAttribute("fromDate", fromDateFormatted);
            request.setAttribute("toDate", toDateFormatted);
            request.setAttribute("viewType", viewType);

            LOGGER.info("➡️ Forward sang partStatistics.jsp");
            request.getRequestDispatcher("partStatistics.jsp").forward(request, response);

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "❌ Lỗi khi xử lý thống kê PartDetail", e);
            response.getWriter().println("<h2 style='color:red;'>Đã xảy ra lỗi khi tải thống kê:</h2><pre>" 
                                         + e.getMessage() + "</pre>");
        }
    }

    @Override
    public String getServletInfo() {
        return "Part Detail Statistics Servlet - Based on History Table";
    }
}