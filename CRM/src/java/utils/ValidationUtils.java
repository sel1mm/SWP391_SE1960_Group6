package utils;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;

public class ValidationUtils {

    // Regex for allowed characters: letters, numbers, spaces, commas, periods, dashes, parentheses, forward slash
    private static final Pattern ALLOWED_TEXT_PATTERN = Pattern.compile("^[a-zA-Z0-9\\s,\\.\\-\\(\\)\\/]*$");

    public static class ValidationResult {
        private final List<String> errors = new ArrayList<>();

        public void addError(String error) {
            this.errors.add(error);
        }

        public boolean isValid() {
            return errors.isEmpty();
        }

        public List<String> getErrors() {
            return new ArrayList<>(errors);
        }

        public String getFirstError() {
            return errors.isEmpty() ? null : errors.get(0);
        }
    }

    public static String sanitize(String input) {
        if (input == null) return null;
        // Basic HTML/script tag removal for safety, though regex above should catch most
        return input.replaceAll("<", "&lt;").replaceAll(">", "&gt;").trim();
    }

    public static ValidationResult validateRequestId(String requestIdStr) {
        ValidationResult result = new ValidationResult();
        if (requestIdStr == null || requestIdStr.trim().isEmpty()) {
            result.addError("Service Request ID is required.");
            return result;
        }
        try {
            long requestId = Long.parseLong(requestIdStr);
            if (requestId <= 0) {
                result.addError("Service Request ID must be a positive number.");
            }
        } catch (NumberFormatException e) {
            result.addError("Service Request ID must be a valid number.");
        }
        return result;
    }

    public static ValidationResult validateDetails(String details) {
        ValidationResult result = new ValidationResult();
        if (details == null || details.trim().isEmpty()) {
            result.addError("Details is required and cannot be blank.");
        } else if (details.length() > 255) {
            result.addError("Details cannot exceed 255 characters.");
        } else if (!ALLOWED_TEXT_PATTERN.matcher(details).matches()) {
            result.addError("Details contains invalid characters. Only letters, numbers, spaces, commas, periods, dashes, parentheses, and forward slashes are allowed.");
        }
        return result;
    }

    public static ValidationResult validateDiagnosis(String diagnosis) {
        ValidationResult result = new ValidationResult();
        if (diagnosis == null || diagnosis.trim().isEmpty()) {
            result.addError("Diagnosis is required and cannot be blank.");
        } else if (diagnosis.length() > 255) {
            result.addError("Diagnosis cannot exceed 255 characters.");
        } else if (!ALLOWED_TEXT_PATTERN.matcher(diagnosis).matches()) {
            result.addError("Diagnosis contains invalid characters. Only letters, numbers, spaces, commas, periods, dashes, parentheses, and forward slashes are allowed.");
        }
        return result;
    }

    public static ValidationResult validateEstimatedCost(String estimatedCostStr) {
        ValidationResult result = new ValidationResult();
        if (estimatedCostStr == null || estimatedCostStr.trim().isEmpty()) {
            result.addError("Estimated cost is required.");
            return result;
        }
        try {
            BigDecimal cost = new BigDecimal(estimatedCostStr);
            if (cost.compareTo(BigDecimal.ZERO) <= 0) {
                result.addError("Estimated cost must be a positive number.");
            }
            if (cost.scale() > 2) {
                result.addError("Estimated cost can have at most 2 decimal places.");
            }
            if (cost.compareTo(new BigDecimal("1000000")) > 0) {
                result.addError("Estimated cost cannot exceed 1,000,000.");
            }
        } catch (NumberFormatException e) {
            result.addError("Estimated cost must be a valid numeric value.");
        }
        return result;
    }

    public static ValidationResult validateRepairDate(String repairDateStr) {
        ValidationResult result = new ValidationResult();
        if (repairDateStr == null || repairDateStr.trim().isEmpty()) {
            result.addError("Repair date is required.");
            return result;
        }
        try {
            LocalDate repairDate = LocalDate.parse(repairDateStr);
            if (repairDate.isBefore(LocalDate.now())) {
                result.addError("Repair date cannot be in the past.");
            }
        } catch (java.time.format.DateTimeParseException e) {
            result.addError("Repair date must be a valid date in YYYY-MM-DD format.");
        }
        return result;
    }
}
