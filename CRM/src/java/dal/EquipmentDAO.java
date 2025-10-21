package dal;

import model.Equipment;
import model.ContractEquipment;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO for Equipment operations.
 * Handles database operations for equipment and contract-equipment relationships.
 */
public class EquipmentDAO extends MyDAO {
    
    /**
     * Find equipment by contract ID
     */
    public List<Equipment> findByContractId(int contractId) throws SQLException {
        List<Equipment> equipmentList = new ArrayList<>();
        xSql = "SELECT e.equipmentId, e.serialNumber, e.model, e.description, e.installDate, " +
               "e.lastUpdatedBy, e.lastUpdatedDate " +
               "FROM Equipment e " +
               "INNER JOIN ContractEquipment ce ON e.equipmentId = ce.equipmentId " +
               "WHERE ce.contractId = ?";
        
        ps = con.prepareStatement(xSql);
        ps.setInt(1, contractId);
        rs = ps.executeQuery();
        
        while (rs.next()) {
            equipmentList.add(mapResultSetToEquipment(rs));
        }
        
        return equipmentList;
    }
    
    /**
     * Find equipment by ID
     */
    public Equipment findById(int equipmentId) throws SQLException {
        xSql = "SELECT * FROM Equipment WHERE equipmentId = ?";
        ps = con.prepareStatement(xSql);
        ps.setInt(1, equipmentId);
        rs = ps.executeQuery();
        
        if (rs.next()) {
            return mapResultSetToEquipment(rs);
        }
        return null;
    }
    
    /**
     * Find contract-equipment relationships by contract ID
     */
    public List<ContractEquipment> findContractEquipmentByContractId(int contractId) throws SQLException {
        List<ContractEquipment> contractEquipmentList = new ArrayList<>();
        xSql = "SELECT ce.contractEquipmentId, ce.contractId, ce.equipmentId, " +
               "ce.startDate, ce.endDate, ce.quantity, ce.price " +
               "FROM ContractEquipment ce WHERE ce.contractId = ?";
        
        ps = con.prepareStatement(xSql);
        ps.setInt(1, contractId);
        rs = ps.executeQuery();
        
        while (rs.next()) {
            contractEquipmentList.add(mapResultSetToContractEquipment(rs));
        }
        
        return contractEquipmentList;
    }
    
    /**
     * Find equipment by serial number
     */
    public Equipment findBySerialNumber(String serialNumber) throws SQLException {
        xSql = "SELECT * FROM Equipment WHERE serialNumber = ?";
        ps = con.prepareStatement(xSql);
        ps.setString(1, serialNumber);
        rs = ps.executeQuery();
        
        if (rs.next()) {
            return mapResultSetToEquipment(rs);
        }
        return null;
    }
    
    /**
     * Search equipment by model or description
     */
    public List<Equipment> searchEquipment(String searchQuery, int page, int pageSize) throws SQLException {
        List<Equipment> equipmentList = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT * FROM Equipment WHERE 1=1");
        
        List<Object> params = new ArrayList<>();
        
        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            sql.append(" AND (model LIKE ? OR description LIKE ? OR serialNumber LIKE ?)");
            String searchPattern = "%" + searchQuery.trim() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
        }
        
        sql.append(" ORDER BY installDate DESC LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add((page - 1) * pageSize);
        
        ps = con.prepareStatement(sql.toString());
        for (int i = 0; i < params.size(); i++) {
            ps.setObject(i + 1, params.get(i));
        }
        
        rs = ps.executeQuery();
        while (rs.next()) {
            equipmentList.add(mapResultSetToEquipment(rs));
        }
        
        return equipmentList;
    }
    
    /**
     * Get equipment count
     */
    public int getEquipmentCount(String searchQuery) throws SQLException {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) FROM Equipment WHERE 1=1");
        
        List<Object> params = new ArrayList<>();
        
        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            sql.append(" AND (model LIKE ? OR description LIKE ? OR serialNumber LIKE ?)");
            String searchPattern = "%" + searchQuery.trim() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
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
     * Map ResultSet to ContractEquipment object
     */
    private ContractEquipment mapResultSetToContractEquipment(ResultSet rs) throws SQLException {
        ContractEquipment contractEquipment = new ContractEquipment();
        contractEquipment.setContractEquipmentId(rs.getInt("contractEquipmentId"));
        contractEquipment.setContractId(rs.getInt("contractId"));
        contractEquipment.setEquipmentId(rs.getInt("equipmentId"));
        
        Date startDate = rs.getDate("startDate");
        if (startDate != null) {
            contractEquipment.setStartDate(startDate.toLocalDate());
        }
        
        Date endDate = rs.getDate("endDate");
        if (endDate != null) {
            contractEquipment.setEndDate(endDate.toLocalDate());
        }
        
        contractEquipment.setQuantity(rs.getInt("quantity"));
        contractEquipment.setPrice(rs.getBigDecimal("price"));
        
        return contractEquipment;
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