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
        profileDAO = new AccountProfileDAO();
        accountDAO = new AccountDAO();
        System.out.println("✅ ManageProfileServlet initialized");
    }
    
    /**
     * Handles the HTTP GET method - Display profile page
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("text/html;charset=UTF-8");
        
        try {
            // Get account ID from session
            HttpSession session = request.getSession();
            Account acc = (Account) session.getAttribute("session_login");

            if (acc == null || acc.getAccountId() == -1) {
                response.sendRedirect("login.jsp");
                return;
            }

            // Get account and profile data
            Response<Account> accountResponse = accountDAO.getAccountById(acc.getAccountId());
            AccountProfile accountProfile = profileDAO.getProfileByAccountId(acc.getAccountId());
            
            // Debug logging
            System.out.println("=== ManageProfileServlet GET ===");
            System.out.println("Account ID: " + acc.getAccountId());
            System.out.println("Account Response: " + accountResponse);
            if (accountResponse != null && accountResponse.getData() != null) {
                System.out.println("Account Data: " + accountResponse.getData().getFullName());
            } else {
                System.out.println("Account Data is NULL");
            }
            System.out.println("Profile: " + accountProfile);
            if (accountProfile != null) {
                System.out.println("   - Profile ID: " + accountProfile.getProfileId());
                System.out.println("   - Avatar URL: " + accountProfile.getAvatarUrl());
            }
            System.out.println("================================");
            
            // ✅ THÊM - Load avatar vào session (giống StorekeeperServlet)
            if (accountProfile != null) {
                ChangeInformationServlet.UserDTO user = new ChangeInformationServlet.UserDTO();
                user.setFullName(acc.getFullName());
                user.setEmail(acc.getEmail());
                user.setPhone(acc.getPhone());
                user.setAddress(accountProfile.getAddress());
                user.setNationalId(accountProfile.getNationalId());
                user.setDob(accountProfile.getDateOfBirth() != null ? 
                    accountProfile.getDateOfBirth().toString() : "");
                user.setAvatar(accountProfile.getAvatarUrl()); // ✅ Avatar từ DB
                
                session.setAttribute("user", user);
                
                System.out.println("✅ ManageProfileServlet: Updated session with avatar");
                System.out.println("   - Avatar: " + user.getAvatar());
            }
            
            // Set attributes for JSP
            request.setAttribute("account", accountResponse);
            request.setAttribute("accountProfile", accountProfile);
            
            // Forward to JSP
            request.getRequestDispatcher("manageProfile.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("❌ Error in ManageProfileServlet GET: " + e.getMessage());
            
            // Redirect to error page or show error message
            request.setAttribute("errorMessage", "Unable to load profile: " + e.getMessage());
            request.getRequestDispatcher("error.jsp").forward(request, response);
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
            // Get account ID from session
            HttpSession session = request.getSession();
            Account acc = (Account) session.getAttribute("session_login");

            if (acc == null || acc.getAccountId() == -1) {
                response.sendRedirect("login.jsp");
                return;
            }
            
            // Get action parameter
            String action = request.getParameter("action");
            
            System.out.println("=== ManageProfileServlet POST ===");
            System.out.println("Action: " + action);
            System.out.println("Account ID: " + acc.getAccountId());
            System.out.println("================================");
            
            // Get data for display
            Response<Account> accountResponse = accountDAO.getAccountById(acc.getAccountId());
            AccountProfile accountProfile = profileDAO.getProfileByAccountId(acc.getAccountId());
            
            // ✅ THÊM - Load avatar vào session
            if (accountProfile != null) {
                ChangeInformationServlet.UserDTO user = new ChangeInformationServlet.UserDTO();
                user.setFullName(acc.getFullName());
                user.setEmail(acc.getEmail());
                user.setPhone(acc.getPhone());
                user.setAddress(accountProfile.getAddress());
                user.setNationalId(accountProfile.getNationalId());
                user.setDob(accountProfile.getDateOfBirth() != null ? 
                    accountProfile.getDateOfBirth().toString() : "");
                user.setAvatar(accountProfile.getAvatarUrl()); // ✅ Avatar từ DB
                
                session.setAttribute("user", user);
            }
            
            // Set attributes
            request.setAttribute("account", accountResponse);
            request.setAttribute("accountProfile", accountProfile);
            
            // Handle different actions
            if (action != null) {
                if (action.equalsIgnoreCase("changePassword")) {
                    request.getRequestDispatcher("changePassword.jsp").forward(request, response);
                    return;
                } else if (action.equalsIgnoreCase("editInformation")) {
                    request.getRequestDispatcher("changeInformation.jsp").forward(request, response);
                    return;
                }
            }
            
            // Default: redirect back to profile page
            response.sendRedirect("manageProfile");
            
        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("❌ Error in ManageProfileServlet POST: " + e.getMessage());
            
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