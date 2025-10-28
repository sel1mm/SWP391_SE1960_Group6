package model;

import java.util.Date;

/**
 * Model class cho ServiceRequest
 * Mapping với bảng servicerequest trong database
 */
public class ServiceRequest {
    private int requestId;
    private int requestNumber; 
    private Integer contractId;      // ✅ ĐỔI int → Integer
    private Integer equipmentId;     // ✅ ĐỔI int → Integer
    private int createdBy;
    private String description;
    private String priorityLevel;
    private Date requestDate;
    private String status;
    private String requestType;
    private Date createdAt;
    private Date updatedAt;
    
    // New field for technician assignment
    private Integer assignedTechnicianId;
    
    // Additional display fields (not stored in DB, populated from joins)
    private String customerName;
    private String customerEmail;
    private String customerPhone;
    private String equipmentName;
    private String serialNumber;
    private String technicianName;
    
    private String contractType;

    public String getContractType() {
        return contractType;
    }

    public void setContractType(String contractType) {
        this.contractType = contractType;
    }

    public String getContractStatus() {
        return contractStatus;
    }

    public void setContractStatus(String contractStatus) {
        this.contractStatus = contractStatus;
    }

    public String getEquipmentModel() {
        return equipmentModel;
    }

    public void setEquipmentModel(String equipmentModel) {
        this.equipmentModel = equipmentModel;
    }

    public String getEquipmentDescription() {
        return equipmentDescription;
    }

    public void setEquipmentDescription(String equipmentDescription) {
        this.equipmentDescription = equipmentDescription;
    }
    private String contractStatus;
    private String equipmentModel;
    private String equipmentDescription;
    
    // Constructor mặc định
    public ServiceRequest() {
    }
    
    // Constructor đầy đủ - SỬA Integer
    public ServiceRequest(int requestId, Integer contractId, Integer equipmentId, 
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
    
    // Constructor cho việc tạo mới - SỬA Integer
    public ServiceRequest(Integer contractId, Integer equipmentId, int createdBy, 
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
    
    // Getters and Setters - SỬA Integer
    public int getRequestId() {
        return requestId;
    }
    
    public void setRequestId(int requestId) {
        this.requestId = requestId;
    }
    
    public Integer getContractId() {     // ✅ ĐỔI int → Integer
        return contractId;
    }
    
    public void setContractId(Integer contractId) {     // ✅ ĐỔI int → Integer
        this.contractId = contractId;
    }
    
    public Integer getEquipmentId() {    // ✅ ĐỔI int → Integer
        return equipmentId;
    }
    
    public void setEquipmentId(Integer equipmentId) {   // ✅ ĐỔI int → Integer
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

    public ServiceRequest(int requestNumber) {
        this.requestNumber = requestNumber;
    }

    public int getRequestNumber() {
        return requestNumber;
    }

    public void setRequestNumber(int requestNumber) {
        this.requestNumber = requestNumber;
    }
    
    
    public Integer getAssignedTechnicianId() {
        return assignedTechnicianId;
    }
    
    public void setAssignedTechnicianId(Integer assignedTechnicianId) {
        this.assignedTechnicianId = assignedTechnicianId;
    }
    
    public String getCustomerName() {
        return customerName;
    }
    
    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }
    
    public String getCustomerEmail() {
        return customerEmail;
    }
    
    public void setCustomerEmail(String customerEmail) {
        this.customerEmail = customerEmail;
    }
    
    public String getCustomerPhone() {
        return customerPhone;
    }
    
    public void setCustomerPhone(String customerPhone) {
        this.customerPhone = customerPhone;
    }
    
    public String getEquipmentName() {
        return equipmentName;
    }
    
    public void setEquipmentName(String equipmentName) {
        this.equipmentName = equipmentName;
    }
    
    public String getSerialNumber() {
        return serialNumber;
    }
    
    public void setSerialNumber(String serialNumber) {
        this.serialNumber = serialNumber;
    }
    
    public String getTechnicianName() {
        return technicianName;
    }
    
    public void setTechnicianName(String technicianName) {
        this.technicianName = technicianName;
    }
    
    // Days pending property
    private int daysPending;
    
    public int getDaysPending() {
        return daysPending;
    }
    
    public void setDaysPending(int daysPending) {
        this.daysPending = daysPending;
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
                ", assignedTechnicianId=" + assignedTechnicianId +
                ", customerName='" + customerName + '\'' +
                ", equipmentName='" + equipmentName + '\'' +
                ", serialNumber='" + serialNumber + '\'' +
                ", technicianName='" + technicianName + '\'' +
                ", daysPending=" + daysPending +
                '}';
    }
}