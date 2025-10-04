package controller;

import constant.MessageConstant;
import java.io.IOException;
import dto.RegisterRequest;
import dto.Response;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class RegisterController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher(MessageConstant.REGISTER_URL).forward(request, response);

    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String fullname = request.getParameter("fullName");
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String email = request.getParameter("email");
        String phoneNumber = request.getParameter("phoneNumber");

        RegisterRequest requestRegister = new RegisterRequest(username, password, fullname, email, phoneNumber);

        // Gọi AccountService để check trùng username/email/phone trước
        service.AccountService accountService = new service.AccountService();
        Response<Boolean> checkResponse = accountService.checkRegisterValid(requestRegister);

        if (!checkResponse.isSuccess() || !checkResponse.getData()) {
            // Nếu không hợp lệ thì quay về register.jsp và hiển thị lỗi
            request.setAttribute("error", checkResponse.getMessage());
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        // Nếu hợp lệ thì mới sinh OTP
        String otp = utils.RandomNumber.getRandomNumber();

        HttpSession session = request.getSession();
        session.setAttribute("pendingRegister", requestRegister);
        session.setAttribute("otp", otp);
        session.setAttribute("otpTime", System.currentTimeMillis());
        session.setAttribute("email", email);
        session.setAttribute("otpPurpose", "register");

        // Gửi mail OTP
        String subject = "Verify your request on CRMS";
        String message = "<p>Chào bạn,</p>"
                + "<p>Bạn đã đăng ký tài khoản trên website CRMS.</p>"
                + "<p>Mã xác minh (OTP) của bạn là:</p>"
                + "<h2 style='color:blue;'>" + otp + "</h2>"
                + "<p>Mã có hiệu lực trong vòng 5 phút.</p>"
                + "<br><p>Trân trọng,<br>Đội ngũ hỗ trợ hệ thống của CRMS</p>";

        utils.Email.sendEmail(email, subject, message);

        response.sendRedirect("verifyOtp.jsp");
    }

}
