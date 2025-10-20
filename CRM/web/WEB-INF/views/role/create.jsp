<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create Role</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
</head>
<body>
    <div class="container-fluid">
        <div class="row">
            <!-- Sidebar -->
            <div class="col-md-2 bg-dark min-vh-100">
                <div class="p-3">
                    <h4 class="text-white">CRM System</h4>
                    <ul class="nav flex-column">
                        <li class="nav-item">
                            <a class="nav-link text-white" href="${pageContext.request.contextPath}/home.jsp">
                                <i class="fas fa-home"></i> Home
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link text-white" href="${pageContext.request.contextPath}/user/list">
                                <i class="fas fa-users"></i> Users
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link text-white active" href="${pageContext.request.contextPath}/role/list">
                                <i class="fas fa-user-tag"></i> Roles
                            </a>
                        </li>
                    </ul>
                </div>
            </div>

            <!-- Main Content -->
            <div class="col-md-10">
                <div class="p-4">
                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <h2><i class="fas fa-user-tag"></i> Create New Role</h2>
                        <a href="${pageContext.request.contextPath}/role/list" class="btn btn-secondary">
                            <i class="fas fa-arrow-left"></i> Back to List
                        </a>
                    </div>

                    <!-- Error Message -->
                    <c:if test="${not empty error}">
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            ${error}
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                    </c:if>

                    <!-- Create Role Form -->
                    <div class="card">
                        <div class="card-body">
                            <form action="${pageContext.request.contextPath}/role/create" method="POST">
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="mb-3">
                                            <label for="roleName" class="form-label">Role Name <span class="text-danger">*</span></label>
                                            <input type="text" class="form-control" id="roleName" name="roleName" 
                                                   value="${role.roleName}" required>
                                            <div class="form-text">Enter a unique name for the role (e.g., Admin, Customer, Technician)</div>
                                        </div>
                                    </div>
                                </div>

                                <div class="d-flex justify-content-end gap-2">
                                    <a href="${pageContext.request.contextPath}/role/list" class="btn btn-secondary">
                                        <i class="fas fa-times"></i> Cancel
                                    </a>
                                    <button type="submit" class="btn btn-primary">
                                        <i class="fas fa-save"></i> Create Role
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>

                    <!-- Common Roles Info -->
                    <div class="card mt-4">
                        <div class="card-header">
                            <h5><i class="fas fa-info-circle"></i> Common Role Examples</h5>
                        </div>
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-3">
                                    <div class="p-3 border rounded">
                                        <h6 class="text-primary">Admin</h6>
                                        <p class="small text-muted mb-0">Full system access and management</p>
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <div class="p-3 border rounded">
                                        <h6 class="text-success">Customer</h6>
                                        <p class="small text-muted mb-0">Basic user with limited access</p>
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <div class="p-3 border rounded">
                                        <h6 class="text-warning">Technician</h6>
                                        <p class="small text-muted mb-0">Technical support and maintenance</p>
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <div class="p-3 border rounded">
                                        <h6 class="text-info">Manager</h6>
                                        <p class="small text-muted mb-0">Team and project management</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
