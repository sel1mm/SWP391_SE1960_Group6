package model;
import java.time.LocalDate;

public class RequestApproval {
    private int approvalId;
    private int requestId;
    private int approvedBy;
    private LocalDate approvalDate;
    private String decision;
    private String note;

    public RequestApproval() {
    }

    public RequestApproval(int approvalId, int requestId, int approvedBy, LocalDate approvalDate, String decision, String note) {
        this.approvalId = approvalId;
        this.requestId = requestId;
        this.approvedBy = approvedBy;
        this.approvalDate = approvalDate;
        this.decision = decision;
        this.note = note;
    }

    public int getApprovalId() {
        return approvalId;
    }

    public void setApprovalId(int approvalId) {
        this.approvalId = approvalId;
    }

    public int getRequestId() {
        return requestId;
    }

    public void setRequestId(int requestId) {
        this.requestId = requestId;
    }

    public int getApprovedBy() {
        return approvedBy;
    }

    public void setApprovedBy(int approvedBy) {
        this.approvedBy = approvedBy;
    }

    public LocalDate getApprovalDate() {
        return approvalDate;
    }

    public void setApprovalDate(LocalDate approvalDate) {
        this.approvalDate = approvalDate;
    }

    public String getDecision() {
        return decision;
    }

    public void setDecision(String decision) {
        this.decision = decision;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }
    
    
}
