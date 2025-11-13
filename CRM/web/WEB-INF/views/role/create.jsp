<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tạo Vai Trò</title>
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
                        <h2><i class="fas fa-user-tag"></i> Tạo Vai Trò Mới</h2>
                        <a href="${pageContext.request.contextPath}/role/list" class="btn btn-secondary">
                            <i class="fas fa-arrow-left"></i> Quay Lại Danh Sách
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
                                            <label for="roleName" class="form-label">Tên Vai Trò <span class="text-danger">*</span></label>
                                            <input type="text" class="form-control" id="roleName" name="roleName" 
                                                   value="${role.roleName}" required>
                                            <div class="form-text">Nhập tên duy nhất cho vai trò (ví dụ: Quản Trị Viên, Khách Hàng, Kỹ Thuật Viên)</div>
                                        </div>
                                    </div>
                                </div>

                                <div class="d-flex justify-content-end gap-2">
                                    <a href="${pageContext.request.contextPath}/role/list" class="btn btn-secondary">
                                        <i class="fas fa-times"></i> Hủy
                                    </a>
                                    <button type="submit" class="btn btn-primary">
                                        <i class="fas fa-save"></i> Tạo Vai Trò
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>

                    <!-- Common Roles Info -->
                    <div class="card mt-4">
                        <div class="card-header">
                            <h5><i class="fas fa-info-circle"></i> Ví Dụ Vai Trò Phổ Biến</h5>
                        </div>
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-3">
                                    <div class="p-3 border rounded">
                                        <h6 class="text-primary">Quản Trị Viên</h6>
                                        <p class="small text-muted mb-0">Toàn quyền truy cập và quản lý hệ thống</p>
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <div class="p-3 border rounded">
                                        <h6 class="text-success">Khách Hàng</h6>
                                        <p class="small text-muted mb-0">Người dùng cơ bản với quyền hạn chế</p>
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <div class="p-3 border rounded">
                                        <h6 class="text-warning">Kỹ Thuật Viên</h6>
                                        <p class="small text-muted mb-0">Hỗ trợ kỹ thuật và bảo trì</p>
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <div class="p-3 border rounded">
                                        <h6 class="text-info">Quản Lý</h6>
                                        <p class="small text-muted mb-0">Quản lý nhóm và dự án</p>
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