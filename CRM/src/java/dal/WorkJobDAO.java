package dal;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import dal.MyDAO;

public class WorkJobDAO extends MyDAO {

    /**
     * Lấy taskId tương ứng với requestId trong bảng WorkTask.
     * 
     * @param requestId ID của yêu cầu dịch vụ (ServiceRequest)
     * @return taskId nếu tồn tại, -1 nếu không tìm thấy
     * @throws SQLException nếu có lỗi khi truy vấn database
     */
    public int getTaskIdByRequestId(int requestId) throws SQLException {
        String sql = "SELECT taskId FROM WorkTask WHERE requestId = ?";
        try (
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, requestId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("taskId");
                }
            }
        }
        return -1; // không tìm thấy task tương ứng
    }
}