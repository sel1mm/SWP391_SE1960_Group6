package dal;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.Equipment;

/**
 * DAO for ContractEquipment operations
 */
public class ContractEquipmentDAO extends MyDAO {

    public static class ContractEquipmentRow {
        public long contractEquipmentId;
        public long contractId;
        public long equipmentId;
        public java.sql.Date startDate;
        public java.sql.Date endDate;
        public int quantity;
        public java.math.BigDecimal price;
        // Equipment details
        public String serialNumber;
        public String model;
        public String description;
        public java.sql.Date installDate;
    }

    /**
     * Get equipment for a specific contract
     */
    public List<ContractEquipmentRow> getEquipmentByContractId(long contractId) throws SQLException {
        List<ContractEquipmentRow> list = new ArrayList<>();
        xSql = "SELECT ce.contractEquipmentId, ce.contractId, ce.equipmentId, ce.startDate, ce.endDate, " +
               "ce.quantity, ce.price, e.serialNumber, e.model, e.description, e.installDate " +
               "FROM ContractEquipment ce " +
               "JOIN Equipment e ON ce.equipmentId = e.equipmentId " +
               "WHERE ce.contractId = ? " +
               "ORDER BY ce.startDate DESC";
        ps = con.prepareStatement(xSql);
        ps.setLong(1, contractId);
        rs = ps.executeQuery();
        while (rs.next()) {
            ContractEquipmentRow row = new ContractEquipmentRow();
            row.contractEquipmentId = rs.getLong("contractEquipmentId");
            row.contractId = rs.getLong("contractId");
            row.equipmentId = rs.getLong("equipmentId");
            row.startDate = rs.getDate("startDate");
            row.endDate = rs.getDate("endDate");
            row.quantity = rs.getInt("quantity");
            row.price = rs.getBigDecimal("price");
            row.serialNumber = rs.getString("serialNumber");
            row.model = rs.getString("model");
            row.description = rs.getString("description");
            row.installDate = rs.getDate("installDate");
            list.add(row);
        }
        return list;
    }

    /**
     * Add equipment to a contract
     */
    public long addEquipmentToContract(long contractId, long equipmentId, java.sql.Date startDate, 
                                     java.sql.Date endDate, int quantity, java.math.BigDecimal price) throws SQLException {
        xSql = "INSERT INTO ContractEquipment (contractId, equipmentId, startDate, endDate, quantity, price) " +
               "VALUES (?, ?, ?, ?, ?, ?)";
        ps = con.prepareStatement(xSql, java.sql.Statement.RETURN_GENERATED_KEYS);
        ps.setLong(1, contractId);
        ps.setLong(2, equipmentId);
        ps.setDate(3, startDate);
        ps.setDate(4, endDate);
        ps.setInt(5, quantity);
        ps.setBigDecimal(6, price);
        
        int affected = ps.executeUpdate();
        if (affected > 0) {
            rs = ps.getGeneratedKeys();
            if (rs.next()) {
                return rs.getLong(1);
            }
        }
        return 0L;
    }

    /**
     * Get all available equipment (not assigned to contracts)
     */
    public List<Equipment> getAvailableEquipment() throws SQLException {
        List<Equipment> list = new ArrayList<>();
        xSql = "SELECT e.equipmentId, e.serialNumber, e.model, e.description, e.installDate, " +
               "e.lastUpdatedBy, e.lastUpdatedDate " +
               "FROM Equipment e " +
               "LEFT JOIN ContractEquipment ce ON e.equipmentId = ce.equipmentId " +
               "WHERE ce.equipmentId IS NULL OR ce.endDate < CURDATE() " +
               "ORDER BY e.serialNumber";
        ps = con.prepareStatement(xSql);
        rs = ps.executeQuery();
        while (rs.next()) {
            Equipment equipment = new Equipment();
            equipment.setEquipmentId(rs.getInt("equipmentId"));
            equipment.setSerialNumber(rs.getString("serialNumber"));
            equipment.setModel(rs.getString("model"));
            equipment.setDescription(rs.getString("description"));
            
            java.sql.Date installDate = rs.getDate("installDate");
            if (installDate != null) {
                equipment.setInstallDate(installDate.toLocalDate());
            }
            
            equipment.setLastUpdatedBy(rs.getInt("lastUpdatedBy"));
            
            java.sql.Date lastUpdatedDate = rs.getDate("lastUpdatedDate");
            if (lastUpdatedDate != null) {
                equipment.setLastUpdatedDate(lastUpdatedDate.toLocalDate());
            }
            
            list.add(equipment);
        }
        return list;
    }
}
