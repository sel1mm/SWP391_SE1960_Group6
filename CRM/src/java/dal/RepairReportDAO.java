package dal;

import model.RepairReport;
import java.sql.*;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO for RepairReport operations.
 * Handles database operations for technician repair reports.
 */
public class RepairReportDAO extends MyDAO {
    
    /**
     * Create a new repair report
     */
    public int createRepairReport(RepairReport report) throws SQLException {
        xSql = "INSERT INTO RepairReport (requestId, technicianId, details, diagnosis, estimatedCost, quotationStatus, repairDate) " +
               "VALUES (?, ?, ?, ?, ?, ?, ?)";
        ps = con.prepareStatement(xSql, Statement.RETURN_GENERATED_KEYS);
        ps.setInt(1, report.getRequestId());
        ps.setInt(2, report.getTechnicianId());
        ps.setString(3, report.getDetails());
        ps.setString(4, report.getDiagnosis());
        ps.setBigDecimal(5, report.getEstimatedCost());
        ps.setString(6, report.getQuotationStatus());
        ps.setDate(7, Date.valueOf(report.getRepairDate()));
        
        int affected = ps.executeUpdate();
        if (affected > 0) {
            rs = ps.getGeneratedKeys();
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }
    
    /**
     * Update an existing repair report
     */
    public boolean updateRepairReport(RepairReport report) throws SQLException {
        xSql = "UPDATE RepairReport SET details = ?, diagnosis = ?, estimatedCost = ?, repairDate = ? " +
               "WHERE reportId = ? AND technicianId = ?";
        ps = con.prepareStatement(xSql);
        ps.setString(1, report.getDetails());
        ps.setString(2, report.getDiagnosis());
        ps.setBigDecimal(3, report.getEstimatedCost());
        ps.setDate(4, Date.valueOf(report.getRepairDate()));
        ps.setInt(5, report.getReportId());
        ps.setInt(6, report.getTechnicianId());
        
        int affected = ps.executeUpdate();
        return affected > 0;
    }
    
    /**
     * Find repair reports by technician ID
     */
    public List<RepairReport> findByTechnicianId(int technicianId, String searchQuery, String statusFilter, int page, int pageSize) throws SQLException {
        List<RepairReport> reports = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT rr.reportId, rr.requestId, rr.technicianId, rr.details, rr.diagnosis, ");
        sql.append("rr.estimatedCost, rr.quotationStatus, rr.repairDate, rr.invoiceDetailId ");
        sql.append("FROM RepairReport rr WHERE rr.technicianId = ?");
        
        List<Object> params = new ArrayList<>();
        params.add(technicianId);
        
        // Add search filter
        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            sql.append(" AND (rr.details LIKE ? OR rr.diagnosis LIKE ? OR CAST(rr.reportId AS CHAR) LIKE ?)");
            String searchPattern = "%" + searchQuery.trim() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
        }
        
        // Add status filter
        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            sql.append(" AND rr.quotationStatus = ?");
            params.add(statusFilter.trim());
        }
        
        sql.append(" ORDER BY rr.repairDate DESC LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add((page - 1) * pageSize);
        
        ps = con.prepareStatement(sql.toString());
        for (int i = 0; i < params.size(); i++) {
            ps.setObject(i + 1, params.get(i));
        }
        
        rs = ps.executeQuery();
        while (rs.next()) {
            reports.add(mapResultSetToRepairReport(rs));
        }
        
        return reports;
    }
    
    /**
     * Find repair report by ID
     */
    public RepairReport findById(int reportId) throws SQLException {
        xSql = "SELECT * FROM RepairReport WHERE reportId = ?";
        ps = con.prepareStatement(xSql);
        ps.setInt(1, reportId);
        rs = ps.executeQuery();
        
        if (rs.next()) {
            return mapResultSetToRepairReport(rs);
        }
        return null;
    }
    
    /**
     * Find repair report by request ID
     */
    public RepairReport findByRequestId(int requestId) throws SQLException {
        xSql = "SELECT * FROM RepairReport WHERE requestId = ?";
        ps = con.prepareStatement(xSql);
        ps.setInt(1, requestId);
        rs = ps.executeQuery();
        
        if (rs.next()) {
            return mapResultSetToRepairReport(rs);
        }
        return null;
    }
    
    /**
     * Check if technician can edit report (only if quotation status is Pending)
     */
    public boolean canTechnicianEditReport(int reportId, int technicianId) throws SQLException {
        xSql = "SELECT quotationStatus FROM RepairReport WHERE reportId = ? AND technicianId = ?";
        ps = con.prepareStatement(xSql);
        ps.setInt(1, reportId);
        ps.setInt(2, technicianId);
        rs = ps.executeQuery();
        
        if (rs.next()) {
            String status = rs.getString("quotationStatus");
            return "Pending".equals(status);
        }
        return false;
    }
    
    /**
     * Get report count for technician
     */
    public int getReportCountForTechnician(int technicianId, String statusFilter) throws SQLException {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) FROM RepairReport WHERE technicianId = ?");
        
        List<Object> params = new ArrayList<>();
        params.add(technicianId);
        
        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            sql.append(" AND quotationStatus = ?");
            params.add(statusFilter.trim());
        }
        
        ps = con.prepareStatement(sql.toString());
        for (int i = 0; i < params.size(); i++) {
            ps.setObject(i + 1, params.get(i));
        }
        
        rs = ps.executeQuery();
        if (rs.next()) {
            return rs.getInt(1);
        }
        return 0;
    }
    
    /**
     * Map ResultSet to RepairReport object
     */
    private RepairReport mapResultSetToRepairReport(ResultSet rs) throws SQLException {
        RepairReport report = new RepairReport();
        report.setReportId(rs.getInt("reportId"));
        report.setRequestId(rs.getInt("requestId"));
        
        Integer technicianId = rs.getObject("technicianId", Integer.class);
        report.setTechnicianId(technicianId);
        
        report.setDetails(rs.getString("details"));
        report.setDiagnosis(rs.getString("diagnosis"));
        
        BigDecimal estimatedCost = rs.getBigDecimal("estimatedCost");
        report.setEstimatedCost(estimatedCost);
        
        report.setQuotationStatus(rs.getString("quotationStatus"));
        
        Date repairDate = rs.getDate("repairDate");
        if (repairDate != null) {
            report.setRepairDate(repairDate.toLocalDate());
        }
        
        Integer invoiceDetailId = rs.getObject("invoiceDetailId", Integer.class);
        report.setInvoiceDetailId(invoiceDetailId);
        
        return report;
    }
    
    public List<RepairReport> findSubmittedReportsByTechnician(int technicianId, String searchQuery, int page, int pageSize) throws SQLException {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT * FROM RepairReport ");
        sql.append("WHERE technicianId = ? ");
        
        List<Object> params = new ArrayList<>();
        params.add(technicianId);
        
        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            sql.append("AND (details LIKE ? OR diagnosis LIKE ?) ");
            String searchPattern = "%" + searchQuery.trim() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
        }
        
        sql.append("ORDER BY repairDate DESC ");
        sql.append("LIMIT ? OFFSET ?");
        
        int offset = (page - 1) * pageSize;
        params.add(pageSize);
        params.add(offset);
        
        List<RepairReport> reports = new ArrayList<>();
        xSql = sql.toString();
        
        try {
            ps = con.prepareStatement(xSql);
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            rs = ps.executeQuery();
            
            while (rs.next()) {
                reports.add(mapResultSetToRepairReport(rs));
            }
        } finally {
            closeResources();
        }
        
        return reports;
    }
    
    public int getSubmittedReportCountForTechnician(int technicianId, String searchQuery) throws SQLException {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) FROM RepairReport ");
        sql.append("WHERE technicianId = ? ");
        
        List<Object> params = new ArrayList<>();
        params.add(technicianId);
        
        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            sql.append("AND (details LIKE ? OR diagnosis LIKE ?) ");
            String searchPattern = "%" + searchQuery.trim() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
        }
        
        xSql = sql.toString();
        
        try {
            ps = con.prepareStatement(xSql);
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1);
            }
        } finally {
            closeResources();
        }
        
        return 0;
    }
    
    private void closeResources() {
        try {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
