/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

import java.math.BigDecimal;

/**
 *
 * @author MY PC
 */
public class RepairReportDetail {
    private int detailId;
    private int reportId;
    private int partId;
    private int partDetailId;
    private int quantity;
    private BigDecimal unitPrice;

    public RepairReportDetail() {
    }

    public RepairReportDetail(int detailId, int reportId, int partId, int partDetailId, int quantity, BigDecimal unitPrice) {
        this.detailId = detailId;
        this.reportId = reportId;
        this.partId = partId;
        this.partDetailId = partDetailId;
        this.quantity = quantity;
        this.unitPrice = unitPrice;
    }

    public int getDetailId() {
        return detailId;
    }

    public void setDetailId(int detailId) {
        this.detailId = detailId;
    }

    public int getReportId() {
        return reportId;
    }

    public void setReportId(int reportId) {
        this.reportId = reportId;
    }

    public int getPartId() {
        return partId;
    }

    public void setPartId(int partId) {
        this.partId = partId;
    }

    public int getPartDetailId() {
        return partDetailId;
    }

    public void setPartDetailId(int partDetailId) {
        this.partDetailId = partDetailId;
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

    @Override
    public String toString() {
        return "RepairReportDetail{" + "detailId=" + detailId + ", reportId=" + reportId + ", partId=" + partId + ", partDetailId=" + partDetailId + ", quantity=" + quantity + ", unitPrice=" + unitPrice + '}';
    }
    
    
}
