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
                if (rs != null) {
                    rs.close();
                }
                if (ps != null) {
                    ps.close();
                }
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
                if (rs != null) {
                    rs.close();
                }
                if (ps != null) {
                    ps.close();
                }
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
        return null;
    }

    public boolean checkExistUserName(String username) {
        xSql = "select * from Account where username = ?";
        try {
            ps = con.prepareStatement(xSql);
            ps.setString(1, username);
            rs = ps.executeQuery();
            if (rs.next()) {
                return true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean checkExistEmail(String email) {
        xSql = "select * from Account where email = ?";
        try {
            ps = con.prepareStatement(xSql);
            ps.setString(1, email);
            rs = ps.executeQuery();
            if (rs.next()) {
                return true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean checkExistPhone(String phone) {
        xSql = "select * from Account where phone = ?";
        try {
            ps = con.prepareStatement(xSql);
            ps.setString(1, phone);
            rs = ps.executeQuery();
            if (rs.next()) {
                return true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean register(String username, String password, String email, String phone, String fullName, String status) {
        if (checkExistUserName(username) || checkExistEmail(email) || checkExistPhone(phone)) {
            return false;
        }
        xSql = "INSERT INTO Account(username, passwordHash, email, phone, fullName, status) VALUES (?, ?, ?, ?, ?, ?)";
        try {
            ps = con.prepareStatement(xSql);
            ps.setString(1, username);
            ps.setString(2, password);
            ps.setString(3, email);
            ps.setString(4, phone);
            ps.setString(5, fullName);
            ps.setString(6,status);
            ps.executeUpdate();
            ps.close();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

}
