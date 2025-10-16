package model;

import java.time.LocalDate;

/**
 * Contract model for equipment procurement related to a task.
 */
public class TechContract {
    private Long id;
    private String equipmentName;
    private Integer quantity;
    private Double unitPrice;
    private String description;
    private LocalDate date;
    private Long technicianId;
    private Long taskId;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getEquipmentName() { return equipmentName; }
    public void setEquipmentName(String equipmentName) { this.equipmentName = equipmentName; }
    public Integer getQuantity() { return quantity; }
    public void setQuantity(Integer quantity) { this.quantity = quantity; }
    public Double getUnitPrice() { return unitPrice; }
    public void setUnitPrice(Double unitPrice) { this.unitPrice = unitPrice; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public LocalDate getDate() { return date; }
    public void setDate(LocalDate date) { this.date = date; }
    public Long getTechnicianId() { return technicianId; }
    public void setTechnicianId(Long technicianId) { this.technicianId = technicianId; }
    public Long getTaskId() { return taskId; }
    public void setTaskId(Long taskId) { this.taskId = taskId; }
}


