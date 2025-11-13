package controller;

import dal.InvoiceDAO;
import model.Invoice;
import model.InvoiceDetail;
import model.InvoiceItem;
import model.Account;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@WebServlet(name = "invoicesServlet", urlPatterns = {"/invoices"})
public class invoicesServlet extends HttpServlet {

    private InvoiceDAO invoiceDAO;

    // ✅ THÊM PAGE_SIZE CONSTANT
    private static final int PAGE_SIZE = 2;

    @Override
    public void init() throws ServletException {
        invoiceDAO = new InvoiceDAO();
        System.out.println("✅ InvoiceDAO initialized");
        System.out.println("📄 PAGE_SIZE configured: " + PAGE_SIZE + " hóa đơn/trang");
    }

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("session_login");

        // Kiểm tra đăng nhập
        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");

        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "search":
                handleSearch(request, response, account);
                break;
            case "view":
                handleViewDetail(request, response, account);
                break;
            default:
                handleList(request, response, account);
                break;
        }
    }

    // Hiển thị danh sách hóa đơn
    private void handleList(HttpServletRequest request, HttpServletResponse response, Account account)
            throws ServletException, IOException {

        int customerId = account.getAccountId();

        System.out.println("🚀 handleList for customer: " + customerId);

        // ✅ LẤY TRANG HIỆN TẠI
        int currentPage = 1;
        String pageParam = request.getParameter("page");
        if (pageParam != null && !pageParam.isEmpty()) {
            try {
                currentPage = Integer.parseInt(pageParam);
                if (currentPage < 1) {
                    currentPage = 1;
                }
            } catch (NumberFormatException e) {
                currentPage = 1;
            }
        }

        // ✅ Lấy danh sách hóa đơn theo customer
        List<Invoice> invoices = invoiceDAO.getInvoicesByCustomerId(customerId);

        // Tạo danh sách InvoiceItem với formatted contract ID
        List<InvoiceItem> fullList = new ArrayList<>();
        for (Invoice invoice : invoices) {
            InvoiceItem item = new InvoiceItem();
            item.setInvoice(invoice);
            item.setFormattedContractId("CTR" + String.format("%04d", invoice.getContractId()));
            fullList.add(item);
        }

        // ============ PHÂN TRANG ============
        int totalItems = fullList.size();
        int totalPages = (totalItems > 0) ? (int) Math.ceil((double) totalItems / PAGE_SIZE) : 0;

        // Đảm bảo currentPage hợp lệ
        if (currentPage < 1) {
            currentPage = 1;
        }
        if (currentPage > totalPages && totalPages > 0) {
            currentPage = totalPages;
        }

        int startIndex = (currentPage - 1) * PAGE_SIZE;
        int endIndex = Math.min(startIndex + PAGE_SIZE, totalItems);

        List<InvoiceItem> paginatedList = new ArrayList<>();
        if (startIndex < totalItems && startIndex >= 0) {
            paginatedList = fullList.subList(startIndex, endIndex);
        }

        System.out.println("📄 Pagination Info:");
        System.out.println("   - Total items: " + totalItems);
        System.out.println("   - Page size: " + PAGE_SIZE);
        System.out.println("   - Total pages: " + totalPages);
        System.out.println("   - Current page: " + currentPage);
        System.out.println("   - Start index: " + startIndex);
        System.out.println("   - End index: " + endIndex);
        System.out.println("   - Items on this page: " + paginatedList.size());

        // ✅ Lấy thống kê theo customer
        int totalInvoices = invoiceDAO.countTotalInvoices(customerId);
        int paidCount = invoiceDAO.countPaidInvoices(customerId);
        int pendingCount = invoiceDAO.countPendingInvoices(customerId);
        double totalAmount = invoiceDAO.calculateTotalAmount(customerId);

        // Debug info
        System.out.println("DEBUG: Customer ID = " + customerId);
        System.out.println("DEBUG: Total invoices found = " + invoices.size());
        System.out.println("DEBUG: Paginated list size = " + paginatedList.size());

        // Set attributes
        request.setAttribute("invoiceList", paginatedList);
        request.setAttribute("totalInvoices", totalInvoices);
        request.setAttribute("paidCount", paidCount);
        request.setAttribute("pendingCount", pendingCount);
        request.setAttribute("totalAmount", totalAmount);
        request.setAttribute("searchMode", false);
        request.setAttribute("viewMode", "list");
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalItems", totalItems);

        System.out.println("✅ Attributes set for JSP:");
        System.out.println("   - invoiceList size: " + paginatedList.size());
        System.out.println("   - currentPage: " + currentPage);
        System.out.println("   - totalPages: " + totalPages);
        System.out.println("   - totalItems: " + totalItems);

        // Forward to JSP
        request.getRequestDispatcher("/invoices.jsp").forward(request, response);
    }

    // Xử lý tìm kiếm
    private void handleSearch(HttpServletRequest request, HttpServletResponse response, Account account)
            throws ServletException, IOException {

        int customerId = account.getAccountId();

        // Lấy các tham số tìm kiếm
        String keyword = request.getParameter("keyword");
        String status = request.getParameter("status");
        String paymentMethod = request.getParameter("paymentMethod");
        String sortBy = request.getParameter("sortBy");
        String fromDate = request.getParameter("fromDate");
        String toDate = request.getParameter("toDate");
        String fromDueDate = request.getParameter("fromDueDate");
        String toDueDate = request.getParameter("toDueDate");

        System.out.println("🔍 Search - Keyword: " + keyword + ", Status: " + status
                + ", PaymentMethod: " + paymentMethod + ", Sort: " + sortBy);

        // Kiểm tra xem có tiêu chí tìm kiếm nào không
        boolean hasSearchCriteria = (keyword != null && !keyword.trim().isEmpty())
                || (status != null && !status.trim().isEmpty())
                || (paymentMethod != null && !paymentMethod.trim().isEmpty())
                || (fromDate != null && !fromDate.trim().isEmpty())
                || (toDate != null && !toDate.trim().isEmpty())
                || (fromDueDate != null && !fromDueDate.trim().isEmpty())
                || (toDueDate != null && !toDueDate.trim().isEmpty());

        List<Invoice> invoices;
        if (hasSearchCriteria) {
            // Tìm kiếm nâng cao
            invoices = invoiceDAO.searchInvoicesAdvanced(customerId, keyword, status,
                    paymentMethod, sortBy, fromDate, toDate, fromDueDate, toDueDate);
        } else {
            // ✅ Không có tiêu chí tìm kiếm, hiển thị tất cả theo customer
            invoices = invoiceDAO.getInvoicesByCustomerId(customerId);
            // Áp dụng sắp xếp nếu có
            if (sortBy != null && !sortBy.trim().isEmpty()) {
                sortInvoices(invoices, sortBy);
            }
        }

        // Tạo danh sách InvoiceItem
        List<InvoiceItem> fullList = new ArrayList<>();
        for (Invoice invoice : invoices) {
            InvoiceItem item = new InvoiceItem();
            item.setInvoice(invoice);
            item.setFormattedContractId("CTR" + String.format("%04d", invoice.getContractId()));
            fullList.add(item);
        }

        // ============ PHÂN TRANG ============
        int currentPage = 1;
        String pageParam = request.getParameter("page");
        if (pageParam != null && !pageParam.isEmpty()) {
            try {
                currentPage = Integer.parseInt(pageParam);
                if (currentPage < 1) {
                    currentPage = 1;
                }
            } catch (NumberFormatException e) {
                currentPage = 1;
            }
        }

        int totalItems = fullList.size();
        int totalPages = (totalItems > 0) ? (int) Math.ceil((double) totalItems / PAGE_SIZE) : 0;

        // Đảm bảo currentPage hợp lệ
        if (currentPage < 1) {
            currentPage = 1;
        }
        if (currentPage > totalPages && totalPages > 0) {
            currentPage = totalPages;
        }

        int startIndex = (currentPage - 1) * PAGE_SIZE;
        int endIndex = Math.min(startIndex + PAGE_SIZE, totalItems);

        List<InvoiceItem> paginatedList = new ArrayList<>();
        if (startIndex < totalItems && startIndex >= 0) {
            paginatedList = fullList.subList(startIndex, endIndex);
        }

        System.out.println("✅ Search Results:");
        System.out.println("   - Total items found: " + totalItems);
        System.out.println("   - Total pages: " + totalPages);
        System.out.println("   - Current page: " + currentPage);
        System.out.println("   - Items on this page: " + paginatedList.size());

        // ✅ Lấy thống kê theo customer
        int totalInvoices = invoiceDAO.countTotalInvoices(customerId);
        int paidCount = invoiceDAO.countPaidInvoices(customerId);
        int pendingCount = invoiceDAO.countPendingInvoices(customerId);
        double totalAmount = invoiceDAO.calculateTotalAmount(customerId);

        // Set attributes
        request.setAttribute("invoiceList", paginatedList);
        request.setAttribute("totalInvoices", totalInvoices);
        request.setAttribute("paidCount", paidCount);
        request.setAttribute("pendingCount", pendingCount);
        request.setAttribute("totalAmount", totalAmount);
        request.setAttribute("searchMode", hasSearchCriteria);
        request.setAttribute("keyword", keyword);
        request.setAttribute("viewMode", "list");
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalItems", totalItems);

        System.out.println("✅ Search Attributes set for JSP:");
        System.out.println("   - invoiceList size: " + paginatedList.size());
        System.out.println("   - currentPage: " + currentPage);
        System.out.println("   - totalPages: " + totalPages);
        System.out.println("   - totalItems: " + totalItems);

        // Forward to JSP
        request.getRequestDispatcher("/invoices.jsp").forward(request, response);
    }

    // Phương thức sắp xếp danh sách hóa đơn
    private void sortInvoices(List<Invoice> invoices, String sortBy) {
        switch (sortBy) {
            case "newest":
                invoices.sort((a, b) -> b.getIssueDate().compareTo(a.getIssueDate()));
                break;
            case "oldest":
                invoices.sort((a, b) -> a.getIssueDate().compareTo(b.getIssueDate()));
                break;
            case "amount_asc":
                invoices.sort((a, b) -> Double.compare(a.getTotalAmount(), b.getTotalAmount()));
                break;
            case "amount_desc":
                invoices.sort((a, b) -> Double.compare(b.getTotalAmount(), a.getTotalAmount()));
                break;
        }
    }

    // Xem chi tiết hóa đơn (hiển thị trên cùng trang)
    private void handleViewDetail(HttpServletRequest request, HttpServletResponse response, Account account)
            throws ServletException, IOException {

        try {
            int invoiceId = Integer.parseInt(request.getParameter("id"));
            int customerId = account.getAccountId();

            System.out.println("🔍 ============================================");
            System.out.println("🔍 Viewing invoice detail");
            System.out.println("🔍 Invoice ID: " + invoiceId);
            System.out.println("🔍 Customer ID: " + customerId);
            System.out.println("🔍 ============================================");

            // ✅ Lấy thông tin hóa đơn
            Invoice invoice = invoiceDAO.getInvoiceById(invoiceId);

            if (invoice == null) {
                System.out.println("❌ Invoice not found: " + invoiceId);
                response.sendRedirect(request.getContextPath() + "/invoices?error="
                        + java.net.URLEncoder.encode("Không tìm thấy hóa đơn", "UTF-8"));
                return;
            }

            System.out.println("✅ Invoice found: #INV" + invoiceId);
            System.out.println("   - Contract ID: " + invoice.getContractId());
            System.out.println("   - Total Amount: $" + invoice.getTotalAmount());
            System.out.println("   - Status: " + invoice.getStatus());

            // ✅ Lấy chi tiết hóa đơn (InvoiceDetail)
            List<InvoiceDetail> invoiceDetails = invoiceDAO.getInvoiceDetails(invoiceId);
            System.out.println("📋 Invoice details count: " + invoiceDetails.size());
            for (InvoiceDetail detail : invoiceDetails) {
                System.out.println("   - " + detail.getDescription() + ": $" + detail.getAmount());
            }

            // ✅ Lấy chi tiết linh kiện từ báo cáo sửa chữa
            List<Map<String, Object>> repairPartDetails = invoiceDAO.getRepairPartDetails(invoiceId);
            System.out.println("🔧 Repair parts count: " + repairPartDetails.size());
            for (Map<String, Object> part : repairPartDetails) {
                System.out.println("   - " + part.get("partName")
                        + " x" + part.get("quantity")
                        + " = $" + part.get("totalPrice"));
            }

            // ✅ Tính tổng tiền linh kiện
            double partsTotalAmount = invoiceDAO.calculatePartsTotalForInvoice(invoiceId);
            System.out.println("💰 Parts total amount: $" + partsTotalAmount);

            // ✅ Lấy thống kê theo danh mục
            List<Map<String, Object>> partsCategoryStats = invoiceDAO.getPartsCategoryStats(invoiceId);
            System.out.println("📊 Category stats count: " + partsCategoryStats.size());
            for (Map<String, Object> stat : partsCategoryStats) {
                System.out.println("   - " + stat.get("category")
                        + ": " + stat.get("partCount") + " parts"
                        + ", Total: $" + stat.get("categoryTotal"));
            }

            // ✅ Vẫn lấy danh sách và thống kê để hiển thị bên dưới
            List<Invoice> invoices = invoiceDAO.getInvoicesByCustomerId(customerId);
            List<InvoiceItem> invoiceList = new ArrayList<>();
            for (Invoice inv : invoices) {
                InvoiceItem item = new InvoiceItem();
                item.setInvoice(inv);
                item.setFormattedContractId("CTR" + String.format("%04d", inv.getContractId()));
                invoiceList.add(item);
            }

            // ✅ Lấy thống kê - theo customer
            int totalInvoices = invoiceDAO.countTotalInvoices(customerId);
            int paidCount = invoiceDAO.countPaidInvoices(customerId);
            int pendingCount = invoiceDAO.countPendingInvoices(customerId);
            double totalAmount = invoiceDAO.calculateTotalAmount(customerId);

            // ✅ Set attributes cho danh sách (hiển thị ở cuối trang)
            request.setAttribute("invoiceList", invoiceList);
            request.setAttribute("totalInvoices", totalInvoices);
            request.setAttribute("paidCount", paidCount);
            request.setAttribute("pendingCount", pendingCount);
            request.setAttribute("totalAmount", totalAmount);

            // ✅ Set attributes cho chi tiết (hiển thị ở đầu trang)
            request.setAttribute("selectedInvoice", invoice);
            request.setAttribute("invoiceDetails", invoiceDetails);
            request.setAttribute("repairPartDetails", repairPartDetails);
            request.setAttribute("partsTotalAmount", partsTotalAmount);
            request.setAttribute("partsCategoryStats", partsCategoryStats);
            request.setAttribute("formattedContractId", "CTR" + String.format("%04d", invoice.getContractId()));
            request.setAttribute("viewMode", "detail");

            System.out.println("✅ ============================================");
            System.out.println("✅ All data loaded successfully!");
            System.out.println("✅ Forwarding to invoices.jsp...");
            System.out.println("✅ ============================================");

            // Forward to JSP
            request.getRequestDispatcher("/invoices.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            System.out.println("❌ Invalid invoice ID format");
            response.sendRedirect(request.getContextPath() + "/invoices?error="
                    + java.net.URLEncoder.encode("ID hóa đơn không hợp lệ", "UTF-8"));
        } catch (Exception e) {
            System.out.println("💥 ERROR in handleViewDetail: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/invoices?error="
                    + java.net.URLEncoder.encode("Có lỗi xảy ra khi xem chi tiết hóa đơn", "UTF-8"));
        }
    }

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

    @Override
    public String getServletInfo() {
        return "Invoice Management Servlet";
    }
}
