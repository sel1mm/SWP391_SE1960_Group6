package model;
import java.time.LocalDate;

public class Part {
    private int partId;
    private String partName;
    private String description;
    private double unitPrice;
    private int lastUpdatedBy;
    private LocalDate lastUpdatedDate;

    public Part() {
    }

    public Part(int partId, String partName, String description, double unitPrice, int lastUpdatedBy, LocalDate lastUpdatedDate) {
        this.partId = partId;
        this.partName = partName;
        this.description = description;
        this.unitPrice = unitPrice;
        this.lastUpdatedBy = lastUpdatedBy;
        this.lastUpdatedDate = lastUpdatedDate;
    }

    public int getPartId() {
        return partId;
    }

    public void setPartId(int partId) {
        this.partId = partId;
    }

    public String getPartName() {
        return partName;
    }

    public void setPartName(String partName) {
        this.partName = partName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public double getUnitPrice() {
        return unitPrice;
    }

    public void setUnitPrice(double unitPrice) {
        this.unitPrice = unitPrice;
    }

    public int getLastUpdatedBy() {
        return lastUpdatedBy;
    }

    public void setLastUpdatedBy(int lastUpdatedBy) {
        this.lastUpdatedBy = lastUpdatedBy;
    }

    public LocalDate getLastUpdatedDate() {
        return lastUpdatedDate;
    }

    public void setLastUpdatedDate(LocalDate lastUpdatedDate) {
        this.lastUpdatedDate = lastUpdatedDate;
    }
    
    
}
