<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<div class="container-fluid">
  <!-- Success/Error Messages -->
  <c:if test="${not empty successMessage}">
    <div class="alert alert-success alert-dismissible fade show" role="alert">
      <i class="bi bi-check-circle me-2"></i>${successMessage}
      <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
  </c:if>
  
  <c:if test="${not empty errorMessage}">
    <div class="alert alert-danger alert-dismissible fade show" role="alert">
      <i class="bi bi-exclamation-triangle me-2"></i>${errorMessage}
      <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
  </c:if>

  <div class="row mb-3 align-items-center">
    <div class="col">
      <h1 class="h4 crm-page-title">Create New Contract</h1>
      <p class="text-muted">Create a new equipment contract for customer</p>
    </div>
    <div class="col-auto">
      <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/technician/contracts">
        <i class="bi bi-arrow-left me-1"></i>Back to Contracts
      </a>
    </div>
  </div>

  <div class="card crm-card-shadow">
    <div class="card-header">
      <h5 class="mb-0">Contract Information</h5>
    </div>
    <div class="card-body">
      <form id="contractForm" action="${pageContext.request.contextPath}/technician/contracts" method="POST" novalidate>
        <input type="hidden" name="action" value="create">
        
        <div class="row">
          <div class="col-md-6">
            <div class="mb-3">
              <label for="customerId" class="form-label fw-bold">Customer <span class="text-danger">*</span></label>
              <select class="form-select" id="customerId" name="customerId" required>
                <option value="">Select Customer</option>
                <c:forEach var="customer" items="${customers}">
                  <option value="${customer.accountId}">${customer.fullName} (ID: ${customer.accountId})</option>
                </c:forEach>
              </select>
              <div class="invalid-feedback">Please select a customer.</div>
            </div>
          </div>
          
          <div class="col-md-6">
            <div class="mb-3">
              <label for="contractType" class="form-label fw-bold">Contract Type <span class="text-danger">*</span></label>
              <select class="form-select" id="contractType" name="contractType" required>
                <option value="">Select Type</option>
                <option value="Equipment Lease">Equipment Lease</option>
                <option value="Equipment Purchase">Equipment Purchase</option>
                <option value="Maintenance Agreement">Maintenance Agreement</option>
                <option value="Service Contract">Service Contract</option>
              </select>
              <div class="invalid-feedback">Please select a contract type.</div>
            </div>
          </div>
        </div>
        
        <div class="mb-3">
          <label for="description" class="form-label fw-bold">Description <span class="text-danger">*</span></label>
          <textarea class="form-control" id="description" name="description" rows="3" 
                    placeholder="Describe the contract details..." maxlength="500" required></textarea>
          <div class="form-text">Maximum 500 characters</div>
          <div class="invalid-feedback">Please provide a description (max 500 characters).</div>
        </div>
        
        <div class="row">
          <div class="col-md-6">
            <div class="mb-3">
              <label for="contractDate" class="form-label fw-bold">Contract Date <span class="text-danger">*</span></label>
              <input type="date" class="form-control" id="contractDate" name="contractDate" required>
              <div class="invalid-feedback">Please select a contract date.</div>
            </div>
          </div>
          
          <div class="col-md-6">
            <div class="mb-3">
              <label for="status" class="form-label fw-bold">Status <span class="text-danger">*</span></label>
              <select class="form-select" id="status" name="status" required>
                <option value="">Select Status</option>
                <option value="Active">Active</option>
                <option value="Completed">Completed</option>
                <option value="Cancelled">Cancelled</option>
              </select>
              <div class="invalid-feedback">Please select a status.</div>
            </div>
          </div>
        </div>
        
        <!-- Equipment Selection -->
        <div class="mb-3">
          <label for="equipmentId" class="form-label fw-bold">Equipment Assignment (Optional)</label>
          <select class="form-select" id="equipmentId" name="equipmentId">
            <option value="">No Equipment Assignment</option>
            <c:forEach var="equipment" items="${availableEquipment}">
              <option value="${equipment.equipmentId}" 
                      data-model="${fn:escapeXml(equipment.model)}"
                      data-serial="${fn:escapeXml(equipment.serialNumber)}"
                      data-location="${fn:escapeXml(equipment.location)}"
                      data-price="${equipment.unitPrice}">
                ${fn:escapeXml(equipment.model)} - ${fn:escapeXml(equipment.serialNumber)} 
                <c:if test="${equipment.location != null && !equipment.location.isEmpty()}">
                  (Location: ${fn:escapeXml(equipment.location)})
                </c:if>
                - $${equipment.unitPrice}
              </option>
            </c:forEach>
          </select>
          <div class="form-text">
            <i class="bi bi-info-circle me-1"></i>
            Only available equipment from inventory is shown. Equipment will be marked as "In Use" when assigned to contract.
          </div>
        </div>
        
        <!-- Equipment Details Preview -->
        <div id="equipmentPreview" class="card mt-3" style="display: none;">
          <div class="card-header">
            <h6 class="mb-0"><i class="bi bi-gear me-1"></i>Selected Equipment Details</h6>
          </div>
          <div class="card-body">
            <div class="row">
              <div class="col-md-6">
                <strong>Model:</strong> <span id="previewModel"></span><br>
                <strong>Serial Number:</strong> <span id="previewSerial"></span>
              </div>
              <div class="col-md-6">
                <strong>Location:</strong> <span id="previewLocation"></span><br>
                <strong>Unit Price:</strong> <span id="previewPrice"></span>
              </div>
            </div>
          </div>
        </div>
        
        <div class="d-flex justify-content-end gap-2">
          <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/technician/contracts">
            Cancel
          </a>
          <button type="submit" class="btn btn-success">
            <i class="bi bi-check-circle me-1"></i>Create Contract
          </button>
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
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        <div id="errorMessage"></div>
        <div id="errorExample" class="mt-2 text-muted"></div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
      </div>
    </div>
  </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const form = document.getElementById('contractForm');
    const contractDateInput = document.getElementById('contractDate');
    const equipmentSelect = document.getElementById('equipmentId');
    const equipmentPreview = document.getElementById('equipmentPreview');
    
    // Set minimum date to today
    const today = new Date().toISOString().split('T')[0];
    contractDateInput.min = today;
    
    // Handle equipment selection preview
    equipmentSelect.addEventListener('change', function() {
        const selectedOption = this.options[this.selectedIndex];
        
        if (this.value && selectedOption.dataset.model) {
            // Show equipment preview
            document.getElementById('previewModel').textContent = selectedOption.dataset.model;
            document.getElementById('previewSerial').textContent = selectedOption.dataset.serial;
            document.getElementById('previewLocation').textContent = selectedOption.dataset.location || 'Not specified';
            document.getElementById('previewPrice').textContent = '$' + parseFloat(selectedOption.dataset.price).toFixed(2);
            equipmentPreview.style.display = 'block';
        } else {
            // Hide equipment preview
            equipmentPreview.style.display = 'none';
        }
    });
    
    form.addEventListener('submit', function(e) {
        e.preventDefault();
        
        if (validateForm()) {
            form.submit();
        }
    });
    
    function validateForm() {
        let isValid = true;
        const errors = [];
        
        // Clear previous validation
        form.classList.remove('was-validated');
        document.querySelectorAll('.is-invalid').forEach(el => el.classList.remove('is-invalid'));
        
        // Validate customer selection
        const customerId = document.getElementById('customerId').value;
        if (!customerId) {
            showFieldError('customerId', 'Please select a customer.');
            errors.push('Customer selection is required');
            isValid = false;
        }
        
        // Validate contract type
        const contractType = document.getElementById('contractType').value;
        if (!contractType) {
            showFieldError('contractType', 'Please select a contract type.');
            errors.push('Contract type selection is required');
            isValid = false;
        }
        
        // Validate description
        const description = document.getElementById('description').value.trim();
        if (!description) {
            showFieldError('description', 'Please provide a description.');
            errors.push('Description is required');
            isValid = false;
        } else if (description.length > 500) {
            showFieldError('description', 'Description must be 500 characters or less.');
            errors.push('Description is too long (max 500 characters)');
            isValid = false;
        }
        
        // Validate contract date
        const contractDate = document.getElementById('contractDate').value;
        if (!contractDate) {
            showFieldError('contractDate', 'Please select a contract date.');
            errors.push('Contract date is required');
            isValid = false;
        }
        
        // Validate status
        const status = document.getElementById('status').value;
        if (!status) {
            showFieldError('status', 'Please select a status.');
            errors.push('Status selection is required');
            isValid = false;
        }
        
        if (!isValid) {
            showErrorModal(errors);
        }
        
        return isValid;
    }
    
    function showFieldError(fieldId, message) {
        const field = document.getElementById(fieldId);
        field.classList.add('is-invalid');
        const feedback = field.nextElementSibling;
        if (feedback && feedback.classList.contains('invalid-feedback')) {
            feedback.textContent = message;
        }
    }
    
    function showErrorModal(errors) {
        const errorMessage = document.getElementById('errorMessage');
        const errorExample = document.getElementById('errorExample');
        
        errorMessage.innerHTML = '<ul class="mb-0"><li>' + errors.join('</li><li>') + '</li></ul>';
        errorExample.innerHTML = '<strong>Example:</strong> Select a customer, choose contract type, provide description, set contract date, and select status.';
        
        const modalElement = document.getElementById('errorModal');
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
    
    // Add event listener for modal OK button to allow retry
    document.getElementById('errorModal').addEventListener('hidden.bs.modal', function() {
        // Focus on the first invalid field to help user continue editing
        const firstInvalidField = document.querySelector('.is-invalid');
        if (firstInvalidField) {
            firstInvalidField.focus();
        }
    });
    
    // Additional event listener for Close button click
    document.getElementById('errorModal').addEventListener('click', function(e) {
        if (e.target.classList.contains('btn-secondary') && e.target.textContent.trim() === 'Close') {
            const modal = bootstrap.Modal.getInstance(this);
            if (modal) {
                modal.hide();
            }
        }
    });
});
</script>
