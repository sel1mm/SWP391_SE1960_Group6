package model;

import java.time.LocalDateTime;

/**
 * Model cho thống kê PartDetail từ lịch sử
 * @author Admin
 */
public class PartDetailStatistics {
    
    // Thông tin từ history
    private int historyId;
    private int partDetailId;
    private String oldStatus;
    private String newStatus;
    private int changedBy;
    private LocalDateTime changedDate;
    private String notes;
    
    // Thông tin join từ các bảng khác
    private String technicianName;
    private String serialNumber;
    private String partName;
    private String category;
    private String location;
    
    // Thống kê tổng hợp
    private int totalChanges;
    private int inUseCount;
    private int faultyCount;
    private int availableCount;
    private int retiredCount;

    // Constructor
    public PartDetailStatistics() {
    }

    // Getters and Setters
    public int getHistoryId() {
        return historyId;
    }

    public void setHistoryId(int historyId) {
        this.historyId = historyId;
    }

    public int getPartDetailId() {
        return partDetailId;
    }

    public void setPartDetailId(int partDetailId) {
        this.partDetailId = partDetailId;
    }

    public String getOldStatus() {
        return oldStatus;
    }

    public void setOldStatus(String oldStatus) {
        this.oldStatus = oldStatus;
    }

    public String getNewStatus() {
        return newStatus;
    }

    public void setNewStatus(String newStatus) {
        this.newStatus = newStatus;
    }

    public int getChangedBy() {
        return changedBy;
    }

    public void setChangedBy(int changedBy) {
        this.changedBy = changedBy;
    }

    public LocalDateTime getChangedDate() {
        return changedDate;
    }

    public void setChangedDate(LocalDateTime changedDate) {
        this.changedDate = changedDate;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public String getTechnicianName() {
        return technicianName;
    }

    public void setTechnicianName(String technicianName) {
        this.technicianName = technicianName;
    }

    public String getSerialNumber() {
        return serialNumber;
    }

    public void setSerialNumber(String serialNumber) {
        this.serialNumber = serialNumber;
    }

    public String getPartName() {
        return partName;
    }

    public void setPartName(String partName) {
        this.partName = partName;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public int getTotalChanges() {
        return totalChanges;
    }

    public void setTotalChanges(int totalChanges) {
        this.totalChanges = totalChanges;
    }

    public int getInUseCount() {
        return inUseCount;
    }

    public void setInUseCount(int inUseCount) {
        this.inUseCount = inUseCount;
    }

    public int getFaultyCount() {
        return faultyCount;
    }

    public void setFaultyCount(int faultyCount) {
        this.faultyCount = faultyCount;
    }

    public int getAvailableCount() {
        return availableCount;
    }

    public void setAvailableCount(int availableCount) {
        this.availableCount = availableCount;
    }

    public int getRetiredCount() {
        return retiredCount;
    }

    public void setRetiredCount(int retiredCount) {
        this.retiredCount = retiredCount;
    }

    @Override
    public String toString() {
        return "PartDetailStatistics{" +
                "historyId=" + historyId +
                ", partDetailId=" + partDetailId +
                ", oldStatus='" + oldStatus + '\'' +
                ", newStatus='" + newStatus + '\'' +
                ", technicianName='" + technicianName + '\'' +
                ", changedDate=" + changedDate +
                '}';
    }
}