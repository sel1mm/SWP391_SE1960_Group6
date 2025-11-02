package dal;

import model.NewPart;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * DAO for Part operations with Category support.
 * Includes methods for CRUD operations and inventory management.
 */
public class PartDAO extends DBContext {

    /**
     * CREATE: Thêm mới một Part VÀ TẠO INVENTORY MẶC ĐỊNH
     */
    public boolean addPart(NewPart part) {
        PreparedStatement psPart = null;
        PreparedStatement psInventory = null;
        
        try {
            connection.setAutoCommit(false);
            
            // 1. Thêm Part mới
            String sqlPart = "INSERT INTO Part (partName, description, unitPrice, categoryId, " +
                           "lastUpdatedBy, lastUpdatedDate) VALUES (?, ?, ?, ?, ?, ?)";
            psPart = connection.prepareStatement(sqlPart, Statement.RETURN_GENERATED_KEYS);
            psPart.setString(1, part.getPartName());
            psPart.setString(2, part.getDescription());
            psPart.setDouble(3, part.getUnitPrice());
            
            // Handle categoryId (can be NULL)
            if (part.getCategoryId() != null) {
                psPart.setInt(4, part.getCategoryId());
            } else {
                psPart.setNull(4, Types.INTEGER);
            }
            
            psPart.setInt(5, part.getLastUpdatedBy());
            
            if (part.getLastUpdatedDate() != null) {
                psPart.setDate(6, Date.valueOf(part.getLastUpdatedDate()));
            } else {
                psPart.setDate(6, Date.valueOf(LocalDate.now()));
            }
            
            int affectedRows = psPart.executeUpdate();
            
            if (affectedRows > 0) {
                // Lấy partId vừa tạo
                ResultSet rs = psPart.getGeneratedKeys();
                if (rs.next()) {
                    int newPartId = rs.getInt(1);
                    
                    // 2. Tạo Inventory với quantity = 0
                    String sqlInventory = "INSERT INTO Inventory (partId, quantity, lastUpdatedBy, lastUpdatedDate) " +
                                        "VALUES (?, 0, ?, ?)";
                    psInventory = connection.prepareStatement(sqlInventory);
                    psInventory.setInt(1, newPartId);
                    psInventory.setInt(2, part.getLastUpdatedBy());
                    psInventory.setDate(3, Date.valueOf(LocalDate.now()));
                    psInventory.executeUpdate();
                    
                    connection.commit();
                    System.out.println("✅ Đã tạo Part ID=" + newPartId + " (Category: " + part.getCategoryId() + ") và Inventory");
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

    /**
     * READ: Lấy thông tin 1 part theo id (với category)
     */
   public NewPart getPartById(int partId) {
    String sql = "SELECT p.partId, p.partName, p.description, p.unitPrice, " +
                 "       p.categoryId, c.categoryName, " +
                 "       COALESCE(COUNT(pd.partDetailId), 0) AS quantity, " + // ✅ THÊM quantity
                 "       p.lastUpdatedBy, p.lastUpdatedDate, a.username " +
                 "FROM Part p " +
                 "LEFT JOIN Category c ON p.categoryId = c.categoryId " +
                 "LEFT JOIN Account a ON p.lastUpdatedBy = a.accountId " +
                 "LEFT JOIN PartDetail pd ON pd.partId = p.partId " +         // ✅ JOIN PartDetail
                 "WHERE p.partId = ? " +
                 "GROUP BY p.partId, p.partName, p.description, p.unitPrice, " + // ✅ GROUP BY
                 "         p.categoryId, c.categoryName, " +
                 "         p.lastUpdatedBy, p.lastUpdatedDate, a.username";
    
    try (PreparedStatement ps = connection.prepareStatement(sql)) {
        ps.setInt(1, partId);
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return mapResultSetToNewPart(rs, true); // ✅ Giữ nguyên true
            }
        }
    } catch (SQLException e) {
        System.out.println("❌ Lỗi khi lấy Part theo ID: " + e.getMessage());
    }
    return null;
}

    /**
     * READ ALL: Lấy danh sách tất cả Part KÈM SỐ LƯỢNG TỪ PartDetail VÀ CATEGORY
     */
    public List<NewPart> getAllParts() {
        List<NewPart> list = new ArrayList<>();
        String sql = "SELECT p.partId, p.partName, p.description, p.unitPrice, " +
                     "       p.categoryId, c.categoryName, " +
                     "       COALESCE(COUNT(pd.partDetailId), 0) AS quantity, " +
                     "       p.lastUpdatedBy, p.lastUpdatedDate, a.username " +
                     "FROM Part p " +
                     "LEFT JOIN Category c ON p.categoryId = c.categoryId " +
                     "LEFT JOIN Account a ON p.lastUpdatedBy = a.accountId " +
                     "LEFT JOIN PartDetail pd ON pd.partId = p.partId " +
                     "GROUP BY p.partId, p.partName, p.description, p.unitPrice, " +
                     "         p.categoryId, c.categoryName, " +
                     "         p.lastUpdatedBy, p.lastUpdatedDate, a.username " +
                     "ORDER BY p.partId";
        
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                NewPart part = mapResultSetToNewPart(rs, true);
                list.add(part);
            }
            
            System.out.println("✅ Loaded " + list.size() + " parts with quantity and category");
        } catch (SQLException e) {
            System.out.println("❌ Lỗi khi lấy danh sách Part: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    /**
     * GET Parts by Category
     */
    public List<NewPart> getPartsByCategory(int categoryId) {
        List<NewPart> list = new ArrayList<>();
        String sql = "SELECT p.partId, p.partName, p.description, p.unitPrice, " +
                     "       p.categoryId, c.categoryName, " +
                     "       COALESCE(COUNT(pd.partDetailId), 0) AS quantity, " +
                     "       p.lastUpdatedBy, p.lastUpdatedDate, a.username " +
                     "FROM Part p " +
                     "LEFT JOIN Category c ON p.categoryId = c.categoryId " +
                     "LEFT JOIN Account a ON p.lastUpdatedBy = a.accountId " +
                     "LEFT JOIN PartDetail pd ON pd.partId = p.partId " +
                     "WHERE p.categoryId = ? " +
                     "GROUP BY p.partId, p.partName, p.description, p.unitPrice, " +
                     "         p.categoryId, c.categoryName, " +
                     "         p.lastUpdatedBy, p.lastUpdatedDate, a.username " +
                     "ORDER BY p.partId";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, categoryId);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    NewPart part = mapResultSetToNewPart(rs, true);
                    list.add(part);
                }
            }
            
            System.out.println("✅ Loaded " + list.size() + " parts for categoryId: " + categoryId);
        } catch (SQLException e) {
            System.out.println("❌ Lỗi khi lấy Parts theo Category: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    /**
     * SEARCH: Tìm kiếm Parts theo tên, mô tả hoặc category
     */
    public List<NewPart> searchParts(String keyword) {
        List<NewPart> list = new ArrayList<>();
        String sql = "SELECT p.partId, p.partName, p.description, p.unitPrice, " +
                     "       p.categoryId, c.categoryName, " +
                     "       COALESCE(COUNT(pd.partDetailId), 0) AS quantity, " +
                     "       p.lastUpdatedBy, p.lastUpdatedDate, a.username " +
                     "FROM Part p " +
                     "LEFT JOIN Category c ON p.categoryId = c.categoryId " +
                     "LEFT JOIN Account a ON p.lastUpdatedBy = a.accountId " +
                     "LEFT JOIN PartDetail pd ON pd.partId = p.partId " +
                     "WHERE p.partName LIKE ? OR p.description LIKE ? OR c.categoryName LIKE ? " +
                     "GROUP BY p.partId, p.partName, p.description, p.unitPrice, " +
                     "         p.categoryId, c.categoryName, " +
                     "         p.lastUpdatedBy, p.lastUpdatedDate, a.username " +
                     "ORDER BY p.partId";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            String searchPattern = "%" + keyword + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);
            ps.setString(3, searchPattern);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    NewPart part = mapResultSetToNewPart(rs, true);
                    list.add(part);
                }
            }
            
            System.out.println("✅ Found " + list.size() + " parts matching keyword: " + keyword);
        } catch (SQLException e) {
            System.out.println("❌ Lỗi khi tìm kiếm Parts: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    /**
     * UPDATE: Cập nhật thông tin part (bao gồm category)
     */
    public boolean updatePart(NewPart part) {
        String sql = "UPDATE Part SET partName = ?, description = ?, unitPrice = ?, " +
                     "categoryId = ?, lastUpdatedBy = ?, lastUpdatedDate = ? " +
                     "WHERE partId = ?";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, part.getPartName());
            ps.setString(2, part.getDescription());
            ps.setDouble(3, part.getUnitPrice());
            
            // Handle categoryId (can be NULL)
            if (part.getCategoryId() != null) {
                ps.setInt(4, part.getCategoryId());
            } else {
                ps.setNull(4, Types.INTEGER);
            }
            
            ps.setInt(5, part.getLastUpdatedBy());

            if (part.getLastUpdatedDate() != null) {
                ps.setDate(6, Date.valueOf(part.getLastUpdatedDate()));
            } else {
                ps.setDate(6, Date.valueOf(LocalDate.now()));
            }

            ps.setInt(7, part.getPartId());
            
            boolean result = ps.executeUpdate() > 0;
            if (result) {
                System.out.println("✅ Updated Part ID=" + part.getPartId());
            }
            return result;
            
        } catch (SQLException e) {
            System.out.println("❌ Lỗi khi cập nhật Part: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    /**
     * DELETE: Xóa part VÀ INVENTORY LIÊN QUAN
     */
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
            System.out.println("❌ Lỗi khi xóa Part: " + e.getMessage());
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

    /**
     * Đếm số lượng PartDetail theo trạng thái cho một Part cụ thể
     */
    public Map<String, Integer> getPartStatusCount(int partId) {
        Map<String, Integer> statusCount = new HashMap<>();
        
        // Khởi tạo 4 trạng thái với giá trị 0
        statusCount.put("Available", 0);
        statusCount.put("Faulty", 0);
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
            System.out.println("   Faulty: " + statusCount.get("Faulty"));
            System.out.println("   InUse: " + statusCount.get("InUse"));
            System.out.println("   Retired: " + statusCount.get("Retired"));
            
        } catch (SQLException e) {
            System.out.println("❌ Error getting status count: " + e.getMessage());
            e.printStackTrace();
        }
        
        return statusCount;
    }

    /**
     * Get total quantity of parts in stock (Available status only)
     */
    public int getAvailableQuantity(int partId) {
        String sql = "SELECT COUNT(*) as count FROM PartDetail " +
                     "WHERE partId = ? AND status = 'Available'";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, partId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("count");
                }
            }
        } catch (SQLException e) {
            System.out.println("❌ Error getting available quantity: " + e.getMessage());
        }
        return 0;
    }

    /**
     * Helper method: Map ResultSet to NewPart object
     */
    private NewPart mapResultSetToNewPart(ResultSet rs, boolean includeQuantity) throws SQLException {
        NewPart part = new NewPart();
        part.setPartId(rs.getInt("partId"));
        part.setPartName(rs.getString("partName"));
        part.setDescription(rs.getString("description"));
        part.setUnitPrice(rs.getDouble("unitPrice"));
        
        // Category info
        int categoryId = rs.getInt("categoryId");
        if (!rs.wasNull()) {
            part.setCategoryId(categoryId);
        }
        part.setCategoryName(rs.getString("categoryName"));
        
        // Quantity (if included in query)
        if (includeQuantity) {
            part.setQuantity(rs.getInt("quantity"));
        }
        
        part.setLastUpdatedBy(rs.getInt("lastUpdatedBy"));
        
        Date date = rs.getDate("lastUpdatedDate");
        if (date != null) {
            part.setLastUpdatedDate(date.toLocalDate());
        }
        
        part.setUserName(rs.getString("username"));
        
        return part;
    }

    /**
     * Get parts count by category
     */
    public Map<String, Integer> getPartsCountByCategory() {
        Map<String, Integer> categoryCount = new HashMap<>();
        String sql = "SELECT c.categoryName, COUNT(p.partId) as count " +
                     "FROM Category c " +
                     "LEFT JOIN Part p ON c.categoryId = p.categoryId " +
                     "WHERE c.type = 'Part' " +
                     "GROUP BY c.categoryId, c.categoryName " +
                     "ORDER BY count DESC";
        
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                String categoryName = rs.getString("categoryName");
                int count = rs.getInt("count");
                categoryCount.put(categoryName, count);
            }
            
            System.out.println("✅ Parts count by category loaded");
        } catch (SQLException e) {
            System.out.println("❌ Error getting parts count by category: " + e.getMessage());
        }
        
        return categoryCount;
    }

    // ==================== MAIN METHOD FOR TESTING ====================
    public static void main(String[] args) {
        PartDAO dao = new PartDAO();
        
        System.out.println("========================================");
        System.out.println("TESTING PartDAO with Category Support");
        System.out.println("========================================\n");

        // Test 1: Get All Parts
        System.out.println("--- Test 1: Get All Parts ---");
        List<NewPart> allParts = dao.getAllParts();
        System.out.println("✅ Found " + allParts.size() + " part(s)");
        
        if (!allParts.isEmpty()) {
            NewPart first = allParts.get(0);
            System.out.println("First Part: " + first.getPartName());
            System.out.println("  - Category: " + first.getCategoryName() + " (ID: " + first.getCategoryId() + ")");
            System.out.println("  - Quantity: " + first.getQuantity());
            System.out.println("  - Unit Price: $" + first.getUnitPrice());
            System.out.println("  - Updated by: " + first.getUserName());
        }
        System.out.println();

        // Test 2: Get Part by ID
        System.out.println("--- Test 2: Get Part by ID (1) ---");
        NewPart part = dao.getPartById(1);
        if (part != null) {
            System.out.println("✅ Found: " + part.getPartName());
            System.out.println("  - Category: " + part.getCategoryName());
            System.out.println("  - Description: " + part.getDescription());
            System.out.println("  - Price: $" + part.getUnitPrice());
        } else {
            System.out.println("❌ Part not found");
        }
        System.out.println();

        // Test 3: Get Parts by Category
        System.out.println("--- Test 3: Get Parts by Category (1 - HVAC Components) ---");
        List<NewPart> hvacParts = dao.getPartsByCategory(1);
        System.out.println("✅ Found " + hvacParts.size() + " HVAC part(s)");
        
        for (NewPart p : hvacParts) {
            System.out.println("  - " + p.getPartName() + " (Qty: " + p.getQuantity() + ")");
        }
        System.out.println();

        // Test 4: Search Parts
        System.out.println("--- Test 4: Search Parts (keyword: 'filter') ---");
        List<NewPart> searchResults = dao.searchParts("filter");
        System.out.println("✅ Found " + searchResults.size() + " result(s)");
        
        for (NewPart p : searchResults) {
            System.out.println("  - " + p.getPartName() + " [" + p.getCategoryName() + "]");
        }
        System.out.println();

        // Test 5: Get Part Status Count
        System.out.println("--- Test 5: Get Part Status Count (Part ID: 1) ---");
        Map<String, Integer> statusCount = dao.getPartStatusCount(1);
        System.out.println("Status breakdown:");
        statusCount.forEach((status, count) -> 
            System.out.println("  - " + status + ": " + count)
        );
        System.out.println();

        // Test 6: Get Available Quantity
        System.out.println("--- Test 6: Get Available Quantity (Part ID: 1) ---");
        int available = dao.getAvailableQuantity(1);
        System.out.println("✅ Available quantity: " + available);
        System.out.println();

        // Test 7: Get Parts Count by Category
        System.out.println("--- Test 7: Get Parts Count by Category ---");
        Map<String, Integer> categoryCount = dao.getPartsCountByCategory();
        System.out.println("Parts distribution by category:");
        categoryCount.forEach((category, count) -> 
            System.out.println("  - " + category + ": " + count + " part(s)")
        );
        System.out.println();

        // Test 8: Insert New Part (commented out to avoid modifying database)
        System.out.println("--- Test 8: Insert New Part (SIMULATION) ---");
        NewPart newPart = new NewPart("Test Filter", "Test description", 100.0, 1, 2, LocalDate.now());
        System.out.println("Would insert: " + newPart.getPartName() + " in category " + newPart.getCategoryId());
        // Uncomment to actually insert:
        // boolean inserted = dao.addPart(newPart);
        // System.out.println(inserted ? "✅ Inserted successfully" : "❌ Insert failed");
        System.out.println();

        System.out.println("========================================");
        System.out.println("ALL TESTS COMPLETED");
        System.out.println("========================================");
    }
}