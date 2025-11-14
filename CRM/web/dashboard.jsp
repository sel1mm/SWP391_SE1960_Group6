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
                min-height: 100vh;
                background-color: #111;
                color: #fff;
                display: flex;
                flex-direction: column;
                justify-content: space-between;
                padding-bottom: 20px;
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

            .logout-section .btn-outline-light {
                border: 1px solid rgba(255,255,255,0.4);
                color: #fff;
                font-weight: 500;
                transition: all 0.3s ease;
            }

            .logout-section .btn-outline-light:hover {
                background-color: #fff;
                color: #000;
                border-color: #fff;
            }

            /* ===== STATISTICS CARDS ===== */
            .stats-container {
                display: grid;
                grid-template-columns: repeat(4, 1fr);
                gap: 20px;
                margin-bottom: 30px;
            }

            .stat-card {
                background: linear-gradient(135deg, var(--card-gradient-start), var(--card-gradient-end));
                border-radius: 12px;
                padding: 25px;
                color: white;
                box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
                transition: all 0.3s ease;
                position: relative;
                overflow: hidden;
                cursor: pointer;
                user-select: none;
                text-decoration: none;
            }

            .stat-card:hover {
                transform: translateY(-5px);
                box-shadow: 0 8px 16px rgba(0, 0, 0, 0.2);
                color: white;
            }

            .stat-card:active {
                transform: translateY(-2px);
                box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
            }

            .stat-card::before {
                content: '';
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                bottom: 0;
                background: rgba(255, 255, 255, 0.1);
                opacity: 0;
                transition: opacity 0.3s ease;
            }

            .stat-card:hover::before {
                opacity: 1;
            }

            .stat-card.blue {
                --card-gradient-start: #2196F3;
                --card-gradient-end: #1976D2;
            }

            .stat-card.orange {
                --card-gradient-start: #FF9800;
                --card-gradient-end: #F57C00;
            }

            .stat-card.cyan {
                --card-gradient-start: #00BCD4;
                --card-gradient-end: #0097A7;
            }

            .stat-card.green {
                --card-gradient-start: #4CAF50;
                --card-gradient-end: #388E3C;
            }

            .stat-card .stat-icon {
                position: absolute;
                right: 25px;
                top: 50%;
                transform: translateY(-50%);
                font-size: 60px;
                opacity: 0.3;
            }

            .stat-card .stat-label {
                font-size: 14px;
                font-weight: 500;
                opacity: 0.95;
                margin-bottom: 8px;
                text-transform: uppercase;
                letter-spacing: 0.5px;
            }

            .stat-card .stat-value {
                font-size: 42px;
                font-weight: bold;
                margin: 0;
                line-height: 1;
            }

            .stat-card .stat-subtext {
                font-size: 12px;
                opacity: 0.85;
                margin-top: 8px;
            }

            /* Tooltip hint on hover */
            .stat-card:hover::after {
                content: 'Click để xem chi tiết';
                position: absolute;
                bottom: 10px;
                left: 50%;
                transform: translateX(-50%);
                background: rgba(0, 0, 0, 0.7);
                padding: 6px 12px;
                border-radius: 4px;
                font-size: 11px;
                white-space: nowrap;
                z-index: 10;
            }

            @media (max-width: 1200px) {
                .stats-container {
                    grid-template-columns: repeat(2, 1fr);
                }
            }

            @media (max-width: 576px) {
                .stats-container {
                    grid-template-columns: 1fr;
                }
            }

        </style>
    </head>
    <body>
        <div class="container-fluid">
            <div class="row">
                <!-- Sidebar -->
                <div class="col-md-2 sidebar p-4 d-flex flex-column">
                    <div>
                        <h4 class="text-center mb-4">
                            <i class="fas fa-cogs"></i> CRM CSS
                        </h4>
                        <nav class="nav flex-column">
                            <c:if test="${sessionScope.session_role eq 'Admin' || sessionScope.session_role eq 'Customer Support Staff'}">
                                <a class="nav-link ${currentPage eq 'dashboard' ? 'fw-bold bg-white text-dark' : ''}" href="dashboard">
                                    <i class="fas fa-palette me-2"></i> Trang chủ
                                </a>
                            </c:if>

                            <c:if test="${sessionScope.session_role eq 'Customer Support Staff'}">
                                <a class="nav-link ${currentPage eq 'users' ? 'fw-bold bg-white text-dark' : ''}" href="customerManagement">
                                    <i class="fas fa-users me-2"></i> Quản lý khách hàng
                                </a>
                            </c:if>
                            
                            <c:if test="${sessionScope.session_role eq 'Customer Support Staff'}">
                                <a class="nav-link ${currentPage eq 'users' ? 'fw-bold bg-white text-dark' : ''}" href="viewCustomerContracts">
                                    <i class="fas fa-file-contract me-2"></i> Quản lý hợp đồng
                                </a>
                            </c:if>

                            <c:if test="${sessionScope.session_role eq 'Customer Support Staff'}">
                                <a class="nav-link ${currentPage eq 'users' ? 'fw-bold bg-white text-dark' : ''}" href="viewCustomerRequest">
                                    <i class="fas fa-clipboard-list"></i> Quản lý yêu cầu
                                </a>
                            </c:if>

                            <c:if test="${sessionScope.session_role eq 'Customer Support Staff'}">
                                <a  href="manageProfile" class="nav-link ${currentPage eq 'profile' ? 'fw-bold bg-white text-dark' : ''}">
                                    <i class="fas fa-user-circle me-2"></i><span> Hồ Sơ</span>
                                </a>
                            </c:if>
                        </nav>
                    </div>

                    <div class="mt-auto logout-section text-center">
                        <hr style="border-color: rgba(255,255,255,0.2);">
                        <button class="btn btn-outline-light w-100" onclick="logout()" style="border-radius: 10px;">
                            <i class="fas fa-sign-out-alt me-2"></i> Đăng xuất
                        </button>
                    </div>
                </div>

                <div class="col-md-10 main-content">
                    <!-- Header -->
                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <h2><i class="fas fa-tachometer-alt text-dark"></i> Bảng Điều Khiển</h2>
                        <div class="d-flex align-items-center">
                            <span class="me-3">Xin chào, <strong>${sessionScope.session_login.username}</strong></span>
                        </div>
                    </div>

                    <!-- ===== STATISTICS CARDS ===== -->
                    <div class="stats-container">
                        <!-- Tổng Tài Khoản -->
                        <a href="customerManagement" class="stat-card blue">
                            <div class="stat-icon">
                                <i class="fas fa-users"></i>
                            </div>
                            <div class="stat-label">Tổng Tài Khoản</div>
                            <h2 class="stat-value">${totalAccounts}</h2>
                            <div class="stat-subtext">Khách hàng trong hệ thống</div>
                        </a>

                        <!-- Đơn Chờ Xử Lý -->
                        <a href="viewCustomerRequest?action=search&status=Pending" class="stat-card orange">
                            <div class="stat-icon">
                                <i class="fas fa-clock"></i>
                            </div>
                            <div class="stat-label">Chờ Xử Lý</div>
                            <h2 class="stat-value">${pendingRequests}</h2>
                            <div class="stat-subtext">Yêu cầu đang chờ duyệt</div>
                        </a>

                        <!-- Tổng Hợp Đồng -->
                        <a href="viewCustomerContracts" class="stat-card cyan">
                            <div class="stat-icon">
                                <i class="fas fa-file-contract"></i>
                            </div>
                            <div class="stat-label">Tổng Hợp Đồng</div>
                            <h2 class="stat-value">${totalContracts}</h2>
                            <div class="stat-subtext">Hợp đồng trong hệ thống</div>
                        </a>

                        <!-- Khách Hàng Top -->
                        <a href="viewCustomerContracts?action=search&keyword=${topCustomer.fullName}" class="stat-card green">
                            <div class="stat-icon">
                                <i class="fas fa-crown"></i>
                            </div>
                            <div class="stat-label">Khách Hàng Top</div>
                            <h2 class="stat-value">${topCustomer.contractCount}</h2>
                            <div class="stat-subtext">
                                <i class="fas fa-user"></i> ${topCustomer.fullName}
                            </div>
                        </a>
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
                                            <h5>Tài khoản</h5>
                                            <p>Quản lý tài khoản khách hàng.</p>
                                        </div>
                                    </a>
                                </div>
                                <div class="col-md-4 mb-4">
                                    <a href="viewCustomerRequest" class="text-decoration-none text-dark">
                                        <div class="card card-hover text-center p-4">
                                            <i class="fas fa-clipboard-list card-icon text-dark"></i>
                                            <h5>Yêu cầu</h5>
                                            <p>Quản lý yêu cầu khách hàng.</p>
                                        </div>
                                    </a>
                                </div>
                                <div class="col-md-4 mb-4">
                                    <a href="viewCustomerContracts" class="text-decoration-none text-dark">
                                        <div class="card card-hover text-center p-4">
                                            <i class="fas fa-file-contract me-2 card-icon text-dark"></i>
                                            <h5>Hợp đồng</h5>
                                            <p>Quản lý hợp đồng khách hàng.</p>
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