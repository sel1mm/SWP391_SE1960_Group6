package service;

import java.util.Properties;
import javax.mail.*;
import javax.mail.internet.*;

/**
 * Service class for sending emails via Gmail
 * @author Admin
 */
public class EmailService {

    // ============= EMAIL CONFIGURATION =============
    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final String SMTP_PORT = "587";
    private static final String EMAIL_USERNAME = "leanhvux123456789@gmail.com";
    private static final String EMAIL_PASSWORD = "vipeucltkjskttiu";
    private static final String FROM_EMAIL = "leanhvux123456789@gmail.com";
    private static final String FROM_NAME = "FPT University - OTP System";

    /**
     * Send email to recipient
     * @param toEmail Recipient email address
     * @param subject Email subject
     * @param htmlContent Email content (HTML format)
     * @return true if email sent successfully, false otherwise
     */
    public boolean sendEmail(String toEmail, String subject, String htmlContent) {
        try {
            System.out.println("\n" + "=".repeat(50));
            System.out.println("📧 SENDING EMAIL");
            System.out.println("=".repeat(50));
            System.out.println("From: " + FROM_EMAIL);
            System.out.println("To: " + toEmail);
            System.out.println("Subject: " + subject);
            System.out.println("Timestamp: " + new java.util.Date());

            // Setup mail server properties
            Properties props = new Properties();
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");
            props.put("mail.smtp.host", SMTP_HOST);
            props.put("mail.smtp.port", SMTP_PORT);
            props.put("mail.smtp.ssl.protocols", "TLSv1.2");
            props.put("mail.smtp.ssl.trust", SMTP_HOST);
            
            // Timeout settings để tránh treo
            props.put("mail.smtp.connectiontimeout", "10000"); // 10 seconds
            props.put("mail.smtp.timeout", "10000");
            props.put("mail.smtp.writetimeout", "10000");

            System.out.println("🔐 Authenticating with Gmail...");

            // Create authenticator
            Authenticator auth = new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(EMAIL_USERNAME, EMAIL_PASSWORD);
                }
            };

            // Create session
            Session session = Session.getInstance(props, auth);
            session.setDebug(false); // Đặt true để debug chi tiết

            System.out.println("📝 Creating email message...");

            // Create message
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(FROM_EMAIL, FROM_NAME));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject(subject);
            message.setContent(htmlContent, "text/html; charset=UTF-8");
            message.setSentDate(new java.util.Date());

            System.out.println("🚀 Sending email via Gmail SMTP...");

            // Send message
            Transport.send(message);

            System.out.println("✅ EMAIL SENT SUCCESSFULLY!");
            System.out.println("=".repeat(50) + "\n");
            return true;

        } catch (AuthenticationFailedException e) {
            System.err.println("\n❌ AUTHENTICATION FAILED!");
            System.err.println("➡️ Kiểm tra:");
            System.err.println("   1. Email: " + EMAIL_USERNAME);
            System.err.println("   2. App Password có đúng 16 ký tự không?");
            System.err.println("   3. Đã bật 2-Step Verification chưa?");
            System.err.println("Error: " + e.getMessage());
            return false;

        } catch (MessagingException e) {
            System.err.println("\n❌ MESSAGING ERROR!");
            System.err.println("Error type: " + e.getClass().getName());
            System.err.println("Error message: " + e.getMessage());
            e.printStackTrace();
            return false;

        } catch (Exception e) {
            System.err.println("\n❌ UNEXPECTED ERROR!");
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Send simple text email
     * @param toEmail Recipient email address
     * @param subject Email subject
     * @param textContent Email content (plain text)
     * @return true if email sent successfully, false otherwise
     */
    public boolean sendTextEmail(String toEmail, String subject, String textContent) {
        try {
            Properties props = new Properties();
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");
            props.put("mail.smtp.host", SMTP_HOST);
            props.put("mail.smtp.port", SMTP_PORT);
            props.put("mail.smtp.ssl.trust", SMTP_HOST);

            Authenticator auth = new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(EMAIL_USERNAME, EMAIL_PASSWORD);
                }
            };

            Session session = Session.getInstance(props, auth);
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(FROM_EMAIL, FROM_NAME));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject(subject);
            message.setText(textContent);

            Transport.send(message);
            return true;

        } catch (Exception e) {
            System.err.println("❌ Failed to send text email: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Test email configuration
     */
    public static void main(String[] args) {
        System.out.println("🧪 TESTING EMAIL SERVICE...\n");
        
        EmailService emailService = new EmailService();
        
        // Test với email của bạn
        String testEmail = "leanhvux712@gmail.com"; // Email test
        String subject = "Test OTP Email";
        String content = "<h1>🔐 Test OTP Code</h1><p>Your OTP is: <strong>123456</strong></p>";
        
        boolean result = emailService.sendEmail(testEmail, subject, content);
        
        System.out.println("\n" + "=".repeat(50));
        System.out.println("📊 TEST RESULT: " + (result ? "✅ SUCCESS" : "❌ FAILED"));
        System.out.println("=".repeat(50));
    }
}