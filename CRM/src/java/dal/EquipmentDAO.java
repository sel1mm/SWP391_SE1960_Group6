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
 * DAO for Equipment operations with Category support.
 * Modified to include categoryId, categoryName, and username in queries.
 */
public class EquipmentDAO extends DBContext {

    /**
     * Get all equipment with category and user information
     */
    public List<Equipment> getAllEquipment() {
        List<Equipment> list = new ArrayList<>();
        String sql = "SELECT e.equipmentId, e.serialNumber, e.model, e.description, " +
                     "       e.installDate, e.categoryId, c.categoryName, " +
                     "       e.lastUpdatedBy, e.lastUpdatedDate, a.username " +
                     "FROM Equipment e " +
                     "LEFT JOIN Category c ON e.categoryId = c.categoryId " +
                     "LEFT JOIN Account a ON e.lastUpdatedBy = a.accountId " +
                     "ORDER BY e.equipmentId DESC";

        try (PreparedStatement ps = connection.prepareStatement(sql); 
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Equipment e = mapResultSetToEquipment(rs);
                list.add(e);
            }

        } catch (Exception ex) {
            System.out.println("❌ Error in getAllEquipment: " + ex.getMessage());
            ex.printStackTrace();
        }

        return list;
    }

    /**
     * Get equipment with inventory status information
     */
    public List<EquipmentWithStatus> getEquipmentWithStatus() {
        List<EquipmentWithStatus> list = new ArrayList<>();
        String sql = "SELECT e.equipmentId, e.serialNumber, e.model, e.description, " +
                     "       e.installDate, e.categoryId, c.categoryName, " +
                     "       e.lastUpdatedBy, e.lastUpdatedDate, a.username, " +
                     "       'Active' as status, 'Building' as location, 0.0 as unitPrice " +
                     "FROM Equipment e " +
                     "LEFT JOIN Category c ON e.categoryId = c.categoryId " +
                     "LEFT JOIN Account a ON e.lastUpdatedBy = a.accountId " +
                     "ORDER BY e.lastUpdatedDate DESC, e.equipmentId DESC";

        try (PreparedStatement ps = connection.prepareStatement(sql); 
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                EquipmentWithStatus e = mapResultSetToEquipmentWithStatus(rs);
                list.add(e);
            }

        } catch (Exception e) {
            System.out.println("❌ Error in getEquipmentWithStatus: " + e.getMessage());
            e.printStackTrace();
        }

        return list;
    }

    /**
     * Find equipment by ID with category and user info
     */
    public Equipment findById(int equipmentId) throws SQLException {
        String sql = "SELECT e.equipmentId, e.serialNumber, e.model, e.description, " +
                     "       e.installDate, e.categoryId, c.categoryName, " +
                     "       e.lastUpdatedBy, e.lastUpdatedDate, a.username " +
                     "FROM Equipment e " +
                     "LEFT JOIN Category c ON e.categoryId = c.categoryId " +
                     "LEFT JOIN Account a ON e.lastUpdatedBy = a.accountId " +
                     "WHERE e.equipmentId = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, equipmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToEquipment(rs);
                }
            }
        } catch (SQLException e) {
            System.out.println("❌ Error finding equipment by ID: " + e.getMessage());
            throw e;
        }
        return null;
    }

    /**
     * Find equipment by serial number with category and user info
     */
    public Equipment findBySerialNumber(String serialNumber) throws SQLException {
        String sql = "SELECT e.equipmentId, e.serialNumber, e.model, e.description, " +
                     "       e.installDate, e.categoryId, c.categoryName, " +
                     "       e.lastUpdatedBy, e.lastUpdatedDate, a.username " +
                     "FROM Equipment e " +
                     "LEFT JOIN Category c ON e.categoryId = c.categoryId " +
                     "LEFT JOIN Account a ON e.lastUpdatedBy = a.accountId " +
                     "WHERE e.serialNumber = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, serialNumber);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToEquipment(rs);
                }
            }
        } catch (SQLException e) {
            System.out.println("❌ Error finding equipment by serial number: " + e.getMessage());
            throw e;
        }
        return null;
    }

    /**
     * Search equipment by model, description, serial number, or category
     */
    public List<Equipment> searchEquipment(String searchQuery, int page, int pageSize) throws SQLException {
        List<Equipment> equipmentList = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT e.equipmentId, e.serialNumber, e.model, e.description, ")
           .append("       e.installDate, e.categoryId, c.categoryName, ")
           .append("       e.lastUpdatedBy, e.lastUpdatedDate, a.username ")
           .append("FROM Equipment e ")
           .append("LEFT JOIN Category c ON e.categoryId = c.categoryId ")
           .append("LEFT JOIN Account a ON e.lastUpdatedBy = a.accountId ")
           .append("WHERE 1=1");

        List<Object> params = new ArrayList<>();

        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            sql.append(" AND (e.model LIKE ? OR e.description LIKE ? OR e.serialNumber LIKE ? OR c.categoryName LIKE ?)");
            String searchPattern = "%" + searchQuery.trim() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
        }

        sql.append(" ORDER BY e.lastUpdatedDate DESC, e.equipmentId DESC LIMIT ? OFFSET ?");
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
            throw e;
        }

        return equipmentList;
    }

    /**
     * Get equipment count with search filter
     */
    public int getEquipmentCount(String searchQuery) throws SQLException {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) FROM Equipment e ")
           .append("LEFT JOIN Category c ON e.categoryId = c.categoryId ")
           .append("WHERE 1=1");

        List<Object> params = new ArrayList<>();

        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            sql.append(" AND (e.model LIKE ? OR e.description LIKE ? OR e.serialNumber LIKE ? OR c.categoryName LIKE ?)");
            String searchPattern = "%" + searchQuery.trim() + "%";
            params.add(searchPattern);
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
            throw e;
        }
        return 0;
    }

    /**
     * Get equipment by category
     */
    public List<Equipment> getEquipmentByCategory(int categoryId) throws SQLException {
        List<Equipment> list = new ArrayList<>();
        String sql = "SELECT e.equipmentId, e.serialNumber, e.model, e.description, " +
                     "       e.installDate, e.categoryId, c.categoryName, " +
                     "       e.lastUpdatedBy, e.lastUpdatedDate, a.username " +
                     "FROM Equipment e " +
                     "LEFT JOIN Category c ON e.categoryId = c.categoryId " +
                     "LEFT JOIN Account a ON e.lastUpdatedBy = a.accountId " +
                     "WHERE e.categoryId = ? " +
                     "ORDER BY e.equipmentId DESC";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, categoryId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToEquipment(rs));
                }
            }
        } catch (SQLException e) {
            System.out.println("❌ Error getting equipment by category: " + e.getMessage());
            throw e;
        }
        return list;
    }

    /**
     * Insert new equipment
     */
    public boolean insertEquipment(Equipment equipment) throws SQLException {
        String sql = "INSERT INTO Equipment (serialNumber, model, description, installDate, " +
                     "categoryId, lastUpdatedBy, lastUpdatedDate) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, equipment.getSerialNumber());
            ps.setString(2, equipment.getModel());
            ps.setString(3, equipment.getDescription());
            ps.setDate(4, equipment.getInstallDate() != null ? Date.valueOf(equipment.getInstallDate()) : null);
            
            if (equipment.getCategoryId() != null) {
                ps.setInt(5, equipment.getCategoryId());
            } else {
                ps.setNull(5, Types.INTEGER);
            }
            
            ps.setInt(6, equipment.getLastUpdatedBy());
            ps.setDate(7, equipment.getLastUpdatedDate() != null ? Date.valueOf(equipment.getLastUpdatedDate()) : null);

            int affectedRows = ps.executeUpdate();
            
            if (affectedRows > 0) {
                try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        equipment.setEquipmentId(generatedKeys.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            System.out.println("❌ Error inserting equipment: " + e.getMessage());
            throw e;
        }
        return false;
    }

    /**
     * Update equipment
     */
    public boolean updateEquipment(Equipment equipment) throws SQLException {
        String sql = "UPDATE Equipment SET serialNumber = ?, model = ?, description = ?, " +
                     "installDate = ?, categoryId = ?, lastUpdatedBy = ?, lastUpdatedDate = ? " +
                     "WHERE equipmentId = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, equipment.getSerialNumber());
            ps.setString(2, equipment.getModel());
            ps.setString(3, equipment.getDescription());
            ps.setDate(4, equipment.getInstallDate() != null ? Date.valueOf(equipment.getInstallDate()) : null);
            
            if (equipment.getCategoryId() != null) {
                ps.setInt(5, equipment.getCategoryId());
            } else {
                ps.setNull(5, Types.INTEGER);
            }
            
            ps.setInt(6, equipment.getLastUpdatedBy());
            ps.setDate(7, equipment.getLastUpdatedDate() != null ? Date.valueOf(equipment.getLastUpdatedDate()) : null);
            ps.setInt(8, equipment.getEquipmentId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.out.println("❌ Error updating equipment: " + e.getMessage());
            throw e;
        }
    }

    /**
     * Delete equipment
     */
    public boolean deleteEquipment(int equipmentId) throws SQLException {
        String sql = "DELETE FROM Equipment WHERE equipmentId = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, equipmentId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.out.println("❌ Error deleting equipment: " + e.getMessage());
            throw e;
        }
    }

    /**
     * Map ResultSet to Equipment object (with category and username)
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

        // Category info
        int categoryId = rs.getInt("categoryId");
        if (!rs.wasNull()) {
            equipment.setCategoryId(categoryId);
        }
        equipment.setCategoryName(rs.getString("categoryName"));

        equipment.setLastUpdatedBy(rs.getInt("lastUpdatedBy"));

        Date lastUpdatedDate = rs.getDate("lastUpdatedDate");
        if (lastUpdatedDate != null) {
            equipment.setLastUpdatedDate(lastUpdatedDate.toLocalDate());
        }

        equipment.setUsername(rs.getString("username"));

        return equipment;
    }

    /**
     * Map ResultSet to EquipmentWithStatus object
     */
    private EquipmentWithStatus mapResultSetToEquipmentWithStatus(ResultSet rs) throws SQLException {
        EquipmentWithStatus equipment = new EquipmentWithStatus();
        equipment.setEquipmentId(rs.getInt("equipmentId"));
        equipment.setSerialNumber(rs.getString("serialNumber"));
        equipment.setModel(rs.getString("model"));
        equipment.setDescription(rs.getString("description"));

        Date installDate = rs.getDate("installDate");
        if (installDate != null) {
            equipment.setInstallDate(installDate.toLocalDate());
        }

        // Category info
        int categoryId = rs.getInt("categoryId");
        if (!rs.wasNull()) {
            equipment.setCategoryId(categoryId);
        }
        equipment.setCategoryName(rs.getString("categoryName"));

        equipment.setLastUpdatedBy(rs.getInt("lastUpdatedBy"));

        Date lastUpdatedDate = rs.getDate("lastUpdatedDate");
        if (lastUpdatedDate != null) {
            equipment.setLastUpdatedDate(lastUpdatedDate.toLocalDate());
        }

        equipment.setUsername(rs.getString("username"));
        equipment.setStatus(rs.getString("status"));
        equipment.setLocation(rs.getString("location"));
        equipment.setUnitPrice(rs.getDouble("unitPrice"));

        return equipment;
    }

    /**
     * Get equipment by contract ID with full details
     */
    public List<EquipmentWithStatus> getEquipmentByContractId(int contractId) {
        List<EquipmentWithStatus> list = new ArrayList<>();
        String sql = "SELECT e.equipmentId, e.serialNumber, e.model, e.description, " +
                     "       e.installDate, e.categoryId, c.categoryName, " +
                     "       e.lastUpdatedBy, e.lastUpdatedDate, a.username, " +
                     "       ce.startDate, ce.endDate, ce.price " +
                     "FROM ContractEquipment ce " +
                     "JOIN Equipment e ON ce.equipmentId = e.equipmentId " +
                     "LEFT JOIN Category c ON e.categoryId = c.categoryId " +
                     "LEFT JOIN Account a ON e.lastUpdatedBy = a.accountId " +
                     "WHERE ce.contractId = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, contractId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                EquipmentWithStatus eq = new EquipmentWithStatus();
                eq.setEquipmentId(rs.getInt("equipmentId"));
                eq.setSerialNumber(rs.getString("serialNumber"));
                eq.setModel(rs.getString("model"));
                eq.setDescription(rs.getString("description"));
                
                Date installDate = rs.getDate("installDate");
                if (installDate != null) {
                    eq.setInstallDate(installDate.toLocalDate());
                }
                
                // Category info
                int categoryId = rs.getInt("categoryId");
                if (!rs.wasNull()) {
                    eq.setCategoryId(categoryId);
                }
                eq.setCategoryName(rs.getString("categoryName"));
                
                eq.setLastUpdatedBy(rs.getInt("lastUpdatedBy"));
                
                Date lastUpdatedDate = rs.getDate("lastUpdatedDate");
                if (lastUpdatedDate != null) {
                    eq.setLastUpdatedDate(lastUpdatedDate.toLocalDate());
                }
                
                eq.setUsername(rs.getString("username"));
                
                // Contract info
                Date startDate = rs.getDate("startDate");
                if (startDate != null) {
                    eq.setStartDate(startDate.toLocalDate());
                }
                
                Date endDate = rs.getDate("endDate");
                if (endDate != null) {
                    eq.setEndDate(endDate.toLocalDate());
                }
                
                eq.setPrice(rs.getBigDecimal("price"));
                
                list.add(eq);
            }
        } catch (Exception e) {
            System.out.println("❌ Error in getEquipmentByContractId: " + e.getMessage());
            e.printStackTrace();
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
     * Get all equipment assigned to contracts of a specific customer
     */
    public List<Equipment> getEquipmentByCustomerContracts(int customerId) throws SQLException {
        List<Equipment> list = new ArrayList<>();
        String sql = "SELECT DISTINCT e.equipmentId, e.serialNumber, e.model, e.description, " +
                     "       e.installDate, e.categoryId, c.categoryName, " +
                     "       e.lastUpdatedBy, e.lastUpdatedDate, a.username " +
                     "FROM Equipment e " +
                     "JOIN ContractEquipment ce ON e.equipmentId = ce.equipmentId " +
                     "JOIN Contract ct ON ce.contractId = ct.contractId " +
                     "LEFT JOIN Category c ON e.categoryId = c.categoryId " +
                     "LEFT JOIN Account a ON e.lastUpdatedBy = a.accountId " +
                     "WHERE ct.customerId = ? " +
                     "ORDER BY e.equipmentId DESC";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToEquipment(rs));
                }
            }
        } catch (SQLException e) {
            System.out.println("❌ Error in getEquipmentByCustomerContracts: " + e.getMessage());
            throw e;
        }
        return list;
    }

    /**
     * Get equipment statistics by customer
     */
    public Map<String, Integer> getEquipmentStatsByCustomer(int customerId) {
        Map<String, Integer> stats = new HashMap<>();
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
            if (active < 0) active = 0;

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
     * Get status for a specific equipment
     */
    public String getEquipmentStatus(int equipmentId) {
        // Check for active service request (Repair)
        String repairSql = "SELECT COUNT(*) as cnt FROM ServiceRequest " +
                          "WHERE equipmentId = ? AND status IN ('Pending', 'Awaiting Approval', 'Approved')";

        try (PreparedStatement ps = connection.prepareStatement(repairSql)) {
            ps.setInt(1, equipmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next() && rs.getInt("cnt") > 0) {
                    return "Repair";
                }
            }
        } catch (SQLException e) {
            System.out.println("❌ Error checking repair status: " + e.getMessage());
        }

        // Check for scheduled maintenance
        String maintenanceSql = "SELECT COUNT(*) as cnt FROM MaintenanceSchedule " +
                               "WHERE equipmentId = ? AND status = 'Scheduled' AND scheduledDate >= CURDATE()";

        try (PreparedStatement ps = connection.prepareStatement(maintenanceSql)) {
            ps.setInt(1, equipmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next() && rs.getInt("cnt") > 0) {
                    return "Maintenance";
                }
            }
        } catch (SQLException e) {
            System.out.println("❌ Error checking maintenance status: " + e.getMessage());
        }

        return "Active";
    }
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

    // ==================== MAIN METHOD FOR TESTING ====================
    public static void main(String[] args) {
        EquipmentDAO dao = new EquipmentDAO();
        
        System.out.println("========================================");
        System.out.println("TESTING EquipmentDAO with Category Support");
        System.out.println("========================================\n");

        // Test 1: Get All Equipment
        System.out.println("--- Test 1: Get All Equipment ---");
        try {
            List<Equipment> allEquipment = dao.getAllEquipment();
            System.out.println("✅ Found " + allEquipment.size() + " equipment(s)");
            
            if (!allEquipment.isEmpty()) {
                Equipment first = allEquipment.get(0);
                System.out.println("First Equipment: " + first);
                System.out.println("  - Category: " + first.getCategoryName() + " (ID: " + first.getCategoryId() + ")");
                System.out.println("  - Updated by: " + first.getUsername());
            }
        } catch (Exception e) {
            System.out.println("❌ Error: " + e.getMessage());
        }
        System.out.println();

        // Test 2: Find Equipment by ID
        System.out.println("--- Test 2: Find Equipment by ID (1) ---");
        try {
            Equipment eq = dao.findById(1);
            if (eq != null) {
                System.out.println("✅ Found: " + eq.getModel());
                System.out.println("  - Serial: " + eq.getSerialNumber());
                System.out.println("  - Category: " + eq.getCategoryName());
                System.out.println("  - Description: " + eq.getDescription());
            } else {
                System.out.println("❌ Equipment not found");
            }
        } catch (SQLException e) {
            System.out.println("❌ Error: " + e.getMessage());
        }
        System.out.println();

        // Test 3: Search Equipment
        System.out.println("--- Test 3: Search Equipment (keyword: 'Daikin') ---");
        try {
            List<Equipment> searchResults = dao.searchEquipment("Daikin", 1, 10);
            System.out.println("✅ Found " + searchResults.size() + " result(s)");
            
            for (Equipment eq : searchResults) {
                System.out.println("  - " + eq.getModel() + " [" + eq.getCategoryName() + "]");
            }
        } catch (SQLException e) {
            System.out.println("❌ Error: " + e.getMessage());
        }
        System.out.println();

        // Test 4: Get Equipment by Category
        System.out.println("--- Test 4: Get Equipment by Category (13 - Air Conditioning Unit) ---");
        try {
            List<Equipment> categoryEquipment = dao.getEquipmentByCategory(13);
            System.out.println("✅ Found " + categoryEquipment.size() + " equipment(s) in category");
            
            for (Equipment eq : categoryEquipment) {
                System.out.println("  - " + eq.getModel() + " (" + eq.getSerialNumber() + ")");
            }
        } catch (SQLException e) {
            System.out.println("❌ Error: " + e.getMessage());
        }
        System.out.println();

        // Test 5: Get Equipment Count
        System.out.println("--- Test 5: Get Equipment Count ---");
        try {
            int totalCount = dao.getEquipmentCount(null);
            int searchCount = dao.getEquipmentCount("HVAC");
            
            System.out.println("✅ Total equipment: " + totalCount);
            System.out.println("✅ Equipment matching 'HVAC': " + searchCount);
        } catch (SQLException e) {
            System.out.println("❌ Error: " + e.getMessage());
        }
        System.out.println();

        // Test 6: Get Equipment with Status
        System.out.println("--- Test 6: Get Equipment with Status ---");
        try {
            List<EquipmentWithStatus> equipmentWithStatus = dao.getEquipmentWithStatus();
            System.out.println("✅ Found " + equipmentWithStatus.size() + " equipment(s) with status");
            
            if (!equipmentWithStatus.isEmpty()) {
                EquipmentWithStatus first = equipmentWithStatus.get(0);
                System.out.println("First Equipment: " + first.getModel());
                System.out.println("  - Status: " + first.getStatus());
                System.out.println("  - Location: " + first.getLocation());
                System.out.println("  - Category: " + first.getCategoryName());
            }
        } catch (Exception e) {
            System.out.println("❌ Error: " + e.getMessage());
        }
        System.out.println();

        // Test 7: Validate Equipment
        System.out.println("--- Test 7: Validate Equipment ---");
        System.out.println("Equipment ID 1 valid: " + dao.isValidEquipment(1));
        System.out.println("Equipment ID 999 valid: " + dao.isValidEquipment(999));
        System.out.println();

        System.out.println("========================================");
        System.out.println("ALL TESTS COMPLETED");
        System.out.println("========================================");
    }
}