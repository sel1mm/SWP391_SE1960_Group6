package dal;

import model.Equipment;
import model.EquipmentWithStatus;
import model.ContractEquipment;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * DAO for Equipment operations. Modified to use Storekeeper's
 * Part/PartDetail/Inventory system while maintaining Equipment interface.
 */
public class EquipmentDAO extends DBContext {

    // ==================== CODE GỐC - GIỮ NGUYÊN 100% ====================
    /**
     * Get all equipment from inventory (using Part/PartDetail system)
     */
    public List<Equipment> getAllEquipment() {
        List<Equipment> list = new ArrayList<>();
        String sql = "SELECT equipmentId, serialNumber, model, description, installDate, lastUpdatedBy, lastUpdatedDate "
                + "FROM Equipment ORDER BY equipmentId DESC";

        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Equipment e = new Equipment();
                e.setEquipmentId(rs.getInt("equipmentId"));
                e.setSerialNumber(rs.getString("serialNumber"));
                e.setModel(rs.getString("model"));
                e.setDescription(rs.getString("description"));

                Date installDate = rs.getDate("installDate");
                if (installDate != null) {
                    e.setInstallDate(installDate.toLocalDate());
                }

                Date lastUpdatedDate = rs.getDate("lastUpdatedDate");
                if (lastUpdatedDate != null) {
                    e.setLastUpdatedDate(lastUpdatedDate.toLocalDate());
                }

                e.setLastUpdatedBy(rs.getInt("lastUpdatedBy"));

                list.add(e);
            }

        } catch (Exception ex) {
            ex.printStackTrace();
        }

        return list;
    }

    /**
     * Get equipment with inventory status information
     */
    public List<EquipmentWithStatus> getEquipmentWithStatus() {
        List<EquipmentWithStatus> list = new ArrayList<>();
        String sql = "SELECT "
                + "    pd.partDetailId as equipmentId, "
                + "    pd.serialNumber, "
                + "    p.partName as model, "
                + "    p.description, "
                + "    pd.lastUpdatedDate as installDate, "
                + "    pd.lastUpdatedBy, "
                + "    pd.lastUpdatedDate, "
                + "    pd.status, "
                + "    pd.location, "
                + "    p.unitPrice "
                + "FROM PartDetail pd "
                + "JOIN Part p ON pd.partId = p.partId "
                + "ORDER BY pd.lastUpdatedDate DESC, pd.partDetailId DESC";

        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

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
        String sql = "SELECT "
                + "    pd.partDetailId as equipmentId, "
                + "    pd.serialNumber, "
                + "    p.partName as model, "
                + "    p.description, "
                + "    pd.lastUpdatedDate as installDate, "
                + "    pd.lastUpdatedBy, "
                + "    pd.lastUpdatedDate, "
                + "    pd.status "
                + "FROM PartDetail pd "
                + "JOIN Part p ON pd.partId = p.partId "
                + "WHERE pd.partDetailId = ?";

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
        String sql = "SELECT "
                + "    pd.partDetailId as equipmentId, "
                + "    pd.serialNumber, "
                + "    p.partName as model, "
                + "    p.description, "
                + "    pd.lastUpdatedDate as installDate, "
                + "    pd.lastUpdatedBy, "
                + "    pd.lastUpdatedDate, "
                + "    pd.status "
                + "FROM PartDetail pd "
                + "JOIN Part p ON pd.partId = p.partId "
                + "WHERE pd.serialNumber = ?";

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
        sql.append("SELECT "
                + "    pd.partDetailId as equipmentId, "
                + "    pd.serialNumber, "
                + "    p.partName as model, "
                + "    p.description, "
                + "    pd.lastUpdatedDate as installDate, "
                + "    pd.lastUpdatedBy, "
                + "    pd.lastUpdatedDate, "
                + "    pd.status "
                + "FROM PartDetail pd "
                + "JOIN Part p ON pd.partId = p.partId "
                + "WHERE 1=1");

        List<Object> params = new ArrayList<>();

        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            sql.append(" AND (p.partName LIKE ? OR p.description LIKE ? OR pd.serialNumber LIKE ?)");
            String searchPattern = "%" + searchQuery.trim() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
        }

        sql.append(" ORDER BY pd.lastUpdatedDate DESC, pd.partDetailId DESC LIMIT ? OFFSET ?");
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
     */
    public List<Equipment> findByContractId(int contractId) throws SQLException {
        List<Equipment> equipmentList = new ArrayList<>();
        return getAllEquipment();
    }

    /**
     * Find contract-equipment relationships by contract ID
     */
    public List<ContractEquipment> findContractEquipmentByContractId(int contractId) throws SQLException {
        List<ContractEquipment> contractEquipmentList = new ArrayList<>();
        return contractEquipmentList;
    }

    /**
     * Get all equipment assigned to contracts of a specific customer
     */
    public List<Equipment> getEquipmentByCustomerContracts(int customerId) throws SQLException {
        List<Equipment> list = new ArrayList<>();
        String sql = "SELECT e.equipmentId, e.serialNumber, e.model, e.description, "
                + "       e.installDate, e.lastUpdatedBy, e.lastUpdatedDate "
                + "FROM Equipment e "
                + "JOIN ContractEquipment ce ON e.equipmentId = ce.equipmentId "
                + "JOIN Contract c ON ce.contractId = c.contractId "
                + "WHERE c.customerId = ? "
                + "ORDER BY e.equipmentId DESC";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Equipment e = new Equipment();
                    e.setEquipmentId(rs.getInt("equipmentId"));
                    e.setSerialNumber(rs.getString("serialNumber"));
                    e.setModel(rs.getString("model"));
                    e.setDescription(rs.getString("description"));

                    Date installDate = rs.getDate("installDate");
                    if (installDate != null) {
                        e.setInstallDate(installDate.toLocalDate());
                    }

                    e.setLastUpdatedBy(rs.getInt("lastUpdatedBy"));

                    Date lastUpdatedDate = rs.getDate("lastUpdatedDate");
                    if (lastUpdatedDate != null) {
                        e.setLastUpdatedDate(lastUpdatedDate.toLocalDate());
                    }

                    list.add(e);
                }
            }
        } catch (SQLException e) {
            System.out.println("❌ Error in getEquipmentByCustomerContracts: " + e.getMessage());
            throw e;
        }
        return list;
    }

    
        /**
     * Check if equipmentId exists and is active
     */
    public boolean isValidEquipment(int equipmentId) {
        String sql = "SELECT COUNT(*) FROM Equipment WHERE equipmentId = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, equipmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            System.out.println("❌ Error in isValidEquipment: " + e.getMessage());
        }
        return false;
    }

    /**
     * Get all equipment owned by a customer (not via Contract)
     * — Optional helper if you later want to load equipment directly by customerId
     */
    public List<Equipment> getEquipmentByCustomer(int customerId) {
        List<Equipment> list = new ArrayList<>();
        String sql = "SELECT e.equipmentId, e.serialNumber, e.model, e.description, "
                   + "       e.installDate, e.lastUpdatedBy, e.lastUpdatedDate "
                   + "FROM Equipment e "
                   + "WHERE e.customerId = ? "
                   + "ORDER BY e.equipmentId DESC";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Equipment e = new Equipment();
                    e.setEquipmentId(rs.getInt("equipmentId"));
                    e.setSerialNumber(rs.getString("serialNumber"));
                    e.setModel(rs.getString("model"));
                    e.setDescription(rs.getString("description"));

                    Date installDate = rs.getDate("installDate");
                    if (installDate != null) {
                        e.setInstallDate(installDate.toLocalDate());
                    }

                    e.setLastUpdatedBy(rs.getInt("lastUpdatedBy"));

                    Date lastUpdatedDate = rs.getDate("lastUpdatedDate");
                    if (lastUpdatedDate != null) {
                        e.setLastUpdatedDate(lastUpdatedDate.toLocalDate());
                    }

                    list.add(e);
                }
            }
        } catch (SQLException e) {
            System.out.println("❌ Error in getEquipmentByCustomer: " + e.getMessage());
        }
        return list;
    }


    // ==================== PHẦN BỔ SUNG CHO CUSTOMER EQUIPMENT VIEW ====================
    /**
     * Get equipment statistics by customer Returns: total, active, repair,
     * maintenance counts
     */
    public Map<String, Integer> getEquipmentStatsByCustomer(int customerId) {
        Map<String, Integer> stats = new HashMap<>();

        // Khởi tạo giá trị mặc định
        stats.put("total", 0);
        stats.put("active", 0);
        stats.put("repair", 0);
        stats.put("maintenance", 0);

        try {
            List<Equipment> allEquipment = getEquipmentByCustomerContracts(customerId);
            int total = allEquipment.size();
            int repair = 0;
            int maintenance = 0;

            for (Equipment eq : allEquipment) {
                String status = getEquipmentStatus(eq.getEquipmentId());
                if ("Repair".equals(status)) {
                    repair++;
                } else if ("Maintenance".equals(status)) {
                    maintenance++;
                }
            }

            int active = total - repair - maintenance;
            if (active < 0) {
                active = 0;
            }

            stats.put("total", total);
            stats.put("active", active);
            stats.put("repair", repair);
            stats.put("maintenance", maintenance);

        } catch (SQLException e) {
            System.out.println("❌ Error in getEquipmentStatsByCustomer: " + e.getMessage());
            e.printStackTrace();
        }

        return stats;
    }

    /**
     * Get status for a specific equipment Returns: "Active", "Repair", or
     * "Maintenance"
     */
    public String getEquipmentStatus(int equipmentId) {
        // Check for active service request (Repair)
        String repairSql = "SELECT COUNT(*) as cnt FROM ServiceRequest "
                + "WHERE equipmentId = ? "
                + "  AND status IN ('Pending', 'Awaiting Approval', 'Approved')";

        try (PreparedStatement ps = connection.prepareStatement(repairSql)) {
            ps.setInt(1, equipmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next() && rs.getInt("cnt") > 0) {
                    return "Repair";
                }
            }
        } catch (SQLException e) {
            System.out.println("❌ Error checking repair status: " + e.getMessage());
            e.printStackTrace();
        }

        // Check for scheduled maintenance
        String maintenanceSql = "SELECT COUNT(*) as cnt FROM MaintenanceSchedule "
                + "WHERE equipmentId = ? "
                + "  AND status = 'Scheduled' "
                + "  AND scheduledDate >= CURDATE()";

        try (PreparedStatement ps = connection.prepareStatement(maintenanceSql)) {
            ps.setInt(1, equipmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next() && rs.getInt("cnt") > 0) {
                    return "Maintenance";
                }
            }
        } catch (SQLException e) {
            System.out.println("❌ Error checking maintenance status: " + e.getMessage());
            e.printStackTrace();
        }

        return "Active";
    }

    /**
     * Get contract ID for an equipment belonging to a customer Returns
     * formatted contract ID (e.g., "HD001")
     */
    public String getContractIdForEquipment(int equipmentId, int customerId) {
        String sql = "SELECT c.contractId FROM Contract c "
                + "JOIN ContractEquipment ce ON c.contractId = ce.contractId "
                + "WHERE ce.equipmentId = ? "
                + "  AND c.customerId = ? "
                + "  AND c.status = 'Active' "
                + "ORDER BY c.contractDate DESC "
                + "LIMIT 1";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, equipmentId);
            ps.setInt(2, customerId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int contractId = rs.getInt("contractId");
                    return "HD" + String.format("%03d", contractId);
                }
            }
        } catch (SQLException e) {
            System.out.println("❌ Error getting contract ID: " + e.getMessage());
            e.printStackTrace();
        }
        return "N/A";
    }

    public List<EquipmentWithStatus> getEquipmentByContractId(int contractId) {
    List<EquipmentWithStatus> list = new ArrayList<>();
    String sql = """
        SELECT e.equipmentId, e.serialNumber, e.model, e.description, e.installDate,
               ce.startDate, ce.endDate, ce.price
        FROM ContractEquipment ce
        JOIN Equipment e ON ce.equipmentId = e.equipmentId
        WHERE ce.contractId = ?
    """;
    try (PreparedStatement ps = connection.prepareStatement(sql)) {
        ps.setInt(1, contractId);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            EquipmentWithStatus eq = new EquipmentWithStatus();
            eq.setEquipmentId(rs.getInt("equipmentId"));
            eq.setSerialNumber(rs.getString("serialNumber"));
            eq.setModel(rs.getString("model"));
            eq.setDescription(rs.getString("description"));
            eq.setInstallDate(rs.getDate("installDate") != null 
    ? rs.getDate("installDate").toLocalDate() 
    : null);
eq.setStartDate(rs.getDate("startDate") != null 
    ? rs.getDate("startDate").toLocalDate() 
    : null);
eq.setEndDate(rs.getDate("endDate") != null 
    ? rs.getDate("endDate").toLocalDate() 
    : null);
            eq.setPrice(rs.getBigDecimal("price"));
            list.add(eq);
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    return list;
}
    
}
