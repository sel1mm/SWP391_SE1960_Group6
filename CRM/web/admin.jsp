<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Trang Quản Trị CRM</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">

    <style>
        body {
            background-color: #f5f6fa;
        }
        .sidebar {
            background-color: #000;
            min-height: 100vh;
        }
        .sidebar .nav-link {
            padding: 10px 15px;
            font-size: 15px;
        }
        .sidebar .nav-link.active {
            background-color: #0d6efd;
            border-radius: 6px;
        }
        .sidebar .nav-link:hover {
            background-color: #333;
            border-radius: 6px;
        }
        .card-hover {
            transition: 0.3s ease;
        }
        .card-hover:hover {
            transform: translateY(-5px);
            cursor: pointer;
        }
    </style>
</head>

<body>
<div class="container-fluid">
    <div class="row">

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

            <!-- LOGOUT -->
            <div class="p-3 border-top border-secondary">
                <a href="${pageContext.request.contextPath}/logout"
                   class="btn btn-outline-light w-100 d-flex align-items-center justify-content-center gap-2">
                    <i class="fas fa-sign-out-alt"></i> Đăng Xuất
                </a>
            </div>
        </div>

        <!-- MAIN CONTENT -->
        <div class="col-md-10">
            <div class="p-4">

                <!-- HEADER -->
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h2><i class="fas fa-tachometer-alt"></i> Bảng Điều Khiển Quản Trị</h2>
                    <span class="text-muted"><i class="fas fa-user-shield"></i> Trang Quản Trị Viên</span>
                </div>

                <!-- WELCOME MESSAGE -->
                <div class="alert alert-info shadow-sm">
                    <h5><i class="fas fa-info-circle"></i> Chào Mừng!</h5>
                    <p class="mb-0">Tại đây bạn có thể quản lý người dùng, vai trò và cài đặt hệ thống.</p>
                </div>

                <!-- MANAGEMENT CARDS -->
                <div class="row g-4">
                    <!-- User Management -->
                    <div class="col-md-6">
                        <div class="card card-hover h-100 shadow-sm">
                            <div class="card-body text-center">
                                <i class="fas fa-users fa-3x text-primary mb-3"></i>
                                <h4>Quản Lý Người Dùng</h4>
                                <p>Tạo, chỉnh sửa và phân quyền người dùng trong hệ thống.</p>
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
                    <div class="col-md-6">
                        <div class="card card-hover h-100 shadow-sm">
                            <div class="card-body text-center">
                                <i class="fas fa-user-tag fa-3x text-success mb-3"></i>
                                <h4>Quản Lý Vai Trò</h4>
                                <p>Tạo và quản lý vai trò, phân quyền truy cập hệ thống.</p>
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

                <!-- QUICK STATS -->
                <div class="card mt-4 shadow-sm">
                    <div class="card-header">
                        <h5><i class="fas fa-chart-bar"></i> Thống Kê Nhanh</h5>
                    </div>
                    <div class="card-body">
                        <div class="row text-center g-3">

                            <div class="col-6 col-md-3">
                                <i class="fas fa-users fa-2x text-primary mb-2"></i>
                                <h5>Người Dùng</h5>
                                <p class="text-muted">Tổng người dùng</p>
                            </div>

                            <div class="col-6 col-md-3">
                                <i class="fas fa-user-tag fa-2x text-success mb-2"></i>
                                <h5>Vai Trò</h5>
                                <p class="text-muted">Số vai trò</p>
                            </div>

                            <div class="col-6 col-md-3">
                                <i class="fas fa-user-check fa-2x text-info mb-2"></i>
                                <h5>Hoạt Động</h5>
                                <p class="text-muted">Tài khoản Active</p>
                            </div>

                            <div class="col-6 col-md-3">
                                <i class="fas fa-user-times fa-2x text-warning mb-2"></i>
                                <h5>Không Hoạt Động</h5>
                                <p class="text-muted">Tài khoản Inactive</p>
                            </div>

                        </div>
                    </div>
                </div>

                <!-- SYSTEM INFO -->
                <div class="card mt-4 shadow-sm mb-4">
                    <div class="card-header">
                        <h5><i class="fas fa-cog"></i> Thông Tin Hệ Thống</h5>
                    </div>
                    <div class="card-body row">

                        <div class="col-md-6">
                            <h6>Tính Năng:</h6>
                            <ul class="list-unstyled">
                                <li><i class="fas fa-check text-success"></i> CRUD Người Dùng</li>
                                <li><i class="fas fa-check text-success"></i> Quản Lý Vai Trò</li>
                                <li><i class="fas fa-check text-success"></i> Phân Quyền</li>
                                <li><i class="fas fa-check text-success"></i> Cập Nhật Mật Khẩu</li>
                                <li><i class="fas fa-check text-success"></i> Kiểm Soát Trạng Thái</li>
                            </ul>
                        </div>

                        <div class="col-md-6">
                            <h6>Bảo Mật:</h6>
                            <ul class="list-unstyled">
                                <li><i class="fas fa-shield-alt text-primary"></i> Mã Hóa Mật Khẩu</li>
                                <li><i class="fas fa-lock text-primary"></i> Phân Quyền Theo Vai Trò</li>
                                <li><i class="fas fa-user-shield text-primary"></i> Kiểm Soát Quản Trị</li>
                                <li><i class="fas fa-key text-primary"></i> Xác Thực & OTP</li>
                            </ul>
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
