package model;
import java.time.LocalDate;

public class MaintenanceSchedule {
    private int scheduleId;
    private int requestId;
    private Integer contractId;  // Changed to Integer to allow null values
    private Integer equipmentId; // Changed to Integer to allow null values
    private int assignedTo;
    private LocalDate scheduledDate;
    private String scheduleType;
    private String recurrenceRule;
    private String status;
    private int priorityId;
    private String technicianName; 
    private Integer customerId;
    private String customerName;
private String equipmentModel;
private String equipmentSerial;
private String contractDetails;
    public MaintenanceSchedule() {
    }

    public MaintenanceSchedule(int scheduleId, int requestId, Integer contractId, Integer equipmentId, int assignedTo, LocalDate scheduledDate, String scheduleType, String recurrenceRule, String status, int priorityId) {
        this.scheduleId = scheduleId;
        this.requestId = requestId;
        this.contractId = contractId;
        this.equipmentId = equipmentId;
        this.assignedTo = assignedTo;
        this.scheduledDate = scheduledDate;
        this.scheduleType = scheduleType;
        this.recurrenceRule = recurrenceRule;
        this.status = status;
        this.priorityId = priorityId;
    }

    public int getScheduleId() {
        return scheduleId;
    }

    public void setScheduleId(int scheduleId) {
        this.scheduleId = scheduleId;
    }

    public int getRequestId() {
        return requestId;
    }

    public void setRequestId(int requestId) {
        this.requestId = requestId;
    }

    public Integer getContractId() {
        return contractId;
    }

    public void setContractId(Integer contractId) {
        this.contractId = contractId;
    }

    public Integer getEquipmentId() {
        return equipmentId;
    }

    public void setEquipmentId(Integer equipmentId) {
        this.equipmentId = equipmentId;
    }

    public int getAssignedTo() {
        return assignedTo;
    }

    public void setAssignedTo(int assignedTo) {
        this.assignedTo = assignedTo;
    }

    public LocalDate getScheduledDate() {
        return scheduledDate;
    }

    public void setScheduledDate(LocalDate scheduledDate) {
        this.scheduledDate = scheduledDate;
    }

    public String getScheduleType() {
        return scheduleType;
    }

    public void setScheduleType(String scheduleType) {
        this.scheduleType = scheduleType;
    }

    public String getRecurrenceRule() {
        return recurrenceRule;
    }

    public void setRecurrenceRule(String recurrenceRule) {
        this.recurrenceRule = recurrenceRule;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public int getPriorityId() {
        return priorityId;
    }

    public void setPriorityId(int priorityId) {
        this.priorityId = priorityId;
    }
    public String getTechnicianName() {
        return technicianName;
    }
    
    public void setTechnicianName(String technicianName) {
        this.technicianName = technicianName;
    }
    public Integer getCustomerId() {
    return customerId;
}

public void setCustomerId(Integer customerId) {
    this.customerId = customerId;
}
public String getCustomerName() {
    return customerName;
}

public void setCustomerName(String customerName) {
    this.customerName = customerName;
}

public String getEquipmentModel() {
    return equipmentModel;
}

public void setEquipmentModel(String equipmentModel) {
    this.equipmentModel = equipmentModel;
}

public String getEquipmentSerial() {
    return equipmentSerial;
}

public void setEquipmentSerial(String equipmentSerial) {
    this.equipmentSerial = equipmentSerial;
}

public String getContractDetails() {
    return contractDetails;
}

public void setContractDetails(String contractDetails) {
    this.contractDetails = contractDetails;
}
}