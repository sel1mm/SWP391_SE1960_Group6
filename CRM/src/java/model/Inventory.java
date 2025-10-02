/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;
import java.time.LocalDate;

/**
 *
 * @author MY PC
 */
public class Inventory {
    private int inventoryId;
    private int partId;
    private int quantity;
    private int lastUpdatedBy;
    private LocalDate lastUpdatedDate;

    public Inventory() {
    }

    public Inventory(int inventoryId, int partId, int quantity, int lastUpdatedBy, LocalDate lastUpdatedDate) {
        this.inventoryId = inventoryId;
        this.partId = partId;
        this.quantity = quantity;
        this.lastUpdatedBy = lastUpdatedBy;
        this.lastUpdatedDate = lastUpdatedDate;
    }

    public int getInventoryId() {
        return inventoryId;
    }

    public void setInventoryId(int inventoryId) {
        this.inventoryId = inventoryId;
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

    public int getLastUpdatedBy() {
        return lastUpdatedBy;
    }

    public void setLastUpdatedBy(int lastUpdatedBy) {
        this.lastUpdatedBy = lastUpdatedBy;
    }

    public LocalDate getLastUpdatedDate() {
        return lastUpdatedDate;
    }

    public void setLastUpdatedDate(LocalDate lastUpdatedDate) {
        this.lastUpdatedDate = lastUpdatedDate;
    }
    
    
}
