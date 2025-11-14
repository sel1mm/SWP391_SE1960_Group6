package dal;

import model.Contract;
import model.EquipmentWithStatus;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * DAO for Contract operations. Updated to work with the final database schema.
 */
public class ContractDAO extends MyDAO {

    public static class ContractWithCustomer {

        public Contract contract;
        public String customerName;

        public Contract getContract() {
            return contract;
        }

        public String getCustomerName() {
            return customerName;
        }
    }

    public static class Customer {

        public int accountId;
        public String fullName;
        public String email;

        public int getAccountId() {
            return accountId;
        }

        public String getFullName() {
            return fullName;
        }

        public String getEmail() {
            return email;
        }
    }

    public Contract getContractById(int contractId) {
        xSql = "SELECT * FROM Contract WHERE contractId = ?";
        try {
            ps = con.prepareStatement(xSql);
            ps.setInt(1, contractId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapResultSetToContract(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return null;
    }

    public String getCustomerNameByContractId(int contractId) {
        xSql = "SELECT a.fullName FROM Contract c "
                + "INNER JOIN Account a ON c.customerId = a.accountId "
                + "WHERE c.contractId = ?";
        try {
            ps = con.prepareStatement(xSql);
            ps.setInt(1, contractId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getString("fullName");
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return null;
    }

    public boolean isContractActive(int contractId) {
        xSql = "SELECT contractId FROM Contract "
                + "WHERE contractId = ? AND status = 'Active'";
        try {
            ps = con.prepareStatement(xSql);
            ps.setInt(1, contractId);
            rs = ps.executeQuery();
            return rs.next();
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            closeResources();
        }
    }

    public boolean updateContractStatus(int contractId, String newStatus) throws SQLException {
        xSql = "UPDATE Contract SET status = ? WHERE contractId = ?";
        ps = con.prepareStatement(xSql);
        ps.setString(1, newStatus);
        ps.setInt(2, contractId);

        int affected = ps.executeUpdate();
        return affected > 0;
    }

    public List<Customer> getAllCustomers() throws SQLException {
        List<Customer> customers = new ArrayList<>();
        xSql = "SELECT accountId, fullName, email FROM Account WHERE accountId > 0 ORDER BY fullName";
        ps = con.prepareStatement(xSql);
        rs = ps.executeQuery();
        while (rs.next()) {
            Customer customer = new Customer();
            customer.accountId = rs.getInt("accountId");
            customer.fullName = rs.getString("fullName");
            customer.email = rs.getString("email");
            customers.add(customer);
        }
        return customers;
    }

    /**
     * Get customers assigned to technician via WorkTask
     */
    public List<Customer> getCustomersAssignedToTechnician(int technicianId) throws SQLException {
        List<Customer> customers = new ArrayList<>();
        String sql = "SELECT DISTINCT a.accountId, a.fullName, a.email "
                + "FROM Account a "
                + "JOIN ServiceRequest sr ON a.accountId = sr.createdBy "
                + "JOIN WorkTask wt ON sr.requestId = wt.requestId "
                + "WHERE wt.technicianId = ? "
                + "ORDER BY a.fullName";

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, technicianId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Customer customer = new Customer();
                    customer.accountId = rs.getInt("accountId");
                    customer.fullName = rs.getString("fullName");
                    customer.email = rs.getString("email");
                    customers.add(customer);
                }
            }
        }
        return customers;
    }

    public List<ContractWithCustomer> getAllContracts() throws SQLException {
        List<ContractWithCustomer> contracts = new ArrayList<>();
        xSql = "SELECT c.contractId, c.customerId, c.contractDate, c.contractType, c.status, c.details, "
                + "a.fullName as customerName "
                + "FROM Contract c "
                + "JOIN Account a ON c.customerId = a.accountId "
                + "ORDER BY c.contractDate DESC";
        ps = con.prepareStatement(xSql);
        rs = ps.executeQuery();
        while (rs.next()) {
            ContractWithCustomer contractWithCustomer = new ContractWithCustomer();
            contractWithCustomer.contract = mapResultSetToContract(rs);
            contractWithCustomer.customerName = rs.getString("customerName");
            contracts.add(contractWithCustomer);
        }
        return contracts;
    }

    public long createContract(int customerId, java.sql.Date contractDate, String contractType,
            String status, String details) throws SQLException {
        xSql = "INSERT INTO Contract (customerId, contractDate, contractType, status, details) "
                + "VALUES (?, ?, ?, ?, ?)";
        ps = con.prepareStatement(xSql, java.sql.Statement.RETURN_GENERATED_KEYS);
        ps.setInt(1, customerId);
        ps.setDate(2, contractDate);
        ps.setString(3, contractType);
        ps.setString(4, status);
        ps.setString(5, details);

        int affected = ps.executeUpdate();
        if (affected > 0) {
            rs = ps.getGeneratedKeys();
            if (rs.next()) {
                return rs.getLong(1);
            }
        }
        return 0L;
    }

    private Contract mapResultSetToContract(ResultSet rs) throws SQLException {
        Contract contract = new Contract();
        contract.setContractId(rs.getInt("contractId"));
        contract.setCustomerId(rs.getInt("customerId"));

        Date sqlDate = rs.getDate("contractDate");
        if (sqlDate != null) {
            contract.setContractDate(sqlDate.toLocalDate());
        }

        contract.setContractType(rs.getString("contractType"));
        contract.setStatus(rs.getString("status"));
        contract.setDetails(rs.getString("details"));
        return contract;
    }

    private void closeResources() {
        try {
            if (rs != null) {
                rs.close();
            }
            if (ps != null) {
                ps.close();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public List<ContractWithCustomer> searchContracts(String searchQuery, String statusFilter, int page, int pageSize) throws SQLException {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT c.*, a.fullName as customerName ");
        sql.append("FROM Contract c ");
        sql.append("JOIN Account a ON c.customerId = a.accountId ");
        sql.append("WHERE 1=1 ");

        List<Object> params = new ArrayList<>();

        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            sql.append("AND (c.contractId LIKE ? OR a.fullName LIKE ? OR c.details LIKE ?) ");
            String searchPattern = "%" + searchQuery.trim() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
        }

        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            sql.append("AND c.status = ? ");
            params.add(statusFilter.trim());
        }

        sql.append("ORDER BY c.contractDate DESC ");
        sql.append("LIMIT ? OFFSET ?");

        int offset = (page - 1) * pageSize;
        params.add(pageSize);
        params.add(offset);

        List<ContractWithCustomer> contracts = new ArrayList<>();
        xSql = sql.toString();

        try {
            ps = con.prepareStatement(xSql);
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            rs = ps.executeQuery();

            while (rs.next()) {
                ContractWithCustomer contractWithCustomer = new ContractWithCustomer();
                contractWithCustomer.contract = mapResultSetToContract(rs);
                contractWithCustomer.customerName = rs.getString("customerName");
                contracts.add(contractWithCustomer);
            }
        } finally {
            closeResources();
        }

        return contracts;
    }

    public int getContractCount(String searchQuery, String statusFilter) throws SQLException {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) ");
        sql.append("FROM Contract c ");
        sql.append("JOIN Account a ON c.customerId = a.accountId ");
        sql.append("WHERE 1=1 ");

        List<Object> params = new ArrayList<>();

        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            sql.append("AND (c.contractId LIKE ? OR a.fullName LIKE ? OR c.details LIKE ?) ");
            String searchPattern = "%" + searchQuery.trim() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
        }

        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            sql.append("AND c.status = ? ");
            params.add(statusFilter.trim());
        }

        xSql = sql.toString();

        try {
            ps = con.prepareStatement(xSql);
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt(1);
            }
        } finally {
            closeResources();
        }

        return 0;
    }

    public List<Contract> getEveryContracts() {
        List<Contract> list = new ArrayList<>();
        String sql = "SELECT contractId, customerId, details FROM Contract"; // ⚠️ Phải có customerId

        try (PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Contract c = new Contract();
                c.setContractId(rs.getInt("contractId"));
                c.setCustomerId(rs.getInt("customerId")); // ⚠️ Dòng này quan trọng!
                c.setDetails(rs.getString("details"));
                list.add(c);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    /**
     * Get available parts from PartDetail table for contract creation
     */
    public List<EquipmentWithStatus> getAvailableParts() throws SQLException {
        List<EquipmentWithStatus> partsList = new ArrayList<>();
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
                + "WHERE pd.status = 'Available' "
                + "ORDER BY p.partName, pd.serialNumber";

        try (PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                EquipmentWithStatus part = new EquipmentWithStatus();
                part.setEquipmentId(rs.getInt("equipmentId"));
                part.setSerialNumber(rs.getString("serialNumber"));
                part.setModel(rs.getString("model"));
                part.setDescription(rs.getString("description"));
                part.setLastUpdatedBy(rs.getInt("lastUpdatedBy"));
                part.setStatus(rs.getString("status"));
                part.setLocation(rs.getString("location"));
                part.setUnitPrice(rs.getDouble("unitPrice"));

                Date installDate = rs.getDate("installDate");
                if (installDate != null) {
                    part.setInstallDate(installDate.toLocalDate());
                }

                Date lastUpdatedDate = rs.getDate("lastUpdatedDate");
                if (lastUpdatedDate != null) {
                    part.setLastUpdatedDate(lastUpdatedDate.toLocalDate());
                }

                partsList.add(part);
            }
        } catch (SQLException e) {
            System.out.println("❌ Error getting available parts: " + e.getMessage());
            throw e;
        }

        return partsList;
    }

    /**
     * Validate if part is available for contract
     */
    public boolean isPartAvailable(int partDetailId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM PartDetail WHERE partDetailId = ? AND status = 'Available'";

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, partDetailId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            System.out.println("❌ Error checking part availability: " + e.getMessage());
            throw e;
        }

        return false;
    }

    /**
     * Create contract with part assignment (creates Equipment entry from
     * PartDetail)
     */
    public long createContractWithPart(int customerId, java.sql.Date contractDate, String contractType,
            String status, String details, int partDetailId) throws SQLException {
        con.setAutoCommit(false);

        try {
            // 1. Create the contract
            String contractSql = "INSERT INTO Contract (customerId, contractDate, contractType, status, details) "
                    + "VALUES (?, ?, ?, ?, ?)";

            long contractId = 0;
            try (PreparedStatement ps = con.prepareStatement(contractSql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, customerId);
                ps.setDate(2, contractDate);
                ps.setString(3, contractType);
                ps.setString(4, status);
                ps.setString(5, details);

                int affected = ps.executeUpdate();
                if (affected > 0) {
                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        if (rs.next()) {
                            contractId = rs.getLong(1);
                        }
                    }
                }
            }

            if (contractId > 0 && partDetailId > 0) {
                // 2. Get part details + OLD STATUS ⭐ THÊM oldStatus vào query
                String selectPartSql = "SELECT pd.serialNumber, pd.status, p.partName, p.description, p.unitPrice "
                        + "FROM PartDetail pd JOIN Part p ON pd.partId = p.partId WHERE pd.partDetailId = ?";
                String serialNumber = null;
                String partName = null;
                String description = null;
                double unitPrice = 0.0;
                String oldStatus = null; // ⭐ THÊM biến để lưu status cũ

                try (PreparedStatement ps = con.prepareStatement(selectPartSql)) {
                    ps.setInt(1, partDetailId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            serialNumber = rs.getString("serialNumber");
                            oldStatus = rs.getString("status"); // ⭐ LẤY status cũ
                            partName = rs.getString("partName");
                            description = rs.getString("description");
                            unitPrice = rs.getDouble("unitPrice");
                        }
                    }
                }

                if (serialNumber == null) {
                    throw new SQLException("Part details not found for partDetailId=" + partDetailId);
                }

                // 3. Create Equipment entry from PartDetail
                String insertEquipmentSql = "INSERT INTO Equipment (serialNumber, model, description, installDate, lastUpdatedBy, lastUpdatedDate) "
                        + "VALUES (?, ?, ?, ?, ?, ?)";
                int equipmentId = 0;
                try (PreparedStatement ps = con.prepareStatement(insertEquipmentSql, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setString(1, serialNumber);
                    ps.setString(2, partName);
                    ps.setString(3, description);
                    ps.setDate(4, contractDate);
                    ps.setInt(5, customerId);
                    ps.setDate(6, contractDate);

                    int affected = ps.executeUpdate();
                    if (affected > 0) {
                        try (ResultSet rs = ps.getGeneratedKeys()) {
                            if (rs.next()) {
                                equipmentId = rs.getInt(1);
                            }
                        }
                    }
                }

                // 4. Create ContractEquipment relationship
                String contractEquipmentSql = "INSERT INTO ContractEquipment (contractId, equipmentId, startDate, quantity, price) "
                        + "VALUES (?, ?, ?, 1, ?)";
                try (PreparedStatement ps = con.prepareStatement(contractEquipmentSql)) {
                    ps.setLong(1, contractId);
                    ps.setInt(2, equipmentId);
                    ps.setDate(3, contractDate);
                    ps.setBigDecimal(4, java.math.BigDecimal.valueOf(unitPrice));
                    ps.executeUpdate();
                }

                // 5. Update PartDetail status to InUse
                String updatePartSql = "UPDATE PartDetail SET status = 'InUse', lastUpdatedDate = ? WHERE partDetailId = ?";
                try (PreparedStatement ps = con.prepareStatement(updatePartSql)) {
                    ps.setDate(1, contractDate);
                    ps.setInt(2, partDetailId);
                    ps.executeUpdate();
                }

                // ⭐⭐⭐ 6. GHI LỊCH SỬ THAY ĐỔI - THÊM MỚI ⭐⭐⭐
// ⭐ 6. GHI LỊCH SỬ
                try {
                    PartDetailHistoryDAO historyDAO = new PartDetailHistoryDAO();
                    String notes = "Technician lấy thiết bị từ kho để tạo contract #" + contractId;

                    // ⭐ Truyền 'con' vào để dùng chung connection
                    historyDAO.addHistoryWithTransaction(
                            con, // ⭐⭐⭐ Connection của ContractDAO
                            partDetailId,
                            oldStatus,
                            "InUse",
                            customerId,
                            notes
                    );

                    System.out.println("✅ History logged successfully");

                } catch (Exception historyError) {
                    System.err.println("⚠️ Warning: Failed to log history - " + historyError.getMessage());
                }
            }

            con.commit();
            return contractId;

        } catch (SQLException e) {
            con.rollback();
            System.out.println("❌ Error creating contract with part: " + e.getMessage());
            throw e;
        } finally {
            con.setAutoCommit(true);
        }
    }

    /**
     * Simple test method to get all equipment (for debugging)
     */
    public List<EquipmentWithStatus> getAllEquipment() throws SQLException {
        List<EquipmentWithStatus> equipmentList = new ArrayList<>();
        String sql = "SELECT equipmentId, serialNumber, model, description, installDate, lastUpdatedBy, lastUpdatedDate FROM Equipment ORDER BY equipmentId";

        try (PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                EquipmentWithStatus equipment = new EquipmentWithStatus();
                equipment.setEquipmentId(rs.getInt("equipmentId"));
                equipment.setSerialNumber(rs.getString("serialNumber"));
                equipment.setModel(rs.getString("model"));
                equipment.setDescription(rs.getString("description"));
                equipment.setLastUpdatedBy(rs.getInt("lastUpdatedBy"));
                equipment.setStatus("Test"); // Test status
                equipment.setLocation("Test Location"); // Test location
                equipment.setUnitPrice(0.0);

                Date installDate = rs.getDate("installDate");
                if (installDate != null) {
                    equipment.setInstallDate(installDate.toLocalDate());
                }

                Date lastUpdatedDate = rs.getDate("lastUpdatedDate");
                if (lastUpdatedDate != null) {
                    equipment.setLastUpdatedDate(lastUpdatedDate.toLocalDate());
                }

                equipmentList.add(equipment);
            }
        } catch (SQLException e) {
            System.out.println("❌ Error getting all equipment: " + e.getMessage());
            throw e;
        }

        System.out.println("📊 getAllEquipment() returning " + equipmentList.size() + " equipment items");
        return equipmentList;
    }

    /**
     * Debug method to test equipment query
     */
    public void debugEquipmentQuery() throws SQLException {
        System.out.println("🔍 Debugging Equipment Query...");

        // Test 1: Check database connection
        if (con == null) {
            System.out.println("❌ Database connection is NULL!");
            return;
        }
        System.out.println("✅ Database connection is active");

        // Test 2: Count total equipment
        String countSql = "SELECT COUNT(*) FROM Equipment";
        try (PreparedStatement ps = con.prepareStatement(countSql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                System.out.println("📊 Total Equipment in database: " + rs.getInt(1));
            }
        }

        // Test 3: Show all equipment
        String allEquipmentSql = "SELECT equipmentId, serialNumber, model FROM Equipment ORDER BY equipmentId";
        try (PreparedStatement ps = con.prepareStatement(allEquipmentSql); ResultSet rs = ps.executeQuery()) {
            System.out.println("📊 All Equipment in database:");
            while (rs.next()) {
                System.out.println("  ID: " + rs.getInt("equipmentId")
                        + ", Serial: " + rs.getString("serialNumber")
                        + ", Model: " + rs.getString("model"));
            }
        }

        // Test 4: Count assigned equipment
        String assignedSql = "SELECT COUNT(*) FROM ContractEquipment";
        try (PreparedStatement ps = con.prepareStatement(assignedSql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                System.out.println("📊 Equipment assigned to contracts: " + rs.getInt(1));
            }
        }

        // Test 5: Show assigned equipment
        String assignedEquipmentSql = "SELECT ce.equipmentId, e.serialNumber, e.model FROM ContractEquipment ce JOIN Equipment e ON ce.equipmentId = e.equipmentId";
        try (PreparedStatement ps = con.prepareStatement(assignedEquipmentSql); ResultSet rs = ps.executeQuery()) {
            System.out.println("📊 Assigned Equipment:");
            while (rs.next()) {
                System.out.println("  ID: " + rs.getInt("equipmentId")
                        + ", Serial: " + rs.getString("serialNumber")
                        + ", Model: " + rs.getString("model"));
            }
        }

        // Test 6: Show available equipment
        String availableSql = "SELECT e.equipmentId, e.serialNumber, e.model "
                + "FROM Equipment e "
                + "LEFT JOIN ContractEquipment ce ON e.equipmentId = ce.equipmentId "
                + "WHERE ce.equipmentId IS NULL";
        try (PreparedStatement ps = con.prepareStatement(availableSql); ResultSet rs = ps.executeQuery()) {
            System.out.println("📊 Available Equipment:");
            int count = 0;
            while (rs.next()) {
                count++;
                System.out.println("  " + count + ". ID: " + rs.getInt("equipmentId")
                        + ", Serial: " + rs.getString("serialNumber")
                        + ", Model: " + rs.getString("model"));
            }
            System.out.println("📊 Total Available Equipment: " + count);
        }
    }

    /**
     * Get available equipment from Equipment table for contract creation
     */
    public List<EquipmentWithStatus> getAvailableEquipment() throws SQLException {
        // Debug the query first
        debugEquipmentQuery();

        List<EquipmentWithStatus> equipmentList = new ArrayList<>();
        String sql = "SELECT "
                + "    e.equipmentId, "
                + "    e.serialNumber, "
                + "    e.model, "
                + "    e.description, "
                + "    e.installDate, "
                + "    e.lastUpdatedBy, "
                + "    e.lastUpdatedDate "
                + "FROM Equipment e "
                + "LEFT JOIN ContractEquipment ce ON e.equipmentId = ce.equipmentId "
                + "WHERE ce.equipmentId IS NULL "
                + // Equipment not assigned to any contract
                "ORDER BY e.model, e.serialNumber";

        try (PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                EquipmentWithStatus equipment = new EquipmentWithStatus();
                equipment.setEquipmentId(rs.getInt("equipmentId"));
                equipment.setSerialNumber(rs.getString("serialNumber"));
                equipment.setModel(rs.getString("model"));
                equipment.setDescription(rs.getString("description"));
                equipment.setLastUpdatedBy(rs.getInt("lastUpdatedBy"));
                equipment.setStatus("Available"); // Available for contract assignment
                equipment.setLocation("Equipment Inventory"); // Default location
                equipment.setUnitPrice(0.0); // Equipment doesn't have unitPrice, set to 0

                Date installDate = rs.getDate("installDate");
                if (installDate != null) {
                    equipment.setInstallDate(installDate.toLocalDate());
                }

                Date lastUpdatedDate = rs.getDate("lastUpdatedDate");
                if (lastUpdatedDate != null) {
                    equipment.setLastUpdatedDate(lastUpdatedDate.toLocalDate());
                }

                equipmentList.add(equipment);
            }
        } catch (SQLException e) {
            System.out.println("❌ Error getting available equipment: " + e.getMessage());
            throw e;
        }

        System.out.println("📊 getAvailableEquipment() returning " + equipmentList.size() + " equipment items");
        return equipmentList;
    }

    /**
     * Validate if equipment is available for contract
     */
    public boolean isEquipmentAvailable(int equipmentId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM Equipment e "
                + "LEFT JOIN ContractEquipment ce ON e.equipmentId = ce.equipmentId "
                + "WHERE e.equipmentId = ? AND ce.equipmentId IS NULL";

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, equipmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            System.out.println("❌ Error checking equipment availability: " + e.getMessage());
            throw e;
        }

        return false;
    }

    /**
     * Create contract with equipment assignment
     */
    public long createContractWithEquipment(int customerId, java.sql.Date contractDate, String contractType,
            String status, String details, int equipmentId) throws SQLException {
        con.setAutoCommit(false);

        try {
            // 1. Create the contract
            String contractSql = "INSERT INTO Contract (customerId, contractDate, contractType, status, details) "
                    + "VALUES (?, ?, ?, ?, ?)";

            long contractId = 0;
            try (PreparedStatement ps = con.prepareStatement(contractSql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, customerId);
                ps.setDate(2, contractDate);
                ps.setString(3, contractType);
                ps.setString(4, status);
                ps.setString(5, details);

                int affected = ps.executeUpdate();
                if (affected > 0) {
                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        if (rs.next()) {
                            contractId = rs.getLong(1);
                        }
                    }
                }
            }

            if (contractId > 0 && equipmentId > 0) {
                // 2. Create ContractEquipment relationship
                String contractEquipmentSql = "INSERT INTO ContractEquipment (contractId, equipmentId, startDate, quantity, price) "
                        + "VALUES (?, ?, ?, 1, (SELECT unitPrice FROM Equipment WHERE equipmentId = ?))";
                try (PreparedStatement ps = con.prepareStatement(contractEquipmentSql)) {
                    ps.setLong(1, contractId);
                    ps.setInt(2, equipmentId);
                    ps.setDate(3, contractDate);
                    ps.setInt(4, equipmentId);
                    ps.executeUpdate();
                }
            }

            con.commit();
            return contractId;

        } catch (SQLException e) {
            con.rollback();
            System.out.println("❌ Error creating contract with equipment: " + e.getMessage());
            throw e;
        } finally {
            con.setAutoCommit(true);
        }
    }

    /**
     * Get contract with equipment details
     */
    public ContractWithEquipment getContractWithEquipment(int contractId) throws SQLException {
        String sql = "SELECT "
                + "    c.contractId, c.customerId, c.contractDate, c.contractType, c.status, c.details, "
                + "    a.fullName as customerName, "
                + "    ce.contractEquipmentId, ce.equipmentId, ce.startDate, ce.endDate, ce.quantity, ce.price, "
                + "    e.serialNumber, e.model as equipmentModel, e.description as equipmentDescription, "
                + "    e.installDate "
                + "FROM Contract c "
                + "JOIN Account a ON c.customerId = a.accountId "
                + "LEFT JOIN ContractEquipment ce ON c.contractId = ce.contractId "
                + "LEFT JOIN Equipment e ON ce.equipmentId = e.equipmentId "
                + "WHERE c.contractId = ?";

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, contractId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    ContractWithEquipment contractWithEquipment = new ContractWithEquipment();
                    contractWithEquipment.contract = mapResultSetToContract(rs);
                    contractWithEquipment.customerName = rs.getString("customerName");

                    // Add equipment details if available
                    if (rs.getInt("equipmentId") > 0) {
                        EquipmentWithStatus equipment = new EquipmentWithStatus();
                        equipment.setEquipmentId(rs.getInt("equipmentId"));
                        equipment.setSerialNumber(rs.getString("serialNumber"));
                        equipment.setModel(rs.getString("equipmentModel"));
                        equipment.setDescription(rs.getString("equipmentDescription"));
                        equipment.setStatus("InUse"); // Equipment in contracts is always InUse
                        equipment.setLocation("Contract Assignment"); // Default location

                        Date installDate = rs.getDate("installDate");
                        if (installDate != null) {
                            equipment.setInstallDate(installDate.toLocalDate());
                        }

                        contractWithEquipment.equipment = equipment;
                        contractWithEquipment.contractEquipmentId = rs.getInt("contractEquipmentId");
                        contractWithEquipment.quantity = rs.getInt("quantity");
                        contractWithEquipment.price = rs.getBigDecimal("price");
                    }

                    return contractWithEquipment;
                }
            }
        } catch (SQLException e) {
            System.out.println("❌ Error getting contract with equipment: " + e.getMessage());
            throw e;
        }

        return null;
    }

    /**
     * Inner class for contract with equipment details
     */
    public static class ContractWithEquipment {

        public Contract contract;
        public String customerName;
        public EquipmentWithStatus equipment;
        public int contractEquipmentId;
        public int quantity;
        public java.math.BigDecimal price;

        public Contract getContract() {
            return contract;
        }

        public String getCustomerName() {
            return customerName;
        }

        public EquipmentWithStatus getEquipment() {
            return equipment;
        }

        public int getContractEquipmentId() {
            return contractEquipmentId;
        }

        public int getQuantity() {
            return quantity;
        }

        public java.math.BigDecimal getPrice() {
            return price;
        }
    }

    public Integer getContractEquipmentIdByContractAndEquipment(int contractId, int equipmentId) {
        String sql = "SELECT contractEquipmentId FROM ContractEquipment WHERE contractId = ? AND equipmentId = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, contractId);
            ps.setInt(2, equipmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int id = rs.getInt("contractEquipmentId");
                    if (id > 0) {
                        return id;
                    }
                }
            }
        } catch (SQLException e) {
            System.out.println("❌ Error getting ContractEquipmentId: " + e.getMessage());
        }
        return null;
    }

    /**
     * ✅ Get all contracts belonging to a specific customer ONLY get main
     * contracts from Contract table
     */
    public List<Contract> getContractsByCustomer(int customerId) throws SQLException {
        List<Contract> list = new ArrayList<>();

        // Chỉ lấy hợp đồng chính từ bảng Contract
        String sql = """
        SELECT 
            contractId, 
            customerId, 
            contractDate, 
            contractType,
            status, 
            details
        FROM Contract 
        WHERE customerId = ?
        ORDER BY contractDate DESC
    """;

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Contract c = new Contract();
                    c.setContractId(rs.getInt("contractId"));
                    c.setCustomerId(rs.getInt("customerId"));

                    Date sqlDate = rs.getDate("contractDate");
                    if (sqlDate != null) {
                        c.setContractDate(sqlDate.toLocalDate());
                    }

                    // ✅ ĐÂY LÀ ĐIỂM QUAN TRỌNG!
                    // Nếu contractType NULL hoặc rỗng → set thành "MainContract"
                    String contractType = rs.getString("contractType");
                    if (contractType == null || contractType.trim().isEmpty()) {
                        c.setContractType("MainContract");
                    } else {
                        c.setContractType(contractType);
                    }

                    c.setStatus(rs.getString("status"));
                    c.setDetails(rs.getString("details"));
                    list.add(c);
                }
            }
        } catch (SQLException e) {
            System.err.println("❌ Error in getContractsByCustomer: " + e.getMessage());
            throw e;
        }

        System.out.println("✅ getContractsByCustomer: Found " + list.size() + " contracts for customer " + customerId);

        // Debug: In ra thông tin từng hợp đồng
        for (Contract c : list) {
            System.out.println("  - Contract ID: " + c.getContractId()
                    + ", Type: " + c.getContractType()
                    + ", Status: " + c.getStatus()
                    + ", Date: " + c.getContractDate());
        }

        return list;
    }

    /**
     * ✅ Get all contracts AND appendixes belonging to a specific customer This
     * method combines both main contracts and appendixes
     */
    /**
     * ✅ Get BOTH main contracts AND appendixes for a customer
     *
     * @param customerId
     */
    public List<Contract> getContractsAndAppendixesByCustomer(int customerId) throws SQLException {
        List<Contract> list = new ArrayList<>();

        // 1. Lấy hợp đồng chính từ bảng Contract
        String mainContractSql = """
        SELECT 
            contractId, 
            customerId, 
            contractDate, 
            contractType,
            status, 
            details,
            fileAttachment
        FROM Contract 
        WHERE customerId = ?
    """;

        try (PreparedStatement ps = con.prepareStatement(mainContractSql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Contract c = new Contract();
                    c.setContractId(rs.getInt("contractId"));
                    c.setCustomerId(rs.getInt("customerId"));

                    Date sqlDate = rs.getDate("contractDate");
                    if (sqlDate != null) {
                        c.setContractDate(sqlDate.toLocalDate());
                    }

                    // ✅ Nếu contractType NULL → set = "MainContract"
                    String contractType = rs.getString("contractType");
                    c.setContractType((contractType == null || contractType.trim().isEmpty())
                            ? "MainContract"
                            : contractType);

                    c.setStatus(rs.getString("status"));
                    c.setDetails(rs.getString("details"));

                    // ✅ THÊM: Lấy file attachment
                    String fileAttachment = rs.getString("fileAttachment");
                    c.setFileAttachment(fileAttachment);
                    c.setDocumentUrl(fileAttachment); // Set cả 2 cho tương thích

                    list.add(c);
                }
            }
        }

        // 2. Lấy phụ lục từ bảng ContractAppendix
        String appendixSql = """
        SELECT 
            ca.appendixId,
            c.customerId,
            ca.effectiveDate as contractDate,
            ca.status,
            CONCAT('Phụ lục: ', ca.appendixName, ' (HĐ #', ca.contractId, ')') as details,
            ca.contractId as parentContractId,
            ca.fileAttachment
        FROM ContractAppendix ca
        JOIN Contract c ON ca.contractId = c.contractId
        WHERE c.customerId = ?
    """;

        try (PreparedStatement ps = con.prepareStatement(appendixSql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Contract c = new Contract();

                    // ⚠️ LƯU Ý: appendixId khác với contractId
                    // Để phân biệt, có thể thêm prefix
                    c.setContractId(rs.getInt("appendixId"));
                    c.setCustomerId(rs.getInt("customerId"));

                    Date sqlDate = rs.getDate("contractDate");
                    if (sqlDate != null) {
                        c.setContractDate(sqlDate.toLocalDate());
                    }

                    // ✅ LUÔN set = "Appendix" cho phụ lục
                    c.setContractType("Appendix");
                    c.setStatus(rs.getString("status"));
                    c.setDetails(rs.getString("details"));

                    // ✅ THÊM: Lấy file attachment của phụ lục
                    String fileAttachment = rs.getString("fileAttachment");
                    c.setFileAttachment(fileAttachment);
                    c.setDocumentUrl(fileAttachment); // Set cả 2 cho tương thích

                    list.add(c);
                }
            }
        }

        // 3. Sắp xếp theo ngày (mới nhất trước)
        list.sort((a, b) -> b.getContractDate().compareTo(a.getContractDate()));

        System.out.println("✅ getContractsAndAppendixesByCustomer: Found " + list.size() + " items for customer " + customerId);

        return list;
    }

    public Integer getContractIdByEquipmentAndCustomer(int equipmentId, int customerId) throws SQLException {
        String sql = "SELECT c.contractId "
                + "FROM Contract c "
                + "JOIN ContractEquipment ce ON c.contractId = ce.contractId "
                + "WHERE ce.equipmentId = ? AND c.customerId = ? "
                + "ORDER BY c.contractId DESC LIMIT 1";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, equipmentId);
            ps.setInt(2, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("contractId");
                }
            }
        }
        return null;
    }

    public String getContractType(int contractId) throws SQLException {
        String sql = "SELECT contractType FROM Contract WHERE contractId = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, contractId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("contractType");
                }
            }
        }
        return null;
    }

    public String getContractStatus(int contractId) throws SQLException {
        String sql = "SELECT status FROM Contract WHERE contractId = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, contractId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("status");
                }
            }
        }
        return null;
    }

    public List<Contract> getAllContractsPaged(int offset, int limit) throws SQLException {
        List<Contract> list = new ArrayList<>();
        String sql = """
        SELECT 
            c.contractId, 
            c.customerId, 
            c.contractDate, 
            c.contractType, 
            c.status, 
            c.details,
            c.FileAttachment,
            a.fullName AS customerName, 
            a.email AS customerEmail, 
            a.phone AS customerPhone,
            -- ✅ Đếm cả request từ thiết bị trong phụ lục
            (
                SELECT COUNT(DISTINCT sr.requestId)
                FROM ServiceRequest sr
                LEFT JOIN Equipment e ON sr.equipmentId = e.equipmentId
                WHERE sr.contractId = c.contractId
                    OR EXISTS (
                        SELECT 1 
                        FROM ContractAppendixEquipment cae
                        JOIN ContractAppendix ca ON cae.appendixId = ca.appendixId
                        WHERE cae.equipmentId = sr.equipmentId
                        AND ca.contractId = c.contractId
                    )
            ) AS requestCount
        FROM Contract c
        LEFT JOIN Account a ON c.customerId = a.accountId
        ORDER BY c.contractDate DESC
        LIMIT ? OFFSET ?
    """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, limit);
            ps.setInt(2, offset);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Contract c = new Contract();
                    c.setContractId(rs.getInt("contractId"));
                    c.setCustomerId(rs.getInt("customerId"));
                    c.setCustomerName(rs.getString("customerName"));
                    c.setCustomerEmail(rs.getString("customerEmail"));
                    c.setCustomerPhone(rs.getString("customerPhone"));
                    c.setContractDate(rs.getDate("contractDate").toLocalDate());
                    c.setContractType(rs.getString("contractType"));
                    c.setStatus(rs.getString("status"));
                    c.setDetails(rs.getString("details"));
                    c.setFileAttachment(rs.getString("FileAttachment"));
                    c.setRequestCount(rs.getInt("requestCount"));
                    list.add(c);
                }
            }
        }
        return list;
    }

    public int countAllContracts() throws SQLException {
        String sql = "SELECT COUNT(*) FROM Contract";
        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }

    public List<Contract> filterContractsPaged(String keyword, String status, String contractType,
            String fromDate, String toDate,
            int offset, int limit) throws SQLException {
        List<Contract> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("""
        SELECT 
            c.contractId, 
            c.customerId, 
            c.contractDate, 
            c.contractType, 
            c.status, 
            c.details,
            c.FileAttachment,
            a.fullName AS customerName, 
            a.email AS customerEmail, 
            a.phone AS customerPhone,
            -- ✅ Đếm cả request từ thiết bị trong phụ lục
            (
                SELECT COUNT(DISTINCT sr.requestId)
                FROM ServiceRequest sr
                LEFT JOIN Equipment e ON sr.equipmentId = e.equipmentId
                WHERE sr.contractId = c.contractId
                    OR EXISTS (
                        SELECT 1 
                        FROM ContractAppendixEquipment cae
                        JOIN ContractAppendix ca ON cae.appendixId = ca.appendixId
                        WHERE cae.equipmentId = sr.equipmentId
                        AND ca.contractId = c.contractId
                    )
            ) AS requestCount
        FROM Contract c
        LEFT JOIN Account a ON c.customerId = a.accountId
        WHERE 1=1
    """);

        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.isEmpty()) {
            sql.append(" AND (a.fullName LIKE ? OR a.phone LIKE ? OR a.email LIKE ? OR c.details LIKE ?)");
            String like = "%" + keyword + "%";
            params.add(like);
            params.add(like);
            params.add(like);
            params.add(like);
        }
        if (status != null && !status.isEmpty()) {
            sql.append(" AND c.status = ?");
            params.add(status);
        }
        if (contractType != null && !contractType.isEmpty()) {
            sql.append(" AND c.contractType = ?");
            params.add(contractType);
        }
        if (fromDate != null && !fromDate.isEmpty()) {
            sql.append(" AND DATE(c.contractDate) >= ?");
            params.add(fromDate);
        }
        if (toDate != null && !toDate.isEmpty()) {
            sql.append(" AND DATE(c.contractDate) <= ?");
            params.add(toDate);
        }

        sql.append("""
        ORDER BY c.contractDate DESC
        LIMIT ? OFFSET ?
    """);

        params.add(limit);
        params.add(offset);

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Contract c = new Contract();
                    c.setContractId(rs.getInt("contractId"));
                    c.setCustomerId(rs.getInt("customerId"));
                    c.setCustomerName(rs.getString("customerName"));
                    c.setCustomerEmail(rs.getString("customerEmail"));
                    c.setCustomerPhone(rs.getString("customerPhone"));
                    c.setContractDate(rs.getDate("contractDate").toLocalDate());
                    c.setContractType(rs.getString("contractType"));
                    c.setStatus(rs.getString("status"));
                    c.setDetails(rs.getString("details"));
                    c.setFileAttachment(rs.getString("FileAttachment"));
                    c.setRequestCount(rs.getInt("requestCount"));
                    list.add(c);
                }
            }
        }
        return list;
    }

    public int countFilteredContracts(String keyword, String status, String contractType,
            String fromDate, String toDate) throws SQLException {
        StringBuilder sql = new StringBuilder("""
        SELECT COUNT(DISTINCT c.contractId)
        FROM Contract c
        LEFT JOIN Account a ON c.customerId = a.accountId
        LEFT JOIN ServiceRequest sr ON c.contractId = sr.contractId
        WHERE 1=1
    """);

        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.isEmpty()) {
            sql.append(" AND (a.fullName LIKE ? OR a.phone LIKE ? OR a.email LIKE ? OR c.details LIKE ?)");
            String like = "%" + keyword + "%";
            params.add(like);
            params.add(like);
            params.add(like);
            params.add(like);
        }
        if (status != null && !status.isEmpty()) {
            sql.append(" AND c.status = ?");
            params.add(status);
        }
        if (contractType != null && !contractType.isEmpty()) {
            sql.append(" AND c.contractType = ?");
            params.add(contractType);
        }
        if (fromDate != null && !fromDate.isEmpty()) {
            sql.append(" AND DATE(c.contractDate) >= ?");
            params.add(fromDate);
        }
        if (toDate != null && !toDate.isEmpty()) {
            sql.append(" AND DATE(c.contractDate) <= ?");
            params.add(toDate);
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
        }

        return 0;
    }

    // ✅ Tạo hợp đồng mới
    public int createContractByCSS(int customerId, LocalDate contractDate, String contractType,
            String status, String details) throws SQLException {

        String sql = "INSERT INTO Contract (customerId, contractDate, contractType, status, details) "
                + "VALUES (?, ?, ?, ?, ?)";

        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, customerId);
            ps.setDate(2, java.sql.Date.valueOf(contractDate));
            ps.setString(3, contractType);
            ps.setString(4, status);
            ps.setString(5, details);

            ps.executeUpdate();

            ResultSet rs = ps.getGeneratedKeys();
            if (rs.next()) {
                return rs.getInt(1);
            }
        }

        return 0;
    }

    // Thêm thiết bị vào hợp đồng
    public boolean addEquipmentToContract(int contractId, int equipmentId,
            LocalDate contractDate) throws SQLException {
        String sql = """
        INSERT INTO ContractEquipment (contractId, equipmentId, startDate, endDate, quantity, price)
        VALUES (?, ?, ?, DATE_ADD(?, INTERVAL 3 YEAR), 1, 0.0)
    """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, contractId);
            ps.setInt(2, equipmentId);
            ps.setDate(3, java.sql.Date.valueOf(contractDate)); // startDate
            ps.setDate(4, java.sql.Date.valueOf(contractDate)); // endDate = startDate + 3 years

            int rows = ps.executeUpdate();
            System.out.println(" Added equipment " + equipmentId + " to contract " + contractId
                    + " (startDate: " + contractDate + ", endDate: " + contractDate.plusYears(3) + ")");
            return rows > 0;
        }
    }

    // Kiểm tra xem hợp đồng có thể xóa không
// Điều kiện:
// 1. Hợp đồng được tạo trong vòng 15 ngày
// 2. Không có phụ lục nào
// 3. KHÔNG có ServiceRequest nào NGOÀI trạng thái Pending/Cancelled
//    (tức là không có request đang được xử lý: Awaiting Approval, Approved, Completed)
    public boolean canDeleteContract(int contractId) throws SQLException {
        String sql = """
    SELECT 
        CASE 
            WHEN c.createdDate IS NULL THEN DATEDIFF(NOW(), c.contractDate) <= 15 
            ELSE DATEDIFF(NOW(), c.createdDate) <= 15 
        END AS withinPeriod,
        COUNT(DISTINCT ca.appendixId) AS appendixCount,
        COUNT(DISTINCT sr.requestId) AS totalRequestCount,
        COUNT(DISTINCT CASE 
            WHEN sr.status NOT IN ('Pending', 'Cancelled') AND sr.status IS NOT NULL 
            THEN sr.requestId 
            ELSE NULL 
        END) AS activeRequestCount
    FROM Contract c
    LEFT JOIN ContractAppendix ca ON c.contractId = ca.contractId
    LEFT JOIN ContractEquipment ce ON c.contractId = ce.contractId
    LEFT JOIN ServiceRequest sr ON ce.equipmentId = sr.equipmentId
    WHERE c.contractId = ?
    GROUP BY c.contractId, c.createdDate, c.contractDate
    """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, contractId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    boolean withinPeriod = rs.getBoolean("withinPeriod");
                    int appendixCount = rs.getInt("appendixCount");
                    int totalRequestCount = rs.getInt("totalRequestCount");
                    int activeRequestCount = rs.getInt("activeRequestCount");

                    System.out.println("=== CAN DELETE CONTRACT CHECK ===");
                    System.out.println("Contract ID: " + contractId);
                    System.out.println("Within 15 days: " + withinPeriod);
                    System.out.println("Appendix Count: " + appendixCount);
                    System.out.println("Total Request Count: " + totalRequestCount);
                    System.out.println("Active Request Count (not Pending/Cancelled): " + activeRequestCount);

                    boolean canDelete = withinPeriod
                            && appendixCount == 0
                            && activeRequestCount == 0;

                    System.out.println("Can Delete: " + canDelete);
                    System.out.println("================================");
                    return canDelete;
                }
            }
        }
        return false;
    }

// Xóa hợp đồng (soft delete - chuyển trạng thái thành Cancelled)
    public boolean deleteContract(int contractId, String cancelReason, int cancelledBy) throws SQLException {
        String sql = """
        UPDATE Contract
        SET status = 'Deleted',
            cancelReason = ?,
            cancelledBy = ?,
            cancelledDate = NOW()
        WHERE contractId = ?
    """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, cancelReason);
            ps.setInt(2, cancelledBy);
            ps.setInt(3, contractId);

            int updated = ps.executeUpdate();
            System.out.println("✅ Contract " + contractId + " cancelled: " + (updated > 0));
            return updated > 0;
        }
    }

// Xóa vĩnh viễn hợp đồng (hard delete - chỉ dùng khi thực sự cần)
    public boolean hardDeleteContract(int contractId) throws SQLException {
        try {
            connection.setAutoCommit(false);

            System.out.println("=== HARD DELETE CONTRACT " + contractId + " ===");

            //Xóa các ServiceRequest có status Pending hoặc Cancelled
            String deleteRequests = """
            DELETE sr 
            FROM ServiceRequest sr
            INNER JOIN ContractEquipment ce ON sr.equipmentId = ce.equipmentId
            WHERE ce.contractId = ?
              AND sr.status IN ('Pending', 'Cancelled')
        """;
            try (PreparedStatement ps = connection.prepareStatement(deleteRequests)) {
                ps.setInt(1, contractId);
                int requestsDeleted = ps.executeUpdate();
                System.out.println("✓ Deleted " + requestsDeleted + " Pending/Cancelled service requests");
            }

            //Xóa ContractEquipment (do ràng buộc khóa ngoại)
            String deleteEquipment = """
            DELETE FROM ContractEquipment WHERE contractId = ?
        """;
            try (PreparedStatement ps = connection.prepareStatement(deleteEquipment)) {
                ps.setInt(1, contractId);
                int equipmentDeleted = ps.executeUpdate();
                System.out.println("✓ Deleted " + equipmentDeleted + " equipment records");
            }

            // Xóa Contract
            String deleteContract = """
            DELETE FROM Contract WHERE contractId = ?
        """;
            try (PreparedStatement ps = connection.prepareStatement(deleteContract)) {
                ps.setInt(1, contractId);
                int contractDeleted = ps.executeUpdate();

                if (contractDeleted > 0) {
                    connection.commit();
                    System.out.println("Hard delete successful for contract " + contractId);
                    return true;
                } else {
                    connection.rollback();
                    System.out.println("Contract not found or already deleted");
                    return false;
                }
            }

        } catch (SQLException e) {
            System.err.println("✗ Error during hard delete:");
            e.printStackTrace();
            connection.rollback();
            throw e;
        } finally {
            connection.setAutoCommit(true);
        }
    }

    public Map<String, Object> getContractDeletionInfo(int contractId) throws SQLException {
        String sql = """
        SELECT 
            COUNT(DISTINCT sr.requestId) AS totalRequests,
            COUNT(DISTINCT CASE WHEN sr.status = 'Pending' THEN sr.requestId END) AS pendingRequests,
            COUNT(DISTINCT CASE WHEN sr.status = 'Cancelled' THEN sr.requestId END) AS cancelledRequests,
            COUNT(DISTINCT CASE WHEN sr.status NOT IN ('Pending', 'Cancelled') THEN sr.requestId END) AS activeRequests
        FROM Contract c
        LEFT JOIN ContractEquipment ce ON c.contractId = ce.contractId
        LEFT JOIN ServiceRequest sr ON ce.equipmentId = sr.equipmentId
        WHERE c.contractId = ?
    """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, contractId);

            try (ResultSet rs = ps.executeQuery()) {
                Map<String, Object> info = new HashMap<>();
                if (rs.next()) {
                    info.put("totalRequests", rs.getInt("totalRequests"));
                    info.put("pendingRequests", rs.getInt("pendingRequests"));
                    info.put("cancelledRequests", rs.getInt("cancelledRequests"));
                    info.put("activeRequests", rs.getInt("activeRequests"));
                }
                return info;
            }
        }
    }

    // Tạo hợp đồng mới với createdDate = NOW()
    public int createContractWithCreatedDate(int customerId, LocalDate contractDate,
            String contractType, String status, String details) throws SQLException {

        String sql = """
        INSERT INTO Contract (customerId, contractDate, contractType, status, details, createdDate)
        VALUES (?, ?, ?, ?, ?, NOW())
    """;

        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, customerId);
            ps.setDate(2, java.sql.Date.valueOf(contractDate));
            ps.setString(3, contractType);
            ps.setString(4, status);
            ps.setString(5, details);
            int affectedRows = ps.executeUpdate();

            if (affectedRows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        int newId = rs.getInt(1);
                        System.out.println("✅ Created new contract ID: " + newId);
                        return newId;
                    }
                }
            }

            System.out.println("⚠️ Failed to create contract for customerId: " + customerId);
            return -1;
        }
    }

    /**
     * Lấy contractId từ equipment (kiểm tra cả contract chính và appendix)
     *
     * @param equipmentId ID của thiết bị
     * @param customerId ID của khách hàng
     * @return contractId hoặc null nếu không tìm thấy
     */
    public Integer getContractIdForEquipment(int equipmentId, int customerId) throws SQLException {
        // ✅ Bước 1: Kiểm tra trong ContractEquipment (hợp đồng chính)
        Integer contractId = getContractIdByEquipmentAndCustomer(equipmentId, customerId);

        if (contractId != null) {
            System.out.println("✅ Equipment " + equipmentId + " found in main contract: " + contractId);
            return contractId;
        }

        // ✅ Bước 2: Kiểm tra trong ContractAppendixEquipment (phụ lục)
        String sql = """
        SELECT ca.contractId
        FROM ContractAppendixEquipment cae
        JOIN ContractAppendix ca ON cae.appendixId = ca.appendixId
        JOIN Contract c ON ca.contractId = c.contractId
        WHERE cae.equipmentId = ?
          AND c.customerId = ?
          AND ca.status = 'Approved'
        LIMIT 1
    """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, equipmentId);
            ps.setInt(2, customerId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int appendixContractId = rs.getInt("contractId");
                    System.out.println("✅ Equipment " + equipmentId + " found in appendix of contract: " + appendixContractId);
                    return appendixContractId;
                }
            }
        } catch (SQLException e) {
            System.err.println("❌ Error checking appendix equipment: " + e.getMessage());
            throw e;
        }

        System.out.println("⚠️ Equipment " + equipmentId + " not found in any contract for customer " + customerId);
        return null;
    }

    // Tạo hợp đồng mới với createdDate = NOW() và fileAttachment
    public int createContractWithCreatedDate(int customerId, LocalDate contractDate,
            String contractType, String status, String details, String fileUrl) throws SQLException {
        String sql = """
        INSERT INTO Contract (customerId, contractDate, contractType, status, details, fileAttachment, createdDate)
        VALUES (?, ?, ?, ?, ?, ?, NOW())
    """;
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, customerId);
            ps.setDate(2, java.sql.Date.valueOf(contractDate));
            ps.setString(3, contractType);
            ps.setString(4, status);
            ps.setString(5, details);
            ps.setString(6, fileUrl);

            int affectedRows = ps.executeUpdate();
            if (affectedRows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        int newId = rs.getInt(1);
                        System.out.println("✅ Created new contract ID: " + newId + " with file: " + fileUrl);
                        return newId;
                    }
                }
            }
            System.out.println("⚠️ Failed to create contract for customerId: " + customerId);
            return -1;
        }
    }

    /**
     * Count contracts by status
     */
    public int countByStatus(String status) throws SQLException {
        String sql = "SELECT COUNT(*) FROM Contract WHERE Status = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    /**
     * Count total service requests from all contracts
     */
    public int countTotalServiceRequests() throws SQLException {
        String sql = "SELECT COUNT(*) FROM ServiceRequest";
        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }

    public Map<String, Object> getCustomerWithMostContracts() throws SQLException {
        String sql = "SELECT "
                + "a.accountId, "
                + "a.fullName, "
                + "COUNT(DISTINCT c.contractId) AS contractCount, "
                + "( "
                + "    SELECT COUNT(DISTINCT equipmentId) "
                + "    FROM ( "
                + "        SELECT ce2.equipmentId "
                + "        FROM Contract c2 "
                + "        LEFT JOIN ContractEquipment ce2 ON c2.contractId = ce2.contractId "
                + "        WHERE c2.customerId = a.accountId AND ce2.equipmentId IS NOT NULL "
                + "        UNION "
                + "        SELECT cae2.equipmentId "
                + "        FROM Contract c3 "
                + "        LEFT JOIN ContractAppendix ca2 ON c3.contractId = ca2.contractId "
                + "        LEFT JOIN ContractAppendixEquipment cae2 ON ca2.appendixId = cae2.appendixId "
                + "        WHERE c3.customerId = a.accountId AND cae2.equipmentId IS NOT NULL "
                + "    ) AS allEquipments "
                + ") AS totalEquipmentCount "
                + "FROM Account a "
                + "INNER JOIN Contract c ON a.accountId = c.customerId "
                + "GROUP BY a.accountId, a.fullName "
                + "ORDER BY contractCount DESC, totalEquipmentCount DESC "
                + "LIMIT 1";

        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                Map<String, Object> customer = new HashMap<>();
                customer.put("accountId", rs.getInt("accountId"));
                customer.put("fullName", rs.getString("fullName"));
                customer.put("contractCount", rs.getInt("contractCount"));
                customer.put("totalEquipmentCount", rs.getInt("totalEquipmentCount")); // Thêm trường này
                return customer;
            }
        }

        // Nếu không có hợp đồng nào
        Map<String, Object> emptyResult = new HashMap<>();
        emptyResult.put("accountId", 0);
        emptyResult.put("fullName", "Chưa có");
        emptyResult.put("contractCount", 0);
        emptyResult.put("totalEquipmentCount", 0);
        return emptyResult;
    }

    public List<Contract> getContractsByCustomerId(int customerId) throws SQLException {
        List<Contract> contracts = new ArrayList<>();

        String sql = """
        SELECT 
            c.contractId,
            c.customerId,
            c.contractDate,
            c.contractType,
            c.status,
            c.details,
            c.fileAttachment
        FROM Contract c
        WHERE c.customerId = ?
        ORDER BY c.contractDate DESC
    """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, customerId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Contract contract = new Contract();
                    contract.setContractId(rs.getInt("contractId"));
                    contract.setCustomerId(rs.getInt("customerId"));

                    Date contractDate = rs.getDate("contractDate");
                    if (contractDate != null) {
                        contract.setContractDate(contractDate.toLocalDate());
                    }

                    contract.setContractType(rs.getString("contractType"));
                    contract.setStatus(rs.getString("status"));
                    contract.setDetails(rs.getString("details"));
                    contract.setFileAttachment(rs.getString("fileAttachment"));

                    contracts.add(contract);
                }
            }
        }

        System.out.println("✅ getContractsByCustomerId: Found " + contracts.size() + " contracts for customer " + customerId);
        return contracts;
    }

    /**
     * ✅ Lấy danh sách thiết bị của một hợp đồng (bao gồm cả thiết bị từ phụ
     * lục)
     */
    public List<Map<String, Object>> getEquipmentByContractId(int contractId) throws SQLException {
        List<Map<String, Object>> equipmentList = new ArrayList<>();

        String sql = """
        SELECT 
            e.equipmentId,
            e.serialNumber,
            e.model,
            e.description,
            ce.startDate,
            ce.endDate,
            ce.quantity,
            ce.price,
            CASE 
                WHEN ce.endDate IS NULL OR ce.endDate >= CURDATE() THEN 'Active'
                WHEN ce.endDate < CURDATE() THEN 'Expired'
                ELSE 'Pending'
            END AS status,
            'Contract' AS source
        FROM ContractEquipment ce
        JOIN Equipment e ON ce.equipmentId = e.equipmentId
        WHERE ce.contractId = ?
        
        UNION ALL
        
        SELECT 
            e.equipmentId,
            e.serialNumber,
            e.model,
            e.description,
            cae.startDate,
            cae.endDate,
            1 AS quantity,
            0 AS price,
            CASE 
                WHEN cae.endDate IS NULL OR cae.endDate >= CURDATE() THEN 'Active'
                WHEN cae.endDate < CURDATE() THEN 'Expired'
                ELSE 'Pending'
            END AS status,
            'Appendix' AS source
        FROM ContractAppendix ca
        JOIN ContractAppendixEquipment cae ON ca.appendixId = cae.appendixId
        JOIN Equipment e ON cae.equipmentId = e.equipmentId
        WHERE ca.contractId = ?
          AND ca.status = 'Approved'
        
        ORDER BY startDate DESC
    """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, contractId);
            ps.setInt(2, contractId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> equipment = new HashMap<>();
                    equipment.put("equipmentId", rs.getInt("equipmentId"));
                    equipment.put("serialNumber", rs.getString("serialNumber"));
                    equipment.put("model", rs.getString("model"));
                    equipment.put("description", rs.getString("description"));

                    Date startDate = rs.getDate("startDate");
                    equipment.put("startDate", startDate != null ? startDate.toString() : null);

                    Date endDate = rs.getDate("endDate");
                    equipment.put("endDate", endDate != null ? endDate.toString() : null);

                    equipment.put("quantity", rs.getInt("quantity"));
                    equipment.put("price", rs.getBigDecimal("price"));
                    equipment.put("status", rs.getString("status"));
                    equipment.put("source", rs.getString("source"));

                    equipmentList.add(equipment);
                }
            }
        } catch (SQLException e) {
            System.err.println("❌ Error getting equipment for contract " + contractId + ": " + e.getMessage());
            throw e;
        }

        System.out.println("✅ Found " + equipmentList.size() + " equipment items for contract " + contractId);
        return equipmentList;
    }

    /**
     * Đếm tổng số hợp đồng trong hệ thống
     */
    public int getTotalContractCount() {
        String sql = "SELECT COUNT(*) FROM Contract";

        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("❌ Error counting contracts: " + e.getMessage());
            e.printStackTrace();
        }

        return 0;
    }

    /**
     * Lấy khách hàng có nhiều hợp đồng nhất
     */
    public Map<String, Object> getTopCustomer() {
        String sql = "SELECT TOP 1 a.accountId, a.fullName, COUNT(c.contractId) as contractCount "
                + "FROM Account a "
                + "INNER JOIN Contract c ON a.accountId = c.customerId "
                + "GROUP BY a.accountId, a.fullName "
                + "ORDER BY contractCount DESC";

        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                Map<String, Object> customer = new HashMap<>();
                customer.put("accountId", rs.getInt("accountId"));
                customer.put("fullName", rs.getString("fullName"));
                customer.put("contractCount", rs.getInt("contractCount"));
                return customer;
            }
        } catch (SQLException e) {
            System.err.println("❌ Error getting top customer: " + e.getMessage());
            e.printStackTrace();
        }

        return null;
    }

}
