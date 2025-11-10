package controller;

import dal.AccountDAO;
import dal.WorkAssignmentDAO;
import dal.TechnicianWorkloadDAO;
import dal.ServiceRequestDAO;
import dal.TechnicianSkillDAO;
import dal.WorkTaskDAO;
import model.WorkAssignment;
import model.TechnicianWorkload;
import model.ServiceRequest;
import model.TechnicianSkill;
import model.Account;
import model.WorkTask;
import service.AccountRoleService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;

@WebServlet(name = "AssignWorkServlet", urlPatterns = {"/assignWork"})
public class AssignWorkServlet extends HttpServlet {

    private WorkAssignmentDAO workAssignmentDAO;
    private TechnicianWorkloadDAO technicianWorkloadDAO;
    private ServiceRequestDAO serviceRequestDAO;
    private TechnicianSkillDAO technicianSkillDAO;
    private AccountRoleService accountRoleService;

    @Override
    public void init() throws ServletException {
        workAssignmentDAO = new WorkAssignmentDAO();
        technicianWorkloadDAO = new TechnicianWorkloadDAO();
        serviceRequestDAO = new ServiceRequestDAO();
        technicianSkillDAO = new TechnicianSkillDAO();
        accountRoleService = new AccountRoleService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        Account loggedInAccount = (Account) session.getAttribute("session_login");
        Integer accountId = (Integer) session.getAttribute("session_login_id");
        String userRole = (String) session.getAttribute("session_role");

        if (accountId == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        if (!"Technical Manager".equals(userRole)) {
            response.sendRedirect(request.getContextPath() + "/dashboard.jsp");
            return;
        }

        String action = request.getParameter("action");
        String requestIdParam = request.getParameter("requestId");
        String priorityParam = request.getParameter("priority");
        
        try {
            if ("getAvailableTechnicians".equals(action)) {
                handleGetAvailableTechnicians(request, response);
            } else if ("getServiceRequests".equals(action)) {
                handleGetServiceRequests(request, response);
            } else if ("getAssignmentHistory".equals(action)) {
                handleGetAssignmentHistory(request, response, accountId);
            } else {
                displayAssignWorkPage(request, response, accountId, requestIdParam, priorityParam);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error occurred");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        Integer accountId = (Integer) session.getAttribute("session_login_id");
        String userRole = (String) session.getAttribute("session_role");

        if (accountId == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        if (!"Technical Manager".equals(userRole)) {
            response.sendRedirect(request.getContextPath() + "/dashboard.jsp");
            return;
        }

        String action = request.getParameter("action");
        
        try {
            if ("assignWork".equals(action)) {
                handleAssignWork(request, response, accountId, session);
            } else if ("updateAssignment".equals(action)) {
                handleUpdateAssignment(request, response, accountId);
            } else if ("deleteAssignment".equals(action)) {
                handleDeleteAssignment(request, response, accountId);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error occurred");
        }
    }

    /**
     * MAIN METHOD: Handle work assignment with complete validation
     */
/**
 * MAIN METHOD: Handle work assignment with duplicate check
 */
private void handleAssignWork(HttpServletRequest request, HttpServletResponse response, 
                              int managerId, HttpSession session)
        throws ServletException, IOException, SQLException {

    try {
        String requestIdParam = request.getParameter("taskId");
        String[] technicianIds = request.getParameterValues("technicianIds"); // ← Lấy mảng
        String estimatedDurationStr = request.getParameter("estimatedDuration");
        String requiredSkills = request.getParameter("requiredSkills");
        String priority = request.getParameter("priority");

        // Validate
        if (requestIdParam == null || technicianIds == null || technicianIds.length == 0 ||
            estimatedDurationStr == null || estimatedDurationStr.trim().isEmpty()) {
            session.setAttribute("errorMessage", "⚠️ Vui lòng điền đầy đủ thông tin!");
            response.sendRedirect(request.getContextPath() + "/assignWork");
            return;
        }

        int requestId = Integer.parseInt(requestIdParam);
        BigDecimal estimatedDuration = new BigDecimal(estimatedDurationStr);

        if (priority == null || priority.trim().isEmpty()) {
            priority = "Normal";
        }

        // Loop qua từng technician và tạo assignment
        int successCount = 0;
        StringBuilder errors = new StringBuilder();
        
        for (String techIdStr : technicianIds) {
            int technicianId = Integer.parseInt(techIdStr);
            
            // Check duplicate
            if (isDuplicateAssignment(requestId, technicianId)) {
                errors.append("KTV #").append(technicianId).append(" đã được giao việc này rồi. ");
                continue;
            }

            // Check workload
            int workloadPoints = calculateWorkloadPoints(priority);
            TechnicianWorkload workload = technicianWorkloadDAO.getWorkloadByTechnician(technicianId);
            
            if (workload == null) {
                errors.append("Không tìm thấy workload của KTV #").append(technicianId).append(". ");
                continue;
            }

            int maxCapacity = workload.getMaxConcurrentTasks();
            int currentLoad = workload.getCurrentActiveTasks();
            int newTotalLoad = currentLoad + workloadPoints;

            if (newTotalLoad > maxCapacity) {
                errors.append("KTV #").append(technicianId).append(" quá tải. ");
                continue;
            }

            // Create WorkTask
            WorkTaskDAO workTaskDAO = new WorkTaskDAO();
            WorkTask task = new WorkTask();
            task.setRequestId(requestId);
            task.setScheduleId(null);
            task.setTechnicianId(technicianId);
            task.setTaskType("Request");
            task.setTaskDetails("Task generated from service request #" + requestId);
            task.setStartDate(LocalDate.now());
            task.setEndDate(LocalDate.now().plusDays(3));
            task.setStatus("Assigned");

            int taskId = workTaskDAO.createWorkTask(task);
            
            if (taskId <= 0) {
                errors.append("Không thể tạo task cho KTV #").append(technicianId).append(". ");
                continue;
            }

            // Create WorkAssignment
            WorkAssignment assignment = new WorkAssignment();
            assignment.setTaskId(taskId);
            assignment.setAssignedBy(managerId);
            assignment.setAssignedTo(technicianId);
            assignment.setAssignmentDate(LocalDateTime.now());
            assignment.setEstimatedDuration(estimatedDuration);
            assignment.setRequiredSkills(requiredSkills != null ? requiredSkills : "");
            assignment.setPriority(priority);
            assignment.setAcceptedByTechnician(false);

            int assignmentId = workAssignmentDAO.createWorkAssignment(assignment);
            
            if (assignmentId <= 0) {
                workTaskDAO.deleteTaskById(taskId);
                errors.append("Phân công thất bại cho KTV #").append(technicianId).append(". ");
                continue;
            }

            // Update workload
            int additionalPoints = workloadPoints - 1;
            if (additionalPoints > 0) {
                technicianWorkloadDAO.incrementWorkloadByPoints(technicianId, additionalPoints);
            }

            successCount++;
        }

        // Success message
        if (successCount > 0) {
            session.setAttribute("successMessage", 
                String.format("✅ Phân công thành công cho %d kỹ thuật viên!", successCount));
        }
        
        if (errors.length() > 0) {
            session.setAttribute("errorMessage", "⚠️ " + errors.toString());
        }

    } catch (Exception e) {
        session.setAttribute("errorMessage", "❌ Lỗi hệ thống: " + e.getMessage());
        e.printStackTrace();
    }

    response.sendRedirect(request.getContextPath() + "/assignWork");
}

/**
 * Check if a technician already has this request assigned (to prevent duplicates)
 * Returns true if duplicate exists, false otherwise
 */
private boolean isDuplicateAssignment(int requestId, int technicianId) {
    try {
        WorkTaskDAO workTaskDAO = new WorkTaskDAO();
        
        // Tìm tất cả WorkTask của request này
        List<WorkTask> tasksForRequest = workTaskDAO.findByRequestId(requestId);
        
        // Kiểm tra xem có task nào đã được assign cho technician này chưa
        for (WorkTask task : tasksForRequest) {
            if (task.getTechnicianId() == technicianId && 
                !"Completed".equals(task.getStatus()) && 
                !"Cancelled".equals(task.getStatus())) {
                // Tìm thấy task đang active cho cùng technician → Duplicate!
                return true;
            }
        }
        
        return false; // Không có duplicate
        
    } catch (Exception e) {
        System.err.println("Error checking duplicate assignment: " + e.getMessage());
        e.printStackTrace();
        return false; // Nếu lỗi, cho phép assign (tránh block hệ thống)
    }
}


    /**
     * Display the assign work page with all necessary data
     */
    /**
 * Display the assign work page with all necessary data
 */
/**
 * Display the assign work page with all necessary data
 */
/**
 * Display the assign work page with all necessary data
 */
private void displayAssignWorkPage(HttpServletRequest request, HttpServletResponse response, 
                                   int managerId, String preSelectedRequestId, String preSelectedPriority)
        throws ServletException, IOException, SQLException {
    
    List<TechnicianWorkload> availableTechnicians = technicianWorkloadDAO.getTechniciansForAssignment();
    request.setAttribute("availableTechnicians", availableTechnicians);
    
    // ✅ LỌC CÁC REQUEST CHƯA TỪNG CÓ WORKTASK
    List<ServiceRequest> allApprovedRequests = serviceRequestDAO.getRequestsByStatus("Approved");
    List<ServiceRequest> pendingRequests = new ArrayList<>();
    
    WorkTaskDAO workTaskDAO = new WorkTaskDAO();
    
    for (ServiceRequest req : allApprovedRequests) {
        // Kiểm tra xem request này đã có task chưa (bất kể status)
        List<WorkTask> existingTasks = workTaskDAO.findByRequestId(req.getRequestId());
        
        // ✅ NẾU CHƯA CÓ TASK NÀO → Hiển thị
        // ❌ NẾU ĐÃ CÓ TASK (dù Completed hay Active) → Ẩn
        if (existingTasks.isEmpty()) {
            pendingRequests.add(req);
        }
    }
    
    request.setAttribute("pendingRequests", pendingRequests);
    
    List<TechnicianSkill> allSkills = technicianSkillDAO.getAllTechnicianSkills();
    request.setAttribute("allSkills", allSkills);
    
    List<WorkAssignment> assignmentHistory = workAssignmentDAO.getAssignmentsByManager(managerId);
    request.setAttribute("assignmentHistory", assignmentHistory);
    
    if (preSelectedRequestId != null && !preSelectedRequestId.trim().isEmpty()) {
        request.setAttribute("preSelectedRequestId", preSelectedRequestId);
    }
    
    if (preSelectedPriority != null && !preSelectedPriority.trim().isEmpty()) {
        request.setAttribute("preSelectedPriority", preSelectedPriority);
    }
    
    request.getRequestDispatcher("/AssignWork.jsp").forward(request, response);
}

    /**
     * Get available technicians as JSON
     */
    private void handleGetAvailableTechnicians(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        List<TechnicianWorkload> technicians = technicianWorkloadDAO.getAvailableTechnicians();
        
        StringBuilder json = new StringBuilder();
        json.append("[");
        
        for (int i = 0; i < technicians.size(); i++) {
            TechnicianWorkload tech = technicians.get(i);
            if (i > 0) json.append(",");
            
            json.append("{");
            json.append("\"technicianId\":").append(tech.getTechnicianId()).append(",");
            json.append("\"currentTasks\":").append(tech.getCurrentActiveTasks()).append(",");
            json.append("\"maxTasks\":").append(tech.getMaxConcurrentTasks()).append(",");
            json.append("\"availableCapacity\":").append(tech.getAvailableCapacity()).append(",");
            json.append("\"averageCompletionTime\":").append(tech.getAverageCompletionTime());
            json.append("}");
        }
        
        json.append("]");
        
        PrintWriter out = response.getWriter();
        out.print(json.toString());
        out.flush();
    }

    /**
     * Get service requests as JSON
     */
    private void handleGetServiceRequests(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        String status = request.getParameter("status");
        if (status == null) status = "Approved";
        
        List<ServiceRequest> requests = serviceRequestDAO.getRequestsByStatus(status);
        
        StringBuilder json = new StringBuilder();
        json.append("[");
        
        for (int i = 0; i < requests.size(); i++) {
            ServiceRequest req = requests.get(i);
            if (i > 0) json.append(",");
            
            json.append("{");
            json.append("\"requestId\":").append(req.getRequestId()).append(",");
            json.append("\"serviceType\":\"").append(escapeJson(req.getRequestType())).append("\",");
            json.append("\"description\":\"").append(escapeJson(req.getDescription())).append("\",");
            json.append("\"priority\":\"").append(escapeJson(req.getPriorityLevel())).append("\",");
            json.append("\"requestDate\":\"").append(req.getRequestDate()).append("\"");
            json.append("}");
        }
        
        json.append("]");
        
        PrintWriter out = response.getWriter();
        out.print(json.toString());
        out.flush();
    }

    /**
     * Get assignment history as JSON with requestId instead of taskId
     */
   /**
 * Get assignment history as JSON with technician name
 */
private void handleGetAssignmentHistory(HttpServletRequest request, HttpServletResponse response, int managerId)
        throws ServletException, IOException, SQLException {

    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");

    List<WorkAssignment> assignments = workAssignmentDAO.getAssignmentsByManager(managerId);

    StringBuilder json = new StringBuilder();
    json.append("[");

    WorkTaskDAO workTaskDAO = new WorkTaskDAO();
    AccountDAO accountDAO = new AccountDAO(); // ✅ Thêm DAO để lấy tên technician

    for (int i = 0; i < assignments.size(); i++) {
        WorkAssignment assignment = assignments.get(i);
        if (i > 0) json.append(",");

        // ✅ Get requestId from WorkTask
        WorkTask task = workTaskDAO.findById(assignment.getTaskId());
        int requestId = (task != null && task.getRequestId() != null) ? task.getRequestId() : 0;
        String status = (task != null) ? task.getStatus() : "Unknown";

        // ✅ Get technician name from Account
        String technicianName = "Unknown";
        try {
            Account techAccount = accountDAO.getAccountById(assignment.getAssignedTo());
            if (techAccount != null) {
                technicianName = techAccount.getFullName();
            }
        } catch (Exception e) {
            System.err.println("Error getting technician name: " + e.getMessage());
        }

        json.append("{");
        json.append("\"assignmentId\":").append(assignment.getAssignmentId()).append(",");
        json.append("\"taskId\":").append(requestId).append(","); 
        json.append("\"assignedTo\":").append(assignment.getAssignedTo()).append(",");
        json.append("\"technicianName\":\"").append(escapeJson(technicianName)).append("\","); // ✅ Thêm tên
        json.append("\"assignmentDate\":\"").append(assignment.getAssignmentDate()).append("\",");
        json.append("\"estimatedDuration\":").append(assignment.getEstimatedDuration()).append(",");
        json.append("\"requiredSkills\":\"").append(escapeJson(assignment.getRequiredSkills())).append("\",");
        json.append("\"priority\":\"").append(escapeJson(assignment.getPriority())).append("\",");
        json.append("\"accepted\":").append(assignment.isAcceptedByTechnician());

        if (assignment.getAcceptedAt() != null) {
            json.append(",\"acceptedAt\":\"").append(assignment.getAcceptedAt()).append("\"");
        }

        json.append(",\"status\":\"").append(escapeJson(status)).append("\"");
        json.append("}");
    }

    json.append("]");

    PrintWriter out = response.getWriter();
    out.print(json.toString());
    out.flush();
}

    /**
     * Update assignment acceptance status
     */
    private void handleUpdateAssignment(HttpServletRequest request, HttpServletResponse response, int managerId)
            throws ServletException, IOException, SQLException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        try {
            int assignmentId = Integer.parseInt(request.getParameter("assignmentId"));
            boolean accepted = Boolean.parseBoolean(request.getParameter("accepted"));
            
            boolean success = workAssignmentDAO.updateAssignmentAcceptance(assignmentId, accepted);
            
            PrintWriter out = response.getWriter();
            out.print("{\"success\":" + success + "}");
            out.flush();
            
        } catch (Exception e) {
            e.printStackTrace();
            PrintWriter out = response.getWriter();
            out.print("{\"success\":false,\"error\":\"" + escapeJson(e.getMessage()) + "\"}");
            out.flush();
        }
    }

    /**
     * Delete assignment and update workload
     */
    private void handleDeleteAssignment(HttpServletRequest request, HttpServletResponse response, int managerId)
            throws ServletException, IOException, SQLException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try {
            int assignmentId = Integer.parseInt(request.getParameter("assignmentId"));

            WorkAssignment assignment = workAssignmentDAO.getAssignmentById(assignmentId);

            if (assignment == null) {
                PrintWriter out = response.getWriter();
                out.print("{\"success\":false,\"error\":\"Assignment not found\"}");
                out.flush();
                return;
            }

            // ✅ Calculate workload points to deduct
            int workloadPoints = calculateWorkloadPoints(assignment.getPriority());

            boolean successAssignment = workAssignmentDAO.deleteAssignment(assignmentId);

            boolean successTask = false;

            if (successAssignment) {
                // ✅ Decrease workload by points
                technicianWorkloadDAO.decrementWorkloadByPoints(assignment.getAssignedTo(), workloadPoints);

                WorkTaskDAO workTaskDAO = new WorkTaskDAO();
                successTask = workTaskDAO.deleteTaskById(assignment.getTaskId());
            }

            PrintWriter out = response.getWriter();
            out.print("{\"success\":" + (successAssignment && successTask) + "}");
            out.flush();

        } catch (Exception e) {
            e.printStackTrace();
            PrintWriter out = response.getWriter();
            out.print("{\"success\":false,\"error\":\"" + escapeJson(e.getMessage()) + "\"}");
            out.flush();
        }
    }

    /**
     * Calculate workload points based on priority level
     * Urgent = 3 points, High = 2 points, Normal = 1 point
     */
    private int calculateWorkloadPoints(String priority) {
        if (priority == null) return 1;
        
        switch (priority.toLowerCase()) {
            case "urgent":
                return 3;
            case "high":
                return 2;
            case "normal":
            case "low":
                return 1;
            default:
                return 1;
        }
    }

    /**
     * Escape special characters for JSON
     */
    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\b", "\\b")
                  .replace("\f", "\\f")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r")
                  .replace("\t", "\\t");
    }
}