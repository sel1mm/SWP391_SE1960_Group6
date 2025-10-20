<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<div class="container-fluid">
    <!-- Header -->
    <div class="row mb-3 align-items-center">
        <div class="col">
            <h1 class="h4 crm-page-title">Create New Contract</h1>
        </div>
        <div class="col-auto">
            <a href="${pageContext.request.contextPath}/technician/contracts" class="btn btn-outline-secondary">
                <i class="bi bi-arrow-left me-1"></i>Back to Contracts
            </a>
        </div>
    </div>

    <!-- Success/Error Messages -->
    <c:if test="${not empty param.success}">
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="bi bi-check-circle me-2"></i>${fn:escapeXml(param.success)}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <c:if test="${not empty param.error}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="bi bi-exclamation-triangle me-2"></i>${fn:escapeXml(param.error)}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <!-- Contract Creation Form -->
    <div class="card crm-card-shadow">
        <div class="card-header">
            <h5 class="mb-0">Contract Information</h5>
        </div>
        <div class="card-body">
            <form method="post" action="${pageContext.request.contextPath}/technician/contracts">
                <input type="hidden" name="action" value="createContract">
                
                <div class="row g-3">
                    <div class="col-md-6">
                        <label class="form-label">Customer <span class="text-danger">*</span></label>
                        <select class="form-select" name="customerId" required>
                            <option value="">Select a customer...</option>
                            <c:forEach var="customer" items="${customers}">
                                <option value="${customer.accountId}">${fn:escapeXml(customer.fullName)} - ${fn:escapeXml(customer.email)}</option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="col-md-6">
                        <label class="form-label">Contract Date <span class="text-danger">*</span></label>
                        <input type="date" class="form-control" name="contractDate" required 
                               value="${fn:escapeXml(param.contractDate)}">
                    </div>

                    <div class="col-md-6">
                        <label class="form-label">Contract Type <span class="text-danger">*</span></label>
                        <select class="form-select" name="contractType" required>
                            <option value="">Select contract type...</option>
                            <option value="Maintenance" ${param.contractType == 'Maintenance' ? 'selected' : ''}>Maintenance</option>
                            <option value="Installation" ${param.contractType == 'Installation' ? 'selected' : ''}>Installation</option>
                            <option value="Repair" ${param.contractType == 'Repair' ? 'selected' : ''}>Repair</option>
                            <option value="Support" ${param.contractType == 'Support' ? 'selected' : ''}>Support</option>
                            <option value="Consultation" ${param.contractType == 'Consultation' ? 'selected' : ''}>Consultation</option>
                        </select>
                    </div>

                    <div class="col-md-6">
                        <label class="form-label">Status</label>
                        <select class="form-select" name="status">
                            <option value="Active" selected>Active</option>
                            <option value="Pending">Pending</option>
                            <option value="Suspended">Suspended</option>
                            <option value="Completed">Completed</option>
                        </select>
                    </div>

                    <div class="col-12">
                        <label class="form-label">Contract Details</label>
                        <textarea class="form-control" name="details" rows="4" 
                                  placeholder="Describe the contract terms, scope of work, and any special requirements...">${fn:escapeXml(param.details)}</textarea>
                        <div class="form-text">Provide detailed information about the contract scope and terms.</div>
                    </div>
                </div>

                <div class="row mt-4">
                    <div class="col-12">
                        <div class="d-flex gap-2">
                            <button type="submit" class="btn btn-primary">
                                <i class="bi bi-check-circle me-1"></i>Create Contract
                            </button>
                            <a href="${pageContext.request.contextPath}/technician/contracts" class="btn btn-secondary">
                                <i class="bi bi-x-circle me-1"></i>Cancel
                            </a>
                        </div>
                    </div>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
// Set today's date as default
document.addEventListener('DOMContentLoaded', function() {
    const contractDateInput = document.querySelector('input[name="contractDate"]');
    if (contractDateInput && !contractDateInput.value) {
        const today = new Date().toISOString().split('T')[0];
        contractDateInput.value = today;
    }
});
</script>