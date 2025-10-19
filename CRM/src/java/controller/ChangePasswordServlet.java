
package controller;

import dal.AccountDAO;
import dto.Response;
import java.io.IOException;
import java.security.MessageDigest;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Account;
import utils.passwordHasher;

/**
 * Servlet for changing user password with enhanced security and validation
 * 
 * @author Admin
 * @version 2.0
 */
@WebServlet(name = "ChangePasswordServlet", urlPatterns = {"/changePassword"})
public class ChangePasswordServlet extends HttpServlet {
    
    private static final Logger LOGGER = Logger.getLogger(ChangePasswordServlet.class.getName());
    private static final long serialVersionUID = 1L;
    
    // Password requirements constants
    private static final int MIN_PASSWORD_LENGTH = 8;
    private static final int MAX_PASSWORD_LENGTH = 128;
    
    // Session attribute names
    private static final String SESSION_ACCOUNT_ID = "accountId";
    private static final String SESSION_SUCCESS_MSG = "successMessage";
    private static final String SESSION_ERROR_MSG = "errorMessage";
    
    // Request attribute names
    private static final String ATTR_ERROR_MSG = "errorMessage";
    private static final String ATTR_ACCOUNT = "account";
    
    // Parameter names
    private static final String PARAM_CURRENT_PASSWORD = "currentPassword";
    private static final String PARAM_NEW_PASSWORD = "newPassword";
    private static final String PARAM_RENEW_PASSWORD = "renewPassword";
    
    private AccountDAO accountDAO;
    
    @Override
    public void init() throws ServletException {
        super.init();
        try {
            accountDAO = new AccountDAO();
            LOGGER.info("ChangePasswordServlet initialized successfully");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to initialize AccountDAO", e);
            throw new ServletException("Failed to initialize servlet", e);
        }
    }
    
    /**
     * Handles the HTTP GET method - Display change password form

     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        
        response.setContentType("text/html;charset=UTF-8");
        
        try {
            HttpSession session = request.getSession();
       
            if (session == null) {
                LOGGER.warning("No session found");
                response.sendRedirect("login.jsp");
                return;
            }

            Account acc = (Account) session.getAttribute("session_login");
            if (acc == null || acc.getAccountId() == -1) {
                LOGGER.warning("Unauthorized password change attempt");
                response.sendRedirect("login.jsp");
                return;
            }
            
            // Get current account data
            Response<Account> accountResponse = accountDAO.getAccountById2(acc.getAccountId());
            
            if (accountResponse == null || !accountResponse.isSuccess() || accountResponse.getData() == null) {
                LOGGER.warning("Account not found for ID: " + acc.getAccountId());
                handleError(request, response, "Account not found. Please login again.");
                return;
            }
            
            LOGGER.info("Loading change password form for account ID: " + acc.getAccountId());
            
            // Set attributes for JSP
            request.setAttribute(ATTR_ACCOUNT, accountResponse);
            
            // Forward to JSP
            request.getRequestDispatcher("changePassword.jsp").forward(request, response);
            
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error loading change password form", e);
            handleError(request, response, "Unable to load password change form. Please try again later.");
        }
    }
    
    /**
     * Handles the HTTP POST method - Process password change or verification

     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        
        // IMPORTANT: Set encoding BEFORE reading any parameters
        request.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession(false);
        
        // DEBUG: Log all parameters (after setting encoding)
        LOGGER.info("===== RAW PARAMETERS =====");
        java.util.Enumeration<String> paramNames = request.getParameterNames();
        while (paramNames.hasMoreElements()) {
            String paramName = paramNames.nextElement();
            String[] paramValues = request.getParameterValues(paramName);
            LOGGER.info(paramName + " = " + String.join(", ", paramValues));
        }
        LOGGER.info("Content-Type: " + request.getContentType());
        LOGGER.info("Character Encoding: " + request.getCharacterEncoding());
        LOGGER.info("==========================");
        
        // Check action parameter to determine if this is verify or change
        String action = request.getParameter("action");
        
        if ("verify".equals(action)) {
            // Handle password verification (Step 1) - JSON response
            response.setContentType("application/json;charset=UTF-8");
            handlePasswordVerification(request, response, session);
        } else {
            // Handle password change (Step 2) - HTML response
            response.setContentType("text/html;charset=UTF-8");
            handlePasswordChange(request, response, session);
        }
    }
    
    /**
     * Handle password verification via AJAX
     */
    private void handlePasswordVerification(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {
        
        java.io.PrintWriter out = response.getWriter();
        
        try {
            // Security check: Verify user is logged in
            if (session == null) {
                LOGGER.warning("No session found during verification");
                out.print("{\"success\":false,\"message\":\"Session expired. Please login again.\"}");
                return;
            }

            Account acc = (Account) session.getAttribute("session_login");
            if (acc == null || acc.getAccountId() <= 0) {
                LOGGER.warning("Unauthorized password verification attempt");
                out.print("{\"success\":false,\"message\":\"Session expired. Please login again.\"}");
                return;
            }
            
            // Get current password from request
            String currentPassword = request.getParameter("currentPassword");
            
            LOGGER.info("===== PASSWORD VERIFICATION DEBUG =====");
            LOGGER.info("Verifying password for account ID: " + acc.getAccountId());
            LOGGER.info("Received currentPassword: " + (currentPassword != null ? currentPassword : "NULL"));
            LOGGER.info("Password length: " + (currentPassword != null ? currentPassword.length() : "0"));
            
            // Validate input
            if (currentPassword == null || currentPassword.trim().isEmpty()) {
                LOGGER.warning("Current password is empty");
                out.print("{\"success\":false,\"message\":\"Please enter your current password.\"}");
                return;
            }
            
            // Get account from database
            Response<Account> accountResponse = accountDAO.getAccountById2(acc.getAccountId());
            if (accountResponse == null || !accountResponse.isSuccess() || accountResponse.getData() == null) {
                LOGGER.warning("Account not found for ID: " + acc.getAccountId());
                out.print("{\"success\":false,\"message\":\"Account not found.\"}");
                return;
            }
            
            
            
            // Hash the input password
            String hashedPassword = passwordHasher.hashPassword(currentPassword);
            
            // Get stored password hash from database
            String storedPasswordHash = acc.getPasswordHash();
            
            LOGGER.info("Input password (plain): " + currentPassword);
            LOGGER.info("Input password hashed: " + hashedPassword);
            LOGGER.info("Stored password hash: " + storedPasswordHash);
            LOGGER.info("Hashes match: " + passwordHasher.checkPassword(currentPassword, storedPasswordHash));
            LOGGER.info("========================================");
            
            boolean passwordMatches = passwordHasher.checkPassword(currentPassword, storedPasswordHash);
            
            if (passwordMatches) {
                LOGGER.info("Password verified successfully for account ID: " + acc.getAccountId());
                out.print("{\"success\":true,\"message\":\"Password verified successfully.\"}");
            } else {
                LOGGER.warning("Password verification failed for account ID: " + acc.getAccountId());
                out.print("{\"success\":false,\"message\":\"Current password is incorrect.\"}");
            }
            
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error verifying password", e);
            out.print("{\"success\":false,\"message\":\"An error occurred. Please try again.\"}");
        } finally {
            out.flush();
        }
    }
    
    /**
     * Handle password change
     */
    private void handlePasswordChange(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {
        
        try {
            // Security check: Verify user is logged in
            if (session == null) {
                LOGGER.warning("No session found during password change");
                response.sendRedirect("login.jsp");
                return;
            }

            Account acc = (Account) session.getAttribute("session_login");
            if (acc == null || acc.getAccountId() <= 0) {
                LOGGER.warning("Unauthorized password change attempt");
                response.sendRedirect("login.jsp");
                return;
            }
            
            // Get form parameters - Try both regular and hidden field
            String currentPassword = request.getParameter("hiddenCurrentPassword");
            if (currentPassword == null || currentPassword.trim().isEmpty()) {
                currentPassword = request.getParameter("currentPassword");
            }
            
            String newPassword = request.getParameter("newPassword");
            String renewPassword = request.getParameter("renewPassword");
            
            LOGGER.info("===== DEBUG PASSWORD CHANGE =====");
            LOGGER.info("Processing password change for account ID: " + acc.getAccountId());
            LOGGER.info("hiddenCurrentPassword: " + (request.getParameter("hiddenCurrentPassword") != null ? request.getParameter("hiddenCurrentPassword") : "NULL"));
            LOGGER.info("currentPassword param: " + (request.getParameter("currentPassword") != null ? request.getParameter("currentPassword") : "NULL"));
            LOGGER.info("newPassword: " + (newPassword != null ? newPassword : "NULL"));
            LOGGER.info("renewPassword: " + (renewPassword != null ? renewPassword : "NULL"));
            LOGGER.info("Final currentPassword used: " + (currentPassword != null ? currentPassword : "NULL"));
            
            // Validate input
            ValidationResult validation = validatePasswordChange(currentPassword, newPassword, renewPassword);
            if (!validation.isValid()) {
                LOGGER.warning("Validation failed: " + validation.getMessage());
                request.setAttribute(ATTR_ERROR_MSG, validation.getMessage());
                request.getRequestDispatcher("changePassword.jsp").forward(request, response);
                return;
            }
            
            // Get current account
            Response<Account> accountResponse = accountDAO.getAccountById2(acc.getAccountId());
            if (accountResponse == null || !accountResponse.isSuccess() || accountResponse.getData() == null) {
                LOGGER.severe("Account not found during password change: " + acc.getAccountId());
                request.setAttribute(ATTR_ERROR_MSG, "Account not found. Please login again.");
                request.getRequestDispatcher("changePassword.jsp").forward(request, response);
                return;
            }
            
          
            
            // Verify current password
           
            String storedPasswordHash = acc.getPasswordHash();
            
            LOGGER.info("===== PASSWORD COMPARISON =====");
            LOGGER.info("Current password (plain): " + currentPassword);
            
            LOGGER.info("Stored password hash: " + storedPasswordHash);
           
            LOGGER.info("================================");
            
            if (!passwordHasher.checkPassword(currentPassword, acc.getPasswordHash())) {
                LOGGER.warning("Current password verification failed for account ID: " + acc.getAccountId());
                request.setAttribute(ATTR_ERROR_MSG, "Current password is incorrect.");
                request.getRequestDispatcher("changePassword.jsp").forward(request, response);
                return;
            }
            
            // Check if new password is different from current
            String hashedNewPassword = passwordHasher.hashPassword(newPassword);
            if (passwordHasher.checkPassword(newPassword, acc.getPasswordHash())) {
                LOGGER.info("New password same as current for account ID: " + acc.getAccountId());
                request.setAttribute(ATTR_ERROR_MSG, "New password must be different from current password.");
                request.getRequestDispatcher("changePassword.jsp").forward(request, response);
                return;
            }
            
            // Update password
            acc.setPasswordHash(hashedNewPassword);
            Response<Account> updateResponse = accountDAO.updateAccount(acc);
            
            if (updateResponse != null && updateResponse.isSuccess()) {
                LOGGER.info("Password changed successfully for account ID: " + acc.getAccountId());
                
                // Clear any error messages
                session.removeAttribute(SESSION_ERROR_MSG);
                
                // Set success message
                session.setAttribute(SESSION_SUCCESS_MSG, "Password changed successfully!");
                
                // Redirect to profile page
                response.sendRedirect("manageProfile");
            } else {
                LOGGER.severe("Failed to update password in database for account ID: " + acc.getAccountId());
                request.setAttribute(ATTR_ERROR_MSG, "Failed to change password. Please try again.");
                request.getRequestDispatcher("changePassword.jsp").forward(request, response);
            }
            
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error processing password change", e);
            handleError(request, response, "An error occurred while changing password. Please try again.");
        }
    }
    
    /**
     * Comprehensive password change validation
     * 
     * @param currentPassword Current password
     * @param newPassword New password
     * @param renewPassword Confirm new password
     * @return ValidationResult with status and message
     */
    private ValidationResult validatePasswordChange(String currentPassword, String newPassword, String renewPassword) {
        // Check current password
        if (currentPassword == null || currentPassword.trim().isEmpty()) {
            return new ValidationResult(false, "Current password is required.");
        }
        
        // Check new password
        if (newPassword == null || newPassword.trim().isEmpty()) {
            return new ValidationResult(false, "New password is required.");
        }
        
        // Check confirm password
        if (renewPassword == null || renewPassword.trim().isEmpty()) {
            return new ValidationResult(false, "Please confirm your new password.");
        }
        
        // Check if passwords match
        if (!newPassword.equals(renewPassword)) {
            return new ValidationResult(false, "New passwords do not match.");
        }
        
        // Check password length
        if (newPassword.length() < MIN_PASSWORD_LENGTH) {
            return new ValidationResult(false, "Password must be at least " + MIN_PASSWORD_LENGTH + " characters long.");
        }
        
        if (newPassword.length() > MAX_PASSWORD_LENGTH) {
            return new ValidationResult(false, "Password must not exceed " + MAX_PASSWORD_LENGTH + " characters.");
        }
        
        // Check for uppercase letter
        if (!newPassword.matches(".*[A-Z].*")) {
            return new ValidationResult(false, "Password must contain at least one uppercase letter.");
        }
        
        // Check for lowercase letter
        if (!newPassword.matches(".*[a-z].*")) {
            return new ValidationResult(false, "Password must contain at least one lowercase letter.");
        }
        
        // Check for digit
        if (!newPassword.matches(".*\\d.*")) {
            return new ValidationResult(false, "Password must contain at least one number.");
        }
        
        // Check for common weak passwords
        if (isCommonPassword(newPassword)) {
            return new ValidationResult(false, "This password is too common. Please choose a stronger password.");
        }
        
        return new ValidationResult(true, null);
    }
    
    /**
     * Check if password is in common weak passwords list
     * 
     * @param password Password to check
     * @return true if password is common/weak
     */
    private boolean isCommonPassword(String password) {
        String lowerPassword = password.toLowerCase();
        String[] commonPasswords = {
            "password", "12345678", "password123", "admin123",
            "qwerty123", "welcome123", "letmein", "monkey123"
        };
        
        for (String common : commonPasswords) {
            if (lowerPassword.equals(common)) {
                return true;
            }
        }
        return false;
    }
    
    /**
     * Verify if provided password matches stored hash
     * 
     * @param storedHash Stored password hash
     * @param providedHash Provided password hash
     * @return true if passwords match
     */
    private boolean verifyPassword(String storedHash, String providedHash) {
        if (storedHash == null || providedHash == null) {
            return false;
        }
        
        // Use constant-time comparison to prevent timing attacks
        return MessageDigest.isEqual(
            storedHash.getBytes(),
            providedHash.getBytes()
        );
    }
    
    /**
     * Handle error by forwarding to change password page with error message
     * 
     * @param request HTTP request
     * @param response HTTP response
     * @param message Error message to display
     */
    private void handleError(HttpServletRequest request, HttpServletResponse response, String message) 
            throws ServletException, IOException {
        request.setAttribute(ATTR_ERROR_MSG, message);
        request.getRequestDispatcher("changePassword.jsp").forward(request, response);
    }
    
    /**
     * Inner class for validation results
     */
    private static class ValidationResult {
        private final boolean valid;
        private final String message;
        
        public ValidationResult(boolean valid, String message) {
            this.valid = valid;
            this.message = message;
        }
        
        public boolean isValid() {
            return valid;
        }
        
        public String getMessage() {
            return message;
        }
    }
    
    @Override
    public String getServletInfo() {
        return "Servlet for changing user password with enhanced security";
    }
    
    @Override
    public void destroy() {
        super.destroy();
        LOGGER.info("ChangePasswordServlet destroyed");
    }
}

