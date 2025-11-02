package model;

import java.time.LocalDate;

/**
 * NewPartDetail Model - với thông tin Category
 * @author Admin
 */
public class NewPartDetail {
    
    private int partDetailId;
    private int partId;
    private String serialNumber;
    private String status;
    private String location;
    
    // Category information (JOIN từ Part -> Category)
    private Integer categoryId; // NULL-able
    private String categoryName; // Tên category để hiển thị
    
    // Cho INSERT/UPDATE (INT - Foreign Key)
    private int lastUpdatedBy;
    
    // Cho SELECT với JOIN (String - display)
    private String username;
    
    private LocalDate lastUpdatedDate;
    
    // ===== CONSTRUCTORS =====
    
    public NewPartDetail() {
    }
    
    // Constructor đầy đủ (có tất cả thuộc tính)
    public NewPartDetail(int partDetailId, int partId, String serialNumber, 
                         String status, String location, Integer categoryId, 
                         String categoryName, int lastUpdatedBy, 
                         String username, LocalDate lastUpdatedDate) {
        this.partDetailId = partDetailId;
        this.partId = partId;
        this.serialNumber = serialNumber;
        this.status = status;
        this.location = location;
        this.categoryId = categoryId;
        this.categoryName = categoryName;
        this.lastUpdatedBy = lastUpdatedBy;
        this.username = username;
        this.lastUpdatedDate = lastUpdatedDate;
    }
    
    // Constructor không có category (dùng khi INSERT/UPDATE PartDetail)
    public NewPartDetail(int partDetailId, int partId, String serialNumber, 
                         String status, String location, int lastUpdatedBy, 
                         LocalDate lastUpdatedDate) {
        this.partDetailId = partDetailId;
        this.partId = partId;
        this.serialNumber = serialNumber;
        this.status = status;
        this.location = location;
        this.lastUpdatedBy = lastUpdatedBy;
        this.lastUpdatedDate = lastUpdatedDate;
    }
    
    // Constructor cho INSERT mới (không có partDetailId)
    public NewPartDetail(int partId, String serialNumber, String status, 
                         String location, int lastUpdatedBy, LocalDate lastUpdatedDate) {
        this.partId = partId;
        this.serialNumber = serialNumber;
        this.status = status;
        this.location = location;
        this.lastUpdatedBy = lastUpdatedBy;
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
    
    public Integer getCategoryId() {
        return categoryId;
    }
    
    public void setCategoryId(Integer categoryId) {
        this.categoryId = categoryId;
    }
    
    public String getCategoryName() {
        return categoryName;
    }
    
    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
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
                ", categoryId=" + categoryId +
                ", categoryName='" + categoryName + '\'' +
                ", lastUpdatedBy=" + lastUpdatedBy +
                ", username='" + username + '\'' +
                ", lastUpdatedDate=" + lastUpdatedDate +
                '}';
    }
}