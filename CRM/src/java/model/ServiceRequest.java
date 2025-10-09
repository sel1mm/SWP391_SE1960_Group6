package model;

import java.util.Date;

/**
 * Model class cho ServiceRequest
 * Mapping với bảng servicerequest trong database
 */
public class ServiceRequest {
    private int requestId;
    private int contractId;
    private int equipmentId;
    private int createdBy;
    private String description;
    private String priorityLevel;
    private Date requestDate;
    private String status;
    private String requestType;
    private Date createdAt;
    private Date updatedAt;
    
    // Constructor mặc định
    public ServiceRequest() {
    }
    
    // Constructor đầy đủ
    public ServiceRequest(int requestId, int contractId, int equipmentId, 
                         int createdBy, String description, String priorityLevel, 
                         Date requestDate, String status, String requestType) {
        this.requestId = requestId;
        this.contractId = contractId;
        this.equipmentId = equipmentId;
        this.createdBy = createdBy;
        this.description = description;
        this.priorityLevel = priorityLevel;
        this.requestDate = requestDate;
        this.status = status;
        this.requestType = requestType;
    }
    
    // Constructor cho việc tạo mới (không có requestId)
    public ServiceRequest(int contractId, int equipmentId, int createdBy, 
                         String description, String priorityLevel, 
                         Date requestDate, String status, String requestType) {
        this.contractId = contractId;
        this.equipmentId = equipmentId;
        this.createdBy = createdBy;
        this.description = description;
        this.priorityLevel = priorityLevel;
        this.requestDate = requestDate;
        this.status = status;
        this.requestType = requestType;
    }
    
    // Getters and Setters
    public int getRequestId() {
        return requestId;
    }
    
    public void setRequestId(int requestId) {
        this.requestId = requestId;
    }
    
    public int getContractId() {
        return contractId;
    }
    
    public void setContractId(int contractId) {
        this.contractId = contractId;
    }
    
    public int getEquipmentId() {
        return equipmentId;
    }
    
    public void setEquipmentId(int equipmentId) {
        this.equipmentId = equipmentId;
    }
    
    public int getCreatedBy() {
        return createdBy;
    }
    
    public void setCreatedBy(int createdBy) {
        this.createdBy = createdBy;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public String getPriorityLevel() {
        return priorityLevel;
    }
    
    public void setPriorityLevel(String priorityLevel) {
        this.priorityLevel = priorityLevel;
    }
    
    public Date getRequestDate() {
        return requestDate;
    }
    
    public void setRequestDate(Date requestDate) {
        this.requestDate = requestDate;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public String getRequestType() {
        return requestType;
    }
    
    public void setRequestType(String requestType) {
        this.requestType = requestType;
    }
    
    public Date getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }
    
    public Date getUpdatedAt() {
        return updatedAt;
    }
    
    public void setUpdatedAt(Date updatedAt) {
        this.updatedAt = updatedAt;
    }
    
    @Override
    public String toString() {
        return "ServiceRequest{" +
                "requestId=" + requestId +
                ", contractId=" + contractId +
                ", equipmentId=" + equipmentId +
                ", createdBy=" + createdBy +
                ", description='" + description + '\'' +
                ", priorityLevel='" + priorityLevel + '\'' +
                ", requestDate=" + requestDate +
                ", status='" + status + '\'' +
                ", requestType='" + requestType + '\'' +
                ", createdAt=" + createdAt +
                ", updatedAt=" + updatedAt +
                '}';
    }
}