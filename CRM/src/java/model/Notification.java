/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;
import java.time.LocalDateTime;

/**
 *
 * @author MY PC
 */
public class Notification {
    private int notificationId;
    private int accountId;
    private String notificationType;
    private int contractEquipmentId;
    private String message;
    private LocalDateTime createdAt;
    private String status;

    public Notification() {
    }

    public Notification(int notificationId, int accountId, String notificationType, int contractEquipmentId, String message, LocalDateTime createdAt, String status) {
        this.notificationId = notificationId;
        this.accountId = accountId;
        this.notificationType = notificationType;
        this.contractEquipmentId = contractEquipmentId;
        this.message = message;
        this.createdAt = createdAt;
        this.status = status;
    }

    public int getNotificationId() {
        return notificationId;
    }

    public void setNotificationId(int notificationId) {
        this.notificationId = notificationId;
    }

    public int getAccountId() {
        return accountId;
    }

    public void setAccountId(int accountId) {
        this.accountId = accountId;
    }

    public String getNotificationType() {
        return notificationType;
    }

    public void setNotificationType(String notificationType) {
        this.notificationType = notificationType;
    }

    public int getContractEquipmentId() {
        return contractEquipmentId;
    }

    public void setContractEquipmentId(int contractEquipmentId) {
        this.contractEquipmentId = contractEquipmentId;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
    
    
}
