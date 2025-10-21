package dal;

import model.Contract;
import java.sql.*;

public class ContractDAO extends MyDAO {
    
    /**
     * Lấy thông tin contract theo ID
     */
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
    
    /**
     * Lấy tên khách hàng từ contractId
     */
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
    
    /**
     * Kiểm tra contract có active không
     */
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
    
    /**
     * Map ResultSet to Contract
     * FIX: Convert java.sql.Date to LocalDate
     */
    private Contract mapResultSetToContract(ResultSet rs) throws SQLException {
        Contract contract = new Contract();
        contract.setContractId(rs.getInt("contractId"));
        contract.setCustomerId(rs.getInt("customerId"));
        
        // Fix: Convert java.sql.Date to LocalDate
        Date sqlDate = rs.getDate("contractDate");
        if (sqlDate != null) {
            contract.setContractDate(sqlDate.toLocalDate());
        }
        
        contract.setContractType(rs.getString("contractType"));
        contract.setStatus(rs.getString("status"));
        contract.setDetails(rs.getString("details"));
        return contract;
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
<<<<<<< Updated upstream
=======
    
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
>>>>>>> Stashed changes
}