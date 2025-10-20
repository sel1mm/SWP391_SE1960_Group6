package model;
import java.time.LocalDate;

public class NewPart {
    private int partId;
    private String partName;
    private String description;
    private double unitPrice;
    private int lastUpdatedBy;
    private LocalDate lastUpdatedDate;
    private String userName ;

    public NewPart() {
    }

    public NewPart(int partId, String partName, String description, double unitPrice, int lastUpdatedBy, LocalDate lastUpdatedDate, String userName) {
        this.partId = partId;
        this.partName = partName;
        this.description = description;
        this.unitPrice = unitPrice;
        this.lastUpdatedBy = lastUpdatedBy;
        this.lastUpdatedDate = lastUpdatedDate;
        this.userName = userName ;
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

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    @Override
    public String toString() {
        return "NewPart{" + "partId=" + partId + ", partName=" + partName + ", description=" + description + ", unitPrice=" + unitPrice + ", lastUpdatedBy=" + lastUpdatedBy + ", lastUpdatedDate=" + lastUpdatedDate + ", userName=" + userName + '}';
    }

  


    
}

