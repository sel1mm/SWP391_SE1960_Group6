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
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.Date;
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
        Response<List<Account>> result = accountService.getAllAccounts();
        
        

        if (result.isSuccess()) {
            request.setAttribute("users", result.getData());
            request.setAttribute("message", result.getMessage());
        } else {
            request.setAttribute("error", result.getMessage());
        }
        
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
        account.setPasswordHash(passwordHasher.hashPassword(password));
        account.setFullName(fullName);
        account.setEmail(email);
        account.setPhone(phone);
        account.setStatus(status != null ? status : "Active");

        Response<Account> result = accountService.createAccount(account);
        
        if (result.isSuccess() && result.getData() != null) {
            // Assign roles if provided
            if (roleIds != null && roleIds.length > 0) {
                for (String roleIdStr : roleIds) {
                    try {
                        int roleId = Integer.parseInt(roleIdStr);
                        accountRoleService.assignRoleToAccount(result.getData().getAccountId(), roleId);
                    } catch (NumberFormatException e) {
                        // Skip invalid role ID
                    }
                }
            }
            
            response.sendRedirect(request.getContextPath() + "/user/list?message=" + 
                java.net.URLEncoder.encode("User created successfully", "UTF-8"));
        } else {
            request.setAttribute("error", result.getMessage());
            request.setAttribute("user", account);
            
            // Get roles for form
            Response<List<model.Role>> rolesResult = roleService.getAllRoles();
            if (rolesResult.isSuccess()) {
                request.setAttribute("roles", rolesResult.getData());
            }
            
            request.getRequestDispatcher("/WEB-INF/views/user/create.jsp").forward(request, response);
        }
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

            Response<Account> result = accountService.updateAccount(account);
            
            if (result.isSuccess()) {
                response.sendRedirect(request.getContextPath() + "/user/list?message=" + 
                    java.net.URLEncoder.encode("User updated successfully", "UTF-8"));
            } else {
                request.setAttribute("error", result.getMessage());
                request.setAttribute("user", account);
                
                // Get roles for form
                Response<List<model.Role>> rolesResult = roleService.getAllRoles();
                if (rolesResult.isSuccess()) {
                    request.setAttribute("roles", rolesResult.getData());
                }
                
                request.getRequestDispatcher("/WEB-INF/views/user/edit.jsp").forward(request, response);
            }
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid user ID");
        }
    }
    
     private void bannedUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "User ID is required");
            return;
        }

        try {
            int userId = Integer.parseInt(idParam);
       
            String status = request.getParameter("InActive");

            Account account = new Account();
            account.setAccountId(userId);
            account.setStatus(status);

            Response<Account> result = accountService.updateAccount(account);
            
            if (result.isSuccess()) {
                response.sendRedirect(request.getContextPath() + "/user/list?message=" + 
                    java.net.URLEncoder.encode("User updated successfully", "UTF-8"));
            } else {
                request.setAttribute("error", result.getMessage());
                request.setAttribute("user", account);
                
                // Get roles for form
                Response<List<model.Role>> rolesResult = roleService.getAllRoles();
                if (rolesResult.isSuccess()) {
                    request.setAttribute("roles", rolesResult.getData());
                }
                
                request.getRequestDispatcher("/WEB-INF/views/user/edit.jsp").forward(request, response);
            }
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid user ID");
        }
    }

    private void updatePassword(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idParam = request.getParameter("id");
        String newPassword = request.getParameter("newPassword");
        
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "User ID is required");
            return;
        }

        try {
            int userId = Integer.parseInt(idParam);
            Response<Account> result = accountService.updatePassword(userId, newPassword);
            
            if (result.isSuccess()) {
                response.sendRedirect(request.getContextPath() + "/user/edit?id=" + userId + "&message=" + 
                    java.net.URLEncoder.encode("Password updated successfully", "UTF-8"));
            } else {
                response.sendRedirect(request.getContextPath() + "/user/edit?id=" + userId + "&error=" + 
                    java.net.URLEncoder.encode(result.getMessage(), "UTF-8"));
            }
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid user ID");
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
            Response<Boolean> result = accountService.deleteAccount(userId);
            
            if (result.isSuccess()) {
                response.sendRedirect(request.getContextPath() + "/user/list?message=" + 
                    java.net.URLEncoder.encode("User deleted successfully", "UTF-8"));
            } else {
                response.sendRedirect(request.getContextPath() + "/user/list?error=" + 
                    java.net.URLEncoder.encode(result.getMessage(), "UTF-8"));
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
            
            if (result.isSuccess()) {
                response.sendRedirect(request.getContextPath() + "/user/roles?id=" + userId + "&message=" + 
                    java.net.URLEncoder.encode("Role assigned successfully", "UTF-8"));
            } else {
                response.sendRedirect(request.getContextPath() + "/user/roles?id=" + userId + "&error=" + 
                    java.net.URLEncoder.encode(result.getMessage(), "UTF-8"));
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
            
            if (result.isSuccess()) {
                response.sendRedirect(request.getContextPath() + "/user/roles?id=" + userId + "&message=" + 
                    java.net.URLEncoder.encode("Role removed successfully", "UTF-8"));
            } else {
                response.sendRedirect(request.getContextPath() + "/user/roles?id=" + userId + "&error=" + 
                    java.net.URLEncoder.encode(result.getMessage(), "UTF-8"));
            }
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid user ID or role ID");
        }
    }
}
