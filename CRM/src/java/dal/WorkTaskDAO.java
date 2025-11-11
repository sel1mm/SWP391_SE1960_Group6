package dal;

import model.WorkTask;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO for WorkTask operations.
 * Handles database operations for technician work tasks.
 */
public class WorkTaskDAO extends MyDAO {
    
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
        
        ps = con.prepareStatement(sql.toString());
        for (int i = 0; i < params.size(); i++) {
            ps.setObject(i + 1, params.get(i));
        }
        
        rs = ps.executeQuery();
        while (rs.next()) {
            tasks.add(mapResultSetToWorkTask(rs));
        }
        
        return tasks;
    }

    /**
     * Find all tasks assigned to a specific technician with customer information
     */
    public List<WorkTaskWithCustomer> findByTechnicianIdWithCustomer(int technicianId, String searchQuery, String statusFilter, int page, int pageSize) throws SQLException {
        List<WorkTaskWithCustomer> tasks = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT wt.taskId, wt.requestId, wt.scheduleId, wt.technicianId, ");
        sql.append("wt.taskType, wt.taskDetails, wt.startDate, wt.endDate, wt.status, ");
        sql.append("sr.createdBy as customerId, a.fullName as customerName, a.email as customerEmail, ");
        // Plan dates from latest WorkAssignment only
        sql.append("wa.assignmentDate AS planStart, ");
        sql.append("CASE WHEN wa.assignmentDate IS NOT NULL AND wa.estimatedDuration IS NOT NULL ");
        sql.append("THEN DATE_ADD(wa.assignmentDate, INTERVAL ROUND(wa.estimatedDuration * 60) MINUTE) ");
        sql.append("ELSE NULL END AS planDone ");
        sql.append("FROM WorkTask wt ");
        sql.append("LEFT JOIN ServiceRequest sr ON wt.requestId = sr.requestId ");
        sql.append("LEFT JOIN Account a ON sr.createdBy = a.accountId ");
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
            sql.append(" AND (wt.taskType LIKE ? OR wt.taskDetails LIKE ? OR CAST(wt.taskId AS CHAR) LIKE ? OR a.fullName LIKE ?)");
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
        sql.append(" ORDER BY COALESCE(wt.endDate, wt.startDate) DESC LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add((page - 1) * pageSize);
        
        ps = con.prepareStatement(sql.toString());
        for (int i = 0; i < params.size(); i++) {
            ps.setObject(i + 1, params.get(i));
        }
        
        rs = ps.executeQuery();
        while (rs.next()) {
            WorkTaskWithCustomer taskWithCustomer = new WorkTaskWithCustomer();
            taskWithCustomer.task = mapResultSetToWorkTask(rs);
            taskWithCustomer.customerId = rs.getObject("customerId", Integer.class);
            taskWithCustomer.customerName = rs.getString("customerName");
            taskWithCustomer.customerEmail = rs.getString("customerEmail");
            taskWithCustomer.planStart = rs.getTimestamp("planStart");
            taskWithCustomer.planDone = rs.getTimestamp("planDone");
            tasks.add(taskWithCustomer);
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
        public java.sql.Timestamp planStart;
        public java.sql.Timestamp planDone;
        
        public WorkTask getTask() { return task; }
        public Integer getCustomerId() { return customerId; }
        public String getCustomerName() { return customerName; }
        public String getCustomerEmail() { return customerEmail; }
        public java.sql.Timestamp getPlanStart() { return planStart; }
        public java.sql.Timestamp getPlanDone() { return planDone; }
    }
    
    /**
     * Find a specific task by ID
     */
    public WorkTask findById(int taskId) throws SQLException {
        xSql = "SELECT * FROM WorkTask WHERE taskId = ?";
        ps = con.prepareStatement(xSql);
        ps.setInt(1, taskId);
        rs = ps.executeQuery();
        
        if (rs.next()) {
            return mapResultSetToWorkTask(rs);
        }
        return null;
    }
    
    /**
     * Update task status
     */
    public boolean updateTaskStatus(int taskId, String newStatus) throws SQLException {
        xSql = "UPDATE WorkTask SET status = ?, endDate = CASE WHEN ? = 'Completed' THEN CURRENT_DATE ELSE NULL END WHERE taskId = ?";
        ps = con.prepareStatement(xSql);
        ps.setString(1, newStatus);
        ps.setString(2, newStatus);
        ps.setInt(3, taskId);
        int affected = ps.executeUpdate();
        return affected > 0;
    }
    
    /**
     * Check if technician has overlapping tasks
     */
    public boolean hasOverlappingTasks(int technicianId, LocalDate startDate, LocalDate endDate, int excludeTaskId) throws SQLException {
        xSql = "SELECT COUNT(*) FROM WorkTask WHERE technicianId = ? AND status IN ('In Progress', 'Pending') " +
               "AND taskId != ? AND ((startDate <= ? AND endDate >= ?) OR (startDate <= ? AND endDate >= ?))";
        ps = con.prepareStatement(xSql);
        ps.setInt(1, technicianId);
        ps.setInt(2, excludeTaskId);
        ps.setDate(3, Date.valueOf(endDate));
        ps.setDate(4, Date.valueOf(startDate));
        ps.setDate(5, Date.valueOf(startDate));
        ps.setDate(6, Date.valueOf(endDate));
        
        rs = ps.executeQuery();
        if (rs.next()) {
            return rs.getInt(1) > 0;
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
        
        ps = con.prepareStatement(sql.toString());
        for (int i = 0; i < params.size(); i++) {
            ps.setObject(i + 1, params.get(i));
        }
        
        rs = ps.executeQuery();
        if (rs.next()) {
            return rs.getInt(1);
        }
        return 0;
    }

    /**
     * Get task count for technician with customer information
     */
    public int getTaskCountForTechnicianWithCustomer(int technicianId, String statusFilter) throws SQLException {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) FROM WorkTask wt ");
        sql.append("LEFT JOIN ServiceRequest sr ON wt.requestId = sr.requestId ");
        sql.append("LEFT JOIN Account a ON sr.createdBy = a.accountId ");
        sql.append("WHERE wt.technicianId = ?");
        
        List<Object> params = new ArrayList<>();
        params.add(technicianId);
        
        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            sql.append(" AND wt.status = ?");
            params.add(statusFilter.trim());
        }
        
        ps = con.prepareStatement(sql.toString());
        for (int i = 0; i < params.size(); i++) {
            ps.setObject(i + 1, params.get(i));
        }
        
        rs = ps.executeQuery();
        if (rs.next()) {
            return rs.getInt(1);
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
        xSql = sql.toString();
        
        try {
            ps = con.prepareStatement(xSql);
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            rs = ps.executeQuery();
            
            while (rs.next()) {
                tasks.add(mapResultSetToWorkTask(rs));
            }
        } finally {
            closeResources();
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
        
        xSql = sql.toString();
        
        try {
            ps = con.prepareStatement(xSql);
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1);
            }
        } finally {
            closeResources();
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
     * Inner class for WorkTask with customer and request information
     */
    public static class WorkTaskForReport {
        public WorkTask task;
        public Integer customerId;
        public String customerName;
        public String requestType;
        
        public WorkTask getTask() { return task; }
        public Integer getCustomerId() { return customerId; }
        public String getCustomerName() { return customerName; }
        public String getRequestType() { return requestType; }
    }
    
    /**
     * Get assigned tasks for technician that are not completed or cancelled (for report creation)
     * Includes customer info and requestType from ServiceRequest
     */
    public List<WorkTaskForReport> getAssignedTasksForReport(int technicianId) throws SQLException {
        List<WorkTaskForReport> tasks = new ArrayList<>();
        xSql = "SELECT wt.taskId, wt.requestId, wt.scheduleId, wt.technicianId, " +
               "wt.taskType, wt.taskDetails, wt.startDate, wt.endDate, wt.status, " +
               "sr.createdBy as customerId, a.fullName as customerName, sr.requestType " +
               "FROM WorkTask wt " +
               "LEFT JOIN ServiceRequest sr ON wt.requestId = sr.requestId " +
               "LEFT JOIN Account a ON sr.createdBy = a.accountId " +
               "WHERE wt.technicianId = ? AND wt.status NOT IN ('Completed', 'Cancelled') " +
               "AND wt.requestId IS NOT NULL " +
               "ORDER BY wt.startDate ASC";
        
        ps = con.prepareStatement(xSql);
        ps.setInt(1, technicianId);
        rs = ps.executeQuery();
        
        while (rs.next()) {
            WorkTaskForReport taskForReport = new WorkTaskForReport();
            taskForReport.task = mapResultSetToWorkTask(rs);
            taskForReport.customerId = rs.getObject("customerId", Integer.class);
            taskForReport.customerName = rs.getString("customerName");
            taskForReport.requestType = rs.getString("requestType");
            tasks.add(taskForReport);
        }
        
        return tasks;
    }
    
    /**
     * Check if technician is assigned to a specific request ID
     */
    public boolean isTechnicianAssignedToRequest(int technicianId, int requestId) throws SQLException {
        xSql = "SELECT COUNT(*) FROM WorkTask WHERE technicianId = ? AND requestId = ?";
        ps = con.prepareStatement(xSql);
        ps.setInt(1, technicianId);
        ps.setInt(2, requestId);
        rs = ps.executeQuery();
        
        if (rs.next()) {
            return rs.getInt(1) > 0;
        }
        return false;
    }
    
    /**
     * Check if a work task is completed
     */
    public boolean isTaskCompleted(int requestId) throws SQLException {
        xSql = "SELECT status FROM WorkTask WHERE requestId = ?";
        ps = con.prepareStatement(xSql);
        ps.setInt(1, requestId);
        rs = ps.executeQuery();
        
        if (rs.next()) {
            return "Completed".equals(rs.getString("status"));
        }
        return false;
    }
    public List<WorkTask> findByScheduleId(int scheduleId) throws SQLException {
    List<WorkTask> tasks = new ArrayList<>();
    String sql = "SELECT * FROM WorkTask WHERE scheduleId = ?";
    try (PreparedStatement ps = con.prepareStatement(sql)) {
        ps.setInt(1, scheduleId);
        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                tasks.add(mapResultSetToWorkTask(rs));
            }
        }
    }
    return tasks;
}
    private void closeResources() {
        try {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public int getTaskIdByRequestId(int requestId) throws SQLException {
        String sql = "SELECT taskId FROM WorkTask WHERE requestId = ?";
        try (
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
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
    try (PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
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
    try (PreparedStatement ps = con.prepareStatement(sql)) {
        ps.setInt(1, taskId);
        int affected = ps.executeUpdate();
        return affected > 0;
    }
}

public List<WorkTask> findByRequestId(int requestId) {
    List<WorkTask> tasks = new ArrayList<>();
    String sql = "SELECT * FROM WorkTask WHERE requestId = ? ORDER BY taskId DESC";
    
    try {
        ps = con.prepareStatement(sql);
        ps.setInt(1, requestId);
        rs = ps.executeQuery();
        
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
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        closeResources();
    }
    
    return tasks;
}

public boolean hasRepairReport(int requestId, int technicianId) throws SQLException {
    String sql = "SELECT COUNT(*) FROM RepairReport WHERE requestId = ? AND technicianId = ?";
    
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    try {
        ps = con.prepareStatement(sql);
        ps.setInt(1, requestId);
        ps.setInt(2, technicianId);
        rs = ps.executeQuery();
        
        if (rs.next()) {
            int count = rs.getInt(1);
            System.out.println("DEBUG hasRepairReport - requestId: " + requestId + 
                             ", technicianId: " + technicianId + ", count: " + count);
            return count > 0;
        }
    } finally {
        if (rs != null) rs.close();
        if (ps != null) ps.close();
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


}
