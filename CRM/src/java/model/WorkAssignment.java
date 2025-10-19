package model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class WorkAssignment {
    private int assignmentId;
    private int taskId;
    private int assignedBy;
    private int assignedTo;
    private LocalDateTime assignmentDate;
    private BigDecimal estimatedDuration;
    private String requiredSkills;
    private String priority;
    private boolean acceptedByTechnician;
    private LocalDateTime acceptedAt;

    public WorkAssignment() {
    }

    public WorkAssignment(int assignmentId, int taskId, int assignedBy, int assignedTo, 
                         LocalDateTime assignmentDate, BigDecimal estimatedDuration, 
                         String requiredSkills, String priority, boolean acceptedByTechnician, 
                         LocalDateTime acceptedAt) {
        this.assignmentId = assignmentId;
        this.taskId = taskId;
        this.assignedBy = assignedBy;
        this.assignedTo = assignedTo;
        this.assignmentDate = assignmentDate;
        this.estimatedDuration = estimatedDuration;
        this.requiredSkills = requiredSkills;
        this.priority = priority;
        this.acceptedByTechnician = acceptedByTechnician;
        this.acceptedAt = acceptedAt;
    }

    public int getAssignmentId() {
        return assignmentId;
    }

    public void setAssignmentId(int assignmentId) {
        this.assignmentId = assignmentId;
    }

    public int getTaskId() {
        return taskId;
    }

    public void setTaskId(int taskId) {
        this.taskId = taskId;
    }

    public int getAssignedBy() {
        return assignedBy;
    }

    public void setAssignedBy(int assignedBy) {
        this.assignedBy = assignedBy;
    }

    public int getAssignedTo() {
        return assignedTo;
    }

    public void setAssignedTo(int assignedTo) {
        this.assignedTo = assignedTo;
    }

    public LocalDateTime getAssignmentDate() {
        return assignmentDate;
    }

    public void setAssignmentDate(LocalDateTime assignmentDate) {
        this.assignmentDate = assignmentDate;
    }

    public BigDecimal getEstimatedDuration() {
        return estimatedDuration;
    }

    public void setEstimatedDuration(BigDecimal estimatedDuration) {
        this.estimatedDuration = estimatedDuration;
    }

    public String getRequiredSkills() {
        return requiredSkills;
    }

    public void setRequiredSkills(String requiredSkills) {
        this.requiredSkills = requiredSkills;
    }

    public String getPriority() {
        return priority;
    }

    public void setPriority(String priority) {
        this.priority = priority;
    }

    public boolean isAcceptedByTechnician() {
        return acceptedByTechnician;
    }

    public void setAcceptedByTechnician(boolean acceptedByTechnician) {
        this.acceptedByTechnician = acceptedByTechnician;
    }

    public LocalDateTime getAcceptedAt() {
        return acceptedAt;
    }

    public void setAcceptedAt(LocalDateTime acceptedAt) {
        this.acceptedAt = acceptedAt;
    }

    /**
     * Alias for getPriority() to maintain compatibility with JSP files
     * that reference priorityLevel property
     */
    public String getPriorityLevel() {
        return this.priority;
    }

    /**
     * Alias for setPriority() to maintain compatibility with JSP files
     * that reference priorityLevel property
     */
    public void setPriorityLevel(String priorityLevel) {
        this.priority = priorityLevel;
    }
}