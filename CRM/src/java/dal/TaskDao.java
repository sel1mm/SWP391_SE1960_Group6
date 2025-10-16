package dal;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import model.TechTask;

/**
 * DAO for TechTask with optional mock mode for UI development.
 */
public class TaskDao extends MyDAO {
    private final boolean mockMode;

    public TaskDao() { this(false); }
    public TaskDao(boolean mockMode) { this.mockMode = mockMode; }

    public List<TechTask> findByTechnicianId(long technicianId, String q, String status, int page, int pageSize) throws SQLException {
        if (mockMode) return mockTasks();
        List<TechTask> list = new ArrayList<>();
        String sql = "SELECT id, title, description, status, priority, due_date, assigned_date, assigned_technician_id, equipment_needed FROM tasks WHERE assigned_technician_id = ?";
        List<Object> params = new ArrayList<>();
        params.add(technicianId);
        if (q != null && !q.trim().isEmpty()) {
            sql += " AND (title LIKE ? OR CAST(id AS CHAR) LIKE ?)";
            params.add("%" + q.trim() + "%");
            params.add("%" + q.trim() + "%");
        }
        if (status != null && !status.trim().isEmpty()) {
            sql += " AND status = ?";
            params.add(status.trim());
        }
        sql += " ORDER BY due_date ASC LIMIT ? OFFSET ?";
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

    public TechTask findById(long id) throws SQLException {
        if (mockMode) {
            TechTask t = mockTasks().get(0);
            t.setId(id);
            return t;
        }
        String sql = "SELECT id, title, description, status, priority, due_date, assigned_date, assigned_technician_id, equipment_needed FROM tasks WHERE id = ?";
        ps = con.prepareStatement(sql);
        ps.setLong(1, id);
        rs = ps.executeQuery();
        if (rs.next()) return mapTask(rs);
        return null;
    }

    public boolean updateStatus(long id, String status) throws SQLException {
        if (mockMode) return true;
        String sql = "UPDATE tasks SET status = ? WHERE id = ?";
        ps = con.prepareStatement(sql);
        ps.setString(1, status);
        ps.setLong(2, id);
        return ps.executeUpdate() > 0;
    }

    public void addStatusChangeLog(long taskId, long technicianId, String comment) throws SQLException {
        if (mockMode) return;
        String sql = "INSERT INTO task_activity (task_id, technician_id, activity, created_at) VALUES (?, ?, ?, NOW())";
        ps = con.prepareStatement(sql);
        ps.setLong(1, taskId);
        ps.setLong(2, technicianId);
        ps.setString(3, comment != null ? comment : "");
        ps.executeUpdate();
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

    private List<TechTask> mockTasks() {
        List<TechTask> list = new ArrayList<>();
        for (int i = 1; i <= 8; i++) {
            TechTask t = new TechTask();
            t.setId(1000L + i);
            t.setTitle("Mock Task " + i);
            t.setDescription("This is a mock task description for UI testing. Item " + i);
            t.setStatus(i % 3 == 0 ? "Completed" : (i % 2 == 0 ? "In Progress" : "Pending"));
            t.setPriority(i % 3 == 0 ? "High" : (i % 2 == 0 ? "Medium" : "Low"));
            t.setDueDate(LocalDate.now().plusDays(i));
            t.setAssignedDate(LocalDate.now().minusDays(2));
            t.setAssignedTechnicianId(1L);
            t.setEquipmentNeeded("Screwdriver, Multimeter");
            list.add(t);
        }
        return list;
    }
}


