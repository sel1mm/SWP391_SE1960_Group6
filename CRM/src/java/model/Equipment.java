package model;

import java.time.LocalDate;

/**
 * Equipment model representing equipment in the system.
 * Maps to the Equipment table in the final database schema.
 */
public class Equipment {
    private int equipmentId;
    private String serialNumber;
    private String model;
    private String description;
    private LocalDate installDate;
    private int lastUpdatedBy;
    private LocalDate lastUpdatedDate;

    // Constructors
    public Equipment() {}

    public Equipment(int equipmentId, String serialNumber, String model, 
                     String description, LocalDate installDate, 
                     int lastUpdatedBy, LocalDate lastUpdatedDate) {
        this.equipmentId = equipmentId;
        this.serialNumber = serialNumber;
        this.model = model;
        this.description = description;
        this.installDate = installDate;
        this.lastUpdatedBy = lastUpdatedBy;
        this.lastUpdatedDate = lastUpdatedDate;
    }

    // Getters and Setters
    public int getEquipmentId() { return equipmentId; }
    public void setEquipmentId(int equipmentId) { this.equipmentId = equipmentId; }

    public String getSerialNumber() { return serialNumber; }
    public void setSerialNumber(String serialNumber) { this.serialNumber = serialNumber; }

    public String getModel() { return model; }
    public void setModel(String model) { this.model = model; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public LocalDate getInstallDate() { return installDate; }
    public void setInstallDate(LocalDate installDate) { this.installDate = installDate; }

    public int getLastUpdatedBy() { return lastUpdatedBy; }
    public void setLastUpdatedBy(int lastUpdatedBy) { this.lastUpdatedBy = lastUpdatedBy; }

    public LocalDate getLastUpdatedDate() { return lastUpdatedDate; }
    public void setLastUpdatedDate(LocalDate lastUpdatedDate) { this.lastUpdatedDate = lastUpdatedDate; }

    @Override
    public String toString() {
        return "Equipment{" +
                "equipmentId=" + equipmentId +
                ", serialNumber='" + serialNumber + '\'' +
                ", model='" + model + '\'' +
                ", description='" + description + '\'' +
                ", installDate=" + installDate +
                ", lastUpdatedBy=" + lastUpdatedBy +
                ", lastUpdatedDate=" + lastUpdatedDate +
                '}';
    }
}