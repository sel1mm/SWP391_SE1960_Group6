package controller;

import dal.WorkTaskDAO;
import dal.RepairReportDAO;
import model.WorkTask;
import model.RepairReport;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

/**
 * Servlet for handling technician task operations.
 * Updated to work with the new WorkTask table structure.
 */
public class TechnicianTaskServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        Integer sessionId = session != null ? (Integer) session.getAttribute("session_login_id") : null;
        String userRole = session != null ? (String) session.getAttribute("session_role") : null;
        
        String action = req.getParameter("action");
        String taskIdParam = req.getParameter("taskId");
        
        // Check authentication
        if (sessionId == null || !isTechnicianOrAdmin(userRole)) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        
        int technicianId = sessionId.intValue();
        
        try {
            WorkTaskDAO taskDAO = new WorkTaskDAO();
            
            if ("detail".equals(action) && taskIdParam != null) {
                // Show task detail
                int taskId = Integer.parseInt(taskIdParam);
                WorkTask task = taskDAO.findById(taskId);
                
                if (task != null && task.getTechnicianId() == technicianId) {
                    RepairReport existingReport = null;
                    RepairReportDAO reportDAO = new RepairReportDAO();
                    try {
                        if (task.getRequestId() != null) {
                            existingReport = reportDAO.findByRequestIdAndTechnician(task.getRequestId(), technicianId);
                        } else if (task.getScheduleId() != null) {
                            existingReport = reportDAO.findByScheduleIdAndTechnician(task.getScheduleId(), technicianId);
                        }
                    } catch (SQLException e) {
                        System.err.println("Error loading existing report: " + e.getMessage());
                    }
                    req.setAttribute("task", task);
                    req.setAttribute("existingReport", existingReport);
                    // Also expose scheduleId so JSP can render Create Report for schedules
                    if (task.getScheduleId() != null && task.getRequestId() == null) {
                        req.setAttribute("effectiveScheduleId", task.getScheduleId());
                    }
                    req.setAttribute("pageTitle", "Chi tiết công việc");
                    req.setAttribute("contentView", "/WEB-INF/technician/task-detail.jsp");
                    req.setAttribute("activePage", "tasks");
                    req.getRequestDispatcher("/WEB-INF/technician/technician-layout.jsp").forward(req, resp);
                } else {
                    req.setAttribute("error", "Không tìm thấy công việc hoặc công việc không được giao cho bạn");
                    doGetTaskList(req, resp, technicianId);
                }
            } else {
                // Show task list
                doGetTaskList(req, resp, technicianId);
            }
            
        } catch (SQLException e) {
            throw new ServletException("Database error: " + e.getMessage(), e);
        } catch (NumberFormatException e) {
            req.setAttribute("error", "Mã công việc không hợp lệ");
            doGetTaskList(req, resp, technicianId);
        }
    }
    
    private void doGetTaskList(HttpServletRequest req, HttpServletResponse resp, int technicianId) 
            throws ServletException, IOException {
        try {
            String searchQuery = sanitize(req.getParameter("q"));
            String statusFilter = sanitize(req.getParameter("status"));
            int page = parseInt(req.getParameter("page"), 1);
            int pageSize = Math.min(parseInt(req.getParameter("pageSize"), 10), 100);
            
            // Handle success/error messages from URL parameters (from redirects)
            String successParam = req.getParameter("success");
            String errorParam = req.getParameter("error");
            if (successParam != null && !successParam.isEmpty()) {
                req.setAttribute("success", successParam);
            }
            if (errorParam != null && !errorParam.isEmpty()) {
                req.setAttribute("error", errorParam);
            }
            
            WorkTaskDAO taskDAO = new WorkTaskDAO();
            List<WorkTaskDAO.WorkTaskWithCustomer> tasksWithCustomer = taskDAO.findByTechnicianIdWithCustomer(technicianId, searchQuery, statusFilter, page, pageSize);
            int totalTasks = taskDAO.getTaskCountForTechnicianWithCustomer(technicianId, statusFilter);
            
            req.setAttribute("tasksWithCustomer", tasksWithCustomer);
            req.setAttribute("totalTasks", totalTasks);
            req.setAttribute("currentPage", page);
            req.setAttribute("pageSize", pageSize);
            req.setAttribute("totalPages", (int) Math.ceil((double) totalTasks / pageSize));
            req.setAttribute("pageTitle", "Công việc của tôi");
            req.setAttribute("contentView", "/WEB-INF/technician/technician-tasks.jsp");
            req.setAttribute("activePage", "tasks");
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
        String taskIdParam = req.getParameter("taskId");
        
        if ("updateStatus".equals(action) && taskIdParam != null) {
            try {
                int taskId = Integer.parseInt(taskIdParam);
                // Read newStatus from form (changed from "status" to avoid conflict with filter parameter)
                String newStatus = req.getParameter("newStatus");
                
                if (newStatus == null || newStatus.trim().isEmpty()) {
                    // Preserve filter parameters when showing error
                    String preservedQ = sanitize(req.getParameter("q"));
                    String preservedStatus = sanitize(req.getParameter("status"));
                    String preservedPage = req.getParameter("page");
                    String redirectUrl = buildTaskListUrlWithMessage(req, preservedQ, preservedStatus, preservedPage, "error", "Vui lòng chọn trạng thái");
                    resp.sendRedirect(redirectUrl);
                    return;
                }
                
                // Preserve filter parameters
                String preservedQ = sanitize(req.getParameter("q"));
                String preservedStatus = sanitize(req.getParameter("status"));
                String preservedPage = req.getParameter("page");
                
                WorkTaskDAO taskDAO = new WorkTaskDAO();
                WorkTask task = taskDAO.findById(taskId);
                
                if (task != null && task.getTechnicianId() == sessionId.intValue()) {
                    int technicianId = sessionId.intValue();
                    String trimmedStatus = newStatus.trim();
                    
                    // ✅ VALIDATION: Check if trying to complete task without valid repair report
                    if ("Completed".equals(trimmedStatus)) {
                        try (RepairReportDAO reportDAO = new RepairReportDAO()) {
                            RepairReport report = null;
                            if (task.getRequestId() != null) {
                                report = reportDAO.findByRequestIdAndTechnician(task.getRequestId(), technicianId);
                            } else if (task.getScheduleId() != null) {
                                report = reportDAO.findByScheduleIdAndTechnician(task.getScheduleId(), technicianId);
                            }

                            if (report == null) {
                                String redirectUrl = buildTaskListUrlWithMessage(req, preservedQ, preservedStatus, preservedPage,
                                        "error", "Không thể hoàn tất công việc: Vui lòng tạo và gửi báo cáo sửa chữa trước.");
                                resp.sendRedirect(redirectUrl);
                                return;
                            }

                            String quotationStatus = report.getQuotationStatus();
                            if (quotationStatus == null || "Pending".equalsIgnoreCase(quotationStatus)) {
                                String redirectUrl = buildTaskListUrlWithMessage(req, preservedQ, preservedStatus, preservedPage,
                                        "error", "Không thể hoàn tất công việc: Báo giá vẫn đang chờ phản hồi từ khách hàng.");
                                resp.sendRedirect(redirectUrl);
                                return;
                            }
                        } catch (SQLException e) {
                            System.err.println("Error checking repair report status: " + e.getMessage());
                            e.printStackTrace();
                            String redirectUrl = buildTaskListUrlWithMessage(req, preservedQ, preservedStatus, preservedPage,
                                    "error", "Lỗi kiểm tra trạng thái báo cáo: " + e.getMessage());
                            resp.sendRedirect(redirectUrl);
                            return;
                        }
                    }
                    
                    // Proceed with status update
                    boolean updated = taskDAO.updateTaskStatus(taskId, trimmedStatus);
                    
                    // Redirect with preserved filter parameters
                    if (updated) {
                        String redirectUrl = buildTaskListUrlWithMessage(req, preservedQ, preservedStatus, preservedPage, "success", "Cập nhật trạng thái công việc thành công");
                        resp.sendRedirect(redirectUrl);
                    } else {
                        String redirectUrl = buildTaskListUrlWithMessage(req, preservedQ, preservedStatus, preservedPage, "error", "Không thể cập nhật trạng thái công việc");
                        resp.sendRedirect(redirectUrl);
                    }
                } else {
                    String redirectUrl = buildTaskListUrlWithMessage(req, preservedQ, preservedStatus, preservedPage, "error", "Không tìm thấy công việc hoặc công việc không được giao cho bạn");
                    resp.sendRedirect(redirectUrl);
                }
                
            } catch (SQLException e) {
                throw new ServletException("Database error: " + e.getMessage(), e);
            } catch (NumberFormatException e) {
                String preservedQ = sanitize(req.getParameter("q"));
                String preservedStatus = sanitize(req.getParameter("status"));
                String preservedPage = req.getParameter("page");
                String redirectUrl = buildTaskListUrlWithMessage(req, preservedQ, preservedStatus, preservedPage, "error", "Mã công việc không hợp lệ");
                resp.sendRedirect(redirectUrl);
            } catch (IOException e) {
                throw new ServletException("Redirect error: " + e.getMessage(), e);
            }
        } else {
            String preservedQ = sanitize(req.getParameter("q"));
            String preservedStatus = sanitize(req.getParameter("status"));
            String preservedPage = req.getParameter("page");
            String redirectUrl = buildTaskListUrlWithMessage(req, preservedQ, preservedStatus, preservedPage, "error", "Thao tác không hợp lệ");
            try {
                resp.sendRedirect(redirectUrl);
            } catch (IOException e) {
                throw new ServletException("Redirect error: " + e.getMessage(), e);
            }
        }
    }

    /**
     * Build task list URL with preserved filter parameters and optional message
     */
    private String buildTaskListUrlWithMessage(HttpServletRequest req, String q, String status, String page, String messageType, String message) {
        StringBuilder url = new StringBuilder();
        url.append(req.getContextPath()).append("/technician/tasks");
        
        boolean hasParams = false;
        if (q != null && !q.isEmpty()) {
            url.append(hasParams ? "&" : "?").append("q=").append(java.net.URLEncoder.encode(q, java.nio.charset.StandardCharsets.UTF_8));
            hasParams = true;
        }
        if (status != null && !status.isEmpty()) {
            url.append(hasParams ? "&" : "?").append("status=").append(java.net.URLEncoder.encode(status, java.nio.charset.StandardCharsets.UTF_8));
            hasParams = true;
        }
        if (page != null && !page.isEmpty()) {
            url.append(hasParams ? "&" : "?").append("page=").append(page);
            hasParams = true;
        }
        if (messageType != null && message != null) {
            url.append(hasParams ? "&" : "?").append(messageType).append("=").append(java.net.URLEncoder.encode(message, java.nio.charset.StandardCharsets.UTF_8));
        }
        
        return url.toString();
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
