<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<div class="container-fluid">
    <!-- Header -->
    <div class="row mb-3 align-items-center">
        <div class="col">
            <h1 class="h4 crm-page-title">Contract Details</h1>
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

    <!-- Contract Information -->
    <div class="card crm-card-shadow mb-4">
        <div class="card-header">
            <h5 class="mb-0">Contract Information</h5>
        </div>
        <div class="card-body">
            <div class="row g-3">
                <div class="col-md-3">
                    <strong>Contract ID:</strong><br>
                    <span class="text-primary">#${contract.contractId}</span>
                </div>
                <div class="col-md-3">
                    <strong>Customer:</strong><br>
                    ${fn:escapeXml(customerName)}
                </div>
                <div class="col-md-3">
                    <strong>Contract Date:</strong><br>
                    ${contract.contractDate}
                </div>
                <div class="col-md-3">
                    <strong>Type:</strong><br>
                    <span class="badge bg-info">${fn:escapeXml(contract.contractType)}</span>
                </div>
                <div class="col-md-3">
                    <strong>Status:</strong><br>
                    <c:choose>
                        <c:when test="${contract.status == 'Active'}">
                            <span class="badge bg-success">Active</span>
                        </c:when>
                        <c:when test="${contract.status == 'Pending'}">
                            <span class="badge bg-warning">Pending</span>
                        </c:when>
                        <c:when test="${contract.status == 'Suspended'}">
                            <span class="badge bg-danger">Suspended</span>
                        </c:when>
                        <c:when test="${contract.status == 'Completed'}">
                            <span class="badge bg-secondary">Completed</span>
                        </c:when>
                        <c:otherwise>
                            <span class="badge bg-light text-dark">${fn:escapeXml(contract.status)}</span>
                        </c:otherwise>
                    </c:choose>
                </div>
                <div class="col-md-9">
                    <strong>Details:</strong><br>
                    <c:choose>
                        <c:when test="${not empty contract.details}">
                            ${fn:escapeXml(contract.details)}
                        </c:when>
                        <c:otherwise>
                            <em class="text-muted">No details provided</em>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>

    <!-- Equipment Management -->
    <div class="card crm-card-shadow">
        <div class="card-header d-flex justify-content-between align-items-center">
            <h5 class="mb-0">Associated Equipment</h5>
            <button class="btn btn-primary btn-sm" onclick="showAddEquipmentModal()">
                <i class="bi bi-plus-circle me-1"></i>Add Equipment
            </button>
        </div>
        <div class="card-body p-0">
            <c:choose>
                <c:when test="${not empty equipmentList}">
                    <div class="table-responsive">
                        <table class="table align-middle mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th>Equipment ID</th>
                                    <th>Serial Number</th>
                                    <th>Model</th>
                                    <th>Description</th>
                                    <th>Start Date</th>
                                    <th>End Date</th>
                                    <th>Quantity</th>
                                    <th>Price</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="equipment" items="${equipmentList}">
                                    <tr>
                                        <td>${equipment.equipmentId}</td>
                                        <td>${fn:escapeXml(equipment.serialNumber)}</td>
                                        <td>${fn:escapeXml(equipment.model)}</td>
                                        <td>
                                            <div class="text-truncate" style="max-width: 200px;" title="${fn:escapeXml(equipment.description)}">
                                                ${fn:escapeXml(equipment.description)}
                                            </div>
                                        </td>
                                        <td>${equipment.startDate}</td>
                                        <td>${equipment.endDate}</td>
                                        <td>${equipment.quantity}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${equipment.price != null}">
                                                    $${equipment.price}
                                                </c:when>
                                                <c:otherwise>
                                                    <em class="text-muted">Not set</em>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <button class="btn btn-sm btn-outline-danger" onclick="removeEquipment(${equipment.contractEquipmentId})">
                                                <i class="bi bi-trash"></i>
                                            </button>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="text-center py-4">
                        <i class="bi bi-box text-muted" style="font-size: 3rem;"></i>
                        <p class="text-muted mt-2">No equipment associated with this contract.</p>
                        <button class="btn btn-primary" onclick="showAddEquipmentModal()">
                            <i class="bi bi-plus-circle me-1"></i>Add First Equipment
                        </button>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>

<!-- Add Equipment Modal -->
<div class="modal fade" id="addEquipmentModal" tabindex="-1" aria-labelledby="addEquipmentModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="addEquipmentModalLabel">Add Equipment to Contract</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form method="post" action="${pageContext.request.contextPath}/technician/contracts">
                <div class="modal-body">
                    <input type="hidden" name="action" value="addEquipment">
                    <input type="hidden" name="contractId" value="${contract.contractId}">
                    
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label">Equipment ID <span class="text-danger">*</span></label>
                            <input type="number" class="form-control" name="equipmentId" required min="1" 
                                   placeholder="Enter equipment ID">
                        </div>
                        
                        <div class="col-md-6">
                            <label class="form-label">Quantity <span class="text-danger">*</span></label>
                            <input type="number" class="form-control" name="quantity" required min="1" 
                                   placeholder="1">
                        </div>
                        
                        <div class="col-md-6">
                            <label class="form-label">Start Date <span class="text-danger">*</span></label>
                            <input type="date" class="form-control" name="startDate" required>
                        </div>
                        
                        <div class="col-md-6">
                            <label class="form-label">End Date</label>
                            <input type="date" class="form-control" name="endDate" 
                                   placeholder="Optional">
                        </div>
                        
                        <div class="col-md-6">
                            <label class="form-label">Price</label>
                            <div class="input-group">
                                <span class="input-group-text">$</span>
                                <input type="number" class="form-control" name="price" 
                                       step="0.01" min="0" placeholder="0.00">
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary">Add Equipment</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
function showAddEquipmentModal() {
    const modal = new bootstrap.Modal(document.getElementById('addEquipmentModal'));
    modal.show();
    
    // Set today's date as default start date
    const startDateInput = document.querySelector('input[name="startDate"]');
    if (startDateInput && !startDateInput.value) {
        const today = new Date().toISOString().split('T')[0];
        startDateInput.value = today;
    }
}

function removeEquipment(contractEquipmentId) {
    if (confirm('Are you sure you want to remove this equipment from the contract?')) {
        // TODO: Implement equipment removal
        alert('Equipment removal feature coming soon!');
    }
}
</script>
