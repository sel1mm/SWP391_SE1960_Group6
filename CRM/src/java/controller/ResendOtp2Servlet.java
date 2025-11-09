package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Account;
import service.EmailService;
import java.io.IOException;

/**
 * Servlet for resending OTP code
 * @author Admin
 */
public class ResendOtp2Servlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        try {
            System.out.println("\n" + "=".repeat(60));
            System.out.println("========== ResendOtp2Servlet POST ==========");
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

            // 2. Get pending email and purpose from session
            String pendingNewEmail = (String) session.getAttribute("pendingNewEmail");
            String otpPurpose = (String) session.getAttribute("otpPurpose");

            System.out.println("📝 Resend OTP Request:");
            System.out.println("   - User: " + currentUser.getEmail());
            System.out.println("   - Pending New Email: " + pendingNewEmail);
            System.out.println("   - Purpose: " + otpPurpose);

            // 3. Validate required data
            if (pendingNewEmail == null || pendingNewEmail.trim().isEmpty()) {
                System.err.println("❌ No pending email found in session");
                request.setAttribute("error", "Session expired. Please try again.");
                request.getRequestDispatcher("verifyOtp2.jsp").forward(request, response);
                return;
            }

            if (otpPurpose == null || otpPurpose.trim().isEmpty()) {
                System.err.println("❌ No OTP purpose found in session");
                request.setAttribute("error", "Invalid request. Please try again.");
                request.getRequestDispatcher("verifyOtp2.jsp").forward(request, response);
                return;
            }

            // 4. Generate new OTP
            String newOtp = generateOTP();
            System.out.println("🔑 Generated new OTP: " + newOtp);

            // 5. Send OTP email
            boolean emailSent = false;

            if ("changeEmail".equals(otpPurpose)) {
                String emailSubject = "Email Verification - OTP Code";
                String emailContent = buildEmailChangeOTPContent(currentUser.getFullName(), newOtp);
                
                // Send email using EmailService instance
                try {
                    EmailService emailService = new EmailService();
                    emailSent = emailService.sendEmail(pendingNewEmail, emailSubject, emailContent);
                } catch (Exception e) {
                    System.err.println("❌ Error sending email: " + e.getMessage());
                    emailSent = false;
                }
            }

            if (!emailSent) {
                System.err.println("❌ Failed to send OTP email");
                request.setAttribute("error", "Failed to send OTP. Please try again.");
                request.getRequestDispatcher("verifyOtp2.jsp").forward(request, response);
                return;
            }

            System.out.println("✅ OTP email sent successfully to: " + pendingNewEmail);

            // 6. Update session with new OTP
            session.setAttribute("otp", newOtp);
            session.setAttribute("otpTime", System.currentTimeMillis());
            // Keep otpPurpose and pendingNewEmail unchanged

            // 7. Set success message and forward
            request.setAttribute("success", "A new OTP code has been sent to your email.");
            request.getRequestDispatcher("verifyOtp2.jsp").forward(request, response);

            System.out.println("✅ OTP resend completed successfully");

        } catch (Exception e) {
            System.err.println("❌ Unexpected error: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "An error occurred. Please try again.");
            request.getRequestDispatcher("verifyOtp2.jsp").forward(request, response);
        }
    }

    /**
     * Generate a 6-digit OTP
     */
    private String generateOTP() {
        int otp = (int) (Math.random() * 900000) + 100000;
        return String.valueOf(otp);
    }

    /**
     * Build email content for email change OTP
     */
    private String buildEmailChangeOTPContent(String fullName, String otp) {
        return "<!DOCTYPE html>" +
               "<html>" +
               "<head>" +
               "    <style>" +
               "        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }" +
               "        .container { max-width: 600px; margin: 0 auto; padding: 20px; }" +
               "        .header { background: linear-gradient(135deg, #212529 0%, #343a40 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }" +
               "        .content { background: #f8f9fa; padding: 30px; border-radius: 0 0 10px 10px; }" +
               "        .otp-box { background: white; border: 2px dashed #212529; padding: 20px; text-align: center; margin: 20px 0; border-radius: 10px; }" +
               "        .otp-code { font-size: 32px; font-weight: bold; color: #212529; letter-spacing: 5px; font-family: 'Courier New', monospace; }" +
               "        .warning { background: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 20px 0; }" +
               "        .footer { text-align: center; margin-top: 20px; font-size: 12px; color: #6c757d; }" +
               "    </style>" +
               "</head>" +
               "<body>" +
               "    <div class='container'>" +
               "        <div class='header'>" +
               "            <h2>🔐 Email Verification</h2>" +
               "        </div>" +
               "        <div class='content'>" +
               "            <p>Hello <strong>" + fullName + "</strong>,</p>" +
               "            <p>You have requested to change your email address. Please use the following OTP code to verify:</p>" +
               "            <div class='otp-box'>" +
               "                <div class='otp-code'>" + otp + "</div>" +
               "            </div>" +
               "            <div class='warning'>" +
               "                <strong>⚠️ Important:</strong>" +
               "                <ul>" +
               "                    <li>This code will expire in <strong>5 minutes</strong></li>" +
               "                    <li>Do not share this code with anyone</li>" +
               "                    <li>If you didn't request this, please ignore this email</li>" +
               "                </ul>" +
               "            </div>" +
               "            <p>Best regards,<br><strong>Your Application Team</strong></p>" +
               "        </div>" +
               "        <div class='footer'>" +
               "            <p>This is an automated email. Please do not reply.</p>" +
               "        </div>" +
               "    </div>" +
               "</body>" +
               "</html>";
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Redirect GET requests to POST
        response.sendRedirect("verifyOtp2");
    }

    @Override
    public String getServletInfo() {
        return "Servlet for resending OTP codes";
    }
}