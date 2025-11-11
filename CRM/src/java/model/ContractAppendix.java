/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 *
 * @author MY PC
 */
public class ContractAppendix {

    private int appendixId;
    private int contractId;
    private String appendixType;
    private String appendixName;
    private String description;
    private LocalDate effectiveDate;
    private double totalAmount;
    private String status;
    private String fileAttachment;
    private boolean canDelete;
    private int partCount;

    public int getPartCount() {
        return partCount;
    }

    public void setPartCount(int partCount) {
        this.partCount = partCount;
    }

    public boolean isCanDelete() {
        return canDelete;
    }

    public void setCanDelete(boolean canDelete) {
        this.canDelete = canDelete;
    }

    public boolean isCanEdit() {
        return canEdit;
    }

    public void setCanEdit(boolean canEdit) {
        this.canEdit = canEdit;
    }
    private int createdBy;
    private LocalDateTime createdAt;
    private int equipmentCount;
    private boolean canEdit;

    public int getEquipmentCount() {
        return equipmentCount;
    }

    public void setEquipmentCount(int equipmentCount) {
        this.equipmentCount = equipmentCount;
    }

    public ContractAppendix() {
    }

    public ContractAppendix(int appendixId, int contractId, String appendixType, String appendixName, String description, LocalDate effectiveDate, double totalAmount, String status, String fileAttachment, int createdBy, LocalDateTime createdAt) {
        this.appendixId = appendixId;
        this.contractId = contractId;
        this.appendixType = appendixType;
        this.appendixName = appendixName;
        this.description = description;
        this.effectiveDate = effectiveDate;
        this.totalAmount = totalAmount;
        this.status = status;
        this.fileAttachment = fileAttachment;
        this.createdBy = createdBy;
        this.createdAt = createdAt;
    }

    public int getAppendixId() {
        return appendixId;
    }

    public void setAppendixId(int appendixId) {
        this.appendixId = appendixId;
    }

    public int getContractId() {
        return contractId;
    }

    public void setContractId(int contractId) {
        this.contractId = contractId;
    }

    public String getAppendixType() {
        return appendixType;
    }

    public void setAppendixType(String appendixType) {
        this.appendixType = appendixType;
    }

    public String getAppendixName() {
        return appendixName;
    }

    public void setAppendixName(String appendixName) {
        this.appendixName = appendixName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public LocalDate getEffectiveDate() {
        return effectiveDate;
    }

    public void setEffectiveDate(LocalDate effectiveDate) {
        this.effectiveDate = effectiveDate;
    }

    public double getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(double totalAmount) {
        this.totalAmount = totalAmount;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getFileAttachment() {
        return fileAttachment;
    }

    public void setFileAttachment(String fileAttachment) {
        this.fileAttachment = fileAttachment;
    }

    public int getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(int createdBy) {
        this.createdBy = createdBy;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    @Override
    public String toString() {
        return "ContractAppendix{" + "appendixId=" + appendixId + ", contractId=" + contractId + ", appendixType=" + appendixType + ", appendixName=" + appendixName + ", description=" + description + ", effectiveDate=" + effectiveDate + ", totalAmount=" + totalAmount + ", status=" + status + ", fileAttachment=" + fileAttachment + ", createdBy=" + createdBy + ", createdAt=" + createdAt + '}';
    }

}
