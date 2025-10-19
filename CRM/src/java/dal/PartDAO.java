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

    // READ ALL: lấy danh sách tất cả Part
    public List<NewPart> getAllParts() {
        List<NewPart> list = new ArrayList<>();
        String sql = "SELECT partId, partName, description, unitprice, username, lastUpdatedDate "
                   + "FROM Account JOIN Part ON Account.accountId = Part.lastUpdatedBy";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                NewPart part = new NewPart();
                part.setPartId(rs.getInt("partId"));
                part.setPartName(rs.getString("partName"));
                part.setDescription(rs.getString("description"));
                part.setUnitPrice(rs.getDouble("unitPrice"));
                part.setUserName(rs.getString("username"));

                Date date = rs.getDate("lastUpdatedDate");
                if (date != null) {
                    part.setLastUpdatedDate(date.toLocalDate());
                }

                list.add(part);
            }
        } catch (SQLException e) {
            System.out.println("❌ Lỗi khi lấy danh sách Part: " + e.getMessage());
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

    // TEST MAIN
    public static void main(String[] args) {
        PartDAO dao = new PartDAO();

        System.out.println("=== TEST THÊM PART MỚI (TỰ ĐỘNG TẠO INVENTORY) ===");
        NewPart newPart = new NewPart(0, "RAM 16GB DDR5", "Bộ nhớ máy tính", 120.0, 1, LocalDate.now(), "admin");
        boolean added = dao.addPart(newPart);
        System.out.println(added ? "✅ Thêm thành công!" : "❌ Thêm thất bại!");

        System.out.println("\n=== TEST LẤY DANH SÁCH PARTS ===");
        List<NewPart> parts = dao.getAllParts();
        for (NewPart p : parts) {
            System.out.println(p);
        }

        System.out.println("\n=== TEST CẬP NHẬT PART (KHÔNG ẢNH HƯỞNG INVENTORY) ===");
        if (!parts.isEmpty()) {
            NewPart part = parts.get(0);
            part.setDescription("Mô tả đã cập nhật");
            part.setUnitPrice(part.getUnitPrice() + 5);
            boolean updated = dao.updatePart(part);
            System.out.println(updated ? "✅ Cập nhật thành công!" : "❌ Cập nhật thất bại!");
        }

        System.out.println("\n=== TEST XÓA PART (TỰ ĐỘNG XÓA INVENTORY) ===");
        int deleteId = 10; // Thay ID phù hợp
        boolean deleted = dao.deletePart(deleteId);
        System.out.println(deleted ? "✅ Đã xóa part và inventory" : "❌ Không xóa được");
    }
}