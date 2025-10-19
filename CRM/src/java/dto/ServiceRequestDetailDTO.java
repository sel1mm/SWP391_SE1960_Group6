package dto;

import model.*;
import java.time.LocalDate;
import java.util.Date;

/**
 * DTO chứa thông tin đầy đủ để hiển thị Service Request
 * (Kết hợp từ ServiceRequest + Contract + Equipment)
 */
public class ServiceRequestDetailDTO {
    // Thông tin từ ServiceRequest
    private int requestId;
    private int contractId;
    private int equipmentId;
    private int createdBy;
    private String description;
    private String priorityLevel;
    private Date requestDate; // Giữ Date vì ServiceRequest dùng Date
    private String status;
    private String requestType;
    
    // Thông tin từ Contract
    private String contractType;
    private String contractStatus;
    private LocalDate contractDate; // Contract dùng LocalDate
    
    // Thông tin từ Equipment
    private String serialNumber;
    private String equipmentModel;
    private String equipmentDescription;
    private LocalDate installDate; // Equipment dùng LocalDate
    
    // Thông tin Customer
    private String customerName;
    
    // Constructor mặc định
    public ServiceRequestDetailDTO() {
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

    public LocalDate getContractDate() {
        return contractDate;
    }

    public void setContractDate(LocalDate contractDate) {
        this.contractDate = contractDate;
    }

    public String getSerialNumber() {
        return serialNumber;
    }

    public void setSerialNumber(String serialNumber) {
        this.serialNumber = serialNumber;
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

    public LocalDate getInstallDate() {
        return installDate;
    }

    public void setInstallDate(LocalDate installDate) {
        this.installDate = installDate;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    @Override
    public String toString() {
        return "ServiceRequestDetailDTO{" +
                "requestId=" + requestId +
                ", contractId=" + contractId +
                ", equipmentId=" + equipmentId +
                ", status='" + status + '\'' +
                ", equipmentModel='" + equipmentModel + '\'' +
                ", serialNumber='" + serialNumber + '\'' +
                '}';
    }
}