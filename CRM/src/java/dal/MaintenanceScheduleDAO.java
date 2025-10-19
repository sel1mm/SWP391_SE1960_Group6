package dal;

import model.MaintenanceSchedule;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.time.LocalDateTime;
import java.time.LocalDate;

public class MaintenanceScheduleDAO extends MyDAO {
    
    /**
     * Create a new maintenance schedule
     */
    public int createMaintenanceSchedule(MaintenanceSchedule schedule) {
        xSql = "INSERT INTO MaintenanceSchedule (requestId, contractId, equipmentId, assignedTo, " +
               "scheduledDate, scheduleType, recurrenceRule, status, priorityId) " +
               "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try {
            ps = con.prepareStatement(xSql, Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, schedule.getRequestId());
            // Handle nullable contractId
            if (schedule.getContractId() != null) {
                ps.setInt(2, schedule.getContractId());
            } else {
                ps.setNull(2, Types.INTEGER);
            }
            // Handle nullable equipmentId
            if (schedule.getEquipmentId() != null) {
                ps.setInt(3, schedule.getEquipmentId());
            } else {
                ps.setNull(3, Types.INTEGER);
            }
            ps.setInt(4, schedule.getAssignedTo());
            ps.setTimestamp(5, Timestamp.valueOf(schedule.getScheduledDate().atStartOfDay()));
            ps.setString(6, schedule.getScheduleType());
            ps.setString(7, schedule.getRecurrenceRule());
            ps.setString(8, schedule.getStatus());
            ps.setInt(9, schedule.getPriorityId());
            
            int affectedRows = ps.executeUpdate();
            if (affectedRows > 0) {
                rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
            return -1;
        } catch (Exception e) {
            e.printStackTrace();
            return -1;
        } finally {
            closeResources();
        }
    }
    
    /**
     * Get all maintenance schedules
     */
    public List<MaintenanceSchedule> getAllMaintenanceSchedules() {
        List<MaintenanceSchedule> schedules = new ArrayList<>();
        xSql = "SELECT * FROM MaintenanceSchedule ORDER BY scheduledDate ASC";
        try {
            ps = con.prepareStatement(xSql);
            rs = ps.executeQuery();
            
            while (rs.next()) {
                schedules.add(mapResultSetToMaintenanceSchedule(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return schedules;
    }
    
    /**
     * Get maintenance schedules by technician
     */
    public List<MaintenanceSchedule> getSchedulesByTechnician(int technicianId) {
        List<MaintenanceSchedule> schedules = new ArrayList<>();
        xSql = "SELECT * FROM MaintenanceSchedule WHERE assignedTo = ? ORDER BY scheduledDate ASC";
        try {
            ps = con.prepareStatement(xSql);
            ps.setInt(1, technicianId);
            rs = ps.executeQuery();
            
            while (rs.next()) {
                schedules.add(mapResultSetToMaintenanceSchedule(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return schedules;
    }
    
    /**
     * Get maintenance schedules by status
     */
    public List<MaintenanceSchedule> getSchedulesByStatus(String status) {
        List<MaintenanceSchedule> schedules = new ArrayList<>();
        xSql = "SELECT * FROM MaintenanceSchedule WHERE status = ? ORDER BY scheduledDate ASC";
        try {
            ps = con.prepareStatement(xSql);
            ps.setString(1, status);
            rs = ps.executeQuery();
            
            while (rs.next()) {
                schedules.add(mapResultSetToMaintenanceSchedule(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return schedules;
    }
    
    /**
     * Get upcoming maintenance schedules (next 7 days)
     */
    public List<MaintenanceSchedule> getUpcomingSchedules() {
        List<MaintenanceSchedule> schedules = new ArrayList<>();
        xSql = "SELECT * FROM MaintenanceSchedule " +
               "WHERE scheduledDate BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 7 DAY) " +
               "AND status IN ('Scheduled', 'Pending') " +
               "ORDER BY scheduledDate ASC";
        try {
            ps = con.prepareStatement(xSql);
            rs = ps.executeQuery();
            
            while (rs.next()) {
                schedules.add(mapResultSetToMaintenanceSchedule(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return schedules;
    }
    
    /**
     * Update maintenance schedule status
     */
    public boolean updateScheduleStatus(int scheduleId, String status) {
        xSql = "UPDATE MaintenanceSchedule SET status = ? WHERE scheduleId = ?";
        try {
            ps = con.prepareStatement(xSql);
            ps.setString(1, status);
            ps.setInt(2, scheduleId);
            
            int affectedRows = ps.executeUpdate();
            return affectedRows > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            closeResources();
        }
    }
    
    /**
     * Update maintenance schedule
     */
    public boolean updateMaintenanceSchedule(MaintenanceSchedule schedule) {
        xSql = "UPDATE MaintenanceSchedule SET requestId = ?, contractId = ?, equipmentId = ?, " +
               "assignedTo = ?, scheduledDate = ?, scheduleType = ?, recurrenceRule = ?, " +
               "status = ?, priorityId = ? WHERE scheduleId = ?";
        try {
            ps = con.prepareStatement(xSql);
            ps.setInt(1, schedule.getRequestId());
            // Handle nullable contractId
            if (schedule.getContractId() != null) {
                ps.setInt(2, schedule.getContractId());
            } else {
                ps.setNull(2, Types.INTEGER);
            }
            // Handle nullable equipmentId
            if (schedule.getEquipmentId() != null) {
                ps.setInt(3, schedule.getEquipmentId());
            } else {
                ps.setNull(3, Types.INTEGER);
            }
            ps.setInt(4, schedule.getAssignedTo());
            ps.setTimestamp(5, Timestamp.valueOf(schedule.getScheduledDate().atStartOfDay()));
            ps.setString(6, schedule.getScheduleType());
            ps.setString(7, schedule.getRecurrenceRule());
            ps.setString(8, schedule.getStatus());
            ps.setInt(9, schedule.getPriorityId());
            ps.setInt(10, schedule.getScheduleId());
            
            int affectedRows = ps.executeUpdate();
            return affectedRows > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            closeResources();
        }
    }
    
    /**
     * Get maintenance schedule by ID
     */
    public MaintenanceSchedule getScheduleById(int scheduleId) {
        xSql = "SELECT * FROM MaintenanceSchedule WHERE scheduleId = ?";
        try {
            ps = con.prepareStatement(xSql);
            ps.setInt(1, scheduleId);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToMaintenanceSchedule(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return null;
    }
    
    /**
     * Get maintenance schedules with equipment and technician details
     */
    public List<MaintenanceSchedule> getSchedulesWithDetails() {
        List<MaintenanceSchedule> schedules = new ArrayList<>();
        xSql = "SELECT ms.*, e.equipmentName, a.fullName as technicianName " +
               "FROM MaintenanceSchedule ms " +
               "LEFT JOIN Equipment e ON ms.equipmentId = e.equipmentId " +
               "LEFT JOIN Account a ON ms.assignedTo = a.accountId " +
               "ORDER BY ms.scheduledDate ASC";
        try {
            ps = con.prepareStatement(xSql);
            rs = ps.executeQuery();
            
            while (rs.next()) {
                MaintenanceSchedule schedule = mapResultSetToMaintenanceSchedule(rs);
                // Additional details can be added to a DTO if needed
                schedules.add(schedule);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return schedules;
    }
    
    /**
     * Delete maintenance schedule
     */
    public boolean deleteMaintenanceSchedule(int scheduleId) {
        xSql = "DELETE FROM MaintenanceSchedule WHERE scheduleId = ?";
        try {
            ps = con.prepareStatement(xSql);
            ps.setInt(1, scheduleId);
            
            int affectedRows = ps.executeUpdate();
            return affectedRows > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            closeResources();
        }
    }
    
    /**
     * Get overdue maintenance schedules
     */
    public List<MaintenanceSchedule> getOverdueSchedules() {
        List<MaintenanceSchedule> schedules = new ArrayList<>();
        xSql = "SELECT * FROM MaintenanceSchedule " +
               "WHERE scheduledDate < CURDATE() AND status IN ('Scheduled', 'Pending') " +
               "ORDER BY scheduledDate ASC";
        try {
            ps = con.prepareStatement(xSql);
            rs = ps.executeQuery();
            
            while (rs.next()) {
                schedules.add(mapResultSetToMaintenanceSchedule(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return schedules;
    }
    
    /**
     * Map ResultSet to MaintenanceSchedule object
     */
    private MaintenanceSchedule mapResultSetToMaintenanceSchedule(ResultSet rs) throws SQLException {
        MaintenanceSchedule schedule = new MaintenanceSchedule();
        schedule.setScheduleId(rs.getInt("scheduleId"));
        schedule.setRequestId(rs.getInt("requestId"));
        
        // Handle nullable contractId
        int contractId = rs.getInt("contractId");
        if (!rs.wasNull()) {
            schedule.setContractId(contractId);
        } else {
            schedule.setContractId(null);
        }
        
        // Handle nullable equipmentId
        int equipmentId = rs.getInt("equipmentId");
        if (!rs.wasNull()) {
            schedule.setEquipmentId(equipmentId);
        } else {
            schedule.setEquipmentId(null);
        }
        
        schedule.setAssignedTo(rs.getInt("assignedTo"));
        schedule.setScheduledDate(rs.getTimestamp("scheduledDate").toLocalDateTime().toLocalDate());
        schedule.setScheduleType(rs.getString("scheduleType"));
        schedule.setRecurrenceRule(rs.getString("recurrenceRule"));
        schedule.setStatus(rs.getString("status"));
        schedule.setPriorityId(rs.getInt("priorityId"));
        
        return schedule;
    }
    
    /**
     * Close database resources
     */
    private void closeResources() {
        try {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}