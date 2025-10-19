
package controller;

import constant.MessageConstant;
import dto.Response;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Account;
import service.AccountRoleService;
import service.AccountService;

public class LoginController extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher(MessageConstant.LOGIN_URL).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String remember = request.getParameter("remember");
        
        AccountService accountService = new AccountService();
        AccountRoleService accountRoleService = new AccountRoleService();
        Response<Account> accountResponse = accountService.checkLogin(username, password);
        if(accountResponse.isSuccess()){
            //Tạo 1 phiên đăng nhập
            HttpSession session = request.getSession(); // Tạo mới 1 session
            session.setAttribute("session_login", accountResponse.getData());
            session.setAttribute("session_login_id", accountResponse.getData().getAccountId());
            // Gán role vào session
            String userRole = accountRoleService.getUserRole(accountResponse.getData().getAccountId());
            session.setAttribute("session_role", userRole);

            // User đang muốn lưu username và password vào cookie của trình duyệt để lần sau không cần nhập username và password lại
            if (remember != null) {
                // Tạo cookie và gán dữ liệu muốn lưu trữ vào cookie
                Cookie usernameCookie = new Cookie("COOKIE_USERNAME", username);
                Cookie passwordCookie = new Cookie("COOKIE_PASSWORD", password);

                // BẮT BUỘC: SET THỜI GIAN TUỔI TÁC CHO COOKIE
                usernameCookie.setMaxAge(60 * 60 * 24); // Đơn vị cookie default là giây (second)
                passwordCookie.setMaxAge(60 * 60 * 24);

                // Thêm Cookie vào response để response nó lưu cookie vào trình duyệt
                response.addCookie(usernameCookie);
                response.addCookie(passwordCookie);
            } else {
                Cookie[] cookies = request.getCookies();
                if (cookies != null) {
                    for (Cookie cookie : cookies) {
                        if (cookie.getName().equals("COOKIE_USERNAME")) {
                            cookie.setMaxAge(0);
                            response.addCookie(cookie);
                        }

                        if (cookie.getName().equals("COOKIE_PASSWORD")) {
                            cookie.setMaxAge(0);
                            response.addCookie(cookie);
                        }
                    }
                }
            }
           
//            request.getRequestDispatcher("welcome.html").forward(request, response); // Dùng câu này khi gửi kèm dữ liệu
             // Điều hướng theo vai trò
            if ("Admin".equals(userRole)) {
                response.sendRedirect(MessageConstant.ADMIN_URL);
            } else if ("Technical Manager".equals(userRole)) {
                response.sendRedirect("technicalManagerApproval");
            } else if ("Customer Support Staff".equals(userRole)) {
                response.sendRedirect("dashboard.jsp");
            } else if("Storekeeper".equals(userRole)){
                response.sendRedirect(MessageConstant.STOREKEEPER_URL);
            } else {
                response.sendRedirect("home.jsp");
            }
        } else {
            request.setAttribute("error", MessageConstant.LOGIN_FAILED);
            request.getRequestDispatcher(MessageConstant.LOGIN_URL).forward(request, response);
        }
    }

}
