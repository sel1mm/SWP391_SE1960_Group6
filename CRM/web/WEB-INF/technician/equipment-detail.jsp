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
          <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/technician/contracts?action=equipment">Equipment</a></li>
          <li class="breadcrumb-item active">Equipment #${equipment.equipmentId}</li>
        </ol>
      </nav>
      <h1 class="h4 crm-page-title mt-2">Equipment Detail</h1>
    </div>
    <div class="col-auto">
      <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/technician/contracts?action=equipment">
        <i class="bi bi-arrow-left me-1"></i>Back to Equipment
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
          <h5 class="mb-0">Equipment Information</h5>
        </div>
        <div class="card-body">
          <div class="row">
            <div class="col-md-6">
              <div class="mb-3">
                <label class="form-label fw-bold">Equipment ID</label>
                <p class="form-control-plaintext">#${equipment.equipmentId}</p>
              </div>
              <div class="mb-3">
                <label class="form-label fw-bold">Serial Number</label>
                <p class="form-control-plaintext">
                  <code class="text-primary fs-5">${fn:escapeXml(equipment.serialNumber)}</code>
                </p>
              </div>
              <div class="mb-3">
                <label class="form-label fw-bold">Model</label>
                <p class="form-control-plaintext">${fn:escapeXml(equipment.model)}</p>
              </div>
            </div>
            <div class="col-md-6">
              <div class="mb-3">
                <label class="form-label fw-bold">Install Date</label>
                <p class="form-control-plaintext">
                  <c:choose>
                    <c:when test="${equipment.installDate != null}">
                      <i class="bi bi-calendar-event me-1"></i>${equipment.installDate}
                    </c:when>
                    <c:otherwise>
                      <span class="text-muted">Not set</span>
                    </c:otherwise>
                  </c:choose>
                </p>
              </div>
              <div class="mb-3">
                <label class="form-label fw-bold">Last Updated By</label>
                <p class="form-control-plaintext">#${equipment.lastUpdatedBy}</p>
              </div>
              <div class="mb-3">
                <label class="form-label fw-bold">Last Updated Date</label>
                <p class="form-control-plaintext">
                  <c:choose>
                    <c:when test="${equipment.lastUpdatedDate != null}">
                      <i class="bi bi-calendar-event me-1"></i>${equipment.lastUpdatedDate}
                    </c:when>
                    <c:otherwise>
                      <span class="text-muted">Unknown</span>
                    </c:otherwise>
                  </c:choose>
                </p>
              </div>
            </div>
          </div>
          
          <div class="mb-3">
            <label class="form-label fw-bold">Description</label>
            <div class="border rounded p-3 bg-light">
              <c:choose>
                <c:when test="${equipment.description != null && !equipment.description.isEmpty()}">
                  <p class="mb-0">${fn:escapeXml(equipment.description)}</p>
                </c:when>
                <c:otherwise>
                  <p class="mb-0 text-muted">No description provided</p>
                </c:otherwise>
              </c:choose>
            </div>
          </div>
        </div>
      </div>
    </div>
    
    <div class="col-lg-4">
      <div class="card crm-card-shadow">
        <div class="card-header">
          <h5 class="mb-0">Equipment Status</h5>
        </div>
        <div class="card-body">
          <div class="text-center">
            <i class="bi bi-gear fs-1 text-primary"></i>
            <p class="mt-2 mb-0">Equipment Active</p>
            <small class="text-muted">This equipment is operational</small>
          </div>
          
          <hr>
          
          <div class="mb-3">
            <label class="form-label fw-bold">Installation Status</label>
            <p class="form-control-plaintext">
              <c:choose>
                <c:when test="${equipment.installDate != null}">
                  <span class="badge bg-success">Installed</span>
                </c:when>
                <c:otherwise>
                  <span class="badge bg-warning">Not Installed</span>
                </c:otherwise>
              </c:choose>
            </p>
          </div>
          
          <div class="mb-3">
            <label class="form-label fw-bold">Maintenance Status</label>
            <p class="form-control-plaintext">
              <span class="badge bg-info">Regular Maintenance</span>
            </p>
          </div>
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
            <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/technician/contracts">
              <i class="bi bi-file-earmark-text me-1"></i>View Contracts
            </a>
          </div>
        </div>
      </div>
      
      <div class="card crm-card-shadow mt-3">
        <div class="card-header">
          <h5 class="mb-0">Equipment Details</h5>
        </div>
        <div class="card-body">
          <div class="row text-center">
            <div class="col-6">
              <div class="border rounded p-2">
                <i class="bi bi-hash fs-4 text-primary"></i>
                <p class="mb-0 fw-bold">${equipment.equipmentId}</p>
                <small class="text-muted">Equipment ID</small>
              </div>
            </div>
            <div class="col-6">
              <div class="border rounded p-2">
                <i class="bi bi-tag fs-4 text-success"></i>
                <p class="mb-0 fw-bold">${fn:substring(equipment.serialNumber, 0, 8)}...</p>
                <small class="text-muted">Serial Number</small>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
