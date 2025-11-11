package dal;

import model.ContractAppendix;
import model.RepairReportDetail;
import dal.RepairReportDAO;
import dal.PartDetailDAO;
import java.sql.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ContractAppendixDAO extends DBContext {

    // ✅ Tạo phụ lục hợp đồng mới
    public int createAppendix(int contractId, String appendixType, String appendixName,
            String description, LocalDate effectiveDate, double totalAmount,
            String status, String fileAttachment, int createdBy) throws SQLException {

        String sql = "INSERT INTO ContractAppendix (contractId, appendixType, appendixName, description, "
                + "effectiveDate, totalAmount, status, fileAttachment, warrantyCovered, warrantyReportId, createdBy, createdAt) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())";

        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, contractId);
            ps.setString(2, appendixType);
            ps.setString(3, appendixName);
            ps.setString(4, description);

            // Chuyển LocalDate thành java.sql.Date
            if (effectiveDate != null) {
                ps.setDate(5, java.sql.Date.valueOf(effectiveDate));
            } else {
                ps.setDate(5, java.sql.Date.valueOf(LocalDate.now()));
            }

            ps.setDouble(6, 0.0); // totalAmount luôn = 0
            ps.setString(7, status);
            ps.setString(8, fileAttachment);
            ps.setBoolean(9, false);
            ps.setNull(10, java.sql.Types.INTEGER);
            ps.setInt(11, createdBy);

            ps.executeUpdate();

            ResultSet rs = ps.getGeneratedKeys();
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }

    // ✅ Thêm thiết bị vào phụ lục
    public void addEquipmentToAppendix(int appendixId, int equipmentId, Double unitPrice, String note) throws SQLException {
        String sql = "INSERT INTO ContractAppendixEquipment (appendixId, equipmentId, unitPrice, note) "
                + "VALUES (?, ?, ?, ?)";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, appendixId);
            ps.setInt(2, equipmentId);

            // Xử lý unitPrice có thể null
            if (unitPrice == null) {
                ps.setNull(3, java.sql.Types.DOUBLE);
            } else {
                ps.setDouble(3, unitPrice);
            }

            // Xử lý note có thể null
            if (note == null || note.trim().isEmpty()) {
                ps.setNull(4, java.sql.Types.VARCHAR);
            } else {
                ps.setString(4, note);
            }

            ps.executeUpdate();
        }
    }

    // ✅ Lấy danh sách phụ lục theo contractId
    public List<ContractAppendix> getAppendixesByContractId(int contractId) throws SQLException {
        List<ContractAppendix> list = new ArrayList<>();

        String sql = "SELECT ca.*, "
                + "(SELECT COUNT(*) FROM ContractAppendixEquipment WHERE appendixId = ca.appendixId) AS equipmentCount, "
                + "(SELECT COUNT(*) FROM ContractAppendixPart WHERE appendixId = ca.appendixId) AS partCount, "
                + "DATEDIFF(NOW(), ca.createdAt) AS daysPassed "
                + "FROM ContractAppendix ca "
                + "WHERE ca.contractId = ? "
                + "ORDER BY ca.createdAt DESC";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, contractId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ContractAppendix appendix = new ContractAppendix();
                    appendix.setAppendixId(rs.getInt("appendixId"));
                    appendix.setContractId(rs.getInt("contractId"));
                    appendix.setAppendixType(rs.getString("appendixType"));
                    appendix.setAppendixName(rs.getString("appendixName"));
                    appendix.setDescription(rs.getString("description"));

                    // ✅ Xử lý LocalDate
                    Date effectiveDate = rs.getDate("effectiveDate");
                    if (effectiveDate != null) {
                        appendix.setEffectiveDate(effectiveDate.toLocalDate());
                    }

                    appendix.setTotalAmount(rs.getDouble("totalAmount"));
                    appendix.setStatus(rs.getString("status"));
                    appendix.setFileAttachment(rs.getString("fileAttachment"));
                    appendix.setEquipmentCount(rs.getInt("equipmentCount"));
                    appendix.setPartCount(rs.getInt("partCount"));
                    appendix.setWarrantyCovered(rs.getBoolean("warrantyCovered"));
                    int warrantyReport = rs.getInt("warrantyReportId");
                    if (!rs.wasNull()) {
                        appendix.setWarrantyReportId(warrantyReport);
                    }

                    // ✅ Kiểm tra xem có thể edit không (trong vòng 15 ngày)
                    int daysPassed = rs.getInt("daysPassed");
                    appendix.setCanEdit(daysPassed <= 15);

                    Timestamp createdAt = rs.getTimestamp("createdAt");
                    if (createdAt != null) {
                        appendix.setCreatedAt(createdAt.toLocalDateTime());
                    }

                    list.add(appendix);
                }
            }
        }

        return list;
    }

    // ✅ Lấy danh sách thiết bị trong phụ lục
    // ✅ Lấy danh sách thiết bị trong phụ lục - FIX: Lấy tất cả, không LIMIT 1
    public List<Map<String, Object>> getEquipmentByAppendixId(int appendixId) throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();

        String sql = "SELECT e.equipmentId, e.model, e.serialNumber, e.description, "
                + "cae.unitPrice, cae.note "
                + "FROM ContractAppendixEquipment cae "
                + "JOIN Equipment e ON cae.equipmentId = e.equipmentId "
                + "WHERE cae.appendixId = ? "
                + "ORDER BY e.model, e.serialNumber";  // XÓA LIMIT 1

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, appendixId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {  // Đổi từ if sang while
                    Map<String, Object> equipment = new HashMap<>();
                    equipment.put("equipmentId", rs.getInt("equipmentId"));
                    equipment.put("model", rs.getString("model"));
                    equipment.put("serialNumber", rs.getString("serialNumber"));
                    equipment.put("description", rs.getString("description"));

                    Double unitPrice = rs.getDouble("unitPrice");
                    if (!rs.wasNull()) {
                        equipment.put("unitPrice", unitPrice);
                    }

                    String note = rs.getString("note");
                    if (note != null) {
                        equipment.put("note", note);
                    }

                    list.add(equipment);
                }
            }
        }

        return list;
    }

// ✅ Đếm số lượng thiết bị trong phụ lục
    public int countEquipmentInAppendix(int appendixId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM ContractAppendixEquipment WHERE appendixId = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, appendixId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }

        return 0;
    }

    // ✅ Đếm số lượng thiết bị trong phụ lục
    public int getEquipmentCountByAppendix(int appendixId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM ContractAppendixEquipment WHERE appendixId = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, appendixId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }

        return 0;
    }

    // ✅ Xóa phụ lục (nếu cần)
//    public boolean deleteAppendix(int appendixId) throws SQLException {
//        // Xóa thiết bị trong phụ lục trước
//        String sql1 = "DELETE FROM ContractAppendixEquipment WHERE appendixId = ?";
//        try (PreparedStatement ps = connection.prepareStatement(sql1)) {
//            ps.setInt(1, appendixId);
//            ps.executeUpdate();
//        }
//
//        // Xóa phụ lục
//        String sql2 = "DELETE FROM ContractAppendix WHERE appendixId = ?";
//        try (PreparedStatement ps = connection.prepareStatement(sql2)) {
//            ps.setInt(1, appendixId);
//            return ps.executeUpdate() > 0;
//        }
//    }
    // ✅ Cập nhật trạng thái phụ lục
    public boolean updateAppendixStatus(int appendixId, String status) throws SQLException {
        String sql = "UPDATE ContractAppendix SET status = ? WHERE appendixId = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, appendixId);
            return ps.executeUpdate() > 0;
        }
    }

    // ✅ Kiểm tra xem phụ lục có thể chỉnh sửa không (trong vòng 15 ngày)
    public boolean canEditAppendix(int appendixId) throws SQLException {
        String sql = "SELECT DATEDIFF(NOW(), createdAt) as daysPassed "
                + "FROM ContractAppendix WHERE appendixId = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, appendixId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int daysPassed = rs.getInt("daysPassed");
                    return daysPassed <= 15;
                }
            }
        }

        return false;
    }

// ✅ Cập nhật phụ lục
    public boolean updateAppendix(int appendixId, String appendixType, String appendixName,
            String description, LocalDate effectiveDate,
            String status, String fileAttachment) throws SQLException {

        String sql = "UPDATE ContractAppendix SET "
                + "appendixType = ?, "
                + "appendixName = ?, "
                + "description = ?, "
                + "effectiveDate = ?, "
                + "status = ?, "
                + "fileAttachment = ?, "
                + "createdAt = NOW() "
                + // ← GHI ĐÈ createdAt thay vì updatedAt
                "WHERE appendixId = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, appendixType);
            ps.setString(2, appendixName);
            ps.setString(3, description);
            ps.setDate(4, java.sql.Date.valueOf(effectiveDate));
            ps.setString(5, status);
            ps.setString(6, fileAttachment);
            ps.setInt(7, appendixId);

            int rowsAffected = ps.executeUpdate();
            System.out.println("Rows affected by update: " + rowsAffected);

            return rowsAffected > 0;
        }
    }

// ✅ Xóa phụ lục (và các thiết bị liên quan)
    public boolean deleteAppendix(int appendixId) throws SQLException {
        // Xóa thiết bị trong phụ lục trước
        String deleteEquipmentSql = "DELETE FROM ContractAppendixEquipment WHERE appendixId = ?";
        try (PreparedStatement ps = connection.prepareStatement(deleteEquipmentSql)) {
            ps.setInt(1, appendixId);
            ps.executeUpdate();
        }

        // Xóa phụ lục
        String deleteAppendixSql = "DELETE FROM ContractAppendix WHERE appendixId = ?";
        try (PreparedStatement ps = connection.prepareStatement(deleteAppendixSql)) {
            ps.setInt(1, appendixId);
            return ps.executeUpdate() > 0;
        }
    }

// ✅ Lấy thông tin chi tiết phụ lục để edit
    public ContractAppendix getAppendixById(int appendixId) throws SQLException {
        String sql = """
        SELECT a.*, 
               COUNT(cae.equipmentId) AS equipmentCount
        FROM ContractAppendix a
        LEFT JOIN ContractAppendixEquipment cae 
               ON a.appendixId = cae.appendixId
        WHERE a.appendixId = ?
        GROUP BY a.appendixId
    """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, appendixId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    ContractAppendix appendix = new ContractAppendix();
                    appendix.setAppendixId(rs.getInt("appendixId"));
                    appendix.setContractId(rs.getInt("contractId"));
                    appendix.setAppendixType(rs.getString("appendixType"));
                    appendix.setAppendixName(rs.getString("appendixName"));
                    appendix.setDescription(rs.getString("description"));

                    Date effectiveDate = rs.getDate("effectiveDate");
                    if (effectiveDate != null) {
                        appendix.setEffectiveDate(effectiveDate.toLocalDate());
                    }

                    appendix.setTotalAmount(rs.getDouble("totalAmount"));
                    appendix.setStatus(rs.getString("status"));
                    appendix.setFileAttachment(rs.getString("fileAttachment"));
                    appendix.setCreatedBy(rs.getInt("createdBy"));
                    appendix.setWarrantyCovered(rs.getBoolean("warrantyCovered"));
                    int warrantyReport = rs.getInt("warrantyReportId");
                    if (!rs.wasNull()) {
                        appendix.setWarrantyReportId(warrantyReport);
                    }

                    Timestamp createdAt = rs.getTimestamp("createdAt");
                    if (createdAt != null) {
                        appendix.setCreatedAt(createdAt.toLocalDateTime());
                    }

                    // ✅ Bổ sung dòng này
                    appendix.setEquipmentCount(rs.getInt("equipmentCount"));

                    return appendix;
                }
            }
        }
        return null;
    }

    // ✅ Xóa tất cả thiết bị trong phụ lục (để update lại)
    public void removeAllEquipmentFromAppendix(int appendixId) throws SQLException {
        String sql = "DELETE FROM ContractAppendixEquipment WHERE appendixId = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, appendixId);
            ps.executeUpdate();
        }
    }

    /**
     * Append repair report parts to contract as an appendix. This method is
     * called when a repair report is approved.
     *
     * Business rule: If contractId is provided, use it. Otherwise, find the
     * latest Active contract for the equipment/customer associated with the
     * report's ServiceRequest.
     *
     * @param reportId The repair report ID
     * @param contractId Optional contract ID (if null, will be discovered from
     * ServiceRequest)
     * @return The created appendix ID, or 0 if failed
     * @throws SQLException If database error occurs or parts are no longer
     * available
     */
    public int appendReportPartsToContract(int reportId, Integer contractId) throws SQLException {
        boolean originalAutoCommit = connection.getAutoCommit();

        try {
            connection.setAutoCommit(false);

            // Get repair report details
            RepairReportDAO reportDAO = new RepairReportDAO();
            List<RepairReportDetail> details = reportDAO.getReportDetails(reportId);

            if (details == null || details.isEmpty()) {
                System.out.println("⚠️ No parts found in repair report " + reportId);
                connection.rollback();
                return 0;
            }

            // Get ServiceRequest info to find contract and equipment
            String sql = "SELECT sr.contractId, sr.equipmentId, sr.createdBy, sr.requestType "
                    + "FROM ServiceRequest sr "
                    + "JOIN RepairReport rr ON sr.requestId = rr.requestId "
                    + "WHERE rr.reportId = ?";

            Integer finalContractId = contractId;
            Integer equipmentId = null;
            Integer customerId = null;
            String requestType = null;
            boolean isWarranty = false;

            try (PreparedStatement ps = connection.prepareStatement(sql)) {
                ps.setInt(1, reportId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        if (finalContractId == null) {
                            Integer srContractId = rs.getObject("contractId", Integer.class);
                            finalContractId = srContractId;
                        }
                        equipmentId = rs.getObject("equipmentId", Integer.class);
                        customerId = rs.getInt("createdBy");
                        requestType = rs.getString("requestType");
                        if (requestType != null && requestType.equalsIgnoreCase("Warranty")) {
                            isWarranty = true;
                        }
                    } else {
                        connection.rollback();
                        throw new SQLException("Repair report " + reportId + " not found or not linked to ServiceRequest");
                    }
                }
            }

            // If contractId still not found, find latest Active contract for this equipment/customer
            if (finalContractId == null && equipmentId != null && customerId != null) {
                sql = "SELECT c.contractId "
                        + "FROM Contract c "
                        + "JOIN ContractEquipment ce ON c.contractId = ce.contractId "
                        + "WHERE c.customerId = ? AND ce.equipmentId = ? AND c.status = 'Active' "
                        + "ORDER BY c.createdDate DESC, c.contractId DESC "
                        + "LIMIT 1";

                try (PreparedStatement ps = connection.prepareStatement(sql)) {
                    ps.setInt(1, customerId);
                    ps.setInt(2, equipmentId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            finalContractId = rs.getInt("contractId");
                            System.out.println("✅ Found latest Active contract: " + finalContractId);
                        }
                    }
                }
            }

            if (finalContractId == null) {
                connection.rollback();
                throw new SQLException("Cannot determine contract for repair report " + reportId
                        + ". Please specify contractId or ensure ServiceRequest has valid contract/equipment.");
            }

            // Verify contract exists and belongs to correct customer
            sql = "SELECT customerId, status FROM Contract WHERE contractId = ?";
            try (PreparedStatement ps = connection.prepareStatement(sql)) {
                ps.setInt(1, finalContractId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        connection.rollback();
                        throw new SQLException("Contract " + finalContractId + " not found");
                    }
                    String contractStatus = rs.getString("status");
                    if (!"Active".equals(contractStatus)) {
                        System.out.println("⚠️ Contract " + finalContractId + " is not Active (status: " + contractStatus + ")");
                        // Continue anyway, but log warning
                    }
                }
            }

            // Check if report has already been appended (prevent duplicates)
            sql = "SELECT COUNT(*) FROM ContractAppendixPart WHERE repairReportId = ?";
            try (PreparedStatement ps = connection.prepareStatement(sql)) {
                ps.setInt(1, reportId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        connection.rollback();
                        throw new SQLException("Repair report " + reportId + " has already been appended to a contract");
                    }
                }
            }

            // Validate all parts are still available and lock them
            PartDetailDAO partDetailDAO = new PartDetailDAO();
            List<Integer> partDetailIdsToUpdate = new ArrayList<>();

            for (RepairReportDetail detail : details) {
                // Validate quantity
                int availableQty = partDetailDAO.getAvailableQuantityForPart(detail.getPartId());
                if (detail.getQuantity() > availableQty) {
                    connection.rollback();
                    throw new SQLException("Part " + detail.getPartId() + " (" + detail.getPartName()
                            + ") has insufficient quantity. Required: " + detail.getQuantity()
                            + ", Available: " + availableQty);
                }

                // If partDetailId is specified, validate and lock it
                if (detail.getPartDetailId() != null) {
                    var partDetail = partDetailDAO.lockAndValidatePartDetail(detail.getPartDetailId());
                    if (partDetail == null) {
                        connection.rollback();
                        throw new SQLException("PartDetail " + detail.getPartDetailId() + " is not available");
                    }
                    partDetailIdsToUpdate.add(detail.getPartDetailId());
                }
            }

            // Calculate total amount
            double totalAmount = details.stream()
                    .mapToDouble(d -> d.getUnitPrice().multiply(java.math.BigDecimal.valueOf(d.getQuantity())).doubleValue())
                    .sum();
            double appendixAmount = isWarranty ? 0 : totalAmount;

            // Create ContractAppendix
            sql = "INSERT INTO ContractAppendix (contractId, appendixType, appendixName, description, "
                    + "effectiveDate, totalAmount, status, warrantyCovered, warrantyReportId, createdBy, createdAt) "
                    + "VALUES (?, 'RepairPart', ?, ?, CURDATE(), ?, 'Approved', ?, ?, ?, NOW())";

            String appendixName = isWarranty
                    ? "Warranty Parts from Report #" + reportId
                    : "Repair Parts from Report #" + reportId;
            String description = isWarranty
                    ? "Warranty-covered parts automatically added when repair report #" + reportId + " was approved"
                    : "Parts automatically added when repair report #" + reportId + " was approved";

            int appendixId;
            try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, finalContractId);
                ps.setString(2, appendixName);
                ps.setString(3, description);
                ps.setBigDecimal(4, java.math.BigDecimal.valueOf(appendixAmount));
                ps.setBoolean(5, isWarranty);
                ps.setInt(6, reportId);
                ps.setInt(7, customerId != null ? customerId : 1); // Use customerId or default

                ps.executeUpdate();
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        appendixId = rs.getInt(1);
                    } else {
                        connection.rollback();
                        throw new SQLException("Failed to create ContractAppendix");
                    }
                }
            }

            // Insert ContractAppendixPart rows and update PartDetail status
            sql = "INSERT INTO ContractAppendixPart (appendixId, equipmentId, partId, quantity, unitPrice, "
                    + "repairReportId, paymentStatus, approvedByCustomer, approvalDate, note) "
                    + "VALUES (?, ?, ?, ?, ?, ?, 'Paid', TRUE, NOW(), ?)";

            try (PreparedStatement ps = connection.prepareStatement(sql)) {
                for (RepairReportDetail detail : details) {
                    ps.setInt(1, appendixId);
                    ps.setInt(2, equipmentId != null ? equipmentId : 0); // May be null, use 0 as placeholder
                    ps.setInt(3, detail.getPartId());
                    ps.setInt(4, detail.getQuantity());
                    ps.setBigDecimal(5, detail.getUnitPrice());
                    ps.setInt(6, reportId);
                    ps.setString(7, isWarranty
                            ? "Warranty-covered part (no customer charge) auto-added from report #" + reportId
                            : "Auto-added from approved repair report #" + reportId);
                    ps.addBatch();
                }
                ps.executeBatch();
            }

            // Update PartDetail status to 'InUse' for specified partDetailIds
            if (!partDetailIdsToUpdate.isEmpty()) {
                int updated = partDetailDAO.markPartDetailsAsInUse(partDetailIdsToUpdate, customerId != null ? customerId : 1);
                if (updated != partDetailIdsToUpdate.size()) {
                    System.out.println("⚠️ Warning: Only " + updated + " of " + partDetailIdsToUpdate.size()
                            + " PartDetails were marked as InUse");
                }
            }

            connection.commit();
            System.out.println("✅ Successfully appended repair report " + reportId + " to contract " + finalContractId);
            return appendixId;

        } catch (SQLException e) {
            connection.rollback();
            System.err.println("❌ Error appending report parts to contract: " + e.getMessage());
            throw e;
        } finally {
            connection.setAutoCommit(originalAutoCommit);
        }
    }

    public List<Map<String, Object>> getRepairPartsByAppendixId(int appendixId) throws SQLException {
        List<Map<String, Object>> partsList = new ArrayList<>();

        String sql = "SELECT "
                + "cap.appendixPartId, "
                + "cap.quantity, "
                + "cap.unitPrice, "
                + "cap.totalPrice, "
                + "cap.note, "
                + "cap.paymentStatus, "
                + "cap.approvalDate, "
                + "p.partId, "
                + "p.partName, "
                + "p.description AS partDescription, "
                + "e.equipmentId, "
                + "e.model AS equipmentModel, "
                + "e.serialNumber AS equipmentSerial, "
                + "rr.reportId "
                + "FROM ContractAppendixPart cap "
                + "JOIN Part p ON cap.partId = p.partId "
                + "JOIN Equipment e ON cap.equipmentId = e.equipmentId "
                + "LEFT JOIN RepairReport rr ON cap.repairReportId = rr.reportId "
                + "WHERE cap.appendixId = ? "
                + "ORDER BY e.equipmentId, p.partName";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, appendixId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> part = new HashMap<>();

                    part.put("appendixPartId", rs.getInt("appendixPartId"));
                    part.put("quantity", rs.getInt("quantity"));
                    part.put("unitPrice", rs.getDouble("unitPrice"));
                    part.put("totalPrice", rs.getDouble("totalPrice"));
                    part.put("note", rs.getString("note"));
                    part.put("paymentStatus", rs.getString("paymentStatus"));
                    part.put("approvalDate", rs.getTimestamp("approvalDate"));

                    part.put("partId", rs.getInt("partId"));
                    part.put("partName", rs.getString("partName"));
                    part.put("partDescription", rs.getString("partDescription"));

                    part.put("equipmentId", rs.getInt("equipmentId"));
                    part.put("equipmentModel", rs.getString("equipmentModel"));
                    part.put("equipmentSerial", rs.getString("equipmentSerial"));

                    part.put("reportId", rs.getObject("reportId"));

                    partsList.add(part);
                }
            }
        }

        return partsList;
    }

}
