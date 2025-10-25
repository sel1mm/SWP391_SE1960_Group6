package model;

import java.time.LocalDate;

/**
 * Equipment model with inventory status information.
 * Extends Equipment to include status and location from PartDetail.
 */
public class EquipmentWithStatus extends Equipment {
    private String status;
    private String location;
    private double unitPrice;

    public EquipmentWithStatus() {
        super();
    }

    public EquipmentWithStatus(int equipmentId, String serialNumber, String model, 
                              String description, LocalDate installDate, 
                              int lastUpdatedBy, LocalDate lastUpdatedDate,
                              String status, String location, double unitPrice) {
        super(equipmentId, serialNumber, model, description, installDate, lastUpdatedBy, lastUpdatedDate);
        this.status = status;
        this.location = location;
        this.unitPrice = unitPrice;
    }

    // Getters and Setters
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }

    public double getUnitPrice() { return unitPrice; }
    public void setUnitPrice(double unitPrice) { this.unitPrice = unitPrice; }

    @Override
    public String toString() {
        return "EquipmentWithStatus{" +
                "equipmentId=" + getEquipmentId() +
                ", serialNumber='" + getSerialNumber() + '\'' +
                ", model='" + getModel() + '\'' +
                ", description='" + getDescription() + '\'' +
                ", installDate=" + getInstallDate() +
                ", lastUpdatedBy=" + getLastUpdatedBy() +
                ", lastUpdatedDate=" + getLastUpdatedDate() +
                ", status='" + status + '\'' +
                ", location='" + location + '\'' +
                ", unitPrice=" + unitPrice +
                '}';
    }
}
