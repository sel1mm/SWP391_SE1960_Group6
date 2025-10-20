package controller;

import constant.MessageConstant;
import dto.Response;
import model.Role;
import service.RoleService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "RoleController", urlPatterns = {"/role/*"})
public class RoleController extends HttpServlet {

    private RoleService roleService;

    @Override
    public void init() throws ServletException {
        super.init();
        roleService = new RoleService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getPathInfo();
        
        if (action == null) {
            action = "/list";
        }

        switch (action) {
            case "/list":
                listRoles(request, response);
                break;
            case "/create":
                showCreateForm(request, response);
                break;
            case "/edit":
                showEditForm(request, response);
                break;
            case "/delete":
                deleteRole(request, response);
                break;
            default:
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getPathInfo();
        
        if (action == null) {
            action = "/create";
        }

        switch (action) {
            case "/create":
                createRole(request, response);
                break;
            case "/update":
                updateRole(request, response);
                break;
            default:
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    private void listRoles(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Response<List<Role>> result = roleService.getAllRoles();
        
        if (result.isSuccess()) {
            request.setAttribute("roles", result.getData());
            request.setAttribute("message", result.getMessage());
        } else {
            request.setAttribute("error", result.getMessage());
        }
        
        request.getRequestDispatcher("/WEB-INF/views/role/list.jsp").forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/role/create.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Role ID is required");
            return;
        }

        try {
            int roleId = Integer.parseInt(idParam);
            Response<Role> result = roleService.getRoleById(roleId);
            
            if (result.isSuccess() && result.getData() != null) {
                request.setAttribute("role", result.getData());
                request.getRequestDispatcher("/WEB-INF/views/role/edit.jsp").forward(request, response);
            } else {
                request.setAttribute("error", "Role not found");
                request.getRequestDispatcher("/WEB-INF/views/role/list.jsp").forward(request, response);
            }
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid role ID");
        }
    }

    private void createRole(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String roleName = request.getParameter("roleName");

        Role role = new Role();
        role.setRoleName(roleName);

        Response<Role> result = roleService.createRole(role);
        
        if (result.isSuccess()) {
            response.sendRedirect(request.getContextPath() + "/role/list?message=" + 
                java.net.URLEncoder.encode("Role created successfully", "UTF-8"));
        } else {
            request.setAttribute("error", result.getMessage());
            request.setAttribute("role", role);
            request.getRequestDispatcher("/WEB-INF/views/role/create.jsp").forward(request, response);
        }
    }

    private void updateRole(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Role ID is required");
            return;
        }

        try {
            int roleId = Integer.parseInt(idParam);
            String roleName = request.getParameter("roleName");

            Role role = new Role();
            role.setRoleId(roleId);
            role.setRoleName(roleName);

            Response<Role> result = roleService.updateRole(role);
            
            if (result.isSuccess()) {
                response.sendRedirect(request.getContextPath() + "/role/list?message=" + 
                    java.net.URLEncoder.encode("Role updated successfully", "UTF-8"));
            } else {
                request.setAttribute("error", result.getMessage());
                request.setAttribute("role", role);
                request.getRequestDispatcher("/WEB-INF/views/role/edit.jsp").forward(request, response);
            }
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid role ID");
        }
    }

    private void deleteRole(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Role ID is required");
            return;
        }

        try {
            int roleId = Integer.parseInt(idParam);
            Response<Boolean> result = roleService.deleteRole(roleId);
            
            if (result.isSuccess()) {
                response.sendRedirect(request.getContextPath() + "/role/list?message=" + 
                    java.net.URLEncoder.encode("Role deleted successfully", "UTF-8"));
            } else {
                response.sendRedirect(request.getContextPath() + "/role/list?error=" + 
                    java.net.URLEncoder.encode(result.getMessage(), "UTF-8"));
            }
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid role ID");
        }
    }
}
