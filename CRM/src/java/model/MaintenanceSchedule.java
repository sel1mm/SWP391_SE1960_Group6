package model;
import java.time.LocalDate;

public class MaintenanceSchedule {
    private int scheduleId;
    private int requestId;
    private int contracId;
    private int equipmentId;
    private int assignedTo;
    private LocalDate scheduledDate;
    private String scheduleType;
    private String recurrenceRule;
    private String status;
    private int priorityId;

    public MaintenanceSchedule() {
    }

    public MaintenanceSchedule(int scheduleId, int requestId, int contracId, int equipmentId, int assignedTo, LocalDate scheduledDate, String scheduleType, String recurrenceRule, String status, int priorityId) {
        this.scheduleId = scheduleId;
        this.requestId = requestId;
        this.contracId = contracId;
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

    public int getContracId() {
        return contracId;
    }

    public void setContracId(int contracId) {
        this.contracId = contracId;
    }

    public int getEquipmentId() {
        return equipmentId;
    }

    public void setEquipmentId(int equipmentId) {
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
    
    
}
