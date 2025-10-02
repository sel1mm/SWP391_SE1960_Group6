package model;
import java.time.LocalDate;

public class Contract {
    private int contractId;
    private int customerId;
    private LocalDate contractDate;
    private String contractType;
    private String status;
    private String details;

    public Contract() {
    }

    public Contract(int contractId, int customerId, LocalDate contractDate, String contractType, String status, String details) {
        this.contractId = contractId;
        this.customerId = customerId;
        this.contractDate = contractDate;
        this.contractType = contractType;
        this.status = status;
        this.details = details;
    }

    public int getContractId() {
        return contractId;
    }

    public void setContractId(int contractId) {
        this.contractId = contractId;
    }

    public int getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    public LocalDate getContractDate() {
        return contractDate;
    }

    public void setContractDate(LocalDate contractDate) {
        this.contractDate = contractDate;
    }

    public String getContractType() {
        return contractType;
    }

    public void setContractType(String contractType) {
        this.contractType = contractType;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getDetails() {
        return details;
    }

    public void setDetails(String details) {
        this.details = details;
    }
    
    
}
