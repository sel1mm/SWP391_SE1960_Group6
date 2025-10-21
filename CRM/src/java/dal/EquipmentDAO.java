package dal;

import model.Equipment;
import java.sql.*;

public class EquipmentDAO extends MyDAO {
    
    /**
     * Lấy thông tin equipment theo ID
     */
    public Equipment getEquipmentById(int equipmentId) {
        xSql = "SELECT * FROM Equipment WHERE equipmentId = ?";
        try {
            ps = con.prepareStatement(xSql);
            ps.setInt(1, equipmentId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapResultSetToEquipment(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return null;
    }
    
    /**
     * Lấy serial number của equipment
     */
    public String getSerialNumberById(int equipmentId) {
        xSql = "SELECT serialNumber FROM Equipment WHERE equipmentId = ?";
        try {
            ps = con.prepareStatement(xSql);
            ps.setInt(1, equipmentId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getString("serialNumber");
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return null;
    }
    
    /**
     * Lấy model của equipment
     */
    public String getModelById(int equipmentId) {
        xSql = "SELECT model FROM Equipment WHERE equipmentId = ?";
        try {
            ps = con.prepareStatement(xSql);
            ps.setInt(1, equipmentId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getString("model");
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return null;
    }
    
    /**
     * Kiểm tra equipment có tồn tại không
     */
    public boolean isEquipmentExists(int equipmentId) {
        xSql = "SELECT equipmentId FROM Equipment WHERE equipmentId = ?";
        try {
            ps = con.prepareStatement(xSql);
            ps.setInt(1, equipmentId);
            rs = ps.executeQuery();
            return rs.next();
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            closeResources();
        }
    }
    
    /**
     * Map ResultSet to Equipment
     * FIX: Convert java.sql.Date to LocalDate
     */
    private Equipment mapResultSetToEquipment(ResultSet rs) throws SQLException {
        Equipment equipment = new Equipment();
        equipment.setEquipmentId(rs.getInt("equipmentId"));
        equipment.setSerialNumber(rs.getString("serialNumber"));
        equipment.setModel(rs.getString("model"));
        equipment.setDescription(rs.getString("description"));
        
        // Fix: Convert java.sql.Date to LocalDate
        Date installDate = rs.getDate("installDate");
        if (installDate != null) {
            equipment.setInstallDate(installDate.toLocalDate());
        }
        
        equipment.setLastUpdatedBy(rs.getInt("lastUpdatedBy"));
        
        Date lastUpdatedDate = rs.getDate("lastUpdatedDate");
        if (lastUpdatedDate != null) {
            equipment.setLastUpdatedDate(lastUpdatedDate.toLocalDate());
        }
        
        return equipment;
    }
    
    /**
     * Đóng resources
     */
    private void closeResources() {
        try {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    public List<Equipment> getAllEquipment() {
        List<Equipment> list = new ArrayList<>();
        String sql = "SELECT equipmentId, serialNumber, model, description FROM Equipment";

        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Equipment e = new Equipment();
                e.setEquipmentId(rs.getInt("equipmentId"));
                e.setSerialNumber(rs.getString("serialNumber"));
                e.setModel(rs.getString("model"));
                e.setDescription(rs.getString("description"));
                list.add(e);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }
}