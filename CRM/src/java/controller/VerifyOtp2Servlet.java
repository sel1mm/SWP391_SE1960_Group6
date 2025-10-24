package controller;

import dal.AccountDAO;
import dto.Response;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Account;
import service.AccountService;
import java.io.IOException;

/**
 * Servlet for verifying OTP code
 * Handles: Email change verification, Password reset verification
 * @author Admin
 */

public class VerifyOtp2Servlet extends HttpServlet {

    private final AccountService accountService = new AccountService();
    private final AccountDAO accountDAO = new AccountDAO();
    private static final long OTP_VALIDITY_MS = 5 * 60 * 1000; // 5 minutes

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        
        // Check if user has valid OTP session
        if (session == null || session.getAttribute("otp") == null) {
            response.sendRedirect("changeInformation");
            return;
        }
        
        request.getRequestDispatcher("verifyOtp.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        try {
            System.out.println("\n" + "=".repeat(60));
            System.out.println("========== VerifyOtpServlet POST ==========");
            System.out.println("=".repeat(60));

            HttpSession session = request.getSession(false);

            // 1. Check session
            if (session == null) {
                System.err.println("❌ Session is NULL");
                response.sendRedirect("login.jsp");
                return;
            }

            Account currentUser = (Account) session.getAttribute("session_login");
            if (currentUser == null || currentUser.getAccountId() == -1) {
                System.err.println("❌ User not logged in");
                response.sendRedirect("login.jsp");
                return;
            }

            // 2. Get OTP data from session
            String sessionOtp = (String) session.getAttribute("otp");
            Long otpTime = (Long) session.getAttribute("otpTime");
            String otpPurpose = (String) session.getAttribute("otpPurpose");
            String newEmail = (String) session.getAttribute("pendingNewEmail");

            // 3. Get input OTP
            String inputOtp = request.getParameter("otpInput");

            System.out.println("📝 OTP Verification:");
            System.out.println("   - Input OTP: " + inputOtp);
            System.out.println("   - Session OTP: " + sessionOtp);
            System.out.println("   - Purpose: " + otpPurpose);
            System.out.println("   - New Email: " + newEmail);

            // 4. Validate OTP exists in session
            if (sessionOtp == null || otpTime == null) {
                System.err.println("❌ No OTP found in session");
                request.setAttribute("error", "OTP session expired. Please request a new one.");
                request.getRequestDispatcher("verifyOtp2.jsp").forward(request, response);
                return;
            }

            // 5. Check OTP expiry
            long currentTime = System.currentTimeMillis();
            long timeDiff = currentTime - otpTime;
            
            if (timeDiff > OTP_VALIDITY_MS) {
                System.err.println("❌ OTP expired. Time difference: " + (timeDiff / 1000) + " seconds");
                
                // Clear expired OTP
                session.removeAttribute("otp");
                session.removeAttribute("otpTime");
                session.removeAttribute("otpPurpose");
                session.removeAttribute("pendingNewEmail");
                
                request.setAttribute("error", "OTP has expired. Please request a new one.");
                request.getRequestDispatcher("verifyOtp2.jsp").forward(request, response);
                return;
            }

            // 6. Validate input OTP
            if (inputOtp == null || inputOtp.trim().isEmpty()) {
                System.err.println("❌ No OTP input provided");
                request.setAttribute("error", "Please enter the OTP code.");
                request.getRequestDispatcher("verifyOtp2.jsp").forward(request, response);
                return;
            }

            // 7. Check OTP match
            if (!inputOtp.trim().equals(sessionOtp)) {
                System.err.println("❌ Invalid OTP. Input: " + inputOtp + ", Expected: " + sessionOtp);
                request.setAttribute("error", "Invalid OTP code. Please try again.");
                request.getRequestDispatcher("verifyOtp2.jsp").forward(request, response);
                return;
            }

            System.out.println("✅ OTP verified successfully");

            // 8. Handle based on purpose
            if ("changeEmail".equals(otpPurpose)) {
                handleEmailChange(session, currentUser, newEmail, response);
            } else {
                System.err.println("❌ Unknown OTP purpose: " + otpPurpose);
                request.setAttribute("error", "Invalid verification purpose.");
                request.getRequestDispatcher("verifyOtp2.jsp").forward(request, response);
            }

        } catch (Exception e) {
            System.err.println("❌ Unexpected error: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "An error occurred during verification. Please try again.");
            request.getRequestDispatcher("verifyOtp2.jsp").forward(request, response);
        }
    }

    /**
     * Handle email change after OTP verification
     */
    private void handleEmailChange(HttpSession session, Account user, String newEmail, 
                                   HttpServletResponse response) throws IOException {
        try {
            System.out.println("📧 Processing email change:");
            System.out.println("   - Account ID: " + user.getAccountId());
            System.out.println("   - Old email: " + user.getEmail());
            System.out.println("   - New email: " + newEmail);

            if (newEmail == null || newEmail.trim().isEmpty()) {
                System.err.println("❌ New email is empty");
                session.setAttribute("errorMessage", "Invalid email data.");
                response.sendRedirect("changeInformation");
                return;
            }

            // Update email in database
            boolean updateSuccess = accountService.updateEmail(newEmail,user.getAccountId());

            if (!updateSuccess) {
                System.err.println("❌ Failed to update email in database");
                session.setAttribute("errorMessage", "Failed to update email. Please try again.");
                response.sendRedirect("changeInformation");
                return;
            }

            System.out.println("✅ Email updated in database");

            // Update session_login
            user.setEmail(newEmail);
            session.setAttribute("session_login", user);

            // Update UserDTO in session
            Response<Account> accountResponse = accountDAO.getAccountById2(user.getAccountId());
            if (accountResponse != null && accountResponse.getData() != null) {
                Account updatedAccount = accountResponse.getData();
                
                // Update UserDTO
                Object userDTOObj = session.getAttribute("user");
                if (userDTOObj != null && userDTOObj instanceof controller.ChangeInformationServlet.UserDTO) {
                    controller.ChangeInformationServlet.UserDTO userDTO = 
                        (controller.ChangeInformationServlet.UserDTO) userDTOObj;
                    userDTO.setEmail(newEmail);
                    session.setAttribute("user", userDTO);
                    System.out.println("✅ UserDTO updated in session");
                }
            }

            // Clear OTP data from session
            session.removeAttribute("otp");
            session.removeAttribute("otpTime");
            session.removeAttribute("otpPurpose");
            session.removeAttribute("pendingNewEmail");
            session.removeAttribute("email");

            System.out.println("✅ Email change completed successfully");

            // Redirect with success message
            session.setAttribute("successMessage", "Email changed successfully!");
            response.sendRedirect("changeInformation");

        } catch (Exception e) {
            System.err.println("❌ Error in handleEmailChange: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("errorMessage", "An error occurred while updating email.");
            response.sendRedirect("changeInformation");
        }
    }

    @Override
    public String getServletInfo() {
        return "Servlet for verifying OTP codes";
    }
}