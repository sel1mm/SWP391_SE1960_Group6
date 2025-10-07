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
}