package dal;

import constant.MessageConstant;
import dto.Response;
import model.Role;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class RoleDAO extends MyDAO {

    public Response<List<Role>> getAllRoles() {
        String sql = "SELECT * FROM Role ORDER BY roleId";
        List<Role> roles = new ArrayList<>();
        try {
            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                Role role = new Role(
                    rs.getInt("roleId"),
                    rs.getString("roleName")
                );
                roles.add(role);
            }
            return new Response<>(roles, true, MessageConstant.MESSAGE_SUCCESS);
        } catch (Exception e) {
            e.printStackTrace();
            return new Response<>(null, false, MessageConstant.MESSAGE_FAILED);
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
    }

    public Response<Role> getRoleById(int roleId) {
        String sql = "SELECT * FROM Role WHERE roleId = ?";
        try {
            ps = con.prepareStatement(sql);
            ps.setInt(1, roleId);
            rs = ps.executeQuery();
            if (rs.next()) {
                Role role = new Role(
                    rs.getInt("roleId"),
                    rs.getString("roleName")
                );
                return new Response<>(role, true, MessageConstant.MESSAGE_SUCCESS);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
        return new Response<>(null, false, MessageConstant.MESSAGE_FAILED);
    }

    public Response<Role> getRoleByName(String roleName) {
        String sql = "SELECT * FROM Role WHERE roleName = ?";
        try {
            ps = con.prepareStatement(sql);
            ps.setString(1, roleName);
            rs = ps.executeQuery();
            if (rs.next()) {
                Role role = new Role(
                    rs.getInt("roleId"),
                    rs.getString("roleName")
                );
                return new Response<>(role, true, MessageConstant.MESSAGE_SUCCESS);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
        return new Response<>(null, false, MessageConstant.MESSAGE_FAILED);
    }

    public Response<Role> createRole(Role role) {
        String sql = "INSERT INTO Role (roleName) VALUES (?)";
        try {
            ps = con.prepareStatement(sql, java.sql.Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, role.getRoleName());
            int affectedRows = ps.executeUpdate();
            
            if (affectedRows > 0) {
                try (java.sql.ResultSet generatedKeys = ps.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        role.setRoleId(generatedKeys.getInt(1));
                        return new Response<>(role, true, "Role created successfully");
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (ps != null) ps.close();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
        return new Response<>(null, false, "Failed to create role");
    }

    public Response<Role> updateRole(Role role) {
        String sql = "UPDATE Role SET roleName = ? WHERE roleId = ?";
        try {
            ps = con.prepareStatement(sql);
            ps.setString(1, role.getRoleName());
            ps.setInt(2, role.getRoleId());
            int affectedRows = ps.executeUpdate();
            
            if (affectedRows > 0) {
                return new Response<>(role, true, "Role updated successfully");
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (ps != null) ps.close();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
        return new Response<>(null, false, "Failed to update role");
    }

    public Response<Boolean> deleteRole(int roleId) {
        String sql = "DELETE FROM Role WHERE roleId = ?";
        try {
            ps = con.prepareStatement(sql);
            ps.setInt(1, roleId);
            int affectedRows = ps.executeUpdate();
            
            if (affectedRows > 0) {
                return new Response<>(true, true, "Role deleted successfully");
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (ps != null) ps.close();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
        return new Response<>(false, false, "Failed to delete role");
    }

    public Response<Boolean> isRoleInUse(int roleId) {
        String sql = "SELECT COUNT(*) as count FROM AccountRole WHERE roleId = ?";
        try {
            ps = con.prepareStatement(sql);
            ps.setInt(1, roleId);
            rs = ps.executeQuery();
            if (rs.next()) {
                int count = rs.getInt("count");
                return new Response<>(count > 0, true, count > 0 ? "Role is in use" : "Role is not in use");
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
        return new Response<>(false, false, "Failed to check role usage");
    }
}
