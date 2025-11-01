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
    private String paymentStatus; // ✅ THÊM: Pending / Completed
    
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
        this.paymentStatus = "Pending"; // ✅ Default value
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

    // ✅ NEW: Payment Status Getter/Setter
    public String getPaymentStatus() {
        return paymentStatus;
    }

    public void setPaymentStatus(String paymentStatus) {
        this.paymentStatus = paymentStatus != null ? paymentStatus : "Pending";
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

    // ✅ NEW: Helper method to get display status
    /**
     * Get display status based on business logic:
     * - "Chờ Xử Lý" = Pending + Awaiting Approval
     * - "Đang Xử Lý" = Approved + (Completed but paymentStatus = Pending)
     * - "Hoàn Thành" = Completed + paymentStatus = Completed
     * - "Đã Hủy" = Cancelled
     * - "Bị Từ Chối" = Rejected
     */
    public String getDisplayStatus() {
        if (status == null) {
            return "Unknown";
        }
        
        switch (status) {
            case "Pending":
            case "Awaiting Approval":
                return "Chờ Xử Lý";
                
            case "Approved":
                return "Đang Xử Lý";
                
            case "Completed":
                // Check payment status
                if ("Completed".equals(paymentStatus)) {
                    return "Hoàn Thành";
                } else {
                    return "Đang Xử Lý"; // Completed but not paid yet
                }
                
            case "Cancelled":
                return "Đã Hủy";
                
            case "Rejected":
                return "Bị Từ Chối";
                
            default:
                return status; // Return original if unknown
        }
    }

    @Override
    public String toString() {
        return "ServiceRequestDetailDTO{" +
                "requestId=" + requestId +
                ", contractId=" + contractId +
                ", equipmentId=" + equipmentId +
                ", status='" + status + '\'' +
                ", paymentStatus='" + paymentStatus + '\'' +
                ", equipmentModel='" + equipmentModel + '\'' +
                ", serialNumber='" + serialNumber + '\'' +
                '}';
    }

    public String getCustomerEmail() {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }

    public String getCustomerPhone() {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }
}