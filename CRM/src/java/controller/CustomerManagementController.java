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

    // Regex constants
    private static final String USERNAME_REGEX = "^[A-Za-z0-9]+$";
    private static final String FULLNAME_REGEX = "^[A-Za-zÀ-ỹ\\s]{2,50}$";
    private static final String EMAIL_REGEX = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$";
    private static final String PHONE_REGEX = "^(03|05|07|08|09)[0-9]{8}$";
    private static final String PASSWORD_REGEX = "^(?=.*[A-Za-z0-9])[A-Za-z0-9!@#$%^&*()_+=-]{6,30}$";
    private static final String URL_REGEX = "^(https?://.*\\.(?:png|jpg|jpeg|gif|webp|svg))$";
    private static final String NATIONALID_REGEX = "^[0-9]{9,12}$";

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

                    if (newUsername == null || !newUsername.matches(USERNAME_REGEX)
                            || newFullName == null || !newFullName.matches(FULLNAME_REGEX)
                            || newEmail == null || !newEmail.matches(EMAIL_REGEX)
                            || newPhone == null || !newPhone.matches(PHONE_REGEX)
                            || newPassword == null || !newPassword.matches(PASSWORD_REGEX)) {

                        request.getSession().setAttribute("message", "Dữ liệu không hợp lệ. Vui lòng kiểm tra lại các trường bắt buộc!");
                        response.sendRedirect("customerManagement");
                        return;
                    }

                    String address = request.getParameter("address");
                    String dateOfBirthStr = request.getParameter("dateOfBirth");
                    String avatarUrl = request.getParameter("avatarUrl");
                    String nationalId = request.getParameter("nationalId");
                    String verifiedStr = request.getParameter("verified");
                    String extraData = request.getParameter("extraData");

                    LocalDate dateOfBirth = null;
                    if (dateOfBirthStr != null && !dateOfBirthStr.trim().isEmpty()) {
                        try {
                            dateOfBirth = LocalDate.parse(dateOfBirthStr);
                            if (dateOfBirth.isAfter(LocalDate.now())) {
                                request.getSession().setAttribute("message", "Ngày sinh không được ở tương lai!");
                                response.sendRedirect("customerManagement");
                                return;
                            }
                            if (LocalDate.now().getYear() - dateOfBirth.getYear() < 10) {
                                request.getSession().setAttribute("message", "Tuổi phải từ 10 trở lên!");
                                response.sendRedirect("customerManagement");
                                return;
                            }
                        } catch (Exception e) {
                            request.getSession().setAttribute("message", "Ngày sinh không hợp lệ!");
                            response.sendRedirect("customerManagement");
                            return;
                        }
                    }

                    if (avatarUrl != null && !avatarUrl.trim().isEmpty() && !avatarUrl.matches(URL_REGEX)) {
                        request.getSession().setAttribute("message", "URL ảnh đại diện không hợp lệ!");
                        response.sendRedirect("customerManagement");
                        return;
                    }

                    if (nationalId != null && !nationalId.trim().isEmpty() && !nationalId.matches(NATIONALID_REGEX)) {
                        request.getSession().setAttribute("message", "CCCD/CMND không hợp lệ!");
                        response.sendRedirect("customerManagement");
                        return;
                    }

                    if (verifiedStr == null || (!verifiedStr.equals("0") && !verifiedStr.equals("1"))) {
                        request.getSession().setAttribute("message", "Trạng thái xác thực không hợp lệ!");
                        response.sendRedirect("customerManagement");
                        return;
                    }

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

                                // Kiểm tra xem có thông tin profile nào được nhập không
                                boolean hasProfileData
                                        = (address != null && !address.trim().isEmpty())
                                        || (dateOfBirth != null)
                                        || (avatarUrl != null && !avatarUrl.trim().isEmpty())
                                        || (nationalId != null && !nationalId.trim().isEmpty())
                                        || (extraData != null && !extraData.trim().isEmpty());

                                if (hasProfileData) {
                                    AccountProfileDAO profileDAO = new AccountProfileDAO();
                                    boolean inserted = profileDAO.insertProfile(profile);
                                    if (!inserted) {
                                        System.err.println("⚠️ Không thể lưu hồ sơ người dùng (AccountProfile), nhưng tài khoản vẫn được thêm.");
                                    }
                                }

                                request.getSession().setAttribute("message", "Thêm người dùng thành công!");

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

                    // Validate định dạng cơ bản
                    if (fullName == null || !fullName.matches(FULLNAME_REGEX)
                            || email == null || !email.matches(EMAIL_REGEX)
                            || phone == null || !phone.matches(PHONE_REGEX)
                            || (password != null && !password.trim().isEmpty() && !password.matches(PASSWORD_REGEX))) {

                        request.getSession().setAttribute("message", "Dữ liệu không hợp lệ. Vui lòng kiểm tra lại các trường bắt buộc!");
                        response.sendRedirect("customerManagement");
                        return;
                    }

                    // Validate ngày sinh
                    LocalDate dateOfBirth = null;
                    if (dateOfBirthStr != null && !dateOfBirthStr.trim().isEmpty()) {
                        try {
                            dateOfBirth = LocalDate.parse(dateOfBirthStr);
                            if (dateOfBirth.isAfter(LocalDate.now())) {
                                request.getSession().setAttribute("message", "Ngày sinh không được ở tương lai!");
                                response.sendRedirect("customerManagement");
                                return;
                            }
                            if (LocalDate.now().getYear() - dateOfBirth.getYear() < 10) {
                                request.getSession().setAttribute("message", "Tuổi phải từ 10 trở lên!");
                                response.sendRedirect("customerManagement");
                                return;
                            }
                        } catch (Exception e) {
                            request.getSession().setAttribute("message", "Ngày sinh không hợp lệ!");
                            response.sendRedirect("customerManagement");
                            return;
                        }
                    }

                    // Validate URL ảnh đại diện
                    if (avatarUrl != null && !avatarUrl.trim().isEmpty() && !avatarUrl.matches(URL_REGEX)) {
                        request.getSession().setAttribute("message", "URL ảnh đại diện không hợp lệ!");
                        response.sendRedirect("customerManagement");
                        return;
                    }

                    // Validate CCCD/CMND
                    if (nationalId != null && !nationalId.trim().isEmpty() && !nationalId.matches(NATIONALID_REGEX)) {
                        request.getSession().setAttribute("message", "CCCD/CMND không hợp lệ!");
                        response.sendRedirect("customerManagement");
                        return;
                    }

                    // Validate trạng thái xác thực
                    if (verifiedStr == null || (!verifiedStr.equals("0") && !verifiedStr.equals("1"))) {
                        request.getSession().setAttribute("message", "Trạng thái xác thực không hợp lệ!");
                        response.sendRedirect("customerManagement");
                        return;
                    }

                    // Validate trạng thái tài khoản
                    if (status == null || (!status.equals("Active") && !status.equals("Inactive"))) {
                        request.getSession().setAttribute("message", "Trạng thái tài khoản không hợp lệ!");
                        response.sendRedirect("customerManagement");
                        return;
                    }

                    // Xử lý password (chỉ hash nếu nhập mới)
                    String hashedPassword = null;
                    if (password != null && !password.trim().isEmpty()) {
                        hashedPassword = passwordHasher.hashPassword(password.trim());
                    }

                    // Chuyển đổi verified
                    boolean verified = "true".equalsIgnoreCase(verifiedStr)
                            || "1".equals(verifiedStr)
                            || "on".equalsIgnoreCase(verifiedStr);

                    // Tạo đối tượng Account & Profile
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

                    // Cập nhật vào DB
                    Response<Account> updateRes = accountService.updateCustomerAccount(account, profile);

                    if (updateRes.isSuccess()) {
                        request.getSession().setAttribute("message", "Cập nhật người dùng thành công!");
                    } else {
                        request.getSession().setAttribute("message", updateRes.getMessage());
                    }

                } catch (Exception e) {
                    e.printStackTrace();
                    request.getSession().setAttribute("message", "Lỗi hệ thống khi cập nhật người dùng: " + e.getMessage());
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
