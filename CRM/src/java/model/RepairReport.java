package model;

import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * RepairReport model representing technician repair reports.
 * Maps to the RepairReport table in the final database schema.
 */
public class RepairReport {
    private int reportId;
    private int requestId;
    private Integer technicianId;
    private String details;
    private String diagnosis;
    private BigDecimal estimatedCost;
    private String quotationStatus;
    private LocalDate repairDate;
    private Integer invoiceDetailId;
    private Integer targetContractId; // Which contract will receive the appendix
    private String technicianName;
    private String technicianEmail;// For display purposes (not stored in DB)

    // Constructors
    public RepairReport() {}

    public RepairReport(int reportId, int requestId, Integer technicianId, 
                       String details, String diagnosis, BigDecimal estimatedCost, 
                       String quotationStatus, LocalDate repairDate, Integer invoiceDetailId) {
        this.reportId = reportId;
        this.requestId = requestId;
        this.technicianId = technicianId;
        this.details = details;
        this.diagnosis = diagnosis;
        this.estimatedCost = estimatedCost;
        this.quotationStatus = quotationStatus;
        this.repairDate = repairDate;
        this.invoiceDetailId = invoiceDetailId;
    }

    // Getters and Setters
    public int getReportId() { return reportId; }
    public void setReportId(int reportId) { this.reportId = reportId; }

    public int getRequestId() { return requestId; }
    public void setRequestId(int requestId) { this.requestId = requestId; }

    public Integer getTechnicianId() { return technicianId; }
    public void setTechnicianId(Integer technicianId) { this.technicianId = technicianId; }

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

    public Integer getInvoiceDetailId() { return invoiceDetailId; }
    public void setInvoiceDetailId(Integer invoiceDetailId) { this.invoiceDetailId = invoiceDetailId; }

    public String getTechnicianName() { return technicianName; }
    public void setTechnicianName(String technicianName) { this.technicianName = technicianName; }

    public Integer getTargetContractId() { return targetContractId; }
    public void setTargetContractId(Integer targetContractId) { this.targetContractId = targetContractId; }
    public String getTechnicianEmail() { return technicianEmail; }
    public void setTechnicianEmail(String technicianEmail) { this.technicianEmail = technicianEmail; }
    

    @Override
    public String toString() {
        return "RepairReport{" +
                "reportId=" + reportId +
                ", requestId=" + requestId +
                ", technicianId=" + technicianId +
                ", details='" + details + '\'' +
                ", diagnosis='" + diagnosis + '\'' +
                ", estimatedCost=" + estimatedCost +
                ", quotationStatus='" + quotationStatus + '\'' +
                ", repairDate=" + repairDate +
                ", invoiceDetailId=" + invoiceDetailId +
                ", targetContractId=" + targetContractId +
                '}';
    }
}