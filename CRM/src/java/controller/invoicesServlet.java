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
    
    @Override
    public void init() throws ServletException {
        invoiceDAO = new InvoiceDAO();
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

    // ✅ Lấy hóa đơn theo từng báo giá (1 báo giá = 1 hóa đơn)
    List<Map<String, Object>> rawInvoices = invoiceDAO.getInvoicesByCustomerWithReport(customerId);

    List<InvoiceItem> invoiceList = new ArrayList<>();
    for (Map<String, Object> row : rawInvoices) {
        Invoice inv = new Invoice();
        inv.setInvoiceId((Integer) row.get("invoiceId"));
        inv.setContractId((Integer) row.get("contractId"));

        java.sql.Date issueDate = (java.sql.Date) row.get("issueDate");
        java.sql.Date dueDate = (java.sql.Date) row.get("dueDate");
        if (issueDate != null) inv.setIssueDate(issueDate.toLocalDate());
        if (dueDate != null) inv.setDueDate(dueDate.toLocalDate());

        inv.setTotalAmount((Double) row.get("totalAmount"));
        inv.setStatus((String) row.get("status"));
        inv.setPaymentMethod((String) row.get("paymentMethod"));

        InvoiceItem item = new InvoiceItem();
        item.setInvoice(inv);
        item.setFormattedContractId("CTR" + String.format("%04d", inv.getContractId()));
        item.setExtraInfo("#RP" + row.get("reportId") + " - " + row.get("reportDescription"));
        invoiceList.add(item);
    }

    // ✅ Thống kê đơn giản
    int totalInvoices = invoiceList.size();
    long paidCount = invoiceList.stream()
            .filter(i -> "Paid".equalsIgnoreCase(i.getInvoice().getStatus()))
            .count();
    long pendingCount = invoiceList.stream()
            .filter(i -> "Pending".equalsIgnoreCase(i.getInvoice().getStatus()))
            .count();
    double totalAmount = invoiceList.stream()
            .mapToDouble(i -> i.getInvoice().getTotalAmount())
            .sum();

    request.setAttribute("invoiceList", invoiceList);
    request.setAttribute("totalInvoices", totalInvoices);
    request.setAttribute("paidCount", paidCount);
    request.setAttribute("pendingCount", pendingCount);
    request.setAttribute("totalAmount", totalAmount);
    request.setAttribute("searchMode", false);
    request.setAttribute("viewMode", "list");

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
        
        // Kiểm tra xem có tiêu chí tìm kiếm nào không
        boolean hasSearchCriteria = (keyword != null && !keyword.trim().isEmpty()) ||
                                   (status != null && !status.trim().isEmpty()) ||
                                   (paymentMethod != null && !paymentMethod.trim().isEmpty()) ||
                                   (fromDate != null && !fromDate.trim().isEmpty()) ||
                                   (toDate != null && !toDate.trim().isEmpty()) ||
                                   (fromDueDate != null && !fromDueDate.trim().isEmpty()) ||
                                   (toDueDate != null && !toDueDate.trim().isEmpty());
        
        List<Invoice> invoices;
        if (hasSearchCriteria) {
            // Tìm kiếm nâng cao
            invoices = invoiceDAO.searchInvoicesAdvanced(customerId, keyword, status, 
                    paymentMethod, sortBy, fromDate, toDate, fromDueDate, toDueDate);
        } else {
            // Không có tiêu chí tìm kiếm, hiển thị tất cả với sắp xếp
            invoices = invoiceDAO.getInvoicesByCustomerId(customerId);
            // Áp dụng sắp xếp nếu có
            if (sortBy != null && !sortBy.trim().isEmpty()) {
                sortInvoices(invoices, sortBy);
            }
        }
        
        // Tạo danh sách InvoiceItem
        List<InvoiceItem> invoiceList = new ArrayList<>();
        for (Invoice invoice : invoices) {
            InvoiceItem item = new InvoiceItem();
            item.setInvoice(invoice);
            item.setFormattedContractId("CTR" + String.format("%04d", invoice.getContractId()));
            invoiceList.add(item);
        }
        
        // Lấy thống kê - tạm thời dùng phương thức test
        int totalInvoices = invoiceDAO.countTotalInvoicesForTest();
        int paidCount = invoiceDAO.countPaidInvoicesForTest();
        int pendingCount = invoiceDAO.countPendingInvoicesForTest();
        double totalAmount = invoiceDAO.calculateTotalAmountForTest();
        
        // Set attributes
        request.setAttribute("invoiceList", invoiceList);
        request.setAttribute("totalInvoices", totalInvoices);
        request.setAttribute("paidCount", paidCount);
        request.setAttribute("pendingCount", pendingCount);
        request.setAttribute("totalAmount", totalAmount);
        request.setAttribute("searchMode", hasSearchCriteria);
        request.setAttribute("keyword", keyword);
        request.setAttribute("viewMode", "list");
        
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
            int customerId = account.getAccountId(); // SỬA LẠI: dùng getAccountId() thay vì getUserId()
            
            // Lấy thông tin hóa đơn
            Invoice invoice = invoiceDAO.getInvoiceById(invoiceId);
            
            if (invoice == null) {
                response.sendRedirect(request.getContextPath() + "/invoices?error=" + 
                        java.net.URLEncoder.encode("Không tìm thấy hóa đơn", "UTF-8"));
                return;
            }
            
            // Lấy chi tiết hóa đơn
            List<InvoiceDetail> invoiceDetails = invoiceDAO.getInvoiceDetails(invoiceId);
            
            // Lấy chi tiết linh kiện từ báo cáo sửa chữa
            List<Map<String, Object>> repairPartDetails = invoiceDAO.getRepairPartDetails(invoiceId);
            double partsTotalAmount = invoiceDAO.calculatePartsTotalForInvoice(invoiceId);
            List<Map<String, Object>> partsCategoryStats = invoiceDAO.getPartsCategoryStats(invoiceId);
            
            // Vẫn lấy danh sách và thống kê để hiển thị - dùng phương thức test
            List<Invoice> invoices = invoiceDAO.getAllInvoicesForTest();
            List<InvoiceItem> invoiceList = new ArrayList<>();
            for (Invoice inv : invoices) {
                InvoiceItem item = new InvoiceItem();
                item.setInvoice(inv);
                item.setFormattedContractId("CTR" + String.format("%04d", inv.getContractId()));
                invoiceList.add(item);
            }
            
            // Lấy thống kê - dùng phương thức test
            int totalInvoices = invoiceDAO.countTotalInvoicesForTest();
            int paidCount = invoiceDAO.countPaidInvoicesForTest();
            int pendingCount = invoiceDAO.countPendingInvoicesForTest();
            double totalAmount = invoiceDAO.calculateTotalAmountForTest();
            
            // Set attributes cho danh sách
            request.setAttribute("invoiceList", invoiceList);
            request.setAttribute("totalInvoices", totalInvoices);
            request.setAttribute("paidCount", paidCount);
            request.setAttribute("pendingCount", pendingCount);
            request.setAttribute("totalAmount", totalAmount);
            
            // Set attributes cho chi tiết
            request.setAttribute("selectedInvoice", invoice);
            request.setAttribute("invoiceDetails", invoiceDetails);
            request.setAttribute("repairPartDetails", repairPartDetails);
            request.setAttribute("partsTotalAmount", partsTotalAmount);
            request.setAttribute("partsCategoryStats", partsCategoryStats);
            request.setAttribute("formattedContractId", "CTR" + String.format("%04d", invoice.getContractId()));
            request.setAttribute("viewMode", "detail");
            
            // Forward to JSP
            request.getRequestDispatcher("/invoices.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/invoices?error=" + 
                    java.net.URLEncoder.encode("ID hóa đơn không hợp lệ", "UTF-8"));
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