package controller;

import java.io.IOException;
import dto.RegisterRequest;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class ResendOtpServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String purpose = (String) session.getAttribute("otpPurpose");
        String email = (String) session.getAttribute("email");

        if (purpose == null || email == null) {
            request.setAttribute("error", "Không xác định được thông tin để gửi lại OTP. Vui lòng thử lại.");
            request.getRequestDispatcher("verifyOtp.jsp").forward(request, response);
            return;
        }

        Long lastOtpTime = (Long) session.getAttribute("otpTime");
        long now = System.currentTimeMillis();
        if (lastOtpTime != null && now - lastOtpTime < 60 * 1000) {
            long remaining = 60 - ((now - lastOtpTime) / 1000);
            request.setAttribute("error", "Vui lòng chờ " + remaining + " giây trước khi gửi lại OTP.");
            request.getRequestDispatcher("verifyOtp.jsp").forward(request, response);
            return;
        }

        String otp = utils.RandomNumber.getRandomNumber();
        session.setAttribute("otp", otp);
        session.setAttribute("otpTime", now);

        String subject = "Verify your request on CRMS";
        String message = "<p>Chào bạn,</p>"
                + "<p>Đây là mã xác minh (OTP) mới của bạn:</p>"
                + "<h2 style='color:blue;'>" + otp + "</h2>"
                + "<p>Mã có hiệu lực trong vòng 5 phút.</p>"
                + "<br><p>Trân trọng,<br>Đội ngũ hỗ trợ hệ thống của CRMS</p>";

        boolean sent = utils.Email.sendEmail(email, subject, message);

        if (sent) {
            request.setAttribute("error", "Mã OTP mới đã được gửi đến email của bạn.");
        } else {
            request.setAttribute("error", "Không thể gửi lại OTP. Vui lòng thử lại sau.");
        }

        request.getRequestDispatcher("verifyOtp.jsp").forward(request, response);
    }
}
