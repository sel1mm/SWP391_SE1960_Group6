package utils;

import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;

/**
 * Comprehensive validation utility for technician forms.
 * Provides both client-side and server-side validation rules.
 */
public class TechnicianValidator {
    
    // Validation patterns - allow Unicode characters (including Vietnamese) and common punctuation
    private static final Pattern SAFE_TEXT_PATTERN = Pattern.compile("^[\\p{L}\\p{N}\\s,.\\(\\)!?;:'\"-]*$", Pattern.UNICODE_CASE);
    private static final Pattern NUMERIC_PATTERN = Pattern.compile("^\\d+(\\.\\d{1,2})?$");
    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$");
    
    // Field length limits
    public static final int MAX_DETAILS_LENGTH = 255;
    public static final int MAX_DIAGNOSIS_LENGTH = 255;
    public static final int MAX_DESCRIPTION_LENGTH = 500;
    public static final int MAX_NAME_LENGTH = 100;
    public static final int MAX_EMAIL_LENGTH = 255;
    
    /**
     * Validation result class
     */
    public static class ValidationResult {
        private boolean valid;
        private List<String> errors;
        private String fieldName;
        
        public ValidationResult(String fieldName) {
            this.fieldName = fieldName;
            this.valid = true;
            this.errors = new ArrayList<>();
        }
        
        public void addError(String error) {
            this.valid = false;
            this.errors.add(error);
        }
        
        public boolean isValid() { return valid; }
        public List<String> getErrors() { return errors; }
        public String getFieldName() { return fieldName; }
        public String getFirstError() { return errors.isEmpty() ? null : errors.get(0); }
    }
    
    /**
     * Validate repair report details field
     */
    public static ValidationResult validateDetails(String details) {
        ValidationResult result = new ValidationResult("details");
        
        if (details == null || details.trim().isEmpty()) {
            result.addError("Chi tiết là bắt buộc");
            return result;
        }
        
        String trimmed = details.trim();
        if (trimmed.length() > MAX_DETAILS_LENGTH) {
            result.addError("Chi tiết phải nhỏ hơn hoặc bằng " + MAX_DETAILS_LENGTH + " ký tự");
        }
        
        if (!SAFE_TEXT_PATTERN.matcher(trimmed).matches()) {
            result.addError("Chi tiết chỉ được chứa chữ, số, khoảng trắng và các ký tự: , . - ( )");
        }
        
        return result;
    }
    
    /**
     * Validate repair report diagnosis field
     */
    public static ValidationResult validateDiagnosis(String diagnosis) {
        ValidationResult result = new ValidationResult("diagnosis");
        
        if (diagnosis == null || diagnosis.trim().isEmpty()) {
            result.addError("Chẩn đoán là bắt buộc");
            return result;
        }
        
        String trimmed = diagnosis.trim();
        if (trimmed.length() > MAX_DIAGNOSIS_LENGTH) {
            result.addError("Chẩn đoán phải nhỏ hơn hoặc bằng " + MAX_DIAGNOSIS_LENGTH + " ký tự");
        }
        
        if (!SAFE_TEXT_PATTERN.matcher(trimmed).matches()) {
            result.addError("Chẩn đoán chỉ được chứa chữ, số, khoảng trắng và các ký tự: , . - ( )");
        }
        
        return result;
    }
    
    /**
     * Validate estimated cost field
     * Input is in VND (Vietnamese Dong), max value: 99,999,999,999 VND
     * This converts to ~3,846,153.85 USD, which fits in DECIMAL(12,2) database limit
     */
    public static ValidationResult validateEstimatedCost(String costStr) {
        ValidationResult result = new ValidationResult("estimatedCost");
        
        if (costStr == null || costStr.trim().isEmpty()) {
            result.addError("Chi phí ước tính là bắt buộc");
            return result;
        }
        
        String trimmed = costStr.trim();
        if (!NUMERIC_PATTERN.matcher(trimmed).matches()) {
            result.addError("Chi phí ước tính phải là số hợp lệ (ví dụ: 1500.00)");
            return result;
        }
        
        try {
            double cost = Double.parseDouble(trimmed);
            if (cost <= 0) {
                result.addError("Chi phí ước tính phải lớn hơn 0");
            }
            // Max VND value: 99,999,999,999 (matches form input max attribute)
            // This ensures converted USD value fits in DECIMAL(12,2) database limit
            if (cost > 99999999999.0) {
                result.addError("Chi phí ước tính không được vượt quá 99.999.999.999 VND");
            }
        } catch (NumberFormatException e) {
            result.addError("Định dạng số không hợp lệ");
        }
        
        return result;
    }
    
    /**
     * Validate repair date field
     * @param dateStr the date string to validate
     * @param isEditMode true if editing existing report, false if creating new report
     */
    public static ValidationResult validateRepairDate(String dateStr, boolean isEditMode) {
        ValidationResult result = new ValidationResult("repairDate");
        
        if (dateStr == null || dateStr.trim().isEmpty()) {
            result.addError("Ngày sửa chữa là bắt buộc");
            return result;
        }
        
        try {
            LocalDate repairDate = LocalDate.parse(dateStr.trim());
            
            if (isEditMode) {
                // For existing reports, repair date should not be changed
                // Just validate that it's a valid date format
                return result; // Valid date is sufficient for edit mode
            } else {
                // For new reports, repair date cannot be in the past
                LocalDate today = LocalDate.now();
                
                if (repairDate.isBefore(today)) {
                    result.addError("Ngày sửa chữa không được ở trong quá khứ");
                }
                
                // Check if date is too far in the future (e.g., more than 1 year)
                LocalDate maxDate = today.plusYears(1);
                if (repairDate.isAfter(maxDate)) {
                    result.addError("Ngày sửa chữa không được quá 1 năm trong tương lai");
                }
            }
            
        } catch (DateTimeParseException e) {
            result.addError("Định dạng ngày không hợp lệ. Vui lòng sử dụng định dạng YYYY-MM-DD");
        }
        
        return result;
    }
    
    /**
     * Validate contract description field
     */
    public static ValidationResult validateDescription(String description) {
        ValidationResult result = new ValidationResult("description");
        
        if (description == null || description.trim().isEmpty()) {
            result.addError("Mô tả là bắt buộc");
            return result;
        }
        
        String trimmed = description.trim();
        if (trimmed.length() > MAX_DESCRIPTION_LENGTH) {
            result.addError("Mô tả phải nhỏ hơn hoặc bằng " + MAX_DESCRIPTION_LENGTH + " ký tự");
        }
        
        if (!SAFE_TEXT_PATTERN.matcher(trimmed).matches()) {
            result.addError("Mô tả chỉ được chứa chữ, số, khoảng trắng và các ký tự: , . - ( )");
        }
        
        return result;
    }
    
    /**
     * Validate customer name field
     */
    public static ValidationResult validateCustomerName(String name) {
        ValidationResult result = new ValidationResult("customerName");
        
        if (name == null || name.trim().isEmpty()) {
            result.addError("Tên khách hàng là bắt buộc");
            return result;
        }
        
        String trimmed = name.trim();
        if (trimmed.length() > MAX_NAME_LENGTH) {
            result.addError("Tên khách hàng phải nhỏ hơn hoặc bằng " + MAX_NAME_LENGTH + " ký tự");
        }
        
        if (!SAFE_TEXT_PATTERN.matcher(trimmed).matches()) {
            result.addError("Tên khách hàng chỉ được chứa chữ, số, khoảng trắng và các ký tự: , . - ( )");
        }
        
        return result;
    }
    
    /**
     * Validate email field
     */
    public static ValidationResult validateEmail(String email) {
        ValidationResult result = new ValidationResult("email");
        
        if (email == null || email.trim().isEmpty()) {
            result.addError("Email là bắt buộc");
            return result;
        }
        
        String trimmed = email.trim();
        if (trimmed.length() > MAX_EMAIL_LENGTH) {
            result.addError("Email phải nhỏ hơn hoặc bằng " + MAX_EMAIL_LENGTH + " ký tự");
        }
        
        if (!EMAIL_PATTERN.matcher(trimmed).matches()) {
            result.addError("Vui lòng nhập địa chỉ email hợp lệ (ví dụ: user@example.com)");
        }
        
        return result;
    }
    
    /**
     * Validate required field (generic)
     */
    public static ValidationResult validateRequired(String value, String fieldName) {
        ValidationResult result = new ValidationResult(fieldName);
        
        if (value == null || value.trim().isEmpty()) {
            result.addError(fieldName + " là bắt buộc");
        }
        
        return result;
    }
    
    /**
     * Validate date range (start date must be before end date)
     */
    public static ValidationResult validateDateRange(String startDateStr, String endDateStr) {
        ValidationResult result = new ValidationResult("dateRange");
        
        try {
            LocalDate startDate = LocalDate.parse(startDateStr.trim());
            LocalDate endDate = LocalDate.parse(endDateStr.trim());
            
            if (!endDate.isAfter(startDate)) {
                result.addError("Ngày kết thúc phải sau ngày bắt đầu");
            }
            
        } catch (DateTimeParseException e) {
            result.addError("Định dạng ngày không hợp lệ trong khoảng thời gian");
        }
        
        return result;
    }
    
    /**
     * Sanitize input by trimming and limiting length
     */
    public static String sanitizeInput(String input, int maxLength) {
        if (input == null) return null;
        String trimmed = input.trim();
        return trimmed.length() > maxLength ? trimmed.substring(0, maxLength) : trimmed;
    }
    
    /**
     * Get validation error message for display
     */
    public static String getErrorMessage(ValidationResult result) {
        if (result.isValid()) return null;
        
        StringBuilder sb = new StringBuilder();
        sb.append("<strong>").append(result.getFieldName()).append(":</strong><br>");
        for (String error : result.getErrors()) {
            sb.append("• ").append(error).append("<br>");
        }
        return sb.toString();
    }
    
    /**
     * Get example text for validation errors
     */
    public static String getExampleText(String fieldName) {
        switch (fieldName.toLowerCase()) {
            case "details":
                return "<strong>Ví dụ:</strong> Thiết bị hỏng, đã thay linh kiện lỗi";
            case "diagnosis":
                return "<strong>Ví dụ:</strong> Động cơ quá nhiệt do bạc đạn mòn";
            case "estimatedcost":
                return "<strong>Ví dụ:</strong> 1500.00";
            case "repairdate":
                return "<strong>Ví dụ:</strong> 2024-12-25";
            case "description":
                return "<strong>Ví dụ:</strong> Hợp đồng bảo trì hằng năm cho thiết bị công nghiệp";
            case "customername":
                return "<strong>Ví dụ:</strong> Công ty sản xuất ABC";
            case "email":
                return "<strong>Ví dụ:</strong> contact@abccompany.com";
            default:
                return "<strong>Ví dụ:</strong> Vui lòng nhập dữ liệu hợp lệ";
        }
    }
}