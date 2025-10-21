/**
 * Technician Module Validation JavaScript
 * Provides client-side validation for technician forms
 */

// Global validation utilities
window.TechnicianValidation = {
    
    // Patterns for validation
    patterns: {
        safeText: /^[a-zA-Z0-9\s.,!?()-]+$/,
        dangerous: /.*(<script|<\/script|'|"|;|--|\/\*|\*\/).*/i,
        decimal: /^\d+(\.\d{1,2})?$/
    },
    
    // Validation rules
    rules: {
        details: {
            required: true,
            maxLength: 255,
            message: 'Details are required and must not exceed 255 characters'
        },
        diagnosis: {
            required: true,
            maxLength: 255,
            message: 'Diagnosis is required and must not exceed 255 characters'
        },
        estimatedCost: {
            required: true,
            min: 0.01,
            max: 999999.99,
            message: 'Estimated cost must be between $0.01 and $999,999.99'
        },
        repairDate: {
            required: true,
            notPast: true,
            message: 'Repair date is required and cannot be in the past'
        },
        taskStatus: {
            required: true,
            validValues: ['Pending', 'In Progress', 'Completed', 'On Hold', 'Cancelled'],
            message: 'Please select a valid task status'
        }
    },
    
    /**
     * Validate repair report form
     */
    validateRepairReport: function(formData) {
        const errors = {};
        
        // Validate details
        if (!formData.details || !formData.details.trim()) {
            errors.details = 'Details are required';
        } else if (formData.details.length > 255) {
            errors.details = 'Details must not exceed 255 characters';
        } else if (this.containsDangerousChars(formData.details)) {
            errors.details = 'Details contain invalid characters';
        }
        
        // Validate diagnosis
        if (!formData.diagnosis || !formData.diagnosis.trim()) {
            errors.diagnosis = 'Diagnosis is required';
        } else if (formData.diagnosis.length > 255) {
            errors.diagnosis = 'Diagnosis must not exceed 255 characters';
        } else if (this.containsDangerousChars(formData.diagnosis)) {
            errors.diagnosis = 'Diagnosis contain invalid characters';
        }
        
        // Validate estimated cost
        if (!formData.estimatedCost || !formData.estimatedCost.trim()) {
            errors.estimatedCost = 'Estimated cost is required';
        } else {
            const cost = parseFloat(formData.estimatedCost);
            if (isNaN(cost) || cost <= 0) {
                errors.estimatedCost = 'Estimated cost must be greater than 0';
            } else if (cost > 999999.99) {
                errors.estimatedCost = 'Estimated cost must not exceed 999,999.99';
            }
        }
        
        // Validate repair date
        if (!formData.repairDate || !formData.repairDate.trim()) {
            errors.repairDate = 'Repair date is required';
        } else {
            const repairDate = new Date(formData.repairDate);
            const today = new Date();
            today.setHours(0, 0, 0, 0);
            
            if (repairDate < today) {
                errors.repairDate = 'Repair date cannot be in the past';
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
                error: 'Status is required'
            };
        }
        
        if (!validStatuses.includes(status.trim())) {
            return {
                isValid: false,
                error: 'Invalid status. Valid options: ' + validStatuses.join(', ')
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
    
    // Initialize repair report form validation
    const reportForm = document.getElementById('reportForm');
    if (reportForm) {
        initializeRepairReportValidation(reportForm);
    }
    
    // Initialize character counters
    initializeCharacterCounters();
    
    // Initialize date restrictions
    initializeDateRestrictions();
});

/**
 * Initialize repair report form validation
 */
function initializeRepairReportValidation(form) {
    form.addEventListener('submit', function(e) {
        e.preventDefault();
        
        const formData = {
            details: document.getElementById('details').value,
            diagnosis: document.getElementById('diagnosis').value,
            estimatedCost: document.getElementById('estimatedCost').value,
            repairDate: document.getElementById('repairDate').value
        };
        
        // Clear previous errors
        TechnicianValidation.clearAllErrors();
        
        // Validate form data
        const validation = TechnicianValidation.validateRepairReport(formData);
        
        if (!validation.isValid) {
            // Show field errors
            Object.keys(validation.errors).forEach(fieldName => {
                const field = document.getElementById(fieldName);
                const errorId = fieldName + 'Error';
                if (field) {
                    TechnicianValidation.showFieldError(field, errorId, validation.errors[fieldName]);
                }
            });
            
            // Show modal with first error
            const firstError = Object.values(validation.errors)[0];
            TechnicianValidation.showValidationModal(firstError);
            
            return;
        }
        
        // Submit form if valid
        form.submit();
    });
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
