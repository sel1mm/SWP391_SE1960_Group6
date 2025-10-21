package model;

import java.time.LocalDate;

/**
 * WorkTask model representing work assigned to a technician.
 * Maps to the WorkTask table in the final database schema.
 */
public class WorkTask {
    private int taskId;
    private Integer requestId;
    private Integer scheduleId;
    private int technicianId;
    private String taskType;
    private String taskDetails;
    private LocalDate startDate;
    private LocalDate endDate;
    private String status;

    // Constructors
    public WorkTask() {}

    public WorkTask(int taskId, Integer requestId, Integer scheduleId, int technicianId, 
                   String taskType, String taskDetails, LocalDate startDate, 
                   LocalDate endDate, String status) {
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

    // Getters and Setters
    public int getTaskId() { return taskId; }
    public void setTaskId(int taskId) { this.taskId = taskId; }

    public Integer getRequestId() { return requestId; }
    public void setRequestId(Integer requestId) { this.requestId = requestId; }

    public Integer getScheduleId() { return scheduleId; }
    public void setScheduleId(Integer scheduleId) { this.scheduleId = scheduleId; }

    public int getTechnicianId() { return technicianId; }
    public void setTechnicianId(int technicianId) { this.technicianId = technicianId; }

    public String getTaskType() { return taskType; }
    public void setTaskType(String taskType) { this.taskType = taskType; }

    public String getTaskDetails() { return taskDetails; }
    public void setTaskDetails(String taskDetails) { this.taskDetails = taskDetails; }

    public LocalDate getStartDate() { return startDate; }
    public void setStartDate(LocalDate startDate) { this.startDate = startDate; }

    public LocalDate getEndDate() { return endDate; }
    public void setEndDate(LocalDate endDate) { this.endDate = endDate; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    @Override
    public String toString() {
        return "WorkTask{" +
                "taskId=" + taskId +
                ", requestId=" + requestId +
                ", scheduleId=" + scheduleId +
                ", technicianId=" + technicianId +
                ", taskType='" + taskType + '\'' +
                ", taskDetails='" + taskDetails + '\'' +
                ", startDate=" + startDate +
                ", endDate=" + endDate +
                ", status='" + status + '\'' +
                '}';
    }
}