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
            <c:if test="${not empty report}">
              <input type="hidden" name="reportId" value="${report.reportId}">
            </c:if>
            <c:choose>
              <c:when test="${not empty report}">
                <!-- Edit mode: show existing request ID as readonly -->
                <input type="hidden" name="requestId" value="${report.requestId}">
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
                <!-- Create mode: show dropdown for assigned tasks -->
                <div class="row">
                  <div class="col-md-6">
                    <div class="mb-3">
                      <label for="requestId" class="form-label fw-bold">Select Task <span class="text-danger">*</span></label>
                      <select class="form-select" id="requestId" name="requestId" required>
                        <option value="">-- Select a task to report on --</option>
                        <c:forEach var="task" items="${assignedTasks}">
                          <option value="${task.requestId}" 
                                  <c:if test="${requestId != null && requestId == task.requestId}">selected</c:if>>
                            #${task.requestId} - ${task.taskType} (${task.status})
                          </option>
                        </c:forEach>
                      </select>
                      <div class="form-text">Only tasks assigned to you and not completed are shown</div>
                      <div class="invalid-feedback" id="requestIdError"></div>
                    </div>
                  </div>
              </c:otherwise>
            </c:choose>
            
            <div class="row">
              <div class="col-md-6">
                <div class="mb-3">
                  <label for="quotationStatus" class="form-label fw-bold">Quotation Status</label>
                  <input type="text" class="form-control" id="quotationStatus" 
                         value="${not empty report ? report.quotationStatus : 'Pending'}" readonly>
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
            
            <div class="mb-3">
              <label for="diagnosis" class="form-label fw-bold">Diagnosis <span class="text-danger">*</span></label>
              <textarea class="form-control" id="diagnosis" name="diagnosis" rows="3" 
                        placeholder="Describe the problem diagnosis..." 
                        maxlength="255" required>${not empty report ? fn:escapeXml(report.diagnosis) : ''}</textarea>
              <div class="form-text">
                <span id="diagnosisCount">0</span>/255 characters
              </div>
              <div class="invalid-feedback" id="diagnosisError"></div>
            </div>
            
            <div class="row">
              <div class="col-md-6">
                <div class="mb-3">
                  <label for="estimatedCost" class="form-label fw-bold">Estimated Cost <span class="text-danger">*</span></label>
                  <div class="input-group">
                    <span class="input-group-text">$</span>
                    <input type="number" class="form-control" id="estimatedCost" name="estimatedCost" 
                           step="0.01" min="0.01" max="999999.99" 
                           placeholder="0.00" required
                           value="${not empty report ? report.estimatedCost : ''}">
                  </div>
                  <div class="form-text">Enter cost in USD (e.g., 150.50)</div>
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
document.addEventListener('DOMContentLoaded', function() {
    const form = document.getElementById('reportForm');
    const detailsField = document.getElementById('details');
    const diagnosisField = document.getElementById('diagnosis');
    const estimatedCostField = document.getElementById('estimatedCost');
    const repairDateField = document.getElementById('repairDate');
    const requestIdField = document.getElementById('requestId');
    
    // Character counters
    function updateCharCount(field, counterId) {
        const counter = document.getElementById(counterId);
        counter.textContent = field.value.length;
    }
    
    detailsField.addEventListener('input', () => updateCharCount(detailsField, 'detailsCount'));
    diagnosisField.addEventListener('input', () => updateCharCount(diagnosisField, 'diagnosisCount'));
    
    // Initialize counters
    updateCharCount(detailsField, 'detailsCount');
    updateCharCount(diagnosisField, 'diagnosisCount');
    
    // Set minimum date to today
    const today = new Date().toISOString().split('T')[0];
    repairDateField.setAttribute('min', today);
    
    // Form validation
    form.addEventListener('submit', function(e) {
        e.preventDefault();
        
        let isValid = true;
        let firstError = '';
        
        // Clear previous validation
        clearValidation();
        
        // Validate request ID (only for create mode)
        if (requestIdField) {
            const requestIdValidation = validateRequestId(requestIdField.value);
            if (!requestIdValidation.isValid) {
                showFieldError(requestIdField, 'requestIdError', requestIdValidation.error);
                isValid = false;
                if (!firstError) firstError = requestIdValidation.error;
            }
        }
        
        // Validate details
        const detailsValidation = validateDetails(detailsField.value);
        if (!detailsValidation.isValid) {
            showFieldError(detailsField, 'detailsError', detailsValidation.error);
            isValid = false;
            if (!firstError) firstError = detailsValidation.error;
        }
        
        // Validate diagnosis
        const diagnosisValidation = validateDiagnosis(diagnosisField.value);
        if (!diagnosisValidation.isValid) {
            showFieldError(diagnosisField, 'diagnosisError', diagnosisValidation.error);
            isValid = false;
            if (!firstError) firstError = diagnosisValidation.error;
        }
        
        // Validate estimated cost
        const costValidation = validateEstimatedCost(estimatedCostField.value);
        if (!costValidation.isValid) {
            showFieldError(estimatedCostField, 'estimatedCostError', costValidation.error);
            isValid = false;
            if (!firstError) firstError = costValidation.error;
        }
        
        // Validate repair date
        const dateValidation = validateRepairDate(repairDateField.value);
        if (!dateValidation.isValid) {
            showFieldError(repairDateField, 'repairDateError', dateValidation.error);
            isValid = false;
            if (!firstError) firstError = dateValidation.error;
        }
        
        if (!isValid) {
            showValidationModal(firstError);
            return;
        }
        
        // Submit form if valid
        form.submit();
    });
    
    // Add event listener for modal OK button to allow retry
    document.getElementById('validationModal').addEventListener('hidden.bs.modal', function() {
        // Focus on the first invalid field to help user continue editing
        const firstInvalidField = document.querySelector('.is-invalid');
        if (firstInvalidField) {
            firstInvalidField.focus();
        }
    });
    
    // Additional event listener for OK button click
    document.getElementById('validationModal').addEventListener('click', function(e) {
        if (e.target.classList.contains('btn-primary') && e.target.textContent.trim() === 'OK') {
            const modal = bootstrap.Modal.getInstance(this);
            if (modal) {
                modal.hide();
            }
        }
    });
    
    function clearValidation() {
        document.querySelectorAll('.is-invalid').forEach(field => field.classList.remove('is-invalid'));
        document.querySelectorAll('.invalid-feedback').forEach(feedback => feedback.textContent = '');
    }
    
    function showFieldError(field, errorId, message) {
        field.classList.add('is-invalid');
        document.getElementById(errorId).textContent = message;
    }
    
    function showValidationModal(message) {
        document.getElementById('validationMessage').innerHTML = 
            '<div class="alert alert-danger mb-0"><i class="bi bi-exclamation-triangle me-2"></i>' + message + '</div>';
        document.getElementById('validationExample').innerHTML = getExampleText(message);
        
        const modalElement = document.getElementById('validationModal');
        const modal = new bootstrap.Modal(modalElement);
        modal.show();
        
        // Ensure OK button properly closes modal
        const okButton = modalElement.querySelector('[data-bs-dismiss="modal"]');
        if (okButton) {
            okButton.addEventListener('click', function() {
                modal.hide();
            });
        }
        
        // Fallback: Close modal when clicking outside or pressing Escape
        modalElement.addEventListener('click', function(e) {
            if (e.target === modalElement) {
                modal.hide();
            }
        });
    }
    
    // Validation functions matching server-side rules
    function validateRequestId(value) {
        if (!value || !value.trim()) {
            return { isValid: false, error: 'Please select a task to report on' };
        }
        return { isValid: true };
    }
    
    function validateDetails(value) {
        if (!value || !value.trim()) {
            return { isValid: false, error: 'Details is required' };
        }
        const trimmed = value.trim();
        if (trimmed.length > 255) {
            return { isValid: false, error: 'Details must be 255 characters or less' };
        }
        // Allow Unicode characters (including Vietnamese) and common punctuation
        const validPattern = /^[\p{L}\p{N}\s,.\-()!?;:'"]*$/u;
        if (!validPattern.test(trimmed)) {
            // Debug: log the actual characters that are causing issues
            console.log('Invalid characters detected in:', trimmed);
            console.log('Character codes:', Array.from(trimmed).map(c => c.charCodeAt(0)));
            return { isValid: false, error: 'Details can only contain letters, numbers, spaces, and these characters: , . - ( ) ! ? ; : \' "' };
        }
        return { isValid: true };
    }
    
    function validateDiagnosis(value) {
        if (!value || !value.trim()) {
            return { isValid: false, error: 'Diagnosis is required' };
        }
        const trimmed = value.trim();
        if (trimmed.length > 255) {
            return { isValid: false, error: 'Diagnosis must be 255 characters or less' };
        }
        // Allow Unicode characters (including Vietnamese) and common punctuation
        const validPattern = /^[\p{L}\p{N}\s,.\-()!?;:'"]*$/u;
        if (!validPattern.test(trimmed)) {
            // Debug: log the actual characters that are causing issues
            console.log('Invalid characters detected in diagnosis:', trimmed);
            console.log('Character codes:', Array.from(trimmed).map(c => c.charCodeAt(0)));
            return { isValid: false, error: 'Diagnosis can only contain letters, numbers, spaces, and these characters: , . - ( ) ! ? ; : \' "' };
        }
        return { isValid: true };
    }
    
    function validateEstimatedCost(value) {
        if (!value || !value.trim()) {
            return { isValid: false, error: 'Estimated cost is required' };
        }
        if (!/^\d+(\.\d{1,2})?$/.test(value.trim())) {
            return { isValid: false, error: 'Estimated cost must be a valid number (e.g., 1500.00)' };
        }
        const cost = parseFloat(value);
        if (cost <= 0) {
            return { isValid: false, error: 'Estimated cost must be greater than 0' };
        }
        if (cost > 999999.99) {
            return { isValid: false, error: 'Estimated cost cannot exceed 999,999.99' };
        }
        return { isValid: true };
    }
    
    function validateRepairDate(value) {
        if (!value || !value.trim()) {
            return { isValid: false, error: 'Repair date is required' };
        }
        
        const repairDate = new Date(value);
        if (isNaN(repairDate.getTime())) {
            return { isValid: false, error: 'Invalid date format. Please use YYYY-MM-DD format' };
        }
        
        // Check if this is an edit operation (update existing report)
        const isEditMode = document.querySelector('input[name="action"]').value === 'update';
        
        if (isEditMode) {
            // For existing reports, repair date should not be changed
            // The date field should be disabled, but if somehow it's not, we allow any valid date
            return { isValid: true };
        } else {
            // For new reports, repair date cannot be in the past
            const today = new Date();
            today.setHours(0, 0, 0, 0);
            
            if (repairDate < today) {
                return { isValid: false, error: 'Repair date cannot be in the past' };
            }
            
            const maxDate = new Date(today);
            maxDate.setFullYear(maxDate.getFullYear() + 1);
            if (repairDate > maxDate) {
                return { isValid: false, error: 'Repair date cannot be more than 1 year in the future' };
            }
        }
        
        return { isValid: true };
    }
    
    function getExampleText(errorMessage) {
        if (errorMessage.includes('task') || errorMessage.includes('select')) {
            return '<strong>Example:</strong> Select a task from the dropdown list';
        } else if (errorMessage.includes('Details')) {
            return '<strong>Example:</strong> Equipment malfunction, replaced faulty component';
        } else if (errorMessage.includes('Diagnosis')) {
            return '<strong>Example:</strong> Motor overheating due to worn bearings';
        } else if (errorMessage.includes('cost')) {
            return '<strong>Example:</strong> 1500.00';
        } else if (errorMessage.includes('date')) {
            return '<strong>Example:</strong> 2024-12-25';
        }
        return '<strong>Example:</strong> Please provide valid input';
    }
});
</script>
