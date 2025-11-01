package model;

import java.time.LocalDate;

/**
 * NewPart - Model cho bảng Part với Quantity
 * @author Admin
 */
public class NewPart {
    private int partId;
    private String partName;
    private String description;
    private double unitPrice;
    private int quantity; // Tổng số lượng đếm từ PartDetail
    private int lastUpdatedBy;
    private LocalDate lastUpdatedDate;
    private String userName; // JOIN với Account

    // Constructor mặc định
    public NewPart() {
    }

    // Constructor đầy đủ (có quantity)
    public NewPart(int partId, String partName, String description, double unitPrice, 
                   int quantity, int lastUpdatedBy, LocalDate lastUpdatedDate, String userName) {
        this.partId = partId;
        this.partName = partName;
        this.description = description;
        this.unitPrice = unitPrice;
        this.quantity = quantity;
        this.lastUpdatedBy = lastUpdatedBy;
        this.lastUpdatedDate = lastUpdatedDate;
        this.userName = userName;
    }

    // Constructor không có quantity (dùng khi thêm mới Part)
    public NewPart(String partName, String description, double unitPrice, 
                   int lastUpdatedBy, LocalDate lastUpdatedDate) {
        this.partName = partName;
        this.description = description;
        this.unitPrice = unitPrice;
        this.lastUpdatedBy = lastUpdatedBy;
        this.lastUpdatedDate = lastUpdatedDate;
        this.quantity = 0; // Mặc định = 0 khi tạo mới
    }

    // Getters and Setters
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

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
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
        return "NewPart{" +
                "partId=" + partId +
                ", partName='" + partName + '\'' +
                ", description='" + description + '\'' +
                ", unitPrice=" + unitPrice +
                ", quantity=" + quantity +
                ", lastUpdatedBy=" + lastUpdatedBy +
                ", lastUpdatedDate=" + lastUpdatedDate +
                ", userName='" + userName + '\'' +
                '}';
    }
}