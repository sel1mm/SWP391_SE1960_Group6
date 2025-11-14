package controller;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonPrimitive;
import com.google.gson.JsonSerializer;
import dal.AccountProfileDAO;
import dal.ContractDAO;
import dto.RegisterRequest;
import dto.Response;
import dto.UserDTO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.PrintWriter;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import model.Account;
import model.AccountProfile;
import model.Contract;
import model.Equipment;
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

        String action = request.getParameter("action");

        // ✅ QUAN TRỌNG: Kiểm tra API actions TRƯỚC, return NGAY
        if ("getCustomerContracts".equals(action)) {
            handleGetCustomerContracts(request, response);
            return; // ⭐ DỪNG NGAY, KHÔNG forward JSP
        }

        if ("getContractEquipment".equals(action)) {
            handleGetContractEquipment(request, response);
            return; // ⭐ DỪNG NGAY, KHÔNG forward JSP
        }

        if ("getById".equals(action)) {
            handleGetById(request, response);
            return; // ⭐ DỪNG NGAY, KHÔNG forward JSP
        }

        // ========== PHẦN NÀY CHỈ CHẠY KHI KHÔNG PHẢI API ==========
        AccountService accountService = new AccountService();

        String searchSerial = request.getParameter("searchSerial");
        if (searchSerial == null) {
            searchSerial = "";
        }

        String keyword = request.getParameter("searchName");
        String status = request.getParameter("status");

        int page = 1;
        int recordsPerPage = 10;

        try {
            if (request.getParameter("page") != null) {
                try {
                    page = Integer.parseInt(request.getParameter("page").trim());
                    if (page < 1) {
                        page = 1;
                    }
                } catch (NumberFormatException e) {
                    page = 1;
                }
            }

            action = (action != null) ? action.trim() : "";
            keyword = (keyword != null) ? keyword.trim() : "";
            status = (status != null) ? status.trim() : "";

            Response<List<Account>> res;
            int totalRecords = 0;

            if (!searchSerial.isEmpty()) {
                res = accountService.searchCustomerByEquipmentSerial(
                        searchSerial,
                        (page - 1) * recordsPerPage,
                        recordsPerPage
                );
                totalRecords = accountService.countCustomersByEquipmentSerial(searchSerial);
            } else if ((!keyword.isEmpty()) || (!status.isEmpty())) {
                res = accountService.searchCustomerAccountsPaged(
                        keyword,
                        status,
                        (page - 1) * recordsPerPage,
                        recordsPerPage
                );
                totalRecords = accountService.countSearchCustomerAccounts(keyword, status);
            } else {
                res = accountService.getCustomerAccountsPaged(
                        (page - 1) * recordsPerPage,
                        recordsPerPage
                );
                totalRecords = accountService.countAllCustomerAccounts();
            }

            int totalPages = (int) Math.ceil((double) totalRecords / recordsPerPage);
            if (totalPages == 0) {
                totalPages = 1;
            }

            if (res.isSuccess()) {
                request.setAttribute("userList", res.getData());
            } else {
                request.setAttribute("message", res.getMessage());
            }

            request.setAttribute("currentPageNumber", page);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("searchName", keyword);
            request.setAttribute("searchSerial", searchSerial);
            request.setAttribute("status", status);
            request.setAttribute("currentPageSection", "users");

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("message", "Lỗi khi xử lý dữ liệu: " + e.getMessage());
        }

        request.getRequestDispatcher("customerManagement.jsp").forward(request, response);
    }

    private void handleGetById(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        String idParam = request.getParameter("userId");
        String emailParam = request.getParameter("email");

        AccountService accountService = new AccountService();

        try {
            Account account = null;
            AccountProfile profile = null;

            if (idParam != null && idParam.matches("\\d+")) {
                int userId = Integer.parseInt(idParam);
                Response<Account> res = accountService.getAccountById(userId);
                if (res.isSuccess() && res.getData() != null) {
                    account = res.getData();
                    profile = accountService.getProfileById(userId);
                }
            } else if (emailParam != null && !emailParam.trim().isEmpty()) {
                Response<Account> res = accountService.getAccountByEmailResponse(emailParam.trim());
                if (res.isSuccess() && res.getData() != null) {
                    account = res.getData();
                    profile = accountService.getProfileById(account.getAccountId());
                }
            }

            Gson gson = new GsonBuilder()
                    .registerTypeAdapter(LocalDate.class,
                            (JsonSerializer<LocalDate>) (src, typeOfSrc, context)
                            -> src == null ? null : new JsonPrimitive(src.toString()))
                    .registerTypeAdapter(LocalDateTime.class,
                            (JsonSerializer<LocalDateTime>) (src, typeOfSrc, context)
                            -> src == null ? null : new JsonPrimitive(src.toString()))
                    .serializeNulls()
                    .setPrettyPrinting()
                    .create();

            PrintWriter out = response.getWriter();

            if (account != null) {
                Map<String, Object> result = new HashMap<>();
                result.put("success", true);
                result.put("account", account);
                result.put("profile", profile);
                out.print(gson.toJson(result));
            } else {
                out.print("{\"success\":false,\"message\":\"Không tìm thấy tài khoản\"}");
            }

        } catch (Exception e) {
            e.printStackTrace();
            String safeMsg = e.getMessage() != null
                    ? e.getMessage().replace("\"", "\\\"")
                    : "Không xác định";
            response.getWriter().print("{\"success\":false,\"message\":\"Lỗi hệ thống: " + safeMsg + "\"}");
        }
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

                        Response<Boolean> result = accountService.registerByCSS(registerRequest);

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

                    if (password != null) {
                        password = password.trim(); // loại bỏ khoảng trắng đầu/cuối
                        if (password.isEmpty()) {
                            password = null; // nếu sau khi trim mà trống thì coi như không nhập
                        }
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
                    account.setPasswordHash(password);

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

    // Handler lấy equipment của contract
    private void handleGetContractEquipment(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.setContentType("application/json;charset=UTF-8");

        try {
            String contractIdStr = request.getParameter("contractId");

            if (contractIdStr == null || contractIdStr.trim().isEmpty()) {
                response.getWriter().write("{\"success\":false,\"message\":\"Contract ID không hợp lệ\"}");
                return;
            }

            int contractId = Integer.parseInt(contractIdStr);

            ContractDAO contractDAO = new ContractDAO();
            // ✅ THAY ĐỔI: Sử dụng List<Map<String, Object>> thay vì List<Equipment>
            List<Map<String, Object>> equipment = contractDAO.getEquipmentByContractId(contractId);

            Gson gson = new GsonBuilder()
                    .registerTypeAdapter(LocalDate.class,
                            (JsonSerializer<LocalDate>) (src, typeOfSrc, context)
                            -> src == null ? null : new JsonPrimitive(src.toString()))
                    .registerTypeAdapter(LocalDateTime.class,
                            (JsonSerializer<LocalDateTime>) (src, typeOfSrc, context)
                            -> src == null ? null : new JsonPrimitive(src.toString()))
                    .serializeNulls()
                    .setPrettyPrinting()
                    .create();

            Map<String, Object> result = new HashMap<>();
            result.put("success", true);
            result.put("equipment", equipment);

            response.getWriter().write(gson.toJson(result));

        } catch (Exception e) {
            e.printStackTrace();
            String safeMsg = e.getMessage() != null ? e.getMessage().replace("\"", "\\\"") : "Không xác định";
            response.getWriter().write("{\"success\":false,\"message\":\"Lỗi: " + safeMsg + "\"}");
        }
    }

    private void handleGetCustomerContracts(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.setContentType("application/json;charset=UTF-8");

        System.out.println("=== handleGetCustomerContracts CALLED ==="); // ⭐ DEBUG

        try {
            String customerIdStr = request.getParameter("customerId");

            System.out.println("customerId parameter: " + customerIdStr); // ⭐ DEBUG

            if (customerIdStr == null || customerIdStr.trim().isEmpty()) {
                System.out.println("❌ Customer ID is null or empty");
                response.getWriter().write("{\"success\":false,\"message\":\"Customer ID không hợp lệ\"}");
                return;
            }

            int customerId = Integer.parseInt(customerIdStr);
            System.out.println("✅ Parsed customerId: " + customerId); // ⭐ DEBUG

            ContractDAO contractDAO = new ContractDAO();
            List<Contract> contracts = contractDAO.getContractsByCustomerId(customerId);

            System.out.println("✅ Found " + contracts.size() + " contracts"); // ⭐ DEBUG

            Gson gson = new GsonBuilder()
                    .registerTypeAdapter(LocalDate.class,
                            (JsonSerializer<LocalDate>) (src, typeOfSrc, context)
                            -> src == null ? null : new JsonPrimitive(src.toString()))
                    .registerTypeAdapter(LocalDateTime.class,
                            (JsonSerializer<LocalDateTime>) (src, typeOfSrc, context)
                            -> src == null ? null : new JsonPrimitive(src.toString()))
                    .serializeNulls()
                    .setPrettyPrinting()
                    .create();

            Map<String, Object> result = new HashMap<>();
            result.put("success", true);
            result.put("contracts", contracts);

            String jsonResult = gson.toJson(result);
            System.out.println("JSON Response: " + jsonResult); // ⭐ DEBUG

            response.getWriter().write(jsonResult);

        } catch (Exception e) {
            System.err.println("❌ Exception in handleGetCustomerContracts:");
            e.printStackTrace();
            response.getWriter().write("{\"success\":false,\"message\":\"Lỗi: " + e.getMessage() + "\"}");
        }
    }
}
