package model;

import java.time.LocalDate;

/**
 * NewPartDetail Model
 * @author Admin
 */
public class NewPartDetail {
    
    private int partDetailId;
    private int partId;
    private String serialNumber;
    private String status;
    private String location;
    
    // Cho INSERT/UPDATE (INT - Foreign Key)
    private int lastUpdatedBy;
    
    // Cho SELECT với JOIN (String - display)
    private String username;
    
    private LocalDate lastUpdatedDate;

    // ===== CONSTRUCTORS =====
    public NewPartDetail() {
    }

    public NewPartDetail(int partDetailId, int partId, String serialNumber, 
                         String status, String location, int lastUpdatedBy, 
                         String username, LocalDate lastUpdatedDate) {
        this.partDetailId = partDetailId;
        this.partId = partId;
        this.serialNumber = serialNumber;
        this.status = status;
        this.location = location;
        this.lastUpdatedBy = lastUpdatedBy;
        this.username = username;
        this.lastUpdatedDate = lastUpdatedDate;
    }

    // ===== GETTERS & SETTERS =====
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

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public LocalDate getLastUpdatedDate() {
        return lastUpdatedDate;
    }

    public void setLastUpdatedDate(LocalDate lastUpdatedDate) {
        this.lastUpdatedDate = lastUpdatedDate;
    }

    // ===== toString() cho debug =====
    @Override
    public String toString() {
        return "NewPartDetail{" +
                "partDetailId=" + partDetailId +
                ", partId=" + partId +
                ", serialNumber='" + serialNumber + '\'' +
                ", status='" + status + '\'' +
                ", location='" + location + '\'' +
                ", lastUpdatedBy=" + lastUpdatedBy +
                ", username='" + username + '\'' +
                ", lastUpdatedDate=" + lastUpdatedDate +
                '}';
    }
}