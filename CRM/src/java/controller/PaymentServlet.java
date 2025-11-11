package controller;

import java.io.IOException;
import dal.ServiceRequestDAO;
import dal.ContractDAO;
import dal.InvoiceDAO;
import dal.PaymentDAO;
import service.VNPayService;
import config.VNPayConfig;
import model.ServiceRequest;
import model.Contract;
import model.RepairReport;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;
import java.sql.*;
import java.time.LocalDate;

@WebServlet(name = "PaymentServlet", urlPatterns = {"/payment"})
public class PaymentServlet extends HttpServlet {
    
    private ServiceRequestDAO serviceRequestDAO;
    private ContractDAO contractDAO;
    private InvoiceDAO invoiceDAO;
    private PaymentDAO paymentDAO;
    private VNPayService vnPayService;
    
    @Override
    public void init() throws ServletException {
        serviceRequestDAO = new ServiceRequestDAO();
        contractDAO = new ContractDAO();
        invoiceDAO = new InvoiceDAO();
        paymentDAO = new PaymentDAO();
        vnPayService = new VNPayService();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Integer customerId = (Integer) session.getAttribute("session_login_id");
        
        if (customerId == null) {
            session.setAttribute("error", "Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        String requestIdStr = request.getParameter("requestId");
        String reportIdStr = request.getParameter("reportId");  // ✅ THÊM PARAMETER reportId
        
        System.out.println("=== PAYMENT SERVLET GET ===");
        System.out.println("✅ RequestIdStr: " + requestIdStr);
        System.out.println("✅ ReportIdStr: " + reportIdStr);  // ✅ DEBUG reportId
        System.out.println("✅ CustomerId: " + customerId);
        
        if (requestIdStr == null || requestIdStr.trim().isEmpty()) {
            System.err.println("❌ ERROR: RequestId is null or empty!");
            session.setAttribute("error", "Mã yêu cầu không hợp lệ!");
            response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
            return;
        }
        
        try {
            int requestId = Integer.parseInt(requestIdStr.trim());
            
            // Lấy Service Request với thông tin chi tiết
            ServiceRequest sr = serviceRequestDAO.getRequestById(requestId);
            
            System.out.println("=== CHECKING SERVICE REQUEST PERMISSION ===");
            System.out.println("✅ RequestId: " + requestId);
            System.out.println("✅ ServiceRequest found: " + (sr != null));
            
            if (sr != null) {
                System.out.println("✅ ServiceRequest.createdBy: " + sr.getCreatedBy());
                System.out.println("✅ Current customerId: " + customerId);
            }
            
            if (sr == null) {
                System.err.println("❌ ERROR: ServiceRequest not found!");
                session.setAttribute("error", "Không tìm thấy yêu cầu dịch vụ!");
                response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
                return;
            }
            
            if (sr.getCreatedBy() != customerId) {
                System.err.println("❌ ERROR: Permission denied!");
                session.setAttribute("error", "Bạn không có quyền xem yêu cầu này!");
                response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
                return;
            }
            
            // Lấy thông tin customer
            model.ServiceRequestDetailDTO2 requestDetail = serviceRequestDAO.getRequestDetailById(requestId);
            if (requestDetail != null) {
                sr.setCustomerName(requestDetail.getCustomerName());
                sr.setCustomerEmail(requestDetail.getCustomerEmail());
                sr.setCustomerPhone(requestDetail.getCustomerPhone());
            }
            
            // Lấy Contract
            Contract contract = null;
            List<Map<String, Object>> contractEquipmentList = new ArrayList<>();
            Integer contractId = sr.getContractId();
            
            if (contractId != null && contractId > 0) {
                contract = contractDAO.getContractById(contractId);
                if (contract != null) {
                    contractEquipmentList = getContractEquipmentWithDetails(contractId);
                }
            }
            
            if (contract == null) {
                contract = new Contract();
                contract.setContractId(contractId != null ? contractId : 0);
            }
            
            // ✅✅✅ LOGIC MỚI: LẤY REPAIR REPORT THEO reportId NẾU CÓ ✅✅✅
            RepairReport repairReport = null;
            
            if (reportIdStr != null && !reportIdStr.trim().isEmpty()) {
                // ✅ Có reportId → Lấy báo giá của technician cụ thể
                try {
                    int reportId = Integer.parseInt(reportIdStr.trim());
                    System.out.println("🎯 SPECIFIC TECHNICIAN PAYMENT");
                    System.out.println("   - Fetching RepairReport with reportId: " + reportId);
                    
                    repairReport = serviceRequestDAO.getRepairReportById(reportId);
                    
                    if (repairReport != null) {
                        System.out.println("✅ Found specific technician's report:");
                        System.out.println("   - ReportId: " + repairReport.getReportId());
                        System.out.println("   - TechnicianName: " + repairReport.getTechnicianName());
                        System.out.println("   - EstimatedCost: " + repairReport.getEstimatedCost());
                    } else {
                        System.err.println("⚠️ RepairReport not found for reportId: " + reportId);
                        session.setAttribute("error", "Không tìm thấy báo giá của kỹ thuật viên này!");
                        response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
                        return;
                    }
                } catch (NumberFormatException e) {
                    System.err.println("❌ Invalid reportId format: " + reportIdStr);
                }
            } else {
                // ✅ Không có reportId → Lấy bất kỳ báo giá nào (backward compatibility)
                System.out.println("⚠️ NO REPORT ID - Using old logic (any technician)");
                repairReport = serviceRequestDAO.getRepairReportByRequestId(requestId);
            }
            
            System.out.println("=== PAYMENT SERVLET DEBUG ===");
            System.out.println("✅ RequestId: " + requestId);
            System.out.println("✅ ReportId parameter: " + reportIdStr);
            if (repairReport != null) {
                System.out.println("✅ RepairReport EXISTS:");
                System.out.println("   - ReportId: " + repairReport.getReportId());
                System.out.println("   - TechnicianName: " + repairReport.getTechnicianName());
                System.out.println("   - EstimatedCost: " + repairReport.getEstimatedCost());
                System.out.println("   - QuotationStatus: " + repairReport.getQuotationStatus());
            } else {
                System.out.println("⚠️ RepairReport is NULL");
            }
            
            // ✅ THÊM LOGIC: Tạo Payment.pending khi mở trang (nếu chưa có)
            if (repairReport != null) {
                int reportId = repairReport.getReportId();
                
                // Kiểm tra đã có Payment pending cho RepairReport này chưa
                Integer existingPaymentId = paymentDAO.getPendingPaymentByReportId(reportId);
                
                if (existingPaymentId == null) {
                    System.out.println("=== CREATING PENDING PAYMENT ===");
                    
                    // Tạo Invoice pending trước
                    double amount = repairReport.getEstimatedCost() != null ? 
                                   repairReport.getEstimatedCost().doubleValue() : 0;
                    
                    int invoiceId = invoiceDAO.createInvoice(
                        contractId, 
                        amount, 
                        "Pending", 
                        LocalDate.now().plusDays(30), 
                        null
                    );
                    
                    if (invoiceId > 0) {
                        
                        // Tạo Payment pending và link với reportId
                        int paymentId = paymentDAO.createPaymentWithReport(
                            invoiceId, 
                            amount, 
                            "Pending",
                            reportId  // ✅ Link với RepairReport cụ thể
                        );
                        
                        System.out.println("✅ Created Pending Payment:");
                        System.out.println("   - PaymentId: " + paymentId);
                        System.out.println("   - InvoiceId: " + invoiceId);
                        System.out.println("   - ReportId: " + reportId);
                        System.out.println("   - TechnicianName: " + repairReport.getTechnicianName());
                        System.out.println("   - Amount: " + amount);
                        
                        // Lưu vào session để tracking
                        session.setAttribute("pendingPaymentId", paymentId);
                        session.setAttribute("pendingInvoiceId", invoiceId);
                        session.setAttribute("pendingReportId", reportId);
                    }
                } else {
                    System.out.println("⚠️ Payment already exists: " + existingPaymentId);
                    session.setAttribute("pendingPaymentId", existingPaymentId);
                }
            }
            
            // Set attributes
            request.setAttribute("serviceRequest", sr);
            request.setAttribute("contract", contract);
            request.setAttribute("contractEquipmentList", contractEquipmentList);
            request.setAttribute("repairReport", repairReport);
            
            // Forward to payment page
            request.getRequestDispatcher("/payment.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            session.setAttribute("error", "Mã yêu cầu phải là số nguyên!");
            response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
        } catch (Exception e) {
            System.err.println("❌ Error loading payment page: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Integer customerId = (Integer) session.getAttribute("session_login_id");
        
        if (customerId == null) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{\"success\":false,\"error\":\"Phiên đăng nhập đã hết hạn.\"}");
            response.getWriter().flush();
            return;
        }
        
        String requestIdStr = request.getParameter("requestId");
        String paymentMethod = request.getParameter("paymentMethod");
        
        System.out.println("=== PAYMENT SERVLET POST ===");
        System.out.println("RequestId: " + requestIdStr);
        System.out.println("PaymentMethod: " + paymentMethod);
        
        if (requestIdStr == null || requestIdStr.trim().isEmpty()) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{\"success\":false,\"error\":\"Mã yêu cầu không hợp lệ!\"}");
            response.getWriter().flush();
            return;
        }
        
        if (paymentMethod == null || paymentMethod.trim().isEmpty()) {
            paymentMethod = "VNPay";
        }
        
        try {
            int requestId = Integer.parseInt(requestIdStr.trim());
            
            // Kiểm tra quyền
            ServiceRequest sr = serviceRequestDAO.getRequestById(requestId);
            if (sr == null || sr.getCreatedBy() != customerId) {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"success\":false,\"error\":\"Bạn không có quyền!\"}");
                response.getWriter().flush();
                return;
            }
            
            // Lấy RepairReport (sử dụng reportId từ session nếu có)
            RepairReport report = null;
            Integer pendingReportId = (Integer) session.getAttribute("pendingReportId");
            
            if (pendingReportId != null && pendingReportId > 0) {
                report = serviceRequestDAO.getRepairReportById(pendingReportId);
                System.out.println("✅ Using reportId from session: " + pendingReportId);
            } else {
                report = serviceRequestDAO.getRepairReportByRequestId(requestId);
                System.out.println("⚠️ No reportId in session, using requestId");
            }
            
            double paymentAmount = 0;
            if (report != null && report.getEstimatedCost() != null) {
                paymentAmount = report.getEstimatedCost().doubleValue();
            }
            
            if (report == null) {
                System.out.println("⚠️ WARNING: RepairReport is null");
            }
            
            // Xử lý theo phương thức thanh toán
            if ("VNPay".equals(paymentMethod)) {
                handleVNPayPayment(request, response, session, sr, report, paymentAmount, requestId);
            } else if ("Cash".equals(paymentMethod)) {
                handleCashPayment(request, response, session, sr, report, paymentAmount, requestId);
            } else {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"success\":false,\"error\":\"Phương thức thanh toán không hợp lệ!\"}");
                response.getWriter().flush();
            }
            
        } catch (Exception e) {
            System.err.println("❌ Error: " + e.getMessage());
            e.printStackTrace();
            if (!response.isCommitted()) {
                response.reset();
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"success\":false,\"error\":\"Có lỗi xảy ra!\"}");
                response.getWriter().flush();
            }
        }
    }
    
    /**
     * Xử lý thanh toán VNPay
     */
    private void handleVNPayPayment(HttpServletRequest request, HttpServletResponse response, 
                                    HttpSession session, ServiceRequest sr, RepairReport report,
                                    double paymentAmount, int requestId) throws Exception {
        if (response.isCommitted()) {
            return;
        }
        
        response.reset();
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        int contractId = sr.getContractId() != null ? sr.getContractId() : 0;
        if (contractId <= 0) {
            response.getWriter().write("{\"success\":false,\"error\":\"Không tìm thấy hợp đồng!\"}");
            response.getWriter().flush();
            return;
        }
        
        // ✅ Sử dụng Payment pending đã tạo sẵn (nếu có)
        Integer pendingPaymentId = (Integer) session.getAttribute("pendingPaymentId");
        Integer pendingInvoiceId = (Integer) session.getAttribute("pendingInvoiceId");
        
        int invoiceId;
        if (pendingInvoiceId != null && pendingInvoiceId > 0) {
            invoiceId = pendingInvoiceId;
            System.out.println("✅ Using existing pending invoice: " + invoiceId);
        } else {
            // Tạo mới nếu chưa có
            invoiceId = invoiceDAO.createInvoice(contractId, paymentAmount, "Pending", 
                                                LocalDate.now().plusDays(30), null);
            if (invoiceId <= 0) {
                response.getWriter().write("{\"success\":false,\"error\":\"Không thể tạo hóa đơn!\"}");
                response.getWriter().flush();
                return;
            }
            invoiceDAO.createInvoiceDetail(invoiceId, "Thanh toán cho yêu cầu #" + requestId, paymentAmount);
        }
        
        // Lưu session để callback xử lý
        session.setAttribute("pendingInvoiceId", invoiceId);
        session.setAttribute("pendingRequestId", requestId);
        if (report != null) {
            session.setAttribute("pendingReportId", report.getReportId());
        }
        
        // Tạo VNPay URL
        String orderInfo = "Thanh toan yeu cau dich vu " + requestId;
        String randomSuffix = VNPayConfig.getRandomNumber(6);
        long timestamp = System.currentTimeMillis();
        String timestampShort = String.valueOf(timestamp).substring(3);
        String orderId = "ORDER" + requestId + "_" + timestampShort + "_" + randomSuffix;
        
        String vnpayUrl = vnPayService.createPaymentUrl((long)paymentAmount, orderInfo, orderId, requestId);
        
        if (vnpayUrl == null || !vnpayUrl.contains("sandbox.vnpayment.vn")) {
            response.getWriter().write("{\"success\":false,\"error\":\"URL thanh toán không hợp lệ!\"}");
            response.getWriter().flush();
            return;
        }
        
        String escapedUrl = vnpayUrl
            .replace("\\", "\\\\")
            .replace("\"", "\\\"")
            .replace("\n", "\\n")
            .replace("\r", "\\r")
            .replace("\t", "\\t");
        
        response.getWriter().write("{\"success\":true,\"redirectUrl\":\"" + escapedUrl + "\"}");
        response.getWriter().flush();
    }
    
    /**
     * Xử lý thanh toán tiền mặt
     */
    private void handleCashPayment(HttpServletRequest request, HttpServletResponse response,
                               HttpSession session, ServiceRequest sr, RepairReport report,
                               double paymentAmount, int requestId) throws Exception {
    if (response.isCommitted()) {
        return;
    }
    
    response.reset();
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    
    int contractId = sr.getContractId() != null ? sr.getContractId() : 0;
    if (contractId <= 0) {
        response.getWriter().write("{\"success\":false,\"error\":\"Không tìm thấy hợp đồng!\"}");
        response.getWriter().flush();
        return;
    }
    
    try {
        System.out.println("\n" + "=".repeat(80));
        System.out.println("========== CASH PAYMENT PROCESSING START ==========");
        System.out.println("=".repeat(80));
        System.out.println("✅ RequestId: " + requestId);
        System.out.println("✅ ContractId: " + contractId);
        System.out.println("✅ PaymentAmount: " + paymentAmount);
        System.out.println("✅ HasReport: " + (report != null));
        
        // ✅ Bước 1: Kiểm tra status hiện tại
        System.out.println("\n--- Step 1: Check current status ---");
        ServiceRequest currentSR = serviceRequestDAO.getRequestById(requestId);
        if (currentSR != null) {
            System.out.println("✅ Current ServiceRequest status: " + currentSR.getStatus());
        } else {
            System.err.println("❌ ERROR: ServiceRequest not found! RequestId=" + requestId);
            response.getWriter().write("{\"success\":false,\"error\":\"Không tìm thấy yêu cầu dịch vụ!\"}");
            response.getWriter().flush();
            return;
        }
        
        // ✅ Bước 2: Sử dụng hoặc tạo Invoice
        System.out.println("\n--- Step 2: Get or Create Invoice ---");
        int invoiceId;
        Integer pendingInvoiceId = (Integer) session.getAttribute("pendingInvoiceId");
        
        if (pendingInvoiceId != null && pendingInvoiceId > 0) {
            // ✅ Sử dụng invoice pending đã tạo sẵn và update status
            invoiceId = pendingInvoiceId;
            boolean updated = invoiceDAO.updateInvoicePaymentInfo(
                invoiceId, 
                "Paid", 
                "Cash", 
                paymentAmount
            );
            if (updated) {
                System.out.println("✅ Updated existing pending invoice to Paid: " + invoiceId);
            } else {
                System.err.println("❌ ERROR: Failed to update pending invoice!");
                response.getWriter().write("{\"success\":false,\"error\":\"Không thể cập nhật hóa đơn!\"}");
                response.getWriter().flush();
                return;
            }
        } else {
            // ✅ Tạo invoice mới nếu không có pending invoice
            invoiceId = invoiceDAO.createInvoice(contractId, paymentAmount, "Paid", 
                                                LocalDate.now().plusDays(30), "Cash");
            if (invoiceId <= 0) {
                System.err.println("❌ ERROR: Failed to create invoice!");
                response.getWriter().write("{\"success\":false,\"error\":\"Không thể tạo hóa đơn!\"}");
                response.getWriter().flush();
                return;
            }
            System.out.println("✅ Invoice created with ID: " + invoiceId);
        }
        
        // ✅ Bước 3: Xóa InvoiceDetail pending cũ (nếu có)
        System.out.println("\n--- Step 3: Cleaning up old pending InvoiceDetails ---");
        try {
            boolean cleaned = invoiceDAO.deletePendingInvoiceDetails(invoiceId);
            if (cleaned) {
                System.out.println("✅ Cleaned up old pending InvoiceDetails for invoiceId=" + invoiceId);
            } else {
                System.out.println("ℹ️ No pending InvoiceDetails to clean for invoiceId=" + invoiceId);
            }
        } catch (Exception e) {
            System.err.println("⚠️ Error cleaning pending InvoiceDetails: " + e.getMessage());
        }
        
        // ✅ Bước 4: Tạo InvoiceDetail với paymentStatus = "Completed"
        System.out.println("\n--- Step 4: Creating InvoiceDetail ---");
        String invoiceDesc = "Thanh toán tiền mặt cho yêu cầu #" + requestId;
        if (report != null && report.getTechnicianName() != null) {
            invoiceDesc += " - Kỹ thuật viên: " + report.getTechnicianName();
        }
        
        // ✅ CHECK TRƯỚC KHI TẠO (Double safety)
        try {
            if (!invoiceDAO.hasInvoiceDetail(invoiceId)) {
                int invoiceDetailId = invoiceDAO.createInvoiceDetail(
                    invoiceId, 
                    invoiceDesc, 
                    paymentAmount, 
                    "Completed"
                );
                
                if (invoiceDetailId > 0) {
                    System.out.println("✅ SUCCESS: InvoiceDetail created with ID: " + invoiceDetailId);
                    System.out.println("   - InvoiceId: " + invoiceId);
                    System.out.println("   - Description: " + invoiceDesc);
                    System.out.println("   - Amount: " + paymentAmount);
                    System.out.println("   - PaymentStatus: Completed");
                } else {
                    System.err.println("❌ ERROR: Failed to create InvoiceDetail!");
                    response.getWriter().write("{\"success\":false,\"error\":\"Không thể tạo chi tiết hóa đơn!\"}");
                    response.getWriter().flush();
                    return;
                }
            } else {
                // Trường hợp đã có rồi (race condition), update thay vì tạo mới
                System.out.println("⚠️ WARNING: InvoiceDetail already exists for invoiceId=" + invoiceId);
                System.out.println("   → Updating paymentStatus to Completed instead...");
                
                boolean updated = invoiceDAO.updateInvoiceDetailPaymentStatus(invoiceId, "Completed");
                if (updated) {
                    System.out.println("✅ Updated existing InvoiceDetail paymentStatus to Completed");
                } else {
                    System.err.println("❌ ERROR: Failed to update InvoiceDetail paymentStatus!");
                }
            }
        } catch (Exception e) {
            System.err.println("❌ EXCEPTION when creating InvoiceDetail: " + e.getMessage());
            e.printStackTrace();
            response.getWriter().write("{\"success\":false,\"error\":\"Lỗi tạo chi tiết hóa đơn: " + 
                                      e.getMessage().replace("\"", "\\\"") + "\"}");
            response.getWriter().flush();
            return;
        }
        
        // ✅ Bước 5: Tạo Payment Completed
        System.out.println("\n--- Step 5: Creating Payment ---");
        int paymentId = -1;
        if (report != null && report.getReportId() > 0) {
            paymentId = paymentDAO.createPaymentWithReport(
                invoiceId, 
                paymentAmount, 
                "Completed", 
                report.getReportId()
            );
            System.out.println("✅ Payment created with reportId: " + report.getReportId());
        } else {
            paymentId = paymentDAO.createPayment(invoiceId, paymentAmount, "Completed");
            System.out.println("✅ Payment created without reportId");
        }
        System.out.println("✅ PaymentId: " + paymentId);
        
        // ✅ Bước 6: Tạo PaymentTransaction
        System.out.println("\n--- Step 6: Creating PaymentTransaction ---");
        if (paymentId > 0) {
            Integer customerId = (Integer) session.getAttribute("session_login_id");
            if (customerId != null && customerId > 0) {
                int transactionId = paymentDAO.createPaymentTransaction(
                    paymentId, 
                    customerId, 
                    paymentAmount, 
                    "Cash", 
                    "Completed"
                );
                System.out.println("✅ PaymentTransaction created with ID: " + transactionId);
            } else {
                System.err.println("⚠️ WARNING: CustomerId is null or invalid!");
            }
        }
        
        // ✅ Bước 7: CẬP NHẬT ServiceRequest.status = Completed
        System.out.println("\n--- Step 7: Updating ServiceRequest status ---");
        System.out.println("✅ About to update requestId=" + requestId + " to status='Completed'");
        
        try {
            boolean statusUpdated = serviceRequestDAO.updateStatusBoolean(requestId, "Completed");
            
            if (statusUpdated) {
                System.out.println("✅ SUCCESS: ServiceRequest status updated to Completed!");
                
                // ✅ Verify lại status trong DB
                ServiceRequest verifiedSR = serviceRequestDAO.getRequestById(requestId);
                if (verifiedSR != null) {
                    System.out.println("✅ VERIFIED: New status in DB = " + verifiedSR.getStatus());
                    if (!"Completed".equals(verifiedSR.getStatus())) {
                        System.err.println("❌ ERROR: Status was not updated correctly in DB!");
                        System.err.println("❌ Expected: Completed, Got: " + verifiedSR.getStatus());
                    }
                } else {
                    System.err.println("❌ ERROR: Cannot verify - ServiceRequest not found after update!");
                }
            } else {
                System.err.println("❌ ERROR: updateStatusBoolean returned false!");
                System.err.println("❌ No rows were affected by the UPDATE statement!");
            }
        } catch (Exception e) {
            System.err.println("❌ EXCEPTION when updating status: " + e.getMessage());
            e.printStackTrace();
        }
        
        // ✅ Bước 8: Cập nhật RepairReport.quotationStatus = Approved
        System.out.println("\n--- Step 8: Updating RepairReport quotationStatus ---");
        if (report != null && report.getReportId() > 0) {
            try {
                boolean reportUpdated = serviceRequestDAO.updateRepairReportQuotationStatus(
                    report.getReportId(), 
                    "Approved"
                );
                
                if (reportUpdated) {
                    System.out.println("✅ SUCCESS: RepairReport quotationStatus updated to Approved!");
                } else {
                    System.err.println("⚠️ WARNING: RepairReport quotationStatus was not updated!");
                }
            } catch (Exception e) {
                System.err.println("❌ ERROR updating RepairReport: " + e.getMessage());
                e.printStackTrace();
            }
        } else {
            System.out.println("ℹ️ No RepairReport to update (report is null or reportId <= 0)");
        }
        
        // ✅ Bước 9: Xóa Payment pending cũ (nếu có)
        System.out.println("\n--- Step 9: Cleaning up pending payment ---");
        Integer pendingPaymentId = (Integer) session.getAttribute("pendingPaymentId");
        if (pendingPaymentId != null && pendingPaymentId > 0) {
            try {
                boolean deleted = paymentDAO.deletePendingPayment(pendingPaymentId);
                if (deleted) {
                    System.out.println("✅ Deleted old pending payment: " + pendingPaymentId);
                    session.removeAttribute("pendingPaymentId");
                } else {
                    System.err.println("⚠️ WARNING: Could not delete pending payment: " + pendingPaymentId);
                }
            } catch (Exception e) {
                System.err.println("❌ ERROR deleting pending payment: " + e.getMessage());
            }
        } else {
            System.out.println("ℹ️ No pending payment to delete");
        }
        
        // ✅ Bước 10: Xóa pending session data và lưu thông tin mới
        session.removeAttribute("pendingInvoiceId");
        session.removeAttribute("pendingRequestId");
        session.removeAttribute("pendingReportId");
        session.removeAttribute("pendingPaymentId");
        
        session.setAttribute("lastPaidInvoiceId", invoiceId);
        session.setAttribute("lastPaidRequestId", requestId);
        System.out.println("✅ Session data cleaned and updated");
        
        // ✅ Summary
        System.out.println("\n" + "=".repeat(80));
        System.out.println("========== CASH PAYMENT SUCCESS SUMMARY ==========");
        System.out.println("=".repeat(80));
        System.out.println("✅ InvoiceId: " + invoiceId + " (Status: Paid, Method: Cash)");
        System.out.println("✅ PaymentId: " + paymentId + " (Status: Completed)");
        System.out.println("✅ RequestId: " + requestId + " (Status: Should be Completed)");
        if (report != null) {
            System.out.println("✅ ReportId: " + report.getReportId() + " (QuotationStatus: Should be Approved)");
            System.out.println("✅ TechnicianName: " + report.getTechnicianName());
        }
        System.out.println("=".repeat(80) + "\n");
        
        // ✅ Trả về JSON success
        response.getWriter().write("{\"success\":true,\"message\":\"Thanh toán thành công!\",\"redirectUrl\":\"" + 
                                  request.getContextPath() + "/managerServiceRequest?success=cash_payment_success\"}");
        response.getWriter().flush();
        
    } catch (Exception e) {
        System.err.println("\n" + "=".repeat(80));
        System.err.println("========== CASH PAYMENT ERROR ==========");
        System.err.println("=".repeat(80));
        System.err.println("❌ Exception type: " + e.getClass().getName());
        System.err.println("❌ Error message: " + e.getMessage());
        System.err.println("❌ Stack trace:");
        e.printStackTrace();
        System.err.println("=".repeat(80) + "\n");
        
        response.getWriter().write("{\"success\":false,\"error\":\"Có lỗi xảy ra: " + 
                                  e.getMessage().replace("\"", "\\\"") + "\"}");
        response.getWriter().flush();
    }
}
    
    private List<Map<String, Object>> getContractEquipmentWithDetails(int contractId) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT ce.*, e.model, e.serialNumber, e.description, e.installDate " +
                     "FROM ContractEquipment ce " +
                     "INNER JOIN Equipment e ON ce.equipmentId = e.equipmentId " +
                     "WHERE ce.contractId = ? ORDER BY ce.startDate DESC";
        
        try (Connection conn = new dal.DBContext().connection;
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, contractId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> item = new HashMap<>();
                    item.put("contractEquipmentId", rs.getInt("contractEquipmentId"));
                    item.put("equipmentId", rs.getInt("equipmentId"));
                    item.put("model", rs.getString("model"));
                    item.put("serialNumber", rs.getString("serialNumber"));
                    item.put("description", rs.getString("description"));
                    item.put("startDate", rs.getDate("startDate"));
                    item.put("endDate", rs.getDate("endDate"));
                    item.put("quantity", rs.getInt("quantity"));
                    item.put("price", rs.getBigDecimal("price"));
                    item.put("installDate", rs.getDate("installDate"));
                    list.add(item);
                }
            }
        } catch (Exception e) {
            System.err.println("❌ Error: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }
}
