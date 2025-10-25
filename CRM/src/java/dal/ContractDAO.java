package dal;

import model.Contract;
import model.EquipmentWithStatus;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO for Contract operations.
 * Updated to work with the final database schema.
 */
public class ContractDAO extends MyDAO {
    
    public static class ContractWithCustomer {
        public Contract contract;
        public String customerName;
        
        public Contract getContract() { return contract; }
        public String getCustomerName() { return customerName; }
    }

    public static class Customer {
        public int accountId;
        public String fullName;
        public String email;
        
        public int getAccountId() { return accountId; }
        public String getFullName() { return fullName; }
        public String getEmail() { return email; }
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
        xSql = "SELECT a.fullName FROM Contract c " +
               "INNER JOIN Account a ON c.customerId = a.accountId " +
               "WHERE c.contractId = ?";
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
        xSql = "SELECT contractId FROM Contract " +
               "WHERE contractId = ? AND status = 'Active'";
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
        String sql = "SELECT DISTINCT a.accountId, a.fullName, a.email " +
                     "FROM Account a " +
                     "JOIN ServiceRequest sr ON a.accountId = sr.createdBy " +
                     "JOIN WorkTask wt ON sr.requestId = wt.requestId " +
                     "WHERE wt.technicianId = ? " +
                     "ORDER BY a.fullName";
        
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
        xSql = "SELECT c.contractId, c.customerId, c.contractDate, c.contractType, c.status, c.details, " +
               "a.fullName as customerName " +
               "FROM Contract c " +
               "JOIN Account a ON c.customerId = a.accountId " +
               "ORDER BY c.contractDate DESC";
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
        xSql = "INSERT INTO Contract (customerId, contractDate, contractType, status, details) " +
               "VALUES (?, ?, ?, ?, ?)";
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
            if (rs != null) rs.close();
            if (ps != null) ps.close();
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
    String sql = "SELECT contractId, details FROM Contract"; // lấy details thay cho contractName

    try (PreparedStatement ps = con.prepareStatement(sql);
         ResultSet rs = ps.executeQuery()) {

        while (rs.next()) {
            Contract c = new Contract();
            c.setContractId(rs.getInt("contractId"));
            c.setDetails(rs.getString("details")); // dùng details
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
                     "WHERE pd.status = 'Available' " +
                     "ORDER BY p.partName, pd.serialNumber";

        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

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
     * Create contract with part assignment (creates Equipment entry from PartDetail)
     */
    public long createContractWithPart(int customerId, java.sql.Date contractDate, String contractType, 
                                     String status, String details, int partDetailId) throws SQLException {
        con.setAutoCommit(false);
        
        try {
            // 1. Create the contract
            String contractSql = "INSERT INTO Contract (customerId, contractDate, contractType, status, details) " +
                                "VALUES (?, ?, ?, ?, ?)";
            
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
                // 2. Get part details
                String selectPartSql = "SELECT pd.serialNumber, p.partName, p.description, p.unitPrice " +
                                       "FROM PartDetail pd JOIN Part p ON pd.partId = p.partId WHERE pd.partDetailId = ?";
                String serialNumber = null;
                String partName = null;
                String description = null;
                double unitPrice = 0.0;
                
                try (PreparedStatement ps = con.prepareStatement(selectPartSql)) {
                    ps.setInt(1, partDetailId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            serialNumber = rs.getString("serialNumber");
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
                String insertEquipmentSql = "INSERT INTO Equipment (serialNumber, model, description, installDate, lastUpdatedBy, lastUpdatedDate) " +
                                           "VALUES (?, ?, ?, ?, ?, ?)";
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
                String contractEquipmentSql = "INSERT INTO ContractEquipment (contractId, equipmentId, startDate, quantity, price) " +
                                              "VALUES (?, ?, ?, 1, ?)";
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

        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

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
        try (PreparedStatement ps = con.prepareStatement(countSql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                System.out.println("📊 Total Equipment in database: " + rs.getInt(1));
            }
        }
        
        // Test 3: Show all equipment
        String allEquipmentSql = "SELECT equipmentId, serialNumber, model FROM Equipment ORDER BY equipmentId";
        try (PreparedStatement ps = con.prepareStatement(allEquipmentSql);
             ResultSet rs = ps.executeQuery()) {
            System.out.println("📊 All Equipment in database:");
            while (rs.next()) {
                System.out.println("  ID: " + rs.getInt("equipmentId") + 
                                 ", Serial: " + rs.getString("serialNumber") + 
                                 ", Model: " + rs.getString("model"));
            }
        }
        
        // Test 4: Count assigned equipment
        String assignedSql = "SELECT COUNT(*) FROM ContractEquipment";
        try (PreparedStatement ps = con.prepareStatement(assignedSql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                System.out.println("📊 Equipment assigned to contracts: " + rs.getInt(1));
            }
        }
        
        // Test 5: Show assigned equipment
        String assignedEquipmentSql = "SELECT ce.equipmentId, e.serialNumber, e.model FROM ContractEquipment ce JOIN Equipment e ON ce.equipmentId = e.equipmentId";
        try (PreparedStatement ps = con.prepareStatement(assignedEquipmentSql);
             ResultSet rs = ps.executeQuery()) {
            System.out.println("📊 Assigned Equipment:");
            while (rs.next()) {
                System.out.println("  ID: " + rs.getInt("equipmentId") + 
                                 ", Serial: " + rs.getString("serialNumber") + 
                                 ", Model: " + rs.getString("model"));
            }
        }
        
        // Test 6: Show available equipment
        String availableSql = "SELECT e.equipmentId, e.serialNumber, e.model " +
                             "FROM Equipment e " +
                             "LEFT JOIN ContractEquipment ce ON e.equipmentId = ce.equipmentId " +
                             "WHERE ce.equipmentId IS NULL";
        try (PreparedStatement ps = con.prepareStatement(availableSql);
             ResultSet rs = ps.executeQuery()) {
            System.out.println("📊 Available Equipment:");
            int count = 0;
            while (rs.next()) {
                count++;
                System.out.println("  " + count + ". ID: " + rs.getInt("equipmentId") + 
                                 ", Serial: " + rs.getString("serialNumber") + 
                                 ", Model: " + rs.getString("model"));
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
        String sql = "SELECT " +
                     "    e.equipmentId, " +
                     "    e.serialNumber, " +
                     "    e.model, " +
                     "    e.description, " +
                     "    e.installDate, " +
                     "    e.lastUpdatedBy, " +
                     "    e.lastUpdatedDate " +
                     "FROM Equipment e " +
                     "LEFT JOIN ContractEquipment ce ON e.equipmentId = ce.equipmentId " +
                     "WHERE ce.equipmentId IS NULL " + // Equipment not assigned to any contract
                     "ORDER BY e.model, e.serialNumber";

        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

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
        String sql = "SELECT COUNT(*) FROM Equipment e " +
                     "LEFT JOIN ContractEquipment ce ON e.equipmentId = ce.equipmentId " +
                     "WHERE e.equipmentId = ? AND ce.equipmentId IS NULL";
        
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
            String contractSql = "INSERT INTO Contract (customerId, contractDate, contractType, status, details) " +
                                "VALUES (?, ?, ?, ?, ?)";
            
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
                String contractEquipmentSql = "INSERT INTO ContractEquipment (contractId, equipmentId, startDate, quantity, price) " +
                                              "VALUES (?, ?, ?, 1, (SELECT unitPrice FROM Equipment WHERE equipmentId = ?))";
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
        String sql = "SELECT " +
                     "    c.contractId, c.customerId, c.contractDate, c.contractType, c.status, c.details, " +
                     "    a.fullName as customerName, " +
                     "    ce.contractEquipmentId, ce.equipmentId, ce.startDate, ce.endDate, ce.quantity, ce.price, " +
                     "    e.serialNumber, e.model as equipmentModel, e.description as equipmentDescription, " +
                     "    e.installDate " +
                     "FROM Contract c " +
                     "JOIN Account a ON c.customerId = a.accountId " +
                     "LEFT JOIN ContractEquipment ce ON c.contractId = ce.contractId " +
                     "LEFT JOIN Equipment e ON ce.equipmentId = e.equipmentId " +
                     "WHERE c.contractId = ?";

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
        
        public Contract getContract() { return contract; }
        public String getCustomerName() { return customerName; }
               public EquipmentWithStatus getEquipment() { return equipment; }
        public int getContractEquipmentId() { return contractEquipmentId; }
        public int getQuantity() { return quantity; }
        public java.math.BigDecimal getPrice() { return price; }
    }

}