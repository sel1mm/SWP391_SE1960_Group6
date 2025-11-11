package controller;

import dal.InvoiceDAO;
import dal.PaymentDAO;
import dal.ServiceRequestDAO;
import service.VNPayService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Map;

/**
 * Servlet xử lý callback từ VNPay sau khi thanh toán
 */
@WebServlet(name = "VNPayCallbackServlet", urlPatterns = {"/vnpayCallback"})
public class VNPayCallbackServlet extends HttpServlet {

    private VNPayService vnPayService;
    private InvoiceDAO invoiceDAO;
    private PaymentDAO paymentDAO;
    private ServiceRequestDAO serviceRequestDAO;

    @Override
    public void init() throws ServletException {
        vnPayService = new VNPayService();
        invoiceDAO = new InvoiceDAO();
        paymentDAO = new PaymentDAO();
        serviceRequestDAO = new ServiceRequestDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        System.out.println("\n" + "=".repeat(80));
        System.out.println("========== VNPAY CALLBACK RECEIVED ==========");
        System.out.println("=".repeat(80));

        HttpSession session = request.getSession(false);

        try {
            // 1. Validate callback parameters
            Map<String, String> vnpParams = vnPayService.getVNPayParams(request);

            System.out.println("📦 VNPay Parameters:");
            vnpParams.forEach((key, value) -> {
                System.out.println("   - " + key + ": " + value);
            });

            // 2. Verify signature
            boolean isValidSignature = vnPayService.verifySignature(vnpParams);

            if (!isValidSignature) {
                System.err.println("❌ ERROR: Invalid VNPay signature!");
                request.setAttribute("error", "Chữ ký VNPay không hợp lệ!");
                request.getRequestDispatcher("/payment-result.jsp").forward(request, response);
                return;
            }

            System.out.println("✅ VNPay signature verified successfully");

            // 3. Get payment result
            String responseCode = vnpParams.get("vnp_ResponseCode");
            String transactionStatus = vnpParams.get("vnp_TransactionStatus");
            String txnRef = vnpParams.get("vnp_TxnRef");  // Order ID
            String amount = vnpParams.get("vnp_Amount");   // Amount * 100
            String bankCode = vnpParams.get("vnp_BankCode");
            String transactionNo = vnpParams.get("vnp_TransactionNo");

            System.out.println("\n📊 Payment Result:");
            System.out.println("   - Response Code: " + responseCode);
            System.out.println("   - Transaction Status: " + transactionStatus);
            System.out.println("   - Order ID: " + txnRef);
            System.out.println("   - Amount: " + amount);
            System.out.println("   - Bank Code: " + bankCode);
            System.out.println("   - Transaction No: " + transactionNo);

            // 4. Get pending data from session
            Integer pendingInvoiceId = null;
            Integer pendingRequestId = null;
            Integer pendingReportId = null;
            Integer pendingPaymentId = null;
            Integer customerId = null;

            if (session != null) {
                pendingInvoiceId = (Integer) session.getAttribute("pendingInvoiceId");
                pendingRequestId = (Integer) session.getAttribute("pendingRequestId");
                pendingReportId = (Integer) session.getAttribute("pendingReportId");
                pendingPaymentId = (Integer) session.getAttribute("pendingPaymentId");
                customerId = (Integer) session.getAttribute("session_login_id");
            }

            System.out.println("\n📝 Session Data:");
            System.out.println("   - CustomerId: " + customerId);
            System.out.println("   - PendingInvoiceId: " + pendingInvoiceId);
            System.out.println("   - PendingRequestId: " + pendingRequestId);
            System.out.println("   - PendingReportId: " + pendingReportId);
            System.out.println("   - PendingPaymentId: " + pendingPaymentId);

            // 5. Check if payment successful
            boolean isSuccess = "00".equals(responseCode) && "00".equals(transactionStatus);

            if (isSuccess) {
                System.out.println("\n✅ PAYMENT SUCCESSFUL - Processing...");

                // 5.1 Update Invoice status to Paid
                if (pendingInvoiceId != null && pendingInvoiceId > 0) {
                    // ✅ Chuyển ngược VND về USD để lưu vào DB
                    double amountInVND = Double.parseDouble(amount) / 100;
                    double amountValue = amountInVND / 26000.0; // VND -> USD

                    System.out.println("💰 Amount Conversion (Callback):");
                    System.out.println("   - Received from VNPay (VND): " + amountInVND);
                    System.out.println("   - Converted to USD for DB: " + amountValue);

                    boolean invoiceUpdated = invoiceDAO.updateInvoicePaymentInfo(
                            pendingInvoiceId,
                            "Paid",
                            "VNPay",
                            amountValue
                    );

                    if (invoiceUpdated) {
                        System.out.println("✅ Invoice updated: invoiceId=" + pendingInvoiceId);
                    } else {
                        System.err.println("⚠️ Failed to update invoice: invoiceId=" + pendingInvoiceId);
                    }
                    if (!invoiceDAO.hasInvoiceDetail(pendingInvoiceId)) {
                        invoiceDAO.createInvoiceDetail(
                                pendingInvoiceId,
                                "Thanh toán VNPay cho yêu cầu #" + (pendingRequestId != null ? pendingRequestId : "N/A"),
                                amountValue, // ✅ Dùng amountValue đã chuyển về USD
                                "Pending"
                        );
                        System.out.println("✅ Auto-created missing InvoiceDetail for invoiceId=" + pendingInvoiceId);
                    }
                    // ✅ Update InvoiceDetail paymentStatus to Completed
                    boolean detailUpdated = invoiceDAO.updateAllInvoiceDetailsPaymentStatus(pendingInvoiceId, "Completed");
                    if (detailUpdated) {
                        System.out.println("✅ InvoiceDetail paymentStatus updated to Completed");
                    } else {
                        System.err.println("⚠️ Failed to update InvoiceDetail paymentStatus");
                    }

                    // 5.2 Create or update Payment record
                    int paymentId;
                    if (pendingPaymentId != null && pendingPaymentId > 0) {
                        // Update existing pending payment
                        boolean updated = paymentDAO.updatePaymentStatus(pendingPaymentId, "Completed");
                        paymentId = updated ? pendingPaymentId : -1;
                        System.out.println("✅ Updated existing Payment: paymentId=" + pendingPaymentId);
                    } else {
                        // Create new payment with reportId
                        if (pendingReportId != null && pendingReportId > 0) {
                            paymentId = paymentDAO.createPaymentWithReport(
                                    pendingInvoiceId,
                                    amountValue,
                                    "Completed",
                                    pendingReportId
                            );
                        } else {
                            paymentId = paymentDAO.createPayment(
                                    pendingInvoiceId,
                                    amountValue,
                                    "Completed"
                            );
                        }
                        System.out.println("✅ Created new Payment: paymentId=" + paymentId);
                    }

                    // 5.3 Create PaymentTransaction
                    if (paymentId > 0 && customerId != null) {
                        int transactionId = paymentDAO.createPaymentTransaction(
                                paymentId,
                                customerId,
                                amountValue,
                                "VNPay",
                                "Completed"
                        );
                        System.out.println("✅ Created PaymentTransaction: transactionId=" + transactionId);
                    }

                    // 5.4 Update ServiceRequest status to Completed
                    if (pendingRequestId != null && pendingRequestId > 0) {
                        boolean requestUpdated = serviceRequestDAO.updateStatusBoolean(
                                pendingRequestId,
                                "Completed"
                        );

                        if (requestUpdated) {
                            System.out.println("✅ ServiceRequest updated to Completed: requestId=" + pendingRequestId);
                        } else {
                            System.err.println("⚠️ Failed to update ServiceRequest: requestId=" + pendingRequestId);
                        }
                    }

                    // ✅ 5.5 Update RepairReport.quotationStatus to Approved
                    if (pendingReportId != null && pendingReportId > 0) {
                        boolean reportUpdated = serviceRequestDAO.updateRepairReportQuotationStatus(
                                pendingReportId,
                                "Approved"
                        );

                        if (reportUpdated) {
                            System.out.println("✅ RepairReport quotationStatus updated to Approved: reportId=" + pendingReportId);
                        } else {
                            System.err.println("⚠️ Failed to update RepairReport: reportId=" + pendingReportId);
                        }
                    }

                    // 5.6 Clear session data
                    if (session != null) {
                        session.removeAttribute("pendingInvoiceId");
                        session.removeAttribute("pendingRequestId");
                        session.removeAttribute("pendingReportId");
                        session.removeAttribute("pendingPaymentId");

                        // Save success data
                        session.setAttribute("lastPaidInvoiceId", pendingInvoiceId);
                        session.setAttribute("lastPaidRequestId", pendingRequestId);

                        System.out.println("✅ Session data cleared");
                    }

                    System.out.println("\n" + "=".repeat(80));
                    System.out.println("========== PAYMENT PROCESSING COMPLETED ==========");
                    System.out.println("=".repeat(80) + "\n");

                    // Set success attributes
                    request.setAttribute("success", true);
                    request.setAttribute("message", "Thanh toán thành công!");
                    request.setAttribute("transactionNo", transactionNo);
                    request.setAttribute("amount", amountInVND);  // ✅ Hiển thị VND trên result page
                    request.setAttribute("bankCode", bankCode);

                } else {
                    System.err.println("❌ ERROR: No pending invoice found in session!");
                    request.setAttribute("error", "Không tìm thấy thông tin hóa đơn!");
                }

            } else {
                // Payment failed
                System.err.println("\n❌ PAYMENT FAILED");
                System.err.println("   - Response Code: " + responseCode);
                System.err.println("   - Transaction Status: " + transactionStatus);

                // Update invoice to Failed if exists
                if (pendingInvoiceId != null && pendingInvoiceId > 0) {
                    invoiceDAO.updateInvoiceStatus(pendingInvoiceId, "Failed");
                    System.out.println("✅ Invoice status updated to Failed");
                }

                // Update payment to Failed if exists
                if (pendingPaymentId != null && pendingPaymentId > 0) {
                    paymentDAO.updatePaymentStatus(pendingPaymentId, "Failed");
                    System.out.println("✅ Payment status updated to Failed");
                }

                request.setAttribute("success", false);
                request.setAttribute("error", getErrorMessage(responseCode));
                request.setAttribute("responseCode", responseCode);
            }

            // Forward to result page
            request.getRequestDispatcher("/payment-result.jsp").forward(request, response);

        } catch (Exception e) {
            System.err.println("❌ ERROR in VNPay callback: " + e.getMessage());
            e.printStackTrace();

            request.setAttribute("error", "Có lỗi xảy ra khi xử lý callback: " + e.getMessage());
            request.getRequestDispatcher("/payment-result.jsp").forward(request, response);
        }
    }

    /**
     * Get error message based on VNPay response code
     */
    private String getErrorMessage(String responseCode) {
        switch (responseCode) {
            case "07":
                return "Trừ tiền thành công. Giao dịch bị nghi ngờ (liên quan tới lừa đảo, giao dịch bất thường).";
            case "09":
                return "Giao dịch không thành công do: Thẻ/Tài khoản của khách hàng chưa đăng ký dịch vụ InternetBanking tại ngân hàng.";
            case "10":
                return "Giao dịch không thành công do: Khách hàng xác thực thông tin thẻ/tài khoản không đúng quá 3 lần";
            case "11":
                return "Giao dịch không thành công do: Đã hết hạn chờ thanh toán. Xin quý khách vui lòng thực hiện lại giao dịch.";
            case "12":
                return "Giao dịch không thành công do: Thẻ/Tài khoản của khách hàng bị khóa.";
            case "13":
                return "Giao dịch không thành công do Quý khách nhập sai mật khẩu xác thực giao dịch (OTP). Xin quý khách vui lòng thực hiện lại giao dịch.";
            case "24":
                return "Giao dịch không thành công do: Khách hàng hủy giao dịch";
            case "51":
                return "Giao dịch không thành công do: Tài khoản của quý khách không đủ số dư để thực hiện giao dịch.";
            case "65":
                return "Giao dịch không thành công do: Tài khoản của Quý khách đã vượt quá hạn mức giao dịch trong ngày.";
            case "75":
                return "Ngân hàng thanh toán đang bảo trì.";
            case "79":
                return "Giao dịch không thành công do: KH nhập sai mật khẩu thanh toán quá số lần quy định. Xin quý khách vui lòng thực hiện lại giao dịch";
            default:
                return "Giao dịch thất bại. Mã lỗi: " + responseCode;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
