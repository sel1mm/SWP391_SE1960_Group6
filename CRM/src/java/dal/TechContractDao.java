package dal;

import java.sql.SQLException;
import model.TechContract;

/**
 * DAO for TechContract with optional mock stub.
 */
public class TechContractDao extends MyDAO {
    private final boolean mockMode;
    public TechContractDao() { this(false); }
    public TechContractDao(boolean mockMode) { this.mockMode = mockMode; }

    public long save(TechContract c) throws SQLException {
        if (mockMode) return 1L;
        xSql = "INSERT INTO contracts (equipment_name, quantity, unit_price, description, date, technician_id, task_id) VALUES (?, ?, ?, ?, ?, ?, ?)";
        ps = con.prepareStatement(xSql, java.sql.Statement.RETURN_GENERATED_KEYS);
        ps.setString(1, c.getEquipmentName());
        ps.setInt(2, c.getQuantity());
        if (c.getUnitPrice() != null) ps.setDouble(3, c.getUnitPrice()); else ps.setNull(3, java.sql.Types.DECIMAL);
        ps.setString(4, c.getDescription());
        if (c.getDate() != null) ps.setDate(5, java.sql.Date.valueOf(c.getDate())); else ps.setNull(5, java.sql.Types.DATE);
        if (c.getTechnicianId() != null) ps.setLong(6, c.getTechnicianId()); else ps.setNull(6, java.sql.Types.BIGINT);
        if (c.getTaskId() != null) ps.setLong(7, c.getTaskId()); else ps.setNull(7, java.sql.Types.BIGINT);
        int affected = ps.executeUpdate();
        if (affected > 0) {
            rs = ps.getGeneratedKeys();
            if (rs.next()) return rs.getLong(1);
        }
        return 0L;
    }
}


