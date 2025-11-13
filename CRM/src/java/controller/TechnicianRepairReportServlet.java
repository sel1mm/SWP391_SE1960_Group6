package controller;

import dal.RepairReportDAO;
import dal.WorkTaskDAO;
import dal.ServiceRequestDAO;
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
 * Servlet for handling technician repair report operations. Handles CRUD
 * operations for RepairReport table.
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
        String scheduleIdParam = req.getParameter("scheduleId");

        int technicianId = sessionId.intValue();
        try (RepairReportDAO reportDAO = new RepairReportDAO();
                ServiceRequestDAO serviceRequestDAO = new ServiceRequestDAO()) {

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
                try (WorkTaskDAO workTaskDAO = new WorkTaskDAO()) {
                    // Show create form with assigned tasks dropdown
                    List<WorkTaskDAO.WorkTaskForReport> assignedTasks = workTaskDAO.getAssignedTasksForReport(technicianId);

                    Integer requestId = null;
                    Integer scheduleId = null;
                    String selectedRequestType = null;

                    // 1) If scheduleId is provided, derive effective requestId from MaintenanceSchedule
                    if (scheduleIdParam != null && !scheduleIdParam.trim().isEmpty()) {
                        try {
                            scheduleId = Integer.parseInt(scheduleIdParam);
                            Integer effectiveReqId = getEffectiveRequestIdForSchedule(scheduleId);
                            // For schedule-origin, allow no linked ServiceRequest. Use effectiveReqId if available.
                            requestId = effectiveReqId;

                            // Validate assignment for schedule/request context
                            // If we have an effective request, reuse assignment/completion checks by request
                            if (requestId != null) {
                                if (!workTaskDAO.isTechnicianAssignedToRequest(technicianId, requestId)) {
                                    req.setAttribute("error", "Bạn không được giao công việc đã lên lịch này");
                                    doGetReportList(req, resp, technicianId);
                                    return;
                                }
                                if (workTaskDAO.isTechnicianTaskCompleted(technicianId, requestId)) {
                                    req.setAttribute("error", "Không thể tạo báo cáo cho công việc đã hoàn thành");
                                    doGetReportList(req, resp, technicianId);
                                    return;
                                }
                            }
                            // Duplicate check by schedule (preferred)
                            try {
                                RepairReport existingReportBySchedule = reportDAO.findByScheduleIdAndTechnician(scheduleId, technicianId);
                                if (existingReportBySchedule != null) {
                                    resp.sendRedirect(req.getContextPath() + "/technician/reports?action=edit&reportId=" + existingReportBySchedule.getReportId());
                                    return;
                                }
                            } catch (SQLException ex) {
                                System.err.println("Duplicate check by schedule failed: " + ex.getMessage());
                            }

                            // Set UI context for schedule-origin (maintenance)
                            req.setAttribute("origin", "Schedule");
                            req.setAttribute("isScheduleOrigin", true);
                            req.setAttribute("selectedRequestType", "Maintenance");

                            // Load schedule's customer info for display (via Contract -> Account)
                            try {
                                Map<String, Object> schedCustomer = getScheduleCustomerInfo(scheduleId);
                                if (schedCustomer != null) {
                                    req.setAttribute("scheduleCustomerId", schedCustomer.get("customerAccountId"));
                                    req.setAttribute("scheduleCustomerName", schedCustomer.get("customerName"));
                                }
                                String taskStatus = getScheduleTaskStatus(technicianId, scheduleId);
                                if (taskStatus != null) {
                                    req.setAttribute("scheduleTaskStatus", taskStatus);
                                }
                            } catch (SQLException ex) {
                                System.err.println("Error loading schedule customer info: " + ex.getMessage());
                            }
                        } catch (NumberFormatException e) {
                            req.setAttribute("error", "Mã lịch trình không hợp lệ");
                            doGetReportList(req, resp, technicianId);
                            return;
                        }
                    }

                    // 2) If requestId provided explicitly (request-origin)
                    if (requestId == null && requestIdParam != null && !requestIdParam.trim().isEmpty()) {
                        try {
                            requestId = Integer.parseInt(requestIdParam);
                            // Validate that technician is assigned to this request
                            if (!workTaskDAO.isTechnicianAssignedToRequest(technicianId, requestId)) {
                                req.setAttribute("error", "Bạn không được giao yêu cầu này");
                                doGetReportList(req, resp, technicianId);
                                return;
                            }
                            // Check if this technician's task is completed
                            if (workTaskDAO.isTechnicianTaskCompleted(technicianId, requestId)) {
                                req.setAttribute("error", "Không thể tạo báo cáo cho công việc đã hoàn thành");
                                doGetReportList(req, resp, technicianId);
                                return;
                            }
                            // Check if a repair report already exists for this requestId by this technician
                            try {
                                RepairReport existingReport = reportDAO.findByRequestIdAndTechnician(requestId, technicianId);
                                if (existingReport != null) {
                                    // Report already exists, redirect to edit instead
                                    req.setAttribute("info", "Đã tồn tại báo cáo sửa chữa cho công việc này. Đang chuyển hướng đến chỉnh sửa...");
                                    resp.sendRedirect(req.getContextPath() + "/technician/reports?action=edit&reportId=" + existingReport.getReportId());
                                    return;
                                }
                            } catch (SQLException e) {
                                // Log error but continue - allow creation if check fails
                                System.err.println("Error checking for existing report: " + e.getMessage());
                            }

                            var serviceRequest = serviceRequestDAO.getRequestById(requestId);
                            if (serviceRequest != null) {
                                selectedRequestType = serviceRequest.getRequestType();
                            }
                        } catch (NumberFormatException e) {
                            req.setAttribute("error", "Mã yêu cầu không hợp lệ");
                            doGetReportList(req, resp, technicianId);
                            return;
                        }
                    }

                    // Load all available parts for dropdown
                    List<Map<String, Object>> availableParts = null;
                    try {
                        availableParts = getAllAvailableParts();
                    } catch (SQLException e) {
                        req.setAttribute("error", "Lỗi khi tải linh kiện: " + e.getMessage());
                        availableParts = new ArrayList<>();
                    }

                    // Get selected parts from session (scoped to this request)
                    String cartKey = (scheduleId != null)
                            ? ("selectedParts_schedule_" + scheduleId)
                            : ("selectedParts_" + (requestId != null ? requestId : "new"));
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
                    if (scheduleId != null) {
                        req.setAttribute("scheduleId", scheduleId);
                    }
                    req.setAttribute("assignedTasks", assignedTasks);
                    req.setAttribute("availableParts", availableParts);
                    req.setAttribute("selectedParts", selectedParts);
                    req.setAttribute("subtotal", subtotal);
                    req.setAttribute("customerRequestInfo", customerRequestInfo);
                    req.setAttribute("customerContracts", customerContracts);
                    req.setAttribute("selectedRequestType", selectedRequestType);
                    req.setAttribute("isWarrantyRequest", "Warranty".equalsIgnoreCase(selectedRequestType));
                    req.setAttribute("pageTitle", "Create Repair Report");
                    req.setAttribute("contentView", "/WEB-INF/technician/report-form.jsp");
                    req.setAttribute("activePage", "reports");
                    req.getRequestDispatcher("/WEB-INF/technician/technician-layout.jsp").forward(req, resp);
                }

            } else if ("edit".equals(action) && reportIdParam != null) {
                // Show edit form
                int reportId = Integer.parseInt(reportIdParam);
                RepairReport report = reportDAO.findById(reportId);

                if (report == null) {
                    req.setAttribute("error", "Không tìm thấy báo cáo");
                    doGetReportList(req, resp, technicianId);
                    return;
                }

                // Verify report belongs to this technician
                if (report.getTechnicianId() == null || report.getTechnicianId() != technicianId) {
                    req.setAttribute("error", "Không tìm thấy báo cáo hoặc báo cáo không được giao cho bạn");
                    doGetReportList(req, resp, technicianId);
                    return;
                }

                // Verify WorkTask is still assigned to this technician
                try (WorkTaskDAO workTaskDAO = new WorkTaskDAO()) {
                    if (!workTaskDAO.isTechnicianAssignedToRequest(technicianId, report.getRequestId())) {
                        req.setAttribute("error", "Bạn không còn được giao công việc này");
                        doGetReportList(req, resp, technicianId);
                        return;
                    }
                } catch (SQLException e) {
                    req.setAttribute("error", "Lỗi khi xác thực phân công công việc: " + e.getMessage());
                    doGetReportList(req, resp, technicianId);
                    return;
                }

                String selectedRequestType = null;
                var serviceRequest = serviceRequestDAO.getRequestById(report.getRequestId());
                if (serviceRequest != null) {
                    selectedRequestType = serviceRequest.getRequestType();
                }

                // Check if report can be edited (status must be Pending)
                try {
                    if (!reportDAO.canTechnicianEditReport(reportId, technicianId)) {
                        req.setAttribute("error", "Báo cáo này không thể chỉnh sửa (trạng thái báo giá không phải là Đang chờ)");
                        doGetReportList(req, resp, technicianId);
                        return;
                    }
                } catch (SQLException e) {
                    req.setAttribute("error", "Lỗi khi kiểm tra quyền chỉnh sửa: " + e.getMessage());
                    doGetReportList(req, resp, technicianId);
                    return;
                }

                // Load report details (parts) and put them in session for the cart
                List<RepairReportDetail> reportDetails = reportDAO.getReportDetails(reportId);
                Integer repScheduleId = report.getScheduleId();
                String cartKey = repScheduleId != null
                        ? "selectedParts_schedule_" + repScheduleId
                        : "selectedParts_" + report.getRequestId();
                req.getSession().setAttribute(cartKey, reportDetails);

                // Load available parts for the form
                List<Map<String, Object>> availableParts = null;
                try {
                    availableParts = getAllAvailableParts();
                } catch (SQLException e) {
                    req.setAttribute("error", "Lỗi khi tải linh kiện: " + e.getMessage());
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
                req.setAttribute("pageTitle", "Chỉnh sửa báo cáo sửa chữa");
                req.setAttribute("contentView", "/WEB-INF/technician/report-form.jsp");
                req.setAttribute("activePage", "reports");
                req.setAttribute("selectedRequestType", selectedRequestType);
                req.setAttribute("isWarrantyRequest", "Warranty".equalsIgnoreCase(selectedRequestType));
                req.getRequestDispatcher("/WEB-INF/technician/technician-layout.jsp").forward(req, resp);

            } else if ("detail".equals(action) && reportIdParam != null) {
                // Show report detail
                int reportId = Integer.parseInt(reportIdParam);
                RepairReport report = reportDAO.findById(reportId);

                if (report != null && report.getTechnicianId() != null && report.getTechnicianId() == technicianId) {
                    // Load report details (parts)
                    List<RepairReportDetail> details = reportDAO.getReportDetails(reportId);
                    Map<String, Object> customerRequestInfo = null;
                    String detailRequestType = null;
                    boolean detailIsWarranty = false;
                    try {
                        customerRequestInfo = getCustomerRequestInfo(report.getRequestId());
                        if (customerRequestInfo != null) {
                            detailRequestType = (String) customerRequestInfo.get("requestType");
                            if (detailRequestType != null) {
                                detailIsWarranty = "Warranty".equalsIgnoreCase(detailRequestType);
                            }
                        }
                    } catch (SQLException e) {
                        System.err.println("Error loading customer info for detail view: " + e.getMessage());
                    }
                    BigDecimal detailSubtotal = calculateSubtotal(details);
                    req.setAttribute("report", report);
                    req.setAttribute("reportDetails", details);
                    req.setAttribute("customerRequestInfo", customerRequestInfo);
                    req.setAttribute("selectedRequestType", detailRequestType);
                    req.setAttribute("isWarrantyRequest", detailIsWarranty);
                    req.setAttribute("subtotal", detailSubtotal);
                    req.setAttribute("pageTitle", "Chi tiết báo cáo sửa chữa");
                    req.setAttribute("contentView", "/WEB-INF/technician/report-detail.jsp");
                    req.setAttribute("activePage", "reports");
                    req.getRequestDispatcher("/WEB-INF/technician/technician-layout.jsp").forward(req, resp);
                } else {
                    req.setAttribute("error", "Không tìm thấy báo cáo hoặc báo cáo không được giao cho bạn");
                    doGetReportList(req, resp, technicianId);
                }

            } else {
                // Show report list
                doGetReportList(req, resp, technicianId);
            }

        } catch (SQLException e) {
            throw new ServletException("Database error: " + e.getMessage(), e);
        } catch (NumberFormatException e) {
            req.setAttribute("error", "Tham số ID không hợp lệ");
            doGetReportList(req, resp, sessionId.intValue());
        }
    }

    private void doGetReportList(HttpServletRequest req, HttpServletResponse resp, int technicianId)
            throws ServletException, IOException {
        try (RepairReportDAO reportDAO = new RepairReportDAO()) {
            String searchQuery = sanitize(req.getParameter("q"));
            String statusFilter = sanitize(req.getParameter("status"));
            int page = parseInt(req.getParameter("page"), 1);
            int pageSize = Math.min(parseInt(req.getParameter("pageSize"), 10), 100);

            List<RepairReportDAO.RepairReportWithCustomer> reportsWithCustomer = reportDAO.getRepairReportsForTechnicianWithCustomer(technicianId, searchQuery, statusFilter, page, pageSize);
            int totalReports = reportDAO.getRepairReportCountForTechnicianWithCustomer(technicianId, statusFilter);

            req.setAttribute("reportsWithCustomer", reportsWithCustomer);
            req.setAttribute("totalReports", totalReports);
            req.setAttribute("currentPage", page);
            req.setAttribute("pageSize", pageSize);
            req.setAttribute("totalPages", (int) Math.ceil((double) totalReports / pageSize));
            req.setAttribute("pageTitle", "Báo cáo sửa chữa của tôi");
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

        int technicianId = sessionId.intValue();
        try (RepairReportDAO reportDAO = new RepairReportDAO();
                ServiceRequestDAO serviceRequestDAO = new ServiceRequestDAO()) {

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
                String scheduleIdStr = req.getParameter("scheduleId");
                HttpSession httpSession = req.getSession();
                if (requestIdStr != null && !requestIdStr.trim().isEmpty()) {
                    httpSession.removeAttribute("selectedParts_" + requestIdStr.trim());
                }
                if (scheduleIdStr != null && !scheduleIdStr.trim().isEmpty()) {
                    httpSession.removeAttribute("selectedParts_schedule_" + scheduleIdStr.trim());
                }
                StringBuilder redirect = new StringBuilder(req.getContextPath()).append("/technician/reports?action=create");
                if (scheduleIdStr != null && !scheduleIdStr.trim().isEmpty()) {
                    redirect.append("&scheduleId=").append(scheduleIdStr.trim());
                } else if (requestIdStr != null && !requestIdStr.trim().isEmpty()) {
                    redirect.append("&requestId=").append(requestIdStr.trim());
                }
                resp.sendRedirect(redirect.toString());
                return;
            }

            if ("create".equals(action)) {
                try (WorkTaskDAO workTaskDAO = new WorkTaskDAO()) {
                    RepairReport report = new RepairReport();
                    String requestIdStr = req.getParameter("requestId");
                    String scheduleIdStr = req.getParameter("scheduleId");

                    Integer requestId = null;
                    Integer scheduleId = null;

                    // Accept either scheduleId (schedule-origin) or requestId (request-origin)
                    if (scheduleIdStr != null && !scheduleIdStr.trim().isEmpty()) {
                        try {
                            scheduleId = Integer.parseInt(scheduleIdStr);
                            Integer effectiveReqId = getEffectiveRequestIdForSchedule(scheduleId);
                            if (effectiveReqId == null) {
                                req.setAttribute("error", "Lịch trình này không được liên kết với bất kỳ Yêu cầu Dịch vụ nào.");
                                doGet(req, resp);
                                return;
                            }
                            requestId = effectiveReqId;
                        } catch (NumberFormatException e) {
                            req.setAttribute("error", "Mã lịch trình không hợp lệ");
                            doGet(req, resp);
                            return;
                        }
                    } else {
                        // Validate request ID (request-origin)
                        if (requestIdStr == null || requestIdStr.trim().isEmpty()) {
                            req.setAttribute("error", "Mã yêu cầu là bắt buộc");
                            doGet(req, resp);
                            return;
                        }
                        try {
                            requestId = Integer.parseInt(requestIdStr);
                        } catch (NumberFormatException e) {
                            req.setAttribute("error", "Mã yêu cầu không hợp lệ");
                            doGet(req, resp);
                            return;
                        }
                    }

                    // Validate technician assignment and task status
                    if (!workTaskDAO.isTechnicianAssignedToRequest(technicianId, requestId)) {
                        req.setAttribute("error", "Bạn không được giao yêu cầu này");
                        doGet(req, resp);
                        return;
                    }

                    if (workTaskDAO.isTechnicianTaskCompleted(technicianId, requestId)) {
                        req.setAttribute("error", "Không thể tạo báo cáo cho công việc đã hoàn thành");
                        doGet(req, resp);
                        return;
                    }

                    // Check if a repair report already exists for this requestId by this technician
                    try {
                        RepairReport existingReport = null;
                        if (scheduleId != null) {
                            existingReport = reportDAO.findByScheduleIdAndTechnician(scheduleId, technicianId);
                        }
                        if (existingReport == null) {
                            existingReport = reportDAO.findByRequestIdAndTechnician(requestId, technicianId);
                        }
                        if (existingReport != null) {
                            req.setAttribute("error", "Đã tồn tại báo cáo sửa chữa cho công việc này. Đang chuyển hướng đến chỉnh sửa...");
                            resp.sendRedirect(req.getContextPath() + "/technician/reports?action=edit&reportId=" + existingReport.getReportId());
                            return;
                        }
                    } catch (SQLException e) {
                        req.setAttribute("error", "Lỗi khi kiểm tra báo cáo hiện có: " + e.getMessage());
                        doGet(req, resp);
                        return;
                    }

                    String requestType = null;
                    boolean isWarranty = false;
                    if (requestId != null) {
                        var serviceRequest = serviceRequestDAO.getRequestById(requestId);
                        if (serviceRequest != null) {
                            requestType = serviceRequest.getRequestType();
                            isWarranty = "Warranty".equalsIgnoreCase(requestType);
                        }
                    }

                    // ✅ THÊM: Kiểm tra warranty eligibility
                    String notEligibleParam = req.getParameter("notEligibleForWarranty");
                    boolean isNotEligibleForWarranty = "true".equalsIgnoreCase(notEligibleParam);

                    report.setRequestId(requestId);
                    if (scheduleId != null) {
                        report.setScheduleId(scheduleId);
                        report.setOrigin("Schedule");
                    } else {
                        report.setOrigin("ServiceRequest");
                    }
                    report.setTechnicianId(technicianId);
                    report.setDetails(req.getParameter("details"));
                    report.setDiagnosis(""); // Parts are stored in RepairReportDetail

                    if (isWarranty && isNotEligibleForWarranty) {
                        report.setInspectionResult("NotEligible");
                        report.setQuotationStatus("Rejected"); // Auto-reject
                    } else {
                        report.setInspectionResult("Eligible");
                        report.setQuotationStatus("Pending");
                    }

                    // Get selected parts from session (scoped to this request)
                    String cartKey = scheduleId != null
                            ? "selectedParts_schedule_" + scheduleId
                            : "selectedParts_" + report.getRequestId();
                    @SuppressWarnings("unchecked")
                    List<RepairReportDetail> parts = (List<RepairReportDetail>) req.getSession().getAttribute(cartKey);
                    if (parts == null) {
                        parts = new ArrayList<>();
                    }

                    List<String> validationErrors = new ArrayList<>();
                    if (!(isWarranty && isNotEligibleForWarranty)) {
                        validationErrors.addAll(validateRepairReportInput(req, false, parts, isWarranty));
                    }

                    // Calculate estimated cost (VND -> USD) unless warranty/maintenance
                    BigDecimal estimatedCost;
                    if (scheduleId != null) {
                        estimatedCost = BigDecimal.ZERO;
                    } else if (isWarranty) {
                        estimatedCost = BigDecimal.ZERO;
                    } else {
                        String estimatedCostStr = req.getParameter("estimatedCost");
                        if (estimatedCostStr != null && !estimatedCostStr.trim().isEmpty()) {
                            try {
                                BigDecimal vndValue = new BigDecimal(estimatedCostStr);
                                BigDecimal usdValue = vndValue.divide(new BigDecimal("26000"), 2, java.math.RoundingMode.HALF_UP);
                                estimatedCost = usdValue;
                            } catch (NumberFormatException e) {
                                validationErrors.add("Định dạng chi phí ước tính không hợp lệ");
                                estimatedCost = calculateTotalFromParts(parts);
                            }
                        } else {
                            estimatedCost = calculateTotalFromParts(parts);
                        }
                    }
                    report.setEstimatedCost(estimatedCost);
                    report.setRepairDate(LocalDate.parse(req.getParameter("repairDate")));
                    if (isWarranty && isNotEligibleForWarranty) {
                        report.setQuotationStatus("Rejected");
                    } else {
                        report.setQuotationStatus("Pending");
                    }

                    if (!validationErrors.isEmpty()) {
                        req.setAttribute("validationErrors", validationErrors);
                        req.setAttribute("requestId", report.getRequestId());
                        req.setAttribute("selectedRequestType", scheduleId != null ? "Maintenance" : requestType);
                        req.setAttribute("isWarrantyRequest", isWarranty);
                        req.setAttribute("selectedParts", parts);
                        if (scheduleId != null) {
                            req.setAttribute("scheduleId", scheduleId);
                            req.setAttribute("origin", "Schedule");
                            req.setAttribute("isScheduleOrigin", true);
                            try {
                                Map<String, Object> schedCustomer = getScheduleCustomerInfo(scheduleId);
                                if (schedCustomer != null) {
                                    req.setAttribute("scheduleCustomerId", schedCustomer.get("customerAccountId"));
                                    req.setAttribute("scheduleCustomerName", schedCustomer.get("customerName"));
                                }
                                String taskStatus = getScheduleTaskStatus(technicianId, scheduleId);
                                if (taskStatus != null) {
                                    req.setAttribute("scheduleTaskStatus", taskStatus);
                                }
                            } catch (SQLException ex) {
                                System.err.println("Error loading schedule info: " + ex.getMessage());
                            }
                        } else {
                            req.setAttribute("isScheduleOrigin", false);
                        }
                        try {
                            req.setAttribute("availableParts", getAllAvailableParts());
                        } catch (SQLException e) {
                            req.setAttribute("availableParts", new ArrayList<Map<String, Object>>());
                            req.setAttribute("error", "Lỗi khi tải linh kiện: " + e.getMessage());
                        }
                        req.setAttribute("subtotal", calculateSubtotal(parts));
                        Map<String, Object> customerRequestInfo = null;
                        List<Map<String, Object>> customerContracts = new ArrayList<>();
                        try {
                            customerRequestInfo = getCustomerRequestInfo(report.getRequestId());
                            if (customerRequestInfo != null) {
                                Integer customerAccountId = (Integer) customerRequestInfo.get("customerAccountId");
                                if (customerAccountId != null) {
                                    customerContracts = getCustomerContracts(customerAccountId);
                                }
                            }
                        } catch (SQLException e) {
                            System.err.println("Error loading customer info: " + e.getMessage());
                        }
                        req.setAttribute("customerRequestInfo", customerRequestInfo);
                        req.setAttribute("customerContracts", customerContracts);
                        req.setAttribute("partsSearchQuery", req.getSession().getAttribute("partsSearchQuery"));
                        req.setAttribute("partsSearchResults", req.getSession().getAttribute("partsSearchResults"));
                        List<WorkTaskDAO.WorkTaskForReport> assignedTasks = workTaskDAO.getAssignedTasksForReport(technicianId);
                        req.setAttribute("assignedTasks", assignedTasks);
                        req.setAttribute("pageTitle", "Tạo báo cáo sửa chữa");
                        req.setAttribute("contentView", "/WEB-INF/technician/report-form.jsp");
                        req.setAttribute("activePage", "reports");
                        req.getRequestDispatcher("/WEB-INF/technician/technician-layout.jsp").forward(req, resp);
                        return;
                    }

                    int reportId = reportDAO.insertReportWithDetails(report, parts);
                    if (reportId > 0) {
                        if (isWarranty && isNotEligibleForWarranty) {
                            try {
                                workTaskDAO.completeTaskForRequest(technicianId, requestId);
                                boolean allRejected = reportDAO.areAllWarrantyReportsRejected(requestId);
                                if (allRejected) {
                                    serviceRequestDAO.updateRequestStatus(requestId, "Rejected");
                                    System.out.println("✓ All technicians rejected warranty - Request " + requestId + " marked as Rejected");
                                } else {
                                    System.out.println("✓ This technician rejected warranty, but request " + requestId
                                            + " remains open (other technicians may approve)");
                                }
                                System.out.println("✓ Warranty inspection: Not Eligible - Request rejected, Task completed");
                            } catch (SQLException e) {
                                System.err.println("Error updating task/request status: " + e.getMessage());
                            }
                        }
                        req.getSession().removeAttribute(cartKey);
                        req.getSession().setAttribute("successMessage", "Báo cáo sửa chữa đã được gửi thành công ✅");
                        resp.sendRedirect(req.getContextPath() + "/technician/reports");
                    } else {
                        req.setAttribute("error", "Không thể tạo báo cáo sửa chữa");
                        doGet(req, resp);
                    }
                }

            } else if ("update".equals(action)) {
                // Update existing report
                int reportId = Integer.parseInt(req.getParameter("reportId"));

                // Get existing report data first
                RepairReport existingReport = reportDAO.findById(reportId);
                if (existingReport == null) {
                    req.setAttribute("error", "Không tìm thấy báo cáo");
                    doGet(req, resp);
                    return;
                }

                // Verify report belongs to this technician
                if (existingReport.getTechnicianId() == null || existingReport.getTechnicianId() != technicianId) {
                    req.setAttribute("error", "Không tìm thấy báo cáo hoặc báo cáo không được giao cho bạn");
                    doGet(req, resp);
                    return;
                }

                // Verify WorkTask is still assigned to this technician
                try (WorkTaskDAO workTaskDAO = new WorkTaskDAO()) {
                    try {
                        if (!workTaskDAO.isTechnicianAssignedToRequest(technicianId, existingReport.getRequestId())) {
                            req.setAttribute("error", "Bạn không còn được giao công việc này");
                            doGet(req, resp);
                            return;
                        }
                    } catch (SQLException e) {
                        req.setAttribute("error", "Lỗi khi xác thực phân công công việc: " + e.getMessage());
                        doGet(req, resp);
                        return;
                    }

                    // Check if report can be edited (status must be Pending)
                    try {
                        if (!reportDAO.canTechnicianEditReport(reportId, technicianId)) {
                            req.setAttribute("error", "Báo cáo này không thể chỉnh sửa (trạng thái báo giá không phải là Đang chờ)");
                            doGet(req, resp);
                            return;
                        }
                    } catch (SQLException e) {
                        req.setAttribute("error", "Lỗi khi kiểm tra quyền chỉnh sửa: " + e.getMessage());
                        doGet(req, resp);
                        return;
                    }

                    String requestType = null;
                    boolean isWarranty = false;
                    var serviceRequest = serviceRequestDAO.getRequestById(existingReport.getRequestId());
                    if (serviceRequest != null) {
                        requestType = serviceRequest.getRequestType();
                        isWarranty = "Warranty".equalsIgnoreCase(requestType);
                    }

                    RepairReport report = new RepairReport();
                    report.setReportId(reportId);
                    report.setRequestId(existingReport.getRequestId());
                    report.setTechnicianId(technicianId);
                    report.setDetails(req.getParameter("details"));
                    report.setDiagnosis("");

                    String cartKey = existingReport.getScheduleId() != null
                            ? "selectedParts_schedule_" + existingReport.getScheduleId()
                            : "selectedParts_" + existingReport.getRequestId();
                    @SuppressWarnings("unchecked")
                    List<RepairReportDetail> parts = (List<RepairReportDetail>) req.getSession().getAttribute(cartKey);
                    if (parts == null || parts.isEmpty()) {
                        parts = reportDAO.getReportDetails(reportId);
                    }

                    BigDecimal estimatedCost;
                    if (isWarranty) {
                        estimatedCost = BigDecimal.ZERO;
                    } else {
                        String estimatedCostStr = req.getParameter("estimatedCost");
                        if (estimatedCostStr != null && !estimatedCostStr.trim().isEmpty()) {
                            try {
                                BigDecimal vndValue = new BigDecimal(estimatedCostStr);
                                BigDecimal usdValue = vndValue.divide(new BigDecimal("26000"), 2, java.math.RoundingMode.HALF_UP);
                                estimatedCost = usdValue;
                            } catch (NumberFormatException e) {
                                estimatedCost = calculateTotalFromParts(parts);
                            }
                        } else {
                            estimatedCost = calculateTotalFromParts(parts);
                        }
                    }
                    report.setEstimatedCost(estimatedCost);
                    report.setRepairDate(existingReport.getRepairDate());
                    report.setQuotationStatus("Pending");

                    List<String> validationErrors = validateRepairReportInput(req, true, parts, isWarranty);
                    if (!validationErrors.isEmpty()) {
                        req.setAttribute("validationErrors", validationErrors);
                        req.setAttribute("report", report);
                        req.setAttribute("selectedRequestType", requestType);
                        req.setAttribute("isWarrantyRequest", isWarranty);
                        req.setAttribute("selectedParts", parts);
                        req.setAttribute("subtotal", calculateSubtotal(parts));
                        try {
                            req.setAttribute("availableParts", getAllAvailableParts());
                        } catch (SQLException e) {
                            req.setAttribute("availableParts", new ArrayList<Map<String, Object>>());
                        }
                        Map<String, Object> customerRequestInfo = null;
                        List<Map<String, Object>> customerContracts = new ArrayList<>();
                        try {
                            customerRequestInfo = getCustomerRequestInfo(report.getRequestId());
                            if (customerRequestInfo != null) {
                                Integer customerAccountId = (Integer) customerRequestInfo.get("customerAccountId");
                                if (customerAccountId != null) {
                                    customerContracts = getCustomerContracts(customerAccountId);
                                }
                            }
                        } catch (SQLException e) {
                            System.err.println("Error loading customer info: " + e.getMessage());
                        }
                        req.setAttribute("customerRequestInfo", customerRequestInfo);
                        req.setAttribute("customerContracts", customerContracts);
                        req.setAttribute("partsSearchQuery", req.getSession().getAttribute("partsSearchQuery"));
                        req.setAttribute("partsSearchResults", req.getSession().getAttribute("partsSearchResults"));
                        req.setAttribute("pageTitle", "Edit Repair Report");
                        req.setAttribute("contentView", "/WEB-INF/technician/report-form.jsp");
                        req.setAttribute("activePage", "reports");
                        req.getRequestDispatcher("/WEB-INF/technician/technician-layout.jsp").forward(req, resp);
                        return;
                    }

                    boolean updated = reportDAO.updateRepairReport(report);
                    if (updated) {
                        req.getSession().removeAttribute(cartKey);
                        req.setAttribute("success", "Báo cáo sửa chữa đã được cập nhật thành công");
                        resp.sendRedirect(req.getContextPath() + "/technician/reports?action=detail&reportId=" + reportId);
                    } else {
                        req.setAttribute("error", "Không thể cập nhật báo cáo sửa chữa");
                        doGet(req, resp);
                    }
                }

            } else {
                req.setAttribute("error", "Hành động không hợp lệ");
                doGet(req, resp);
            }

        } catch (SQLException e) {
            throw new ServletException("Database error: " + e.getMessage(), e);
        } catch (NumberFormatException e) {
            req.setAttribute("error", "Giá trị số không hợp lệ");
            doGet(req, resp);
        } catch (DateTimeParseException e) {
            req.setAttribute("error", "Định dạng ngày không hợp lệ");
            doGet(req, resp);
        }
    }

    /**
     * Parse parts arrays from request parameters. Expected format: partId[],
     * partDetailId[], quantity[], unitPrice[]
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

    private List<String> validateRepairReportInput(HttpServletRequest req, boolean isEditMode, List<RepairReportDetail> parts, boolean isWarranty) {
        List<String> errors = new ArrayList<>();

        // Validate details
        TechnicianValidator.ValidationResult detailsResult = TechnicianValidator.validateDetails(req.getParameter("details"));
        if (!detailsResult.isValid()) {
            errors.addAll(detailsResult.getErrors());
        }

        // Validate parts (replaces diagnosis validation)
        if ((parts == null || parts.isEmpty()) && !isWarranty) {
            errors.add("Vui lòng chọn ít nhất một linh kiện");
        } else if (parts != null && !parts.isEmpty()) {
            try (PartDetailDAO partDetailDAO = new PartDetailDAO()) {
                for (RepairReportDetail part : parts) {
                    // Validate partId exists
                    if (part.getPartId() <= 0) {
                        errors.add("Mã linh kiện không hợp lệ");
                        continue;
                    }

                    // Validate quantity
                    if (part.getQuantity() <= 0) {
                        errors.add("Số lượng phải lớn hơn 0 cho linh kiện có ID " + part.getPartId());
                    }

                    // Validate unit price
                    if (part.getUnitPrice() == null || part.getUnitPrice().compareTo(BigDecimal.ZERO) < 0) {
                        errors.add("Đơn giá phải lớn hơn hoặc bằng 0 cho linh kiện có ID " + part.getPartId());
                    }

                    // Validate available quantity
                    int availableQty = partDetailDAO.getAvailableQuantityForPart(part.getPartId());
                    if (part.getQuantity() > availableQty) {
                        errors.add("Không đủ số lượng cho linh kiện ID " + part.getPartId()
                                + ". Yêu cầu: " + part.getQuantity() + ", Có sẵn: " + availableQty);
                    }

                    // Validate partDetailId if specified
                    if (part.getPartDetailId() != null) {
                        var partDetail = partDetailDAO.lockAndValidatePartDetail(part.getPartDetailId());
                        if (partDetail == null) {
                            errors.add("Mã chi tiết linh kiện " + part.getPartDetailId() + " không khả dụng");
                        } else if (partDetail.getPartId() != part.getPartId()) {
                            errors.add("Mã chi tiết linh kiện " + part.getPartDetailId() + " không thuộc về linh kiện ID " + part.getPartId());
                        }
                    }
                }
            } catch (SQLException e) {
                errors.add("Lỗi cơ sở dữ liệu khi kiểm tra linh kiện: " + e.getMessage());
            }
        }

        // Validate estimated cost
        if (!isWarranty) {
            String estimatedCostStr = req.getParameter("estimatedCost");
            if (estimatedCostStr != null && !estimatedCostStr.trim().isEmpty()) {
                TechnicianValidator.ValidationResult costResult = TechnicianValidator.validateEstimatedCost(estimatedCostStr);
                if (!costResult.isValid()) {
                    errors.addAll(costResult.getErrors());
                }
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
        if (s == null) {
            return null;
        }
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
        if (role == null) {
            return false;
        }
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
        String sql = "SELECT "
                + "    p.partId, "
                + "    p.partName, "
                + "    p.unitPrice, "
                + "    (SELECT MIN(pd.partDetailId) FROM PartDetail pd WHERE pd.partId = p.partId AND pd.status = 'Available') as partDetailId, "
                + "    (SELECT MIN(pd.serialNumber) FROM PartDetail pd WHERE pd.partId = p.partId AND pd.status = 'Available') as serialNumber, "
                + "    (SELECT MIN(pd.location) FROM PartDetail pd WHERE pd.partId = p.partId AND pd.status = 'Available') as location, "
                + "    COALESCE((SELECT COUNT(*) FROM PartDetail pd WHERE pd.partId = p.partId AND pd.status = 'Available'), 0) as availableQuantity "
                + "FROM Part p "
                + "ORDER BY p.partName";

        System.out.println("Executing SQL: " + sql);

        try (var con = new dal.DBContext().connection; var ps = con.prepareStatement(sql)) {

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
                req.setAttribute("error", "Thiếu mã linh kiện hoặc số lượng");
                resp.sendRedirect(req.getContextPath() + "/technician/reports?action=create&requestId=" + requestIdStr);
                return;
            }

            int partId = Integer.parseInt(partIdStr);
            int quantity = Integer.parseInt(quantityStr);

            // Get part details directly
            String sql = "SELECT p.partId, p.partName, p.unitPrice, "
                    + "MIN(pd.partDetailId) as partDetailId, "
                    + "MIN(CASE WHEN pd.status = 'Available' THEN pd.serialNumber END) as serialNumber, "
                    + "MIN(CASE WHEN pd.status = 'Available' THEN pd.location END) as location, "
                    + "COUNT(CASE WHEN pd.status = 'Available' THEN 1 END) as availableQuantity "
                    + "FROM Part p "
                    + "LEFT JOIN PartDetail pd ON p.partId = pd.partId "
                    + "WHERE p.partId = ? AND pd.status = 'Available' "
                    + "GROUP BY p.partId, p.partName, p.unitPrice";

            Map<String, Object> part = null;
            try (var con = new dal.DBContext().connection; var ps = con.prepareStatement(sql)) {
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
                req.setAttribute("error", "Không tìm thấy linh kiện hoặc linh kiện không còn sẵn");
                resp.sendRedirect(req.getContextPath() + "/technician/reports?action=create&requestId=" + requestIdStr);
                return;
            }

            // Validate quantity
            int availableQty = ((Number) part.get("availableQuantity")).intValue();
            if (quantity > availableQty) {
                req.setAttribute("error", "Không đủ số lượng. Có sẵn: " + availableQty);
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
                        req.setAttribute("error", "Tổng số lượng vượt quá số lượng có sẵn. Có sẵn: " + availableQty);
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
            req.setAttribute("error", "Lỗi thêm linh kiện: " + e.getMessage());
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
        String scheduleIdStr = req.getParameter("scheduleId");

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
                        if (currentQty == null) {
                            currentQty = 0;
                        }

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
        String sql = "SELECT "
                + "    p.partId, "
                + "    p.partName, "
                + "    p.unitPrice, "
                + "    MIN(pd.partDetailId) as partDetailId, "
                + "    MIN(CASE WHEN pd.status = 'Available' THEN pd.serialNumber END) as serialNumber, "
                + "    MIN(CASE WHEN pd.status = 'Available' THEN pd.location END) as location, "
                + "    COUNT(CASE WHEN pd.status = 'Available' THEN 1 END) as availableQuantity "
                + "FROM Part p "
                + "LEFT JOIN PartDetail pd ON p.partId = pd.partId AND pd.status = 'Available' "
                + "WHERE p.partName LIKE ? "
                + "   OR EXISTS ("
                + "       SELECT 1 FROM PartDetail pd2 "
                + "       WHERE pd2.partId = p.partId "
                + "       AND pd2.status = 'Available' "
                + "       AND (pd2.serialNumber LIKE ? OR pd2.location LIKE ?)"
                + "   ) "
                + "GROUP BY p.partId, p.partName, p.unitPrice "
                + "HAVING availableQuantity > 0 "
                + "ORDER BY p.partName "
                + "LIMIT ?";

        System.out.println("=== Search Available Parts Debug ===");
        System.out.println("Search query: '" + query + "'");

        try (var con = new dal.DBContext().connection; var ps = con.prepareStatement(sql)) {

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

                    System.out.println("  [" + count + "] " + part.get("partName")
                            + " (ID:" + part.get("partId")
                            + ", Available:" + part.get("availableQuantity")
                            + ", Serial:" + part.get("serialNumber")
                            + ", Price:$" + part.get("unitPrice") + ")");
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
        String scheduleIdStr = req.getParameter("scheduleId");

        if (partIdStr == null) {
            StringBuilder redirectMiss = new StringBuilder(req.getContextPath()).append("/technician/reports?action=create");
            if (scheduleIdStr != null && !scheduleIdStr.trim().isEmpty()) {
                redirectMiss.append("&scheduleId=").append(scheduleIdStr.trim());
            } else if (requestIdStr != null && !requestIdStr.trim().isEmpty()) {
                redirectMiss.append("&requestId=").append(requestIdStr.trim());
            }
            resp.sendRedirect(redirectMiss.toString());
            return;
        }

        int partId = Integer.parseInt(partIdStr);

        // Get request-specific cart
        String cartKey = (scheduleIdStr != null && !scheduleIdStr.trim().isEmpty())
                ? ("selectedParts_schedule_" + scheduleIdStr.trim())
                : ("selectedParts_" + (requestIdStr != null ? requestIdStr.trim() : "new"));
        @SuppressWarnings("unchecked")
        List<RepairReportDetail> selectedParts = (List<RepairReportDetail>) req.getSession().getAttribute(cartKey);
        if (selectedParts != null) {
            selectedParts.removeIf(detail -> detail.getPartId() == partId);
        }

        StringBuilder redirect = new StringBuilder(req.getContextPath()).append("/technician/reports?action=create");
        if (scheduleIdStr != null && !scheduleIdStr.trim().isEmpty()) {
            redirect.append("&scheduleId=").append(scheduleIdStr.trim());
        } else if (requestIdStr != null && !requestIdStr.trim().isEmpty()) {
            redirect.append("&requestId=").append(requestIdStr.trim());
        }
        resp.sendRedirect(redirect.toString());
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
        String sql = "SELECT "
                + "sr.requestId, "
                + "sr.contractId, "
                + "c.contractType, "
                + "a.accountId, "
                + "a.fullName as customerName, "
                + "sr.description as requestDescription, "
                + "sr.requestType "
                + "FROM ServiceRequest sr "
                + "LEFT JOIN Contract c ON sr.contractId = c.contractId "
                + "LEFT JOIN Account a ON sr.createdBy = a.accountId "
                + "WHERE sr.requestId = ?";

        try (var con = new dal.DBContext().connection; var ps = con.prepareStatement(sql)) {

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
     * Resolve effective requestId from a scheduleId (MaintenanceSchedule)
     */
    private Integer getEffectiveRequestIdForSchedule(int scheduleId) throws SQLException {
        String sql = "SELECT requestId FROM MaintenanceSchedule WHERE scheduleId = ?";
        try (var con = new dal.DBContext().connection; var ps = con.prepareStatement(sql)) {
            ps.setInt(1, scheduleId);
            try (var rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getObject("requestId", Integer.class);
                }
            }
        }
        return null;
    }

    /**
     * Get schedule's customer info via Contract -> Account
     */
    private Map<String, Object> getScheduleCustomerInfo(int scheduleId) throws SQLException {
        String sql = "SELECT a.accountId as customerAccountId, a.fullName as customerName "
                + "FROM MaintenanceSchedule ms "
                + "JOIN Contract c ON ms.contractId = c.contractId "
                + "JOIN Account a ON c.customerId = a.accountId "
                + "WHERE ms.scheduleId = ?";
        try (var con = new dal.DBContext().connection; var ps = con.prepareStatement(sql)) {
            ps.setInt(1, scheduleId);
            try (var rs = ps.executeQuery()) {
                if (rs.next()) {
                    Map<String, Object> info = new LinkedHashMap<>();
                    info.put("customerAccountId", rs.getInt("customerAccountId"));
                    info.put("customerName", rs.getString("customerName"));
                    return info;
                }
            }
        }
        return null;
    }

    /**
     * Get WorkTask status for this technician and scheduleId (if exists)
     */
    private String getScheduleTaskStatus(int technicianId, int scheduleId) throws SQLException {
        String sql = "SELECT status FROM WorkTask WHERE technicianId = ? AND scheduleId = ? ORDER BY taskId DESC LIMIT 1";
        try (var con = new dal.DBContext().connection; var ps = con.prepareStatement(sql)) {
            ps.setInt(1, technicianId);
            ps.setInt(2, scheduleId);
            try (var rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("status");
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

        String sql = "SELECT "
                + "c.contractId, "
                + "c.contractType, "
                + "c.startDate, "
                + "c.endDate, "
                + "c.status, "
                + "c.totalValue "
                + "FROM Contract c "
                + "WHERE c.customerId = ? "
                + "AND c.status IN ('Active', 'Pending') "
                + "ORDER BY c.startDate DESC";

        try (var con = new dal.DBContext().connection; var ps = con.prepareStatement(sql)) {

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
        String sql = "SELECT "
                + "    p.partId, "
                + "    p.partName, "
                + "    p.unitPrice, "
                + "    MIN(CASE WHEN pd.status = 'Available' THEN pd.partDetailId END) as partDetailId, "
                + "    MIN(CASE WHEN pd.status = 'Available' THEN pd.serialNumber END) as serialNumber, "
                + "    MIN(CASE WHEN pd.status = 'Available' THEN pd.location END) as location, "
                + "    COALESCE(COUNT(CASE WHEN pd.status = 'Available' THEN 1 END), 0) as availableQuantity "
                + "FROM Part p "
                + "LEFT JOIN PartDetail pd ON p.partId = pd.partId "
                + "WHERE (LOWER(p.partName) LIKE LOWER(?) "
                + "       OR LOWER(pd.serialNumber) LIKE LOWER(?)) "
                + "GROUP BY p.partId, p.partName, p.unitPrice "
                + "ORDER BY p.partName "
                + "LIMIT 50";

        try (var con = new dal.DBContext().connection; var ps = con.prepareStatement(sql)) {

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
                if (i > 0) {
                    json.append(",");
                }
                json.append("{");
                json.append("\"partId\":").append(part.get("partId")).append(",");
                json.append("\"partName\":\"").append(escapeJsonString((String) part.get("partName"))).append("\",");
                json.append("\"serialNumber\":\"").append(escapeJsonString((String) part.get("serialNumber"))).append("\",");
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
            resp.getWriter().write("{\"error\":\"Lỗi cơ sở dữ liệu: " + escapeJsonString(e.getMessage()) + "\"}");
        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("Exception in handleSearchPartsAjax: " + e.getMessage());
            resp.setStatus(500);
            resp.getWriter().write("{\"error\":\"Lỗi: " + escapeJsonString(e.getMessage()) + "\"}");
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
            String requestIdParam = req.getParameter("requestId");
            String scheduleIdParam = req.getParameter("scheduleId");

            if (partIdStr == null || quantityStr == null) {
                resp.getWriter().write("{\"success\":false,\"error\":\"Thiếu tham số\"}");
                return;
            }

            int partId = Integer.parseInt(partIdStr);
            int quantity = Integer.parseInt(quantityStr);
            HttpSession session = req.getSession();
            String cartKey;
            Integer requestIdForContext = null;
            Integer scheduleIdForContext = null;

            if (requestIdParam != null && !requestIdParam.trim().isEmpty()) {
                requestIdForContext = Integer.parseInt(requestIdParam.trim());
                cartKey = "selectedParts_" + requestIdForContext;
            } else if (scheduleIdParam != null && !scheduleIdParam.trim().isEmpty()) {
                scheduleIdForContext = Integer.parseInt(scheduleIdParam.trim());
                cartKey = "selectedParts_schedule_" + scheduleIdForContext;
            } else {
                resp.getWriter().write("{\"success\":false,\"error\":\"Thiếu requestId hoặc scheduleId\"}");
                return;
            }

            @SuppressWarnings("unchecked")
            List<RepairReportDetail> selectedParts = (List<RepairReportDetail>) session.getAttribute(cartKey);

            // Validate contract exists for request-origin only
            if (requestIdForContext != null) {
                try {
                    Map<String, Object> customerInfo = getCustomerRequestInfo(requestIdForContext);

                    if (customerInfo == null) {
                        resp.getWriter().write("{\"success\":false,\"error\":\"Yêu cầu không hợp lệ hoặc không tìm thấy hợp đồng\"}");
                        return;
                    }

                    // Check if contract exists
                    Object contractId = customerInfo.get("contractId");
                    if (contractId == null) {
                        resp.getWriter().write("{\"success\":false,\"error\":\"Yêu cầu dịch vụ này không có hợp đồng. Không thể thêm linh kiện.\"}");
                        return;
                    }
                } catch (SQLException e) {
                    resp.getWriter().write("{\"success\":false,\"error\":\"Lỗi cơ sở dữ liệu: " + escapeJsonString(e.getMessage()) + "\"}");
                    return;
                }
            }

            // Initialize selected parts if not exists (request-specific)
            if (selectedParts == null) {
                selectedParts = new ArrayList<>();
                session.setAttribute(cartKey, selectedParts);
            }

            // Get part details (reuse existing logic)
            String sql = "SELECT p.partId, p.partName, p.unitPrice, "
                    + "MIN(pd.partDetailId) as partDetailId, "
                    + "MIN(CASE WHEN pd.status = 'Available' THEN pd.serialNumber END) as serialNumber, "
                    + "MIN(CASE WHEN pd.status = 'Available' THEN pd.location END) as location, "
                    + "COUNT(CASE WHEN pd.status = 'Available' THEN 1 END) as availableQuantity "
                    + "FROM Part p "
                    + "LEFT JOIN PartDetail pd ON p.partId = pd.partId "
                    + "WHERE p.partId = ? AND pd.status = 'Available' "
                    + "GROUP BY p.partId, p.partName, p.unitPrice";

            Map<String, Object> part = null;
            try (var con = new dal.DBContext().connection; var ps = con.prepareStatement(sql)) {
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
                resp.getWriter().write("{\"success\":false,\"error\":\"Không tìm thấy linh kiện\"}");
                return;
            }

            int availableQty = ((Number) part.get("availableQuantity")).intValue();
            if (quantity > availableQty) {
                resp.getWriter().write("{\"success\":false,\"error\":\"Không đủ số lượng. Có sẵn: " + availableQty + "\"}");
                return;
            }

            // Check if part already exists, REPLACE quantity (not add)
            boolean found = false;
            for (RepairReportDetail detail : selectedParts) {
                if (detail.getPartId() == partId) {
                    // Replace quantity (JavaScript sends the total quantity, not delta)
                    if (quantity > availableQty) {
                        resp.getWriter().write("{\"success\":false,\"error\":\"Số lượng vượt quá số lượng có sẵn. Có sẵn: " + availableQty + "\"}");
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
            resp.getWriter().write("{\"success\":false,\"error\":\"Định dạng partId, quantity hoặc requestId không hợp lệ\"}");
        } catch (Exception e) {
            e.printStackTrace();
            resp.getWriter().write("{\"success\":false,\"error\":\"Lỗi: " + escapeJsonString(e.getMessage()) + "\"}");
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
            String scheduleIdStr = req.getParameter("scheduleId");

            System.out.println("Received partId: '" + partIdStr + "' (type: " + (partIdStr != null ? partIdStr.getClass().getSimpleName() : "null") + ")");
            System.out.println("Received requestId: '" + requestIdStr + "' (type: " + (requestIdStr != null ? requestIdStr.getClass().getSimpleName() : "null") + ")");

            if (partIdStr == null || partIdStr.trim().isEmpty()) {
                System.out.println("ERROR: Missing partId");
                resp.getWriter().write("{\"success\":false,\"error\":\"Thiếu partId\"}");
                return;
            }

            if ((requestIdStr == null || requestIdStr.trim().isEmpty()) && (scheduleIdStr == null || scheduleIdStr.trim().isEmpty())) {
                System.out.println("ERROR: Missing requestId/scheduleId");
                resp.getWriter().write("{\"success\":false,\"error\":\"Thiếu requestId hoặc scheduleId\"}");
                return;
            }

            int partId;
            try {
                partId = Integer.parseInt(partIdStr.trim());
                System.out.println("Parsed partId: " + partId);
            } catch (NumberFormatException e) {
                System.out.println("ERROR: Cannot parse partId '" + partIdStr + "': " + e.getMessage());
                resp.getWriter().write("{\"success\":false,\"error\":\"Định dạng partId không hợp lệ: '" + escapeJsonString(partIdStr) + "'\"}");
                return;
            }

            // Get request-specific cart
            String cartKey = (requestIdStr != null && !requestIdStr.trim().isEmpty())
                    ? ("selectedParts_" + requestIdStr.trim())
                    : ("selectedParts_schedule_" + scheduleIdStr.trim());
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
            resp.getWriter().write("{\"success\":false,\"error\":\"Định dạng partId hoặc requestId không hợp lệ: " + escapeJsonString(e.getMessage()) + "\"}");
        } catch (Exception e) {
            System.out.println("Exception: " + e.getMessage());
            e.printStackTrace();
            resp.getWriter().write("{\"success\":false,\"error\":\"Lỗi: " + escapeJsonString(e.getMessage()) + "\"}");
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
            String scheduleIdStr = req.getParameter("scheduleId");
            Integer requestId = null;
            Integer scheduleId = null;
            if (requestIdStr != null && !requestIdStr.trim().isEmpty()) {
                requestId = Integer.parseInt(requestIdStr);
            } else if (scheduleIdStr != null && !scheduleIdStr.trim().isEmpty()) {
                scheduleId = Integer.parseInt(scheduleIdStr);
            } else {
            resp.getWriter().write("{\"success\":false,\"error\":\"Thiếu requestId hoặc scheduleId\"}");
                return;
            }

            // Get customer/request info
            Map<String, Object> customerInfo = null;
            if (requestId != null) {
                customerInfo = getCustomerRequestInfo(requestId);
            }

            // Get selected parts from session (request-specific cart)
            String cartKey = (requestId != null)
                    ? ("selectedParts_" + requestId)
                    : ("selectedParts_schedule_" + scheduleId);
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
                json.append("\"customerName\":\"").append(escapeJsonString((String) customerInfo.get("customerName"))).append("\",");
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
                if (i > 0) {
                    json.append(",");
                }
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
            String scheduleIdStr = req.getParameter("scheduleId");
            HttpSession session = req.getSession();

            if (requestIdStr != null && !requestIdStr.trim().isEmpty()) {
                // Clear specific request's cart
                String cartKey = "selectedParts_" + requestIdStr;
                session.removeAttribute(cartKey);
            } else if (scheduleIdStr != null && !scheduleIdStr.trim().isEmpty()) {
                String cartKey = "selectedParts_schedule_" + scheduleIdStr;
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
            resp.getWriter().write("{\"success\":false,\"error\":\"Thiếu requestId\"}");
                return;
            }

            int requestId = Integer.parseInt(requestIdStr);

            // Get customer info from request
            Map<String, Object> customerInfo = getCustomerRequestInfo(requestId);
            if (customerInfo == null) {
                resp.getWriter().write("{\"success\":false,\"error\":\"Không tìm thấy yêu cầu\"}");
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
                if (i > 0) {
                    json.append(",");
                }
                json.append("{");
                json.append("\"contractId\":").append(contract.get("contractId")).append(",");
                json.append("\"contractType\":\"").append(escapeJsonString((String) contract.get("contractType"))).append("\",");
                json.append("\"startDate\":\"").append(contract.get("startDate")).append("\",");
                json.append("\"endDate\":\"").append(contract.get("endDate")).append("\",");
                json.append("\"status\":\"").append(escapeJsonString((String) contract.get("status"))).append("\",");
                json.append("\"totalValue\":").append(contract.get("totalValue"));
                json.append("}");
            }

            json.append("]}");
            resp.getWriter().write(json.toString());

        } catch (SQLException e) {
            resp.getWriter().write("{\"success\":false,\"error\":\"Lỗi cơ sở dữ liệu: " + escapeJsonString(e.getMessage()) + "\"}");
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

        try (RepairReportDAO reportDAO = new RepairReportDAO()) {
            String scheduleIdStr = req.getParameter("scheduleId");
            String requestIdStr = req.getParameter("requestId");

            RepairReport existingReport = null;

            if (scheduleIdStr != null && !scheduleIdStr.trim().isEmpty()) {
                int scheduleId = Integer.parseInt(scheduleIdStr.trim());
                existingReport = reportDAO.findByScheduleIdAndTechnician(scheduleId, technicianId);
            } else if (requestIdStr != null && !requestIdStr.trim().isEmpty()) {
                int requestId = Integer.parseInt(requestIdStr.trim());
                existingReport = reportDAO.findByRequestIdAndTechnician(requestId, technicianId);
            } else {
            resp.getWriter().write("{\"exists\":false,\"error\":\"Thiếu định danh\"}");
                return;
            }

            if (existingReport != null) {
                resp.getWriter().write("{\"exists\":true,\"reportId\":" + existingReport.getReportId() + "}");
            } else {
                resp.getWriter().write("{\"exists\":false}");
            }
        } catch (NumberFormatException e) {
            resp.getWriter().write("{\"exists\":false,\"error\":\"Định dạng định danh không hợp lệ\"}");
        } catch (SQLException e) {
            e.printStackTrace();
            System.err.println("SQLException in handleCheckExistingReportAjax: " + e.getMessage());
            resp.setStatus(500);
            resp.getWriter().write("{\"exists\":false,\"error\":\"Lỗi cơ sở dữ liệu: " + escapeJsonString(e.getMessage()) + "\"}");
        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("Exception in handleCheckExistingReportAjax: " + e.getMessage());
            resp.setStatus(500);
            resp.getWriter().write("{\"exists\":false,\"error\":\"Lỗi: " + escapeJsonString(e.getMessage()) + "\"}");
        }
    }

    /**
     * Helper method to escape JSON strings
     */
    private String escapeJsonString(String s) {
        if (s == null) {
            return "";
        }
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}
