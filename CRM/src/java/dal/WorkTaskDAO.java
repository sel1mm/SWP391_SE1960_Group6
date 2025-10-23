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
        
        sql.append(" ORDER BY wt.startDate ASC LIMIT ? OFFSET ?");
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
        xSql = "UPDATE WorkTask SET status = ? WHERE taskId = ?";
        ps = con.prepareStatement(xSql);
        ps.setString(1, newStatus);
        ps.setInt(2, taskId);
        
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
        ps.setDate(6, Date.valueOf(task.getStartDate()));
        ps.setDate(7, Date.valueOf(task.getEndDate()));
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

}
