package model;

import java.time.LocalDate;

/**
 * Equipment model representing equipment in the system.
 * Maps to the Equipment table in the final database schema.
 * Includes category and user information via JOIN.
 */
public class Equipment {
    private int equipmentId;
    private String serialNumber;
    private String model;
    private String description;
    private LocalDate installDate;
    
    // Category information
    private Integer categoryId; // NULL-able
    private String categoryName; // JOIN với Category
    
    private int lastUpdatedBy;
    private LocalDate lastUpdatedDate;
    
    // JOIN field
    private String username; // JOIN với Account
    
    // Constructors
    public Equipment() {}
    
    // Constructor cơ bản (cho INSERT/UPDATE)
    public Equipment(int equipmentId, String serialNumber, String model, 
                     String description, LocalDate installDate, Integer categoryId,
                     int lastUpdatedBy, LocalDate lastUpdatedDate) {
        this.equipmentId = equipmentId;
        this.serialNumber = serialNumber;
        this.model = model;
        this.description = description;
        this.installDate = installDate;
        this.categoryId = categoryId;
        this.lastUpdatedBy = lastUpdatedBy;
        this.lastUpdatedDate = lastUpdatedDate;
    }
    
    // Constructor đầy đủ (cho SELECT với JOIN)
    public Equipment(int equipmentId, String serialNumber, String model, 
                     String description, LocalDate installDate, 
                     Integer categoryId, String categoryName,
                     int lastUpdatedBy, LocalDate lastUpdatedDate, String username) {
        this.equipmentId = equipmentId;
        this.serialNumber = serialNumber;
        this.model = model;
        this.description = description;
        this.installDate = installDate;
        this.categoryId = categoryId;
        this.categoryName = categoryName;
        this.lastUpdatedBy = lastUpdatedBy;
        this.lastUpdatedDate = lastUpdatedDate;
        this.username = username;
    }
    
    // Constructor cho INSERT mới (không có equipmentId)
    public Equipment(String serialNumber, String model, String description, 
                     LocalDate installDate, Integer categoryId,
                     int lastUpdatedBy, LocalDate lastUpdatedDate) {
        this.serialNumber = serialNumber;
        this.model = model;
        this.description = description;
        this.installDate = installDate;
        this.categoryId = categoryId;
        this.lastUpdatedBy = lastUpdatedBy;
        this.lastUpdatedDate = lastUpdatedDate;
    }
    
    // Getters and Setters
    public int getEquipmentId() { 
        return equipmentId; 
    }
    
    public void setEquipmentId(int equipmentId) { 
        this.equipmentId = equipmentId; 
    }
    
    public String getSerialNumber() { 
        return serialNumber; 
    }
    
    public void setSerialNumber(String serialNumber) { 
        this.serialNumber = serialNumber; 
    }
    
    public String getModel() { 
        return model; 
    }
    
    public void setModel(String model) { 
        this.model = model; 
    }
    
    public String getDescription() { 
        return description; 
    }
    
    public void setDescription(String description) { 
        this.description = description; 
    }
    
    public LocalDate getInstallDate() { 
        return installDate; 
    }
    
    public void setInstallDate(LocalDate installDate) { 
        this.installDate = installDate; 
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
    
    public LocalDate getLastUpdatedDate() { 
        return lastUpdatedDate; 
    }
    
    public void setLastUpdatedDate(LocalDate lastUpdatedDate) { 
        this.lastUpdatedDate = lastUpdatedDate; 
    }
    
    public String getUsername() { 
        return username; 
    }
    
    public void setUsername(String username) { 
        this.username = username; 
    }
    
    @Override
    public String toString() {
        return "Equipment{" +
                "equipmentId=" + equipmentId +
                ", serialNumber='" + serialNumber + '\'' +
                ", model='" + model + '\'' +
                ", description='" + description + '\'' +
                ", installDate=" + installDate +
                ", categoryId=" + categoryId +
                ", categoryName='" + categoryName + '\'' +
                ", lastUpdatedBy=" + lastUpdatedBy +
                ", lastUpdatedDate=" + lastUpdatedDate +
                ", username='" + username + '\'' +
                '}';
    }
}