package model;

import java.time.LocalDateTime;

/**
 * Model class for Payment table
 * Updated with reportId to link with RepairReport
 */
public class Payment {
    private int paymentId;
    private int invoiceId;
    private double amount;
    private LocalDateTime paymentDate;
    private String status; // "Pending", "Completed", "Failed"
    private Integer reportId; // ✅ Link to RepairReport (nullable)
    
    // Constructors
    public Payment() {
    }
    
    public Payment(int paymentId, int invoiceId, double amount, LocalDateTime paymentDate, 
                   String status, Integer reportId) {
        this.paymentId = paymentId;
        this.invoiceId = invoiceId;
        this.amount = amount;
        this.paymentDate = paymentDate;
        this.status = status;
        this.reportId = reportId;
    }
    
    // Getters and Setters
    public int getPaymentId() {
        return paymentId;
    }
    
    public void setPaymentId(int paymentId) {
        this.paymentId = paymentId;
    }
    
    public int getInvoiceId() {
        return invoiceId;
    }
    
    public void setInvoiceId(int invoiceId) {
        this.invoiceId = invoiceId;
    }
    
    public double getAmount() {
        return amount;
    }
    
    public void setAmount(double amount) {
        this.amount = amount;
    }
    
    public LocalDateTime getPaymentDate() {
        return paymentDate;
    }
    
    public void setPaymentDate(LocalDateTime paymentDate) {
        this.paymentDate = paymentDate;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    /**
     * ✅ Get reportId - Link to RepairReport
     */
    public Integer getReportId() {
        return reportId;
    }
    
    /**
     * ✅ Set reportId - Link to RepairReport
     */
    public void setReportId(Integer reportId) {
        this.reportId = reportId;
    }
    
    // Helper methods
    public boolean isPending() {
        return "Pending".equalsIgnoreCase(this.status);
    }
    
    public boolean isCompleted() {
        return "Completed".equalsIgnoreCase(this.status);
    }
    
    public boolean isFailed() {
        return "Failed".equalsIgnoreCase(this.status);
    }
    
    public boolean hasReport() {
        return this.reportId != null && this.reportId > 0;
    }
    
    @Override
    public String toString() {
        return "Payment{" +
                "paymentId=" + paymentId +
                ", invoiceId=" + invoiceId +
                ", amount=" + amount +
                ", paymentDate=" + paymentDate +
                ", status='" + status + '\'' +
                ", reportId=" + reportId +
                '}';
    }
}

