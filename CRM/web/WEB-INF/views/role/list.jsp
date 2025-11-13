<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản Lý Vai Trò</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .table th {
            background-color: #f8f9fa;
        }
    </style>
</head>
<body>
    <div class="container-fluid">
        <div class="row">
           <!-- Sidebar -->
                <div class="col-md-2 min-vh-100 d-flex flex-column justify-content-between" style="background-color: #000000;">
                    <!-- Phần trên của sidebar -->
                    <div class="p-3">
                        <h4 class="text-white">Hệ Thống CRM</h4>
                        <ul class="nav flex-column">
                            <li class="nav-item">
                                <a class="nav-link text-white" href="${pageContext.request.contextPath}/home.jsp">
                                    <i class="fas fa-home"></i> Trang Chủ
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link text-white active" href="${pageContext.request.contextPath}/admin.jsp">
                                    <i class="fas fa-tachometer-alt"></i> Bảng Điều Khiển
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link text-white" href="${pageContext.request.contextPath}/user/list">
                                    <i class="fas fa-users"></i> Người Dùng
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link text-white" href="${pageContext.request.contextPath}/role/list">
                                    <i class="fas fa-user-tag"></i> Vai Trò
                                </a>
                            </li>
                        </ul>
                    </div>

                    <!-- Nút Logout ở dưới cùng -->
                    <div class="p-3 border-top border-secondary">
                        <a href="${pageContext.request.contextPath}/logout"
                           class="btn btn-outline-light w-100 d-flex align-items-center justify-content-center gap-2">
                            <i class="fas fa-sign-out-alt"></i> Đăng Xuất
                        </a>
                    </div>
                </div>

            <!-- Main Content -->
            <div class="col-md-10">
                <div class="p-4">
                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <h2><i class="fas fa-user-tag"></i> Quản Lý Vai Trò</h2>
                        <a href="${pageContext.request.contextPath}/role/create" class="btn btn-primary">
                            <i class="fas fa-plus"></i> Thêm Vai Trò Mới
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

                    <!-- Roles Table -->
                    <div class="card">
                        <div class="card-body">
                            <c:choose>
                                <c:when test="${not empty roles}">
                                    <div class="table-responsive">
                                        <table class="table table-striped table-hover">
                                            <thead>
                                                <tr>
                                                    <th>ID</th>
                                                    <th>Tên Vai Trò</th>
                                                    <th>Thao Tác</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach var="role" items="${roles}">
                                                    <tr>
                                                        <td>${role.roleId}</td>
                                                        <td>
                                                            <span class="badge bg-primary">${role.roleName}</span>
                                                        </td>
                                                        <td>
                                                            <div class="btn-group" role="group">
                                                                <a href="${pageContext.request.contextPath}/role/edit?id=${role.roleId}" 
                                                                   class="btn btn-sm btn-outline-primary" title="Chỉnh sửa">
                                                                    <i class="fas fa-edit"></i>
                                                                </a>
                                                                <a href="${pageContext.request.contextPath}/role/delete?id=${role.roleId}" 
                                                                   class="btn btn-sm btn-outline-danger" 
                                                                   onclick="return confirm('Bạn có chắc chắn muốn xóa vai trò này?')" 
                                                                   title="Xóa">
                                                                    <i class="fas fa-trash"></i>
                                                                </a>
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
                                        <i class="fas fa-user-tag fa-3x text-muted mb-3"></i>
                                        <h5 class="text-muted">Không tìm thấy vai trò</h5>
                                        <p class="text-muted">Bắt đầu bằng cách thêm vai trò đầu tiên của bạn.</p>
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