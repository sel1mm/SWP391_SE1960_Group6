package dal;

import model.Contract;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

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
}