package controller;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class LogoutController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Nếu để false thì nó sẽ trả về NULL nếu ko có session tồn tại, 
        // nó sẽ trả về session nếu nó tồn tại (chứ không tạo mới 1 session khác)
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate(); // Câu lệnh này để xóa đi các session hiện có
            response.sendRedirect("login.jsp");
        }

    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

    }
}
