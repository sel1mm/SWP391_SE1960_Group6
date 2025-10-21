<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Create User</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    </head>
    <body>
        <div class="container-fluid">
            <div class="row">
                <!-- Sidebar -->
                <div class="col-md-2 bg-dark min-vh-100 d-flex flex-column justify-content-between">
                    <!-- Phần trên của sidebar -->
                    <div class="p-3">
                        <h4 class="text-white">CRM System</h4>
                        <ul class="nav flex-column">
                            <li class="nav-item">
                                <a class="nav-link text-white" href="${pageContext.request.contextPath}/home.jsp">
                                    <i class="fas fa-home"></i> Home
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link text-white active" href="${pageContext.request.contextPath}/admin.jsp">
                                    <i class="fas fa-tachometer-alt"></i> Admin Dashboard
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link text-white" href="${pageContext.request.contextPath}/user/list">
                                    <i class="fas fa-users"></i> Users
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link text-white" href="${pageContext.request.contextPath}/role/list">
                                    <i class="fas fa-user-tag"></i> Roles
                                </a>
                            </li>
                        </ul>
                    </div>

                    <!-- Nút Logout ở dưới cùng -->
                    <div class="p-3 border-top border-secondary">
                        <a href="${pageContext.request.contextPath}/logout"
                           class="btn btn-outline-light w-100 d-flex align-items-center justify-content-center gap-2">
                            <i class="fas fa-sign-out-alt"></i> Đăng xuất
                        </a>
                    </div>
                </div>

                <!-- Main Content -->
                <div class="col-md-10">
                    <div class="p-4">
                        <div class="d-flex justify-content-between align-items-center mb-4">
                            <h2><i class="fas fa-user-plus"></i> Create New User</h2>
                            <a href="${pageContext.request.contextPath}/user/list" class="btn btn-secondary">
                                <i class="fas fa-arrow-left"></i> Back to List
                            </a>
                        </div>

                        <!-- Error Message -->
                        <c:if test="${not empty error}">
                            <div class="alert alert-danger alert-dismissible fade show mt-3" role="alert">
                                <i class="fas fa-exclamation-circle"></i> ${error}
                                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                            </div>
                        </c:if>

                        <!-- Success Message -->
                        <c:if test="${not empty param.message}">
                            <div class="alert alert-success alert-dismissible fade show mt-3" role="alert">
                                <i class="fas fa-check-circle"></i> ${param.message}
                                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                            </div>
                        </c:if>

                        <!-- Create User Form -->
                        <div class="card">
                            <div class="card-body">
                                <form action="${pageContext.request.contextPath}/user/create" method="POST">
                                    <div class="row">
                                        <div class="col-md-6">
                                            <div class="mb-3">
                                                <label for="username" class="form-label">Username <span class="text-danger">*</span></label>
                                                <input type="text" class="form-control" id="username" name="username" 
                                                       value="${user.username}" required>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="mb-3">
                                                <label for="password" class="form-label">Password <span class="text-danger">*</span></label>
                                                <input type="password" class="form-control" id="password" name="password" required>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="row">
                                        <div class="col-md-6">
                                            <div class="mb-3">
                                                <label for="fullName" class="form-label">Full Name</label>
                                                <input type="text" class="form-control" id="fullName" name="fullName" 
                                                       value="${user.fullName}">
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="mb-3">
                                                <label for="email" class="form-label">Email <span class="text-danger">*</span></label>
                                                <input type="email" class="form-control" id="email" name="email" 
                                                       value="${user.email}" required>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="row">
                                        <div class="col-md-6">
                                            <div class="mb-3">
                                                <label for="phone" class="form-label">Phone</label>
                                                <input type="tel" class="form-control" id="phone" name="phone" 
                                                       value="${user.phone}">
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="mb-3">
                                                <label for="status" class="form-label">Status</label>
                                                <select class="form-select" id="status" name="status">
                                                    <option value="Active" ${user.status == 'Active' ? 'selected' : ''}>Active</option>
                                                    <option value="Inactive" ${user.status == 'Inactive' ? 'selected' : ''}>Inactive</option>
                                                </select>
                                            </div>
                                        </div>
                                    </div>

                                    <c:if test="${not empty roles}">
                                        <div class="mb-3">
                                            <label class="form-label">Roles</label>
                                            <div class="row">
                                                <c:forEach var="role" items="${roles}">
                                                    <div class="col-md-4">
                                                        <div class="form-check">
                                                            <input class="form-check-input" type="checkbox" 
                                                                   name="roleIds" value="${role.roleId}" 
                                                                   id="role_${role.roleId}">
                                                            <label class="form-check-label" for="role_${role.roleId}">
                                                                ${role.roleName}
                                                            </label>
                                                        </div>
                                                    </div>
                                                </c:forEach>
                                            </div>
                                        </div>
                                    </c:if>

                                    <div class="d-flex justify-content-end gap-2">
                                        <a href="${pageContext.request.contextPath}/user/list" class="btn btn-secondary">
                                            <i class="fas fa-times"></i> Cancel
                                        </a>
                                        <button type="submit" class="btn btn-primary">
                                            <i class="fas fa-save"></i> Create User
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
