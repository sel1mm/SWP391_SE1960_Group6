package controller;

import dal.AccountDAO;
import dal.AccountProfileDAO;
import dto.Response;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import model.Account;
import model.AccountProfile;

/**
 * Servlet for managing user profile
 * @author Admin
 */
@WebServlet(name = "ManageProfileServlet", urlPatterns = {"/manageProfile"})
public class ManageProfileServlet extends HttpServlet {
    
    private AccountProfileDAO profileDAO;
    private AccountDAO accountDAO;
    
    @Override
    public void init() throws ServletException {
        super.init();
        try {
            profileDAO = new AccountProfileDAO();
            accountDAO = new AccountDAO();
            System.out.println("✅ ManageProfileServlet initialized successfully");
        } catch (Exception e) {
            System.err.println("❌ CRITICAL: Failed to initialize ManageProfileServlet");
            e.printStackTrace();
            throw new ServletException("Failed to initialize servlet", e);
        }
    }
    
    /**
     * Handles the HTTP GET method - Display profile page
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("text/html;charset=UTF-8");
        
        try {
            System.out.println("\n" + "=".repeat(60));
            System.out.println("========== ManageProfileServlet GET ==========");
            System.out.println("=".repeat(60));
            
            // ✅ Step 1: Check session
            HttpSession session = request.getSession(false);
            if (session == null) {
                System.err.println("❌ Session is NULL");
                response.sendRedirect("login.jsp");
                return;
            }
            System.out.println("✅ Step 1: Session exists - ID: " + session.getId());
            
            // ✅ Step 2: Get account from session
            Account acc = null;
            try {
                acc = (Account) session.getAttribute("session_login");
            } catch (Exception e) {
                System.err.println("❌ Error getting session_login: " + e.getMessage());
                e.printStackTrace();
            }
            
            if (acc == null) {
                System.err.println("❌ session_login is NULL");
                response.sendRedirect("login.jsp");
                return;
            }
            
            if (acc.getAccountId() == -1) {
                System.err.println("❌ Invalid account ID: " + acc.getAccountId());
                response.sendRedirect("login.jsp");
                return;
            }
            
            System.out.println("✅ Step 2: Account found");
            System.out.println("   - Account ID: " + acc.getAccountId());
            System.out.println("   - Username: " + acc.getUsername());

            // ✅ Step 3: Get account data from database
            Response<Account> accountResponse = null;
            try {
                accountResponse = accountDAO.getAccountById2(acc.getAccountId());
                System.out.println("✅ Step 3: AccountDAO query executed");
            } catch (Exception e) {
                System.err.println("❌ Error calling accountDAO.getAccountById2: " + e.getMessage());
                e.printStackTrace();
                throw e;
            }
            
            if (accountResponse == null) {
                System.err.println("❌ accountResponse is NULL");
                request.setAttribute("errorMessage", "Failed to load account data");
                request.getRequestDispatcher("error.jsp").forward(request, response);
                return;
            }
            
            if (accountResponse.getData() == null) {
                System.err.println("❌ accountResponse.getData() is NULL");
                request.setAttribute("errorMessage", "Account data not found");
                request.getRequestDispatcher("error.jsp").forward(request, response);
                return;
            }
            
            Account account = accountResponse.getData();
            System.out.println("✅ Account Data loaded:");
            System.out.println("   - Full Name: " + account.getFullName());
            System.out.println("   - Email: " + account.getEmail());
            
            // ✅ Step 4: Get profile data from database
            AccountProfile accountProfile = null;
            try {
                accountProfile = profileDAO.getProfileByAccountId(acc.getAccountId());
                System.out.println("✅ Step 4: ProfileDAO query executed");
            } catch (Exception e) {
                System.err.println("⚠️ Error calling profileDAO.getProfileByAccountId: " + e.getMessage());
                e.printStackTrace();
                // Don't throw - profile might not exist yet
            }
            
            if (accountProfile != null) {
                System.out.println("✅ Profile Data loaded:");
                System.out.println("   - Profile ID: " + accountProfile.getProfileId());
                System.out.println("   - Address: " + accountProfile.getAddress());
                System.out.println("   - Avatar URL: " + accountProfile.getAvatarUrl());
            } else {
                System.out.println("⚠️ Profile Data is NULL (user may not have profile yet)");
            }
            
            // ✅ Step 5: Create UserDTO and load into session
            try {
                ChangeInformationServlet.UserDTO user = new ChangeInformationServlet.UserDTO();
                
                // Load from Account table (always exists)
                user.setFullName(account.getFullName() != null ? account.getFullName() : "");
                user.setEmail(account.getEmail() != null ? account.getEmail() : "");
                user.setPhone(account.getPhone() != null ? account.getPhone() : "");
                
                // Load from AccountProfile table (might not exist)
                if (accountProfile != null) {
                    user.setAddress(accountProfile.getAddress() != null ? accountProfile.getAddress() : "");
                    user.setNationalId(accountProfile.getNationalId() != null ? accountProfile.getNationalId() : "");
                    user.setDob(accountProfile.getDateOfBirth() != null ? 
                        accountProfile.getDateOfBirth().toString() : "");
                    
                    // Only set avatar if exists
                    String avatarUrl = accountProfile.getAvatarUrl();
                    if (avatarUrl != null && !avatarUrl.trim().isEmpty()) {
                        user.setAvatar(avatarUrl);
                        System.out.println("✅ Avatar loaded: " + avatarUrl);
                    } else {
                        System.out.println("ℹ️ No avatar found for user");
                    }
                } else {
                    System.out.println("ℹ️ Using default values for profile fields");
                }
                
                session.setAttribute("user", user);
                System.out.println("✅ Step 5: UserDTO stored in session");
                
            } catch (Exception e) {
                System.err.println("❌ Error creating UserDTO: " + e.getMessage());
                e.printStackTrace();
                throw e;
            }
            
            // ✅ Step 6: Set attributes for JSP
            request.setAttribute("account", accountResponse);
            request.setAttribute("accountProfile", accountProfile);
            
            System.out.println("=".repeat(60));
            System.out.println("✅ All steps completed - Forwarding to manageProfile.jsp");
            System.out.println("=".repeat(60) + "\n");
            
            // Forward to JSP
            request.getRequestDispatcher("manageProfile.jsp").forward(request, response);
            
        } catch (Exception e) {
            System.err.println("\n" + "=".repeat(60));
            System.err.println("❌❌❌ EXCEPTION in ManageProfileServlet GET ❌❌❌");
            System.err.println("=".repeat(60));
            System.err.println("Exception type: " + e.getClass().getName());
            System.err.println("Exception message: " + e.getMessage());
            System.err.println("Stack trace:");
            e.printStackTrace();
            System.err.println("=".repeat(60) + "\n");
            
            // Set error message and forward to error page
            request.setAttribute("errorMessage", "Unable to load profile: " + e.getMessage());
            request.setAttribute("exceptionType", e.getClass().getSimpleName());
            
            try {
                request.getRequestDispatcher("error.jsp").forward(request, response);
            } catch (Exception ex) {
                System.err.println("❌ Failed to forward to error.jsp: " + ex.getMessage());
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "System error");
            }
        }
    }
    
    /**
     * Handles the HTTP POST method - Handle form submissions
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("text/html;charset=UTF-8");
        
        try {
            System.out.println("\n" + "=".repeat(60));
            System.out.println("========== ManageProfileServlet POST ==========");
            System.out.println("=".repeat(60));
            
            // Get account ID from session
            HttpSession session = request.getSession(false);
            if (session == null) {
                System.err.println("❌ Session is NULL");
                response.sendRedirect("login.jsp");
                return;
            }
            
            Account acc = (Account) session.getAttribute("session_login");
            if (acc == null || acc.getAccountId() == -1 || acc.getAccountId() == -1) {
                System.err.println("❌ Account not found in session");
                response.sendRedirect("login.jsp");
                return;
            }
            
            // Get action parameter
            String action = request.getParameter("action");
            System.out.println("📝 Action: " + action);
            System.out.println("📝 Account ID: " + acc.getAccountId());
            
            // Get data for display
            Response<Account> accountResponse = accountDAO.getAccountById2(acc.getAccountId());
            AccountProfile accountProfile = profileDAO.getProfileByAccountId(acc.getAccountId());
            
            // Update session (same logic as GET)
            if (accountResponse != null && accountResponse.getData() != null) {
                Account account = accountResponse.getData();
                ChangeInformationServlet.UserDTO user = new ChangeInformationServlet.UserDTO();
                
                user.setFullName(account.getFullName() != null ? account.getFullName() : "");
                user.setEmail(account.getEmail() != null ? account.getEmail() : "");
                user.setPhone(account.getPhone() != null ? account.getPhone() : "");
                
                if (accountProfile != null) {
                    user.setAddress(accountProfile.getAddress() != null ? accountProfile.getAddress() : "");
                    user.setNationalId(accountProfile.getNationalId() != null ? accountProfile.getNationalId() : "");
                    user.setDob(accountProfile.getDateOfBirth() != null ? 
                        accountProfile.getDateOfBirth().toString() : "");
                    
                    String avatarUrl = accountProfile.getAvatarUrl();
                    if (avatarUrl != null && !avatarUrl.trim().isEmpty()) {
                        user.setAvatar(avatarUrl);
                        System.out.println("✅ Avatar loaded: " + avatarUrl);
                    }
                }
                
                session.setAttribute("user", user);
                System.out.println("✅ Session updated");
            }
            
            // Set attributes
            request.setAttribute("account", accountResponse);
            request.setAttribute("accountProfile", accountProfile);
            
            // Handle different actions
            if (action != null) {
                if (action.equalsIgnoreCase("changePassword")) {
                    System.out.println("→ Forwarding to changePassword.jsp");
                    request.getRequestDispatcher("changePassword.jsp").forward(request, response);
                    return;
                } else if (action.equalsIgnoreCase("editInformation")) {
                    System.out.println("→ Forwarding to changeInformation.jsp");
                    request.getRequestDispatcher("changeInformation.jsp").forward(request, response);
                    return;
                }
            }
            
            System.out.println("✅ Redirecting to manageProfile\n");
            response.sendRedirect("manageProfile");
            
        } catch (Exception e) {
            System.err.println("\n❌ EXCEPTION in ManageProfileServlet POST");
            System.err.println("Exception: " + e.getMessage());
            e.printStackTrace();
            
            request.setAttribute("errorMessage", "Unable to process request: " + e.getMessage());
            request.getRequestDispatcher("error.jsp").forward(request, response);
        }
    }
    
    /**
     * Returns a short description of the servlet
     */
    @Override
    public String getServletInfo() {
        return "Servlet for managing user profile information with avatar support";
    }
}