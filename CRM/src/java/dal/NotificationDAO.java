package dal;

import java.sql.SQLException;
import java.sql.Types;
import model.Notification;

public class NotificationDAO extends MyDAO {

    /**
     * Insert a notification record. createdAt defaults to CURRENT_TIMESTAMP in DB.
     * @return number of affected rows (1 on success)
     */
    public int createNotification(Notification notification) {
        xSql = "INSERT INTO Notification (accountId, notificationType, contractEquipmentId, message, status) "
             + "VALUES (?, ?, ?, ?, ?)";
        try {
            ps = con.prepareStatement(xSql);
            ps.setInt(1, notification.getAccountId());
            ps.setString(2, notification.getNotificationType());

            int ceId = notification.getContractEquipmentId();
            if (ceId > 0) {
                ps.setInt(3, ceId);
            } else {
                ps.setNull(3, Types.INTEGER);
            }

            ps.setString(4, notification.getMessage());
            ps.setString(5, notification.getStatus());

            return ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        } finally {
            closeResources();
        }
    }

    private void closeResources() {
        try {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}