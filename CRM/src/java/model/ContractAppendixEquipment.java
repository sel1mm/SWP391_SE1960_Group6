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
public class ContractAppendixEquipment {
    private int appendixEquipId;
    private int appendixId;
    private int equipmentId;
    private BigDecimal unitPrice;
    private String note;

    public ContractAppendixEquipment() {
    }

    public int getAppendixEquipId() {
        return appendixEquipId;
    }

    public void setAppendixEquipId(int appendixEquipId) {
        this.appendixEquipId = appendixEquipId;
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

    public BigDecimal getUnitPrice() {
        return unitPrice;
    }

    public void setUnitPrice(BigDecimal unitPrice) {
        this.unitPrice = unitPrice;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    @Override
    public String toString() {
        return "ContractAppendixEquipment{" + "appendixEquipId=" + appendixEquipId + ", appendixId=" + appendixId + ", equipmentId=" + equipmentId + ", unitPrice=" + unitPrice + ", note=" + note + '}';
    }
    
    
}
