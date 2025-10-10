package dal;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

public class DBContext {

    public Connection connection;

    public DBContext() {
        try {
            String username = "root";
            String password = "sa123456";
            String url = "jdbc:mysql://localhost:3306/crm_system?useSSL=false&allowPublicKeyRetrieval=true&useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC";
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, username, password);
        } catch (ClassNotFoundException | SQLException ex) {
            Logger.getLogger(DBContext.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
    public static void main(String[] args) throws ClassNotFoundException {
         String username = "root";
            String password = "sa123456";
            String url = "jdbc:mysql://localhost:3306/crm_system?useSSL=false&allowPublicKeyRetrieval=true&useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC";
            Class.forName("com.mysql.cj.jdbc.Driver");

        try {
            Connection conn = DriverManager.getConnection(url, username, password);
            if (conn != null) {
                System.out.println("✅ Kết nối thành công!");
            }
        } catch (Exception e) {
            System.out.println("❌ Kết nối thất bại: " + e.getMessage());
        }
    }

}



