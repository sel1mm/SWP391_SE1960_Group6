package controller;

import dal.ServiceRequestDAO;
import dal.MaintenanceScheduleDAO;
import dal.WorkAssignmentDAO;
import dal.TechnicianWorkloadDAO;
import model.Account;
import model.ServiceRequest;
import model.MaintenanceSchedule;
import model.WorkAssignment;
import model.WorkTask;
import model.RepairReport;
import model.RepairResult;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonPrimitive;
import com.google.gson.JsonSerializer;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.List;
import java.util.ArrayList;
import java.util.logging.Level;
import java.util.logging.Logger;
import com.google.gson.Gson;
import com.google.gson.JsonObject;

/**
 * Servlet for Technical Manager to review maintenance reports
 * Handles viewing, approving, and managing maintenance reports
 */
@WebServlet(name = "ReviewMaintenanceReportServlet", urlPatterns = {"/reviewMaintenanceReport"})
public class ReviewMaintenanceReportServlet extends HttpServlet {
    
    private static final Logger LOGGER = Logger.getLogger(ReviewMaintenanceReportServlet.class.getName());
    
    private ServiceRequestDAO serviceRequestDAO;
    private MaintenanceScheduleDAO maintenanceScheduleDAO;
    private WorkAssignmentDAO workAssignmentDAO;
    private TechnicianWorkloadDAO technicianWorkloadDAO;
    private Gson gson;
    
    @Override
    public void init() throws ServletException {
        super.init();
        try {
            serviceRequestDAO = new ServiceRequestDAO();
            maintenanceScheduleDAO = new MaintenanceScheduleDAO();
            workAssignmentDAO = new WorkAssignmentDAO();
            technicianWorkloadDAO = new TechnicianWorkloadDAO();
            gson = new Gson();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error initializing ReviewMaintenanceReportServlet", e);
            throw new ServletException("Failed to initialize servlet", e);
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Set character encoding
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession();
        Account loggedInAccount = (Account) session.getAttribute("session_login");
        String userRole = (String) session.getAttribute("session_role");
        
        // Check authentication and authorization
        if (loggedInAccount == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        if (!"Technical Manager".equals(userRole)) {
            response.sendRedirect("dashboard.jsp");
            return;
        }
        
        try {
            String action = request.getParameter("action");
            
            if ("getReportDetails".equals(action)) {
                handleGetReportDetails(request, response);
                return;
            }
            
            // Load data for the main page
            loadMaintenanceReportsData(request);
            
            // Forward to JSP
            request.getRequestDispatcher("ReviewMaintenanceReport.jsp").forward(request, response);
            
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in ReviewMaintenanceReportServlet doGet", e);
            session.setAttribute("errorMessage", "Lỗi hệ thống: " + e.getMessage());
            response.sendRedirect("dashboard.jsp");
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession();
        Account loggedInAccount = (Account) session.getAttribute("session_login");
        String userRole = (String) session.getAttribute("session_role");
        
        // Check authentication and authorization
        if (loggedInAccount == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        if (!"Technical Manager".equals(userRole)) {
            response.sendRedirect("dashboard.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        
        try {
            switch (action) {
                case "approveReport":
                    handleApproveReport(request, response, session);
                    break;
                case "rejectReport":
                    handleRejectReport(request, response, session);
                    break;
                case "requestRevision":
                    handleRequestRevision(request, response, session);
                    break;
                case "addComment":
                    handleAddComment(request, response, session);
                    break;
                case "updateReportStatus":
                    handleUpdateReportStatus(request, response, session);
                    break;
                default:
                    session.setAttribute("errorMessage", "Hành động không hợp lệ");
                    response.sendRedirect("reviewMaintenanceReport");
                    break;
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in ReviewMaintenanceReportServlet doPost", e);
            session.setAttribute("errorMessage", "Lỗi hệ thống: " + e.getMessage());
            response.sendRedirect("reviewMaintenanceReport");
        }
    }
    
    /**
     * Load maintenance reports data for the main page
     */
    private void loadMaintenanceReportsData(HttpServletRequest request) {
        try {
            // Get completed maintenance schedules (reports to review)
            List<MaintenanceSchedule> completedSchedules = maintenanceScheduleDAO.getSchedulesByStatus("Completed");
            request.setAttribute("completedSchedules", completedSchedules);
            
            // Get pending reports (reports waiting for review)
            List<MaintenanceSchedule> pendingReports = maintenanceScheduleDAO.getSchedulesByStatus("Pending Review");
            request.setAttribute("pendingReports", pendingReports);
            
            // Get approved reports
            List<MaintenanceSchedule> approvedReports = maintenanceScheduleDAO.getSchedulesByStatus("Approved");
            request.setAttribute("approvedReports", approvedReports);
            
            // Get rejected reports
            List<MaintenanceSchedule> rejectedReports = maintenanceScheduleDAO.getSchedulesByStatus("Rejected");
            request.setAttribute("rejectedReports", rejectedReports);
            
            // Get all maintenance schedules for overview
            List<MaintenanceSchedule> allSchedules = maintenanceScheduleDAO.getAllMaintenanceSchedules();
            request.setAttribute("allSchedules", allSchedules);
            
            // Get service requests for context
            List<ServiceRequest> serviceRequests = serviceRequestDAO.getAllRequestsHistory();
            request.setAttribute("serviceRequests", serviceRequests);
            
            // Calculate statistics
            int totalReports = completedSchedules.size() + pendingReports.size() + approvedReports.size() + rejectedReports.size();
            int pendingCount = pendingReports.size();
            int approvedCount = approvedReports.size();
            int rejectedCount = rejectedReports.size();
            
            request.setAttribute("totalReports", totalReports);
            request.setAttribute("pendingCount", pendingCount);
            request.setAttribute("approvedCount", approvedCount);
            request.setAttribute("rejectedCount", rejectedCount);
            
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error loading maintenance reports data", e);
        }
    }
    
    /**
     * Handle getting detailed report information
     */
 private void handleGetReportDetails(HttpServletRequest request, HttpServletResponse response) 
        throws IOException {

    response.setContentType("application/json");
    PrintWriter out = response.getWriter();

    try {
        int scheduleId = Integer.parseInt(request.getParameter("scheduleId"));

        // Get schedule details
        MaintenanceSchedule schedule = maintenanceScheduleDAO.getScheduleById(scheduleId);

        if (schedule == null) {
            JsonObject errorResponse = new JsonObject();
            errorResponse.addProperty("error", "Không tìm thấy lịch bảo trì");
            out.print(gson.toJson(errorResponse));
            return;
        }

        // Get related service request if exists
        ServiceRequest serviceRequest = null;
        if (schedule.getRequestId() > 0) {
            serviceRequest = serviceRequestDAO.getRequestById(schedule.getRequestId());
        }

        // Work assignments (empty for now)
        List<WorkAssignment> assignments = new ArrayList<>();

        // Khởi tạo Gson có serializer cho LocalDate/LocalDateTime
        Gson localDateGson = new GsonBuilder()
                .registerTypeAdapter(LocalDate.class,
                        (JsonSerializer<LocalDate>) (date, type, context) ->
                                new JsonPrimitive(date.format(DateTimeFormatter.ISO_LOCAL_DATE)))
                .registerTypeAdapter(LocalDateTime.class,
                        (JsonSerializer<LocalDateTime>) (dateTime, type, context) ->
                                new JsonPrimitive(dateTime.format(DateTimeFormatter.ISO_LOCAL_DATE_TIME)))
                .create();

        // Create response object
        JsonObject response_obj = new JsonObject();
        response_obj.add("schedule", localDateGson.toJsonTree(schedule));
        if (serviceRequest != null) {
            response_obj.add("serviceRequest", localDateGson.toJsonTree(serviceRequest));
        }
        response_obj.add("assignments", localDateGson.toJsonTree(assignments));

        out.print(localDateGson.toJson(response_obj));

    } catch (NumberFormatException e) {
        JsonObject errorResponse = new JsonObject();
        errorResponse.addProperty("error", "ID lịch bảo trì không hợp lệ");
        out.print(new Gson().toJson(errorResponse));
    } catch (Exception e) {
        LOGGER.log(Level.SEVERE, "Error getting report details", e);
        JsonObject errorResponse = new JsonObject();
        errorResponse.addProperty("error", "Lỗi cơ sở dữ liệu: " + e.getMessage());
        out.print(new Gson().toJson(errorResponse));
    }
}

    
    /**
     * Handle approving a maintenance report
     */
    private void handleApproveReport(HttpServletRequest request, HttpServletResponse response, 
                                   HttpSession session) throws IOException {
        
        try {
            int scheduleId = Integer.parseInt(request.getParameter("scheduleId"));
            String approvalComments = request.getParameter("approvalComments");
            
            // Update schedule status to approved
            boolean success = maintenanceScheduleDAO.updateScheduleStatus(scheduleId, "Approved");
            
            if (success) {
                // TODO: Add approval comments to a comments table if needed
                // For now, we'll just update the status
                
                session.setAttribute("successMessage", "Báo cáo bảo trì đã được phê duyệt thành công!");
            } else {
                session.setAttribute("errorMessage", "Không thể phê duyệt báo cáo bảo trì");
            }
            
        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "ID lịch bảo trì không hợp lệ");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error approving report", e);
            session.setAttribute("errorMessage", "Lỗi cơ sở dữ liệu: " + e.getMessage());
        }
        
        response.sendRedirect("reviewMaintenanceReport");
    }
    
    /**
     * Handle rejecting a maintenance report
     */
    private void handleRejectReport(HttpServletRequest request, HttpServletResponse response, 
                                  HttpSession session) throws IOException {
        
        try {
            int scheduleId = Integer.parseInt(request.getParameter("scheduleId"));
            String rejectionReason = request.getParameter("rejectionReason");
            
            if (rejectionReason == null || rejectionReason.trim().isEmpty()) {
                session.setAttribute("errorMessage", "Vui lòng nhập lý do từ chối");
                response.sendRedirect("reviewMaintenanceReport");
                return;
            }
            
            // Update schedule status to rejected
            boolean success = maintenanceScheduleDAO.updateScheduleStatus(scheduleId, "Rejected");
            
            if (success) {
                // TODO: Add rejection reason to a comments table if needed
                session.setAttribute("successMessage", "Báo cáo bảo trì đã bị từ chối!");
            } else {
                session.setAttribute("errorMessage", "Không thể từ chối báo cáo bảo trì");
            }
            
        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "ID lịch bảo trì không hợp lệ");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error rejecting report", e);
            session.setAttribute("errorMessage", "Lỗi cơ sở dữ liệu: " + e.getMessage());
        }
        
        response.sendRedirect("reviewMaintenanceReport");
    }
    
    /**
     * Handle requesting revision for a maintenance report
     */
    private void handleRequestRevision(HttpServletRequest request, HttpServletResponse response, 
                                     HttpSession session) throws IOException {
        
        try {
            int scheduleId = Integer.parseInt(request.getParameter("scheduleId"));
            String revisionComments = request.getParameter("revisionComments");
            
            if (revisionComments == null || revisionComments.trim().isEmpty()) {
                session.setAttribute("errorMessage", "Vui lòng nhập yêu cầu chỉnh sửa");
                response.sendRedirect("reviewMaintenanceReport");
                return;
            }
            
            // Update schedule status to revision requested
            boolean success = maintenanceScheduleDAO.updateScheduleStatus(scheduleId, "Revision Requested");
            
            if (success) {
                // TODO: Add revision comments to a comments table if needed
                session.setAttribute("successMessage", "Đã yêu cầu chỉnh sửa báo cáo bảo trì!");
            } else {
                session.setAttribute("errorMessage", "Không thể yêu cầu chỉnh sửa báo cáo bảo trì");
            }
            
        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "ID lịch bảo trì không hợp lệ");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error requesting revision", e);
            session.setAttribute("errorMessage", "Lỗi cơ sở dữ liệu: " + e.getMessage());
        }
        
        response.sendRedirect("reviewMaintenanceReport");
    }
    
    /**
     * Handle adding comments to a maintenance report
     */
    private void handleAddComment(HttpServletRequest request, HttpServletResponse response, 
                                HttpSession session) throws IOException {
        
        try {
            int scheduleId = Integer.parseInt(request.getParameter("scheduleId"));
            String comment = request.getParameter("comment");
            
            if (comment == null || comment.trim().isEmpty()) {
                session.setAttribute("errorMessage", "Vui lòng nhập nội dung bình luận");
                response.sendRedirect("reviewMaintenanceReport");
                return;
            }
            
            // TODO: Add comment to a comments table
            // For now, we'll just show a success message
            session.setAttribute("successMessage", "Đã thêm bình luận thành công!");
            
        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "ID lịch bảo trì không hợp lệ");
        }
        
        response.sendRedirect("reviewMaintenanceReport");
    }
    
    /**
     * Handle updating report status
     */
    private void handleUpdateReportStatus(HttpServletRequest request, HttpServletResponse response, 
                                        HttpSession session) throws IOException {
        
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        
        try {
            int scheduleId = Integer.parseInt(request.getParameter("scheduleId"));
            String newStatus = request.getParameter("status");
            
            boolean success = maintenanceScheduleDAO.updateScheduleStatus(scheduleId, newStatus);
            
            JsonObject response_obj = new JsonObject();
            if (success) {
                response_obj.addProperty("success", true);
                response_obj.addProperty("message", "Cập nhật trạng thái thành công");
            } else {
                response_obj.addProperty("success", false);
                response_obj.addProperty("error", "Không thể cập nhật trạng thái");
            }
            
            out.print(gson.toJson(response_obj));
            
        } catch (NumberFormatException e) {
            JsonObject errorResponse = new JsonObject();
            errorResponse.addProperty("success", false);
            errorResponse.addProperty("error", "ID lịch bảo trì không hợp lệ");
            out.print(gson.toJson(errorResponse));
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error updating report status", e);
            JsonObject errorResponse = new JsonObject();
            errorResponse.addProperty("success", false);
            errorResponse.addProperty("error", "Lỗi cơ sở dữ liệu: " + e.getMessage());
            out.print(gson.toJson(errorResponse));
        }
    }
}