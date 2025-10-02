package model;
import java.time.LocalDate;

public class ContractEquipment {
    private int contractEquipmentId;
    private int contractId;
    private int equipmentId;
    private LocalDate startDate;
    private LocalDate endDate;
    private int quantity = 1;
    private double price;

    public ContractEquipment() {
    }

    public ContractEquipment(int contractEquipmentId, int contractId, int equipmentId, LocalDate startDate, LocalDate endDate, double price) {
        this.contractEquipmentId = contractEquipmentId;
        this.contractId = contractId;
        this.equipmentId = equipmentId;
        this.startDate = startDate;
        this.endDate = endDate;
        this.price = price;
    }

    public int getContractEquipmentId() {
        return contractEquipmentId;
    }

    public void setContractEquipmentId(int contractEquipmentId) {
        this.contractEquipmentId = contractEquipmentId;
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

    public LocalDate getStartDate() {
        return startDate;
    }

    public void setStartDate(LocalDate startDate) {
        this.startDate = startDate;
    }

    public LocalDate getEndDate() {
        return endDate;
    }

    public void setEndDate(LocalDate endDate) {
        this.endDate = endDate;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }
    
    
}
