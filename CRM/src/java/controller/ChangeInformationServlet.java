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
    private static final String UPLOAD_DIR = "D:/Every thing relate to Lam/BTVN/Hoc tap/SWP/app-uploads/avatar";
    private static final String[] ALLOWED_EXTENSIONS = {".jpg", ".jpeg", ".png", ".gif"};
    private static final long MAX_FILE_SIZE = 2 * 1024 * 1024; // 2MB

    @Override
    public void init() throws ServletException {
        super.init();
        profileDAO = new AccountProfileDAO();
        accountDAO = new AccountDAO();
        
        // Create upload directory if it doesn't exist
        File uploadDir = new File(UPLOAD_DIR);
        if (!uploadDir.exists()) {
            boolean created = uploadDir.mkdirs();
            if (created) {
                System.out.println("✅ Created upload directory: " + UPLOAD_DIR);
            } else {
                System.err.println("❌ Failed to create upload directory: " + UPLOAD_DIR);
            }
        }
        System.out.println("✅ ChangeInformationServlet initialized");
        System.out.println("   Upload directory: " + UPLOAD_DIR);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
HttpSession session = request.getSession(false);
        response.setContentType("text/html;charset=UTF-8");

        try {
            System.out.println("\n" + "=".repeat(60));
            System.out.println("========== ChangeInformationServlet GET ==========");
            System.out.println("=".repeat(60));
            
            
       
            if (session == null) {
                System.err.println("❌ Session is NULL - Redirecting to login");
                response.sendRedirect("login.jsp");
                return;
            }
            System.out.println("✅ Session exists: " + session.getId());

            Account acc = (Account) session.getAttribute("session_login");
            if (acc == null || acc.getAccountId() == -1 || acc.getAccountId() == -1) {
                System.err.println("❌ Account not found in session or invalid - Redirecting to login");
                response.sendRedirect("login.jsp");
                return;
            }
            
            System.out.println("✅ Account found in session:");
            System.out.println("   - Account ID: " + acc.getAccountId());
            System.out.println("   - Username: " + acc.getUsername());

            // Load account and profile data
            Response<Account> accountResponse = accountDAO.getAccountById2(acc.getAccountId());
            AccountProfile accountProfile = profileDAO.getProfileByAccountId(acc.getAccountId());

            if (accountResponse != null && accountResponse.getData() != null) {
                Account account = accountResponse.getData();
                UserDTO user = new UserDTO();
                
                user.setFullName(account.getFullName());
                user.setEmail(account.getEmail());
                user.setPhone(account.getPhone());
                
                if (accountProfile != null) {
                    user.setAddress(accountProfile.getAddress());
                    user.setNationalId(accountProfile.getNationalId());
                    user.setDob(accountProfile.getDateOfBirth() != null ? 
                        accountProfile.getDateOfBirth().toString() : "");
                    
                    String avatarUrl = accountProfile.getAvatarUrl();
                    if (avatarUrl != null && !avatarUrl.isEmpty()) {
                        user.setAvatar("avatar/" + avatarUrl);
                    }
                }
                
                session.setAttribute("user", user);
                System.out.println("✅ UserDTO created and stored in session");
                System.out.println("   - Full Name: " + user.getFullName());
                System.out.println("   - Email: " + user.getEmail());
            }

            request.getRequestDispatcher("changeInformation.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("\n❌ ERROR in ChangeInformationServlet GET: " + e.getMessage());
            session.setAttribute("errorMessage", "Unable to load information form: " + e.getMessage());
            response.sendRedirect("storekeeper");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
   
        if (session == null) {
            System.err.println("❌ Session is NULL - Redirecting to login");
            response.sendRedirect("login.jsp");
            return;
        }

        Account acc = (Account) session.getAttribute("session_login");
        if (acc == null || acc.getAccountId() == -1 || acc.getAccountId() == -1) {
            System.err.println("❌ Account not found in session - Redirecting to login");
            response.sendRedirect("login.jsp");
            return;
        }
        
        try {
            System.out.println("\n" + "=".repeat(60));
            System.out.println("========== ChangeInformationServlet POST ==========");
            System.out.println("=".repeat(60));
            
            // Get form parameters
            String fullName = request.getParameter("fullName");
            String email = request.getParameter("email");
            String phone = request.getParameter("phone");
            String address = request.getParameter("address");
            String nationalId = request.getParameter("nationalId");
            String dobString = request.getParameter("dob");

            System.out.println("📝 Form data received:");
            System.out.println("   - Full Name: " + fullName);
            System.out.println("   - Email: " + email);
            System.out.println("   - Phone: " + phone);
            System.out.println("   - Address: " + address);
            System.out.println("   - National ID: " + nationalId);
            System.out.println("   - DOB: " + dobString);

            // Validate input
            String validationError = validateInput(fullName, email, phone, address, nationalId, dobString);
            if (validationError != null) {
                System.err.println("❌ Validation error: " + validationError);
                session.setAttribute("errorMessage", validationError);
                response.sendRedirect("changeInformation");
                return;
            }

            // Parse and validate date of birth
            LocalDate dateOfBirth = null;
            try {
                dateOfBirth = LocalDate.parse(dobString);
                if (!isAtLeast18YearsOld(dateOfBirth)) {
                    session.setAttribute("errorMessage", "You must be at least 18 years old.");
                    response.sendRedirect("changeInformation");
                    return;
                }
            } catch (Exception e) {
                session.setAttribute("errorMessage", "Invalid date format.");
                response.sendRedirect("changeInformation");
                return;
            }

            // Handle avatar upload
            String avatarFileName = null;
            Part avatarPart = request.getPart("avatar");
            if (avatarPart != null && avatarPart.getSize() > 0) {
                System.out.println("📷 Avatar file detected:");
                System.out.println("   - File name: " + avatarPart.getSubmittedFileName());
                System.out.println("   - File size: " + avatarPart.getSize() + " bytes");
                
                try {
                    avatarFileName = handleAvatarUpload(avatarPart, acc.getAccountId());
                    System.out.println("✅ Avatar uploaded successfully: " + avatarFileName);
                } catch (Exception e) {
                    System.err.println("❌ Avatar upload error: " + e.getMessage());
                    session.setAttribute("errorMessage", "Avatar upload failed: " + e.getMessage());
                    response.sendRedirect("changeInformation");
                    return;
                }
            }

            // Update Account table (fullName, email, phone)
            Response<Account> accountResponse = accountDAO.getAccountById2(acc.getAccountId());
            if (accountResponse != null && accountResponse.getData() != null) {
                Account account = accountResponse.getData();
                
                // Store old email for logging
                String oldEmail = account.getEmail();
                
                account.setFullName(fullName);
                account.setEmail(email);
                account.setPhone(phone);

                Response<Account> updateResponse = accountDAO.updateAccount(account);
                if (updateResponse == null || !updateResponse.isSuccess()) {
                    System.err.println("❌ Failed to update account information");
                    session.setAttribute("errorMessage", "Failed to update account information.");
                    response.sendRedirect("changeInformation");
                    return;
                }
                
                System.out.println("✅ Account updated successfully");
                if (!oldEmail.equals(email)) {
                    System.out.println("   - Email changed from: " + oldEmail + " to: " + email);
                }
                
                // Update session_login với thông tin mới
                acc.setFullName(fullName);
                acc.setEmail(email);
                acc.setPhone(phone);
                session.setAttribute("session_login", acc);
            }

            // Update AccountProfile table (address, dob, nationalId, avatar)
            AccountProfile profile = profileDAO.getProfileByAccountId(acc.getAccountId());
            boolean isNewProfile = (profile == null);

            if (isNewProfile) {
                System.out.println("📋 Creating new profile...");
                profile = new AccountProfile();
                profile.setAccountId(acc.getAccountId());
            } else {
                System.out.println("📋 Updating existing profile...");
            }

            profile.setAddress(address);
            profile.setDateOfBirth(dateOfBirth);
            profile.setNationalId(nationalId);

            // Update avatar if new file was uploaded
            if (avatarFileName != null) {
                // Delete old avatar file if exists
                String oldAvatar = profile.getAvatarUrl();
                if (oldAvatar != null && !oldAvatar.isEmpty()) {
                    deleteOldAvatar(oldAvatar);
                }
                profile.setAvatarUrl(avatarFileName);
            }

            boolean success;
            if (isNewProfile) {
                success = profileDAO.insertProfile(profile);
            } else {
                success = profileDAO.updateProfile(profile);
            }

            if (success) {
                System.out.println("✅ Profile " + (isNewProfile ? "created" : "updated") + " successfully");
                
                // Update session with new user data
                UserDTO user = new UserDTO();
                user.setFullName(fullName);
                user.setEmail(email);
                user.setPhone(phone);
                user.setAddress(address);
                user.setNationalId(nationalId);
                user.setDob(dobString);
                
                if (profile.getAvatarUrl() != null && !profile.getAvatarUrl().isEmpty()) {
                    user.setAvatar("avatar/" + profile.getAvatarUrl());
                }
                session.setAttribute("user", user);

                session.setAttribute("successMessage", "Information updated successfully!");
                System.out.println("✅ All operations completed successfully");
                response.sendRedirect("changeInformation");
            } else {
                System.err.println("❌ Failed to " + (isNewProfile ? "create" : "update") + " profile");
                session.setAttribute("errorMessage", "Failed to update information. Please try again.");
                response.sendRedirect("changeInformation");
            }

        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("❌ Unexpected error: " + e.getMessage());
            session.setAttribute("errorMessage", "Unable to update information: " + e.getMessage());
            response.sendRedirect("changeInformation");
        }
    }

    /**
     * Handle avatar file upload
     */
    private String handleAvatarUpload(Part filePart, Integer accountId) throws Exception {
        String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();

        if (!isValidFileExtension(fileName)) {
            throw new Exception("Invalid file type. Only JPG, PNG, and GIF are allowed.");
        }

        if (filePart.getSize() > MAX_FILE_SIZE) {
            throw new Exception("File size exceeds 2MB limit.");
        }

        String extension = fileName.substring(fileName.lastIndexOf('.'));
        String newFileName = "avatar_" + accountId + "_" + System.currentTimeMillis() + extension;

        File uploadDir = new File(UPLOAD_DIR);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        Path filePath = Paths.get(UPLOAD_DIR, newFileName);
        try (InputStream fileContent = filePart.getInputStream()) {
            Files.copy(fileContent, filePath, StandardCopyOption.REPLACE_EXISTING);
        }

        System.out.println("✅ File saved to: " + filePath.toString());
        return newFileName;
    }

    /**
     * Delete old avatar file
     */
    private void deleteOldAvatar(String fileName) {
        try {
            Path filePath = Paths.get(UPLOAD_DIR, fileName);
            if (Files.exists(filePath)) {
                Files.delete(filePath);
                System.out.println("🗑️ Old avatar deleted: " + fileName);
            }
        } catch (IOException e) {
            System.err.println("⚠️ Failed to delete old avatar: " + e.getMessage());
        }
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
     * Check if user is at least 18 years old
     */
    private boolean isAtLeast18YearsOld(LocalDate dateOfBirth) {
        LocalDate today = LocalDate.now();
        Period period = Period.between(dateOfBirth, today);
        return period.getYears() >= 18;
    }

    /**
     * Validate all input fields
     */
    private String validateInput(String fullName, String email, String phone, 
                                 String address, String nationalId, String dob) {
        
        if (fullName == null || fullName.trim().isEmpty() || fullName.trim().length() < 2) {
            return "Full name must be at least 2 characters.";
        }
        
        if (fullName.trim().length() > 50) {
            return "Full name must not exceed 50 characters.";
        }
        
        if (email == null || email.trim().isEmpty() || !email.matches("^[\\w._%+-]+@[\\w.-]+\\.[A-Za-z]{2,}$")) {
            return "Invalid email format.";
        }
        
        if (email.trim().length() > 100) {
            return "Email must not exceed 100 characters.";
        }
        
        // Phone is optional, but if provided must be valid
        if (phone != null && !phone.trim().isEmpty()) {
            if (!phone.matches("^[0-9]{10,11}$")) {
                return "Phone number must be 10-11 digits.";
            }
        }
        
        if (address == null || address.trim().isEmpty() || address.trim().length() < 5) {
            return "Address must be at least 5 characters.";
        }
        
        if (address.trim().length() > 200) {
            return "Address must not exceed 200 characters.";
        }
        
        if (nationalId == null || nationalId.trim().isEmpty() || !nationalId.matches("^[0-9]{9,12}$")) {
            return "National ID must be 9-12 digits.";
        }
        
        if (dob == null || dob.trim().isEmpty()) {
            return "Date of birth is required.";
        }
        
        return null; // No errors
    }

    @Override
    public String getServletInfo() {
        return "Servlet for changing user information with avatar upload support";
    }
    
    /**
     * Data Transfer Object for user information
     */
    public static class UserDTO implements java.io.Serializable {
        private static final long serialVersionUID = 1L;
        
        private String fullName;
        private String email;
        private String phone;
        private String address;
        private String nationalId;
        private String dob;
        private String avatar;

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