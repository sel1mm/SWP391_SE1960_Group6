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

                        // ✅ Lấy paymentMethod từ Invoice table
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

                        // ✅ Lấy paymentMethod từ Invoice table
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

            // Lấy chi tiết các dòng trong hóa đơn
            public List<InvoiceDetail> getInvoiceDetails(int invoiceId) {
                List<InvoiceDetail> details = new ArrayList<>();
                String sql = "SELECT * FROM InvoiceDetail WHERE InvoiceId = ?";

                try (PreparedStatement ps = connection.prepareStatement(sql)) {
                    ps.setInt(1, invoiceId);
                    ResultSet rs = ps.executeQuery();

                    while (rs.next()) {
                        InvoiceDetail detail = new InvoiceDetail();
                        detail.setInvoiceDetailId(rs.getInt("InvoiceDetailId"));
                        detail.setInvoiceId(rs.getInt("InvoiceId"));
                        detail.setDescription(rs.getString("Description"));
                        detail.setAmount(rs.getDouble("Amount"));
                        details.add(detail);
                    }
                } catch (SQLException e) {
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

                        // ✅ Lấy paymentMethod từ Invoice table
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

            // Lấy chi tiết linh kiện từ báo cáo sửa chữa
            public List<Map<String, Object>> getRepairPartDetails(int invoiceId) {
                List<Map<String, Object>> partDetails = new ArrayList<>();
                String sql = "SELECT "
                        + "rr.reportId, "
                        + "rr.description as reportDescription, "
                        + "rrd.quantity, "
                        + "p.partName, "
                        + "p.category, "
                        + "pd.price, "
                        + "(rrd.quantity * pd.price) as totalPrice "
                        + "FROM RepairReport rr "
                        + "JOIN RepairReportDetail rrd ON rr.reportId = rrd.reportId "
                        + "JOIN Part p ON rrd.partId = p.partId "
                        + "JOIN PartDetail pd ON p.partId = pd.partId "
                        + "JOIN InvoiceDetail id ON rr.invoiceDetailId = id.invoiceDetailId "
                        + "WHERE id.invoiceId = ? "
                        + "ORDER BY rr.reportId, p.partName";

                try (PreparedStatement ps = connection.prepareStatement(sql)) {
                    ps.setInt(1, invoiceId);
                    ResultSet rs = ps.executeQuery();

                    while (rs.next()) {
                        Map<String, Object> detail = new HashMap<>();
                        detail.put("reportId", rs.getInt("reportId"));
                        detail.put("reportDescription", rs.getString("reportDescription"));
                        detail.put("quantity", rs.getInt("quantity"));
                        detail.put("partName", rs.getString("partName"));
                        detail.put("category", rs.getString("category"));
                        detail.put("price", rs.getDouble("price"));
                        detail.put("totalPrice", rs.getDouble("totalPrice"));
                        partDetails.add(detail);
                    }
                } catch (SQLException e) {
                    e.printStackTrace();
                }
                return partDetails;
            }

            // Tính tổng tiền linh kiện cho một hóa đơn
            public double calculatePartsTotalForInvoice(int invoiceId) {
                String sql = "SELECT ISNULL(SUM(rrd.quantity * pd.price), 0) as totalPartsAmount "
                        + "FROM RepairReport rr "
                        + "JOIN RepairReportDetail rrd ON rr.reportId = rrd.reportId "
                        + "JOIN Part p ON rrd.partId = p.partId "
                        + "JOIN PartDetail pd ON p.partId = pd.partId "
                        + "JOIN InvoiceDetail id ON rr.invoiceDetailId = id.invoiceDetailId "
                        + "WHERE id.invoiceId = ?";

                try (PreparedStatement ps = connection.prepareStatement(sql)) {
                    ps.setInt(1, invoiceId);
                    ResultSet rs = ps.executeQuery();
                    if (rs.next()) {
                        return rs.getDouble("totalPartsAmount");
                    }
                } catch (SQLException e) {
                    e.printStackTrace();
                }
                return 0.0;
            }

            // Lấy thống kê linh kiện theo danh mục cho một hóa đơn
            public List<Map<String, Object>> getPartsCategoryStats(int invoiceId) {
                List<Map<String, Object>> categoryStats = new ArrayList<>();
                String sql = "SELECT "
                        + "p.category, "
                        + "COUNT(DISTINCT p.partId) as partCount, "
                        + "SUM(rrd.quantity) as totalQuantity, "
                        + "SUM(rrd.quantity * pd.price) as categoryTotal "
                        + "FROM RepairReport rr "
                        + "JOIN RepairReportDetail rrd ON rr.reportId = rrd.reportId "
                        + "JOIN Part p ON rrd.partId = p.partId "
                        + "JOIN PartDetail pd ON p.partId = pd.partId "
                        + "JOIN InvoiceDetail id ON rr.invoiceDetailId = id.invoiceDetailId "
                        + "WHERE id.invoiceId = ? "
                        + "GROUP BY p.category "
                        + "ORDER BY categoryTotal DESC";

                try (PreparedStatement ps = connection.prepareStatement(sql)) {
                    ps.setInt(1, invoiceId);
                    ResultSet rs = ps.executeQuery();

                    while (rs.next()) {
                        Map<String, Object> stat = new HashMap<>();
                        stat.put("category", rs.getString("category"));
                        stat.put("partCount", rs.getInt("partCount"));
                        stat.put("totalQuantity", rs.getInt("totalQuantity"));
                        stat.put("categoryTotal", rs.getDouble("categoryTotal"));
                        categoryStats.add(stat);
                    }
                } catch (SQLException e) {
                    e.printStackTrace();
                }
                return categoryStats;
            }
public List<Map<String, Object>> getInvoicesByCustomerWithReport(int customerId) {
    List<Map<String, Object>> invoices = new ArrayList<>();

    String sql = """
        SELECT 
            i.invoiceId,
            i.contractId,
            i.issueDate,
            i.dueDate,
            i.totalAmount,
            i.status,
            i.paymentMethod,
            r.reportId,
            r.description AS reportDescription
        FROM Invoice i
        JOIN Payment p ON i.invoiceId = p.invoiceId
        JOIN RepairReport r ON p.reportId = r.reportId
        JOIN Contract c ON i.contractId = c.contractId
        WHERE c.customerId = ?
        ORDER BY i.issueDate DESC
    """;

    try (PreparedStatement ps = connection.prepareStatement(sql)) {
        ps.setInt(1, customerId);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Map<String, Object> map = new HashMap<>();
            map.put("invoiceId", rs.getInt("invoiceId"));
            map.put("contractId", rs.getInt("contractId"));
            map.put("issueDate", rs.getDate("issueDate"));
            map.put("dueDate", rs.getDate("dueDate"));
            map.put("totalAmount", rs.getDouble("totalAmount"));
            map.put("status", rs.getString("status"));
            map.put("paymentMethod", rs.getString("paymentMethod"));
            map.put("reportId", rs.getInt("reportId"));
            map.put("reportDescription", rs.getString("reportDescription"));
            invoices.add(map);
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }

    return invoices;
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
             * Tạo InvoiceDetail
             */
public int createInvoiceDetail(int invoiceId, String description, double amount, String paymentStatus) throws SQLException {
    String sql = "INSERT INTO InvoiceDetail (invoiceId, description, paymentStatus, amount, paymentDate) VALUES (?, ?, ?, ?, NOW())";
    try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
        ps.setInt(1, invoiceId);
        ps.setString(2, description);
        ps.setString(3, paymentStatus);
        ps.setDouble(4, amount);
        
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

            
         
            private boolean isInvoiceDetailExistsForPart(int invoiceId, String description) throws SQLException {
                String sql = "SELECT COUNT(*) FROM InvoiceDetail WHERE invoiceId = ? AND description = ?";

                try (PreparedStatement ps = connection.prepareStatement(sql)) {
                    ps.setInt(1, invoiceId);
                    ps.setString(2, description);
                    ResultSet rs = ps.executeQuery();

                    if (rs.next()) {
                        int count = rs.getInt(1);
                        return count > 0;
                    }
                }

                return false;
            }

            /**
             * ✅ LẤY ID CỦA INVOICE DETAIL ĐÃ TỒN TẠI
             */
            private int getExistingInvoiceDetailIdForPart(int invoiceId, String description) throws SQLException {
                String sql = "SELECT invoiceDetailId FROM InvoiceDetail WHERE invoiceId = ? AND description = ? LIMIT 1";

                try (PreparedStatement ps = connection.prepareStatement(sql)) {
                    ps.setInt(1, invoiceId);
                    ps.setString(2, description);
                    ResultSet rs = ps.executeQuery();

                    if (rs.next()) {
                        return rs.getInt("invoiceDetailId");
                    }
                }

                return -1;
            }

            /**
             * ✅ CẬP NHẬT TOTAL AMOUNT CỦA INVOICE
             */
            public boolean updateInvoiceTotalAmountFromDetails(int invoiceId) throws SQLException {
                String sql = "UPDATE Invoice "
                        + "SET totalAmount = (SELECT COALESCE(SUM(amount), 0) FROM InvoiceDetail WHERE invoiceId = ?) "
                        + "WHERE invoiceId = ?";

                try (PreparedStatement ps = connection.prepareStatement(sql)) {
                    ps.setInt(1, invoiceId);
                    ps.setInt(2, invoiceId);

                    int affected = ps.executeUpdate();
                    System.out.println("✅ Updated Invoice totalAmount for invoiceId: " + invoiceId);
                    return affected > 0;
                }
            }

            /**
             * ✅ CẬP NHẬT STATUS CỦA INVOICE (overload method)
             */
            public boolean updateInvoiceStatusOnly(int invoiceId, String status) throws SQLException {
                String sql = "UPDATE Invoice SET status = ? WHERE invoiceId = ?";

                try (PreparedStatement ps = connection.prepareStatement(sql)) {
                    ps.setString(1, status);
                    ps.setInt(2, invoiceId);

                    int affected = ps.executeUpdate();
                    System.out.println("✅ Updated Invoice status to '" + status + "' for invoiceId: " + invoiceId);
                    return affected > 0;
                }
            }
            /**
     * ✅ TẠO HOẶC LẤY INVOICE CHO SERVICE REQUEST (TRÁNH DUPLICATE)
     */
    public int getOrCreateInvoiceForServiceRequest(int requestId, int customerId) throws SQLException {
        System.out.println("========== GET OR CREATE INVOICE ==========");
        System.out.println("requestId: " + requestId);

        // ✅ BƯỚC 1: Kiểm tra đã có Invoice chưa (kiểm tra cả Pending và Paid)
        String checkSql = "SELECT i.invoiceId, i.status "
                + "FROM Invoice i "
                + "JOIN ServiceRequest sr ON i.contractId = sr.contractId "
                + "WHERE sr.requestId = ? "
                + "ORDER BY i.invoiceId DESC LIMIT 1";
        
        try (PreparedStatement ps = connection.prepareStatement(checkSql)) {
            ps.setInt(1, requestId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                int existingInvoiceId = rs.getInt("invoiceId");
                String status = rs.getString("status");
                System.out.println("✅ Found existing Invoice: " + existingInvoiceId + " with status: " + status);
                
                // ⚠️ Nếu đã Paid rồi, không cho thanh toán lại
                if ("Paid".equalsIgnoreCase(status)) {
                    System.out.println("⚠️ Invoice already paid - returning existing ID");
                }
                return existingInvoiceId;
            }
        }

        // ✅ BƯỚC 2: Lấy contractId từ ServiceRequest
        int contractId = -1;
        String getContractSql = "SELECT contractId FROM ServiceRequest WHERE requestId = ?";
        try (PreparedStatement ps = connection.prepareStatement(getContractSql)) {
            ps.setInt(1, requestId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                contractId = rs.getInt("contractId");
                if (rs.wasNull()) {
                    contractId = -1;
                }
            }
        }

        if (contractId <= 0) {
            System.err.println("❌ Invalid contractId: " + contractId);
            return -1;
        }

        // ✅ BƯỚC 3: Tạo Invoice mới
        String insertSql = "INSERT INTO Invoice (contractId, issueDate, dueDate, totalAmount, status) "
                + "VALUES (?, ?, ?, ?, ?)";
        
        try (PreparedStatement ps = connection.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, contractId);
            ps.setDate(2, Date.valueOf(LocalDate.now()));
            ps.setDate(3, Date.valueOf(LocalDate.now().plusDays(30)));
            ps.setDouble(4, 0.0);
            ps.setString(5, "Pending");

            int affected = ps.executeUpdate();
            if (affected > 0) {
                ResultSet rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    int newInvoiceId = rs.getInt(1);
                    System.out.println("✅ Created new Invoice: " + newInvoiceId);
                    return newInvoiceId;
                }
            }
        }

        return -1;
    }

    /**
     * ✅ TẠO INVOICE DETAIL CHO THANH TOÁN LINH KIỆN (TRÁNH DUPLICATE + CẬP NHẬT PAYMENT STATUS)
     */
    public int createInvoiceDetailForPart(int invoiceId, String description, java.math.BigDecimal amount) throws SQLException {
        System.out.println("========== CREATE INVOICE DETAIL FOR PART ==========");
        System.out.println("invoiceId: " + invoiceId);
        System.out.println("description: " + description);
        System.out.println("amount: " + amount);

        // ✅ KIỂM TRA TRÙNG LẶP TRƯỚC KHI INSERT
        int existingDetailId = getExistingInvoiceDetailIdForPart(invoiceId, description);
        if (existingDetailId > 0) {
            System.out.println("⚠️ InvoiceDetail already exists with ID: " + existingDetailId);
            
            // ✅ CẬP NHẬT PAYMENT STATUS NẾU CHƯA COMPLETED
            
            return existingDetailId;
        }

        // ✅ TẠO MỚI INVOICE DETAIL VỚI PAYMENT STATUS = 'Pending'
        String sql = "INSERT INTO InvoiceDetail (invoiceId, description, amount, paymentStatus) VALUES (?, ?, ?, ?)";
        
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, invoiceId);
            ps.setString(2, description);
            ps.setBigDecimal(3, amount);
            ps.setString(4, "Pending"); // Mặc định là Pending

            int affected = ps.executeUpdate();
            System.out.println("✅ INSERT affected rows: " + affected);

            if (affected > 0) {
                ResultSet rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    int invoiceDetailId = rs.getInt(1);
                    System.out.println("✅ Created InvoiceDetail ID: " + invoiceDetailId);
                    return invoiceDetailId;
                }
            }

            System.out.println("❌ Failed to create invoice detail");
            return -1;

        } catch (SQLException e) {
            System.err.println("❌ SQL Error:");
            System.err.println("   Message: " + e.getMessage());
            e.printStackTrace();
            throw e;
        }
    }

    /**
     * ✅ CẬP NHẬT PAYMENT STATUS CỦA INVOICE DETAIL
     */
public boolean updateInvoiceDetailPaymentStatus(Integer invoiceId) {
    String sql = "UPDATE InvoiceDetail SET paymentStatus = ?, paymentDate = NOW() WHERE invoiceId = ?";
    
    try {
        PreparedStatement st = connection.prepareStatement(sql);
        st.setString(1, "Completed");
        st.setInt(2, invoiceId);
        
        System.out.println("Executing SQL: " + sql);
        System.out.println("Parameters: paymentStatus=Completed, invoiceId=" + invoiceId);
        
        int rowsAffected = st.executeUpdate();
        System.out.println("Rows affected: " + rowsAffected);
        
        return rowsAffected > 0;
    } catch (SQLException e) {
        System.out.println("Error updating invoice detail payment status: " + e.getMessage());
        e.printStackTrace();
        return false;
    }
}

    /**
     * ✅ CẬP NHẬT PAYMENT STATUS CHO TẤT CẢ INVOICE DETAIL CỦA MỘT INVOICE
     */
    public boolean updateAllInvoiceDetailsPaymentStatus(int invoiceId, String paymentStatus) throws SQLException {
        String sql = "UPDATE InvoiceDetail SET paymentStatus = ? WHERE invoiceId = ?";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, paymentStatus);
            ps.setInt(2, invoiceId);
            int affected = ps.executeUpdate();
            
            System.out.println("✅ Updated " + affected + " InvoiceDetails to paymentStatus '" + paymentStatus + "' for invoiceId: " + invoiceId);
            return affected > 0;
        }
    }

    /**
     * ✅ CẬP NHẬT TOTAL AMOUNT CỦA INVOICE TỪ CÁC INVOICE DETAIL
     */

    /**
     * ✅ CẬP NHẬT STATUS VÀ PAYMENT METHOD CỦA INVOICE + TẤT CẢ INVOICE DETAIL
     */
    public boolean completeInvoicePayment(int invoiceId, String paymentMethod) throws SQLException {
        connection.setAutoCommit(false);
        
        try {
            // 1. Cập nhật Invoice status = 'Paid', paymentMethod
            String updateInvoiceSql = "UPDATE Invoice SET status = 'Paid', paymentMethod = ? WHERE invoiceId = ?";
            try (PreparedStatement ps = connection.prepareStatement(updateInvoiceSql)) {
                ps.setString(1, paymentMethod);
                ps.setInt(2, invoiceId);
                ps.executeUpdate();
            }

            // 2. Cập nhật tất cả InvoiceDetail paymentStatus = 'Completed'
            updateAllInvoiceDetailsPaymentStatus(invoiceId, "Completed");

            connection.commit();
            System.out.println("✅ Completed payment for Invoice ID: " + invoiceId);
            return true;

        } catch (SQLException e) {
            connection.rollback();
            System.err.println("❌ Error completing payment: " + e.getMessage());
            throw e;
        } finally {
            connection.setAutoCommit(true);
        }
    }

    /**
     * ✅ KIỂM TRA XEM INVOICE ĐÃ ĐƯỢC THANH TOÁN CHƯA
     */
    public boolean isInvoicePaid(int invoiceId) throws SQLException {
        String sql = "SELECT status FROM Invoice WHERE invoiceId = ?";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, invoiceId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                String status = rs.getString("status");
                return "Paid".equalsIgnoreCase(status);
            }
        }
        return false;
    }

    /**
     * ✅ LẤY INVOICE ID TỪ REQUEST ID (VỚI KIỂM TRA TRÙNG LẶP)
     */
    public Integer getInvoiceIdByRequestId(int requestId) throws SQLException {
        String sql = "SELECT i.invoiceId "
                + "FROM Invoice i "
                + "JOIN ServiceRequest sr ON i.contractId = sr.contractId "
                + "WHERE sr.requestId = ? "
                + "ORDER BY i.invoiceId DESC LIMIT 1";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, requestId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("invoiceId");
            }
        }
        return null;
    }
    public boolean updateInvoicePaymentInfo(Integer invoiceId, String transactionNo, String paymentMethod, double amount) {
    String sql = "UPDATE Invoice SET TransactionNo = ?, PaymentMethod = ?, Amount = ?, PaymentStatus = ?, PaymentDate = NOW() WHERE InvoiceID = ?";
    
    try {
        PreparedStatement st = connection.prepareStatement(sql);
        st.setString(1, transactionNo);
        st.setString(2, paymentMethod);
        st.setDouble(3, amount);
        st.setString(4, "Paid"); // or whatever status indicates successful payment
        st.setInt(5, invoiceId);
        
        int rowsAffected = st.executeUpdate();
        return rowsAffected > 0;
    } catch (SQLException e) {
        System.out.println("Error updating invoice payment info: " + e.getMessage());
        return false;
    }
}
        }
