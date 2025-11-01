package dal;

import model.ServiceRequest;
import model.ServiceRequestDetailDTO2;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import model.RepairReport;

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
        xSql = "SELECT requestId FROM ServiceRequest "
                + "WHERE requestId = ? AND createdBy = ? AND status = 'Pending'";
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
        xSql = "SELECT requestId FROM ServiceRequest "
                + "WHERE requestId = ? AND createdBy = ? AND status = 'Pending'";
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
        xSql = "SELECT sr.*, e.model as equipmentName "
                + // ✅ THÊM equipmentName
                "FROM ServiceRequest sr "
                + "LEFT JOIN Equipment e ON sr.equipmentId = e.equipmentId "
                + // ✅ LEFT JOIN
                "WHERE sr.createdBy = ? "
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
     * Tìm kiếm theo keyword (description hoặc requestId) - Sắp xếp cũ nhất
     * trước
     */
    public List<ServiceRequest> searchRequests(int customerId, String keyword) {
        List<ServiceRequest> list = new ArrayList<>();
        xSql = "SELECT sr.*, e.model as equipmentName "
                + // ✅ THÊM equipmentName
                "FROM ServiceRequest sr "
                + "LEFT JOIN Equipment e ON sr.equipmentId = e.equipmentId "
                + // ✅ LEFT JOIN
                "WHERE sr.createdBy = ? "
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
        xSql = "SELECT sr.*, e.model as equipmentName "
                + // ✅ THÊM equipmentName
                "FROM ServiceRequest sr "
                + "LEFT JOIN Equipment e ON sr.equipmentId = e.equipmentId "
                + // ✅ LEFT JOIN
                "WHERE sr.createdBy = ? AND sr.status = ? "
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
        xSql = xSql = "SELECT COUNT(*) FROM ServiceRequest "
                + "WHERE createdBy = ?";
        return getCount(customerId);
    }

    /**
     * Đếm số requests theo status (cho customer cụ thể)
     */
    public int getRequestCountByStatus(int customerId, String status) {
        xSql = "SELECT COUNT(*) FROM ServiceRequest "
                + "WHERE createdBy = ? AND status = ?";
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
            String equipmentName = rs.getString("equipmentName");
            if (equipmentName != null) {
                sr.setEquipmentName(equipmentName);
            }
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
     *
     * @deprecated Use updateServiceRequestStatusWithResult for better error
     * handling
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
     * Update service request status with technician assignment Returns detailed
     * result information for better error handling
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
                String checkTechnicianSql = "SELECT COUNT(*) FROM Account a "
                        + "INNER JOIN AccountRole ar ON a.accountId = ar.accountId "
                        + "INNER JOIN Role r ON ar.roleId = r.roleId "
                        + "WHERE a.accountId = ? AND r.roleName = 'Technician' AND a.status = 'Active'";
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
                if (conn != null) {
                    conn.rollback();
                }
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
            return dto.ServiceRequestUpdateResult.databaseError(e);
        } finally {
            try {
                if (psCheck != null) {
                    psCheck.close();
                }
                if (psCheckApproval != null) {
                    psCheckApproval.close();
                }
                if (psCheckTechnician != null) {
                    psCheckTechnician.close();
                }
                if (psUpdate != null) {
                    psUpdate.close();
                }
                if (psInsert != null) {
                    psInsert.close();
                }
                if (conn != null) {
                    conn.setAutoCommit(true);
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    /**
     * Update service request status with technician assignment
     *
     * @deprecated Use updateServiceRequestStatusWithResult for better error
     * handling
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
     * Get pending requests with enhanced information for Technical Manager
     * dashboard Shows only requests with status 'Awaiting Approval'
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
     * Get pending requests as DetailDTO objects for Technical Manager approval
     * page
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
     * Search pending requests as DetailDTO objects for Technical Manager
     * approval page
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
     * Filter pending requests as DetailDTO objects for Technical Manager
     * approval page
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
     * Get requests assigned to a specific technician with 'Awaiting Approval'
     * status
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

    public List<ServiceRequest> filterRequests(String keyword, String status, String requestType,
            String priority, String fromDate, String toDate) throws SQLException {
        List<ServiceRequest> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT sr.*, ");
        sql.append("a.fullName AS customerName, a.email AS customerEmail, a.phone AS customerPhone, ");
        sql.append("c.contractType, c.status AS contractStatus, ");
        sql.append("e.model AS equipmentModel, e.serialNumber, e.description AS equipmentDescription, ");
        sql.append("tech.fullName AS technicianName ");
        sql.append("FROM ServiceRequest sr ");
        sql.append("LEFT JOIN Account a ON sr.createdBy = a.accountId ");
        sql.append("LEFT JOIN Contract c ON sr.contractId = c.contractId ");
        sql.append("LEFT JOIN Equipment e ON sr.equipmentId = e.equipmentId ");
        sql.append("LEFT JOIN RequestApproval ra ON sr.requestId = ra.requestId ");
        sql.append("LEFT JOIN Account tech ON ra.assignedTechnicianId = tech.accountId ");
        sql.append("WHERE 1=1 ");

        // dynamic conditions
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (a.fullName LIKE ? OR a.phone LIKE ? OR c.contractId LIKE ? ")
                    .append("OR e.model LIKE ? OR e.serialNumber LIKE ? OR sr.description LIKE ?) ");
        }
        if (status != null && !status.trim().isEmpty()) {
            sql.append("AND sr.status = ? ");
        }
        if (requestType != null && !requestType.trim().isEmpty()) {
            sql.append("AND sr.requestType = ? ");
        }
        if (priority != null && !priority.trim().isEmpty()) {
            sql.append("AND sr.priorityLevel = ? ");
        }
        if (fromDate != null && !fromDate.trim().isEmpty()) {
            sql.append("AND sr.requestDate >= ? ");
        }
        if (toDate != null && !toDate.trim().isEmpty()) {
            sql.append("AND sr.requestDate <= ? ");
        }

        sql.append("ORDER BY sr.requestDate DESC");

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            int idx = 1;
            if (keyword != null && !keyword.trim().isEmpty()) {
                String like = "%" + keyword.trim() + "%";
                ps.setString(idx++, like);
                ps.setString(idx++, like);
                ps.setString(idx++, like);
                ps.setString(idx++, like);
                ps.setString(idx++, like);
                ps.setString(idx++, like);
            }
            if (status != null && !status.trim().isEmpty()) {
                ps.setString(idx++, status.trim());
            }
            if (requestType != null && !requestType.trim().isEmpty()) {
                ps.setString(idx++, requestType.trim());
            }
            if (priority != null && !priority.trim().isEmpty()) {
                ps.setString(idx++, priority.trim());
            }
            if (fromDate != null && !fromDate.trim().isEmpty()) {
                ps.setString(idx++, fromDate.trim());
            }
            if (toDate != null && !toDate.trim().isEmpty()) {
                ps.setString(idx++, toDate.trim());
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ServiceRequest sr = new ServiceRequest();
                    sr.setRequestId(rs.getInt("requestId"));
                    sr.setContractId(rs.getInt("contractId"));
                    sr.setEquipmentId(rs.getInt("equipmentId"));
                    sr.setCreatedBy(rs.getInt("createdBy"));
                    sr.setDescription(rs.getString("description"));
                    sr.setPriorityLevel(rs.getString("priorityLevel"));
                    sr.setRequestDate(rs.getTimestamp("requestDate"));
                    sr.setStatus(rs.getString("status"));
                    sr.setRequestType(rs.getString("requestType"));

                    // joined info
                    sr.setCustomerName(rs.getString("customerName"));
                    sr.setCustomerEmail(rs.getString("customerEmail"));
                    sr.setCustomerPhone(rs.getString("customerPhone"));
                    sr.setContractType(rs.getString("contractType"));
                    sr.setContractStatus(rs.getString("contractStatus"));
                    sr.setEquipmentModel(rs.getString("equipmentModel"));
                    sr.setEquipmentDescription(rs.getString("equipmentDescription"));
                    sr.setTechnicianName(rs.getString("technicianName"));

                    list.add(sr);
                }
            }
        }

        return list;
    }

    public List<ServiceRequest> getAllRequests() throws SQLException {
        List<ServiceRequest> list = new ArrayList<>();

        String sql = "SELECT sr.*, "
                + "a.fullName AS customerName, a.email AS customerEmail, a.phone AS customerPhone, "
                + "c.contractType, c.status AS contractStatus, "
                + "e.model AS equipmentModel, e.serialNumber, e.description AS equipmentDescription, "
                + "tech.fullName AS technicianName "
                + "FROM ServiceRequest sr "
                + "LEFT JOIN Account a ON sr.createdBy = a.accountId "
                + "LEFT JOIN Contract c ON sr.contractId = c.contractId "
                + "LEFT JOIN Equipment e ON sr.equipmentId = e.equipmentId "
                + "LEFT JOIN RequestApproval ra ON sr.requestId = ra.requestId "
                + "LEFT JOIN Account tech ON ra.assignedTechnicianId = tech.accountId "
                + "ORDER BY sr.requestDate DESC";

        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                ServiceRequest sr = new ServiceRequest();

                // Core fields
                sr.setRequestId(rs.getInt("requestId"));
                sr.setContractId(rs.getInt("contractId"));
                sr.setEquipmentId(rs.getInt("equipmentId"));
                sr.setCreatedBy(rs.getInt("createdBy"));
                sr.setDescription(rs.getString("description"));
                sr.setPriorityLevel(rs.getString("priorityLevel"));
                sr.setRequestDate(rs.getTimestamp("requestDate"));
                sr.setStatus(rs.getString("status"));
                sr.setRequestType(rs.getString("requestType"));

                // Joined data
                sr.setCustomerName(rs.getString("customerName"));
                sr.setCustomerEmail(rs.getString("customerEmail"));
                sr.setCustomerPhone(rs.getString("customerPhone"));
                sr.setContractType(rs.getString("contractType"));
                sr.setContractStatus(rs.getString("contractStatus"));
                sr.setEquipmentModel(rs.getString("equipmentModel"));
                sr.setEquipmentDescription(rs.getString("equipmentDescription"));
                sr.setSerialNumber(rs.getString("serialNumber"));
                sr.setTechnicianName(rs.getString("technicianName"));

                list.add(sr);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    // Lấy danh sách Service Request có phân trang
    public List<ServiceRequest> getAllRequestsPaged(int offset, int limit) throws SQLException {
        List<ServiceRequest> list = new ArrayList<>();

        String sql = """
        SELECT sr.*, 
               a.fullName AS customerName, a.email AS customerEmail, a.phone AS customerPhone,
               c.contractType, c.status AS contractStatus,
               e.model AS equipmentModel, e.serialNumber, e.description AS equipmentDescription,
               tech.fullName AS technicianName
        FROM ServiceRequest sr
        LEFT JOIN Account a ON sr.createdBy = a.accountId
        LEFT JOIN Contract c ON sr.contractId = c.contractId
        LEFT JOIN Equipment e ON sr.equipmentId = e.equipmentId
        LEFT JOIN RequestApproval ra ON sr.requestId = ra.requestId
        LEFT JOIN Account tech ON ra.assignedTechnicianId = tech.accountId
        ORDER BY sr.requestDate DESC
        LIMIT ? OFFSET ?
    """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, limit);
            ps.setInt(2, offset);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ServiceRequest sr = new ServiceRequest();
                    sr.setRequestId(rs.getInt("requestId"));
                    sr.setContractId(rs.getInt("contractId"));
                    sr.setEquipmentId(rs.getInt("equipmentId"));
                    sr.setCreatedBy(rs.getInt("createdBy"));
                    sr.setDescription(rs.getString("description"));
                    sr.setPriorityLevel(rs.getString("priorityLevel"));
                    sr.setRequestDate(rs.getTimestamp("requestDate"));
                    sr.setStatus(rs.getString("status"));
                    sr.setRequestType(rs.getString("requestType"));

                    sr.setCustomerName(rs.getString("customerName"));
                    sr.setCustomerEmail(rs.getString("customerEmail"));
                    sr.setCustomerPhone(rs.getString("customerPhone"));
                    sr.setContractType(rs.getString("contractType"));
                    sr.setContractStatus(rs.getString("contractStatus"));
                    sr.setEquipmentModel(rs.getString("equipmentModel"));
                    sr.setEquipmentDescription(rs.getString("equipmentDescription"));
                    sr.setSerialNumber(rs.getString("serialNumber"));
                    sr.setTechnicianName(rs.getString("technicianName"));

                    list.add(sr);
                }
            }
        }
        return list;
    }

// Đếm tổng số bản ghi ServiceRequest
    public int countAllRequests() throws SQLException {
        String sql = "SELECT COUNT(*) FROM ServiceRequest";
        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }

    public List<ServiceRequest> filterRequestsPaged(String keyword, String status, String requestType,
            String priority, String fromDate, String toDate,
            int offset, int limit) throws SQLException {
        List<ServiceRequest> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder("""
        SELECT sr.*, 
               a.fullName AS customerName, a.email AS customerEmail, a.phone AS customerPhone,
               c.contractType, c.status AS contractStatus,
               e.model AS equipmentModel, e.serialNumber, e.description AS equipmentDescription,
               tech.fullName AS technicianName
        FROM ServiceRequest sr
        LEFT JOIN Account a ON sr.createdBy = a.accountId
        LEFT JOIN Contract c ON sr.contractId = c.contractId
        LEFT JOIN Equipment e ON sr.equipmentId = e.equipmentId
        LEFT JOIN RequestApproval ra ON sr.requestId = ra.requestId
        LEFT JOIN Account tech ON ra.assignedTechnicianId = tech.accountId
        WHERE 1=1
    """);

        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.isEmpty()) {
            sql.append(" AND (a.fullName LIKE ? OR e.model LIKE ? OR sr.description LIKE ? OR c.contractId LIKE ?)");
            String like = "%" + keyword + "%";
            params.add(like);
            params.add(like);
            params.add(like);
            params.add(like);
        }
        if (status != null && !status.isEmpty()) {
            sql.append(" AND sr.status = ?");
            params.add(status);
        }
        if (requestType != null && !requestType.isEmpty()) {
            sql.append(" AND sr.requestType = ?");
            params.add(requestType);
        }
        if (priority != null && !priority.isEmpty()) {
            sql.append(" AND sr.priorityLevel = ?");
            params.add(priority);
        }
        if (fromDate != null && !fromDate.isEmpty()) {
            sql.append(" AND DATE(sr.requestDate) >= ?");
            params.add(fromDate);
        }
        if (toDate != null && !toDate.isEmpty()) {
            sql.append(" AND DATE(sr.requestDate) <= ?");
            params.add(toDate);
        }

        sql.append(" ORDER BY sr.requestDate DESC LIMIT ? OFFSET ?");
        params.add(limit);
        params.add(offset);

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ServiceRequest sr = new ServiceRequest();
                    sr.setRequestId(rs.getInt("requestId"));
                    sr.setContractId(rs.getInt("contractId"));
                    sr.setEquipmentId(rs.getInt("equipmentId"));
                    sr.setCreatedBy(rs.getInt("createdBy"));
                    sr.setDescription(rs.getString("description"));
                    sr.setPriorityLevel(rs.getString("priorityLevel"));
                    sr.setRequestDate(rs.getTimestamp("requestDate"));
                    sr.setStatus(rs.getString("status"));
                    sr.setRequestType(rs.getString("requestType"));

                    sr.setCustomerName(rs.getString("customerName"));
                    sr.setCustomerEmail(rs.getString("customerEmail"));
                    sr.setCustomerPhone(rs.getString("customerPhone"));
                    sr.setContractType(rs.getString("contractType"));
                    sr.setContractStatus(rs.getString("contractStatus"));
                    sr.setEquipmentModel(rs.getString("equipmentModel"));
                    sr.setEquipmentDescription(rs.getString("equipmentDescription"));
                    sr.setSerialNumber(rs.getString("serialNumber"));
                    sr.setTechnicianName(rs.getString("technicianName"));

                    list.add(sr);
                }
            }
        }

        return list;
    }

    public int countFilteredRequests(String keyword, String status, String requestType,
            String priority, String fromDate, String toDate) throws SQLException {
        int total = 0;

        StringBuilder sql = new StringBuilder("""
        SELECT COUNT(*) 
        FROM ServiceRequest sr
        LEFT JOIN Account a ON sr.createdBy = a.accountId
        LEFT JOIN Contract c ON sr.contractId = c.contractId
        LEFT JOIN Equipment e ON sr.equipmentId = e.equipmentId
        LEFT JOIN RequestApproval ra ON sr.requestId = ra.requestId
        LEFT JOIN Account tech ON ra.assignedTechnicianId = tech.accountId
        WHERE 1=1
    """);

        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.isEmpty()) {
            sql.append(" AND (a.fullName LIKE ? OR e.model LIKE ? OR sr.description LIKE ? OR c.contractId LIKE ?)");
            String like = "%" + keyword + "%";
            params.add(like);
            params.add(like);
            params.add(like);
            params.add(like);
        }
        if (status != null && !status.isEmpty()) {
            sql.append(" AND sr.status = ?");
            params.add(status);
        }
        if (requestType != null && !requestType.isEmpty()) {
            sql.append(" AND sr.requestType = ?");
            params.add(requestType);
        }
        if (priority != null && !priority.isEmpty()) {
            sql.append(" AND sr.priorityLevel = ?");
            params.add(priority);
        }
        if (fromDate != null && !fromDate.isEmpty()) {
            sql.append(" AND DATE(sr.requestDate) >= ?");
            params.add(fromDate);
        }
        if (toDate != null && !toDate.isEmpty()) {
            sql.append(" AND DATE(sr.requestDate) <= ?");
            params.add(toDate);
        }

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    total = rs.getInt(1);
                }
            }
        }

        return total;
    }

    public void updateStatus(int requestId, String status) throws SQLException {
        String sql = "UPDATE ServiceRequest SET status = ? WHERE requestId = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, requestId);
            ps.executeUpdate();
        }
    }

    /**
     * Search service requests by equipment name and description only
     */
    /**
     * Search service requests by equipment name and description only
     *
     * @param keyword
     */
    /**
     * Search service requests by equipment name and description only
     *
     * @param customerId
     * @param keyword
     */
    /**
     * Search service requests by equipment name and description only
     *
     * @param customerId
     * @param keyword
     * @return
     */
    public List<ServiceRequest> searchRequestsByEquipmentAndDescription(int customerId, String keyword) {
        List<ServiceRequest> list = new ArrayList<>();

        String sql = "SELECT sr.*, e.model as equipmentName "
                + "FROM ServiceRequest sr "
                + "LEFT JOIN Equipment e ON sr.equipmentId = e.equipmentId "
                + "WHERE sr.createdBy = ? "
                + "AND (e.model LIKE ? OR sr.description LIKE ?) "
                + "ORDER BY sr.requestDate DESC";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            String searchPattern = "%" + keyword + "%";
            ps.setString(2, searchPattern);
            ps.setString(3, searchPattern);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ServiceRequest sr = mapResultSetToServiceRequest(rs);
                    list.add(sr);
                }
            }
        } catch (SQLException e) {
            System.out.println("❌ Error searching requests: " + e.getMessage());
            e.printStackTrace();
        }

        return list;

    }

    // ============ QUOTATION & REPAIR INFO METHODS ============
    /**
     * Lấy thông tin báo giá (RepairReport) cho một Service Request Dùng cho
     * modal "Đang Xử Lý" - hiển thị báo giá
     */
    public RepairReport getRepairReportByRequestId(int requestId) {
        String sql = "SELECT rr.*, "
                + "a.fullName as technicianName "
                + "FROM RepairReport rr "
                + "LEFT JOIN Account a ON rr.technicianId = a.accountId "
                + "WHERE rr.requestId = ?";

        try {
            ps = con.prepareStatement(sql);
            ps.setInt(1, requestId);
            rs = ps.executeQuery();

            if (rs.next()) {
                RepairReport report = new RepairReport();
                report.setReportId(rs.getInt("reportId"));
                report.setRequestId(rs.getInt("requestId"));

                // Handle nullable technicianId
                int techId = rs.getInt("technicianId");
                if (!rs.wasNull()) {
                    report.setTechnicianId(techId);
                }

                report.setDetails(rs.getString("details"));
                report.setDiagnosis(rs.getString("diagnosis"));
                report.setEstimatedCost(rs.getBigDecimal("estimatedCost"));
                report.setQuotationStatus(rs.getString("quotationStatus"));

                // ✅ Convert SQL Date to LocalDate
                java.sql.Date sqlDate = rs.getDate("repairDate");
                if (sqlDate != null) {
                    report.setRepairDate(sqlDate.toLocalDate());
                }

                // Thông tin người sửa
                report.setTechnicianName(rs.getString("technicianName"));

                return report;
            }
        } catch (Exception e) {
            System.err.println("❌ Error getting repair report: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return null;
    }

    /**
     * Lấy tên người xử lý (Assigned Technician) từ RequestApproval Dùng cho
     * modal "Chờ Xử Lý"
     */
    public String getAssignedTechnicianName(int requestId) {
        String sql = "SELECT a.fullName "
                + "FROM RequestApproval ra "
                + "INNER JOIN Account a ON ra.assignedTechnicianId = a.accountId "
                + "WHERE ra.requestId = ?";

        try {
            ps = con.prepareStatement(sql);
            ps.setInt(1, requestId);
            rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getString("fullName");
            }
        } catch (Exception e) {
            System.err.println("❌ Error getting technician name: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return null;
    }

    /**
     * Lấy đầy đủ thông tin Service Request + Báo giá (nếu có) + Người xử lý
     * Dùng cho modal "Chi Tiết" tùy theo trạng thái
     */
    public ServiceRequestWithQuotation getRequestWithQuotation(int requestId, int customerId) {
        String sql = "SELECT sr.*, "
                + "e.model as equipmentName, "
                + "ra.assignedTechnicianId, "
                + "tech.fullName as assignedTechnicianName, "
                + "rr.reportId, rr.technicianId as repairTechnicianId, "
                + "rr.details as repairDetails, rr.diagnosis, "
                + "rr.estimatedCost, rr.quotationStatus, rr.repairDate "
                + "FROM ServiceRequest sr "
                + "LEFT JOIN Equipment e ON sr.equipmentId = e.equipmentId "
                + "LEFT JOIN RequestApproval ra ON sr.requestId = ra.requestId "
                + "LEFT JOIN Account tech ON ra.assignedTechnicianId = tech.accountId "
                + "LEFT JOIN RepairReport rr ON sr.requestId = rr.requestId "
                + "WHERE sr.requestId = ? AND sr.createdBy = ?";

        try {
            ps = con.prepareStatement(sql);
            ps.setInt(1, requestId);
            ps.setInt(2, customerId);
            rs = ps.executeQuery();

            if (rs.next()) {
                ServiceRequestWithQuotation result = new ServiceRequestWithQuotation();

                // ✅ Service Request info
                ServiceRequest sr = mapResultSetToServiceRequest(rs);
                result.setServiceRequest(sr);

                // ✅ Technician info (for "Chờ Xử Lý" state)
                result.setAssignedTechnicianName(rs.getString("assignedTechnicianName"));

                // ✅ Repair Report info (for "Đang Xử Lý" state)
                if (rs.getObject("reportId") != null) {
                    RepairReport report = new RepairReport();
                    report.setReportId(rs.getInt("reportId"));
                    report.setRequestId(requestId);

                    // Handle nullable technicianId
                    int techId = rs.getInt("repairTechnicianId");
                    if (!rs.wasNull()) {
                        report.setTechnicianId(techId);
                    }

                    report.setDetails(rs.getString("repairDetails"));
                    report.setDiagnosis(rs.getString("diagnosis"));
                    report.setEstimatedCost(rs.getBigDecimal("estimatedCost"));
                    report.setQuotationStatus(rs.getString("quotationStatus"));

                    // ✅ Convert SQL Date to LocalDate
                    java.sql.Date sqlDate = rs.getDate("repairDate");
                    if (sqlDate != null) {
                        report.setRepairDate(sqlDate.toLocalDate());
                    }

                    report.setTechnicianName(rs.getString("assignedTechnicianName"));
                    result.setRepairReport(report);
                }

                return result;
            }
        } catch (Exception e) {
            System.err.println("❌ Error getting request with quotation: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return null;
    }

    // ============ INNER CLASS FOR COMBINED DATA ============
    /**
     * Class kết hợp ServiceRequest + RepairReport + Technician info Dùng để trả
     * về đầy đủ thông tin cho modal "Chi Tiết"
     */
    public static class ServiceRequestWithQuotation {

        private ServiceRequest serviceRequest;
        private RepairReport repairReport;
        private String assignedTechnicianName;

        public ServiceRequest getServiceRequest() {
            return serviceRequest;
        }

        public void setServiceRequest(ServiceRequest serviceRequest) {
            this.serviceRequest = serviceRequest;
        }

        public RepairReport getRepairReport() {
            return repairReport;
        }

        public void setRepairReport(RepairReport repairReport) {
            this.repairReport = repairReport;
        }

        public String getAssignedTechnicianName() {
            return assignedTechnicianName;
        }

        public void setAssignedTechnicianName(String assignedTechnicianName) {
            this.assignedTechnicianName = assignedTechnicianName;
        }
    }

}
