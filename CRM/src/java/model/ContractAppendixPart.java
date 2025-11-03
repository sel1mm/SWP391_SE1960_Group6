/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 *
 * @author MY PC
 */
public class ContractAppendixPart {
    private int appendixPartId;
    private int appendixId;
    private int equipmentId;
    private int partId;
    private int quantity;
    private BigDecimal unitPrice;
    private BigDecimal totalPrice;
    private int repairReportId;
    private String paymentStatus;
    private Boolean approvedByCustomer;
    private LocalDateTime approvalDate;
    private String note;

    public ContractAppendixPart() {
    }

    public ContractAppendixPart(int appendixPartId, int appendixId, int equipmentId, int partId, int quantity, BigDecimal unitPrice, BigDecimal totalPrice, int repairReportId, String paymentStatus, Boolean approvedByCustomer, LocalDateTime approvalDate, String note) {
        this.appendixPartId = appendixPartId;
        this.appendixId = appendixId;
        this.equipmentId = equipmentId;
        this.partId = partId;
        this.quantity = quantity;
        this.unitPrice = unitPrice;
        this.totalPrice = totalPrice;
        this.repairReportId = repairReportId;
        this.paymentStatus = paymentStatus;
        this.approvedByCustomer = approvedByCustomer;
        this.approvalDate = approvalDate;
        this.note = note;
    }

    public int getAppendixPartId() {
        return appendixPartId;
    }

    public void setAppendixPartId(int appendixPartId) {
        this.appendixPartId = appendixPartId;
    }

    public int getAppendixId() {
        return appendixId;
    }

    public void setAppendixId(int appendixId) {
        this.appendixId = appendixId;
    }

    public int getEquipmentId() {
        return equipmentId;
    }

    public void setEquipmentId(int equipmentId) {
        this.equipmentId = equipmentId;
    }

    public int getPartId() {
        return partId;
    }

    public void setPartId(int partId) {
        this.partId = partId;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public BigDecimal getUnitPrice() {
        return unitPrice;
    }

    public void setUnitPrice(BigDecimal unitPrice) {
        this.unitPrice = unitPrice;
    }

    public BigDecimal getTotalPrice() {
        return totalPrice;
    }

    public void setTotalPrice(BigDecimal totalPrice) {
        this.totalPrice = totalPrice;
    }

    public int getRepairReportId() {
        return repairReportId;
    }

    public void setRepairReportId(int repairReportId) {
        this.repairReportId = repairReportId;
    }

    public String getPaymentStatus() {
        return paymentStatus;
    }

    public void setPaymentStatus(String paymentStatus) {
        this.paymentStatus = paymentStatus;
    }

    public Boolean getApprovedByCustomer() {
        return approvedByCustomer;
    }

    public void setApprovedByCustomer(Boolean approvedByCustomer) {
        this.approvedByCustomer = approvedByCustomer;
    }

    public LocalDateTime getApprovalDate() {
        return approvalDate;
    }

    public void setApprovalDate(LocalDateTime approvalDate) {
        this.approvalDate = approvalDate;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    @Override
    public String toString() {
        return "ContractAppendixPart{" + "appendixPartId=" + appendixPartId + ", appendixId=" + appendixId + ", equipmentId=" + equipmentId + ", partId=" + partId + ", quantity=" + quantity + ", unitPrice=" + unitPrice + ", totalPrice=" + totalPrice + ", repairReportId=" + repairReportId + ", paymentStatus=" + paymentStatus + ", approvedByCustomer=" + approvedByCustomer + ", approvalDate=" + approvalDate + ", note=" + note + '}';
    }
    
    
}
