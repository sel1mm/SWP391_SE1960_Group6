package controller;

import dal.RepairReportDAO;
import dal.WorkTaskDAO;
import dal.PartDetailDAO;
import dal.PartDAO;
import model.RepairReport;
import model.RepairReportDetail;
import model.WorkTask;
import java.util.Map;
import java.util.LinkedHashMap;
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
import java.util.HashMap;
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

            // Handle AJAX requests for parts search and cart operations
            if ("searchParts".equals(action)) {
                handleSearchPartsAjax(req, resp);
                return;
            } else if ("addPartAjax".equals(action)) {
                handleAddPartAjax(req, resp, technicianId);
                return;
            } else if ("removePartAjax".equals(action)) {
                handleRemovePartAjax(req, resp);
                return;
            } else if ("getCartSummary".equals(action)) {
                handleGetCartSummaryAjax(req, resp);
                return;
            } else if ("clearCartAjax".equals(action)) {
                handleClearCartAjax(req, resp);
                return;
            } else if ("getCustomerContracts".equals(action)) {
                handleGetCustomerContractsAjax(req, resp);
                return;
            } else if ("checkExistingReport".equals(action)) {
                handleCheckExistingReportAjax(req, resp, technicianId);
                return;
            }

            if ("create".equals(action)) {
                // Show create form with assigned tasks dropdown
                WorkTaskDAO workTaskDAO = new WorkTaskDAO();
                List<WorkTaskDAO.WorkTaskForReport> assignedTasks = workTaskDAO.getAssignedTasksForReport(technicianId);
                
                Integer requestId = null;
                if (requestIdParam != null && !requestIdParam.trim().isEmpty()) {
                    try {
                        requestId = Integer.parseInt(requestIdParam);
                        // Validate that technician is assigned to this request
                        if (!workTaskDAO.isTechnicianAssignedToRequest(technicianId, requestId)) {
                            req.setAttribute("error", "You are not assigned to this request");
                            doGetReportList(req, resp, technicianId);
                            return;
                        }
                        // Check if this technician's task is completed
                        if (workTaskDAO.isTechnicianTaskCompleted(technicianId, requestId)) {
                            req.setAttribute("error", "Cannot create report for completed task");
                            doGetReportList(req, resp, technicianId);
                            return;
                        }
                        // Check if a repair report already exists for this requestId by this technician
                        try {
                            RepairReport existingReport = reportDAO.findByRequestIdAndTechnician(requestId, technicianId);
                            if (existingReport != null) {
                                // Report already exists, redirect to edit instead
                                req.setAttribute("info", "A repair report already exists for this task. Redirecting to edit...");
                                resp.sendRedirect(req.getContextPath() + "/technician/reports?action=edit&reportId=" + existingReport.getReportId());
                                return;
                            }
                        } catch (SQLException e) {
                            // Log error but continue - allow creation if check fails
                            System.err.println("Error checking for existing report: " + e.getMessage());
                        }
                    } catch (NumberFormatException e) {
                        req.setAttribute("error", "Invalid request ID");
                        doGetReportList(req, resp, technicianId);
                        return;
                    }
                }
                
                // Load all available parts for dropdown
                List<Map<String, Object>> availableParts = null;
                try {
                    availableParts = getAllAvailableParts();
                } catch (SQLException e) {
                    req.setAttribute("error", "Error loading parts: " + e.getMessage());
                    availableParts = new ArrayList<>();
                }
                
                // Get selected parts from session (scoped to this request)
                String cartKey = "selectedParts_" + (requestId != null ? requestId : "new");
                @SuppressWarnings("unchecked")
                List<RepairReportDetail> selectedParts = (List<RepairReportDetail>) req.getSession().getAttribute(cartKey);
                if (selectedParts == null) {
                    selectedParts = new ArrayList<>();
                    req.getSession().setAttribute(cartKey, selectedParts);
                }
                
                // Calculate subtotal
                BigDecimal subtotal = calculateSubtotal(selectedParts);

                // Get customer and request info for the summary box
                Map<String, Object> customerRequestInfo = null;
                List<Map<String, Object>> customerContracts = new ArrayList<>();
                if (requestId != null) {
                    try {   
                        customerRequestInfo = getCustomerRequestInfo(requestId);
                        if (customerRequestInfo != null) {
                            int customerAccountId = (Integer) customerRequestInfo.get("customerAccountId");
                            customerContracts = getCustomerContracts(customerAccountId);
                        }
                    } catch (SQLException e) {
                        // Log error but continue
                        System.err.println("Error loading customer info: " + e.getMessage());
                    }
                }

                // Pass session search data to request for JSP access
                req.setAttribute("partsSearchQuery", req.getSession().getAttribute("partsSearchQuery"));
                req.setAttribute("partsSearchResults", req.getSession().getAttribute("partsSearchResults"));

                req.setAttribute("requestId", requestId);
                req.setAttribute("assignedTasks", assignedTasks);
                req.setAttribute("availableParts", availableParts);
                req.setAttribute("selectedParts", selectedParts);
                req.setAttribute("subtotal", subtotal);
                req.setAttribute("customerRequestInfo", customerRequestInfo);
                req.setAttribute("customerContracts", customerContracts);
                req.setAttribute("pageTitle", "Create Repair Report");
                req.setAttribute("contentView", "/WEB-INF/technician/report-form.jsp");
                req.setAttribute("activePage", "reports");
                req.getRequestDispatcher("/WEB-INF/technician/technician-layout.jsp").forward(req, resp);
                
            } else if ("edit".equals(action) && reportIdParam != null) {
                // Show edit form
                int reportId = Integer.parseInt(reportIdParam);
                RepairReport report = reportDAO.findById(reportId);
                
                if (report == null) {
                    req.setAttribute("error", "Report not found");
                    doGetReportList(req, resp, technicianId);
                    return;
                }
                
                // Verify report belongs to this technician
                if (report.getTechnicianId() == null || report.getTechnicianId() != technicianId) {
                    req.setAttribute("error", "Report not found or not assigned to you");
                    doGetReportList(req, resp, technicianId);
                    return;
                }
                
                // Verify WorkTask is still assigned to this technician
                WorkTaskDAO workTaskDAO = new WorkTaskDAO();
                try {
                    if (!workTaskDAO.isTechnicianAssignedToRequest(technicianId, report.getRequestId())) {
                        req.setAttribute("error", "You are no longer assigned to this task");
                        doGetReportList(req, resp, technicianId);
                        return;
                    }
                } catch (SQLException e) {
                    req.setAttribute("error", "Error validating task assignment: " + e.getMessage());
                    doGetReportList(req, resp, technicianId);
                    return;
                }
                
                // Check if report can be edited (status must be Pending)
                try {
                    if (!reportDAO.canTechnicianEditReport(reportId, technicianId)) {
                        req.setAttribute("error", "This report cannot be edited (quotation status is not Pending)");
                        doGetReportList(req, resp, technicianId);
                        return;
                    }
                } catch (SQLException e) {
                    req.setAttribute("error", "Error checking edit permission: " + e.getMessage());
                    doGetReportList(req, resp, technicianId);
                    return;
                }
                
                // Load report details (parts) and put them in session for the cart
                List<RepairReportDetail> reportDetails = reportDAO.getReportDetails(reportId);
                String cartKey = "selectedParts_" + report.getRequestId();
                req.getSession().setAttribute(cartKey, reportDetails);
                
                // Load available parts for the form
                List<Map<String, Object>> availableParts = null;
                try {
                    availableParts = getAllAvailableParts();
                } catch (SQLException e) {
                    req.setAttribute("error", "Error loading parts: " + e.getMessage());
                    availableParts = new ArrayList<>();
                }
                
                // Get customer/request info for display
                Map<String, Object> customerRequestInfo = null;
                try {
                    customerRequestInfo = getCustomerRequestInfo(report.getRequestId());
                } catch (SQLException e) {
                    System.err.println("Error loading customer info: " + e.getMessage());
                }
                
                // Calculate subtotal from existing parts
                BigDecimal subtotal = BigDecimal.ZERO;
                if (reportDetails != null && !reportDetails.isEmpty()) {
                    for (RepairReportDetail detail : reportDetails) {
                        subtotal = subtotal.add(detail.getUnitPrice().multiply(BigDecimal.valueOf(detail.getQuantity())));
                    }
                }
                
                // All validations passed, show edit form
                req.setAttribute("report", report);
                req.setAttribute("reportDetails", reportDetails);
                req.setAttribute("availableParts", availableParts);
                req.setAttribute("selectedParts", reportDetails);
                req.setAttribute("subtotal", subtotal);
                req.setAttribute("customerRequestInfo", customerRequestInfo);
                req.setAttribute("pageTitle", "Edit Repair Report");
                req.setAttribute("contentView", "/WEB-INF/technician/report-form.jsp");
                req.setAttribute("activePage", "reports");
                req.getRequestDispatcher("/WEB-INF/technician/technician-layout.jsp").forward(req, resp);
                
            } else if ("detail".equals(action) && reportIdParam != null) {
                // Show report detail
                int reportId = Integer.parseInt(reportIdParam);
                RepairReport report = reportDAO.findById(reportId);
                
                if (report != null && report.getTechnicianId() != null && report.getTechnicianId() == technicianId) {
                    // Load report details (parts)
                    List<RepairReportDetail> details = reportDAO.getReportDetails(reportId);
                    req.setAttribute("report", report);
                    req.setAttribute("reportDetails", details);
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
            List<RepairReportDAO.RepairReportWithCustomer> reportsWithCustomer = reportDAO.getRepairReportsForTechnicianWithCustomer(technicianId, searchQuery, statusFilter, page, pageSize);
            int totalReports = reportDAO.getRepairReportCountForTechnicianWithCustomer(technicianId, statusFilter);
            
            req.setAttribute("reportsWithCustomer", reportsWithCustomer);
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
            
            // Handle parts management actions
            if ("searchParts".equals(action)) {
                handleSearchParts(req, resp);
                return;
            } else if ("adjustQuantity".equals(action)) {
                handleAdjustQuantity(req, resp);
                return;
            } else if ("addPart".equals(action)) {
                handleAddPart(req, resp, technicianId);
                return;
            } else if ("removePart".equals(action)) {
                handleRemovePart(req, resp);
                return;
            } else if ("clearParts".equals(action)) {
                String requestIdStr = req.getParameter("requestId");
                if (requestIdStr != null && !requestIdStr.trim().isEmpty()) {
                    String cartKey = "selectedParts_" + requestIdStr;
                    req.getSession().removeAttribute(cartKey);
                }
                resp.sendRedirect(req.getContextPath() + "/technician/reports?action=create&requestId=" + requestIdStr);
                return;
            }
            
            if ("create".equals(action)) {
                // Create new report with validation
                WorkTaskDAO workTaskDAO = new WorkTaskDAO();
                RepairReport report = new RepairReport();
                String requestIdStr = req.getParameter("requestId");
                
                // Validate request ID
                if (requestIdStr == null || requestIdStr.trim().isEmpty()) {
                    req.setAttribute("error", "Request ID is required");
                    doGet(req, resp);
                    return;
                }
                
                int requestId;
                try {
                    requestId = Integer.parseInt(requestIdStr);
                } catch (NumberFormatException e) {
                    req.setAttribute("error", "Invalid request ID");
                    doGet(req, resp);
                    return;
                }
                
                // Validate technician assignment and task status
                if (!workTaskDAO.isTechnicianAssignedToRequest(technicianId, requestId)) {
                    req.setAttribute("error", "You are not assigned to this request");
                    doGet(req, resp);
                    return;
                }
                
                if (workTaskDAO.isTechnicianTaskCompleted(technicianId, requestId)) {
                    req.setAttribute("error", "Cannot create report for completed task");
                    doGet(req, resp);
                    return;
                }
                
                // Check if a repair report already exists for this requestId by this technician
                try {
                    RepairReport existingReport = reportDAO.findByRequestIdAndTechnician(requestId, technicianId);
                    if (existingReport != null) {
                        // Report already exists, redirect to edit instead
                        req.setAttribute("error", "A repair report already exists for this task. Redirecting to edit...");
                        resp.sendRedirect(req.getContextPath() + "/technician/reports?action=edit&reportId=" + existingReport.getReportId());
                        return;
                    }
                } catch (SQLException e) {
                    req.setAttribute("error", "Error checking for existing report: " + e.getMessage());
                    doGet(req, resp);
                    return;
                }
                
                report.setRequestId(requestId);
                report.setTechnicianId(technicianId);
                report.setDetails(req.getParameter("details"));
                // Diagnosis field is replaced by parts - keep empty or use summary
                report.setDiagnosis(""); // Parts are stored in RepairReportDetail
                
                // targetContractId removed - contract is automatically determined from ServiceRequest
                // when the repair report is approved (via database trigger)
                
                // Get selected parts from session (scoped to this request)
                String cartKey = "selectedParts_" + report.getRequestId();
                @SuppressWarnings("unchecked")
                List<RepairReportDetail> parts = (List<RepairReportDetail>) req.getSession().getAttribute(cartKey);
                if (parts == null) {
                    parts = new ArrayList<>();
                }
                
                List<String> validationErrors = new ArrayList<>();
                
                // Run validations (targetContractId validation removed - contract is auto-determined from ServiceRequest)
                validationErrors.addAll(validateRepairReportInput(req, false, parts));
                
                // Calculate estimated cost from parts if not manually overridden
                // Input is in VND, convert to USD for database storage
                String estimatedCostStr = req.getParameter("estimatedCost");
                BigDecimal estimatedCost;
                if (estimatedCostStr != null && !estimatedCostStr.trim().isEmpty()) {
                    try {
                        // Input is in VND, convert to USD (divide by 26000)
                        BigDecimal vndValue = new BigDecimal(estimatedCostStr);
                        BigDecimal usdValue = vndValue.divide(new BigDecimal("26000"), 2, java.math.RoundingMode.HALF_UP);
                        estimatedCost = usdValue;
                    } catch (NumberFormatException e) {
                        validationErrors.add("Invalid estimated cost format");
                        estimatedCost = calculateTotalFromParts(parts);
                    }
                } else {
                    estimatedCost = calculateTotalFromParts(parts);
                }
                report.setEstimatedCost(estimatedCost);
                report.setRepairDate(LocalDate.parse(req.getParameter("repairDate")));
                report.setQuotationStatus("Pending"); // Default status
                
                if (!validationErrors.isEmpty()) {
                    req.setAttribute("validationErrors", validationErrors);
                    req.setAttribute("requestId", report.getRequestId());
                    // Get assigned tasks for dropdown
                    List<WorkTaskDAO.WorkTaskForReport> assignedTasks = workTaskDAO.getAssignedTasksForReport(technicianId);
                    req.setAttribute("assignedTasks", assignedTasks);
                    req.setAttribute("pageTitle", "Create Repair Report");
                    req.setAttribute("contentView", "/WEB-INF/technician/report-form.jsp");
                    req.setAttribute("activePage", "reports");
                    req.getRequestDispatcher("/WEB-INF/technician/technician-layout.jsp").forward(req, resp);
                    return;
                }
                
                // Use transactional insert with details
                int reportId = reportDAO.insertReportWithDetails(report, parts);
                if (reportId > 0) {
                    // Clear selected parts from session (request-specific cart)
                    req.getSession().removeAttribute(cartKey);
                    req.getSession().setAttribute("successMessage", "Repair Report has been submitted successfully ✅");
                    resp.sendRedirect(req.getContextPath() + "/technician/reports");
                } else {
                    req.setAttribute("error", "Failed to create repair report");
                    doGet(req, resp);
                }
                
            } else if ("update".equals(action)) {
                // Update existing report
                int reportId = Integer.parseInt(req.getParameter("reportId"));
                
                // Get existing report data first
                RepairReport existingReport = reportDAO.findById(reportId);
                if (existingReport == null) {
                    req.setAttribute("error", "Report not found");
                    doGet(req, resp);
                    return;
                }
                
                // Verify report belongs to this technician
                if (existingReport.getTechnicianId() == null || existingReport.getTechnicianId() != technicianId) {
                    req.setAttribute("error", "Report not found or not assigned to you");
                    doGet(req, resp);
                    return;
                }
                
                // Verify WorkTask is still assigned to this technician
                WorkTaskDAO workTaskDAO = new WorkTaskDAO();
                try {
                    if (!workTaskDAO.isTechnicianAssignedToRequest(technicianId, existingReport.getRequestId())) {
                        req.setAttribute("error", "You are no longer assigned to this task");
                        doGet(req, resp);
                        return;
                    }
                } catch (SQLException e) {
                    req.setAttribute("error", "Error validating task assignment: " + e.getMessage());
                    doGet(req, resp);
                    return;
                }
                
                // Check if report can be edited (status must be Pending)
                try {
                    if (!reportDAO.canTechnicianEditReport(reportId, technicianId)) {
                        req.setAttribute("error", "This report cannot be edited (quotation status is not Pending)");
                        doGet(req, resp);
                        return;
                    }
                } catch (SQLException e) {
                    req.setAttribute("error", "Error checking edit permission: " + e.getMessage());
                    doGet(req, resp);
                    return;
                }
                
                RepairReport report = new RepairReport();
                report.setReportId(reportId);
                report.setRequestId(existingReport.getRequestId()); // Use existing requestId
                report.setTechnicianId(technicianId);
                report.setDetails(req.getParameter("details"));
                report.setDiagnosis(""); // Parts replace diagnosis
                
                // Get selected parts from session (or existing parts if session is empty)
                String cartKey = "selectedParts_" + existingReport.getRequestId();
                @SuppressWarnings("unchecked")
                List<RepairReportDetail> parts = (List<RepairReportDetail>) req.getSession().getAttribute(cartKey);
                if (parts == null || parts.isEmpty()) {
                    // If no parts in session, load existing parts from database
                    parts = reportDAO.getReportDetails(reportId);
                }
                
                // Input is in VND, convert to USD for database storage
                String estimatedCostStr = req.getParameter("estimatedCost");
                BigDecimal estimatedCost;
                if (estimatedCostStr != null && !estimatedCostStr.trim().isEmpty()) {
                    try {
                        // Input is in VND, convert to USD (divide by 26000)
                        BigDecimal vndValue = new BigDecimal(estimatedCostStr);
                        BigDecimal usdValue = vndValue.divide(new BigDecimal("26000"), 2, java.math.RoundingMode.HALF_UP);
                        estimatedCost = usdValue;
                    } catch (NumberFormatException e) {
                        estimatedCost = calculateTotalFromParts(parts);
                    }
                } else {
                    estimatedCost = calculateTotalFromParts(parts);
                }
                report.setEstimatedCost(estimatedCost);
                report.setRepairDate(existingReport.getRepairDate()); // Use existing repair date
                report.setQuotationStatus("Pending"); // Keep as Pending
                
                // Validate input using new validation system
                List<String> validationErrors = validateRepairReportInput(req, true, parts); // true = update mode
                if (!validationErrors.isEmpty()) {
                    req.setAttribute("validationErrors", validationErrors);
                    req.setAttribute("report", report);
                    req.setAttribute("pageTitle", "Edit Repair Report");
                    req.setAttribute("contentView", "/WEB-INF/technician/report-form.jsp");
                    req.setAttribute("activePage", "reports");
                    req.getRequestDispatcher("/WEB-INF/technician/technician-layout.jsp").forward(req, resp);
                    return;
                }
                
                // For update, we need to delete old details and insert new ones
                // This requires a more complex update method - for now, we'll update the report header
                // and note that parts editing requires deleting and recreating the report
                // TODO: Implement updateReportWithDetails method if needed
                boolean updated = reportDAO.updateRepairReport(report);
                if (updated) {
                    // Clear session (request-specific cart)
                    req.getSession().removeAttribute(cartKey);
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
    
    /**
     * Parse parts arrays from request parameters.
     * Expected format: partId[], partDetailId[], quantity[], unitPrice[]
     */
    private List<RepairReportDetail> parsePartsFromRequest(HttpServletRequest req) {
        List<RepairReportDetail> parts = new ArrayList<>();
        String[] partIds = req.getParameterValues("partId");
        
        if (partIds == null || partIds.length == 0) {
            return parts;
        }
        
        String[] partDetailIds = req.getParameterValues("partDetailId");
        String[] quantities = req.getParameterValues("quantity");
        String[] unitPrices = req.getParameterValues("unitPrice");
        
        for (int i = 0; i < partIds.length; i++) {
            try {
                int partId = Integer.parseInt(partIds[i]);
                Integer partDetailId = null;
                if (partDetailIds != null && i < partDetailIds.length && partDetailIds[i] != null && !partDetailIds[i].trim().isEmpty()) {
                    partDetailId = Integer.parseInt(partDetailIds[i]);
                }
                int quantity = quantities != null && i < quantities.length ? Integer.parseInt(quantities[i]) : 1;
                BigDecimal unitPrice = unitPrices != null && i < unitPrices.length ? new BigDecimal(unitPrices[i]) : BigDecimal.ZERO;
                
                RepairReportDetail detail = new RepairReportDetail();
                detail.setPartId(partId);
                detail.setPartDetailId(partDetailId);
                detail.setQuantity(quantity);
                detail.setUnitPrice(unitPrice);
                parts.add(detail);
            } catch (NumberFormatException e) {
                // Skip invalid entries
                System.err.println("Invalid part data at index " + i + ": " + e.getMessage());
            }
        }
        
        return parts;
    }
    
    /**
     * Calculate total cost from parts list.
     */
    private BigDecimal calculateTotalFromParts(List<RepairReportDetail> parts) {
        if (parts == null || parts.isEmpty()) {
            return BigDecimal.ZERO;
        }
        return parts.stream()
            .map(RepairReportDetail::getLineTotal)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
    }
    
    private List<String> validateRepairReportInput(HttpServletRequest req, boolean isEditMode, List<RepairReportDetail> parts) {
        List<String> errors = new ArrayList<>();
        
        // Validate details
        TechnicianValidator.ValidationResult detailsResult = TechnicianValidator.validateDetails(req.getParameter("details"));
        if (!detailsResult.isValid()) {
            errors.addAll(detailsResult.getErrors());
        }
        
        // Validate parts (replaces diagnosis validation)
        if (parts == null || parts.isEmpty()) {
            errors.add("At least one part must be selected");
        } else {
            try {
                PartDetailDAO partDetailDAO = new PartDetailDAO();
                for (RepairReportDetail part : parts) {
                    // Validate partId exists
                    if (part.getPartId() <= 0) {
                        errors.add("Invalid part ID");
                        continue;
                    }
                    
                    // Validate quantity
                    if (part.getQuantity() <= 0) {
                        errors.add("Quantity must be greater than 0 for part ID " + part.getPartId());
                    }
                    
                    // Validate unit price
                    if (part.getUnitPrice() == null || part.getUnitPrice().compareTo(BigDecimal.ZERO) < 0) {
                        errors.add("Unit price must be >= 0 for part ID " + part.getPartId());
                    }
                    
                    // Validate available quantity
                    int availableQty = partDetailDAO.getAvailableQuantityForPart(part.getPartId());
                    if (part.getQuantity() > availableQty) {
                        errors.add("Insufficient quantity for part ID " + part.getPartId() + 
                                  ". Required: " + part.getQuantity() + ", Available: " + availableQty);
                    }
                    
                    // Validate partDetailId if specified
                    if (part.getPartDetailId() != null) {
                        var partDetail = partDetailDAO.lockAndValidatePartDetail(part.getPartDetailId());
                        if (partDetail == null) {
                            errors.add("PartDetail ID " + part.getPartDetailId() + " is not available");
                        } else if (partDetail.getPartId() != part.getPartId()) {
                            errors.add("PartDetail ID " + part.getPartDetailId() + " does not belong to part ID " + part.getPartId());
                        }
                    }
                }
            } catch (SQLException e) {
                errors.add("Database error while validating parts: " + e.getMessage());
            }
        }
        
        // Validate estimated cost
        String estimatedCostStr = req.getParameter("estimatedCost");
        if (estimatedCostStr != null && !estimatedCostStr.trim().isEmpty()) {
            TechnicianValidator.ValidationResult costResult = TechnicianValidator.validateEstimatedCost(estimatedCostStr);
            if (!costResult.isValid()) {
                errors.addAll(costResult.getErrors());
            }
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
    
    /**
     * Get all available parts for dropdown (server-side)
     */
    private List<Map<String, Object>> getAllAvailableParts() throws SQLException {
        System.out.println("=== getAllAvailableParts() called ===");
        List<Map<String, Object>> results = new ArrayList<>();
        
        // Simplified query: Just get all parts from Part table
        // Count available PartDetail records separately
        String sql = "SELECT " +
                    "    p.partId, " +
                    "    p.partName, " +
                    "    p.unitPrice, " +
                    "    (SELECT MIN(pd.partDetailId) FROM PartDetail pd WHERE pd.partId = p.partId AND pd.status = 'Available') as partDetailId, " +
                    "    (SELECT MIN(pd.serialNumber) FROM PartDetail pd WHERE pd.partId = p.partId AND pd.status = 'Available') as serialNumber, " +
                    "    (SELECT MIN(pd.location) FROM PartDetail pd WHERE pd.partId = p.partId AND pd.status = 'Available') as location, " +
                    "    COALESCE((SELECT COUNT(*) FROM PartDetail pd WHERE pd.partId = p.partId AND pd.status = 'Available'), 0) as availableQuantity " +
                    "FROM Part p " +
                    "ORDER BY p.partName";
        
        System.out.println("Executing SQL: " + sql);
        
        try (var con = new dal.DBContext().connection;
             var ps = con.prepareStatement(sql)) {
            
            System.out.println("Connection obtained, executing query...");
            try (var rs = ps.executeQuery()) {
                System.out.println("Query executed, processing results...");
                int count = 0;
                while (rs.next()) {
                    count++;
                    Map<String, Object> part = new LinkedHashMap<>();
                    part.put("partId", rs.getInt("partId"));
                    Object partDetailId = rs.getObject("partDetailId");
                    part.put("partDetailId", partDetailId != null ? partDetailId : null);
                    part.put("partName", rs.getString("partName"));
                    part.put("serialNumber", rs.getString("serialNumber"));
                    part.put("location", rs.getString("location"));
                    part.put("unitPrice", rs.getBigDecimal("unitPrice"));
                    part.put("availableQuantity", rs.getInt("availableQuantity"));
                    results.add(part);
                    System.out.println("  Part #" + count + ": " + rs.getString("partName") + " (ID: " + rs.getInt("partId") + ")");
                }
                System.out.println("Total parts found: " + count);
            }
        } catch (SQLException e) {
            System.err.println("SQLException in getAllAvailableParts: " + e.getMessage());
            e.printStackTrace();
            throw e;
        }
        
        System.out.println("Returning " + results.size() + " parts");
        return results;
    }
    
    /**
     * Handle adding a part to the selection (server-side)
     */
    private void handleAddPart(HttpServletRequest req, HttpServletResponse resp, int technicianId) 
            throws ServletException, IOException {
        try {
            String partIdStr = req.getParameter("partId");
            String quantityStr = req.getParameter("quantity");
            String requestIdStr = req.getParameter("requestId");
            
            if (partIdStr == null || quantityStr == null) {
                req.setAttribute("error", "Missing part ID or quantity");
                resp.sendRedirect(req.getContextPath() + "/technician/reports?action=create&requestId=" + requestIdStr);
                return;
            }
            
            int partId = Integer.parseInt(partIdStr);
            int quantity = Integer.parseInt(quantityStr);
            
            // Get part details directly
            String sql = "SELECT p.partId, p.partName, p.unitPrice, " +
                       "MIN(pd.partDetailId) as partDetailId, " +
                       "MIN(CASE WHEN pd.status = 'Available' THEN pd.serialNumber END) as serialNumber, " +
                       "MIN(CASE WHEN pd.status = 'Available' THEN pd.location END) as location, " +
                       "COUNT(CASE WHEN pd.status = 'Available' THEN 1 END) as availableQuantity " +
                       "FROM Part p " +
                       "LEFT JOIN PartDetail pd ON p.partId = pd.partId " +
                       "WHERE p.partId = ? AND pd.status = 'Available' " +
                       "GROUP BY p.partId, p.partName, p.unitPrice";
            
            Map<String, Object> part = null;
            try (var con = new dal.DBContext().connection;
                 var ps = con.prepareStatement(sql)) {
                ps.setInt(1, partId);
                try (var rs = ps.executeQuery()) {
                    if (rs.next()) {
                        part = new LinkedHashMap<>();
                        part.put("partId", rs.getInt("partId"));
                        part.put("partDetailId", rs.getObject("partDetailId"));
                        part.put("partName", rs.getString("partName"));
                        part.put("serialNumber", rs.getString("serialNumber"));
                        part.put("location", rs.getString("location"));
                        part.put("unitPrice", rs.getBigDecimal("unitPrice"));
                        part.put("availableQuantity", rs.getInt("availableQuantity"));
                    }
                }
            }
            
            if (part == null) {
                req.setAttribute("error", "Part not found or not available");
                resp.sendRedirect(req.getContextPath() + "/technician/reports?action=create&requestId=" + requestIdStr);
                return;
            }
            
            // Validate quantity
            int availableQty = ((Number) part.get("availableQuantity")).intValue();
            if (quantity > availableQty) {
                req.setAttribute("error", "Insufficient quantity. Available: " + availableQty);
                resp.sendRedirect(req.getContextPath() + "/technician/reports?action=create&requestId=" + requestIdStr);
                return;
            }
            
            // Get or create selected parts list in session
            @SuppressWarnings("unchecked")
            List<RepairReportDetail> selectedParts = (List<RepairReportDetail>) req.getSession().getAttribute("selectedParts");
            if (selectedParts == null) {
                selectedParts = new ArrayList<>();
                req.getSession().setAttribute("selectedParts", selectedParts);
            }
            
            // Check if part already exists, update quantity if so
            boolean found = false;
            for (RepairReportDetail detail : selectedParts) {
                if (detail.getPartId() == partId) {
                    int newQty = detail.getQuantity() + quantity;
                    if (newQty > availableQty) {
                        req.setAttribute("error", "Total quantity exceeds available. Available: " + availableQty);
                        resp.sendRedirect(req.getContextPath() + "/technician/reports?action=create&requestId=" + requestIdStr);
                        return;
                    }
                    detail.setQuantity(newQty);
                    found = true;
                    break;
                }
            }
            
            // Add new part if not found
            if (!found) {
                RepairReportDetail detail = new RepairReportDetail();
                detail.setPartId(partId);
                Object partDetailId = part.get("partDetailId");
                if (partDetailId != null) {
                    detail.setPartDetailId(((Number) partDetailId).intValue());
                }
                detail.setQuantity(quantity);
                detail.setUnitPrice((BigDecimal) part.get("unitPrice"));
                detail.setPartName((String) part.get("partName"));
                detail.setSerialNumber((String) part.get("serialNumber"));
                detail.setLocation((String) part.get("location"));
                selectedParts.add(detail);
            }
            
            resp.sendRedirect(req.getContextPath() + "/technician/reports?action=create&requestId=" + requestIdStr);
            
        } catch (Exception e) {
            req.setAttribute("error", "Error adding part: " + e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/technician/reports?action=create&requestId=" + req.getParameter("requestId"));
        }
    }
    
    /**
     * Handle parts search form submission
     */
    private void handleSearchParts(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException, SQLException {
        String query = req.getParameter("searchQuery");
        String requestIdStr = req.getParameter("requestId");

        System.out.println("=== Parts Search Debug ===");
        System.out.println("Search query: " + query);
        System.out.println("Request ID: " + requestIdStr);

        if (query != null && !query.trim().isEmpty()) {
            // Store search query in session
            req.getSession().setAttribute("partsSearchQuery", query.trim());
            
            // Perform search
            List<Map<String, Object>> searchResults = searchAvailableParts(query.trim(), 20);
            System.out.println("Search results found: " + (searchResults != null ? searchResults.size() : 0));
            
            // Store results in session
            req.getSession().setAttribute("partsSearchResults", searchResults);
            
            // Debug: print first result if available
            if (searchResults != null && !searchResults.isEmpty()) {
                Map<String, Object> firstResult = searchResults.get(0);
                System.out.println("First result: " + firstResult.get("partName") + " (ID: " + firstResult.get("partId") + ")");
            }
        } else {
            // Clear search
            System.out.println("Clearing search results");
            req.getSession().removeAttribute("partsSearchQuery");
            req.getSession().removeAttribute("partsSearchResults");
        }

        System.out.println("========================");

        // Redirect back to create form
        resp.sendRedirect(req.getContextPath() + "/technician/reports?action=create&requestId=" + requestIdStr);
    }

    /**
     * Handle quantity adjustment for search results
     */
    private void handleAdjustQuantity(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String partIdStr = req.getParameter("partId");
        String deltaStr = req.getParameter("delta");
        String requestIdStr = req.getParameter("requestId");

        if (partIdStr == null || deltaStr == null) {
            resp.sendRedirect(req.getContextPath() + "/technician/reports?action=create&requestId=" + requestIdStr);
            return;
        }

        try {
            int partId = Integer.parseInt(partIdStr);
            int delta = Integer.parseInt(deltaStr);

            // Get search results from session
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> searchResults = (List<Map<String, Object>>) req.getSession().getAttribute("partsSearchResults");

            if (searchResults != null) {
                // Find the part in search results and update quantity
                for (Map<String, Object> part : searchResults) {
                    if (part.get("partId").equals(partId)) {
                        Integer currentQty = (Integer) part.get("quantity");
                        if (currentQty == null) currentQty = 0;

                        int newQty = Math.max(0, currentQty + delta);
                        int maxAvailable = (Integer) part.get("availableQuantity");

                        newQty = Math.min(newQty, maxAvailable);
                        part.put("quantity", newQty);
                        break;
                    }
                }

                req.getSession().setAttribute("partsSearchResults", searchResults);
            }
        } catch (NumberFormatException e) {
            // Ignore invalid input
        }

        resp.sendRedirect(req.getContextPath() + "/technician/reports?action=create&requestId=" + requestIdStr);
    }

    /**
     * Search for available parts by name or serial number
     */
    private List<Map<String, Object>> searchAvailableParts(String query, int limit) throws SQLException {
        List<Map<String, Object>> results = new ArrayList<>();

        // Fixed query: Search parts by name first, then join with available PartDetails
        // This ensures we find parts even if the search term doesn't match serial/location
        String sql = "SELECT " +
                    "    p.partId, " +
                    "    p.partName, " +
                    "    p.unitPrice, " +
                    "    MIN(pd.partDetailId) as partDetailId, " +
                    "    MIN(CASE WHEN pd.status = 'Available' THEN pd.serialNumber END) as serialNumber, " +
                    "    MIN(CASE WHEN pd.status = 'Available' THEN pd.location END) as location, " +
                    "    COUNT(CASE WHEN pd.status = 'Available' THEN 1 END) as availableQuantity " +
                    "FROM Part p " +
                    "LEFT JOIN PartDetail pd ON p.partId = pd.partId AND pd.status = 'Available' " +
                    "WHERE p.partName LIKE ? " +
                    "   OR EXISTS (" +
                    "       SELECT 1 FROM PartDetail pd2 " +
                    "       WHERE pd2.partId = p.partId " +
                    "       AND pd2.status = 'Available' " +
                    "       AND (pd2.serialNumber LIKE ? OR pd2.location LIKE ?)" +
                    "   ) " +
                    "GROUP BY p.partId, p.partName, p.unitPrice " +
                    "HAVING availableQuantity > 0 " +
                    "ORDER BY p.partName " +
                    "LIMIT ?";

        System.out.println("=== Search Available Parts Debug ===");
        System.out.println("Search query: '" + query + "'");
        
        try (var con = new dal.DBContext().connection;
             var ps = con.prepareStatement(sql)) {

            String searchPattern = "%" + query + "%";
            ps.setString(1, searchPattern); // Part name search
            ps.setString(2, searchPattern); // Serial number search
            ps.setString(3, searchPattern); // Location search
            ps.setInt(4, limit);

            System.out.println("SQL: " + sql.replaceAll("\\s+", " "));
            System.out.println("Search pattern: " + searchPattern);

            try (var rs = ps.executeQuery()) {
                int count = 0;
                while (rs.next()) {
                    Map<String, Object> part = new HashMap<>();
                    part.put("partId", rs.getInt("partId"));
                    part.put("partName", rs.getString("partName"));
                    part.put("serialNumber", rs.getString("serialNumber"));
                    part.put("location", rs.getString("location"));
                    part.put("unitPrice", rs.getBigDecimal("unitPrice"));
                    part.put("availableQuantity", rs.getInt("availableQuantity"));
                    part.put("quantity", 0); // Start with 0 quantity
                    results.add(part);
                    count++;
                    
                    System.out.println("  [" + count + "] " + part.get("partName") + 
                                     " (ID:" + part.get("partId") + 
                                     ", Available:" + part.get("availableQuantity") + 
                                     ", Serial:" + part.get("serialNumber") + 
                                     ", Price:$" + part.get("unitPrice") + ")");
                }
                System.out.println("Total parts found: " + count);
            }
        } catch (Exception e) {
            System.err.println("ERROR searching parts: " + e.getMessage());
            e.printStackTrace();
            throw e;
        }
        
        System.out.println("=====================================");
        return results;
    }

    /**
     * Handle removing a part from selection (server-side)
     */
    private void handleRemovePart(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        String partIdStr = req.getParameter("partId");
        String requestIdStr = req.getParameter("requestId");
        
        if (partIdStr == null) {
            resp.sendRedirect(req.getContextPath() + "/technician/reports?action=create&requestId=" + requestIdStr);
            return;
        }
        
        int partId = Integer.parseInt(partIdStr);
        
        // Get request-specific cart
        String cartKey = "selectedParts_" + (requestIdStr != null ? requestIdStr : "new");
        @SuppressWarnings("unchecked")
        List<RepairReportDetail> selectedParts = (List<RepairReportDetail>) req.getSession().getAttribute(cartKey);
        if (selectedParts != null) {
            selectedParts.removeIf(detail -> detail.getPartId() == partId);
        }
        
        resp.sendRedirect(req.getContextPath() + "/technician/reports?action=create&requestId=" + requestIdStr);
    }
    

    /**
     * Calculate subtotal from selected parts
     */
    private BigDecimal calculateSubtotal(List<RepairReportDetail> parts) {
        if (parts == null || parts.isEmpty()) {
            return BigDecimal.ZERO;
        }
        return parts.stream()
            .map(RepairReportDetail::getLineTotal)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    /**
     * Get customer and request information for the summary box
     */
    private Map<String, Object> getCustomerRequestInfo(int requestId) throws SQLException {
        String sql = "SELECT " +
                    "sr.requestId, " +
                    "sr.contractId, " +
                    "c.contractType, " +
                    "a.accountId, " +
                    "a.fullName as customerName, " +
                    "sr.description as requestDescription, " +
                    "sr.requestType " +
                    "FROM ServiceRequest sr " +
                    "LEFT JOIN Contract c ON sr.contractId = c.contractId " +
                    "LEFT JOIN Account a ON sr.createdBy = a.accountId " +
                    "WHERE sr.requestId = ?";

        try (var con = new dal.DBContext().connection;
             var ps = con.prepareStatement(sql)) {

            ps.setInt(1, requestId);
            try (var rs = ps.executeQuery()) {
                if (rs.next()) {
                    Map<String, Object> info = new LinkedHashMap<>();
                    info.put("requestId", rs.getInt("requestId"));
                    info.put("contractId", rs.getObject("contractId"));
                    info.put("contractType", rs.getString("contractType"));
                    info.put("customerAccountId", rs.getInt("accountId"));
                    info.put("customerName", rs.getString("customerName"));
                    info.put("requestDescription", rs.getString("requestDescription"));
                    info.put("requestType", rs.getString("requestType"));
                    return info;
                }
            }
        }
        return null;
    }
    
    /**
     * Get all active contracts for a customer
     */
    private List<Map<String, Object>> getCustomerContracts(int customerAccountId) throws SQLException {
        List<Map<String, Object>> contracts = new ArrayList<>();
        
        String sql = "SELECT " +
                    "c.contractId, " +
                    "c.contractType, " +
                    "c.startDate, " +
                    "c.endDate, " +
                    "c.status, " +
                    "c.totalValue " +
                    "FROM Contract c " +
                    "WHERE c.customerId = ? " +
                    "AND c.status IN ('Active', 'Pending') " +
                    "ORDER BY c.startDate DESC";
        
        try (var con = new dal.DBContext().connection;
             var ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, customerAccountId);
            try (var rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> contract = new LinkedHashMap<>();
                    contract.put("contractId", rs.getInt("contractId"));
                    contract.put("contractType", rs.getString("contractType"));
                    contract.put("startDate", rs.getDate("startDate"));
                    contract.put("endDate", rs.getDate("endDate"));
                    contract.put("status", rs.getString("status"));
                    contract.put("totalValue", rs.getBigDecimal("totalValue"));
                    contracts.add(contract);
                }
            }
        }
        
        return contracts;
    }

    /**
     * Search parts by name or serial number (AJAX endpoint)
     */
    private List<Map<String, Object>> searchParts(String query) throws SQLException {
        List<Map<String, Object>> results = new ArrayList<>();

        // Fixed: Search in Part table, show all parts matching search
        // Count available PartDetail records
        String sql = "SELECT " +
                    "    p.partId, " +
                    "    p.partName, " +
                    "    p.unitPrice, " +
                    "    MIN(CASE WHEN pd.status = 'Available' THEN pd.partDetailId END) as partDetailId, " +
                    "    MIN(CASE WHEN pd.status = 'Available' THEN pd.serialNumber END) as serialNumber, " +
                    "    MIN(CASE WHEN pd.status = 'Available' THEN pd.location END) as location, " +
                    "    COALESCE(COUNT(CASE WHEN pd.status = 'Available' THEN 1 END), 0) as availableQuantity " +
                    "FROM Part p " +
                    "LEFT JOIN PartDetail pd ON p.partId = pd.partId " +
                    "WHERE (LOWER(p.partName) LIKE LOWER(?) " +
                    "       OR LOWER(pd.serialNumber) LIKE LOWER(?)) " +
                    "GROUP BY p.partId, p.partName, p.unitPrice " +
                    "ORDER BY p.partName " +
                    "LIMIT 50";

        try (var con = new dal.DBContext().connection;
             var ps = con.prepareStatement(sql)) {

            String searchPattern = "%" + query.toLowerCase() + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);

            try (var rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> part = new LinkedHashMap<>();
                    part.put("partId", rs.getInt("partId"));
                    Object partDetailId = rs.getObject("partDetailId");
                    part.put("partDetailId", partDetailId != null ? partDetailId : null);
                    part.put("partName", rs.getString("partName"));
                    part.put("serialNumber", rs.getString("serialNumber"));
                    part.put("location", rs.getString("location"));
                    part.put("unitPrice", rs.getBigDecimal("unitPrice"));
                    part.put("availableQuantity", rs.getInt("availableQuantity"));
                    results.add(part);
                }
            }
        }

        return results;
    }

    /**
     * Handle AJAX parts search
     */
    private void handleSearchPartsAjax(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        System.out.println("=== handleSearchPartsAjax called ===");
        String query = req.getParameter("q");
        System.out.println("Query parameter: " + query);
        
        List<Map<String, Object>> parts;
        
        try {
            // If query is empty, return all available parts
            if (query == null || query.trim().isEmpty()) {
                System.out.println("Calling getAllAvailableParts()");
                parts = getAllAvailableParts();
                System.out.println("getAllAvailableParts returned: " + (parts != null ? parts.size() : "null") + " parts");
            } else {
                System.out.println("Calling searchParts() with query: " + query);
                parts = searchParts(query.trim());
                System.out.println("searchParts returned: " + (parts != null ? parts.size() : "null") + " parts");
            }
            
            // Ensure parts is not null
            if (parts == null) {
                System.out.println("Parts was null, creating empty list");
                parts = new ArrayList<>();
            }
            
            System.out.println("Final parts count: " + parts.size());
            
            // Convert to JSON manually for simplicity
            StringBuilder json = new StringBuilder("[");
            for (int i = 0; i < parts.size(); i++) {
                Map<String, Object> part = parts.get(i);
                if (i > 0) json.append(",");
                json.append("{");
                json.append("\"partId\":").append(part.get("partId")).append(",");
                json.append("\"partName\":\"").append(escapeJsonString((String)part.get("partName"))).append("\",");
                json.append("\"serialNumber\":\"").append(escapeJsonString((String)part.get("serialNumber"))).append("\",");
                json.append("\"unitPrice\":").append(part.get("unitPrice")).append(",");
                json.append("\"availableQuantity\":").append(part.get("availableQuantity"));
                json.append("}");
            }
            json.append("]");
            
            String jsonResponse = json.toString();
            System.out.println("Sending JSON response (first 200 chars): " + jsonResponse.substring(0, Math.min(200, jsonResponse.length())));
            resp.getWriter().write(jsonResponse);
        } catch (SQLException e) {
            e.printStackTrace();
            System.err.println("SQLException in handleSearchPartsAjax: " + e.getMessage());
            resp.setStatus(500);
            resp.getWriter().write("{\"error\":\"Database error: " + escapeJsonString(e.getMessage()) + "\"}");
        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("Exception in handleSearchPartsAjax: " + e.getMessage());
            resp.setStatus(500);
            resp.getWriter().write("{\"error\":\"Error: " + escapeJsonString(e.getMessage()) + "\"}");
        }
    }

    /**
     * Handle AJAX add part to cart
     */
    private void handleAddPartAjax(HttpServletRequest req, HttpServletResponse resp, int technicianId) throws IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        try {
            String partIdStr = req.getParameter("partId");
            String quantityStr = req.getParameter("quantity");

            if (partIdStr == null || quantityStr == null) {
                resp.getWriter().write("{\"success\":false,\"error\":\"Missing parameters\"}");
                return;
            }

            int partId = Integer.parseInt(partIdStr);
            int quantity = Integer.parseInt(quantityStr);
            
            // Validate that there's a valid request with contract
            String requestIdParam = req.getParameter("requestId");
            if (requestIdParam == null || requestIdParam.trim().isEmpty()) {
                resp.getWriter().write("{\"success\":false,\"error\":\"Missing requestId\"}");
                return;
            }
            
            // Get request-specific cart
            int requestIdForCart = Integer.parseInt(requestIdParam);
            String cartKey = "selectedParts_" + requestIdForCart;
            HttpSession session = req.getSession();
            @SuppressWarnings("unchecked")
            List<RepairReportDetail> selectedParts = (List<RepairReportDetail>) session.getAttribute(cartKey);
            
            // Validate contract exists
            if (requestIdParam != null && !requestIdParam.trim().isEmpty()) {
                try {
                    int requestId = Integer.parseInt(requestIdParam);
                    Map<String, Object> customerInfo = getCustomerRequestInfo(requestId);
                    
                    if (customerInfo == null) {
                        resp.getWriter().write("{\"success\":false,\"error\":\"Invalid request or no contract found\"}");
                        return;
                    }
                    
                    // Check if contract exists
                    Object contractId = customerInfo.get("contractId");
                    if (contractId == null) {
                        resp.getWriter().write("{\"success\":false,\"error\":\"This service request has no contract. Parts cannot be added.\"}");
                        return;
                    }
                } catch (SQLException e) {
                    resp.getWriter().write("{\"success\":false,\"error\":\"Database error: \" + e.getMessage()}");
                    return;
                }
            }

            // Initialize selected parts if not exists (request-specific)
            if (selectedParts == null) {
                selectedParts = new ArrayList<>();
                session.setAttribute(cartKey, selectedParts);
            }

            // Get part details (reuse existing logic)
            String sql = "SELECT p.partId, p.partName, p.unitPrice, " +
                        "MIN(pd.partDetailId) as partDetailId, " +
                        "MIN(CASE WHEN pd.status = 'Available' THEN pd.serialNumber END) as serialNumber, " +
                        "MIN(CASE WHEN pd.status = 'Available' THEN pd.location END) as location, " +
                        "COUNT(CASE WHEN pd.status = 'Available' THEN 1 END) as availableQuantity " +
                        "FROM Part p " +
                        "LEFT JOIN PartDetail pd ON p.partId = pd.partId " +
                        "WHERE p.partId = ? AND pd.status = 'Available' " +
                        "GROUP BY p.partId, p.partName, p.unitPrice";

            Map<String, Object> part = null;
            try (var con = new dal.DBContext().connection;
                 var ps = con.prepareStatement(sql)) {
                ps.setInt(1, partId);
                try (var rs = ps.executeQuery()) {
                    if (rs.next()) {
                        part = new LinkedHashMap<>();
                        part.put("partId", rs.getInt("partId"));
                        part.put("partDetailId", rs.getObject("partDetailId"));
                        part.put("partName", rs.getString("partName"));
                        part.put("serialNumber", rs.getString("serialNumber"));
                        part.put("location", rs.getString("location"));
                        part.put("unitPrice", rs.getBigDecimal("unitPrice"));
                        part.put("availableQuantity", rs.getInt("availableQuantity"));
                    }
                }
            }

            if (part == null) {
                resp.getWriter().write("{\"success\":false,\"error\":\"Part not found\"}");
                return;
            }

            int availableQty = ((Number) part.get("availableQuantity")).intValue();
            if (quantity > availableQty) {
                resp.getWriter().write("{\"success\":false,\"error\":\"Insufficient quantity. Available: " + availableQty + "\"}");
                return;
            }

            // Check if part already exists, REPLACE quantity (not add)
            boolean found = false;
            for (RepairReportDetail detail : selectedParts) {
                if (detail.getPartId() == partId) {
                    // Replace quantity (JavaScript sends the total quantity, not delta)
                    if (quantity > availableQty) {
                        resp.getWriter().write("{\"success\":false,\"error\":\"Quantity exceeds available. Available: " + availableQty + "\"}");
                        return;
                    }
                    detail.setQuantity(quantity); // Replace, don't add
                    found = true;
                    break;
                }
            }

            // Add new part if not found
            if (!found) {
                RepairReportDetail detail = new RepairReportDetail();
                detail.setPartId(partId);
                Object partDetailId = part.get("partDetailId");
                if (partDetailId != null) {
                    detail.setPartDetailId(((Number) partDetailId).intValue());
                }
                detail.setQuantity(quantity);
                detail.setUnitPrice((BigDecimal) part.get("unitPrice"));
                detail.setPartName((String) part.get("partName"));
                detail.setSerialNumber((String) part.get("serialNumber"));
                detail.setLocation((String) part.get("location"));
                selectedParts.add(detail);
            }

            BigDecimal subtotal = calculateSubtotal(selectedParts);
            resp.getWriter().write("{\"success\":true,\"subtotal\":" + subtotal + ",\"partsCount\":" + selectedParts.size() + "}");

        } catch (NumberFormatException e) {
            resp.getWriter().write("{\"success\":false,\"error\":\"Invalid partId, quantity, or requestId format\"}");
        } catch (Exception e) {
            e.printStackTrace();
            resp.getWriter().write("{\"success\":false,\"error\":\"" + escapeJsonString(e.getMessage()) + "\"}");
        }
    }

    /**
     * Handle AJAX remove part from cart
     */
    private void handleRemovePartAjax(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        System.out.println("=== handleRemovePartAjax called ===");
        
        try {
            String partIdStr = req.getParameter("partId");
            String requestIdStr = req.getParameter("requestId");
            
            System.out.println("Received partId: '" + partIdStr + "' (type: " + (partIdStr != null ? partIdStr.getClass().getSimpleName() : "null") + ")");
            System.out.println("Received requestId: '" + requestIdStr + "' (type: " + (requestIdStr != null ? requestIdStr.getClass().getSimpleName() : "null") + ")");
            
            if (partIdStr == null || partIdStr.trim().isEmpty()) {
                System.out.println("ERROR: Missing partId");
                resp.getWriter().write("{\"success\":false,\"error\":\"Missing partId\"}");
                return;
            }
            
            if (requestIdStr == null || requestIdStr.trim().isEmpty()) {
                System.out.println("ERROR: Missing requestId");
                resp.getWriter().write("{\"success\":false,\"error\":\"Missing requestId\"}");
                return;
            }

            int partId;
            try {
                partId = Integer.parseInt(partIdStr.trim());
                System.out.println("Parsed partId: " + partId);
            } catch (NumberFormatException e) {
                System.out.println("ERROR: Cannot parse partId '" + partIdStr + "': " + e.getMessage());
                resp.getWriter().write("{\"success\":false,\"error\":\"Invalid partId format: '" + escapeJsonString(partIdStr) + "'\"}");
                return;
            }
            
            // Get request-specific cart
            String cartKey = "selectedParts_" + requestIdStr.trim();
            System.out.println("Cart key: " + cartKey);
            HttpSession session = req.getSession();
            @SuppressWarnings("unchecked")
            List<RepairReportDetail> selectedParts = (List<RepairReportDetail>) session.getAttribute(cartKey);

            System.out.println("Selected parts in cart: " + (selectedParts != null ? selectedParts.size() : "null"));

            if (selectedParts != null) {
                int beforeSize = selectedParts.size();
                System.out.println("Removing part with partId: " + partId);
                selectedParts.removeIf(detail -> detail.getPartId() == partId);
                int afterSize = selectedParts.size();
                System.out.println("Before: " + beforeSize + ", After: " + afterSize);
                
                // Update session
                if (selectedParts.isEmpty()) {
                    session.removeAttribute(cartKey);
                    System.out.println("Cart is now empty, removed from session");
                } else {
                    session.setAttribute(cartKey, selectedParts);
                    System.out.println("Updated cart in session");
                }
                
                BigDecimal subtotal = calculateSubtotal(selectedParts);
                System.out.println("Subtotal: " + subtotal);
                resp.getWriter().write("{\"success\":true,\"subtotal\":" + subtotal + ",\"partsCount\":" + afterSize + "}");
            } else {
                System.out.println("Cart is null, returning success with empty cart");
                resp.getWriter().write("{\"success\":true,\"subtotal\":0,\"partsCount\":0}");
            }

        } catch (NumberFormatException e) {
            System.out.println("NumberFormatException: " + e.getMessage());
            e.printStackTrace();
            resp.getWriter().write("{\"success\":false,\"error\":\"Invalid partId or requestId format: " + escapeJsonString(e.getMessage()) + "\"}");
        } catch (Exception e) {
            System.out.println("Exception: " + e.getMessage());
            e.printStackTrace();
            resp.getWriter().write("{\"success\":false,\"error\":\"" + escapeJsonString(e.getMessage()) + "\"}");
        }
    }

    /**
     * Handle AJAX get cart summary
     */
    private void handleGetCartSummaryAjax(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        try {
            String requestIdStr = req.getParameter("requestId");
            int requestId = Integer.parseInt(requestIdStr);

            // Get customer/request info
            Map<String, Object> customerInfo = getCustomerRequestInfo(requestId);

            // Get selected parts from session (request-specific cart)
            String cartKey = "selectedParts_" + requestId;
            HttpSession session = req.getSession();
            @SuppressWarnings("unchecked")
            List<RepairReportDetail> selectedParts = (List<RepairReportDetail>) session.getAttribute(cartKey);
            if (selectedParts == null) {
                selectedParts = new ArrayList<>();
            }

            BigDecimal subtotal = calculateSubtotal(selectedParts);

            // Build JSON response
            StringBuilder json = new StringBuilder("{");
            json.append("\"success\":true,");

            // Customer info
            if (customerInfo != null) {
                json.append("\"customerInfo\":{");
                json.append("\"customerName\":\"").append(escapeJsonString((String)customerInfo.get("customerName"))).append("\",");
                json.append("\"customerAccountId\":").append(customerInfo.get("customerAccountId")).append(",");
                json.append("\"contractId\":").append(customerInfo.get("contractId") != null ? customerInfo.get("contractId") : "null").append(",");
                json.append("\"requestId\":").append(customerInfo.get("requestId"));
                json.append("},");
            }

            // Parts summary
            json.append("\"partsCount\":").append(selectedParts.size()).append(",");
            json.append("\"subtotal\":").append(subtotal).append(",");
            json.append("\"parts\":[");
            for (int i = 0; i < selectedParts.size(); i++) {
                RepairReportDetail part = selectedParts.get(i);
                if (i > 0) json.append(",");
                json.append("{");
                json.append("\"partId\":").append(part.getPartId()).append(",");
                json.append("\"partName\":\"").append(escapeJsonString(part.getPartName())).append("\",");
                json.append("\"serialNumber\":\"").append(escapeJsonString(part.getSerialNumber() != null ? part.getSerialNumber() : "N/A")).append("\",");
                json.append("\"unitPrice\":").append(part.getUnitPrice()).append(",");
                json.append("\"quantity\":").append(part.getQuantity()).append(",");
                json.append("\"lineTotal\":").append(part.getLineTotal());
                json.append("}");
            }
            json.append("]");
            json.append("}");

            resp.getWriter().write(json.toString());

        } catch (Exception e) {
            resp.getWriter().write("{\"success\":false,\"error\":\"" + e.getMessage() + "\"}");
        }
    }

    /**
     * Handle AJAX clear cart
     */
    private void handleClearCartAjax(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        
        try {
            String requestIdStr = req.getParameter("requestId");
            HttpSession session = req.getSession();
            
            if (requestIdStr != null && !requestIdStr.trim().isEmpty()) {
                // Clear specific request's cart
                String cartKey = "selectedParts_" + requestIdStr;
                session.removeAttribute(cartKey);
            }
            
            resp.getWriter().write("{\"success\":true,\"subtotal\":0,\"partsCount\":0}");
        } catch (Exception e) {
            resp.getWriter().write("{\"success\":false,\"error\":\"" + e.getMessage() + "\"}");
        }
    }
    
    /**
     * Handle AJAX get customer contracts
     */
    private void handleGetCustomerContractsAjax(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        
        try {
            String requestIdStr = req.getParameter("requestId");
            if (requestIdStr == null || requestIdStr.trim().isEmpty()) {
                resp.getWriter().write("{\"success\":false,\"error\":\"Missing requestId\"}");
                return;
            }
            
            int requestId = Integer.parseInt(requestIdStr);
            
            // Get customer info from request
            Map<String, Object> customerInfo = getCustomerRequestInfo(requestId);
            if (customerInfo == null) {
                resp.getWriter().write("{\"success\":false,\"error\":\"Request not found\"}");
                return;
            }
            
            int customerAccountId = (Integer) customerInfo.get("customerAccountId");
            List<Map<String, Object>> contracts = getCustomerContracts(customerAccountId);
            
            // Build JSON response
            StringBuilder json = new StringBuilder("{");
            json.append("\"success\":true,");
            json.append("\"contracts\":[");
            
            for (int i = 0; i < contracts.size(); i++) {
                Map<String, Object> contract = contracts.get(i);
                if (i > 0) json.append(",");
                json.append("{");
                json.append("\"contractId\":").append(contract.get("contractId")).append(",");
                json.append("\"contractType\":\"").append(escapeJsonString((String)contract.get("contractType"))).append("\",");
                json.append("\"startDate\":\"").append(contract.get("startDate")).append("\",");
                json.append("\"endDate\":\"").append(contract.get("endDate")).append("\",");
                json.append("\"status\":\"").append(escapeJsonString((String)contract.get("status"))).append("\",");
                json.append("\"totalValue\":").append(contract.get("totalValue"));
                json.append("}");
            }
            
            json.append("]}");
            resp.getWriter().write(json.toString());
            
        } catch (SQLException e) {
            resp.getWriter().write("{\"success\":false,\"error\":\"Database error: " + escapeJsonString(e.getMessage()) + "\"}");
        } catch (Exception e) {
            resp.getWriter().write("{\"success\":false,\"error\":\"" + escapeJsonString(e.getMessage()) + "\"}");
        }
    }

    /**
     * Handle AJAX check for existing repair report
     */
    private void handleCheckExistingReportAjax(HttpServletRequest req, HttpServletResponse resp, int technicianId) throws IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        
        try {
            String requestIdStr = req.getParameter("requestId");
            if (requestIdStr == null || requestIdStr.trim().isEmpty()) {
                resp.getWriter().write("{\"exists\":false,\"error\":\"Missing requestId\"}");
                return;
            }
            
            int requestId = Integer.parseInt(requestIdStr);
            
            RepairReportDAO reportDAO = new RepairReportDAO();
            RepairReport existingReport = reportDAO.findByRequestIdAndTechnician(requestId, technicianId);
            
            if (existingReport != null) {
                resp.getWriter().write("{\"exists\":true,\"reportId\":" + existingReport.getReportId() + "}");
            } else {
                resp.getWriter().write("{\"exists\":false}");
            }
        } catch (NumberFormatException e) {
            resp.getWriter().write("{\"exists\":false,\"error\":\"Invalid requestId format\"}");
        } catch (SQLException e) {
            e.printStackTrace();
            System.err.println("SQLException in handleCheckExistingReportAjax: " + e.getMessage());
            resp.setStatus(500);
            resp.getWriter().write("{\"exists\":false,\"error\":\"Database error: " + escapeJsonString(e.getMessage()) + "\"}");
        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("Exception in handleCheckExistingReportAjax: " + e.getMessage());
            resp.setStatus(500);
            resp.getWriter().write("{\"exists\":false,\"error\":\"Error: " + escapeJsonString(e.getMessage()) + "\"}");
        }
    }
    
    /**
     * Helper method to escape JSON strings
     */
    private String escapeJsonString(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}
