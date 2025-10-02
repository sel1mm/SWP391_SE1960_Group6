package model;
import java.time.LocalDate;

public class WorkTask {
    private int taskId;
    private int requestId;
    private int scheduleId;
    private int technicianId;
    private String taskType;
    private String taskDetails;
    private LocalDate startDate;
    private LocalDate endDate;
    private String status;

    public WorkTask() {
    }

    public WorkTask(int taskId, int requestId, int scheduleId, int technicianId, String taskType, String taskDetails, LocalDate startDate, LocalDate endDate, String status) {
        this.taskId = taskId;
        this.requestId = requestId;
        this.scheduleId = scheduleId;
        this.technicianId = technicianId;
        this.taskType = taskType;
        this.taskDetails = taskDetails;
        this.startDate = startDate;
        this.endDate = endDate;
        this.status = status;
    }

    public int getTaskId() {
        return taskId;
    }

    public void setTaskId(int taskId) {
        this.taskId = taskId;
    }

    public int getRequestId() {
        return requestId;
    }

    public void setRequestId(int requestId) {
        this.requestId = requestId;
    }

    public int getScheduleId() {
        return scheduleId;
    }

    public void setScheduleId(int scheduleId) {
        this.scheduleId = scheduleId;
    }

    public int getTechnicianId() {
        return technicianId;
    }

    public void setTechnicianId(int technicianId) {
        this.technicianId = technicianId;
    }

    public String getTaskType() {
        return taskType;
    }

    public void setTaskType(String taskType) {
        this.taskType = taskType;
    }

    public String getTaskDetails() {
        return taskDetails;
    }

    public void setTaskDetails(String taskDetails) {
        this.taskDetails = taskDetails;
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

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
    
    
}
