package service;

import constant.MessageConstant;
import dal.AccountDAO;
import dal.AccountRoleDAO;
import dto.RegisterRequest;
import dto.Response;
import dto.UserDTO;
import java.util.ArrayList;
import java.util.List;
import model.Account;
import utils.passwordHasher;

public class AccountService {

    AccountDAO accountDAO;
    AccountRoleDAO accountRoleDAO;

    public AccountService() {
        accountDAO = new AccountDAO();
        accountRoleDAO = new AccountRoleDAO();
    }

    public Response<Account> checkLogin(String username, String password) {
        Account account = accountDAO.getAccountByUserName(username);
        if (account != null && passwordHasher.checkPassword(password, account.getPasswordHash())) {
            return new Response<>(account, true, MessageConstant.LOGIN_SUCCESS);
        } else {
            return new Response<>(null, false, MessageConstant.LOGIN_FAILED);
        }
    }

    public boolean compareUsernameWithId(String username, int id) {
        Account account = accountDAO.getAccountByUserName(username);
        if (account != null && account.getAccountId() == id) {
            return true;
        }
        return false;
    }

    public Response<Boolean> register(RegisterRequest request) {
        if (accountDAO.checkExistUserName(request.getUsername())) {
            return new Response<>(false, false, "Tên đăng nhập đã tồn tại");
        }
        if (accountDAO.checkExistEmail(request.getEmail())) {
            return new Response<>(false, false, "Email đã được sử dụng");
        }
        if (accountDAO.checkExistPhone(request.getPhone())) {
            return new Response<>(false, false, "Số điện thoại đã tồn tại");
        }

        String hashedPassword = passwordHasher.hashPassword(request.getPassword());

        boolean account = accountDAO.register(
                request.getUsername(),
                hashedPassword,
                request.getEmail(),
                request.getPhone(),
                request.getFullName(),
                "Active"
        );

        if (account) {
            int roleId = 2;
            boolean roleAdded = accountRoleDAO.addAccountRole(request.getUsername(), roleId);

            if (roleAdded) {
                return new Response<>(true, true, "Đăng ký thành công! Quay lại trang đăng nhập để bắt đầu!");
            } else {
                return new Response<>(false, false, "Đăng ký thất bại! Vui lòng thử lại sau!");
            }
        }

        return new Response<>(false, false, "Đăng ký thất bại! Vui lòng thử lại sau!");
    }

     public Response<Boolean> checkRegisterValid(RegisterRequest req) {
        if (accountDAO.checkExistUserName(req.getUsername())) {
            return new Response<>(false, false, "Tên đăng nhập đã tồn tại");
        }
        if (accountDAO.checkExistEmail(req.getEmail())) {
            return new Response<>(false, false, "Email đã được sử dụng");
        }
        if (accountDAO.checkExistPhone(req.getPhone())) {
            return new Response<>(false, false, "Số điện thoại đã được sử dụng");
        }
        return new Response<>(true, true, "Thông tin hợp lệ");
    }

}
