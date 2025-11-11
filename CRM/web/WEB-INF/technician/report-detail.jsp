<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

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
          <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/technician/reports">Reports</a></li>
          <li class="breadcrumb-item active">Report Detail</li>
        </ol>
      </nav>
      <h1 class="h4 crm-page-title mt-2">Repair Report Detail</h1>
    </div>
    <div class="col-auto">
      <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/technician/reports">
        <i class="bi bi-arrow-left me-1"></i>Back to Reports
      </a>
      <c:if test="${report.quotationStatus == 'Pending'}">
        <a class="btn btn-primary" href="${pageContext.request.contextPath}/technician/reports?action=edit&reportId=${report.reportId}">
          <i class="bi bi-pencil me-1"></i>Edit Report
        </a>
      </c:if>
    </div>
  </div>

  <div class="row">
    <div class="col-lg-8">
      <div class="card crm-card-shadow">
        <div class="card-header">
          <h5 class="mb-0">Report Information</h5>
        </div>
        <div class="card-body">
          <div class="row">
            <div class="col-md-6">
              <div class="mb-3">
                <label class="form-label fw-bold">Report ID</label>
                <p class="form-control-plaintext">#${report.reportId}</p>
              </div>
              <div class="mb-3">
                <label class="form-label fw-bold">Request ID</label>
                <p class="form-control-plaintext">
                  <a href="#" class="text-decoration-none">#${report.requestId}</a>
                </p>
              </div>
              <c:if test="${not empty selectedRequestType}">
                <div class="mb-3">
                  <span class="badge ${isWarrantyRequest ? 'bg-warning text-dark' : 'bg-info'}">
                    <c:choose>
                      <c:when test="${isWarrantyRequest}">Warranty / Preventive Maintenance</c:when>
                      <c:otherwise>Service Request</c:otherwise>
                    </c:choose>
                  </span>
                </div>
              </c:if>
              <div class="mb-3">
                <label class="form-label fw-bold">Technician ID</label>
                <p class="form-control-plaintext">#${report.technicianId}</p>
              </div>
            </div>
            <div class="col-md-6">
              <div class="mb-3">
                <label class="form-label fw-bold">Quotation Status</label>
                <p class="form-control-plaintext">
                  <c:set var="status" value="${report.quotationStatus}"/>
                  <c:choose>
                    <c:when test="${status == 'Pending'}">
                      <span class="badge bg-warning">Pending</span>
                    </c:when>
                    <c:when test="${status == 'Approved'}">
                      <span class="badge bg-success">Approved</span>
                    </c:when>
                    <c:when test="${status == 'Rejected'}">
                      <span class="badge bg-danger">Rejected</span>
                    </c:when>
                    <c:when test="${status == 'In Review'}">
                      <span class="badge bg-info">In Review</span>
                    </c:when>
                    <c:otherwise>
                      <span class="badge bg-dark">${report.quotationStatus}</span>
                    </c:otherwise>
                  </c:choose>
                </p>
              </div>
              <div class="mb-3">
                <label class="form-label fw-bold">Estimated Cost</label>
                <p class="form-control-plaintext">
                  <c:choose>
                    <c:when test="${isWarrantyRequest}">
                      <span class="fw-bold text-muted fs-5">₫0</span>
                      <div class="text-muted small">Warranty covered – no charge to customer.</div>
                      <c:if test="${not empty subtotal}">
                        <div class="text-muted small">Parts value: ₫<fmt:formatNumber value="${subtotal * 26000}" type="number" maxFractionDigits="0"/></div>
                      </c:if>
                    </c:when>
                    <c:otherwise>
                      <span class="fw-bold text-success fs-5">₫<fmt:formatNumber value="${report.estimatedCost * 26000}" type="number" maxFractionDigits="0"/></span>
                    </c:otherwise>
                  </c:choose>
                </p>
              </div>
              <div class="mb-3">
                <label class="form-label fw-bold">Repair Date</label>
                <p class="form-control-plaintext">
                  <i class="bi bi-calendar-event me-1"></i>${report.repairDate}
                </p>
              </div>
            </div>
          </div>
          
          <div class="mb-3">
            <label class="form-label fw-bold">Details</label>
            <div class="border rounded p-3 bg-light">
              <c:choose>
                <c:when test="${report.details != null && !report.details.isEmpty()}">
                  <p class="mb-0">${fn:escapeXml(report.details)}</p>
                </c:when>
                <c:otherwise>
                  <p class="mb-0 text-muted">No details provided</p>
                </c:otherwise>
              </c:choose>
            </div>
          </div>
          
          <!-- Parts List (replaces Diagnosis) -->
          <div class="mb-3">
            <label class="form-label fw-bold">Parts</label>
            <c:choose>
              <c:when test="${not empty reportDetails}">
                <div class="table-responsive">
                  <table class="table table-sm table-bordered">
                    <thead class="table-light">
                      <tr>
                        <th>Part Name</th>
                        <th>Serial</th>
                        <th>Location</th>
                        <th>Unit Price</th>
                        <th>Quantity</th>
                        <th>Line Total</th>
                      </tr>
                    </thead>
                    <tbody>
                      <c:forEach var="detail" items="${reportDetails}">
                        <tr>
                          <td>${fn:escapeXml(detail.partName)}</td>
                          <td>${fn:escapeXml(detail.serialNumber != null ? detail.serialNumber : 'N/A')}</td>
                          <td>${fn:escapeXml(detail.location != null ? detail.location : 'N/A')}</td>
                          <td>₫<fmt:formatNumber value="${detail.unitPrice * 26000}" type="number" maxFractionDigits="0"/></td>
                          <td>${detail.quantity}</td>
                          <td class="fw-bold">₫<fmt:formatNumber value="${detail.lineTotal * 26000}" type="number" maxFractionDigits="0"/></td>
                        </tr>
                      </c:forEach>
                    </tbody>
                    <tfoot>
                      <tr>
                        <td colspan="5" class="text-end fw-bold">Parts Value:</td>
                        <td class="fw-bold text-success fs-5">₫<fmt:formatNumber value="${subtotal * 26000}" type="number" maxFractionDigits="0"/></td>
                      </tr>
                      <c:if test="${isWarrantyRequest}">
                        <tr>
                          <td colspan="5" class="text-end fw-bold text-muted">Customer Charged:</td>
                          <td class="fw-bold text-muted">₫0 (Warranty Covered)</td>
                        </tr>
                      </c:if>
                      <c:if test="${!isWarrantyRequest}">
                        <tr>
                          <td colspan="5" class="text-end fw-bold">Customer Charged:</td>
                          <td class="fw-bold text-success fs-5">₫<fmt:formatNumber value="${report.estimatedCost * 26000}" type="number" maxFractionDigits="0"/></td>
                        </tr>
                      </c:if>
                    </tfoot>
                  </table>
                </div>
              </c:when>
              <c:otherwise>
                <div class="border rounded p-3 bg-light">
                  <p class="mb-0 text-muted">No parts selected for this report</p>
                </div>
              </c:otherwise>
            </c:choose>
          </div>
        </div>
      </div>
    </div>
    
    <div class="col-lg-4">
      <div class="card crm-card-shadow">
        <div class="card-header">
          <h5 class="mb-0">Quick Actions</h5>
        </div>
        <div class="card-body">
          <div class="d-grid gap-2">
            <c:if test="${report.quotationStatus == 'Pending'}">
              <a class="btn btn-primary" href="${pageContext.request.contextPath}/technician/reports?action=edit&reportId=${report.reportId}">
                <i class="bi bi-pencil me-1"></i>Edit Report
              </a>
            </c:if>
            <a class="btn btn-outline-primary" href="${pageContext.request.contextPath}/technician/tasks">
              <i class="bi bi-list-task me-1"></i>View Tasks
            </a>
            <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/technician/contracts">
              <i class="bi bi-file-earmark-text me-1"></i>View Contracts
            </a>
          </div>
        </div>
      </div>
      
      <div class="card crm-card-shadow mt-3">
        <div class="card-header">
          <h5 class="mb-0">Report Status</h5>
        </div>
        <div class="card-body">
          <div class="text-center">
            <c:set var="status" value="${report.quotationStatus}"/>
            <c:choose>
              <c:when test="${status == 'Pending'}">
                <i class="bi bi-clock-history fs-1 text-warning"></i>
                <p class="mt-2 mb-0">Report is pending approval</p>
                <small class="text-muted">You can still edit this report</small>
              </c:when>
              <c:when test="${status == 'Approved'}">
                <i class="bi bi-check-circle fs-1 text-success"></i>
                <p class="mt-2 mb-0">Report has been approved</p>
                <small class="text-muted">This report is finalized</small>
              </c:when>
              <c:when test="${status == 'Rejected'}">
                <i class="bi bi-x-circle fs-1 text-danger"></i>
                <p class="mt-2 mb-0">Report has been rejected</p>
                <small class="text-muted">Contact manager for details</small>
              </c:when>
              <c:when test="${status == 'In Review'}">
                <i class="bi bi-eye fs-1 text-info"></i>
                <p class="mt-2 mb-0">Report is under review</p>
                <small class="text-muted">Awaiting manager decision</small>
              </c:when>
              <c:otherwise>
                <i class="bi bi-question-circle fs-1 text-secondary"></i>
                <p class="mt-2 mb-0">Unknown status</p>
                <small class="text-muted">Contact support</small>
              </c:otherwise>
            </c:choose>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
