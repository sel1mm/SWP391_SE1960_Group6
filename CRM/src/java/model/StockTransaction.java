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
public class StockTransaction {
    private int transactionId;
    private int partId;
    private String transactionType;
    private int quantity;
    private LocalDate transactionDate;
    private int performedBy;

    public StockTransaction() {
    }

    public StockTransaction(int transactionId, int partId, String transactionType, int quantity, LocalDate transactionDate, int performedBy) {
        this.transactionId = transactionId;
        this.partId = partId;
        this.transactionType = transactionType;
        this.quantity = quantity;
        this.transactionDate = transactionDate;
        this.performedBy = performedBy;
    }

    public int getTransactionId() {
        return transactionId;
    }

    public void setTransactionId(int transactionId) {
        this.transactionId = transactionId;
    }

    public int getPartId() {
        return partId;
    }

    public void setPartId(int partId) {
        this.partId = partId;
    }

    public String getTransactionType() {
        return transactionType;
    }

    public void setTransactionType(String transactionType) {
        this.transactionType = transactionType;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public LocalDate getTransactionDate() {
        return transactionDate;
    }

    public void setTransactionDate(LocalDate transactionDate) {
        this.transactionDate = transactionDate;
    }

    public int getPerformedBy() {
        return performedBy;
    }

    public void setPerformedBy(int performedBy) {
        this.performedBy = performedBy;
    }
    
    
}
