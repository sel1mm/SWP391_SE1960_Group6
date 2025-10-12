<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <title>Bảng Điều Khiển</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        html, body {
            height: 100%;
            margin: 0;
            background-color: #f4f4f4;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        .sidebar {
            background-color: #111;
            color: #fff;
            min-height: 100vh;
        }

        .sidebar h4 {
            font-weight: 600;
            letter-spacing: 0.5px;
        }

        .sidebar .nav-link {
            color: #ccc;
            padding: 10px 15px;
            border-radius: 6px;
            margin-bottom: 5px;
            transition: all 0.3s ease;
        }

        .sidebar .nav-link:hover,
        .sidebar .nav-link.fw-bold {
            background-color: #fff;
            color: #000;
            font-weight: 600;
        }

        .main-content {
            background-color: #fff;
            min-height: 100vh;
            padding: 2rem;
        }

        .card-hover {
            border: none;
            border-radius: 10px;
            transition: 0.3s ease;
            box-shadow: 0 0.125rem 0.25rem rgba(0,0,0,0.1);
        }

        .card-hover:hover {
            transform: translateY(-3px);
            box-shadow: 0 0.5rem 1rem rgba(0,0,0,0.15);
        }

        .btn-outline-dark:hover {
            background-color: #000;
            color: #fff;
        }

        .card-icon {
            font-size: 2rem;
            margin-bottom: 10px;
        }

        .card h5 {
            font-weight: 600;
        }

        .card p {
            color: #666;
            margin: 0;
        }
    </style>
</head>
<body>
<div class="container-fluid">
    <div class="row">
        <!-- Sidebar -->
        <div class="col-md-2 sidebar p-4">
            <h4 class="text-center mb-4"><i class="fas fa-cogs"></i> Quản lý</h4>
            <nav class="nav flex-column">
                <c:if test="${sessionScope.session_role eq 'admin' || sessionScope.session_role eq 'Customer Support Staff'}">
                    <a class="nav-link ${currentPage eq 'dashboard' ? 'fw-bold bg-white text-dark' : ''}" href="dashboard.jsp">
                        <i class="fas fa-tachometer-alt me-2"></i> Trang chủ
                    </a>
                </c:if>
                <c:if test="${sessionScope.session_role eq 'admin' || sessionScope.session_role eq 'Customer Support Staff'}">
                    <a class="nav-link ${currentPage eq 'users' ? 'fw-bold bg-white text-dark' : ''}" href="customerManagement">
                        <i class="fas fa-users me-2"></i> Quản lý người dùng
                    </a>
                </c:if>
            </nav>
        </div>

        <div class="col-md-10 main-content">
            <!-- Header -->
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h2><i class="fas fa-tachometer-alt text-dark"></i> Bảng Điều Khiển</h2>
                <div class="d-flex align-items-center">
                    <span class="me-3">Xin chào, <strong>${sessionScope.session_login.username}</strong></span>
                    <button class="btn btn-outline-dark" onclick="logout()">
                        <i class="fas fa-sign-out-alt"></i> Đăng Xuất
                    </button>
                </div>
            </div>

            <!-- Dashboard Content -->
            <div class="card p-4 mb-4 shadow-sm rounded">
                <h4><i class="fas fa-home text-dark"></i> Trang chủ quản lý</h4>
                <p class="text-muted">Chào mừng bạn đến với hệ thống quản lý CRMS. Hãy chọn một chức năng từ thanh bên trái để bắt đầu.</p>

                <div class="row mt-4">
                    <c:if test="${sessionScope.session_role eq 'Admin' || sessionScope.session_role eq 'Customer Support Staff'}">
                        <div class="col-md-4 mb-4">
                            <a href="customerManagement" class="text-decoration-none text-dark">
                                <div class="card card-hover text-center p-4">
                                    <i class="fas fa-users card-icon text-dark"></i>
                                    <h5>Người dùng</h5>
                                    <p>Quản lý tài khoản.</p>
                                </div>
                            </a>
                        </div>
                    </c:if>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Scripts -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script>
    function logout() {
        Swal.fire({
            title: 'Đăng xuất?',
            text: 'Bạn có chắc chắn muốn đăng xuất?',
            icon: 'question',
            showCancelButton: true,
            confirmButtonText: 'Đăng xuất',
            cancelButtonText: 'Hủy'
        }).then(result => {
            if (result.isConfirmed) {
                window.location.href = 'logout';
            }
        });
    }
</script>
</body>
</html>
