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
public class RepairResult {
    private int resultId;
    private int taskId;
    private String details;
    private LocalDate completionDate;
    private int technicianId;
    private String status;

    public RepairResult() {
    }

    public RepairResult(int resultId, int taskId, String details, LocalDate completionDate, int technicianId, String status) {
        this.resultId = resultId;
        this.taskId = taskId;
        this.details = details;
        this.completionDate = completionDate;
        this.technicianId = technicianId;
        this.status = status;
    }

    public int getResultId() {
        return resultId;
    }

    public void setResultId(int resultId) {
        this.resultId = resultId;
    }

    public int getTaskId() {
        return taskId;
    }

    public void setTaskId(int taskId) {
        this.taskId = taskId;
    }

    public String getDetails() {
        return details;
    }

    public void setDetails(String details) {
        this.details = details;
    }

    public LocalDate getCompletionDate() {
        return completionDate;
    }

    public void setCompletionDate(LocalDate completionDate) {
        this.completionDate = completionDate;
    }

    public int getTechnicianId() {
        return technicianId;
    }

    public void setTechnicianId(int technicianId) {
        this.technicianId = technicianId;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
    
    
}
