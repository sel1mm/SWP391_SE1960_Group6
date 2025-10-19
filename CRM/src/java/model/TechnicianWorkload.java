package model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class TechnicianWorkload {
    private int workloadId;
    private int technicianId;
    private int currentActiveTasks;
    private int maxConcurrentTasks;
    private BigDecimal averageCompletionTime;
    private LocalDateTime lastAssignedDate;
    private LocalDateTime lastUpdated;

    public TechnicianWorkload() {
    }

    public TechnicianWorkload(int workloadId, int technicianId, int currentActiveTasks, 
                             int maxConcurrentTasks, BigDecimal averageCompletionTime, 
                             LocalDateTime lastAssignedDate, LocalDateTime lastUpdated) {
        this.workloadId = workloadId;
        this.technicianId = technicianId;
        this.currentActiveTasks = currentActiveTasks;
        this.maxConcurrentTasks = maxConcurrentTasks;
        this.averageCompletionTime = averageCompletionTime;
        this.lastAssignedDate = lastAssignedDate;
        this.lastUpdated = lastUpdated;
    }

    public int getWorkloadId() {
        return workloadId;
    }

    public void setWorkloadId(int workloadId) {
        this.workloadId = workloadId;
    }

    public int getTechnicianId() {
        return technicianId;
    }

    public void setTechnicianId(int technicianId) {
        this.technicianId = technicianId;
    }

    public int getCurrentActiveTasks() {
        return currentActiveTasks;
    }

    public void setCurrentActiveTasks(int currentActiveTasks) {
        this.currentActiveTasks = currentActiveTasks;
    }

    public int getMaxConcurrentTasks() {
        return maxConcurrentTasks;
    }

    public void setMaxConcurrentTasks(int maxConcurrentTasks) {
        this.maxConcurrentTasks = maxConcurrentTasks;
    }

    public BigDecimal getAverageCompletionTime() {
        return averageCompletionTime;
    }

    public void setAverageCompletionTime(BigDecimal averageCompletionTime) {
        this.averageCompletionTime = averageCompletionTime;
    }

    public LocalDateTime getLastAssignedDate() {
        return lastAssignedDate;
    }

    public void setLastAssignedDate(LocalDateTime lastAssignedDate) {
        this.lastAssignedDate = lastAssignedDate;
    }

    public LocalDateTime getLastUpdated() {
        return lastUpdated;
    }

    public void setLastUpdated(LocalDateTime lastUpdated) {
        this.lastUpdated = lastUpdated;
    }

    // Helper method to calculate available capacity
    public int getAvailableCapacity() {
        return maxConcurrentTasks - currentActiveTasks;
    }

    // Helper method to check if technician is available
    public boolean isAvailable() {
        return currentActiveTasks < maxConcurrentTasks;
    }

    // Helper method to get availability status
    public String getAvailabilityStatus() {
        if (currentActiveTasks >= maxConcurrentTasks) {
            return "Fully Booked";
        } else if (currentActiveTasks >= (maxConcurrentTasks * 0.8)) {
            return "Nearly Full";
        } else {
            return "Available";
        }
    }
}