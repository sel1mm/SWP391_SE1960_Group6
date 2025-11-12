package dal;

import model.Invoice;
import model.InvoiceDetail;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class InvoiceDAO extends DBContext {

    // Lấy tất cả hóa đơn của một khách hàng
    public List<Invoice> getInvoicesByCustomerId(int customerId) {
        List<Invoice> invoices = new ArrayList<>();
        String sql = "SELECT i.* FROM Invoice i "
                + "JOIN Contract c ON i.ContractId = c.ContractId "
                + "WHERE c.CustomerId = ? "
                + "ORDER BY i.IssueDate DESC";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Invoice invoice = new Invoice();
                invoice.setInvoiceId(rs.getInt("InvoiceId"));
                invoice.setContractId(rs.getInt("ContractId"));

                Date issueDate = rs.getDate("IssueDate");
                if (issueDate != null) {
                    invoice.setIssueDate(issueDate.toLocalDate());
                }

                Date dueDate = rs.getDate("DueDate");
                if (dueDate != null) {
                    invoice.setDueDate(dueDate.toLocalDate());
                }

                invoice.setTotalAmount(rs.getDouble("TotalAmount"));
                invoice.setStatus(rs.getString("Status"));

                String paymentMethod = rs.getString("paymentMethod");
                if (paymentMethod != null) {
                    invoice.setPaymentMethod(paymentMethod);
                }

                invoices.add(invoice);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return invoices;
    }

    // Tìm kiếm hóa đơn theo từ khóa
    public List<Invoice> searchInvoices(int customerId, String keyword) {
        List<Invoice> invoices = new ArrayList<>();
        String sql = "SELECT i.* FROM Invoice i "
                + "JOIN Contract c ON i.ContractId = c.ContractId "
                + "WHERE c.CustomerId = ? "
                + "AND (CAST(i.InvoiceId AS VARCHAR) LIKE ? "
                + "OR CAST(i.TotalAmount AS VARCHAR) LIKE ? "
                + "OR i.Status LIKE ? "
                + "OR CAST(i.ContractId AS VARCHAR) LIKE ?) "
                + "ORDER BY i.IssueDate DESC";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            String searchPattern = "%" + keyword + "%";
            ps.setString(2, searchPattern);
            ps.setString(3, searchPattern);
            ps.setString(4, searchPattern);
            ps.setString(5, searchPattern);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Invoice invoice = new Invoice();
                invoice.setInvoiceId(rs.getInt("InvoiceId"));
                invoice.setContractId(rs.getInt("ContractId"));

                Date issueDate = rs.getDate("IssueDate");
                if (issueDate != null) {
                    invoice.setIssueDate(issueDate.toLocalDate());
                }

                Date dueDate = rs.getDate("DueDate");
                if (dueDate != null) {
                    invoice.setDueDate(dueDate.toLocalDate());
                }

                invoice.setTotalAmount(rs.getDouble("TotalAmount"));
                invoice.setStatus(rs.getString("Status"));
                invoices.add(invoice);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return invoices;
    }

    // Tìm kiếm hóa đơn nâng cao với nhiều tiêu chí
    public List<Invoice> searchInvoicesAdvanced(int customerId, String keyword, String status,
            String paymentMethod, String sortBy, String fromDate, String toDate,
            String fromDueDate, String toDueDate) {
        List<Invoice> invoices = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT i.* FROM Invoice i ");
        sql.append("JOIN Contract c ON i.ContractId = c.ContractId ");
        sql.append("WHERE c.CustomerId = ? ");

        List<Object> params = new ArrayList<>();
        params.add(customerId);

        // Tìm kiếm theo từ khóa
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (CAST(i.InvoiceId AS VARCHAR) LIKE ? ");
            sql.append("OR CAST(i.TotalAmount AS VARCHAR) LIKE ? ");
            sql.append("OR i.Status LIKE ? ");
            sql.append("OR CAST(i.ContractId AS VARCHAR) LIKE ?) ");
            String searchPattern = "%" + keyword.trim() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
        }

        // Lọc theo trạng thái
        if (status != null && !status.trim().isEmpty()) {
            sql.append("AND i.Status = ? ");
            params.add(status);
        }

        // Lọc theo phương thức thanh toán
        if (paymentMethod != null && !paymentMethod.trim().isEmpty()) {
            sql.append("AND pt.method = ? ");
            params.add(paymentMethod);
        }

        // Lọc theo ngày phát hành
        if (fromDate != null && !fromDate.trim().isEmpty()) {
            sql.append("AND i.IssueDate >= ? ");
            params.add(fromDate);
        }
        if (toDate != null && !toDate.trim().isEmpty()) {
            sql.append("AND i.IssueDate <= ? ");
            params.add(toDate);
        }

        // Lọc theo ngày đến hạn
        if (fromDueDate != null && !fromDueDate.trim().isEmpty()) {
            sql.append("AND i.DueDate >= ? ");
            params.add(fromDueDate);
        }
        if (toDueDate != null && !toDueDate.trim().isEmpty()) {
            sql.append("AND i.DueDate <= ? ");
            params.add(toDueDate);
        }

        // Sắp xếp
        if (sortBy != null && !sortBy.trim().isEmpty()) {
            switch (sortBy) {
                case "newest":
                    sql.append("ORDER BY i.IssueDate DESC");
                    break;
                case "oldest":
                    sql.append("ORDER BY i.IssueDate ASC");
                    break;
                case "amount_asc":
                    sql.append("ORDER BY i.TotalAmount ASC");
                    break;
                case "amount_desc":
                    sql.append("ORDER BY i.TotalAmount DESC");
                    break;
                default:
                    sql.append("ORDER BY i.IssueDate DESC");
            }
        } else {
            sql.append("ORDER BY i.IssueDate DESC");
        }

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Invoice invoice = new Invoice();
                invoice.setInvoiceId(rs.getInt("InvoiceId"));
                invoice.setContractId(rs.getInt("ContractId"));

                Date issueDate = rs.getDate("IssueDate");
                if (issueDate != null) {
                    invoice.setIssueDate(issueDate.toLocalDate());
                }

                Date dueDate = rs.getDate("DueDate");
                if (dueDate != null) {
                    invoice.setDueDate(dueDate.toLocalDate());
                }

                invoice.setTotalAmount(rs.getDouble("TotalAmount"));
                invoice.setStatus(rs.getString("Status"));
                invoices.add(invoice);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return invoices;
    }

    // Lấy chi tiết một hóa đơn
    public Invoice getInvoiceById(int invoiceId) {
        String sql = "SELECT * FROM Invoice WHERE InvoiceId = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, invoiceId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                Invoice invoice = new Invoice();
                invoice.setInvoiceId(rs.getInt("InvoiceId"));
                invoice.setContractId(rs.getInt("ContractId"));

                Date issueDate = rs.getDate("IssueDate");
                if (issueDate != null) {
                    invoice.setIssueDate(issueDate.toLocalDate());
                }

                Date dueDate = rs.getDate("DueDate");
                if (dueDate != null) {
                    invoice.setDueDate(dueDate.toLocalDate());
                }

                invoice.setTotalAmount(rs.getDouble("TotalAmount"));
                invoice.setStatus(rs.getString("Status"));

                String paymentMethod = rs.getString("paymentMethod");
                if (paymentMethod != null) {
                    invoice.setPaymentMethod(paymentMethod);
                }

                return invoice;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * ✅ LẤY CHI TIẾT HÓA ĐƠN (InvoiceDetail) Cập nhật để lấy thêm thông tin
     * linh kiện nếu có
     */
    public List<InvoiceDetail> getInvoiceDetails(int invoiceId) {
        List<InvoiceDetail> details = new ArrayList<>();
        String sql = "SELECT "
                + "    id.InvoiceDetailID, "
                + "    id.InvoiceID, "
                + "    id.Description, "
                + "    id.Amount, "
                + "    id.PaymentStatus "
                + "FROM InvoiceDetail id "
                + "WHERE id.InvoiceID = ? "
                + "ORDER BY id.InvoiceDetailID";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, invoiceId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                InvoiceDetail detail = new InvoiceDetail();
                detail.setInvoiceDetailId(rs.getInt("InvoiceDetailID"));
                detail.setInvoiceId(rs.getInt("InvoiceID"));
                detail.setDescription(rs.getString("Description"));
                detail.setAmount(rs.getDouble("Amount"));

                String paymentStatus = rs.getString("PaymentStatus");
                if (paymentStatus != null) {
                    detail.setPaymentStatus(paymentStatus);
                }

                details.add(detail);

                System.out.println("📋 Invoice detail: " + rs.getString("Description")
                        + " - Amount: $" + rs.getDouble("Amount"));
            }

            System.out.println("📋 Invoice details found: " + details.size());

        } catch (SQLException e) {
            System.out.println("❌ Error getting invoice details: " + e.getMessage());
            e.printStackTrace();
        }

        return details;
    }

    // Đếm tổng số hóa đơn của khách hàng
    public int countTotalInvoices(int customerId) {
        String sql = "SELECT COUNT(*) FROM Invoice i "
                + "JOIN Contract c ON i.ContractId = c.ContractId "
                + "WHERE c.CustomerId = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // Đếm hóa đơn đã thanh toán
    public int countPaidInvoices(int customerId) {
        String sql = "SELECT COUNT(*) FROM Invoice i "
                + "JOIN Contract c ON i.ContractId = c.ContractId "
                + "WHERE c.CustomerId = ? AND i.Status = 'Paid'";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // Đếm hóa đơn chưa thanh toán
    public int countPendingInvoices(int customerId) {
        String sql = "SELECT COUNT(*) FROM Invoice i "
                + "JOIN Contract c ON i.ContractId = c.ContractId "
                + "WHERE c.CustomerId = ? AND i.Status = 'Pending'";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // Tính tổng tiền tất cả hóa đơn
    public double calculateTotalAmount(int customerId) {
        String sql = "SELECT ISNULL(SUM(i.TotalAmount), 0) FROM Invoice i "
                + "JOIN Contract c ON i.ContractId = c.ContractId "
                + "WHERE c.CustomerId = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0.0;
    }

    // Phương thức test - lấy tất cả hóa đơn (không phân biệt customer)
    public List<Invoice> getAllInvoicesForTest() {
        List<Invoice> invoices = new ArrayList<>();
        String sql = "SELECT i.* FROM Invoice i ORDER BY i.InvoiceId DESC";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Invoice invoice = new Invoice();
                invoice.setInvoiceId(rs.getInt("InvoiceId"));
                invoice.setContractId(rs.getInt("ContractId"));

                Date issueDate = rs.getDate("IssueDate");
                if (issueDate != null) {
                    invoice.setIssueDate(issueDate.toLocalDate());
                }

                Date dueDate = rs.getDate("DueDate");
                if (dueDate != null) {
                    invoice.setDueDate(dueDate.toLocalDate());
                }

                invoice.setTotalAmount(rs.getDouble("TotalAmount"));
                invoice.setStatus(rs.getString("Status"));

                String paymentMethod = rs.getString("paymentMethod");
                if (paymentMethod != null) {
                    invoice.setPaymentMethod(paymentMethod);
                }

                invoices.add(invoice);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return invoices;
    }

    // Phương thức test - thống kê tất cả hóa đơn
    public int countTotalInvoicesForTest() {
        String sql = "SELECT COUNT(*) FROM Invoice";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int countPaidInvoicesForTest() {
        String sql = "SELECT COUNT(*) FROM Invoice WHERE Status = 'Paid'";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int countPendingInvoicesForTest() {
        String sql = "SELECT COUNT(*) FROM Invoice WHERE Status = 'Pending'";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public double calculateTotalAmountForTest() {
        String sql = "SELECT ISNULL(SUM(TotalAmount), 0) FROM Invoice";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0.0;
    }

    /**
     * ✅ LẤY CHI TIẾT LINH KIỆN CỦA HÓA ĐƠN Lấy từ RepairPartDetails thông qua
     * ServiceRequest và RepairReport
     */
    public List<Map<String, Object>> getRepairPartDetails(int invoiceId) {
        List<Map<String, Object>> partDetails = new ArrayList<>();

        // Query mới phù hợp với cấu trúc database thực tế
        String sql = "SELECT "
                + "    rr.ReportID, "
                + "    rr.Diagnosis as ReportDescription, "
                + "    p.PartName, "
                + "    p.Category, "
                + "    rpd.Quantity, "
                + "    rpd.UnitPrice, "
                + "    (rpd.Quantity * rpd.UnitPrice) as TotalPrice, "
                + "    rpd.PaymentStatus, "
                + "    rpd.PartDetailID "
                + "FROM Invoice i "
                + "INNER JOIN ServiceRequest sr ON i.ContractID = sr.ContractID "
                + "INNER JOIN RepairReport rr ON sr.RequestID = rr.RequestID "
                + "INNER JOIN RepairPartDetails rpd ON rr.ReportID = rpd.ReportID "
                + "INNER JOIN Part p ON rpd.PartID = p.PartID "
                + "WHERE i.InvoiceID = ? "
                + "AND rpd.PaymentStatus = 'Completed' "
                + "ORDER BY rr.ReportID, p.PartName";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, invoiceId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Map<String, Object> part = new HashMap<>();
                part.put("reportId", rs.getInt("ReportID"));
                part.put("reportDescription", rs.getString("ReportDescription"));
                part.put("partName", rs.getString("PartName"));
                part.put("category", rs.getString("Category"));
                part.put("quantity", rs.getInt("Quantity"));
                part.put("price", rs.getDouble("UnitPrice"));
                part.put("totalPrice", rs.getDouble("TotalPrice"));
                part.put("paymentStatus", rs.getString("PaymentStatus"));
                partDetails.add(part);

                System.out.println("✅ Found part: " + rs.getString("PartName")
                        + " - Qty: " + rs.getInt("Quantity")
                        + " - Price: $" + rs.getDouble("UnitPrice"));
            }

            System.out.println("📦 Total parts found for invoice " + invoiceId + ": " + partDetails.size());

        } catch (SQLException e) {
            System.out.println("❌ Error getting repair part details: " + e.getMessage());
            e.printStackTrace();
        }

        return partDetails;
    }

    /**
     * ✅ TÍNH TỔNG TIỀN LINH KIỆN CỦA HÓA ĐƠN
     */
    public double calculatePartsTotalForInvoice(int invoiceId) {
        double total = 0;
        String sql = "SELECT ISNULL(SUM(rpd.Quantity * rpd.UnitPrice), 0) as Total "
                + "FROM Invoice i "
                + "INNER JOIN ServiceRequest sr ON i.ContractID = sr.ContractID "
                + "INNER JOIN RepairReport rr ON sr.RequestID = rr.RequestID "
                + "INNER JOIN RepairPartDetails rpd ON rr.ReportID = rpd.ReportID "
                + "WHERE i.InvoiceID = ? "
                + "AND rpd.PaymentStatus = 'Completed'";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, invoiceId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                total = rs.getDouble("Total");
                System.out.println("💰 Parts total for invoice " + invoiceId + ": $" + total);
            }

        } catch (SQLException e) {
            System.out.println("❌ Error calculating parts total: " + e.getMessage());
            e.printStackTrace();
        }

        return total;
    }

    /**
     * ✅ THỐNG KÊ LINH KIỆN THEO DANH MỤC
     */
    public List<Map<String, Object>> getPartsCategoryStats(int invoiceId) {
        List<Map<String, Object>> stats = new ArrayList<>();
        String sql = "SELECT "
                + "    p.Category, "
                + "    COUNT(DISTINCT p.PartID) as PartCount, "
                + "    SUM(rpd.Quantity) as TotalQuantity, "
                + "    SUM(rpd.Quantity * rpd.UnitPrice) as CategoryTotal "
                + "FROM Invoice i "
                + "INNER JOIN ServiceRequest sr ON i.ContractID = sr.ContractID "
                + "INNER JOIN RepairReport rr ON sr.RequestID = rr.RequestID "
                + "INNER JOIN RepairPartDetails rpd ON rr.ReportID = rpd.ReportID "
                + "INNER JOIN Part p ON rpd.PartID = p.PartID "
                + "WHERE i.InvoiceID = ? "
                + "AND rpd.PaymentStatus = 'Completed' "
                + "GROUP BY p.Category "
                + "ORDER BY CategoryTotal DESC";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, invoiceId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Map<String, Object> stat = new HashMap<>();
                stat.put("category", rs.getString("Category"));
                stat.put("partCount", rs.getInt("PartCount"));
                stat.put("totalQuantity", rs.getInt("TotalQuantity"));
                stat.put("categoryTotal", rs.getDouble("CategoryTotal"));
                stats.add(stat);

                System.out.println("📊 Category: " + rs.getString("Category")
                        + " - Parts: " + rs.getInt("PartCount")
                        + " - Total: $" + rs.getDouble("CategoryTotal"));
            }

            System.out.println("📊 Category stats for invoice " + invoiceId + ": " + stats.size() + " categories");

        } catch (SQLException e) {
            System.out.println("❌ Error getting category stats: " + e.getMessage());
            e.printStackTrace();
        }

        return stats;
    }

    /**
     * Tạo Invoice mới (với paymentMethod)
     */
    public int createInvoice(int contractId, double totalAmount, String status, LocalDate dueDate, String paymentMethod) throws SQLException {
        String sql = "INSERT INTO Invoice (contractId, issueDate, dueDate, totalAmount, status, paymentMethod) VALUES (?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, contractId);
            ps.setDate(2, Date.valueOf(LocalDate.now()));
            if (dueDate != null) {
                ps.setDate(3, Date.valueOf(dueDate));
            } else {
                ps.setDate(3, Date.valueOf(LocalDate.now().plusDays(30))); // Mặc định 30 ngày
            }
            ps.setDouble(4, totalAmount);
            ps.setString(5, status);
            ps.setString(6, paymentMethod);

            int rowsAffected = ps.executeUpdate();
            if (rowsAffected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
        }
        return -1;
    }

    /**
     * Tạo Invoice mới (backward compatibility - không có paymentMethod)
     */
    public int createInvoice(int contractId, double totalAmount, String status, LocalDate dueDate) throws SQLException {
        return createInvoice(contractId, totalAmount, status, dueDate, null);
    }

    /**
     * Tạo InvoiceDetail với paymentStatus
     */
    public int createInvoiceDetail(int invoiceId, String description, double amount, String paymentStatus) throws SQLException {
        String sql = "INSERT INTO InvoiceDetail (invoiceId, description, amount, paymentStatus) VALUES (?, ?, ?, ?)";
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, invoiceId);
            ps.setString(2, description);
            ps.setDouble(3, amount);
            ps.setString(4, paymentStatus);

            int rowsAffected = ps.executeUpdate();
            if (rowsAffected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        int detailId = rs.getInt(1);
                        System.out.println("✅ InvoiceDetail created: detailId=" + detailId + ", paymentStatus=" + paymentStatus);
                        return detailId;
                    }
                }
            }
        }
        return -1;
    }

    /**
     * Tạo InvoiceDetail (backward compatibility - default paymentStatus =
     * "Pending")
     */
    public int createInvoiceDetail(int invoiceId, String description, double amount) throws SQLException {
        return createInvoiceDetail(invoiceId, description, amount, "Pending");
    }

    /**
     * ✅ Tạo InvoiceDetail với link đến RepairReportDetail
     *
     * @param invoiceId ID của Invoice
     * @param description Mô tả
     * @param amount Số tiền
     * @param repairReportDetailId ID của RepairReportDetail (linh kiện)
     * @param paymentStatus Trạng thái thanh toán (Pending, Completed)
     * @return ID của InvoiceDetail vừa tạo
     */
    public int createInvoiceDetailWithRepairPart(int invoiceId, String description, double amount,
            int repairReportDetailId, String paymentStatus) throws SQLException {
        String sql = "INSERT INTO InvoiceDetail (invoiceId, description, amount, repairReportDetailId, paymentStatus) "
                + "VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, invoiceId);
            ps.setString(2, description);
            ps.setDouble(3, amount);
            ps.setInt(4, repairReportDetailId);
            ps.setString(5, paymentStatus);

            int rowsAffected = ps.executeUpdate();
            if (rowsAffected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        int invoiceDetailId = rs.getInt(1);
                        System.out.println("✅ Created InvoiceDetail: ID=" + invoiceDetailId
                                + ", RepairPartId=" + repairReportDetailId
                                + ", Amount=" + amount
                                + ", PaymentStatus=" + paymentStatus);
                        return invoiceDetailId;
                    }
                }
            }
        }
        return -1;
    }

    /**
     * Cập nhật trạng thái Invoice
     */
    public boolean updateInvoiceStatus(int invoiceId, String status) throws SQLException {
        String sql = "UPDATE Invoice SET status = ? WHERE invoiceId = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, invoiceId);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Cập nhật thông tin thanh toán Invoice (status, paymentMethod,
     * totalAmount)
     */
    public boolean updateInvoicePaymentInfo(int invoiceId, String status, String paymentMethod, double totalAmount) throws SQLException {
        String sql = "UPDATE Invoice SET status = ?, paymentMethod = ?, totalAmount = ? WHERE invoiceId = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setString(2, paymentMethod);
            ps.setDouble(3, totalAmount);
            ps.setInt(4, invoiceId);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * ✅ Cập nhật paymentStatus của một InvoiceDetail cụ thể (theo
     * invoiceDetailId)
     *
     * @param invoiceDetailId ID của InvoiceDetail
     * @param paymentStatus Trạng thái thanh toán (Pending, Completed,
     * Cancelled)
     * @return true nếu cập nhật thành công
     */
    public boolean updateInvoiceDetailPaymentStatus(int invoiceDetailId, String paymentStatus) throws SQLException {
        String sql = "UPDATE InvoiceDetail SET paymentStatus = ? WHERE invoiceDetailId = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, paymentStatus);
            ps.setInt(2, invoiceDetailId);
            int rowsAffected = ps.executeUpdate();
            System.out.println("✅ Updated InvoiceDetail " + invoiceDetailId + " paymentStatus to: " + paymentStatus + " (rows affected: " + rowsAffected + ")");
            return rowsAffected > 0;
        }
    }

    /**
     * ✅ Cập nhật paymentStatus của tất cả InvoiceDetail thuộc một Invoice (theo
     * invoiceId)
     *
     * @param invoiceId ID của Invoice
     * @param paymentStatus Trạng thái thanh toán (Pending, Completed,
     * Cancelled)
     * @return true nếu cập nhật thành công
     */
    public boolean updateAllInvoiceDetailsPaymentStatus(int invoiceId, String paymentStatus) throws SQLException {
        String sql = "UPDATE InvoiceDetail SET paymentStatus = ? WHERE invoiceId = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, paymentStatus);
            ps.setInt(2, invoiceId);
            int rowsAffected = ps.executeUpdate();
            System.out.println("✅ Updated all InvoiceDetails of Invoice " + invoiceId + " paymentStatus to: " + paymentStatus + " (rows affected: " + rowsAffected + ")");
            return rowsAffected > 0;
        }
    }

    /**
     * ✅ Kiểm tra xem Invoice có InvoiceDetail hay không
     */
    public boolean hasInvoiceDetail(int invoiceId) {
        String sql = "SELECT COUNT(*) FROM InvoiceDetail WHERE invoiceId = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, invoiceId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                int count = rs.getInt(1);
                System.out.println("✅ InvoiceDetail count for invoiceId=" + invoiceId + ": " + count);
                return count > 0;
            }
        } catch (SQLException e) {
            System.err.println("❌ Error checking InvoiceDetail: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    /**
     * ✅ Xóa tất cả InvoiceDetail pending cho invoiceId (cleanup)
     */
    public boolean deletePendingInvoiceDetails(int invoiceId) {
        String sql = "DELETE FROM InvoiceDetail WHERE invoiceId = ? AND paymentStatus = 'Pending'";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, invoiceId);
            int rowsAffected = ps.executeUpdate();
            if (rowsAffected > 0) {
                System.out.println("✅ Deleted " + rowsAffected + " pending InvoiceDetail(s) for invoiceId=" + invoiceId);
            }
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.err.println("❌ Error deleting pending InvoiceDetails: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    public Invoice getInvoiceByReportId(int reportId) {
        String sql = "SELECT i.* FROM Invoice i "
                + "JOIN InvoiceDetail d ON i.InvoiceId = d.InvoiceId "
                + "JOIN RepairReport r ON d.repairReportDetailId = r.reportId "
                + "WHERE r.reportId = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, reportId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Invoice inv = new Invoice();
                inv.setInvoiceId(rs.getInt("InvoiceId"));
                inv.setContractId(rs.getInt("ContractId"));
                inv.setIssueDate(rs.getDate("IssueDate").toLocalDate());
                inv.setDueDate(rs.getDate("DueDate").toLocalDate());
                inv.setTotalAmount(rs.getDouble("TotalAmount"));
                inv.setStatus(rs.getString("Status"));
                inv.setPaymentMethod(rs.getString("paymentMethod"));
                return inv;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
}
