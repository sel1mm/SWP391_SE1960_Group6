<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<div class="container-fluid">
    <!-- Header with New Contract Button -->
    <div class="row mb-3 align-items-center">
        <div class="col">
            <h1 class="h4 crm-page-title">Contract Management</h1>
        </div>
        <div class="col-auto">
            <a href="${pageContext.request.contextPath}/technician/contracts?view=create" class="btn btn-primary">
                <i class="bi bi-plus-circle me-1"></i>New Contract
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

    <!-- Search and Filter -->
    <div class="card crm-card-shadow mb-3">
        <div class="card-body">
            <form method="get" action="${pageContext.request.contextPath}/technician/contracts" class="row g-3">
                <div class="col-md-4">
                    <label class="form-label">Search Customer</label>
                    <input type="text" class="form-control" name="search" 
                           placeholder="Search by customer name..." 
                           value="${fn:escapeXml(param.search)}">
                </div>
                <div class="col-md-3">
                    <label class="form-label">Contract Type</label>
                    <select class="form-select" name="type">
                        <option value="">All Types</option>
                        <option value="Maintenance" ${param.type == 'Maintenance' ? 'selected' : ''}>Maintenance</option>
                        <option value="Installation" ${param.type == 'Installation' ? 'selected' : ''}>Installation</option>
                        <option value="Repair" ${param.type == 'Repair' ? 'selected' : ''}>Repair</option>
                        <option value="Support" ${param.type == 'Support' ? 'selected' : ''}>Support</option>
                        <option value="Consultation" ${param.type == 'Consultation' ? 'selected' : ''}>Consultation</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <label class="form-label">Status</label>
                    <select class="form-select" name="status">
                        <option value="">All Statuses</option>
                        <option value="Active" ${param.status == 'Active' ? 'selected' : ''}>Active</option>
                        <option value="Pending" ${param.status == 'Pending' ? 'selected' : ''}>Pending</option>
                        <option value="Suspended" ${param.status == 'Suspended' ? 'selected' : ''}>Suspended</option>
                        <option value="Completed" ${param.status == 'Completed' ? 'selected' : ''}>Completed</option>
                        <option value="Cancelled" ${param.status == 'Cancelled' ? 'selected' : ''}>Cancelled</option>
                    </select>
                </div>
                <div class="col-md-2">
                    <label class="form-label">&nbsp;</label>
                    <div class="d-grid">
                        <button type="submit" class="btn btn-outline-primary">
                            <i class="bi bi-search"></i> Search
                        </button>
                    </div>
                </div>
            </form>
        </div>
    </div>

    <!-- Contracts List -->
    <div class="card crm-card-shadow">
        <div class="card-header d-flex justify-content-between align-items-center">
            <h5 class="mb-0">All Contracts</h5>
            <c:if test="${not empty param.search || not empty param.type || not empty param.status}">
                <a href="${pageContext.request.contextPath}/technician/contracts" class="btn btn-sm btn-outline-secondary">
                    <i class="bi bi-x-circle me-1"></i>Clear Filters
                </a>
            </c:if>
        </div>
        <div class="card-body p-0">
            <c:choose>
                <c:when test="${not empty contracts}">
                    <div class="table-responsive">
                        <table class="table align-middle mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th>Contract ID</th>
                                    <th>Customer</th>
                                    <th>Contract Date</th>
                                    <th>Type</th>
                                    <th>Status</th>
                                    <th>Details</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="contractWithCustomer" items="${contracts}">
                                    <c:set var="contract" value="${contractWithCustomer.contract}" />
                                    <tr>
                                        <td>${contract.contractId}</td>
                                        <td>${fn:escapeXml(contractWithCustomer.customerName)}</td>
                                        <td>${contract.contractDate}</td>
                                        <td>${fn:escapeXml(contract.contractType)}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${contract.status == 'Active'}">
                                                    <span class="badge bg-success">Active</span>
                                                </c:when>
                                                <c:when test="${contract.status == 'Completed'}">
                                                    <span class="badge bg-info text-dark">Completed</span>
                                                </c:when>
                                                <c:when test="${contract.status == 'Cancelled'}">
                                                    <span class="badge bg-danger">Cancelled</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-secondary">${fn:escapeXml(contract.status)}</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <div class="text-truncate" style="max-width: 200px;" title="${fn:escapeXml(contract.details)}">
                                                ${fn:escapeXml(contract.details)}
                                            </div>
                                        </td>
                                        <td>
                                            <div class="btn-group" role="group">
                                                <a href="${pageContext.request.contextPath}/technician/contracts?contractId=${contract.contractId}" 
                                                   class="btn btn-sm btn-outline-primary">
                                                    <i class="bi bi-eye"></i> View
                                                </a>
                                                <button class="btn btn-sm btn-outline-success" onclick="updateStatus(${contract.contractId}, '${contract.status}')">
                                                    <i class="bi bi-arrow-repeat"></i> Status
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="text-center py-4">
                        <i class="bi bi-file-earmark-x text-muted" style="font-size: 3rem;"></i>
                        <p class="text-muted mt-2">No contracts found. Create your first contract!</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>

<!-- Status Update Modal -->
<div class="modal fade" id="statusModal" tabindex="-1" aria-labelledby="statusModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="statusModalLabel">Update Contract Status</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form method="post" action="${pageContext.request.contextPath}/technician/contracts">
                <div class="modal-body">
                    <input type="hidden" name="action" value="updateContractStatus">
                    <input type="hidden" id="statusContractId" name="contractId" value="">
                    
                    <div class="mb-3">
                        <label class="form-label">Current Status:</label>
                        <span id="currentStatus" class="badge bg-secondary"></span>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label">New Status:</label>
                        <select class="form-select" name="status" required>
                            <option value="">Select new status...</option>
                            <option value="Active">Active</option>
                            <option value="Pending">Pending</option>
                            <option value="Suspended">Suspended</option>
                            <option value="Completed">Completed</option>
                            <option value="Cancelled">Cancelled</option>
                        </select>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary">Update Status</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
function updateStatus(contractId, currentStatus) {
    document.getElementById('statusContractId').value = contractId;
    document.getElementById('currentStatus').textContent = currentStatus;
    document.getElementById('currentStatus').className = 'badge bg-secondary';
    
    const modal = new bootstrap.Modal(document.getElementById('statusModal'));
    modal.show();
}
</script>
