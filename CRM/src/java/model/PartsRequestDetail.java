package model;

public class PartsRequestDetail {
    private int requestDetailId;
    private int partsRequestId;
    private int partId;
    private int quantityRequested;
    private int quantityIssued;

    public PartsRequestDetail() {
    }

    public PartsRequestDetail(int requestDetailId, int partsRequestId, int partId, int quantityRequested, int quantityIssued) {
        this.requestDetailId = requestDetailId;
        this.partsRequestId = partsRequestId;
        this.partId = partId;
        this.quantityRequested = quantityRequested;
        this.quantityIssued = quantityIssued;
    }

    public int getRequestDetailId() {
        return requestDetailId;
    }

    public void setRequestDetailId(int requestDetailId) {
        this.requestDetailId = requestDetailId;
    }

    public int getPartsRequestId() {
        return partsRequestId;
    }

    public void setPartsRequestId(int partsRequestId) {
        this.partsRequestId = partsRequestId;
    }

    public int getPartId() {
        return partId;
    }

    public void setPartId(int partId) {
        this.partId = partId;
    }

    public int getQuantityRequested() {
        return quantityRequested;
    }

    public void setQuantityRequested(int quantityRequested) {
        this.quantityRequested = quantityRequested;
    }

    public int getQuantityIssued() {
        return quantityIssued;
    }

    public void setQuantityIssued(int quantityIssued) {
        this.quantityIssued = quantityIssued;
    }
    
    
}
