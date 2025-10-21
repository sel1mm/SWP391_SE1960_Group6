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
          <li class="breadcrumb-item active">Contract #${contract.contractId}</li>
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
                <p class="form-control-plaintext">#${contract.contractId}</p>
              </div>
              <div class="mb-3">
                <label class="form-label fw-bold">Customer</label>
                <p class="form-control-plaintext">
                  <i class="bi bi-person-circle me-1"></i>${fn:escapeXml(customerName)}
                </p>
              </div>
              <div class="mb-3">
                <label class="form-label fw-bold">Contract Type</label>
                <p class="form-control-plaintext">${fn:escapeXml(contract.contractType)}</p>
              </div>
            </div>
            <div class="col-md-6">
              <div class="mb-3">
                <label class="form-label fw-bold">Status</label>
                <p class="form-control-plaintext">
                  <c:set var="status" value="${contract.status}"/>
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
                      <span class="badge bg-dark">${contract.status}</span>
                    </c:otherwise>
                  </c:choose>
                </p>
              </div>
              <div class="mb-3">
                <label class="form-label fw-bold">Contract Date</label>
                <p class="form-control-plaintext">
                  <i class="bi bi-calendar-event me-1"></i>${contract.contractDate}
                </p>
              </div>
            </div>
          </div>
          
          <div class="mb-3">
            <label class="form-label fw-bold">Details</label>
            <div class="border rounded p-3 bg-light">
              <c:choose>
                <c:when test="${contract.details != null && !contract.details.isEmpty()}">
                  <p class="mb-0">${fn:escapeXml(contract.details)}</p>
                </c:when>
                <c:otherwise>
                  <p class="mb-0 text-muted">No details provided</p>
                </c:otherwise>
              </c:choose>
            </div>
          </div>
        </div>
      </div>
      
      <!-- Equipment List -->
      <div class="card crm-card-shadow mt-3">
        <div class="card-header d-flex justify-content-between align-items-center">
          <h5 class="mb-0">Associated Equipment</h5>
          <span class="badge bg-primary">${fn:length(equipmentList)} equipment</span>
        </div>
        <div class="card-body">
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
                      <th>Install Date</th>
                    </tr>
                  </thead>
                  <tbody>
                    <c:forEach var="equipment" items="${equipmentList}">
                      <tr>
                        <td><strong>#${equipment.equipmentId}</strong></td>
                        <td><code class="text-primary">${fn:escapeXml(equipment.serialNumber)}</code></td>
                        <td>${fn:escapeXml(equipment.model)}</td>
                        <td>
                          <c:choose>
                            <c:when test="${equipment.description != null && !equipment.description.isEmpty()}">
                              <div class="text-truncate" style="max-width:200px;" title="${fn:escapeXml(equipment.description)}">
                                ${fn:escapeXml(equipment.description)}
                              </div>
                            </c:when>
                            <c:otherwise>
                              <span class="text-muted">No description</span>
                            </c:otherwise>
                          </c:choose>
                        </td>
                        <td>
                          <c:choose>
                            <c:when test="${equipment.installDate != null}">
                              <i class="bi bi-calendar-event me-1"></i>${equipment.installDate}
                            </c:when>
                            <c:otherwise>
                              <span class="text-muted">Not set</span>
                            </c:otherwise>
                          </c:choose>
                        </td>
                      </tr>
                    </c:forEach>
                  </tbody>
                </table>
              </div>
            </c:when>
            <c:otherwise>
              <div class="text-center py-4">
                <div class="text-muted">
                  <i class="bi bi-gear fs-1 d-block mb-2"></i>
                  <p>No equipment associated with this contract</p>
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
            <p class="form-control-plaintext fs-5">${fn:length(equipmentList)} items</p>
          </div>
          
          <c:if test="${not empty contractEquipmentList}">
            <div class="mb-3">
              <label class="form-label fw-bold">Contract Equipment Details</label>
              <div class="border rounded p-2 bg-light">
                <c:forEach var="ce" items="${contractEquipmentList}">
                  <div class="d-flex justify-content-between mb-1">
                    <small>Equipment #${ce.equipmentId}</small>
                    <small class="text-muted">Qty: ${ce.quantity}</small>
                  </div>
                  <c:if test="${ce.price != null}">
                    <div class="d-flex justify-content-between">
                      <small>Price:</small>
                      <small class="fw-bold">$${ce.price}</small>
                    </div>
                  </c:if>
                  <hr class="my-2">
                </c:forEach>
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
