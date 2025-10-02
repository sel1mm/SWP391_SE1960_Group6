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
}
