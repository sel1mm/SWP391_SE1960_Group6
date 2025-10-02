package model;

public class VnpayTransaction {
    private int vnpayId;
    private int transactionId;
    private String vnpayRef;
    private String responseCode;

    public VnpayTransaction() {
    }

    public VnpayTransaction(int vnpayId, int transactionId, String vnpayRef, String responseCode) {
        this.vnpayId = vnpayId;
        this.transactionId = transactionId;
        this.vnpayRef = vnpayRef;
        this.responseCode = responseCode;
    }

    public int getVnpayId() {
        return vnpayId;
    }

    public void setVnpayId(int vnpayId) {
        this.vnpayId = vnpayId;
    }

    public int getTransactionId() {
        return transactionId;
    }

    public void setTransactionId(int transactionId) {
        this.transactionId = transactionId;
    }

    public String getVnpayRef() {
        return vnpayRef;
    }

    public void setVnpayRef(String vnpayRef) {
        this.vnpayRef = vnpayRef;
    }

    public String getResponseCode() {
        return responseCode;
    }

    public void setResponseCode(String responseCode) {
        this.responseCode = responseCode;
    }
    
    
}
