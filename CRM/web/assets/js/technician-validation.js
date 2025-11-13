/**
 * Technician Module Validation JavaScript
 * Provides client-side validation for technician forms
 */

// Global validation utilities
window.TechnicianValidation = {
    
    // Patterns for validation
    patterns: {
        safeText: /^[\p{L}\p{N}\s,.()!?;:'"-]*$/u,
        dangerous: /.*(<script|<\/script|'|"|;|--|\/\*|\*\/).*/iu,
        decimal: /^\d+(\.\d{1,2})?$/
    },
    
    // Validation rules
    rules: {
        details: {
            required: true,
            maxLength: 255,
            message: 'Chi tiết là bắt buộc và không được vượt quá 255 ký tự'
        },
        diagnosis: {
            required: true,
            maxLength: 255,
            message: 'Chẩn đoán là bắt buộc và không được vượt quá 255 ký tự'
        },
        estimatedCost: {
            required: true,
            min: 0.01,
            max: 99999999999,
            message: 'Chi phí ước tính phải nằm trong khoảng 0,01 đến 99.999.999.999 VND'
        },
        repairDate: {
            required: true,
            notPast: true,
            message: 'Ngày sửa chữa là bắt buộc và không được ở trong quá khứ'
        },
        taskStatus: {
            required: true,
            validValues: ['Pending', 'In Progress', 'Completed', 'On Hold', 'Cancelled'],
            message: 'Vui lòng chọn một trạng thái hợp lệ'
        }
    },
    
    /**
     * Validate repair report form
     */
    validateRepairReport: function(formData) {
        const errors = {};
        const requestType = formData.requestType ? formData.requestType.trim() : '';
        const isWarranty = requestType.toLowerCase() === 'warranty';
        
        // Validate details
        if (!formData.details || !formData.details.trim()) {
            errors.details = 'Chi tiết là bắt buộc';
        } else if (formData.details.length > 255) {
            errors.details = 'Chi tiết không được vượt quá 255 ký tự';
        } else if (this.containsDangerousChars(formData.details)) {
            errors.details = 'Chi tiết chứa ký tự không hợp lệ';
        }
        
        // Validate diagnosis
        if (!formData.diagnosis || !formData.diagnosis.trim()) {
            errors.diagnosis = 'Chẩn đoán là bắt buộc';
        } else if (formData.diagnosis.length > 255) {
            errors.diagnosis = 'Chẩn đoán không được vượt quá 255 ký tự';
        } else if (this.containsDangerousChars(formData.diagnosis)) {
            errors.diagnosis = 'Chẩn đoán chứa ký tự không hợp lệ';
        }
        
        // Validate estimated cost (input is in VND)
        if (!isWarranty) {
            if (!formData.estimatedCost || !formData.estimatedCost.trim()) {
                errors.estimatedCost = 'Chi phí ước tính là bắt buộc';
            } else {
                const cost = parseFloat(formData.estimatedCost);
                if (isNaN(cost) || cost <= 0) {
                    errors.estimatedCost = 'Chi phí ước tính phải lớn hơn 0';
                } else if (cost > 99999999999) {
                    errors.estimatedCost = 'Chi phí ước tính không được vượt quá 99.999.999.999 VND';
                }
            }
        }
        
        // Validate repair date
        if (!formData.repairDate || !formData.repairDate.trim()) {
            errors.repairDate = 'Ngày sửa chữa là bắt buộc';
        } else {
            const repairDate = new Date(formData.repairDate);
            const today = new Date();
            today.setHours(0, 0, 0, 0);
            
            if (repairDate < today) {
                errors.repairDate = 'Ngày sửa chữa không được ở trong quá khứ';
            }
        }
        
        return {
            isValid: Object.keys(errors).length === 0,
            errors: errors
        };
    },
    
    /**
     * Validate task status update
     */
    validateTaskStatus: function(status) {
        const validStatuses = ['Pending', 'In Progress', 'Completed', 'On Hold', 'Cancelled'];
        
        if (!status || !status.trim()) {
            return {
                isValid: false,
                error: 'Vui lòng chọn trạng thái'
            };
        }
        
        if (!validStatuses.includes(status.trim())) {
            return {
                isValid: false,
                error: 'Trạng thái không hợp lệ. Các giá trị hợp lệ: ' + validStatuses.join(', ')
            };
        }
        
        return {
            isValid: true,
            error: null
        };
    },
    
    /**
     * Check if text contains dangerous characters
     */
    containsDangerousChars: function(input) {
        if (!input) return false;
        return this.patterns.dangerous.test(input);
    },
    
    /**
     * Show validation error modal
     */
    showValidationModal: function(message) {
        const modal = document.getElementById('validationModal');
        if (modal) {
            const messageDiv = document.getElementById('validationMessage');
            if (messageDiv) {
                messageDiv.innerHTML = '<div class="alert alert-danger mb-0"><i class="bi bi-exclamation-triangle me-2"></i>' + message + '</div>';
            }
            new bootstrap.Modal(modal).show();
        }
    },
    
    /**
     * Show field error
     */
    showFieldError: function(field, errorId, message) {
        field.classList.add('is-invalid');
        const errorElement = document.getElementById(errorId);
        if (errorElement) {
            errorElement.textContent = message;
        }
    },
    
    /**
     * Clear field error
     */
    clearFieldError: function(field, errorId) {
        field.classList.remove('is-invalid');
        const errorElement = document.getElementById(errorId);
        if (errorElement) {
            errorElement.textContent = '';
        }
    },
    
    /**
     * Clear all validation errors
     */
    clearAllErrors: function() {
        document.querySelectorAll('.is-invalid').forEach(field => {
            field.classList.remove('is-invalid');
        });
        document.querySelectorAll('.invalid-feedback').forEach(feedback => {
            feedback.textContent = '';
        });
    },
    
    /**
     * Sanitize input
     */
    sanitize: function(input) {
        if (!input) return null;
        return input.trim();
    }
};

// Auto-initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    
    // Note: Individual forms handle their own validation to avoid conflicts
    // Only initialize shared utilities here
    
    // Initialize character counters
    initializeCharacterCounters();
    
    // Initialize date restrictions
    initializeDateRestrictions();
});

/**
 * Initialize repair report form validation
 * NOTE: This function is kept for reference but not used to avoid conflicts
 * Individual forms handle their own validation
 */
function initializeRepairReportValidation(form) {
    // This function is intentionally empty to avoid conflicts
    // Individual forms handle their own validation
}

/**
 * Initialize character counters
 */
function initializeCharacterCounters() {
    const detailsField = document.getElementById('details');
    const diagnosisField = document.getElementById('diagnosis');
    
    if (detailsField) {
        const detailsCounter = document.getElementById('detailsCount');
        detailsField.addEventListener('input', function() {
            if (detailsCounter) {
                detailsCounter.textContent = this.value.length;
            }
        });
        // Initialize counter
        if (detailsCounter) {
            detailsCounter.textContent = detailsField.value.length;
        }
    }
    
    if (diagnosisField) {
        const diagnosisCounter = document.getElementById('diagnosisCount');
        diagnosisField.addEventListener('input', function() {
            if (diagnosisCounter) {
                diagnosisCounter.textContent = this.value.length;
            }
        });
        // Initialize counter
        if (diagnosisCounter) {
            diagnosisCounter.textContent = diagnosisField.value.length;
        }
    }
}

/**
 * Initialize date restrictions
 */
function initializeDateRestrictions() {
    const repairDateField = document.getElementById('repairDate');
    if (repairDateField) {
        const today = new Date().toISOString().split('T')[0];
        repairDateField.setAttribute('min', today);
    }
}

/**
 * Show status update modal
 */
function showStatusUpdateModal(taskId, currentStatus) {
    const modal = document.getElementById('statusUpdateModal');
    if (modal) {
        const taskIdField = document.getElementById('modalTaskId');
        const statusSelect = document.getElementById('statusSelect');
        
        if (taskIdField) taskIdField.value = taskId;
        if (statusSelect) statusSelect.value = currentStatus;
        
        new bootstrap.Modal(modal).show();
    }
}

/**
 * Validate status update form
 */
function validateStatusUpdate(form) {
    const status = form.status.value;
    const validation = TechnicianValidation.validateTaskStatus(status);
    
    if (!validation.isValid) {
        TechnicianValidation.showValidationModal(validation.error);
        return false;
    }
    
    return true;
}
