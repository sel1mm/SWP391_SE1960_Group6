package dal;

import java.sql.*;
import java.time.LocalDate;
import model.AccountProfile;

public class AccountProfileDAO extends MyDAO {

    public boolean updateProfileDetails(int accountId, String address, LocalDate dateOfBirth,
            String avatarUrl, String nationalId, boolean verified, String extraData) {
        String sql = """
        UPDATE AccountProfile
        SET address = ?, dateOfBirth = ?, avatarUrl = ?, nationalId = ?, verified = ?, extraData = ?
        WHERE accountId = ?
    """;

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            // NULL-safe cho từng cột
            ps.setString(1, isNotBlank(address) ? address.trim() : null);
            if (dateOfBirth != null) {
                ps.setDate(2, java.sql.Date.valueOf(dateOfBirth));
            } else {
                ps.setNull(2, Types.DATE);
            }
            ps.setString(3, isNotBlank(avatarUrl) ? avatarUrl.trim() : null);
            ps.setString(4, isNotBlank(nationalId) ? nationalId.trim() : null);
            ps.setBoolean(5, verified);
            ps.setString(6, isNotBlank(extraData) ? extraData.trim() : null);
            ps.setInt(7, accountId);

            int rows = ps.executeUpdate();
            System.out.println("🟢 Update profile - Rows affected: " + rows);

            if (rows > 0) {
                // ✅ Profile tồn tại và được update
                return true;
            } else {
                // ⚠️ Không có bản ghi nào bị ảnh hưởng → chèn mới (vì profile có thể chưa tồn tại)
                System.out.println("⚠️ No profile found for accountId = " + accountId + ", inserting new one...");
                AccountProfile newProfile = new AccountProfile();
                newProfile.setAccountId(accountId);
                newProfile.setAddress(address);
                newProfile.setDateOfBirth(dateOfBirth);
                newProfile.setAvatarUrl(avatarUrl);
                newProfile.setNationalId(nationalId);
                newProfile.setVerified(verified);
                newProfile.setExtraData(extraData);

                return insertProfile(newProfile);
            }

        } catch (SQLException e) {
            System.err.println("❌ Error updating profile: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
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

            // NULL-safe cho từng trường
            ps.setString(2, isNotBlank(profile.getAddress()) ? profile.getAddress().trim() : null);

            if (profile.getDateOfBirth() != null) {
                ps.setDate(3, java.sql.Date.valueOf(profile.getDateOfBirth()));
            } else {
                ps.setNull(3, Types.DATE);
            }

            ps.setString(4, isNotBlank(profile.getAvatarUrl()) ? profile.getAvatarUrl().trim() : null);
            ps.setString(5, isNotBlank(profile.getNationalId()) ? profile.getNationalId().trim() : null);
            ps.setBoolean(6, profile.isVerified());
            ps.setString(7, isNotBlank(profile.getExtraData()) ? profile.getExtraData().trim() : null);

            int rows = ps.executeUpdate();
            System.out.println("✅ Insert profile - Rows affected: " + rows);
            return rows > 0;

        } catch (SQLException e) {
            System.err.println("❌ Error inserting profile: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

// Helper nhỏ
    private boolean isNotBlank(String s) {
        return s != null && !s.trim().isEmpty();
    }

    public AccountProfile getProfileByAccountId(int accountId) {
        String sql = "SELECT * FROM AccountProfile WHERE accountId = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            rs = ps.executeQuery();
            if (rs.next()) {
                AccountProfile profile = new AccountProfile();

                // ✅ QUAN TRỌNG: Phải lấy profileId từ database
                profile.setProfileId(rs.getInt("profileId"));

                profile.setAccountId(rs.getInt("accountId"));
                profile.setAddress(rs.getString("address"));
                if (rs.getDate("dateOfBirth") != null) {
                    profile.setDateOfBirth(rs.getDate("dateOfBirth").toLocalDate());
                }

                profile.setAvatarUrl(rs.getString("avatarUrl"));
                profile.setNationalId(rs.getString("nationalId"));
                profile.setVerified(rs.getBoolean("verified"));
                profile.setExtraData(rs.getString("extraData"));

                System.out.println("✅ Profile loaded - ProfileID: " + profile.getProfileId()
                        + ", AccountID: " + profile.getAccountId());

                return profile;
            }
        } catch (SQLException e) {
            System.err.println("❌ Error getting profile: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    // ✅ FIX: Thêm avatarUrl vào UPDATE statement
    public boolean updateProfile(AccountProfile profile) {
        String sql = "UPDATE AccountProfile SET address = ?, nationalId = ?, dateOfBirth = ?, avatarUrl = ? WHERE profileId = ?";

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, profile.getAddress());
            ps.setString(2, profile.getNationalId());

            // Convert LocalDate to SQL Date
            if (profile.getDateOfBirth() != null) {
                ps.setDate(3, java.sql.Date.valueOf(profile.getDateOfBirth()));
            } else {
                ps.setNull(3, java.sql.Types.DATE);
            }

            // ✅ THÊM avatarUrl parameter
            ps.setString(4, profile.getAvatarUrl());

            // ✅ profileId giờ là parameter thứ 5
            ps.setInt(5, profile.getProfileId());

            int rowsAffected = ps.executeUpdate();

            System.out.println("✅ Update profile - ProfileID: " + profile.getProfileId()
                    + ", Rows affected: " + rowsAffected);
            System.out.println("   - Address: " + profile.getAddress());
            System.out.println("   - National ID: " + profile.getNationalId());
            System.out.println("   - DOB: " + profile.getDateOfBirth());
            System.out.println("   - Avatar URL: " + profile.getAvatarUrl());

            return rowsAffected > 0;

        } catch (SQLException e) {
            System.err.println("❌ Error updating profile: " + e.getMessage());
            System.err.println("   - ProfileID: " + profile.getProfileId());
            System.err.println("   - AccountID: " + profile.getAccountId());
            e.printStackTrace();
            return false;
        }
    }

    public boolean createProfile(AccountProfile profile) {
        String sql = "INSERT INTO AccountProfile (accountId, verified) VALUES (?, ?)";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, profile.getAccountId());
            ps.setBoolean(2, profile.isVerified());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

}
