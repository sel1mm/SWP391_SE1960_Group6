<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản Lý Hợp Đồng - Customer</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css" rel="stylesheet">
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

        /* ========== SIDEBAR STYLES ========== */
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
            cursor: pointer;
            pointer-events: auto;
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
            z-index: 1001;
        }

        .sidebar-toggle:hover {
            transform: scale(1.1);
            background: #1e3c72;
            color: white;
        }

        /* MAIN CONTENT WITH SIDEBAR */
        .main-content {
            margin-left: 260px;
            transition: all 0.3s ease;
            min-height: 100vh;
        }

        .sidebar.collapsed ~ .main-content {
            margin-left: 70px;
        }

        /* HEADER */
        .page-header {
            background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
            color: white;
            padding: 30px 40px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            position: relative;
        }

        .page-header h1 {
            font-size: 2rem;
            font-weight: 700;
            margin-bottom: 10px;
        }

        .page-header .breadcrumb {
            background: transparent;
            padding: 0;
            margin: 0;
        }

        .page-header .breadcrumb-item {
            color: rgba(255,255,255,0.8);
        }

        .page-header .breadcrumb-item.active {
            color: white;
        }

        .page-header .breadcrumb-item + .breadcrumb-item::before {
            color: rgba(255,255,255,0.6);
        }

        /* NOTIFICATION BADGE IN HEADER */
        .notification-badge-header {
            cursor: pointer;
            position: relative;
        }

        .notification-badge-header .btn {
            border-radius: 50%;
            width: 50px;
            height: 50px;
            padding: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            background: rgba(255,255,255,0.15);
            border: 2px solid rgba(255,255,255,0.3);
            color: white;
            transition: all 0.3s;
        }

        .notification-badge-header .btn:hover {
            background: rgba(255,255,255,0.25);
            border-color: white;
            transform: scale(1.05);
        }

        .notification-badge-header .badge {
            position: absolute;
            top: -5px;
            right: -5px;
            padding: 5px 8px;
            border-radius: 12px;
            font-size: 0.75rem;
            background: #dc3545;
            border: 2px solid #1e3c72;
            color: white;
            font-weight: 700;
        }

        /* CONTENT WRAPPER */
        .content-wrapper {
            padding: 30px 40px;
            max-width: 1600px;
            margin: 0 auto;
        }

        .notification-dropdown {
            position: absolute;
            top: 100%;
            right: 40px;
            margin-top: 10px;
            width: 400px;
            max-height: 500px;
            background: white;
            border-radius: 10px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.3);
            display: none;
            z-index: 1049;
            overflow: hidden;
        }

        .notification-dropdown.show {
            display: block;
        }

        .notification-header {
            background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
            color: white;
            padding: 15px 20px;
            font-weight: 600;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .notification-list {
            max-height: 400px;
            overflow-y: auto;
        }

        .notification-item {
            padding: 15px 20px;
            border-bottom: 1px solid #e9ecef;
            transition: all 0.3s;
            cursor: pointer;
        }

        .notification-item:hover {
            background: #f8f9fa;
        }

        .notification-item.unread {
            background: #e7f3ff;
            border-left: 4px solid #0d6efd;
        }

        .notification-item .notification-icon {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.2rem;
            margin-right: 15px;
        }

        .notification-item.type-new .notification-icon {
            background: #d1f2eb;
            color: #198754;
        }

        .notification-item.type-expiring .notification-icon {
            background: #fff3cd;
            color: #ffc107;
        }

        .notification-item.type-response .notification-icon {
            background: #cfe2ff;
            color: #0d6efd;
        }

        /* STATS CARDS */
        .stats-row {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .stat-card {
            background: white;
            border-radius: 12px;
            padding: 25px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
            transition: all 0.3s;
            border-left: 4px solid;
        }

        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.15);
        }

        .stat-card.total {
            border-color: #0d6efd;
        }

        .stat-card.active {
            border-color: #198754;
        }

        .stat-card.expiring {
            border-color: #ffc107;
        }

        .stat-card.expired {
            border-color: #dc3545;
        }

        .stat-card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
        }

        .stat-card-icon {
            width: 50px;
            height: 50px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
        }

        .stat-card.total .stat-card-icon {
            background: rgba(13, 110, 253, 0.1);
            color: #0d6efd;
        }

        .stat-card.active .stat-card-icon {
            background: rgba(25, 135, 84, 0.1);
            color: #198754;
        }

        .stat-card.expiring .stat-card-icon {
            background: rgba(255, 193, 7, 0.1);
            color: #ffc107;
        }

        .stat-card.expired .stat-card-icon {
            background: rgba(220, 53, 69, 0.1);
            color: #dc3545;
        }

        .stat-card-title {
            color: #6c757d;
            font-size: 0.9rem;
            font-weight: 500;
            margin-bottom: 5px;
        }

        .stat-card-value {
            font-size: 2rem;
            font-weight: 700;
            color: #212529;
        }

        /* SEARCH & FILTER */
        .search-filter-section {
            background: white;
            border-radius: 12px;
            padding: 25px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
            margin-bottom: 30px;
        }

        .filter-title {
            font-size: 1.1rem;
            font-weight: 600;
            color: #212529;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        /* CONTRACT TABLE */
        .contract-table-wrapper {
            background: white;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
            overflow: hidden;
        }

        .table-header {
            background: linear-gradient(135deg, #000000 0%, #1a1a1a 100%);
            color: white;
            padding: 20px 25px;
            font-size: 1.2rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .table-responsive {
            padding: 0;
        }

        .contract-table {
            width: 100%;
            margin-bottom: 0;
        }

        .contract-table thead th {
            background: #f8f9fa;
            color: #495057;
            font-weight: 600;
            padding: 15px 20px;
            border-bottom: 2px solid #dee2e6;
            white-space: nowrap;
        }

        .contract-table tbody td {
            padding: 15px 20px;
            vertical-align: middle;
            border-bottom: 1px solid #e9ecef;
        }

        .contract-table tbody tr {
            transition: all 0.3s;
        }

        .contract-table tbody tr:hover {
            background: #f8f9fa;
            transform: scale(1.01);
        }

        /* STATUS BADGES */
        .status-badge {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 5px;
        }

        .status-badge.active {
            background: #d1f2eb;
            color: #0f5132;
        }

        .status-badge.expiring {
            background: #fff3cd;
            color: #664d03;
        }

        .status-badge.expired {
            background: #f8d7da;
            color: #842029;
        }

        .status-badge.terminated {
            background: #e2e3e5;
            color: #41464b;
        }

        /* CONTRACT TYPE BADGE */
        .contract-type-badge {
            padding: 5px 10px;
            border-radius: 6px;
            font-size: 0.8rem;
            font-weight: 600;
            display: inline-block;
        }

        .contract-type-badge.service {
            background: #cfe2ff;
            color: #084298;
        }

        .contract-type-badge.warranty {
            background: #d1e7dd;
            color: #0a3622;
        }

        /* ACTION BUTTONS */
        .action-buttons {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
        }

        .btn-action {
            padding: 6px 12px;
            font-size: 0.85rem;
            border-radius: 6px;
            border: none;
            cursor: pointer;
            transition: all 0.3s;
            display: inline-flex;
            align-items: center;
            gap: 5px;
        }

        .btn-action:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.15);
        }

        .btn-view {
            background: #0d6efd;
            color: white;
        }

        .btn-view:hover {
            background: #0b5ed7;
        }

        .btn-download {
            background: #198754;
            color: white;
        }

        .btn-download:hover {
            background: #157347;
        }

        .btn-terminate {
            background: #dc3545;
            color: white;
        }

        .btn-terminate:hover {
            background: #bb2d3b;
        }

        .btn-terminate:disabled {
            background: #6c757d;
            cursor: not-allowed;
            opacity: 0.6;
        }

        /* DAYS REMAINING INDICATOR */
        .days-remaining {
            font-size: 0.9rem;
            font-weight: 600;
        }

        .days-remaining.critical {
            color: #dc3545;
        }

        .days-remaining.warning {
            color: #ffc107;
        }

        .days-remaining.safe {
            color: #198754;
        }

        /* EMPTY STATE */
        .empty-state {
            text-align: center;
            padding: 60px 20px;
        }

        .empty-state i {
            font-size: 5rem;
            color: #dee2e6;
            margin-bottom: 20px;
        }

        .empty-state h3 {
            color: #6c757d;
            font-size: 1.5rem;
            margin-bottom: 10px;
        }

        .empty-state p {
            color: #adb5bd;
            font-size: 1rem;
        }

        /* PAGINATION */
        .pagination-wrapper {
            padding: 20px 25px;
            background: #f8f9fa;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .pagination {
            margin: 0;
        }

        .page-link {
            color: #000000;
            border: 1px solid #dee2e6;
            padding: 8px 15px;
        }

        .page-link:hover {
            background: #000000;
            color: white;
            border-color: #000000;
        }

        .page-item.active .page-link {
            background: #000000;
            border-color: #000000;
        }

        /* MODAL CUSTOM */
        .modal-content {
            border-radius: 12px;
            border: none;
        }

        .modal-header {
            border-top-left-radius: 12px;
            border-top-right-radius: 12px;
            padding: 20px 25px;
        }

        .modal-body {
            padding: 25px;
        }

        .modal-footer {
            padding: 15px 25px;
            background: #f8f9fa;
            border-bottom-left-radius: 12px;
            border-bottom-right-radius: 12px;
        }

        .detail-row {
            display: grid;
            grid-template-columns: 200px 1fr;
            gap: 15px;
            padding: 12px 0;
            border-bottom: 1px solid #e9ecef;
        }

        .detail-row:last-child {
            border-bottom: none;
        }

        .detail-label {
            font-weight: 600;
            color: #495057;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .detail-value {
            color: #212529;
        }

        /* ALERT CUSTOM */
        .alert-custom {
            border-left: 4px solid;
            border-radius: 8px;
            padding: 15px 20px;
        }

        .alert-custom.alert-warning {
            border-color: #ffc107;
            background: #fff3cd;
        }

        .alert-custom.alert-info {
            border-color: #0dcaf0;
            background: #cff4fc;
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

            .content-wrapper {
                padding: 20px 15px;
            }

            .stats-row {
                grid-template-columns: 1fr;
            }

            .action-buttons {
                flex-direction: column;
            }

            .btn-action {
                width: 100%;
                justify-content: center;
            }

            .notification-dropdown {
                width: calc(100vw - 40px);
                right: 20px;
            }

            .detail-row {
                grid-template-columns: 1fr;
                gap: 5px;
            }
        }

        /* LOADING SPINNER */
        .spinner-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.5);
            display: none;
            justify-content: center;
            align-items: center;
            z-index: 9999;
        }

        .spinner-overlay.show {
            display: flex;
        }

        .spinner-content {
            background: white;
            padding: 30px;
            border-radius: 12px;
            text-align: center;
        }
    </style>
</head>
<body>

    <!-- ========== SIDEBAR ========== -->
    <div class="sidebar" id="sidebar">
        <div class="sidebar-toggle" onclick="toggleSidebar()">
            <i class="fas fa-chevron-left" id="toggleIcon"></i>
        </div>

        <div class="sidebar-header">
            <a href="#" class="sidebar-brand">
                <i class="fas fa-building"></i>
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
                    <span class="badge bg-warning">3</span>
                </a>
                <a href="${pageContext.request.contextPath}/viewCustomerContract" class="menu-item active">
                    <i class="fas fa-file-contract"></i>
                    <span>Hợp Đồng</span>
                </a>
                <a href="${pageContext.request.contextPath}/equipment" class="menu-item">
                    <i class="fas fa-tools"></i>
                    <span>Thiết Bị</span>
                </a>
            </div>

            <div class="menu-section">
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
                        <c:when test="${not empty sessionScope.session_login.username}">
                            ${sessionScope.session_login.username.substring(0,1).toUpperCase()}
                        </c:when>
                        <c:otherwise>
                            C
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
                                Customer
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="user-role">
                        <c:choose>
                            <c:when test="${not empty sessionScope.session_role}">
                                ${sessionScope.session_role}
                            </c:when>
                            <c:otherwise>
                                Khách Hàng
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
            <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
                <i class="fas fa-sign-out-alt"></i>
                <span>Đăng Xuất</span>
            </a>
        </div>
    </div>

    <!-- MAIN CONTENT WRAPPER -->
    <div class="main-content">

    <!-- PAGE HEADER -->
    <div class="page-header">
        <!-- NOTIFICATION DROPDOWN -->
        <div class="notification-dropdown" id="notificationDropdown">
            <div class="notification-header">
                <span><i class="fas fa-bell"></i> Thông Báo</span>
                <button class="btn btn-sm btn-light" onclick="markAllAsRead()">
                    <i class="fas fa-check-double"></i> Đọc tất cả
                </button>
            </div>
            <div class="notification-list">
                <!-- Example notifications -->
                <div class="notification-item unread type-new" onclick="viewNotification(1)">
                    <div class="d-flex">
                        <div class="notification-icon">
                            <i class="fas fa-file-contract"></i>
                        </div>
                        <div class="flex-grow-1">
                            <strong>Hợp đồng mới được tạo</strong>
                            <p class="mb-1 text-muted small">Hợp đồng HD001 đã được tạo và chờ xác nhận từ bạn.</p>
                            <small class="text-muted"><i class="fas fa-clock"></i> 2 giờ trước</small>
                        </div>
                    </div>
                </div>

                <div class="notification-item unread type-expiring" onclick="viewNotification(2)">
                    <div class="d-flex">
                        <div class="notification-icon">
                            <i class="fas fa-exclamation-triangle"></i>
                        </div>
                        <div class="flex-grow-1">
                            <strong>Hợp đồng sắp hết hạn</strong>
                            <p class="mb-1 text-muted small">Hợp đồng HD002 sẽ hết hạn trong 10 ngày nữa.</p>
                            <small class="text-muted"><i class="fas fa-clock"></i> 1 ngày trước</small>
                        </div>
                    </div>
                </div>

                <div class="notification-item unread type-response" onclick="viewNotification(3)">
                    <div class="d-flex">
                        <div class="notification-icon">
                            <i class="fas fa-reply"></i>
                        </div>
                        <div class="flex-grow-1">
                            <strong>Phản hồi yêu cầu chấm dứt</strong>
                            <p class="mb-1 text-muted small">Yêu cầu chấm dứt hợp đồng HD003 đã được xử lý.</p>
                            <small class="text-muted"><i class="fas fa-clock"></i> 3 ngày trước</small>
                        </div>
                    </div>
                </div>

                <div class="notification-item" onclick="viewNotification(4)">
                    <div class="d-flex">
                        <div class="notification-icon">
                            <i class="fas fa-info-circle"></i>
                        </div>
                        <div class="flex-grow-1">
                            <strong>Thông báo hệ thống</strong>
                            <p class="mb-1 text-muted small">Hệ thống sẽ bảo trì vào 00:00 ngày 15/01/2025.</p>
                            <small class="text-muted"><i class="fas fa-clock"></i> 1 tuần trước</small>
                        </div>
                    </div>
                </div>
            </div>
            <div class="text-center p-3 border-top">
                <a href="#" class="text-decoration-none">Xem tất cả thông báo</a>
            </div>
        </div>

        <div class="d-flex justify-content-between align-items-center">
            <div>
                <h1><i class="fas fa-file-contract"></i> Quản Lý Hợp Đồng Khách Hàng</h1>
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="#" class="text-white-50">Trang chủ</a></li>
                        <li class="breadcrumb-item active">Hợp đồng của tôi</li>
                    </ol>
                </nav>
            </div>
            <div class="d-flex align-items-center gap-3">
                <!-- NOTIFICATION BADGE IN HEADER -->
                <div class="notification-badge-header" onclick="toggleNotifications()">
                    <button class="btn position-relative">
                        <i class="fas fa-bell fs-5"></i>
                        <span class="badge" id="notificationCount">3</span>
                    </button>
                </div>
                <div class="text-end">
                    <p class="mb-0">Xin chào, <strong>customer1</strong></p>
                    <small>Khách hàng</small>
                </div>
            </div>
        </div>
    </div>

    <!-- MAIN CONTENT -->
    <div class="content-wrapper">
        
        <!-- STATISTICS CARDS -->
        <div class="stats-row">
            <div class="stat-card total">
                <div class="stat-card-header">
                    <div>
                        <div class="stat-card-title">Tổng hợp đồng</div>
                        <div class="stat-card-value">5</div>
                    </div>
                    <div class="stat-card-icon">
                        <i class="fas fa-file-contract"></i>
                    </div>
                </div>
            </div>

            <div class="stat-card active">
                <div class="stat-card-header">
                    <div>
                        <div class="stat-card-title">Đang hoạt động</div>
                        <div class="stat-card-value">3</div>
                    </div>
                    <div class="stat-card-icon">
                        <i class="fas fa-check-circle"></i>
                    </div>
                </div>
            </div>

            <div class="stat-card expiring">
                <div class="stat-card-header">
                    <div>
                        <div class="stat-card-title">Sắp hết hạn</div>
                        <div class="stat-card-value">1</div>
                    </div>
                    <div class="stat-card-icon">
                        <i class="fas fa-exclamation-triangle"></i>
                    </div>
                </div>
            </div>

            <div class="stat-card expired">
                <div class="stat-card-header">
                    <div>
                        <div class="stat-card-title">Đã hết hạn</div>
                        <div class="stat-card-value">1</div>
                    </div>
                    <div class="stat-card-icon">
                        <i class="fas fa-times-circle"></i>
                    </div>
                </div>
            </div>
        </div>

        <!-- SEARCH & FILTER SECTION -->
        <div class="search-filter-section">
            <div class="filter-title">
                <i class="fas fa-filter"></i> Tìm kiếm & Lọc
            </div>
            <form method="get" action="${pageContext.request.contextPath}/viewCustomerContract">
                <div class="row g-3">
                    <div class="col-md-4">
                        <label class="form-label">
                            <i class="fas fa-search"></i> Tìm kiếm
                        </label>
                        <input type="text" class="form-control" name="keyword" 
                               placeholder="Tên khách hàng / SDT / Email / Username..." 
                               value="${keyword}">
                    </div>
                    <div class="col-md-2">
                        <label class="form-label">
                            <i class="fas fa-calendar-alt"></i> Từ ngày ký
                        </label>
                        <input type="date" class="form-control" name="fromDate" value="${fromDate}">
                    </div>
                    <div class="col-md-2">
                        <label class="form-label">
                            <i class="fas fa-calendar-alt"></i> Đến ngày ký
                        </label>
                        <input type="date" class="form-control" name="toDate" value="${toDate}">
                    </div>
                    <div class="col-md-2">
                        <label class="form-label">
                            <i class="fas fa-info-circle"></i> Trạng thái
                        </label>
                        <select class="form-select" name="status">
                            <option value="">Tất cả</option>
                            <option value="Active" ${status == 'Active' ? 'selected' : ''}>Hoạt động</option>
                            <option value="Expiring" ${status == 'Expiring' ? 'selected' : ''}>Sắp hết hạn</option>
                            <option value="Expired" ${status == 'Expired' ? 'selected' : ''}>Hết hạn</option>
                            <option value="Terminated" ${status == 'Terminated' ? 'selected' : ''}>Đã chấm dứt</option>
                        </select>
                    </div>
                    <div class="col-md-2 d-flex align-items-end gap-2">
                        <button type="submit" class="btn btn-primary flex-grow-1">
                            <i class="fas fa-search"></i> Tìm kiếm
                        </button>
                        <button type="button" class="btn btn-secondary" onclick="resetFilters()">
                            <i class="fas fa-redo"></i>
                        </button>
                    </div>
                </div>
            </form>
        </div>

        <!-- CONTRACTS TABLE -->
        <div class="contract-table-wrapper">
            <div class="table-header">
                <i class="fas fa-list"></i> Danh sách hợp đồng
            </div>

            <div class="table-responsive">
                <table class="contract-table table">
                    <thead>
                        <tr>
                            <th>Mã hợp đồng</th>
                            <th>Loại hợp đồng</th>
                            <th>Ngày ký</th>
                            <th>Ngày kết thúc</th>
                            <th>Còn lại</th>
                            <th>Trạng thái</th>
                            <th>Chi tiết</th>
                            <th>Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <!-- Sample Data Row 1 - Active -->
                        <tr>
                            <td><strong>HD001</strong></td>
                            <td><span class="contract-type-badge service">Dịch Vụ</span></td>
                            <td>01/01/2024</td>
                            <td>31/12/2024</td>
                            <td><span class="days-remaining safe">120 ngày</span></td>
                            <td><span class="status-badge active"><i class="fas fa-check-circle"></i> Hoạt động</span></td>
                            <td>
                                <small class="text-muted">Giá trị: 50,000,000 VNĐ</small><br>
                                <small class="text-muted">Thiết bị: 3 cái</small>
                            </td>
                            <td>
                                <div class="action-buttons">
                                    <button class="btn-action btn-view" onclick="viewContractDetail(1)">
                                        <i class="fas fa-eye"></i> Xem
                                    </button>
                                    <button class="btn-action btn-download" onclick="downloadContract(1)">
                                        <i class="fas fa-download"></i> Tải
                                    </button>
                                    <button class="btn-action btn-terminate" onclick="requestTermination(1)">
                                        <i class="fas fa-ban"></i> Chấm dứt
                                    </button>
                                </div>
                            </td>
                        </tr>

                        <!-- Sample Data Row 2 - Expiring -->
                        <tr>
                            <td><strong>HD002</strong></td>
                            <td><span class="contract-type-badge warranty">Bảo Hành</span></td>
                            <td>15/03/2024</td>
                            <td>15/01/2025</td>
                            <td><span class="days-remaining warning">10 ngày</span></td>
                            <td><span class="status-badge expiring"><i class="fas fa-exclamation-triangle"></i> Sắp hết hạn</span></td>
                            <td>
                                <small class="text-muted">Giá trị: 30,000,000 VNĐ</small><br>
                                <small class="text-muted">Thiết bị: 2 cái</small>
                            </td>
                            <td>
                                <div class="action-buttons">
                                    <button class="btn-action btn-view" onclick="viewContractDetail(2)">
                                        <i class="fas fa-eye"></i> Xem
                                    </button>
                                    <button class="btn-action btn-download" onclick="downloadContract(2)">
                                        <i class="fas fa-download"></i> Tải
                                    </button>
                                    <button class="btn-action btn-terminate" onclick="requestTermination(2)">
                                        <i class="fas fa-ban"></i> Chấm dứt
                                    </button>
                                </div>
                            </td>
                        </tr>

                        <!-- Sample Data Row 3 - Active -->
                        <tr>
                            <td><strong>HD003</strong></td>
                            <td><span class="contract-type-badge service">Dịch Vụ</span></td>
                            <td>10/05/2024</td>
                            <td>10/05/2025</td>
                            <td><span class="days-remaining safe">90 ngày</span></td>
                            <td><span class="status-badge active"><i class="fas fa-check-circle"></i> Hoạt động</span></td>
                            <td>
                                <small class="text-muted">Giá trị: 75,000,000 VNĐ</small><br>
                                <small class="text-muted">Thiết bị: 5 cái</small>
                            </td>
                            <td>
                                <div class="action-buttons">
                                    <button class="btn-action btn-view" onclick="viewContractDetail(3)">
                                        <i class="fas fa-eye"></i> Xem
                                    </button>
                                    <button class="btn-action btn-download" onclick="downloadContract(3)">
                                        <i class="fas fa-download"></i> Tải
                                    </button>
                                    <button class="btn-action btn-terminate" onclick="requestTermination(3)">
                                        <i class="fas fa-ban"></i> Chấm dứt
                                    </button>
                                </div>
                            </td>
                        </tr>

                        <!-- Sample Data Row 4 - Expired -->
                        <tr>
                            <td><strong>HD004</strong></td>
                            <td><span class="contract-type-badge warranty">Bảo Hành</span></td>
                            <td>01/06/2023</td>
                            <td>01/06/2024</td>
                            <td><span class="days-remaining critical">Đã hết hạn</span></td>
                            <td><span class="status-badge expired"><i class="fas fa-times-circle"></i> Hết hạn</span></td>
                            <td>
                                <small class="text-muted">Giá trị: 20,000,000 VNĐ</small><br>
                                <small class="text-muted">Thiết bị: 1 cái</small>
                            </td>
                            <td>
                                <div class="action-buttons">
                                    <button class="btn-action btn-view" onclick="viewContractDetail(4)">
                                        <i class="fas fa-eye"></i> Xem
                                    </button>
                                    <button class="btn-action btn-download" onclick="downloadContract(4)">
                                        <i class="fas fa-download"></i> Tải
                                    </button>
                                    <button class="btn-action btn-terminate" disabled title="Hợp đồng đã hết hạn">
                                        <i class="fas fa-ban"></i> Chấm dứt
                                    </button>
                                </div>
                            </td>
                        </tr>

                        <!-- Sample Data Row 5 - Terminated -->
                        <tr>
                            <td><strong>HD005</strong></td>
                            <td><span class="contract-type-badge service">Dịch Vụ</span></td>
                            <td>20/08/2024</td>
                            <td>20/08/2025</td>
                            <td><span class="days-remaining">-</span></td>
                            <td><span class="status-badge terminated"><i class="fas fa-stop-circle"></i> Đã chấm dứt</span></td>
                            <td>
                                <small class="text-muted">Giá trị: 40,000,000 VNĐ</small><br>
                                <small class="text-muted">Thiết bị: 2 cái</small>
                            </td>
                            <td>
                                <div class="action-buttons">
                                    <button class="btn-action btn-view" onclick="viewContractDetail(5)">
                                        <i class="fas fa-eye"></i> Xem
                                    </button>
                                    <button class="btn-action btn-download" onclick="downloadContract(5)">
                                        <i class="fas fa-download"></i> Tải
                                    </button>
                                    <button class="btn-action btn-terminate" disabled title="Hợp đồng đã chấm dứt">
                                        <i class="fas fa-ban"></i> Chấm dứt
                                    </button>
                                </div>
                            </td>
                        </tr>

                        <!-- Empty State (uncomment when no data) -->
                        <!-- <tr>
                            <td colspan="8">
                                <div class="empty-state">
                                    <i class="fas fa-folder-open"></i>
                                    <h3>Không có hợp đồng nào</h3>
                                    <p>Chưa có hợp đồng được tạo cho tài khoản của bạn.</p>
                                </div>
                            </td>
                        </tr> -->
                    </tbody>
                </table>
            </div>

            <!-- PAGINATION -->
            <div class="pagination-wrapper">
                <div class="text-muted">
                    Hiển thị <strong>1-5</strong> trong tổng số <strong>5</strong> hợp đồng
                </div>
                <nav>
                    <ul class="pagination mb-0">
                        <li class="page-item disabled">
                            <a class="page-link" href="#"><i class="fas fa-chevron-left"></i></a>
                        </li>
                        <li class="page-item active"><a class="page-link" href="#">1</a></li>
                        <li class="page-item disabled">
                            <a class="page-link" href="#"><i class="fas fa-chevron-right"></i></a>
                        </li>
                    </ul>
                </nav>
            </div>
        </div>

    </div>

    <!-- MODAL: VIEW CONTRACT DETAIL -->
    <div class="modal fade" id="viewContractModal" tabindex="-1">
        <div class="modal-dialog modal-xl">
            <div class="modal-content">
                <div class="modal-header text-white" style="background: linear-gradient(135deg, #000000 0%, #1a1a1a 100%);">
                    <h5 class="modal-title">
                        <i class="fas fa-file-contract"></i> Chi Tiết Hợp Đồng
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <!-- Contract Information -->
                    <h6 class="fw-bold mb-3"><i class="fas fa-info-circle text-primary"></i> Thông Tin Hợp Đồng</h6>
                    <div class="detail-row">
                        <div class="detail-label"><i class="fas fa-hashtag"></i> Mã hợp đồng:</div>
                        <div class="detail-value"><strong>HD001</strong></div>
                    </div>
                    <div class="detail-row">
                        <div class="detail-label"><i class="fas fa-tag"></i> Loại hợp đồng:</div>
                        <div class="detail-value"><span class="contract-type-badge service">Dịch Vụ</span></div>
                    </div>
                    <div class="detail-row">
                        <div class="detail-label"><i class="fas fa-calendar-check"></i> Ngày ký:</div>
                        <div class="detail-value">01/01/2024</div>
                    </div>
                    <div class="detail-row">
                        <div class="detail-label"><i class="fas fa-calendar-times"></i> Ngày kết thúc:</div>
                        <div class="detail-value">31/12/2024</div>
                    </div>
                    <div class="detail-row">
                        <div class="detail-label"><i class="fas fa-dollar-sign"></i> Giá trị hợp đồng:</div>
                        <div class="detail-value"><strong class="text-success">50,000,000 VNĐ</strong></div>
                    </div>
                    <div class="detail-row">
                        <div class="detail-label"><i class="fas fa-info-circle"></i> Trạng thái:</div>
                        <div class="detail-value"><span class="status-badge active"><i class="fas fa-check-circle"></i> Hoạt động</span></div>
                    </div>

                    <hr class="my-4">

                    <!-- Customer Information -->
                    <h6 class="fw-bold mb-3"><i class="fas fa-user text-primary"></i> Thông Tin Khách Hàng</h6>
                    <div class="detail-row">
                        <div class="detail-label"><i class="fas fa-user"></i> Họ và tên:</div>
                        <div class="detail-value">Nguyễn Văn A</div>
                    </div>
                    <div class="detail-row">
                        <div class="detail-label"><i class="fas fa-envelope"></i> Email:</div>
                        <div class="detail-value">customer1@example.com</div>
                    </div>
                    <div class="detail-row">
                        <div class="detail-label"><i class="fas fa-phone"></i> Số điện thoại:</div>
                        <div class="detail-value">0123456789</div>
                    </div>
                    <div class="detail-row">
                        <div class="detail-label"><i class="fas fa-map-marker-alt"></i> Địa chỉ:</div>
                        <div class="detail-value">123 Đường ABC, Quận 1, TP.HCM</div>
                    </div>

                    <hr class="my-4">

                    <!-- Equipment List -->
                    <h6 class="fw-bold mb-3"><i class="fas fa-tools text-primary"></i> Thiết Bị Trong Hợp Đồng</h6>
                    <div class="table-responsive">
                        <table class="table table-bordered table-sm">
                            <thead class="table-light">
                                <tr>
                                    <th>STT</th>
                                    <th>Tên thiết bị</th>
                                    <th>Serial Number</th>
                                    <th>Trạng thái</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td>1</td>
                                    <td>Máy photocopy Canon iR2625</td>
                                    <td>SN123456</td>
                                    <td><span class="badge bg-success">Hoạt động</span></td>
                                </tr>
                                <tr>
                                    <td>2</td>
                                    <td>Máy in HP LaserJet Pro</td>
                                    <td>SN789012</td>
                                    <td><span class="badge bg-success">Hoạt động</span></td>
                                </tr>
                                <tr>
                                    <td>3</td>
                                    <td>Máy scan Epson DS-770</td>
                                    <td>SN345678</td>
                                    <td><span class="badge bg-success">Hoạt động</span></td>
                                </tr>
                            </tbody>
                        </table>
                    </div>

                    <!-- Alerts -->
                    <div class="alert alert-custom alert-info mt-3">
                        <i class="fas fa-info-circle"></i>
                        <strong>Lưu ý:</strong> Hợp đồng này còn <strong>120 ngày</strong> nữa sẽ hết hạn. Vui lòng liên hệ với chúng tôi để gia hạn hoặc tạo hợp đồng mới.
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                        <i class="fas fa-times"></i> Đóng
                    </button>
                    <button type="button" class="btn btn-success" onclick="downloadContract(1)">
                        <i class="fas fa-download"></i> Tải xuống PDF
                    </button>
                    <button type="button" class="btn btn-danger" onclick="requestTermination(1)">
                        <i class="fas fa-ban"></i> Yêu cầu chấm dứt
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- MODAL: REQUEST TERMINATION -->
    <div class="modal fade" id="terminationModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header bg-danger text-white">
                    <h5 class="modal-title">
                        <i class="fas fa-ban"></i> Yêu Cầu Chấm Dứt Hợp Đồng
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <form id="terminationForm" onsubmit="submitTermination(event)">
                    <div class="modal-body">
                        <input type="hidden" name="contractId" id="terminationContractId">
                        
                        <div class="alert alert-custom alert-warning">
                            <i class="fas fa-exclamation-triangle"></i>
                            <strong>Cảnh báo:</strong> Yêu cầu chấm dứt hợp đồng là hành động nghiêm trọng. Vui lòng cung cấp lý do chi tiết.
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-bold">
                                <i class="fas fa-file-contract"></i> Hợp đồng:
                            </label>
                            <input type="text" class="form-control" id="terminationContractDisplay" readonly>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-bold">
                                <i class="fas fa-list"></i> Lý do chấm dứt: <span class="text-danger">*</span>
                            </label>
                            <select class="form-select" name="terminationReason" id="terminationReason" required>
                                <option value="">-- Chọn lý do --</option>
                                <option value="service_quality">Chất lượng dịch vụ không đạt yêu cầu</option>
                                <option value="financial">Lý do tài chính</option>
                                <option value="no_longer_need">Không còn nhu cầu sử dụng</option>
                                <option value="other">Lý do khác</option>
                            </select>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-bold">
                                <i class="fas fa-comment"></i> Mô tả chi tiết: <span class="text-danger">*</span>
                            </label>
                            <textarea class="form-control" name="terminationDescription" 
                                      rows="5" required 
                                      placeholder="Vui lòng mô tả chi tiết lý do chấm dứt hợp đồng..."
                                      minlength="50" maxlength="500"></textarea>
                            <small class="text-muted">Tối thiểu 50 ký tự, tối đa 500 ký tự</small>
                        </div>

                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" id="confirmTermination" required>
                            <label class="form-check-label" for="confirmTermination">
                                Tôi xác nhận đã đọc và hiểu rõ về việc chấm dứt hợp đồng. Tôi chịu trách nhiệm về quyết định này.
                            </label>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                            <i class="fas fa-times"></i> Hủy
                        </button>
                        <button type="submit" class="btn btn-danger">
                            <i class="fas fa-paper-plane"></i> Gửi Yêu Cầu
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    </div>
    <!-- END MAIN CONTENT WRAPPER -->

    <!-- LOADING SPINNER -->
    <div class="spinner-overlay" id="loadingSpinner">
        <div class="spinner-content">
            <div class="spinner-border text-primary" style="width: 3rem; height: 3rem;" role="status">
                <span class="visually-hidden">Loading...</span>
            </div>
            <p class="mt-3 mb-0">Đang xử lý...</p>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script>
        // ========== SIDEBAR TOGGLE ==========
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

        // ========== NOTIFICATION FUNCTIONS ==========
        function toggleNotifications() {
            const dropdown = document.getElementById('notificationDropdown');
            dropdown.classList.toggle('show');
        }

        function markAllAsRead() {
            document.querySelectorAll('.notification-item.unread').forEach(item => {
                item.classList.remove('unread');
            });
            document.getElementById('notificationCount').textContent = '0';
            
            Swal.fire({
                icon: 'success',
                title: 'Thành công!',
                text: 'Đã đánh dấu tất cả thông báo là đã đọc.',
                timer: 2000,
                showConfirmButton: false,
                position: 'top-end',
                toast: true
            });
        }

        function viewNotification(id) {
            // Mark as read
            event.target.closest('.notification-item').classList.remove('unread');
            
            // Update count
            const currentCount = parseInt(document.getElementById('notificationCount').textContent);
            if (currentCount > 0) {
                document.getElementById('notificationCount').textContent = currentCount - 1;
            }
            
            // Handle different notification types
            console.log('View notification:', id);
            toggleNotifications();
        }

        // Close dropdown when clicking outside
        document.addEventListener('click', function(event) {
            const dropdown = document.getElementById('notificationDropdown');
            const badge = document.querySelector('.notification-badge-header');
            
            if (badge && dropdown) {
                if (!badge.contains(event.target) && !dropdown.contains(event.target)) {
                    dropdown.classList.remove('show');
                }
            }
        });

        // ========== FILTER FUNCTIONS ==========
        function resetFilters() {
            window.location.href = '${pageContext.request.contextPath}/viewCustomerContract';
        }

        // ========== CONTRACT ACTIONS ==========
        function viewContractDetail(contractId) {
            console.log('View contract:', contractId);
            
            // Show loading
            document.getElementById('loadingSpinner').classList.add('show');
            
            // Simulate API call
            setTimeout(() => {
                document.getElementById('loadingSpinner').classList.remove('show');
                const modal = new bootstrap.Modal(document.getElementById('viewContractModal'));
                modal.show();
            }, 500);
        }

        function downloadContract(contractId) {
            Swal.fire({
                title: 'Tải xuống hợp đồng?',
                text: 'File PDF sẽ được tải về máy của bạn.',
                icon: 'question',
                showCancelButton: true,
                confirmButtonText: '<i class="fas fa-download"></i> Tải xuống',
                cancelButtonText: '<i class="fas fa-times"></i> Hủy',
                confirmButtonColor: '#198754',
                cancelButtonColor: '#6c757d'
            }).then((result) => {
                if (result.isConfirmed) {
                    // Show loading
                    document.getElementById('loadingSpinner').classList.add('show');
                    
                    // Simulate download
                    setTimeout(() => {
                        document.getElementById('loadingSpinner').classList.remove('show');
                        
                        Swal.fire({
                            icon: 'success',
                            title: 'Thành công!',
                            text: 'Hợp đồng đã được tải xuống.',
                            timer: 2000,
                            showConfirmButton: false
                        });
                        
                        // Actual download logic here
                        // window.location.href = contextPath + '/downloadContract?id=' + contractId;
                    }, 1500);
                }
            });
        }

        function requestTermination(contractId) {
            // Set contract info
            document.getElementById('terminationContractId').value = contractId;
            document.getElementById('terminationContractDisplay').value = 'HD' + String(contractId).padStart(3, '0');
            
            // Show modal
            const modal = new bootstrap.Modal(document.getElementById('terminationModal'));
            modal.show();
        }

        function submitTermination(event) {
            event.preventDefault();
            
            const form = event.target;
            const formData = new FormData(form);
            
            // Validate
            if (!form.checkValidity()) {
                form.classList.add('was-validated');
                return;
            }
            
            Swal.fire({
                title: 'Xác nhận gửi yêu cầu?',
                text: 'Yêu cầu chấm dứt hợp đồng sẽ được gửi đến bộ phận quản lý.',
                icon: 'warning',
                showCancelButton: true,
                confirmButtonText: '<i class="fas fa-paper-plane"></i> Xác nhận',
                cancelButtonText: '<i class="fas fa-times"></i> Hủy',
                confirmButtonColor: '#dc3545',
                cancelButtonColor: '#6c757d'
            }).then((result) => {
                if (result.isConfirmed) {
                    // Close modal
                    bootstrap.Modal.getInstance(document.getElementById('terminationModal')).hide();
                    
                    // Show loading
                    document.getElementById('loadingSpinner').classList.add('show');
                    
                    // Simulate API call
                    setTimeout(() => {
                        document.getElementById('loadingSpinner').classList.remove('show');
                        
                        Swal.fire({
                            icon: 'success',
                            title: 'Gửi thành công!',
                            html: 'Yêu cầu chấm dứt hợp đồng đã được gửi.<br>Chúng tôi sẽ xem xét và phản hồi trong vòng 3-5 ngày làm việc.',
                            confirmButtonText: 'Đóng'
                        }).then(() => {
                            // Reload page or update UI
                            // window.location.reload();
                        });
                        
                        // Reset form
                        form.reset();
                        form.classList.remove('was-validated');
                    }, 1500);
                }
            });
        }

        // ========== PAGE LOAD ==========
        document.addEventListener('DOMContentLoaded', function() {
            console.log('Customer Contract Management Page Loaded');
            
            // Check for URL parameters to show notifications
            const urlParams = new URLSearchParams(window.location.search);
            
            if (urlParams.get('success') === 'true') {
                Swal.fire({
                    icon: 'success',
                    title: 'Thành công!',
                    text: urlParams.get('message') || 'Thao tác đã được thực hiện thành công.',
                    timer: 3000,
                    showConfirmButton: false,
                    position: 'top-end',
                    toast: true
                });
            }
            
            if (urlParams.get('error') === 'true') {
                Swal.fire({
                    icon: 'error',
                    title: 'Lỗi!',
                    text: urlParams.get('message') || 'Đã xảy ra lỗi. Vui lòng thử lại.',
                    confirmButtonText: 'Đóng'
                });
            }
        });
    </script>
</body>
</html>
