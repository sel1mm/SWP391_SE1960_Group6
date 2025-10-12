package dal;

import java.sql.*;
import java.time.LocalDate;
import model.AccountProfile;

public class AccountProfileDAO extends MyDAO {

    public boolean updateProfileDetails(int accountId, String address, LocalDate dateOfBirth,
            String avatarUrl, String nationalId, boolean verified, String extraData) {
        String sqlUpdate = """
            UPDATE AccountProfile
            SET address = ?, dateOfBirth = ?, avatarUrl = ?, nationalId = ?, verified = ?, extraData = ?
            WHERE accountId = ?
        """;

        try (PreparedStatement ps = con.prepareStatement(sqlUpdate)) {
            ps.setString(1, address);
            if (dateOfBirth != null) {
                ps.setDate(2, Date.valueOf(dateOfBirth));
            } else {
                ps.setNull(2, Types.DATE);
            }
            ps.setString(3, avatarUrl);
            ps.setString(4, nationalId);
            ps.setBoolean(5, verified);
            ps.setString(6, extraData);
            ps.setInt(7, accountId);

            int rows = ps.executeUpdate();
            if (rows > 0) {
                return true;
            }

            return insertProfileIfNotExists(accountId, address, dateOfBirth, avatarUrl, nationalId, verified, extraData);

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private boolean insertProfileIfNotExists(int accountId, String address, LocalDate dateOfBirth,
            String avatarUrl, String nationalId, boolean verified, String extraData) {
        String sqlInsert = """
            INSERT INTO AccountProfile (accountId, address, dateOfBirth, avatarUrl, nationalId, verified, extraData)
            SELECT ?, ?, ?, ?, ?, ?, ?
            WHERE NOT EXISTS (SELECT 1 FROM AccountProfile WHERE accountId = ?)
        """;

        try (PreparedStatement ps = con.prepareStatement(sqlInsert)) {
            ps.setInt(1, accountId);
            ps.setString(2, address);
            if (dateOfBirth != null) {
                ps.setDate(3, Date.valueOf(dateOfBirth));
            } else {
                ps.setNull(3, Types.DATE);
            }
            ps.setString(4, avatarUrl);
            ps.setString(5, nationalId);
            ps.setBoolean(6, verified);
            ps.setString(7, extraData);
            ps.setInt(8, accountId);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean insertProfile(AccountProfile profile) {
        String sql = """
        INSERT INTO AccountProfile (accountId, address, dateOfBirth, avatarUrl, nationalId, verified, extraData)
        VALUES (?, ?, ?, ?, ?, ?, ?)
    """;

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, profile.getAccountId());
            ps.setString(2, profile.getAddress());
            if (profile.getDateOfBirth() != null) {
                ps.setDate(3, Date.valueOf(profile.getDateOfBirth()));
            } else {
                ps.setNull(3, Types.DATE);
            }
            ps.setString(4, profile.getAvatarUrl());
            ps.setString(5, profile.getNationalId());
            ps.setBoolean(6, profile.isVerified());
            ps.setString(7, profile.getExtraData());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public AccountProfile getProfileByAccountId(int accountId) {
        String sql = "SELECT * FROM AccountProfile WHERE accountId = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            rs = ps.executeQuery();
            if (rs.next()) {
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
                return profile;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
}
