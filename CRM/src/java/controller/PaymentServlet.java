package controller;

import java.io.IOException;
import dal.ServiceRequestDAO;
import dal.ContractDAO;
import dal.InvoiceDAO;
import dal.PaymentDAO;
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

    @Override
    public void init() throws ServletException {
        serviceRequestDAO = new ServiceRequestDAO();
        contractDAO = new ContractDAO();
        invoiceDAO = new InvoiceDAO();
        paymentDAO = new PaymentDAO();
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
        String reportIdStr = request.getParameter("reportId");

        if (requestIdStr == null || requestIdStr.trim().isEmpty()) {
            session.setAttribute("error", "Mã yêu cầu không hợp lệ!");
            response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
            return;
        }

        try {
            int requestId = Integer.parseInt(requestIdStr.trim());
            ServiceRequest sr = serviceRequestDAO.getRequestById(requestId);

            if (sr == null || sr.getCreatedBy() != customerId) {
                session.setAttribute("error", "Bạn không có quyền xem yêu cầu này!");
                response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
                return;
            }

            // Lấy thông tin chi tiết yêu cầu
            model.ServiceRequestDetailDTO2 requestDetail = serviceRequestDAO.getRequestDetailById(requestId);
            if (requestDetail != null) {
                sr.setCustomerName(requestDetail.getCustomerName());
                sr.setCustomerEmail(requestDetail.getCustomerEmail());
                sr.setCustomerPhone(requestDetail.getCustomerPhone());
            }

            // Lấy hợp đồng
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

            // Lấy RepairReport
            RepairReport repairReport = null;
            if (reportIdStr != null && !reportIdStr.trim().isEmpty()) {
                int reportId = Integer.parseInt(reportIdStr.trim());
                repairReport = serviceRequestDAO.getRepairReportById(reportId);
            } else {
                repairReport = serviceRequestDAO.getRepairReportByRequestId(requestId);
            }

            // Gán attribute cho JSP
            request.setAttribute("serviceRequest", sr);
            request.setAttribute("contract", contract);
            request.setAttribute("contractEquipmentList", contractEquipmentList);
            request.setAttribute("repairReport", repairReport);

            request.getRequestDispatcher("/payment.jsp").forward(request, response);

        } catch (Exception e) {
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
            response.getWriter().write("{\"success\":false,\"error\":\"Phiên đăng nhập đã hết hạn.\"}");
            return;
        }

        String requestIdStr = request.getParameter("requestId");

        if (requestIdStr == null || requestIdStr.trim().isEmpty()) {
            response.setContentType("application/json");
            response.getWriter().write("{\"success\":false,\"error\":\"Mã yêu cầu không hợp lệ!\"}");
            return;
        }

        try {
            int requestId = Integer.parseInt(requestIdStr.trim());
            ServiceRequest sr = serviceRequestDAO.getRequestById(requestId);

            if (sr == null || sr.getCreatedBy() != customerId) {
                response.setContentType("application/json");
                response.getWriter().write("{\"success\":false,\"error\":\"Bạn không có quyền!\"}");
                return;
            }

            RepairReport report = serviceRequestDAO.getRepairReportByRequestId(requestId);
            double paymentAmount = report != null && report.getEstimatedCost() != null
                    ? report.getEstimatedCost().doubleValue() : 0;

            handleCashPayment(request, response, session, sr, report, paymentAmount, requestId);

        } catch (Exception e) {
            response.setContentType("application/json");
            response.getWriter().write("{\"success\":false,\"error\":\"Có lỗi xảy ra: " + e.getMessage() + "\"}");
        }
    }

    /** ✅ Chỉ giữ thanh toán tiền mặt */
    private void handleCashPayment(HttpServletRequest request, HttpServletResponse response,
            HttpSession session, ServiceRequest sr, RepairReport report,
            double paymentAmount, int requestId) throws Exception {

        int contractId = sr.getContractId() != null ? sr.getContractId() : 0;
        if (contractId <= 0) {
            response.getWriter().write("{\"success\":false,\"error\":\"Không tìm thấy hợp đồng!\"}");
            return;
        }

        int invoiceId = invoiceDAO.createInvoice(contractId, paymentAmount, "Paid",
                LocalDate.now().plusDays(30), "Cash");

        String invoiceDesc = "Thanh toán tiền mặt cho yêu cầu #" + requestId;
        if (report != null && report.getTechnicianName() != null) {
            invoiceDesc += " - Kỹ thuật viên: " + report.getTechnicianName();
        }

        int invoiceDetailId = invoiceDAO.createInvoiceDetail(invoiceId, invoiceDesc, paymentAmount, "Completed");

        int paymentId = paymentDAO.createPaymentWithReport(
                invoiceId, paymentAmount, "Completed",
                report != null ? report.getReportId() : 0);

        serviceRequestDAO.updateStatusBoolean(requestId, "Completed");

        if (report != null && report.getReportId() > 0) {
            serviceRequestDAO.updateRepairReportQuotationStatus(report.getReportId(), "Approved");
        }

        response.setContentType("application/json");
        response.getWriter().write("{\"success\":true,\"message\":\"Thanh toán tiền mặt thành công!\"}");
    }

    private List<Map<String, Object>> getContractEquipmentWithDetails(int contractId) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT ce.*, e.model, e.serialNumber, e.description, e.installDate "
                + "FROM ContractEquipment ce "
                + "INNER JOIN Equipment e ON ce.equipmentId = e.equipmentId "
                + "WHERE ce.contractId = ? ORDER BY ce.startDate DESC";

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
