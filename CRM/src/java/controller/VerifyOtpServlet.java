package controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import dto.RegisterRequest;
import dto.Response;
import jakarta.servlet.http.HttpSession;
import model.Account;
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

        if (inputOtp == null || !inputOtp.trim().matches("^[0-9]{6}$")) {
            request.setAttribute("error", "Mã OTP không hợp lệ. Vui lòng nhập đúng 6 chữ số.");
            request.getRequestDispatcher("verifyOtp.jsp").forward(request, response);
            return;
        }

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
            } else if ("createUser".equals(purpose)) {
                Account pendingUser = (Account) session.getAttribute("pendingUser");
                if (pendingUser != null) {
                    AccountService accountService = new AccountService();
                    Response<Account> createResult = accountService.createAccount(pendingUser);

                    if (createResult.isSuccess()) {
                        session.removeAttribute("pendingUser");
                        session.removeAttribute("otp");
                        session.removeAttribute("otpTime");
                        session.removeAttribute("otpPurpose");

                        response.sendRedirect("user/list?message=User created successfully");
                        return;
                    } else {
                        request.setAttribute("error", createResult.getMessage());
                        request.getRequestDispatcher("verifyOtp.jsp").forward(request, response);
                        return;
                    }
                }
            } else if ("updateUserEmail".equals(purpose)) {
                Account pendingUpdate = (Account) session.getAttribute("pendingUpdateUser");
                if (pendingUpdate != null) {
                    AccountService accountService = new AccountService();
                    Response<Account> result = accountService.updateAccount(pendingUpdate);
                    if (result.isSuccess()) {
                        session.removeAttribute("pendingUpdateUser");
                        session.removeAttribute("otp");
                        session.removeAttribute("otpTime");
                        session.removeAttribute("otpPurpose");
                        response.sendRedirect("user/list?message=User updated successfully");
                        return;
                    } else {
                        request.setAttribute("error", result.getMessage());
                        request.getRequestDispatcher("verifyOtp.jsp").forward(request, response);
                        return;
                    }
                }
            }

        } else {
            // Nếu OTP sai
            request.setAttribute("error", "Mã OTP không đúng.");
            request.getRequestDispatcher("verifyOtp.jsp").forward(request, response);
        }

    }
}
