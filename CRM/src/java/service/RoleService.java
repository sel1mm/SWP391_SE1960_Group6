package service;

import constant.MessageConstant;
import dal.RoleDAO;
import dto.Response;
import model.Role;
import java.util.List;

public class RoleService {
    private final RoleDAO roleDAO;
    
    public RoleService() {
        roleDAO = new RoleDAO();
    }
    
    public Response<List<Role>> getAllRoles() {
        return roleDAO.getAllRoles();
    }
    
    public Response<Role> getRoleById(int roleId) {
        return roleDAO.getRoleById(roleId);
    }
    
    public Response<Role> getRoleByName(String roleName) {
        return roleDAO.getRoleByName(roleName);
    }
    
    public Response<Role> createRole(Role role) {
        // Validate role name
        if (role.getRoleName() == null || role.getRoleName().trim().isEmpty()) {
            return new Response<>(null, false, "Role name cannot be empty");
        }
        
        // Check if role name already exists
        Response<Role> existingRole = roleDAO.getRoleByName(role.getRoleName().trim());
        if (existingRole.isSuccess() && existingRole.getData() != null) {
            return new Response<>(null, false, "Role name already exists");
        }
        
        role.setRoleName(role.getRoleName().trim());
        return roleDAO.createRole(role);
    }
    
    public Response<Role> updateRole(Role role) {
        // Validate role name
        if (role.getRoleName() == null || role.getRoleName().trim().isEmpty()) {
            return new Response<>(null, false, "Role name cannot be empty");
        }
        
        // Check if role exists
        Response<Role> existingRole = roleDAO.getRoleById(role.getRoleId());
        if (!existingRole.isSuccess() || existingRole.getData() == null) {
            return new Response<>(null, false, "Role not found");
        }
        
        // Check if new role name already exists (excluding current role)
        Response<Role> duplicateRole = roleDAO.getRoleByName(role.getRoleName().trim());
        if (duplicateRole.isSuccess() && duplicateRole.getData() != null 
            && duplicateRole.getData().getRoleId() != role.getRoleId()) {
            return new Response<>(null, false, "Role name already exists");
        }
        
        role.setRoleName(role.getRoleName().trim());
        return roleDAO.updateRole(role);
    }
    
    public Response<Boolean> deleteRole(int roleId) {
        // Check if role exists
        Response<Role> existingRole = roleDAO.getRoleById(roleId);
        if (!existingRole.isSuccess() || existingRole.getData() == null) {
            return new Response<>(false, false, "Role not found");
        }
        
        // Check if role is in use
        Response<Boolean> roleInUse = roleDAO.isRoleInUse(roleId);
        if (roleInUse.isSuccess() && roleInUse.getData()) {
            return new Response<>(false, false, "Cannot delete role that is currently assigned to users");
        }
        
        return roleDAO.deleteRole(roleId);
    }
    
    public Response<Boolean> isRoleInUse(int roleId) {
        return roleDAO.isRoleInUse(roleId);
    }
}
