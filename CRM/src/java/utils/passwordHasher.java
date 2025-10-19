package utils;

import org.mindrot.jbcrypt.BCrypt;

public class passwordHasher {
    // Mã hóa password
    public static String hashPassword(String password){
        return BCrypt.hashpw(password, BCrypt.gensalt(12));
    }
    
    // Giải mã password và so sánh với password mà user đã nhập vào
    public static boolean checkPassword(String password, String hashedPassword){
        return BCrypt.checkpw(password, hashedPassword);
    }
      public static void main(String[] args) {
        String originalPassword = "1@Choigamenhuhack.";

        // Hash mật khẩu lần đầu (giống lúc lưu vào DB)
        String hashedPassword = hashPassword(originalPassword);
        System.out.println("Hashed password: " + hashedPassword);

        // Test kiểm tra
        boolean match1 = checkPassword("1@Choigamenhuhack.", "$2a$12$/EBvaV2Yx3HLbxL642jaEuYKh3KY7PYf7pZ8KOze.B7ZDX16Ky0Ba");
        boolean match2 = checkPassword("abcdef", hashedPassword);

        System.out.println("Check correct password: " + match1); // ✅ true
        System.out.println("Check wrong password: " + match2);   // ❌ false
    }

}
