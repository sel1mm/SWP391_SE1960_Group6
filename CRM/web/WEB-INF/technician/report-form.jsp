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
  
  <!-- Validation Errors -->
  <c:if test="${not empty validationErrors}">
    <div class="alert alert-danger alert-dismissible fade show" role="alert">
      <i class="bi bi-exclamation-triangle me-2"></i>
      <strong>Validation Errors:</strong><br>
      <c:forEach var="error" items="${validationErrors}">
        • ${error}<br>
      </c:forEach>
      <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
  </c:if>

  <div class="row mb-3 align-items-center">
    <div class="col">
      <nav aria-label="breadcrumb">
        <ol class="breadcrumb mb-0">
          <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/technician/reports">Reports</a></li>
          <li class="breadcrumb-item active">
            <c:choose>
              <c:when test="${not empty report}">Edit Report</c:when>
              <c:otherwise>Create Report</c:otherwise>
            </c:choose>
          </li>
        </ol>
      </nav>
      <h1 class="h4 crm-page-title mt-2">
        <c:choose>
          <c:when test="${not empty report}">Edit Repair Report</c:when>
          <c:otherwise>Create Repair Report</c:otherwise>
        </c:choose>
      </h1>
    </div>
    <div class="col-auto">
      <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/technician/reports">
        <i class="bi bi-arrow-left me-1"></i>Back to Reports
      </a>
    </div>
  </div>

  <div class="row justify-content-center">
    <div class="col-lg-8">
      <div class="card crm-card-shadow">
        <div class="card-header">
          <h5 class="mb-0">Report Information</h5>
        </div>
        <div class="card-body">
          <form id="reportForm" method="post" action="${pageContext.request.contextPath}/technician/reports" novalidate>
            <input type="hidden" name="action" value="${not empty report ? 'update' : 'create'}">
            <input type="hidden" name="requestType" id="requestTypeInput" value="${not empty selectedRequestType ? selectedRequestType : (not empty customerRequestInfo ? customerRequestInfo.requestType : '')}">
            <c:if test="${not empty report}">
              <input type="hidden" name="reportId" value="${report.reportId}">
            </c:if>
            <c:choose>
              <c:when test="${not empty report}">
                <!-- Edit mode: show existing request ID as readonly -->
                <input type="hidden" id="requestIdHidden" name="requestId" value="${report.requestId}">
                <div class="row">
                  <div class="col-md-6">
                    <div class="mb-3">
                      <label for="requestIdDisplay" class="form-label fw-bold">Request ID</label>
                      <input type="text" class="form-control" id="requestIdDisplay" 
                             value="<c:choose><c:when test='${report.requestId != null}'>#${report.requestId}</c:when><c:otherwise>General Report</c:otherwise></c:choose>" readonly>
                    </div>
                  </div>
              </c:when>
              <c:otherwise>
                <c:choose>
                  <c:when test="${not empty scheduleId}">
                    <input type="hidden" id="scheduleIdHidden" name="scheduleId" value="${scheduleId}"/>
                    <input type="hidden" id="requestIdHidden" name="requestId" value="${requestId != null ? requestId : ''}"/>
                    <div class="row">
                      <div class="col-md-6">
                        <div class="mb-3">
                          <c:choose>
                            <c:when test="${not empty requestId}">
                              <label class="form-label fw-bold">Linked Request</label>
                              <input type="text" class="form-control" value="#${requestId}" readonly/>
                              <div class="form-text">This report originates from a scheduled task (Schedule ID #${scheduleId}).</div>
                            </c:when>
                            <c:otherwise>
                              <label class="form-label fw-bold">Schedule Context</label>
                              <div class="form-control-plaintext">
                                #${scheduleId}
                                <c:if test="${not empty scheduleCustomerName}">
                                  - ${fn:escapeXml(scheduleCustomerName)} (ID: ${scheduleCustomerId})
                                </c:if>
                                - Scheduled Maintenance Task
                                <c:if test="${not empty scheduleTaskStatus}">
                                  (${scheduleTaskStatus})
                                </c:if>
                              </div>
                              <div class="form-text">This report originates from a scheduled maintenance task.</div>
                            </c:otherwise>
                          </c:choose>
                        </div>
                      </div>
                    </div>
                  </c:when>
                  <c:otherwise>
                <div class="row">
                  <div class="col-md-6">
                    <div class="mb-3">
                      <label for="taskSelector" class="form-label fw-bold">Select Task <span class="text-danger">*</span></label>
                      <select class="form-select" id="taskSelector" name="taskSelector" required>
                        <option value="">-- Select a task to report on --</option>
                        <c:forEach var="taskForReport" items="${assignedTasks}">
                          <c:choose>
                            <c:when test="${taskForReport.origin eq 'Schedule'}">
                              <c:set var="optionValue" value="${'schedule:'}${taskForReport.scheduleId}" />
                            </c:when>
                            <c:otherwise>
                              <c:set var="optionValue" value="${'request:'}${taskForReport.requestId}" />
                            </c:otherwise>
                          </c:choose>
                          <option value="${optionValue}"
                                  data-origin="${taskForReport.origin}"
                                  data-request-id="${taskForReport.requestId != null ? taskForReport.requestId : ''}"
                                  data-schedule-id="${taskForReport.scheduleId != null ? taskForReport.scheduleId : ''}"
                                  data-request-type="${taskForReport.requestType}"
                                  data-task-status="${taskForReport.taskStatus}"
                                  <c:if test="${taskForReport.origin eq 'Schedule' && scheduleId != null && taskForReport.scheduleId != null && scheduleId == taskForReport.scheduleId}">selected</c:if>
                                  <c:if test="${taskForReport.origin ne 'Schedule' && requestId != null && taskForReport.requestId != null && requestId == taskForReport.requestId}">selected</c:if>>
                            ${fn:escapeXml(taskForReport.displayLabel)}
                          </option>
                        </c:forEach>
                      </select>
                      <input type="hidden" id="requestIdHidden" name="requestId" value="${requestId != null ? requestId : ''}">
                      <input type="hidden" id="scheduleIdHidden" name="scheduleId" value="${scheduleId != null ? scheduleId : ''}">
                      <div class="form-text">Only tasks assigned to you and not completed are shown</div>
                      <div class="invalid-feedback" id="requestIdError"></div>
                    </div>
                  </div>
                  
                  <!-- Contract Selection removed - Contract is automatically determined from ServiceRequest when report is approved -->
                </div>
                  </c:otherwise>
                </c:choose>
              </c:otherwise>
            </c:choose>
            
            <c:set var="initialRequestType" value="${not empty selectedRequestType ? selectedRequestType : (not empty customerRequestInfo ? customerRequestInfo.requestType : '')}" />
            <c:set var="isScheduleOrigin" value="${not empty scheduleId}"/>
            <c:if test="${!isScheduleOrigin}">
            <div id="requestTypeBanner" class="alert ${(initialRequestType == 'Warranty') ? 'alert-warning' : 'alert-info'} d-flex align-items-center">
              <i class="bi ${initialRequestType == 'Warranty' ? 'bi-shield-check' : 'bi-tools'} me-2 fs-4"></i>
              <div>
                <strong id="requestTypeLabel">
                  <c:choose>
                    <c:when test="${initialRequestType == 'Warranty'}">Warranty / Preventive Maintenance</c:when>
                    <c:when test="${initialRequestType == 'Service'}">Service Request</c:when>
                    <c:otherwise>Repair Request</c:otherwise>
                  </c:choose>
                </strong>
                <div class="small text-muted" id="requestTypeDescription">
                  <c:choose>
                    <c:when test="${initialRequestType == 'Warranty'}">
                      Warranty visits are free for the customer. Parts are optional and costs are recorded as 0.
                    </c:when>
                    <c:otherwise>
                      Standard repair workflow. Parts and estimated cost will be billed to the customer.
                    </c:otherwise>
                  </c:choose>
                </div>
              </div>
            </div>
            </c:if>
            
            <div class="row">
              <div class="col-md-6">
                <div class="mb-3">
                  <label for="quotationStatus" class="form-label fw-bold">Quotation Status</label>
                  <input type="text" class="form-control" id="quotationStatus" 
                         value="${not empty report ? report.quotationStatus : 'Pending'}" readonly>
                  <c:if test="${not empty scheduleId}">
                    <div class="mt-2">
                      <span class="badge bg-success"><i class="bi bi-shield-check me-1"></i>Covered by contract</span>
                    </div>
                  </c:if>
                </div>
              </div>
            </div>
            
            <div class="mb-3">
              <label for="details" class="form-label fw-bold">Details <span class="text-danger">*</span></label>
              <textarea class="form-control" id="details" name="details" rows="4" 
                        placeholder="Describe the repair work performed..." 
                        maxlength="255" required>${not empty report ? fn:escapeXml(report.details) : ''}</textarea>
              <div class="form-text">
                <span id="detailsCount">0</span>/255 characters
              </div>
              <div class="invalid-feedback" id="detailsError"></div>
            </div>
            
            <!-- Parts Selection (Simple Search & Select) -->
            <div class="mb-3">
              <label class="form-label fw-bold" id="partsLabel">Parts <span class="text-danger" id="partsRequiredIndicator">*</span></label>
              <div id="partsOptionalNote" class="text-muted small d-none">Parts are optional for warranty maintenance visits.</div>

              <!-- Search Box -->
              <div class="mb-3">
                <div class="input-group">
                  <input type="text"
                         id="partSearchInput"
                         class="form-control"
                         placeholder="Search parts by name or serial number..."
                         autocomplete="off">
                  <span class="input-group-text">
                    <i class="bi bi-search" id="searchIcon"></i>
                    <span class="spinner-border spinner-border-sm d-none" id="searchSpinner"></span>
                  </span>
                </div>
                <div class="form-text">Type to filter parts - all available parts shown below</div>
              </div>

              <!-- Available Parts List -->
              <div class="card mb-3">
                <div class="card-header bg-light">
                  <h6 class="mb-0"><i class="bi bi-box-seam me-2"></i>Available Parts</h6>
                </div>
                <div class="card-body p-0">
                  <div class="table-responsive" style="max-height: 400px; overflow-y: auto;">
                    <table class="table table-hover table-sm mb-0">
                      <thead class="table-light sticky-top">
                        <tr>
                          <th>Part Name</th>
                          <th class="text-center">Serial Number</th>
                          <th class="text-center">Unit Price</th>
                          <th class="text-center">Available</th>
                          <th class="text-center">Quantity</th>
                        </tr>
                      </thead>
                      <tbody id="partsListBody">
                        <!-- Will be populated by JavaScript -->
                        <tr>
                          <td colspan="5" class="text-center text-muted py-4">
                            <i class="bi bi-search me-2"></i>Select a task first to load available parts
                          </td>
                        </tr>
                      </tbody>
                    </table>
                  </div>
                </div>
              </div>

              <!-- Selected Parts List -->
              <div class="card border-success">
                <div class="card-header bg-success text-white">
                  <h6 class="mb-0">
                    <i class="bi bi-cart-check me-2"></i>
                    Selected Parts 
                    <span class="badge bg-light text-dark ms-2" id="selectedPartsCount">0</span>
                  </h6>
                </div>
                <div class="card-body p-0">
                  <div id="selectedPartsList" class="list-group list-group-flush">
                    <div class="list-group-item text-center text-muted py-4" id="emptyCartMessage">
                      <i class="bi bi-cart-x me-2"></i>No parts selected yet
                    </div>
                  </div>
                </div>
                <div class="card-footer bg-light">
                  <div class="d-flex justify-content-between align-items-center">
                    <span class="fw-bold">Total Estimated Cost:</span>
                    <span id="totalCost" class="fw-bold text-success fs-4">₫0</span>
                  </div>
                </div>
              </div>

              <div class="invalid-feedback" id="partsError" data-default-message="Please add at least one part."></div>
            </div>
            
            <div class="row">
              <div class="col-md-6">
                <div class="mb-3">
                  <label for="estimatedCost" class="form-label fw-bold">Estimated Cost <span class="text-danger">*</span></label>
                  <div class="input-group">
                    <span class="input-group-text">₫</span>
                    <input type="number" class="form-control" id="estimatedCost" name="estimatedCost" 
                           step="1" min="0" max="99999999999" 
                           placeholder="0" required
                           value="${not empty report ? (report.estimatedCost * 26000) : (not empty subtotal ? (subtotal * 26000) : '')}">
                  </div>
                  <c:choose>
                    <c:when test="${isScheduleOrigin}">
                      <div class="form-text text-muted" id="estimatedCostHint">
                        Covered by contract; customer billed ₫0. Internal unit prices are recorded in the appendix.
                      </div>
                    </c:when>
                    <c:otherwise>
                      <div class="form-text" id="estimatedCostHint">
                        <c:choose>
                          <c:when test="${not empty subtotal && subtotal > 0}">
                            Auto-calculated from parts: ₫<span id="autoCalculatedVnd"><fmt:formatNumber value="${subtotal * 26000}" type="number" maxFractionDigits="0"/></span>. You can override if needed.
                          </c:when>
                          <c:otherwise>
                            Enter cost in VND (Vietnamese Dong). Will be auto-filled when parts are selected.
                          </c:otherwise>
                        </c:choose>
                      </div>
                    </c:otherwise>
                  </c:choose>
                  <div class="form-text text-warning d-none" id="warrantyCostNotice">
                    Warranty jobs are recorded at ₫0 for the customer. Internal costs can still be tracked via parts.
                  </div>
                  <div class="invalid-feedback" id="estimatedCostError"></div>
                </div>
              </div>
              <div class="col-md-6">
                <div class="mb-3">
                  <label for="repairDate" class="form-label fw-bold">Repair Date <span class="text-danger">*</span></label>
                  <input type="date" class="form-control" id="repairDate" name="repairDate" 
                         required value="${not empty report ? report.repairDate : ''}"
                         ${not empty report ? 'disabled' : ''}>
                  <div class="form-text">
                    <c:choose>
                      <c:when test="${not empty report}">
                        <span class="text-muted">Repair date cannot be changed for existing reports</span>
                      </c:when>
                      <c:otherwise>
                        Date when repair was completed
                      </c:otherwise>
                    </c:choose>
                  </div>
                  <div class="invalid-feedback" id="repairDateError"></div>
                </div>
              </div>
            </div>
            
            <div class="d-flex justify-content-between">
              <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/technician/reports">
                <i class="bi bi-x-circle me-1"></i>Cancel
              </a>
              <button type="submit" class="btn btn-primary">
                <i class="bi bi-check-circle me-1"></i>
                <c:choose>
                  <c:when test="${not empty report}">Update Report</c:when>
                  <c:otherwise>Create Report</c:otherwise>
                </c:choose>
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</div>

<!-- Validation Error Modal -->
<div class="modal fade" id="validationModal" tabindex="-1" aria-labelledby="validationModalLabel" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="validationModalLabel">Validation Error</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        <div id="validationMessage"></div>
        <div id="validationExample" class="mt-2 text-muted"></div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-primary" data-bs-dismiss="modal">OK</button>
      </div>
    </div>
  </div>
</div>

<script>
// ============================================
// REAL-TIME PART SELECTION SYSTEM
// Pure JavaScript (No Frameworks)
// ============================================

(function() {
  'use strict';
  
  // Search state
  let searchTimeout = null;
  const SEARCH_DELAY = 300; // milliseconds
  
  // DOM Elements
  const partSearchInput = document.getElementById('partSearchInput');
  const searchIcon = document.getElementById('searchIcon');
  const searchSpinner = document.getElementById('searchSpinner');
  const partsListBody = document.getElementById('partsListBody');
  const selectedPartsList = document.getElementById('selectedPartsList');
  const selectedPartsCount = document.getElementById('selectedPartsCount');
  const totalCost = document.getElementById('totalCost');
  const estimatedCostInput = document.getElementById('estimatedCost');
  // Contract selection removed - contract is automatically determined from ServiceRequest
  
  // State
  let allParts = []; // All available parts loaded from server
  let selectedParts = {}; // In-memory cart: {partId: {partId, partName, serialNumber, unitPrice, quantity}}
  
  // Context path
  const contextPath = '${pageContext.request.contextPath}';
  
  // Currency conversion constants
  const USD_TO_VND_RATE = 26000;
  let isScheduleOrigin = false;
  
  // Conversion functions
  function usdToVnd(usd) {
    return parseFloat(usd || 0) * USD_TO_VND_RATE;
  }
  
  function vndToUsd(vnd) {
    return parseFloat(vnd || 0) / USD_TO_VND_RATE;
  }
  
  // Format VND for display
  function formatVnd(amount) {
    return new Intl.NumberFormat('vi-VN').format(Math.round(amount));
  }
  
  const requestTypeInputField = document.getElementById('requestTypeInput');
  const requestTypeBanner = document.getElementById('requestTypeBanner');
  const requestTypeLabel = document.getElementById('requestTypeLabel');
  const requestTypeDescription = document.getElementById('requestTypeDescription');
  const requestTypeBannerIcon = requestTypeBanner ? requestTypeBanner.querySelector('i') : null;
  const partsRequiredIndicator = document.getElementById('partsRequiredIndicator');
  const partsError = document.getElementById('partsError');
  const partsOptionalNote = document.getElementById('partsOptionalNote');
  const estimatedCostHint = document.getElementById('estimatedCostHint');
  const warrantyCostNotice = document.getElementById('warrantyCostNotice');
  let isWarrantyMode = false;

  function applyRequestTypeUI(requestType) {
    const normalizedType = (requestType || '').toLowerCase();
    isWarrantyMode = normalizedType === 'warranty';

    if (requestTypeInputField) {
      requestTypeInputField.value = requestType || '';
    }

    if (requestTypeBanner) {
      if (isScheduleOrigin) {
        requestTypeBanner.classList.add('d-none');
      } else {
        requestTypeBanner.classList.remove('d-none');
      }
      requestTypeBanner.classList.remove('alert-info', 'alert-warning');
      requestTypeBanner.classList.add(isWarrantyMode ? 'alert-warning' : 'alert-info');
    }

    if (requestTypeBannerIcon) {
      requestTypeBannerIcon.classList.remove('bi-tools', 'bi-shield-check');
      requestTypeBannerIcon.classList.add(isWarrantyMode ? 'bi-shield-check' : 'bi-tools');
    }

    if (requestTypeLabel) {
      requestTypeLabel.textContent = isWarrantyMode
        ? 'Warranty / Preventive Maintenance'
        : 'Service Request';
    }

    if (requestTypeDescription) {
      requestTypeDescription.textContent = isWarrantyMode
        ? 'Warranty visits are free for the customer. Parts are optional and costs are recorded as ₫0.'
        : 'Standard repair workflow. Parts and estimated cost will be billed to the customer.';
    }

    if (partsRequiredIndicator) {
      partsRequiredIndicator.classList.toggle('d-none', isWarrantyMode);
      partsRequiredIndicator.textContent = isWarrantyMode ? '' : '*';
    }

    if (partsOptionalNote) {
      partsOptionalNote.classList.toggle('d-none', !isWarrantyMode);
    }

    if (partsError) {
      const defaultMessage = partsError.dataset.defaultMessage || 'Please add at least one part.';
      partsError.textContent = isWarrantyMode ? '' : defaultMessage;
    }

    if (estimatedCostHint) {
      estimatedCostHint.classList.toggle('d-none', isWarrantyMode);
    }

    if (warrantyCostNotice) {
      warrantyCostNotice.classList.toggle('d-none', !isWarrantyMode);
    }

    if (estimatedCostInput) {
      let lastServiceValue = estimatedCostInput.getAttribute('data-last-service-value');
      if (!lastServiceValue) {
        lastServiceValue = estimatedCostInput.value || '0';
        estimatedCostInput.setAttribute('data-last-service-value', lastServiceValue);
      }
      if (!isWarrantyMode) {
        estimatedCostInput.readOnly = false;
        estimatedCostInput.classList.remove('bg-light');
        estimatedCostInput.value = lastServiceValue;
      } else {
        estimatedCostInput.setAttribute('data-last-service-value', lastServiceValue);
        estimatedCostInput.value = 0;
        estimatedCostInput.readOnly = true;
        estimatedCostInput.classList.add('bg-light');
      }
    }
  }
  
  // ============================================
  // EVENT LISTENERS
  // ============================================
  
  // Client-side search filter (instant, no AJAX)
  if (partSearchInput) {
    partSearchInput.addEventListener('keyup', function(e) {
      if (this.disabled) return;
      filterPartsList(this.value.trim());
    });
  }
  
  // Variables for requestId elements (will be set in DOMContentLoaded)
  let requestIdSelect = null;
  let requestIdInput = null;
  let scheduleIdInput = null;
  
  // Initialize cart from server-side session
  window.addEventListener('DOMContentLoaded', function() {
    console.log('=== DOMContentLoaded - Initializing repair report form ===');
    console.log('Context path:', contextPath);
    
    // Get requestId elements (select for create, input for edit)
    requestIdSelect = document.getElementById('taskSelector');
    requestIdInput = document.getElementById('requestIdHidden');
    scheduleIdInput = document.getElementById('scheduleIdHidden');
    isScheduleOrigin = !!(scheduleIdInput && scheduleIdInput.value);
    
    console.log('Request ID select found:', !!requestIdSelect);
    console.log('Request ID input found:', !!requestIdInput);
    console.log('Parts list body found:', !!partsListBody);
    
    // Check if requestId is available (from select for create, or input for edit)
    const requestId = requestIdInput?.value || '';
    const scheduleId = scheduleIdInput?.value || '';
    let initialRequestType = requestTypeInputField?.value || '';
    if (!initialRequestType && requestIdSelect) {
      const selectedOption = requestIdSelect.options[requestIdSelect.selectedIndex];
      if (selectedOption && selectedOption.dataset) {
        initialRequestType = selectedOption.dataset.requestType || '';
      }
    }
    const typeToApply = isScheduleOrigin ? 'Maintenance' : initialRequestType;
    applyRequestTypeUI(typeToApply);
    if (estimatedCostInput && !estimatedCostInput.getAttribute('data-last-service-value')) {
      estimatedCostInput.setAttribute('data-last-service-value', estimatedCostInput.value || '0');
    }
    
    if (requestId || scheduleId) {
      console.log('Request ID found:', requestId, '(from', requestIdSelect ? 'select' : 'input', ')');
      // Load parts first, then load cart
      loadAllAvailableParts(requestId || scheduleId, function() {
        loadCartFromSession();
      });
    } else {
      console.log('No request ID found, waiting for user selection');
      // Still try to load cart (might be empty)
      loadCartFromSession();
    }
    
    // If schedule-origin, force estimated cost read-only and 0 (covered)
    if (scheduleId && estimatedCostInput) {
      estimatedCostInput.value = 0;
      estimatedCostInput.readOnly = true;
      estimatedCostInput.classList.add('bg-light');
    }
    
    updatePartsSearchState();
    
    // Clear cart when Request ID changes (only for select, not input)
    if (requestIdSelect) {
      console.log('Task select element found, attaching change listener');
      requestIdSelect.addEventListener('change', function() {
        const selectedOption = requestIdSelect.options[requestIdSelect.selectedIndex];
        if (!selectedOption || !selectedOption.dataset) {
          console.log('No option selected, resetting state');
          if (requestIdInput) requestIdInput.value = '';
          if (scheduleIdInput) scheduleIdInput.value = '';
          isScheduleOrigin = false;
          disablePartsSearch();
          clearPartsList();
          applyRequestTypeUI('');
          selectedParts = {};
          updateCartDisplay([], 0);
          return;
        }

        const origin = selectedOption.dataset.origin || 'ServiceRequest';
        const selectedRequestId = selectedOption.dataset.requestId || '';
        const selectedScheduleId = selectedOption.dataset.scheduleId || '';
        const requestType = selectedOption.dataset.requestType || '';

        console.log('Task selection changed. Origin:', origin, 'RequestId:', selectedRequestId, 'ScheduleId:', selectedScheduleId);

        if (origin === 'Schedule') {
          if (requestIdInput) requestIdInput.value = '';
          if (scheduleIdInput) scheduleIdInput.value = selectedScheduleId;
        } else {
          if (requestIdInput) requestIdInput.value = selectedRequestId;
          if (scheduleIdInput) scheduleIdInput.value = '';
        }
        isScheduleOrigin = origin === 'Schedule';

        // Duplicate check before proceeding
        checkExistingReportForSelection(origin, selectedRequestId, selectedScheduleId, function(exists, reportId) {
          if (exists && reportId) {
            console.log('Existing report found (ID: ' + reportId + '), redirecting to edit');
            window.location.href = contextPath + '/technician/reports?action=edit&reportId=' + reportId;
            return;
          }

          console.log('No existing report, preparing form for new report');

          // Apply UI context
          if (isScheduleOrigin) {
            applyRequestTypeUI('Maintenance');
            if (estimatedCostInput) {
              estimatedCostInput.value = 0;
              estimatedCostInput.readOnly = true;
              estimatedCostInput.classList.add('bg-light');
            }
          } else {
            applyRequestTypeUI(requestType);
            if (estimatedCostInput) {
              estimatedCostInput.readOnly = false;
              estimatedCostInput.classList.remove('bg-light');
            }
          }

          // Reset client-side cart state
          selectedParts = {};

          const identifier = isScheduleOrigin ? selectedScheduleId : selectedRequestId;

          // Load parts for the selected task, then load cart
          loadAllAvailableParts(identifier, function() {
            loadCartFromSession();
          });

          enablePartsSearch();
        });
      });
    } else {
      console.log('Request ID select not found (this is normal in edit mode)');
    }
    
    // For edit mode, requestId is in a hidden input, so load parts on page load
    if (requestIdInput && !requestIdSelect) {
      console.log('Request ID input found (edit mode), parts will load on page load');
    }
  });
  
  // Check if parts search should be enabled
  function updatePartsSearchState() {
    // Check both select (create) and input (edit) for requestId
    const requestId = requestIdInput?.value || '';
    const scheduleId = scheduleIdInput?.value || '';
    
    if (!requestId && !scheduleId) {
      disablePartsSearch('Please select a task first before searching for parts.');
      return;
    }
    
    // Enable search
    enablePartsSearch();
  }
  
  function disablePartsSearch(message) {
    if (partSearchInput) {
      partSearchInput.disabled = true;
      partSearchInput.placeholder = message || 'Parts search disabled';
      partSearchInput.value = '';
    }
    clearPartsList();
  }
  
  function enablePartsSearch() {
    if (partSearchInput) {
      partSearchInput.disabled = false;
      partSearchInput.placeholder = 'Search parts by name or serial number...';
    }
  }
  
  // Check if a repair report already exists for the selected task
  function checkExistingReportForSelection(origin, requestId, scheduleId, callback) {
    const effectiveOrigin = origin || (scheduleId ? 'Schedule' : 'ServiceRequest');
    
    if (effectiveOrigin === 'Schedule' && !scheduleId) {
      if (callback) callback(false, null);
      return;
    }
    
    if (effectiveOrigin !== 'Schedule' && !requestId) {
      if (callback) callback(false, null);
      return;
    }
    
    const url = new URL(contextPath + '/technician/reports', window.location.origin);
    url.searchParams.set('action', 'checkExistingReport');
    if (effectiveOrigin === 'Schedule') {
      url.searchParams.set('scheduleId', scheduleId);
      console.log('Checking for existing schedule-origin report, scheduleId:', scheduleId);
    } else {
      url.searchParams.set('requestId', requestId);
      console.log('Checking for existing service-origin report, requestId:', requestId);
    }
    
    fetch(url.toString())
      .then(response => response.json())
      .then(data => {
        console.log('Check existing report response:', data);
        if (data.exists && data.reportId) {
          if (callback) callback(true, data.reportId);
        } else {
          if (callback) callback(false, null);
        }
      })
      .catch(error => {
        console.error('Error checking for existing report:', error);
        // On error, assume no report exists and continue
        if (callback) callback(false, null);
      });
  }
  
  // Load all available parts when task is selected
  function loadAllAvailableParts(requestId, callback) {
    console.log('=== loadAllAvailableParts called with requestId:', requestId);
    if (!requestId) {
      console.log('No requestId provided, clearing parts list');
      clearPartsList();
      if (callback) callback();
      return;
    }
    
    console.log('Showing loading spinner and fetching parts...');
    showSearchLoading(true);
    
    // Include requestId in URL for server-side validation and cart loading
    const url = contextPath + '/technician/reports?action=searchParts&q=&requestId=' + encodeURIComponent(requestId);
    console.log('Fetching from URL:', url);
    
    // Load all parts (empty query = all parts)
    fetch(url)
      .then(response => {
        console.log('Response status:', response.status);
        console.log('Response content-type:', response.headers.get('content-type'));
        if (!response.ok) {
          throw new Error('HTTP error! status: ' + response.status);
        }
        return response.text();
      })
      .then(text => {
        console.log('Raw response text (first 500 chars):', text.substring(0, Math.min(500, text.length)));
        try {
          const data = JSON.parse(text);
          console.log('Parsed data type:', Array.isArray(data) ? 'Array' : typeof data);
          console.log('Parsed data length:', Array.isArray(data) ? data.length : 'N/A');
          if (Array.isArray(data) && data.length > 0) {
            console.log('First part sample:', data[0]);
          }
          showSearchLoading(false);
          
          // Check if response is an error object
          if (data && typeof data === 'object' && data.error) {
            console.error('Server error:', data.error);
            alert('Error loading parts: ' + data.error);
            allParts = [];
            clearPartsList();
            if (callback) callback();
            return;
          }
          
          // Check if response is an array
          if (Array.isArray(data)) {
            allParts = data;
            console.log('All parts loaded successfully:', allParts.length, 'parts');
            if (allParts.length === 0) {
              console.warn('No parts found in database');
            }
            filterPartsList(partSearchInput?.value || '');
            // Call callback after parts are loaded
            if (callback) callback();
          } else {
            console.error('Unexpected response format. Expected array, got:', typeof data, data);
            allParts = [];
            clearPartsList();
            if (callback) callback();
          }
        } catch (e) {
          console.error('JSON parse error:', e);
          console.error('Response text that failed to parse:', text);
          showSearchLoading(false);
          allParts = [];
          clearPartsList();
          alert('Error parsing server response. Check console for details.');
          if (callback) callback();
        }
      })
      .catch(error => {
        showSearchLoading(false);
        console.error('Load parts fetch error:', error);
        allParts = [];
        clearPartsList();
        alert('Network error loading parts: ' + error.message);
        if (callback) callback();
      });
  }
  
  // Filter parts list (client-side, instant)
  function filterPartsList(query) {
    if (!partsListBody) return;
    
    const searchTerm = query.toLowerCase();
    const filtered = allParts.filter(part => {
      if (!searchTerm) return true;
      const name = (part.partName || '').toLowerCase();
      const serial = (part.serialNumber || '').toLowerCase();
      return name.includes(searchTerm) || serial.includes(searchTerm);
    });
    
    renderPartsList(filtered);
  }
  
  // Render parts in the table
  function renderPartsList(parts) {
    console.log('=== renderPartsList called with', parts?.length || 0, 'parts');
    if (!partsListBody) {
      console.error('❌ partsListBody element not found! Check HTML ID.');
      return;
    }
    
    if (!parts || parts.length === 0) {
      console.log('No parts to render, showing empty message');
      partsListBody.innerHTML = '<tr><td colspan="5" class="text-center text-muted py-4"><i class="bi bi-inbox me-2"></i>No parts found. Please check if parts exist in the database.</td></tr>';
      return;
    }
    
    console.log('✅ Rendering', parts.length, 'parts');
    let html = '';
    let renderedCount = 0;
    parts.forEach(function(part) {
      const partId = part.partId;
      if (!partId) {
        console.warn('⚠️ Part missing partId:', part);
        return;
      }
      renderedCount++;
      const isSelected = selectedParts[partId] != null;
      const selectedQty = isSelected ? selectedParts[partId].quantity : 0;
      
      // Get quantity from cart (server-side session)
      const cartQty = 0; // Will be updated from cart after loadCartFromSession
      
      html += '<tr data-part-id="' + partId + '">';
      html += '<td><strong>' + escapeHtml(part.partName) + '</strong></td>';
      html += '<td class="text-center">' + escapeHtml(part.serialNumber || 'N/A') + '</td>';
      html += '<td class="text-center"><strong class="text-success">₫' + formatVnd(usdToVnd(part.unitPrice)) + '</strong></td>';
      html += '<td class="text-center"><span class="badge bg-success">' + part.availableQuantity + '</span></td>';
      html += '<td class="text-center">';
      html += '<div class="btn-group btn-group-sm" role="group">';
      html += '<button type="button" class="btn btn-outline-secondary qty-minus" data-part-id="' + partId + '" ' + (selectedQty <= 0 ? 'disabled' : '') + '>';
      html += '<i class="bi bi-dash"></i></button>';
      html += '<span class="btn btn-light disabled qty-display" style="min-width: 40px;" data-part-id="' + partId + '">' + selectedQty + '</span>';
      html += '<button type="button" class="btn btn-outline-secondary qty-plus" data-part-id="' + partId + '" ' + (selectedQty >= part.availableQuantity ? 'disabled' : '') + '>';
      html += '<i class="bi bi-plus"></i></button>';
      html += '</div>';
      html += '</td>';
      html += '</tr>';
    });
    
    console.log('✅ Rendered', renderedCount, 'parts in table');
    partsListBody.innerHTML = html;
    
    // Attach event listeners
    attachPartsListListeners();
  }
  
  // Attach listeners to quantity controls
  function attachPartsListListeners() {
    // Plus buttons
    document.querySelectorAll('.qty-plus').forEach(function(btn) {
      btn.addEventListener('click', function(e) {
        e.preventDefault();
        e.stopPropagation();
        const partId = parseInt(this.dataset.partId);
        if (isNaN(partId) || partId <= 0) {
          console.error('Invalid partId in plus button:', this.dataset.partId);
          return false;
        }
        adjustPartQuantity(partId, 1);
        return false;
      });
    });
    
    // Minus buttons
    document.querySelectorAll('.qty-minus').forEach(function(btn) {
      btn.addEventListener('click', function(e) {
        e.preventDefault();
        e.stopPropagation();
        const partId = parseInt(this.dataset.partId);
        if (isNaN(partId) || partId <= 0) {
          console.error('Invalid partId in minus button:', this.dataset.partId);
          return false;
        }
        adjustPartQuantity(partId, -1);
        return false;
      });
    });
  }
  
  // Adjust quantity in the parts list - auto-adds to cart when quantity > 0
  function adjustPartQuantity(partId, delta) {
    const part = allParts.find(p => p.partId === partId);
    if (!part) return;
    
    const currentQty = selectedParts[partId] ? selectedParts[partId].quantity : 0;
    let newQty = currentQty + delta;
    newQty = Math.max(0, Math.min(newQty, part.availableQuantity));
    
    // Update in-memory state
    if (newQty > 0) {
      if (!selectedParts[partId]) {
        selectedParts[partId] = {
          partId: partId,
          partName: part.partName,
          serialNumber: part.serialNumber,
          unitPrice: part.unitPrice,
          quantity: 0
        };
      }
      selectedParts[partId].quantity = newQty;
    } else {
      delete selectedParts[partId];
    }
    
    // Update UI
    const row = partsListBody.querySelector('tr[data-part-id="' + partId + '"]');
    if (row) {
      const qtyDisplay = row.querySelector('.qty-display[data-part-id="' + partId + '"]');
      const minusBtn = row.querySelector('.qty-minus[data-part-id="' + partId + '"]');
      const plusBtn = row.querySelector('.qty-plus[data-part-id="' + partId + '"]');
      
      qtyDisplay.textContent = newQty;
      minusBtn.disabled = (newQty <= 0);
      plusBtn.disabled = (newQty >= part.availableQuantity);
      
      // Auto-add to cart when quantity becomes > 0, or update if already in cart
      if (newQty > 0) {
        // Check if this is an increase (delta > 0) or if it's a new addition
        if (delta > 0 || currentQty === 0) {
          addPartToCart(partId, newQty);
        } else {
          // Quantity decreased, update cart
          addPartToCart(partId, newQty);
        }
      } else if (newQty === 0 && currentQty > 0) {
        // Quantity reduced to 0, remove from cart
        removePartFromCart(partId, false); // false = no confirm dialog
      }
    }
  }
  
  // Clear parts list
  function clearPartsList() {
    allParts = [];
    if (partsListBody) {
      partsListBody.innerHTML = '<tr><td colspan="5" class="text-center text-muted py-4"><i class="bi bi-search me-2"></i>Select a task first to load available parts</td></tr>';
    }
  }
  
  // Contract selection functions removed - contract is automatically determined from ServiceRequest
  
  // ============================================
  // UTILITY FUNCTIONS
  // ============================================
  
  function showSearchLoading(loading) {
    if (loading) {
      searchIcon.classList.add('d-none');
      searchSpinner.classList.remove('d-none');
    } else {
      searchIcon.classList.remove('d-none');
      searchSpinner.classList.add('d-none');
    }
  }
  
  // ============================================
  // CART MANAGEMENT
  // ============================================
  
  function addPartToCart(partId, quantity) {
    // Check both select (create) and input (edit) for requestId
    const requestId = requestIdInput?.value || '';
    const scheduleId = scheduleIdInput?.value || '';
    if (!requestId && !scheduleId) {
      alert('Please select a task before adding parts to cart.');
      return;
    }
    
    const part = allParts.find(p => p.partId === partId);
    if (!part) {
      console.error('Part not found:', partId);
      return;
    }
    
    if (quantity <= 0) {
      console.log('Quantity is 0, skipping add to cart');
      return;
    }
    
    console.log('Adding part', partId, 'quantity', quantity, 'to cart');
    
    // AJAX request to add/update part in cart
    const addUrl = new URL(contextPath + '/technician/reports', window.location.origin);
    addUrl.searchParams.set('action','addPartAjax');
    addUrl.searchParams.set('partId', partId);
    addUrl.searchParams.set('quantity', quantity);
    if (requestId) addUrl.searchParams.set('requestId', requestId);
    if (scheduleId) addUrl.searchParams.set('scheduleId', scheduleId);
    fetch(addUrl.toString())
      .then(response => {
        if (!response.ok) {
          throw new Error('HTTP error! status: ' + response.status);
        }
        return response.json();
      })
      .then(data => {
        console.log('Add part response:', data);
        if (data.success) {
          // Reload cart from session to update display
          loadCartFromSession();
        } else {
          console.error('Add part failed:', data.error);
          alert('Error: ' + (data.error || 'Failed to add part'));
          // Revert quantity in UI
          const row = partsListBody.querySelector('tr[data-part-id="' + partId + '"]');
          if (row) {
            const qtyDisplay = row.querySelector('.qty-display[data-part-id="' + partId + '"]');
            if (qtyDisplay) {
              const currentCartQty = 0; // Will be updated by loadCartFromSession
              qtyDisplay.textContent = currentCartQty;
            }
          }
        }
      })
      .catch(error => {
        console.error('Add part error:', error);
        alert('Network error: Could not add part to cart. ' + error.message);
        // Revert quantity in UI
        const row = partsListBody.querySelector('tr[data-part-id="' + partId + '"]');
        if (row) {
          const qtyDisplay = row.querySelector('.qty-display[data-part-id="' + partId + '"]');
          if (qtyDisplay) {
            qtyDisplay.textContent = '0';
          }
        }
      });
  }
  
  function removePartFromCart(partId, showConfirm = true) {
    if (showConfirm && !confirm('Remove this part from cart?')) {
      return;
    }
    
    // Validate partId
    if (!partId || isNaN(partId) || partId <= 0) {
      console.error('Invalid partId:', partId);
      alert('Invalid part ID. Please refresh the page and try again.');
      return;
    }
    
    // Check both select (create) and input (edit) for requestId
    const requestId = requestIdInput?.value || '';
    const scheduleId = scheduleIdInput?.value || '';
    
    if (!requestId && !scheduleId) {
      console.error('Cannot remove part: No requestId selected');
      alert('Please select a task first');
      return;
    }
    
    console.log('Removing part', partId, '(type:', typeof partId, ') from cart for request', requestId, '(type:', typeof requestId, ')');
    
    // AJAX request to remove part
    const url = new URL(contextPath + '/technician/reports', window.location.origin);
    url.searchParams.set('action','removePartAjax');
    url.searchParams.set('partId', partId);
    if (requestId) url.searchParams.set('requestId', requestId);
    if (scheduleId) url.searchParams.set('scheduleId', scheduleId);
    console.log('Remove URL:', url);
    
    fetch(url)
      .then(response => {
        console.log('Remove response status:', response.status);
        if (!response.ok) {
          throw new Error('HTTP error! status: ' + response.status);
        }
        return response.json();
      })
      .then(data => {
        console.log('Remove response data:', data);
        if (data.success) {
          // Reset quantity in parts list to 0
          delete selectedParts[partId];
          
          // Update the quantity display in the parts list
          const row = partsListBody.querySelector('tr[data-part-id="' + partId + '"]');
          if (row) {
            const qtyDisplay = row.querySelector('.qty-display[data-part-id="' + partId + '"]');
            const minusBtn = row.querySelector('.qty-minus[data-part-id="' + partId + '"]');
            const plusBtn = row.querySelector('.qty-plus[data-part-id="' + partId + '"]');
            
            if (qtyDisplay) qtyDisplay.textContent = '0';
            if (minusBtn) minusBtn.disabled = true;
            if (plusBtn) {
              const part = allParts.find(p => p.partId === partId);
              if (part) {
                plusBtn.disabled = (0 >= part.availableQuantity);
              }
            }
          }
          
          // Update cart display immediately with the new subtotal from response
          const newSubtotal = data.subtotal || 0;
          const newPartsCount = data.partsCount || 0;
          
          // Reload full cart to get updated parts list
          loadCartFromSession();
          
          // Also update estimated cost immediately (convert USD to VND)
          if (estimatedCostInput) {
            const vndAmount = Math.round(usdToVnd(newSubtotal));
            estimatedCostInput.value = (isScheduleOrigin || isWarrantyMode) ? 0 : vndAmount;
          }
        } else {
          alert('Error: ' + (data.error || 'Failed to remove part'));
        }
      })
      .catch(error => {
        console.error('Remove part error:', error);
        alert('Network error: Could not remove part. ' + error.message);
      });
  }
  
  function clearCartAjax() {
    // Clear all parts from cart when changing request
    // Check both select (create) and input (edit) for requestId
    const requestId = requestIdInput?.value || '';
    const scheduleId = scheduleIdInput?.value || '';
    const clrUrl = new URL(contextPath + '/technician/reports', window.location.origin);
    clrUrl.searchParams.set('action','clearCartAjax');
    if (requestId) clrUrl.searchParams.set('requestId', requestId);
    if (scheduleId) clrUrl.searchParams.set('scheduleId', scheduleId);
    return fetch(clrUrl.toString())
      .then(response => response.json())
      .then(data => {
        if (data.success) {
          // Reset all quantities in parts list
          selectedParts = {};
          // Re-render parts list to reset all quantities
          filterPartsList(partSearchInput?.value || '');
          // Update cart display
          updateCartDisplay([], 0);
        }
        return data;
      })
      .catch(error => {
        console.error('Clear cart error:', error);
        throw error;
      });
  }
  
  function loadCartFromSession() {
    const requestId = requestIdInput?.value || '';
    const scheduleId = scheduleIdInput?.value || '';
    loadCartFromSessionForRequest(requestId || scheduleId);
  }
  
  function loadCartFromSessionForRequest(id) {
    if (!id) {
      // If no request ID yet, show empty cart
      updateCartDisplay([], 0);
      return;
    }
    
    // AJAX request to get cart summary
    const reqId = requestIdInput?.value || '';
    const scheduleId = scheduleIdInput?.value || '';
    const url = new URL(contextPath + '/technician/reports', window.location.origin);
    url.searchParams.set('action','getCartSummary');
    if (reqId) url.searchParams.set('requestId', reqId);
    if (scheduleId) url.searchParams.set('scheduleId', scheduleId);
    fetch(url.toString())
      .then(response => response.json())
      .then(data => {
        if (data.success) {
          updateCartDisplay(data.parts || [], data.subtotal || 0);
        }
      })
      .catch(error => {
        console.error('Load cart error:', error);
      });
  }
  
  function updateCartDisplay(parts, subtotal) {
    // Calculate total quantity
    const totalQty = parts.reduce((sum, part) => sum + (part.quantity || 0), 0);
    
    // Update summary numbers
    if (selectedPartsCount) {
      selectedPartsCount.textContent = totalQty;
    }
    if (totalCost) {
      const vndAmount = usdToVnd(subtotal || 0);
      totalCost.textContent = '₫' + formatVnd(vndAmount);
    }
    
    // Update estimated cost input (sync) - always update, even when 0
    // Convert USD to VND for display
    if (estimatedCostInput) {
      const vndAmount = Math.round(usdToVnd(subtotal || 0));
      estimatedCostInput.setAttribute('data-last-service-value', vndAmount);
      if (isWarrantyMode || isScheduleOrigin) {
        estimatedCostInput.value = 0;
      } else {
        estimatedCostInput.value = vndAmount;
      }
    }
    
    // Contract requirement update removed - contract is automatically determined from ServiceRequest
    
    // Update selected parts list
    if (!selectedPartsList) return;
    
    if (parts.length === 0) {
      selectedPartsList.innerHTML = '<div class="list-group-item text-center text-muted py-4" id="emptyCartMessage"><i class="bi bi-cart-x me-2"></i>No parts selected yet</div>';
    } else {
      let html = '';
      parts.forEach(function(part) {
        // Ensure partId is a valid number
        const partId = parseInt(part.partId);
        if (isNaN(partId) || partId <= 0) {
          console.error('Invalid partId in cart part:', part);
          return; // Skip this part
        }
        
        const lineTotalUsd = part.unitPrice * part.quantity;
        const unitPriceVnd = usdToVnd(part.unitPrice);
        const lineTotalVnd = usdToVnd(lineTotalUsd);
        html += '<div class="list-group-item d-flex justify-content-between align-items-start">';
        html += '<div class="flex-grow-1">';
        html += '<div class="fw-bold">' + escapeHtml(part.partName) + '</div>';
        html += '<div class="text-muted small">S/N: ' + escapeHtml(part.serialNumber || 'N/A') + '</div>';
        html += '<div class="text-muted small">';
        html += '₫' + formatVnd(unitPriceVnd) + ' × ' + part.quantity + ' = <strong>₫' + formatVnd(lineTotalVnd) + '</strong>';
        html += '</div>';
        html += '</div>';
        html += '<button type="button" class="btn btn-sm btn-outline-danger ms-2 remove-part-btn" data-part-id="' + partId + '" title="Remove">';
        html += '<i class="bi bi-trash"></i>';
        html += '</button>';
        html += '</div>';
      });
      selectedPartsList.innerHTML = html;
      
      // Attach remove button listeners
      document.querySelectorAll('.remove-part-btn').forEach(function(btn) {
        btn.addEventListener('click', function(e) {
          e.preventDefault(); // Prevent any default behavior
          e.stopPropagation(); // Stop event bubbling
          
          const partIdStr = this.dataset.partId;
          console.log('Remove button clicked, partId from dataset:', partIdStr, 'type:', typeof partIdStr);
          const partId = parseInt(partIdStr);
          console.log('Parsed partId:', partId, 'isNaN:', isNaN(partId));
          if (isNaN(partId) || partId <= 0) {
            console.error('Invalid partId:', partIdStr);
            alert('Invalid part ID. Please refresh the page and try again.');
            return false;
          }
          removePartFromCart(partId, true); // true = show confirm dialog
          return false; // Prevent any further action
        });
      });
      
      // Update selectedParts object to match cart
      selectedParts = {};
      parts.forEach(function(cartPart) {
        selectedParts[cartPart.partId] = {
          partId: cartPart.partId,
          partName: cartPart.partName,
          serialNumber: cartPart.serialNumber,
          unitPrice: cartPart.unitPrice,
          quantity: cartPart.quantity
        };
      });
      
      // Re-render parts list to show updated quantities
      if (allParts.length > 0) {
        filterPartsList(partSearchInput?.value || '');
      }
      
      // Update quantity displays in parts list to match cart
      if (partsListBody && allParts.length > 0) {
        parts.forEach(function(cartPart) {
          const row = partsListBody.querySelector('tr[data-part-id="' + cartPart.partId + '"]');
          if (row) {
            const qtyDisplay = row.querySelector('.qty-display[data-part-id="' + cartPart.partId + '"]');
            const minusBtn = row.querySelector('.qty-minus[data-part-id="' + cartPart.partId + '"]');
            const plusBtn = row.querySelector('.qty-plus[data-part-id="' + cartPart.partId + '"]');
            const part = allParts.find(p => p.partId === cartPart.partId);
            
            if (qtyDisplay) qtyDisplay.textContent = cartPart.quantity;
            if (minusBtn) minusBtn.disabled = (cartPart.quantity <= 0);
            if (plusBtn && part) {
              plusBtn.disabled = (cartPart.quantity >= part.availableQuantity);
            }
            
            // Update in-memory state
            selectedParts[cartPart.partId] = {
              partId: cartPart.partId,
              partName: cartPart.partName,
              serialNumber: cartPart.serialNumber,
              unitPrice: cartPart.unitPrice,
              quantity: cartPart.quantity
            };
          }
        });
      }
    }
  }
  
  // ============================================
  // UTILITY FUNCTIONS
  // ============================================
  
  function escapeHtml(text) {
    if (!text) return '';
    const map = {
      '&': '&amp;',
      '<': '&lt;',
      '>': '&gt;',
      '"': '&quot;',
      "'": '&#039;'
    };
    return text.toString().replace(/[&<>"']/g, function(m) { return map[m]; });
  }
  
  // ============================================
  // FORM VALIDATION
  // ============================================
  
  // Ensure at least one part is selected before submit
  const reportForm = document.getElementById('reportForm');
  if (reportForm) {
    reportForm.addEventListener('submit', function(e) {
      const partsCount = selectedPartsCount ? parseInt(selectedPartsCount.textContent) || 0 : 0;
      if (!isWarrantyMode && partsCount <= 0) {
        e.preventDefault();
        alert('Please select at least one part for the repair report.');
        return false;
      }
      if (isWarrantyMode && estimatedCostInput) {
        estimatedCostInput.value = 0;
      }
      
      // Server will handle VND to USD conversion
      // The form submits VND value, server converts it to USD before saving
      // Contract validation removed - contract is automatically determined from ServiceRequest
    });
  }
  
})();
</script>
