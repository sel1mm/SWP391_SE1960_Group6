package model;

import java.time.LocalDateTime;
import java.time.LocalDate;

public class MaintenanceHistory {

    // Task info
    private int id;
    private String taskType; // Request / Scheduled
    private String status; // Completed / In Progress / Assigned / Failed
    private String taskDetails;
    private LocalDateTime startDate;
    private LocalDateTime endDate;

    // Technician info
    private int technicianId;
    private String technicianName;
    private String technicianEmail;
    private String technicianPhone;

    // Schedule info
    private int scheduleId;
    private LocalDateTime scheduledDate;
    private String scheduleType; // Periodic / Request
    private String scheduleStatus;
    private String recurrenceRule;

    // Priority info
    private String priorityLevel; // Normal / High / Urgent

    // Equipment info
    private int equipmentId;
    private String serialNumber;
    private String model;
    private String equipmentDescription;
    private LocalDate installDate;
    private String equipmentCategory;

    // Contract info
    private Integer contractId;
    private String contractType;
    private String customerName;

    // Legacy fields for backward compatibility
    private LocalDateTime maintenanceDateTime;
    private String maintenanceType;

    // Constructors
    public MaintenanceHistory() {
    }

    public MaintenanceHistory(int id, String technicianName, LocalDateTime maintenanceDateTime,
            String maintenanceType, String priorityLevel, String taskType,
            String status, String taskDetails) {
        this.id = id;
        this.technicianName = technicianName;
        this.maintenanceDateTime = maintenanceDateTime;
        this.maintenanceType = maintenanceType;
        this.priorityLevel = priorityLevel;
        this.taskType = taskType;
        this.status = status;
        this.taskDetails = taskDetails;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getTechnicianName() {
        return technicianName;
    }

    public void setTechnicianName(String technicianName) {
        this.technicianName = technicianName;
    }

    public LocalDateTime getMaintenanceDateTime() {
        return maintenanceDateTime;
    }

    public void setMaintenanceDateTime(LocalDateTime maintenanceDateTime) {
        this.maintenanceDateTime = maintenanceDateTime;
    }

    public String getMaintenanceType() {
        return maintenanceType;
    }

    public void setMaintenanceType(String maintenanceType) {
        this.maintenanceType = maintenanceType;
    }

    public String getPriorityLevel() {
        return priorityLevel;
    }

    public void setPriorityLevel(String priorityLevel) {
        this.priorityLevel = priorityLevel;
    }

    public String getTaskType() {
        return taskType;
    }

    public void setTaskType(String taskType) {
        this.taskType = taskType;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getTaskDetails() {
        return taskDetails;
    }

    public void setTaskDetails(String taskDetails) {
        this.taskDetails = taskDetails;
    }

    // New getters and setters
    public LocalDateTime getStartDate() {
        return startDate;
    }

    public void setStartDate(LocalDateTime startDate) {
        this.startDate = startDate;
    }

    public LocalDateTime getEndDate() {
        return endDate;
    }

    public void setEndDate(LocalDateTime endDate) {
        this.endDate = endDate;
    }

    public int getTechnicianId() {
        return technicianId;
    }

    public void setTechnicianId(int technicianId) {
        this.technicianId = technicianId;
    }

    public String getTechnicianEmail() {
        return technicianEmail;
    }

    public void setTechnicianEmail(String technicianEmail) {
        this.technicianEmail = technicianEmail;
    }

    public String getTechnicianPhone() {
        return technicianPhone;
    }

    public void setTechnicianPhone(String technicianPhone) {
        this.technicianPhone = technicianPhone;
    }

    public int getScheduleId() {
        return scheduleId;
    }

    public void setScheduleId(int scheduleId) {
        this.scheduleId = scheduleId;
    }

    public LocalDateTime getScheduledDate() {
        return scheduledDate;
    }

    public void setScheduledDate(LocalDateTime scheduledDate) {
        this.scheduledDate = scheduledDate;
    }

    public String getScheduleType() {
        return scheduleType;
    }

    public void setScheduleType(String scheduleType) {
        this.scheduleType = scheduleType;
    }

    public String getScheduleStatus() {
        return scheduleStatus;
    }

    public void setScheduleStatus(String scheduleStatus) {
        this.scheduleStatus = scheduleStatus;
    }

    public String getRecurrenceRule() {
        return recurrenceRule;
    }

    public void setRecurrenceRule(String recurrenceRule) {
        this.recurrenceRule = recurrenceRule;
    }

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

    public String getEquipmentDescription() {
        return equipmentDescription;
    }

    public void setEquipmentDescription(String equipmentDescription) {
        this.equipmentDescription = equipmentDescription;
    }

    public LocalDate getInstallDate() {
        return installDate;
    }

    public void setInstallDate(LocalDate installDate) {
        this.installDate = installDate;
    }

    public String getEquipmentCategory() {
        return equipmentCategory;
    }

    public void setEquipmentCategory(String equipmentCategory) {
        this.equipmentCategory = equipmentCategory;
    }

    public Integer getContractId() {
        return contractId;
    }

    public void setContractId(Integer contractId) {
        this.contractId = contractId;
    }

    public String getContractType() {
        return contractType;
    }

    public void setContractType(String contractType) {
        this.contractType = contractType;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

// Thêm @Override toString() để debug dễ hơn
    @Override
    public String toString() {
        return "MaintenanceHistory{"
                + "id=" + id
                + ", technicianName='" + technicianName + '\''
                + ", maintenanceDateTime=" + maintenanceDateTime
                + ", maintenanceType='" + maintenanceType + '\''
                + ", priorityLevel='" + priorityLevel + '\''
                + ", taskType='" + taskType + '\''
                + ", status='" + status + '\''
                + ", equipmentCategory='" + equipmentCategory + '\''
                + '}';
    }
}
