package dal;

import model.TechnicianSkill;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.time.LocalDateTime;

public class TechnicianSkillDAO extends MyDAO {
    
    /**
     * Create a new technician skill
     */
    public int createTechnicianSkill(TechnicianSkill skill) {
        xSql = "INSERT INTO TechnicianSkill (skillName, description, category, createdAt, updatedAt) " +
               "VALUES (?, ?, ?, ?, ?)";
        try {
            ps = con.prepareStatement(xSql, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, skill.getSkillName());
            ps.setString(2, skill.getDescription());
            ps.setString(3, skill.getCategory());
            ps.setTimestamp(4, Timestamp.valueOf(skill.getCreatedAt()));
            ps.setTimestamp(5, Timestamp.valueOf(skill.getUpdatedAt()));
            
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
     * Get all technician skills
     */
    public List<TechnicianSkill> getAllTechnicianSkills() {
        List<TechnicianSkill> skills = new ArrayList<>();
        xSql = "SELECT * FROM TechnicianSkill ORDER BY category, skillName";
        try {
            ps = con.prepareStatement(xSql);
            rs = ps.executeQuery();
            
            while (rs.next()) {
                skills.add(mapResultSetToTechnicianSkill(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return skills;
    }
    
    /**
     * Get skills by category
     */
    public List<TechnicianSkill> getSkillsByCategory(String category) {
        List<TechnicianSkill> skills = new ArrayList<>();
        xSql = "SELECT * FROM TechnicianSkill WHERE category = ? ORDER BY skillName";
        try {
            ps = con.prepareStatement(xSql);
            ps.setString(1, category);
            rs = ps.executeQuery();
            
            while (rs.next()) {
                skills.add(mapResultSetToTechnicianSkill(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return skills;
    }
    
    /**
     * Get skill by ID
     */
    public TechnicianSkill getSkillById(int skillId) {
        xSql = "SELECT * FROM TechnicianSkill WHERE skillId = ?";
        try {
            ps = con.prepareStatement(xSql);
            ps.setInt(1, skillId);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToTechnicianSkill(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return null;
    }
    
    /**
     * Update technician skill
     */
    public boolean updateTechnicianSkill(TechnicianSkill skill) {
        xSql = "UPDATE TechnicianSkill SET skillName = ?, description = ?, category = ?, updatedAt = ? " +
               "WHERE skillId = ?";
        try {
            ps = con.prepareStatement(xSql);
            ps.setString(1, skill.getSkillName());
            ps.setString(2, skill.getDescription());
            ps.setString(3, skill.getCategory());
            ps.setTimestamp(4, Timestamp.valueOf(LocalDateTime.now()));
            ps.setInt(5, skill.getSkillId());
            
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
     * Delete technician skill
     */
    public boolean deleteTechnicianSkill(int skillId) {
        xSql = "DELETE FROM TechnicianSkill WHERE skillId = ?";
        try {
            ps = con.prepareStatement(xSql);
            ps.setInt(1, skillId);
            
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
     * Search skills by name
     */
    public List<TechnicianSkill> searchSkillsByName(String skillName) {
        List<TechnicianSkill> skills = new ArrayList<>();
        xSql = "SELECT * FROM TechnicianSkill WHERE skillName LIKE ? ORDER BY skillName";
        try {
            ps = con.prepareStatement(xSql);
            ps.setString(1, "%" + skillName + "%");
            rs = ps.executeQuery();
            
            while (rs.next()) {
                skills.add(mapResultSetToTechnicianSkill(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return skills;
    }
    
    /**
     * Get all skill categories
     */
    public List<String> getAllSkillCategories() {
        List<String> categories = new ArrayList<>();
        xSql = "SELECT DISTINCT category FROM TechnicianSkill ORDER BY category";
        try {
            ps = con.prepareStatement(xSql);
            rs = ps.executeQuery();
            
            while (rs.next()) {
                categories.add(rs.getString("category"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return categories;
    }
    
    /**
     * Check if skill name already exists
     */
    public boolean isSkillNameExists(String skillName) {
        xSql = "SELECT COUNT(*) FROM TechnicianSkill WHERE skillName = ?";
        try {
            ps = con.prepareStatement(xSql);
            ps.setString(1, skillName);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return false;
    }
    
    /**
     * Check if skill name exists for update (excluding current skill)
     */
    public boolean isSkillNameExistsForUpdate(String skillName, int skillId) {
        xSql = "SELECT COUNT(*) FROM TechnicianSkill WHERE skillName = ? AND skillId != ?";
        try {
            ps = con.prepareStatement(xSql);
            ps.setString(1, skillName);
            ps.setInt(2, skillId);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return false;
    }
    
    /**
     * Get skills assigned to a specific technician
     */
    public List<TechnicianSkill> getSkillsByTechnician(int technicianId) {
        List<TechnicianSkill> skills = new ArrayList<>();
        xSql = "SELECT ts.* FROM TechnicianSkill ts " +
               "INNER JOIN TechnicianSkillAssignment tsa ON ts.skillId = tsa.skillId " +
               "WHERE tsa.technicianId = ? ORDER BY ts.category, ts.skillName";
        try {
            ps = con.prepareStatement(xSql);
            ps.setInt(1, technicianId);
            rs = ps.executeQuery();
            
            while (rs.next()) {
                skills.add(mapResultSetToTechnicianSkill(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return skills;
    }
    
    /**
     * Map ResultSet to TechnicianSkill object
     */
    private TechnicianSkill mapResultSetToTechnicianSkill(ResultSet rs) throws SQLException {
        TechnicianSkill skill = new TechnicianSkill();
        skill.setSkillId(rs.getInt("skillId"));
        skill.setSkillName(rs.getString("skillName"));
        skill.setDescription(rs.getString("description"));
        skill.setCategory(rs.getString("category"));
        skill.setCreatedAt(rs.getTimestamp("createdAt").toLocalDateTime());
        skill.setUpdatedAt(rs.getTimestamp("updatedAt").toLocalDateTime());
        
        return skill;
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