package dal;

import model.WorkTask;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO for WorkTask operations. Handles database operations for technician work
 * tasks.
 */
public class WorkTaskDAO extends MyDAO {

    /**
     * Get a valid database connection with validation
     *
     * @return Connection if valid, throws SQLException if not available
     * @throws SQLException if connection is null or closed
     */
    private Connection getValidConnection() throws SQLException {
        if (connection == null || connection.isClosed()) {
            throw new SQLException("Database connection is not available");
        }
        return connection;
    }

    /**
     * Find all tasks assigned to a specific technician
     */
    public List<WorkTask> findByTechnicianId(int technicianId, String searchQuery, String statusFilter, int page, int pageSize) throws SQLException {
        List<WorkTask> tasks = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT wt.taskId, wt.requestId, wt.scheduleId, wt.technicianId, ");
        sql.append("wt.taskType, wt.taskDetails, wt.startDate, wt.endDate, wt.status ");
        sql.append("FROM WorkTask wt WHERE wt.technicianId = ?");

        List<Object> params = new ArrayList<>();
        params.add(technicianId);

        // Add search filter
        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            sql.append(" AND (wt.taskType LIKE ? OR wt.taskDetails LIKE ? OR CAST(wt.taskId AS CHAR) LIKE ?)");
            String searchPattern = "%" + searchQuery.trim() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
        }

        // Add status filter
        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            sql.append(" AND wt.status = ?");
            params.add(statusFilter.trim());
        }

        // Work History: order by taskId DESC
        sql.append(" ORDER BY wt.taskId ASC LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add((page - 1) * pageSize);

        try (PreparedStatement ps = getValidConnection().prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    tasks.add(mapResultSetToWorkTask(rs));
                }
            }
        }

        return tasks;
    }

    /**
     * Find all tasks assigned to a specific technician with customer
     * information
     */
    public List<WorkTaskWithCustomer> findByTechnicianIdWithCustomer(int technicianId, String searchQuery, String statusFilter, int page, int pageSize) throws SQLException {
        List<WorkTaskWithCustomer> tasks = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT wt.taskId, wt.requestId, wt.scheduleId, wt.technicianId, ");
        sql.append("wt.taskType, wt.taskDetails, wt.startDate, wt.endDate, wt.status, ");
        // Customer derivation for both Request and Scheduled tasks
        sql.append("COALESCE(a_ms.accountId, a_sr.accountId, a_c.accountId) AS customerId, ");
        sql.append("COALESCE(a_ms.fullName, a_sr.fullName, a_c.fullName) AS customerName, ");
        sql.append("COALESCE(a_ms.email, a_sr.email, a_c.email) AS customerEmail, ");
        sql.append("COALESCE(wt.requestId, ms.requestId) AS effectiveRequestId, ");
        // Assignment date from latest WorkAssignment
        sql.append("wa.assignmentDate AS assignmentDate ");
        sql.append("FROM WorkTask wt ");
        // Join MaintenanceSchedule first, then ServiceRequest can reference ms.requestId
        sql.append("LEFT JOIN MaintenanceSchedule ms ON wt.scheduleId = ms.scheduleId ");
        // For Request-type (or schedule-linked) tasks: derive customer via ServiceRequest.createdBy
        sql.append("LEFT JOIN ServiceRequest sr ON sr.requestId = COALESCE(wt.requestId, ms.requestId) ");
        sql.append("LEFT JOIN Account a_sr ON sr.createdBy = a_sr.accountId ");
        // For Scheduled-type tasks: prefer MaintenanceSchedule.customerId, else fallback via sr/contract
        sql.append("LEFT JOIN Account a_ms ON ms.customerId = a_ms.accountId ");
        sql.append("LEFT JOIN Contract c ON ms.contractId = c.contractId ");
        sql.append("LEFT JOIN Account a_c ON c.customerId = a_c.accountId ");
        // Join latest assignment per task (most recent assignmentDate)
        sql.append("LEFT JOIN ( ");
        sql.append("  SELECT wa1.* FROM WorkAssignment wa1 ");
        sql.append("  JOIN (SELECT taskId, MAX(assignmentDate) AS maxDate FROM WorkAssignment GROUP BY taskId) wa_last ");
        sql.append("    ON wa1.taskId = wa_last.taskId AND wa1.assignmentDate = wa_last.maxDate ");
        sql.append(") wa ON wa.taskId = wt.taskId ");
        // Remove other fallbacks; only WorkAssignment defines planning for this view
        sql.append("WHERE wt.technicianId = ?");

        List<Object> params = new ArrayList<>();
        params.add(technicianId);

        // Add search filter
        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            sql.append(" AND (wt.taskType LIKE ? OR wt.taskDetails LIKE ? OR CAST(wt.taskId AS CHAR) LIKE ? ");
            sql.append(" OR COALESCE(a_ms.fullName, a_sr.fullName, a_c.fullName) LIKE ?)");
            String searchPattern = "%" + searchQuery.trim() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
        }

        // Add status filter
        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            sql.append(" AND wt.status = ?");
            params.add(statusFilter.trim());
        }

        // Technician Tasks list: closest date first using endDate, then startDate (DESC)
        sql.append(" ORDER BY COALESCE(wt.endDate, wt.startDate, ms.scheduledDate) DESC LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add((page - 1) * pageSize);

        try (PreparedStatement ps = getValidConnection().prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    WorkTaskWithCustomer taskWithCustomer = new WorkTaskWithCustomer();
                    taskWithCustomer.task = mapResultSetToWorkTask(rs);
                    Integer effectiveRequestId = rs.getObject("effectiveRequestId", Integer.class);
                    if (effectiveRequestId != null) {
                        taskWithCustomer.task.setRequestId(effectiveRequestId);
                    }
                    taskWithCustomer.customerId = rs.getObject("customerId", Integer.class);
                    taskWithCustomer.customerName = rs.getString("customerName");
                    taskWithCustomer.customerEmail = rs.getString("customerEmail");
                    taskWithCustomer.assignmentDate = rs.getTimestamp("assignmentDate");
                    tasks.add(taskWithCustomer);
                }
            }
        }

        return tasks;
    }

    /**
     * Inner class for WorkTask with customer information
     */
    public static class WorkTaskWithCustomer {

        public WorkTask task;
        public Integer customerId;
        public String customerName;
        public String customerEmail;
        public java.sql.Timestamp assignmentDate;

        public WorkTask getTask() {
            return task;
        }

        public Integer getCustomerId() {
            return customerId;
        }

        public String getCustomerName() {
            return customerName;
        }

        public String getCustomerEmail() {
            return customerEmail;
        }

        public java.sql.Timestamp getAssignmentDate() {
            return assignmentDate;
        }

        public void setAssignmentDate(java.sql.Timestamp assignmentDate) {
            this.assignmentDate = assignmentDate;
        }
    }

    /**
     * Find a specific task by ID
     */
    public WorkTask findById(int taskId) throws SQLException {
        String sql = "SELECT wt.*, COALESCE(wt.requestId, ms.requestId) AS effectiveRequestId "
                + "FROM WorkTask wt "
                + "LEFT JOIN MaintenanceSchedule ms ON wt.scheduleId = ms.scheduleId "
                + "WHERE wt.taskId = ?";

        try (PreparedStatement ps = getValidConnection().prepareStatement(sql)) {
            ps.setInt(1, taskId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    WorkTask task = mapResultSetToWorkTask(rs);
                    Integer effectiveRequestId = rs.getObject("effectiveRequestId", Integer.class);
                    if (effectiveRequestId != null) {
                        task.setRequestId(effectiveRequestId);
                    }
                    return task;
                }
            }
        }
        return null;
    }

    /**
     * Update task status and auto-update request status if all tasks completed
     */
    public boolean updateTaskStatus(int taskId, String newStatus) throws SQLException {
        // Lấy requestId trước khi update
        Integer requestId = null;
        String getRequestSql = "SELECT requestId FROM WorkTask WHERE taskId = ?";

        try (PreparedStatement ps = getValidConnection().prepareStatement(getRequestSql)) {
            ps.setInt(1, taskId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    requestId = rs.getObject("requestId", Integer.class);
                }
            }
        }

        // Update task status
        int affected;
        String updateTaskSql;
        if ("Completed".equals(newStatus) || "Failed".equals(newStatus)) {
            updateTaskSql = "UPDATE WorkTask SET status = ?, endDate = CURRENT_DATE WHERE taskId = ?";
            try (PreparedStatement ps = getValidConnection().prepareStatement(updateTaskSql)) {
                ps.setString(1, newStatus);
                ps.setInt(2, taskId);
                affected = ps.executeUpdate();
            }
        } else if ("Assigned".equals(newStatus) || "In Progress".equals(newStatus)) {
            updateTaskSql = "UPDATE WorkTask SET status = ?, endDate = NULL WHERE taskId = ?";
            try (PreparedStatement ps = getValidConnection().prepareStatement(updateTaskSql)) {
                ps.setString(1, newStatus);
                ps.setInt(2, taskId);
                affected = ps.executeUpdate();
            }
        } else {
            updateTaskSql = "UPDATE WorkTask SET status = ? WHERE taskId = ?";
            try (PreparedStatement ps = getValidConnection().prepareStatement(updateTaskSql)) {
                ps.setString(1, newStatus);
                ps.setInt(2, taskId);
                affected = ps.executeUpdate();
            }
        }

        // Nếu update thành công và task vừa được set là Completed
        if (affected > 0 && "Completed".equals(newStatus) && requestId != null) {
            System.out.println("🔍 Task #" + taskId + " marked as Completed. Checking request #" + requestId + "...");

            // Kiểm tra xem tất cả task của request này đã completed chưa
            if (areAllTasksCompletedForRequest(requestId)) {
                // Cập nhật request status thành Completed
                try (ServiceRequestDAO serviceRequestDAO = new ServiceRequestDAO()) {
                    serviceRequestDAO.updateStatus(requestId, "Completed");
                    System.out.println("✅ All tasks completed for Request #" + requestId
                            + ". Request status updated to Completed.");
                } catch (SQLException e) {
                    System.err.println("⚠️ Failed to update request status: " + e.getMessage());
                    e.printStackTrace();
                }
            } else {
                List<String> statuses = getTaskStatusesForRequest(requestId);
                System.out.println("ℹ️ Request #" + requestId + " still has incomplete tasks. "
                        + "Task statuses: " + statuses);
            }
        }

        return affected > 0;
    }

    /**
     * Check if technician has overlapping tasks
     */
    public boolean hasOverlappingTasks(int technicianId, LocalDate startDate, LocalDate endDate, int excludeTaskId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM WorkTask WHERE technicianId = ? AND status IN ('In Progress', 'Pending') "
                + "AND taskId != ? AND ((startDate <= ? AND endDate >= ?) OR (startDate <= ? AND endDate >= ?))";

        try (PreparedStatement ps = getValidConnection().prepareStatement(sql)) {
            ps.setInt(1, technicianId);
            ps.setInt(2, excludeTaskId);
            ps.setDate(3, Date.valueOf(endDate));
            ps.setDate(4, Date.valueOf(startDate));
            ps.setDate(5, Date.valueOf(startDate));
            ps.setDate(6, Date.valueOf(endDate));

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }
        return false;
    }

    /**
     * Get task count for technician
     */
    public int getTaskCountForTechnician(int technicianId, String statusFilter) throws SQLException {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) FROM WorkTask WHERE technicianId = ?");

        List<Object> params = new ArrayList<>();
        params.add(technicianId);

        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            sql.append(" AND status = ?");
            params.add(statusFilter.trim());
        }

        try (PreparedStatement ps = getValidConnection().prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    /**
     * Get task count for technician with customer information
     */
    public int getTaskCountForTechnicianWithCustomer(int technicianId, String statusFilter) throws SQLException {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) FROM WorkTask wt ");
        sql.append("LEFT JOIN MaintenanceSchedule ms ON wt.scheduleId = ms.scheduleId ");
        sql.append("LEFT JOIN ServiceRequest sr ON sr.requestId = COALESCE(wt.requestId, ms.requestId) ");
        sql.append("WHERE wt.technicianId = ?");

        List<Object> params = new ArrayList<>();
        params.add(technicianId);

        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            sql.append(" AND wt.status = ?");
            params.add(statusFilter.trim());
        }

        try (PreparedStatement ps = getValidConnection().prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    /**
     * Map ResultSet to WorkTask object
     */
    private WorkTask mapResultSetToWorkTask(ResultSet rs) throws SQLException {
        WorkTask task = new WorkTask();
        task.setTaskId(rs.getInt("taskId"));

        Integer requestId = rs.getObject("requestId", Integer.class);
        task.setRequestId(requestId);

        Integer scheduleId = rs.getObject("scheduleId", Integer.class);
        task.setScheduleId(scheduleId);

        task.setTechnicianId(rs.getInt("technicianId"));
        task.setTaskType(rs.getString("taskType"));
        task.setTaskDetails(rs.getString("taskDetails"));

        Date startDate = rs.getDate("startDate");
        if (startDate != null) {
            task.setStartDate(startDate.toLocalDate());
        }

        Date endDate = rs.getDate("endDate");
        if (endDate != null) {
            task.setEndDate(endDate.toLocalDate());
        }

        task.setStatus(rs.getString("status"));

        return task;
    }

    public List<WorkTask> findCompletedTasksByTechnician(int technicianId, String searchQuery, int page, int pageSize) throws SQLException {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT * FROM WorkTask ");
        sql.append("WHERE technicianId = ? AND status = 'Completed' ");

        List<Object> params = new ArrayList<>();
        params.add(technicianId);

        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            sql.append("AND (taskType LIKE ? OR taskDetails LIKE ?) ");
            String searchPattern = "%" + searchQuery.trim() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
        }

        sql.append("ORDER BY endDate DESC ");
        sql.append("LIMIT ? OFFSET ?");

        int offset = (page - 1) * pageSize;
        params.add(pageSize);
        params.add(offset);

        List<WorkTask> tasks = new ArrayList<>();

        try (PreparedStatement ps = getValidConnection().prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    tasks.add(mapResultSetToWorkTask(rs));
                }
            }
        }

        return tasks;
    }

    public int getCompletedTaskCountForTechnician(int technicianId, String searchQuery) throws SQLException {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) FROM WorkTask ");
        sql.append("WHERE technicianId = ? AND status = 'Completed' ");

        List<Object> params = new ArrayList<>();
        params.add(technicianId);

        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            sql.append("AND (taskType LIKE ? OR taskDetails LIKE ?) ");
            String searchPattern = "%" + searchQuery.trim() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
        }

        try (PreparedStatement ps = getValidConnection().prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }

        return 0;
    }

    /**
     * Create a new work task
     */
//    public int createWorkTask(WorkTask task) throws SQLException {
//        xSql = "INSERT INTO WorkTask (requestId, scheduleId, technicianId, taskType, taskDetails, startDate, endDate, status) " +
//               "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
//        try {
//            ps = con.prepareStatement(xSql, Statement.RETURN_GENERATED_KEYS);
//            ps.setObject(1, task.getRequestId());
//            ps.setObject(2, task.getScheduleId());
//            ps.setInt(3, task.getTechnicianId());
//            ps.setString(4, task.getTaskType());
//            ps.setString(5, task.getTaskDetails());
//            ps.setDate(6, task.getStartDate() != null ? Date.valueOf(task.getStartDate()) : null);
//            ps.setDate(7, task.getEndDate() != null ? Date.valueOf(task.getEndDate()) : null);
//            ps.setString(8, task.getStatus());
//            
//            int affectedRows = ps.executeUpdate();
//            if (affectedRows > 0) {
//                rs = ps.getGeneratedKeys();
//                if (rs.next()) {
//                    return rs.getInt(1);
//                }
//            }
//            return -1;
//        } catch (Exception e) {
//            e.printStackTrace();
//            return -1;
//        } finally {
//            closeResources();
//        }
//    }
    /**
     * Get task ID by request ID
     */
//    public int getTaskIdByRequestId(int requestId) throws SQLException {
//        xSql = "SELECT taskId FROM WorkTask WHERE requestId = ?";
//        ps = con.prepareStatement(xSql);
//        ps.setInt(1, requestId);
//        rs = ps.executeQuery();
//        
//        if (rs.next()) {
//            return rs.getInt("taskId");
//        }
//        return -1;
//    }
    /**
     * Delete a task by ID
     */
//    public boolean deleteTaskById(int taskId) throws SQLException {
//        xSql = "DELETE FROM WorkTask WHERE taskId = ?";
//        try {
//            ps = con.prepareStatement(xSql);
//            ps.setInt(1, taskId);
//            
//            int affectedRows = ps.executeUpdate();
//            return affectedRows > 0;
//        } catch (Exception e) {
//            e.printStackTrace();
//            return false;
//        } finally {
//            closeResources();
//        }
//    }
    /**
     * DTO for report dropdown entries
     */
    public static class WorkTaskForReport {

        private int taskId;
        private String origin;
        private Integer requestId;
        private Integer scheduleId;
        private String taskStatus;
        private Integer customerId;
        private String customerName;
        private String requestType;
        private String displayLabel;

        public int getTaskId() {
            return taskId;
        }

        public String getOrigin() {
            return origin;
        }

        public Integer getRequestId() {
            return requestId;
        }

        public Integer getScheduleId() {
            return scheduleId;
        }

        public String getTaskStatus() {
            return taskStatus;
        }

        public Integer getCustomerId() {
            return customerId;
        }

        public String getCustomerName() {
            return customerName;
        }

        public String getRequestType() {
            return requestType;
        }

        public String getDisplayLabel() {
            return displayLabel;
        }
    }

    /**
     * Get assigned tasks for technician that are not completed or cancelled
     * (for report creation) Includes customer info and requestType from
     * ServiceRequest
     */
    public List<WorkTaskForReport> getAssignedTasksForReport(int technicianId) throws SQLException {
        List<WorkTaskForReport> tasks = new ArrayList<>();

        String sql = """
            SELECT wt.taskId,
                   wt.requestId,
                   wt.scheduleId,
                   wt.status AS taskStatus,
                   COALESCE(a_sr.accountId, a_sched.accountId) AS customerId,
                   COALESCE(a_sr.fullName, a_sched.fullName) AS customerName,
                   CASE WHEN wt.scheduleId IS NOT NULL THEN 'Schedule' ELSE 'ServiceRequest' END AS origin,
                   CASE WHEN wt.scheduleId IS NOT NULL THEN 'Maintenance' ELSE COALESCE(sr.requestType, 'Service') END AS requestType,
                   CASE
                       WHEN wt.scheduleId IS NOT NULL THEN CONCAT('Scheduled Maintenance Task - ',
                                                                COALESCE(a_sched.fullName, 'N/A'),
                                                                ' (ID: ', COALESCE(a_sched.accountId, 0), ') - #',
                                                                wt.scheduleId, ' (', wt.status, ')')
                       ELSE CONCAT('Service Request Task - ',
                                   COALESCE(a_sr.fullName, 'N/A'),
                                   ' (ID: ', COALESCE(a_sr.accountId, 0), ') - #',
                                   wt.requestId, ' (', wt.status, ')')
                   END AS displayLabel,
                   COALESCE(wt.startDate, ms.scheduledDate, wt.endDate, wt.taskId) AS sortKey
            FROM WorkTask wt
            LEFT JOIN ServiceRequest sr ON wt.requestId = sr.requestId
            LEFT JOIN Account a_sr ON sr.createdBy = a_sr.accountId
            LEFT JOIN MaintenanceSchedule ms ON wt.scheduleId = ms.scheduleId
            LEFT JOIN Contract c ON ms.contractId = c.contractId
            LEFT JOIN Account a_sched ON c.customerId = a_sched.accountId
            WHERE wt.technicianId = ?
              AND wt.status NOT IN ('Completed', 'Cancelled')
            ORDER BY sortKey ASC, wt.taskId ASC
        """;

        try (PreparedStatement ps = getValidConnection().prepareStatement(sql)) {
            ps.setInt(1, technicianId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    WorkTaskForReport dto = new WorkTaskForReport();
                    dto.taskId = rs.getInt("taskId");
                    dto.requestId = rs.getObject("requestId", Integer.class);
                    dto.scheduleId = rs.getObject("scheduleId", Integer.class);
                    dto.taskStatus = rs.getString("taskStatus");
                    dto.customerId = rs.getObject("customerId", Integer.class);
                    dto.customerName = rs.getString("customerName");
                    dto.origin = rs.getString("origin");
                    dto.requestType = rs.getString("requestType");
                    dto.displayLabel = rs.getString("displayLabel");
                    tasks.add(dto);
                }
            }
        }

        return tasks;
    }

    // Hàm kiểm tra kết nối
    public boolean checkConnection() {
        try {
            if (connection != null && !connection.isClosed()) {
                System.out.println("Kết nối DB thành công!");
                return true;
            } else {
                System.out.println("Kết nối DB thất bại!");
                return false;
            }
        } catch (SQLException ex) {

            return false;
        }
    }

    /**
     * Check if technician is assigned to a specific request ID
     */
    public boolean isTechnicianAssignedToRequest(int technicianId, int requestId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM WorkTask wt "
                + "LEFT JOIN MaintenanceSchedule ms ON wt.scheduleId = ms.scheduleId "
                + "WHERE wt.technicianId = ? "
                + "AND COALESCE(wt.requestId, ms.requestId) = ?";

        try (PreparedStatement ps = getValidConnection().prepareStatement(sql)) {
            ps.setInt(1, technicianId);
            ps.setInt(2, requestId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }

        return false;
    }

    /**
     * Check if a specific technician's work task is completed for a request
     * This ensures each technician can work independently on the same
     * ServiceRequest
     */
    public boolean isTechnicianTaskCompleted(int technicianId, int requestId) throws SQLException {
        String sql = "SELECT wt.status FROM WorkTask wt "
                + "LEFT JOIN MaintenanceSchedule ms ON wt.scheduleId = ms.scheduleId "
                + "WHERE wt.technicianId = ? "
                + "AND COALESCE(wt.requestId, ms.requestId) = ? "
                + "LIMIT 1";

        try (PreparedStatement ps = getValidConnection().prepareStatement(sql)) {
            ps.setInt(1, technicianId);
            ps.setInt(2, requestId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return "Completed".equals(rs.getString("status"));
                }
            }
        }
        return false; // No task found for this technician and request
    }

    /**
     * Check if technician is assigned to a specific schedule ID
     */
    public boolean isTechnicianAssignedToSchedule(int technicianId, int scheduleId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM WorkTask WHERE technicianId = ? AND scheduleId = ?";

        try (PreparedStatement ps = getValidConnection().prepareStatement(sql)) {
            ps.setInt(1, technicianId);
            ps.setInt(2, scheduleId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }
        return false;
    }

    public List<WorkTask> findByScheduleId(int scheduleId) throws SQLException {
        List<WorkTask> tasks = new ArrayList<>();
        String sql = "SELECT * FROM WorkTask WHERE scheduleId = ?";
        try (PreparedStatement ps = getValidConnection().prepareStatement(sql)) {
            ps.setInt(1, scheduleId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    tasks.add(mapResultSetToWorkTask(rs));
                }
            }
        }
        return tasks;
    }

    public int getTaskIdByRequestId(int requestId) throws SQLException {
        String sql = "SELECT wt.taskId FROM WorkTask wt "
                + "LEFT JOIN MaintenanceSchedule ms ON wt.scheduleId = ms.scheduleId "
                + "WHERE COALESCE(wt.requestId, ms.requestId) = ? "
                + "LIMIT 1";
        try (PreparedStatement ps = getValidConnection().prepareStatement(sql)) {
            ps.setInt(1, requestId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("taskId");
                }
            }
        }
        return -1; // không tìm thấy task tương ứng
    }

    public int createWorkTask(WorkTask task) throws SQLException {
        String sql = "INSERT INTO WorkTask (requestId, scheduleId, technicianId, taskType, taskDetails, startDate, endDate, status) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = getValidConnection().prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            if (task.getRequestId() != null) {
                ps.setInt(1, task.getRequestId());
            } else {
                ps.setNull(1, Types.INTEGER);
            }

            if (task.getScheduleId() != null) {
                ps.setInt(2, task.getScheduleId());
            } else {
                ps.setNull(2, Types.INTEGER);
            }

            ps.setInt(3, task.getTechnicianId());
            ps.setString(4, task.getTaskType());
            ps.setString(5, task.getTaskDetails());
            if (task.getStartDate() != null) {
                ps.setDate(6, Date.valueOf(task.getStartDate()));
            } else {
                ps.setNull(6, Types.DATE);
            }
            if (task.getEndDate() != null) {
                ps.setDate(7, Date.valueOf(task.getEndDate()));
            } else {
                ps.setNull(7, Types.DATE);
            }
            ps.setString(8, task.getStatus());

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
        }
        return -1;
    }

    public boolean deleteTaskById(int taskId) throws SQLException {
        String sql = "DELETE FROM WorkTask WHERE taskId = ?";
        try (PreparedStatement ps = getValidConnection().prepareStatement(sql)) {
            ps.setInt(1, taskId);
            int affected = ps.executeUpdate();
            return affected > 0;
        }
    }

    public List<WorkTask> findByRequestId(int requestId) throws SQLException {
        List<WorkTask> tasks = new ArrayList<>();
        String sql = "SELECT * FROM WorkTask WHERE requestId = ? ORDER BY taskId DESC";

        try (PreparedStatement ps = getValidConnection().prepareStatement(sql)) {
            ps.setInt(1, requestId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    WorkTask task = new WorkTask();
                    task.setTaskId(rs.getInt("taskId"));
                    task.setRequestId(rs.getInt("requestId"));

                    // Handle nullable scheduleId
                    int scheduleId = rs.getInt("scheduleId");
                    if (!rs.wasNull()) {
                        task.setScheduleId(scheduleId);
                    }

                    task.setTechnicianId(rs.getInt("technicianId"));
                    task.setTaskType(rs.getString("taskType"));
                    task.setTaskDetails(rs.getString("taskDetails"));

                    // Handle nullable dates
                    Date startDate = rs.getDate("startDate");
                    if (startDate != null) {
                        task.setStartDate(startDate.toLocalDate());
                    }

                    Date endDate = rs.getDate("endDate");
                    if (endDate != null) {
                        task.setEndDate(endDate.toLocalDate());
                    }

                    task.setStatus(rs.getString("status"));

                    tasks.add(task);
                }
            }
        }

        return tasks;
    }

    public boolean hasRepairReport(int requestId, int technicianId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM RepairReport WHERE requestId = ? AND technicianId = ?";

        try (PreparedStatement ps = getValidConnection().prepareStatement(sql)) {
            ps.setInt(1, requestId);
            ps.setInt(2, technicianId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int count = rs.getInt(1);
                    System.out.println("DEBUG hasRepairReport - requestId: " + requestId
                            + ", technicianId: " + technicianId + ", count: " + count);
                    return count > 0;
                }
            }
        }

        return false;
    }
//public List<WorkTask> findByScheduleId(int scheduleId) throws SQLException {
//    List<WorkTask> tasks = new ArrayList<>();
//    String sql = "SELECT * FROM WorkTask WHERE scheduleId = ?";
//    try (PreparedStatement ps = con.prepareStatement(sql)) {
//        ps.setInt(1, scheduleId);
//        try (ResultSet rs = ps.executeQuery()) {
//            while (rs.next()) {
//                tasks.add(mapResultSetToWorkTask(rs));
//            }
//        }
//    }
//    return tasks;
//}

    /**
     * Check if all work tasks for a request are completed
     */
    public boolean areAllTasksCompletedForRequest(int requestId) throws SQLException {
        String sql = "SELECT COUNT(*) as total, "
                + "SUM(CASE WHEN status = 'Completed' THEN 1 ELSE 0 END) as completed "
                + "FROM WorkTask WHERE requestId = ?";

        try (PreparedStatement ps = getValidConnection().prepareStatement(sql)) {
            ps.setInt(1, requestId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int total = rs.getInt("total");
                    int completed = rs.getInt("completed");

                    System.out.println("📊 Request #" + requestId + ": " + completed + "/" + total + " tasks completed");

                    // Nếu không có task nào thì return false
                    if (total == 0) {
                        System.out.println("⚠️ No tasks found for request #" + requestId);
                        return false;
                    }

                    // Tất cả task phải completed
                    boolean allCompleted = (total == completed);
                    System.out.println(allCompleted ? "✅ All tasks completed!" : "❌ Not all tasks completed yet");
                    return allCompleted;
                }
            }
        }

        return false;
    }

    /**
     * Get all task statuses for a request (for debugging)
     */
    public List<String> getTaskStatusesForRequest(int requestId) throws SQLException {
        List<String> statuses = new ArrayList<>();
        String sql = "SELECT taskId, status FROM WorkTask WHERE requestId = ?";

        try (PreparedStatement ps = getValidConnection().prepareStatement(sql)) {
            ps.setInt(1, requestId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int taskId = rs.getInt("taskId");
                    String status = rs.getString("status");
                    statuses.add("Task#" + taskId + ":" + status);
                }
            }
        }

        return statuses;
    }

    /**
     * Complete work task for a specific request and technician Used when
     * warranty inspection result is NotEligible
     *
     * @param technicianId The technician ID
     * @param requestId The request ID
     * @return true if task was updated, false otherwise
     * @throws SQLException if database error occurs
     */
    public boolean completeTaskForRequest(int technicianId, int requestId) throws SQLException {
        String sql = "UPDATE WorkTask SET status = 'Completed', endDate = CURRENT_DATE "
                + "WHERE technicianId = ? AND requestId = ? AND status != 'Completed'";

        try (PreparedStatement ps = getValidConnection().prepareStatement(sql)) {
            ps.setInt(1, technicianId);
            ps.setInt(2, requestId);

            int affected = ps.executeUpdate();

            if (affected > 0) {
                System.out.println("✅ WorkTask completed for technician #" + technicianId
                        + " on request #" + requestId);
            } else {
                System.out.println("⚠️ No active WorkTask found for technician #" + technicianId
                        + " on request #" + requestId);
            }

            return affected > 0;
        }
    }

    /**
     * Complete work task for a schedule and technician Used for schedule-origin
     * reports when warranty inspection is NotEligible
     *
     * @param technicianId The technician ID
     * @param scheduleId The schedule ID
     * @return true if task was updated, false otherwise
     * @throws SQLException if database error occurs
     */
    public boolean completeTaskForSchedule(int technicianId, int scheduleId) throws SQLException {
        String sql = "UPDATE WorkTask SET status = 'Completed', endDate = CURRENT_DATE "
                + "WHERE technicianId = ? AND scheduleId = ? AND status != 'Completed'";

        try (PreparedStatement ps = getValidConnection().prepareStatement(sql)) {
            ps.setInt(1, technicianId);
            ps.setInt(2, scheduleId);

            int affected = ps.executeUpdate();

            if (affected > 0) {
                System.out.println("✅ WorkTask completed for technician #" + technicianId
                        + " on schedule #" + scheduleId);
            } else {
                System.out.println("⚠️ No active WorkTask found for technician #" + technicianId
                        + " on schedule #" + scheduleId);
            }

            return affected > 0;
        }
    }


}
