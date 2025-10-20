package dal;

import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import model.TechRepairReport;

/**
 * DAO for RepairReport table (technician quotations).
 */
public class RepairReportDAO extends MyDAO {

    public long save(TechRepairReport report) throws SQLException {
        String sql;
        boolean isInsert = report.getReportId() == null;
        if (isInsert) {
            sql = "INSERT INTO RepairReport (requestId, technicianId, details, diagnosis, estimatedCost, quotationStatus, repairDate) VALUES (?, ?, ?, ?, ?, ?, ?)";
        } else {
            sql = "UPDATE RepairReport SET details=?, diagnosis=?, estimatedCost=?, quotationStatus=?, repairDate=? WHERE reportId=? AND technicianId=?";
        }
        ps = con.prepareStatement(sql, java.sql.Statement.RETURN_GENERATED_KEYS);
        if (isInsert) {
            ps.setLong(1, report.getRequestId());
            ps.setLong(2, report.getTechnicianId());
            ps.setString(3, report.getDetails());
            ps.setString(4, report.getDiagnosis());
            ps.setBigDecimal(5, report.getEstimatedCost());
            ps.setString(6, report.getQuotationStatus());
            ps.setDate(7, java.sql.Date.valueOf(report.getRepairDate()));
        } else {
            ps.setString(1, report.getDetails());
            ps.setString(2, report.getDiagnosis());
            ps.setBigDecimal(3, report.getEstimatedCost());
            ps.setString(4, report.getQuotationStatus());
            ps.setDate(5, java.sql.Date.valueOf(report.getRepairDate()));
            ps.setLong(6, report.getReportId());
            ps.setLong(7, report.getTechnicianId());
        }
        int affected = ps.executeUpdate();
        if (affected > 0 && isInsert) {
            rs = ps.getGeneratedKeys();
            if (rs.next()) return rs.getLong(1);
        }
        return isInsert ? 0L : report.getReportId();
    }

    public List<TechRepairReport> findByTechnicianId(long technicianId) throws SQLException {
        List<TechRepairReport> list = new ArrayList<>();
        xSql = "SELECT reportId, requestId, technicianId, details, diagnosis, estimatedCost, quotationStatus, repairDate, invoiceDetailId FROM RepairReport WHERE technicianId=? ORDER BY repairDate DESC";
        ps = con.prepareStatement(xSql);
        ps.setLong(1, technicianId);
        rs = ps.executeQuery();
        while (rs.next()) {
            list.add(map(rs));
        }
        return list;
    }

    public TechRepairReport findById(long reportId) throws SQLException {
        xSql = "SELECT reportId, requestId, technicianId, details, diagnosis, estimatedCost, quotationStatus, repairDate, invoiceDetailId FROM RepairReport WHERE reportId = ?";
        ps = con.prepareStatement(xSql);
        ps.setLong(1, reportId);
        rs = ps.executeQuery();
        if (rs.next()) return map(rs);
        return null;
    }

    private TechRepairReport map(java.sql.ResultSet rs) throws SQLException {
        TechRepairReport r = new TechRepairReport();
        r.setReportId(rs.getLong("reportId"));
        r.setRequestId(rs.getLong("requestId"));
        r.setTechnicianId(rs.getLong("technicianId"));
        r.setDetails(rs.getString("details"));
        r.setDiagnosis(rs.getString("diagnosis"));
        r.setEstimatedCost(rs.getBigDecimal("estimatedCost"));
        r.setQuotationStatus(rs.getString("quotationStatus"));
        java.sql.Date d = rs.getDate("repairDate");
        if (d != null) r.setRepairDate(d.toLocalDate());
        long inv = rs.getLong("invoiceDetailId");
        if (inv > 0) r.setInvoiceDetailId(inv);
        return r;
    }
}


