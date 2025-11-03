package model;

public class InvoiceItem {
    private Invoice invoice;
    private String formattedContractId;
    
    public InvoiceItem() {
    }
    
    public InvoiceItem(Invoice invoice, String formattedContractId) {
        this.invoice = invoice;
        this.formattedContractId = formattedContractId;
    }
    
    public Invoice getInvoice() {
        return invoice;
    }
    
    public void setInvoice(Invoice invoice) {
        this.invoice = invoice;
    }
    
    public String getFormattedContractId() {
        return formattedContractId;
    }
    
    public void setFormattedContractId(String formattedContractId) {
        this.formattedContractId = formattedContractId;
    }
}