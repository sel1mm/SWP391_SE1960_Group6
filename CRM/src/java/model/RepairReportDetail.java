package model;

import java.math.BigDecimal;

/**
 * Model class for RepairReportDetail.
 * Represents a line item in a repair report (part with quantity and price).
 */
public class RepairReportDetail {
    private int detailId;
    private int reportId;
    private int partId;
    private Integer partDetailId; // Optional: specific PartDetail instance
    private int quantity;
    private BigDecimal unitPrice;
    
    // Display fields (not stored in DB, populated from joins)
    private String partName;
    private String serialNumber;
    private String location;
    
    // Constructors
    public RepairReportDetail() {}
    
    public RepairReportDetail(int reportId, int partId, Integer partDetailId, int quantity, BigDecimal unitPrice) {
        this.reportId = reportId;
        this.partId = partId;
        this.partDetailId = partDetailId;
        this.quantity = quantity;
        this.unitPrice = unitPrice;
    }
    
    // Getters and Setters
    public int getDetailId() {
        return detailId;
    }
    
    public void setDetailId(int detailId) {
        this.detailId = detailId;
    }
    
    public int getReportId() {
        return reportId;
    }
    
    public void setReportId(int reportId) {
        this.reportId = reportId;
    }
    
    public int getPartId() {
        return partId;
    }
    
    public void setPartId(int partId) {
        this.partId = partId;
    }
    
    public Integer getPartDetailId() {
        return partDetailId;
    }
    
    public void setPartDetailId(Integer partDetailId) {
        this.partDetailId = partDetailId;
    }
    
    public int getQuantity() {
        return quantity;
    }
    
    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }
    
    public BigDecimal getUnitPrice() {
        return unitPrice;
    }
    
    public void setUnitPrice(BigDecimal unitPrice) {
        this.unitPrice = unitPrice;
    }
    
    public String getPartName() {
        return partName;
    }
    
    public void setPartName(String partName) {
        this.partName = partName;
    }
    
    public String getSerialNumber() {
        return serialNumber;
    }
    
    public void setSerialNumber(String serialNumber) {
        this.serialNumber = serialNumber;
    }
    
    public String getLocation() {
        return location;
    }
    
    public void setLocation(String location) {
        this.location = location;
    }
    
    /**
     * Calculate line total (quantity * unitPrice)
     */
    public BigDecimal getLineTotal() {
        if (unitPrice == null || quantity <= 0) {
            return BigDecimal.ZERO;
        }
        return unitPrice.multiply(BigDecimal.valueOf(quantity));
    }
    
    @Override
    public String toString() {
        return "RepairReportDetail{" +
                "detailId=" + detailId +
                ", reportId=" + reportId +
                ", partId=" + partId +
                ", partDetailId=" + partDetailId +
                ", quantity=" + quantity +
                ", unitPrice=" + unitPrice +
                '}';
    }
}
