package dal;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import model.PartDetailHistory;

/**
 * DAO để quản lý lịch sử thay đổi PartDetail
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
     * Lấy tất cả lịch sử với filter
     */
    public List<PartDetailHistory> getAllHistory(String fromDate, String toDate, 
                                                 String actionType, String keyword) {
        List<PartDetailHistory> list = new ArrayList<>();
        
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT h.historyId, h.partDetailId, h.oldStatus, h.newStatus, ")
           .append("h.changedBy, h.changedDate, h.notes, ")
           .append("a.fullName as username, ")
           .append("pd.serialNumber, pd.location, ")
           .append("p.partName ")
           .append("FROM PartDetailStatusHistory h ")
           .append("LEFT JOIN Account a ON h.changedBy = a.accountId ")
           .append("LEFT JOIN PartDetail pd ON h.partDetailId = pd.partDetailId ")
           .append("LEFT JOIN Part p ON pd.partId = p.partId ")
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
        
        // Search by serial number
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND pd.serialNumber LIKE ? ");
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
                ps.setString(paramIndex++, "%" + keyword.trim() + "%");
            }
            
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
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
                
                list.add(history);
            }
            
            System.out.println("✅ Loaded " + list.size() + " history records");
            
        } catch (SQLException e) {
            System.out.println("❌ Error getting history: " + e.getMessage());
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
            sql.append("AND pd.serialNumber LIKE ? ");
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
                ps.setString(paramIndex++, "%" + keyword.trim() + "%");
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
 * ⭐ Method mới - Dùng cho transaction từ DAO khác
 * Nhận connection từ bên ngoài để tránh tạo connection mới
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
        System.out.println("✅ History added: " + oldStatus + " → " + newStatus);
        return result > 0;
        
    } catch (SQLException e) {
        System.out.println("❌ Error adding history: " + e.getMessage());
        e.printStackTrace();
        return false;
    } finally {
        // CHỈ close PreparedStatement, KHÔNG close connection
        if (ps != null) {
            try {
                ps.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}
}   