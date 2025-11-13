<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Quản lý người dùng</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
        <style>
            .table th {
                background-color: #f8f9fa;
            }
            .status-badge {
                font-size: 0.8em;
            }
            /* 🎨 Pagination Style */
            .pagination .page-item.active .page-link {
                background-color: #007bff;
                border-color: #007bff;
                color: white;
            }
            .pagination .page-link {
                color: #007bff;
                border-radius: 0.25rem;
                border: 1px solid #dee2e6;
            }
            .pagination .page-link:hover {
                background-color: #e9ecef;
            }
        </style>
    </head>
    <body>
        <div class="container-fluid">
            <div class="row">

                <!-- Sidebar -->
               <div class="col-md-2 min-vh-100 d-flex flex-column justify-content-between" style="background-color: #000000;">
                    <div class="p-3">
                        <h4 class="text-white">CRM System</h4>
                        <ul class="nav flex-column">
                            <li class="nav-item">
                                <a class="nav-link text-white" href="${pageContext.request.contextPath}/home.jsp">
                                    <i class="fas fa-home"></i> Trang Chủ
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link text-white active" href="${pageContext.request.contextPath}/admin.jsp">
                                    <i class="fas fa-tachometer-alt"></i> Admin Dashboard
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link text-white" href="${pageContext.request.contextPath}/user/list">
                                    <i class="fas fa-users"></i> Người dùng
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link text-white" href="${pageContext.request.contextPath}/role/list">
                                    <i class="fas fa-user-tag"></i> Vai trò
                                </a>
                            </li>
                        </ul>
                    </div>

                    <!-- Logout -->
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
                            <h2><i class="fas fa-users"></i> Quản lý người dùng</h2>
                            <a href="${pageContext.request.contextPath}/user/create" class="btn btn-primary">
                                <i class="fas fa-plus"></i> Thêm người dùng
                            </a>
                        </div>

                        <!-- Search Form -->
                        <form class="row mb-3" method="get" action="${pageContext.request.contextPath}/user/list">
                            <div class="col-md-3">
                                <input type="text" class="form-control" name="keyword"
                                       placeholder="Tìm kiếm bằng username, email hoặc full name..."
                                       value="${param.keyword}">
                            </div>
                            <div class="col-md-2">
                                <select name="status" class="form-select">
                                    <option value="">Tất cả trạng thái</option>
                                    <option value="Active" ${param.status == 'Active' ? 'selected' : ''}>Hoạt động</option>
                                    <option value="Inactive" ${param.status == 'Inactive' ? 'selected' : ''}>Không hoạt động</option>
                                </select>
                            </div>
                            <div class="col-md-2">
                                <select name="roleId" class="form-select">
                                    <option value="">Tất cả vai trò</option>
                                    <c:forEach var="role" items="${allRoles}">
                                        <option value="${role.roleId}" ${param.roleId == role.roleId ? 'selected' : ''}>
                                            ${role.roleName}
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div class="col-md-2">
                                <button type="submit" class="btn btn-primary w-100">
                                    <i class="fas fa-search"></i> Tìm kiếm
                                </button>
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

                        <!-- User List -->
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
                                                        <th>Họ và Tên</th>
                                                        <th>Email</th>
                                                        <th>Phone</th>
                                                        <th>Vai trò</th>
                                                        <th>Trạng Thái</th>
                                                        <th>Thao tác</th>
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
                                                                <c:set var="userRoles" value="${userRolesMap[user.accountId]}" />
                                                                <c:choose>
                                                                    <c:when test="${not empty userRoles}">
                                                                        <c:forEach var="role" items="${userRoles}">
                                                                            <span class="badge bg-info text-dark me-1">${role.roleName}</span>
                                                                        </c:forEach>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <span class="text-muted">Không có vai trò</span>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </td>
                                                            <td>
                                                                <c:choose>
                                                                    <c:when test="${user.status == 'Active'}">
                                                                        <span class="badge bg-success status-badge">Hoạt động</span>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <span class="badge bg-secondary status-badge">Không hoạt động</span>
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
                                                                        <c:when test="${user.accountId ne sessionScope.session_login.accountId}">
                                                                            <c:choose>
                                                                                <c:when test="${user.status == 'Active'}">
                                                                                    <a href="${pageContext.request.contextPath}/user/delete?id=${user.accountId}"
                                                                                       class="btn btn-sm btn-outline-danger"
                                                                                       onclick="return confirm('Bạn có chắc chắn muốn ban người dùng này')"
                                                                                       title="Ban User">
                                                                                        <i class="fas fa-user-slash"></i>
                                                                                    </a>
                                                                                </c:when>
                                                                                <c:otherwise>
                                                                                    <a href="${pageContext.request.contextPath}/user/delete?id=${user.accountId}"
                                                                                       class="btn btn-sm btn-outline-success"
                                                                                       onclick="return confirm('Bạn có chắc chắn muốn unban người dùng này?')"
                                                                                       title="Unban User">
                                                                                        <i class="fas fa-user-check"></i>
                                                                                    </a>
                                                                                </c:otherwise>
                                                                            </c:choose>
                                                                        </c:when>
                                                                    </c:choose>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    </c:forEach>
                                                </tbody>
                                            </table>
                                        </div>

                                        <!-- Pagination (VN style) -->
                                        <c:if test="${totalPages > 1}">
                                            <nav aria-label="User pagination">
                                                <ul class="pagination justify-content-center mt-4">
                                                    <!-- Trước -->
                                                    <c:choose>
                                                        <c:when test="${currentPage > 1}">
                                                            <li class="page-item">
                                                                <a class="page-link"
                                                                   href="?page=${currentPage - 1}&keyword=${param.keyword}&status=${param.status}&roleId=${param.roleId}">
                                                                    &lsaquo; Trước</a>
                                                            </li>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <li class="page-item disabled">
                                                                <span class="page-link">&lsaquo; Trước</span>
                                                            </li>
                                                        </c:otherwise>
                                                    </c:choose>

                                                    <!-- Số trang -->
                                                    <c:forEach var="i" begin="1" end="${totalPages}">
                                                        <li class="page-item ${i == currentPage ? 'active' : ''}">
                                                            <a class="page-link"
                                                               href="?page=${i}&keyword=${param.keyword}&status=${param.status}&roleId=${param.roleId}">
                                                                ${i}</a>
                                                        </li>
                                                    </c:forEach>

                                                    <!-- Tiếp -->
                                                    <c:choose>
                                                        <c:when test="${currentPage < totalPages}">
                                                            <li class="page-item">
                                                                <a class="page-link"
                                                                   href="?page=${currentPage + 1}&keyword=${param.keyword}&status=${param.status}&roleId=${param.roleId}">
                                                                    Tiếp &rsaquo;</a>
                                                            </li>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <li class="page-item disabled">
                                                                <span class="page-link">Tiếp &rsaquo;</span>
                                                            </li>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </ul>
                                            </nav>
                                        </c:if>

                                    </c:when>
                                    <c:otherwise>
                                        <div class="text-center py-5">
                                            <i class="fas fa-users fa-3x text-muted mb-3"></i>
                                            <h5 class="text-muted">Không tìm thấy người dùng</h5>
                                            <p class="text-muted">Bắt đầu bằng cách thêm người dùng mới.</p>
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
