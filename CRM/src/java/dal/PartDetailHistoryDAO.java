package dal;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import model.PartDetailHistory;

/**
 * DAO để quản lý lịch sử thay đổi PartDetail với Category support
 */
public class PartDetailHistoryDAO extends DBContext {
    
    /**
     * Thêm lịch sử khi thêm mới hoặc cập nhật PartDetail
     */
    public boolean addHistory(int partDetailId, String oldStatus, String newStatus, 
                              int changedBy, String notes) {
        String sql = "INSERT INTO PartDetailStatusHistory " +
                     "(partDetailId, oldStatus, newStatus, changedBy, changedDate, notes) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, partDetailId);
            
            if (oldStatus == null || oldStatus.isEmpty()) {
                ps.setNull(2, Types.VARCHAR);
            } else {
                ps.setString(2, oldStatus);
            }
            
            ps.setString(3, newStatus);
            ps.setInt(4, changedBy);
            ps.setTimestamp(5, Timestamp.valueOf(LocalDateTime.now()));
            ps.setString(6, notes);
            
            int result = ps.executeUpdate();
            System.out.println("✅ History added: PartDetailId=" + partDetailId + 
                             ", " + oldStatus + " → " + newStatus);
            return result > 0;
            
        } catch (SQLException e) {
            System.out.println("❌ Error adding history: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Lấy tất cả lịch sử với filter VÀ CATEGORY
     */
    public List<PartDetailHistory> getAllHistory(String fromDate, String toDate, 
                                                 String actionType, String keyword) {
        List<PartDetailHistory> list = new ArrayList<>();
        
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT h.historyId, h.partDetailId, h.oldStatus, h.newStatus, ")
           .append("h.changedBy, h.changedDate, h.notes, ")
           .append("a.username, ")
           .append("pd.serialNumber, pd.location, ")
           .append("p.partName, p.categoryId, c.categoryName ")
           .append("FROM PartDetailStatusHistory h ")
           .append("LEFT JOIN Account a ON h.changedBy = a.accountId ")
           .append("LEFT JOIN PartDetail pd ON h.partDetailId = pd.partDetailId ")
           .append("LEFT JOIN Part p ON pd.partId = p.partId ")
           .append("LEFT JOIN Category c ON p.categoryId = c.categoryId ")
           .append("WHERE 1=1 ");
        
        // Filter by date
        if (fromDate != null && !fromDate.isEmpty()) {
            sql.append("AND DATE(h.changedDate) >= ? ");
        }
        if (toDate != null && !toDate.isEmpty()) {
            sql.append("AND DATE(h.changedDate) <= ? ");
        }
        
        // Filter by action type
        if ("add".equals(actionType)) {
            sql.append("AND h.oldStatus IS NULL ");
        } else if ("update".equals(actionType)) {
            sql.append("AND h.oldStatus IS NOT NULL ");
        }
        
        // Search by serial number, part name, or category
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (pd.serialNumber LIKE ? OR p.partName LIKE ? OR c.categoryName LIKE ?) ");
        }
        
        sql.append("ORDER BY h.changedDate DESC");
        
        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            
            if (fromDate != null && !fromDate.isEmpty()) {
                ps.setString(paramIndex++, fromDate);
            }
            if (toDate != null && !toDate.isEmpty()) {
                ps.setString(paramIndex++, toDate);
            }
            if (keyword != null && !keyword.trim().isEmpty()) {
                String searchPattern = "%" + keyword.trim() + "%";
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
            }
            
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                PartDetailHistory history = mapResultSetToHistory(rs);
                list.add(history);
            }
            
            System.out.println("✅ Loaded " + list.size() + " history records with category info");
            
        } catch (SQLException e) {
            System.out.println("❌ Error getting history: " + e.getMessage());
            e.printStackTrace();
        }
        
        return list;
    }
    
    /**
     * Lấy lịch sử theo PartDetailId
     */
    public List<PartDetailHistory> getHistoryByPartDetailId(int partDetailId) {
        List<PartDetailHistory> list = new ArrayList<>();
        
        String sql = "SELECT h.historyId, h.partDetailId, h.oldStatus, h.newStatus, " +
                     "h.changedBy, h.changedDate, h.notes, " +
                     "a.username, " +
                     "pd.serialNumber, pd.location, " +
                     "p.partName, p.categoryId, c.categoryName " +
                     "FROM PartDetailStatusHistory h " +
                     "LEFT JOIN Account a ON h.changedBy = a.accountId " +
                     "LEFT JOIN PartDetail pd ON h.partDetailId = pd.partDetailId " +
                     "LEFT JOIN Part p ON pd.partId = p.partId " +
                     "LEFT JOIN Category c ON p.categoryId = c.categoryId " +
                     "WHERE h.partDetailId = ? " +
                     "ORDER BY h.changedDate DESC";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, partDetailId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                PartDetailHistory history = mapResultSetToHistory(rs);
                list.add(history);
            }
            
            System.out.println("✅ Loaded " + list.size() + " history records for partDetailId: " + partDetailId);
            
        } catch (SQLException e) {
            System.out.println("❌ Error getting history by partDetailId: " + e.getMessage());
            e.printStackTrace();
        }
        
        return list;
    }
    
    /**
     * Lấy lịch sử theo Category
     */
    public List<PartDetailHistory> getHistoryByCategory(int categoryId, String fromDate, String toDate) {
        List<PartDetailHistory> list = new ArrayList<>();
        
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT h.historyId, h.partDetailId, h.oldStatus, h.newStatus, ")
           .append("h.changedBy, h.changedDate, h.notes, ")
           .append("a.username, ")
           .append("pd.serialNumber, pd.location, ")
           .append("p.partName, p.categoryId, c.categoryName ")
           .append("FROM PartDetailStatusHistory h ")
           .append("LEFT JOIN Account a ON h.changedBy = a.accountId ")
           .append("LEFT JOIN PartDetail pd ON h.partDetailId = pd.partDetailId ")
           .append("LEFT JOIN Part p ON pd.partId = p.partId ")
           .append("LEFT JOIN Category c ON p.categoryId = c.categoryId ")
           .append("WHERE p.categoryId = ? ");
        
        if (fromDate != null && !fromDate.isEmpty()) {
            sql.append("AND DATE(h.changedDate) >= ? ");
        }
        if (toDate != null && !toDate.isEmpty()) {
            sql.append("AND DATE(h.changedDate) <= ? ");
        }
        
        sql.append("ORDER BY h.changedDate DESC");
        
        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            ps.setInt(paramIndex++, categoryId);
            
            if (fromDate != null && !fromDate.isEmpty()) {
                ps.setString(paramIndex++, fromDate);
            }
            if (toDate != null && !toDate.isEmpty()) {
                ps.setString(paramIndex++, toDate);
            }
            
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                PartDetailHistory history = mapResultSetToHistory(rs);
                list.add(history);
            }
            
            System.out.println("✅ Loaded " + list.size() + " history records for categoryId: " + categoryId);
            
        } catch (SQLException e) {
            System.out.println("❌ Error getting history by category: " + e.getMessage());
            e.printStackTrace();
        }
        
        return list;
    }
    
    /**
     * Lấy thống kê tổng quan
     */
    public PartDetailHistory getOverview(String fromDate, String toDate) {
        PartDetailHistory overview = new PartDetailHistory();
        
        String sql = "SELECT " +
                     "COUNT(*) as totalCount, " +
                     "SUM(CASE WHEN oldStatus IS NULL THEN 1 ELSE 0 END) as addedCount, " +
                     "SUM(CASE WHEN oldStatus IS NOT NULL THEN 1 ELSE 0 END) as changedCount " +
                     "FROM PartDetailStatusHistory " +
                     "WHERE 1=1 ";
        
        if (fromDate != null && !fromDate.isEmpty()) {
            sql += "AND DATE(changedDate) >= ? ";
        }
        if (toDate != null && !toDate.isEmpty()) {
            sql += "AND DATE(changedDate) <= ? ";
        }
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            int paramIndex = 1;
            
            if (fromDate != null && !fromDate.isEmpty()) {
                ps.setString(paramIndex++, fromDate);
            }
            if (toDate != null && !toDate.isEmpty()) {
                ps.setString(paramIndex++, toDate);
            }
            
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                overview.setTotalCount(rs.getInt("totalCount"));
                overview.setAddedCount(rs.getInt("addedCount"));
                overview.setChangedCount(rs.getInt("changedCount"));
            }
            
            System.out.println("✅ Overview loaded: Total=" + overview.getTotalCount() +
                             ", Added=" + overview.getAddedCount() +
                             ", Changed=" + overview.getChangedCount());
            
        } catch (SQLException e) {
            System.out.println("❌ Error getting overview: " + e.getMessage());
            e.printStackTrace();
        }
        
        return overview;
    }
    
    /**
     * Đếm tổng số bản ghi theo filter
     */
    public int countHistory(String fromDate, String toDate, String actionType, String keyword) {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) as total ")
           .append("FROM PartDetailStatusHistory h ")
           .append("LEFT JOIN PartDetail pd ON h.partDetailId = pd.partDetailId ")
           .append("LEFT JOIN Part p ON pd.partId = p.partId ")
           .append("LEFT JOIN Category c ON p.categoryId = c.categoryId ")
           .append("WHERE 1=1 ");
        
        if (fromDate != null && !fromDate.isEmpty()) {
            sql.append("AND DATE(h.changedDate) >= ? ");
        }
        if (toDate != null && !toDate.isEmpty()) {
            sql.append("AND DATE(h.changedDate) <= ? ");
        }
        
        if ("add".equals(actionType)) {
            sql.append("AND h.oldStatus IS NULL ");
        } else if ("update".equals(actionType)) {
            sql.append("AND h.oldStatus IS NOT NULL ");
        }
        
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (pd.serialNumber LIKE ? OR p.partName LIKE ? OR c.categoryName LIKE ?) ");
        }
        
        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            
            if (fromDate != null && !fromDate.isEmpty()) {
                ps.setString(paramIndex++, fromDate);
            }
            if (toDate != null && !toDate.isEmpty()) {
                ps.setString(paramIndex++, toDate);
            }
            if (keyword != null && !keyword.trim().isEmpty()) {
                String searchPattern = "%" + keyword.trim() + "%";
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
            }
            
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("total");
            }
            
        } catch (SQLException e) {
            System.out.println("❌ Error counting history: " + e.getMessage());
        }
        
        return 0;
    }
    
    /**
     * Thống kê số lượng changes theo category
     */
    public Map<String, Integer> getChangesByCategory(String fromDate, String toDate) {
        Map<String, Integer> categoryStats = new HashMap<>();
        
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT c.categoryName, COUNT(*) as changeCount ")
           .append("FROM PartDetailStatusHistory h ")
           .append("JOIN PartDetail pd ON h.partDetailId = pd.partDetailId ")
           .append("JOIN Part p ON pd.partId = p.partId ")
           .append("LEFT JOIN Category c ON p.categoryId = c.categoryId ")
           .append("WHERE 1=1 ");
        
        if (fromDate != null && !fromDate.isEmpty()) {
            sql.append("AND DATE(h.changedDate) >= ? ");
        }
        if (toDate != null && !toDate.isEmpty()) {
            sql.append("AND DATE(h.changedDate) <= ? ");
        }
        
        sql.append("GROUP BY c.categoryId, c.categoryName ")
           .append("ORDER BY changeCount DESC");
        
        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            
            if (fromDate != null && !fromDate.isEmpty()) {
                ps.setString(paramIndex++, fromDate);
            }
            if (toDate != null && !toDate.isEmpty()) {
                ps.setString(paramIndex++, toDate);
            }
            
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                String categoryName = rs.getString("categoryName");
                if (categoryName == null) categoryName = "Uncategorized";
                int count = rs.getInt("changeCount");
                categoryStats.put(categoryName, count);
            }
            
            System.out.println("✅ Changes by category loaded: " + categoryStats.size() + " categories");
            
        } catch (SQLException e) {
            System.out.println("❌ Error getting changes by category: " + e.getMessage());
            e.printStackTrace();
        }
        
        return categoryStats;
    }
    
    /**
     * Method dùng cho transaction từ DAO khác
     */
    public boolean addHistoryWithTransaction(Connection externalConn, int partDetailId, 
                                            String oldStatus, String newStatus, 
                                            int changedBy, String notes) {
        String sql = "INSERT INTO PartDetailStatusHistory " +
                     "(partDetailId, oldStatus, newStatus, changedBy, changedDate, notes) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";
        
        PreparedStatement ps = null;
        try {
            ps = externalConn.prepareStatement(sql);
            ps.setInt(1, partDetailId);
            
            if (oldStatus == null || oldStatus.isEmpty()) {
                ps.setNull(2, Types.VARCHAR);
            } else {
                ps.setString(2, oldStatus);
            }
            
            ps.setString(3, newStatus);
            ps.setInt(4, changedBy);
            ps.setTimestamp(5, Timestamp.valueOf(LocalDateTime.now()));
            ps.setString(6, notes);
            
            int result = ps.executeUpdate();
            System.out.println("✅ History added (transaction): " + oldStatus + " → " + newStatus);
            return result > 0;
            
        } catch (SQLException e) {
            System.out.println("❌ Error adding history (transaction): " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            if (ps != null) {
                try {
                    ps.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }
    
    /**
     * Helper method: Map ResultSet to PartDetailHistory
     */
    private PartDetailHistory mapResultSetToHistory(ResultSet rs) throws SQLException {
        PartDetailHistory history = new PartDetailHistory();
        history.setHistoryId(rs.getInt("historyId"));
        history.setPartDetailId(rs.getInt("partDetailId"));
        history.setOldStatus(rs.getString("oldStatus"));
        history.setNewStatus(rs.getString("newStatus"));
        history.setChangedBy(rs.getInt("changedBy"));
        history.setChangedDate(rs.getTimestamp("changedDate"));
        history.setNotes(rs.getString("notes"));
        history.setUsername(rs.getString("username"));
        history.setSerialNumber(rs.getString("serialNumber"));
        history.setLocation(rs.getString("location"));
        history.setPartName(rs.getString("partName"));
        
        // Category info
        int categoryId = rs.getInt("categoryId");
        if (!rs.wasNull()) {
            history.setCategoryId(categoryId);
        }
        history.setCategoryName(rs.getString("categoryName"));
        
        return history;
    }
    
    // ==================== MAIN METHOD FOR TESTING ====================
    public static void main(String[] args) {
        PartDetailHistoryDAO dao = new PartDetailHistoryDAO();
        
        System.out.println("========================================");
        System.out.println("TESTING PartDetailHistoryDAO with Category Support");
        System.out.println("========================================\n");

        // Test 1: Get All History
        System.out.println("--- Test 1: Get All History ---");
        List<PartDetailHistory> allHistory = dao.getAllHistory(null, null, null, null);
        System.out.println("✅ Found " + allHistory.size() + " history record(s)");
        
        if (!allHistory.isEmpty()) {
            PartDetailHistory first = allHistory.get(0);
            System.out.println("Latest History:");
            System.out.println("  - Serial: " + first.getSerialNumber());
            System.out.println("  - Change: " + first.getOldStatus() + " → " + first.getNewStatus());
            System.out.println("  - Category: " + first.getCategoryName());
            System.out.println("  - Changed by: " + first.getUsername());
            System.out.println("  - Date: " + first.getChangedDate());
        }
        System.out.println();

        // Test 2: Get History by Date Range
        System.out.println("--- Test 2: Get History by Date Range (2024-10-01 to 2025-11-30) ---");
        List<PartDetailHistory> dateRangeHistory = dao.getAllHistory("2024-10-01", "2025-11-30", null, null);
        System.out.println("✅ Found " + dateRangeHistory.size() + " record(s) in date range");
        System.out.println();

        // Test 3: Get History by Action Type
        System.out.println("--- Test 3: Get History by Action Type (add) ---");
        List<PartDetailHistory> addHistory = dao.getAllHistory(null, null, "add", null);
        System.out.println("✅ Found " + addHistory.size() + " addition record(s)");
        
        System.out.println("\n--- Test 3b: Get History by Action Type (update) ---");
        List<PartDetailHistory> updateHistory = dao.getAllHistory(null, null, "update", null);
        System.out.println("✅ Found " + updateHistory.size() + " update record(s)");
        System.out.println();

        // Test 4: Search History by Keyword
        System.out.println("--- Test 4: Search History (keyword: 'HVAC') ---");
        List<PartDetailHistory> searchResults = dao.getAllHistory(null, null, null, "HVAC");
        System.out.println("✅ Found " + searchResults.size() + " result(s)");
        
        int count = 0;
        for (PartDetailHistory h : searchResults) {
            System.out.println("  - " + h.getSerialNumber() + " [" + h.getCategoryName() + "]: " + 
                             h.getOldStatus() + " → " + h.getNewStatus());
            if (++count >= 5) {
                System.out.println("  ... and " + (searchResults.size() - 5) + " more");
                break;
            }
        }
        System.out.println();

        // Test 5: Get History by PartDetailId
        System.out.println("--- Test 5: Get History by PartDetailId (1) ---");
        List<PartDetailHistory> pdHistory = dao.getHistoryByPartDetailId(1);
        System.out.println("✅ Found " + pdHistory.size() + " history record(s) for PartDetail ID 1");
        
        for (PartDetailHistory h : pdHistory) {
            System.out.println("  - " + h.getChangedDate() + ": " + h.getOldStatus() + " → " + h.getNewStatus());
        }
        System.out.println();

        // Test 6: Get History by Category
        System.out.println("--- Test 6: Get History by Category (1 - HVAC Components) ---");
        List<PartDetailHistory> categoryHistory = dao.getHistoryByCategory(1, null, null);
        System.out.println("✅ Found " + categoryHistory.size() + " history record(s) for HVAC category");
        
        count = 0;
        for (PartDetailHistory h : categoryHistory) {
            System.out.println("  - " + h.getSerialNumber() + ": " + h.getOldStatus() + " → " + h.getNewStatus());
            if (++count >= 5) {
                System.out.println("  ... and " + (categoryHistory.size() - 5) + " more");
                break;
            }
        }
        System.out.println();

        // Test 7: Get Overview
        System.out.println("--- Test 7: Get Overview (All Time) ---");
        PartDetailHistory overview = dao.getOverview(null, null);
        System.out.println("Statistics:");
        System.out.println("  - Total changes: " + overview.getTotalCount());
        System.out.println("  - Additions: " + overview.getAddedCount());
        System.out.println("  - Updates: " + overview.getChangedCount());
        System.out.println();

        // Test 8: Count History
        System.out.println("--- Test 8: Count History with Filters ---");
        int totalCount = dao.countHistory(null, null, null, null);
        int addCount = dao.countHistory(null, null, "add", null);
        int updateCount = dao.countHistory(null, null, "update", null);
        
        System.out.println("✅ Total history records: " + totalCount);
        System.out.println("✅ Addition records: " + addCount);
        System.out.println("✅ Update records: " + updateCount);
        System.out.println();

        // Test 9: Get Changes by Category
        System.out.println("--- Test 9: Get Changes by Category ---");
        Map<String, Integer> categoryStats = dao.getChangesByCategory(null, null);
        System.out.println("Changes distribution by category:");
        categoryStats.entrySet().stream()
            .sorted((a, b) -> b.getValue().compareTo(a.getValue()))
            .forEach(entry -> 
                System.out.println("  - " + entry.getKey() + ": " + entry.getValue() + " change(s)")
            );
        System.out.println();

        // Test 10: Add History (SIMULATION)
        System.out.println("--- Test 10: Add History (SIMULATION) ---");
        System.out.println("Would add history: partDetailId=1, Available → InUse");
        // Uncomment to actually add:
        // boolean added = dao.addHistory(1, "Available", "InUse", 2, "Test change");
        // System.out.println(added ? "✅ Added successfully" : "❌ Add failed");
        System.out.println();

        System.out.println("========================================");
        System.out.println("ALL TESTS COMPLETED");
        System.out.println("========================================");
    }
}