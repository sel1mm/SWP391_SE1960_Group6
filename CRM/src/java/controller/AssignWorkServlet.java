package controller;

import dal.WorkAssignmentDAO;
import dal.TechnicianWorkloadDAO;
import dal.ServiceRequestDAO;
import dal.TechnicianSkillDAO;
import dal.WorkJobDAO;
import model.WorkAssignment;
import model.TechnicianWorkload;
import model.ServiceRequest;
import model.TechnicianSkill;
import model.Account;
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
import java.util.stream.Collectors;

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

        // Check if user is logged in and is a Technical Manager
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
        
        try {
            if ("getAvailableTechnicians".equals(action)) {
                handleGetAvailableTechnicians(request, response);
            } else if ("getServiceRequests".equals(action)) {
                handleGetServiceRequests(request, response);
            } else if ("getAssignmentHistory".equals(action)) {
                handleGetAssignmentHistory(request, response, accountId);
            } else {
                displayAssignWorkPage(request, response, accountId);
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

        // Check if user is logged in and is a Technical Manager
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

    private void displayAssignWorkPage(HttpServletRequest request, HttpServletResponse response, int managerId)
            throws ServletException, IOException, SQLException {
        
        // Get available technicians
        List<TechnicianWorkload> availableTechnicians = technicianWorkloadDAO.getTechniciansForAssignment();
        request.setAttribute("availableTechnicians", availableTechnicians);
        
        // Get pending service requests
        List<ServiceRequest> pendingRequests = serviceRequestDAO.getRequestsByStatus("Approved");
        request.setAttribute("pendingRequests", pendingRequests);
        
        // Get all skills for filtering
        List<TechnicianSkill> allSkills = technicianSkillDAO.getAllTechnicianSkills();
        request.setAttribute("allSkills", allSkills);
        
        // Get assignment history for this manager
        List<WorkAssignment> assignmentHistory = workAssignmentDAO.getAssignmentsByManager(managerId);
        request.setAttribute("assignmentHistory", assignmentHistory);
        
        request.getRequestDispatcher("/AssignWork.jsp").forward(request, response);
    }

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

    private void handleGetAssignmentHistory(HttpServletRequest request, HttpServletResponse response, int managerId)
            throws ServletException, IOException, SQLException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        List<WorkAssignment> assignments = workAssignmentDAO.getAssignmentsByManager(managerId);
        
        StringBuilder json = new StringBuilder();
        json.append("[");
        
        for (int i = 0; i < assignments.size(); i++) {
            WorkAssignment assignment = assignments.get(i);
            if (i > 0) json.append(",");
            
            json.append("{");
            json.append("\"assignmentId\":").append(assignment.getAssignmentId()).append(",");
            json.append("\"taskId\":").append(assignment.getTaskId()).append(",");
            json.append("\"assignedTo\":").append(assignment.getAssignedTo()).append(",");
            json.append("\"assignmentDate\":\"").append(assignment.getAssignmentDate()).append("\",");
            json.append("\"estimatedDuration\":").append(assignment.getEstimatedDuration()).append(",");
            json.append("\"requiredSkills\":\"").append(escapeJson(assignment.getRequiredSkills())).append("\",");
            json.append("\"priority\":\"").append(escapeJson(assignment.getPriority())).append("\",");
            json.append("\"accepted\":").append(assignment.isAcceptedByTechnician());
            if (assignment.getAcceptedAt() != null) {
                json.append(",\"acceptedAt\":\"").append(assignment.getAcceptedAt()).append("\"");
            }
            json.append("}");
        }
        
        json.append("]");
        
        PrintWriter out = response.getWriter();
        out.print(json.toString());
        out.flush();
    }

  private void handleAssignWork(HttpServletRequest request, HttpServletResponse response, int managerId, HttpSession session)
        throws ServletException, IOException, SQLException {

    try {
        // Lấy requestId (tên field trong form vẫn là taskId)
        int requestId = Integer.parseInt(request.getParameter("taskId")); // thực chất là requestId

        // Lấy technicianId và các thông tin khác
        int technicianId = Integer.parseInt(request.getParameter("technicianId"));
        String estimatedDurationStr = request.getParameter("estimatedDuration");
        String requiredSkills = request.getParameter("requiredSkills");
        String priority = request.getParameter("priority");

        // Validate estimatedDuration
        if (estimatedDurationStr == null || estimatedDurationStr.trim().isEmpty()) {
            session.setAttribute("errorMessage", "Estimated duration is required");
            response.sendRedirect(request.getContextPath() + "/assignWork");
            return;
        }

        BigDecimal estimatedDuration = new BigDecimal(estimatedDurationStr);

        // ✅ Tra taskId thật từ WorkJob dựa theo requestId
        WorkJobDAO workJobDAO = new WorkJobDAO();
        int taskId = workJobDAO.getTaskIdByRequestId(requestId);

        if (taskId == -1) {
            session.setAttribute("errorMessage", "Không tìm thấy công việc tương ứng với yêu cầu #" + requestId);
            response.sendRedirect(request.getContextPath() + "/assignWork");
            return;
        }

        // ✅ Kiểm tra tải công việc của technician
        TechnicianWorkload workload = technicianWorkloadDAO.getWorkloadByTechnician(technicianId);
        if (workload != null && workload.getAvailableCapacity() <= 0) {
            session.setAttribute("errorMessage", "Selected technician has no available capacity");
            response.sendRedirect(request.getContextPath() + "/assignWork");
            return;
        }

        // ✅ Tạo đối tượng WorkAssignment
        WorkAssignment assignment = new WorkAssignment();
        assignment.setTaskId(taskId); // taskId thật
        assignment.setAssignedBy(managerId);
        assignment.setAssignedTo(technicianId);
        assignment.setAssignmentDate(LocalDateTime.now());
        assignment.setEstimatedDuration(estimatedDuration);
        assignment.setRequiredSkills(requiredSkills != null ? requiredSkills : "");
        assignment.setPriority(priority != null ? priority : "Normal");
        assignment.setAcceptedByTechnician(false);

        // ✅ Insert vào DB
        int assignmentId = workAssignmentDAO.createWorkAssignment(assignment);

        if (assignmentId > 0) {
            // Cập nhật workload cho technician
            technicianWorkloadDAO.incrementActiveTasks(technicianId);
            session.setAttribute("successMessage", "Work assigned successfully to technician");
        } else {
session.setAttribute("errorMessage", "Failed to assign work. Please try again.");
        }

    } catch (NumberFormatException e) {
        session.setAttribute("errorMessage", "Invalid input format. Please check your entries.");
    } catch (Exception e) {
        e.printStackTrace();
        session.setAttribute("errorMessage", "An error occurred while assigning work: " + e.getMessage());
    }

    // ✅ Dù thành công hay thất bại, luôn quay về trang assignWork
    response.sendRedirect(request.getContextPath() + "/assignWork");
}

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

    private void handleDeleteAssignment(HttpServletRequest request, HttpServletResponse response, int managerId)
            throws ServletException, IOException, SQLException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        try {
            int assignmentId = Integer.parseInt(request.getParameter("assignmentId"));
            
            // Get assignment details before deletion to update workload
            WorkAssignment assignment = workAssignmentDAO.getAssignmentById(assignmentId);
            
            boolean success = workAssignmentDAO.deleteAssignment(assignmentId);
            
            if (success && assignment != null) {
                // Decrement technician workload
                technicianWorkloadDAO.decrementActiveTasks(assignment.getAssignedTo());
            }
            
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