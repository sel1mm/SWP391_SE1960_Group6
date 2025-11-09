package dal;

import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import model.NewPartDetail;

/**
 * PartDetailDAO - Data Access Object cho PartDetail với Category support
 * @author Admin
 */
public class PartDetailDAO extends DBContext {

    /**
     * GET ALL với JOIN để lấy username và category
     */
    public List<NewPartDetail> getAllPartDetails() {
        List<NewPartDetail> list = new ArrayList<>();
        String sql = "SELECT pd.partDetailId, pd.partId, pd.serialNumber, pd.status, pd.location, " +
                     "       pd.lastUpdatedBy, pd.lastUpdatedDate, " +
                     "       a.username, " +
                     "       p.categoryId, c.categoryName " +
                     "FROM PartDetail pd " +
                     "LEFT JOIN Account a ON pd.lastUpdatedBy = a.accountId " +
                     "LEFT JOIN Part p ON pd.partId = p.partId " +
                     "LEFT JOIN Category c ON p.categoryId = c.categoryId " +
                     "ORDER BY pd.partDetailId DESC";
        
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                NewPartDetail pd = mapResultSetToPartDetail(rs);
                list.add(pd);
            }
            
            System.out.println("✅ Loaded " + list.size() + " part details with category info");
            
        } catch (SQLException e) {
            System.out.println("❌ Error in getAllPartDetails: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    /**
     * GET BY ID với category information
     */
    public NewPartDetail getPartDetailById(int partDetailId) {
        String sql = "SELECT pd.partDetailId, pd.partId, pd.serialNumber, pd.status, pd.location, " +
                     "       pd.lastUpdatedBy, pd.lastUpdatedDate, " +
                     "       a.username, " +
                     "       p.categoryId, c.categoryName " +
                     "FROM PartDetail pd " +
                     "LEFT JOIN Account a ON pd.lastUpdatedBy = a.accountId " +
                     "LEFT JOIN Part p ON pd.partId = p.partId " +
                     "LEFT JOIN Category c ON p.categoryId = c.categoryId " +
                     "WHERE pd.partDetailId = ?";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, partDetailId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    NewPartDetail pd = mapResultSetToPartDetail(rs);
                    System.out.println("✅ Found partDetail with ID: " + partDetailId);
                    return pd;
                }
            }
        } catch (SQLException e) {
            System.out.println("❌ Error in getPartDetailById: " + e.getMessage());
            e.printStackTrace();
        }
        
        System.out.println("❌ PartDetail not found with ID: " + partDetailId);
        return null;
    }

    /**
     * GET PartDetails by PartId (with category)
     */
    public List<NewPartDetail> getPartDetailsByPartId(int partId) {
        List<NewPartDetail> list = new ArrayList<>();
        String sql = "SELECT pd.partDetailId, pd.partId, pd.serialNumber, pd.status, pd.location, " +
                     "       pd.lastUpdatedBy, pd.lastUpdatedDate, " +
                     "       a.username, " +
                     "       p.categoryId, c.categoryName " +
                     "FROM PartDetail pd " +
                     "LEFT JOIN Account a ON pd.lastUpdatedBy = a.accountId " +
                     "LEFT JOIN Part p ON pd.partId = p.partId " +
                     "LEFT JOIN Category c ON p.categoryId = c.categoryId " +
                     "WHERE pd.partId = ? " +
                     "ORDER BY pd.partDetailId DESC";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, partId);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    NewPartDetail pd = mapResultSetToPartDetail(rs);
                    list.add(pd);
                }
            }
            
            System.out.println("✅ Found " + list.size() + " part details for partId: " + partId);
            
        } catch (SQLException e) {
            System.out.println("❌ Error in getPartDetailsByPartId: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    /**
     * GET PartDetails by Status (with category)
     */
    public List<NewPartDetail> getPartDetailsByStatus(String status) {
        List<NewPartDetail> list = new ArrayList<>();
        String sql = "SELECT pd.partDetailId, pd.partId, pd.serialNumber, pd.status, pd.location, " +
                     "       pd.lastUpdatedBy, pd.lastUpdatedDate, " +
                     "       a.username, " +
                     "       p.categoryId, c.categoryName " +
                     "FROM PartDetail pd " +
                     "LEFT JOIN Account a ON pd.lastUpdatedBy = a.accountId " +
                     "LEFT JOIN Part p ON pd.partId = p.partId " +
                     "LEFT JOIN Category c ON p.categoryId = c.categoryId " +
                     "WHERE pd.status = ? " +
                     "ORDER BY pd.partDetailId DESC";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, status);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    NewPartDetail pd = mapResultSetToPartDetail(rs);
                    list.add(pd);
                }
            }
            
            System.out.println("✅ Found " + list.size() + " part details with status: " + status);
            
        } catch (SQLException e) {
            System.out.println("❌ Error in getPartDetailsByStatus: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    /**
     * GET PartDetails by Category
     */
    public List<NewPartDetail> getPartDetailsByCategory(int categoryId) {
        List<NewPartDetail> list = new ArrayList<>();
        String sql = "SELECT pd.partDetailId, pd.partId, pd.serialNumber, pd.status, pd.location, " +
                     "       pd.lastUpdatedBy, pd.lastUpdatedDate, " +
                     "       a.username, " +
                     "       p.categoryId, c.categoryName " +
                     "FROM PartDetail pd " +
                     "LEFT JOIN Account a ON pd.lastUpdatedBy = a.accountId " +
                     "LEFT JOIN Part p ON pd.partId = p.partId " +
                     "LEFT JOIN Category c ON p.categoryId = c.categoryId " +
                     "WHERE p.categoryId = ? " +
                     "ORDER BY pd.partDetailId DESC";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, categoryId);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    NewPartDetail pd = mapResultSetToPartDetail(rs);
                    list.add(pd);
                }
            }
            
            System.out.println("✅ Found " + list.size() + " part details for categoryId: " + categoryId);
            
        } catch (SQLException e) {
            System.out.println("❌ Error in getPartDetailsByCategory: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    /**
     * SEARCH PartDetails by serial number, location, or category
     */
    public List<NewPartDetail> searchPartDetails(String keyword) {
        List<NewPartDetail> list = new ArrayList<>();
        String sql = "SELECT pd.partDetailId, pd.partId, pd.serialNumber, pd.status, pd.location, " +
                     "       pd.lastUpdatedBy, pd.lastUpdatedDate, " +
                     "       a.username, " +
                     "       p.categoryId, c.categoryName " +
                     "FROM PartDetail pd " +
                     "LEFT JOIN Account a ON pd.lastUpdatedBy = a.accountId " +
                     "LEFT JOIN Part p ON pd.partId = p.partId " +
                     "LEFT JOIN Category c ON p.categoryId = c.categoryId " +
                     "WHERE pd.serialNumber LIKE ? OR pd.location LIKE ? OR c.categoryName LIKE ? " +
                     "ORDER BY pd.partDetailId DESC";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            String searchPattern = "%" + keyword + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);
            ps.setString(3, searchPattern);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    NewPartDetail pd = mapResultSetToPartDetail(rs);
                    list.add(pd);
                }
            }
            
            System.out.println("✅ Found " + list.size() + " part details matching: " + keyword);
            
        } catch (SQLException e) {
            System.out.println("❌ Error in searchPartDetails: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    /**
     * ADD (INSERT) PartDetail
     */
    public boolean addPartDetail(NewPartDetail part) {
        System.out.println("=== DAO: addPartDetail START ===");
        String sql = "INSERT INTO PartDetail (partId, serialNumber, status, location, " +
                     "lastUpdatedBy, lastUpdatedDate) VALUES (?, ?, ?, ?, ?, ?)";
        
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, part.getPartId());
            ps.setString(2, part.getSerialNumber());
            ps.setString(3, part.getStatus());
            ps.setString(4, part.getLocation());
            ps.setInt(5, part.getLastUpdatedBy());
            
            if (part.getLastUpdatedDate() != null) {
                ps.setDate(6, Date.valueOf(part.getLastUpdatedDate()));
            } else {
                ps.setDate(6, Date.valueOf(LocalDate.now()));
            }
            
            System.out.println("=== Executing SQL: " + sql);
            System.out.println("=== Values: [" + part.getPartId() + ", " + 
                              part.getSerialNumber() + ", " + part.getStatus() + ", " +
                              part.getLocation() + ", " + part.getLastUpdatedBy() + "]");
            
            int rows = ps.executeUpdate();
            System.out.println("=== Rows inserted: " + rows + " ===");
            
            if (rows > 0) {
                try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        part.setPartDetailId(generatedKeys.getInt(1));
                        System.out.println("=== Generated partDetailId: " + part.getPartDetailId() + " ===");
                    }
                }
            }
            
            return rows > 0;
            
        } catch (SQLException e) {
            System.out.println("❌ SQL ERROR in addPartDetail: " + e.getMessage());
            e.printStackTrace();
            
            if (e.getMessage().contains("Duplicate entry")) {
                System.out.println("❌ Serial Number đã tồn tại!");
            } else if (e.getMessage().contains("foreign key")) {
                System.out.println("❌ PartId hoặc AccountId không tồn tại!");
            }
            
            return false;
        }
    }

    /**
     * UPDATE PartDetail
     */
    public boolean updatePartDetail(NewPartDetail part) {
        System.out.println("=== DAO: updatePartDetail START ===");
        String sql = "UPDATE PartDetail SET partId = ?, serialNumber = ?, status = ?, " +
                     "location = ?, lastUpdatedBy = ?, lastUpdatedDate = ? " +
                     "WHERE partDetailId = ?";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, part.getPartId());
            ps.setString(2, part.getSerialNumber());
            ps.setString(3, part.getStatus());
            ps.setString(4, part.getLocation());
            ps.setInt(5, part.getLastUpdatedBy());
            
            if (part.getLastUpdatedDate() != null) {
                ps.setDate(6, Date.valueOf(part.getLastUpdatedDate()));
            } else {
                ps.setDate(6, Date.valueOf(LocalDate.now()));
            }
            
            ps.setInt(7, part.getPartDetailId());
            
            System.out.println("=== Executing UPDATE for partDetailId: " + part.getPartDetailId());
            
            int rows = ps.executeUpdate();
            System.out.println("=== Rows updated: " + rows + " ===");
            
            return rows > 0;
            
        } catch (SQLException e) {
            System.out.println("❌ SQL ERROR in updatePartDetail: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * DELETE PartDetail
     */
    public boolean deletePartDetail(int partDetailId) {
        System.out.println("=== DAO: deletePartDetail START ===");
        String sql = "DELETE FROM PartDetail WHERE partDetailId = ?";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, partDetailId);
            
            System.out.println("=== Deleting partDetailId: " + partDetailId);
            
            int rows = ps.executeUpdate();
            System.out.println("=== Rows deleted: " + rows + " ===");
            
            return rows > 0;
            
        } catch (SQLException e) {
            System.out.println("❌ SQL ERROR in deletePartDetail: " + e.getMessage());
            e.printStackTrace();
            
            if (e.getMessage().contains("foreign key")) {
                System.out.println("❌ Không thể xóa vì có ràng buộc dữ liệu!");
            }
            
            return false;
        }
    }

    /**
     * Get last inserted ID
     */
    public int getLastInsertedId() {
        String sql = "SELECT LAST_INSERT_ID() as id";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt("id");
            }
        } catch (SQLException e) {
            System.out.println("Error getting last inserted ID: " + e.getMessage());
        }
        return -1;
    }

    /**
     * Get count by status for all part details
     */
    public Map<String, Integer> getStatusCount() {
        Map<String, Integer> statusCount = new HashMap<>();
        statusCount.put("Available", 0);
        statusCount.put("Faulty", 0);
        statusCount.put("InUse", 0);
        statusCount.put("Retired", 0);
        
        String sql = "SELECT status, COUNT(*) as count FROM PartDetail GROUP BY status";
        
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                String status = rs.getString("status");
                int count = rs.getInt("count");
                statusCount.put(status, count);
            }
            
            System.out.println("✅ Overall status count loaded");
            
        } catch (SQLException e) {
            System.out.println("❌ Error getting status count: " + e.getMessage());
        }
        
        return statusCount;
    }

    /**
     * Get count by location
     */
    public Map<String, Integer> getLocationCount() {
        Map<String, Integer> locationCount = new HashMap<>();
        String sql = "SELECT location, COUNT(*) as count FROM PartDetail " +
                     "GROUP BY location ORDER BY count DESC";
        
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                String location = rs.getString("location");
                int count = rs.getInt("count");
                locationCount.put(location, count);
            }
            
            System.out.println("✅ Location count loaded");
            
        } catch (SQLException e) {
            System.out.println("❌ Error getting location count: " + e.getMessage());
        }
        
        return locationCount;
    }

    /**
     * Lock and validate a PartDetail for use in a repair report.
     * Uses SELECT ... FOR UPDATE to prevent concurrent modifications.
     * Returns the PartDetail if it exists and is Available, null otherwise.
     */
    public NewPartDetail lockAndValidatePartDetail(int partDetailId) throws SQLException {
        String sql = "SELECT pd.partDetailId, pd.partId, pd.serialNumber, pd.status, pd.location, " +
                     "       pd.lastUpdatedBy, pd.lastUpdatedDate, " +
                     "       a.username, " +
                     "       p.categoryId, c.categoryName " +
                     "FROM PartDetail pd " +
                     "LEFT JOIN Account a ON pd.lastUpdatedBy = a.accountId " +
                     "LEFT JOIN Part p ON pd.partId = p.partId " +
                     "LEFT JOIN Category c ON p.categoryId = c.categoryId " +
                     "WHERE pd.partDetailId = ? AND pd.status = 'Available' " +
                     "FOR UPDATE";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, partDetailId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    NewPartDetail pd = mapResultSetToPartDetail(rs);
                    System.out.println("✅ Locked and validated PartDetail ID: " + partDetailId);
                    return pd;
                }
            }
        }
        
        System.out.println("❌ PartDetail ID " + partDetailId + " not found or not Available");
        return null;
    }
    
    /**
     * Get available quantity for a specific Part (count of Available PartDetails).
     */
    public int getAvailableQuantityForPart(int partId) throws SQLException {
        String sql = "SELECT COUNT(*) as count FROM PartDetail " +
                     "WHERE partId = ? AND status = 'Available'";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, partId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("count");
                }
            }
        }
        
        return 0;
    }
    
    /**
     * Update PartDetail status to 'InUse' (optimistic locking).
     * Returns true if update succeeded (part was Available), false otherwise.
     */
    public boolean markPartDetailAsInUse(int partDetailId, int updatedBy) throws SQLException {
        String sql = "UPDATE PartDetail SET status = 'InUse', " +
                     "lastUpdatedBy = ?, lastUpdatedDate = ? " +
                     "WHERE partDetailId = ? AND status = 'Available'";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, updatedBy);
            ps.setDate(2, Date.valueOf(LocalDate.now()));
            ps.setInt(3, partDetailId);
            
            int rowsAffected = ps.executeUpdate();
            boolean success = rowsAffected > 0;
            
            if (success) {
                System.out.println("✅ Marked PartDetail ID " + partDetailId + " as InUse");
            } else {
                System.out.println("❌ Failed to mark PartDetail ID " + partDetailId + " as InUse (not Available or not found)");
            }
            
            return success;
        }
    }
    
    /**
     * Batch update multiple PartDetails to 'InUse' status.
     * Returns the number of successfully updated rows.
     */
    public int markPartDetailsAsInUse(List<Integer> partDetailIds, int updatedBy) throws SQLException {
        if (partDetailIds == null || partDetailIds.isEmpty()) {
            return 0;
        }
        
        // Build IN clause
        StringBuilder sql = new StringBuilder(
            "UPDATE PartDetail SET status = 'InUse', " +
            "lastUpdatedBy = ?, lastUpdatedDate = ? " +
            "WHERE partDetailId IN ("
        );
        
        for (int i = 0; i < partDetailIds.size(); i++) {
            if (i > 0) sql.append(",");
            sql.append("?");
        }
        sql.append(") AND status = 'Available'");
        
        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            ps.setInt(1, updatedBy);
            ps.setDate(2, Date.valueOf(LocalDate.now()));
            
            for (int i = 0; i < partDetailIds.size(); i++) {
                ps.setInt(i + 3, partDetailIds.get(i));
            }
            
            int rowsAffected = ps.executeUpdate();
            System.out.println("✅ Marked " + rowsAffected + " PartDetails as InUse");
            return rowsAffected;
        }
    }
    
    /**
     * Helper method: Map ResultSet to NewPartDetail
     */
    private NewPartDetail mapResultSetToPartDetail(ResultSet rs) throws SQLException {
        NewPartDetail pd = new NewPartDetail();
        pd.setPartDetailId(rs.getInt("partDetailId"));
        pd.setPartId(rs.getInt("partId"));
        pd.setSerialNumber(rs.getString("serialNumber"));
        pd.setStatus(rs.getString("status"));
        pd.setLocation(rs.getString("location"));
        pd.setLastUpdatedBy(rs.getInt("lastUpdatedBy"));
        pd.setUsername(rs.getString("username"));
        
        // Category info
        int categoryId = rs.getInt("categoryId");
        if (!rs.wasNull()) {
            pd.setCategoryId(categoryId);
        }
        pd.setCategoryName(rs.getString("categoryName"));
        
        Date date = rs.getDate("lastUpdatedDate");
        if (date != null) {
            pd.setLastUpdatedDate(date.toLocalDate());
        }
        
        return pd;
    }

    // ==================== MAIN METHOD FOR TESTING ====================
    public static void main(String[] args) {
        PartDetailDAO dao = new PartDetailDAO();
        
        System.out.println("========================================");
        System.out.println("TESTING PartDetailDAO with Category Support");
        System.out.println("========================================\n");

        // Test 1: Get All PartDetails
        System.out.println("--- Test 1: Get All PartDetails ---");
        List<NewPartDetail> allPartDetails = dao.getAllPartDetails();
        System.out.println("✅ Found " + allPartDetails.size() + " part detail(s)");
        
        if (!allPartDetails.isEmpty()) {
            NewPartDetail first = allPartDetails.get(0);
            System.out.println("First PartDetail:");
            System.out.println("  - Serial: " + first.getSerialNumber());
            System.out.println("  - Status: " + first.getStatus());
            System.out.println("  - Location: " + first.getLocation());
            System.out.println("  - Category: " + first.getCategoryName() + " (ID: " + first.getCategoryId() + ")");
            System.out.println("  - Updated by: " + first.getUsername());
        }
        System.out.println();

        // Test 2: Get PartDetail by ID
        System.out.println("--- Test 2: Get PartDetail by ID (1) ---");
        NewPartDetail pd = dao.getPartDetailById(1);
        if (pd != null) {
            System.out.println("✅ Found: " + pd.getSerialNumber());
            System.out.println("  - Status: " + pd.getStatus());
            System.out.println("  - Location: " + pd.getLocation());
            System.out.println("  - Category: " + pd.getCategoryName());
        } else {
            System.out.println("❌ PartDetail not found");
        }
        System.out.println();

        // Test 3: Get PartDetails by PartId
        System.out.println("--- Test 3: Get PartDetails by PartId (1) ---");
        List<NewPartDetail> partDetails = dao.getPartDetailsByPartId(1);
        System.out.println("✅ Found " + partDetails.size() + " part detail(s) for partId 1");
        
        for (NewPartDetail detail : partDetails) {
            System.out.println("  - " + detail.getSerialNumber() + " [" + detail.getStatus() + "] @ " + detail.getLocation());
        }
        System.out.println();

        // Test 4: Get PartDetails by Status
        System.out.println("--- Test 4: Get PartDetails by Status (Available) ---");
        List<NewPartDetail> availableDetails = dao.getPartDetailsByStatus("Available");
        System.out.println("✅ Found " + availableDetails.size() + " available part(s)");
        
        int count = 0;
        for (NewPartDetail detail : availableDetails) {
            System.out.println("  - " + detail.getSerialNumber() + " [" + detail.getCategoryName() + "]");
            if (++count >= 5) {
                System.out.println("  ... and " + (availableDetails.size() - 5) + " more");
                break;
            }
        }
        System.out.println();

        // Test 5: Get PartDetails by Category
        System.out.println("--- Test 5: Get PartDetails by Category (1 - HVAC Components) ---");
        List<NewPartDetail> hvacDetails = dao.getPartDetailsByCategory(1);
        System.out.println("✅ Found " + hvacDetails.size() + " HVAC part detail(s)");
        
        for (NewPartDetail detail : hvacDetails) {
            System.out.println("  - " + detail.getSerialNumber() + " @ " + detail.getLocation());
        }
        System.out.println();

        // Test 6: Search PartDetails
        System.out.println("--- Test 6: Search PartDetails (keyword: 'Warehouse') ---");
        List<NewPartDetail> searchResults = dao.searchPartDetails("Warehouse");
        System.out.println("✅ Found " + searchResults.size() + " result(s)");
        
        count = 0;
        for (NewPartDetail detail : searchResults) {
            System.out.println("  - " + detail.getSerialNumber() + " @ " + detail.getLocation() + " [" + detail.getCategoryName() + "]");
            if (++count >= 5) {
                System.out.println("  ... and " + (searchResults.size() - 5) + " more");
                break;
            }
        }
        System.out.println();

        // Test 7: Get Status Count
        System.out.println("--- Test 7: Get Overall Status Count ---");
        Map<String, Integer> statusCount = dao.getStatusCount();
        System.out.println("Status distribution:");
        statusCount.forEach((status, cnt) -> 
            System.out.println("  - " + status + ": " + cnt)
        );
        System.out.println();

        // Test 8: Get Location Count
        System.out.println("--- Test 8: Get Location Count ---");
        Map<String, Integer> locationCount = dao.getLocationCount();
        System.out.println("Location distribution (top 5):");
        locationCount.entrySet().stream()
            .limit(5)
            .forEach(entry -> 
                System.out.println("  - " + entry.getKey() + ": " + entry.getValue())
            );
        System.out.println();

        // Test 9: Insert New PartDetail (SIMULATION)
        System.out.println("--- Test 9: Insert New PartDetail (SIMULATION) ---");
        NewPartDetail newDetail = new NewPartDetail(1, "TEST-SERIAL-001", "Available", "Main Warehouse", 2, LocalDate.now());
        System.out.println("Would insert: " + newDetail.getSerialNumber() + " for partId " + newDetail.getPartId());
        // Uncomment to actually insert:
        // boolean inserted = dao.addPartDetail(newDetail);
        // System.out.println(inserted ? "✅ Inserted successfully" : "❌ Insert failed");
        System.out.println();

        System.out.println("========================================");
        System.out.println("ALL TESTS COMPLETED");
        System.out.println("========================================");
    }
}