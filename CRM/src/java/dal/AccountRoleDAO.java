package dal;

import constant.MessageConstant;
import dto.Response;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.AccountRole;

public class AccountRoleDAO extends MyDAO {

    public Response<AccountRole> checkAccountRole(int accountId) {
        xSql = "SELECT accountId, roleId FROM AccountRole WHERE accountId = ?";
        try {
            ps = con.prepareStatement(xSql);
            ps.setInt(1, accountId);
            rs = ps.executeQuery();
            if (rs.next()) {
                AccountRole accountRole = new AccountRole(
                    rs.getInt("accountId"),
                    rs.getInt("roleId")
                );
                return new Response<>(
                    accountRole,
                    true,
                    MessageConstant.MESSAGE_SUCCESS
                );
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
        return new Response<>(null, false, MessageConstant.MESSAGE_FAILED);
    }

    public Response<List<AccountRole>> getRolesByAccountId(int accountId) {
        String sql = "SELECT accountId, roleId FROM AccountRole WHERE accountId = ?";
        List<AccountRole> accountRoles = new ArrayList<>();
        try {
            ps = con.prepareStatement(sql);
            ps.setInt(1, accountId);
            rs = ps.executeQuery();
            while (rs.next()) {
                AccountRole accountRole = new AccountRole(
                    rs.getInt("accountId"),
                    rs.getInt("roleId")
                );
                accountRoles.add(accountRole);
            }
            return new Response<>(accountRoles, true, MessageConstant.MESSAGE_SUCCESS);
        } catch (Exception e) {
            e.printStackTrace();
            return new Response<>(null, false, MessageConstant.MESSAGE_FAILED);
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
    }

    public Response<AccountRole> assignRoleToAccount(int accountId, int roleId) {
        String sql = "INSERT INTO AccountRole (accountId, roleId) VALUES (?, ?)";
        try {
            ps = con.prepareStatement(sql);
            ps.setInt(1, accountId);
            ps.setInt(2, roleId);
            int affectedRows = ps.executeUpdate();
            
            if (affectedRows > 0) {
                AccountRole accountRole = new AccountRole(accountId, roleId);
                return new Response<>(accountRole, true, "Role assigned successfully");
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (ps != null) ps.close();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
        return new Response<>(null, false, "Failed to assign role");
    }

    public Response<Boolean> removeRoleFromAccount(int accountId, int roleId) {
        String sql = "DELETE FROM AccountRole WHERE accountId = ? AND roleId = ?";
        try {
            ps = con.prepareStatement(sql);
            ps.setInt(1, accountId);
            ps.setInt(2, roleId);
            int affectedRows = ps.executeUpdate();
            
            if (affectedRows > 0) {
                return new Response<>(true, true, "Role removed successfully");
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (ps != null) ps.close();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
        return new Response<>(false, false, "Failed to remove role");
    }

    public Response<Boolean> hasRole(int accountId, int roleId) {
        String sql = "SELECT COUNT(*) as count FROM AccountRole WHERE accountId = ? AND roleId = ?";
        try {
            ps = con.prepareStatement(sql);
            ps.setInt(1, accountId);
            ps.setInt(2, roleId);
            rs = ps.executeQuery();
            if (rs.next()) {
                int count = rs.getInt("count");
                return new Response<>(count > 0, true, count > 0 ? "Account has this role" : "Account does not have this role");
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
        return new Response<>(false, false, "Failed to check role");
    }

    public Response<Boolean> removeAllRolesFromAccount(int accountId) {
        String sql = "DELETE FROM AccountRole WHERE accountId = ?";
        try {
            ps = con.prepareStatement(sql);
            ps.setInt(1, accountId);
            int affectedRows = ps.executeUpdate();
            
            return new Response<>(affectedRows >= 0, true, "All roles removed successfully");
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (ps != null) ps.close();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
        return new Response<>(false, false, "Failed to remove roles");
    }
}
