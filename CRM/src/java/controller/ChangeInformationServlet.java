package controller;

import dal.AccountDAO;
import dal.AccountProfileDAO;
import dto.Response;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.time.LocalDate;
import java.time.Period;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import model.Account;
import model.AccountProfile;

/**
 * Servlet for changing user information
 * Handles: fullName, email, phone, address, dateOfBirth, nationalId, and avatar upload
 * @author Admin
 */
@WebServlet(name = "ChangeInformationServlet", urlPatterns = {"/changeInformation"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 1,  // 1 MB
    maxFileSize = 1024 * 1024 * 2,        // 2 MB
    maxRequestSize = 1024 * 1024 * 5      // 5 MB
)
public class ChangeInformationServlet extends HttpServlet {

    private AccountProfileDAO profileDAO;
    private AccountDAO accountDAO;
    
    // Avatar upload configuration
    private static final String UPLOAD_DIR = "uploads/avatars";
    private static final String[] ALLOWED_EXTENSIONS = {".jpg", ".jpeg", ".png", ".gif"};
    private static final long MAX_FILE_SIZE = 2 * 1024 * 1024; // 2MB

    @Override
    public void init() throws ServletException {
        super.init();
        profileDAO = new AccountProfileDAO();
        accountDAO = new AccountDAO();
        
        // Create upload directory if it doesn't exist
        String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIR;
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }
        System.out.println("✅ ChangeInformationServlet initialized");
        System.out.println("   Upload directory: " + uploadPath);
    }

    /**
     * Handles the HTTP GET method - Display change information form
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");

        try {
            System.out.println("\n" + "=".repeat(60));
            System.out.println("========== ChangeInformationServlet GET ==========");
            System.out.println("=".repeat(60));
            
            HttpSession session = request.getSession();
       
            if (session == null) {
                System.err.println("❌ Session is NULL - Redirecting to login");
                response.sendRedirect("login.jsp");
                return;
            }
            System.out.println("✅ Session exists: " + session.getId());

            Account acc = (Account) session.getAttribute("session_login");
            if (acc == null || acc.getAccountId() == -1) {
                System.err.println("❌ Account not found in session or invalid - Redirecting to login");
                response.sendRedirect("login.jsp");
                return;
            }
            
            System.out.println("✅ Account found in session:");
            System.out.println("   - Account ID: " + acc.getAccountId());
            System.out.println("   - Username: " + acc.getUsername());

            // Get current account and profile data
            System.out.println("\n--- Fetching Account Data ---");
            Response<Account> accountResponse = accountDAO.getAccountById2(acc.getAccountId());
            System.out.println("Account Response: " + (accountResponse != null ? "Success" : "NULL"));
            if (accountResponse != null && accountResponse.getData() != null) {
                Account account = accountResponse.getData();
                System.out.println("   - Full Name: " + account.getFullName());
                System.out.println("   - Email: " + account.getEmail());
                System.out.println("   - Phone: " + account.getPhone());
            } else {
                System.err.println("❌ Failed to get account data from database");
            }
            
            System.out.println("\n--- Fetching Profile Data ---");
            AccountProfile accountProfile = profileDAO.getProfileByAccountId(acc.getAccountId());
            System.out.println("Profile: " + (accountProfile != null ? "Found" : "NULL"));
            if (accountProfile != null) {
                System.out.println("   - Profile ID: " + accountProfile.getProfileId());
                System.out.println("   - Account ID: " + accountProfile.getAccountId());
                System.out.println("   - Address: " + accountProfile.getAddress());
                System.out.println("   - National ID: " + accountProfile.getNationalId());
                System.out.println("   - DOB: " + accountProfile.getDateOfBirth());
                System.out.println("   - Avatar URL: " + accountProfile.getAvatarUrl());
                System.out.println("   - Verified: " + accountProfile.isVerified());
            } else {
                System.out.println("⚠️ No profile found for this account");
            }

            // Create a user object to store in session for JSP
            System.out.println("\n--- Creating UserDTO for JSP ---");
            if (accountResponse != null && accountResponse.getData() != null) {
                Account account = accountResponse.getData();
                UserDTO user = new UserDTO();
                
                // Data from Account table
                user.setFullName(account.getFullName());
                user.setEmail(account.getEmail());
                user.setPhone(account.getPhone());
                
                // Data from AccountProfile table
                if (accountProfile != null) {
                    user.setAddress(accountProfile.getAddress());
                    user.setNationalId(accountProfile.getNationalId());
                    user.setDob(accountProfile.getDateOfBirth() != null ? 
                        accountProfile.getDateOfBirth().toString() : "");
                    user.setAvatar(accountProfile.getAvatarUrl());
                }
                
                session.setAttribute("user", user);
                System.out.println("✅ UserDTO created and stored in session");
                System.out.println("   - Full Name: " + user.getFullName());
                System.out.println("   - Email: " + user.getEmail());
                System.out.println("   - Phone: " + user.getPhone());
                System.out.println("   - Address: " + user.getAddress());
            }

            System.out.println("\n✅ Forwarding to changeInformation.jsp");
            System.out.println("=".repeat(60) + "\n");
            
            // Forward to JSP
            request.getRequestDispatcher("changeInformation.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("\n❌ ERROR in ChangeInformationServlet GET: " + e.getMessage());
            System.err.println("Stack trace printed above");
            handleError(request, response, "Unable to load information form: " + e.getMessage());
        }
    }

    /**
     * Handles the HTTP POST method - Process form submission
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
   
        if (session == null) {
            System.err.println("❌ Session is NULL - Redirecting to login");
            response.sendRedirect("login.jsp");
            return;
        }

        Account acc = (Account) session.getAttribute("session_login");
        if (acc == null || acc.getAccountId() == -1) {
            System.err.println("❌ Account not found in session - Redirecting to login");
            response.sendRedirect("login.jsp");
            return;
        }
        
        try {
            System.out.println("\n" + "=".repeat(60));
            System.out.println("========== ChangeInformationServlet POST ==========");
            System.out.println("=".repeat(60));
            System.out.println("Account ID: " + acc.getAccountId());
            
            // Get form parameters
            String fullName = request.getParameter("fullName");
            String email = request.getParameter("email");
            String phone = request.getParameter("phone");
            String address = request.getParameter("address");
            String nationalId = request.getParameter("nationalId");
            String dobString = request.getParameter("dob");

            System.out.println("\n--- Form Parameters Received ---");
            System.out.println("Full Name: " + fullName);
            System.out.println("Email: " + email);
            System.out.println("Phone: " + phone);
            System.out.println("Address: " + address);
            System.out.println("National ID: " + nationalId);
            System.out.println("DOB: " + dobString);

            // Validate input
            System.out.println("\n--- Validating Input ---");
            String validationError = validateInput(fullName, email, phone, address, nationalId, dobString);
            if (validationError != null) {
                System.err.println("❌ Validation Failed: " + validationError);
                session.setAttribute("errorMessage", validationError);
                response.sendRedirect("changeInformation");
                return;
            }
            System.out.println("✅ All input validation passed");

            // Convert date string to LocalDate
            System.out.println("\n--- Parsing Date of Birth ---");
            LocalDate dateOfBirth = null;
            try {
                dateOfBirth = LocalDate.parse(dobString);
                System.out.println("✅ Date parsed: " + dateOfBirth);
                
                // Validate age (must be at least 18 years old)
                if (!isAtLeast18YearsOld(dateOfBirth)) {
                    System.err.println("❌ Age validation failed: User is under 18 years old");
                    session.setAttribute("errorMessage", "You must be at least 18 years old.");
                    response.sendRedirect("changeInformation");
                    return;
                }
                System.out.println("✅ Age validation passed (18+ years old)");
            } catch (Exception e) {
                System.err.println("❌ Date parsing failed: " + e.getMessage());
                session.setAttribute("errorMessage", "Invalid date format.");
                response.sendRedirect("changeInformation");
                return;
            }

            // Handle avatar upload
            System.out.println("\n--- Checking Avatar Upload ---");
            String avatarPath = null;
            Part avatarPart = request.getPart("avatar");
            if (avatarPart != null && avatarPart.getSize() > 0) {
                System.out.println("Avatar file detected:");
                System.out.println("   - File name: " + avatarPart.getSubmittedFileName());
                System.out.println("   - File size: " + avatarPart.getSize() + " bytes");
                System.out.println("   - Content type: " + avatarPart.getContentType());
                
                try {
                    avatarPath = handleAvatarUpload(avatarPart, acc.getAccountId());
                    System.out.println("✅ Avatar uploaded successfully: " + avatarPath);
                } catch (Exception e) {
                    System.err.println("❌ Avatar upload error: " + e.getMessage());
                    session.setAttribute("errorMessage", "Avatar upload failed: " + e.getMessage());
                    response.sendRedirect("changeInformation");
                    return;
                }
            } else {
                System.out.println("ℹ️ No avatar file uploaded");
            }

            // ===== UPDATE ACCOUNT TABLE =====
            System.out.println("\n" + "=".repeat(50));
            System.out.println("========== UPDATE ACCOUNT TABLE ==========");
            System.out.println("=".repeat(50));
            
            Response<Account> accountResponse = accountDAO.getAccountById2(acc.getAccountId());
            System.out.println("1. Get account by ID: " + acc.getAccountId());
            System.out.println("   - Response: " + (accountResponse != null ? "Success" : "NULL"));
            System.out.println("   - Account data: " + (accountResponse != null && accountResponse.getData() != null ? "Found" : "NULL"));
            
            if (accountResponse != null && accountResponse.getData() != null) {
                Account account = accountResponse.getData();
                
                System.out.println("\n2. Current Account values:");
                System.out.println("   - Current fullName: " + account.getFullName());
                System.out.println("   - Current email: " + account.getEmail());
                System.out.println("   - Current phone: " + account.getPhone());

                // Update Account fields: fullName, email, phone
                account.setFullName(fullName);
                account.setEmail(email);
                account.setPhone(phone);
                
                System.out.println("\n3. New Account values (after set):");
                System.out.println("   - New fullName: " + account.getFullName());
                System.out.println("   - New email: " + account.getEmail());
                System.out.println("   - New phone: " + account.getPhone());

                System.out.println("\n4. Calling accountDAO.updateAccount()...");
                Response<Account> updateResponse = accountDAO.updateAccount(account);
                
                System.out.println("\n5. Update Account Response:");
                System.out.println("   - Response: " + (updateResponse != null ? "Not NULL" : "NULL"));
                System.out.println("   - isSuccess: " + (updateResponse != null ? updateResponse.isSuccess() : "N/A"));
                System.out.println("   - Message: " + (updateResponse != null ? updateResponse.getMessage() : "N/A"));
                
                if (updateResponse == null || !updateResponse.isSuccess()) {
                    System.err.println("❌ FAILED to update Account table!");
                    session.setAttribute("errorMessage", "Failed to update account information.");
                    response.sendRedirect("changeInformation");
                    return;
                }
                System.out.println("✅ Account table updated successfully!");
            } else {
                System.err.println("❌ Cannot get account from database!");
            }
            System.out.println("=".repeat(50));

            // ===== UPDATE ACCOUNT PROFILE TABLE =====
            System.out.println("\n" + "=".repeat(50));
            System.out.println("========== UPDATE ACCOUNT PROFILE TABLE ==========");
            System.out.println("=".repeat(50));
            
            AccountProfile profile = profileDAO.getProfileByAccountId(acc.getAccountId());
            System.out.println("1. Get profile by accountId: " + acc.getAccountId());
            System.out.println("   - Profile: " + (profile != null ? "Found" : "NULL (will create new)"));
            
            boolean isNewProfile = (profile == null);
            System.out.println("   - Is new profile: " + isNewProfile);

            if (isNewProfile) {
                profile = new AccountProfile();
                profile.setAccountId(acc.getAccountId());
                System.out.println("   - Created new AccountProfile object");
                System.out.println("   - Set accountId: " + acc.getAccountId());
            } else {
                System.out.println("\n2. Current Profile values:");
                System.out.println("   - Profile ID: " + profile.getProfileId());
                System.out.println("   - Account ID: " + profile.getAccountId());
                System.out.println("   - Current address: " + profile.getAddress());
                System.out.println("   - Current nationalId: " + profile.getNationalId());
                System.out.println("   - Current dateOfBirth: " + profile.getDateOfBirth());
                System.out.println("   - Current avatarUrl: " + profile.getAvatarUrl());
                System.out.println("   - Verified: " + profile.isVerified());
            }

            // Set AccountProfile fields: address, dateOfBirth, avatarUrl, nationalId
            System.out.println("\n3. Setting new values...");
            profile.setAddress(address);
            profile.setDateOfBirth(dateOfBirth);
            profile.setNationalId(nationalId);
            System.out.println("   - Address set: " + address);
            System.out.println("   - DateOfBirth set: " + dateOfBirth);
            System.out.println("   - NationalId set: " + nationalId);

            // Update avatar if new file was uploaded
            if (avatarPath != null) {
                System.out.println("\n4. Avatar uploaded:");
                System.out.println("   - New avatar path: " + avatarPath);
                profile.setAvatarUrl(avatarPath);
            } else {
                System.out.println("\n4. No new avatar uploaded");
                if (!isNewProfile) {
                    System.out.println("   - Keeping existing avatar: " + profile.getAvatarUrl());
                }
            }
            
            System.out.println("\n5. Final Profile values (before save):");
            System.out.println("   - Profile ID: " + profile.getProfileId());
            System.out.println("   - Account ID: " + profile.getAccountId());
            System.out.println("   - Address: " + profile.getAddress());
            System.out.println("   - National ID: " + profile.getNationalId());
            System.out.println("   - Date of Birth: " + profile.getDateOfBirth());
            System.out.println("   - Avatar URL: " + profile.getAvatarUrl());

            // Save to database - FIX: Only check isNewProfile, not profileId
            boolean success;
            if (isNewProfile) {
                System.out.println("\n6. Calling profileDAO.insertProfile()...");
                System.out.println("   - Operation: INSERT");
                success = profileDAO.insertProfile(profile);
            } else {
                System.out.println("\n6. Calling profileDAO.updateProfile()...");
                System.out.println("   - Operation: UPDATE");
                System.out.println("   - Updating profileId: " + profile.getProfileId());
                success = profileDAO.updateProfile(profile);
            }

            System.out.println("\n7. Database Operation Result:");
            System.out.println("   - Operation: " + (isNewProfile ? "INSERT" : "UPDATE"));
            System.out.println("   - Success: " + success);
            
            if (!success) {
                System.err.println("❌ FAILED to " + (isNewProfile ? "insert" : "update") + " AccountProfile table!");
            } else {
                System.out.println("✅ AccountProfile table " + (isNewProfile ? "inserted" : "updated") + " successfully!");
            }
            System.out.println("=".repeat(50));

            if (success) {
                System.out.println("\n" + "=".repeat(50));
                System.out.println("========== FINAL SUCCESS ==========");
                System.out.println("=".repeat(50));
                
                // Update session with new user data
                UserDTO user = new UserDTO();
                user.setFullName(fullName);
                user.setEmail(email);
                user.setPhone(phone);
                user.setAddress(address);
                user.setNationalId(nationalId);
                user.setDob(dobString);
                user.setAvatar(profile.getAvatarUrl());
                session.setAttribute("user", user);
                
                System.out.println("✅ Session updated with new user data:");
                System.out.println("   - Full Name: " + user.getFullName());
                System.out.println("   - Email: " + user.getEmail());
                System.out.println("   - Phone: " + user.getPhone());
                System.out.println("   - Address: " + user.getAddress());
                System.out.println("   - National ID: " + user.getNationalId());
                System.out.println("   - DOB: " + user.getDob());
                System.out.println("   - Avatar: " + user.getAvatar());
                System.out.println("\n✅ Redirecting to changeInformation with SUCCESS message");
                System.out.println("=".repeat(50) + "\n");

                // Success message
                session.setAttribute("successMessage", "Information updated successfully!");
                response.sendRedirect("changeInformation");
            } else {
                System.err.println("\n" + "=".repeat(50));
                System.err.println("========== FINAL FAILURE ==========");
                System.err.println("=".repeat(50));
                System.err.println("❌ Failed to update profile in database");
                System.err.println("❌ Redirecting to changeInformation with ERROR message");
                System.err.println("=".repeat(50) + "\n");
                
                session.setAttribute("errorMessage", "Failed to update information. Please try again.");
                response.sendRedirect("changeInformation");
            }

        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("\n" + "=".repeat(50));
            System.err.println("❌ EXCEPTION in ChangeInformationServlet POST");
            System.err.println("=".repeat(50));
            System.err.println("Error message: " + e.getMessage());
            System.err.println("Error class: " + e.getClass().getName());
            System.err.println("Stack trace printed above");
            System.err.println("=".repeat(50) + "\n");
            
            session.setAttribute("errorMessage", "Unable to update information: " + e.getMessage());
            response.sendRedirect("changeInformation");
        }
    }

    /**
     * Handle avatar file upload
     */
    private String handleAvatarUpload(Part filePart, Integer accountId) throws Exception {
        System.out.println("\n--- handleAvatarUpload() ---");
        
        // Get filename
        String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
        System.out.println("Original filename: " + fileName);
        
        // Validate file extension
        if (!isValidFileExtension(fileName)) {
            System.err.println("❌ Invalid file extension: " + fileName);
            throw new Exception("Invalid file type. Only JPG, PNG, and GIF are allowed.");
        }
        System.out.println("✅ File extension valid");
        
        // Validate file size
        if (filePart.getSize() > MAX_FILE_SIZE) {
            System.err.println("❌ File size too large: " + filePart.getSize() + " bytes (max: " + MAX_FILE_SIZE + ")");
            throw new Exception("File size exceeds 2MB limit.");
        }
        System.out.println("✅ File size valid: " + filePart.getSize() + " bytes");
        
        // Generate unique filename
        String fileExtension = fileName.substring(fileName.lastIndexOf("."));
        String newFileName = "avatar_" + accountId + "_" + System.currentTimeMillis() + fileExtension;
        System.out.println("New filename: " + newFileName);
        
        // Get upload path
        String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIR;
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
            System.out.println("Created upload directory: " + uploadPath);
        }
        
        // Save file
        Path filePath = Paths.get(uploadPath, newFileName);
        System.out.println("Saving to: " + filePath.toString());
        
        try (InputStream fileContent = filePart.getInputStream()) {
            Files.copy(fileContent, filePath, StandardCopyOption.REPLACE_EXISTING);
            System.out.println("✅ File saved successfully");
        }
        
        // Return relative path for storing in database
        String relativePath = UPLOAD_DIR + "/" + newFileName;
        System.out.println("Relative path for DB: " + relativePath);
        
        return relativePath;
    }

    /**
     * Validate file extension
     */
    private boolean isValidFileExtension(String fileName) {
        String lowerFileName = fileName.toLowerCase();
        for (String ext : ALLOWED_EXTENSIONS) {
            if (lowerFileName.endsWith(ext)) {
                return true;
            }
        }
        return false;
    }

    /**
     * Check if date of birth is at least 18 years old
     */
    private boolean isAtLeast18YearsOld(LocalDate dateOfBirth) {
        LocalDate today = LocalDate.now();
        Period period = Period.between(dateOfBirth, today);
        int years = period.getYears();
        System.out.println("Age calculation: " + years + " years old");
        return years >= 18;
    }

    /**
     * Get account ID from session
     */
    private Integer getAccountIdFromSession(HttpSession session) {
        if (session != null && session.getAttribute("accountId") != null) {
            return (Integer) session.getAttribute("accountId");
        }
        return null;
    }

    /**
     * Validate all input parameters
     */
    private String validateInput(String fullName, String email, String phone, 
                                 String address, String nationalId, String dob) {
        
        // Validate full name
        if (fullName == null || fullName.trim().isEmpty()) {
            System.out.println("❌ Full name is empty");
            return "Full name is required.";
        }
        if (fullName.trim().length() < 2) {
            System.out.println("❌ Full name too short: " + fullName.trim().length() + " chars");
            return "Full name must be at least 2 characters.";
        }
        System.out.println("✅ Full name valid");
        
        // Validate email
        if (email == null || email.trim().isEmpty()) {
            System.out.println("❌ Email is empty");
            return "Email is required.";
        }
        if (!email.matches("^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$")) {
            System.out.println("❌ Email format invalid: " + email);
            return "Invalid email format.";
        }
        System.out.println("✅ Email valid");
        
        // Validate phone (optional but if provided must be valid)
        if (phone != null && !phone.trim().isEmpty()) {
            if (!phone.matches("^[0-9]{10,11}$")) {
                System.out.println("❌ Phone format invalid: " + phone);
                return "Phone number must be 10-11 digits.";
            }
            System.out.println("✅ Phone valid");
        } else {
            System.out.println("ℹ️ Phone is empty (optional)");
        }
        
        // Validate address
        if (address == null || address.trim().isEmpty()) {
            System.out.println("❌ Address is empty");
            return "Address is required.";
        }
        if (address.trim().length() < 5) {
            System.out.println("❌ Address too short: " + address.trim().length() + " chars");
            return "Address must be at least 5 characters.";
        }
        System.out.println("✅ Address valid");
        
        // Validate national ID
        if (nationalId == null || nationalId.trim().isEmpty()) {
            System.out.println("❌ National ID is empty");
            return "National ID is required.";
        }
        if (!nationalId.matches("^[0-9]{9,12}$")) {
            System.out.println("❌ National ID format invalid: " + nationalId);
            return "National ID must be 9-12 digits.";
        }
        System.out.println("✅ National ID valid");
        
        // Validate date of birth
        if (dob == null || dob.trim().isEmpty()) {
            System.out.println("❌ DOB is empty");
            return "Date of birth is required.";
        }
        System.out.println("✅ DOB valid");
        
        return null; // All validations passed
    }

    /**
     * Handle error by setting error message and redirecting
     */
    private void handleError(HttpServletRequest request, HttpServletResponse response, String message) 
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        session.setAttribute("errorMessage", message);
        System.err.println("⚠️ Handling error: " + message);
        response.sendRedirect("changeInformation");
    }

    /**
     * Returns a short description of the servlet
     */
    @Override
    public String getServletInfo() {
        return "Servlet for changing user information with avatar upload support";
    }
    
    /**
     * Inner class for user data transfer between Servlet and JSP
     * Maps data from Account and AccountProfile tables
     */
    public static class UserDTO implements java.io.Serializable {
        // From Account table
        private String fullName;
        private String email;
        private String phone;
        
        // From AccountProfile table
        private String address;
        private String nationalId;
        private String dob;  // dateOfBirth as String
        private String avatar;  // avatarUrl

        // Getters and Setters
        public String getFullName() { return fullName; }
        public void setFullName(String fullName) { this.fullName = fullName; }
        
        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }
        
        public String getPhone() { return phone; }
        public void setPhone(String phone) { this.phone = phone; }
        
        public String getAddress() { return address; }
        public void setAddress(String address) { this.address = address; }
        
        public String getNationalId() { return nationalId; }
        public void setNationalId(String nationalId) { this.nationalId = nationalId; }
        
        public String getDob() { return dob; }
        public void setDob(String dob) { this.dob = dob; }
        
        public String getAvatar() { return avatar; }
        public void setAvatar(String avatar) { this.avatar = avatar; }
    }
}