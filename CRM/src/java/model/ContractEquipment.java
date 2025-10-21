package model;

import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * ContractEquipment model representing the relationship between contracts and equipment.
 * Maps to the ContractEquipment table in the final database schema.
 */
public class ContractEquipment {
    private int contractEquipmentId;
    private int contractId;
    private int equipmentId;
    private LocalDate startDate;
    private LocalDate endDate;
    private int quantity;
    private BigDecimal price;

    // Constructors
    public ContractEquipment() {}

    public ContractEquipment(int contractEquipmentId, int contractId, int equipmentId, 
                            LocalDate startDate, LocalDate endDate, int quantity, BigDecimal price) {
        this.contractEquipmentId = contractEquipmentId;
        this.contractId = contractId;
        this.equipmentId = equipmentId;
        this.startDate = startDate;
        this.endDate = endDate;
        this.quantity = quantity;
        this.price = price;
    }

    // Getters and Setters
    public int getContractEquipmentId() { return contractEquipmentId; }
    public void setContractEquipmentId(int contractEquipmentId) { this.contractEquipmentId = contractEquipmentId; }

    public int getContractId() { return contractId; }
    public void setContractId(int contractId) { this.contractId = contractId; }

    public int getEquipmentId() { return equipmentId; }
    public void setEquipmentId(int equipmentId) { this.equipmentId = equipmentId; }

    public LocalDate getStartDate() { return startDate; }
    public void setStartDate(LocalDate startDate) { this.startDate = startDate; }

    public LocalDate getEndDate() { return endDate; }
    public void setEndDate(LocalDate endDate) { this.endDate = endDate; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }

    @Override
    public String toString() {
        return "ContractEquipment{" +
                "contractEquipmentId=" + contractEquipmentId +
                ", contractId=" + contractId +
                ", equipmentId=" + equipmentId +
                ", startDate=" + startDate +
                ", endDate=" + endDate +
                ", quantity=" + quantity +
                ", price=" + price +
                '}';
    }
}