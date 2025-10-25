<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Manage User Roles</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    </head>
    <body>
        <div class="container-fluid">
            <div class="row">
                <!-- Sidebar -->
                <div class="col-md-2 min-vh-100 d-flex flex-column justify-content-between" style="background-color: #000000;">
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
                            <h2><i class="fas fa-user-tag"></i> Manage User Roles</h2>
                            <a href="${pageContext.request.contextPath}/user/edit?id=${user.accountId}" class="btn btn-secondary">
                                <i class="fas fa-arrow-left"></i> Back to User
                            </a>
                        </div>

                        <!-- Messages -->
                        <c:if test="${not empty message}">
                            <div class="alert alert-success alert-dismissible fade show" role="alert">
                                ${message}
                                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                            </div>
                        </c:if>

                        <c:if test="${not empty error}">
                            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                ${error}
                                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                            </div>
                        </c:if>

                        <c:if test="${not empty user}">
                            <!-- User Info -->
                            <div class="card mb-4">
                                <div class="card-body">
                                    <h5><i class="fas fa-user"></i> User Information</h5>
                                    <div class="row">
                                        <div class="col-md-3">
                                            <strong>Username:</strong> ${user.username}
                                        </div>
                                        <div class="col-md-3">
                                            <strong>Full Name:</strong> ${user.fullName}
                                        </div>
                                        <div class="col-md-3">
                                            <strong>Email:</strong> ${user.email}
                                        </div>
                                        <div class="col-md-3">
                                            <strong>Status:</strong> 
                                            <c:choose>
                                                <c:when test="${user.status == 'Active'}">
                                                    <span class="badge bg-success">Active</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-secondary">Inactive</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Current Roles -->
                            <div class="card mb-4">
                                <div class="card-header">
                                    <h5><i class="fas fa-check-circle"></i> Current Roles</h5>
                                </div>
                                <div class="card-body">
                                    <c:choose>
                                        <c:when test="${not empty userRoles}">
                                            <div class="row">
                                                <c:forEach var="userRole" items="${userRoles}">
                                                    <c:forEach var="role" items="${roles}">
                                                        <c:if test="${userRole.roleId == role.roleId}">
                                                            <div class="col-md-3 mb-2">
                                                                <div class="d-flex justify-content-between align-items-center p-2 border rounded">
                                                                    <span class="badge bg-primary">${role.roleName}</span>
                                                                    <form action="${pageContext.request.contextPath}/user/removeRole" method="POST" 
                                                                          style="display: inline;" onsubmit="return confirm('Remove this role?')">
                                                                        <input type="hidden" name="userId" value="${user.accountId}">
                                                                        <input type="hidden" name="roleId" value="${role.roleId}">
                                                                        <button type="submit" class="btn btn-sm btn-outline-danger">
                                                                            <i class="fas fa-times"></i>
                                                                        </button>
                                                                    </form>
                                                                </div>
                                                            </div>
                                                        </c:if>
                                                    </c:forEach>
                                                </c:forEach>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="text-center py-3">
                                                <i class="fas fa-user-tag fa-2x text-muted mb-2"></i>
                                                <p class="text-muted">No roles assigned</p>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>

                            <!-- Available Roles -->
                            <div class="card">
                                <div class="card-header">
                                    <h5><i class="fas fa-plus-circle"></i> Available Roles</h5>
                                </div>
                                <div class="card-body">
                                    <c:choose>
                                        <c:when test="${not empty roles}">
                                            <div class="row">
                                                <c:forEach var="role" items="${roles}">
                                                    <c:set var="hasRole" value="false" />
                                                    <c:forEach var="userRole" items="${userRoles}">
                                                        <c:if test="${userRole.roleId == role.roleId}">
                                                            <c:set var="hasRole" value="true" />
                                                        </c:if>
                                                    </c:forEach>

                                                    <c:if test="${!hasRole}">
                                                        <div class="col-md-3 mb-2">
                                                            <div class="d-flex justify-content-between align-items-center p-2 border rounded">
                                                                <span class="text-muted">${role.roleName}</span>
                                                                <form action="${pageContext.request.contextPath}/user/assignRole" method="POST" 
                                                                      style="display: inline;">
                                                                    <input type="hidden" name="userId" value="${user.accountId}">
                                                                    <input type="hidden" name="roleId" value="${role.roleId}">
                                                                    <button type="submit" class="btn btn-sm btn-outline-success">
                                                                        <i class="fas fa-plus"></i> Assign
                                                                    </button>
                                                                </form>
                                                            </div>
                                                        </div>
                                                    </c:if>
                                                </c:forEach>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="text-center py-3">
                                                <i class="fas fa-exclamation-triangle fa-2x text-muted mb-2"></i>
                                                <p class="text-muted">No roles available</p>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </c:if>
                    </div>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
