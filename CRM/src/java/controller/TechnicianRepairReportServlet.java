package controller;

import dal.RepairReportDAO;
import model.TechRepairReport;
import utils.ValidationUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.List;

/**
 * Handle repair report list view and form submission with strict validation.
 */
public class TechnicianRepairReportServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        Integer sessionId = session != null ? (Integer) session.getAttribute("session_login_id") : null;
        String userRole = session != null ? (String) session.getAttribute("session_role") : null;
        String dev = req.getParameter("dev");

        // Check authentication
        if (sessionId == null || !isTechnicianOrAdmin(userRole)) {
            if ("true".equalsIgnoreCase(dev)) {
                // Dev mode - show mock data
                loadReportList(req, resp, 1L, dev);
            } else {
                resp.sendRedirect(req.getContextPath() + "/login.jsp");
                return;
            }
        } else {
            // Real user - get their reports
            long techId = sessionId.longValue();
            loadReportList(req, resp, techId, dev);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        Integer sessionId = session != null ? (Integer) session.getAttribute("session_login_id") : null;
        String userRole = session != null ? (String) session.getAttribute("session_role") : null;

        if (sessionId == null || !isTechnicianOrAdmin(userRole)) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        // Get form parameters
        String requestIdStr = req.getParameter("requestId");
        String details = req.getParameter("details");
        String diagnosis = req.getParameter("diagnosis");
        String estimatedCostStr = req.getParameter("estimatedCost");
        String repairDateStr = req.getParameter("repairDate");
        String reportIdStr = req.getParameter("reportId"); // For updates

        // Server-side validation
        ValidationUtils.ValidationResult validation = validateRepairReport(requestIdStr, details, diagnosis, estimatedCostStr, repairDateStr);

        if (!validation.isValid()) {
            // Validation failed - redirect back with error
            String errorMsg = validation.getFirstError();
            resp.sendRedirect(req.getContextPath() + "/technician/reports?error=" + java.net.URLEncoder.encode(errorMsg, "UTF-8"));
            return;
        }

        // Create repair report object
        TechRepairReport report = new TechRepairReport();

        // Set fields
        report.setRequestId(Long.parseLong(requestIdStr));
        report.setTechnicianId(sessionId.longValue());
        report.setDetails(ValidationUtils.sanitize(details));
        report.setDiagnosis(ValidationUtils.sanitize(diagnosis));
        report.setEstimatedCost(new BigDecimal(estimatedCostStr));
        report.setRepairDate(LocalDate.parse(repairDateStr));
        report.setQuotationStatus("Pending"); // Always set to pending on creation/update by technician

        // Handle update vs create
        if (reportIdStr != null && !reportIdStr.trim().isEmpty()) {
            try {
                report.setReportId(Long.parseLong(reportIdStr));
            } catch (NumberFormatException e) {
                resp.sendRedirect(req.getContextPath() + "/technician/reports?error=Invalid report ID");
                return;
            }
        }

        // Save to database
        boolean dev = "true".equalsIgnoreCase(req.getParameter("dev"));
        RepairReportDAO dao = new RepairReportDAO();

        try {
            long savedId = dao.save(report);
            if (savedId > 0) {
                // Success - redirect with success message
                resp.sendRedirect(req.getContextPath() + "/technician/reports?success=Repair Report has been submitted successfully ✅");
            } else {
                resp.sendRedirect(req.getContextPath() + "/technician/reports?error=Failed to save repair report");
            }
        } catch (SQLException e) {
            resp.sendRedirect(req.getContextPath() + "/technician/reports?error=Database error occurred: " + e.getMessage());
        }
    }

    /**
     * Load report list for display
     */
    private void loadReportList(HttpServletRequest req, HttpServletResponse resp, long techId, String dev)
            throws ServletException, IOException {

        RepairReportDAO dao = new RepairReportDAO();

        try {
            List<TechRepairReport> reports = dao.findByTechnicianId(techId);
            req.setAttribute("reports", reports);
            req.setAttribute("pageTitle", "Repair Reports");
            req.setAttribute("contentView", "/WEB-INF/technician/technician-reports.jsp");
            req.setAttribute("activePage", "reports");
            req.getRequestDispatcher("/WEB-INF/technician/technician-layout.jsp").forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    /**
     * Validate all repair report fields
     */
    private ValidationUtils.ValidationResult validateRepairReport(String requestId, String details, String diagnosis, String estimatedCost, String repairDate) {
        ValidationUtils.ValidationResult result = new ValidationUtils.ValidationResult();

        // Validate each field
        ValidationUtils.ValidationResult requestIdValidation = ValidationUtils.validateRequestId(requestId);
        if (!requestIdValidation.isValid()) {
            result.addError(requestIdValidation.getFirstError());
        }

        ValidationUtils.ValidationResult detailsValidation = ValidationUtils.validateDetails(details);
        if (!detailsValidation.isValid()) {
            result.addError(detailsValidation.getFirstError());
        }

        ValidationUtils.ValidationResult diagnosisValidation = ValidationUtils.validateDiagnosis(diagnosis);
        if (!diagnosisValidation.isValid()) {
            result.addError(diagnosisValidation.getFirstError());
        }

        ValidationUtils.ValidationResult costValidation = ValidationUtils.validateEstimatedCost(estimatedCost);
        if (!costValidation.isValid()) {
            result.addError(costValidation.getFirstError());
        }

        ValidationUtils.ValidationResult dateValidation = ValidationUtils.validateRepairDate(repairDate);
        if (!dateValidation.isValid()) {
            result.addError(dateValidation.getFirstError());
        }

        return result;
    }

    private boolean isTechnicianOrAdmin(String role) {
        if (role == null) return false;
        String r = role.toLowerCase();
        return r.contains("technician") || r.equals("admin");
    }
}
