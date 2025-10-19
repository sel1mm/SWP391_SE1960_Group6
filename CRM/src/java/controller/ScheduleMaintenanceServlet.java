package controller;

import dal.MaintenanceScheduleDAO;
import dal.ServiceRequestDAO;
import dal.TechnicianWorkloadDAO;
import dal.EquipmentDAO;
import dal.ContractDAO;
import model.Account;
import model.MaintenanceSchedule;
import model.ServiceRequest;
import model.TechnicianWorkload;
import model.Equipment;
import model.Contract;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Date;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.util.List;
import java.util.ArrayList;
import java.util.Calendar;
import com.google.gson.Gson;
import com.google.gson.JsonObject;

@WebServlet(name = "ScheduleMaintenanceServlet", urlPatterns = {"/scheduleMaintenance"})
public class ScheduleMaintenanceServlet extends HttpServlet {
    
    private MaintenanceScheduleDAO maintenanceScheduleDAO;
    private ServiceRequestDAO serviceRequestDAO;
    private TechnicianWorkloadDAO technicianWorkloadDAO;
    private EquipmentDAO equipmentDAO;
    private ContractDAO contractDAO;
    
    @Override
    public void init() throws ServletException {
        super.init();
        maintenanceScheduleDAO = new MaintenanceScheduleDAO();
        serviceRequestDAO = new ServiceRequestDAO();
        technicianWorkloadDAO = new TechnicianWorkloadDAO();
        equipmentDAO = new EquipmentDAO();
        contractDAO = new ContractDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
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
            if ("getScheduleDetails".equals(action)) {
                getScheduleDetails(request, response);
                return;
            } else if ("getUpcomingSchedules".equals(action)) {
                getUpcomingSchedules(request, response);
                return;
            } else if ("getOverdueSchedules".equals(action)) {
                getOverdueSchedules(request, response);
                return;
            }
            
            // Load data for the main page
            loadMainPageData(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMessage", "Lỗi hệ thống: " + e.getMessage());
            request.getRequestDispatcher("ScheduleMaintenance.jsp").forward(request, response);
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
            if ("createSchedule".equals(action)) {
                createMaintenanceSchedule(request, response);
            } else if ("updateSchedule".equals(action)) {
                updateMaintenanceSchedule(request, response);
            } else if ("deleteSchedule".equals(action)) {
                deleteMaintenanceSchedule(request, response);
            } else if ("updateStatus".equals(action)) {
                updateScheduleStatus(request, response);
            } else {
                response.sendRedirect("scheduleMaintenance");
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMessage", "Lỗi hệ thống: " + e.getMessage());
            response.sendRedirect("scheduleMaintenance");
        }
    }
    
    private void loadMainPageData(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            // Get approved service requests that need maintenance scheduling
            List<ServiceRequest> approvedRequests = serviceRequestDAO.getRequestsByStatus("Approved");
            request.setAttribute("approvedRequests", approvedRequests);
            
            // Get available technicians
            List<TechnicianWorkload> availableTechnicians = technicianWorkloadDAO.getAvailableTechnicians();
            request.setAttribute("availableTechnicians", availableTechnicians);
            
            // Get all maintenance schedules
            List<MaintenanceSchedule> allSchedules = maintenanceScheduleDAO.getAllMaintenanceSchedules();
            request.setAttribute("allSchedules", allSchedules);
            
            // Get upcoming schedules (next 7 days)
            List<MaintenanceSchedule> upcomingSchedules = maintenanceScheduleDAO.getUpcomingSchedules();
            request.setAttribute("upcomingSchedules", upcomingSchedules);
            
            // Get overdue schedules
            List<MaintenanceSchedule> overdueSchedules = maintenanceScheduleDAO.getOverdueSchedules();
            request.setAttribute("overdueSchedules", overdueSchedules);
            
            // Equipment list will be loaded via AJAX or other means
            
            // Get contracts for dropdown
            // Contract list will be loaded via AJAX or other means
            
            request.getRequestDispatcher("ScheduleMaintenance.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "Lỗi khi tải dữ liệu: " + e.getMessage());
            request.getRequestDispatcher("ScheduleMaintenance.jsp").forward(request, response);
        }
    }
    
    private void createMaintenanceSchedule(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        try {
            // Get form parameters
            String requestIdStr = request.getParameter("requestId");
            String contractIdStr = request.getParameter("contractId");
            String equipmentIdStr = request.getParameter("equipmentId");
            String assignedToStr = request.getParameter("assignedTo");
            String scheduledDateStr = request.getParameter("scheduledDate");
            String scheduleType = request.getParameter("scheduleType");
            String recurrenceRule = request.getParameter("recurrenceRule");
            String priorityIdStr = request.getParameter("priorityId");
            
            // Validate required fields
            if (scheduledDateStr == null || scheduledDateStr.trim().isEmpty() ||
                assignedToStr == null || assignedToStr.trim().isEmpty() ||
                scheduleType == null || scheduleType.trim().isEmpty()) {
                session.setAttribute("errorMessage", "Vui lòng điền đầy đủ thông tin bắt buộc!");
                response.sendRedirect("scheduleMaintenance");
                return;
            }
            
            // Parse and validate parameters with null checks
            Integer requestId = null;
            if (requestIdStr != null && !requestIdStr.trim().isEmpty()) {
                requestId = Integer.parseInt(requestIdStr);
            }
            
            Integer contractId = null;
            if (contractIdStr != null && !contractIdStr.trim().isEmpty()) {
                contractId = Integer.parseInt(contractIdStr);
            }
            // Allow contractId to remain null if not provided
            
            Integer equipmentId = null;
            if (equipmentIdStr != null && !equipmentIdStr.trim().isEmpty()) {
                equipmentId = Integer.parseInt(equipmentIdStr);
            }
            // Allow equipmentId to remain null if not provided
            int assignedTo = Integer.parseInt(assignedToStr);
            int priorityId = (priorityIdStr != null && !priorityIdStr.trim().isEmpty()) ? 
                            Integer.parseInt(priorityIdStr) : 1;
            
            // Parse scheduled date
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
            java.util.Date parsedDate = dateFormat.parse(scheduledDateStr);
            Timestamp scheduledTimestamp = new Timestamp(parsedDate.getTime());
            LocalDate scheduledDate = scheduledTimestamp.toLocalDateTime().toLocalDate();
            
            // Check technician availability
            TechnicianWorkload technicianWorkload = technicianWorkloadDAO.getWorkloadByTechnician(assignedTo);
            if (technicianWorkload == null || technicianWorkload.getAvailableCapacity() <= 0) {
                session.setAttribute("errorMessage", "Kỹ thuật viên đã chọn không có khả năng nhận thêm công việc!");
                response.sendRedirect("scheduleMaintenance");
                return;
            }
            
            // Create maintenance schedule
            MaintenanceSchedule schedule = new MaintenanceSchedule();
            
            // Set requestId with null check
            if (requestId != null) {
                schedule.setRequestId(requestId);
            }
            
            // Set contractId with null check
            if (contractId != null) {
                schedule.setContractId(contractId);
            }
            // Allow contractId to remain null if not provided
            
            // Set equipmentId with null check
            if (equipmentId != null) {
                schedule.setEquipmentId(equipmentId);
            }
            // Allow equipmentId to remain null if not provided
            
            schedule.setAssignedTo(assignedTo);
            schedule.setScheduledDate(scheduledDate);
            schedule.setScheduleType(scheduleType);
            schedule.setRecurrenceRule(recurrenceRule);
            schedule.setStatus("Scheduled");
            schedule.setPriorityId(priorityId);
            
            int scheduleId = maintenanceScheduleDAO.createMaintenanceSchedule(schedule);
            
            if (scheduleId > 0) {
                // Update technician workload
                technicianWorkloadDAO.incrementActiveTasks(assignedTo);
                
                session.setAttribute("successMessage", "Lập lịch bảo trì thành công!");
            } else {
                session.setAttribute("errorMessage", "Lỗi khi lập lịch bảo trì!");
            }
            
        } catch (ParseException e) {
            session.setAttribute("errorMessage", "Định dạng ngày giờ không hợp lệ!");
        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "Dữ liệu số không hợp lệ!");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMessage", "Lỗi hệ thống: " + e.getMessage());
        }
        
        response.sendRedirect("scheduleMaintenance");
    }
    
    private void updateMaintenanceSchedule(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        try {
            String scheduleIdStr = request.getParameter("scheduleId");
            String priorityIdStr = request.getParameter("priorityId");
            
            // Validate required parameters
            if (scheduleIdStr == null || scheduleIdStr.trim().isEmpty()) {
                session.setAttribute("errorMessage", "Thiếu thông tin ID lịch bảo trì!");
                response.sendRedirect("scheduleMaintenance");
                return;
            }
            
            if (priorityIdStr == null || priorityIdStr.trim().isEmpty()) {
                session.setAttribute("errorMessage", "Thiếu thông tin mức độ ưu tiên!");
                response.sendRedirect("scheduleMaintenance");
                return;
            }
            
            int scheduleId = Integer.parseInt(scheduleIdStr.trim());
            String scheduledDateStr = request.getParameter("scheduledDate");
            String scheduleType = request.getParameter("scheduleType");
            String recurrenceRule = request.getParameter("recurrenceRule");
            String status = request.getParameter("status");
            int priorityId = Integer.parseInt(priorityIdStr.trim());
            
            // Parse scheduled date
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
            java.util.Date parsedDate = dateFormat.parse(scheduledDateStr);
            Timestamp scheduledTimestamp = new Timestamp(parsedDate.getTime());
            LocalDate scheduledDate = scheduledTimestamp.toLocalDateTime().toLocalDate();
            
            // Get existing schedule
            MaintenanceSchedule existingSchedule = maintenanceScheduleDAO.getScheduleById(scheduleId);
            if (existingSchedule == null) {
                session.setAttribute("errorMessage", "Không tìm thấy lịch bảo trì!");
                response.sendRedirect("scheduleMaintenance");
                return;
            }
            
            // Update schedule
            existingSchedule.setScheduledDate(scheduledDate);
            existingSchedule.setScheduleType(scheduleType);
            existingSchedule.setRecurrenceRule(recurrenceRule);
            existingSchedule.setStatus(status);
            existingSchedule.setPriorityId(priorityId);
            
            boolean success = maintenanceScheduleDAO.updateMaintenanceSchedule(existingSchedule);
            
            if (success) {
                session.setAttribute("successMessage", "Cập nhật lịch bảo trì thành công!");
            } else {
                session.setAttribute("errorMessage", "Lỗi khi cập nhật lịch bảo trì!");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMessage", "Lỗi hệ thống: " + e.getMessage());
        }
        
        response.sendRedirect("scheduleMaintenance");
    }
    
    private void deleteMaintenanceSchedule(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        Gson gson = new Gson();
        JsonObject jsonResponse = new JsonObject();
        
        try {
            String scheduleIdStr = request.getParameter("scheduleId");
            
            // Validate scheduleId parameter
            if (scheduleIdStr == null || scheduleIdStr.trim().isEmpty()) {
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("error", "Thiếu thông tin ID lịch bảo trì!");
                out.print(gson.toJson(jsonResponse));
                out.flush();
                return;
            }
            
            int scheduleId = Integer.parseInt(scheduleIdStr.trim());
            
            // Get existing schedule to check status
            MaintenanceSchedule existingSchedule = maintenanceScheduleDAO.getScheduleById(scheduleId);
            if (existingSchedule == null) {
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("error", "Không tìm thấy lịch bảo trì!");
                out.print(gson.toJson(jsonResponse));
                return;
            }
            
            // Don't allow deletion of completed or in-progress schedules
            if ("Completed".equals(existingSchedule.getStatus()) || 
                "In Progress".equals(existingSchedule.getStatus())) {
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("error", "Không thể xóa lịch bảo trì đã hoàn thành hoặc đang thực hiện!");
                out.print(gson.toJson(jsonResponse));
                return;
            }
            
            boolean success = maintenanceScheduleDAO.deleteMaintenanceSchedule(scheduleId);
            
            if (success) {
                // Update technician workload if schedule was assigned
                if (existingSchedule.getAssignedTo() > 0) {
                    technicianWorkloadDAO.decrementActiveTasks(existingSchedule.getAssignedTo());
                }
                
                jsonResponse.addProperty("success", true);
                jsonResponse.addProperty("message", "Xóa lịch bảo trì thành công!");
            } else {
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("error", "Lỗi khi xóa lịch bảo trì!");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("error", "Lỗi hệ thống: " + e.getMessage());
        }
        
        out.print(gson.toJson(jsonResponse));
        out.flush();
    }
    
    private void updateScheduleStatus(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        Gson gson = new Gson();
        JsonObject jsonResponse = new JsonObject();
        
        try {
            String scheduleIdStr = request.getParameter("scheduleId");
            
            // Validate scheduleId parameter
            if (scheduleIdStr == null || scheduleIdStr.trim().isEmpty()) {
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("error", "Thiếu thông tin ID lịch bảo trì!");
                out.print(gson.toJson(jsonResponse));
                out.flush();
                return;
            }
            
            int scheduleId = Integer.parseInt(scheduleIdStr.trim());
            String newStatus = request.getParameter("status");
            
            boolean success = maintenanceScheduleDAO.updateScheduleStatus(scheduleId, newStatus);
            
            if (success) {
                // If status is completed, update technician workload
                if ("Completed".equals(newStatus)) {
                    MaintenanceSchedule schedule = maintenanceScheduleDAO.getScheduleById(scheduleId);
                    if (schedule != null && schedule.getAssignedTo() > 0) {
                        technicianWorkloadDAO.decrementActiveTasks(schedule.getAssignedTo());
                    }
                }
                
                jsonResponse.addProperty("success", true);
                jsonResponse.addProperty("message", "Cập nhật trạng thái thành công!");
            } else {
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("error", "Lỗi khi cập nhật trạng thái!");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("error", "Lỗi hệ thống: " + e.getMessage());
        }
        
        out.print(gson.toJson(jsonResponse));
        out.flush();
    }
    
    private void getScheduleDetails(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        Gson gson = new Gson();
        
        try {
            String scheduleIdStr = request.getParameter("scheduleId");
            
            // Validate scheduleId parameter
            if (scheduleIdStr == null || scheduleIdStr.trim().isEmpty()) {
                JsonObject errorResponse = new JsonObject();
                errorResponse.addProperty("error", "Thiếu thông tin ID lịch bảo trì!");
                out.print(gson.toJson(errorResponse));
                out.flush();
                return;
            }
            
            int scheduleId = Integer.parseInt(scheduleIdStr.trim());
            MaintenanceSchedule schedule = maintenanceScheduleDAO.getScheduleById(scheduleId);
            
            if (schedule != null) {
                out.print(gson.toJson(schedule));
            } else {
                JsonObject errorResponse = new JsonObject();
                errorResponse.addProperty("error", "Không tìm thấy lịch bảo trì!");
                out.print(gson.toJson(errorResponse));
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            JsonObject errorResponse = new JsonObject();
            errorResponse.addProperty("error", "Lỗi hệ thống: " + e.getMessage());
            out.print(gson.toJson(errorResponse));
        }
        
        out.flush();
    }
    
    private void getUpcomingSchedules(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        Gson gson = new Gson();
        
        try {
            String daysStr = request.getParameter("days");
            
            // Validate days parameter - use default if not provided
            int days = 7; // default to 7 days
            if (daysStr != null && !daysStr.trim().isEmpty()) {
                days = Integer.parseInt(daysStr.trim());
            }
            
            List<MaintenanceSchedule> upcomingSchedules = maintenanceScheduleDAO.getUpcomingSchedules();
            out.print(gson.toJson(upcomingSchedules));
            
        } catch (Exception e) {
            e.printStackTrace();
            JsonObject errorResponse = new JsonObject();
            errorResponse.addProperty("error", "Lỗi hệ thống: " + e.getMessage());
            out.print(gson.toJson(errorResponse));
        }
        
        out.flush();
    }
    
    private void getOverdueSchedules(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        Gson gson = new Gson();
        
        try {
            List<MaintenanceSchedule> overdueSchedules = maintenanceScheduleDAO.getOverdueSchedules();
            out.print(gson.toJson(overdueSchedules));
            
        } catch (Exception e) {
            e.printStackTrace();
            JsonObject errorResponse = new JsonObject();
            errorResponse.addProperty("error", "Lỗi hệ thống: " + e.getMessage());
            out.print(gson.toJson(errorResponse));
        }
        
        out.flush();
    }
}