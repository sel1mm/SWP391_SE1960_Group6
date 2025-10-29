package dal;

import constant.MessageConstant;
import dto.Response;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import model.Account;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import model.AccountProfile;

public class AccountDAO extends MyDAO {

    public List<Account> searchAccounts(String keyword, String status) {
        List<Account> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM Account WHERE 1=1");

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (username LIKE ? OR fullName LIKE ? OR email LIKE ?)");
        }
        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND status = ?");
        }

        try (
                PreparedStatement ps = con.prepareStatement(sql.toString())) {
            int index = 1;
            if (keyword != null && !keyword.trim().isEmpty()) {
                String searchPattern = "%" + keyword.trim() + "%";
                ps.setString(index++, searchPattern);
                ps.setString(index++, searchPattern);
                ps.setString(index++, searchPattern);
            }
            if (status != null && !status.trim().isEmpty()) {
                ps.setString(index++, status);
            }

            rs = ps.executeQuery();
            while (rs.next()) {
                LocalDateTime createdAt = null;
                LocalDateTime updatedAt = null;

                if (rs.getTimestamp("createdAt") != null) {
                    createdAt = rs.getTimestamp("createdAt").toLocalDateTime();
                }
                if (rs.getTimestamp("updatedAt") != null) {
                    updatedAt = rs.getTimestamp("updatedAt").toLocalDateTime();
                }

                Account a = new Account(
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
                list.add(a);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
    
    public List<Account> searchAccountsWithRole(String keyword, String status, String roleId) {
        List<Account> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT DISTINCT a.* FROM Account a "
        );
        
        // Add JOIN if roleId filter is provided
        if (roleId != null && !roleId.trim().isEmpty()) {
            sql.append("INNER JOIN AccountRole ar ON a.accountId = ar.accountId ");
        }
        
        sql.append("WHERE 1=1 ");

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (a.username LIKE ? OR a.fullName LIKE ? OR a.email LIKE ?) ");
        }
        if (status != null && !status.trim().isEmpty()) {
            sql.append("AND a.status = ? ");
        }
        if (roleId != null && !roleId.trim().isEmpty()) {
            sql.append("AND ar.roleId = ? ");
        }
        
        sql.append("ORDER BY a.accountId");

        try (PreparedStatement ps = con.prepareStatement(sql.toString())) {
            int index = 1;
            if (keyword != null && !keyword.trim().isEmpty()) {
                String searchPattern = "%" + keyword.trim() + "%";
                ps.setString(index++, searchPattern);
                ps.setString(index++, searchPattern);
                ps.setString(index++, searchPattern);
            }
            if (status != null && !status.trim().isEmpty()) {
                ps.setString(index++, status);
            }
            if (roleId != null && !roleId.trim().isEmpty()) {
                ps.setInt(index++, Integer.parseInt(roleId));
            }

            rs = ps.executeQuery();
            while (rs.next()) {
                LocalDateTime createdAt = null;
                LocalDateTime updatedAt = null;

                if (rs.getTimestamp("createdAt") != null) {
                    createdAt = rs.getTimestamp("createdAt").toLocalDateTime();
                }
                if (rs.getTimestamp("updatedAt") != null) {
                    updatedAt = rs.getTimestamp("updatedAt").toLocalDateTime();
                }

                Account a = new Account(
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
                list.add(a);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Account> searchCustomerAccounts(String keyword, String status) {
        List<Account> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder("""
        SELECT a.*, 
               p.address, p.dateOfBirth, p.avatarUrl, p.nationalId, 
               p.verified, p.extraData
        FROM Account a
        INNER JOIN AccountRole ar ON a.accountId = ar.accountId
        LEFT JOIN AccountProfile p ON a.accountId = p.accountId
        WHERE ar.roleId = 2
    """);

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (a.username LIKE ? OR a.fullName LIKE ? OR a.email LIKE ?)");
        }
        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND a.status = ?");
        }

        sql.append(" ORDER BY a.accountId");

        try (PreparedStatement ps = con.prepareStatement(sql.toString())) {
            int index = 1;

            if (keyword != null && !keyword.trim().isEmpty()) {
                String searchPattern = "%" + keyword.trim() + "%";
                ps.setString(index++, searchPattern);
                ps.setString(index++, searchPattern);
                ps.setString(index++, searchPattern);
            }

            if (status != null && !status.trim().isEmpty()) {
                ps.setString(index++, status);
            }

            rs = ps.executeQuery();

            while (rs.next()) {
                LocalDateTime createdAt = rs.getTimestamp("createdAt") != null
                        ? rs.getTimestamp("createdAt").toLocalDateTime()
                        : null;
                LocalDateTime updatedAt = rs.getTimestamp("updatedAt") != null
                        ? rs.getTimestamp("updatedAt").toLocalDateTime()
                        : null;

                Account account = new Account(
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

                AccountProfile profile = new AccountProfile();
                profile.setAccountId(rs.getInt("accountId"));
                profile.setAddress(rs.getString("address"));
                if (rs.getDate("dateOfBirth") != null) {
                    profile.setDateOfBirth(rs.getDate("dateOfBirth").toLocalDate());
                }
                profile.setAvatarUrl(rs.getString("avatarUrl"));
                profile.setNationalId(rs.getString("nationalId"));
                profile.setVerified(rs.getBoolean("verified"));
                profile.setExtraData(rs.getString("extraData"));

                account.setProfile(profile);

                list.add(account);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    public Response<List<Account>> getAllAccounts() {
        String sql = "SELECT * FROM Account ORDER BY accountId";
        List<Account> accounts = new ArrayList<>();
        try {
            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                LocalDateTime createdAt = null;
                LocalDateTime updatedAt = null;

                if (rs.getTimestamp("createdAt") != null) {
                    createdAt = rs.getTimestamp("createdAt").toLocalDateTime();
                }
                if (rs.getTimestamp("updatedAt") != null) {
                    updatedAt = rs.getTimestamp("updatedAt").toLocalDateTime();
                }

                Account account = new Account(
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
                accounts.add(account);
            }
            return new Response<>(accounts, true, MessageConstant.MESSAGE_SUCCESS);
        } catch (Exception e) {
            e.printStackTrace();
            return new Response<>(null, false, MessageConstant.MESSAGE_FAILED);
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
    }

    public Response<List<Account>> getAllCustomerAccounts() {
        String sql = """
        SELECT a.*, 
               p.address, p.dateOfBirth, p.avatarUrl, p.nationalId, 
               p.verified, p.extraData
        FROM Account a
        INNER JOIN AccountRole ar ON a.accountId = ar.accountId
        LEFT JOIN AccountProfile p ON a.accountId = p.accountId
        WHERE ar.roleId = 2
        ORDER BY a.accountId
    """;

        List<Account> accounts = new ArrayList<>();

        try {
            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                LocalDateTime createdAt = rs.getTimestamp("createdAt") != null
                        ? rs.getTimestamp("createdAt").toLocalDateTime()
                        : null;
                LocalDateTime updatedAt = rs.getTimestamp("updatedAt") != null
                        ? rs.getTimestamp("updatedAt").toLocalDateTime()
                        : null;

                Account account = new Account(
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

                AccountProfile profile = new AccountProfile();
                profile.setAccountId(rs.getInt("accountId"));
                profile.setAddress(rs.getString("address"));
                if (rs.getDate("dateOfBirth") != null) {
                    profile.setDateOfBirth(rs.getDate("dateOfBirth").toLocalDate());
                }
                profile.setAvatarUrl(rs.getString("avatarUrl"));
                profile.setNationalId(rs.getString("nationalId"));
                profile.setVerified(rs.getBoolean("verified"));
                profile.setExtraData(rs.getString("extraData"));

                account.setProfile(profile);

                accounts.add(account);
            }

            return new Response<>(accounts, true, MessageConstant.MESSAGE_SUCCESS);

        } catch (Exception e) {
            e.printStackTrace();
            return new Response<>(null, false, MessageConstant.MESSAGE_FAILED);
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
    }

    public Account checkLogin(String username, String passwordHash) {
        String sql = "SELECT * FROM Account WHERE username = ? AND passwordHash = ?";
        try {
            ps = con.prepareStatement(sql);
            ps.setString(1, username);
            ps.setString(2, passwordHash);
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
            ps.setString(6, status);
            ps.executeUpdate();
            ps.close();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public Account getAccountByEmail(String email) {
        String sql = "SELECT * FROM Account WHERE email = ?";
        try {
            ps = con.prepareStatement(sql);
            ps.setString(1, email);
            rs = ps.executeQuery();
            if (rs.next()) {
                return new Account(
                        rs.getInt("accountId"),
                        rs.getString("username"),
                        rs.getString("passwordHash"),
                        rs.getString("fullName"),
                        rs.getString("email"),
                        rs.getString("phone"),
                        rs.getString("status")
                );
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updatePasswordByEmail(String email, String hashedPassword) {
        String sql = "UPDATE Account SET passwordHash = ?, updatedAt = NOW() WHERE email = ?";
        try {
            ps = con.prepareStatement(sql);
            ps.setString(1, hashedPassword);
            ps.setString(2, email);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public Account getAccountById(int accountId) {
        String sql = "SELECT * FROM Account WHERE accountId = ?";
        try {
            ps = connection.prepareStatement(sql);
            ps.setInt(1, accountId);
            rs = ps.executeQuery();

            if (rs.next()) {
                Account account = new Account();

                account.setAccountId(rs.getInt("accountId"));
                account.setUsername(rs.getString("username"));
                account.setPasswordHash(rs.getString("passwordHash"));
                account.setFullName(rs.getString("fullName"));
                account.setEmail(rs.getString("email"));
                account.setPhone(rs.getString("phone"));
                account.setStatus(rs.getString("status"));

                // Xử lý createdAt
                java.sql.Timestamp createdTs = rs.getTimestamp("createdAt");
                if (createdTs != null) {
                    account.setCreatedAt(createdTs.toLocalDateTime());
                }

                // Xử lý updatedAt
                java.sql.Timestamp updatedTs = rs.getTimestamp("updatedAt");
                if (updatedTs != null) {
                    account.setUpdatedAt(updatedTs.toLocalDateTime());
                }

                return account;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) {
                    rs.close();
                }
                if (ps != null) {
                    ps.close();
                }
            } catch (Exception ignored) {
            }
        }
        return null;
    }

    public Response<Account> getAccountById2(int accountId) {
        String sql = "SELECT * FROM Account WHERE accountId = ?";
        try {
            ps = con.prepareStatement(sql);
            ps.setInt(1, accountId);
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

                Account account = new Account(
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
                return new Response<>(account, true, MessageConstant.MESSAGE_SUCCESS);
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
        return new Response<>(null, false, MessageConstant.MESSAGE_FAILED);
    }

    public Response<Account> createAccount(Account account) {
        String sql = "INSERT INTO Account (username, passwordHash, fullName, email, phone, status, createdAt) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try {
            ps = con.prepareStatement(sql, java.sql.Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, account.getUsername());
            ps.setString(2, account.getPasswordHash());
            ps.setString(3, account.getFullName());
            ps.setString(4, account.getEmail());
            ps.setString(5, account.getPhone());
            ps.setString(6, account.getStatus());
            ps.setTimestamp(7, java.sql.Timestamp.valueOf(account.getCreatedAt()));

            int affectedRows = ps.executeUpdate();

            if (affectedRows > 0) {
                try (java.sql.ResultSet generatedKeys = ps.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        account.setAccountId(generatedKeys.getInt(1));
                        return new Response<>(account, true, "Account created successfully");
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (ps != null) {
                    ps.close();
                }
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
        return new Response<>(null, false, "Failed to create account");
    }

    public Response<Account> getAccountByUsername(String username) {
        String sql = "SELECT * FROM Account WHERE username = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
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

                Account acc = new Account(
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

                return new Response<>(acc, true, MessageConstant.MESSAGE_SUCCESS);
            }

            return new Response<>(null, false, "Account not found");

        } catch (SQLException e) {
            e.printStackTrace();
            return new Response<>(null, false, "Database error: " + e.getMessage());
        }
    }

    public Response<Account> updateAccount(Account account) {
        String sql = "UPDATE Account SET username = ?, fullName = ?, email = ?, phone = ?, status = ?, updatedAt = ? WHERE accountId = ?";
        try {
            ps = con.prepareStatement(sql);
            ps.setString(1, account.getUsername());
            ps.setString(2, account.getFullName());
            ps.setString(3, account.getEmail());
            ps.setString(4, account.getPhone());
            ps.setString(5, account.getStatus());
            ps.setTimestamp(6, java.sql.Timestamp.valueOf(java.time.LocalDateTime.now()));
            ps.setInt(7, account.getAccountId());

            int affectedRows = ps.executeUpdate();

            if (affectedRows > 0) {
                account.setUpdatedAt(java.time.LocalDateTime.now());
                return new Response<>(account, true, "Account updated successfully");
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (ps != null) {
                    ps.close();
                }
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
        return new Response<>(null, false, "Failed to update account");
    }

    public Response<Account> updatePassword(int accountId, String newPasswordHash) {
        String sql = "UPDATE Account SET passwordHash = ?, updatedAt = ? WHERE accountId = ?";
        try {
            ps = con.prepareStatement(sql);
            ps.setString(1, newPasswordHash);
            ps.setTimestamp(2, java.sql.Timestamp.valueOf(java.time.LocalDateTime.now()));
            ps.setInt(3, accountId);

            int affectedRows = ps.executeUpdate();

            if (affectedRows > 0) {
                return new Response<>(null, true, "Password updated successfully");
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (ps != null) {
                    ps.close();
                }
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
        return new Response<>(null, false, "Failed to update password");
    }

    public Response<Boolean> deleteAccount(int accountId) {
        String sql = """
        UPDATE Account
        SET status = 
            CASE 
                WHEN status = 'Active' THEN 'InActive'
                ELSE 'Active'
            END
        WHERE accountId = ?
    """;

        try {
            ps = con.prepareStatement(sql);
            ps.setInt(1, accountId);
            int affectedRows = ps.executeUpdate();

            if (affectedRows > 0) {
                return new Response<>(true, true, "Account status toggled successfully");
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (ps != null) {
                    ps.close();
                }
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
        return new Response<>(false, false, "Account status toggled failed");
    }

    public Response<Boolean> isUsernameExists(String username) {
        String sql = "SELECT COUNT(*) as count FROM Account WHERE username = ?";
        try {
            ps = con.prepareStatement(sql);
            ps.setString(1, username);
            rs = ps.executeQuery();
            if (rs.next()) {
                int count = rs.getInt("count");
                return new Response<>(count > 0, true, count > 0 ? "Username already exists" : "Username available");
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
        return new Response<>(false, false, "Failed to check username");
    }

    public Response<Boolean> isEmailExists(String email) {
        String sql = "SELECT COUNT(*) as count FROM Account WHERE email = ?";
        try {
            ps = con.prepareStatement(sql);
            ps.setString(1, email);
            rs = ps.executeQuery();
            if (rs.next()) {
                int count = rs.getInt("count");
                return new Response<>(count > 0, true, count > 0 ? "Email already exists" : "Email available");
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
        return new Response<>(false, false, "Failed to check email");
    }

    public Response<Boolean> isPhoneExists(String phone) {
        String sql = "SELECT COUNT(*) as count FROM Account WHERE phone = ?";
        try {
            ps = con.prepareStatement(sql);
            ps.setString(1, phone);
            rs = ps.executeQuery();
            if (rs.next()) {
                int count = rs.getInt("count");
                return new Response<>(count > 0, true, count > 0 ? "Phone already exists" : "Phone available");
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
        return new Response<>(false, false, "Failed to check phone");
    }

    public boolean updateAccountDetails(int accountId, String username, String passwordHash,
            String fullName, String email, String phone, String status) {
        String sql = """
            UPDATE Account
            SET username = ?, passwordHash = ?, fullName = ?, email = ?, phone = ?, status = ?, updatedAt = NOW()
            WHERE accountId = ?
        """;
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, passwordHash);
            ps.setString(3, fullName);
            ps.setString(4, email);
            ps.setString(5, phone);
            ps.setString(6, status);
            ps.setInt(7, accountId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean isSameAccountByUsername(String username, int accountId) {
        String sql = "SELECT COUNT(*) AS count FROM Account WHERE username = ? AND accountId = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setInt(2, accountId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("count") > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean isSameAccountByEmail(String email, int accountId) {
        String sql = "SELECT COUNT(*) AS count FROM Account WHERE email = ? AND accountId = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setInt(2, accountId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("count") > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean isSameAccountByPhone(String phone, int accountId) {
        String sql = "SELECT COUNT(*) AS count FROM Account WHERE phone = ? AND accountId = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, phone);
            ps.setInt(2, accountId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("count") > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Account> getAccountsByRole(String roleName) {
        List<Account> accounts = new ArrayList<>();
        xSql = "SELECT a.* FROM Account a "
                + "INNER JOIN AccountRole ar ON a.accountId = ar.accountId "
                + "INNER JOIN Role r ON ar.roleId = r.roleId "
                + "WHERE r.roleName = ? AND a.status = 'Active'";

        try {
            ps = con.prepareStatement(xSql);
            ps.setString(1, roleName);
            rs = ps.executeQuery();

            while (rs.next()) {
                LocalDateTime createdAt = null;
                LocalDateTime updatedAt = null;

                if (rs.getTimestamp("createdAt") != null) {
                    createdAt = rs.getTimestamp("createdAt").toLocalDateTime();
                }
                if (rs.getTimestamp("updatedAt") != null) {
                    updatedAt = rs.getTimestamp("updatedAt").toLocalDateTime();
                }

                Account account = new Account(
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
                accounts.add(account);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }

        return accounts;
    }

    private void closeResources() {
        try {
            if (rs != null) {
                rs.close();
            }
            if (ps != null) {
                ps.close();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public Response<Boolean> isEmailExistsExcludingId(String email, int accountId) {
        String sql = "SELECT COUNT(*) as count FROM Account WHERE email = ? AND accountId <> ?";
        try {
            ps = con.prepareStatement(sql);
            ps.setString(1, email);
            ps.setInt(2, accountId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return new Response<>(rs.getInt("count") > 0, true, rs.getInt("count") > 0 ? "Email already exists" : "Email available");
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
        return new Response<>(false, false, "Failed to check email");
    }

    public Response<Boolean> isPhoneExistsExcludingId(String phone, int accountId) {
        String sql = "SELECT COUNT(*) as count FROM Account WHERE phone = ? AND accountId <> ?";
        try {
            ps = con.prepareStatement(sql);
            ps.setString(1, phone);
            ps.setInt(2, accountId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return new Response<>(rs.getInt("count") > 0, true, rs.getInt("count") > 0 ? "Phone already exists" : "Phone available");
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
        return new Response<>(false, false, "Failed to check phone");
    }

    public List<Account> getCustomerAccountsPaged(int offset, int limit) {
        List<Account> list = new ArrayList<>();
        String sql = """
        SELECT a.*, 
               p.address AS address, 
               p.dateOfBirth AS dateOfBirth, 
               p.avatarUrl AS avatarUrl, 
               p.nationalId AS nationalId, 
               p.verified AS verified, 
               p.extraData AS extraData
        FROM Account a
        INNER JOIN AccountRole ar ON a.accountId = ar.accountId
        INNER JOIN Role r ON ar.roleId = r.roleId
        LEFT JOIN AccountProfile p ON a.accountId = p.accountId
        WHERE r.roleName = 'Customer'
        ORDER BY a.accountId
        LIMIT ? OFFSET ?
    """;

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, limit);
            ps.setInt(2, offset);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    LocalDateTime createdAt = rs.getTimestamp("createdAt") != null
                            ? rs.getTimestamp("createdAt").toLocalDateTime()
                            : null;
                    LocalDateTime updatedAt = rs.getTimestamp("updatedAt") != null
                            ? rs.getTimestamp("updatedAt").toLocalDateTime()
                            : null;

                    Account account = new Account(
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

                    AccountProfile profile = new AccountProfile();
                    profile.setAccountId(rs.getInt("accountId"));
                    profile.setAddress(rs.getString("address"));
                    if (rs.getDate("dateOfBirth") != null) {
                        profile.setDateOfBirth(rs.getDate("dateOfBirth").toLocalDate());
                    }
                    profile.setAvatarUrl(rs.getString("avatarUrl"));
                    profile.setNationalId(rs.getString("nationalId"));
                    profile.setVerified(rs.getBoolean("verified"));
                    profile.setExtraData(rs.getString("extraData"));
                    account.setProfile(profile);

                    list.add(account);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countAllCustomerAccounts() throws SQLException {
        String sql = "SELECT COUNT(*) FROM Account a "
                + "JOIN AccountRole ar ON a.accountId = ar.accountId "
                + "JOIN Role r ON ar.roleId = r.roleId "
                + "WHERE r.roleName = 'Customer'";
        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }

    public List<Account> searchCustomerAccountsPaged(String keyword, String status, int offset, int limit) {
        List<Account> list = new ArrayList<>();

        // ✅ Sử dụng roleName để đảm bảo không phụ thuộc roleId
        StringBuilder sql = new StringBuilder("""
        SELECT a.*, 
               p.address AS address, 
               p.dateOfBirth AS dateOfBirth, 
               p.avatarUrl AS avatarUrl, 
               p.nationalId AS nationalId, 
               p.verified AS verified, 
               p.extraData AS extraData
        FROM Account a
        INNER JOIN AccountRole ar ON a.accountId = ar.accountId
        INNER JOIN Role r ON ar.roleId = r.roleId
        LEFT JOIN AccountProfile p ON a.accountId = p.accountId
        WHERE r.roleName = 'Customer'
    """);

        // ✅ Thêm điều kiện tìm kiếm nếu có keyword hoặc status
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (a.username LIKE ? OR a.fullName LIKE ? OR a.email LIKE ?)");
        }
        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND a.status = ?");
        }

        sql.append(" ORDER BY a.accountId LIMIT ? OFFSET ?");

        try (PreparedStatement ps = con.prepareStatement(sql.toString())) {
            int index = 1;

            // ✅ Gán giá trị cho keyword
            if (keyword != null && !keyword.trim().isEmpty()) {
                String searchPattern = "%" + keyword.trim() + "%";
                ps.setString(index++, searchPattern);
                ps.setString(index++, searchPattern);
                ps.setString(index++, searchPattern);
            }

            // ✅ Gán giá trị cho status
            if (status != null && !status.trim().isEmpty()) {
                ps.setString(index++, status.trim());
            }

            // ✅ Giới hạn phân trang
            ps.setInt(index++, limit);
            ps.setInt(index, offset);

            // ✅ Sử dụng try-with-resources cho ResultSet để tránh rò rỉ
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    LocalDateTime createdAt = rs.getTimestamp("createdAt") != null
                            ? rs.getTimestamp("createdAt").toLocalDateTime()
                            : null;
                    LocalDateTime updatedAt = rs.getTimestamp("updatedAt") != null
                            ? rs.getTimestamp("updatedAt").toLocalDateTime()
                            : null;

                    // ✅ Khởi tạo Account
                    Account account = new Account(
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

                    // ✅ Khởi tạo Profile (nếu có dữ liệu)
                    AccountProfile profile = new AccountProfile();
                    profile.setAccountId(rs.getInt("accountId"));
                    profile.setAddress(rs.getString("address"));

                    if (rs.getDate("dateOfBirth") != null) {
                        profile.setDateOfBirth(rs.getDate("dateOfBirth").toLocalDate());
                    }

                    profile.setAvatarUrl(rs.getString("avatarUrl"));
                    profile.setNationalId(rs.getString("nationalId"));
                    profile.setVerified(rs.getBoolean("verified"));
                    profile.setExtraData(rs.getString("extraData"));

                    account.setProfile(profile);
                    list.add(account);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    public int countSearchCustomerAccounts(String keyword, String status) throws SQLException {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM Account a "
                + "JOIN AccountRole ar ON a.accountId = ar.accountId "
                + "JOIN Role r ON ar.roleId = r.roleId "
                + "WHERE r.roleName = 'Customer' ");

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (a.username LIKE ? OR a.email LIKE ? OR a.fullName LIKE ?) ");
        }
        if (status != null && !status.trim().isEmpty()) {
            sql.append("AND a.status = ? ");
        }

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            int idx = 1;
            if (keyword != null && !keyword.trim().isEmpty()) {
                String like = "%" + keyword + "%";
                ps.setString(idx++, like);
                ps.setString(idx++, like);
                ps.setString(idx++, like);
            }
            if (status != null && !status.trim().isEmpty()) {
                ps.setString(idx++, status);
            }

            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }




//public Response<Boolean> isPhoneExistsExcludingId(String phone, int accountId) {
//    String sql = "SELECT COUNT(*) as count FROM Account WHERE phone = ? AND accountId <> ?";
//    try {
//        ps = con.prepareStatement(sql);
//        ps.setString(1, phone);
//        ps.setInt(2, accountId);
//        rs = ps.executeQuery();
//        if (rs.next()) {
//            return new Response<>(rs.getInt("count") > 0, true, rs.getInt("count") > 0 ? "Phone already exists" : "Phone available");
//        }
//    } catch (Exception e) {
//        e.printStackTrace();
//    } finally {
//        try { if(rs != null) rs.close(); if(ps != null) ps.close(); } catch(SQLException ex){ ex.printStackTrace(); }
//    }
//    return new Response<>(false, false, "Failed to check phone");
//}
public boolean updateEmail(int accountId, String newEmail) {
    String sql = "UPDATE Account SET email = ?, updatedAt = ? WHERE accountId = ?";
    PreparedStatement ps = null;
    try {
        ps = con.prepareStatement(sql);
        ps.setString(1, newEmail);
        ps.setTimestamp(2, java.sql.Timestamp.valueOf(java.time.LocalDateTime.now()));
        ps.setInt(3, accountId);


        int affectedRows = ps.executeUpdate();
        return affectedRows > 0; // true nếu update thành công
    } catch (Exception e) {
        e.printStackTrace();
        return false;
    } finally {
        try {
            if (ps != null) ps.close();
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
    }
}
// Đếm tổng số user (có thể có điều kiện search/filter)
public int countAllAccounts(String keyword, String status, String roleId) {
    StringBuilder sql = new StringBuilder("SELECT COUNT(DISTINCT a.accountId) FROM Account a ");
    if (roleId != null && !roleId.trim().isEmpty()) {
        sql.append("JOIN AccountRole ar ON a.accountId = ar.accountId ");
    }
    sql.append("WHERE 1=1 ");
    if (keyword != null && !keyword.trim().isEmpty()) {
        sql.append("AND (a.username LIKE ? OR a.fullName LIKE ? OR a.email LIKE ?) ");
    }
    if (status != null && !status.trim().isEmpty()) {
        sql.append("AND a.status = ? ");
    }
    if (roleId != null && !roleId.trim().isEmpty()) {
        sql.append("AND ar.roleId = ? ");
    }

    try (PreparedStatement ps = con.prepareStatement(sql.toString())) {
        int idx = 1;
        if (keyword != null && !keyword.trim().isEmpty()) {
            String like = "%" + keyword.trim() + "%";
            ps.setString(idx++, like);
            ps.setString(idx++, like);
            ps.setString(idx++, like);
        }
        if (status != null && !status.trim().isEmpty()) {
            ps.setString(idx++, status);
        }
        if (roleId != null && !roleId.trim().isEmpty()) {
            ps.setInt(idx++, Integer.parseInt(roleId));
        }

        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    return 0;
}

// Lấy danh sách user có phân trang
public List<Account> getAccountsPaged(String keyword, String status, String roleId, int offset, int limit) {
    List<Account> list = new ArrayList<>();
    StringBuilder sql = new StringBuilder(
        "SELECT DISTINCT a.* FROM Account a "
    );
    if (roleId != null && !roleId.trim().isEmpty()) {
        sql.append("JOIN AccountRole ar ON a.accountId = ar.accountId ");
    }
    sql.append("WHERE 1=1 ");
    if (keyword != null && !keyword.trim().isEmpty()) {
        sql.append("AND (a.username LIKE ? OR a.fullName LIKE ? OR a.email LIKE ?) ");
    }
    if (status != null && !status.trim().isEmpty()) {
        sql.append("AND a.status = ? ");
    }
    if (roleId != null && !roleId.trim().isEmpty()) {
        sql.append("AND ar.roleId = ? ");
    }
    sql.append("ORDER BY a.accountId LIMIT ? OFFSET ?");

    try (PreparedStatement ps = con.prepareStatement(sql.toString())) {
        int idx = 1;
        if (keyword != null && !keyword.trim().isEmpty()) {
            String like = "%" + keyword.trim() + "%";
            ps.setString(idx++, like);
            ps.setString(idx++, like);
            ps.setString(idx++, like);
        }
        if (status != null && !status.trim().isEmpty()) {
            ps.setString(idx++, status);
        }
        if (roleId != null && !roleId.trim().isEmpty()) {
            ps.setInt(idx++, Integer.parseInt(roleId));
        }
        ps.setInt(idx++, limit);
        ps.setInt(idx, offset);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Account a = new Account(
                rs.getInt("accountId"),
                rs.getString("username"),
                rs.getString("passwordHash"),
                rs.getString("fullName"),
                rs.getString("email"),
                rs.getString("phone"),
                rs.getString("status"),
                rs.getTimestamp("createdAt") != null ? rs.getTimestamp("createdAt").toLocalDateTime() : null,
                rs.getTimestamp("updatedAt") != null ? rs.getTimestamp("updatedAt").toLocalDateTime() : null
            );
            list.add(a);
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    return list;
}
}
