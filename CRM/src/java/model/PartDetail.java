package model;
import java.time.LocalDate;

public class PartDetail {
    private int partDetailId;
    private int partId;
    private String serialNumber;
    private String status;
    private String location;
    private int lastUpdatedBy;
    private LocalDate lastUpdatedDate;

    public PartDetail() {
    }

    public PartDetail(int partDetailId, int partId, String serialNumber, String status, String location, int lastUpdatedBy, LocalDate lastUpdatedDate) {
        this.partDetailId = partDetailId;
        this.partId = partId;
        this.serialNumber = serialNumber;
        this.status = status;
        this.location = location;
        this.lastUpdatedBy = lastUpdatedBy;
        this.lastUpdatedDate = lastUpdatedDate;
    }

    public int getPartDetailId() {
        return partDetailId;
    }

    public void setPartDetailId(int partDetailId) {
        this.partDetailId = partDetailId;
    }

    public int getPartId() {
        return partId;
    }

    public void setPartId(int partId) {
        this.partId = partId;
    }

    public String getSerialNumber() {
        return serialNumber;
    }

    public void setSerialNumber(String serialNumber) {
        this.serialNumber = serialNumber;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
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
