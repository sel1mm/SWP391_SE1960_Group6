package dal;

import model.Equipment;
import model.EquipmentWithStatus;
import model.ContractEquipment;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO for Equipment operations.
 * Modified to use Storekeeper's Part/PartDetail/Inventory system while maintaining Equipment interface.
 */
public class EquipmentDAO extends DBContext {
    
    /**
     * Get all equipment from inventory (using Part/PartDetail system)
     */
    public List<Equipment> getAllEquipment() {
        List<Equipment> list = new ArrayList<>();
        String sql = "SELECT " +
                     "    pd.partDetailId as equipmentId, " +
                     "    pd.serialNumber, " +
                     "    p.partName as model, " +
                     "    p.description, " +
                     "    pd.lastUpdatedDate as installDate, " +
                     "    pd.lastUpdatedBy, " +
                     "    pd.lastUpdatedDate, " +
                     "    pd.status, " +
                     "    pd.location " +
                     "FROM PartDetail pd " +
                     "JOIN Part p ON pd.partId = p.partId " +
                     "ORDER BY pd.partDetailId DESC";

        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Equipment e = new Equipment();
                e.setEquipmentId(rs.getInt("equipmentId"));
                e.setSerialNumber(rs.getString("serialNumber"));
                e.setModel(rs.getString("model"));
                e.setDescription(rs.getString("description"));
                e.setLastUpdatedBy(rs.getInt("lastUpdatedBy"));
                
                Date installDate = rs.getDate("installDate");
                if (installDate != null) {
                    e.setInstallDate(installDate.toLocalDate());
                }
                
                Date lastUpdatedDate = rs.getDate("lastUpdatedDate");
                if (lastUpdatedDate != null) {
                    e.setLastUpdatedDate(lastUpdatedDate.toLocalDate());
                }
                
                list.add(e);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }
    
    /**
     * Get equipment with inventory status information
     */
    public List<EquipmentWithStatus> getEquipmentWithStatus() {
        List<EquipmentWithStatus> list = new ArrayList<>();
        String sql = "SELECT " +
                     "    pd.partDetailId as equipmentId, " +
                     "    pd.serialNumber, " +
                     "    p.partName as model, " +
                     "    p.description, " +
                     "    pd.lastUpdatedDate as installDate, " +
                     "    pd.lastUpdatedBy, " +
                     "    pd.lastUpdatedDate, " +
                     "    pd.status, " +
                     "    pd.location, " +
                     "    p.unitPrice " +
                     "FROM PartDetail pd " +
                     "JOIN Part p ON pd.partId = p.partId " +
                     "ORDER BY pd.partDetailId DESC";

        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                EquipmentWithStatus e = new EquipmentWithStatus();
                e.setEquipmentId(rs.getInt("equipmentId"));
                e.setSerialNumber(rs.getString("serialNumber"));
                e.setModel(rs.getString("model"));
                e.setDescription(rs.getString("description"));
                e.setLastUpdatedBy(rs.getInt("lastUpdatedBy"));
                e.setStatus(rs.getString("status"));
                e.setLocation(rs.getString("location"));
                e.setUnitPrice(rs.getDouble("unitPrice"));
                
                Date installDate = rs.getDate("installDate");
                if (installDate != null) {
                    e.setInstallDate(installDate.toLocalDate());
                }
                
                Date lastUpdatedDate = rs.getDate("lastUpdatedDate");
                if (lastUpdatedDate != null) {
                    e.setLastUpdatedDate(lastUpdatedDate.toLocalDate());
                }
                
                list.add(e);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }
    
    /**
     * Find equipment by ID (using PartDetail ID)
     */
    public Equipment findById(int equipmentId) throws SQLException {
        String sql = "SELECT " +
                     "    pd.partDetailId as equipmentId, " +
                     "    pd.serialNumber, " +
                     "    p.partName as model, " +
                     "    p.description, " +
                     "    pd.lastUpdatedDate as installDate, " +
                     "    pd.lastUpdatedBy, " +
                     "    pd.lastUpdatedDate, " +
                     "    pd.status " +
                     "FROM PartDetail pd " +
                     "JOIN Part p ON pd.partId = p.partId " +
                     "WHERE pd.partDetailId = ?";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, equipmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToEquipment(rs);
                }
            }
        } catch (SQLException e) {
            System.out.println("❌ Error finding equipment by ID: " + e.getMessage());
        }
        return null;
    }
    
    /**
     * Find equipment by serial number
     */
    public Equipment findBySerialNumber(String serialNumber) throws SQLException {
        String sql = "SELECT " +
                     "    pd.partDetailId as equipmentId, " +
                     "    pd.serialNumber, " +
                     "    p.partName as model, " +
                     "    p.description, " +
                     "    pd.lastUpdatedDate as installDate, " +
                     "    pd.lastUpdatedBy, " +
                     "    pd.lastUpdatedDate, " +
                     "    pd.status " +
                     "FROM PartDetail pd " +
                     "JOIN Part p ON pd.partId = p.partId " +
                     "WHERE pd.serialNumber = ?";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, serialNumber);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToEquipment(rs);
                }
            }
        } catch (SQLException e) {
            System.out.println("❌ Error finding equipment by serial number: " + e.getMessage());
        }
        return null;
    }
    
    /**
     * Search equipment by model or description (using Part/PartDetail system)
     */
    public List<Equipment> searchEquipment(String searchQuery, int page, int pageSize) throws SQLException {
        List<Equipment> equipmentList = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT " +
                   "    pd.partDetailId as equipmentId, " +
                   "    pd.serialNumber, " +
                   "    p.partName as model, " +
                   "    p.description, " +
                   "    pd.lastUpdatedDate as installDate, " +
                   "    pd.lastUpdatedBy, " +
                   "    pd.lastUpdatedDate, " +
                   "    pd.status " +
                   "FROM PartDetail pd " +
                   "JOIN Part p ON pd.partId = p.partId " +
                   "WHERE 1=1");
        
        List<Object> params = new ArrayList<>();
        
        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            sql.append(" AND (p.partName LIKE ? OR p.description LIKE ? OR pd.serialNumber LIKE ?)");
            String searchPattern = "%" + searchQuery.trim() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
        }
        
        sql.append(" ORDER BY pd.partDetailId DESC LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add((page - 1) * pageSize);
        
        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    equipmentList.add(mapResultSetToEquipment(rs));
                }
            }
        } catch (SQLException e) {
            System.out.println("❌ Error searching equipment: " + e.getMessage());
        }
        
        return equipmentList;
    }
    
    /**
     * Get equipment count
     */
    public int getEquipmentCount(String searchQuery) throws SQLException {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) FROM PartDetail pd JOIN Part p ON pd.partId = p.partId WHERE 1=1");
        
        List<Object> params = new ArrayList<>();
        
        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            sql.append(" AND (p.partName LIKE ? OR p.description LIKE ? OR pd.serialNumber LIKE ?)");
            String searchPattern = "%" + searchQuery.trim() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
        }
        
        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            System.out.println("❌ Error getting equipment count: " + e.getMessage());
        }
        return 0;
    }
    
    /**
     * Map ResultSet to Equipment object
     */
    private Equipment mapResultSetToEquipment(ResultSet rs) throws SQLException {
        Equipment equipment = new Equipment();
        equipment.setEquipmentId(rs.getInt("equipmentId"));
        equipment.setSerialNumber(rs.getString("serialNumber"));
        equipment.setModel(rs.getString("model"));
        equipment.setDescription(rs.getString("description"));
        
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
     * Find equipment by contract ID (for backward compatibility)
     * Note: This method may need to be adapted based on how contracts relate to parts
     */
    public List<Equipment> findByContractId(int contractId) throws SQLException {
        List<Equipment> equipmentList = new ArrayList<>();
        // For now, return all equipment since contract-equipment relationship 
        // needs to be defined based on business requirements
        return getAllEquipment();
    }
    
    /**
     * Find contract-equipment relationships by contract ID (for backward compatibility)
     */
    public List<ContractEquipment> findContractEquipmentByContractId(int contractId) throws SQLException {
        List<ContractEquipment> contractEquipmentList = new ArrayList<>();
        // This would need to be implemented based on how contracts relate to parts
        // For now, return empty list
        return contractEquipmentList;
    }
}