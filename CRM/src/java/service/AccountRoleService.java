package service;

import dal.AccountRoleDAO;
import dto.Response;
import java.util.List;
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

    public boolean isTechnicalManager(int accountId) {
        Response<AccountRole> accountRole = accountRoleDAO.checkAccountRole(accountId);
        return accountRole.isSuccess()
                && accountRole.getData() != null
                && accountRole.getData().getRoleId() == 4;
    }
    
    public boolean isCustomerSupportStaff(int accountId) {
        Response<AccountRole> accountRole = accountRoleDAO.checkAccountRole(accountId);
        return accountRole.isSuccess()
                && accountRole.getData() != null
                && accountRole.getData().getRoleId() == 3;
    }
      public boolean isStorekeeper(int accountId) {
        Response<AccountRole> accountRole = accountRoleDAO.checkAccountRole(accountId);
        return accountRole.isSuccess()
                && accountRole.getData() != null
                && accountRole.getData().getRoleId() == 5;
    }

    public String getUserRole(int accountId) {
        if (isAdmin(accountId)) {
            return "admin";
        } else if (isTechnicalManager(accountId)) {
            return "Technical Manager";
        } else if (isCustomerSupportStaff(accountId)) {
            return "Customer Support Staff";
        } else if (isCustomer(accountId)) {
            return "customer";
        } else if(isStorekeeper(accountId)){
            return "Storekeeper";
        }
        return "unknown";
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
