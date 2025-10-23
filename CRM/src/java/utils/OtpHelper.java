package utils;

import jakarta.servlet.http.HttpSession;

public class OtpHelper {
    public static void sendOtpToEmail(HttpSession session, String email, String purpose) {
        String otp = RandomNumber.getRandomNumber();
        long now = System.currentTimeMillis();

        // Lưu OTP vào session
        session.setAttribute("otp", otp);
        session.setAttribute("otpTime", now);
        session.setAttribute("otpPurpose", purpose);
        session.setAttribute("email", email);

        String subject = "Xác minh email CRMS";
        String message = "<p>Xin chào,</p>"
                + "<p>Mã xác minh OTP của bạn là:</p>"
                + "<h2 style='color:blue;'>" + otp + "</h2>"
                + "<p>Mã có hiệu lực trong 5 phút.</p>"
                + "<br><p>Trân trọng,<br>CRMS System</p>";

        Email.sendEmail(email, subject, message);
    }
}
