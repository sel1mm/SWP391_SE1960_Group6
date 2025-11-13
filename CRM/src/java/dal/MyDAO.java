package dal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class MyDAO extends DBContext implements AutoCloseable {
  // Deprecated: Use 'connection' from DBContext instead
  // Kept for backward compatibility but should not be used directly
  @Deprecated
  public Connection con = null;
  // Deprecated: Use try-with-resources instead
  @Deprecated
  public PreparedStatement ps = null;
  // Deprecated: Use try-with-resources instead
  @Deprecated
  public ResultSet rs = null;
  public String xSql = null;

  public MyDAO() {
     // Synchronize con with connection for backward compatibility
     con = connection;
  }
  @Override
  public void close() {
     closeQuietly(rs);
     closeQuietly(ps);
     if (connection != null) {
        try {
           connection.close();
        } catch (SQLException ex) {
           ex.printStackTrace();
        } finally {
           connection = null;
           con = null;
        }
     }
  }

  private void closeQuietly(AutoCloseable    resource) {
     if (resource != null) {
        try {
           resource.close();
        } catch (Exception ex) {
           ex.printStackTrace();
        }
     }
  }
}
