package model;
import java.time.LocalDate;

public class RepairReport {
    private int reportId;
    private int requestId;
    private int technicianId;
    private String details;
    private String diagnosis;
    private double estimatedCost;
    private String quotationStatus = "Pending";
    private LocalDate repairDate;
    private int invoiceDetailId;

    public RepairReport() {
    }

    public RepairReport(int reportId, int requestId, int technicianId, String details, String diagnosis, double estimatedCost, LocalDate repairDate, int invoiceDetailId) {
        this.reportId = reportId;
        this.requestId = requestId;
        this.technicianId = technicianId;
        this.details = details;
        this.diagnosis = diagnosis;
        this.estimatedCost = estimatedCost;
        this.repairDate = repairDate;
        this.invoiceDetailId = invoiceDetailId;
    }

    public int getReportId() {
        return reportId;
    }

    public void setReportId(int reportId) {
        this.reportId = reportId;
    }

    public int getRequestId() {
        return requestId;
    }

    public void setRequestId(int requestId) {
        this.requestId = requestId;
    }

    public int getTechnicianId() {
        return technicianId;
    }

    public void setTechnicianId(int technicianId) {
        this.technicianId = technicianId;
    }

    public String getDetails() {
        return details;
    }

    public void setDetails(String details) {
        this.details = details;
    }

    public String getDiagnosis() {
        return diagnosis;
    }

    public void setDiagnosis(String diagnosis) {
        this.diagnosis = diagnosis;
    }

    public double getEstimatedCost() {
        return estimatedCost;
    }

    public void setEstimatedCost(double estimatedCost) {
        this.estimatedCost = estimatedCost;
    }

    public String getQuotationStatus() {
        return quotationStatus;
    }

    public void setQuotationStatus(String quotationStatus) {
        this.quotationStatus = quotationStatus;
    }

    public LocalDate getRepairDate() {
        return repairDate;
    }

    public void setRepairDate(LocalDate repairDate) {
        this.repairDate = repairDate;
    }

    public int getInvoiceDetailId() {
        return invoiceDetailId;
    }

    public void setInvoiceDetailId(int invoiceDetailId) {
        this.invoiceDetailId = invoiceDetailId;
    }
    
    
}
