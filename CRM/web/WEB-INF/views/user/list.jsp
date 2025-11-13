<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Bảng Điều Khiển Quản Trị</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
        <style>
            .card-hover:hover {
                transform: translateY(-5px);
                transition: transform 0.3s ease;
            }
            .card-hover {
                transition: transform 0.3s ease;
            }
        </style>
    </head>
    <body>
        <div class="container-fluid">
            <div class="row">
                <!-- Sidebar -->
                <div class="col-md-2 min-vh-100 d-flex flex-column justify-content-between" style="background-color: #000000;">
                    <!-- Top of sidebar -->
                    <div class="p-3">
                        <h4 class="text-white">Hệ Thống CRM</h4>
                        <ul class="nav flex-column">
                            <li class="nav-item">
                                <a class="nav-link text-white" href="${pageContext.request.contextPath}/home.jsp">
                                    <i class="fas fa-home"></i> Trang chủ
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link text-white active" href="${pageContext.request.contextPath}/admin.jsp">
                                    <i class="fas fa-tachometer-alt"></i> Bảng Điều Khiển Admin
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

                    <!-- Logout button at bottom -->
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
                            <h2><i class="fas fa-tachometer-alt"></i> Bảng Điều Khiển Admin</h2>
                            <div class="text-muted">
                                <i class="fas fa-user-shield"></i> Khu vực quản trị
                            </div>
                        </div>

                        <!-- Welcome Message -->
                        <div class="alert alert-info">
                            <h5><i class="fas fa-info-circle"></i> Chào mừng đến Bảng Điều Khiển Quản Trị</h5>
                            <p class="mb-0">Quản lý người dùng, vai trò và các thiết lập hệ thống tại đây.</p>
                        </div>

                        <!-- Management Cards -->
                        <div class="row">
                            <!-- User Management -->
                            <div class="col-md-6 mb-4">
                                <div class="card card-hover h-100">
                                    <div class="card-body text-center">
                                        <i class="fas fa-users fa-3x text-primary mb-3"></i>
                                        <h4 class="card-title">Quản Lý Người Dùng</h4>
                                        <p class="card-text">Tạo mới, chỉnh sửa và quản lý tài khoản người dùng. Phân quyền và vai trò.</p>
                                        <div class="d-grid gap-2">
                                            <a href="${pageContext.request.contextPath}/user/list" class="btn btn-primary">
                                                <i class="fas fa-users"></i> Danh Sách Người Dùng
                                            </a>
                                            <a href="${pageContext.request.contextPath}/user/create" class="btn btn-outline-primary">
                                                <i class="fas fa-user-plus"></i> Thêm Người Dùng
                                            </a>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Role Management -->
                            <div class="col-md-6 mb-4">
                                <div class="card card-hover h-100">
                                    <div class="card-body text-center">
                                        <i class="fas fa-user-tag fa-3x text-success mb-3"></i>
                                        <h4 class="card-title">Quản Lý Vai Trò</h4>
                                        <p class="card-text">Tạo và quản lý vai trò. Định nghĩa quyền truy cập cho từng loại người dùng.</p>
                                        <div class="d-grid gap-2">
                                            <a href="${pageContext.request.contextPath}/role/list" class="btn btn-success">
                                                <i class="fas fa-user-tag"></i> Danh Sách Vai Trò
                                            </a>
                                            <a href="${pageContext.request.contextPath}/role/create" class="btn btn-outline-success">
                                                <i class="fas fa-plus"></i> Thêm Vai Trò
                                            </a>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Quick Stats -->
                        <div class="row">
                            <div class="col-md-12">
                                <div class="card">
                                    <div class="card-header">
                                        <h5><i class="fas fa-chart-bar"></i> Thống Kê Nhanh</h5>
                                    </div>
                                    <div class="card-body">
                                        <div class="row text-center">
                                            <div class="col-md-3">
                                                <div class="p-3">
                                                    <i class="fas fa-users fa-2x text-primary mb-2"></i>
                                                    <h4 class="text-primary">Người dùng</h4>
                                                    <p class="text-muted">Tổng số người dùng</p>
                                                </div>
                                            </div>
                                            <div class="col-md-3">
                                                <div class="p-3">
                                                    <i class="fas fa-user-tag fa-2x text-success mb-2"></i>
                                                    <h4 class="text-success">Vai trò</h4>
                                                    <p class="text-muted">Tổng số vai trò</p>
                                                </div>
                                            </div>
                                            <div class="col-md-3">
                                                <div class="p-3">
                                                    <i class="fas fa-user-check fa-2x text-info mb-2"></i>
                                                    <h4 class="text-info">Hoạt động</h4>
                                                    <p class="text-muted">Tài khoản đang hoạt động</p>
                                                </div>
                                            </div>
                                            <div class="col-md-3">
                                                <div class="p-3">
                                                    <i class="fas fa-user-times fa-2x text-warning mb-2"></i>
                                                    <h4 class="text-warning">Không hoạt động</h4>
                                                    <p class="text-muted">Tài khoản bị vô hiệu hóa</p>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- System Information -->
                        <div class="row mt-4">
                            <div class="col-md-12">
                                <div class="card">
                                    <div class="card-header">
                                        <h5><i class="fas fa-cog"></i> Thông Tin Hệ Thống</h5>
                                    </div>
                                    <div class="card-body">
                                        <div class="row">
                                            <div class="col-md-6">
                                                <h6>Chức năng khả dụng:</h6>
                                                <ul class="list-unstyled">
                                                    <li><i class="fas fa-check text-success"></i> CRUD người dùng</li>
                                                    <li><i class="fas fa-check text-success"></i> Quản lý vai trò</li>
                                                    <li><i class="fas fa-check text-success"></i> Gán vai trò cho người dùng</li>
                                                    <li><i class="fas fa-check text-success"></i> Quản lý mật khẩu</li>
                                                    <li><i class="fas fa-check text-success"></i> Kiểm soát trạng thái tài khoản</li>
                                                </ul>
                                            </div>
                                            <div class="col-md-6">
                                                <h6>Tính năng bảo mật:</h6>
                                                <ul class="list-unstyled">
                                                    <li><i class="fas fa-shield-alt text-primary"></i> Mã hoá mật khẩu</li>
                                                    <li><i class="fas fa-lock text-primary"></i> Phân quyền theo vai trò</li>
                                                    <li><i class="fas fa-user-shield text-primary"></i> Quyền quản trị viên</li>
                                                    <li><i class="fas fa-key text-primary"></i> Xác thực an toàn</li>
                                                </ul>
                                            </div>
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
