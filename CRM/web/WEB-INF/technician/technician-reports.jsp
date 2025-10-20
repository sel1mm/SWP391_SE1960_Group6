<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<div class="container-fluid">
    <!-- Header with New Report Button -->
    <div class="row mb-3 align-items-center">
        <div class="col">
            <h1 class="h4 crm-page-title">Repair Reports</h1>
        </div>
        <div class="col-auto">
            <button class="btn btn-primary" onclick="showReportForm()">
                <i class="bi bi-plus-circle me-1"></i>New Repair Report
            </button>
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

    <!-- Reports List -->
    <div class="card crm-card-shadow">
        <div class="card-header">
            <h5 class="mb-0">Your Repair Reports</h5>
        </div>
        <div class="card-body p-0">
            <c:choose>
                <c:when test="${not empty reports}">
                    <div class="table-responsive">
                        <table class="table align-middle mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th>Report ID</th>
                                    <th>Request ID</th>
                                    <th>Details</th>
                                    <th>Diagnosis</th>
                                    <th>Estimated Cost</th>
                                    <th>Quotation Status</th>
                                    <th>Repair Date</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="report" items="${reports}">
                                    <tr>
                                        <td>${report.reportId}</td>
                                        <td>${report.requestId}</td>
                                        <td>
                                            <div class="text-truncate" style="max-width: 200px;" title="${fn:escapeXml(report.details)}">
                                                ${fn:escapeXml(report.details)}
                                            </div>
                                        </td>
                                        <td>
                                            <div class="text-truncate" style="max-width: 200px;" title="${fn:escapeXml(report.diagnosis)}">
                                                ${fn:escapeXml(report.diagnosis)}
                                            </div>
                                        </td>
                                        <td>$${report.estimatedCost}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${report.quotationStatus == 'Approved'}">
                                                    <span class="badge bg-success">Approved</span>
                                                </c:when>
                                                <c:when test="${report.quotationStatus == 'Pending'}">
                                                    <span class="badge bg-warning">Pending</span>
                                                </c:when>
                                                <c:when test="${report.quotationStatus == 'Rejected'}">
                                                    <span class="badge bg-danger">Rejected</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-secondary">${report.quotationStatus}</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>${report.repairDate}</td>
                                        <td>
                                            <button class="btn btn-sm btn-outline-primary" onclick="editReport(${report.reportId})">
                                                <i class="bi bi-pencil"></i> Edit
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
                        <i class="bi bi-clipboard-x text-muted" style="font-size: 3rem;"></i>
                        <p class="text-muted mt-2">No repair reports found. Create your first report!</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>

<!-- Report Form Modal -->
<div class="modal fade" id="reportModal" tabindex="-1" aria-labelledby="reportModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="reportModalLabel">Repair Report</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form id="reportForm" method="post" action="${pageContext.request.contextPath}/technician/reports">
                <div class="modal-body">
                    <input type="hidden" id="reportId" name="reportId" value="">

                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label">Service Request ID <span class="text-danger">*</span></label>
                            <input type="number" class="form-control" id="requestId" name="requestId" required min="1">
                            <div class="invalid-feedback" id="requestIdError"></div>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Repair Date <span class="text-danger">*</span></label>
                            <input type="date" class="form-control" id="repairDate" name="repairDate" required>
                            <div class="invalid-feedback" id="repairDateError"></div>
                        </div>

                        <div class="col-12">
                            <label class="form-label">Details <span class="text-danger">*</span></label>
                            <textarea class="form-control" id="details" name="details" rows="3" required maxlength="255"
                                      placeholder="Describe what you found during the repair visit..."></textarea>
                            <div class="form-text">Maximum 255 characters. Only letters, numbers, spaces, commas, periods, dashes, parentheses, and forward slashes allowed.</div>
                            <div class="invalid-feedback" id="detailsError"></div>
                        </div>

                        <div class="col-12">
                            <label class="form-label">Diagnosis <span class="text-danger">*</span></label>
                            <textarea class="form-control" id="diagnosis" name="diagnosis" rows="3" required maxlength="255"
                                      placeholder="Your professional diagnosis and conclusion..."></textarea>
                            <div class="form-text">Maximum 255 characters. Only letters, numbers, spaces, commas, periods, dashes, parentheses, and forward slashes allowed.</div>
                            <div class="invalid-feedback" id="diagnosisError"></div>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Estimated Cost <span class="text-danger">*</span></label>
                            <div class="input-group">
                                <span class="input-group-text">$</span>
                                <input type="number" class="form-control" id="estimatedCost" name="estimatedCost"
                                       required step="0.01" min="0.01" max="1000000" placeholder="1500.00">
                            </div>
                            <div class="invalid-feedback" id="estimatedCostError"></div>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Quotation Status</label>
                            <input type="text" class="form-control" value="Pending" readonly>
                            <div class="form-text">Status is automatically set to "Pending" when submitted.</div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary" id="submitBtn">Submit Report</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Error Modal -->
<div class="modal fade" id="errorModal" tabindex="-1" aria-labelledby="errorModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header bg-danger text-white">
                <h5 class="modal-title" id="errorModalLabel">
                    <i class="bi bi-exclamation-triangle me-2"></i>Validation Error
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <div id="errorMessage"></div>
                <div class="mt-3">
                    <strong>Example of correct format:</strong>
                    <div id="errorExample" class="text-muted"></div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-danger" data-bs-dismiss="modal">OK</button>
            </div>
        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/technician/validation.js"></script>
