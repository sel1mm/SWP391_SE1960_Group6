package dto;

/**
 * Result class for service request update operations
 * Provides detailed information about the update result
 */
public class ServiceRequestUpdateResult {
    public enum Status {
        SUCCESS,
        REQUEST_NOT_FOUND,
        ALREADY_PROCESSED,
        TECHNICIAN_NOT_FOUND,
        DATABASE_ERROR
    }
    
    private Status status;
    private String message;
    private Exception exception;
    
    public ServiceRequestUpdateResult(Status status, String message) {
        this.status = status;
        this.message = message;
    }
    
    public ServiceRequestUpdateResult(Status status, String message, Exception exception) {
        this.status = status;
        this.message = message;
        this.exception = exception;
    }
    
    // Getters
    public Status getStatus() {
        return status;
    }
    
    public String getMessage() {
        return message;
    }
    
    public Exception getException() {
        return exception;
    }
    
    public boolean isSuccess() {
        return status == Status.SUCCESS;
    }
    
    // Static factory methods for common results
    public static ServiceRequestUpdateResult success() {
        return new ServiceRequestUpdateResult(Status.SUCCESS, "Request updated successfully");
    }
    
    public static ServiceRequestUpdateResult requestNotFound() {
        return new ServiceRequestUpdateResult(Status.REQUEST_NOT_FOUND, "Request not found!");
    }
    
    public static ServiceRequestUpdateResult alreadyProcessed() {
        return new ServiceRequestUpdateResult(Status.ALREADY_PROCESSED, "This request has already been processed!");
    }
    
    public static ServiceRequestUpdateResult technicianNotFound() {
        return new ServiceRequestUpdateResult(Status.TECHNICIAN_NOT_FOUND, "Assigned technician not found!");
    }
    
    public static ServiceRequestUpdateResult databaseError(Exception e) {
        return new ServiceRequestUpdateResult(Status.DATABASE_ERROR, "Database error occurred: " + e.getMessage(), e);
    }
}