package dal;

import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO for WorkTask operations in Technician scope.
 */
public class WorkTaskDAO extends MyDAO {

    public static class TaskRow {
        public long taskId;
        public Long requestId;
        public Long scheduleId;
        public Long technicianId;
        public String taskType;
        public String taskDetails;
        public java.sql.Date startDate;
        public java.sql.Date endDate;
        public String status;
        public java.sql.Date scheduledDate; // from MaintenanceSchedule
    }

    public List<TaskRow> listAssigned(long technicianId, int offset, int limit) throws SQLException {
        List<TaskRow> list = new ArrayList<>();
        xSql = "SELECT wt.taskId, wt.requestId, wt.scheduleId, wt.technicianId, wt.taskType, wt.taskDetails, wt.startDate, wt.endDate, wt.status, ms.scheduledDate " +
               "FROM WorkTask wt LEFT JOIN MaintenanceSchedule ms ON wt.scheduleId = ms.scheduleId " +
               "WHERE wt.technicianId = ? AND wt.status IN ('Assigned','InProgress','Scheduled') " +
               "ORDER BY COALESCE(ms.scheduledDate, wt.startDate) DESC LIMIT ?, ?";
        ps = con.prepareStatement(xSql);
        ps.setLong(1, technicianId);
        ps.setInt(2, offset);
        ps.setInt(3, limit);
        rs = ps.executeQuery();
        while (rs.next()) {
            TaskRow r = new TaskRow();
            r.taskId = rs.getLong("taskId");
            r.requestId = rs.getLong("requestId");
            r.scheduleId = rs.getLong("scheduleId");
            r.technicianId = rs.getLong("technicianId");
            r.taskType = rs.getString("taskType");
            r.taskDetails = rs.getString("taskDetails");
            r.startDate = rs.getDate("startDate");
            r.endDate = rs.getDate("endDate");
            r.status = rs.getString("status");
            r.scheduledDate = rs.getDate("scheduledDate");
            list.add(r);
        }
        return list;
    }

    public boolean belongsToTechnician(long taskId, long technicianId) throws SQLException {
        xSql = "SELECT COUNT(*) FROM WorkTask WHERE taskId=? AND technicianId=?";
        ps = con.prepareStatement(xSql);
        ps.setLong(1, taskId);
        ps.setLong(2, technicianId);
        rs = ps.executeQuery();
        if (rs.next()) return rs.getInt(1) > 0;
        return false;
    }

    public int getCurrentActiveTasks(long technicianId) throws SQLException {
        xSql = "SELECT COUNT(*) FROM WorkTask WHERE technicianId=? AND status IN ('Assigned','InProgress','Scheduled')";
        ps = con.prepareStatement(xSql);
        ps.setLong(1, technicianId);
        rs = ps.executeQuery();
        if (rs.next()) return rs.getInt(1);
        return 0;
    }

    public boolean hasTimeConflict(long technicianId, LocalDate startDate, LocalDate endDate) throws SQLException {
        xSql = "SELECT COUNT(*) FROM WorkTask wt LEFT JOIN MaintenanceSchedule ms ON wt.scheduleId = ms.scheduleId " +
               "WHERE wt.technicianId=? AND wt.status IN ('Assigned','InProgress','Scheduled') " +
               "AND ( (wt.startDate IS NOT NULL AND wt.endDate IS NOT NULL AND wt.startDate <= ? AND wt.endDate >= ?) " +
               "OR (ms.scheduledDate IS NOT NULL AND ms.scheduledDate BETWEEN ? AND ?) )";
        ps = con.prepareStatement(xSql);
        ps.setLong(1, technicianId);
        ps.setDate(2, java.sql.Date.valueOf(endDate));
        ps.setDate(3, java.sql.Date.valueOf(startDate));
        ps.setDate(4, java.sql.Date.valueOf(startDate));
        ps.setDate(5, java.sql.Date.valueOf(endDate));
        rs = ps.executeQuery();
        if (rs.next()) return rs.getInt(1) > 0;
        return false;
    }
}