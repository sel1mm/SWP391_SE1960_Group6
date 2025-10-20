<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Management</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .table th {
            background-color: #f8f9fa;
        }
        .status-badge {
            font-size: 0.8em;
        }
    </style>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">

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
                        <h2><i class="fas fa-users"></i> User Management</h2>
                        
                        <a href="${pageContext.request.contextPath}/user/create" class="btn btn-primary">
                            <i class="fas fa-plus"></i> Add New User
                        </a>
                    </div>
<form class="row mb-3" method="get" action="${pageContext.request.contextPath}/user/list">
    <div class="col-md-4">
        <input type="text" class="form-control" name="keyword" 
               placeholder="Search by username, email or full name..." 
               value="${param.keyword}">
    </div>
    <div class="col-md-3">
        <select name="status" class="form-select">
            <option value="">All Status</option>
            <option value="Active" ${param.status == 'Active' ? 'selected' : ''}>Active</option>
            <option value="Inactive" ${param.status == 'Inactive' ? 'selected' : ''}>Inactive</option>
        </select>
    </div>
    <div class="col-md-2">
        <button type="submit" class="btn btn-primary w-100"><i class="fas fa-search"></i> Search</button>
    </div>
    <div class="col-md-2">
        <a href="${pageContext.request.contextPath}/user/list" class="btn btn-secondary w-100">
            <i class="fas fa-undo"></i> Reset
        </a>
    </div>
</form>

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

                    <!-- Users Table -->
                    <div class="card">
                        <div class="card-body">
                            <c:choose>
                                <c:when test="${not empty users}">
                                    <div class="table-responsive">
                                        <table class="table table-striped table-hover">
                                            <thead>
                                                <tr>
                                                    <th>ID</th>
                                                    <th>Username</th>
                                                    <th>Full Name</th>
                                                    <th>Email</th>
                                                    <th>Phone</th>
                                                    <th>Status</th>
                                                    <th>Actions</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach var="user" items="${users}">
                                                    <tr>
                                                        <td>${user.accountId}</td>
                                                        <td>${user.username}</td>
                                                        <td>${user.fullName}</td>
                                                        <td>${user.email}</td>
                                                        <td>${user.phone}</td>
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${user.status == 'Active'}">
                                                                    <span class="badge bg-success status-badge">Active</span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="badge bg-secondary status-badge">Inactive</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </td>
                                     
                                                        <td>
                                                            <div class="btn-group" role="group">
                                                                <a href="${pageContext.request.contextPath}/user/edit?id=${user.accountId}" 
                                                                   class="btn btn-sm btn-outline-primary" title="Edit">
                                                                    <i class="fas fa-edit"></i>
                                                                </a>
                                                                <a href="${pageContext.request.contextPath}/user/roles?id=${user.accountId}" 
                                                                   class="btn btn-sm btn-outline-info" title="Manage Roles">
                                                                    <i class="fas fa-user-tag"></i>
                                                                </a>

    <c:choose>
    <c:when test="${user.status == 'Active'}">
        <!-- Hiển thị nút Ban -->
        <a href="${pageContext.request.contextPath}/user/delete?id=${user.accountId}" 
           class="btn btn-sm btn-outline-danger" 
           onclick="return confirm('Are you sure you want to ban this user?')" 
           title="Ban User">
            <i class="fas fa-user-slash"></i>
        </a>
    </c:when>
    <c:otherwise>
        <!-- Hiển thị nút Unban -->
        <a href="${pageContext.request.contextPath}/user/delete?id=${user.accountId}" 
           class="btn btn-sm btn-outline-success" 
           onclick="return confirm('Are you sure you want to unban this user?')" 
           title="Unban User">
            <i class="fas fa-user-check"></i>
        </a>
    </c:otherwise>
</c:choose>


                                                            </div>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </tbody>
                                        </table>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="text-center py-5">
                                        <i class="fas fa-users fa-3x text-muted mb-3"></i>
                                        <h5 class="text-muted">No users found</h5>
                                        <p class="text-muted">Start by adding your first user.</p>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
