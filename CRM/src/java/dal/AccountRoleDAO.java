package dal;

import constant.MessageConstant;
import dto.Response;
import java.sql.SQLException;
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
}
