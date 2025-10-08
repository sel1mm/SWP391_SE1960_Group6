package model;
import java.time.LocalDate;

public class AccountProfile {
    private int profileId;
    private int acoountId;
    private String address;
    private LocalDate dateOfBirth;
    private String avatarUrl;
    private String nationalId;
    private boolean verified = false;
    private String extraData;

    public AccountProfile() {
    }

    public AccountProfile(int profileId, int acoountId, String address, LocalDate dateOfBirth, String avatarUrl, String nationalId, String extraData) {
        this.profileId = profileId;
        this.acoountId = acoountId;
        this.address = address;
        this.dateOfBirth = dateOfBirth;
        this.avatarUrl = avatarUrl;
        this.nationalId = nationalId;
        this.extraData = extraData;
    }

    public int getProfileId() {
        return profileId;
    }

    public void setProfileId(int profileId) {
        this.profileId = profileId;
    }

    public int getAcoountId() {
        return acoountId;
    }

    public void setAcoountId(int acoountId) {
        this.acoountId = acoountId;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public LocalDate getDateOfBirth() {
        return dateOfBirth;
    }

    public void setDateOfBirth(LocalDate dateOfBirth) {
        this.dateOfBirth = dateOfBirth;
    }

    public String getAvatarUrl() {
        return avatarUrl;
    }

    public void setAvatarUrl(String avatarUrl) {
        this.avatarUrl = avatarUrl;
    }

    public String getNationalId() {
        return nationalId;
    }

    public void setNationalId(String nationalId) {
        this.nationalId = nationalId;
    }

    public boolean isVerified() {
        return verified;
    }

    public void setVerified(boolean verified) {
        this.verified = verified;
    }

    public String getExtraData() {
        return extraData;
    }

    public void setExtraData(String extraData) {
        this.extraData = extraData;
    }

    @Override
    public String toString() {
        return "AccountProfile{" + "profileId=" + profileId + ", acoountId=" + acoountId + ", address=" + address + ", dateOfBirth=" + dateOfBirth + ", avatarUrl=" + avatarUrl + ", nationalId=" + nationalId + ", verified=" + verified + ", extraData=" + extraData + '}';
    }
    
    
}
