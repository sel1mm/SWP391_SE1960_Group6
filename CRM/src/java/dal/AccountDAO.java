package dal;

import model.Account;
import java.sql.SQLException;
import java.time.LocalDateTime;

public class AccountDAO extends MyDAO {

    public Account checkLogin(String username, String passwordHash) {
        String sql = "SELECT * FROM Account WHERE username = ? AND passwordHash = ?";
        try {
            ps = con.prepareStatement(sql);
            ps.setString(1, username);
            ps.setString(2, passwordHash); // password đã hash từ service
            rs = ps.executeQuery();
            if (rs.next()) {
                LocalDateTime createdAt = null;
                LocalDateTime updatedAt = null;

                if (rs.getTimestamp("createdAt") != null) {
                    createdAt = rs.getTimestamp("createdAt").toLocalDateTime();
                }
                if (rs.getTimestamp("updatedAt") != null) {
                    updatedAt = rs.getTimestamp("updatedAt").toLocalDateTime();
                }

                return new Account(
                    rs.getInt("accountId"),
                    rs.getString("username"),
                    rs.getString("passwordHash"),
                    rs.getString("fullName"),
                    rs.getString("email"),
                    rs.getString("phone"),
                    rs.getString("status"),
                    createdAt,
                    updatedAt
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
        return null;
    }
    
    public Account getAccountByUserName(String username) {
    String sql = "SELECT * FROM Account WHERE username = ?";
    try {
        ps = con.prepareStatement(sql);
        ps.setString(1, username);
        rs = ps.executeQuery();
        if (rs.next()) {
            LocalDateTime createdAt = null;
            LocalDateTime updatedAt = null;

            if (rs.getTimestamp("createdAt") != null) {
                createdAt = rs.getTimestamp("createdAt").toLocalDateTime();
            }
            if (rs.getTimestamp("updatedAt") != null) {
                updatedAt = rs.getTimestamp("updatedAt").toLocalDateTime();
            }

            return new Account(
                rs.getInt("accountId"),
                rs.getString("username"),
                rs.getString("passwordHash"),
                rs.getString("fullName"),
                rs.getString("email"),
                rs.getString("phone"),
                rs.getString("status"),
                createdAt,
                updatedAt
            );
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        try {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }
    return null;
}

}
