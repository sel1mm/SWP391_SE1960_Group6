package dal;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import model.TechTask;

/**
 * DAO for Work History with optional mock mode for UI development.
 */
public class WorkHistoryDao extends MyDAO {
    private final boolean mockMode;
    private static List<TechTask> cachedMockData = null;

    public WorkHistoryDao() { this(false); }
    public WorkHistoryDao(boolean mockMode) { this.mockMode = mockMode; }

    public List<TechTask> findByTechnicianId(long technicianId, String status, LocalDate startDate, LocalDate endDate, int page, int pageSize) throws SQLException {
        if (mockMode) return mockWorkHistory();
        List<TechTask> list = new ArrayList<>();
        String sql = "SELECT id, title, description, status, priority, due_date, assigned_date, assigned_technician_id, equipment_needed FROM tasks WHERE assigned_technician_id = ?";
        List<Object> params = new ArrayList<>();
        params.add(technicianId);
        
        if (status != null && !status.trim().isEmpty()) {
            sql += " AND status = ?";
            params.add(status.trim());
        }
        
        if (startDate != null) {
            sql += " AND assigned_date >= ?";
            params.add(startDate);
        }
        
        if (endDate != null) {
            sql += " AND assigned_date <= ?";
            params.add(endDate);
        }
        
        sql += " ORDER BY assigned_date DESC LIMIT ? OFFSET ?";
        params.add(pageSize);
        params.add(Math.max(0, (page - 1)) * pageSize);

        ps = con.prepareStatement(sql);
        for (int i = 0; i < params.size(); i++) {
            ps.setObject(i + 1, params.get(i));
        }
        rs = ps.executeQuery();
        while (rs.next()) {
            list.add(mapTask(rs));
        }
        return list;
    }

    public int getTotalCount(long technicianId, String status, LocalDate startDate, LocalDate endDate) throws SQLException {
        if (mockMode) return 25; // Mock total count
        String sql = "SELECT COUNT(*) FROM tasks WHERE assigned_technician_id = ?";
        List<Object> params = new ArrayList<>();
        params.add(technicianId);
        
        if (status != null && !status.trim().isEmpty()) {
            sql += " AND status = ?";
            params.add(status.trim());
        }
        
        if (startDate != null) {
            sql += " AND assigned_date >= ?";
            params.add(startDate);
        }
        
        if (endDate != null) {
            sql += " AND assigned_date <= ?";
            params.add(endDate);
        }

        ps = con.prepareStatement(sql);
        for (int i = 0; i < params.size(); i++) {
            ps.setObject(i + 1, params.get(i));
        }
        rs = ps.executeQuery();
        if (rs.next()) return rs.getInt(1);
        return 0;
    }

    private TechTask mapTask(ResultSet rs) throws SQLException {
        TechTask t = new TechTask();
        t.setId(rs.getLong("id"));
        t.setTitle(rs.getString("title"));
        t.setDescription(rs.getString("description"));
        t.setStatus(rs.getString("status"));
        t.setPriority(rs.getString("priority"));
        java.sql.Date due = rs.getDate("due_date");
        if (due != null) t.setDueDate(due.toLocalDate());
        java.sql.Date assigned = rs.getDate("assigned_date");
        if (assigned != null) t.setAssignedDate(assigned.toLocalDate());
        t.setAssignedTechnicianId(rs.getLong("assigned_technician_id"));
        t.setEquipmentNeeded(rs.getString("equipment_needed"));
        return t;
    }

    private List<TechTask> mockWorkHistory() {
        // Use cached data to prevent repeated generation
        if (cachedMockData != null) {
            return new ArrayList<>(cachedMockData);
        }
        
        List<TechTask> list = new ArrayList<>();
        // Reduced to 5 items for better performance
        for (int i = 1; i <= 5; i++) {
            TechTask t = new TechTask();
            t.setId(2000L + i);
            t.setTitle("Task " + i);
            t.setDescription("Completed work item " + i);
            t.setStatus("Completed");
            t.setPriority(i % 3 == 0 ? "High" : (i % 2 == 0 ? "Medium" : "Low"));
            t.setDueDate(LocalDate.now().minusDays(i));
            t.setAssignedDate(LocalDate.now().minusDays(i + 2));
            t.setAssignedTechnicianId(1L);
            t.setEquipmentNeeded("Tools");
            list.add(t);
        }
        
        // Cache the data
        cachedMockData = new ArrayList<>(list);
        return list;
    }
}
