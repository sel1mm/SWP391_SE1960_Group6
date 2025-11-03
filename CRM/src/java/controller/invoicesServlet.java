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
        
        int customerId = account.getAccountId(); // SỬA LẠI: dùng getAccountId() thay vì getUserId()
        
        // Lấy danh sách hóa đơn
        List<Invoice> invoices = invoiceDAO.getInvoicesByCustomerId(customerId);
        
        // Tạo danh sách InvoiceItem với formatted contract ID
        List<InvoiceItem> invoiceList = new ArrayList<>();
        for (Invoice invoice : invoices) {
            InvoiceItem item = new InvoiceItem();
            item.setInvoice(invoice);
            item.setFormattedContractId("CTR" + String.format("%04d", invoice.getContractId()));
            invoiceList.add(item);
        }
        
        // Lấy thống kê
        int totalInvoices = invoiceDAO.countTotalInvoices(customerId);
        int paidCount = invoiceDAO.countPaidInvoices(customerId);
        int pendingCount = invoiceDAO.countPendingInvoices(customerId);
        double totalAmount = invoiceDAO.calculateTotalAmount(customerId);
        
        // Set attributes
        request.setAttribute("invoiceList", invoiceList);
        request.setAttribute("totalInvoices", totalInvoices);
        request.setAttribute("paidCount", paidCount);
        request.setAttribute("pendingCount", pendingCount);
        request.setAttribute("totalAmount", totalAmount);
        request.setAttribute("searchMode", false);
        request.setAttribute("viewMode", "list");
        
        // Forward to JSP
        request.getRequestDispatcher("/invoices.jsp").forward(request, response);
    }
    
    // Xử lý tìm kiếm
    private void handleSearch(HttpServletRequest request, HttpServletResponse response, Account account)
            throws ServletException, IOException {
        
        int customerId = account.getAccountId(); // SỬA LẠI: dùng getAccountId() thay vì getUserId()
        String keyword = request.getParameter("keyword");
        
        if (keyword == null || keyword.trim().isEmpty()) {
            handleList(request, response, account);
            return;
        }
        
        // Tìm kiếm hóa đơn
        List<Invoice> invoices = invoiceDAO.searchInvoices(customerId, keyword.trim());
        
        // Tạo danh sách InvoiceItem
        List<InvoiceItem> invoiceList = new ArrayList<>();
        for (Invoice invoice : invoices) {
            InvoiceItem item = new InvoiceItem();
            item.setInvoice(invoice);
            item.setFormattedContractId("CTR" + String.format("%04d", invoice.getContractId()));
            invoiceList.add(item);
        }
        
        // Lấy thống kê (vẫn lấy từ tất cả hóa đơn)
        int totalInvoices = invoiceDAO.countTotalInvoices(customerId);
        int paidCount = invoiceDAO.countPaidInvoices(customerId);
        int pendingCount = invoiceDAO.countPendingInvoices(customerId);
        double totalAmount = invoiceDAO.calculateTotalAmount(customerId);
        
        // Set attributes
        request.setAttribute("invoiceList", invoiceList);
        request.setAttribute("totalInvoices", totalInvoices);
        request.setAttribute("paidCount", paidCount);
        request.setAttribute("pendingCount", pendingCount);
        request.setAttribute("totalAmount", totalAmount);
        request.setAttribute("searchMode", true);
        request.setAttribute("keyword", keyword);
        request.setAttribute("viewMode", "list");
        
        // Forward to JSP
        request.getRequestDispatcher("/invoices.jsp").forward(request, response);
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
            
            // Vẫn lấy danh sách và thống kê để hiển thị
            List<Invoice> invoices = invoiceDAO.getInvoicesByCustomerId(customerId);
            List<InvoiceItem> invoiceList = new ArrayList<>();
            for (Invoice inv : invoices) {
                InvoiceItem item = new InvoiceItem();
                item.setInvoice(inv);
                item.setFormattedContractId("CTR" + String.format("%04d", inv.getContractId()));
                invoiceList.add(item);
            }
            
            // Lấy thống kê
            int totalInvoices = invoiceDAO.countTotalInvoices(customerId);
            int paidCount = invoiceDAO.countPaidInvoices(customerId);
            int pendingCount = invoiceDAO.countPendingInvoices(customerId);
            double totalAmount = invoiceDAO.calculateTotalAmount(customerId);
            
            // Set attributes cho danh sách
            request.setAttribute("invoiceList", invoiceList);
            request.setAttribute("totalInvoices", totalInvoices);
            request.setAttribute("paidCount", paidCount);
            request.setAttribute("pendingCount", pendingCount);
            request.setAttribute("totalAmount", totalAmount);
            
            // Set attributes cho chi tiết
            request.setAttribute("selectedInvoice", invoice);
            request.setAttribute("invoiceDetails", invoiceDetails);
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