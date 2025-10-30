<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>CRM Dashboard - Quản Lý Thiết Bị</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
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

            .stats-card {
                border-radius: 10px;
                padding: 20px;
                margin-bottom: 20px;
                box-shadow: 0 2px 4px rgba(0,0,0,0.1);
                transition: all 0.3s;
            }

            .stats-card:hover {
                transform: translateY(-5px);
                box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            }

            .stats-card i {
                font-size: 2.5rem;
                opacity: 0.8;
            }

            .table-container {
                background: white;
                border-radius: 10px;
                padding: 25px;
                box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            }

            .badge-active {
                background-color: #198754;
            }

            .badge-repair {
                background-color: #ffc107;
                color: #000;
            }

            .badge-maintenance {
                background-color: #8b5cf6;
            }

            .search-filter-bar {
                background: white;
                padding: 20px;
                border-radius: 10px;
                margin-bottom: 20px;
                box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            }

            .btn-action {
                padding: 5px 10px;
                margin: 0 2px;
            }

            /* TOAST NOTIFICATION */
            #toastContainer {
                position: fixed;
                top: 80px;
                right: 20px;
                z-index: 99999;
                width: 350px;
                max-width: 90vw;
            }

            .toast-notification {
                background: white;
                border-radius: 10px;
                padding: 15px 20px;
                box-shadow: 0 4px 12px rgba(0,0,0,0.15);
                display: flex;
                align-items: center;
                gap: 15px;
                margin-bottom: 10px;
                animation: slideInRight 0.4s ease-out;
            }

            @keyframes slideInRight {
                from {
                    transform: translateX(400px);
                    opacity: 0;
                }
                to {
                    transform: translateX(0);
                    opacity: 1;
                }
            }

            .toast-notification.hiding {
                animation: slideOutRight 0.4s ease-out forwards;
            }

            @keyframes slideOutRight {
                from {
                    transform: translateX(0);
                    opacity: 1;
                }
                to {
                    transform: translateX(400px);
                    opacity: 0;
                }
            }

            .toast-notification.success {
                border-left: 4px solid #198754;
            }

            .toast-notification.error {
                border-left: 4px solid #dc3545;
            }

            .toast-icon {
                font-size: 24px;
                flex-shrink: 0;
            }

            .toast-icon.success {
                color: #198754;
            }

            .toast-icon.error {
                color: #dc3545;
            }

            .toast-content {
                flex: 1;
            }

            .toast-close {
                background: none;
                border: none;
                cursor: pointer;
                color: #999;
                padding: 0;
                font-size: 18px;
                transition: color 0.2s;
            }

            .toast-close:hover {
                color: #333;
            }

            /* FOOTER STYLES */
            .site-footer {
                background: linear-gradient(135deg, #1a202c 0%, #2d3748 100%);
                color: rgba(255, 255, 255, 0.9);
                padding: 50px 0 20px;
                margin-top: 50px;
            }

            .footer-content {
                max-width: 1400px;
                margin: 0 auto;
                padding: 0 30px;
            }

            .footer-grid {
                display: grid;
                grid-template-columns: repeat(4, 1fr);
                gap: 50px;
                margin-bottom: 60px;
            }

            .footer-section h5 {
                color: #fff;
                font-size: 1.1rem;
                font-weight: 600;
                margin-bottom: 20px;
                position: relative;
                padding-bottom: 10px;
            }

            .footer-section h5:after {
                content: '';
                position: absolute;
                left: 0;
                bottom: 0;
                width: 50px;
                height: 2px;
                background: #ffc107;
            }

            .footer-about {
                color: rgba(255, 255, 255, 0.8);
                line-height: 1.8;
                margin-bottom: 15px;
                font-size: 14px;
            }

            .footer-links {
                list-style: none;
                padding: 0;
                margin: 0;
            }

            .footer-links li {
                margin-bottom: 12px;
            }

            .footer-links a {
                color: rgba(255, 255, 255, 0.8);
                text-decoration: none;
                display: flex;
                align-items: center;
                gap: 8px;
                transition: all 0.3s;
                font-size: 0.95rem;
            }

            .footer-links a:hover {
                color: #ffc107;
                transform: translateX(5px);
            }

            .footer-bottom {
                border-top: 1px solid rgba(255, 255, 255, 0.1);
                padding-top: 25px;
                display: flex;
                justify-content: space-between;
                align-items: center;
                flex-wrap: wrap;
                gap: 15px;
            }

            .footer-copyright {
                color: rgba(255, 255, 255, 0.7);
                font-size: 0.9rem;
            }

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

                .footer-grid {
                    grid-template-columns: 1fr;
                    gap: 30px;
                }

                .footer-bottom {
                    flex-direction: column;
                    text-align: center;
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
                    <i class="fas fa-cube"></i>
                    <span>CRM System</span>
                </a>
            </div>

            <div class="sidebar-menu">
                <div class="menu-section">
                    <a href="${pageContext.request.contextPath}/dashboard" class="menu-item">
                        <i class="fas fa-home"></i>
                        <span>Dashboard</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/managerServiceRequest" class="menu-item">
                        <i class="fas fa-clipboard-list"></i>
                        <span>Yêu Cầu Dịch Vụ</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/contracts" class="menu-item">
                        <i class="fas fa-file-contract"></i>
                        <span>Hợp Đồng</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/equipment" class="menu-item active">
                        <i class="fas fa-tools"></i>
                        <span>Thiết Bị</span>
                    </a>
                </div>

                <div class="menu-section">
                    <a href="${pageContext.request.contextPath}/customers" class="menu-item">
                        <i class="fas fa-users"></i>
                        <span>Khách Hàng</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/reports" class="menu-item">
                        <i class="fas fa-chart-bar"></i>
                        <span>Báo Cáo</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/maintenance" class="menu-item">
                        <i class="fas fa-wrench"></i>
                        <span>Bảo Trì</span>
                    </a>
                </div>

                <div class="menu-section">
                    <a href="${pageContext.request.contextPath}/manageProfile" class="menu-item">
                        <i class="fas fa-user-circle"></i>
                        <span>Hồ Sơ</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/settings" class="menu-item">
                        <i class="fas fa-cog"></i>
                        <span>Cài Đặt</span>
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
                            <c:otherwise>U</c:otherwise>
                        </c:choose>
                    </div>
                    <div class="user-details">
                        <div class="user-name">
                            <c:choose>
                                <c:when test="${not empty sessionScope.session_login.fullName}">
                                    ${sessionScope.session_login.fullName}
                                </c:when>
                                <c:otherwise>User</c:otherwise>
                            </c:choose>
                        </div>
                        <div class="user-role">
                            <c:choose>
                                <c:when test="${not empty sessionScope.session_role}">
                                    ${sessionScope.session_role}
                                </c:when>
                                <c:otherwise>Customer</c:otherwise>
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
                <h1 class="page-title"><i class="fas fa-tools"></i> Quản Lý Thiết Bị</h1>
                <div class="d-flex gap-2">
                    <button class="btn btn-secondary" onclick="refreshPage()">
                        <i class="fas fa-sync"></i> Làm Mới
                    </button>
                </div>
            </div>

            <div id="toastContainer"></div>

            <div class="content-wrapper">
                <!-- THỐNG KÊ - 4 Ô -->
                <div class="row">
                    <div class="col-xl-3 col-lg-6 col-md-6 col-sm-6">
                        <div class="stats-card bg-primary text-white">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h6>Tổng Thiết Bị</h6>
                                    <h2>${totalEquipment != null ? totalEquipment : 0}</h2>
                                </div>
                                <i class="fas fa-clipboard-list"></i>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-lg-6 col-md-6 col-sm-6">
                        <div class="stats-card bg-success text-white">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h6>Đang Hoạt Động</h6>
                                    <h2>${activeCount != null ? activeCount : 0}</h2>
                                </div>
                                <i class="fas fa-check-circle"></i>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-lg-6 col-md-6 col-sm-6">
                        <div class="stats-card bg-warning text-dark">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h6>Đang Sửa Chữa</h6>
                                    <h2>${repairCount != null ? repairCount : 0}</h2>
                                </div>
                                <i class="fas fa-wrench"></i>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-lg-6 col-md-6 col-sm-6">
                        <div class="stats-card" style="background-color: #8b5cf6; color: white;">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h6>Đang Bảo Trì</h6>
                                    <h2>${maintenanceCount != null ? maintenanceCount : 0}</h2>
                                </div>
                                <i class="fas fa-cog"></i>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- SEARCH BAR -->
                <div class="search-filter-bar">
                    <form action="${pageContext.request.contextPath}/equipment" method="get" class="row g-3">
                        <div class="col-md-10">
                            <div class="input-group">
                                <input type="text" class="form-control" name="keyword" 
                                       placeholder="🔍 Tìm kiếm theo tên, serial number..." value="${keyword}">
                                <button class="btn btn-primary" type="submit" name="action" value="search">
                                    <i class="fas fa-search"></i> Tìm Kiếm
                                </button>
                            </div>
                        </div>
                        <div class="col-md-2">
                            <c:if test="${searchMode}">
                                <a href="${pageContext.request.contextPath}/equipment" class="btn btn-secondary w-100">
                                    <i class="fas fa-times"></i> Xóa Bộ Lọc
                                </a>
                            </c:if>
                        </div>
                    </form>
                </div>


                <!-- TABLE -->
                <div class="table-container">
                    <div class="table-responsive">
                        <c:choose>
                            <c:when test="${not empty equipmentList}">
                                <table class="table table-hover">
                                    <thead class="table-light">
                                        <tr>
                                            <th>STT</th>
                                            <th>Tên Thiết Bị</th>
                                            <th>Serial Number</th>
                                            <th>Mã Hợp Đồng</th>
                                            <th>Ngày Lắp Đặt</th>
                                            <th>Trạng Thái</th>
                                            <th>Thao Tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="item" items="${equipmentList}" varStatus="status">
                                            <tr>
                                                <td><strong>${status.index + 1}</strong></td>
                                                <td><strong>${item.equipment.model}</strong></td>
                                                <td>${item.equipment.serialNumber}</td>
                                                <td><span class="badge bg-primary">${item.contractId}</span></td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${not empty item.equipment.installDate}">
                                                            ${item.equipment.installDate}
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="text-muted">Chưa cập nhật</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${item.status == 'Active'}">
                                                            <span class="badge badge-active">
                                                                <i class="fas fa-circle"></i> Hoạt Động
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${item.status == 'Repair'}">
                                                            <span class="badge badge-repair">
                                                                <i class="fas fa-wrench"></i> Đang Sửa
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${item.status == 'Maintenance'}">
                                                            <span class="badge badge-maintenance">
                                                                <i class="fas fa-cog"></i> Bảo Trì
                                                            </span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge badge-active">
                                                                <i class="fas fa-circle"></i> Hoạt Động
                                                            </span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <button class="btn btn-sm btn-info btn-action"
                                                            data-id="${item.equipment.equipmentId}"
                                                            data-model="${item.equipment.model}"
                                                            data-serial="${item.equipment.serialNumber}"
                                                            data-contract="${item.contractId}"
                                                            data-description="${item.equipment.description}"
                                                            data-install-date="${item.equipment.installDate}"
                                                            data-last-update="${item.equipment.lastUpdatedDate}"
                                                            data-status="${item.status}"
                                                            onclick="viewEquipment(this)">
                                                        <i class="fas fa-eye"></i> Chi Tiết
                                                    </button>
                                                    <button class="btn btn-sm btn-warning btn-action"
                                                            data-id="${item.equipment.equipmentId}"
                                                            data-contract="${item.contractId}"
                                                            data-serial="${item.equipment.serialNumber}"
                                                            data-model="${item.equipment.model}"
                                                            onclick="createRequest(this)">
                                                        <i class="fas fa-plus-circle"></i> Tạo Đơn
                                                    </button>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </c:when>
                            <c:otherwise>
                                <div class="text-center py-5">
                                    <i class="fas fa-box-open fa-3x text-muted mb-3"></i>
                                    <h4 class="text-muted">Không tìm thấy thiết bị</h4>
                                    <p class="text-muted">
                                        <c:choose>
                                            <c:when test="${searchMode}">
                                                Không tìm thấy thiết bị phù hợp với từ khóa "<strong>${keyword}</strong>"
                                            </c:when>
                                            <c:otherwise>
                                                Hiện tại bạn chưa có thiết bị nào trong hệ thống
                                            </c:otherwise>
                                        </c:choose>
                                    </p>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>

            <!-- FOOTER -->
            <footer class="site-footer">
                <div class="footer-content">
                    <div class="footer-grid">
                        <div class="footer-section">
                            <h5>CRM System</h5>
                            <p class="footer-about">
                                Giải pháp quản lý khách hàng toàn diện, giúp doanh nghiệp tối ưu hóa quy trình và nâng cao chất lượng dịch vụ.
                            </p>
                        </div>

                        <div class="footer-section">
                            <h5>Tính năng chính</h5>
                            <ul class="footer-links">
                                <li><a href="#">→ Quản lý khách hàng</a></li>
                                <li><a href="#">→ Quản lý hợp đồng</a></li>
                                <li><a href="#">→ Quản lý thiết bị</a></li>
                                <li><a href="#">→ Báo cáo & Phân tích</a></li>
                            </ul>
                        </div>

                        <div class="footer-section">
                            <h5>Hỗ trợ</h5>
                            <ul class="footer-links">
                                <li><a href="#">→ Trung tâm trợ giúp</a></li>
                                <li><a href="#">→ Hướng dẫn sử dụng</a></li>
                                <li><a href="#">→ Liên hệ hỗ trợ</a></li>
                                <li><a href="#">→ Câu hỏi thường gặp</a></li>
                            </ul>
                        </div>

                        <div class="footer-section">
                            <h5>Thông tin</h5>
                            <ul class="footer-links">
                                <li><a href="#">→ Về chúng tôi</a></li>
                                <li><a href="#">→ Điều khoản sử dụng</a></li>
                                <li><a href="#">→ Chính sách bảo mật</a></li>
                                <li><a href="#">→ Liên hệ</a></li>
                            </ul>
                        </div>
                    </div>

                    <div class="footer-bottom">
                        <p class="footer-copyright">
                            &copy; 2025 CRM System. All rights reserved. | Phát triển bởi <strong>Group 6</strong>
                        </p>
                    </div>
                </div>
            </footer>

            <!-- Scroll to Top Button -->
            <div class="scroll-to-top" id="scrollToTop" onclick="scrollToTop()">
                <i class="fas fa-arrow-up"></i>
            </div>
        </div>

        <!-- MODAL VIEW EQUIPMENT -->
        <div class="modal fade" id="viewModal" tabindex="-1">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header bg-info text-white">
                        <h5 class="modal-title">
                            <i class="fas fa-info-circle"></i> Chi Tiết Thiết Bị
                        </h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <strong>Tên Thiết Bị:</strong>
                                <p class="fw-normal" id="viewEquipmentName"></p>
                            </div>
                            <div class="col-md-6">
                                <strong>Serial Number:</strong>
                                <p class="fw-normal" id="viewSerialNumber"></p>
                            </div>
                        </div>

                        <div class="row mb-3">
                            <div class="col-md-6">
                                <strong>Mã Hợp Đồng:</strong>
                                <p class="fw-normal" id="viewContractId"></p>
                            </div>
                            <div class="col-md-6">
                                <strong>Ngày Lắp Đặt:</strong>
                                <p class="fw-normal" id="viewInstallDate"></p>
                            </div>
                        </div>

                        <div class="row mb-3">
                            <div class="col-md-6">
                                <strong>Cập Nhật Lần Cuối:</strong>
                                <p class="fw-normal" id="viewLastUpdate"></p>
                            </div>
                            <div class="col-md-6">
                                <strong>Trạng Thái:</strong>
                                <span class="badge" id="viewStatus"></span>
                            </div>
                        </div>

                        <div class="mb-3">
                            <strong>Mô Tả:</strong>
                            <div class="border rounded p-3 bg-light" id="viewDescription"></div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                            <i class="fas fa-times"></i> Đóng
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- MODAL CREATE SERVICE REQUEST -->
        <div class="modal fade" id="createRequestModal" tabindex="-1">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header bg-warning text-dark">
                        <h5 class="modal-title">
                            <i class="fas fa-plus-circle"></i> Tạo Đơn Hỗ Trợ Thiết Bị
                        </h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <form action="${pageContext.request.contextPath}/managerServiceRequest" method="post" id="createRequestForm">
                        <input type="hidden" name="action" value="CreateServiceRequest">
                        <input type="hidden" name="supportType" value="equipment">
                        <input type="hidden" name="equipmentId" id="requestEquipmentId">
                        <input type="hidden" name="contractId" id="requestContractIdValue">

                        <div class="modal-body">
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">
                                        <i class="fas fa-tools"></i> Tên Thiết Bị
                                        <span class="text-danger">*</span>
                                    </label>
                                    <input type="text" class="form-control" 
                                           id="requestEquipmentName" readonly>
                                </div>

                                <div class="col-md-6 mb-3">
                                    <label class="form-label">
                                        <i class="fas fa-file-contract"></i> Mã Hợp Đồng
                                        <span class="text-danger">*</span>
                                    </label>
                                    <input type="text" class="form-control" 
                                           id="requestContractId" readonly>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">
                                        <i class="fas fa-barcode"></i> Serial Number
                                    </label>
                                    <input type="text" class="form-control" 
                                           id="requestSerialNumber" readonly>
                                </div>

                                <div class="col-md-6 mb-3">
                                    <label class="form-label">
                                        <i class="fas fa-exclamation-circle"></i> Mức Độ Ưu Tiên 
                                        <span class="text-danger">*</span>
                                    </label>
                                    <select class="form-select" name="priorityLevel" required>
                                        <option value="">-- Chọn mức độ --</option>
                                        <option value="Normal">⚪ Bình Thường</option>
                                        <option value="High">🟡 Cao</option>
                                        <option value="Urgent">🔴 Khẩn Cấp</option>
                                    </select>
                                </div>
                            </div>

                            <div class="mb-3">
                                <label class="form-label">
                                    <i class="fas fa-comment-dots"></i> Mô Tả Vấn Đề 
                                    <span class="text-danger">*</span>
                                </label>
                                <textarea class="form-control" name="description" id="requestDescription" rows="5" 
                                          placeholder="Mô tả chi tiết vấn đề bạn đang gặp phải với thiết bị..."
                                          minlength="10" maxlength="1000" required></textarea>
                                <div class="d-flex justify-content-between align-items-center mt-1">
                                    <small class="form-text text-muted">
                                        <i class="fas fa-info-circle"></i> Tối thiểu 10 ký tự, tối đa 1000 ký tự
                                    </small>
                                    <span id="charCount" class="text-muted" style="font-size: 0.875rem;">0/1000</span>
                                </div>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                                <i class="fas fa-times"></i> Hủy
                            </button>
                            <button type="submit" class="btn btn-warning">
                                <i class="fas fa-paper-plane"></i> Gửi Yêu Cầu
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <script>
                // ========== TOAST NOTIFICATION ==========
                let currentToastTimeout = null;

                function showToast(message, type) {
                    const container = document.getElementById('toastContainer');
                    if (currentToastTimeout) {
                        clearTimeout(currentToastTimeout);
                    }

                    let iconClass = 'fa-check-circle';
                    if (type === 'error')
                        iconClass = 'fa-exclamation-circle';

                    const toastDiv = document.createElement('div');
                    toastDiv.className = 'toast-notification ' + type;

                    const iconDiv = document.createElement('div');
                    iconDiv.className = 'toast-icon ' + type;
                    iconDiv.innerHTML = '<i class="fas ' + iconClass + '"></i>';

                    const contentDiv = document.createElement('div');
                    contentDiv.className = 'toast-content';
                    contentDiv.textContent = message;

                    const closeBtn = document.createElement('button');
                    closeBtn.className = 'toast-close';
                    closeBtn.type = 'button';
                    closeBtn.innerHTML = '<i class="fas fa-times"></i>';
                    closeBtn.onclick = hideToast;

                    toastDiv.appendChild(iconDiv);
                    toastDiv.appendChild(contentDiv);
                    toastDiv.appendChild(closeBtn);

                    container.innerHTML = '';
                    container.appendChild(toastDiv);

                    currentToastTimeout = setTimeout(hideToast, 5000);
                }

                function hideToast() {
                    const container = document.getElementById('toastContainer');
                    const toast = container.querySelector('.toast-notification');
                    if (toast) {
                        toast.classList.add('hiding');
                        setTimeout(() => {
                            container.innerHTML = '';
                        }, 400);
                    }
                    if (currentToastTimeout) {
                        clearTimeout(currentToastTimeout);
                        currentToastTimeout = null;
                    }
                }

                // ========== CHARACTER COUNT ==========
                function updateCharCount() {
                    const textarea = document.getElementById('requestDescription');
                    const charCount = document.getElementById('charCount');
                    if (!textarea || !charCount)
                        return;

                    const currentLength = textarea.value.length;
                    charCount.textContent = currentLength + '/1000';

                    if (currentLength > 900) {
                        charCount.className = 'text-danger';
                    } else if (currentLength > 700) {
                        charCount.className = 'text-warning';
                    } else {
                        charCount.className = 'text-muted';
                    }
                }

// ========== VIEW EQUIPMENT ==========
                function viewEquipment(button) {
                    const model = button.getAttribute('data-model');
                    const serial = button.getAttribute('data-serial');
                    const contract = button.getAttribute('data-contract');
                    const description = button.getAttribute('data-description');
                    const installDate = button.getAttribute('data-install-date');
                    const lastUpdate = button.getAttribute('data-last-update');
                    const status = button.getAttribute('data-status');

                    document.getElementById('viewEquipmentName').textContent = model || 'N/A';
                    document.getElementById('viewSerialNumber').textContent = serial || 'N/A';
                    document.getElementById('viewContractId').textContent = contract || 'N/A';
                    document.getElementById('viewInstallDate').textContent = installDate || 'N/A';
                    document.getElementById('viewLastUpdate').textContent = lastUpdate || 'N/A';
                    document.getElementById('viewDescription').textContent = description || 'Không có mô tả';

                    const statusBadge = document.getElementById('viewStatus');
                    if (status === 'Active') {
                        statusBadge.className = 'badge badge-active';
                        statusBadge.innerHTML = '<i class="fas fa-check-circle"></i> Đang hoạt động';
                    } else if (status === 'Repair') {
                        statusBadge.className = 'badge badge-repair';
                        statusBadge.innerHTML = '<i class="fas fa-wrench"></i> Đang sửa chữa';
                    } else if (status === 'Maintenance') {
                        statusBadge.className = 'badge badge-maintenance';
                        statusBadge.innerHTML = '<i class="fas fa-cog"></i> Đang bảo trì';
                    }

                    new bootstrap.Modal(document.getElementById('viewModal')).show();
                }

// ========== CREATE REQUEST ==========
                function createRequest(button) {
                    const equipmentId = button.getAttribute('data-id');
                    const contractId = button.getAttribute('data-contract');
                    const serialNumber = button.getAttribute('data-serial');
                    const equipmentName = button.getAttribute('data-model');

                    // Remove "HD" prefix if exists to get clean number
                    const cleanContractId = contractId.replace('HD', '').replace('#', '');

                    document.getElementById('requestEquipmentId').value = equipmentId;
                    document.getElementById('requestContractIdValue').value = cleanContractId;
                    document.getElementById('requestEquipmentName').value = equipmentName;
                    document.getElementById('requestContractId').value = contractId;
                    document.getElementById('requestSerialNumber').value = serialNumber;

                    new bootstrap.Modal(document.getElementById('createRequestModal')).show();
                }

                 // ========== EVENT LISTENERS ==========
                document.addEventListener('DOMContentLoaded', function () {
                    const descriptionTextarea = document.getElementById('requestDescription');
                    if (descriptionTextarea) {
                        descriptionTextarea.addEventListener('input', updateCharCount);
                    }

                    // Reset form when modal closes
                    const createModal = document.getElementById('createRequestModal');
                    if (createModal) {
                        createModal.addEventListener('hidden.bs.modal', function () {
                            document.getElementById('createRequestForm').reset();
                            updateCharCount();
                        });
                    }
                });
        </script>
    </body>
</html>