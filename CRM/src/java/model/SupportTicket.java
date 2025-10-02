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
public class SupportTicket {
    private int ticketId;
    private int customerId;
    private int supportStaffId;
    private int contractId;
    private int equipmentId;
    private String description;
    private String response; 
    private LocalDate createdDate;
    private LocalDate closedDate;

    public SupportTicket() {
    }

    public SupportTicket(int ticketId, int customerId, int supportStaffId, int contractId, int equipmentId, String description, String response, LocalDate createdDate, LocalDate closedDate) {
        this.ticketId = ticketId;
        this.customerId = customerId;
        this.supportStaffId = supportStaffId;
        this.contractId = contractId;
        this.equipmentId = equipmentId;
        this.description = description;
        this.response = response;
        this.createdDate = createdDate;
        this.closedDate = closedDate;
    }

    public int getTicketId() {
        return ticketId;
    }

    public void setTicketId(int ticketId) {
        this.ticketId = ticketId;
    }

    public int getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    public int getSupportStaffId() {
        return supportStaffId;
    }

    public void setSupportStaffId(int supportStaffId) {
        this.supportStaffId = supportStaffId;
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

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getResponse() {
        return response;
    }

    public void setResponse(String response) {
        this.response = response;
    }

    public LocalDate getCreatedDate() {
        return createdDate;
    }

    public void setCreatedDate(LocalDate createdDate) {
        this.createdDate = createdDate;
    }

    public LocalDate getClosedDate() {
        return closedDate;
    }

    public void setClosedDate(LocalDate closedDate) {
        this.closedDate = closedDate;
    }
    
    
}
