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
      <h1 class="h4 crm-page-title">Tạo hợp đồng mới</h1>
      <p class="text-muted">Tạo hợp đồng mới cho khách hàng với linh kiện bắt buộc</p>
    </div>
    <div class="col-auto">
      <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/technician/contracts">
        <i class="bi bi-arrow-left me-1"></i>Quay lại hợp đồng
      </a>
    </div>
  </div>

  <div class="card crm-card-shadow">
    <div class="card-header">
      <h5 class="mb-0">Thông tin hợp đồng</h5>
    </div>
    <div class="card-body">
      <form id="contractForm" action="${pageContext.request.contextPath}/technician/contracts" method="POST" novalidate>
        <input type="hidden" name="action" value="create">
        
        <div class="row">
          <div class="col-md-6">
            <div class="mb-3">
              <label for="customerId" class="form-label fw-bold">Khách hàng <span class="text-danger">*</span></label>
              <select class="form-select" id="customerId" name="customerId" required>
                <option value="">Chọn khách hàng</option>
                <c:forEach var="customer" items="${customers}">
                  <option value="${customer.accountId}">${customer.fullName} (ID: ${customer.accountId})</option>
                </c:forEach>
              </select>
              <div class="invalid-feedback">Vui lòng chọn khách hàng.</div>
            </div>
          </div>
          
          <div class="col-md-6">
            <div class="mb-3">
              <label for="contractType" class="form-label fw-bold">Loại hợp đồng <span class="text-danger">*</span></label>
              <select class="form-select" id="contractType" name="contractType" required>
                <option value="">Chọn loại</option>
                <option value="Equipment Warranty Return">Trả thiết bị bảo hành</option>
                <option value="Equipment Purchase">Mua thiết bị</option>
              </select>
              <div class="invalid-feedback">Vui lòng chọn loại hợp đồng.</div>
            </div>
          </div>
        </div>
        
        <div class="mb-3">
          <label for="description" class="form-label fw-bold">Mô tả <span class="text-danger">*</span></label>
          <textarea class="form-control" id="description" name="description" rows="3" 
                    placeholder="Mô tả chi tiết hợp đồng..." maxlength="500" required></textarea>
          <div class="form-text">Tối đa 500 ký tự</div>
          <div class="invalid-feedback">Vui lòng nhập mô tả (tối đa 500 ký tự).</div>
        </div>
        
        <div class="row">
          <div class="col-md-6">
            <div class="mb-3">
              <label for="contractDate" class="form-label fw-bold">Ngày ký <span class="text-danger">*</span></label>
              <input type="date" class="form-control" id="contractDate" name="contractDate" required>
              <div class="invalid-feedback">Vui lòng chọn ngày ký hợp đồng.</div>
            </div>
          </div>
          
          <div class="col-md-6">
            <div class="mb-3">
              <label for="status" class="form-label fw-bold">Trạng thái <span class="text-danger">*</span></label>
              <select class="form-select" id="status" name="status" required>
                <option value="">Chọn trạng thái</option>
                <option value="Active">Đang hiệu lực</option>
                <option value="Completed">Đã hoàn thành</option>
              </select>
              <div class="invalid-feedback">Vui lòng chọn trạng thái.</div>
            </div>
          </div>
        </div>
        
        <!-- Part Selection -->
        <div class="mb-3">
          <label for="partId" class="form-label fw-bold">Linh kiện sửa chữa <span class="text-danger">*</span></label>
          <select class="form-select" id="partId" name="partId" required>
            <option value="">Chọn linh kiện</option>
            <c:forEach var="part" items="${availableParts}">
              <option value="${part.equipmentId}" 
                      data-model="${fn:escapeXml(part.model)}"
                      data-serial="${fn:escapeXml(part.serialNumber)}"
                      data-location="${fn:escapeXml(part.location)}"
                      data-price="${part.unitPrice}">
                ${fn:escapeXml(part.model)} - ${fn:escapeXml(part.serialNumber)} 
                <c:if test="${part.location != null && !part.location.isEmpty()}">
                  (Vị trí: ${fn:escapeXml(part.location)})
                </c:if>
                - $${part.unitPrice}
              </option>
            </c:forEach>
          </select>
          <div class="invalid-feedback">Vui lòng chọn linh kiện cần sửa.</div>
          <div class="form-text">
            <i class="bi bi-info-circle me-1"></i>
            Chỉ hiển thị các linh kiện hiện có trong kho.
          </div>
        </div>
        
        <!-- Part Details Preview -->
        <div id="partPreview" class="card mt-3" style="display: none;">
          <div class="card-header">
            <h6 class="mb-0"><i class="bi bi-gear me-1"></i>Chi tiết linh kiện đã chọn</h6>
          </div>
          <div class="card-body">
            <div class="row">
              <div class="col-md-6">
                <strong>Mẫu thiết bị:</strong> <span id="previewModel"></span><br>
                <strong>Số seri:</strong> <span id="previewSerial"></span>
              </div>
              <div class="col-md-6">
                <strong>Vị trí:</strong> <span id="previewLocation"></span><br>
                <strong>Đơn giá:</strong> <span id="previewPrice"></span>
              </div>
            </div>
          </div>
        </div>
        
        <div class="d-flex justify-content-end gap-2">
          <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/technician/contracts">
            Hủy
          </a>
          <button type="submit" class="btn btn-success">
            <i class="bi bi-check-circle me-1"></i>Tạo hợp đồng
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
          <i class="bi bi-exclamation-triangle me-2"></i>Lỗi xác thực
        </h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Đóng"></button>
      </div>
      <div class="modal-body">
        <div id="errorMessage"></div>
        <div id="errorExample" class="mt-2 text-muted"></div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
      </div>
    </div>
  </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const form = document.getElementById('contractForm');
    const contractDateInput = document.getElementById('contractDate');
    const partSelect = document.getElementById('partId');
    const partPreview = document.getElementById('partPreview');
    
    // Set minimum date to today
    const today = new Date().toISOString().split('T')[0];
    contractDateInput.min = today;
    
    // Handle part selection preview
    function updatePreview(selectElement, previewElement) {
        const selectedOption = selectElement.options[selectElement.selectedIndex];
        
        if (selectElement.value && selectedOption.dataset.model) {
            // Show preview
            document.getElementById('previewModel').textContent = selectedOption.dataset.model;
            document.getElementById('previewSerial').textContent = selectedOption.dataset.serial;
            document.getElementById('previewLocation').textContent = selectedOption.dataset.location || 'Không xác định';
            document.getElementById('previewPrice').textContent = '$' + parseFloat(selectedOption.dataset.price).toFixed(2);
            previewElement.style.display = 'block';
        } else {
            // Hide preview
            previewElement.style.display = 'none';
        }
    }
    
    // Handle part selection
    partSelect.addEventListener('change', function() {
        updatePreview(this, partPreview);
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
            showFieldError('customerId', 'Vui lòng chọn khách hàng.');
            errors.push('Chưa chọn khách hàng');
            isValid = false;
        }
        
        // Validate contract type
        const contractType = document.getElementById('contractType').value;
        if (!contractType) {
            showFieldError('contractType', 'Vui lòng chọn loại hợp đồng.');
            errors.push('Chưa chọn loại hợp đồng');
            isValid = false;
        }
        
        // Validate description
        const description = document.getElementById('description').value.trim();
        if (!description) {
            showFieldError('description', 'Vui lòng nhập mô tả.');
            errors.push('Mô tả là bắt buộc');
            isValid = false;
        } else if (description.length > 500) {
            showFieldError('description', 'Mô tả phải tối đa 500 ký tự.');
            errors.push('Mô tả quá dài (tối đa 500 ký tự)');
            isValid = false;
        }
        
        // Validate contract date
        const contractDate = document.getElementById('contractDate').value;
        if (!contractDate) {
            showFieldError('contractDate', 'Vui lòng chọn ngày ký hợp đồng.');
            errors.push('Ngày ký hợp đồng là bắt buộc');
            isValid = false;
        }
        
        // Validate status
        const status = document.getElementById('status').value;
        if (!status) {
            showFieldError('status', 'Vui lòng chọn trạng thái.');
            errors.push('Chưa chọn trạng thái');
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
        errorExample.innerHTML = '<strong>Ví dụ:</strong> Chọn khách hàng, chọn loại hợp đồng, nhập mô tả, đặt ngày ký và chọn trạng thái.';
        
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
        if (e.target.classList.contains('btn-secondary') && e.target.textContent.trim() === 'Đóng') {
            const modal = bootstrap.Modal.getInstance(this);
            if (modal) {
                modal.hide();
            }
        }
    });
});
</script>
