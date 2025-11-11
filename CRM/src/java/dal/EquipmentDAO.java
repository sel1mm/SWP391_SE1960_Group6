package dal;

import model.Equipment;
import model.EquipmentWithStatus;
import model.ContractEquipment;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class EquipmentDAO extends DBContext {

    // ==================== BASIC CRUD OPERATIONS ====================
    /**
     * Get all equipment with category and user information
     */
    public List<Equipment> getAllEquipment() {
        List<Equipment> list = new ArrayList<>();
        String sql = "SELECT e.equipmentId, e.serialNumber, e.model, e.description, "
                + "       e.installDate, e.categoryId, c.categoryName, "
                + "       e.lastUpdatedBy, e.lastUpdatedDate, a.username "
                + "FROM Equipment e "
                + "LEFT JOIN Category c ON e.categoryId = c.categoryId "
                + "LEFT JOIN Account a ON e.lastUpdatedBy = a.accountId "
                + "ORDER BY e.equipmentId DESC";

        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

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
     * Find equipment by ID with category and user info
     */
    public Equipment findById(int equipmentId) throws SQLException {
        String sql = "SELECT e.equipmentId, e.serialNumber, e.model, e.description, "
                + "       e.installDate, e.categoryId, c.categoryName, "
                + "       e.lastUpdatedBy, e.lastUpdatedDate, a.username "
                + "FROM Equipment e "
                + "LEFT JOIN Category c ON e.categoryId = c.categoryId "
                + "LEFT JOIN Account a ON e.lastUpdatedBy = a.accountId "
                + "WHERE e.equipmentId = ?";

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
        String sql = "SELECT e.equipmentId, e.serialNumber, e.model, e.description, "
                + "       e.installDate, e.categoryId, c.categoryName, "
                + "       e.lastUpdatedBy, e.lastUpdatedDate, a.username "
                + "FROM Equipment e "
                + "LEFT JOIN Category c ON e.categoryId = c.categoryId "
                + "LEFT JOIN Account a ON e.lastUpdatedBy = a.accountId "
                + "WHERE e.serialNumber = ?";

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
     * Insert new equipment
     */
    public boolean insertEquipment(Equipment equipment) throws SQLException {
        String sql = "INSERT INTO Equipment (serialNumber, model, description, installDate, "
                + "categoryId, lastUpdatedBy, lastUpdatedDate) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, equipment.getSerialNumber());
            ps.setString(2, equipment.getModel());
            ps.setString(3, equipment.getDescription());
            ps.setDate(4, equipment.getInstallDate() != null ? Date.valueOf(equipment.getInstallDate()) : null);

            if (equipment.getCategoryId() != -1) {
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
        String sql = "UPDATE Equipment SET serialNumber = ?, model = ?, description = ?, "
                + "installDate = ?, categoryId = ?, lastUpdatedBy = ?, lastUpdatedDate = ? "
                + "WHERE equipmentId = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, equipment.getSerialNumber());
            ps.setString(2, equipment.getModel());
            ps.setString(3, equipment.getDescription());
            ps.setDate(4, equipment.getInstallDate() != null ? Date.valueOf(equipment.getInstallDate()) : null);

            if (equipment.getCategoryId() != -1) {
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

    // ==================== SEARCH & FILTER OPERATIONS ====================
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
    public List<Equipment> getEquipmentGroupedByModel() {
        List<Equipment> list = new ArrayList<>();
        String sql = "SELECT e.model, "
                + "e.categoryId, "
                + "c.categoryName, "
                + "e.description, "
                + "COUNT(*) as totalCount "
                + "FROM Equipment e "
                + "LEFT JOIN Category c ON e.categoryId = c.categoryId "
                + "GROUP BY e.model, e.categoryId, c.categoryName, e.description "
                + "ORDER BY e.model";

        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Equipment eq = new Equipment();
                eq.setModel(rs.getString("model"));

                // Xử lý categoryId (có thể null)
                int categoryId = rs.getInt("categoryId");
                if (rs.wasNull()) {
                    eq.setCategoryId(null);
                } else {
                    eq.setCategoryId(categoryId);
                }

                eq.setCategoryName(rs.getString("categoryName"));
                eq.setDescription(rs.getString("description"));
                list.add(eq);
            }

            System.out.println("✅ Loaded " + list.size() + " grouped equipment models");

        } catch (SQLException e) {
            System.out.println("❌ Error in getEquipmentGroupedByModel: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    public List<Equipment> getEquipmentByModel(String model) {
        List<Equipment> list = new ArrayList<>();
        String sql = "SELECT e.equipmentId, e.serialNumber, e.model, "
                + "e.description, e.installDate, e.lastUpdatedBy, e.lastUpdatedDate, "
                + "e.categoryId, c.categoryName, a.username "
                + "FROM Equipment e "
                + "LEFT JOIN Category c ON e.categoryId = c.categoryId "
                + "LEFT JOIN Account a ON e.lastUpdatedBy = a.accountId "
                + "WHERE e.model = ? "
                + "ORDER BY e.equipmentId";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, model);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Equipment eq = new Equipment();
                eq.setEquipmentId(rs.getInt("equipmentId"));
                eq.setSerialNumber(rs.getString("serialNumber"));
                eq.setModel(rs.getString("model"));
                eq.setDescription(rs.getString("description"));
                eq.setInstallDate(rs.getDate("installDate") != null
                        ? rs.getDate("installDate").toLocalDate() : null);
                eq.setLastUpdatedBy(rs.getInt("lastUpdatedBy"));
                eq.setLastUpdatedDate(rs.getDate("lastUpdatedDate") != null
                        ? rs.getDate("lastUpdatedDate").toLocalDate() : null);
                eq.setCategoryId(rs.getInt("categoryId"));
                eq.setCategoryName(rs.getString("categoryName"));
                eq.setUsername(rs.getString("username"));
                list.add(eq);
            }
        } catch (SQLException e) {
            System.out.println("Error in getEquipmentByModel: " + e.getMessage());
        }
        return list;
    }

    public List<Equipment> getEquipmentByCategory(int categoryId) throws SQLException {
        List<Equipment> list = new ArrayList<>();
        String sql = "SELECT e.equipmentId, e.serialNumber, e.model, e.description, "
                + "       e.installDate, e.categoryId, c.categoryName, "
                + "       e.lastUpdatedBy, e.lastUpdatedDate, a.username "
                + "FROM Equipment e "
                + "LEFT JOIN Category c ON e.categoryId = c.categoryId "
                + "LEFT JOIN Account a ON e.lastUpdatedBy = a.accountId "
                + "WHERE e.categoryId = ? "
                + "ORDER BY e.equipmentId DESC";

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

    // ==================== STATUS & STATISTICS OPERATIONS ====================
    /**
     * Get equipment with inventory status information
     */
    public List<EquipmentWithStatus> getEquipmentWithStatus() {
        List<EquipmentWithStatus> list = new ArrayList<>();
        String sql = "SELECT e.equipmentId, e.serialNumber, e.model, e.description, "
                + "       e.installDate, e.categoryId, c.categoryName, "
                + "       e.lastUpdatedBy, e.lastUpdatedDate, a.username, "
                + "       'Active' as status, 'Building' as location, 0.0 as unitPrice "
                + "FROM Equipment e "
                + "LEFT JOIN Category c ON e.categoryId = c.categoryId "
                + "LEFT JOIN Account a ON e.lastUpdatedBy = a.accountId "
                + "ORDER BY e.lastUpdatedDate DESC, e.equipmentId DESC";

        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

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
     * Get status for a specific equipment Returns: "Active", "Repair", or
     * "Maintenance"
     */
    public String getEquipmentStatus(int equipmentId) {
        // Check for active service request (Repair)
        String repairSql = "SELECT COUNT(*) as cnt FROM ServiceRequest "
                + "WHERE equipmentId = ? AND status IN ('Pending', 'Awaiting Approval', 'Approved')";

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
        String maintenanceSql = "SELECT COUNT(*) as cnt FROM MaintenanceSchedule "
                + "WHERE equipmentId = ? AND status = 'Scheduled' AND scheduledDate >= CURDATE()";

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

    // ==================== CONTRACT & CUSTOMER OPERATIONS ====================
    /**
     * Get equipment by contract ID with full details
     */
    public List<EquipmentWithStatus> getEquipmentByContractId(int contractId) {
        List<EquipmentWithStatus> list = new ArrayList<>();
        String sql = "SELECT e.equipmentId, e.serialNumber, e.model, e.description, "
                + "       e.installDate, e.categoryId, c.categoryName, "
                + "       e.lastUpdatedBy, e.lastUpdatedDate, a.username, "
                + "       ce.startDate, ce.endDate, ce.price "
                + "FROM ContractEquipment ce "
                + "JOIN Equipment e ON ce.equipmentId = e.equipmentId "
                + "LEFT JOIN Category c ON e.categoryId = c.categoryId "
                + "LEFT JOIN Account a ON e.lastUpdatedBy = a.accountId "
                + "WHERE ce.contractId = ?";

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
     * Get all equipment assigned to contracts of a specific customer
     */
    public List<Equipment> getEquipmentByCustomerContracts(int customerId) throws SQLException {
        List<Equipment> list = new ArrayList<>();
        String sql = "SELECT DISTINCT e.equipmentId, e.serialNumber, e.model, e.description, "
                + "       e.installDate, e.categoryId, c.categoryName, "
                + "       e.lastUpdatedBy, e.lastUpdatedDate, a.username "
                + "FROM Equipment e "
                + "JOIN ContractEquipment ce ON e.equipmentId = ce.equipmentId "
                + "JOIN Contract ct ON ce.contractId = ct.contractId "
                + "LEFT JOIN Category c ON e.categoryId = c.categoryId "
                + "LEFT JOIN Account a ON e.lastUpdatedBy = a.accountId "
                + "WHERE ct.customerId = ? "
                + "ORDER BY e.equipmentId DESC";

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
     * Get equipment statistics by customer Returns: total, active, repair,
     * maintenance counts
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

    /**
     * Lấy thông tin hợp đồng cho thiết bị (bao gồm cả phụ lục)
     *
     * @param equipmentId ID thiết bị
     * @param customerId ID khách hàng
     * @return EquipmentContractInfo chứa thông tin hợp đồng và nguồn
     */
    public EquipmentContractInfo getEquipmentContractInfo(int equipmentId, int customerId) {
        // Kiểm tra trong ContractEquipment trước
        String sql1 = "SELECT c.contractId, 'Contract' as source FROM Contract c "
                + "JOIN ContractEquipment ce ON c.contractId = ce.contractId "
                + "WHERE ce.equipmentId = ? AND c.customerId = ? "
                + "ORDER BY c.contractDate DESC LIMIT 1";

        try (PreparedStatement ps = connection.prepareStatement(sql1)) {
            ps.setInt(1, equipmentId);
            ps.setInt(2, customerId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int contractId = rs.getInt("contractId");
                    return new EquipmentContractInfo(contractId, "Contract", "HD" + String.format("%03d", contractId));
                }
            }
        } catch (SQLException e) {
            System.out.println("❌ Error checking contract equipment: " + e.getMessage());
        }

        // Kiểm tra trong ContractAppendixEquipment
        String sql2 = "SELECT c.contractId, 'Appendix' as source FROM Contract c "
                + "JOIN ContractAppendix ca ON c.contractId = ca.contractId "
                + "JOIN ContractAppendixEquipment cae ON ca.appendixId = cae.appendixId "
                + "WHERE cae.equipmentId = ? AND c.customerId = ? "
                + "ORDER BY ca.effectiveDate DESC LIMIT 1";

        try (PreparedStatement ps = connection.prepareStatement(sql2)) {
            ps.setInt(1, equipmentId);
            ps.setInt(2, customerId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int contractId = rs.getInt("contractId");
                    return new EquipmentContractInfo(contractId, "Appendix", "HD" + String.format("%03d", contractId));
                }
            }
        } catch (SQLException e) {
            System.out.println("❌ Error checking appendix equipment: " + e.getMessage());
        }

        // Không tìm thấy hợp đồng nào
        return new EquipmentContractInfo(0, "None", "N/A");
    }

    /**
     * Class chứa thông tin hợp đồng của thiết bị
     */
    public static class EquipmentContractInfo {

        private int contractId;
        private String source; // "Contract", "Appendix", "None"
        private String formattedContractId; // "HD001", "N/A"

        public EquipmentContractInfo(int contractId, String source, String formattedContractId) {
            this.contractId = contractId;
            this.source = source;
            this.formattedContractId = formattedContractId;
        }

        public int getContractId() {
            return contractId;
        }

        public String getSource() {
            return source;
        }

        public String getFormattedContractId() {
            return formattedContractId;
        }

        public boolean hasContract() {
            return contractId > 0;
        }
    }

    /**
     * Get repair information for equipment (includes technician, quotation,
     * repair details)
     *
     * @param equipmentId Equipment ID
     * @return Map containing repair info or null if not found
     */
    public Map<String, Object> getEquipmentRepairInfo(int equipmentId) {
        String sql = "SELECT "
                + "    a.fullName AS technician_name, "
                + "    sr.requestDate AS repair_date, "
                + "    rr.diagnosis, "
                + "    rr.details AS repair_details, "
                + "    rr.estimatedCost AS estimated_cost, "
                + "    rr.quotationStatus AS quotation_status "
                + "FROM Equipment e "
                + "LEFT JOIN ServiceRequest sr ON e.equipmentId = sr.equipmentId "
                + "    AND sr.status IN ('Approved', 'Completed') "
                + "    AND sr.requestType IN ('Service', 'Warranty') "
                + "LEFT JOIN RepairReport rr ON sr.requestId = rr.requestId "
                + "LEFT JOIN Account a ON rr.technicianId = a.accountId "
                + "WHERE e.equipmentId = ? "
                + "    AND sr.requestId IS NOT NULL "
                + "ORDER BY sr.requestDate DESC "
                + "LIMIT 1";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, equipmentId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Map<String, Object> repairInfo = new HashMap<>();

                    repairInfo.put("technicianName", rs.getString("technician_name"));
                    repairInfo.put("repairDate", rs.getDate("repair_date") != null
                            ? rs.getDate("repair_date").toString() : null);
                    repairInfo.put("diagnosis", rs.getString("diagnosis"));
                    repairInfo.put("repairDetails", rs.getString("repair_details"));
                    repairInfo.put("estimatedCost", rs.getBigDecimal("estimated_cost"));
                    repairInfo.put("quotationStatus", rs.getString("quotation_status"));

                    System.out.println("✅ Found repair info for equipment: " + equipmentId
                            + " - Technician: " + rs.getString("technician_name"));

                    return repairInfo;
                }
            }

            System.out.println("⚠️ No repair info found for equipment: " + equipmentId);
            return null;

        } catch (SQLException e) {
            System.out.println("💥 Error getting repair info for equipment " + equipmentId + ": " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }

    // ==================== HELPER METHODS ====================
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

    // ==================== MAIN METHOD FOR TESTING ====================
    public static void main(String[] args) {
        EquipmentDAO dao = new EquipmentDAO();

        System.out.println("========================================");
        System.out.println("TESTING EquipmentDAO - Complete Merged Version");
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

        // Test 2: Get Equipment Status
        System.out.println("--- Test 2: Get Equipment Status (ID 1) ---");
        String status = dao.getEquipmentStatus(1);
        System.out.println("✅ Status: " + status);
        System.out.println();

        // Test 3: Get Equipment Repair Info
        System.out.println("--- Test 3: Get Equipment Repair Info (ID 1) ---");
        Map<String, Object> repairInfo = dao.getEquipmentRepairInfo(1);
        if (repairInfo != null) {
            System.out.println("✅ Repair Info Found:");
            System.out.println("  - Technician: " + repairInfo.get("technicianName"));
            System.out.println("  - Repair Date: " + repairInfo.get("repairDate"));
            System.out.println("  - Diagnosis: " + repairInfo.get("diagnosis"));
            System.out.println("  - Estimated Cost: " + repairInfo.get("estimatedCost"));
        } else {
            System.out.println("⚠️ No repair info found");
        }
        System.out.println();

        // Test 4: Get Equipment Stats by Customer
        System.out.println("--- Test 4: Get Equipment Statistics (customerId: 1) ---");

        // Test 4: Validate Equipment
        System.out.println("--- Test 4: Validate Equipment ---");
        System.out.println("Equipment ID 1 valid: " + dao.isValidEquipment(1));
        System.out.println("Equipment ID 999 valid: " + dao.isValidEquipment(999));
        System.out.println();

        // Test 5: Get Equipment by Category
        System.out.println("--- Test 5: Get Equipment by Category (ID 13) ---");
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

        // Test 6: Get Equipment Count
        System.out.println("--- Test 6: Get Equipment Count ---");
        try {
            int totalCount = dao.getEquipmentCount(null);
            int searchCount = dao.getEquipmentCount("HVAC");

            System.out.println("✅ Total equipment: " + totalCount);
            System.out.println("✅ Equipment matching 'HVAC': " + searchCount);
        } catch (SQLException e) {
            System.out.println("❌ Error: " + e.getMessage());
        }
        System.out.println();

        // Test 7: Get Contract ID for Equipment
        System.out.println("--- Test 7: Get Contract ID for Equipment ---");
        System.out.println("Testing getContractIdForEquipment(equipmentId: 1, customerId: 1)");
        String contractId1 = dao.getContractIdForEquipment(1, 1);
        System.out.println("✅ Contract ID: " + contractId1);

        System.out.println("\nTesting getContractIdForEquipment(equipmentId: 2, customerId: 1)");
        String contractId2 = dao.getContractIdForEquipment(2, 1);
        System.out.println("✅ Contract ID: " + contractId2);

        System.out.println("\nTesting getContractIdForEquipment(equipmentId: 999, customerId: 1)");
        String contractId3 = dao.getContractIdForEquipment(999, 1);
        System.out.println("✅ Contract ID: " + contractId3 + " (Should be N/A)");

        System.out.println("\nTesting getContractIdForEquipment(equipmentId: 1, customerId: 999)");
        String contractId4 = dao.getContractIdForEquipment(1, 999);
        System.out.println("✅ Contract ID: " + contractId4 + " (Should be N/A)");
        System.out.println();

        // Test 8: Get Equipment by Customer Contracts
        System.out.println("--- Test 8: Get Equipment by Customer Contracts (customerId: 1) ---");
        try {
            List<Equipment> customerEquipment = dao.getEquipmentByCustomerContracts(1);
            System.out.println("✅ Found " + customerEquipment.size() + " equipment(s) for customer");

            for (Equipment eq : customerEquipment) {
                String contractId = dao.getContractIdForEquipment(eq.getEquipmentId(), 1);
                System.out.println("  - Equipment ID: " + eq.getEquipmentId()
                        + " | Model: " + eq.getModel()
                        + " | Contract: " + contractId);
            }
        } catch (SQLException e) {
            System.out.println("❌ Error: " + e.getMessage());
        }
        System.out.println();

        // Test 9: Get Equipment Statistics by Customer
        System.out.println("--- Test 9: Get Equipment Statistics by Customer (customerId: 1) ---");
        Map<String, Integer> stats = dao.getEquipmentStatsByCustomer(1);
        System.out.println("✅ Total: " + stats.get("total"));
        System.out.println("✅ Active: " + stats.get("active"));
        System.out.println("✅ Repair: " + stats.get("repair"));
        System.out.println("✅ Maintenance: " + stats.get("maintenance"));
        System.out.println();

        // Test 5: Get Contract ID for Equipment
        System.out.println("--- Test 5: Get Contract ID for Equipment ---");
        String contractId = dao.getContractIdForEquipment(1, 1);
        System.out.println("✅ Equipment 1 - Contract ID: " + contractId);
        System.out.println();

        // Test 6: Get Equipment by Contract ID
        System.out.println("--- Test 6: Get Equipment by Contract ID (contractId: 1) ---");
        List<EquipmentWithStatus> contractEquipment = dao.getEquipmentByContractId(1);
        System.out.println("✅ Found " + contractEquipment.size() + " equipment(s) in contract");

        for (EquipmentWithStatus eq : contractEquipment) {
            System.out.println("  - " + eq.getModel()
                    + " | Serial: " + eq.getSerialNumber()
                    + " | Price: " + eq.getPrice());
        }
        System.out.println();

        // Test 7: Get Equipment by Customer Contracts
        System.out.println("--- Test 7: Get Equipment by Customer Contracts (customerId: 1) ---");
        try {
            List<Equipment> customerEquipment = dao.getEquipmentByCustomerContracts(1);
            System.out.println("✅ Found " + customerEquipment.size() + " equipment(s) for customer");

            for (Equipment eq : customerEquipment) {
                String cId = dao.getContractIdForEquipment(eq.getEquipmentId(), 1);
                System.out.println("  - Equipment ID: " + eq.getEquipmentId()
                        + " | Model: " + eq.getModel()
                        + " | Contract: " + cId);
            }
        } catch (SQLException e) {
            System.out.println("❌ Error: " + e.getMessage());
        }
        System.out.println();

        // Test 8: Search Equipment with Pagination
        System.out.println("--- Test 8: Search Equipment (keyword: 'Air', page: 1, size: 5) ---");
        try {
            List<Equipment> searchResults = dao.searchEquipment("Air", 1, 5);
            System.out.println("✅ Found " + searchResults.size() + " result(s)");

            for (Equipment eq : searchResults) {
                System.out.println("  - " + eq.getModel() + " [" + eq.getCategoryName() + "]");
            }
        } catch (SQLException e) {
            System.out.println("❌ Error: " + e.getMessage());
        }
        System.out.println();

        // Test 9: Get Equipment Count
        System.out.println("--- Test 9: Get Equipment Count ---");
        try {
            int totalCount = dao.getEquipmentCount(null);
            int searchCount = dao.getEquipmentCount("HVAC");

            System.out.println("✅ Total equipment: " + totalCount);
            System.out.println("✅ Equipment matching 'HVAC': " + searchCount);
        } catch (SQLException e) {
            System.out.println("❌ Error: " + e.getMessage());
        }
        System.out.println();

        // Test 10: Validate Equipment
        System.out.println("--- Test 10: Validate Equipment ---");
        System.out.println("Equipment ID 1 valid: " + dao.isValidEquipment(1));
        System.out.println("Equipment ID 999 valid: " + dao.isValidEquipment(999));
        System.out.println();

        System.out.println("========================================");
        System.out.println("ALL TESTS COMPLETED SUCCESSFULLY");
        System.out.println("========================================");
    }

    // ✅ Lấy tất cả thiết bị khả dụng với thông tin category và giá
// ✅ Lấy tất cả thiết bị khả dụng (chưa được gán trong ContractEquipment hoặc ContractAppendixEquipment)
    public List<Map<String, Object>> getAllAvailableEquipment() throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();

        String sql = "SELECT e.equipmentId, e.serialNumber, e.model, e.description, "
                + "e.installDate, e.categoryId, c.categoryName, c.type as categoryType "
                + "FROM Equipment e "
                + "LEFT JOIN Category c ON e.categoryId = c.categoryId "
                + "WHERE (c.type = 'Equipment' OR c.type = 'Part') "
                + // Loại trừ thiết bị đã có trong ContractEquipment
                "AND e.equipmentId NOT IN (SELECT DISTINCT equipmentId FROM ContractEquipment WHERE equipmentId IS NOT NULL) "
                + // Loại trừ thiết bị đã có trong ContractAppendixEquipment
                "AND e.equipmentId NOT IN (SELECT DISTINCT equipmentId FROM ContractAppendixEquipment WHERE equipmentId IS NOT NULL) "
                + "ORDER BY c.type, c.categoryName, e.model, e.serialNumber";

        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> equipment = new HashMap<>();
                equipment.put("equipmentId", rs.getInt("equipmentId"));
                equipment.put("serialNumber", rs.getString("serialNumber"));
                equipment.put("model", rs.getString("model"));
                equipment.put("description", rs.getString("description"));
                equipment.put("categoryId", rs.getInt("categoryId"));
                equipment.put("categoryName", rs.getString("categoryName"));
                equipment.put("categoryType", rs.getString("categoryType"));

                Date installDate = rs.getDate("installDate");
                if (installDate != null) {
                    equipment.put("installDate", installDate.toLocalDate().toString());
                }

                list.add(equipment);
            }
        }

        return list;
    }

    // ✅ Lấy tất cả thiết bị theo contractId (bao gồm cả từ phụ lục)
    public List<EquipmentWithStatus> getEquipmentAndAppendixByContractId(int contractId) {
        List<EquipmentWithStatus> list = new ArrayList<>();

        // Query lấy thiết bị từ ContractEquipment
        String sqlContract = "SELECT e.equipmentId, e.serialNumber, e.model, e.description, "
                + "e.installDate, e.categoryId, ce.startDate, ce.endDate, ce.price, "
                + "'Contract' as source, "
                + "CASE "
                + "  WHEN ce.startDate > CURDATE() THEN 'Pending' "
                + "  WHEN ce.endDate < CURDATE() THEN 'Expired' "
                + "  ELSE 'Active' "
                + "END as status "
                + "FROM Equipment e "
                + "JOIN ContractEquipment ce ON e.equipmentId = ce.equipmentId "
                + "WHERE ce.contractId = ?";

        // ✅ Query lấy thiết bị từ ContractAppendix (ĐÃ CÓ startDate, endDate)
        String sqlAppendix = "SELECT e.equipmentId, e.serialNumber, e.model, e.description, "
                + "e.installDate, e.categoryId, "
                + "cae.startDate, " // ✅ LẤY startDate từ ContractAppendixEquipment
                + "cae.endDate, " // ✅ LẤY endDate từ ContractAppendixEquipment
                + "cae.unitPrice as price, "
                + "'Appendix' as source, "
                + "CASE " // ✅ TÍNH TOÁN STATUS
                + "  WHEN cae.startDate > CURDATE() THEN 'Pending' "
                + "  WHEN cae.endDate < CURDATE() THEN 'Expired' "
                + "  ELSE 'Active' "
                + "END as status "
                + "FROM Equipment e "
                + "JOIN ContractAppendixEquipment cae ON e.equipmentId = cae.equipmentId "
                + "JOIN ContractAppendix ca ON cae.appendixId = ca.appendixId "
                + "WHERE ca.contractId = ?";

        // UNION cả 2 query
        String sql = "(" + sqlContract + ") UNION ALL (" + sqlAppendix + ") "
                + "ORDER BY source, model, serialNumber";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, contractId);
            ps.setInt(2, contractId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    EquipmentWithStatus eq = new EquipmentWithStatus();

                    eq.setEquipmentId(rs.getInt("equipmentId"));
                    eq.setSerialNumber(rs.getString("serialNumber"));
                    eq.setModel(rs.getString("model"));
                    eq.setDescription(rs.getString("description"));

                    // Set installDate
                    Date installDate = rs.getDate("installDate");
                    if (installDate != null) {
                        eq.setInstallDate(installDate.toLocalDate());
                    }

                    // SET startDate (CẢ CONTRACT VÀ APPENDIX ĐỀU CÓ)
                    Date startDate = rs.getDate("startDate");
                    if (startDate != null) {
                        eq.setStartDate(startDate.toLocalDate());
                    }

                    // SET endDate (CẢ CONTRACT VÀ APPENDIX ĐỀU CÓ)
                    Date endDate = rs.getDate("endDate");
                    if (endDate != null) {
                        eq.setEndDate(endDate.toLocalDate());
                    }

                    // SET PRICE
                    eq.setPrice(rs.getBigDecimal("price"));

                    // SET SOURCE
                    eq.setSource(rs.getString("source"));

                    // SET STATUS (ĐÃ TÍNH TRONG SQL)
                    eq.setStatus(rs.getString("status"));

                    list.add(eq);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    // ✅ Lấy thiết bị chưa được dùng trong bất kỳ hợp đồng hoặc phụ lục nào
    public List<Map<String, Object>> getAvailableEquipmentNotInAnyContract() throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();

        String sql = "SELECT e.equipmentId, e.serialNumber, e.model, e.description "
                + "FROM Equipment e "
                + "WHERE e.equipmentId NOT IN ("
                + "   SELECT DISTINCT equipmentId FROM ContractEquipment "
                + "   UNION "
                + "   SELECT DISTINCT equipmentId FROM ContractAppendixEquipment"
                + ") "
                + "ORDER BY e.model, e.serialNumber";

        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> equipment = new HashMap<>();
                equipment.put("equipmentId", rs.getInt("equipmentId"));
                equipment.put("serialNumber", rs.getString("serialNumber"));
                equipment.put("model", rs.getString("model"));
                equipment.put("description", rs.getString("description"));
                list.add(equipment);
            }
        }

        return list;
    }

    /**
     * Lấy tất cả thiết bị của khách hàng từ cả hợp đồng chính và phụ lục
     *
     * @param customerId ID của khách hàng
     * @return Danh sách thiết bị
     */
//    public List<Equipment> getEquipmentByCustomerContractsAndAppendix(int customerId) throws SQLException {
//        List<Equipment> list = new ArrayList<>();
//
//        String sql = "SELECT DISTINCT e.equipmentId, e.serialNumber, e.model, e.description, "
//                + "e.installDate, e.lastUpdatedBy, e.lastUpdatedDate "
//                + "FROM Equipment e "
//                + "WHERE e.equipmentId IN ( "
//                + "   SELECT DISTINCT ce.equipmentId "
//                + "   FROM ContractEquipment ce "
//                + "   INNER JOIN Contract c ON ce.contractId = c.contractId "
//                + "   WHERE c.customerId = ? "
//                + "   UNION "
//                + "   SELECT DISTINCT cae.equipmentId "
//                + "   FROM ContractAppendixEquipment cae "
//                + "   INNER JOIN ContractAppendix ca ON cae.appendixId = ca.appendixId "
//                + "   INNER JOIN Contract c ON ca.contractId = c.contractId "
//                + "   WHERE c.customerId = ? "
//                + ") "
//                + "ORDER BY e.model, e.serialNumber";
//
//        try (PreparedStatement ps = connection.prepareStatement(sql)) {
//            ps.setInt(1, customerId);
//            ps.setInt(2, customerId);
//
//            try (ResultSet rs = ps.executeQuery()) {
//                while (rs.next()) {
//                    Equipment equipment = new Equipment();
//                    equipment.setEquipmentId(rs.getInt("equipmentId"));
//                    equipment.setSerialNumber(rs.getString("serialNumber"));
//                    equipment.setModel(rs.getString("model"));
//                    equipment.setDescription(rs.getString("description"));
//
//                    Date installDate = rs.getDate("installDate");
//                    if (installDate != null) {
//                        equipment.setInstallDate(installDate.toLocalDate());
//                    }
//
//                    equipment.setLastUpdatedBy(rs.getInt("lastUpdatedBy"));
//
//                    Date lastUpdatedDate = rs.getDate("lastUpdatedDate");
//                    if (lastUpdatedDate != null) {
//                        equipment.setLastUpdatedDate(lastUpdatedDate.toLocalDate());
//                    }
//
//                    list.add(equipment);
//                }
//            }
//        }
//
//        return list;
//    }
    /**
     * Lấy tất cả thiết bị từ hợp đồng chính VÀ phụ lục của khách hàng
     */
    public List<Equipment> getEquipmentByCustomerContractsAndAppendix(int customerId) throws SQLException {
        List<Equipment> equipmentList = new ArrayList<>();

        String sql = """
        SELECT DISTINCT e.*
        FROM Equipment e
        WHERE e.equipmentId IN (
            -- Thiết bị từ hợp đồng chính
            SELECT ce.equipmentId
            FROM ContractEquipment ce
            JOIN Contract c ON ce.contractId = c.contractId
            WHERE c.customerId = ?

            UNION

            -- Thiết bị từ phụ lục
            SELECT cae.equipmentId
            FROM ContractAppendixEquipment cae
            JOIN ContractAppendix ca ON cae.appendixId = ca.appendixId
            JOIN Contract c ON ca.contractId = c.contractId
            WHERE c.customerId = ?
              AND ca.status = 'Approved'
        )
    """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ps.setInt(2, customerId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Equipment eq = new Equipment();
                    eq.setEquipmentId(rs.getInt("equipmentId"));
                    eq.setModel(rs.getString("model"));
                    eq.setSerialNumber(rs.getString("serialNumber"));
                    eq.setDescription(rs.getString("description"));
                    eq.setInstallDate(rs.getDate("installDate") != null
                            ? rs.getDate("installDate").toLocalDate() : null);
                    eq.setCategoryId(rs.getObject("categoryId") != null
                            ? rs.getInt("categoryId") : null);
                    // Có thể set thêm các field khác nếu model Equipment có

                    equipmentList.add(eq);
                }
            }
        } catch (SQLException e) {
            System.err.println("❌ Error fetching equipment for customer " + customerId + ": " + e.getMessage());
            throw e;
        }

        System.out.println("📋 Found " + equipmentList.size() + " equipment for customer " + customerId);
        return equipmentList;
    }

    /**
     * Lấy tất cả thiết bị của khách hàng với thông tin nguồn (Hợp đồng/Phụ lục)
     *
     * @param customerId ID của khách hàng
     * @return Danh sách thiết bị với thông tin nguồn
     */
    public List<EquipmentWithSource> getEquipmentByCustomerWithSource(int customerId) throws SQLException {
        List<EquipmentWithSource> list = new ArrayList<>();

        String sql = "SELECT DISTINCT e.equipmentId, e.serialNumber, e.model, e.description, "
                + "e.installDate, e.lastUpdatedBy, e.lastUpdatedDate, "
                + "CASE "
                + "  WHEN ce.equipmentId IS NOT NULL THEN 'Hợp Đồng' "
                + "  WHEN cae.equipmentId IS NOT NULL THEN 'Phụ Lục' "
                + "  ELSE 'Không xác định' "
                + "END as sourceType, "
                + "CASE "
                + "  WHEN ce.equipmentId IS NOT NULL THEN CONCAT('HD', LPAD(c1.contractId, 3, '0')) "
                + "  WHEN cae.equipmentId IS NOT NULL THEN CONCAT('HD', LPAD(c2.contractId, 3, '0')) "
                + "  ELSE 'N/A' "
                + "END as contractId "
                + "FROM Equipment e "
                + "LEFT JOIN ContractEquipment ce ON e.equipmentId = ce.equipmentId "
                + "LEFT JOIN Contract c1 ON ce.contractId = c1.contractId AND c1.customerId = ? "
                + "LEFT JOIN ContractAppendixEquipment cae ON e.equipmentId = cae.equipmentId "
                + "LEFT JOIN ContractAppendix ca ON cae.appendixId = ca.appendixId "
                + "LEFT JOIN Contract c2 ON ca.contractId = c2.contractId AND c2.customerId = ? "
                + "WHERE (c1.customerId = ? OR c2.customerId = ?) "
                + "ORDER BY sourceType, e.model, e.serialNumber";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ps.setInt(2, customerId);
            ps.setInt(3, customerId);
            ps.setInt(4, customerId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    EquipmentWithSource equipment = new EquipmentWithSource();
                    equipment.setEquipmentId(rs.getInt("equipmentId"));
                    equipment.setSerialNumber(rs.getString("serialNumber"));
                    equipment.setModel(rs.getString("model"));
                    equipment.setDescription(rs.getString("description"));
                    equipment.setSourceType(rs.getString("sourceType"));
                    equipment.setContractId(rs.getString("contractId"));

                    Date installDate = rs.getDate("installDate");
                    if (installDate != null) {
                        equipment.setInstallDate(installDate.toLocalDate());
                    }

                    equipment.setLastUpdatedBy(rs.getInt("lastUpdatedBy"));

                    Date lastUpdatedDate = rs.getDate("lastUpdatedDate");
                    if (lastUpdatedDate != null) {
                        equipment.setLastUpdatedDate(lastUpdatedDate.toLocalDate());
                    }

                    list.add(equipment);
                }
            }
        }

        return list;
    }

    /**
     * Inner class để chứa thông tin thiết bị với nguồn
     */
    public static class EquipmentWithSource {

        private int equipmentId;
        private String serialNumber;
        private String model;
        private String description;
        private java.time.LocalDate installDate;
        private int lastUpdatedBy;
        private java.time.LocalDate lastUpdatedDate;
        private String sourceType; // "Hợp Đồng" hoặc "Phụ Lục"
        private String contractId; // Mã hợp đồng

        // Getters and Setters
        public int getEquipmentId() {
            return equipmentId;
        }

        public void setEquipmentId(int equipmentId) {
            this.equipmentId = equipmentId;
        }

        public String getSerialNumber() {
            return serialNumber;
        }

        public void setSerialNumber(String serialNumber) {
            this.serialNumber = serialNumber;
        }

        public String getModel() {
            return model;
        }

        public void setModel(String model) {
            this.model = model;
        }

        public String getDescription() {
            return description;
        }

        public void setDescription(String description) {
            this.description = description;
        }

        public java.time.LocalDate getInstallDate() {
            return installDate;
        }

        public void setInstallDate(java.time.LocalDate installDate) {
            this.installDate = installDate;
        }

        public int getLastUpdatedBy() {
            return lastUpdatedBy;
        }

        public void setLastUpdatedBy(int lastUpdatedBy) {
            this.lastUpdatedBy = lastUpdatedBy;
        }

        public java.time.LocalDate getLastUpdatedDate() {
            return lastUpdatedDate;
        }

        public void setLastUpdatedDate(java.time.LocalDate lastUpdatedDate) {
            this.lastUpdatedDate = lastUpdatedDate;
        }

        public String getSourceType() {
            return sourceType;
        }

        public void setSourceType(String sourceType) {
            this.sourceType = sourceType;
        }

        public String getContractId() {
            return contractId;
        }

        public void setContractId(String contractId) {
            this.contractId = contractId;
        }
    }

    public int getEquipmentCount() {
        String sql = "SELECT COUNT(*) FROM Equipment";
        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return 0;
    }
// Thêm method này vào class EquipmentDAO của bạn

    /**
     * Lấy thông tin template của 1 model cụ thể (để dùng khi thêm equipment với
     * model có sẵn)
     *
     * @param model Model name
     * @return Equipment object chứa thông tin template, hoặc null nếu không tìm
     * thấy
     */
    public Equipment getEquipmentGroupedByModelSingle(String model) {
        String sql = "SELECT e.model, e.description, e.category_id, c.category_name "
                + "FROM equipment e "
                + "LEFT JOIN category c ON e.category_id = c.category_id "
                + "WHERE e.model = ? "
                + "LIMIT 1";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, model);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                Equipment equipment = new Equipment();
                equipment.setModel(rs.getString("model"));
                equipment.setDescription(rs.getString("description"));

                int categoryId = rs.getInt("category_id");
                if (!rs.wasNull()) {
                    equipment.setCategoryId(categoryId);
                    equipment.setCategoryName(rs.getString("category_name"));
                } else {
                    equipment.setCategoryId(0);
                }

                return equipment;
            }
        } catch (SQLException e) {
            System.out.println("Error in getEquipmentGroupedByModelSingle: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    public List<Equipment> getEquipmentByContract(int contractId) throws SQLException {
        List<Equipment> list = new ArrayList<>();

        String sql = "SELECT DISTINCT e.equipmentId, e.serialNumber, e.model, e.description, "
                + "e.installDate, e.categoryId, c.categoryName, "
                + "e.lastUpdatedBy, e.lastUpdatedDate, a.username "
                + "FROM Equipment e "
                + "INNER JOIN ContractEquipment ce ON e.equipmentId = ce.equipmentId "
                + "LEFT JOIN Category c ON e.categoryId = c.categoryId "
                + "LEFT JOIN Account a ON e.lastUpdatedBy = a.accountId "
                + "WHERE ce.contractId = ? "
                + "ORDER BY e.model, e.serialNumber";

        System.out.println("📊 DAO: Executing query for contractId: " + contractId);

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, contractId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Equipment equipment = mapResultSetToEquipment(rs);
                    list.add(equipment);
                    System.out.println("  - Found: " + equipment.getModel() + " (ID: " + equipment.getEquipmentId() + ")");
                }
            }
        } catch (SQLException e) {
            System.out.println("❌ DAO Error getting equipment by contractId: " + e.getMessage());
            throw e;
        }

        System.out.println("✅ DAO: Returning " + list.size() + " equipment");
        return list;
    }
}
