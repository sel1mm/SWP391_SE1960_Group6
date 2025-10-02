/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author MY PC
 */
public class Priority {
    private int priorityId;
    private String priorityName;
    private int priorityLevel;
    private String description;

    public Priority() {
    }

    public Priority(int priorityId, String priorityName, int priorityLevel, String description) {
        this.priorityId = priorityId;
        this.priorityName = priorityName;
        this.priorityLevel = priorityLevel;
        this.description = description;
    }

    public int getPriorityId() {
        return priorityId;
    }

    public void setPriorityId(int priorityId) {
        this.priorityId = priorityId;
    }

    public String getPriorityName() {
        return priorityName;
    }

    public void setPriorityName(String priorityName) {
        this.priorityName = priorityName;
    }

    public int getPriorityLevel() {
        return priorityLevel;
    }

    public void setPriorityLevel(int priorityLevel) {
        this.priorityLevel = priorityLevel;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }
    
    
}
