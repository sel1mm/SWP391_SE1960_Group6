package dal;

import model.WorkAssignment;
import model.Account;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.math.BigDecimal;
import java.time.LocalDateTime;

public class WorkAssignmentDAO extends MyDAO {
    
    /**
     * Create a new work assignment
     */
    public int createWorkAssignment(WorkAssignment assignment) {
        xSql = "INSERT INTO WorkAssignment (taskId, assignedBy, assignedTo, assignmentDate, " +
               "estimatedDuration, requiredSkills, priority, acceptedByTechnician) " +
               "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try {
            ps = con.prepareStatement(xSql, Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, assignment.getTaskId());
            ps.setInt(2, assignment.getAssignedBy());
            ps.setInt(3, assignment.getAssignedTo());
            ps.setTimestamp(4, Timestamp.valueOf(assignment.getAssignmentDate()));
            ps.setBigDecimal(5, assignment.getEstimatedDuration());
            ps.setString(6, assignment.getRequiredSkills());
            ps.setString(7, assignment.getPriority());
            ps.setBoolean(8, assignment.isAcceptedByTechnician());
            
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
     * Get all assignments for a specific technician
     */
    public List<WorkAssignment> getAssignmentsByTechnician(int technicianId) {
        List<WorkAssignment> assignments = new ArrayList<>();
        xSql = "SELECT * FROM WorkAssignment WHERE assignedTo = ? ORDER BY assignmentDate DESC";
        try {
            ps = con.prepareStatement(xSql);
            ps.setInt(1, technicianId);
            rs = ps.executeQuery();
            
            while (rs.next()) {
                assignments.add(mapResultSetToWorkAssignment(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return assignments;
    }
    
    /**
     * Get all assignments created by a specific manager
     */
    public List<WorkAssignment> getAssignmentsByManager(int managerId) {
        List<WorkAssignment> assignments = new ArrayList<>();
        xSql = "SELECT * FROM WorkAssignment WHERE assignedBy = ? ORDER BY assignmentDate DESC";
        try {
            ps = con.prepareStatement(xSql);
            ps.setInt(1, managerId);
            rs = ps.executeQuery();
            
            while (rs.next()) {
                assignments.add(mapResultSetToWorkAssignment(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return assignments;
    }
    
    /**
     * Update assignment acceptance status
     */
    public boolean updateAssignmentAcceptance(int assignmentId, boolean accepted) {
        xSql = "UPDATE WorkAssignment SET acceptedByTechnician = ?, acceptedAt = ? WHERE assignmentId = ?";
        try {
            ps = con.prepareStatement(xSql);
            ps.setBoolean(1, accepted);
            ps.setTimestamp(2, accepted ? Timestamp.valueOf(LocalDateTime.now()) : null);
            ps.setInt(3, assignmentId);
            
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
     * Get assignment by ID
     */
    public WorkAssignment getAssignmentById(int assignmentId) {
        xSql = "SELECT * FROM WorkAssignment WHERE assignmentId = ?";
        try {
            ps = con.prepareStatement(xSql);
            ps.setInt(1, assignmentId);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToWorkAssignment(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return null;
    }
    
    /**
     * Get pending assignments (not yet accepted)
     */
    public List<WorkAssignment> getPendingAssignments() {
        List<WorkAssignment> assignments = new ArrayList<>();
        xSql = "SELECT * FROM WorkAssignment WHERE acceptedByTechnician = 0 ORDER BY assignmentDate DESC";
        try {
            ps = con.prepareStatement(xSql);
            rs = ps.executeQuery();
            
            while (rs.next()) {
                assignments.add(mapResultSetToWorkAssignment(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return assignments;
    }
    
    /**
     * Get assignments with technician details for manager view
     */
    public List<WorkAssignment> getAssignmentsWithTechnicianDetails(int managerId) {
        List<WorkAssignment> assignments = new ArrayList<>();
        xSql = "SELECT wa.*, a.fullName as technicianName, a.email as technicianEmail " +
               "FROM WorkAssignment wa " +
               "INNER JOIN Account a ON wa.assignedTo = a.accountId " +
               "WHERE wa.assignedBy = ? " +
               "ORDER BY wa.assignmentDate DESC";
        try {
            ps = con.prepareStatement(xSql);
            ps.setInt(1, managerId);
            rs = ps.executeQuery();
            
            while (rs.next()) {
                WorkAssignment assignment = mapResultSetToWorkAssignment(rs);
                // Additional technician details can be added to a DTO if needed
                assignments.add(assignment);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return assignments;
    }
    
    /**
     * Delete assignment
     */
    public boolean deleteAssignment(int assignmentId) {
        xSql = "DELETE FROM WorkAssignment WHERE assignmentId = ?";
        try {
            ps = con.prepareStatement(xSql);
            ps.setInt(1, assignmentId);
            
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
     * Map ResultSet to WorkAssignment object
     */
    private WorkAssignment mapResultSetToWorkAssignment(ResultSet rs) throws SQLException {
        WorkAssignment assignment = new WorkAssignment();
        assignment.setAssignmentId(rs.getInt("assignmentId"));
        assignment.setTaskId(rs.getInt("taskId"));
        assignment.setAssignedBy(rs.getInt("assignedBy"));
        assignment.setAssignedTo(rs.getInt("assignedTo"));
        assignment.setAssignmentDate(rs.getTimestamp("assignmentDate").toLocalDateTime());
        assignment.setEstimatedDuration(rs.getBigDecimal("estimatedDuration"));
        assignment.setRequiredSkills(rs.getString("requiredSkills"));
        assignment.setPriority(rs.getString("priority"));
        assignment.setAcceptedByTechnician(rs.getBoolean("acceptedByTechnician"));
        
        Timestamp acceptedAt = rs.getTimestamp("acceptedAt");
        if (acceptedAt != null) {
            assignment.setAcceptedAt(acceptedAt.toLocalDateTime());
        }
        
        return assignment;
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