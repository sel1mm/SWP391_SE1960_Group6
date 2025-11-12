package dal;

import model.RepairReport;
import model.RepairReportDetail;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO for RepairReport operations. Handles database operations for technician
 * repair reports.
 */
public class RepairReportDAO extends MyDAO {

    /**
     * Get repair reports for a technician with customer information
     */
    public List<RepairReportWithCustomer> getRepairReportsForTechnicianWithCustomer(int technicianId, String searchQuery, String statusFilter, int page, int pageSize) throws SQLException {
        List<RepairReportWithCustomer> reports = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT rr.reportId, rr.requestId, rr.technicianId, rr.details, rr.diagnosis, ");
        sql.append("rr.estimatedCost, rr.quotationStatus, rr.repairDate, rr.invoiceDetailId, ");
        sql.append("sr.createdBy as customerId, a.fullName as customerName, a.email as customerEmail ");
        sql.append("FROM RepairReport rr ");
        sql.append("JOIN ServiceRequest sr ON rr.requestId = sr.requestId ");
        sql.append("JOIN Account a ON sr.createdBy = a.accountId ");
        sql.append("WHERE rr.technicianId = ?");

        List<Object> params = new ArrayList<>();
        params.add(technicianId);

        // Add search filter
        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            sql.append(" AND (rr.details LIKE ? OR rr.diagnosis LIKE ? OR CAST(rr.reportId AS CHAR) LIKE ? OR a.fullName LIKE ?)");
            String searchPattern = "%" + searchQuery.trim() + "%";
            params.add(searchPattern);
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

        ps = connection.prepareStatement(sql.toString());
        for (int i = 0; i < params.size(); i++) {
            ps.setObject(i + 1, params.get(i));
        }

        rs = ps.executeQuery();
        while (rs.next()) {
            RepairReportWithCustomer reportWithCustomer = new RepairReportWithCustomer();
            reportWithCustomer.report = mapResultSetToRepairReport(rs);
            reportWithCustomer.customerId = rs.getInt("customerId");
            reportWithCustomer.customerName = rs.getString("customerName");
            reportWithCustomer.customerEmail = rs.getString("customerEmail");
            reports.add(reportWithCustomer);
        }

        return reports;
    }

    /**
     * Get repair report count for technician with customer information
     */
    public int getRepairReportCountForTechnicianWithCustomer(int technicianId, String statusFilter) throws SQLException {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) FROM RepairReport rr ");
        sql.append("JOIN ServiceRequest sr ON rr.requestId = sr.requestId ");
        sql.append("JOIN Account a ON sr.createdBy = a.accountId ");
        sql.append("WHERE rr.technicianId = ?");

        List<Object> params = new ArrayList<>();
        params.add(technicianId);

        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            sql.append(" AND rr.quotationStatus = ?");
            params.add(statusFilter.trim());
        }

        ps = connection.prepareStatement(sql.toString());
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
        report.setTechnicianId(rs.getObject("technicianId", Integer.class));
        report.setDetails(rs.getString("details"));
        report.setDiagnosis(rs.getString("diagnosis"));
        report.setEstimatedCost(rs.getBigDecimal("estimatedCost"));
        report.setQuotationStatus(rs.getString("quotationStatus"));

        Date repairDate = rs.getDate("repairDate");
        if (repairDate != null) {
            report.setRepairDate(repairDate.toLocalDate());
        }

        report.setInvoiceDetailId(rs.getObject("invoiceDetailId", Integer.class));
        return report;
    }

    /**
     * Inner class for RepairReport with customer information
     */
    public static class RepairReportWithCustomer {

        public RepairReport report;
        public int customerId;
        public String customerName;
        public String customerEmail;

        public RepairReport getReport() {
            return report;
        }

        public int getCustomerId() {
            return customerId;
        }

        public String getCustomerName() {
            return customerName;
        }

        public String getCustomerEmail() {
            return customerEmail;
        }
    }

    /**
     * Create a new repair report
     */
    public int createRepairReport(RepairReport report) throws SQLException {
        xSql = "INSERT INTO RepairReport (requestId, scheduleId, origin, technicianId, details, diagnosis, estimatedCost, quotationStatus, repairDate) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        ps = connection.prepareStatement(xSql, Statement.RETURN_GENERATED_KEYS);
        // requestId is primitive int in model; treat values <= 0 as NULL for DB
        if (report.getRequestId() > 0) {
            ps.setInt(1, report.getRequestId());
        } else {
            ps.setNull(1, Types.INTEGER);
        }
        if (report.getScheduleId() != null) {
            ps.setInt(2, report.getScheduleId());
        } else {
            ps.setNull(2, Types.INTEGER);
        }
        ps.setString(3, report.getOrigin() != null ? report.getOrigin() : "ServiceRequest");
        ps.setInt(4, report.getTechnicianId());
        ps.setString(5, report.getDetails());
        ps.setString(6, report.getDiagnosis());
        ps.setBigDecimal(7, report.getEstimatedCost());
        ps.setString(8, report.getQuotationStatus());
        ps.setDate(9, Date.valueOf(report.getRepairDate()));

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
     * Create a new repair report with details in a single transaction. Inserts
     * the RepairReport header and all RepairReportDetail rows atomically.
     *
     * @param report The repair report to insert
     * @param details List of repair report detail lines (parts)
     * @return The generated reportId, or 0 if insertion failed
     * @throws SQLException If database error occurs (transaction will be rolled
     * back)
     */
    public int insertReportWithDetails(RepairReport report, List<RepairReportDetail> details) throws SQLException {
        boolean originalAutoCommit = connection.getAutoCommit();

        try {
            connection.setAutoCommit(false);

            // Insert RepairReport header (supports both request-origin and schedule-origin)
            xSql = "INSERT INTO RepairReport (requestId, scheduleId, origin, technicianId, details, diagnosis, estimatedCost, quotationStatus, repairDate) "
                    + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
            ps = connection.prepareStatement(xSql, Statement.RETURN_GENERATED_KEYS);
            // requestId is primitive int; interpret <= 0 as NULL for DB
            if (report.getRequestId() > 0) {
                ps.setInt(1, report.getRequestId());
            } else {
                ps.setNull(1, Types.INTEGER);
            }
            if (report.getScheduleId() != null) {
                ps.setInt(2, report.getScheduleId());
            } else {
                ps.setNull(2, Types.INTEGER);
            }
            ps.setString(3, report.getOrigin() != null ? report.getOrigin() : (report.getScheduleId() != null ? "Schedule" : "ServiceRequest"));
            ps.setInt(4, report.getTechnicianId());
            ps.setString(5, report.getDetails());
            ps.setString(6, report.getDiagnosis() != null ? report.getDiagnosis() : ""); // Keep diagnosis field but may be empty
            ps.setBigDecimal(7, report.getEstimatedCost());
            ps.setString(8, report.getQuotationStatus());
            ps.setDate(9, Date.valueOf(report.getRepairDate()));
            // targetContractId column doesn't exist - connectiontract is automatically determined from ServiceRequest when report is approved

            int affected = ps.executeUpdate();
            if (affected == 0) {
                connection.rollback();
                return 0;
            }

            // Get generated reportId
            rs = ps.getGeneratedKeys();
            int reportId;
            if (rs.next()) {
                reportId = rs.getInt(1);
            } else {
                connection.rollback();
                return 0;
            }

            // Insert RepairReportDetail rows and reserve PartDetail records
            if (details != null && !details.isEmpty()) {
                xSql = "INSERT INTO RepairReportDetail (reportId, partId, partDetailId, quantity, unitPrice) "
                        + "VALUES (?, ?, ?, ?, ?)";
                ps = connection.prepareStatement(xSql);

                for (RepairReportDetail detail : details) {
                    int partId = detail.getPartId();
                    int quantity = detail.getQuantity();
                    
                    // Select available PartDetail records for this part (up to quantity needed)
                    List<Integer> reservedPartDetailIds = new ArrayList<>();
                    String selectSql = "SELECT partDetailId FROM PartDetail " +
                                     "WHERE partId = ? AND status = 'Available' " +
                                     "ORDER BY partDetailId ASC " +
                                     "LIMIT ? FOR UPDATE";
                    
                    try (PreparedStatement selectPs = connection.prepareStatement(selectSql)) {
                        selectPs.setInt(1, partId);
                        selectPs.setInt(2, quantity);
                        try (ResultSet selectRs = selectPs.executeQuery()) {
                            while (selectRs.next()) {
                                reservedPartDetailIds.add(selectRs.getInt("partDetailId"));
                            }
                        }
                    }
                    
                    // Validate we have enough available parts
                    if (reservedPartDetailIds.size() < quantity) {
                        connection.rollback();
                        throw new SQLException("Insufficient available parts for partId " + partId + 
                                             ". Required: " + quantity + ", Available: " + reservedPartDetailIds.size());
                    }
                    
                    // Update PartDetail status to 'InUse' for reserved parts
                    if (!reservedPartDetailIds.isEmpty()) {
                        String updateSql = "UPDATE PartDetail SET status = 'InUse', " +
                                         "lastUpdatedBy = ?, lastUpdatedDate = ? " +
                                         "WHERE partDetailId IN (";
                        StringBuilder updateSqlBuilder = new StringBuilder(updateSql);
                        for (int i = 0; i < reservedPartDetailIds.size(); i++) {
                            if (i > 0) updateSqlBuilder.append(",");
                            updateSqlBuilder.append("?");
                        }
                        updateSqlBuilder.append(")");
                        
                        try (PreparedStatement updatePs = connection.prepareStatement(updateSqlBuilder.toString())) {
                            updatePs.setInt(1, report.getTechnicianId() != null ? report.getTechnicianId() : 1);
                            updatePs.setDate(2, Date.valueOf(java.time.LocalDate.now()));
                            for (int i = 0; i < reservedPartDetailIds.size(); i++) {
                                updatePs.setInt(i + 3, reservedPartDetailIds.get(i));
                            }
                            int updated = updatePs.executeUpdate();
                            if (updated != reservedPartDetailIds.size()) {
                                connection.rollback();
                                throw new SQLException("Failed to reserve all PartDetail records for partId " + partId);
                            }
                        }
                    }
                    
                    // Insert RepairReportDetail - for quantity > 1, we need to insert multiple rows
                    // Each row represents one PartDetail instance
                    for (int i = 0; i < reservedPartDetailIds.size(); i++) {
                        ps.setInt(1, reportId);
                        ps.setInt(2, partId);
                        ps.setInt(3, reservedPartDetailIds.get(i));
                        ps.setInt(4, 1); // Each row is quantity 1 (one PartDetail instance)
                        ps.setBigDecimal(5, detail.getUnitPrice());
                        ps.addBatch();
                    }
                }

                int[] batchResults = ps.executeBatch();
                for (int result : batchResults) {
                    if (result == PreparedStatement.EXECUTE_FAILED) {
                        connection.rollback();
                        throw new SQLException("Failed to insert one or more repair report details");
                    }
                }
            }

            connection.commit();
            return reportId;

        } catch (SQLException e) {
            connection.rollback();
            throw e;
        } finally {
            connection.setAutoCommit(originalAutoCommit);
        }
    }

    /**
     * Get all details (parts) for a repair report.
     */
    public List<RepairReportDetail> getReportDetails(int reportId) throws SQLException {
        List<RepairReportDetail> details = new ArrayList<>();

        xSql = "SELECT rrd.detailId, rrd.reportId, rrd.partId, rrd.partDetailId, rrd.quantity, rrd.unitPrice, "
                + "       p.partName, pd.serialNumber, pd.location "
                + "FROM RepairReportDetail rrd "
                + "JOIN Part p ON rrd.partId = p.partId "
                + "LEFT JOIN PartDetail pd ON rrd.partDetailId = pd.partDetailId "
                + "WHERE rrd.reportId = ? "
                + "ORDER BY rrd.detailId";

        ps = connection.prepareStatement(xSql);
        ps.setInt(1, reportId);
        rs = ps.executeQuery();

        while (rs.next()) {
            RepairReportDetail detail = new RepairReportDetail();
            detail.setDetailId(rs.getInt("detailId"));
            detail.setReportId(rs.getInt("reportId"));
            detail.setPartId(rs.getInt("partId"));
            Integer partDetailId = rs.getObject("partDetailId", Integer.class);
            detail.setPartDetailId(partDetailId);
            detail.setQuantity(rs.getInt("quantity"));
            detail.setUnitPrice(rs.getBigDecimal("unitPrice"));
            detail.setPartName(rs.getString("partName"));
            detail.setSerialNumber(rs.getString("serialNumber"));
            detail.setLocation(rs.getString("location"));
            details.add(detail);
        }

        return details;
    }

    /**
     * Update an existing repair report
     */
    public boolean updateRepairReport(RepairReport report) throws SQLException {
        xSql = "UPDATE RepairReport SET details = ?, diagnosis = ?, estimatedCost = ?, repairDate = ? "
                + "WHERE reportId = ? AND technicianId = ?";
        ps = connection.prepareStatement(xSql);
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
     * Update repair report with new parts list
     * Releases old reserved parts and reserves new ones
     * @param report The repair report to update
     * @param newDetails New list of parts
     * @return true if successful
     */
    public boolean updateReportWithDetails(RepairReport report, List<RepairReportDetail> newDetails) throws SQLException {
        boolean originalAutoCommit = connection.getAutoCommit();
        
        try {
            connection.setAutoCommit(false);
            
            // 1. Return old reserved parts to Available
            returnReservedPartsToAvailable(report.getReportId());
            
            // 2. Delete old RepairReportDetail rows
            xSql = "DELETE FROM RepairReportDetail WHERE reportId = ?";
            ps = connection.prepareStatement(xSql);
            ps.setInt(1, report.getReportId());
            ps.executeUpdate();
            
            // 3. Update report header
            boolean headerUpdated = updateRepairReport(report);
            if (!headerUpdated) {
                connection.rollback();
                return false;
            }
            
            // 4. Reserve new parts and insert new details (reuse logic from insertReportWithDetails)
            if (newDetails != null && !newDetails.isEmpty()) {
                xSql = "INSERT INTO RepairReportDetail (reportId, partId, partDetailId, quantity, unitPrice) "
                        + "VALUES (?, ?, ?, ?, ?)";
                ps = connection.prepareStatement(xSql);

                for (RepairReportDetail detail : newDetails) {
                    int partId = detail.getPartId();
                    int quantity = detail.getQuantity();
                    
                    // Reserve specific PartDetail records
                    List<Integer> reservedPartDetailIds = new ArrayList<>();
                    String selectSql = "SELECT partDetailId FROM PartDetail " +
                                     "WHERE partId = ? AND status = 'Available' " +
                                     "ORDER BY partDetailId ASC " +
                                     "LIMIT ? FOR UPDATE";
                    
                    try (PreparedStatement selectPs = connection.prepareStatement(selectSql)) {
                        selectPs.setInt(1, partId);
                        selectPs.setInt(2, quantity);
                        try (ResultSet selectRs = selectPs.executeQuery()) {
                            while (selectRs.next()) {
                                reservedPartDetailIds.add(selectRs.getInt("partDetailId"));
                            }
                        }
                    }
                    
                    if (reservedPartDetailIds.size() < quantity) {
                        connection.rollback();
                        throw new SQLException("Insufficient available parts for partId " + partId + 
                                             ". Required: " + quantity + ", Available: " + reservedPartDetailIds.size());
                    }
                    
                    // Update PartDetail status to 'InUse'
                    if (!reservedPartDetailIds.isEmpty()) {
                        String updateSql = "UPDATE PartDetail SET status = 'InUse', " +
                                         "lastUpdatedBy = ?, lastUpdatedDate = ? " +
                                         "WHERE partDetailId IN (";
                        StringBuilder updateSqlBuilder = new StringBuilder(updateSql);
                        for (int i = 0; i < reservedPartDetailIds.size(); i++) {
                            if (i > 0) updateSqlBuilder.append(",");
                            updateSqlBuilder.append("?");
                        }
                        updateSqlBuilder.append(")");
                        
                        try (PreparedStatement updatePs = connection.prepareStatement(updateSqlBuilder.toString())) {
                            updatePs.setInt(1, report.getTechnicianId() != null ? report.getTechnicianId() : 1);
                            updatePs.setDate(2, Date.valueOf(java.time.LocalDate.now()));
                            for (int i = 0; i < reservedPartDetailIds.size(); i++) {
                                updatePs.setInt(i + 3, reservedPartDetailIds.get(i));
                            }
                            updatePs.executeUpdate();
                        }
                    }
                    
                    // Insert RepairReportDetail rows
                    for (int i = 0; i < reservedPartDetailIds.size(); i++) {
                        ps.setInt(1, report.getReportId());
                        ps.setInt(2, partId);
                        ps.setInt(3, reservedPartDetailIds.get(i));
                        ps.setInt(4, 1);
                        ps.setBigDecimal(5, detail.getUnitPrice());
                        ps.addBatch();
                    }
                }
                
                int[] batchResults = ps.executeBatch();
                for (int result : batchResults) {
                    if (result == PreparedStatement.EXECUTE_FAILED) {
                        connection.rollback();
                        throw new SQLException("Failed to insert one or more repair report details");
                    }
                }
            }
            
            connection.commit();
            return true;
            
        } catch (SQLException e) {
            connection.rollback();
            throw e;
        } finally {
            connection.setAutoCommit(originalAutoCommit);
        }
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

        ps = connection.prepareStatement(sql.toString());
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
        ps = connection.prepareStatement(xSql);
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
    /**
     * Find repair report by requestId and technicianId (to prevent duplicates)
     */
    public RepairReport findByRequestIdAndTechnician(int requestId, int technicianId) throws SQLException {
        xSql = "SELECT * FROM RepairReport WHERE requestId = ? AND technicianId = ?";
        ps = connection.prepareStatement(xSql);
        ps.setInt(1, requestId);
        ps.setInt(2, technicianId);
        rs = ps.executeQuery();

        if (rs.next()) {
            return mapResultSetToRepairReport(rs);
        }
        return null;
    }

    public RepairReport findByRequestId(int requestId) throws SQLException {
        xSql = "SELECT * FROM RepairReport WHERE requestId = ?";
        ps = connection.prepareStatement(xSql);
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
        ps = connection.prepareStatement(xSql);
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

        ps = connection.prepareStatement(sql.toString());
        for (int i = 0; i < params.size(); i++) {
            ps.setObject(i + 1, params.get(i));
        }

        rs = ps.executeQuery();
        if (rs.next()) {
            return rs.getInt(1);
        }
        return 0;
    }

    public RepairReport findByScheduleIdAndTechnician(int scheduleId, int technicianId) throws SQLException {
        String sql = "SELECT * FROM RepairReport WHERE scheduleId = ? AND technicianId = ? LIMIT 1";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, scheduleId);
            ps.setInt(2, technicianId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    RepairReport report = new RepairReport();
                    report.setReportId(rs.getInt("reportId"));
                    Integer reqId = rs.getObject("requestId", Integer.class);
                    report.setRequestId(reqId != null ? reqId : 0);
                    report.setScheduleId(rs.getObject("scheduleId", Integer.class));
                    report.setTechnicianId(rs.getInt("technicianId"));
                    report.setDetails(rs.getString("details"));
                    report.setDiagnosis(rs.getString("diagnosis"));
                    report.setEstimatedCost(rs.getBigDecimal("estimatedCost"));
                    report.setQuotationStatus(rs.getString("quotationStatus"));
                    Date d = rs.getDate("repairDate");
                    if (d != null) report.setRepairDate(d.toLocalDate());
                    report.setInvoiceDetailId(rs.getObject("invoiceDetailId", Integer.class));
                    return report;
                }
            }
        }
        return null;
    }

    /**
     * Find submitted reports by technician
     */
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
            ps = connection.prepareStatement(xSql);
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
            ps = connection.prepareStatement(xSql);
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

    /**
     * Find all repair reports (for managers)
     */
    public List<RepairReport> findAllReports(String searchQuery, String statusFilter, int page, int pageSize) throws SQLException {
        List<RepairReport> reports = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT rr.reportId, rr.requestId, rr.technicianId, rr.details, rr.diagnosis, ");
        sql.append("rr.estimatedCost, rr.quotationStatus, rr.repairDate, rr.invoiceDetailId, ");
        sql.append("a.fullName as technicianName ");
        sql.append("FROM RepairReport rr ");
        sql.append("LEFT JOIN Account a ON rr.technicianId = a.accountId ");
        sql.append("WHERE 1=1");

        List<Object> params = new ArrayList<>();

        // Add search filter
        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            sql.append(" AND (rr.details LIKE ? OR rr.diagnosis LIKE ? OR CAST(rr.reportId AS CHAR) LIKE ? OR a.fullName LIKE ?)");
            String searchPattern = "%" + searchQuery.trim() + "%";
            params.add(searchPattern);
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

        ps = connection.prepareStatement(sql.toString());
        for (int i = 0; i < params.size(); i++) {
            ps.setObject(i + 1, params.get(i));
        }

        rs = ps.executeQuery();
        while (rs.next()) {
            RepairReport report = mapResultSetToRepairReport(rs);
            // Add technician name if available
            String technicianName = rs.getString("technicianName");
            if (technicianName != null) {
                report.setTechnicianName(technicianName);
            }
            reports.add(report);
        }

        return reports;
    }

    /**
     * Get total count of all reports (for managers)
     */
    public int getAllReportsCount(String searchQuery, String statusFilter) throws SQLException {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) FROM RepairReport rr ");
        sql.append("LEFT JOIN Account a ON rr.technicianId = a.accountId ");
        sql.append("WHERE 1=1");

        List<Object> params = new ArrayList<>();

        // Add search filter
        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            sql.append(" AND (rr.details LIKE ? OR rr.diagnosis LIKE ? OR CAST(rr.reportId AS CHAR) LIKE ? OR a.fullName LIKE ?)");
            String searchPattern = "%" + searchQuery.trim() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
        }

        // Add status filter
        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            sql.append(" AND rr.quotationStatus = ?");
            params.add(statusFilter.trim());
        }

        ps = connection.prepareStatement(sql.toString());
        for (int i = 0; i < params.size(); i++) {
            ps.setObject(i + 1, params.get(i));
        }

        rs = ps.executeQuery();
        if (rs.next()) {
            return rs.getInt(1);
        }
        return 0;
    }

    private void closeResources() {
        try {
            if (rs != null) {
                rs.close();
            }
            if (ps != null) {
                ps.close();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public boolean updatePartPaymentStatus(int partDetailId, String paymentStatus) throws SQLException {
        try {
            connection.setAutoCommit(false);

            // Check if InvoiceDetail exists for this part
            String checkSql = "SELECT id.invoiceDetailId "
                    + "FROM InvoiceDetail id "
                    + "WHERE id.repairReportDetailId = ?";

            ps = connection.prepareStatement(checkSql);
            ps.setInt(1, partDetailId);
            rs = ps.executeQuery();

            if (rs.next()) {
                // Update existing InvoiceDetail
                int invoiceDetailId = rs.getInt("invoiceDetailId");
                String updateSql = "UPDATE InvoiceDetail SET paymentStatus = ?, paymentDate = CURRENT_DATE "
                        + "WHERE invoiceDetailId = ?";

                ps = connection.prepareStatement(updateSql);
                ps.setString(1, paymentStatus);
                ps.setInt(2, invoiceDetailId);
                int affected = ps.executeUpdate();

                connection.commit();
                return affected > 0;
            } else {
                // Create new InvoiceDetail
                // First get part info
                String partInfoSql = "SELECT rrd.reportId, rrd.quantity, rrd.unitPrice, rr.requestId "
                        + "FROM RepairReportDetail rrd "
                        + "JOIN RepairReport rr ON rrd.reportId = rr.reportId "
                        + "WHERE rrd.detailId = ?";

                ps = connection.prepareStatement(partInfoSql);
                ps.setInt(1, partDetailId);
                rs = ps.executeQuery();

                if (rs.next()) {
                    int reportId = rs.getInt("reportId");
                    int quantity = rs.getInt("quantity");
                    java.math.BigDecimal unitPrice = rs.getBigDecimal("unitPrice");
                    int requestId = rs.getInt("requestId");
                    java.math.BigDecimal totalAmount = unitPrice.multiply(new java.math.BigDecimal(quantity));

                    // Get or create Invoice for this request
                    String invoiceSql = "SELECT invoiceId FROM Invoice WHERE requestId = ?";
                    ps = connection.prepareStatement(invoiceSql);
                    ps.setInt(1, requestId);
                    rs = ps.executeQuery();

                    int invoiceId;
                    if (rs.next()) {
                        invoiceId = rs.getInt("invoiceId");
                    } else {
                        // Create new Invoice
                        String createInvoiceSql = "INSERT INTO Invoice (requestId, totalAmount, invoiceDate, paymentStatus) "
                                + "VALUES (?, ?, CURRENT_DATE, 'Pending')";
                        ps = connection.prepareStatement(createInvoiceSql, Statement.RETURN_GENERATED_KEYS);
                        ps.setInt(1, requestId);
                        ps.setBigDecimal(2, totalAmount);
                        ps.executeUpdate();

                        rs = ps.getGeneratedKeys();
                        if (rs.next()) {
                            invoiceId = rs.getInt(1);
                        } else {
                            connection.rollback();
                            return false;
                        }
                    }

                    // Create InvoiceDetail
                    String createDetailSql = "INSERT INTO InvoiceDetail (invoiceId, repairReportDetailId, quantity, unitPrice, totalPrice, paymentStatus, paymentDate) "
                            + "VALUES (?, ?, ?, ?, ?, ?, CURRENT_DATE)";
                    ps = connection.prepareStatement(createDetailSql);
                    ps.setInt(1, invoiceId);
                    ps.setInt(2, partDetailId);
                    ps.setInt(3, quantity);
                    ps.setBigDecimal(4, unitPrice);
                    ps.setBigDecimal(5, totalAmount);
                    ps.setString(6, paymentStatus);

                    int affected = ps.executeUpdate();
                    connection.commit();
                    return affected > 0;
                }

                connection.rollback();
                return false;
            }
        } catch (SQLException e) {
            connection.rollback();
            throw e;
        } finally {
            connection.setAutoCommit(true);
            closeResources();
        }
    }

    /**
     * ✅ Check if all parts for a request have been paid
     */
    public boolean checkAllPartsPaid(int requestId) throws SQLException {
        String sql = "SELECT COUNT(*) as totalParts, "
                + "SUM(CASE WHEN COALESCE(id.paymentStatus, 'Pending') = 'Completed' THEN 1 ELSE 0 END) as paidParts "
                + "FROM RepairReportDetail rrd "
                + "JOIN RepairReport rr ON rrd.reportId = rr.reportId "
                + "LEFT JOIN InvoiceDetail id ON rrd.detailId = id.repairReportDetailId "
                + "WHERE rr.requestId = ?";

        try {
            ps = connection.prepareStatement(sql);
            ps.setInt(1, requestId);
            rs = ps.executeQuery();

            if (rs.next()) {
                int totalParts = rs.getInt("totalParts");
                int paidParts = rs.getInt("paidParts");

                // If no parts, return false
                if (totalParts == 0) {
                    return false;
                }

                // All parts must be paid
                return totalParts == paidParts;
            }
        } finally {
            closeResources();
        }

        return false;
    }

    /**
     * ✅ Get all repair reports by request ID (for customer view)
     */
    public List<RepairReport> getRepairReportsByRequestId(int requestId) throws SQLException {
        List<RepairReport> reports = new ArrayList<>();
        String sql = "SELECT rr.*, a.fullName as technicianName, a.email as technicianEmail "
                + "FROM RepairReport rr "
                + "LEFT JOIN Account a ON rr.technicianId = a.accountId "
                + "WHERE rr.requestId = ? "
                + "ORDER BY rr.repairDate DESC";

        try {
            ps = connection.prepareStatement(sql);
            ps.setInt(1, requestId);
            rs = ps.executeQuery();

            while (rs.next()) {
                RepairReport report = mapResultSetToRepairReport(rs);
                report.setTechnicianName(rs.getString("technicianName"));
                report.setTechnicianEmail(rs.getString("technicianEmail"));
                reports.add(report);
            }
        } finally {
            closeResources();
        }

        return reports;
    }

    /**
     * ✅ Get payment status by report ID
     */
    public String getPaymentStatusByReportId(int reportId) throws SQLException {
        String sql = "SELECT id.paymentStatus "
                + "FROM RepairReport rr "
                + "LEFT JOIN InvoiceDetail id ON rr.invoiceDetailId = id.invoiceDetailId "
                + "WHERE rr.reportId = ?";

        try {
            ps = connection.prepareStatement(sql);
            ps.setInt(1, reportId);
            rs = ps.executeQuery();

            if (rs.next()) {
                String status = rs.getString("paymentStatus");
                return status != null ? status : "Pending";
            }
        } finally {
            closeResources();
        }

        return "Pending";
    }

    /**
     * ✅ Get repair report by ID with technician info
     */
    public RepairReport getRepairReportById(int reportId) throws SQLException {
        String sql = "SELECT rr.*, a.fullName as technicianName, a.email as technicianEmail "
                + "FROM RepairReport rr "
                + "LEFT JOIN Account a ON rr.technicianId = a.accountId "
                + "WHERE rr.reportId = ?";

        try {
            ps = connection.prepareStatement(sql);
            ps.setInt(1, reportId);
            rs = ps.executeQuery();

            if (rs.next()) {
                RepairReport report = mapResultSetToRepairReport(rs);
                report.setTechnicianName(rs.getString("technicianName"));
                report.setTechnicianEmail(rs.getString("technicianEmail"));
                return report;
            }
        } finally {
            closeResources();
        }

        return null;
    }

    /**
     * ✅ Get payment date by report ID
     */
    public String getPaymentDateByReportId(int reportId) throws SQLException {
        String sql = "SELECT id.paymentDate "
                + "FROM RepairReport rr "
                + "LEFT JOIN InvoiceDetail id ON rr.invoiceDetailId = id.invoiceDetailId "
                + "WHERE rr.reportId = ?";

        try {
            ps = connection.prepareStatement(sql);
            ps.setInt(1, reportId);
            rs = ps.executeQuery();

            if (rs.next()) {
                Date paymentDate = rs.getDate("paymentDate");
                if (paymentDate != null) {
                    return new java.text.SimpleDateFormat("dd/MM/yyyy").format(paymentDate);
                }
            }
        } finally {
            closeResources();
        }

        return null;
    }

    /**
     * ✅ Get repair report details (parts list) by report ID
     */
    public List<model.RepairReportDetail> getRepairReportDetails(int reportId) throws SQLException {
        List<model.RepairReportDetail> details = new ArrayList<>();
        String sql = "SELECT rrd.*, p.partName, p.description, pd.serialNumber, "
                + "COALESCE(id.paymentStatus, 'Pending') as paymentStatus "
                + "FROM RepairReportDetail rrd "
                + "JOIN Part p ON rrd.partId = p.partId "
                + "LEFT JOIN PartDetail pd ON rrd.partDetailId = pd.partDetailId "
                + "LEFT JOIN InvoiceDetail id ON rrd.detailId = id.repairReportDetailId "
                + "WHERE rrd.reportId = ? "
                + "ORDER BY p.partName";

        try {
            ps = connection.prepareStatement(sql);
            ps.setInt(1, reportId);
            rs = ps.executeQuery();

            while (rs.next()) {
                model.RepairReportDetail detail = new model.RepairReportDetail();
                detail.setDetailId(rs.getInt("detailId"));
                detail.setReportId(rs.getInt("reportId"));
                detail.setPartId(rs.getInt("partId"));
                detail.setPartDetailId(rs.getInt("partDetailId"));
                detail.setQuantity(rs.getInt("quantity"));
                detail.setUnitPrice(rs.getBigDecimal("unitPrice"));
                detail.setPartName(rs.getString("partName"));
                detail.setDescription(rs.getString("description"));
                detail.setSerialNumber(rs.getString("serialNumber"));
                detail.setPaymentStatus(rs.getString("paymentStatus"));

                details.add(detail);
            }
        } finally {
            closeResources();
        }

        return details;
    }
    
   /**
     * ✅ Get payment status for a specific part (RepairReportDetail)
     */
    public String getPartPaymentStatus(int partDetailId) throws SQLException {
        String sql = "SELECT COALESCE(id.paymentStatus, 'Pending') as paymentStatus " +
                     "FROM RepairReportDetail rrd " +
                     "LEFT JOIN InvoiceDetail id ON rrd.detailId = id.repairReportDetailId " +
                     "WHERE rrd.detailId = ?";
        
        try {
            ps = connection.prepareStatement(sql);
            ps.setInt(1, partDetailId);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getString("paymentStatus");
            }
        } finally {
            closeResources();
        }
        
        return "Pending";
    }
     /**
     * Return reserved parts to Available status when report is rejected
     * This method finds all PartDetail records linked to this report and returns them to Available
     * @param reportId ID of the repair report
     * @return number of PartDetail records returned to Available
     */
    public int returnReservedPartsToAvailable(int reportId) throws SQLException {
        // Get all partDetailIds linked to this report
        List<Integer> partDetailIds = new ArrayList<>();
        String selectSql = "SELECT DISTINCT partDetailId FROM RepairReportDetail " +
                         "WHERE reportId = ? AND partDetailId IS NOT NULL";
        
        try (PreparedStatement selectPs = connection.prepareStatement(selectSql)) {
            selectPs.setInt(1, reportId);
            try (ResultSet rs = selectPs.executeQuery()) {
                while (rs.next()) {
                    partDetailIds.add(rs.getInt("partDetailId"));
                }
            }
        }
        
        if (partDetailIds.isEmpty()) {
            return 0;
        }
        
        // Update PartDetail status back to 'Available'
        StringBuilder updateSql = new StringBuilder(
            "UPDATE PartDetail SET status = 'Available', " +
            "lastUpdatedBy = 1, lastUpdatedDate = ? " +
            "WHERE partDetailId IN ("
        );
        for (int i = 0; i < partDetailIds.size(); i++) {
            if (i > 0) updateSql.append(",");
            updateSql.append("?");
        }
        updateSql.append(") AND status = 'InUse'");
        
        int updated = 0;
        try (PreparedStatement updatePs = connection.prepareStatement(updateSql.toString())) {
            updatePs.setDate(1, Date.valueOf(java.time.LocalDate.now()));
            for (int i = 0; i < partDetailIds.size(); i++) {
                updatePs.setInt(i + 2, partDetailIds.get(i));
            }
            updated = updatePs.executeUpdate();
        }
        
        return updated;
    }
    
    /**
     * Hủy 1 linh kiện cụ thể (đánh dấu status = "Cancelled")
     * @param partDetailId ID của PartDetail cần hủy
     * @return true nếu hủy thành công
     */
    public boolean cancelPartDetail(int partDetailId) throws SQLException {
        xSql = "UPDATE PartDetail SET status = 'Cancelled' WHERE partDetailId = ?";
        
        try {
            ps = connection.prepareStatement(xSql);
            ps.setInt(1, partDetailId);
            int rowsAffected = ps.executeUpdate();
            
            System.out.println("✅ Updated " + rowsAffected + " row(s) for partDetailId: " + partDetailId);
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.err.println("❌ Error cancelling part detail: " + e.getMessage());
            throw e;
        }
    }

    

}
