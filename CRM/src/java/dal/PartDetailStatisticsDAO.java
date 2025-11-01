package dal;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import model.PartDetailStatistics;

/**
 * DAO để lấy thống kê từ bảng PartDetailStatusHistory
 * @author Admin
 */
public class PartDetailStatisticsDAO extends DBContext {
    
    /**
     * Lấy danh sách chi tiết theo status và khoảng thời gian
     * @param newStatus - Trạng thái cần thống kê (InUse, Faulty, Available, Retired)
     * @param fromDate - Từ ngày (format: yyyy-MM-dd)
     * @param toDate - Đến ngày (format: yyyy-MM-dd)
     */
    public List<PartDetailStatistics> getDetailsByStatusAndDate(String newStatus, 
                                                                String fromDate, 
                                                                String toDate) {
        List<PartDetailStatistics> list = new ArrayList<>();
        
        String sql = "SELECT " +
                     "h.historyId, " +
                     "h.partDetailId, " +
                     "h.oldStatus, " +
                     "h.newStatus, " +
                     "h.changedBy, " +
                     "h.changedDate, " +
                     "h.notes, " +
                     "a.fullName as technicianName, " +  // ✅ Sửa từ CONCAT
                     "pd.serialNumber, " +
                     "pd.location, " +
                     "p.partName " +  // ✅ Bỏ p.category
                     "FROM PartDetailStatusHistory h " +
                     "LEFT JOIN Account a ON h.changedBy = a.accountId " +
                     "LEFT JOIN PartDetail pd ON h.partDetailId = pd.partDetailId " +
                     "LEFT JOIN Part p ON pd.partId = p.partId " +
                     "WHERE h.newStatus = ? " +
                     "AND DATE(h.changedDate) BETWEEN ? AND ? " +
                     "ORDER BY h.changedDate DESC";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setString(2, fromDate);
            ps.setString(3, toDate);
            
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                PartDetailStatistics stat = new PartDetailStatistics();
                stat.setHistoryId(rs.getInt("historyId"));
                stat.setPartDetailId(rs.getInt("partDetailId"));
                stat.setOldStatus(rs.getString("oldStatus"));
                stat.setNewStatus(rs.getString("newStatus"));
                stat.setChangedBy(rs.getInt("changedBy"));
                stat.setChangedDate(rs.getTimestamp("changedDate").toLocalDateTime());
                stat.setNotes(rs.getString("notes"));
                stat.setTechnicianName(rs.getString("technicianName"));
                stat.setSerialNumber(rs.getString("serialNumber"));
                stat.setLocation(rs.getString("location"));
                stat.setPartName(rs.getString("partName"));
                // ✅ Bỏ stat.setCategory(rs.getString("category"));
                
                list.add(stat);
            }
            
            System.out.println("✅ Found " + list.size() + " records for status: " + newStatus);
            
        } catch (SQLException e) {
            System.out.println("❌ Error in getDetailsByStatusAndDate: " + e.getMessage());
            e.printStackTrace();
        }
        
        return list;
    }
    
    /**
     * Thống kê tổng hợp theo Technician
     * @param newStatus - Trạng thái cần thống kê
     * @param fromDate - Từ ngày
     * @param toDate - Đến ngày
     */
    public List<PartDetailStatistics> getStatisticsByTechnician(String newStatus, 
                                                                String fromDate, 
                                                                String toDate) {
        List<PartDetailStatistics> list = new ArrayList<>();
        
        String sql = "SELECT " +
                     "h.changedBy, " +
                     "a.fullName as technicianName, " +  // ✅ Sửa từ CONCAT
                     "COUNT(*) as totalChanges, " +
                     "MIN(h.changedDate) as firstChange, " +
                     "MAX(h.changedDate) as lastChange " +
                     "FROM PartDetailStatusHistory h " +
                     "LEFT JOIN Account a ON h.changedBy = a.accountId " +
                     "WHERE h.newStatus = ? " +
                     "AND DATE(h.changedDate) BETWEEN ? AND ? " +
                     "GROUP BY h.changedBy, a.fullName " +  // ✅ Sửa GROUP BY
                     "ORDER BY totalChanges DESC";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setString(2, fromDate);
            ps.setString(3, toDate);
            
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                PartDetailStatistics stat = new PartDetailStatistics();
                stat.setChangedBy(rs.getInt("changedBy"));
                stat.setTechnicianName(rs.getString("technicianName"));
                stat.setTotalChanges(rs.getInt("totalChanges"));
                
                list.add(stat);
            }
            
            System.out.println("✅ Found " + list.size() + " technicians");
            
        } catch (SQLException e) {
            System.out.println("❌ Error in getStatisticsByTechnician: " + e.getMessage());
            e.printStackTrace();
        }
        
        return list;
    }
    
    /**
     * Lấy thống kê tổng quan (Overview)
     * @param fromDate - Từ ngày
     * @param toDate - Đến ngày
     */
    public PartDetailStatistics getOverviewStatistics(String fromDate, String toDate) {
        PartDetailStatistics stat = new PartDetailStatistics();
        
        String sql = "SELECT " +
                     "SUM(CASE WHEN newStatus = 'InUse' THEN 1 ELSE 0 END) as inUseCount, " +
                     "SUM(CASE WHEN newStatus = 'Faulty' THEN 1 ELSE 0 END) as faultyCount, " +
                     "SUM(CASE WHEN newStatus = 'Available' THEN 1 ELSE 0 END) as availableCount, " +
                     "SUM(CASE WHEN newStatus = 'Retired' THEN 1 ELSE 0 END) as retiredCount, " +
                     "COUNT(*) as totalChanges " +
                     "FROM PartDetailStatusHistory " +
                     "WHERE DATE(changedDate) BETWEEN ? AND ?";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, fromDate);
            ps.setString(2, toDate);
            
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                stat.setInUseCount(rs.getInt("inUseCount"));
                stat.setFaultyCount(rs.getInt("faultyCount"));
                stat.setAvailableCount(rs.getInt("availableCount"));
                stat.setRetiredCount(rs.getInt("retiredCount"));
                stat.setTotalChanges(rs.getInt("totalChanges"));
                
                System.out.println("✅ Overview stats loaded");
            }
            
        } catch (SQLException e) {
            System.out.println("❌ Error in getOverviewStatistics: " + e.getMessage());
            e.printStackTrace();
        }
        
        return stat;
    }
    
    /**
     * Đếm số lượng theo status
     */
    public int countByStatus(String newStatus, String fromDate, String toDate) {
        String sql = "SELECT COUNT(*) as total " +
                     "FROM PartDetailStatusHistory " +
                     "WHERE newStatus = ? " +
                     "AND DATE(changedDate) BETWEEN ? AND ?";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setString(2, fromDate);
            ps.setString(3, toDate);
            
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("total");
            }
            
        } catch (SQLException e) {
            System.out.println("❌ Error in countByStatus: " + e.getMessage());
        }
        
        return 0;
    }
     public static void main(String[] args) {
        // Tạo đối tượng DAO
        PartDetailStatisticsDAO dao = new PartDetailStatisticsDAO();

        // Khai báo tham số test
        String fromDate = "2025-01-01";
        String toDate = "2025-12-31";
        String status = "Available";

        // -------------------------------
        // 1️⃣ Test lấy danh sách chi tiết theo trạng thái
        // -------------------------------
        System.out.println("===== Test getDetailsByStatusAndDate() =====");
        List<PartDetailStatistics> details = dao.getDetailsByStatusAndDate(status, fromDate, toDate);
        for (PartDetailStatistics d : details) {
            System.out.println(
                "HistoryID: " + d.getHistoryId() +
                ", PartDetailID: " + d.getPartDetailId() +
                ", Status: " + d.getOldStatus() + " → " + d.getNewStatus() +
                ", Technician: " + d.getTechnicianName() +
                ", Date: " + d.getChangedDate() +
                ", Notes: " + d.getNotes()
            );
        }

        // -------------------------------
        // 2️⃣ Test thống kê theo kỹ thuật viên
        // -------------------------------
        System.out.println("\n===== Test getStatisticsByTechnician() =====");
        List<PartDetailStatistics> techStats = dao.getStatisticsByTechnician(status, fromDate, toDate);
        for (PartDetailStatistics t : techStats) {
            System.out.println(
                "Technician: " + t.getTechnicianName() +
                " | Changes: " + t.getTotalChanges()
            );
        }

        // -------------------------------
        // 3️⃣ Test thống kê tổng quan
        // -------------------------------
        System.out.println("\n===== Test getOverviewStatistics() =====");
        PartDetailStatistics overview = dao.getOverviewStatistics(fromDate, toDate);
        System.out.println(
            "InUse: " + overview.getInUseCount() +
            ", Faulty: " + overview.getFaultyCount() +
            ", Available: " + overview.getAvailableCount() +
            ", Retired: " + overview.getRetiredCount() +
            ", Total changes: " + overview.getTotalChanges()
        );

        // -------------------------------
        // 4️⃣ Test đếm theo status
        // -------------------------------
        System.out.println("\n===== Test countByStatus() =====");
        int total = dao.countByStatus(status, fromDate, toDate);
        System.out.println("Total '" + status + "' changes: " + total);
    }
}