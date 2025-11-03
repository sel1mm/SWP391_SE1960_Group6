package dal;

import model.ContractAppendix;
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
                + "effectiveDate, totalAmount, status, fileAttachment, createdBy, createdAt) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())";

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
            ps.setInt(9, createdBy);

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
    // ✅ Lấy danh sách phụ lục theo contractId
    public List<ContractAppendix> getAppendixesByContractId(int contractId) throws SQLException {
        List<ContractAppendix> list = new ArrayList<>();

        String sql = "SELECT ca.*, "
                + "COUNT(cae.equipmentId) as equipmentCount, "
                + "DATEDIFF(NOW(), ca.createdAt) as daysPassed "
                + "FROM ContractAppendix ca "
                + "LEFT JOIN ContractAppendixEquipment cae ON ca.appendixId = cae.appendixId "
                + "WHERE ca.contractId = ? "
                + "GROUP BY ca.appendixId "
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

                    // XỬ LÝ LocalDate
                    Date effectiveDate = rs.getDate("effectiveDate");
                    if (effectiveDate != null) {
                        appendix.setEffectiveDate(effectiveDate.toLocalDate());
                    }

                    appendix.setTotalAmount(rs.getDouble("totalAmount"));
                    appendix.setStatus(rs.getString("status"));
                    appendix.setFileAttachment(rs.getString("fileAttachment"));
                    appendix.setEquipmentCount(rs.getInt("equipmentCount"));

                    // Kiểm tra xem có thể edit không (trong vòng 15 ngày)
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
        String sql = "SELECT * FROM ContractAppendix WHERE appendixId = ?";

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

                    // XỬ LÝ LocalDate
                    Date effectiveDate = rs.getDate("effectiveDate");
                    if (effectiveDate != null) {
                        appendix.setEffectiveDate(effectiveDate.toLocalDate());
                    }

                    appendix.setTotalAmount(rs.getDouble("totalAmount"));
                    appendix.setStatus(rs.getString("status"));
                    appendix.setFileAttachment(rs.getString("fileAttachment"));
                    appendix.setCreatedBy(rs.getInt("createdBy"));

                    Timestamp createdAt = rs.getTimestamp("createdAt");
                    if (createdAt != null) {
                        appendix.setCreatedAt(createdAt.toLocalDateTime());
                    }

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
}
