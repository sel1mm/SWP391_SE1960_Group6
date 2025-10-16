package dal;

import java.sql.SQLException;
import model.TechRepairReport;

/**
 * DAO for TechRepairReport with optional mock stub.
 */
public class ReportDao extends MyDAO {
    private final boolean mockMode;
    public ReportDao() { this(false); }
    public ReportDao(boolean mockMode) { this.mockMode = mockMode; }

    public long save(TechRepairReport r) throws SQLException {
        if (mockMode) return 1L;
        xSql = "INSERT INTO repair_reports (task_id, summary, description, file_path, created_date) VALUES (?, ?, ?, ?, NOW())";
        ps = con.prepareStatement(xSql, java.sql.Statement.RETURN_GENERATED_KEYS);
        ps.setLong(1, r.getTaskId());
        ps.setString(2, r.getSummary());
        ps.setString(3, r.getDescription());
        ps.setString(4, r.getFilePath());
        int affected = ps.executeUpdate();
        if (affected > 0) {
            rs = ps.getGeneratedKeys();
            if (rs.next()) return rs.getLong(1);
        }
        return 0L;
    }
}


