// Set minimum date to today for repairDate
document.addEventListener("DOMContentLoaded", function() {
    const repairDateInput = document.getElementById("repairDate");
    if (repairDateInput) {
        const today = new Date().toISOString().split("T")[0];
        repairDateInput.setAttribute("min", today);
    }
});

// Show report form modal
function showReportForm() {
    document.getElementById("reportId").value = "";
    document.getElementById("reportForm").reset();
    document.getElementById("reportModalLabel").textContent = "New Repair Report";
    document.getElementById("submitBtn").textContent = "Submit Report";

    // Set minimum date to today
    const repairDateInput = document.getElementById("repairDate");
    if (repairDateInput) {
        const today = new Date().toISOString().split("T")[0];
        repairDateInput.setAttribute("min", today);
    }

    new bootstrap.Modal(document.getElementById("reportModal")).show();
}

// Edit report function (placeholder - would need backend support)
function editReport(reportId) {
    // For now, just show the form
    showReportForm();
    // In a real implementation, you would load the report data here via AJAX
    // and populate the form fields before showing the modal.
}

// Client-side validation
function validateForm() {
    let isValid = true;
    
    // Clear previous errors
    document.querySelectorAll(".is-invalid").forEach(el => el.classList.remove("is-invalid"));
    document.querySelectorAll(".invalid-feedback").forEach(el => el.textContent = "");
    
    // Validate Service Request ID
    const requestId = document.getElementById("requestId");
    if (!requestId.value || requestId.value <= 0) {
        showFieldError(requestId, "Service Request ID is required and must be positive.");
        isValid = false;
    }
    
    // Validate Repair Date
    const repairDate = document.getElementById("repairDate");
    if (!repairDate.value) {
        showFieldError(repairDate, "Repair date is required.");
        isValid = false;
    } else {
        const selectedDate = new Date(repairDate.value);
        const today = new Date();
        today.setHours(0, 0, 0, 0);
        if (selectedDate < today) {
            showFieldError(repairDate, "Repair date cannot be in the past.");
            isValid = false;
        }
    }
    
    // Validate Details
    const details = document.getElementById("details");
    if (!details.value.trim()) {
        showFieldError(details, "Details is required and cannot be blank.");
        isValid = false;
    } else if (details.value.length > 255) {
        showFieldError(details, "Details cannot exceed 255 characters.");
        isValid = false;
    } else if (!/^[a-zA-Z0-9\s,.\-()/]*$/.test(details.value)) {
        showFieldError(details, "Details contains invalid characters. Only letters, numbers, spaces, commas, periods, dashes, parentheses, and forward slashes are allowed.");
        isValid = false;
    }
    
    // Validate Diagnosis
    const diagnosis = document.getElementById("diagnosis");
    if (!diagnosis.value.trim()) {
        showFieldError(diagnosis, "Diagnosis is required and cannot be blank.");
        isValid = false;
    } else if (diagnosis.value.length > 255) {
        showFieldError(diagnosis, "Diagnosis cannot exceed 255 characters.");
        isValid = false;
    } else if (!/^[a-zA-Z0-9\s,.\-()/]*$/.test(diagnosis.value)) {
        showFieldError(diagnosis, "Diagnosis contains invalid characters. Only letters, numbers, spaces, commas, periods, dashes, parentheses, and forward slashes are allowed.");
        isValid = false;
    }
    
    // Validate Estimated Cost
    const estimatedCost = document.getElementById("estimatedCost");
    if (!estimatedCost.value) {
        showFieldError(estimatedCost, "Estimated cost is required.");
        isValid = false;
    } else {
        const cost = parseFloat(estimatedCost.value);
        if (isNaN(cost) || cost <= 0) {
            showFieldError(estimatedCost, "Estimated cost must be a positive number.");
            isValid = false;
        } else if (cost > 1000000) {
            showFieldError(estimatedCost, "Estimated cost cannot exceed 1,000,000.");
            isValid = false;
        }
    }
    
    if (!isValid) {
        showErrorModal("Please fix the validation errors above before submitting.");
    }
    
    return isValid;
}

function showFieldError(field, message) {
    field.classList.add("is-invalid");
    const errorDiv = document.getElementById(field.id + "Error");
    if (errorDiv) {
        errorDiv.textContent = message;
    }
}

function showErrorModal(message) {
    document.getElementById("errorMessage").innerHTML = message;
    new bootstrap.Modal(document.getElementById("errorModal")).show();
}

// Add form validation on submit
document.addEventListener("DOMContentLoaded", function() {
    const form = document.getElementById("reportForm");
    if (form) {
        form.addEventListener("submit", function(e) {
            if (!validateForm()) {
                e.preventDefault();
            }
        });
    }
});
