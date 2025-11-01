package dal;

import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import model.NewPartDetail;

/**
 * PartDetailDAO - Data Access Object cho PartDetail
 * @author Admin
 */
public class PartDetailDAO extends DBContext {

    // ===== GET ALL với JOIN để lấy username =====
    public List<NewPartDetail> getAllPartDetails() {
        List<NewPartDetail> list = new ArrayList<>();
        String sql = "SELECT pd.*, a.username " +
                     "FROM PartDetail pd " +
                     "LEFT JOIN Account a ON pd.lastUpdatedBy = a.accountId " +
                     "ORDER BY pd.partDetailId DESC";
        
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                NewPartDetail pd = new NewPartDetail();
                pd.setPartDetailId(rs.getInt("partDetailId"));
                pd.setPartId(rs.getInt("partId"));
                pd.setSerialNumber(rs.getString("serialNumber"));
                pd.setStatus(rs.getString("status"));
                pd.setLocation(rs.getString("location"));
                pd.setLastUpdatedBy(rs.getInt("lastUpdatedBy"));
                pd.setUsername(rs.getString("username")); // từ JOIN
                
                Date date = rs.getDate("lastUpdatedDate");
                if (date != null) {
                    pd.setLastUpdatedDate(date.toLocalDate());
                }
                
                list.add(pd);
            }
            
            System.out.println("✅ Loaded " + list.size() + " part details");
            
        } catch (SQLException e) {
            System.out.println("❌ Error in getAllPartDetails: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    // ===== GET BY ID =====
    public NewPartDetail getPartDetailById(int partDetailId) {
        String sql = "SELECT pd.*, a.username " +
                     "FROM PartDetail pd " +
                     "LEFT JOIN Account a ON pd.lastUpdatedBy = a.accountId " +
                     "WHERE pd.partDetailId = ?";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, partDetailId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    NewPartDetail pd = new NewPartDetail();
                    pd.setPartDetailId(rs.getInt("partDetailId"));
                    pd.setPartId(rs.getInt("partId"));
                    pd.setSerialNumber(rs.getString("serialNumber"));
                    pd.setStatus(rs.getString("status"));
                    pd.setLocation(rs.getString("location"));
                    pd.setLastUpdatedBy(rs.getInt("lastUpdatedBy"));
                    pd.setUsername(rs.getString("username"));
                    
                    Date date = rs.getDate("lastUpdatedDate");
                    if (date != null) {
                        pd.setLastUpdatedDate(date.toLocalDate());
                    }
                    
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

    // ===== ADD (INSERT) =====
    public boolean addPartDetail(NewPartDetail part) {
        System.out.println("=== DAO: addPartDetail START ===");
        String sql = "INSERT INTO PartDetail (partId, serialNumber, status, location, lastUpdatedBy, lastUpdatedDate) "
                   + "VALUES (?, ?, ?, ?, ?, ?)";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, part.getPartId());
            ps.setString(2, part.getSerialNumber());
            ps.setString(3, part.getStatus());
            ps.setString(4, part.getLocation());
            ps.setInt(5, part.getLastUpdatedBy()); // accountId (INT)
            
            // Set date
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
            
            return rows > 0;
            
        } catch (SQLException e) {
            System.out.println("❌ SQL ERROR in addPartDetail: " + e.getMessage());
            e.printStackTrace();
            
            // Chi tiết lỗi
            if (e.getMessage().contains("Duplicate entry")) {
                System.out.println("❌ Serial Number đã tồn tại!");
            } else if (e.getMessage().contains("foreign key")) {
                System.out.println("❌ PartId hoặc AccountId không tồn tại!");
            }
            
            return false;
        }
    }

    // ===== UPDATE =====
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

    // ===== DELETE =====
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
 * Lấy ID của PartDetail vừa được thêm vào
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
}