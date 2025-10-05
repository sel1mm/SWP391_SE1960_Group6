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
import utils.passwordHasher;

@WebServlet(name="ResetPasswordServlet", urlPatterns={"/resetPassword"})
public class ResetPasswordServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
    } 

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        String newPass = request.getParameter("newPassword");
        String confirm = request.getParameter("confirmPassword");

        HttpSession session = request.getSession();
        String email = (String) session.getAttribute("email");

        if (newPass.equals(confirm)) {
            AccountDAO dao = new AccountDAO();
            String hashed = passwordHasher.hashPassword(newPass);
            dao.updatePasswordByEmail(email, hashed);

            session.removeAttribute("otp");
            session.removeAttribute("email");
            response.sendRedirect("login.jsp");
        } else {
            request.setAttribute("error", "Mật khẩu nhập lại không khớp.");
            request.getRequestDispatcher("resetPassword.jsp").forward(request, response);
        }
    }
}
