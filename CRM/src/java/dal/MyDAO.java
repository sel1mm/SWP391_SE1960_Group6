package dal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class MyDAO extends DBContext {
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
  public void finalize() {
     // Note: Connection should be managed by connection pool or DBContext
     // This finalize is kept for backward compatibility but may not be needed
     try {
        // Don't close connection here as it may be shared or managed by pool
        // if(con != null && !con.isClosed()) con.close();
     }
     catch(Exception e) {
        e.printStackTrace();
     }
  }
    
}
