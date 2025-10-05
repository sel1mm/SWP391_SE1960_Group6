package controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import dto.RegisterRequest;
import dto.Response;
import jakarta.servlet.http.HttpSession;
import service.AccountService;

/**
 *
 * @author MY PC
 */
public class VerifyOtpServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String inputOtp = request.getParameter("otp");
        HttpSession session = request.getSession();
        String otp = (String) session.getAttribute("otp");
        Long otpTime = (Long) session.getAttribute("otpTime");
        String purpose = (String) session.getAttribute("otpPurpose");

        if (otp == null || otpTime == null || purpose == null) {
            request.setAttribute("error", "OTP không hợp lệ hoặc đã hết hạn.");
            request.getRequestDispatcher("verifyOtp.jsp").forward(request, response);
            return;
        }

        long now = System.currentTimeMillis();
        if (now - otpTime > 5 * 60 * 1000) {
            session.removeAttribute("otp");
            session.removeAttribute("otpTime");
            session.removeAttribute("otpPurpose");
            request.setAttribute("error", "Mã OTP đã hết hạn. Vui lòng yêu cầu lại.");
            request.getRequestDispatcher("verifyOtp.jsp").forward(request, response);
            return;
        }

        if (otp.equals(inputOtp)) {
            if ("register".equals(purpose)) {
                RegisterRequest pendingRegister = (RegisterRequest) session.getAttribute("pendingRegister");
                if (pendingRegister != null) {
                    AccountService accountService = new AccountService();
                    Response<Boolean> registerResponse = accountService.register(pendingRegister);

                    if (registerResponse.isSuccess() && registerResponse.getData()) {
                        session.invalidate();
                        request.setAttribute("error", registerResponse.getMessage());
                        request.getRequestDispatcher("register.jsp").forward(request, response);
                        return;
                    } else {
                        request.setAttribute("error", registerResponse.getMessage());
                        request.getRequestDispatcher("register.jsp").forward(request, response);
                        return;
                    }
                }
            } else if ("forgotPassword".equals(purpose)) {
                session.removeAttribute("otp");
                session.removeAttribute("otpTime");
                session.removeAttribute("otpPurpose");
                response.sendRedirect("resetPassword.jsp");
                return;
            }
        } else {
            request.setAttribute("error", "Mã OTP không đúng.");
            request.getRequestDispatcher("verifyOtp.jsp").forward(request, response);
        }
    }

}
