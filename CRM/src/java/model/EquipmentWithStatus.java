package model;

import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * Equipment model with inventory status information.
 * Extends Equipment to include status, location, and contract information.
 * Includes category and user information via JOIN.
 */
public class EquipmentWithStatus extends Equipment {
    private String status;
    private String location;
    private double unitPrice;
    
    // Contract information (ContractEquipment)
    private LocalDate startDate;    // ngày bắt đầu trong hợp đồng
    private LocalDate endDate;      // ngày kết thúc trong hợp đồng
    private BigDecimal price;       // giá thiết bị trong hợp đồng
    
    // Constructors
    public EquipmentWithStatus() {
        super();
    }
    
    // Constructor cơ bản (không có category và username)
    public EquipmentWithStatus(int equipmentId, String serialNumber, String model, 
                              String description, LocalDate installDate, 
                              int lastUpdatedBy, LocalDate lastUpdatedDate,
                              String status, String location, double unitPrice) {
        super(equipmentId, serialNumber, model, description, installDate, null, lastUpdatedBy, lastUpdatedDate);
        this.status = status;
        this.location = location;
        this.unitPrice = unitPrice;
    }
    
    // Constructor đầy đủ (có category và username)
    public EquipmentWithStatus(int equipmentId, String serialNumber, String model, 
                              String description, LocalDate installDate,
                              Integer categoryId, String categoryName,
                              int lastUpdatedBy, LocalDate lastUpdatedDate, String username,
                              String status, String location, double unitPrice) {
        super(equipmentId, serialNumber, model, description, installDate, 
              categoryId, categoryName, lastUpdatedBy, lastUpdatedDate, username);
        this.status = status;
        this.location = location;
        this.unitPrice = unitPrice;
    }
    
    // Constructor đầy đủ với contract info
    public EquipmentWithStatus(int equipmentId, String serialNumber, String model, 
                              String description, LocalDate installDate,
                              Integer categoryId, String categoryName,
                              int lastUpdatedBy, LocalDate lastUpdatedDate, String username,
                              String status, String location, double unitPrice,
                              LocalDate startDate, LocalDate endDate, BigDecimal price) {
        super(equipmentId, serialNumber, model, description, installDate, 
              categoryId, categoryName, lastUpdatedBy, lastUpdatedDate, username);
        this.status = status;
        this.location = location;
        this.unitPrice = unitPrice;
        this.startDate = startDate;
        this.endDate = endDate;
        this.price = price;
    }
    
    // Getters and Setters
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
    
    public double getUnitPrice() { 
        return unitPrice; 
    }
    
    public void setUnitPrice(double unitPrice) { 
        this.unitPrice = unitPrice; 
    }
    
    public LocalDate getStartDate() {
        return startDate;
    }
    
    public void setStartDate(LocalDate startDate) {
        this.startDate = startDate;
    }
    
    public LocalDate getEndDate() {
        return endDate;
    }
    
    public void setEndDate(LocalDate endDate) {
        this.endDate = endDate;
    }
    
    public BigDecimal getPrice() {
        return price;
    }
    
    public void setPrice(BigDecimal price) {
        this.price = price;
    }
    
    @Override
    public String toString() {
        return "EquipmentWithStatus{" +
                "equipmentId=" + getEquipmentId() +
                ", serialNumber='" + getSerialNumber() + '\'' +
                ", model='" + getModel() + '\'' +
                ", description='" + getDescription() + '\'' +
                ", installDate=" + getInstallDate() +
                ", categoryId=" + getCategoryId() +
                ", categoryName='" + getCategoryName() + '\'' +
                ", lastUpdatedBy=" + getLastUpdatedBy() +
                ", lastUpdatedDate=" + getLastUpdatedDate() +
                ", username='" + getUsername() + '\'' +
                ", status='" + status + '\'' +
                ", location='" + location + '\'' +
                ", unitPrice=" + unitPrice +
                ", startDate=" + startDate +
                ", endDate=" + endDate +
                ", price=" + price +
                '}';
    }
}