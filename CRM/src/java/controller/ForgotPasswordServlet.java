package controller;

import dal.AccountDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Account;
import utils.Email;
import utils.RandomNumber;

@WebServlet(name = "ForgotPasswordServlet", urlPatterns = {"/forgotPassword"})
public class ForgotPasswordServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
    }

     @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = request.getParameter("email");
        AccountDAO dao = new AccountDAO();
        Account acc = dao.getAccountByEmail(email);

        if (acc != null) {
            String otp = RandomNumber.getRandomNumber();
            HttpSession session = request.getSession();
            session.setAttribute("otp", otp);
            session.setAttribute("email", email);
            session.setAttribute("otpTime", System.currentTimeMillis()); 
            session.setAttribute("otpPurpose", "forgotPassword"); 

            String subject = "Verify your request on CRMS";
            String message
                    = "<p>Chào bạn,</p>"
                    + "<p>Chúng tôi đã nhận được yêu cầu đặt lại mật khẩu trên website CRMS từ bạn.</p>"
                    + "<p>Mã xác minh (OTP) của bạn là:</p>"
                    + "<h2 style='color:blue;'>" + otp + "</h2>"
                    + "<p>Mã có hiệu lực trong vòng 5 phút. Nếu bạn không yêu cầu, vui lòng bỏ qua email này.</p>"
                    + "<br><p>Trân trọng,<br>Đội ngũ hỗ trợ hệ thống của CRMS</p>";

            Email.sendEmail(email, subject, message);
            response.sendRedirect("verifyOtp.jsp");
        } else {
            request.setAttribute("error", "Email không tồn tại trong hệ thống.");
            request.getRequestDispatcher("forgotPassword.jsp").forward(request, response);
        }
    }

}
