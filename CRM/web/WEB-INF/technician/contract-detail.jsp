<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<div class="container-fluid">
  <!-- Success/Error Messages -->
  <c:if test="${not empty success}">
    <div class="alert alert-success alert-dismissible fade show" role="alert">
      <i class="bi bi-check-circle me-2"></i>${success}
      <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
  </c:if>
  <c:if test="${not empty error}">
    <div class="alert alert-danger alert-dismissible fade show" role="alert">
      <i class="bi bi-exclamation-triangle me-2"></i>${error}
      <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
  </c:if>

  <div class="row mb-3 align-items-center">
    <div class="col">
      <nav aria-label="breadcrumb">
        <ol class="breadcrumb mb-0">
          <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/technician/contracts">Contracts</a></li>
          <li class="breadcrumb-item active">Contract #${contractWithEquipment.contract.contractId}</li>
        </ol>
      </nav>
      <h1 class="h4 crm-page-title mt-2">Contract Detail</h1>
    </div>
    <div class="col-auto">
      <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/technician/contracts">
        <i class="bi bi-arrow-left me-1"></i>Back to Contracts
      </a>
      <a class="btn btn-primary" href="${pageContext.request.contextPath}/technician/tasks">
        <i class="bi bi-list-task me-1"></i>My Tasks
      </a>
    </div>
  </div>

  <div class="row">
    <div class="col-lg-8">
      <div class="card crm-card-shadow">
        <div class="card-header">
          <h5 class="mb-0">Contract Information</h5>
        </div>
        <div class="card-body">
          <div class="row">
            <div class="col-md-6">
              <div class="mb-3">
                <label class="form-label fw-bold">Contract ID</label>
                <p class="form-control-plaintext">#${contractWithEquipment.contract.contractId}</p>
              </div>
              <div class="mb-3">
                <label class="form-label fw-bold">Customer</label>
                <p class="form-control-plaintext">
                  <i class="bi bi-person-circle me-1"></i>${fn:escapeXml(contractWithEquipment.customerName)}
                </p>
              </div>
              <div class="mb-3">
                <label class="form-label fw-bold">Contract Type</label>
                <p class="form-control-plaintext">${fn:escapeXml(contractWithEquipment.contract.contractType)}</p>
              </div>
            </div>
            <div class="col-md-6">
              <div class="mb-3">
                <label class="form-label fw-bold">Status</label>
                <p class="form-control-plaintext">
                  <c:set var="status" value="${contractWithEquipment.contract.status}"/>
                  <c:choose>
                    <c:when test="${status == 'Active'}">
                      <span class="badge bg-success">Active</span>
                    </c:when>
                    <c:when test="${status == 'Completed'}">
                      <span class="badge bg-primary">Completed</span>
                    </c:when>
                    <c:when test="${status == 'Cancelled'}">
                      <span class="badge bg-danger">Cancelled</span>
                    </c:when>
                    <c:otherwise>
                      <span class="badge bg-dark">${contractWithEquipment.contract.status}</span>
                    </c:otherwise>
                  </c:choose>
                </p>
              </div>
              <div class="mb-3">
                <label class="form-label fw-bold">Contract Date</label>
                <p class="form-control-plaintext">
                  <i class="bi bi-calendar-event me-1"></i>${contractWithEquipment.contract.contractDate}
                </p>
              </div>
            </div>
          </div>
          
          <div class="mb-3">
            <label class="form-label fw-bold">Details</label>
            <div class="border rounded p-3 bg-light">
              <c:choose>
                <c:when test="${contractWithEquipment.contract.details != null && !contractWithEquipment.contract.details.isEmpty()}">
                  <p class="mb-0">${fn:escapeXml(contractWithEquipment.contract.details)}</p>
                </c:when>
                <c:otherwise>
                  <p class="mb-0 text-muted">No details provided</p>
                </c:otherwise>
              </c:choose>
            </div>
          </div>
        </div>
      </div>
      
      <!-- Equipment Information -->
      <div class="card crm-card-shadow mt-3">
        <div class="card-header d-flex justify-content-between align-items-center">
          <h5 class="mb-0">Associated Equipment</h5>
          <c:choose>
            <c:when test="${contractWithEquipment.equipment != null}">
              <span class="badge bg-success">1 Equipment</span>
            </c:when>
            <c:otherwise>
              <span class="badge bg-secondary">No Equipment</span>
            </c:otherwise>
          </c:choose>
        </div>
        <div class="card-body">
          <c:choose>
            <c:when test="${contractWithEquipment.equipment != null}">
              <div class="row">
                <div class="col-md-6">
                  <div class="mb-3">
                    <label class="form-label fw-bold">Equipment ID</label>
                    <p class="form-control-plaintext">#${contractWithEquipment.equipment.equipmentId}</p>
                  </div>
                  <div class="mb-3">
                    <label class="form-label fw-bold">Model</label>
                    <p class="form-control-plaintext">${fn:escapeXml(contractWithEquipment.equipment.model)}</p>
                  </div>
                  <div class="mb-3">
                    <label class="form-label fw-bold">Serial Number</label>
                    <p class="form-control-plaintext"><code class="text-primary">${fn:escapeXml(contractWithEquipment.equipment.serialNumber)}</code></p>
                  </div>
                </div>
                <div class="col-md-6">
                  <div class="mb-3">
                    <label class="form-label fw-bold">Status</label>
                    <p class="form-control-plaintext">
                      <c:choose>
                        <c:when test="${contractWithEquipment.equipment.status == 'InUse'}">
                          <span class="badge bg-warning">In Use</span>
                        </c:when>
                        <c:when test="${contractWithEquipment.equipment.status == 'Available'}">
                          <span class="badge bg-success">Available</span>
                        </c:when>
                        <c:when test="${contractWithEquipment.equipment.status == 'Faulty'}">
                          <span class="badge bg-danger">Faulty</span>
                        </c:when>
                        <c:when test="${contractWithEquipment.equipment.status == 'Retired'}">
                          <span class="badge bg-secondary">Retired</span>
                        </c:when>
                        <c:otherwise>
                          <span class="badge bg-light text-dark">${contractWithEquipment.equipment.status}</span>
                        </c:otherwise>
                      </c:choose>
                    </p>
                  </div>
                  <div class="mb-3">
                    <label class="form-label fw-bold">Location</label>
                    <p class="form-control-plaintext">
                      <c:choose>
                        <c:when test="${contractWithEquipment.equipment.location != null && !contractWithEquipment.equipment.location.isEmpty()}">
                          <i class="bi bi-geo-alt me-1"></i>${fn:escapeXml(contractWithEquipment.equipment.location)}
                        </c:when>
                        <c:otherwise>
                          <span class="text-muted">Not specified</span>
                        </c:otherwise>
                      </c:choose>
                    </p>
                  </div>
                  <div class="mb-3">
                    <label class="form-label fw-bold">Unit Price</label>
                    <p class="form-control-plaintext">$${contractWithEquipment.equipment.unitPrice}</p>
                  </div>
                </div>
              </div>
              
              <c:if test="${contractWithEquipment.equipment.description != null && !contractWithEquipment.equipment.description.isEmpty()}">
                <div class="mb-3">
                  <label class="form-label fw-bold">Description</label>
                  <div class="border rounded p-3 bg-light">
                    <p class="mb-0">${fn:escapeXml(contractWithEquipment.equipment.description)}</p>
                  </div>
                </div>
              </c:if>
            </c:when>
            <c:otherwise>
              <div class="text-center py-4">
                <div class="text-muted">
                  <i class="bi bi-gear fs-1 d-block mb-2"></i>
                  <p>No equipment associated with this contract</p>
                  <small>This contract was created without equipment assignment</small>
                </div>
              </div>
            </c:otherwise>
          </c:choose>
        </div>
      </div>
    </div>
    
    <div class="col-lg-4">
      <div class="card crm-card-shadow">
        <div class="card-header">
          <h5 class="mb-0">Contract Summary</h5>
        </div>
        <div class="card-body">
          <div class="mb-3">
            <label class="form-label fw-bold">Total Equipment</label>
            <p class="form-control-plaintext fs-5">
              <c:choose>
                <c:when test="${contractWithEquipment.equipment != null}">1 item</c:when>
                <c:otherwise>0 items</c:otherwise>
              </c:choose>
            </p>
          </div>
          
          <c:if test="${contractWithEquipment.equipment != null}">
            <div class="mb-3">
              <label class="form-label fw-bold">Contract Equipment Details</label>
              <div class="border rounded p-2 bg-light">
                <div class="d-flex justify-content-between mb-1">
                  <small>Equipment #${contractWithEquipment.equipment.equipmentId}</small>
                  <small class="text-muted">Qty: ${contractWithEquipment.quantity}</small>
                </div>
                <c:if test="${contractWithEquipment.price != null}">
                  <div class="d-flex justify-content-between">
                    <small>Price:</small>
                    <small class="fw-bold">$${contractWithEquipment.price}</small>
                  </div>
                </c:if>
              </div>
            </div>
          </c:if>
        </div>
      </div>
      
      <div class="card crm-card-shadow mt-3">
        <div class="card-header">
          <h5 class="mb-0">Quick Actions</h5>
        </div>
        <div class="card-body">
          <div class="d-grid gap-2">
            <a class="btn btn-primary" href="${pageContext.request.contextPath}/technician/tasks">
              <i class="bi bi-list-task me-1"></i>View My Tasks
            </a>
            <a class="btn btn-outline-primary" href="${pageContext.request.contextPath}/technician/reports?action=create">
              <i class="bi bi-clipboard-plus me-1"></i>Create Report
            </a>
            <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/technician/contracts?action=equipment">
              <i class="bi bi-gear me-1"></i>View All Equipment
            </a>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
