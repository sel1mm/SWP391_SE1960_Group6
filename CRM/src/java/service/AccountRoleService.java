package service;

import dal.AccountRoleDAO;
import dto.Response;
import model.AccountRole;

public class AccountRoleService {
    private final AccountRoleDAO accountRoleDAO;
    
    public AccountRoleService() {
        accountRoleDAO = new AccountRoleDAO();
    }
    
    public boolean isAdmin(int accountId) {
        Response<AccountRole> accountRole = accountRoleDAO.checkAccountRole(accountId);
        return accountRole.isSuccess() 
                && accountRole.getData() != null 
                && accountRole.getData().getRoleId() == 1;
    }
   
    public boolean isCustomer(int accountId) {
        Response<AccountRole> accountRole = accountRoleDAO.checkAccountRole(accountId);
        return accountRole.isSuccess() 
                && accountRole.getData() != null 
                && accountRole.getData().getRoleId() == 2;
    }
}
