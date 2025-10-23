<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>CRM Dashboard - Manager Service Request</title>
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

            .badge-pending {
                background-color: #ffc107;
                color: #000;
            }
            .badge-inprogress {
                background-color: #0dcaf0;
            }
            .badge-completed {
                background-color: #198754;
            }
            .badge-cancelled {
                background-color: #dc3545;
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

            .toast-notification.info {
                border-left: 4px solid #0dcaf0;
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

            .toast-icon.info {
                color: #0dcaf0;
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

            /* CSS cho description display */
            .description-display {
                white-space: pre-wrap !important;
                word-wrap: break-word !important;
                word-break: break-word !important;
                overflow-wrap: anywhere !important;
                max-height: 300px;
                overflow-y: auto;
                overflow-x: hidden;
                line-height: 1.6;
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            }

            .description-display::-webkit-scrollbar {
                width: 8px;
            }

            .description-display::-webkit-scrollbar-thumb {
                background: rgba(0,0,0,0.2);
                border-radius: 4px;
            }

            .description-display::-webkit-scrollbar-thumb:hover {
                background: rgba(0,0,0,0.3);
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

            .footer-version {
                color: rgba(255, 255, 255, 0.6);
                font-size: 0.9rem;
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

            .footer-contact-item {
                display: flex;
                align-items: flex-start;
                gap: 12px;
                margin-bottom: 15px;
                color: rgba(255, 255, 255, 0.8);
                font-size: 0.9rem;
            }

            .footer-contact-item i {
                font-size: 1rem;
                color: #ffc107;
                margin-top: 3px;
            }

            .footer-stats {
                list-style: none;
                padding: 0;
                margin: 0;
            }

            .footer-stats li {
                margin-bottom: 12px;
                display: flex;
                align-items: center;
                gap: 10px;
                color: rgba(255, 255, 255, 0.8);
                font-size: 0.9rem;
            }

            .footer-stats i {
                color: #ffc107;
                font-size: 1rem;
            }

            .footer-certifications {
                display: flex;
                gap: 10px;
                margin-top: 20px;
                flex-wrap: wrap;
            }

            .cert-badge {
                background: rgba(255, 255, 255, 0.1);
                padding: 6px 12px;
                border-radius: 6px;
                display: flex;
                align-items: center;
                gap: 6px;
                font-size: 0.8rem;
                transition: all 0.3s;
            }

            .cert-badge:hover {
                background: rgba(255, 255, 255, 0.2);
                transform: translateY(-2px);
            }

            .cert-badge i {
                color: #ffc107;
            }

            .footer-divider {
                height: 1px;
                background: linear-gradient(to right, transparent, rgba(255,255,255,0.2), transparent);
                margin-bottom: 40px;
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

            .footer-bottom-links {
                display: flex;
                gap: 25px;
            }

            .footer-bottom-links a {
                color: rgba(255, 255, 255, 0.7);
                text-decoration: none;
                font-size: 0.9rem;
                transition: all 0.3s;
            }

            .footer-bottom-links a:hover {
                color: #ffc107;
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

                .footer-bottom-links {
                    flex-direction: column;
                    gap: 10px;
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

                    <a href="${pageContext.request.contextPath}/dashboard" class="menu-item">
                        <i class="fas fa-home"></i>
                        <span>Dashboard</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/managerServiceRequest" class="menu-item active">
                        <i class="fas fa-clipboard-list"></i>
                        <span>Yêu Cầu Dịch Vụ</span>
                        <span class="badge bg-warning">${pendingCount}</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/contracts" class="menu-item">
                        <i class="fas fa-file-contract"></i>
                        <span>Hợp Đồng</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/equipment" class="menu-item">
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
                <h1 class="page-title"><i class="fas fa-clipboard-list"></i> Yêu Cầu Dịch Vụ</h1>
                <div class="d-flex gap-2">
                    <button class="btn btn-secondary" onclick="refreshPage()">
                        <i class="fas fa-sync"></i> Làm Mới
                    </button>
                    <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#createModal">
                        <i class="fas fa-plus"></i> Tạo Yêu Cầu Mới
                    </button>
                </div>
            </div>

            <div id="toastContainer"></div>

            <div class="content-wrapper">
                <%
                    String errorMsg = (String) session.getAttribute("error");
                    String successMsg = (String) session.getAttribute("success");
                    String infoMsg = (String) session.getAttribute("info");
                %>

                <% if (errorMsg != null || successMsg != null || infoMsg != null) { %>
                <script>
                    window.addEventListener('load', function () {
                    <% if (errorMsg != null) { 
                            session.removeAttribute("error");
                    %>
                        setTimeout(function () {
                            showToast('<%= errorMsg.replace("'", "\\'").replace("\"", "\\\"") %>', 'error');
                        }, 100);
                    <% } %>

                    <% if (successMsg != null) { 
                            session.removeAttribute("success");
                    %>
                        setTimeout(function () {
                            showToast('<%= successMsg.replace("'", "\\'").replace("\"", "\\\"") %>', 'success');
                        }, 100);
                    <% } %>

                    <% if (infoMsg != null) { 
                            session.removeAttribute("info");
                    %>
                        setTimeout(function () {
                            showToast('<%= infoMsg.replace("'", "\\'").replace("\"", "\\\"") %>', 'info');
                        }, 100);
                    <% } %>
                    });
                </script>
                <% } %>

                <!-- THỐNG KÊ - 5 Ô TRẢI ĐỀU TOÀN MÀN HÌNH -->
                <div class="row">
                    <div class="col-xl col-lg-4 col-md-6 col-sm-6">
                        <div class="stats-card bg-primary text-white">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h6>Tổng Yêu Cầu</h6>
                                    <h2>${totalRequests}</h2>
                                </div>
                                <i class="fas fa-clipboard-list"></i>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl col-lg-4 col-md-6 col-sm-6">
                        <div class="stats-card bg-warning text-dark">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h6>Chờ Xử Lý</h6>
                                    <h2>${pendingCount}</h2>
                                </div>
                                <i class="fas fa-clock"></i>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl col-lg-4 col-md-6 col-sm-6">
                        <div class="stats-card bg-info text-white">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h6>Đã Duyệt</h6>
                                    <h2>${inProgressCount}</h2>
                                </div>
                                <i class="fas fa-spinner"></i>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl col-lg-6 col-md-6 col-sm-6">
                        <div class="stats-card bg-success text-white">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h6>Hoàn Thành</h6>
                                    <h2>${completedCount}</h2>
                                </div>
                                <i class="fas fa-check-circle"></i>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl col-lg-6 col-md-6 col-sm-6">
                        <div class="stats-card bg-danger text-white">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h6>Đã Hủy</h6>
                                    <h2>${cancelledCount}</h2>
                                </div>
                                <i class="fas fa-times-circle"></i>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- SEARCH & FILTER BAR -->
                <div class="search-filter-bar">
                    <form action="${pageContext.request.contextPath}/managerServiceRequest" method="get" class="row g-3">
                        <div class="col-md-6">
                            <div class="input-group">
                                <input type="text" class="form-control" name="keyword" 
                                       placeholder="Tìm kiếm theo mô tả, ID..." value="${keyword}">
                                <button class="btn btn-primary" type="submit" name="action" value="search">
                                    <i class="fas fa-search"></i> Tìm Kiếm
                                </button>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <select class="form-select" name="status" id="filterStatus">
                                <option value="">-- Tất Cả Trạng Thái --</option>
                                <option value="Pending" ${filterStatus == 'Pending' ? 'selected' : ''}>Chờ Xử Lý</option>
                                <option value="Approved" ${filterStatus == 'Approved' ? 'selected' : ''}>Đã Duyệt</option>
                                <option value="Completed" ${filterStatus == 'Completed' ? 'selected' : ''}>Hoàn Thành</option>
                                <option value="Rejected" ${filterStatus == 'Rejected' ? 'selected' : ''}>Bị từ chối</option>
                                <option value="Cancelled" ${filterStatus == 'Cancelled' ? 'selected' : ''}>Đã Hủy</option>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <button type="submit" name="action" value="filter" class="btn btn-info w-100">
                                <i class="fas fa-filter"></i> Lọc
                            </button>
                        </div>
                    </form>
                    <c:if test="${searchMode || filterMode}">
                        <div class="mt-2">
                            <a href="${pageContext.request.contextPath}/managerServiceRequest" class="btn btn-sm btn-secondary">
                                <i class="fas fa-times"></i> Xóa Bộ Lọc
                            </a>
                        </div>
                    </c:if>
                </div>

                <!-- BẢNG DANH SÁCH -->
                <div class="table-container">
                    <div class="table-responsive">
                        <table class="table table-hover">
                            <thead class="table-light">
                                <tr>
                                    <th>Hợp Đồng</th>
                                    <th>Thiết Bị</th>
                                    <th>Mô Tả</th>
                                    <th>Ngày Tạo</th>
                                    <th>Trạng Thái</th>
                                    <th>Thao Tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="req" items="${requests}">
                                    <tr>
                                        <td>${req.contractId}</td>
                                        <td>${req.equipmentId}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${req.description.length() > 60}">
                                                    ${req.description.substring(0, 60)}...
                                                </c:when>
                                                <c:otherwise>
                                                    ${req.description}
                                                </c:otherwise>
                                            </c:choose>
                                            <!-- Hidden div chứa full description -->
                                            <div class="d-none" id="desc-${req.requestId}"><c:out value="${req.description}"/></div>
                                        </td>
                                        <td>
                                            <fmt:formatDate value="${req.requestDate}" pattern="dd/MM/yyyy"/>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${req.status == 'Pending'}"><span class="badge badge-pending">Chờ Xử Lý</span></c:when>
                                                <c:when test="${req.status == 'Approved'}"><span class="badge badge-inprogress">Đã Duyệt</span></c:when>
                                                <c:when test="${req.status == 'Completed'}"><span class="badge badge-completed">Hoàn Thành</span></c:when>
                                                <c:when test="${req.status == 'Rejected'}"><span class="badge badge-cancelled">Bị từ chối</span></c:when>
                                                <c:when test="${req.status == 'Cancelled'}"><span class="badge badge-cancelled">Đã Hủy</span></c:when>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <button class="btn btn-sm btn-info btn-action btn-view"
                                                    data-id="${req.requestId}"
                                                    data-contract-id="${req.contractId}"
                                                    data-equipment-id="${req.equipmentId}"
                                                    data-request-date="<fmt:formatDate value="${req.requestDate}" pattern="dd/MM/yyyy"/>"
                                                    data-status="${req.status}"
                                                    data-priority="${req.priorityLevel}">
                                                <i class="fas fa-eye"></i> Chi Tiết
                                            </button>

                                            <c:if test="${req.status == 'Pending'}">
                                                <button class="btn btn-sm btn-warning btn-action btn-edit"
                                                        data-id="${req.requestId}"
                                                        data-description="${fn:escapeXml(req.description)}"
                                                        data-priority="${req.priorityLevel}">
                                                    <i class="fas fa-edit"></i> Sửa
                                                </button>
                                                <button class="btn btn-sm btn-danger btn-action btn-cancel"
                                                        data-id="${req.requestId}">
                                                    <i class="fas fa-times-circle"></i> Hủy
                                                </button>
                                            </c:if>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty requests}">
                                    <tr>
                                        <td colspan="6" class="text-center py-4">
                                            <i class="fas fa-inbox fa-3x text-muted mb-3"></i>
                                            <p class="text-muted">Bạn chưa có yêu cầu dịch vụ nào</p>
                                            <button class="btn btn-primary mt-2" data-bs-toggle="modal" data-bs-target="#createModal">
                                                <i class="fas fa-plus"></i> Tạo Yêu Cầu Đầu Tiên
                                            </button>
                                        </td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>

                    <!-- PHÂN TRANG -->
                    <c:if test="${totalPages > 1}">
                        <nav aria-label="Page navigation" class="mt-4">
                            <ul class="pagination justify-content-center">
                                <li class="page-item ${currentPage <= 1 ? 'disabled' : ''}">
                                    <c:if test="${currentPage > 1}">
                                        <a class="page-link" href="?page=${currentPage - 1}${filterStatus != null ? '&status='.concat(filterStatus) : ''}${keyword != null ? '&keyword='.concat(keyword) : ''}&action=${filterMode ? 'filter' : (searchMode ? 'search' : '')}">
                                            <i class="fas fa-chevron-left"></i> Trước
                                        </a>
                                    </c:if>
                                    <c:if test="${currentPage <= 1}">
                                        <span class="page-link">
                                            <i class="fas fa-chevron-left"></i> Trước
                                        </span>
                                    </c:if>
                                </li>

                                <c:forEach var="i" begin="1" end="${totalPages}">
                                    <li class="page-item ${i == currentPage ? 'active' : ''}">
                                        <c:if test="${i != currentPage}">
                                            <a class="page-link" href="?page=${i}${filterStatus != null ? '&status='.concat(filterStatus) : ''}${keyword != null ? '&keyword='.concat(keyword) : ''}&action=${filterMode ? 'filter' : (searchMode ? 'search' : '')}">
                                                ${i}
                                            </a>
                                        </c:if>
                                        <c:if test="${i == currentPage}">
                                            <span class="page-link">${i}</span>
                                        </c:if>
                                    </li>
                                </c:forEach>

                                <li class="page-item ${currentPage >= totalPages ? 'disabled' : ''}">
                                    <c:if test="${currentPage < totalPages}">
                                        <a class="page-link" href="?page=${currentPage + 1}${filterStatus != null ? '&status='.concat(filterStatus) : ''}${keyword != null ? '&keyword='.concat(keyword) : ''}&action=${filterMode ? 'filter' : (searchMode ? 'search' : '')}">
                                            Tiếp <i class="fas fa-chevron-right"></i>
                                        </a>
                                    </c:if>
                                    <c:if test="${currentPage >= totalPages}">
                                        <span class="page-link">
                                            Tiếp <i class="fas fa-chevron-right"></i>
                                        </span>
                                    </c:if>
                                </li>
                            </ul>
                        </nav>

                        <div class="text-center text-muted mb-3">
                            <small>
                                Trang <strong>${currentPage}</strong> của <strong>${totalPages}</strong> 
                                | Hiển thị <strong>${fn:length(requests)}</strong> yêu cầu
                            </small>
                        </div>
                    </c:if>
                </div>
            </div>

            <!-- FOOTER -->
            <footer class="site-footer">
                <div class="footer-content">
                    <!-- Main Footer Content -->
                    <div class="footer-grid">
                        <!-- About Section -->
                        <div class="footer-section">
                            <h5>CRM System</h5>
                            <p class="footer-about">
                                Giải pháp quản lý khách hàng toàn diện, giúp doanh nghiệp tối ưu hóa quy trình và nâng cao chất lượng dịch vụ.
                            </p>
                            <p class="footer-version">
                                <strong>Version:</strong> 1.0.0<br>
                                <strong>Phiên bản:</strong> Enterprise Edition
                            </p>
                        </div>

                        <!-- Products & Features -->
                        <div class="footer-section">
                            <h5>Tính năng chính</h5>
                            <ul class="footer-links">
                                <li><a href="#">→ Quản lý khách hàng</a></li>
                                <li><a href="#">→ Quản lý hợp đồng</a></li>
                                <li><a href="#">→ Quản lý thiết bị</a></li>
                                <li><a href="#">→ Báo cáo & Phân tích</a></li>
                                <li><a href="#">→ Quản lý yêu cầu dịch vụ</a></li>
                            </ul>
                        </div>

                        <!-- Support & Help -->
                        <div class="footer-section">
                            <h5>Hỗ trợ & Trợ giúp</h5>
                            <ul class="footer-links">
                                <li><a href="#">→ Trung tâm trợ giúp</a></li>
                                <li><a href="#">→ Hướng dẫn sử dụng</a></li>
                                <li><a href="#">→ Liên hệ hỗ trợ</a></li>
                                <li><a href="#">→ Câu hỏi thường gặp</a></li>
                                <li><a href="#">→ Yêu cầu tính năng</a></li>
                            </ul>
                        </div>

                        <!-- Company Info -->
                        <div class="footer-section">
                            <h5>Thông tin công ty</h5>
                            <ul class="footer-links">
                                <li><a href="#">→ Về chúng tôi</a></li>
                                <li><a href="#">→ Điều khoản sử dụng</a></li>
                                <li><a href="#">→ Chính sách bảo mật</a></li>
                                <li><a href="#">→ Bảo mật dữ liệu</a></li>
                                <li><a href="#">→ Liên hệ</a></li>
                            </ul>
                        </div>
                    </div>

                    <!-- Divider -->
                    <div class="footer-divider"></div>

                    <!-- Bottom Info -->
                    <div class="footer-grid" style="margin-bottom: 30px;">
                        <!-- Contact Info -->
                        <div>
                            <h5 style="font-size: 14px; text-transform: uppercase; letter-spacing: 0.5px;">Liên hệ</h5>
                            <div class="footer-contact-item">
                                <i class="fas fa-envelope"></i>
                                <span><strong>Email:</strong> support@crmsystem.com</span>
                            </div>
                            <div class="footer-contact-item">
                                <i class="fas fa-phone"></i>
                                <span><strong>Hotline:</strong> (+84) 123 456 7890</span>
                            </div>
                            <div class="footer-contact-item">
                                <i class="fas fa-map-marker-alt"></i>
                                <span><strong>Địa chỉ:</strong> Ho Chi Minh City, Vietnam</span>
                            </div>
                            <div class="footer-contact-item">
                                <i class="fas fa-clock"></i>
                                <span><strong>Hỗ trợ:</strong> 24/7</span>
                            </div>
                        </div>

                        <!-- Stats -->
                        <div>
                            <h5 style="font-size: 14px; text-transform: uppercase; letter-spacing: 0.5px;">Thống kê</h5>
                            <ul class="footer-stats">
                                <li><i class="fas fa-users"></i> <span>Người dùng: <strong>5,000+</strong></span></li>
                                <li><i class="fas fa-building"></i> <span>Công ty: <strong>1,200+</strong></span></li>
                                <li><i class="fas fa-database"></i> <span>Dữ liệu: <strong>500K+</strong></span></li>
                                <li><i class="fas fa-star"></i> <span>Đánh giá: <strong>4.9/5.0</strong></span></li>
                            </ul>
                        </div>

                        <!-- Certification -->
                        <div style="grid-column: span 2;">
                            <h5 style="font-size: 14px; text-transform: uppercase; letter-spacing: 0.5px;">Chứng chỉ</h5>
                            <div class="footer-certifications">
                                <div class="cert-badge">
                                    <i class="fas fa-lock"></i>
                                    <span>ISO 27001</span>
                                </div>
                                <div class="cert-badge">
                                    <i class="fas fa-check-circle"></i>
                                    <span>GDPR</span>
                                </div>
                                <div class="cert-badge">
                                    <i class="fas fa-shield-alt"></i>
                                    <span>SOC 2</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Footer Bottom -->
                    <div class="footer-bottom">
                        <p class="footer-copyright">
                            &copy; 2025 CRM System. All rights reserved. | Phát triển bởi <strong>Group 6</strong>
                        </p>
                        <div class="footer-bottom-links">
                            <a href="#">Chính sách bảo mật</a>
                            <a href="#">Điều khoản dịch vụ</a>
                            <a href="#">Cài đặt Cookie</a>
                        </div>
                    </div>
                </div>
            </footer>

            <!-- Scroll to Top Button -->
            <div class="scroll-to-top" id="scrollToTop" onclick="scrollToTop()">
                <i class="fas fa-arrow-up"></i>
            </div>
        </div>

        <!-- ========== MODAL TẠO YÊU CẦU MỚI ========== -->
        <div class="modal fade" id="createModal" tabindex="-1">
            <div class="modal-dialog">
                <div class="modal-content">
                    <form action="${pageContext.request.contextPath}/managerServiceRequest" method="post" id="createForm" onsubmit="return validateCreateForm(event)">
                        <input type="hidden" name="action" value="CreateServiceRequest">
                        <div class="modal-header bg-primary text-white">
                            <h5 class="modal-title"><i class="fas fa-plus"></i> Tạo Yêu Cầu Dịch Vụ Mới</h5>
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                        </div>
                        <div class="modal-body">
                            <!-- LOẠI ĐƠN -->
                            <div class="mb-3">
                                <label class="form-label">Loại Hỗ Trợ <span class="text-danger">*</span></label>
                                <select class="form-select" name="supportType" id="supportType" onchange="toggleFields()" required>
                                    <option value="" selected disabled>Chọn loại hỗ trợ bạn cần</option>
                                    <option value="account">🔐 Hỗ trợ về tài khoản</option>
                                    <option value="equipment">🔧 Hỗ trợ về thiết bị</option>
                                </select>
                                <small class="form-text text-muted">Chọn loại hỗ trợ bạn cần</small>
                            </div>

                            <!-- MÃ HỢP ĐỒNG -->
                            <div class="mb-3" id="contractIdField" style="display: none;">
                                <label class="form-label">Mã Hợp Đồng <span class="text-danger">*</span></label>
                                <input type="number" class="form-control" name="contractId" id="contractId" placeholder="Nhập mã hợp đồng của bạn" min="1">
                                <small class="form-text text-muted">Nhập mã hợp đồng đã ký với công ty</small>
                            </div>

                            <!-- MÃ THIẾT BỊ -->
                            <div class="mb-3" id="equipmentIdField" style="display: none;">
                                <label class="form-label">Mã Thiết Bị <span class="text-danger">*</span></label>
                                <input type="number" class="form-control" name="equipmentId" id="equipmentId" placeholder="Nhập mã thiết bị cần bảo trì" min="1">
                                <small class="form-text text-muted">Nhập mã thiết bị cần yêu cầu dịch vụ</small>
                            </div>

                            <!-- MỨC ĐỘ ƯU TIÊN -->
                            <div class="mb-3" id="priorityField" style="display: none;">
                                <label class="form-label">Mức Độ Ưu Tiên <span class="text-danger">*</span></label>
                                <select class="form-select" name="priorityLevel" id="priorityLevel">
                                    <option value="Normal" selected>Bình Thường</option>
                                    <option value="High">Cao</option>
                                    <option value="Urgent">Khẩn Cấp</option>
                                </select>
                                <small class="form-text text-muted">Chọn mức độ ưu tiên phù hợp với tình trạng thiết bị</small>
                            </div>

                            <!-- MÔ TẢ VẤN ĐỀ -->
                            <div class="mb-3" id="descriptionField" style="display: none;">
                                <label class="form-label">Mô Tả Vấn Đề <span class="text-danger">*</span></label>
                                <textarea class="form-control" 
                                          name="description" 
                                          id="description" 
                                          rows="5" 
                                          placeholder="Mô tả chi tiết vấn đề bạn đang gặp phải..." 
                                          maxlength="1000"
                                          oninput="updateCharCount()"></textarea>
                                <div class="d-flex justify-content-between align-items-center mt-1">
                                    <small class="form-text text-muted">
                                        Tối thiểu 10 ký tự, tối đa 1000 ký tự.
                                    </small>
                                    <span id="charCount" class="text-muted" style="font-size: 0.875rem;">0/1000</span>
                                </div>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                            <button type="submit" class="btn btn-primary"><i class="fas fa-paper-plane"></i> Gửi Yêu Cầu</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <!-- MODAL HỦY -->
        <div class="modal fade" id="cancelModal" tabindex="-1">
            <div class="modal-dialog">
                <div class="modal-content">
                    <form action="${pageContext.request.contextPath}/managerServiceRequest" method="post">
                        <input type="hidden" name="action" value="CancelServiceRequest">
                        <div class="modal-header bg-danger text-white">
                            <h5 class="modal-title"><i class="fas fa-exclamation-triangle"></i> Xác Nhận Hủy</h5>
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                        </div>
                        <div class="modal-body">
                            <p>Bạn có chắc chắn muốn hủy yêu cầu không?</p>
                            <input type="hidden" name="requestId" id="cancelRequestId">
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Không</button>
                            <button type="submit" class="btn btn-danger">Có, Hủy Yêu Cầu</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <!-- MODAL XEM CHI TIẾT -->
        <div class="modal fade" id="viewModal" tabindex="-1">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header bg-info text-white">
                        <h5 class="modal-title"><i class="fas fa-file-alt"></i> Chi Tiết Yêu Cầu</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div class="row mb-3">
                            <div class="col-md-6"><strong>Mã Yêu Cầu:</strong> <p class="fw-normal" id="viewRequestId"></p></div>
                            <div class="col-md-6"><strong>Ngày Tạo:</strong> <p class="fw-normal" id="viewRequestDate"></p></div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-md-6"><strong>Mã Hợp Đồng:</strong> <p class="fw-normal" id="viewContractId"></p></div>
                            <div class="col-md-6"><strong>Mã Thiết Bị:</strong> <p class="fw-normal" id="viewEquipmentId"></p></div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-md-6"><strong>Trạng Thái:</strong> <span class="badge" id="viewStatus"></span></div>
                            <div class="col-md-6"><strong>Mức Độ Ưu Tiên:</strong> <span class="badge" id="viewPriority"></span></div>
                        </div>
                        <div class="mb-3">
                            <strong>Mô Tả Vấn Đề:</strong>
                            <div class="border rounded p-3 bg-light description-display" id="viewDescription"></div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- MODAL SỬA -->
        <div class="modal fade" id="editModal" tabindex="-1">
            <div class="modal-dialog">
                <div class="modal-content">
                    <form action="${pageContext.request.contextPath}/managerServiceRequest" method="post" id="editForm" onsubmit="return validateEditForm(event)">
                        <input type="hidden" name="action" value="UpdateServiceRequest">
                        <div class="modal-header bg-warning text-dark">
                            <h5 class="modal-title"><i class="fas fa-edit"></i> Chỉnh Sửa Yêu Cầu</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                        </div>
                        <div class="modal-body">
                            <input type="hidden" name="requestId" id="editRequestId">
                            <div class="mb-3">
                                <label class="form-label">Mức Độ Ưu Tiên <span class="text-danger">*</span></label>
                                <select class="form-select" name="priorityLevel" id="editPriorityLevel" required>
                                    <option value="Normal">Bình Thường</option>
                                    <option value="High">Cao</option>
                                    <option value="Urgent">Khẩn Cấp</option>
                                </select>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Mô Tả Vấn Đề <span class="text-danger">*</span></label>
                                <textarea class="form-control" name="description" id="editDescription" rows="5" 
                                          required 
                                          maxlength="1000"
                                          oninput="updateEditCharCount()"></textarea>
                                <div class="d-flex justify-content-between align-items-center mt-1">
                                    <small class="form-text text-muted">
                                        Tối thiểu 10 ký tự, tối đa 1000 ký tự.
                                    </small>
                                    <span id="editCharCount" class="text-muted" style="font-size: 0.875rem;">0/1000</span>
                                </div>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                            <button type="submit" class="btn btn-warning">Lưu Thay Đổi</button>
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
                            if (type === 'info')
                                iconClass = 'fa-info-circle';

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

                        // ========== CHARACTER COUNT FUNCTIONS ==========
                        function updateCharCount() {
                            const textarea = document.getElementById('description');
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

                        function updateEditCharCount() {
                            const textarea = document.getElementById('editDescription');
                            const charCount = document.getElementById('editCharCount');
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

                        // ========== TOGGLE FIELDS FUNCTION ==========
                        function toggleFields() {
                            const supportType = document.getElementById('supportType').value;
                            const contractField = document.getElementById('contractIdField');
                            const equipmentField = document.getElementById('equipmentIdField');
                            const priorityField = document.getElementById('priorityField');
                            const descriptionField = document.getElementById('descriptionField');

                            const contractInput = document.getElementById('contractId');
                            const equipmentInput = document.getElementById('equipmentId');
                            const priorityInput = document.getElementById('priorityLevel');
                            const descriptionInput = document.getElementById('description');

                            if (supportType === 'equipment') {
                                contractField.style.display = 'block';
                                equipmentField.style.display = 'block';
                                priorityField.style.display = 'block';
                                descriptionField.style.display = 'block';

                                contractInput.setAttribute('required', 'required');
                                equipmentInput.setAttribute('required', 'required');
                                priorityInput.setAttribute('required', 'required');
                                descriptionInput.setAttribute('required', 'required');

                                updateCharCount();
                            } else if (supportType === 'account') {
                                contractField.style.display = 'none';
                                equipmentField.style.display = 'none';
                                priorityField.style.display = 'block';
                                descriptionField.style.display = 'block';

                                contractInput.removeAttribute('required');
                                equipmentInput.removeAttribute('required');
                                contractInput.value = '';
                                equipmentInput.value = '';
                                priorityInput.setAttribute('required', 'required');
                                descriptionInput.setAttribute('required', 'required');

                                updateCharCount();
                            } else {
                                contractField.style.display = 'none';
                                equipmentField.style.display = 'none';
                                priorityField.style.display = 'none';
                                descriptionField.style.display = 'none';

                                contractInput.removeAttribute('required');
                                equipmentInput.removeAttribute('required');
                                priorityInput.removeAttribute('required');
                                descriptionInput.removeAttribute('required');
                            }
                        }

                        // ========== VALIDATION FUNCTIONS ==========
                        function validateCreateForm(event) {
                            const supportType = document.getElementById('supportType').value;
                            const description = document.getElementById('description').value.trim();
                            const contractId = document.getElementById('contractId').value;
                            const equipmentId = document.getElementById('equipmentId').value;

                            if (!supportType) {
                                event.preventDefault();
                                showToast('Vui lòng chọn loại hỗ trợ!', 'error');
                                return false;
                            }

                            if (description.length < 10) {
                                event.preventDefault();
                                showToast('Mô tả phải có ít nhất 10 ký tự!', 'error');
                                document.getElementById('description').focus();
                                return false;
                            }

                            if (description.length > 1000) {
                                event.preventDefault();
                                showToast('Mô tả không được vượt quá 1000 ký tự!', 'error');
                                document.getElementById('description').focus();
                                return false;
                            }

                            if (supportType === 'equipment') {
                                if (!contractId || contractId <= 0) {
                                    event.preventDefault();
                                    showToast('Vui lòng nhập mã hợp đồng hợp lệ!', 'error');
                                    document.getElementById('contractId').focus();
                                    return false;
                                }

                                if (!equipmentId || equipmentId <= 0) {
                                    event.preventDefault();
                                    showToast('Vui lòng nhập mã thiết bị hợp lệ!', 'error');
                                    document.getElementById('equipmentId').focus();
                                    return false;
                                }
                            }

                            return true;
                        }

                        function validateEditForm(event) {
                            const description = document.getElementById('editDescription').value.trim();

                            if (description.length < 10) {
                                event.preventDefault();
                                showToast('Mô tả phải có ít nhất 10 ký tự!', 'error');
                                document.getElementById('editDescription').focus();
                                return false;
                            }

                            if (description.length > 1000) {
                                event.preventDefault();
                                showToast('Mô tả không được vượt quá 1000 ký tự!', 'error');
                                document.getElementById('editDescription').focus();
                                return false;
                            }

                            return true;
                        }

                        // ========== UTILITY FUNCTIONS ==========
                        function refreshPage() {
                            window.location.href = "${pageContext.request.contextPath}/managerServiceRequest";
                        }

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

                        function viewRequest(id, contractId, equipmentId, description, requestDate, status, priorityLevel) {
                            document.getElementById('viewRequestId').textContent = '#' + id;
                            document.getElementById('viewContractId').textContent = contractId || 'N/A';
                            document.getElementById('viewEquipmentId').textContent = equipmentId || 'N/A';
                            document.getElementById('viewDescription').textContent = description;
                            document.getElementById('viewRequestDate').textContent = requestDate;

                            const statusBadge = document.getElementById('viewStatus');
                            const statusMap = {
                                'Pending': {className: 'badge-pending', text: 'Chờ Xử Lý'},
                                'Approved': {className: 'badge-inprogress', text: 'Đã Duyệt'},
                                'Completed': {className: 'badge-completed', text: 'Hoàn Thành'},
                                'Rejected': {className: 'badge-cancelled', text: 'Bị từ chối'},
                                'Cancelled': {className: 'badge-cancelled', text: 'Đã Hủy'}
                            };
                            const statusInfo = statusMap[status] || {className: 'bg-secondary', text: status};
                            statusBadge.className = 'badge ' + statusInfo.className;
                            statusBadge.textContent = statusInfo.text;

                            const priorityBadge = document.getElementById('viewPriority');
                            const priorityMap = {
                                'Normal': {className: 'bg-secondary', text: 'Bình Thường'},
                                'High': {className: 'bg-warning text-dark', text: 'Cao'},
                                'Urgent': {className: 'bg-danger', text: 'Khẩn Cấp'}
                            };
                            const priorityInfo = priorityMap[priorityLevel] || {className: 'bg-dark', text: priorityLevel};
                            priorityBadge.className = 'badge ' + priorityInfo.className;
                            priorityBadge.textContent = priorityInfo.text;

                            new bootstrap.Modal(document.getElementById('viewModal')).show();
                        }

                        function editRequest(id, description, priorityLevel) {
                            document.getElementById('editRequestId').value = id;
                            document.getElementById('editDescription').value = description;
                            document.getElementById('editPriorityLevel').value = priorityLevel;
                            updateEditCharCount();
                            new bootstrap.Modal(document.getElementById('editModal')).show();
                        }

                        function confirmCancel(id) {
                            document.getElementById('cancelRequestId').value = id;
                            new bootstrap.Modal(document.getElementById('cancelModal')).show();
                        }

                        function scrollToTop() {
                            window.scrollTo({
                                top: 0,
                                behavior: 'smooth'
                            });
                        }

                        // ========== EVENT LISTENERS ==========
                        window.addEventListener('scroll', function () {
                            const scrollBtn = document.getElementById('scrollToTop');
                            if (window.pageYOffset > 300) {
                                scrollBtn.classList.add('show');
                            } else {
                                scrollBtn.classList.remove('show');
                            }
                        });

                        document.addEventListener('DOMContentLoaded', function () {
                            // Event cho nút VIEW - LẤY DESCRIPTION TỪ HIDDEN DIV
                            document.querySelectorAll('.btn-view').forEach(button => {
                                button.addEventListener('click', function () {
                                    const data = this.dataset;
                                    const requestId = data.id;

                                    const descElement = document.getElementById('desc-' + requestId);
                                    const description = descElement ? descElement.textContent.trim() : 'Không có mô tả';

                                    viewRequest(
                                            requestId,
                                            data.contractId,
                                            data.equipmentId,
                                            description,
                                            data.requestDate,
                                            data.status,
                                            data.priority
                                            );
                                });
                            });

                            // Event cho nút EDIT
                            document.querySelectorAll('.btn-edit').forEach(button => {
                                button.addEventListener('click', function () {
                                    const data = this.dataset;
                                    editRequest(data.id, data.description, data.priority);
                                });
                            });

                            // Event cho nút CANCEL
                            document.querySelectorAll('.btn-cancel').forEach(button => {
                                button.addEventListener('click', function () {
                                    confirmCancel(this.dataset.id);
                                });
                            });

                            // Event cho textarea description trong create modal
                            const descriptionTextarea = document.getElementById('description');
                            if (descriptionTextarea) {
                                descriptionTextarea.addEventListener('input', updateCharCount);
                            }

                            // Event cho textarea description trong edit modal
                            const editDescriptionTextarea = document.getElementById('editDescription');
                            if (editDescriptionTextarea) {
                                editDescriptionTextarea.addEventListener('input', updateEditCharCount);
                            }

                            // Reset form khi đóng modal TẠO MỚI
                            const createModal = document.getElementById('createModal');
                            if (createModal) {
                                createModal.addEventListener('hidden.bs.modal', function () {
                                    document.getElementById('createForm').reset();
                                    toggleFields();
                                });

                                createModal.addEventListener('shown.bs.modal', function () {
                                    updateCharCount();
                                });
                            }

                            // Cập nhật char count khi mở modal CHỈNH SỬA
                            const editModal = document.getElementById('editModal');
                            if (editModal) {
                                editModal.addEventListener('shown.bs.modal', function () {
                                    updateEditCharCount();
                                });
                            }

                            // Ngăn nhập ký tự không phải số cho contract và equipment ID
                            const numberInputs = ['contractId', 'equipmentId'];
                            numberInputs.forEach(function (inputId) {
                                const input = document.getElementById(inputId);
                                if (input) {
                                    input.addEventListener('keypress', function (e) {
                                        if (e.key < '0' || e.key > '9') {
                                            e.preventDefault();
                                        }
                                    });

                                    input.addEventListener('paste', function (e) {
                                        setTimeout(function () {
                                            input.value = input.value.replace(/[^0-9]/g, '');
                                        }, 0);
                                    });
                                }
                            });
                        });
        </script>
    </body>
</html>