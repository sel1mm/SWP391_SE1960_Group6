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
            .badge-awaiting {
                background-color: #ff9800; /* Màu cam đậm */
                color: #fff;
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
            .btn-purple {
                background: #8b5cf6;
                color: white;
                border: none;
            }

            .btn-purple:hover {
                background: #7c3aed;
                color: white;
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

                    <a href="${pageContext.request.contextPath}/dashbroadCustomer.jsp" class="menu-item">
                        <i class="fas fa-home"></i>
                        <span>Dashboard</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/managerServiceRequest" class="menu-item active">
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
                <!-- ✅ THỐNG KÊ - 6 Ô THEO DISPLAY STATUS -->
                <div class="row">
                    <!-- 1. Tổng Yêu Cầu -->
                    <div class="col-xl-2 col-lg-4 col-md-6 col-sm-6 mb-3">
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

                    <!-- 2. Chờ Xác Nhận (Pending) -->
                    <div class="col-xl-2 col-lg-4 col-md-6 col-sm-6 mb-3">
                        <div class="stats-card bg-warning text-dark">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h6>Chờ Xác Nhận</h6>
                                    <h2>
                                        <c:set var="countChoXacNhan" value="0" />
                                        <c:forEach var="req" items="${allRequests}">
                                            <c:if test="${req.getDisplayStatus() == 'Chờ Xác Nhận'}">
                                                <c:set var="countChoXacNhan" value="${countChoXacNhan + 1}" />
                                            </c:if>
                                        </c:forEach>
                                        ${countChoXacNhan}
                                    </h2>
                                </div>
                                <i class="fas fa-question-circle"></i>
                            </div>
                        </div>
                    </div>

                    <!-- 3. Chờ Xử Lý (Awaiting Approval) -->
                    <div class="col-xl-2 col-lg-4 col-md-6 col-sm-6 mb-3">
                        <div class="stats-card" style="background: #ff9800; color: white;">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h6>Chờ Xử Lý</h6>
                                    <h2>
                                        <c:set var="countChoXuLy" value="0" />
                                        <c:forEach var="req" items="${allRequests}">
                                            <c:if test="${req.getDisplayStatus() == 'Chờ Xử Lý'}">
                                                <c:set var="countChoXuLy" value="${countChoXuLy + 1}" />
                                            </c:if>
                                        </c:forEach>
                                        ${countChoXuLy}
                                    </h2>
                                </div>
                                <i class="fas fa-hourglass-half"></i>
                            </div>
                        </div>
                    </div>

                    <!-- 4. Đang Xử Lý (Approved + Completed chưa trả) -->
                    <div class="col-xl-2 col-lg-4 col-md-6 col-sm-6 mb-3">
                        <div class="stats-card bg-info text-white">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h6>Đang Xử Lý</h6>
                                    <h2>
                                        <c:set var="countDangXuLy" value="0" />
                                        <c:forEach var="req" items="${allRequests}">
                                            <c:if test="${req.getDisplayStatus() == 'Đang Xử Lý'}">
                                                <c:set var="countDangXuLy" value="${countDangXuLy + 1}" />
                                            </c:if>
                                        </c:forEach>
                                        ${countDangXuLy}
                                    </h2>
                                </div>
                                <i class="fas fa-spinner"></i>
                            </div>
                        </div>
                    </div>

                    <!-- 5. Hoàn Thành -->
                    <div class="col-xl-2 col-lg-4 col-md-6 col-sm-6 mb-3">
                        <div class="stats-card bg-success text-white">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h6>Hoàn Thành</h6>
                                    <h2>
                                        <c:set var="countHoanThanh" value="0" />
                                        <c:forEach var="req" items="${allRequests}">
                                            <c:if test="${req.getDisplayStatus() == 'Hoàn Thành'}">
                                                <c:set var="countHoanThanh" value="${countHoanThanh + 1}" />
                                            </c:if>
                                        </c:forEach>
                                        ${countHoanThanh}
                                    </h2>
                                </div>
                                <i class="fas fa-check-circle"></i>
                            </div>
                        </div>
                    </div>

                    <!-- 6. Đã Hủy -->
                    <div class="col-xl-2 col-lg-4 col-md-6 col-sm-6 mb-3">
                        <div class="stats-card bg-danger text-white">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h6>Đã Hủy</h6>
                                    <h2>
                                        <c:set var="countDaHuy" value="0" />
                                        <c:forEach var="req" items="${allRequests}">
                                            <c:if test="${req.getDisplayStatus() == 'Đã Hủy'}">
                                                <c:set var="countDaHuy" value="${countDaHuy + 1}" />
                                            </c:if>
                                        </c:forEach>
                                        ${countDaHuy}
                                    </h2>
                                </div>
                                <i class="fas fa-times-circle"></i>
                            </div>
                        </div>
                    </div>
                </div>




                <!-- SEARCH BAR FOR SERVICE REQUEST -->
                <div class="search-filter-bar">
                    <form action="${pageContext.request.contextPath}/managerServiceRequest" method="get">
                        <input type="hidden" name="action" value="search"/>

                        <!-- Hàng 1: Search + Dropdowns -->
                        <div class="row g-3 mb-2">
                            <div class="col-md-3">
                                <label class="form-label fw-bold">Tìm kiếm</label>
                                <input type="text" class="form-control" name="keyword"
                                       placeholder="Mô tả, ID yêu cầu, mã hợp đồng..."
                                       value="${param.keyword}">
                            </div>

                            <div class="col-md-2">
                                <label class="form-label fw-bold">Trạng Thái</label>
                                <select name="status" class="form-select">
                                    <option value="">Tất cả</option>
                                    <option value="Pending" ${param.status == 'Pending' ? 'selected' : ''}>Chờ Xác Nhận</option>
                                    <option value="AwaitingApproval" ${param.status == 'AwaitingApproval' ? 'selected' : ''}>Chờ Xử Lý</option>
                                    <option value="Approved" ${param.status == 'Approved' ? 'selected' : ''}>Đang Xử Lý</option>
                                    <option value="Completed" ${param.status == 'Completed' ? 'selected' : ''}>Hoàn Thành</option>
                                    <option value="Cancelled" ${param.status == 'Cancelled' ? 'selected' : ''}>Đã Hủy</option>
                                    <option value="Rejected" ${param.status == 'Rejected' ? 'selected' : ''}>Bị Từ Chối</option>
                                </select>
                            </div>

                            <div class="col-md-3">
                                <label class="form-label fw-bold">Loại Yêu Cầu</label>
                                <select name="requestType" class="form-select">
                                    <option value="">Tất cả</option>
                                    <option value="Service" ${param.requestType == 'Service' ? 'selected' : ''}>Dịch Vụ</option>
                                    <option value="Warranty" ${param.requestType == 'Warranty' ? 'selected' : ''}>Bảo Hành</option>
                                    <option value="InformationUpdate" ${param.requestType == 'InformationUpdate' ? 'selected' : ''}>Cập Nhật Thông Tin</option>
                                </select>
                            </div>

                            <div class="col-md-4">
                                <label class="form-label fw-bold">Sắp xếp</label>
                                <select name="sortBy" class="form-select">
                                    <option value="newest" ${param.sortBy == 'newest' ? 'selected' : ''}>Mới nhất</option>
                                    <option value="oldest" ${param.sortBy == 'oldest' ? 'selected' : ''}>Cũ nhất</option>
                                    <option value="priority_high" ${param.sortBy == 'priority_high' ? 'selected' : ''}>Ưu tiên cao</option>
                                    <option value="priority_low" ${param.sortBy == 'priority_low' ? 'selected' : ''}>Ưu tiên thấp</option>
                                </select>
                            </div>
                        </div>

                        <!-- Hàng 2: Date range + Priority -->
                        <div class="row g-3 mb-2 align-items-end">
                            <div class="col-md-3">
                                <label class="form-label fw-bold">Từ ngày tạo</label>
                                <input type="date" class="form-control" name="fromDate" value="${param.fromDate}">
                            </div>

                            <div class="col-md-3">
                                <label class="form-label fw-bold">Đến ngày tạo</label>
                                <input type="date" class="form-control" name="toDate" value="${param.toDate}">
                            </div>

                            <div class="col-md-3">
                                <label class="form-label fw-bold">Mức độ ưu tiên</label>
                                <select name="priorityLevel" class="form-select">
                                    <option value="">Tất cả</option>
                                    <option value="Normal" ${param.priorityLevel == 'Normal' ? 'selected' : ''}>Bình Thường</option>
                                    <option value="High" ${param.priorityLevel == 'High' ? 'selected' : ''}>Cao</option>
                                    <option value="Urgent" ${param.priorityLevel == 'Urgent' ? 'selected' : ''}>Khẩn Cấp</option>
                                </select>
                            </div>
                        </div>

                        <!-- Hàng 3: Buttons -->
                        <div class="row g-3">
                            <div class="col-md-3 d-grid">
                                <button type="submit" class="btn btn-dark">
                                    <i class="fas fa-search me-1"></i> Tìm kiếm
                                </button>
                            </div>
                            <div class="col-md-3 d-grid">
                                <a href="${pageContext.request.contextPath}/managerServiceRequest" class="btn btn-outline-dark">
                                    <i class="fas fa-sync-alt me-1"></i> Làm mới
                                </a>
                            </div>
                        </div>
                    </form>
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
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty req.equipmentName}">
                                                    ${req.equipmentName}
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-muted">-</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
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
                                            <%-- ✅ SỬ DỤNG getDisplayStatus() thay vì req.status --%>
                                            <c:set var="displayStatus" value="${req.getDisplayStatus()}" />
                                            <c:choose>
                                                <c:when test="${displayStatus == 'Chờ Xác Nhận'}">
                                                    <span class="badge badge-pending"><i class="fas fa-question-circle"></i> Chờ Xác Nhận</span>
                                                </c:when>
                                                <c:when test="${displayStatus == 'Chờ Xử Lý'}">
                                                    <span class="badge badge-awaiting"><i class="fas fa-hourglass-half"></i> Chờ Xử Lý</span>
                                                </c:when>
                                                <c:when test="${displayStatus == 'Đang Xử Lý'}">
                                                    <span class="badge badge-inprogress"><i class="fas fa-spinner"></i> Đang Xử Lý</span>
                                                </c:when>
                                                <c:when test="${displayStatus == 'Hoàn Thành'}">
                                                    <span class="badge badge-completed"><i class="fas fa-check-circle"></i> Hoàn Thành</span>
                                                </c:when>
                                                <c:when test="${displayStatus == 'Đã Hủy'}">
                                                    <span class="badge badge-cancelled"><i class="fas fa-times-circle"></i> Đã Hủy</span>
                                                </c:when>
                                                <c:when test="${displayStatus == 'Bị Từ Chối'}">
                                                    <span class="badge bg-secondary"><i class="fas fa-ban"></i> Bị Từ Chối</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-secondary">${displayStatus}</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>

                                        <td>
                                            <%-- Set các biến để dễ đọc --%>
                                            <c:set var="displayStatus" value="${req.getDisplayStatus()}" />
                                            <c:set var="dbStatus" value="${req.status}" />
                                            <c:set var="paymentStatus" value="${req.paymentStatus}" />
                                            <c:set var="requestType" value="${req.requestType}" />

                                            <%-- NÚT CHI TIẾT - Luôn hiển thị --%>
                                            <button class="btn btn-sm btn-info btn-action btn-view"
                                                    onclick="viewRequestDetail(${req.requestId}, '${displayStatus}')">
                                                <i class="fas fa-eye"></i> Chi Tiết
                                            </button>

                                            <%-- ✅ NÚT SỬA - CHỈ KHI "Chờ Xác Nhận" --%>
                                            <c:if test="${displayStatus == 'Chờ Xác Nhận'}">
                                                <button class="btn btn-sm btn-warning btn-action btn-edit"
                                                        data-id="${req.requestId}"
                                                        data-description="${fn:escapeXml(req.description)}"
                                                        data-priority="${req.priorityLevel}">
                                                    <i class="fas fa-edit"></i> Sửa
                                                </button>
                                            </c:if>

                                            <%-- ✅ NÚT HỦY - CHỈ KHI "Chờ Xác Nhận" --%>
                                            <c:if test="${displayStatus == 'Chờ Xác Nhận'}">
                                                <button class="btn btn-sm btn-danger btn-action btn-cancel"
                                                        data-id="${req.requestId}">
                                                    <i class="fas fa-times-circle"></i> Hủy
                                                </button>
                                            </c:if>
                                            <%-- ✅ NÚT XEM BÁO GIÁ - Hiển thị khi đang xử lý --%>
                                            <c:if test="${displayStatus == 'Đang Xử Lý' && 
                                                          dbStatus == 'Completed' && 
                                                          paymentStatus != 'Completed' && 
                                                          (requestType == 'Service' || requestType == 'Warranty')}">
                                                  <button class="btn btn-sm btn-purple btn-action"
                                                          onclick="viewQuotation(${req.requestId})">
                                                      <i class="fas fa-file-invoice"></i> Báo Giá
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
                                        <a class="page-link" href="javascript:void(0)" onclick="goToPage(${currentPage - 1})">
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
                                            <a class="page-link" href="javascript:void(0)" onclick="goToPage(${i})">
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
                                        <a class="page-link" href="javascript:void(0)" onclick="goToPage(${currentPage + 1})">
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
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <form action="${pageContext.request.contextPath}/managerServiceRequest" method="post" id="createForm" onsubmit="return validateCreateForm(event)">
                        <input type="hidden" name="action" value="CreateServiceRequest">
                        <div class="modal-header bg-primary text-white">
                            <h5 class="modal-title">
                                <i class="fas fa-plus-circle"></i> Tạo Yêu Cầu Hỗ Trợ Mới
                            </h5>
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                        </div>
                        <div class="modal-body">
                            <!-- Loại Hỗ Trợ -->
                            <div class="mb-3">
                                <label class="form-label">
                                    <i class="fas fa-question-circle"></i> Loại Hỗ Trợ 
                                    <span class="text-danger">*</span>
                                </label>
                                <select class="form-select" name="supportType" id="supportType" required onchange="toggleFields()">
                                    <option value="">-- Chọn loại hỗ trợ --</option>
                                    <option value="equipment">🔧 Hỗ Trợ Thiết Bị</option>
                                    <option value="account">👤 Hỗ Trợ Tài Khoản / Thông Tin</option>
                                </select>
                            </div>

                            <!-- ✅ DROPDOWN THIẾT BỊ MỚI -->
                            <div class="mb-3" id="equipmentSelectField" style="display:none;">
                                <label class="form-label">
                                    <i class="fas fa-tools"></i> Chọn Thiết Bị 
                                    <span class="text-danger">*</span>
                                </label>

                                <!-- Button trigger dropdown -->
                                <button class="btn btn-outline-secondary w-100 text-start d-flex justify-content-between align-items-center" 
                                        type="button" 
                                        id="equipmentDropdownBtn"
                                        onclick="toggleEquipmentDropdown()">
                                    <span id="equipmentDropdownLabel">
                                        <i class="fas fa-list"></i> Chọn thiết bị cần hỗ trợ
                                    </span>
                                    <i class="fas fa-chevron-down" id="equipmentDropdownIcon"></i>
                                </button>

                                <!-- Dropdown menu -->
                                <div class="border rounded mt-2 p-3 bg-light" 
                                     id="equipmentDropdownMenu" 
                                     style="display: none; max-height: 300px; overflow-y: auto;">

                                    <c:choose>
                                        <c:when test="${not empty sessionScope.customerEquipmentList}">
                                            <c:forEach var="equipment" items="${sessionScope.customerEquipmentList}" varStatus="status">
                                                <div class="form-check mb-2">
                                                    <input class="form-check-input equipment-checkbox" 
                                                           type="checkbox" 
                                                           name="equipmentIds" 
                                                           value="${equipment.equipmentId}"
                                                           id="equipment_${status.index}"
                                                           data-model="${equipment.model}"
                                                           data-serial="${equipment.serialNumber}"
                                                           data-contract="${equipment.contractId}"
                                                           onchange="updateSelectedEquipment()">
                                                    <label class="form-check-label w-100" for="equipment_${status.index}">
                                                        <strong><c:out value="${equipment.model}"/></strong><br>
                                                        <small class="text-muted">
                                                            Serial: <c:out value="${equipment.serialNumber}"/> | 
                                                            <c:choose>
                                                                <c:when test="${equipment.contractId != null}">
                                                                    Hợp đồng: HD<c:out value="${String.format('%03d', equipment.contractId)}"/>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="text-warning">Không có hợp đồng</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </small>
                                                    </label>
                                                </div>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="text-center text-muted py-3">
                                                <i class="fas fa-inbox fa-2x mb-2"></i>
                                                <p>Bạn chưa có thiết bị nào</p>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>

                                <!-- Hiển thị thiết bị đã chọn -->
                                <div id="selectedEquipmentDisplay" class="mt-2"></div>

                                <small class="form-text text-muted">
                                    <i class="fas fa-info-circle"></i> Bạn có thể chọn nhiều thiết bị cùng lúc
                                </small>
                            </div>

                            <!-- Mức Độ Ưu Tiên -->
                            <div class="mb-3" id="priorityField" style="display:none;">
                                <label class="form-label">
                                    <i class="fas fa-exclamation-circle"></i> Mức Độ Ưu Tiên 
                                    <span class="text-danger">*</span>
                                </label>
                                <select class="form-select" name="priorityLevel" id="priorityLevel">
                                    <option value="Normal">⚪ Bình Thường</option>
                                    <option value="High">🟡 Cao</option>
                                    <option value="Urgent">🔴 Khẩn Cấp</option>
                                </select>
                            </div>

                            <!-- Mô Tả -->
                            <div class="mb-3" id="descriptionField" style="display:none;">
                                <label class="form-label">
                                    <i class="fas fa-comment-dots"></i> Mô Tả Vấn Đề 
                                    <span class="text-danger">*</span>
                                </label>
                                <textarea class="form-control" name="description" id="description" rows="5" 
                                          placeholder="Mô tả chi tiết vấn đề bạn đang gặp phải..."
                                          maxlength="1000"
                                          oninput="updateCharCount()"></textarea>
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
                            <button type="submit" class="btn btn-primary">
                                <i class="fas fa-paper-plane"></i> Gửi Yêu Cầu
                            </button>
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

        <!-- ========================================== -->
        <!-- MODAL 1: CHỜ XÁC NHẬN (Pending) -->
        <!-- ========================================== -->
        <div class="modal fade" id="viewModalPending" tabindex="-1">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header bg-warning text-dark">
                        <h5 class="modal-title">
                            <i class="fas fa-question-circle"></i> Chi Tiết Yêu Cầu - Chờ Xác Nhận
                        </h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <strong><i class="fas fa-hashtag"></i> Mã Yêu Cầu:</strong>
                                <p class="fw-normal" id="pendingRequestId"></p>
                            </div>
                            <div class="col-md-6">
                                <strong><i class="fas fa-calendar"></i> Ngày Tạo:</strong>
                                <p class="fw-normal" id="pendingRequestDate"></p>
                            </div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <strong><i class="fas fa-file-contract"></i> Mã Hợp Đồng:</strong>
                                <p class="fw-normal" id="pendingContractId"></p>
                            </div>
                            <div class="col-md-6">
                                <strong><i class="fas fa-tools"></i> Thiết Bị:</strong>
                                <p class="fw-normal" id="pendingEquipmentName"></p>
                            </div>
                        </div>
                        <div class="row mb-3">                      
                            <div class="col-md-6">
                                <strong><i class="fas fa-exclamation-circle"></i> Mức Độ Ưu Tiên:</strong>
                                <span class="badge" id="pendingPriority"></span>
                            </div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <strong><i class="fas fa-tag"></i> Loại Yêu Cầu:</strong>
                                <span class="badge" id="pendingRequestType"></span>
                            </div>
                        </div>
                        <div class="mb-3">
                            <strong><i class="fas fa-comment-dots"></i> Mô Tả Vấn Đề:</strong>
                            <div class="border rounded p-3 bg-light description-display" id="pendingDescription"></div>
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

        <!-- ========================================== -->
        <!-- MODAL 2: CHỜ XỬ LÝ (Awaiting Approval) -->
        <!-- ========================================== -->
        <div class="modal fade" id="viewModalAwaiting" tabindex="-1">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header" style="background: #ff9800; color: white;">
                        <h5 class="modal-title">
                            <i class="fas fa-hourglass-half"></i> Chi Tiết Yêu Cầu - Chờ Xử Lý
                        </h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <strong><i class="fas fa-hashtag"></i> Mã Yêu Cầu:</strong>
                                <p class="fw-normal" id="awaitingRequestId"></p>
                            </div>
                            <div class="col-md-6">
                                <strong><i class="fas fa-calendar"></i> Ngày Tạo:</strong>
                                <p class="fw-normal" id="awaitingRequestDate"></p>
                            </div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <strong><i class="fas fa-file-contract"></i> Mã Hợp Đồng:</strong>
                                <p class="fw-normal" id="awaitingContractId"></p>
                            </div>
                            <div class="col-md-6">
                                <strong><i class="fas fa-tools"></i> Thiết Bị:</strong>
                                <p class="fw-normal" id="awaitingEquipmentName"></p>
                            </div>
                        </div>
                        <div class="row mb-3">                            
                            <div class="col-md-6">
                                <strong><i class="fas fa-exclamation-circle"></i> Mức Độ Ưu Tiên:</strong>
                                <span class="badge" id="awaitingPriority"></span>
                            </div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <strong><i class="fas fa-tag"></i> Loại Yêu Cầu:</strong>
                                <span class="badge" id="awaitingRequestType"></span>
                            </div>
                            <!-- ✅ THÊM: TÊN NGƯỜI XỬ LÝ -->
                            <div class="col-md-6">
                                <strong><i class="fas fa-user-cog"></i> Người Xử Lý:</strong>
                                <p class="fw-normal text-primary" id="awaitingTechnicianName">
                                    <i class="fas fa-spinner fa-spin"></i> Đang tải...
                                </p>
                            </div>
                        </div>
                        <div class="mb-3">
                            <strong><i class="fas fa-comment-dots"></i> Mô Tả Vấn Đề:</strong>
                            <div class="border rounded p-3 bg-light description-display" id="awaitingDescription"></div>
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
        <style>
            /* ✅ THÊM STYLE CHO BẢNG LINH KIỆN */
            #partsTable {
                font-size: 0.9rem;
            }

            #partsTable thead th {
                background-color: #f8f9fa;
                font-weight: 600;
                text-align: center;
                vertical-align: middle;
            }

            #partsTable tbody td {
                vertical-align: middle;
            }

            #partsTable tbody tr:hover {
                background-color: #f1f3f5;
            }

            .part-description {
                font-size: 0.85rem;
                color: #6c757d;
                font-style: italic;
            }

            #partsTable tfoot {
                font-size: 1rem;
            }
        </style>

        <!-- ========================================== -->
        <!-- MODAL 3: ĐANG XỬ LÝ - BÁO GIÁ (In Progress) -->
        <!-- ========================================== -->
        <div class="modal fade" id="viewModalQuotation" tabindex="-1">
            <div class="modal-dialog modal-xl">
                <div class="modal-content">
                    <div class="modal-header bg-primary text-white">
                        <h5 class="modal-title">
                            <i class="fas fa-file-invoice-dollar"></i> Báo Giá Dịch Vụ
                        </h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <!-- Thông Tin Yêu Cầu -->
                        <div class="card mb-3">
                            <div class="card-header bg-light">
                                <h6 class="mb-0"><i class="fas fa-info-circle"></i> Thông Tin Yêu Cầu</h6>
                            </div>
                            <div class="card-body">
                                <div class="row">
                                    <div class="col-md-3">
                                        <strong>Mã Yêu Cầu:</strong>
                                        <p id="quotationRequestId"></p>
                                    </div>
                                    <div class="col-md-3">
                                        <strong>Ngày Tạo:</strong>
                                        <p id="quotationRequestDate"></p>
                                    </div>
                                    <div class="col-md-3">
                                        <strong>Mã Hợp Đồng:</strong>
                                        <p id="quotationContractId"></p>
                                    </div>
                                    <div class="col-md-3">
                                        <strong>Thiết Bị:</strong>
                                        <p id="quotationEquipmentName"></p>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-12">
                                        <strong>Mô Tả Vấn Đề:</strong>
                                        <div class="border rounded p-2 bg-light" id="quotationDescription"></div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Thông Tin Báo Giá -->
                        <div class="card mb-3">
                            <div class="card-header bg-success text-white">
                                <h6 class="mb-0"><i class="fas fa-clipboard-check"></i> Chi Tiết Báo Giá</h6>
                            </div>
                            <div class="card-body">
                                <div class="row mb-3">
                                    <div class="col-md-6">
                                        <strong><i class="fas fa-user-cog"></i> Kỹ Thuật Viên:</strong>
                                        <p class="text-primary" id="quotationTechnicianName"></p>
                                    </div>
                                    <div class="col-md-6">
                                        <strong><i class="fas fa-calendar-check"></i> Ngày Sửa Chữa:</strong>
                                        <p id="quotationRepairDate">Chưa xác định</p>
                                    </div>
                                </div>

                                <!-- ✅ BẢNG DANH SÁCH LINH KIỆN THAY THẾ -->
                                <div class="mb-3">
                                    <strong><i class="fas fa-cogs"></i> Linh Kiện Thay Thế:</strong>
                                    <div class="table-responsive mt-2">
                                        <table class="table table-bordered table-hover" id="partsTable">
                                            <thead class="table-light">
                                                <tr>
                                                    <th width="5%">#</th>
                                                    <th width="30%">Tên Linh Kiện</th>
                                                    <th width="20%">Serial Number</th>
                                                    <th width="10%">Số Lượng</th>
                                                    <th width="15%">Đơn Giá</th>
                                                    <th width="20%">Thành Tiền</th>
                                                </tr>
                                            </thead>
                                            <tbody id="partsTableBody">
                                                <tr>
                                                    <td colspan="6" class="text-center text-muted">
                                                        <i class="fas fa-spinner fa-spin"></i> Đang tải...
                                                    </td>
                                                </tr>
                                            </tbody>
                                            <tfoot class="table-light">
                                                <tr>
                                                    <td colspan="5" class="text-end"><strong>Tổng Chi Phí:</strong></td>
                                                    <td><strong id="partsTotalCost" class="text-primary">0 VNĐ</strong></td>
                                                </tr>
                                            </tfoot>
                                        </table>
                                    </div>
                                    <small class="text-muted">
                                        <i class="fas fa-info-circle"></i> Chi phí đã bao gồm linh kiện và công sửa chữa
                                    </small>
                                </div>
                            </div>
                        </div>

                        <!-- Lưu Ý -->
                        <div class="alert alert-warning">
                            <i class="fas fa-exclamation-triangle"></i>
                            <strong>Lưu ý:</strong> Khi bạn đồng ý báo giá, bạn sẽ được chuyển sang trang thanh toán để hoàn tất giao dịch. 
                            Nếu từ chối, yêu cầu vẫn giữ nguyên trạng thái.
                        </div>
                    </div>
                    <div class="modal-footer">
                        <input type="hidden" id="quotationRequestIdHidden">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                            <i class="fas fa-times"></i> Đóng
                        </button>
                        <%-- ✅ NÚT THANH TOÁN - Chỉ hiển thị khi có linh kiện --%>
                        <button type="button" class="btn btn-success" id="btnPaymentInModal" 
                                onclick="makePaymentFromModal()" style="display: none;">
                            <i class="fas fa-credit-card"></i> Thanh Toán
                        </button>
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
                                setTimeout(function () {
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
                            const equipmentSelectField = document.getElementById('equipmentSelectField');
                            const priorityField = document.getElementById('priorityField');
                            const descriptionField = document.getElementById('descriptionField');
                            const priorityInput = document.getElementById('priorityLevel');
                            const descriptionInput = document.getElementById('description');

                            if (supportType === 'equipment') {
                                equipmentSelectField.style.display = 'block';
                                priorityField.style.display = 'block';
                                descriptionField.style.display = 'block';
                                priorityInput.setAttribute('required', 'required');
                                descriptionInput.setAttribute('required', 'required');
                                updateCharCount();
                            } else if (supportType === 'account') {
                                equipmentSelectField.style.display = 'none';
                                priorityField.style.display = 'block';
                                descriptionField.style.display = 'block';
                                document.querySelectorAll('.equipment-checkbox').forEach(function (cb) {
                                    cb.checked = false;
                                });
                                updateSelectedEquipment();
                                priorityInput.setAttribute('required', 'required');
                                descriptionInput.setAttribute('required', 'required');
                                updateCharCount();
                            } else {
                                equipmentSelectField.style.display = 'none';
                                priorityField.style.display = 'none';
                                descriptionField.style.display = 'none';
                                priorityInput.removeAttribute('required');
                                descriptionInput.removeAttribute('required');
                            }
                        }

                        // ========== TOGGLE EQUIPMENT DROPDOWN ==========
                        function toggleEquipmentDropdown() {
                            const menu = document.getElementById('equipmentDropdownMenu');
                            const icon = document.getElementById('equipmentDropdownIcon');

                            if (menu.style.display === 'none' || menu.style.display === '') {
                                menu.style.display = 'block';
                                icon.classList.remove('fa-chevron-down');
                                icon.classList.add('fa-chevron-up');
                            } else {
                                menu.style.display = 'none';
                                icon.classList.remove('fa-chevron-up');
                                icon.classList.add('fa-chevron-down');
                            }
                        }

                        // ========== UPDATE SELECTED EQUIPMENT DISPLAY ==========
                        function updateSelectedEquipment() {
                            const checkboxes = document.querySelectorAll('.equipment-checkbox:checked');
                            const display = document.getElementById('selectedEquipmentDisplay');

                            if (checkboxes.length === 0) {
                                display.innerHTML = '';
                                return;
                            }

                            let html = '<div class="alert alert-info mb-0"><strong>Đã chọn ' + checkboxes.length + ' thiết bị:</strong><ul class="mb-0 mt-2">';
                            checkboxes.forEach(function (cb) {
                                const label = document.querySelector('label[for="' + cb.id + '"]');
                                const equipmentName = label.querySelector('strong').textContent;
                                html += '<li>' + equipmentName + '</li>';
                            });
                            html += '</ul></div>';
                            display.innerHTML = html;
                        }

                        // ========== VALIDATION FUNCTIONS ==========
                        function validateCreateForm(event) {
                            const supportType = document.getElementById('supportType').value;
                            const description = document.getElementById('description').value.trim();

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
                                const selectedEquipment = document.querySelectorAll('.equipment-checkbox:checked');
                                if (selectedEquipment.length === 0) {
                                    event.preventDefault();
                                    showToast('Vui lòng chọn ít nhất một thiết bị!', 'error');
                                    return false;
                                }
                            }

                            return true;
                        }

                        // ========== EVENT LISTENERS ==========
                        document.addEventListener('DOMContentLoaded', function () {
                            // Add date range validation to search form
                            const searchForm = document.querySelector('form[action*="/managerServiceRequest"]');
                            if (searchForm) {
                                searchForm.addEventListener('submit', function (e) {
                                    if (!validateDateRange()) {
                                        e.preventDefault();
                                    }
                                });
                            }
                        });

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

                        // ========== PAGINATION ==========
                        function goToPage(pageNumber) {
                            // Lấy URL hiện tại và các tham số
                            const urlParams = new URLSearchParams(window.location.search);

                            // Cập nhật hoặc thêm tham số page
                            urlParams.set('page', pageNumber);

                            // Nếu không có action=search trong URL, thêm vào
                            if (!urlParams.has('action')) {
                                urlParams.set('action', 'search');
                            }

                            // Chuyển hướng với tất cả tham số
                            window.location.href = '${pageContext.request.contextPath}/managerServiceRequest?' + urlParams.toString();
                        }

                        // ========== QUOTATION MODAL FUNCTIONS ==========
                        function viewQuotation(requestId) {
                            // Tìm request trong danh sách để lấy thông tin
                            const requests = [
            <c:forEach var="req" items="${requests}" varStatus="status">
                            {
                            requestId: ${req.requestId},
                                    requestDate: '<fmt:formatDate value="${req.requestDate}" pattern="dd/MM/yyyy"/>',
                                    contractId: '${req.contractId}',
                                    equipmentName: '${req.equipmentName}',
                                    description: `${fn:escapeXml(req.description)}`,
                                    technicianName: '${req.technicianName}',
                                    customerName: '${req.customerName}'
                            }<c:if test="${!status.last}">,</c:if>
            </c:forEach>
                            ];

                            const request = requests.find(r => r.requestId === requestId);
                            if (!request) {
                                showToast('Không tìm thấy thông tin yêu cầu!', 'error');
                                        return;
                            }

                            // Điền thông tin vào modal
                            document.getElementById('quotationRequestId').textContent = '#' + requestId;
                            document.getElementById('quotationRequestDate').textContent = request.requestDate;
                            document.getElementById('quotationContractId').textContent = 'CTR' + String(request.contractId).padStart(4, '0');
                            document.getElementById('quotationEquipmentName').textContent = request.equipmentName || 'Không xác định';
                            document.getElementById('quotationDescription').textContent = request.description;

                            // Hiển thị thông tin kỹ thuật viên
                            const technicianElement = document.getElementById('quotationTechnicianName');
                            if (request.technicianName && request.technicianName.trim() !== '') {
                                technicianElement.innerHTML = `<i class="fas fa-user-check me-1"></i>${request.technicianName}`;
                                technicianElement.className = 'text-success fw-bold';
                            } else {
                                technicianElement.innerHTML = '<i class="fas fa-user-clock me-1"></i>Chưa phân công kỹ thuật viên';
                                technicianElement.className = 'text-warning';
                            }

                            // Hiển thị thông tin báo giá mặc định (có thể lấy từ server sau)
                            document.getElementById('quotationRepairDate').textContent = 'Sẽ được thông báo sau khi xác nhận';
                            document.getElementById('quotationDiagnosis').textContent = 'Đang chờ kỹ thuật viên thực hiện chẩn đoán...';
                            document.getElementById('quotationDetails').textContent = 'Chi tiết sửa chữa sẽ được cập nhật sau khi hoàn thành chẩn đoán.';
                            document.getElementById('quotationCost').textContent = 'Đang tính toán...';
                            document.getElementById('quotationQuotationStatus').textContent = 'Đang xử lý';

                            // Ẩn nút đồng ý vì chưa có báo giá thực tế
                            document.getElementById('btnAcceptQuotation').style.display = 'none';

                            // Hiển thị modal
                            const modal = new bootstrap.Modal(document.getElementById('viewModalQuotation'));
                            modal.show();
                        }

                        // ========== DATE RANGE VALIDATION ==========
                        function validateDateRange() {
                            const fromDate = document.querySelector('input[name="fromDate"]');
                            const toDate = document.querySelector('input[name="toDate"]');

                            if (fromDate && toDate && fromDate.value && toDate.value) {
                                if (fromDate.value > toDate.value) {
                                    showToast('Từ ngày không thể lớn hơn đến ngày!', 'error');
                                    return false;
                                }
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

                        function scrollToTop() {
                            window.scrollTo({
                                top: 0,
                                behavior: 'smooth'
                            });
                        }

                        // ========== VIEW REQUEST DETAIL FUNCTION (AJAX) ==========
                        /**
                         * ✅ Hàm mới: Gọi AJAX để lấy dữ liệu và hiển thị modal phù hợp
                         */
                        function viewRequestDetail(requestId, displayStatus) {
                            console.log('🔍 Opening detail modal for request:', requestId, 'Status:', displayStatus);

                            // Hiển thị loading
                            Swal.fire({
                                title: 'Đang tải...',
                                html: 'Vui lòng đợi trong giây lát',
                                allowOutsideClick: false,
                                didOpen: () => {
                                    Swal.showLoading();
                                }
                            });

                            // Gọi AJAX để lấy dữ liệu
                            fetch('${pageContext.request.contextPath}/managerServiceRequest?action=viewDetail&requestId=' + requestId)
                                    .then(response => response.json())
                                    .then(data => {
                                        Swal.close(); // Đóng loading

                                        if (!data.success) {
                                            Swal.fire({
                                                icon: 'error',
                                                title: 'Lỗi!',
                                                text: data.message || 'Không thể tải thông tin yêu cầu'
                                            });
                                            return;
                                        }

                                        console.log('✅ Received data:', data);

                                        // Hiển thị modal tùy theo trạng thái
                                        if (displayStatus === 'Chờ Xác Nhận') {
                                            showPendingModal(data);
                                        } else if (displayStatus === 'Chờ Xử Lý') {
                                            showAwaitingModal(data);
                                        } else if (displayStatus === 'Đang Xử Lý') {
                                            showQuotationModal(data);
                                        } else {
                                            // Fallback: dùng modal Pending
                                            showPendingModal(data);
                                        }
                                    })
                                    .catch(error => {
                                        Swal.close();
                                        console.error('❌ Error:', error);
                                        Swal.fire({
                                            icon: 'error',
                                            title: 'Lỗi!',
                                            text: 'Có lỗi xảy ra khi tải dữ liệu: ' + error.message
                                        });
                                    });
                        }

                        // ========== MODAL 1: CHỜ XÁC NHẬN ==========
                        function showPendingModal(data) {
                            document.getElementById('pendingRequestId').textContent = '#' + data.requestId;
                            document.getElementById('pendingRequestDate').textContent = data.requestDate;
                            document.getElementById('pendingContractId').textContent = data.contractId || 'N/A';
                            document.getElementById('pendingEquipmentName').textContent = data.equipmentName || 'N/A';
                            document.getElementById('pendingDescription').textContent = data.description;

                            // Priority badge
                            const priorityBadge = document.getElementById('pendingPriority');
                            const priorityMap = {
                                'Normal': {className: 'bg-secondary', text: 'Bình Thường'},
                                'High': {className: 'bg-warning text-dark', text: 'Cao'},
                                'Urgent': {className: 'bg-danger', text: 'Khẩn Cấp'}
                            };
                            const priority = priorityMap[data.priorityLevel] || {className: 'bg-dark', text: data.priorityLevel};
                            priorityBadge.className = 'badge ' + priority.className;
                            priorityBadge.textContent = priority.text;

                            // Request Type badge
                            const typeBadge = document.getElementById('pendingRequestType');
                            if (data.requestType === 'Service' || data.requestType === 'Warranty') {
                                typeBadge.className = 'badge bg-primary';
                                typeBadge.textContent = '🔧 Hỗ Trợ Thiết Bị';
                            } else if (data.requestType === 'InformationUpdate') {
                                typeBadge.className = 'badge bg-info';
                                typeBadge.textContent = '👤 Hỗ Trợ Tài Khoản';
                            } else {
                                typeBadge.className = 'badge bg-secondary';
                                typeBadge.textContent = data.requestType || 'N/A';
                            }

                            // Mở modal
                            new bootstrap.Modal(document.getElementById('viewModalPending')).show();
                        }

// ========== MODAL 2: CHỜ XỬ LÝ ==========
                        function showAwaitingModal(data) {
                            document.getElementById('awaitingRequestId').textContent = '#' + data.requestId;
                            document.getElementById('awaitingRequestDate').textContent = data.requestDate;
                            document.getElementById('awaitingContractId').textContent = data.contractId || 'N/A';
                            document.getElementById('awaitingEquipmentName').textContent = data.equipmentName || 'N/A';
                            document.getElementById('awaitingDescription').textContent = data.description;

                            // Priority badge
                            const priorityBadge = document.getElementById('awaitingPriority');
                            const priorityMap = {
                                'Normal': {className: 'bg-secondary', text: 'Bình Thường'},
                                'High': {className: 'bg-warning text-dark', text: 'Cao'},
                                'Urgent': {className: 'bg-danger', text: 'Khẩn Cấp'}
                            };
                            const priority = priorityMap[data.priorityLevel] || {className: 'bg-dark', text: data.priorityLevel};
                            priorityBadge.className = 'badge ' + priority.className;
                            priorityBadge.textContent = priority.text;

                            // Request Type badge
                            const typeBadge = document.getElementById('awaitingRequestType');
                            if (data.requestType === 'Service' || data.requestType === 'Warranty') {
                                typeBadge.className = 'badge bg-primary';
                                typeBadge.textContent = '🔧 Hỗ Trợ Thiết Bị';
                            } else if (data.requestType === 'InformationUpdate') {
                                typeBadge.className = 'badge bg-info';
                                typeBadge.textContent = '👤 Hỗ Trợ Tài Khoản';
                            } else {
                                typeBadge.className = 'badge bg-secondary';
                                typeBadge.textContent = data.requestType || 'N/A';
                            }

                            // ✅ Tên người xử lý
                            const technicianNameEl = document.getElementById('awaitingTechnicianName');
                            if (data.assignedTechnicianName) {
                                technicianNameEl.innerHTML = '<i class="fas fa-user-check"></i> ' + data.assignedTechnicianName;
                                technicianNameEl.className = 'fw-normal text-primary';
                            } else {
                                technicianNameEl.innerHTML = '<i class="fas fa-question-circle"></i> Chưa phân công';
                                technicianNameEl.className = 'fw-normal text-muted';
                            }

                            // Mở modal
                            new bootstrap.Modal(document.getElementById('viewModalAwaiting')).show();
                        }

                        // ========== MODAL 3: ĐANG XỬ LÝ - BÁO GIÁ ==========
                        function showQuotationModal(data) {
                            // Thông tin yêu cầu
                            document.getElementById('quotationRequestId').textContent = '#' + data.requestId;
                            document.getElementById('quotationRequestDate').textContent = data.requestDate;
                            document.getElementById('quotationContractId').textContent = data.contractId || 'N/A';
                            document.getElementById('quotationEquipmentName').textContent = data.equipmentName || 'N/A';
                            document.getElementById('quotationDescription').textContent = data.description;

                            // Thông tin báo giá
                            if (data.quotation) {
                                const q = data.quotation;

                                document.getElementById('quotationTechnicianName').textContent = q.technicianName || 'N/A';
                                document.getElementById('quotationRepairDate').textContent = q.repairDate || 'Chưa xác định';

                                // ✅ HIỂN THỊ BẢNG LINH KIỆN
                                const tbody = document.getElementById('partsTableBody');
                                tbody.innerHTML = '';

                                let hasParts = false; // ✅ BIẾN KIỂM TRA CÓ LINH KIỆN HAY KHÔNG

                                if (q.parts && q.parts.length > 0) {
                                    let totalCost = 0;
                                    hasParts = true; // ✅ CÓ LINH KIỆN

                                    q.parts.forEach((part, index) => {
                                        const unitPrice = parseFloat(part.unitPrice) || 0;
                                        const quantity = parseInt(part.quantity) || 0;
                                        const totalPrice = parseFloat(part.totalPrice) || 0;
                                        totalCost += totalPrice;

                                        const row = `
                    <tr>
                        <td class="text-center">${index + 1}</td>
                        <td>
                            <strong>${part.partName}</strong>
            ${part.description ? '<br><span class="part-description">' + part.description + '</span>' : ''}
                        </td>
                        <td class="text-center"><code>${part.serialNumber}</code></td>
                        <td class="text-center">${quantity}</td>
                        <td class="text-end">${unitPrice.toLocaleString('vi-VN')} VNĐ</td>
                        <td class="text-end"><strong>${totalPrice.toLocaleString('vi-VN')} VNĐ</strong></td>
                    </tr>
                `;
                                        tbody.innerHTML += row;
                                    });

                                    document.getElementById('partsTotalCost').textContent = totalCost.toLocaleString('vi-VN') + ' VNĐ';
                                } else {
                                    tbody.innerHTML = `
                <tr>
                    <td colspan="6" class="text-center text-muted py-3">
                        <i class="fas fa-box-open fa-2x mb-2"></i>
                        <p>Không có linh kiện nào cần thay thế</p>
                    </td>
                </tr>
            `;
                                    document.getElementById('partsTotalCost').textContent = '0 VNĐ';
                                }

                                // Lưu requestId cho nút thanh toán
                                document.getElementById('quotationRequestIdHidden').value = data.requestId;

                                // ✅ KIỂM TRA ĐIỀU KIỆN HIỂN THỊ NÚT THANH TOÁN
                                // CHỈ hiển thị khi: Có linh kiện thay thế
                                const btnPayment = document.getElementById('btnPaymentInModal');
                                
                                if (hasParts) {
                                    btnPayment.style.display = 'inline-block';
                                    console.log('✅ Shown Payment button: hasParts=' + hasParts);
                                } else {
                                    btnPayment.style.display = 'none';
                                    console.log('🚫 Hidden Payment button: hasParts=' + hasParts);
                                }
                            }

                            // Mở modal
                            new bootstrap.Modal(document.getElementById('viewModalQuotation')).show();
                        }

                        // ========== ĐỒNG Ý BÁO GIÁ ==========
                        function acceptQuotation() {
                            const requestId = document.getElementById('quotationRequestIdHidden').value;

                            Swal.fire({
                                title: 'Xác nhận đồng ý báo giá?',
                                text: 'Bạn sẽ được chuyển đến trang thanh toán',
                                icon: 'question',
                                showCancelButton: true,
                                confirmButtonText: '✅ Đồng Ý',
                                cancelButtonText: '❌ Hủy',
                                confirmButtonColor: '#10b981',
                                cancelButtonColor: '#6c757d'
                            }).then((result) => {
                                if (result.isConfirmed) {
                                    // Gửi POST request
                                    const form = document.createElement('form');
                                    form.method = 'POST';
                                    form.action = '${pageContext.request.contextPath}/managerServiceRequest';

                                    const actionInput = document.createElement('input');
                                    actionInput.type = 'hidden';
                                    actionInput.name = 'action';
                                    actionInput.value = 'AcceptQuotation';

                                    const requestIdInput = document.createElement('input');
                                    requestIdInput.type = 'hidden';
                                    requestIdInput.name = 'requestId';
                                    requestIdInput.value = requestId;

                                    form.appendChild(actionInput);
                                    form.appendChild(requestIdInput);
                                    document.body.appendChild(form);
                                    form.submit();
                                }
                            });
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

                        // ========== PAYMENT & QUOTATION FUNCTIONS ==========
                        function viewQuotation(requestId) {
                            var contextPath = '${pageContext.request.contextPath}';
                            Swal.fire({
                                title: 'Xem Báo Giá',
                                html: 'Đang tải thông tin báo giá cho yêu cầu #' + requestId + '...',
                                icon: 'info',
                                showConfirmButton: true,
                                confirmButtonText: 'Đóng'
                            }).then(function () {
                                window.location.href = contextPath + '/managerServiceRequest?action=viewQuotation&requestId=' + requestId;
                            });
                        }

                        function makePayment(requestId) {
                            var contextPath = '${pageContext.request.contextPath}';
                            Swal.fire({
                                title: 'Xác nhận thanh toán?',
                                text: 'Bạn sẽ được chuyển đến trang thanh toán',
                                icon: 'question',
                                showCancelButton: true,
                                confirmButtonText: 'Tiếp tục',
                                cancelButtonText: 'Hủy',
                                confirmButtonColor: '#10b981',
                                cancelButtonColor: '#6c757d'
                            }).then(function (result) {
                                if (result.isConfirmed) {
                                    window.location.href = contextPath + '/managerServiceRequest?action=makePayment&requestId=' + requestId;
                                }
                            });
                        }

                        // ✅ Hàm thanh toán từ modal báo giá
                        function makePaymentFromModal() {
                            const requestId = document.getElementById('quotationRequestIdHidden').value;
                            if (!requestId) {
                                Swal.fire({
                                    icon: 'error',
                                    title: 'Lỗi!',
                                    text: 'Không tìm thấy thông tin yêu cầu'
                                });
                                return;
                            }
                            
                            var contextPath = '${pageContext.request.contextPath}';
                            Swal.fire({
                                title: 'Xác nhận thanh toán?',
                                text: 'Bạn sẽ được chuyển đến trang thanh toán',
                                icon: 'question',
                                showCancelButton: true,
                                confirmButtonText: 'Tiếp tục',
                                cancelButtonText: 'Hủy',
                                confirmButtonColor: '#10b981',
                                cancelButtonColor: '#6c757d'
                            }).then(function (result) {
                                if (result.isConfirmed) {
                                    // Đóng modal trước khi chuyển trang
                                    bootstrap.Modal.getInstance(document.getElementById('viewModalQuotation')).hide();
                                    window.location.href = contextPath + '/managerServiceRequest?action=makePayment&requestId=' + requestId;
                                }
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
                            console.log('🔍 DOM Loaded');




                            // Event cho nút EDIT
                            document.querySelectorAll('.btn-edit').forEach(function (button) {
                                button.addEventListener('click', function () {
                                    const data = this.dataset;
                                    editRequest(data.id, data.description, data.priority);
                                });
                            });

                            // Event cho nút CANCEL
                            document.querySelectorAll('.btn-cancel').forEach(function (button) {
                                button.addEventListener('click', function () {
                                    confirmCancel(this.dataset.id);
                                });
                            });

                            // Event cho textarea
                            const descriptionTextarea = document.getElementById('description');
                            if (descriptionTextarea) {
                                descriptionTextarea.addEventListener('input', updateCharCount);
                            }

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
                        });
        </script>

        <!-- ========== ✅ FLASH MESSAGE HANDLER ✅ ========== -->
        <c:if test="${not empty sessionScope.success}">
            <script>
                Swal.fire({
                    icon: 'success',
                    title: 'Thành công!',
                    text: '${sessionScope.success}',
                    timer: 3000,
                    showConfirmButton: false,
                    position: 'top-end',
                    toast: true,
                    timerProgressBar: true
                });
            </script>
            <% session.removeAttribute("success"); %>
        </c:if>

        <c:if test="${not empty sessionScope.error}">
            <script>
                Swal.fire({
                    icon: 'error',
                    title: 'Lỗi!',
                    text: '${sessionScope.error}',
                    timer: 3000,
                    showConfirmButton: false,
                    position: 'top-end',
                    toast: true,
                    timerProgressBar: true
                });
            </script>
            <% session.removeAttribute("error"); %>
        </c:if>

        <c:if test="${not empty sessionScope.warning}">
            <script>
                Swal.fire({
                    icon: 'warning',
                    title: 'Cảnh báo!',
                    text: '${sessionScope.warning}',
                    timer: 3000,
                    showConfirmButton: false,
                    position: 'top-end',
                    toast: true,
                    timerProgressBar: true
                }
                );
            </script>
            <% session.removeAttribute("warning"); %>
        </c:if>
        <script>
// ========== EQUIPMENT DROPDOWN FUNCTIONS ==========
            function toggleEquipmentDropdown() {
                const menu = document.getElementById('equipmentDropdownMenu');
                const icon = document.getElementById('equipmentDropdownIcon');

                if (menu.style.display === 'none' || menu.style.display === '') {
                    menu.style.display = 'block';
                    icon.classList.remove('fa-chevron-down');
                    icon.classList.add('fa-chevron-up');
                } else {
                    menu.style.display = 'none';
                    icon.classList.remove('fa-chevron-up');
                    icon.classList.add('fa-chevron-down');
                }
            }

// Đóng dropdown khi click bên ngoài
            document.addEventListener('click', function (event) {
                const dropdown = document.getElementById('equipmentDropdownMenu');
                const button = document.getElementById('equipmentDropdownBtn');

                if (dropdown && button) {
                    if (!button.contains(event.target) && !dropdown.contains(event.target)) {
                        dropdown.style.display = 'none';
                        const icon = document.getElementById('equipmentDropdownIcon');
                        if (icon) {
                            icon.classList.remove('fa-chevron-up');
                            icon.classList.add('fa-chevron-down');
                        }
                    }
                }
            });

            function updateSelectedEquipment() {
                const checkboxes = document.querySelectorAll('.equipment-checkbox:checked');
                const display = document.getElementById('selectedEquipmentDisplay');
                const label = document.getElementById('equipmentDropdownLabel');

                if (checkboxes.length === 0) {
                    display.innerHTML = '';
                    label.innerHTML = '<i class="fas fa-list"></i> Chọn thiết bị cần hỗ trợ';
                    return;
                }

                // Update label
                label.innerHTML = `<i class="fas fa-check-circle text-success"></i> Đã chọn ${checkboxes.length} thiết bị`;

                // Update display
                let html = '<div class="alert alert-info mb-0 mt-2"><strong>Đã chọn ' + checkboxes.length + ' thiết bị:</strong><ul class="mb-0 mt-2">';
                checkboxes.forEach(function (cb) {
                    const model = cb.dataset.model;
                    const serial = cb.dataset.serial;
                    html += '<li><strong>' + model + '</strong> (SN: ' + serial + ')</li>';
                });
                html += '</ul></div>';
                display.innerHTML = html;
            }

// Reset dropdown khi đóng modal
            document.getElementById('createModal').addEventListener('hidden.bs.modal', function () {
                // Reset dropdown
                const menu = document.getElementById('equipmentDropdownMenu');
                if (menu) {
                    menu.style.display = 'none';
                }

                const icon = document.getElementById('equipmentDropdownIcon');
                if (icon) {
                    icon.classList.remove('fa-chevron-up');
                    icon.classList.add('fa-chevron-down');
                }

                // Uncheck all checkboxes
                document.querySelectorAll('.equipment-checkbox').forEach(cb => cb.checked = false);
                updateSelectedEquipment();
            });
        </script>



        <script>
            // ✅ Nút thanh toán hiển thị ngay cho tất cả đơn "Đang Xử Lý"
            // Không cần kiểm tra thêm điều kiện
            console.log('✅ Payment buttons are now visible for all "Đang Xử Lý" requests');
        </script>
    </body>
</html>
