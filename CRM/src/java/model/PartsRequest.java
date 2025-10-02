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
public class PartsRequest {
    private int partsRequestId;
    private int taskId;
    private LocalDate requestDate;
    private String status;
    private int handledBy;
    private LocalDate handledDate;

    public PartsRequest() {
    }

    public PartsRequest(int partsRequestId, int taskId, LocalDate requestDate, String status, int handledBy, LocalDate handledDate) {
        this.partsRequestId = partsRequestId;
        this.taskId = taskId;
        this.requestDate = requestDate;
        this.status = status;
        this.handledBy = handledBy;
        this.handledDate = handledDate;
    }

    public int getPartsRequestId() {
        return partsRequestId;
    }

    public void setPartsRequestId(int partsRequestId) {
        this.partsRequestId = partsRequestId;
    }

    public int getTaskId() {
        return taskId;
    }

    public void setTaskId(int taskId) {
        this.taskId = taskId;
    }

    public LocalDate getRequestDate() {
        return requestDate;
    }

    public void setRequestDate(LocalDate requestDate) {
        this.requestDate = requestDate;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public int getHandledBy() {
        return handledBy;
    }

    public void setHandledBy(int handledBy) {
        this.handledBy = handledBy;
    }

    public LocalDate getHandledDate() {
        return handledDate;
    }

    public void setHandledDate(LocalDate handledDate) {
        this.handledDate = handledDate;
    }
    
    
}
