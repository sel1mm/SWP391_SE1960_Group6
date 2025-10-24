package controller;

import constant.MessageConstant;
import dto.Response;
import model.Account;
import service.AccountService;
import service.AccountRoleService;
import service.RoleService;
import utils.passwordHasher;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet(name = "UserController", urlPatterns = {"/user/*"})
public class UserController extends HttpServlet {

    private AccountService accountService;
    private AccountRoleService accountRoleService;
    private RoleService roleService;

    @Override
    public void init() throws ServletException {
        super.init();
        accountService = new AccountService();
        accountRoleService = new AccountRoleService();
        roleService = new RoleService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getPathInfo();

        if (action == null) {
            action = "/list";
        }

        switch (action) {
            case "/list":
                listUsers(request, response);
                break;
            case "/create":
                showCreateForm(request, response);
                break;
            case "/edit":
                showEditForm(request, response);
                break;
            case "/delete":
                deleteUser(request, response);
                break;
            case "/roles":
                showUserRoles(request, response);
                break;
            default:
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getPathInfo();

        if (action == null) {
            action = "/create";
        }

        switch (action) {
            case "/create":
                createUser(request, response);
                break;
            case "/update":
                updateUser(request, response);
                break;
            case "/updatePassword":
                updatePassword(request, response);
                break;
            case "/assignRole":
                assignRole(request, response);
                break;
            case "/removeRole":
                removeRole(request, response);
                break;
            default:
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    private void listUsers(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 👉 Lấy message hoặc error từ query string
        String message = request.getParameter("message");
        String error = request.getParameter("error");
        if (message != null && !message.trim().isEmpty()) {
            request.setAttribute("message", message);
        }
        if (error != null && !error.trim().isEmpty()) {
            request.setAttribute("error", error);
        }

        String keyword = request.getParameter("keyword");
        String status = request.getParameter("status");
        String roleId = request.getParameter("roleId");

        Response<List<Account>> result;
        if ((keyword != null && !keyword.trim().isEmpty())
                || (status != null && !status.trim().isEmpty())
                || (roleId != null && !roleId.trim().isEmpty())) {
            result = accountService.searchAccountsWithRole(keyword, status, roleId);
        } else {
            result = accountService.getAllAccounts();
        }

        if (result.isSuccess()) {
            List<Account> users = result.getData();
            request.setAttribute("users", users);
            
            // Load roles for all users
            if (users != null && !users.isEmpty()) {
                List<Integer> accountIds = new java.util.ArrayList<>();
                for (Account user : users) {
                    accountIds.add(user.getAccountId());
                }
                
                Response<java.util.Map<Integer, List<model.Role>>> rolesResult = 
                    accountRoleService.getRolesForAccounts(accountIds);
                
                if (rolesResult.isSuccess()) {
                    request.setAttribute("userRolesMap", rolesResult.getData());
                }
            }
        } else {
            request.setAttribute("error", result.getMessage());
        }
        
        // Load all roles for filter dropdown
        Response<List<model.Role>> allRolesResult = roleService.getAllRoles();
        if (allRolesResult.isSuccess()) {
            request.setAttribute("allRoles", allRolesResult.getData());
        }

        // Forward đến trang JSP hiển thị danh sách
        request.getRequestDispatcher("/WEB-INF/views/user/list.jsp").forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Response<List<model.Role>> rolesResult = roleService.getAllRoles();
        if (rolesResult.isSuccess()) {
            request.setAttribute("roles", rolesResult.getData());
        }
        request.getRequestDispatcher("/WEB-INF/views/user/create.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "User ID is required");
            return;
        }

        try {
            int userId = Integer.parseInt(idParam);
            Response<Account> result = accountService.getAccountById(userId);

            if (result.isSuccess() && result.getData() != null) {
                request.setAttribute("user", result.getData());

                // Get available roles
                Response<List<model.Role>> rolesResult = roleService.getAllRoles();
                if (rolesResult.isSuccess()) {
                    request.setAttribute("roles", rolesResult.getData());
                }

                // Get user's current roles
                Response<List<model.AccountRole>> userRolesResult = accountRoleService.getRolesByAccountId(userId);
                if (userRolesResult.isSuccess()) {
                    request.setAttribute("userRoles", userRolesResult.getData());
                }

                request.getRequestDispatcher("/WEB-INF/views/user/edit.jsp").forward(request, response);
            } else {
                request.setAttribute("error", "User not found");
                request.getRequestDispatcher("/WEB-INF/views/user/list.jsp").forward(request, response);
            }
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid user ID");
        }
    }

    private void createUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String status = request.getParameter("status");
        String[] roleIds = request.getParameterValues("roleIds");

        Account account = new Account();
        account.setUsername(username);
        account.setFullName(fullName);
        account.setEmail(email);
        account.setPhone(phone);
        account.setStatus(status != null ? status : "Active");

        // ================= VALIDATION =================
        String error = null;
        //Validate username chuẩn thực tế (giống Google/GitHub)
        if (username == null || username.trim().isEmpty()) {
            error = "Username is required.";
        } else if (!username.matches("^[A-Za-z][A-Za-z0-9._-]{3,19}$")) {
            error = "Username must start with a letter, be 4–20 characters long, and can include letters, numbers, '.', '_', or '-'.";
        } else if (username.matches(".*[._-]{2,}.*")) {
            error = "Username cannot contain consecutive special characters (like '..' or '__').";
        } else if (username.endsWith(".") || username.endsWith("_") || username.endsWith("-")) {
            error = "Username cannot end with '.', '_' or '-'.";
        }
        // 1️⃣ Full name không được chứa số
        if (fullName == null || fullName.trim().isEmpty()) {
            error = "Full name is required.";
        } else if (!fullName.matches("^[a-zA-ZÀ-ỹ\\s]+$")) {
            error = "Full name must not contain numbers or special characters.";
        } else if (phone == null || phone.trim().isEmpty()) {
            error = "Phone is required.";
        } else if (phone != null && !phone.trim().isEmpty() && !phone.matches("^\\d{9,11}$")) {
            // 2️⃣ Số điện thoại chỉ được chứa số (9–11 chữ số)
            error = "Phone number must contain only digits (9–11 digits).";
        } else if (password == null || password.trim().isEmpty()) {
            // 3️⃣ Password không được để trống
            error = "Password is required.";
        } else if (!password.matches("^(?=.*[A-Za-z0-9])[A-Za-z0-9!@#$%^&*()_+=-]{6,30}$")) {
            error = "Password must be 6–30 characters and may include letters, numbers, or special characters (!@#$%^&*()_+=-).";
        } else {
            // 5️⃣ Email không trùng
            Response<Boolean> emailExists = accountService.isEmailExists(email);
            if (emailExists.isSuccess() && emailExists.getData()) {
                error = "Email already exists.";
            }
        }

        // 6️⃣ Số điện thoại không trùng
        if (error == null && phone != null && !phone.trim().isEmpty()) {
            Response<Boolean> phoneExists = accountService.isPhoneExists(phone);
            if (phoneExists.isSuccess() && phoneExists.getData()) {
                error = "Phone number already exists.";
            }
        }

        // Nếu có lỗi → quay lại form
        if (error != null) {
            request.setAttribute("error", error);
            request.setAttribute("user", account);

            Response<List<model.Role>> rolesResult = roleService.getAllRoles();
            if (rolesResult.isSuccess()) {
                request.setAttribute("roles", rolesResult.getData());
            }

            request.getRequestDispatcher("/WEB-INF/views/user/create.jsp").forward(request, response);
            return;
        }

// Hash password trước khi lưu vào session để khi xác minh tạo luôn được
        account.setPasswordHash(passwordHasher.hashPassword(password));

// Lưu user tạm và gửi OTP
        HttpSession session = request.getSession();
        session.setAttribute("pendingUser", account);
        session.setAttribute("pendingUserRoleIds", roleIds); // Save roleIds for later
        utils.OtpHelper.sendOtpToEmail(session, email, "createUser");
        request.getRequestDispatcher("/verifyOtp.jsp").forward(request, response);
        return;

    }

    private void updateUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "User ID is required");
            return;
        }

        try {
            int userId = Integer.parseInt(idParam);
            String username = request.getParameter("username");
            String fullName = request.getParameter("fullName");
            String email = request.getParameter("email");
            String phone = request.getParameter("phone");
            String status = request.getParameter("status");

            Account account = new Account();
            account.setAccountId(userId);
            account.setUsername(username);
            account.setFullName(fullName);
            account.setEmail(email);
            account.setPhone(phone);
            account.setStatus(status);

            // ✅ VALIDATE CƠ BẢN
            String error = null;
            if (fullName == null || fullName.trim().isEmpty()) {
                error = "Full name is required.";
            } else if (!fullName.matches("^[a-zA-ZÀ-ỹ\\s]+$")) {
                error = "Full name must not contain numbers or special characters.";
            } else if (phone == null || phone.trim().isEmpty()) {
                error = "Phone is required.";
            } else if (!phone.matches("^\\d{9,11}$")) {
                error = "Phone number must contain only digits (9–11 digits).";
            }

            if (error != null) {
                request.setAttribute("error", error);
                request.setAttribute("user", account);
                reloadRolesAndReturn(request, response);
                return;
            }

            // ✅ LẤY USER CŨ ĐỂ KIỂM TRA EMAIL
            Response<Account> existingAccRes = accountService.getAccountById(userId);
            Account oldAccount = existingAccRes.getData();

            // 🔹 Nếu email thay đổi → gửi OTP xác minh
            if (oldAccount != null && !oldAccount.getEmail().trim().equalsIgnoreCase(email.trim())) {
                HttpSession session = request.getSession();
                session.setAttribute("pendingUpdateUser", account);
                utils.OtpHelper.sendOtpToEmail(session, email.trim(), "updateUserEmail");
                request.getRequestDispatcher("/verifyOtp.jsp").forward(request, response);
                return;
            }

            // 🔹 Nếu KHÔNG đổi email → kiểm tra trùng lặp & cập nhật luôn
            Response<Boolean> emailExists = accountService.isEmailExistsForUpdate(email.trim(), userId);
            if (emailExists.isSuccess() && emailExists.getData()) {
                request.setAttribute("error", "Email already exists.");
                request.setAttribute("user", account);
                reloadRolesAndReturn(request, response);
                return;
            }

            Response<Boolean> phoneExists = accountService.isPhoneExistsForUpdate(phone.trim(), userId);
            if (phoneExists.isSuccess() && phoneExists.getData()) {
                request.setAttribute("error", "Phone number already exists.");
                request.setAttribute("user", account);
                reloadRolesAndReturn(request, response);
                return;
            }

            // 🔹 Nếu không đổi email → update luôn
            Response<Account> result = accountService.updateAccount(account);
            if (result.isSuccess()) {
                response.sendRedirect(request.getContextPath() + "/user/list?message="
                        + java.net.URLEncoder.encode("User updated successfully", "UTF-8"));
            } else {
                request.setAttribute("error", result.getMessage());
                request.setAttribute("user", account);
                reloadRolesAndReturn(request, response);
            }

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid user ID");
        }
    }

    /**
     * Tải lại danh sách role và quay lại form edit.jsp khi có lỗi
     */
    private void reloadRolesAndReturn(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Response<List<model.Role>> rolesResult = roleService.getAllRoles();
        if (rolesResult.isSuccess()) {
            request.setAttribute("roles", rolesResult.getData());
        }
        request.getRequestDispatcher("/WEB-INF/views/user/edit.jsp").forward(request, response);
    }

    private void updatePassword(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "User ID is required");
            return;
        }

        int userId;
        try {
            userId = Integer.parseInt(idParam);
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid user ID");
            return;
        }

        // ===== VALIDATION =====
        String error = null;
        if (newPassword == null || newPassword.trim().isEmpty()) {
            error = "New password is required.";
        } else if (!newPassword.matches("^(?=.*[A-Za-z0-9])[A-Za-z0-9!@#$%^&*()_+=-]{6,30}$")) {
            error = "Password must be 6–30 characters and may include letters, numbers, or special characters (!@#$%^&*()_+=-).";
        } else if (!newPassword.equals(confirmPassword)) {
            error = "Passwords do not match.";
        }

        // Lấy user để hiển thị lại form
        Response<Account> userResult = accountService.getAccountById(userId);
        if (userResult.isSuccess() && userResult.getData() != null) {
            request.setAttribute("user", userResult.getData());
        }

        if (error != null) {
            request.setAttribute("error", error);
            request.getRequestDispatcher("/WEB-INF/views/user/edit.jsp").forward(request, response);
            return;
        }

        // ===== CẬP NHẬT PASSWORD =====
        Response<Account> result = accountService.updatePassword(userId, newPassword);

        if (result.isSuccess()) {
            request.setAttribute("message", "Password updated successfully!");
            request.getRequestDispatcher("/WEB-INF/views/user/edit.jsp").forward(request, response);
        } else {
            request.setAttribute("error", result.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/user/edit.jsp").forward(request, response);
        }
    }

    private void deleteUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "User ID is required");
            return;
        }

        try {
            int userId = Integer.parseInt(idParam);

            // 🔹 Lấy thông tin người dùng đang đăng nhập
            HttpSession session = request.getSession(false);
            Account currentLogin = (session != null) ? (Account) session.getAttribute("account") : null;

            // 🔹 Kiểm tra nếu người đang login trùng với userId cần inactive
            if (currentLogin != null && currentLogin.getAccountId() == userId) {
                response.sendRedirect(request.getContextPath() + "/user/list?error="
                        + java.net.URLEncoder.encode("You cannot deactivate your own account.", "UTF-8"));
                return;
            }

            // 🔹 Lấy thông tin user mục tiêu
            Response<Account> userResponse = accountService.getAccountById(userId);
            if (!userResponse.isSuccess() || userResponse.getData() == null) {
                response.sendRedirect(request.getContextPath() + "/user/list?error="
                        + java.net.URLEncoder.encode("User not found", "UTF-8"));
                return;
            }

            Account targetUser = userResponse.getData();
            String newStatus = targetUser.getStatus().equalsIgnoreCase("Active") ? "Inactive" : "Active";

            // 🔹 Cập nhật trạng thái
            targetUser.setStatus(newStatus);
            Response<Account> updateResult = accountService.updateAccount(targetUser);

            if (updateResult.isSuccess()) {
                String message = newStatus.equals("Active")
                        ? "User activated successfully"
                        : "User inactivated successfully";
                response.sendRedirect(request.getContextPath() + "/user/list?message="
                        + java.net.URLEncoder.encode(message, "UTF-8"));
            } else {
                response.sendRedirect(request.getContextPath() + "/user/list?error="
                        + java.net.URLEncoder.encode(updateResult.getMessage(), "UTF-8"));
            }

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid user ID");
        }
    }

    private void showUserRoles(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "User ID is required");
            return;
        }

        try {
            int userId = Integer.parseInt(idParam);

            // Get user info
            Response<Account> userResult = accountService.getAccountById(userId);
            if (!userResult.isSuccess() || userResult.getData() == null) {
                request.setAttribute("error", "User not found");
                request.getRequestDispatcher("/WEB-INF/views/user/list.jsp").forward(request, response);
                return;
            }

            request.setAttribute("user", userResult.getData());

            // Get all roles
            Response<List<model.Role>> rolesResult = roleService.getAllRoles();
            if (rolesResult.isSuccess()) {
                request.setAttribute("roles", rolesResult.getData());
            }

            // Get user's current roles
            Response<List<model.AccountRole>> userRolesResult = accountRoleService.getRolesByAccountId(userId);
            if (userRolesResult.isSuccess()) {
                request.setAttribute("userRoles", userRolesResult.getData());
            }

            request.getRequestDispatcher("/WEB-INF/views/user/roles.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid user ID");
        }
    }

    private void assignRole(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String userIdParam = request.getParameter("userId");
        String roleIdParam = request.getParameter("roleId");

        if (userIdParam == null || roleIdParam == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "User ID and Role ID are required");
            return;
        }

        try {
            int userId = Integer.parseInt(userIdParam);
            int roleId = Integer.parseInt(roleIdParam);

            Response<model.AccountRole> result = accountRoleService.assignRoleToAccount(userId, roleId);

            // Check if this is an AJAX request
            String ajaxHeader = request.getHeader("X-Requested-With");
            boolean isAjax = "XMLHttpRequest".equals(ajaxHeader) || 
                           request.getContentType() != null && request.getContentType().contains("application/x-www-form-urlencoded");
            
            if (isAjax) {
                // Return JSON response for AJAX
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                PrintWriter out = response.getWriter();
                if (result.isSuccess()) {
                    out.print("{\"success\": true, \"message\": \"Role assigned successfully\"}");
                } else {
                    out.print("{\"success\": false, \"message\": \"" + result.getMessage() + "\"}");
                }
                out.flush();
            } else {
                // Regular redirect for non-AJAX requests
                if (result.isSuccess()) {
                    response.sendRedirect(request.getContextPath() + "/user/roles?id=" + userId + "&message="
                            + java.net.URLEncoder.encode("Role assigned successfully", "UTF-8"));
                } else {
                    response.sendRedirect(request.getContextPath() + "/user/roles?id=" + userId + "&error="
                            + java.net.URLEncoder.encode(result.getMessage(), "UTF-8"));
                }
            }
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid user ID or role ID");
        }
    }

    private void removeRole(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String userIdParam = request.getParameter("userId");
        String roleIdParam = request.getParameter("roleId");

        if (userIdParam == null || roleIdParam == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "User ID and Role ID are required");
            return;
        }

        try {
            int userId = Integer.parseInt(userIdParam);
            int roleId = Integer.parseInt(roleIdParam);

            Response<Boolean> result = accountRoleService.removeRoleFromAccount(userId, roleId);

            // Check if this is an AJAX request
            String ajaxHeader = request.getHeader("X-Requested-With");
            boolean isAjax = "XMLHttpRequest".equals(ajaxHeader) || 
                           request.getContentType() != null && request.getContentType().contains("application/x-www-form-urlencoded");
            
            if (isAjax) {
                // Return JSON response for AJAX
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                PrintWriter out = response.getWriter();
                if (result.isSuccess()) {
                    out.print("{\"success\": true, \"message\": \"Role removed successfully\"}");
                } else {
                    out.print("{\"success\": false, \"message\": \"" + result.getMessage() + "\"}");
                }
                out.flush();
            } else {
                // Regular redirect for non-AJAX requests
                if (result.isSuccess()) {
                    response.sendRedirect(request.getContextPath() + "/user/roles?id=" + userId + "&message="
                            + java.net.URLEncoder.encode("Role removed successfully", "UTF-8"));
                } else {
                    response.sendRedirect(request.getContextPath() + "/user/roles?id=" + userId + "&error="
                            + java.net.URLEncoder.encode(result.getMessage(), "UTF-8"));
                }
            }
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid user ID or role ID");
        }
    }
}
