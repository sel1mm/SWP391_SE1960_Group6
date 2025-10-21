package dal;

import model.ServiceRequest;
import model.ServiceRequestDetailDTO2;
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
        xSql = "SELECT contractEquipmentId FROM ContractEquipment "
                + "WHERE contractId = ? AND equipmentId = ?";
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
     * Hủy service request (chuyển status sang Cancelled) Chỉ cho phép cancel
     * khi status = Pending
     *
     * @return true nếu thành công, false nếu thất bại
     */
    public boolean cancelServiceRequest(int requestId) {
        xSql = "UPDATE ServiceRequest SET status = 'Cancelled' "
                + "WHERE requestId = ? AND status = 'Pending'";
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
        xSql = "SELECT sr.requestId FROM ServiceRequest sr "
                + "INNER JOIN Contract c ON sr.contractId = c.contractId "
                + "WHERE sr.requestId = ? AND c.customerId = ? AND sr.status = 'Pending'";
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
     * Cập nhật service request (chỉ cho phép update description và
     * priorityLevel)
     *
     * @return true nếu thành công, false nếu thất bại
     */
    public boolean updateServiceRequest(int requestId, String description, String priorityLevel) {
        xSql = "UPDATE ServiceRequest SET description = ?, priorityLevel = ? "
                + "WHERE requestId = ? AND status = 'Pending'";
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
        xSql = "SELECT sr.requestId FROM ServiceRequest sr "
                + "INNER JOIN Contract c ON sr.contractId = c.contractId "
                + "WHERE sr.requestId = ? AND c.customerId = ? AND sr.status = 'Pending'";
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
     *
     * @return requestId nếu thành công, -1 nếu thất bại
     */
    public int createServiceRequest(ServiceRequest request) {
        xSql = "INSERT INTO ServiceRequest (contractId, equipmentId, createdBy, description, "
                + "priorityLevel, requestDate, status, requestType) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        System.out.println("🔍 DAO: Starting createServiceRequest");
        System.out.println("🔍 DAO: contractId = " + request.getContractId());
        System.out.println("🔍 DAO: equipmentId = " + request.getEquipmentId());

        try {
            ps = con.prepareStatement(xSql, Statement.RETURN_GENERATED_KEYS);

            // XỬ LÝ NULL cho contractId
            if (request.getContractId() == null) {
                ps.setNull(1, java.sql.Types.INTEGER);
                System.out.println("🔍 DAO: Set contractId = NULL");
            } else {
                ps.setInt(1, request.getContractId());
                System.out.println("🔍 DAO: Set contractId = " + request.getContractId());
            }

            // XỬ LÝ NULL cho equipmentId
            if (request.getEquipmentId() == null) {
                ps.setNull(2, java.sql.Types.INTEGER);
                System.out.println("🔍 DAO: Set equipmentId = NULL");
            } else {
                ps.setInt(2, request.getEquipmentId());
                System.out.println("🔍 DAO: Set equipmentId = " + request.getEquipmentId());
            }

            ps.setInt(3, request.getCreatedBy());
            ps.setString(4, request.getDescription());
            ps.setString(5, request.getPriorityLevel());
            ps.setDate(6, new java.sql.Date(request.getRequestDate().getTime()));
            ps.setString(7, request.getStatus());
            ps.setString(8, request.getRequestType());

            System.out.println("🔍 DAO: About to execute SQL...");
            int affectedRows = ps.executeUpdate();
            System.out.println("🔍 DAO: Affected rows = " + affectedRows);

            if (affectedRows > 0) {
                rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    int generatedId = rs.getInt(1);
                    System.out.println("✅ DAO: Successfully created request with ID = " + generatedId);
                    return generatedId;
                }
            }
            System.out.println("❌ DAO: No rows affected");
            return -1;
        } catch (SQLException e) {
            System.err.println("❌ DAO SQL Error:");
            System.err.println("   Error Code: " + e.getErrorCode());
            System.err.println("   SQL State: " + e.getSQLState());
            System.err.println("   Message: " + e.getMessage());
            e.printStackTrace();
            return -1;
        } catch (Exception e) {
            System.err.println("❌ DAO General Error: " + e.getMessage());
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
    public model.ServiceRequestDetailDTO2 getRequestDetailById(int requestId) {
        xSql = "SELECT sr.*, "
                + "c.contractType, c.status as contractStatus, c.contractDate, "
                + "e.serialNumber, e.model as equipmentModel, e.description as equipmentDescription, "
                + "a.fullName as customerName, a.email as customerEmail, a.phone as customerPhone "
                + "FROM ServiceRequest sr "
                + "INNER JOIN Contract c ON sr.contractId = c.contractId "
                + "INNER JOIN Equipment e ON sr.equipmentId = e.equipmentId "
                + "INNER JOIN Account a ON c.customerId = a.accountId "
                + "WHERE sr.requestId = ?";
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
     * Lấy tất cả service requests của một customer (Sắp xếp mới nhất trước)
     */
    public List<ServiceRequest> getRequestsByCustomerId(int customerId) {
        List<ServiceRequest> list = new ArrayList<>();
        xSql = "SELECT sr.* FROM ServiceRequest sr "
                + "WHERE sr.createdBy = ? "
                + "ORDER BY sr.requestId DESC";
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
     * Tìm kiếm theo keyword (description hoặc requestId) - Sắp xếp cũ nhất trước
     */
    public List<ServiceRequest> searchRequests(int customerId, String keyword) {
        List<ServiceRequest> list = new ArrayList<>();
        xSql = "SELECT sr.* FROM ServiceRequest sr "
                + "INNER JOIN Contract c ON sr.contractId = c.contractId "
                + "WHERE c.customerId = ? "
                + "AND (sr.description LIKE ? OR CAST(sr.requestId AS CHAR) LIKE ?) "
                + "ORDER BY sr.requestDate ASC, sr.requestId ASC";
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
     * Lọc theo status - Sắp xếp cũ nhất trước
     */
    public List<ServiceRequest> filterRequestsByStatus(int customerId, String status) {
        List<ServiceRequest> list = new ArrayList<>();
        xSql = "SELECT sr.* FROM ServiceRequest sr "
                + "INNER JOIN Contract c ON sr.contractId = c.contractId "
                + "WHERE c.customerId = ? AND sr.status = ? "
                + "ORDER BY sr.requestDate ASC, sr.requestId ASC";
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
        xSql = "SELECT COUNT(*) FROM ServiceRequest sr "
                + "INNER JOIN Contract c ON sr.contractId = c.contractId "
                + "WHERE c.customerId = ?";
        return getCount(customerId);
    }

    /**
     * Đếm số requests theo status (cho customer cụ thể)
     */
    public int getRequestCountByStatus(int customerId, String status) {
        xSql = "SELECT COUNT(*) FROM ServiceRequest sr "
                + "INNER JOIN Contract c ON sr.contractId = c.contractId "
                + "WHERE c.customerId = ? AND sr.status = ?";
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
        
        // Handle assigned_technician_id (can be null)
        try {
            int technicianId = rs.getInt("assigned_technician_id");
            if (!rs.wasNull()) {
                sr.setAssignedTechnicianId(technicianId);
            }
        } catch (SQLException e) {
            // Column might not exist in all queries, ignore
        }
        
        // Handle additional display fields if they exist
        try {
            sr.setCustomerName(rs.getString("customerName"));
        } catch (SQLException e) {
            // Column might not exist in all queries, ignore
        }
        
        try {
            sr.setCustomerEmail(rs.getString("customerEmail"));
        } catch (SQLException e) {
            // Column might not exist in all queries, ignore
        }
        
        try {
            sr.setCustomerPhone(rs.getString("customerPhone"));
        } catch (SQLException e) {
            // Column might not exist in all queries, ignore
        }
        
        try {
            sr.setEquipmentName(rs.getString("equipmentModel"));
        } catch (SQLException e) {
            // Column might not exist in all queries, ignore
        }
        
        try {
            sr.setSerialNumber(rs.getString("serialNumber"));
        } catch (SQLException e) {
            // Column might not exist in all queries, ignore
        }
        
        try {
            sr.setTechnicianName(rs.getString("technicianName"));
        } catch (SQLException e) {
            // Column might not exist in all queries, ignore
        }
        
        try {
            sr.setDaysPending(rs.getInt("daysPending"));
        } catch (SQLException e) {
            // Column might not exist in all queries, ignore
        }
        
        return sr;
    }

    /**
     * Map ResultSet thành ServiceRequestDetailDTO
     */
    private model.ServiceRequestDetailDTO2 mapResultSetToDetailDTO(ResultSet rs) throws SQLException {
        model.ServiceRequestDetailDTO2 dto = new model.ServiceRequestDetailDTO2();
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
        dto.setCustomerEmail(rs.getString("customerEmail"));
        dto.setCustomerPhone(rs.getString("customerPhone"));
        
        // Calculate days pending
        java.util.Date requestDate = rs.getDate("requestDate");
        if (requestDate != null) {
            long diffInMillies = System.currentTimeMillis() - requestDate.getTime();
            int daysPending = (int) (diffInMillies / (1000 * 60 * 60 * 24));
            dto.setDaysPending(daysPending);
        } else {
            dto.setDaysPending(0);
        }

        return dto;
    }

    /**
     * Đóng resources
     */
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
        xSql = "SELECT sr.* FROM ServiceRequest sr "
                + "INNER JOIN Account a ON sr.createdBy = a.accountId "
                + "WHERE sr.status = 'Pending' "
                + "AND (sr.description LIKE ? OR a.fullName LIKE ? OR CAST(sr.requestId AS CHAR) LIKE ?) "
                + "ORDER BY sr.priorityLevel DESC, sr.requestDate ASC";
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
            conditions.add("sr.priorityLevel = ?");
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

            // Set parameter cho priority nếu có
            if (priority != null && !priority.trim().isEmpty()) {
                ps.setString(1, priority);
            }

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
     * @deprecated Use updateServiceRequestStatusWithResult for better error handling
     */
    @Deprecated
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
     * Update service request status with technician assignment
     * Returns detailed result information for better error handling
     */
    public dto.ServiceRequestUpdateResult updateServiceRequestStatusWithResult(int requestId, String newStatus, String managerNotes, int managerId, Integer assignedTechnicianId) {
        Connection conn = null;
        PreparedStatement psCheck = null;
        PreparedStatement psCheckApproval = null;
        PreparedStatement psCheckTechnician = null;
        PreparedStatement psUpdate = null;
        PreparedStatement psInsert = null;
        
        try {
            conn = con;
            conn.setAutoCommit(false); // Start transaction
            
            // 1. Check if request exists and get current status
            String checkSql = "SELECT status FROM ServiceRequest WHERE requestId = ?";
            psCheck = conn.prepareStatement(checkSql);
            psCheck.setInt(1, requestId);
            ResultSet rs = psCheck.executeQuery();
            
            if (!rs.next()) {
                conn.rollback();
                return dto.ServiceRequestUpdateResult.requestNotFound();
            }
            
            String currentStatus = rs.getString("status");
            if (!"Awaiting Approval".equals(currentStatus)) {
                conn.rollback();
                return dto.ServiceRequestUpdateResult.alreadyProcessed();
            }
            
            // 2. Check if approval record already exists
            String checkApprovalSql = "SELECT COUNT(*) FROM RequestApproval WHERE requestId = ?";
            psCheckApproval = conn.prepareStatement(checkApprovalSql);
            psCheckApproval.setInt(1, requestId);
            ResultSet rsApproval = psCheckApproval.executeQuery();
            
            if (rsApproval.next() && rsApproval.getInt(1) > 0) {
                conn.rollback();
                return dto.ServiceRequestUpdateResult.alreadyProcessed();
            }
            
            // 3. If technician is assigned, verify technician exists and has correct role
            if (assignedTechnicianId != null) {
                String checkTechnicianSql = "SELECT COUNT(*) FROM Account a " +
                                          "INNER JOIN AccountRole ar ON a.accountId = ar.accountId " +
                                          "INNER JOIN Role r ON ar.roleId = r.roleId " +
                                          "WHERE a.accountId = ? AND r.roleName = 'Technician' AND a.status = 'Active'";
                psCheckTechnician = conn.prepareStatement(checkTechnicianSql);
                psCheckTechnician.setInt(1, assignedTechnicianId);
                ResultSet rsTechnician = psCheckTechnician.executeQuery();
                
                if (!rsTechnician.next() || rsTechnician.getInt(1) == 0) {
                    conn.rollback();
                    return dto.ServiceRequestUpdateResult.technicianNotFound();
                }
            }
            
            // 4. Update ServiceRequest status
            String updateSql = "UPDATE ServiceRequest SET status = ? WHERE requestId = ? AND status = 'Awaiting Approval'";
            
            psUpdate = conn.prepareStatement(updateSql);
            psUpdate.setString(1, newStatus);
            psUpdate.setInt(2, requestId);
            
            int affectedRows = psUpdate.executeUpdate();
            if (affectedRows == 0) {
                conn.rollback();
                return dto.ServiceRequestUpdateResult.alreadyProcessed();
            }
            
            // 5. Insert into RequestApproval table with technician assignment
            String insertApprovalSQL;
            if (assignedTechnicianId != null) {
                insertApprovalSQL = "INSERT INTO RequestApproval (requestId, approvedBy, approvalDate, decision, note, assignedTechnicianId) VALUES (?, ?, NOW(), ?, ?, ?)";
            } else {
                insertApprovalSQL = "INSERT INTO RequestApproval (requestId, approvedBy, approvalDate, decision, note) VALUES (?, ?, NOW(), ?, ?)";
            }
            
            psInsert = conn.prepareStatement(insertApprovalSQL);
            psInsert.setInt(1, requestId);
            psInsert.setInt(2, managerId);
            psInsert.setString(3, newStatus);
            psInsert.setString(4, managerNotes);
            
            if (assignedTechnicianId != null) {
                psInsert.setInt(5, assignedTechnicianId);
            }
            
            psInsert.executeUpdate();
            
            conn.commit(); // Commit transaction
            return dto.ServiceRequestUpdateResult.success();
            
        } catch (Exception e) {
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
            return dto.ServiceRequestUpdateResult.databaseError(e);
        } finally {
            try {
                if (psCheck != null) psCheck.close();
                if (psCheckApproval != null) psCheckApproval.close();
                if (psCheckTechnician != null) psCheckTechnician.close();
                if (psUpdate != null) psUpdate.close();
                if (psInsert != null) psInsert.close();
                if (conn != null) conn.setAutoCommit(true);
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    /**
     * Update service request status with technician assignment
     * @deprecated Use updateServiceRequestStatusWithResult for better error handling
     */
    @Deprecated
    public boolean updateServiceRequestStatus(int requestId, String newStatus, String managerNotes, int managerId, Integer assignedTechnicianId) {
        dto.ServiceRequestUpdateResult result = updateServiceRequestStatusWithResult(requestId, newStatus, managerNotes, managerId, assignedTechnicianId);
        return result.isSuccess();
    }

    /**
     * Get request count by priority (for Support Staff - only Pending requests)
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
     * Get request count by priority and status (for Technical Manager)
     */
    public int getRequestCountByPriority(String priority, String status) {
        xSql = "SELECT COUNT(*) FROM ServiceRequest WHERE priorityLevel = ? AND status = ?";
        try {
            ps = con.prepareStatement(xSql);
            ps.setString(1, priority);
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
     * Get requests created today (all statuses)
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
     * Get requests created today with specific status (for Technical Manager)
     */
    public int getRequestsCreatedTodayByStatus(String status) {
        xSql = "SELECT COUNT(*) FROM ServiceRequest WHERE DATE(requestDate) = CURDATE() AND status = ?";
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

    /**
     * Get pending requests with enhanced information for Technical Manager dashboard
     * Shows only requests with status 'Awaiting Approval'
     */
    public List<ServiceRequest> getPendingRequestsWithDetails() {
        List<ServiceRequest> list = new ArrayList<>();
       
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

        try {
            ps = con.prepareStatement(xSql);
            rs = ps.executeQuery();
            while (rs.next()) {
                ServiceRequest sr = mapResultSetToServiceRequest(rs);
                list.add(sr);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return list;
    }

    /**
     * Get pending requests as DetailDTO objects for Technical Manager approval page
     */
    public List<model.ServiceRequestDetailDTO2> getPendingRequestsDetailDTO() {
        List<model.ServiceRequestDetailDTO2> list = new ArrayList<>();
        xSql = "SELECT sr.*, "
                + "a.fullName as customerName, a.email as customerEmail, a.phone as customerPhone, "
                + "e.serialNumber, e.model as equipmentModel, e.description as equipmentDescription, "
                + "c.contractType, c.contractDate, c.status as contractStatus, "
                + "DATEDIFF(CURRENT_DATE, sr.requestDate) as daysPending "
                + "FROM ServiceRequest sr "
                + "LEFT JOIN Account a ON sr.createdBy = a.accountId "
                + "LEFT JOIN Equipment e ON sr.equipmentId = e.equipmentId "
                + "LEFT JOIN Contract c ON sr.contractId = c.contractId "
                + "WHERE sr.status = 'Pending' "
                + "ORDER BY "
                + "CASE sr.priorityLevel "
                + "    WHEN 'Urgent' THEN 1 "
                + "    WHEN 'High' THEN 2 "
                + "    WHEN 'Normal' THEN 3 "
                + "END, sr.requestDate ASC";
        try {
            ps = con.prepareStatement(xSql);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToDetailDTO(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return list;
    }

    /**
     * Search pending requests as DetailDTO objects for Technical Manager approval page
     */
    public List<model.ServiceRequestDetailDTO2> searchPendingRequestsDetailDTO(String keyword) {
        List<model.ServiceRequestDetailDTO2> list = new ArrayList<>();
        xSql = "SELECT sr.*, "
                + "a.fullName as customerName, a.email as customerEmail, a.phone as customerPhone, "
                + "e.serialNumber, e.model as equipmentModel, e.description as equipmentDescription, "
                + "c.contractType, c.contractDate, c.status as contractStatus, "
                + "DATEDIFF(CURRENT_DATE, sr.requestDate) as daysPending "
                + "FROM ServiceRequest sr "
                + "LEFT JOIN Account a ON sr.createdBy = a.accountId "
                + "LEFT JOIN Equipment e ON sr.equipmentId = e.equipmentId "
                + "LEFT JOIN Contract c ON sr.contractId = c.contractId "
                + "WHERE sr.status = 'Pending' "
                + "AND (sr.description LIKE ? OR a.fullName LIKE ? OR CAST(sr.requestId AS CHAR) LIKE ?) "
                + "ORDER BY "
                + "CASE sr.priorityLevel "
                + "    WHEN 'Urgent' THEN 1 "
                + "    WHEN 'High' THEN 2 "
                + "    WHEN 'Normal' THEN 3 "
                + "END, sr.requestDate ASC";
        try {
            ps = con.prepareStatement(xSql);
            ps.setString(1, "%" + keyword + "%");
            ps.setString(2, "%" + keyword + "%");
            ps.setString(3, "%" + keyword + "%");
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToDetailDTO(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return list;
    }

    /**
     * Filter pending requests as DetailDTO objects for Technical Manager approval page
     */
    public List<model.ServiceRequestDetailDTO2> filterPendingRequestsDetailDTO(String priority, String urgency) {
        List<model.ServiceRequestDetailDTO2> list = new ArrayList<>();
        
        StringBuilder sqlBuilder = new StringBuilder();
        sqlBuilder.append("SELECT sr.*, ");
        sqlBuilder.append("a.fullName as customerName, a.email as customerEmail, a.phone as customerPhone, ");
        sqlBuilder.append("e.serialNumber, e.model as equipmentModel, e.description as equipmentDescription, ");
        sqlBuilder.append("c.contractType, c.contractDate, c.status as contractStatus, ");
        sqlBuilder.append("DATEDIFF(CURRENT_DATE, sr.requestDate) as daysPending ");
        sqlBuilder.append("FROM ServiceRequest sr ");
        sqlBuilder.append("LEFT JOIN Account a ON sr.createdBy = a.accountId ");
        sqlBuilder.append("LEFT JOIN Equipment e ON sr.equipmentId = e.equipmentId ");
        sqlBuilder.append("LEFT JOIN Contract c ON sr.contractId = c.contractId ");
        sqlBuilder.append("WHERE sr.status = 'Pending' ");
        
        List<String> conditions = new ArrayList<>();
        List<String> parameters = new ArrayList<>();
        
        if (priority != null && !priority.trim().isEmpty()) {
            conditions.add("sr.priorityLevel = ?");
            parameters.add(priority.trim());
        }
        
        if (urgency != null && !urgency.trim().isEmpty()) {
            conditions.add("sr.priorityLevel = ?");
            parameters.add(urgency.trim());
        }
        
        if (!conditions.isEmpty()) {
            sqlBuilder.append("AND (");
            sqlBuilder.append(String.join(" OR ", conditions));
            sqlBuilder.append(") ");
        }
        
        sqlBuilder.append("ORDER BY ");
        sqlBuilder.append("CASE sr.priorityLevel ");
        sqlBuilder.append("    WHEN 'Urgent' THEN 1 ");
        sqlBuilder.append("    WHEN 'High' THEN 2 ");
        sqlBuilder.append("    WHEN 'Normal' THEN 3 ");
        sqlBuilder.append("END, sr.requestDate ASC");
        
        xSql = sqlBuilder.toString();
        
        try {
            ps = con.prepareStatement(xSql);
            for (int i = 0; i < parameters.size(); i++) {
                ps.setString(i + 1, parameters.get(i));
            }
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToDetailDTO(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return list;
    }

    // ============ SUPPORT STAFF METHODS ============

    /**
     * Get requests by status for Support Staff
     */
    public List<ServiceRequest> getRequestsByStatus(String status) {
        List<ServiceRequest> list = new ArrayList<>();
        xSql = "SELECT sr.*, "
                + "a.fullName as customerName, a.email as customerEmail, a.phone as customerPhone, "
                + "e.serialNumber, e.model as equipmentModel, e.description as equipmentDescription "
                + "FROM ServiceRequest sr "
                + "LEFT JOIN Account a ON sr.createdBy = a.accountId "
                + "LEFT JOIN Equipment e ON sr.equipmentId = e.equipmentId "
                + "WHERE sr.status = ? "
                + "ORDER BY sr.priorityLevel DESC, sr.requestDate ASC";
        try {
            ps = con.prepareStatement(xSql);
            ps.setString(1, status);
            rs = ps.executeQuery();
            while (rs.next()) {
                ServiceRequest sr = mapResultSetToServiceRequest(rs);
                sr.setCustomerName(rs.getString("customerName"));
                sr.setCustomerEmail(rs.getString("customerEmail"));
                sr.setCustomerPhone(rs.getString("customerPhone"));
                sr.setEquipmentName(rs.getString("equipmentModel"));
                list.add(sr);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return list;
    }

    /**
     * Search requests by status and keyword for Support Staff
     */
    public List<ServiceRequest> searchRequestsByStatusAndKeyword(String status, String keyword) {
        List<ServiceRequest> list = new ArrayList<>();
        xSql = "SELECT sr.*, "
                + "a.fullName as customerName, a.email as customerEmail, a.phone as customerPhone, "
                + "e.serialNumber, e.model as equipmentModel, e.description as equipmentDescription "
                + "FROM ServiceRequest sr "
                + "LEFT JOIN Account a ON sr.createdBy = a.accountId "
                + "LEFT JOIN Equipment e ON sr.equipmentId = e.equipmentId "
                + "WHERE sr.status = ? "
                + "AND (sr.description LIKE ? OR a.fullName LIKE ? OR CAST(sr.requestId AS CHAR) LIKE ?) "
                + "ORDER BY sr.priorityLevel DESC, sr.requestDate ASC";
        try {
            ps = con.prepareStatement(xSql);
            ps.setString(1, status);
            ps.setString(2, "%" + keyword + "%");
            ps.setString(3, "%" + keyword + "%");
            ps.setString(4, "%" + keyword + "%");
            rs = ps.executeQuery();
            while (rs.next()) {
                ServiceRequest sr = mapResultSetToServiceRequest(rs);
                sr.setCustomerName(rs.getString("customerName"));
                sr.setCustomerEmail(rs.getString("customerEmail"));
                sr.setCustomerPhone(rs.getString("customerPhone"));
                sr.setEquipmentName(rs.getString("equipmentModel"));
                list.add(sr);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return list;
    }

    /**
     * Get requests by status and priority for Support Staff
     */
    public List<ServiceRequest> getRequestsByStatusAndPriority(String status, String priority) {
        List<ServiceRequest> list = new ArrayList<>();
        xSql = "SELECT sr.*, "
                + "a.fullName as customerName, a.email as customerEmail, a.phone as customerPhone, "
                + "e.serialNumber, e.model as equipmentModel, e.description as equipmentDescription "
                + "FROM ServiceRequest sr "
                + "LEFT JOIN Account a ON sr.createdBy = a.accountId "
                + "LEFT JOIN Equipment e ON sr.equipmentId = e.equipmentId "
                + "WHERE sr.status = ? AND sr.priorityLevel = ? "
                + "ORDER BY sr.requestDate ASC";
        try {
            ps = con.prepareStatement(xSql);
            ps.setString(1, status);
            ps.setString(2, priority);
            rs = ps.executeQuery();
            while (rs.next()) {
                ServiceRequest sr = mapResultSetToServiceRequest(rs);
                sr.setCustomerName(rs.getString("customerName"));
                sr.setCustomerEmail(rs.getString("customerEmail"));
                sr.setCustomerPhone(rs.getString("customerPhone"));
                sr.setEquipmentName(rs.getString("equipmentModel"));
                list.add(sr);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return list;
    }

    /**
     * Forward request to technician - Update status to 'Awaiting Approval'
     */
    public boolean forwardRequestToTechnician(int requestId, int technicianId) {
        xSql = "UPDATE ServiceRequest SET status = 'Awaiting Approval', assigned_technician_id = ? "
                + "WHERE requestId = ? AND status = 'Pending'";
        try {
            ps = con.prepareStatement(xSql);
            ps.setInt(1, technicianId);
            ps.setInt(2, requestId);
            
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
     * Get requests assigned to a specific technician with 'Awaiting Approval' status
     */
    public List<ServiceRequest> getRequestsAssignedToTechnician(int technicianId) {
        List<ServiceRequest> list = new ArrayList<>();
        xSql = "SELECT sr.*, "
                + "a.fullName as customerName, a.email as customerEmail, a.phone as customerPhone, "
                + "e.serialNumber, e.model as equipmentModel, e.description as equipmentDescription "
                + "FROM ServiceRequest sr "
                + "LEFT JOIN Account a ON sr.createdBy = a.accountId "
                + "LEFT JOIN Equipment e ON sr.equipmentId = e.equipmentId "
                + "LEFT JOIN RequestApproval ra ON sr.requestId = ra.requestId "
                + "WHERE ra.assignedTechnicianId = ? AND sr.status = 'Awaiting Approval' "
                + "ORDER BY sr.priorityLevel DESC, sr.requestDate ASC";
        try {
            ps = con.prepareStatement(xSql);
            ps.setInt(1, technicianId);
            rs = ps.executeQuery();
            while (rs.next()) {
                ServiceRequest sr = mapResultSetToServiceRequest(rs);
                sr.setCustomerName(rs.getString("customerName"));
                sr.setCustomerEmail(rs.getString("customerEmail"));
                sr.setCustomerPhone(rs.getString("customerPhone"));
                sr.setEquipmentName(rs.getString("equipmentModel"));
                list.add(sr);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return list;
    }

    /**
     * Get all requests with history for Technical Manager
     */
    public List<ServiceRequest> getAllRequestsHistory() {
        List<ServiceRequest> list = new ArrayList<>();
        xSql = "SELECT sr.*, "
                + "a.fullName as customerName, a.email as customerEmail, a.phone as customerPhone, "
                + "e.serialNumber, e.model as equipmentModel, e.description as equipmentDescription, "
                + "tech.fullName as technicianName, "
                + "ra.decision, ra.approvalDate, ra.note, "
                + "manager.fullName as approvedByName "
                + "FROM ServiceRequest sr "
                + "LEFT JOIN Account a ON sr.createdBy = a.accountId "
                + "LEFT JOIN Equipment e ON sr.equipmentId = e.equipmentId "
                + "INNER JOIN RequestApproval ra ON sr.requestId = ra.requestId "
                + "LEFT JOIN Account tech ON ra.assignedTechnicianId = tech.accountId "
                + "LEFT JOIN Account manager ON ra.approvedBy = manager.accountId "
                + "WHERE ra.decision IS NOT NULL "
                + "ORDER BY ra.approvalDate DESC, sr.requestDate DESC";
        try {
            ps = con.prepareStatement(xSql);
            rs = ps.executeQuery();
            while (rs.next()) {
                ServiceRequest sr = mapResultSetToServiceRequest(rs);
                sr.setCustomerName(rs.getString("customerName"));
                sr.setCustomerEmail(rs.getString("customerEmail"));
                sr.setCustomerPhone(rs.getString("customerPhone"));
                sr.setEquipmentName(rs.getString("equipmentModel"));
                sr.setTechnicianName(rs.getString("technicianName"));
                list.add(sr);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return list;
    }

    /**
     * Filter service requests by status and criteria (priority, urgency)
     */
    public List<ServiceRequest> filterRequestsByStatusAndCriteria(String status, String priority, String urgency) {
        List<ServiceRequest> list = new ArrayList<>();
        
        StringBuilder sqlBuilder = new StringBuilder();
        sqlBuilder.append("SELECT sr.*, ");
        sqlBuilder.append("a.fullName as customerName, a.email as customerEmail, a.phone as customerPhone, ");
        sqlBuilder.append("e.serialNumber, e.model as equipmentModel, e.description as equipmentDescription, ");
        sqlBuilder.append("tech.fullName as technicianName ");
        sqlBuilder.append("FROM ServiceRequest sr ");
        sqlBuilder.append("LEFT JOIN Account a ON sr.createdBy = a.accountId ");
        sqlBuilder.append("LEFT JOIN Equipment e ON sr.equipmentId = e.equipmentId ");
        sqlBuilder.append("LEFT JOIN RequestApproval ra ON sr.requestId = ra.requestId ");
        sqlBuilder.append("LEFT JOIN Account tech ON ra.assignedTechnicianId = tech.accountId ");
        sqlBuilder.append("WHERE sr.status = ? ");
        
        List<String> conditions = new ArrayList<>();
        List<String> parameters = new ArrayList<>();
        parameters.add(status);
        
        if (priority != null && !priority.trim().isEmpty()) {
            conditions.add("sr.priorityLevel = ?");
            parameters.add(priority);
        }
        
        if (urgency != null && !urgency.trim().isEmpty()) {
            conditions.add("sr.priorityLevel = ?");
            parameters.add(urgency);
        }
        
        if (!conditions.isEmpty()) {
            sqlBuilder.append("AND ").append(String.join(" AND ", conditions)).append(" ");
        }
        
        sqlBuilder.append("ORDER BY sr.priorityLevel DESC, sr.requestDate ASC");
        
        try {
            ps = con.prepareStatement(sqlBuilder.toString());
            for (int i = 0; i < parameters.size(); i++) {
                ps.setString(i + 1, parameters.get(i));
            }
            rs = ps.executeQuery();
            while (rs.next()) {
                ServiceRequest sr = mapResultSetToServiceRequest(rs);
                sr.setCustomerName(rs.getString("customerName"));
                sr.setCustomerEmail(rs.getString("customerEmail"));
                sr.setCustomerPhone(rs.getString("customerPhone"));
                sr.setEquipmentName(rs.getString("equipmentModel"));
                sr.setTechnicianName(rs.getString("technicianName"));
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