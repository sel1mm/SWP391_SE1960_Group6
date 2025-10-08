package dal;

import model.AccountProfile;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.sql.* ;

public class AccountProfileDAO extends DBContext {
    PreparedStatement ps = null;
    ResultSet rs = null;

    // READ: lấy thông tin profile theo accountId
    public AccountProfile getProfileByAccountId(int accountId) {
        String sql = "SELECT * FROM AccountProfile WHERE accountId = ?";
        try {
            ps = connection.prepareStatement(sql);
            ps.setInt(1, accountId);
            rs = ps.executeQuery();

            if (rs.next()) {
                AccountProfile profile = new AccountProfile();
                profile.setProfileId(rs.getInt("profileId"));
                profile.setAcoountId(rs.getInt("accountId"));
                profile.setAddress(rs.getString("address"));

                if (rs.getDate("dateOfBirth") != null) {
                   Date dob = rs.getDate("dateOfBirth");
if (dob != null) {
    profile.setDateOfBirth(dob.toLocalDate());
}
                }

                profile.setAvatarUrl(rs.getString("avatarUrl"));
                profile.setNationalId(rs.getString("nationalId"));
                profile.setVerified(rs.getBoolean("verified"));
                profile.setExtraData(rs.getString("extraData"));

                return profile;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); if (ps != null) ps.close(); } catch (Exception ignored) {}
        }
        return null;
    }

    // UPDATE: cập nhật thông tin profile
    public boolean updateProfile(AccountProfile profile) {
        String sql = "UPDATE AccountProfile SET address = ?, dateOfBirth = ?, avatarUrl = ?, " +
                     "nationalId = ?, verified = ?, extraData = ? WHERE accountId = ?";
        try {
            ps = connection.prepareStatement(sql);
            ps.setString(1, profile.getAddress());
            
            if (profile.getDateOfBirth() != null) {
                ps.setDate(2, java.sql.Date.valueOf(profile.getDateOfBirth()));
            } else {
                ps.setNull(2, java.sql.Types.DATE);
            }
            
            ps.setString(3, profile.getAvatarUrl());
            ps.setString(4, profile.getNationalId());
            ps.setBoolean(5, profile.isVerified());
            ps.setString(6, profile.getExtraData());
            ps.setInt(7, profile.getAcoountId());

            return ps.executeUpdate() > 0; // nếu có dòng bị ảnh hưởng → update thành công
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try { if (ps != null) ps.close(); } catch (Exception ignored) {}
        }
        return false;
    }
    public static void main(String[] args) {
    AccountProfileDAO dao = new AccountProfileDAO();

    int testAccountId = 2; // thay bằng accountId bạn muốn test
    AccountProfile profile = dao.getProfileByAccountId(testAccountId);

    if (profile != null) {
        System.out.println("Thông tin Profile cho accountId = " + testAccountId);
        System.out.println("Profile ID: " + profile.getProfileId());
        System.out.println("Account ID: " + profile.getAcoountId());
        System.out.println("Address: " + profile.getAddress());
        System.out.println("Date of Birth: " + profile.getDateOfBirth());
        System.out.println("Avatar URL: " + profile.getAvatarUrl());
        System.out.println("National ID: " + profile.getNationalId());
        System.out.println("Verified: " + profile.isVerified());
        System.out.println("Extra Data: " + profile.getExtraData());
    } else {
        System.out.println("Không tìm thấy profile với accountId = " + testAccountId);
    }
}
}