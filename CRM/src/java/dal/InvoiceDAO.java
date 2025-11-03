package dal;

import model.Invoice;
import model.InvoiceDetail;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class InvoiceDAO extends DBContext {
    
    // Lấy tất cả hóa đơn của một khách hàng
    public List<Invoice> getInvoicesByCustomerId(int customerId) {
        List<Invoice> invoices = new ArrayList<>();
        String sql = "SELECT i.* FROM Invoice i " +
                     "JOIN Contract c ON i.ContractId = c.ContractId " +
                     "WHERE c.CustomerId = ? " +
                     "ORDER BY i.IssueDate DESC";
        
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
        String sql = "SELECT i.* FROM Invoice i " +
                     "JOIN Contract c ON i.ContractId = c.ContractId " +
                     "WHERE c.CustomerId = ? " +
                     "AND (CAST(i.InvoiceId AS VARCHAR) LIKE ? " +
                     "OR CAST(i.TotalAmount AS VARCHAR) LIKE ? " +
                     "OR i.Status LIKE ?) " +
                     "ORDER BY i.IssueDate DESC";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            String searchPattern = "%" + keyword + "%";
            ps.setString(2, searchPattern);
            ps.setString(3, searchPattern);
            ps.setString(4, searchPattern);
            
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
        String sql = "SELECT COUNT(*) FROM Invoice i " +
                     "JOIN Contract c ON i.ContractId = c.ContractId " +
                     "WHERE c.CustomerId = ?";
        
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
        String sql = "SELECT COUNT(*) FROM Invoice i " +
                     "JOIN Contract c ON i.ContractId = c.ContractId " +
                     "WHERE c.CustomerId = ? AND i.Status = 'Paid'";
        
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
        String sql = "SELECT COUNT(*) FROM Invoice i " +
                     "JOIN Contract c ON i.ContractId = c.ContractId " +
                     "WHERE c.CustomerId = ? AND i.Status = 'Pending'";
        
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
        String sql = "SELECT ISNULL(SUM(i.TotalAmount), 0) FROM Invoice i " +
                     "JOIN Contract c ON i.ContractId = c.ContractId " +
                     "WHERE c.CustomerId = ?";
        
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
}