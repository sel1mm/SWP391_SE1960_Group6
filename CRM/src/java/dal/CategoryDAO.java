package dal;

import model.Category;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO for Category operations
 * Manages categories for both Parts and Products
 */
public class CategoryDAO extends DBContext {

    /**
     * GET ALL CATEGORIES
     */
    public List<Category> getAllCategories() {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT categoryId, categoryName, type " +
                     "FROM Category " +
                     "ORDER BY type, categoryName";
        
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Category category = new Category(
                    rs.getInt("categoryId"),
                    rs.getString("categoryName"),
                    rs.getString("type")
                );
                list.add(category);
            }
            
            System.out.println("✅ Loaded " + list.size() + " categories");
        } catch (SQLException e) {
            System.out.println("❌ Error getting all categories: " + e.getMessage());
            e.printStackTrace();
        }
        
        return list;
    }

    /**
     * GET CATEGORIES BY TYPE (Part or Product)
     */
    public List<Category> getCategoriesByType(String type) {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT categoryId, categoryName, type " +
                     "FROM Category " +
                     "WHERE type = ? " +
                     "ORDER BY categoryName";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, type);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Category category = new Category(
                        rs.getInt("categoryId"),
                        rs.getString("categoryName"),
                        rs.getString("type")
                    );
                    list.add(category);
                }
            }
            
            System.out.println("✅ Loaded " + list.size() + " categories for type: " + type);
        } catch (SQLException e) {
            System.out.println("❌ Error getting categories by type: " + e.getMessage());
            e.printStackTrace();
        }
        
        return list;
    }

    /**
     * GET CATEGORY BY ID
     */
    public Category getCategoryById(int categoryId) {
        String sql = "SELECT categoryId, categoryName, type " +
                     "FROM Category " +
                     "WHERE categoryId = ?";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, categoryId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Category category = new Category(
                        rs.getInt("categoryId"),
                        rs.getString("categoryName"),
                        rs.getString("type")
                    );
                    System.out.println("✅ Found category: " + category.getCategoryName());
                    return category;
                }
            }
        } catch (SQLException e) {
            System.out.println("❌ Error getting category by ID: " + e.getMessage());
            e.printStackTrace();
        }
        
        System.out.println("❌ Category not found with ID: " + categoryId);
        return null;
    }

    /**
     * ADD NEW CATEGORY
     */
    public boolean addCategory(Category category) {
        String sql = "INSERT INTO Category (categoryName, type) VALUES (?, ?)";
        
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, category.getCategoryName());
            ps.setString(2, category.getType());
            
            int affectedRows = ps.executeUpdate();
            
            if (affectedRows > 0) {
                ResultSet rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    int newCategoryId = rs.getInt(1);
                    System.out.println("✅ Created category ID: " + newCategoryId + " (" + category.getCategoryName() + ")");
                    return true;
                }
            }
        } catch (SQLException e) {
            System.out.println("❌ Error adding category: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }

    /**
     * UPDATE CATEGORY
     */
    public boolean updateCategory(Category category) {
        String sql = "UPDATE Category SET categoryName = ?, type = ? WHERE categoryId = ?";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, category.getCategoryName());
            ps.setString(2, category.getType());
            ps.setInt(3, category.getCategoryId());
            
            boolean result = ps.executeUpdate() > 0;
            
            if (result) {
                System.out.println("✅ Updated category ID: " + category.getCategoryId());
            }
            
            return result;
        } catch (SQLException e) {
            System.out.println("❌ Error updating category: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }

    /**
     * DELETE CATEGORY
     * Note: Will fail if there are Parts/Products using this category (FK constraint)
     */
    public boolean deleteCategory(int categoryId) {
        String sql = "DELETE FROM Category WHERE categoryId = ?";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, categoryId);
            
            int affected = ps.executeUpdate();
            
            if (affected > 0) {
                System.out.println("✅ Deleted category ID: " + categoryId);
                return true;
            } else {
                System.out.println("❌ Category not found or already deleted: " + categoryId);
            }
        } catch (SQLException e) {
            System.out.println("❌ Error deleting category: " + e.getMessage());
            System.out.println("   Possible reason: Category is being used by Parts/Products");
            e.printStackTrace();
        }
        
        return false;
    }

    /**
     * CHECK IF CATEGORY NAME EXISTS (for validation)
     */
    public boolean categoryNameExists(String categoryName, String type) {
        String sql = "SELECT COUNT(*) as count FROM Category " +
                     "WHERE categoryName = ? AND type = ?";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, categoryName);
            ps.setString(2, type);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("count") > 0;
                }
            }
        } catch (SQLException e) {
            System.out.println("❌ Error checking category name: " + e.getMessage());
        }
        
        return false;
    }

    /**
     * COUNT PARTS/PRODUCTS IN CATEGORY
     */
    public int countItemsInCategory(int categoryId, String type) {
        String tableName = type.equals("Part") ? "Part" : "Product";
        String sql = "SELECT COUNT(*) as count FROM " + tableName + " " +
                     "WHERE categoryId = ?";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, categoryId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int count = rs.getInt("count");
                    System.out.println("✅ Category " + categoryId + " has " + count + " " + type + "(s)");
                    return count;
                }
            }
        } catch (SQLException e) {
            System.out.println("❌ Error counting items in category: " + e.getMessage());
        }
        
        return 0;
    }

    /**
     * SEARCH CATEGORIES
     */
    public List<Category> searchCategories(String keyword, String type) {
        List<Category> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT categoryId, categoryName, type ");
        sql.append("FROM Category ");
        sql.append("WHERE categoryName LIKE ? ");
        
        if (type != null && !type.isEmpty()) {
            sql.append("AND type = ? ");
        }
        
        sql.append("ORDER BY categoryName");
        
        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            String searchPattern = "%" + keyword + "%";
            ps.setString(1, searchPattern);
            
            if (type != null && !type.isEmpty()) {
                ps.setString(2, type);
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Category category = new Category(
                        rs.getInt("categoryId"),
                        rs.getString("categoryName"),
                        rs.getString("type")
                    );
                    list.add(category);
                }
            }
            
            System.out.println("✅ Found " + list.size() + " categories matching: " + keyword);
        } catch (SQLException e) {
            System.out.println("❌ Error searching categories: " + e.getMessage());
            e.printStackTrace();
        }
        
        return list;
    }

    /**
     * GET CATEGORY STATISTICS
     */
    public List<CategoryStatistics> getCategoryStatistics(String type) {
        List<CategoryStatistics> stats = new ArrayList<>();
        String tableName = type.equals("Part") ? "Part" : "Product";
        String idColumn = type.equals("Part") ? "partId" : "productId";
        
        String sql = "SELECT c.categoryId, c.categoryName, c.type, " +
                     "COUNT(" + tableName.toLowerCase().charAt(0) + "." + idColumn + ") as itemCount " +
                     "FROM Category c " +
                     "LEFT JOIN " + tableName + " " + tableName.toLowerCase().charAt(0) + 
                     " ON c.categoryId = " + tableName.toLowerCase().charAt(0) + ".categoryId " +
                     "WHERE c.type = ? " +
                     "GROUP BY c.categoryId, c.categoryName, c.type " +
                     "ORDER BY itemCount DESC, c.categoryName";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, type);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CategoryStatistics stat = new CategoryStatistics();
                    stat.setCategoryId(rs.getInt("categoryId"));
                    stat.setCategoryName(rs.getString("categoryName"));
                    stat.setType(rs.getString("type"));
                    stat.setItemCount(rs.getInt("itemCount"));
                    stats.add(stat);
                }
            }
            
            System.out.println("✅ Loaded statistics for " + stats.size() + " categories");
        } catch (SQLException e) {
            System.out.println("❌ Error getting category statistics: " + e.getMessage());
            e.printStackTrace();
        }
        
        return stats;
    }

    // ==================== INNER CLASS FOR STATISTICS ====================
    public static class CategoryStatistics {
        private int categoryId;
        private String categoryName;
        private String type;
        private int itemCount;

        // Getters and Setters
        public int getCategoryId() { return categoryId; }
        public void setCategoryId(int categoryId) { this.categoryId = categoryId; }

        public String getCategoryName() { return categoryName; }
        public void setCategoryName(String categoryName) { this.categoryName = categoryName; }

        public String getType() { return type; }
        public void setType(String type) { this.type = type; }

        public int getItemCount() { return itemCount; }
        public void setItemCount(int itemCount) { this.itemCount = itemCount; }

        @Override
        public String toString() {
            return "CategoryStatistics{" +
                    "categoryId=" + categoryId +
                    ", categoryName='" + categoryName + '\'' +
                    ", type='" + type + '\'' +
                    ", itemCount=" + itemCount +
                    '}';
        }
    }

    // ==================== MAIN METHOD FOR TESTING ====================
    public static void main(String[] args) {
        CategoryDAO dao = new CategoryDAO();
        
        System.out.println("========================================");
        System.out.println("TESTING CategoryDAO");
        System.out.println("========================================\n");

        // Test 1: Get All Categories
        System.out.println("--- Test 1: Get All Categories ---");
        List<Category> allCategories = dao.getAllCategories();
        System.out.println("Found " + allCategories.size() + " total categories");
        for (Category cat : allCategories) {
            System.out.println("  " + cat);
        }
        System.out.println();

        // Test 2: Get Categories by Type (Part)
        System.out.println("--- Test 2: Get Part Categories ---");
        List<Category> partCategories = dao.getCategoriesByType("Part");
        for (Category cat : partCategories) {
            System.out.println("  - " + cat.getCategoryName() + " (ID: " + cat.getCategoryId() + ")");
        }
        System.out.println();

        // Test 3: Get Categories by Type (Product)
        System.out.println("--- Test 3: Get Product Categories ---");
        List<Category> productCategories = dao.getCategoriesByType("Product");
        for (Category cat : productCategories) {
            System.out.println("  - " + cat.getCategoryName() + " (ID: " + cat.getCategoryId() + ")");
        }
        System.out.println();

        // Test 4: Get Category by ID
        System.out.println("--- Test 4: Get Category by ID (1) ---");
        Category category = dao.getCategoryById(1);
        if (category != null) {
            System.out.println("Category: " + category);
        }
        System.out.println();

        // Test 5: Count Items in Category
        System.out.println("--- Test 5: Count Parts in Category 1 ---");
        int count = dao.countItemsInCategory(1, "Part");
        System.out.println("Total parts: " + count + "\n");

        // Test 6: Search Categories
        System.out.println("--- Test 6: Search Categories (keyword: 'HVAC') ---");
        List<Category> searchResults = dao.searchCategories("HVAC", null);
        for (Category cat : searchResults) {
            System.out.println("  - " + cat.getCategoryName() + " (" + cat.getType() + ")");
        }
        System.out.println();

        // Test 7: Category Statistics
        System.out.println("--- Test 7: Part Category Statistics ---");
        List<CategoryStatistics> stats = dao.getCategoryStatistics("Part");
        for (CategoryStatistics stat : stats) {
            System.out.println("  - " + stat.getCategoryName() + ": " + stat.getItemCount() + " parts");
        }
        System.out.println();

        // Test 8: Check if Category Name Exists
        System.out.println("--- Test 8: Check if 'HVAC Components' exists ---");
        boolean exists = dao.categoryNameExists("HVAC Components", "Part");
        System.out.println("Exists: " + exists + "\n");

        // Test 9: Add New Category (COMMENTED OUT)
        System.out.println("--- Test 9: Add New Category (SIMULATION) ---");
        Category newCat = new Category("Test Category", "Part");
        System.out.println("Would insert: " + newCat.getCategoryName());
        // Uncomment to actually insert:
        // boolean inserted = dao.addCategory(newCat);
        // System.out.println(inserted ? "✅ Inserted" : "❌ Failed");
        System.out.println();

        System.out.println("========================================");
        System.out.println("ALL TESTS COMPLETED");
        System.out.println("========================================");
    }
}