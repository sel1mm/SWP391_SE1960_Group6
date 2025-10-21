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
    
    // ============ DELETE METHOD ============
    
    /**
     * Hủy service request (chuyển status sang Cancelled)
     * Chỉ cho phép cancel khi status = Pending
     * @return true nếu thành công, false nếu thất bại
     */
    public boolean cancelServiceRequest(int requestId) {
        xSql = "UPDATE ServiceRequest SET status = 'Cancelled' " +
               "WHERE requestId = ? AND status = 'Pending'";
        try {
            ps = con.prepareStatement(xSql);
            ps.setInt(1, requestId);
            
            int affectedRows = ps.executeUpdate();
            return affectedRows > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            closeResources();
        }
    }
    
    /**
     * Kiểm tra request có thể cancel không (thuộc customer và Pending)
     */
    public boolean canCancelRequest(int requestId, int customerId) {
        xSql = "SELECT sr.requestId FROM ServiceRequest sr " +
               "INNER JOIN Contract c ON sr.contractId = c.contractId " +
               "WHERE sr.requestId = ? AND c.customerId = ? AND sr.status = 'Pending'";
        try {
            ps = con.prepareStatement(xSql);
            ps.setInt(1, requestId);
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
    
    // ============ UPDATE METHOD ============
    
    /**
     * Cập nhật service request (chỉ cho phép update description và priorityLevel)
     * @return true nếu thành công, false nếu thất bại
     */
    public boolean updateServiceRequest(int requestId, String description, String priorityLevel) {
        xSql = "UPDATE ServiceRequest SET description = ?, priorityLevel = ? " +
               "WHERE requestId = ? AND status = 'Pending'";
        try {
            ps = con.prepareStatement(xSql);
            ps.setString(1, description);
            ps.setString(2, priorityLevel);
            ps.setInt(3, requestId);
            
            int affectedRows = ps.executeUpdate();
            return affectedRows > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            closeResources();
        }
    }
    
    /**
     * Kiểm tra request có thuộc về customer và đang Pending không
     */
    public boolean canUpdateRequest(int requestId, int customerId) {
        xSql = "SELECT sr.requestId FROM ServiceRequest sr " +
               "INNER JOIN Contract c ON sr.contractId = c.contractId " +
               "WHERE sr.requestId = ? AND c.customerId = ? AND sr.status = 'Pending'";
        try {
            ps = con.prepareStatement(xSql);
            ps.setInt(1, requestId);
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
     * Lấy service request detail với đầy đủ thông tin (JOIN)
     */
    public model.ServiceRequestDetailDTO getRequestDetailById(int requestId) {
        xSql = "SELECT sr.*, " +
               "c.contractType, c.status as contractStatus, c.contractDate, " +
               "e.serialNumber, e.model as equipmentModel, e.description as equipmentDescription, " +
               "a.fullName as customerName " +
               "FROM ServiceRequest sr " +
               "INNER JOIN Contract c ON sr.contractId = c.contractId " +
               "INNER JOIN Equipment e ON sr.equipmentId = e.equipmentId " +
               "INNER JOIN Account a ON c.customerId = a.accountId " +
               "WHERE sr.requestId = ?";
        try {
            ps = con.prepareStatement(xSql);
            ps.setInt(1, requestId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapResultSetToDetailDTO(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return null;
    }
    
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
     * Đếm số requests theo status (cho customer cụ thể)
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

    /**
     * Đếm số requests theo status (toàn bộ hệ thống - cho Technical Manager)
     */
    public int getRequestCountByStatus(String status) {
        xSql = "SELECT COUNT(*) FROM ServiceRequest WHERE status = ?";
        try {
            ps = con.prepareStatement(xSql);
            ps.setString(1, status);
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
     * Map ResultSet thành ServiceRequestDetailDTO
     * FIX: Convert java.sql.Date to LocalDate for Contract and Equipment
     */
    private model.ServiceRequestDetailDTO mapResultSetToDetailDTO(ResultSet rs) throws SQLException {
        model.ServiceRequestDetailDTO dto = new model.ServiceRequestDetailDTO();
        // ServiceRequest info
        dto.setRequestId(rs.getInt("requestId"));
        dto.setContractId(rs.getInt("contractId"));
        dto.setEquipmentId(rs.getInt("equipmentId"));
        dto.setCreatedBy(rs.getInt("createdBy"));
        dto.setDescription(rs.getString("description"));
        dto.setPriorityLevel(rs.getString("priorityLevel"));
        dto.setRequestDate(rs.getDate("requestDate"));
        dto.setStatus(rs.getString("status"));
        dto.setRequestType(rs.getString("requestType"));
        
        // Contract info
        dto.setContractType(rs.getString("contractType"));
        dto.setContractStatus(rs.getString("contractStatus"));
        
        // Fix: Convert contractDate to LocalDate
        java.sql.Date contractDate = rs.getDate("contractDate");
        if (contractDate != null) {
            dto.setContractDate(contractDate.toLocalDate());
        }
        
        // Equipment info
        dto.setSerialNumber(rs.getString("serialNumber"));
        dto.setEquipmentModel(rs.getString("equipmentModel"));
        dto.setEquipmentDescription(rs.getString("equipmentDescription"));
        
        // Customer info
        dto.setCustomerName(rs.getString("customerName"));
        
        return dto;
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

    // ============ TECHNICAL MANAGER METHODS ============

    /**
     * Get all pending requests for Technical Manager approval
     */
    public List<ServiceRequest> getPendingRequestsForApproval() {
        List<ServiceRequest> list = new ArrayList<>();
        xSql = "SELECT sr.* FROM ServiceRequest sr WHERE sr.status = 'Pending' ORDER BY sr.priorityLevel DESC, sr.requestDate ASC";
        try {
            ps = con.prepareStatement(xSql);
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
     * Search pending requests for Technical Manager
     */
    public List<ServiceRequest> searchPendingRequests(String keyword) {
        List<ServiceRequest> list = new ArrayList<>();
        xSql = "SELECT sr.* FROM ServiceRequest sr " +
                "INNER JOIN Account a ON sr.createdBy = a.accountId " +
                "WHERE sr.status = 'Pending' " +
                "AND (sr.description LIKE ? OR a.fullName LIKE ? OR sr.requestId LIKE ?) " +
                "ORDER BY sr.priorityLevel DESC, sr.requestDate ASC";
        try {
            ps = con.prepareStatement(xSql);
            ps.setString(1, "%" + keyword + "%");
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
     * Filter pending requests by priority and urgency
     */
    public List<ServiceRequest> filterPendingRequests(String priority, String urgency) {
        List<ServiceRequest> list = new ArrayList<>();

        StringBuilder sqlBuilder = new StringBuilder(
            "SELECT sr.* FROM ServiceRequest sr WHERE sr.status = 'Pending'"
        );

        List<String> conditions = new ArrayList<>();

        if (priority != null && !priority.trim().isEmpty()) {
            conditions.add("sr.priorityLevel = '" + priority + "'");
        }

        if (urgency != null && !urgency.trim().isEmpty()) {
            if ("Urgent".equals(urgency)) {
                conditions.add("DATEDIFF(CURRENT_DATE, sr.requestDate) >= 7");
            } else if ("High".equals(urgency)) {
                conditions.add("DATEDIFF(CURRENT_DATE, sr.requestDate) >= 3");
            } else if ("Normal".equals(urgency)) {
                conditions.add("DATEDIFF(CURRENT_DATE, sr.requestDate) < 3");
            }
        }

        if (!conditions.isEmpty()) {
            sqlBuilder.append(" AND ").append(String.join(" AND ", conditions));
        }

        sqlBuilder.append(" ORDER BY sr.priorityLevel DESC, sr.requestDate ASC");

        xSql = sqlBuilder.toString();
        try {
            ps = con.prepareStatement(xSql);
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
     * Update service request status (for Technical Manager)
     */
    public boolean updateServiceRequestStatus(int requestId, String newStatus, String managerNotes) {
        xSql = "UPDATE ServiceRequest SET status = ?, managerNotes = ?, lastReviewedAt = NOW() WHERE requestId = ? AND status = 'Pending'";
        try {
            ps = con.prepareStatement(xSql);
            ps.setString(1, newStatus);
            ps.setString(2, managerNotes);
            ps.setInt(3, requestId);

            int affectedRows = ps.executeUpdate();
            return affectedRows > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            closeResources();
        }
    }

    /**
     * Get request count by priority
     */
    public int getRequestCountByPriority(String priority) {
        xSql = "SELECT COUNT(*) FROM ServiceRequest WHERE priorityLevel = ? AND status = 'Pending'";
        try {
            ps = con.prepareStatement(xSql);
            ps.setString(1, priority);
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
     * Get requests created today
     */
    public int getRequestsCreatedToday() {
        xSql = "SELECT COUNT(*) FROM ServiceRequest WHERE DATE(requestDate) = CURDATE()";
        try {
            ps = con.prepareStatement(xSql);
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
     * Get pending requests with enhanced information for Technical Manager dashboard
     */
    public List<ServiceRequest> getPendingRequestsWithDetails() {
        List<ServiceRequest> list = new ArrayList<>();
<<<<<<< Updated upstream
        xSql = "SELECT sr.*, " +
                "a.fullName as customerName, a.email as customerEmail, a.phone as customerPhone, " +
                "e.serialNumber, e.model as equipmentModel, e.description as equipmentDescription, " +
                "c.contractType, c.contractDate, " +
                "DATEDIFF(CURRENT_DATE, sr.requestDate) as daysPending " +
                "FROM ServiceRequest sr " +
                "INNER JOIN Account a ON sr.createdBy = a.accountId " +
                "INNER JOIN Equipment e ON sr.equipmentId = e.equipmentId " +
                "INNER JOIN Contract c ON sr.contractId = c.contractId " +
                "WHERE sr.status = 'Pending' " +
                "ORDER BY " +
                "CASE sr.priorityLevel " +
                "    WHEN 'Urgent' THEN 1 " +
                "    WHEN 'High' THEN 2 " +
                "    WHEN 'Normal' THEN 3 " +
                "END, sr.requestDate ASC";
=======
        xSql = "SELECT sr.*, "
                + "a.fullName as customerName, a.email as customerEmail, a.phone as customerPhone, "
                + "e.serialNumber, e.model as equipmentModel, e.description as equipmentDescription, "
                + "c.contractType, c.contractDate, "
                + "DATEDIFF(CURRENT_DATE, sr.requestDate) as daysPending "
                + "FROM ServiceRequest sr "
                + "INNER JOIN Account a ON sr.createdBy = a.accountId "
                + "INNER JOIN Equipment e ON sr.equipmentId = e.equipmentId "
                + "INNER JOIN Contract c ON sr.contractId = c.contractId "
                + "WHERE sr.status = 'Awaiting Approval' "
                + "ORDER BY "
                + "CASE sr.priorityLevel "
                + "    WHEN 'Urgent' THEN 1 "
                + "    WHEN 'High' THEN 2 "
                + "    WHEN 'Normal' THEN 3 "
                + "END, sr.requestDate ASC";
>>>>>>> Stashed changes
        try {
            ps = con.prepareStatement(xSql);
            rs = ps.executeQuery();
            while (rs.next()) {
                ServiceRequest sr = mapResultSetToServiceRequest(rs);
                // Note: In a real implementation, you might want to create a DTO
                // that includes the additional fields like customerName, equipmentModel, etc.
                list.add(sr);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return list;
    }

}