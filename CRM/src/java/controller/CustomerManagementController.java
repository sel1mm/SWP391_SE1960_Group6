package controller;

import dal.AccountProfileDAO;
import dto.RegisterRequest;
import dto.Response;
import dto.UserDTO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.time.LocalDate;
import java.util.List;
import model.Account;
import model.AccountProfile;
import service.AccountService;
import utils.passwordHasher;

public class CustomerManagementController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        AccountService accountService = new AccountService();
        String action = request.getParameter("action");
        String keyword = request.getParameter("searchName");
        String status = request.getParameter("status");

        Response<List<Account>> res;

        try {
            if (("search".equalsIgnoreCase(action))
                    && ((keyword != null && !keyword.trim().isEmpty())
                    || (status != null && !status.trim().isEmpty()))) {

                res = accountService.searchCustomerAccounts(keyword != null ? keyword.trim() : "",
                        status != null ? status.trim() : "");
            } else {
                res = accountService.getAllCustomerAccounts();
            }

            if (res.isSuccess()) {
                request.setAttribute("userList", res.getData());
            } else {
                request.setAttribute("message", res.getMessage());
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("message", "Lỗi khi xử lý dữ liệu: " + e.getMessage());
        }

        request.setAttribute("currentPage", "users");
        request.getRequestDispatcher("customerManagement.jsp").forward(request, response);

    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        AccountService accountService = new AccountService();

        try {
            switch (action) {
                case "delete":
                    int deleteId = Integer.parseInt(request.getParameter("id"));
                    accountService.deleteAccount(deleteId);
                    break;

                case "add":
    try {
                    String newUsername = request.getParameter("username");
                    String newEmail = request.getParameter("email");
                    String newPassword = request.getParameter("password");
                    String newPhone = request.getParameter("phone");
                    String newFullName = request.getParameter("fullName");

                    String address = request.getParameter("address");
                    String dateOfBirthStr = request.getParameter("dateOfBirth");
                    String avatarUrl = request.getParameter("avatarUrl");
                    String nationalId = request.getParameter("nationalId");
                    String verifiedStr = request.getParameter("verified");
                    String extraData = request.getParameter("extraData");

                    if (newUsername != null && newPassword != null && newEmail != null && newPhone != null) {

                        RegisterRequest registerRequest = new RegisterRequest();
                        registerRequest.setUsername(newUsername);
                        registerRequest.setPassword(newPassword);
                        registerRequest.setEmail(newEmail);
                        registerRequest.setPhone(newPhone);
                        registerRequest.setFullName(newFullName);

                        Response<Boolean> result = accountService.register(registerRequest);

                        if (result.isSuccess()) {
                            Response<Account> createdAccountRes = accountService.getAccountByUsername(newUsername);
                            if (createdAccountRes.isSuccess() && createdAccountRes.getData() != null) {
                                int newAccountId = createdAccountRes.getData().getAccountId();

                                LocalDate dateOfBirth = null;
                                if (dateOfBirthStr != null && !dateOfBirthStr.trim().isEmpty()) {
                                    dateOfBirth = LocalDate.parse(dateOfBirthStr);
                                }
                                boolean verified = "true".equalsIgnoreCase(verifiedStr) || "1".equals(verifiedStr) || "on".equalsIgnoreCase(verifiedStr);

                                AccountProfile profile = new AccountProfile();
                                profile.setAccountId(newAccountId);
                                profile.setAddress(address);
                                profile.setDateOfBirth(dateOfBirth);
                                profile.setAvatarUrl(avatarUrl);
                                profile.setNationalId(nationalId);
                                profile.setVerified(verified);
                                profile.setExtraData(extraData);

                                AccountProfileDAO profileDAO = new AccountProfileDAO();
                                boolean inserted = profileDAO.insertProfile(profile);

                                if (inserted) {
                                    request.getSession().setAttribute("message", "Thêm người dùng thành công!");
                                } else {
                                    request.getSession().setAttribute("message", "Thêm tài khoản thành công nhưng không thể lưu hồ sơ!");
                                }

                            } else {
                                request.getSession().setAttribute("message", "Không thể lấy thông tin tài khoản vừa tạo!");
                            }

                        } else {
                            request.getSession().setAttribute("message", result.getMessage());
                        }

                    } else {
                        request.getSession().setAttribute("message", "Vui lòng nhập đủ thông tin bắt buộc!");
                    }

                } catch (Exception e) {
                    e.printStackTrace();
                    request.getSession().setAttribute("message", "Lỗi hệ thống khi thêm người dùng: " + e.getMessage());
                }

                break;

                case "edit":
    try {
                    int editId = Integer.parseInt(request.getParameter("id"));
                    String username = request.getParameter("username");
                    String fullName = request.getParameter("fullName");
                    String email = request.getParameter("email");
                    String phone = request.getParameter("phone");
                    String status = request.getParameter("status");
                    String password = request.getParameter("password");

                    String address = request.getParameter("address");
                    String dateOfBirthStr = request.getParameter("dateOfBirth");
                    String avatarUrl = request.getParameter("avatarUrl");
                    String nationalId = request.getParameter("nationalId");
                    String verifiedStr = request.getParameter("verified");
                    String extraData = request.getParameter("extraData");

                    boolean verified = "true".equalsIgnoreCase(verifiedStr) || "on".equalsIgnoreCase(verifiedStr);
                    LocalDate dateOfBirth = null;
                    if (dateOfBirthStr != null && !dateOfBirthStr.isEmpty()) {
                        dateOfBirth = LocalDate.parse(dateOfBirthStr);
                    }

                    String hashedPassword = null;
                    if (password != null && !password.trim().isEmpty()) {
                        hashedPassword = passwordHasher.hashPassword(password.trim());
                    }

                    Account account = new Account();
                    account.setAccountId(editId);
                    account.setUsername(username);
                    account.setFullName(fullName);
                    account.setEmail(email);
                    account.setPhone(phone);
                    account.setStatus(status);
                    account.setPasswordHash(hashedPassword);

                    AccountProfile profile = new AccountProfile();
                    profile.setAccountId(editId);
                    profile.setAddress(address);
                    profile.setDateOfBirth(dateOfBirth);
                    profile.setAvatarUrl(avatarUrl);
                    profile.setNationalId(nationalId);
                    profile.setVerified(verified);
                    profile.setExtraData(extraData);
                    Response<Account> updateRes = accountService.updateCustomerAccount(account, profile);

                    if (updateRes.isSuccess()) {
                        request.setAttribute("message", "Cập nhật người dùng thành công!");
                    } else {
                        request.setAttribute("error", updateRes.getMessage());
                    }

                } catch (Exception e) {
                    e.printStackTrace();
                    request.setAttribute("error", "Lỗi hệ thống khi cập nhật người dùng: " + e.getMessage());
                }
                break;

                default:
                    System.out.println("Không xác định được action: " + action);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("message", "Có lỗi xảy ra: " + e.getMessage());
        }

        response.sendRedirect("customerManagement");
    }
}
