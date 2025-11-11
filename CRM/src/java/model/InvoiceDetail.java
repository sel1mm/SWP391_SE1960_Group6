package model;

public class InvoiceDetail {
    private int invoiceDetailId;
    private int invoiceId;
    private String description;
    private double amount;
    private String paymentStatus; // ✅ Added: "Pending", "Completed", "Failed"

    public InvoiceDetail() {
    }

    public InvoiceDetail(int invoiceDetailId, int invoiceId, String description, double amount) {
        this.invoiceDetailId = invoiceDetailId;
        this.invoiceId = invoiceId;
        this.description = description;
        this.amount = amount;
    }
    
    public InvoiceDetail(int invoiceDetailId, int invoiceId, String description, double amount, String paymentStatus) {
        this.invoiceDetailId = invoiceDetailId;
        this.invoiceId = invoiceId;
        this.description = description;
        this.amount = amount;
        this.paymentStatus = paymentStatus;
    }

    public int getInvoiceDetailId() {
        return invoiceDetailId;
    }

    public void setInvoiceDetailId(int invoiceDetailId) {
        this.invoiceDetailId = invoiceDetailId;
    }

    public int getInvoiceId() {
        return invoiceId;
    }

    public void setInvoiceId(int invoiceId) {
        this.invoiceId = invoiceId;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public double getAmount() {
        return amount;
    }

    public void setAmount(double amount) {
        this.amount = amount;
    }
    
    public String getPaymentStatus() {
        return paymentStatus;
    }
    
    public void setPaymentStatus(String paymentStatus) {
        this.paymentStatus = paymentStatus;
    }
}
