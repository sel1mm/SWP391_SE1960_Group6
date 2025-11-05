package controller;

import dal.MaintenanceScheduleDAO;
import dal.ServiceRequestDAO;
import dal.TechnicianWorkloadDAO;
import dal.EquipmentDAO;
import dal.ContractDAO;
import dal.WorkTaskDAO;
import model.WorkTask;
import model.Account;
import model.MaintenanceSchedule;
import model.ServiceRequest;
import model.TechnicianWorkload;
import model.Equipment;
import model.Contract;
import com.google.gson.GsonBuilder;
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
            
            List<Contract> contractList = contractDAO.getEveryContracts();
            request.setAttribute("contractList", contractList);

            List<Equipment> equipmentList = equipmentDAO.getAllEquipment();
            request.setAttribute("equipmentList", equipmentList);
            
            // ===== XỬ LÝ THAM SỐ TỪ URL =====
            String requestIdParam = request.getParameter("requestId");
            String contractIdParam = request.getParameter("contractId");
            String priorityParam = request.getParameter("priority");
            
            // Truyền các tham số sang JSP để pre-fill form
            if (requestIdParam != null && !requestIdParam.trim().isEmpty()) {
                request.setAttribute("prefilledRequestId", requestIdParam);
            }
            
            if (contractIdParam != null && !contractIdParam.trim().isEmpty()) {
                request.setAttribute("prefilledContractId", contractIdParam);
            }
            
            if (priorityParam != null && !priorityParam.trim().isEmpty()) {
                // Map priority level sang priorityId
                int priorityId = 2; // Default: Trung Bình
                switch(priorityParam) {
                    case "Urgent":
                        priorityId = 4; // Khẩn Cấp
                        break;
                    case "High":
                        priorityId = 3; // Cao
                        break;
                    case "Normal":
                        priorityId = 2; // Trung Bình
                        break;
                    default:
                        priorityId = 1; // Thấp
                        break;
                }
                request.setAttribute("prefilledPriorityId", priorityId);
            }
            
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
        // --- Lấy thông tin từ form ---
        String requestIdStr = request.getParameter("requestId");
        String contractIdStr = request.getParameter("contractId");
        String equipmentIdStr = request.getParameter("equipmentId");
        String assignedToStr = request.getParameter("assignedTo");
        String scheduledDateStr = request.getParameter("scheduledDate");
        String scheduleType = request.getParameter("scheduleType");
        String recurrenceRule = request.getParameter("recurrenceRule");
        String priorityIdStr = request.getParameter("priorityId");

        // --- Validate thông tin bắt buộc ---
        if (scheduledDateStr == null || scheduledDateStr.trim().isEmpty() ||
            assignedToStr == null || assignedToStr.trim().isEmpty() ||
            scheduleType == null || scheduleType.trim().isEmpty()) {
            session.setAttribute("errorMessage", "Vui lòng điền đầy đủ thông tin bắt buộc!");
            response.sendRedirect("scheduleMaintenance");
            return;
        }

        // --- Parse thông tin ---
        Integer requestId = (requestIdStr != null && !requestIdStr.trim().isEmpty()) ? Integer.parseInt(requestIdStr) : null;
        Integer contractId = (contractIdStr != null && !contractIdStr.trim().isEmpty()) ? Integer.parseInt(contractIdStr) : null;
        Integer equipmentId = (equipmentIdStr != null && !equipmentIdStr.trim().isEmpty()) ? Integer.parseInt(equipmentIdStr) : null;
        int assignedTo = Integer.parseInt(assignedToStr);
        int priorityId = (priorityIdStr != null && !priorityIdStr.trim().isEmpty()) ? Integer.parseInt(priorityIdStr) : 2;

        // --- Chuyển đổi ngày giờ ---
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
        java.util.Date parsedDate = dateFormat.parse(scheduledDateStr);
        Timestamp scheduledTimestamp = new Timestamp(parsedDate.getTime());
        LocalDate scheduledDate = scheduledTimestamp.toLocalDateTime().toLocalDate();

        // --- Kiểm tra khả năng KTV THEO PRIORITY ---
        TechnicianWorkload technicianWorkload = technicianWorkloadDAO.getWorkloadByTechnician(assignedTo);
        if (technicianWorkload == null) {
            session.setAttribute("errorMessage", "Không tìm thấy thông tin workload của kỹ thuật viên!");
            response.sendRedirect("scheduleMaintenance");
            return;
        }

        // Tính workload points theo priority
        int workloadPoints = calculateWorkloadPoints(priorityId);
        int maxCapacity = technicianWorkload.getMaxConcurrentTasks();
        int currentLoad = technicianWorkload.getCurrentActiveTasks();
        int newTotalLoad = currentLoad + workloadPoints;

        // ✅ KIỂM TRA VƯỢT QUÁ GIỚI HẠN
        if (newTotalLoad > maxCapacity) {
            String priorityName = priorityId == 4 ? "Khẩn Cấp" : 
                                  priorityId == 3 ? "Cao" : 
                                  priorityId == 2 ? "Trung Bình" : "Thấp";
            
            session.setAttribute("errorMessage", 
                String.format("⚠️ KHÔNG THỂ PHÂN CÔNG! Kỹ thuật viên #%d đang có %d/%d points. " +
                              "Độ ưu tiên '%s' cần +%d points → Tổng sẽ là %d/%d (VƯỢT QUÁ GIỚI HẠN). " +
                              "Vui lòng chọn kỹ thuật viên khác hoặc giảm độ ưu tiên!",
                              assignedTo, currentLoad, maxCapacity, priorityName, 
                              workloadPoints, newTotalLoad, maxCapacity));
            response.sendRedirect("scheduleMaintenance");
            return;
        }

        // --- Tạo MaintenanceSchedule ---
        MaintenanceSchedule schedule = new MaintenanceSchedule();
        if (requestId != null) schedule.setRequestId(requestId);
        if (contractId != null) schedule.setContractId(contractId);
        if (equipmentId != null) schedule.setEquipmentId(equipmentId);

        schedule.setAssignedTo(assignedTo);
        schedule.setScheduledDate(scheduledDate);
        schedule.setScheduleType(scheduleType);
        schedule.setRecurrenceRule(recurrenceRule);
        schedule.setStatus("Scheduled");
        schedule.setPriorityId(priorityId);

        int scheduleId = maintenanceScheduleDAO.createMaintenanceSchedule(schedule);

        if (scheduleId > 0) {
            // ✅ TẠO WORKTASK
            WorkTaskDAO workTaskDAO = new WorkTaskDAO();
            WorkTask task = new WorkTask();
            task.setScheduleId(scheduleId);
            task.setRequestId(requestId);
            task.setTechnicianId(assignedTo);
            task.setTaskType("Scheduled");
            task.setTaskDetails("Bảo trì " + scheduleType + 
                                (equipmentId != null ? " thiết bị #" + equipmentId : ""));
            task.setStartDate(scheduledDate);
            task.setEndDate(scheduledDate);
            task.setStatus("Assigned");

            int taskId = workTaskDAO.createWorkTask(task);

            if (taskId > 0) {
                // ✅ QUAN TRỌNG: Trigger đã tự động cộng 1, giờ cộng thêm (workloadPoints - 1)
                int additionalPoints = workloadPoints - 1; // Urgent: 3-1=2, High: 2-1=1, Normal: 1-1=0
                
                if (additionalPoints > 0) {
                    boolean workloadUpdated = technicianWorkloadDAO.incrementWorkloadByPoints(assignedTo, additionalPoints);
                    
                    if (workloadUpdated) {
                        session.setAttribute("successMessage", 
                            String.format("✅ Lập lịch bảo trì thành công! KTV #%d nhận +%d points (Priority: %s)", 
                                assignedTo, workloadPoints, 
                                priorityId == 4 ? "Urgent" : priorityId == 3 ? "High" : "Normal"));
                    } else {
                        session.setAttribute("successMessage", "Lập lịch thành công nhưng cập nhật workload thất bại!");
                    }
                } else {
                    // Normal priority: trigger đã cộng đủ rồi
                    session.setAttribute("successMessage", 
                        String.format("✅ Lập lịch bảo trì thành công! KTV #%d nhận +%d point (Priority: Normal)", 
                            assignedTo, workloadPoints));
                }
            } else {
                session.setAttribute("errorMessage", "Lập lịch thành công nhưng tạo công việc thất bại!");
            }
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
        String scheduledDateStr = request.getParameter("scheduledDate");
        String scheduleType = request.getParameter("scheduleType");
        String recurrenceRule = request.getParameter("recurrenceRule");
        // ❌ BỎ: String status = request.getParameter("status");
        String priorityIdStr = request.getParameter("priorityId");
        
        // Validate required parameters
        if (scheduleIdStr == null || scheduleIdStr.trim().isEmpty()) {
            session.setAttribute("errorMessage", "Thiếu thông tin ID lịch bảo trì!");
            response.sendRedirect("scheduleMaintenance");
            return;
        }
        
        if (scheduledDateStr == null || scheduledDateStr.trim().isEmpty()) {
            session.setAttribute("errorMessage", "Thiếu thông tin ngày bảo trì!");
            response.sendRedirect("scheduleMaintenance");
            return;
        }
        
        if (scheduleType == null || scheduleType.trim().isEmpty()) {
            session.setAttribute("errorMessage", "Thiếu thông tin loại bảo trì!");
            response.sendRedirect("scheduleMaintenance");
            return;
        }
        
        int scheduleId = Integer.parseInt(scheduleIdStr.trim());
        int priorityId = (priorityIdStr != null && !priorityIdStr.trim().isEmpty()) 
                        ? Integer.parseInt(priorityIdStr.trim()) : 2;
        
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
        
        // ✅ Update schedule properties (KHÔNG cập nhật status)
        existingSchedule.setScheduledDate(scheduledDate);
        existingSchedule.setScheduleType(scheduleType);
        existingSchedule.setRecurrenceRule((recurrenceRule != null && !recurrenceRule.trim().isEmpty()) 
                                          ? recurrenceRule : null);
        // ❌ BỎ: existingSchedule.setStatus(status);
        existingSchedule.setPriorityId(priorityId);
        
        boolean success = maintenanceScheduleDAO.updateMaintenanceSchedule(existingSchedule);

if (success) {
    // ✅ ĐIỀU CHỈNH WORKLOAD KHI THAY ĐỔI PRIORITY
    MaintenanceSchedule oldSchedule = maintenanceScheduleDAO.getScheduleById(scheduleId);
    if (oldSchedule != null && oldSchedule.getPriorityId() != priorityId) {
        int oldPoints = calculateWorkloadPoints(oldSchedule.getPriorityId());
        int newPoints = calculateWorkloadPoints(priorityId);
        int diff = newPoints - oldPoints;
        
        if (diff > 0) {
            technicianWorkloadDAO.incrementWorkloadByPoints(existingSchedule.getAssignedTo(), diff);
        } else if (diff < 0) {
            technicianWorkloadDAO.decrementWorkloadByPoints(existingSchedule.getAssignedTo(), Math.abs(diff));
        }
    }
    
    session.setAttribute("successMessage", "Cập nhật lịch bảo trì thành công!");} else {
            session.setAttribute("errorMessage", "Lỗi khi cập nhật lịch bảo trì!");
        }
        
    } catch (ParseException e) {
        e.printStackTrace();
        session.setAttribute("errorMessage", "Định dạng ngày giờ không hợp lệ!");
    } catch (NumberFormatException e) {
        e.printStackTrace();
        session.setAttribute("errorMessage", "Dữ liệu số không hợp lệ!");
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

        if (scheduleIdStr == null || scheduleIdStr.trim().isEmpty()) {
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("error", "Thiếu thông tin ID lịch bảo trì!");
            out.print(gson.toJson(jsonResponse));
            return;
        }

        int scheduleId = Integer.parseInt(scheduleIdStr.trim());

        // Lấy lịch bảo trì hiện tại
        MaintenanceSchedule existingSchedule = maintenanceScheduleDAO.getScheduleById(scheduleId);
        if (existingSchedule == null) {
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("error", "Không tìm thấy lịch bảo trì!");
            out.print(gson.toJson(jsonResponse));
            return;
        }

        // Không cho xóa nếu Completed hoặc In Progress
        if ("Completed".equals(existingSchedule.getStatus()) ||
            "In Progress".equals(existingSchedule.getStatus())) {
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("error", "Không thể xóa lịch bảo trì đã hoàn thành hoặc đang thực hiện!");
            out.print(gson.toJson(jsonResponse));
            return;
        }

        // ✅ BƯỚC 1: Tính workload points cần giảm
        int workloadPoints = calculateWorkloadPoints(existingSchedule.getPriorityId());

        // ✅ BƯỚC 2: Xóa tất cả WorkTask liên quan
        WorkTaskDAO workTaskDAO = new WorkTaskDAO();
        List<WorkTask> tasks = workTaskDAO.findByScheduleId(scheduleId);
        for (WorkTask task : tasks) {
            workTaskDAO.deleteTaskById(task.getTaskId());
        }

        // ✅ BƯỚC 3: Xóa MaintenanceSchedule
        boolean success = maintenanceScheduleDAO.deleteMaintenanceSchedule(scheduleId);

        if (success) {
            // ✅ BƯỚC 4: Giảm workload theo ĐÚNG priority
            if (existingSchedule.getAssignedTo() > 0) {
                technicianWorkloadDAO.decrementWorkloadByPoints(existingSchedule.getAssignedTo(), workloadPoints);
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

    // ✅ Gson custom để serialize LocalDate / LocalDateTime
    Gson gson = new GsonBuilder()
        .registerTypeAdapter(LocalDate.class,
            (com.google.gson.JsonSerializer<LocalDate>) (date, type, context) ->
                new com.google.gson.JsonPrimitive(date.format(DateTimeFormatter.ISO_LOCAL_DATE)))
        .registerTypeAdapter(LocalDateTime.class,
            (com.google.gson.JsonSerializer<LocalDateTime>) (dateTime, type, context) ->
                new com.google.gson.JsonPrimitive(dateTime.format(DateTimeFormatter.ISO_LOCAL_DATE_TIME)))
        .create();

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

    // ✅ Gson custom để serialize LocalDate / LocalDateTime
    Gson gson = new GsonBuilder()
        .registerTypeAdapter(LocalDate.class,
            (com.google.gson.JsonSerializer<LocalDate>) (date, type, context) ->
                new com.google.gson.JsonPrimitive(date.format(DateTimeFormatter.ISO_LOCAL_DATE)))
        .registerTypeAdapter(LocalDateTime.class,
            (com.google.gson.JsonSerializer<LocalDateTime>) (dateTime, type, context) ->
                new com.google.gson.JsonPrimitive(dateTime.format(DateTimeFormatter.ISO_LOCAL_DATE_TIME)))
        .create();

    try {
        String daysStr = request.getParameter("days");

        // Validate days parameter - default to 7
        int days = 7;
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

    // Gson custom để serialize LocalDate / LocalDateTime
    Gson gson = new GsonBuilder()
        .registerTypeAdapter(LocalDate.class,
            (com.google.gson.JsonSerializer<LocalDate>) (date, type, context) ->
                new com.google.gson.JsonPrimitive(date.format(DateTimeFormatter.ISO_LOCAL_DATE)))
        .registerTypeAdapter(LocalDateTime.class,
            (com.google.gson.JsonSerializer<LocalDateTime>) (dateTime, type, context) ->
                new com.google.gson.JsonPrimitive(dateTime.format(DateTimeFormatter.ISO_LOCAL_DATE_TIME)))
        .create();

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

    /**
 * Calculate workload points based on priority level
 * Urgent = 3, High = 2, Normal = 1
 */
private int calculateWorkloadPoints(int priorityId) {
    switch (priorityId) {
        case 4: return 3; // Urgent
        case 3: return 2; // High
        case 2: return 1; // Normal
        case 1: return 1; // Low (treated as Normal)
        default: return 1;
    }
}
} 
