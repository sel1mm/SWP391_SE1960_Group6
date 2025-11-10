package dal;

import model.Payment;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class PaymentDAO extends DBContext {
    
    /**
     * ✅ Kiểm tra có Payment pending nào cho reportId này chưa
     * @return paymentId nếu tồn tại, null nếu không
     */
    public Integer getPendingPaymentByReportId(int reportId) {
        String sql = "SELECT paymentId FROM Payment WHERE reportId = ? AND status = 'Pending'";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, reportId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("paymentId");
            }
        } catch (SQLException e) {
            System.err.println("❌ Error checking pending payment: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }
    
    /**
     * ✅ Tạo Payment mới với liên kết reportId
     * @return paymentId nếu thành công, -1 nếu thất bại
     */
    public int createPaymentWithReport(int invoiceId, double amount, String status, int reportId) {
        String sql = "INSERT INTO Payment (invoiceId, amount, paymentDate, status, reportId) " +
                     "VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, invoiceId);
            ps.setDouble(2, amount);
            ps.setTimestamp(3, Timestamp.valueOf(LocalDateTime.now()));
            ps.setString(4, status);
            ps.setInt(5, reportId);
            
            int rowsAffected = ps.executeUpdate();
            if (rowsAffected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        int paymentId = rs.getInt(1);
                        System.out.println("✅ Created Payment with reportId: paymentId=" + paymentId + ", reportId=" + reportId);
                        return paymentId;
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("❌ Error creating payment with report: " + e.getMessage());
            e.printStackTrace();
        }
        return -1;
    }
    
    /**
     * ✅ Tạo Payment mới (không có reportId - backward compatibility)
     */
    public int createPayment(int invoiceId, double amount, String status) {
        String sql = "INSERT INTO Payment (invoiceId, amount, paymentDate, status) VALUES (?, ?, ?, ?)";
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, invoiceId);
            ps.setDouble(2, amount);
            ps.setTimestamp(3, Timestamp.valueOf(LocalDateTime.now()));
            ps.setString(4, status);
            
            int rowsAffected = ps.executeUpdate();
            if (rowsAffected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("❌ Error creating payment: " + e.getMessage());
            e.printStackTrace();
        }
        return -1;
    }
    
    /**
     * ✅ Xóa Payment pending (dùng khi thanh toán thành công hoặc hủy)
     */
    public boolean deletePendingPayment(int paymentId) {
        String sql = "DELETE FROM Payment WHERE paymentId = ? AND status = 'Pending'";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, paymentId);
            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.err.println("❌ Error deleting pending payment: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * ✅ Cập nhật Payment status
     */
    public boolean updatePaymentStatus(int paymentId, String status) {
        String sql = "UPDATE Payment SET status = ?, paymentDate = ? WHERE paymentId = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setTimestamp(2, Timestamp.valueOf(LocalDateTime.now()));
            ps.setInt(3, paymentId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("❌ Error updating payment status: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * ✅ Lấy Payment theo invoiceId
     */
    public Payment getPaymentByInvoiceId(int invoiceId) {
        String sql = "SELECT * FROM Payment WHERE invoiceId = ? ORDER BY paymentDate DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, invoiceId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Payment payment = new Payment();
                payment.setPaymentId(rs.getInt("paymentId"));
                payment.setInvoiceId(rs.getInt("invoiceId"));
                payment.setAmount(rs.getDouble("amount"));
                
                Timestamp paymentDate = rs.getTimestamp("paymentDate");
                if (paymentDate != null) {
                    payment.setPaymentDate(paymentDate.toLocalDateTime());
                }
                
                payment.setStatus(rs.getString("status"));
                
                // Lấy reportId nếu có
                int reportId = rs.getInt("reportId");
                if (!rs.wasNull()) {
                    payment.setReportId(reportId);
                }
                
                return payment;
            }
        } catch (SQLException e) {
            System.err.println("❌ Error getting payment by invoiceId: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }
    
    /**
     * ✅ Tạo PaymentTransaction
     */
    public int createPaymentTransaction(int paymentId, int customerId, double amount, 
                                       String method, String status) {
        String sql = "INSERT INTO PaymentTransaction (paymentId, customerId, amount, method, status, transactionDate) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, paymentId);
            ps.setInt(2, customerId);
            ps.setDouble(3, amount);
            ps.setString(4, method);
            ps.setString(5, status);
            ps.setTimestamp(6, Timestamp.valueOf(LocalDateTime.now()));
            
            int rowsAffected = ps.executeUpdate();
            if (rowsAffected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("❌ Error creating payment transaction: " + e.getMessage());
            e.printStackTrace();
        }
        return -1;
    }
    
    /**
     * ✅ Lấy tất cả Payment của customer
     */
    public List<Payment> getPaymentsByCustomerId(int customerId) {
        List<Payment> payments = new ArrayList<>();
        String sql = "SELECT p.* FROM Payment p " +
                     "JOIN Invoice i ON p.invoiceId = i.invoiceId " +
                     "JOIN Contract c ON i.contractId = c.contractId " +
                     "WHERE c.customerId = ? ORDER BY p.paymentDate DESC";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Payment payment = new Payment();
                payment.setPaymentId(rs.getInt("paymentId"));
                payment.setInvoiceId(rs.getInt("invoiceId"));
                payment.setAmount(rs.getDouble("amount"));
                
                Timestamp paymentDate = rs.getTimestamp("paymentDate");
                if (paymentDate != null) {
                    payment.setPaymentDate(paymentDate.toLocalDateTime());
                }
                
                payment.setStatus(rs.getString("status"));
                
                int reportId = rs.getInt("reportId");
                if (!rs.wasNull()) {
                    payment.setReportId(reportId);
                }
                
                payments.add(payment);
            }
        } catch (SQLException e) {
            System.err.println("❌ Error getting payments: " + e.getMessage());
            e.printStackTrace();
        }
        return payments;
    }
    
}