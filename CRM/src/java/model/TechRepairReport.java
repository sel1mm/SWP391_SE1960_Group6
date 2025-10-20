package model;

import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * RepairReport model aligned with business flow - quotation and diagnosis for customers.
 */
public class TechRepairReport {
    private Long reportId;
    private Long requestId;
    private Long technicianId;
    private String details;
    private String diagnosis;
    private BigDecimal estimatedCost;
    private String quotationStatus;
    private LocalDate repairDate;
    private Long invoiceDetailId;

    // Constructors
    public TechRepairReport() {
        this.quotationStatus = "Pending"; // Default status
    }

    // Getters and Setters
    public Long getReportId() { return reportId; }
    public void setReportId(Long reportId) { this.reportId = reportId; }

    public Long getRequestId() { return requestId; }
    public void setRequestId(Long requestId) { this.requestId = requestId; }

    public Long getTechnicianId() { return technicianId; }
    public void setTechnicianId(Long technicianId) { this.technicianId = technicianId; }

    public String getDetails() { return details; }
    public void setDetails(String details) { this.details = details; }

    public String getDiagnosis() { return diagnosis; }
    public void setDiagnosis(String diagnosis) { this.diagnosis = diagnosis; }

    public BigDecimal getEstimatedCost() { return estimatedCost; }
    public void setEstimatedCost(BigDecimal estimatedCost) { this.estimatedCost = estimatedCost; }

    public String getQuotationStatus() { return quotationStatus; }
    public void setQuotationStatus(String quotationStatus) { this.quotationStatus = quotationStatus; }

    public LocalDate getRepairDate() { return repairDate; }
    public void setRepairDate(LocalDate repairDate) { this.repairDate = repairDate; }

    public Long getInvoiceDetailId() { return invoiceDetailId; }
    public void setInvoiceDetailId(Long invoiceDetailId) { this.invoiceDetailId = invoiceDetailId; }
}