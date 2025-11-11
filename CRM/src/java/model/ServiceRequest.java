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

    // ✅ NEW FIELD: Payment Status
    private String paymentStatus;    // Pending / Completed

    // New field for technician assignment
    private Integer assignedTechnicianId;
    
    // ✅ NEW FIELD: WorkTask completion status
    private boolean allWorkTasksCompleted;  // true nếu tất cả WorkTask đã completed

    // Additional display fields (not stored in DB, populated from joins)
    private String customerName;
    private String customerEmail;
    private String customerPhone;
    private String equipmentName;
    private String serialNumber;
    private String technicianName;
    private String contractType;
    private String contractStatus;
    private String equipmentModel;
    private String equipmentDescription;
    private int daysPending;

    // ==================== CONSTRUCTORS ====================
    
    /**
     * Constructor mặc định
     */
    public ServiceRequest() {
        this.paymentStatus = "Pending"; // ✅ Default value
    }

    /**
     * Constructor đầy đủ - SỬA Integer + THÊM paymentStatus
     */
    public ServiceRequest(int requestId, Integer contractId, Integer equipmentId,
            int createdBy, String description, String priorityLevel,
            Date requestDate, String status, String requestType, String paymentStatus) {
        this.requestId = requestId;
        this.contractId = contractId;
        this.equipmentId = equipmentId;
        this.createdBy = createdBy;
        this.description = description;
        this.priorityLevel = priorityLevel;
        this.requestDate = requestDate;
        this.status = status;
        this.requestType = requestType;
        this.paymentStatus = paymentStatus != null ? paymentStatus : "Pending";
    }

    /**
     * Constructor cho việc tạo mới - SỬA Integer
     */
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
        this.paymentStatus = "Pending"; // ✅ Default
    }

    /**
     * Constructor với requestNumber
     */
    public ServiceRequest(int requestNumber) {
        this.requestNumber = requestNumber;
        this.paymentStatus = "Pending"; // ✅ Default
    }

    // ==================== GETTERS AND SETTERS ====================

    public int getRequestId() {
        return requestId;
    }

    public void setRequestId(int requestId) {
        this.requestId = requestId;
    }

    public Integer getContractId() {
        return contractId;
    }

    public void setContractId(Integer contractId) {
        this.contractId = contractId;
    }

    public Integer getEquipmentId() {
        return equipmentId;
    }

    public void setEquipmentId(Integer equipmentId) {
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

    public String getPaymentStatus() {
        return paymentStatus;
    }

    public void setPaymentStatus(String paymentStatus) {
        this.paymentStatus = paymentStatus != null ? paymentStatus : "Pending";
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

    public int getDaysPending() {
        return daysPending;
    }

    public void setDaysPending(int daysPending) {
        this.daysPending = daysPending;
    }

    public boolean isAllWorkTasksCompleted() {
        return allWorkTasksCompleted;
    }

    public void setAllWorkTasksCompleted(boolean allWorkTasksCompleted) {
        this.allWorkTasksCompleted = allWorkTasksCompleted;
    }

    // ==================== BUSINESS LOGIC METHODS ====================

    /**
     * ✅ UPDATED: Get display status based on business logic
     * 
     * LOGIC:
     * - Phân biệt đơn Equipment (Service/Warranty) vs Account (InformationUpdate)
     * - Equipment Completed CHỈ cần check WorkTask status (không check paymentStatus)
     * - Account Completed = Hoàn Thành luôn
     * 
     * Lý do không check paymentStatus:
     * - WorkTask chỉ được tạo KHI người dùng đã thanh toán
     * - Nếu từ chối hết thanh toán → Không có WorkTask → allWorkTasksCompleted = true → Hoàn Thành
     * - Nếu có thanh toán → Có WorkTask → Chờ WorkTask completed → Hoàn Thành
     * 
     * Mapping:
     * - Pending → "Chờ Xác Nhận"
     * - Awaiting Approval → "Chờ Xử Lý"
     * - Approved → "Đang Xử Lý"
     * - Completed + Equipment + WorkTask chưa hết Completed → "Đang Xử Lý"
     * - Completed + Equipment + WorkTask đã hết Completed → "Hoàn Thành"
     * - Completed + Account → "Hoàn Thành"
     * - Cancelled → "Đã Hủy"
     * - Rejected → "Bị Từ Chối"
     */
    public String getDisplayStatus() {
        // 1. Nếu đã hủy hoặc bị từ chối → hiển thị ngay
        if ("Cancelled".equals(this.status)) {
            return "Đã Hủy";
        }
        if ("Rejected".equals(this.status)) {
            return "Bị Từ Chối";
        }

        // 2. ✅ TÁCH RIÊNG: Pending vs Awaiting Approval
        if ("Pending".equals(this.status)) {
            return "Chờ Xác Nhận";  // Pending = Chờ xác nhận
        }

        if ("Awaiting Approval".equals(this.status)) {
            return "Chờ Xử Lý";  // Awaiting Approval = Chờ xử lý
        }

        // 3. Nếu đã Approved → Đang Xử Lý
        if ("Approved".equals(this.status)) {
            return "Đang Xử Lý";
        }

        // 4. ✅ NẾU COMPLETED - PHÂN BIỆT THEO REQUEST TYPE
        if ("Completed".equals(this.status)) {
            // ✅ Nếu là đơn Account (InformationUpdate) → Hoàn Thành luôn
            if ("InformationUpdate".equals(this.requestType)) {
                return "Hoàn Thành";
            }
            
            // ✅ Nếu là đơn Equipment (Service/Warranty) → CHỈ check WorkTask
            if ("Service".equals(this.requestType) || "Warranty".equals(this.requestType)) {
                // ✅ KIỂM TRA WORKTASK: Nếu chưa hết completed → vẫn "Đang Xử Lý"
                if (!this.allWorkTasksCompleted) {
                    return "Đang Xử Lý";  // Còn WorkTask chưa hoàn thành
                }
                
                // ✅ Tất cả WorkTask đã completed (hoặc không có WorkTask) → Hoàn Thành
                return "Hoàn Thành";
            }
            
            // Fallback: nếu không xác định được requestType
            // Mặc định check WorkTask như Equipment
            if (!this.allWorkTasksCompleted) {
                return "Đang Xử Lý";
            }
            return "Hoàn Thành";
        }

        // 5. Fallback cho các trường hợp khác
        return this.status;
    }

    /**
     * ✅ HELPER: Check if this is an Equipment request
     */
    public boolean isEquipmentRequest() {
        return "Service".equals(this.requestType) || "Warranty".equals(this.requestType);
    }

    /**
     * ✅ HELPER: Check if this is an Account request
     */
    public boolean isAccountRequest() {
        return "InformationUpdate".equals(this.requestType);
    }

    /**
     * ✅ HELPER: Check if payment is required for this request
     */
    public boolean requiresPayment() {
        return isEquipmentRequest() && "Completed".equals(this.status);
    }

    /**
     * ✅ HELPER: Check if payment can be made (Completed but not paid)
     */
    public boolean canMakePayment() {
        return isEquipmentRequest() 
                && "Completed".equals(this.status) 
                && !"Completed".equals(this.paymentStatus);
    }

    // ==================== OVERRIDE METHODS ====================

    @Override
    public String toString() {
        return "ServiceRequest{"
                + "requestId=" + requestId
                + ", contractId=" + contractId
                + ", equipmentId=" + equipmentId
                + ", createdBy=" + createdBy
                + ", description='" + description + '\''
                + ", priorityLevel='" + priorityLevel + '\''
                + ", requestDate=" + requestDate
                + ", status='" + status + '\''
                + ", requestType='" + requestType + '\''
                + ", paymentStatus='" + paymentStatus + '\''
                + ", createdAt=" + createdAt
                + ", updatedAt=" + updatedAt
                + ", assignedTechnicianId=" + assignedTechnicianId
                + ", customerName='" + customerName + '\''
                + ", equipmentName='" + equipmentName + '\''
                + ", serialNumber='" + serialNumber + '\''
                + ", technicianName='" + technicianName + '\''
                + ", daysPending=" + daysPending
                + ", displayStatus='" + getDisplayStatus() + '\''
                + '}';
    }
}