package dal;

import model.Part;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import model.NewPart;

public class PartDAO extends DBContext {

    // CREATE: thêm mới một Part VÀ TẠO INVENTORY MẶC ĐỊNH
    public boolean addPart(NewPart part) {
        PreparedStatement psPart = null;
        PreparedStatement psInventory = null;
        
        try {
            connection.setAutoCommit(false);
            
            // 1. Thêm Part mới
            String sqlPart = "INSERT INTO Part (partName, description, unitPrice, lastUpdatedBy, lastUpdatedDate) "
                           + "VALUES (?, ?, ?, ?, ?)";
            psPart = connection.prepareStatement(sqlPart, Statement.RETURN_GENERATED_KEYS);
            psPart.setString(1, part.getPartName());
            psPart.setString(2, part.getDescription());
            psPart.setDouble(3, part.getUnitPrice());
            psPart.setInt(4, part.getLastUpdatedBy());
            
            if (part.getLastUpdatedDate() != null) {
                psPart.setDate(5, Date.valueOf(part.getLastUpdatedDate()));
            } else {
                psPart.setNull(5, Types.DATE);
            }
            
            int affectedRows = psPart.executeUpdate();
            
            if (affectedRows > 0) {
                // Lấy partId vừa tạo
                ResultSet rs = psPart.getGeneratedKeys();
                if (rs.next()) {
                    int newPartId = rs.getInt(1);
                    
                    // 2. Tạo Inventory với quantity = 0 (cột tồn tại nhưng không dùng, quantity thực sẽ tính từ PartDetail)
                    String sqlInventory = "INSERT INTO Inventory (partId, quantity, lastUpdatedBy, lastUpdatedDate) "
                                        + "VALUES (?, 0, ?, ?)";
                    psInventory = connection.prepareStatement(sqlInventory);
                    psInventory.setInt(1, newPartId);
                    psInventory.setInt(2, part.getLastUpdatedBy());
                    psInventory.setDate(3, Date.valueOf(LocalDate.now()));
                    psInventory.executeUpdate();
                    
                    connection.commit();
                    System.out.println("✅ Đã tạo Part ID=" + newPartId + " và Inventory (quantity = 0 trong DB, thực tế đếm từ PartDetail)");
                    return true;
                }
            }
            
            connection.rollback();
            return false;
            
        } catch (SQLException e) {
            try {
                connection.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            System.out.println("❌ Lỗi khi thêm Part và Inventory: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (psPart != null) psPart.close();
                if (psInventory != null) psInventory.close();
                connection.setAutoCommit(true);
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    // READ: lấy thông tin 1 part theo id
    public NewPart getPartById(int partId) {
        String sql = "SELECT * FROM Part WHERE partId = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, partId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    NewPart part = new NewPart();
                    part.setPartId(rs.getInt("partId"));
                    part.setPartName(rs.getString("partName"));
                    part.setDescription(rs.getString("description"));
                    part.setUnitPrice(rs.getDouble("unitPrice"));
                    part.setLastUpdatedBy(rs.getInt("lastUpdatedBy"));

                    Date date = rs.getDate("lastUpdatedDate");
                    if (date != null) {
                        part.setLastUpdatedDate(date.toLocalDate());
                    }

                    return part;
                }
            }
        } catch (SQLException e) {
            System.out.println("❌ Lỗi khi lấy Part theo ID: " + e.getMessage());
        }
        return null;
    }

    // READ ALL: lấy danh sách tất cả Part KÈM SỐ LƯỢNG TỪ PartDetail
    public List<NewPart> getAllParts() {
        List<NewPart> list = new ArrayList<>();
        String sql = "SELECT Part.partId, Part.partName, Part.description, Part.unitPrice, "
                   + "COALESCE(COUNT(PartDetail.partDetailId), 0) AS quantity, "
                   + "Part.lastUpdatedBy, Part.lastUpdatedDate, Account.username "
                   + "FROM Part "
                   + "JOIN Account ON Account.accountId = Part.lastUpdatedBy "
                   + "LEFT JOIN PartDetail ON PartDetail.partId = Part.partId "
                   + "GROUP BY Part.partId, Part.partName, Part.description, Part.unitPrice, "
                   + "         Part.lastUpdatedBy, Part.lastUpdatedDate, Account.username "
                   + "ORDER BY Part.partId";
        
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                NewPart part = new NewPart();
                part.setPartId(rs.getInt("partId"));
                part.setPartName(rs.getString("partName"));
                part.setDescription(rs.getString("description"));
                part.setUnitPrice(rs.getDouble("unitPrice"));
                part.setQuantity(rs.getInt("quantity"));  // ← THÊM QUANTITY
                part.setUserName(rs.getString("username"));

                Date date = rs.getDate("lastUpdatedDate");
                if (date != null) {
                    part.setLastUpdatedDate(date.toLocalDate());
                }

                list.add(part);
            }
            
            System.out.println("✅ Loaded " + list.size() + " parts with quantity");
        } catch (SQLException e) {
            System.out.println("❌ Lỗi khi lấy danh sách Part: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    // UPDATE: cập nhật thông tin part (KHÔNG CẬP NHẬT INVENTORY)
    public boolean updatePart(NewPart part) {
        String sql = "UPDATE Part SET partName = ?, description = ?, unitPrice = ?, "
                   + "lastUpdatedBy = ?, lastUpdatedDate = ? WHERE partId = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, part.getPartName());
            ps.setString(2, part.getDescription());
            ps.setDouble(3, part.getUnitPrice());
            ps.setInt(4, part.getLastUpdatedBy());

            if (part.getLastUpdatedDate() != null) {
                ps.setDate(5, Date.valueOf(part.getLastUpdatedDate()));
            } else {
                ps.setNull(5, Types.DATE);
            }

            ps.setInt(6, part.getPartId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.out.println("❌ Lỗi khi cập nhật Part: " + e.getMessage());
        }
        return false;
    }

    // DELETE: xóa part VÀ INVENTORY LIÊN QUAN
    public boolean deletePart(int partId) {
        PreparedStatement psInventory = null;
        PreparedStatement psPartDetail = null;
        PreparedStatement psPart = null;

        try {
            connection.setAutoCommit(false);

            // 1. Xóa Inventory
            psInventory = connection.prepareStatement("DELETE FROM Inventory WHERE partId = ?");
            psInventory.setInt(1, partId);
            psInventory.executeUpdate();

            // 2. Xóa PartDetail
            psPartDetail = connection.prepareStatement("DELETE FROM PartDetail WHERE partId = ?");
            psPartDetail.setInt(1, partId);
            psPartDetail.executeUpdate();

            // 3. Xóa Part
            psPart = connection.prepareStatement("DELETE FROM Part WHERE partId = ?");
            psPart.setInt(1, partId);
            int affected = psPart.executeUpdate();

            connection.commit();
            System.out.println("✅ Đã xóa Part ID=" + partId + " và Inventory liên quan");
            return affected > 0;

        } catch (SQLException e) {
            try {
                connection.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (psInventory != null) psInventory.close();
                if (psPartDetail != null) psPartDetail.close();
                if (psPart != null) psPart.close();
                connection.setAutoCommit(true);
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    // THÊM VÀO CLASS PartDAO (dal/PartDAO.java)

/**
 * Đếm số lượng PartDetail theo trạng thái cho một Part cụ thể
 * @param partId ID của Part
 * @return Map<String, Integer> với key là status và value là số lượng
 */
public java.util.Map<String, Integer> getPartStatusCount(int partId) {
    java.util.Map<String, Integer> statusCount = new java.util.HashMap<>();
    
    // Khởi tạo 4 trạng thái với giá trị 0
    statusCount.put("Available", 0);
    statusCount.put("Fault", 0);
    statusCount.put("InUse", 0);
    statusCount.put("Retired", 0);
    
    String sql = "SELECT status, COUNT(*) as count " +
                 "FROM PartDetail " +
                 "WHERE partId = ? " +
                 "GROUP BY status";
    
    try (PreparedStatement ps = connection.prepareStatement(sql)) {
        ps.setInt(1, partId);
        
        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String status = rs.getString("status");
                int count = rs.getInt("count");
                statusCount.put(status, count);
            }
        }
        
        System.out.println("✅ Loaded status count for partId: " + partId);
        System.out.println("   Available: " + statusCount.get("Available"));
        System.out.println("   Fault: " + statusCount.get("Fault"));
        System.out.println("   InUse: " + statusCount.get("InUse"));
        System.out.println("   Retired: " + statusCount.get("Retired"));
        
    } catch (SQLException e) {
        System.out.println("❌ Error getting status count: " + e.getMessage());
        e.printStackTrace();
    }
    
    return statusCount;
}
}