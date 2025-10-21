package controller;

import dal.RepairReportDAO;
import model.RepairReport;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;
import utils.TechnicianValidator;

/**
 * Servlet for handling technician repair report operations.
 * Handles CRUD operations for RepairReport table.
 */
public class TechnicianRepairReportServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        Integer sessionId = session != null ? (Integer) session.getAttribute("session_login_id") : null;
        String userRole = session != null ? (String) session.getAttribute("session_role") : null;
        
        // Check authentication
        if (sessionId == null || !isTechnicianOrAdmin(userRole)) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        
        String action = req.getParameter("action");
        String reportIdParam = req.getParameter("reportId");
        String requestIdParam = req.getParameter("requestId");
        
        try {
            RepairReportDAO reportDAO = new RepairReportDAO();
            int technicianId = sessionId.intValue();
            
            if ("create".equals(action)) {
                // Show create form
                Integer requestId = null;
                if (requestIdParam != null && !requestIdParam.trim().isEmpty()) {
                    try {
                        requestId = Integer.parseInt(requestIdParam);
                    } catch (NumberFormatException e) {
                        req.setAttribute("error", "Invalid request ID");
                        doGetReportList(req, resp, technicianId);
                        return;
                    }
                }
                req.setAttribute("requestId", requestId);
                req.setAttribute("pageTitle", "Create Repair Report");
                req.setAttribute("contentView", "/WEB-INF/technician/report-form.jsp");
                req.setAttribute("activePage", "reports");
                req.getRequestDispatcher("/WEB-INF/technician/technician-layout.jsp").forward(req, resp);
                
            } else if ("edit".equals(action) && reportIdParam != null) {
                // Show edit form
                int reportId = Integer.parseInt(reportIdParam);
                RepairReport report = reportDAO.findById(reportId);
                
                if (report != null && report.getTechnicianId() != null && report.getTechnicianId() == technicianId) {
                    if (reportDAO.canTechnicianEditReport(reportId, technicianId)) {
                        req.setAttribute("report", report);
                        req.setAttribute("pageTitle", "Edit Repair Report");
                        req.setAttribute("contentView", "/WEB-INF/technician/report-form.jsp");
                        req.setAttribute("activePage", "reports");
                        req.getRequestDispatcher("/WEB-INF/technician/technician-layout.jsp").forward(req, resp);
                    } else {
                        req.setAttribute("error", "This report cannot be edited (quotation status is not Pending)");
                        doGetReportList(req, resp, technicianId);
                    }
                } else {
                    req.setAttribute("error", "Report not found or not assigned to you");
                    doGetReportList(req, resp, technicianId);
                }
                
            } else if ("detail".equals(action) && reportIdParam != null) {
                // Show report detail
                int reportId = Integer.parseInt(reportIdParam);
                RepairReport report = reportDAO.findById(reportId);
                
                if (report != null && report.getTechnicianId() != null && report.getTechnicianId() == technicianId) {
                    req.setAttribute("report", report);
                    req.setAttribute("pageTitle", "Repair Report Detail");
                    req.setAttribute("contentView", "/WEB-INF/technician/report-detail.jsp");
                    req.setAttribute("activePage", "reports");
                    req.getRequestDispatcher("/WEB-INF/technician/technician-layout.jsp").forward(req, resp);
                } else {
                    req.setAttribute("error", "Report not found or not assigned to you");
                    doGetReportList(req, resp, technicianId);
                }
                
            } else {
                // Show report list
                doGetReportList(req, resp, technicianId);
            }
            
        } catch (SQLException e) {
            throw new ServletException("Database error: " + e.getMessage(), e);
        } catch (NumberFormatException e) {
            req.setAttribute("error", "Invalid ID parameter");
            doGetReportList(req, resp, sessionId.intValue());
        }
    }
    
    private void doGetReportList(HttpServletRequest req, HttpServletResponse resp, int technicianId) 
            throws ServletException, IOException {
        try {
            String searchQuery = sanitize(req.getParameter("q"));
            String statusFilter = sanitize(req.getParameter("status"));
            int page = parseInt(req.getParameter("page"), 1);
            int pageSize = Math.min(parseInt(req.getParameter("pageSize"), 10), 100);
            
            RepairReportDAO reportDAO = new RepairReportDAO();
            List<RepairReport> reports = reportDAO.findByTechnicianId(technicianId, searchQuery, statusFilter, page, pageSize);
            int totalReports = reportDAO.getReportCountForTechnician(technicianId, statusFilter);
            
            req.setAttribute("reports", reports);
            req.setAttribute("totalReports", totalReports);
            req.setAttribute("currentPage", page);
            req.setAttribute("pageSize", pageSize);
            req.setAttribute("totalPages", (int) Math.ceil((double) totalReports / pageSize));
            req.setAttribute("pageTitle", "My Repair Reports");
            req.setAttribute("contentView", "/WEB-INF/technician/technician-reports.jsp");
            req.setAttribute("activePage", "reports");
            req.getRequestDispatcher("/WEB-INF/technician/technician-layout.jsp").forward(req, resp);
            
        } catch (SQLException e) {
            throw new ServletException("Database error: " + e.getMessage(), e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        Integer sessionId = session != null ? (Integer) session.getAttribute("session_login_id") : null;
        String userRole = session != null ? (String) session.getAttribute("session_role") : null;
        
        // Check authentication
        if (sessionId == null || !isTechnicianOrAdmin(userRole)) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        
        String action = req.getParameter("action");
        
        try {
            RepairReportDAO reportDAO = new RepairReportDAO();
            int technicianId = sessionId.intValue();
            
            if ("create".equals(action)) {
                // Create new report
                RepairReport report = new RepairReport();
                String requestIdStr = req.getParameter("requestId");
                int requestId = 0; // Default to 0 if no request ID provided
                if (requestIdStr != null && !requestIdStr.trim().isEmpty()) {
                    try {
                        requestId = Integer.parseInt(requestIdStr);
                    } catch (NumberFormatException e) {
                        req.setAttribute("error", "Invalid request ID");
                        doGet(req, resp);
                        return;
                    }
                }
                report.setRequestId(requestId);
                report.setTechnicianId(technicianId);
                report.setDetails(req.getParameter("details"));
                report.setDiagnosis(req.getParameter("diagnosis"));
                report.setEstimatedCost(new BigDecimal(req.getParameter("estimatedCost")));
                report.setRepairDate(LocalDate.parse(req.getParameter("repairDate")));
                report.setQuotationStatus("Pending"); // Default status
                
                // Validate input using new validation system
                List<String> validationErrors = validateRepairReportInput(req, false); // false = create mode
                if (!validationErrors.isEmpty()) {
                    req.setAttribute("validationErrors", validationErrors);
                    req.setAttribute("requestId", report.getRequestId());
                    req.setAttribute("pageTitle", "Create Repair Report");
                    req.setAttribute("contentView", "/WEB-INF/technician/report-form.jsp");
                    req.setAttribute("activePage", "reports");
                    req.getRequestDispatcher("/WEB-INF/technician/technician-layout.jsp").forward(req, resp);
                    return;
                }
                
                int reportId = reportDAO.createRepairReport(report);
                if (reportId > 0) {
                    req.getSession().setAttribute("successMessage", "Repair Report has been submitted successfully ✅");
                    resp.sendRedirect(req.getContextPath() + "/technician/reports");
                } else {
                    req.setAttribute("error", "Failed to create repair report");
                    doGet(req, resp);
                }
                
            } else if ("update".equals(action)) {
                // Update existing report
                int reportId = Integer.parseInt(req.getParameter("reportId"));
                
                if (!reportDAO.canTechnicianEditReport(reportId, technicianId)) {
                    req.setAttribute("error", "This report cannot be edited (quotation status is not Pending)");
                    doGet(req, resp);
                    return;
                }
                
                // Get existing report data first
                RepairReport existingReport = reportDAO.findById(reportId);
                if (existingReport == null) {
                    req.setAttribute("error", "Report not found");
                    doGet(req, resp);
                    return;
                }
                
                RepairReport report = new RepairReport();
                report.setReportId(reportId);
                report.setRequestId(existingReport.getRequestId()); // Use existing requestId
                report.setTechnicianId(technicianId);
                report.setDetails(req.getParameter("details"));
                report.setDiagnosis(req.getParameter("diagnosis"));
                report.setEstimatedCost(new BigDecimal(req.getParameter("estimatedCost")));
                report.setRepairDate(existingReport.getRepairDate()); // Use existing repair date
                report.setQuotationStatus("Pending"); // Keep as Pending
                
                // Validate input using new validation system
                List<String> validationErrors = validateRepairReportInput(req, true); // true = update mode
                if (!validationErrors.isEmpty()) {
                    req.setAttribute("validationErrors", validationErrors);
                    req.setAttribute("report", report);
                    req.setAttribute("pageTitle", "Edit Repair Report");
                    req.setAttribute("contentView", "/WEB-INF/technician/report-form.jsp");
                    req.setAttribute("activePage", "reports");
                    req.getRequestDispatcher("/WEB-INF/technician/technician-layout.jsp").forward(req, resp);
                    return;
                }
                
                boolean updated = reportDAO.updateRepairReport(report);
                if (updated) {
                    req.setAttribute("success", "Repair report updated successfully");
                    resp.sendRedirect(req.getContextPath() + "/technician/reports?action=detail&reportId=" + reportId);
                } else {
                    req.setAttribute("error", "Failed to update repair report");
                    doGet(req, resp);
                }
                
            } else {
                req.setAttribute("error", "Invalid action");
                doGet(req, resp);
            }
            
        } catch (SQLException e) {
            throw new ServletException("Database error: " + e.getMessage(), e);
        } catch (NumberFormatException e) {
            req.setAttribute("error", "Invalid numeric input");
            doGet(req, resp);
        } catch (DateTimeParseException e) {
            req.setAttribute("error", "Invalid date format");
            doGet(req, resp);
        }
    }
    
    private List<String> validateRepairReportInput(HttpServletRequest req, boolean isEditMode) {
        List<String> errors = new ArrayList<>();
        
        // Validate details
        TechnicianValidator.ValidationResult detailsResult = TechnicianValidator.validateDetails(req.getParameter("details"));
        if (!detailsResult.isValid()) {
            errors.addAll(detailsResult.getErrors());
        }
        
        // Validate diagnosis
        TechnicianValidator.ValidationResult diagnosisResult = TechnicianValidator.validateDiagnosis(req.getParameter("diagnosis"));
        if (!diagnosisResult.isValid()) {
            errors.addAll(diagnosisResult.getErrors());
        }
        
        // Validate estimated cost
        TechnicianValidator.ValidationResult costResult = TechnicianValidator.validateEstimatedCost(req.getParameter("estimatedCost"));
        if (!costResult.isValid()) {
            errors.addAll(costResult.getErrors());
        }
        
        // Validate repair date (with edit mode consideration)
        String repairDateParam = req.getParameter("repairDate");
        if (isEditMode && repairDateParam == null) {
            // For edit mode, if repair date is null (disabled field), skip validation
            // The repair date will be preserved from existing report
        } else {
            TechnicianValidator.ValidationResult dateResult = TechnicianValidator.validateRepairDate(repairDateParam, isEditMode);
            if (!dateResult.isValid()) {
                errors.addAll(dateResult.getErrors());
            }
        }
        
        return errors;
    }

    private String sanitize(String s) {
        if (s == null) return null;
        String t = s.trim();
        return t.isEmpty() ? null : t;
    }

    private int parseInt(String s, int def) {
        try {
            return Integer.parseInt(s);
        } catch (Exception e) {
            return def;
        }
    }

    private boolean isTechnicianOrAdmin(String role) {
        if (role == null) return false;
        String r = role.toLowerCase();
        return r.contains("technician") || r.equals("admin");
    }
}
