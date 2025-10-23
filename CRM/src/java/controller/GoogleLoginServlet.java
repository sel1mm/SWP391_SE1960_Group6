package controller;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import constant.Iconstant;
import constant.MessageConstant;
import model.GoogleAccount;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import org.apache.http.client.fluent.Form;
import org.apache.http.client.fluent.Request;
import service.AccountService;
import service.AccountRoleService;
import model.Account;

public class GoogleLoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String code = request.getParameter("code");
        if (code == null || code.isEmpty()) {
            response.sendRedirect("login.jsp");
            return;
        }

        String responseToken = Request.Post(Iconstant.GOOGLE_LINK_GET_TOKEN)
                .bodyForm(Form.form()
                        .add("client_id", Iconstant.GOOGLE_CLIENT_ID)
                        .add("client_secret", Iconstant.GOOGLE_CLIENT_SECRET)
                        .add("redirect_uri", Iconstant.GOOGLE_REDIRECT_URI)
                        .add("code", code)
                        .add("grant_type", Iconstant.GOOGLE_GRANT_TYPE)
                        .build())
                .execute().returnContent().asString();

        JsonObject jobj = new Gson().fromJson(responseToken, JsonObject.class);

        if (jobj == null || jobj.get("access_token") == null) {
            throw new ServletException("❌ Không lấy được access_token từ Google.");
        }

        String accessToken = jobj.get("access_token").getAsString();

        String userInfoJson = Request.Get(Iconstant.GOOGLE_LINK_GET_USER_INFO + accessToken)
                .execute().returnContent().asString();

        GoogleAccount googleUser = new Gson().fromJson(userInfoJson, GoogleAccount.class);
        if (googleUser == null || googleUser.getEmail() == null) {
            throw new ServletException("❌ Không thể lấy thông tin người dùng từ Google.");
        }

        AccountService accountService = new AccountService();
        Account existingAccount = accountService.getAccountByEmail(googleUser.getEmail());

        if (existingAccount == null) {
            Account newAcc = accountService.createGoogleAccount(googleUser.getEmail(), googleUser.getName());
            existingAccount = newAcc; 
        }

        if (existingAccount == null) {
            throw new ServletException("❌ Không thể tạo tài khoản Google mới.");
        }

        HttpSession session = request.getSession();
        session.setAttribute("session_login", existingAccount);
        session.setAttribute("session_login_id", existingAccount.getAccountId());

        AccountRoleService roleService = new AccountRoleService();
        if (roleService.isAdmin(existingAccount.getAccountId())) {
            session.setAttribute("session_role", "admin");
            response.sendRedirect("admin.jsp"); 
        } else if (roleService.isTechnicalManager(existingAccount.getAccountId())) {
            session.setAttribute("session_role", "Technical Manager");
            response.sendRedirect("technicalManagerApproval");
        } else if (roleService.isCustomerSupportStaff(existingAccount.getAccountId())) {
            session.setAttribute("session_role", "customer support staff");
            response.sendRedirect("dashboard.jsp");
        } else if (roleService.isStorekeeper(existingAccount.getAccountId())) {
            session.setAttribute("session_role", "Storekeeper");
            response.sendRedirect(MessageConstant.STOREKEEPER_URL);
        } else if (roleService.isTechnician(existingAccount.getAccountId())) {
            session.setAttribute("session_role", "Technician");
            response.sendRedirect("technician/dashboard");
        } else if (roleService.isCustomer(existingAccount.getAccountId())) {
            session.setAttribute("session_role", "customer");
            response.sendRedirect("managerServiceRequest");
        } else {
            response.sendRedirect("home.jsp");
        }
    }
}
