package dal;

import model.TechnicianWorkload;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.time.LocalDateTime;
import java.math.BigDecimal;

public class TechnicianWorkloadDAO extends MyDAO {
    
    /**
     * Create or update technician workload
     */
    public boolean createOrUpdateWorkload(TechnicianWorkload workload) {
        // First check if workload exists for this technician
        if (getWorkloadByTechnician(workload.getTechnicianId()) != null) {
            return updateWorkload(workload);
        } else {
            return createWorkload(workload) > 0;
        }
    }
    
    /**
     * Create a new technician workload
     */
    private int createWorkload(TechnicianWorkload workload) {
        xSql = "INSERT INTO TechnicianWorkload (technicianId, currentActiveTasks, maxConcurrentTasks, " +
               "averageCompletionTime, lastAssignedDate, lastUpdated) " +
               "VALUES (?, ?, ?, ?, ?, ?)";
        try {
            ps = con.prepareStatement(xSql, Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, workload.getTechnicianId());
            ps.setInt(2, workload.getCurrentActiveTasks());
            ps.setInt(3, workload.getMaxConcurrentTasks());
            ps.setBigDecimal(4, workload.getAverageCompletionTime());
            ps.setTimestamp(5, workload.getLastAssignedDate() != null ? 
                           Timestamp.valueOf(workload.getLastAssignedDate()) : null);
            ps.setTimestamp(6, Timestamp.valueOf(workload.getLastUpdated()));
            
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
     * Update existing technician workload
     */
    private boolean updateWorkload(TechnicianWorkload workload) {
        xSql = "UPDATE TechnicianWorkload SET currentActiveTasks = ?, maxConcurrentTasks = ?, " +
               "averageCompletionTime = ?, lastAssignedDate = ?, lastUpdated = ? " +
               "WHERE technicianId = ?";
        try {
            ps = con.prepareStatement(xSql);
            ps.setInt(1, workload.getCurrentActiveTasks());
            ps.setInt(2, workload.getMaxConcurrentTasks());
            ps.setBigDecimal(3, workload.getAverageCompletionTime());
            ps.setTimestamp(4, workload.getLastAssignedDate() != null ? 
                           Timestamp.valueOf(workload.getLastAssignedDate()) : null);
            ps.setTimestamp(5, Timestamp.valueOf(LocalDateTime.now()));
            ps.setInt(6, workload.getTechnicianId());
            
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
     * Get workload by technician ID
     */
    public TechnicianWorkload getWorkloadByTechnician(int technicianId) {
        xSql = "SELECT * FROM TechnicianWorkload WHERE technicianId = ?";
        try {
            ps = con.prepareStatement(xSql);
            ps.setInt(1, technicianId);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToTechnicianWorkload(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return null;
    }
    
    /**
     * Get all technician workloads
     */
    public List<TechnicianWorkload> getAllWorkloads() {
        List<TechnicianWorkload> workloads = new ArrayList<>();
        xSql = "SELECT * FROM TechnicianWorkload ORDER BY technicianId";
        try {
            ps = con.prepareStatement(xSql);
            rs = ps.executeQuery();
            
            while (rs.next()) {
                workloads.add(mapResultSetToTechnicianWorkload(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return workloads;
    }
    
    /**
     * Get available technicians (those with capacity for more tasks)
     */
    public List<TechnicianWorkload> getAvailableTechnicians() {
        List<TechnicianWorkload> workloads = new ArrayList<>();
        xSql = "SELECT tw.*, a.fullName as technicianName " +
               "FROM TechnicianWorkload tw " +
               "INNER JOIN Account a ON tw.technicianId = a.accountId " +
               "WHERE tw.currentActiveTasks < tw.maxConcurrentTasks " +
               "ORDER BY (tw.maxConcurrentTasks - tw.currentActiveTasks) DESC, tw.averageCompletionTime ASC";
        try {
            ps = con.prepareStatement(xSql);
            rs = ps.executeQuery();
            
            while (rs.next()) {
                workloads.add(mapResultSetToTechnicianWorkload(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return workloads;
    }
    
    /**
     * Increment active tasks for a technician
     */
    public boolean incrementActiveTasks(int technicianId) {
        xSql = "UPDATE TechnicianWorkload SET currentActiveTasks = currentActiveTasks + 1, " +
               "lastAssignedDate = ?, lastUpdated = ? WHERE technicianId = ?";
        try {
            ps = con.prepareStatement(xSql);
            ps.setTimestamp(1, Timestamp.valueOf(LocalDateTime.now()));
            ps.setTimestamp(2, Timestamp.valueOf(LocalDateTime.now()));
            ps.setInt(3, technicianId);
            
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
     * Decrement active tasks for a technician
     */
    public boolean decrementActiveTasks(int technicianId) {
        xSql = "UPDATE TechnicianWorkload SET currentActiveTasks = " +
               "CASE WHEN currentActiveTasks > 0 THEN currentActiveTasks - 1 ELSE 0 END, " +
               "lastUpdated = ? WHERE technicianId = ?";
        try {
            ps = con.prepareStatement(xSql);
            ps.setTimestamp(1, Timestamp.valueOf(LocalDateTime.now()));
            ps.setInt(2, technicianId);
            
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
     * Update average completion time for a technician
     */
    public boolean updateAverageCompletionTime(int technicianId, BigDecimal newCompletionTime) {
        xSql = "UPDATE TechnicianWorkload SET averageCompletionTime = " +
               "(averageCompletionTime + ?) / 2, lastUpdated = ? WHERE technicianId = ?";
        try {
            ps = con.prepareStatement(xSql);
            ps.setBigDecimal(1, newCompletionTime);
            ps.setTimestamp(2, Timestamp.valueOf(LocalDateTime.now()));
            ps.setInt(3, technicianId);
            
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
     * Get technicians with workload details for assignment
     */
    public List<TechnicianWorkload> getTechniciansForAssignment() {
        List<TechnicianWorkload> workloads = new ArrayList<>();
        xSql = "SELECT tw.*, a.fullName as technicianName, a.email " +
               "FROM TechnicianWorkload tw " +
               "INNER JOIN Account a ON tw.technicianId = a.accountId " +
               "INNER JOIN AccountRole ar ON a.accountId = ar.accountId " +
               "INNER JOIN Role r ON ar.roleId = r.roleId " +
               "WHERE r.roleName = 'Technician' " +
               "ORDER BY (tw.maxConcurrentTasks - tw.currentActiveTasks) DESC, tw.averageCompletionTime ASC";
        try {
            ps = con.prepareStatement(xSql);
            rs = ps.executeQuery();
            
            while (rs.next()) {
                workloads.add(mapResultSetToTechnicianWorkload(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return workloads;
    }
    
    /**
     * Initialize workload for a new technician
     */
    public boolean initializeWorkloadForTechnician(int technicianId, int maxConcurrentTasks) {
        TechnicianWorkload workload = new TechnicianWorkload();
        workload.setTechnicianId(technicianId);
        workload.setCurrentActiveTasks(0);
        workload.setMaxConcurrentTasks(maxConcurrentTasks);
        workload.setAverageCompletionTime(new BigDecimal("8.0")); // Default 8 hours
        workload.setLastUpdated(LocalDateTime.now());
        
        return createWorkload(workload) > 0;
    }
    
    /**
     * Delete workload for a technician
     */
    public boolean deleteWorkload(int technicianId) {
        xSql = "DELETE FROM TechnicianWorkload WHERE technicianId = ?";
        try {
            ps = con.prepareStatement(xSql);
            ps.setInt(1, technicianId);
            
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
     * Map ResultSet to TechnicianWorkload object
     */
    private TechnicianWorkload mapResultSetToTechnicianWorkload(ResultSet rs) throws SQLException {
        TechnicianWorkload workload = new TechnicianWorkload();
        workload.setWorkloadId(rs.getInt("workloadId"));
        workload.setTechnicianId(rs.getInt("technicianId"));
        workload.setCurrentActiveTasks(rs.getInt("currentActiveTasks"));
        workload.setMaxConcurrentTasks(rs.getInt("maxConcurrentTasks"));
        workload.setAverageCompletionTime(rs.getBigDecimal("averageCompletionTime"));
        
        Timestamp lastAssigned = rs.getTimestamp("lastAssignedDate");
        if (lastAssigned != null) {
            workload.setLastAssignedDate(lastAssigned.toLocalDateTime());
        }
        
        workload.setLastUpdated(rs.getTimestamp("lastUpdated").toLocalDateTime());
        
        return workload;
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