package controller;

import dto.Response;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Account;
import service.AccountService;
import utils.Email;
import utils.RandomNumber;
import java.io.IOException;

/**
 * Handles request for changing user's email (via OTP verification)
 * @author Admin
 */

public class ChangeEmailServlet extends HttpServlet {

    private final AccountService accountService = new AccountService();
    private static final int OTP_VALIDITY_MINUTES = 5;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        try {
            System.out.println("\n" + "=".repeat(60));
            System.out.println("========== ChangeEmailServlet POST ==========");
            System.out.println("=".repeat(60));

            HttpSession session = request.getSession(false);

            // 1. Check login
            if (session == null) {
                System.err.println("❌ Session is NULL");
                response.sendRedirect("login.jsp");
                return;
            }

            Account currentAcc = (Account) session.getAttribute("session_login");
            if (currentAcc == null || currentAcc.getAccountId() == -1) {
                System.err.println("❌ User not logged in");
                session.setAttribute("errorMessage", "Please log in first.");
                response.sendRedirect("login.jsp");
                return;
            }

            System.out.println("✅ User logged in: " + currentAcc.getEmail());

            // 2. Get parameters
            String newEmail = request.getParameter("newEmail");
            String confirmEmail = request.getParameter("confirmEmail");

            System.out.println("📧 Request to change email:");
            System.out.println("   - Current email: " + currentAcc.getEmail());
            System.out.println("   - New email: " + newEmail);

            // 3. Validate input
            String validationError = validateEmailInput(newEmail, confirmEmail, currentAcc.getEmail());
            if (validationError != null) {
                System.err.println("❌ Validation error: " + validationError);
                session.setAttribute("errorMessage", validationError);
                response.sendRedirect("changeInformation");
                return;
            }

            // 4. Check if email already exists
            Response<Boolean> existResponse = accountService.isEmailExists(newEmail);
            if (existResponse != null && existResponse.isSuccess() && 
                Boolean.TRUE.equals(existResponse.getData())) {
                System.err.println("❌ Email already exists: " + newEmail);
                session.setAttribute("errorMessage", "This email is already registered.");
                response.sendRedirect("changeInformation");
                return;
            }

            // 5. Generate OTP
            String otp = RandomNumber.getRandomNumber();
            long otpTime = System.currentTimeMillis();

            // 6. Send OTP to new email
            String subject = "Verify Your New Email Address - CRMS";
            String message = buildOtpEmailMessage(otp, currentAcc.getFullName());

            boolean sent = Email.sendEmail(newEmail, subject, message);

            if (!sent) {
                System.err.println("❌ Failed to send OTP email");
                session.setAttribute("errorMessage", 
                    "Cannot send OTP. Please check your email address or try again later.");
                response.sendRedirect("changeInformation");
                return;
            }

            // 7. Save OTP to session
            session.setAttribute("otp", otp);
            session.setAttribute("otpTime", otpTime);
            session.setAttribute("otpPurpose", "changeEmail");
            session.setAttribute("pendingNewEmail", newEmail);
            session.setAttribute("email", newEmail); // For resend OTP

            System.out.println("✅ OTP sent successfully");
            System.out.println("   - To: " + newEmail);
            System.out.println("   - OTP: " + otp);
            System.out.println("   - Valid for: " + OTP_VALIDITY_MINUTES + " minutes");

            // 8. Redirect to verify page
            response.sendRedirect("verifyOtp2.jsp");

        } catch (Exception e) {
            System.err.println("❌ Unexpected error: " + e.getMessage());
            e.printStackTrace();
            HttpSession session = request.getSession(false);
            if (session != null) {
                session.setAttribute("errorMessage", "An error occurred. Please try again.");
            }
            response.sendRedirect("changeInformation");
        }
    }

    /**
     * Validate email input
     */
    private String validateEmailInput(String newEmail, String confirmEmail, String currentEmail) {
        if (newEmail == null || newEmail.trim().isEmpty()) {
            return "New email is required.";
        }

        if (confirmEmail == null || confirmEmail.trim().isEmpty()) {
            return "Please confirm your new email.";
        }

        if (!newEmail.equals(confirmEmail)) {
            return "Email confirmation does not match.";
        }

        if (!newEmail.matches("^[\\w._%+-]+@[\\w.-]+\\.[A-Za-z]{2,}$")) {
            return "Invalid email format.";
        }

        if (newEmail.equalsIgnoreCase(currentEmail)) {
            return "New email must be different from the current email.";
        }

        return null; // No errors
    }

    /**
     * Build OTP email message
     */
    private String buildOtpEmailMessage(String otp, String fullName) {
        return "<!DOCTYPE html>" +
                "<html>" +
                "<head>" +
                "<style>" +
                "body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }" +
                ".container { max-width: 600px; margin: 0 auto; padding: 20px; }" +
                ".header { background: linear-gradient(135deg, #212529 0%, #343a40 100%); color: white; padding: 20px; text-align: center; border-radius: 10px 10px 0 0; }" +
                ".content { background: #f8f9fa; padding: 30px; border-radius: 0 0 10px 10px; }" +
                ".otp-box { background: white; border: 2px solid #212529; border-radius: 10px; padding: 20px; text-align: center; margin: 20px 0; }" +
                ".otp-code { font-size: 32px; font-weight: bold; color: #212529; letter-spacing: 5px; }" +
                ".footer { text-align: center; margin-top: 20px; font-size: 12px; color: #6c757d; }" +
                "</style>" +
                "</head>" +
                "<body>" +
                "<div class='container'>" +
                "<div class='header'>" +
                "<h1>Email Verification</h1>" +
                "</div>" +
                "<div class='content'>" +
                "<p>Hello " + (fullName != null ? fullName : "User") + ",</p>" +
                "<p>You have requested to change your email address on CRMS.</p>" +
                "<p>Your verification code is:</p>" +
                "<div class='otp-box'>" +
                "<div class='otp-code'>" + otp + "</div>" +
                "</div>" +
                "<p><strong>This code is valid for " + OTP_VALIDITY_MINUTES + " minutes.</strong></p>" +
                "<p>If you did not request this change, please ignore this email.</p>" +
                "</div>" +
                "<div class='footer'>" +
                "<p>This is an automated message, please do not reply.</p>" +
                "<p>&copy; 2025 CRMS - All rights reserved</p>" +
                "</div>" +
                "</div>" +
                "</body>" +
                "</html>";
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("changeInformation");
    }

    @Override
    public String getServletInfo() {
        return "Servlet for changing user's email via OTP verification";
    }
}