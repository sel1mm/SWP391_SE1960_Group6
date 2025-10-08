package dal;

import constant.MessageConstant;
import dto.Response;
import model.Account;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

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
                if (rs != null) rs.close();
                if (ps != null) ps.close();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
    }

    public Response<Account> getAccountById(int accountId) {
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
                if (rs != null) rs.close();
                if (ps != null) ps.close();
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
                if (ps != null) ps.close();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
        return new Response<>(null, false, "Failed to create account");
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
                if (ps != null) ps.close();
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
            // controller => service => dao 
            if (affectedRows > 0) {
                return new Response<>(null, true, "Password updated successfully");
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
            if (ps != null) ps.close();
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
    }

    return new Response<>(false, false, "Failed to toggle account status");
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
                if (rs != null) rs.close();
                if (ps != null) ps.close();
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
                if (rs != null) rs.close();
                if (ps != null) ps.close();
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
                if (rs != null) rs.close();
                if (ps != null) ps.close();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
        return new Response<>(false, false, "Failed to check phone");
    }

}
