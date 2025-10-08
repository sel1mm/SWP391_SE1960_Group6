package dal;

import model.RequestApproval;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class RequestApprovalDAO extends MyDAO {

    /**
     * Create a new approval record
     */
    public int createApproval(RequestApproval approval) {
        xSql = "INSERT INTO RequestApproval (requestId, approvedBy, approvalDate, decision, note) VALUES (?, ?, ?, ?, ?)";

        try {
            ps = con.prepareStatement(xSql);
            ps.setInt(1, approval.getRequestId());
            ps.setInt(2, approval.getApprovedBy());
            ps.setDate(3, Date.valueOf(approval.getApprovalDate()));
            ps.setString(4, approval.getDecision());
            ps.setString(5, approval.getNote());

            return ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        } finally {
            closeResources();
        }
    }

    /**
     * Get approval by request ID
     */
    public RequestApproval getApprovalByRequestId(int requestId) {
        xSql = "SELECT * FROM RequestApproval WHERE requestId = ?";

        try {
            ps = con.prepareStatement(xSql);
            ps.setInt(1, requestId);
            rs = ps.executeQuery();

            if (rs.next()) {
                return mapResultSetToApproval(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }

        return null;
    }

    /**
     * Get approvals by manager ID
     */
    public List<RequestApproval> getApprovalsByManager(int managerId) {
        List<RequestApproval> approvals = new ArrayList<>();
        xSql = "SELECT * FROM RequestApproval WHERE approvedBy = ? ORDER BY approvalDate DESC";

        try {
            ps = con.prepareStatement(xSql);
            ps.setInt(1, managerId);
            rs = ps.executeQuery();

            while (rs.next()) {
                approvals.add(mapResultSetToApproval(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }

        return approvals;
    }

    /**
     * Get approvals today by manager (for Technical Manager dashboard)
     */
    public int getApprovalsToday(int managerId) {
        xSql = "SELECT COUNT(*) FROM RequestApproval WHERE approvedBy = ? AND DATE(approvalDate) = CURDATE()";

        try {
            ps = con.prepareStatement(xSql);
            ps.setInt(1, managerId);
            rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }

        return 0;
    }

    /**
     * Get all approvals with pagination
     */
    public List<RequestApproval> getAllApprovals(int offset, int limit) {
        List<RequestApproval> approvals = new ArrayList<>();
        xSql = "SELECT * FROM RequestApproval ORDER BY approvalDate DESC LIMIT ? OFFSET ?";

        try {
            ps = con.prepareStatement(xSql);
            ps.setInt(1, limit);
            ps.setInt(2, offset);
            rs = ps.executeQuery();

            while (rs.next()) {
                approvals.add(mapResultSetToApproval(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }

        return approvals;
    }

    /**
     * Get approval statistics by decision
     */
    public int getApprovalCountByDecision(String decision) {
        xSql = "SELECT COUNT(*) FROM RequestApproval WHERE decision = ?";

        try {
            ps = con.prepareStatement(xSql);
            ps.setString(1, decision);
            rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }

        return 0;
    }

    /**
     * Update approval record
     */
    public boolean updateApproval(RequestApproval approval) {
        xSql = "UPDATE RequestApproval SET approvedBy = ?, approvalDate = ?, decision = ?, note = ? WHERE approvalId = ?";

        try {
            ps = con.prepareStatement(xSql);
            ps.setInt(1, approval.getApprovedBy());
            ps.setDate(2, Date.valueOf(approval.getApprovalDate()));
            ps.setString(3, approval.getDecision());
            ps.setString(4, approval.getNote());
            ps.setInt(5, approval.getApprovalId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            closeResources();
        }
    }

    /**
     * Delete approval record
     */
    public boolean deleteApproval(int approvalId) {
        xSql = "DELETE FROM RequestApproval WHERE approvalId = ?";

        try {
            ps = con.prepareStatement(xSql);
            ps.setInt(1, approvalId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            closeResources();
        }
    }

    /**
     * Helper method to map ResultSet to RequestApproval object
     */
    private RequestApproval mapResultSetToApproval(ResultSet rs) throws SQLException {
        RequestApproval approval = new RequestApproval();
        approval.setApprovalId(rs.getInt("approvalId"));
        approval.setRequestId(rs.getInt("requestId"));
        approval.setApprovedBy(rs.getInt("approvedBy"));

        // Handle LocalDate conversion
        Date approvalDate = rs.getDate("approvalDate");
        if (approvalDate != null) {
            approval.setApprovalDate(approvalDate.toLocalDate());
        }

        approval.setDecision(rs.getString("decision"));
        approval.setNote(rs.getString("note"));

        return approval;
    }

    /**
     * Close database resources
     */
    private void closeResources() {
        try {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}