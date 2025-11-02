<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>CRM Dashboard - Quản Lý Hóa Đơn</title>
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
                background: linear-gradient(135deg, #f5f7fa 0%, #e8ecf1 100%);
                overflow-x: hidden;
            }

            /* SIDEBAR STYLES */
            .sidebar {
                position: fixed;
                top: 0;
                left: 0;
                height: 100vh;
                width: 260px;
                background: linear-gradient(180deg, #1a1a2e 0%, #16213e 100%);
                padding: 0;
                transition: all 0.3s ease;
                z-index: 1000;
                box-shadow: 4px 0 20px rgba(0,0,0,0.15);
                display: flex;
                flex-direction: column;
            }

            .sidebar.collapsed {
                width: 70px;
            }

            .sidebar-header {
                padding: 25px 20px;
                background: rgba(0,0,0,0.3);
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
                text-shadow: 0 0 10px rgba(255, 193, 7, 0.5);
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
                background: linear-gradient(90deg, rgba(255,193,7,0.2), rgba(255,193,7,0.1));
                color: white;
                border-left: 4px solid #ffc107;
                box-shadow: 0 0 15px rgba(255, 193, 7, 0.3);
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
                background: rgba(0,0,0,0.3);
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
                box-shadow: 0 4px 10px rgba(255, 193, 7, 0.3);
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
                border: 1px solid rgba(255,255,255,0.3);
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
                background: linear-gradient(135deg, #dc3545, #c82333);
                color: white;
                border-color: #dc3545;
                transform: translateY(-2px);
                box-shadow: 0 4px 12px rgba(220, 53, 69, 0.3);
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
                box-shadow: 0 2px 10px rgba(0,0,0,0.08);
                display: flex;
                justify-content: space-between;
                align-items: center;
                backdrop-filter: blur(10px);
            }

            .page-title {
                font-size: 1.8rem;
                font-weight: 700;
                background: linear-gradient(135deg, #1e3c72, #2a5298);
                -webkit-background-clip: text;
                -webkit-text-fill-color: transparent;
                margin: 0;
                display: flex;
                align-items: center;
                gap: 12px;
            }

            .page-title i {
                background: linear-gradient(135deg, #ffc107, #ff9800);
                -webkit-background-clip: text;
                -webkit-text-fill-color: transparent;
            }

            .content-wrapper {
                padding: 30px;
            }

            .stats-card {
                border-radius: 15px;
                padding: 25px;
                margin-bottom: 20px;
                box-shadow: 0 4px 15px rgba(0,0,0,0.1);
                transition: all 0.3s;
                position: relative;
                overflow: hidden;
            }

            .stats-card::before {
                content: '';
                position: absolute;
                top: -50%;
                right: -50%;
                width: 200%;
                height: 200%;
                background: radial-gradient(circle, rgba(255,255,255,0.2) 0%, transparent 70%);
                animation: pulse 3s ease-in-out infinite;
            }

            @keyframes pulse {
                0%, 100% {
                    transform: scale(0.8);
                    opacity: 0.3;
                }
                50% {
                    transform: scale(1.2);
                    opacity: 0.5;
                }
            }

            .stats-card:hover {
                transform: translateY(-8px);
                box-shadow: 0 8px 25px rgba(0,0,0,0.2);
            }

            .stats-card i {
                font-size: 2.8rem;
                opacity: 0.9;
            }

            .stats-card h6 {
                font-size: 0.9rem;
                font-weight: 600;
                margin-bottom: 8px;
                opacity: 0.9;
            }

            .stats-card h2 {
                font-size: 2rem;
                font-weight: 700;
                margin: 0;
            }

            .table-container {
                background: white;
                border-radius: 15px;
                padding: 30px;
                box-shadow: 0 4px 20px rgba(0,0,0,0.08);
                margin-top: 20px;
            }

            .table {
                margin-bottom: 0;
            }

            .table thead th {
                border-bottom: 2px solid #dee2e6;
                font-weight: 600;
                color: #1e3c72;
                text-transform: uppercase;
                font-size: 0.85rem;
                letter-spacing: 0.5px;
                padding: 15px 10px;
            }

            .table tbody tr {
                transition: all 0.3s;
            }

            .table tbody tr:hover {
                background-color: rgba(30, 60, 114, 0.05);
                transform: scale(1.01);
            }

            .table tbody td {
                vertical-align: middle;
                padding: 15px 10px;
            }

            .badge-paid {
                background: linear-gradient(135deg, #198754, #157347);
                padding: 6px 12px;
                border-radius: 20px;
                font-size: 0.8rem;
            }

            .badge-pending {
                background: linear-gradient(135deg, #ffc107, #ffb300);
                color: #000;
                padding: 6px 12px;
                border-radius: 20px;
                font-size: 0.8rem;
            }

            .badge-overdue {
                background: linear-gradient(135deg, #dc3545, #c82333);
                padding: 6px 12px;
                border-radius: 20px;
                font-size: 0.8rem;
            }

            .search-filter-bar {
                background: white;
                padding: 25px;
                border-radius: 15px;
                margin-bottom: 20px;
                box-shadow: 0 4px 15px rgba(0,0,0,0.08);
            }

            .form-control {
                border-radius: 10px;
                border: 2px solid #e9ecef;
                padding: 12px 15px;
                transition: all 0.3s;
            }

            .form-control:focus {
                border-color: #ffc107;
                box-shadow: 0 0 0 0.2rem rgba(255, 193, 7, 0.25);
            }

            .btn {
                border-radius: 10px;
                padding: 10px 20px;
                font-weight: 600;
                transition: all 0.3s;
            }

            .btn-primary {
                background: linear-gradient(135deg, #1e3c72, #2a5298);
                border: none;
            }

            .btn-primary:hover {
                background: linear-gradient(135deg, #2a5298, #1e3c72);
                transform: translateY(-2px);
                box-shadow: 0 4px 12px rgba(30, 60, 114, 0.3);
            }

            .btn-secondary {
                background: linear-gradient(135deg, #6c757d, #5a6268);
                border: none;
            }

            .btn-secondary:hover {
                background: linear-gradient(135deg, #5a6268, #545b62);
                transform: translateY(-2px);
                box-shadow: 0 4px 12px rgba(108, 117, 125, 0.3);
            }

            .btn-info {
                background: linear-gradient(135deg, #0dcaf0, #0aa2c0);
                border: none;
            }

            .btn-info:hover {
                background: linear-gradient(135deg, #0aa2c0, #0987a0);
                transform: translateY(-2px);
                box-shadow: 0 4px 12px rgba(13, 202, 240, 0.3);
            }

            .btn-action {
                padding: 6px 12px;
                margin: 0 2px;
                font-size: 0.85rem;
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
                border-radius: 12px;
                padding: 15px 20px;
                box-shadow: 0 8px 20px rgba(0,0,0,0.15);
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
                position: relative;
            }

            .site-footer::before {
                content: '';
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                height: 1px;
                background: linear-gradient(90deg, transparent, rgba(255,193,7,0.5), transparent);
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
                margin-bottom: 40px;
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
                height: 3px;
                background: linear-gradient(90deg, #ffc107, transparent);
                border-radius: 2px;
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

            .footer-social {
                display: flex;
                gap: 15px;
            }

            .social-link {
                width: 40px;
                height: 40px;
                border-radius: 50%;
                background: rgba(255,255,255,0.1);
                display: flex;
                align-items: center;
                justify-content: center;
                color: white;
                text-decoration: none;
                transition: all 0.3s;
            }

            .social-link:hover {
                background: #ffc107;
                color: #1a202c;
                transform: translateY(-3px);
            }

            .scroll-to-top {
                position: fixed;
                bottom: 30px;
                right: 30px;
                width: 50px;
                height: 50px;
                background: linear-gradient(135deg, #ffc107, #ff9800);
                color: white;
                border-radius: 50%;
                display: none;
                align-items: center;
                justify-content: center;
                cursor: pointer;
                transition: all 0.3s;
                z-index: 999;
                box-shadow: 0 4px 15px rgba(255, 193, 7, 0.4);
            }

            .scroll-to-top:hover {
                background: linear-gradient(135deg, #ff9800, #ffc107);
                transform: translateY(-5px);
                box-shadow: 0 6px 20px rgba(255, 193, 7, 0.6);
            }

            .scroll-to-top.show {
                display: flex;
            }

            /* RESPONSIVE */
            @media (max-width: 1200px) {
                .footer-grid {
                    grid-template-columns: repeat(2, 1fr);
                    gap: 40px;
                }
            }

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

                .page-title {
                    font-size: 1.3rem;
                }

                .stats-card h2 {
                    font-size: 1.5rem;
                }

                .top-navbar {
                    flex-direction: column;
                    gap: 15px;
                    align-items: flex-start;
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
                    <a href="${pageContext.request.contextPath}/equipment" class="menu-item">
                        <i class="fas fa-tools"></i>
                        <span>Thiết Bị</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/invoices" class="menu-item active">
                        <i class="fas fa-file-invoice-dollar"></i>
                        <span>Hóa Đơn</span>
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
                <h1 class="page-title">
                    <i class="fas fa-file-invoice-dollar"></i>
                    Quản Lý Hóa Đơn
                </h1>
                <div class="d-flex gap-2">
                    <button class="btn btn-secondary" onclick="refreshPage()">
                        <i class="fas fa-sync-alt"></i> Làm Mới
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
                                    <h6>Tổng Hóa Đơn</h6>
                                    <h2>${totalInvoices != null ? totalInvoices : 0}</h2>
                                </div>
                                <i class="fas fa-file-invoice"></i>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-lg-6 col-md-6 col-sm-6">
                        <div class="stats-card bg-success text-white">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h6>Đã Thanh Toán</h6>
                                    <h2>${paidCount != null ? paidCount : 0}</h2>
                                </div>
                                <i class="fas fa-check-circle"></i>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-lg-6 col-md-6 col-sm-6">
                        <div class="stats-card bg-warning text-dark">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h6>Chưa Thanh Toán</h6>
                                    <h2>${pendingCount != null ? pendingCount : 0}</h2>
                                </div>
                                <i class="fas fa-clock"></i>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-lg-6 col-md-6 col-sm-6">
                        <div class="stats-card" style="background: linear-gradient(135deg, #8b5cf6, #7c3aed); color: white;">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h6>Tổng Tiền</h6>
                                    <h2><fmt:formatNumber value="${totalAmount != null ? totalAmount : 0}" pattern="#,###" /> đ</h2>
                                </div>
                                <i class="fas fa-dollar-sign"></i>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- SEARCH BAR -->
                <div class="search-filter-bar">
                    <form action="${pageContext.request.contextPath}/invoices" method="get" class="row g-3">
                        <div class="col-md-10">
                            <div class="input-group">
                                <span class="input-group-text bg-white border-end-0">
                                    <i class="fas fa-search text-muted"></i>
                                </span>
                                <input type="text" class="form-control border-start-0" name="keyword" 
                                       placeholder="Tìm kiếm theo mã hóa đơn, số tiền..." value="${keyword}">
                                <button class="btn btn-primary" type="submit" name="action" value="search">
                                    <i class="fas fa-search"></i> Tìm Kiếm
                                </button>
                            </div>
                        </div>
                        <div class="col-md-2">
                            <c:if test="${searchMode}">
                                <a href="${pageContext.request.contextPath}/invoices" class="btn btn-secondary w-100">
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
                            <c:when test="${not empty invoiceList}">
                                <table class="table table-hover">
                                    <thead class="table-light">
                                        <tr>
                                            <th><i class="fas fa-hashtag me-2"></i>Mã HĐ</th>
                                            <th><i class="fas fa-file-contract me-2"></i>Mã Hợp Đồng</th>
                                            <th><i class="fas fa-calendar-alt me-2"></i>Ngày Phát Hành</th>
                                            <th><i class="fas fa-calendar-check me-2"></i>Hạn Thanh Toán</th>
                                            <th><i class="fas fa-money-bill-wave me-2"></i>Tổng Tiền</th>
                                            <th><i class="fas fa-info-circle me-2"></i>Trạng Thái</th>
                                            <th class="text-center"><i class="fas fa-cog me-2"></i>Thao Tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="item" items="${invoiceList}" varStatus="status">
                                            <tr>
                                                <td><strong class="text-primary">#INV${item.invoice.invoiceId}</strong></td>
                                                <td><span class="badge bg-primary">${item.formattedContractId}</span></td>
                                                <td><i class="fas fa-calendar text-muted me-2"></i><fmt:formatDate value="${item.invoice.issueDate}" pattern="dd/MM/yyyy"/></td>
                                                <td><i class="fas fa-calendar text-muted me-2"></i><fmt:formatDate value="${item.invoice.dueDate}" pattern="dd/MM/yyyy"/></td>
                                                <td><strong class="text-success"><fmt:formatNumber value="${item.invoice.totalAmount}" pattern="#,###"/> đ</strong></td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${item.invoice.status == 'Paid'}">
                                                            <span class="badge badge-paid">
                                                                <i class="fas fa-check-circle"></i> Đã Thanh Toán
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${item.invoice.status == 'Pending'}">
                                                            <span class="badge badge-pending">
                                                                <i class="fas fa-clock"></i> Chưa Thanh Toán
                                                            </span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge badge-overdue">
                                                                <i class="fas fa-exclamation-triangle"></i> Quá Hạn
                                                            </span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td class="text-center">
                                                    <a href="${pageContext.request.contextPath}/invoices?action=view&id=${item.invoice.invoiceId}" 
                                                       class="btn btn-sm btn-info btn-action">
                                                        <i class="fas fa-eye"></i> Chi Tiết
                                                    </a>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </c:when>
                            <c:otherwise>
                                <div class="text-center py-5">
                                    <i class="fas fa-inbox fa-4x text-muted mb-3" style="opacity: 0.3;"></i>
                                    <h4 class="text-muted">Không tìm thấy hóa đơn</h4>
                                    <p class="text-muted">
                                        <c:choose>
                                            <c:when test="${searchMode}">
                                                Không tìm thấy hóa đơn phù hợp với từ khóa "<strong>${keyword}</strong>"
                                            </c:when>
                                            <c:otherwise>
                                                Hiện tại bạn chưa có hóa đơn nào trong hệ thống
                                            </c:otherwise>
                                        </c:choose>
                                    </p>
                                    <c:if test="${searchMode}">
                                        <a href="${pageContext.request.contextPath}/invoices" class="btn btn-primary mt-3">
                                            <i class="fas fa-arrow-left"></i> Quay lại danh sách
                                        </a>
                                    </c:if>
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
                                <li><a href="#">→ Quản lý hóa đơn</a></li>
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
                                <li><a href="#">→ Điều khoản dịch vụ</a></li>
                                <li><a href="#">→ Chính sách bảo mật</a></li>
                                <li><a href="#">→ Liên hệ</a></li>
                            </ul>
                        </div>
                    </div>

                    <div class="footer-bottom">
                        <div class="footer-copyright">
                            © 2025 CRM System. All rights reserved. Made with <i class="fas fa-heart text-danger"></i> in Vietnam
                        </div>
                        <div class="footer-social">
                            <a href="#" class="social-link" title="Facebook">
                                <i class="fab fa-facebook-f"></i>
                            </a>
                            <a href="#" class="social-link" title="Twitter">
                                <i class="fab fa-twitter"></i>
                            </a>
                            <a href="#" class="social-link" title="LinkedIn">
                                <i class="fab fa-linkedin-in"></i>
                            </a>
                            <a href="#" class="social-link" title="Instagram">
                                <i class="fab fa-instagram"></i>
                            </a>
                        </div>
                    </div>
                </div>
            </footer>
        </div>

        <!-- SCROLL TO TOP BUTTON -->
        <div class="scroll-to-top" id="scrollToTop">
            <i class="fas fa-arrow-up"></i>
        </div>

        <!-- SCRIPTS -->
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

                        // Refresh Page
                        function refreshPage() {
                            location.reload();
                        }

                        // Toast Notification Function
                        function showToast(message, type = 'success') {
                            const container = document.getElementById('toastContainer');
                            const toast = document.createElement('div');
                            toast.className = 'toast-notification ' + type;

                            const icon = type === 'success' ? 'fa-check-circle' : 'fa-exclamation-circle';

                            toast.innerHTML =
                                    '<div class="toast-icon ' + type + '">' +
                                    '<i class="fas ' + icon + '"></i>' +
                                    '</div>' +
                                    '<div class="toast-content">' +
                                    '<strong>' + (type === 'success' ? 'Thành công!' : 'Lỗi!') + '</strong>' +
                                    '<p style="margin: 0; font-size: 0.9rem;">' + message + '</p>' +
                                    '</div>' +
                                    '<button class="toast-close" onclick="closeToast(this)">' +
                                    '<i class="fas fa-times"></i>' +
                                    '</button>';

                            container.appendChild(toast);

                            setTimeout(function () {
                                toast.classList.add('hiding');
                                setTimeout(function () {
                                    toast.remove();
                                }, 400);
                            }, 5000);
                        }

                        function closeToast(btn) {
                            const toast = btn.closest('.toast-notification');
                            toast.classList.add('hiding');
                            setTimeout(() => toast.remove(), 400);
                        }

                        // Scroll to Top
                        const scrollToTopBtn = document.getElementById('scrollToTop');

                        window.addEventListener('scroll', () => {
                            if (window.pageYOffset > 300) {
                                scrollToTopBtn.classList.add('show');
                            } else {
                                scrollToTopBtn.classList.remove('show');
                            }
                        });

                        scrollToTopBtn.addEventListener('click', () => {
                            window.scrollTo({
                                top: 0,
                                behavior: 'smooth'
                            });
                        });

                        // Check for URL parameters to show toast
                        window.addEventListener('DOMContentLoaded', () => {
                            const urlParams = new URLSearchParams(window.location.search);
                            const success = urlParams.get('success');
                            const error = urlParams.get('error');

                            if (success) {
                                showToast(decodeURIComponent(success), 'success');
                            }
                            if (error) {
                                showToast(decodeURIComponent(error), 'error');
                            }
                        });

                        // Mobile Sidebar Toggle
                        if (window.innerWidth <= 768) {
                            const sidebar = document.getElementById('sidebar');
                            document.addEventListener('click', (e) => {
                                if (!sidebar.contains(e.target) && sidebar.classList.contains('show')) {
                                    sidebar.classList.remove('show');
                                }
                            });
                        }

                        // Add animation to stats cards on page load
                        window.addEventListener('load', () => {
                            const statsCards = document.querySelectorAll('.stats-card');
                            statsCards.forEach((card, index) => {
                                setTimeout(() => {
                                    card.style.opacity = '0';
                                    card.style.transform = 'translateY(20px)';
                                    card.style.transition = 'all 0.5s ease';

                                    setTimeout(() => {
                                        card.style.opacity = '1';
                                        card.style.transform = 'translateY(0)';
                                    }, 50);
                                }, index * 100);
                            });
                        });
        </script>
    </body>
</html>