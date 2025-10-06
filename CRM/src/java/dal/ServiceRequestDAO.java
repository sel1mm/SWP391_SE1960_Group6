package dal;

import model.ServiceRequest;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ServiceRequestDAO extends MyDAO {
    
    // ============ VALIDATION METHODS ============
    
    /**
     * Kiểm tra contractId có tồn tại và thuộc về customer không
     */
    public boolean isValidContract(int contractId, int customerId) {
        xSql = "SELECT contractId FROM Contract WHERE contractId = ? AND customerId = ? AND status = 'Active'";
        try {
            ps = con.prepareStatement(xSql);
            ps.setInt(1, contractId);
            ps.setInt(2, customerId);
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
     * Kiểm tra equipmentId có tồn tại không
     */
    public boolean isValidEquipment(int equipmentId) {
        xSql = "SELECT equipmentId FROM Equipment WHERE equipmentId = ?";
        try {
            ps = con.prepareStatement(xSql);
            ps.setInt(1, equipmentId);
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
     * Kiểm tra equipment có trong contract không
     */
    public boolean isEquipmentInContract(int contractId, int equipmentId) {
        xSql = "SELECT contractEquipmentId FROM ContractEquipment " +
               "WHERE contractId = ? AND equipmentId = ?";
        try {
            ps = con.prepareStatement(xSql);
            ps.setInt(1, contractId);
            ps.setInt(2, equipmentId);
            rs = ps.executeQuery();
            return rs.next();
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            closeResources();
        }
    }
    
    // ============ CREATE METHOD ============
    
    /**
     * Tạo service request mới
     * @return requestId nếu thành công, -1 nếu thất bại
     */
    public int createServiceRequest(ServiceRequest request) {
        xSql = "INSERT INTO ServiceRequest (contractId, equipmentId, createdBy, description, " +
               "priorityLevel, requestDate, status, requestType) " +
               "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try {
            ps = con.prepareStatement(xSql, Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, request.getContractId());
            ps.setInt(2, request.getEquipmentId());
            ps.setInt(3, request.getCreatedBy());
            ps.setString(4, request.getDescription());
            ps.setString(5, request.getPriorityLevel());
            ps.setDate(6, new java.sql.Date(request.getRequestDate().getTime()));
            ps.setString(7, request.getStatus());
            ps.setString(8, request.getRequestType());
            
            int affectedRows = ps.executeUpdate();
            
            if (affectedRows > 0) {
                rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    return rs.getInt(1); // Trả về requestId vừa tạo
                }
            }
            return -1;
        } catch (Exception e) {
            e.printStackTrace();
            return -1;
        } finally {
            closeResources();
        }
    }
    
    // ============ READ METHODS ============
    
    /**
     * Lấy tất cả service requests của một customer
     */
    public List<ServiceRequest> getRequestsByCustomerId(int customerId) {
        List<ServiceRequest> list = new ArrayList<>();
        xSql = "SELECT sr.* FROM ServiceRequest sr " +
               "INNER JOIN Contract c ON sr.contractId = c.contractId " +
               "WHERE c.customerId = ? " +
               "ORDER BY sr.requestDate DESC";
        try {
            ps = con.prepareStatement(xSql);
            ps.setInt(1, customerId);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToServiceRequest(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return list;
    }
    
    /**
     * Lấy service request theo ID
     */
    public ServiceRequest getRequestById(int requestId) {
        xSql = "SELECT * FROM ServiceRequest WHERE requestId = ?";
        try {
            ps = con.prepareStatement(xSql);
            ps.setInt(1, requestId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapResultSetToServiceRequest(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return null;
    }
    
    /**
     * Tìm kiếm theo keyword (description hoặc requestId)
     */
    public List<ServiceRequest> searchRequests(int customerId, String keyword) {
        List<ServiceRequest> list = new ArrayList<>();
        xSql = "SELECT sr.* FROM ServiceRequest sr " +
               "INNER JOIN Contract c ON sr.contractId = c.contractId " +
               "WHERE c.customerId = ? " +
               "AND (sr.description LIKE ? OR sr.requestId LIKE ?) " +
               "ORDER BY sr.requestDate DESC";
        try {
            ps = con.prepareStatement(xSql);
            ps.setInt(1, customerId);
            ps.setString(2, "%" + keyword + "%");
            ps.setString(3, "%" + keyword + "%");
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToServiceRequest(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return list;
    }
    
    /**
     * Lọc theo status
     */
    public List<ServiceRequest> filterRequestsByStatus(int customerId, String status) {
        List<ServiceRequest> list = new ArrayList<>();
        xSql = "SELECT sr.* FROM ServiceRequest sr " +
               "INNER JOIN Contract c ON sr.contractId = c.contractId " +
               "WHERE c.customerId = ? AND sr.status = ? " +
               "ORDER BY sr.requestDate DESC";
        try {
            ps = con.prepareStatement(xSql);
            ps.setInt(1, customerId);
            ps.setString(2, status);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToServiceRequest(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return list;
    }
    
    // ============ STATISTICS METHODS ============
    
    /**
     * Đếm tổng số requests của customer
     */
    public int getTotalRequests(int customerId) {
        xSql = "SELECT COUNT(*) FROM ServiceRequest sr " +
               "INNER JOIN Contract c ON sr.contractId = c.contractId " +
               "WHERE c.customerId = ?";
        return getCount(customerId);
    }
    
    /**
     * Đếm số requests theo status
     */
    public int getRequestCountByStatus(int customerId, String status) {
        xSql = "SELECT COUNT(*) FROM ServiceRequest sr " +
               "INNER JOIN Contract c ON sr.contractId = c.contractId " +
               "WHERE c.customerId = ? AND sr.status = ?";
        try {
            ps = con.prepareStatement(xSql);
            ps.setInt(1, customerId);
            ps.setString(2, status);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return 0;
    }
    
    // ============ HELPER METHODS ============
    
    private int getCount(int customerId) {
        try {
            ps = con.prepareStatement(xSql);
            ps.setInt(1, customerId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return 0;
    }
    
    /**
     * Map ResultSet thành ServiceRequest object
     */
    private ServiceRequest mapResultSetToServiceRequest(ResultSet rs) throws SQLException {
        ServiceRequest sr = new ServiceRequest();
        sr.setRequestId(rs.getInt("requestId"));
        sr.setContractId(rs.getInt("contractId"));
        sr.setEquipmentId(rs.getInt("equipmentId"));
        sr.setCreatedBy(rs.getInt("createdBy"));
        sr.setDescription(rs.getString("description"));
        sr.setPriorityLevel(rs.getString("priorityLevel"));
        sr.setRequestDate(rs.getDate("requestDate"));
        sr.setStatus(rs.getString("status"));
        sr.setRequestType(rs.getString("requestType"));
        return sr;
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