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

    public Response<List<Account>> getAllAccounts() {
        return accountDAO.getAllAccounts();
    }

    public Response<Account> getAccountById(int accountId) {
        return accountDAO.getAccountById(accountId);
    }

    public Response<Account> createAccount(Account account) {
        // Validate required fields
        if (account.getUsername() == null || account.getUsername().trim().isEmpty()) {
            return new Response<>(null, false, "Username is required");
        }
        if (account.getPasswordHash() == null || account.getPasswordHash().trim().isEmpty()) {
            return new Response<>(null, false, "Password is required");
        }
        if (account.getEmail() == null || account.getEmail().trim().isEmpty()) {
            return new Response<>(null, false, "Email is required");
        }

        // Check if username already exists
        Response<Boolean> usernameExists = accountDAO.isUsernameExists(account.getUsername().trim());
        if (usernameExists.isSuccess() && usernameExists.getData()) {
            return new Response<>(null, false, "Username already exists");
        }

        // Check if email already exists
        Response<Boolean> emailExists = accountDAO.isEmailExists(account.getEmail().trim());
        if (emailExists.isSuccess() && emailExists.getData()) {
            return new Response<>(null, false, "Email already exists");
        }

        // Check if phone already exists (if provided)
        if (account.getPhone() != null && !account.getPhone().trim().isEmpty()) {
            Response<Boolean> phoneExists = accountDAO.isPhoneExists(account.getPhone().trim());
            if (phoneExists.isSuccess() && phoneExists.getData()) {
                return new Response<>(null, false, "Phone number already exists");
            }
        }

        // Set default values
        account.setUsername(account.getUsername().trim());
        account.setEmail(account.getEmail().trim());
        if (account.getPhone() != null) {
            account.setPhone(account.getPhone().trim());
        }
        if (account.getFullName() != null) {
            account.setFullName(account.getFullName().trim());
        }
        if (account.getStatus() == null || account.getStatus().trim().isEmpty()) {
            account.setStatus("Active");
        }

        return accountDAO.createAccount(account);
    }

    public Response<Account> updateAccount(Account account) {
        // Validate required fields
        if (account.getUsername() == null || account.getUsername().trim().isEmpty()) {
            return new Response<>(null, false, "Username is required");
        }
        if (account.getEmail() == null || account.getEmail().trim().isEmpty()) {
            return new Response<>(null, false, "Email is required");
        }

        // Check if account exists
        Response<Account> existingAccount = accountDAO.getAccountById(account.getAccountId());
        if (!existingAccount.isSuccess() || existingAccount.getData() == null) {
            return new Response<>(null, false, "Account not found");
        }

        // Check if new username already exists (excluding current account)
        Response<Boolean> usernameExists = accountDAO.isUsernameExists(account.getUsername().trim());
        if (usernameExists.isSuccess() && usernameExists.getData()) {
            // Check if it's the same account
            if (!compareUsernameWithId(account.getUsername().trim(), account.getAccountId())) {
                return new Response<>(null, false, "Username already exists");
            }
        }

        // Check if new email already exists (excluding current account)
        Response<Boolean> emailExists = accountDAO.isEmailExists(account.getEmail().trim());
        if (emailExists.isSuccess() && emailExists.getData()) {
            // Check if it's the same account
            Account existing = existingAccount.getData();
            if (!account.getEmail().trim().equals(existing.getEmail())) {
                return new Response<>(null, false, "Email already exists");
            }
        }

        // Check if new phone already exists (if provided and different from current)
        if (account.getPhone() != null && !account.getPhone().trim().isEmpty()) {
            Response<Boolean> phoneExists = accountDAO.isPhoneExists(account.getPhone().trim());
            if (phoneExists.isSuccess() && phoneExists.getData()) {
                Account existing = existingAccount.getData();
                if (!account.getPhone().trim().equals(existing.getPhone())) {
                    return new Response<>(null, false, "Phone number already exists");
                }
            }
        }

        // Clean up data
        account.setUsername(account.getUsername().trim());
        account.setEmail(account.getEmail().trim());
        if (account.getPhone() != null) {
            account.setPhone(account.getPhone().trim());
        }
        if (account.getFullName() != null) {
            account.setFullName(account.getFullName().trim());
        }

        return accountDAO.updateAccount(account);
    }
    
     public Response<Account> banAccountService(Account account) {
        // Validate required fields
        if (account.getUsername() == null || account.getUsername().trim().isEmpty()) {
            return new Response<>(null, false, "Username is required");
        }
        if (account.getEmail() == null || account.getEmail().trim().isEmpty()) {
            return new Response<>(null, false, "Email is required");
        }

        // Check if account exists
        Response<Account> existingAccount = accountDAO.getAccountById(account.getAccountId());
        if (!existingAccount.isSuccess() || existingAccount.getData() == null) {
            return new Response<>(null, false, "Account not found");
        }

        // Check if new username already exists (excluding current account)
        Response<Boolean> usernameExists = accountDAO.isUsernameExists(account.getUsername().trim());
        if (usernameExists.isSuccess() && usernameExists.getData()) {
            // Check if it's the same account
            if (!compareUsernameWithId(account.getUsername().trim(), account.getAccountId())) {
                return new Response<>(null, false, "Username already exists");
            }
        }

        // Check if new email already exists (excluding current account)
        Response<Boolean> emailExists = accountDAO.isEmailExists(account.getEmail().trim());
        if (emailExists.isSuccess() && emailExists.getData()) {
            // Check if it's the same account
            Account existing = existingAccount.getData();
            if (!account.getEmail().trim().equals(existing.getEmail())) {
                return new Response<>(null, false, "Email already exists");
            }
        }

        // Check if new phone already exists (if provided and different from current)
        if (account.getPhone() != null && !account.getPhone().trim().isEmpty()) {
            Response<Boolean> phoneExists = accountDAO.isPhoneExists(account.getPhone().trim());
            if (phoneExists.isSuccess() && phoneExists.getData()) {
                Account existing = existingAccount.getData();
                if (!account.getPhone().trim().equals(existing.getPhone())) {
                    return new Response<>(null, false, "Phone number already exists");
                }
            }
        }

        // Clean up data
        account.setUsername(account.getUsername().trim());
        account.setEmail(account.getEmail().trim());
        if (account.getPhone() != null) {
            account.setPhone(account.getPhone().trim());
        }
        if (account.getFullName() != null) {
            account.setFullName(account.getFullName().trim());
        }

        return accountDAO.updateAccount(account);
    }

    public Response<Account> updatePassword(int accountId, String newPassword) {
        if (newPassword == null || newPassword.trim().isEmpty()) {
            return new Response<>(null, false, "Password is required");
        }

        String hashedPassword = passwordHasher.hashPassword(newPassword);
        return accountDAO.updatePassword(accountId, hashedPassword);
    }

    public Response<Boolean> deleteAccount(int accountId) {
        // Check if account exists
        Response<Account> existingAccount = accountDAO.getAccountById(accountId);
        if (!existingAccount.isSuccess() || existingAccount.getData() == null) {
            return new Response<>(false, false, "Account not found");
        }

        // Remove all roles first
       // accountRoleDAO.removeAllRolesFromAccount(accountId);

        return accountDAO.deleteAccount(accountId);
    }

    public Response<Boolean> isUsernameExists(String username) {
        return accountDAO.isUsernameExists(username);
    }

    public Response<Boolean> isEmailExists(String email) {
        return accountDAO.isEmailExists(email);
    }

    public Response<Boolean> isPhoneExists(String phone) {
        return accountDAO.isPhoneExists(phone);
    }
}
