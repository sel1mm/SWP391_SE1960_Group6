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
}
