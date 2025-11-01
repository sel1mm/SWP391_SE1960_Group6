package model;

import java.sql.Timestamp;

/**
 * Model class cho bảng PartDetailStatusHistory
 */
public class PartDetailHistory {
    private int historyId;
    private int partDetailId;
    private String oldStatus;
    private String newStatus;
    private int changedBy;
    private Timestamp changedDate;
    private String notes;
    
    // JOIN fields
    private String username;
    private String serialNumber;
    private String location;
    private String partName;
    
    // Overview fields
    private int totalCount;
    private int addedCount;
    private int changedCount;

    // Constructors
    public PartDetailHistory() {
    }

    public PartDetailHistory(int historyId, int partDetailId, String oldStatus, String newStatus, 
                            int changedBy, Timestamp changedDate, String notes) {
        this.historyId = historyId;
        this.partDetailId = partDetailId;
        this.oldStatus = oldStatus;
        this.newStatus = newStatus;
        this.changedBy = changedBy;
        this.changedDate = changedDate;
        this.notes = notes;
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

    public Timestamp getChangedDate() {
        return changedDate;
    }

    public void setChangedDate(Timestamp changedDate) {
        this.changedDate = changedDate;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getSerialNumber() {
        return serialNumber;
    }

    public void setSerialNumber(String serialNumber) {
        this.serialNumber = serialNumber;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public String getPartName() {
        return partName;
    }

    public void setPartName(String partName) {
        this.partName = partName;
    }

    public int getTotalCount() {
        return totalCount;
    }

    public void setTotalCount(int totalCount) {
        this.totalCount = totalCount;
    }

    public int getAddedCount() {
        return addedCount;
    }

    public void setAddedCount(int addedCount) {
        this.addedCount = addedCount;
    }

    public int getChangedCount() {
        return changedCount;
    }

    public void setChangedCount(int changedCount) {
        this.changedCount = changedCount;
    }

    @Override
    public String toString() {
        return "PartDetailHistory{" +
                "historyId=" + historyId +
                ", partDetailId=" + partDetailId +
                ", oldStatus='" + oldStatus + '\'' +
                ", newStatus='" + newStatus + '\'' +
                ", changedBy=" + changedBy +
                ", changedDate=" + changedDate +
                ", notes='" + notes + '\'' +
                ", username='" + username + '\'' +
                ", serialNumber='" + serialNumber + '\'' +
                ", partName='" + partName + '\'' +
                '}';
    }
}