package service;

import dal.AccountRoleDAO;
import dto.Response;
import model.AccountRole;
import java.util.List;

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
    
    public Response<List<AccountRole>> getRolesByAccountId(int accountId) {
        return accountRoleDAO.getRolesByAccountId(accountId);
    }
    
    public Response<AccountRole> assignRoleToAccount(int accountId, int roleId) {
        return accountRoleDAO.assignRoleToAccount(accountId, roleId);
    }
    
    public Response<Boolean> removeRoleFromAccount(int accountId, int roleId) {
        return accountRoleDAO.removeRoleFromAccount(accountId, roleId);
    }
    
    public Response<Boolean> hasRole(int accountId, int roleId) {
        return accountRoleDAO.hasRole(accountId, roleId);
    }
    
    public Response<Boolean> removeAllRolesFromAccount(int accountId) {
        return accountRoleDAO.removeAllRolesFromAccount(accountId);
    }
}
