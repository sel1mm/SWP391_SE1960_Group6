<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Bảng Điều Khiển - CRM System</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
        <style>
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }

            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                background-color: #f8f9fa;
                overflow-x: hidden;
            }

            /* SIDEBAR STYLES */
            .sidebar {
                position: fixed;
                top: 0;
                left: 0;
                height: 100vh;
                width: 260px;
                background: #000000;
                padding: 0;
                transition: all 0.3s ease;
                z-index: 1000;
                box-shadow: 4px 0 10px rgba(0,0,0,0.1);
                display: flex;
                flex-direction: column;
            }

            .sidebar.collapsed {
                width: 70px;
            }

            .sidebar-header {
                padding: 25px 20px;
                background: rgba(0,0,0,0.2);
                border-bottom: 1px solid rgba(255,255,255,0.1);
            }

            .sidebar-brand {
                display: flex;
                align-items: center;
                gap: 12px;
                color: white;
                text-decoration: none;
                font-size: 1.4rem;
                font-weight: 700;
                transition: all 0.3s;
            }

            .sidebar-brand i {
                font-size: 2rem;
                color: #ffc107;
            }

            .sidebar.collapsed .sidebar-brand span {
                display: none;
            }

            .sidebar-menu {
                flex: 1;
                padding: 20px 0;
                overflow-y: auto;
                overflow-x: hidden;
            }

            .sidebar-menu::-webkit-scrollbar {
                width: 6px;
            }

            .sidebar-menu::-webkit-scrollbar-thumb {
                background: rgba(255,255,255,0.2);
                border-radius: 10px;
            }

            .menu-section {
                margin-bottom: 20px;
            }

            .menu-section-title {
                padding: 8px 20px;
                color: rgba(255,255,255,0.5);
                font-size: 0.75rem;
                font-weight: 600;
                text-transform: uppercase;
                letter-spacing: 1px;
                transition: all 0.3s;
            }

            .sidebar.collapsed .menu-section-title {
                opacity: 0;
                height: 0;
                padding: 0;
            }

            .menu-item {
                display: flex;
                align-items: center;
                padding: 14px 20px;
                color: rgba(255,255,255,0.8);
                text-decoration: none;
                transition: all 0.3s;
                position: relative;
                margin: 2px 10px;
                border-radius: 8px;
            }

            .menu-item:hover {
                background: rgba(255,255,255,0.1);
                color: white;
                transform: translateX(5px);
            }

            .menu-item.active {
                background: rgba(255,255,255,0.15);
                color: white;
                border-left: 4px solid #ffc107;
            }

            .menu-item i {
                font-size: 1.2rem;
                width: 30px;
                text-align: center;
            }

            .menu-item span {
                margin-left: 12px;
                font-size: 0.95rem;
                transition: all 0.3s;
            }

            .sidebar.collapsed .menu-item span {
                display: none;
            }

            .menu-item .badge {
                margin-left: auto;
                font-size: 0.7rem;
            }

            .sidebar.collapsed .menu-item .badge {
                display: none;
            }

            /* SIDEBAR FOOTER */
            .sidebar-footer {
                padding: 20px;
                border-top: 1px solid rgba(255,255,255,0.1);
                background: rgba(0,0,0,0.2);
            }

            .user-info {
                display: flex;
                align-items: center;
                gap: 12px;
                color: white;
                margin-bottom: 15px;
                padding: 10px;
                background: rgba(255,255,255,0.1);
                border-radius: 8px;
                transition: all 0.3s;
            }

            .user-avatar {
                width: 40px;
                height: 40px;
                border-radius: 50%;
                background: linear-gradient(135deg, #ffc107, #ff9800);
                display: flex;
                align-items: center;
                justify-content: center;
                font-weight: 700;
                font-size: 1.1rem;
                color: white;
            }

            .user-details {
                flex: 1;
                transition: all 0.3s;
            }

            .user-name {
                font-size: 0.9rem;
                font-weight: 600;
                margin-bottom: 2px;
            }

            .user-role {
                font-size: 0.75rem;
                color: rgba(255,255,255,0.6);
            }

            .sidebar.collapsed .user-details {
                display: none;
            }

            .btn-logout {
                width: 100%;
                padding: 12px;
                background: transparent;
                color: white;
                border: 1px solid white;
                border-radius: 8px;
                font-weight: 600;
                display: flex;
                align-items: center;
                justify-content: center;
                gap: 10px;
                transition: all 0.3s;
                cursor: pointer;
                text-decoration: none;
            }

            .btn-logout:hover {
                background: white;
                color: #1a1a2e;
                border-color: white;
            }
            .sidebar.collapsed .btn-logout span {
                display: none;
            }

            /* TOGGLE BUTTON */
            .sidebar-toggle {
                position: absolute;
                top: 25px;
                right: -15px;
                width: 30px;
                height: 30px;
                background: white;
                border: 2px solid #1e3c72;
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                cursor: pointer;
                color: #1e3c72;
                transition: all 0.3s;
                box-shadow: 0 2px 8px rgba(0,0,0,0.15);
            }

            .sidebar-toggle:hover {
                transform: scale(1.1);
                background: #1e3c72;
                color: white;
            }

            /* MAIN CONTENT */
            .main-content {
                margin-left: 260px;
                transition: all 0.3s ease;
                min-height: 100vh;
            }

            .sidebar.collapsed ~ .main-content {
                margin-left: 70px;
            }

            .top-navbar {
                background: white;
                padding: 20px 30px;
                box-shadow: 0 2px 4px rgba(0,0,0,0.1);
                display: flex;
                justify-content: space-between;
                align-items: center;
            }

            .page-title {
                font-size: 1.5rem;
                font-weight: 700;
                color: #1e3c72;
                margin: 0;
            }

            .content-wrapper {
                padding: 30px;
            }

            /* WELCOME SECTION */
            .welcome-card {
                background: white;
                border-radius: 10px;
                padding: 30px;
                margin-bottom: 30px;
                box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            }

            .welcome-card h4 {
                color: #1e3c72;
                font-weight: 600;
                margin-bottom: 15px;
            }

            .welcome-card p {
                color: #666;
                line-height: 1.6;
                margin: 0;
            }

            /* DASHBOARD CARDS */
            .dashboard-cards {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
                gap: 20px;
                margin-top: 20px;
            }

            .dashboard-card {
                background: white;
                border-radius: 10px;
                padding: 30px;
                text-align: center;
                box-shadow: 0 2px 8px rgba(0,0,0,0.1);
                transition: all 0.3s;
                cursor: pointer;
                text-decoration: none;
                color: inherit;
                display: block;
            }

            .dashboard-card:hover {
                transform: translateY(-5px);
                box-shadow: 0 4px 16px rgba(0,0,0,0.15);
            }

            .card-icon {
                font-size: 3rem;
                margin-bottom: 20px;
                color: #1e3c72;
            }

            .card-title {
                font-size: 1.25rem;
                font-weight: 600;
                color: #333;
                margin-bottom: 10px;
            }

            .card-description {
                color: #666;
                font-size: 0.95rem;
                line-height: 1.5;
            }

            /* SCROLL TO TOP */
            .scroll-to-top {
                position: fixed;
                bottom: 30px;
                right: 30px;
                width: 45px;
                height: 45px;
                background: #ffc107;
                color: #1e3c72;
                border-radius: 50%;
                display: none;
                align-items: center;
                justify-content: center;
                cursor: pointer;
                transition: all 0.3s;
                z-index: 999;
                box-shadow: 0 4px 12px rgba(255, 193, 7, 0.3);
            }

            .scroll-to-top:hover {
                background: #ffb300;
                transform: translateY(-5px);
            }

            .scroll-to-top.show {
                display: flex;
            }

            /* RESPONSIVE */
            @media (max-width: 768px) {
                .sidebar {
                    transform: translateX(-100%);
                }

                .sidebar.show {
                    transform: translateX(0);
                }

                .main-content {
                    margin-left: 0;
                }

                .sidebar.collapsed ~ .main-content {
                    margin-left: 0;
                }

                .dashboard-cards {
                    grid-template-columns: 1fr;
                }
            }
        </style>
    </head>
    <body>
        <!-- SIDEBAR -->
        <div class="sidebar" id="sidebar">
            <div class="sidebar-toggle" onclick="toggleSidebar()">
                <i class="fas fa-chevron-left" id="toggleIcon"></i>
            </div>

            <div class="sidebar-header">
                <a href="#" class="sidebar-brand">
                    <i></i>
                    <span>CRM System</span>
                </a>
            </div>

            <div class="sidebar-menu">
                <div class="menu-section">

                    <a href="${pageContext.request.contextPath}/dashboard" class="menu-item active">
                        <i class="fas fa-home"></i>
                        <span>Dashboard</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/managerServiceRequest" class="menu-item">
                        <i class="fas fa-clipboard-list"></i>
                        <span>Yêu Cầu Dịch Vụ</span>
                        <span class="badge bg-warning">${pendingCount}</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/viewcontracts" class="menu-item">
                        <i class="fas fa-file-contract"></i>
                        <span>Hợp Đồng</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/equipment" class="menu-item">
                        <i class="fas fa-tools"></i>
                        <span>Thiết Bị</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/invoices" class="menu-item">
                        <i class="fas fa-file-invoice-dollar"></i>
                        <span>Hóa Đơn</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/manageProfile" class="menu-item">
                        <i class="fas fa-user-circle"></i>
                        <span>Hồ Sơ</span>
                    </a> 
                </div>                      
            </div>

            <div class="sidebar-footer">
                <div class="user-info">
                    <div class="user-avatar">
                        <c:choose>
                            <c:when test="${not empty sessionScope.session_login.fullName}">
                                ${sessionScope.session_login.fullName.substring(0,1).toUpperCase()}
                            </c:when>
                            <c:when test="${not empty sessionScope.session_login.username}">
                                ${sessionScope.session_login.username.substring(0,1).toUpperCase()}
                            </c:when>
                            <c:otherwise>
                                U
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="user-details">
                        <div class="user-name">
                            <c:choose>
                                <c:when test="${not empty sessionScope.session_login.fullName}">
                                    ${sessionScope.session_login.fullName}
                                </c:when>
                                <c:when test="${not empty sessionScope.session_login.username}">
                                    ${sessionScope.session_login.username}
                                </c:when>
                                <c:otherwise>
                                    User
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <div class="user-role">
                            <c:choose>
                                <c:when test="${not empty sessionScope.session_role}">
                                    ${sessionScope.session_role}
                                </c:when>
                                <c:otherwise>
                                    Manager
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
                <a href="${pageContext.request.contextPath}/logout" class="btn-logout" style="text-decoration: none;">
                    <i class="fas fa-sign-out-alt"></i>
                    <span>Đăng Xuất</span>
                </a>
            </div>
        </div>

        <!-- MAIN CONTENT -->
        <div class="main-content">
            <div class="top-navbar">
                <h1 class="page-title"><i class="fas fa-tachometer-alt"></i> Bảng Điều Khiển</h1>
                <div>
                    <span class="text-muted">Xin chào, </span>
                    <strong>
                        <c:choose>
                            <c:when test="${not empty sessionScope.session_login.username}">
                                ${sessionScope.session_login.username}
                            </c:when>
                            <c:otherwise>
                                User
                            </c:otherwise>
                        </c:choose>
                    </strong>
                </div>
            </div>

            <div class="content-wrapper">
                <!-- WELCOME CARD -->
                <div class="welcome-card">
                    <h4><i class="fas fa-home"></i> Trang chủ quản lý</h4>
                    <p>Chào mừng bạn đến với hệ thống quản lý CRMS. Hãy chọn một chức năng từ thanh bên trái để bắt đầu.</p>
                </div>

                <!-- DASHBOARD CARDS -->
                <div class="dashboard-cards">
                    <!-- Yêu Cầu Dịch Vụ -->
                    <a href="${pageContext.request.contextPath}/managerServiceRequest" class="dashboard-card">
                        <div class="card-icon">
                            <i class="fas fa-clipboard-list"></i>
                        </div>
                        <div class="card-title">Yêu cầu</div>
                        <div class="card-description">Quản lý yêu cầu dịch vụ khách hàng.</div>
                    </a>

                    <!-- Hợp Đồng -->
                    <a href="${pageContext.request.contextPath}/managerContracts" class="dashboard-card">
                        <div class="card-icon">
                            <i class="fas fa-file-contract"></i>
                        </div>
                        <div class="card-title">Hợp đồng</div>
                        <div class="card-description">Quản lý hợp đồng khách hàng.</div>
                    </a>

                    <!-- Thiết Bị -->
                    <a href="${pageContext.request.contextPath}/equipment" class="dashboard-card">
                        <div class="card-icon">
                            <i class="fas fa-tools"></i>
                        </div>
                        <div class="card-title">Thiết bị</div>
                        <div class="card-description">Quản lý thiết bị khách hàng.</div>
                    </a>
                    <!-- Hóa Đơn -->
                    <a href="${pageContext.request.contextPath}/invoices" class="dashboard-card">
                        <div class="card-icon">
                            <i class="fas fa-receipt"></i>

                        </div>
                        <div class="card-title">Hóa Đơn</div>
                        <div class="card-description">Quản lý hóa đơn.</div>
                    </a>
                </div>
            </div>

            <!-- Scroll to Top -->
            <div class="scroll-to-top" id="scrollToTop" onclick="scrollToTop()">
                <i class="fas fa-arrow-up"></i>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <script>
                // Toggle Sidebar
                function toggleSidebar() {
                    const sidebar = document.getElementById('sidebar');
                    const toggleIcon = document.getElementById('toggleIcon');
                    sidebar.classList.toggle('collapsed');

                    if (sidebar.classList.contains('collapsed')) {
                        toggleIcon.classList.remove('fa-chevron-left');
                        toggleIcon.classList.add('fa-chevron-right');
                    } else {
                        toggleIcon.classList.remove('fa-chevron-right');
                        toggleIcon.classList.add('fa-chevron-left');
                    }
                }

                // Scroll to Top
                function scrollToTop() {
                    window.scrollTo({
                        top: 0,
                        behavior: 'smooth'
                    });
                }

                // Show/Hide Scroll Button
                window.addEventListener('scroll', function () {
                    const scrollBtn = document.getElementById('scrollToTop');
                    if (window.pageYOffset > 300) {
                        scrollBtn.classList.add('show');
                    } else {
                        scrollBtn.classList.remove('show');
                    }
                });

                // Confirm Logout
                function confirmLogout(event) {
                    event.preventDefault();
                    Swal.fire({
                        title: 'Đăng xuất?',
                        text: 'Bạn có chắc chắn muốn đăng xuất?',
                        icon: 'question',
                        showCancelButton: true,
                        confirmButtonText: 'Đăng xuất',
                        cancelButtonText: 'Hủy',
                        confirmButtonColor: '#dc3545',
                        cancelButtonColor: '#6c757d'
                    }).then((result) => {
                        if (result.isConfirmed) {
                            window.location.href = '${pageContext.request.contextPath}/logout';
                        }
                    });
                    return false;
                }
        </script>
    </body>
</html>
