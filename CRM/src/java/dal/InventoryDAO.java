package dal;

import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import model.NewInventory;

public class InventoryDAO extends DBContext {

    // Lấy toàn bộ danh sách inventory với quantity ĐỘNG (đếm từ PartDetail)
    public List<NewInventory> getAllInventories() {
        List<NewInventory> list = new ArrayList<>();
        String sql = "SELECT " +
                     "    Part.partId, " +
                     "    Inventory.inventoryId, " +
                     "    Part.partName, " +
                     "    COALESCE(COUNT(PartDetail.partDetailId), 0) AS quantity, " +
                     "    Account.username, " +
                     "    Inventory.lastUpdatedBy, " +
                     "    Inventory.lastUpdatedDate " +
                     "FROM Inventory " +
                     "JOIN Account ON Account.accountId = Inventory.lastUpdatedBy " +
                     "JOIN Part ON Part.partId = Inventory.partId " +
                     "LEFT JOIN PartDetail ON PartDetail.partId = Part.partId " +
                     "GROUP BY Part.partId, Inventory.inventoryId, Part.partName, " +
                     "         Account.username, Inventory.lastUpdatedBy, Inventory.lastUpdatedDate";
        
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                NewInventory inv = new NewInventory(
                        rs.getInt("inventoryId"),
                        rs.getInt("partId"),
                        rs.getInt("quantity"),  // Quantity được tính từ COUNT
                        rs.getInt("lastUpdatedBy"),
                        rs.getDate("lastUpdatedDate").toLocalDate(),
                        rs.getString("partName"),
                        rs.getString("username")
                );
                list.add(inv);
            }
            
            System.out.println("✅ Loaded " + list.size() + " inventories with dynamic quantity");

        } catch (SQLException e) {
            System.out.println("❌ getAllInventories error: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    // Lấy 1 inventory theo ID với quantity ĐỘNG
    public NewInventory getInventoryById(int id) {
        String sql = "SELECT " +
                     "    i.inventoryId, " +
                     "    i.partId, " +
                     "    COALESCE(COUNT(pd.partDetailId), 0) AS quantity, " +
                     "    i.lastUpdatedBy, " +
                     "    i.lastUpdatedDate, " +
                     "    p.partName, " +
                     "    a.username " +
                     "FROM Inventory i " +
                     "JOIN Part p ON i.partId = p.partId " +
                     "JOIN Account a ON i.lastUpdatedBy = a.accountId " +
                     "LEFT JOIN PartDetail pd ON pd.partId = p.partId " +
                     "WHERE i.inventoryId = ? " +
                     "GROUP BY i.inventoryId, i.partId, i.lastUpdatedBy, " +
                     "         i.lastUpdatedDate, p.partName, a.username";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return new NewInventory(
                        rs.getInt("inventoryId"),
                        rs.getInt("partId"),
                        rs.getInt("quantity"),  // Quantity động
                        rs.getInt("lastUpdatedBy"),
                        rs.getDate("lastUpdatedDate").toLocalDate(),
                        rs.getString("partName"),
                        rs.getString("username")
                );
            }
        } catch (SQLException e) {
            System.out.println("❌ getInventoryById error: " + e.getMessage());
        }
        return null;
    }

    // Thêm mới một inventory (KHÔNG CẦN quantity nữa)
    public void addInventory(NewInventory inv) {
        String sql = "INSERT INTO Inventory (partId, lastUpdatedBy, lastUpdatedDate) " +
                     "VALUES (?, ?, ?)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, inv.getPartId());
            ps.setInt(2, inv.getLastUpdatedBy());
            ps.setDate(3, Date.valueOf(inv.getLastUpdatedDate()));
            ps.executeUpdate();
            System.out.println("✅ Added Inventory for PartId=" + inv.getPartId());
        } catch (SQLException e) {
            System.out.println("❌ addInventory error: " + e.getMessage());
        }
    }

    // Cập nhật inventory (CHỈ CẬP NHẬT metadata, KHÔNG CẬP NHẬT quantity)
    public void updateInventory(NewInventory inv) {
        String sql = "UPDATE Inventory " +
                     "SET lastUpdatedBy = ?, lastUpdatedDate = ? " +
                     "WHERE inventoryId = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, inv.getLastUpdatedBy());
            ps.setDate(2, Date.valueOf(inv.getLastUpdatedDate()));
            ps.setInt(3, inv.getInventoryId());
            ps.executeUpdate();
            System.out.println("✅ Updated Inventory ID=" + inv.getInventoryId());
        } catch (SQLException e) {
            System.out.println("❌ updateInventory error: " + e.getMessage());
        }
    }

    // Xóa inventory theo ID
    public void deleteInventory(int id) {
        String sql = "DELETE FROM Inventory WHERE inventoryId = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
            System.out.println("✅ Deleted Inventory ID=" + id);
        } catch (SQLException e) {
            System.out.println("❌ deleteInventory error: " + e.getMessage());
        }
    }

    // LẤY QUANTITY ĐỘNG theo partId (hữu ích cho các báo cáo)
    public int getQuantityByPartId(int partId) {
        String sql = "SELECT COUNT(partDetailId) AS quantity " +
                     "FROM PartDetail " +
                     "WHERE partId = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, partId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("quantity");
            }
        } catch (SQLException e) {
            System.out.println("❌ getQuantityByPartId error: " + e.getMessage());
        }
        return 0;
    }

    // Tìm kiếm inventory theo tên linh kiện với quantity ĐỘNG
    public List<NewInventory> searchByPartName(String keyword) {
        List<NewInventory> list = new ArrayList<>();
        String sql = "SELECT " +
                     "    i.inventoryId, " +
                     "    i.partId, " +
                     "    COALESCE(COUNT(pd.partDetailId), 0) AS quantity, " +
                     "    i.lastUpdatedBy, " +
                     "    i.lastUpdatedDate, " +
                     "    p.partName, " +
                     "    a.username " +
                     "FROM Inventory i " +
                     "JOIN Part p ON i.partId = p.partId " +
                     "JOIN Account a ON i.lastUpdatedBy = a.accountId " +
                     "LEFT JOIN PartDetail pd ON pd.partId = p.partId " +
                     "WHERE p.partName LIKE ? " +
                     "GROUP BY i.inventoryId, i.partId, i.lastUpdatedBy, " +
                     "         i.lastUpdatedDate, p.partName, a.username";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, "%" + keyword + "%");
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                NewInventory inv = new NewInventory(
                        rs.getInt("inventoryId"),
                        rs.getInt("partId"),
                        rs.getInt("quantity"),
                        rs.getInt("lastUpdatedBy"),
                        rs.getDate("lastUpdatedDate").toLocalDate(),
                        rs.getString("partName"),
                        rs.getString("username")
                );
                list.add(inv);
            }

        } catch (SQLException e) {
            System.out.println("❌ searchByPartName error: " + e.getMessage());
        }
        return list;
    }

    // TEST MAIN
    public static void main(String[] args) {
        InventoryDAO dao = new InventoryDAO();

        System.out.println("=== TEST LẤY DANH SÁCH INVENTORY (QUANTITY ĐỘNG) ===");
        List<NewInventory> list = dao.getAllInventories();
        for (NewInventory inv : list) {
            System.out.println("PartId=" + inv.getPartId() + 
                             ", PartName=" + inv.getPartName() + 
                             ", Quantity=" + inv.getQuantity() + " (đếm từ PartDetail)");
        }

        System.out.println("\n=== TEST LẤY QUANTITY CỦA 1 PART ===");
        int partId = 1;
        int qty = dao.getQuantityByPartId(partId);
        System.out.println("PartId=" + partId + " có " + qty + " chi tiết thiết bị");
    }
}