<%-- 
    Document   : managerContracts
    Created on : Oct 28, 2025, 9:55:30 PM
    Author     : doand
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>CRM Dashboard - Quản Lý Hợp Đồng</title>
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

            .badge-expired {
                background-color: #dc3545;
            }

            .badge-pending {
                background-color: #ffc107;
                color: #000;
            }

            .badge-terminated {
                background-color: #6c757d;
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

            .contract-value {
                color: #198754;
                font-weight: 700;
                font-size: 1.1rem;
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
                    <i class="fas fa-chart-line"></i>
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
                    <a href="${pageContext.request.contextPath}/contracts" class="menu-item active">
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
                <h1 class="page-title"><i class="fas fa-file-contract"></i> Quản Lý Hợp Đồng</h1>
                <div class="d-flex gap-2">
                    <a href="${pageContext.request.contextPath}/managerServiceRequest" class="btn btn-secondary">
                        <i class="fas fa-arrow-left"></i> Quay Lại
                    </a>
                    <button class="btn btn-secondary" onclick="refreshPage()">
                        <i class="fas fa-sync"></i> Làm Mới
                    </button>
                    <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#createContractModal">
                        <i class="fas fa-plus"></i> Tạo Hợp Đồng Mới
                    </button>
                </div>
            </div>

            <div id="toastContainer"></div>

            <div class="content-wrapper">
                <!-- THỐNG KÊ -->
                <div class="row">
                    <div class="col-xl col-lg-3 col-md-6 col-sm-6">
                        <div class="stats-card bg-primary text-white">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h6>Tổng Hợp Đồng</h6>
                                    
                                </div>
                                <i class="fas fa-file-contract"></i>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl col-lg-3 col-md-6 col-sm-6">
                        <div class="stats-card bg-success text-white">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h6>Đang Hiệu Lực</h6>
                                   
                                </div>
                                <i class="fas fa-check-circle"></i>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl col-lg-3 col-md-6 col-sm-6">
                        <div class="stats-card bg-warning text-dark">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h6>Sắp Hết Hạn</h6>
                                   
                                </div>
                                <i class="fas fa-exclamation-triangle"></i>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl col-lg-3 col-md-6 col-sm-6">
                        <div class="stats-card bg-danger text-white">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h6>Đã Hết Hạn</h6>
                                    
                                </div>
                                <i class="fas fa-times-circle"></i>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- SEARCH & FILTER BAR -->
                <div class="search-filter-bar">
                    <form action="${pageContext.request.contextPath}/contracts" method="get" class="row g-3">
                        <div class="col-md-5">
                            <div class="input-group">
                                <input type="text" class="form-control" name="keyword" 
                                       placeholder="Tìm kiếm theo mã hợp đồng, khách hàng..." value="${param.keyword}">
                                <button class="btn btn-primary" type="submit" name="action" value="search">
                                    <i class="fas fa-search"></i> Tìm Kiếm
                                </button>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <select class="form-select" name="status" id="filterStatus">
                                <option value="">-- Tất Cả Trạng Thái --</option>
                                <option value="Active" ${param.status == 'Active' ? 'selected' : ''}>Đang Hiệu Lực</option>
                                <option value="Pending" ${param.status == 'Pending' ? 'selected' : ''}>Chờ Kích Hoạt</option>
                                <option value="Expired" ${param.status == 'Expired' ? 'selected' : ''}>Đã Hết Hạn</option>
                                <option value="Terminated" ${param.status == 'Terminated' ? 'selected' : ''}>Đã Chấm Dứt</option>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <select class="form-select" name="type">
                                <option value="">-- Loại Hợp Đồng --</option>
                                <option value="Service" ${param.type == 'Service' ? 'selected' : ''}>Dịch Vụ</option>
                                <option value="Maintenance" ${param.type == 'Maintenance' ? 'selected' : ''}>Bảo Trì</option>
                                <option value="Support" ${param.type == 'Support' ? 'selected' : ''}>Hỗ Trợ</option>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <button type="submit" name="action" value="filter" class="btn btn-info w-100">
                                <i class="fas fa-filter"></i> Lọc
                            </button>
                        </div>
                    </form>
                </div>

                <!-- BẢNG DANH SÁCH HỢP ĐỒNG -->
                <div class="table-container">
                    <div class="table-responsive">
                        <table class="table table-hover">
                            <thead class="table-light">
                                <tr>
                                    <th>Mã HĐ</th>
                                    <th>Khách Hàng</th>
                                    <th>Loại HĐ</th>
                                    <th>Ngày Bắt Đầu</th>
                                    <th>Ngày Kết Thúc</th>
                                    <th>Giá Trị (VNĐ)</th>
                                    <th>Trạng Thái</th>
                                    <th>Thao Tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <!-- Sample Data Row 1 -->
                                <tr>
                                    <td><strong>#CT001</strong></td>
                                    <td>Công Ty TNHH ABC</td>
                                    <td><span class="badge bg-primary">Dịch Vụ</span></td>
                                    <td>01/01/2025</td>
                                    <td>31/12/2025</td>
                                    <td><span class="contract-value">250,000,000</span></td>
                                    <td><span class="badge badge-active">Hiệu Lực</span></td>
                                    <td>
                                        <button class="btn btn-sm btn-info btn-action" onclick="viewContract(1)">
                                            <i class="fas fa-eye"></i> Chi Tiết
                                        </button>
                                        <button class="btn btn-sm btn-warning btn-action" onclick="editContract(1)">
                                            <i class="fas fa-edit"></i> Sửa
                                        </button>
                                        <button class="btn btn-sm btn-success btn-action" onclick="renewContract(1)">
                                            <i class="fas fa-redo"></i> Gia Hạn
                                        </button>
                                    </td>
                                </tr>
                                <!-- Sample Data Row 2 -->
                                <tr>
                                    <td><strong>#CT002</strong></td>
                                    <td>Công Ty Cổ Phần XYZ</td>
                                    <td><span class="badge bg-success">Bảo Trì</span></td>
                                    <td>15/03/2025</td>
                                    <td>14/03/2026</td>
                                    <td><span class="contract-value">180,000,000</span></td>
                                    <td><span class="badge badge-active">Hiệu Lực</span></td>
                                    <td>
                                        <button class="btn btn-sm btn-info btn-action" onclick="viewContract(2)">
                                            <i class="fas fa-eye"></i> Chi Tiết
                                        </button>
                                        <button class="btn btn-sm btn-warning btn-action" onclick="editContract(2)">
                                            <i class="fas fa-edit"></i> Sửa
                                        </button>
                                        <button class="btn btn-sm btn-success btn-action" onclick="renewContract(2)">
                                            <i class="fas fa-redo"></i> Gia Hạn
                                        </button>
                                    </td>
                                </tr>
                                <!-- Sample Data Row 3 -->
                                <tr>
                                    <td><strong>#CT003</strong></td>
                                    <td>Doanh Nghiệp Tư Nhân 123</td>
                                    <td><span class="badge bg-info">Hỗ Trợ</span></td>
                                    <td>20/02/2025</td>
                                    <td>19/11/2025</td>
                                    <td><span class="contract-value">95,000,000</span></td>
                                    <td><span class="badge badge-pending">Chờ Kích Hoạt</span></td>
                                    <td>
                                        <button class="btn btn-sm btn-info btn-action" onclick="viewContract(3)">
                                            <i class="fas fa-eye"></i> Chi Tiết
                                        </button>
                                        <button class="btn btn-sm btn-success btn-action" onclick="activateContract(3)">
                                            <i class="fas fa-check"></i> Kích Hoạt
                                        </button>
                                        <button class="btn btn-sm btn-warning btn-action" onclick="editContract(3)">
                                            <i class="fas fa-edit"></i> Sửa
                                        </button>
                                    </td>
                                </tr>
                                <!-- Sample Data Row 4 -->
                                <tr>
                                    <td><strong>#CT004</strong></td>
                                    <td>Công Ty TNHH DEF</td>
                                    <td><span class="badge bg-primary">Dịch Vụ</span></td>
                                    <td>10/06/2024</td>
                                    <td>09/06/2025</td>
                                    <td><span class="contract-value">320,000,000</span></td>
                                    <td><span class="badge bg-warning text-dark">Sắp Hết Hạn</span></td>
                                    <td>
                                        <button class="btn btn-sm btn-info btn-action" onclick="viewContract(4)">
                                            <i class="fas fa-eye"></i> Chi Tiết
                                        </button>
                                        <button class="btn btn-sm btn-success btn-action" onclick="renewContract(4)">
                                            <i class="fas fa-redo"></i> Gia Hạn
                                        </button>
                                        <button class="btn btn-sm btn-warning btn-action" onclick="editContract(4)">
                                            <i class="fas fa-edit"></i> Sửa
                                        </button>
                                    </td>
                                </tr>
                                <!-- Sample Data Row 5 -->
                                <tr>
                                    <td><strong>#CT005</strong></td>
                                    <td>Tập Đoàn GHI</td>
                                    <td><span class="badge bg-success">Bảo Trì</span></td>
                                    <td>05/01/2024</td>
                                    <td>04/01/2025</td>
                                    <td><span class="contract-value">450,000,000</span></td>
                                    <td><span class="badge badge-expired">Đã Hết Hạn</span></td>
                                    <td>
                                        <button class="btn btn-sm btn-info btn-action" onclick="viewContract(5)">
                                            <i class="fas fa-eye"></i> Chi Tiết
                                        </button>
                                        <button class="btn btn-sm btn-success btn-action" onclick="renewContract(5)">
                                            <i class="fas fa-redo"></i> Gia Hạn
                                        </button>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>

                    <!-- PHÂN TRANG -->
                    <nav aria-label="Page navigation" class="mt-4">
                        <ul class="pagination justify-content-center">
                            <li class="page-item disabled">
                                <span class="page-link">
                                    <i class="fas fa-chevron-left"></i> Trước
                                </span>
                            </li>
                            <li class="page-item active">
                                <span class="page-link">1</span>
                            </li>
                            <li class="page-item">
                                <a class="page-link" href="#">2</a>
                            </li>
                            <li class="page-item">
                                <a class="page-link" href="#">3</a>
                            </li>
                            <li class="page-item">
                                <a class="page-link" href="#">
                                    Tiếp <i class="fas fa-chevron-right"></i>
                                </a>
                            </li>
                        </ul>
                    </nav>

                    <div class="text-center text-muted mb-3">
                        <small>
                            Trang <strong>1</strong> của <strong>3</strong> 
                            | Hiển thị <strong>5</strong> hợp đồng
                        </small>
                    </div>
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

        <!-- ========== MODAL TẠO HỢP ĐỒNG MỚI ========== -->
        <div class="modal fade" id="createContractModal" tabindex="-1">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <form action="${pageContext.request.contextPath}/contracts" method="post" id="createContractForm">
                        <input type="hidden" name="action" value="create">
                        <div class="modal-header bg-primary text-white">
                            <h5 class="modal-title"><i class="fas fa-plus"></i> Tạo Hợp Đồng Mới</h5>
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                        </div>
                        <div class="modal-body">
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">Mã Khách Hàng <span class="text-danger">*</span></label>
                                    <input type="number" class="form-control" name="customerId" required min="1">
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">Loại Hợp Đồng <span class="text-danger">*</span></label>
                                    <select class="form-select" name="contractType" required>
                                        <option value="">-- Chọn Loại --</option>
                                        <option value="Service">Dịch Vụ</option>
                                        <option value="Maintenance">Bảo Trì</option>
                                        <option value="Support">Hỗ Trợ</option>
                                    </select>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">Ngày Bắt Đầu <span class="text-danger">*</span></label>
                                    <input type="date" class="form-control" name="startDate" required>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">Ngày Kết Thúc <span class="text-danger">*</span></label>
                                    <input type="date" class="form-control" name="endDate" required>
                                </div>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Giá Trị Hợp Đồng (VNĐ) <span class="text-danger">*</span></label>
                                <input type="number" class="form-control" name="contractValue" required min="0" step="1000">
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Điều Khoản & Điều Kiện</label>
                                <textarea class="form-control" name="terms" rows="4" placeholder="Nhập các điều khoản và điều kiện của hợp đồng..."></textarea>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Ghi Chú</label>
                                <textarea class="form-control" name="notes" rows="3" placeholder="Ghi chú thêm (nếu có)..."></textarea>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                            <button type="submit" class="btn btn-primary"><i class="fas fa-save"></i> Tạo Hợp Đồng</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <!-- ========== MODAL XEM CHI TIẾT HỢP ĐỒNG ========== -->
        <div class="modal fade" id="viewContractModal" tabindex="-1">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header bg-info text-white">
                        <h5 class="modal-title"><i class="fas fa-file-alt"></i> Chi Tiết Hợp Đồng</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div class="row mb-3">
                            <div class="col-md-6"><strong>Mã Hợp Đồng:</strong> <p id="viewContractId"></p></div>
                            <div class="col-md-6"><strong>Khách Hàng:</strong> <p id="viewCustomer"></p></div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-md-6"><strong>Loại Hợp Đồng:</strong> <p id="viewType"></p></div>
                            <div class="col-md-6"><strong>Trạng Thái:</strong> <span id="viewStatus"></span></div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-md-6"><strong>Ngày Bắt Đầu:</strong> <p id="viewStartDate"></p></div>
                            <div class="col-md-6"><strong>Ngày Kết Thúc:</strong> <p id="viewEndDate"></p></div>
                        </div>
                        <div class="mb-3">
                            <strong>Giá Trị:</strong> <span class="contract-value" id="viewValue"></span> VNĐ
                        </div>
                        <div class="mb-3">
                            <strong>Điều Khoản:</strong>
                            <div class="border rounded p-3 bg-light" id="viewTerms" style="white-space: pre-wrap;"></div>
                        </div>
                        <div class="mb-3">
                            <strong>Ghi Chú:</strong>
                            <div class="border rounded p-3 bg-light" id="viewNotes" style="white-space: pre-wrap;"></div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- ========== MODAL CHỈNH SỬA HỢP ĐỒNG ========== -->
        <div class="modal fade" id="editContractModal" tabindex="-1">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <form action="${pageContext.request.contextPath}/contracts" method="post" id="editContractForm">
                        <input type="hidden" name="action" value="update">
                        <input type="hidden" name="contractId" id="editContractId">
                        <div class="modal-header bg-warning text-dark">
                            <h5 class="modal-title"><i class="fas fa-edit"></i> Chỉnh Sửa Hợp Đồng</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                        </div>
                        <div class="modal-body">
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">Loại Hợp Đồng <span class="text-danger">*</span></label>
                                    <select class="form-select" name="contractType" id="editContractType" required>
                                        <option value="Service">Dịch Vụ</option>
                                        <option value="Maintenance">Bảo Trì</option>
                                        <option value="Support">Hỗ Trợ</option>
                                    </select>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">Trạng Thái <span class="text-danger">*</span></label>
                                    <select class="form-select" name="status" id="editStatus" required>
                                        <option value="Active">Đang Hiệu Lực</option>
                                        <option value="Pending">Chờ Kích Hoạt</option>
                                        <option value="Expired">Đã Hết Hạn</option>
                                        <option value="Terminated">Đã Chấm Dứt</option>
                                    </select>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">Ngày Kết Thúc <span class="text-danger">*</span></label>
                                    <input type="date" class="form-control" name="endDate" id="editEndDate" required>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">Giá Trị (VNĐ) <span class="text-danger">*</span></label>
                                    <input type="number" class="form-control" name="contractValue" id="editValue" required min="0" step="1000">
                                </div>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Điều Khoản</label>
                                <textarea class="form-control" name="terms" id="editTerms" rows="4"></textarea>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Ghi Chú</label>
                                <textarea class="form-control" name="notes" id="editNotes" rows="3"></textarea>
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

        <!-- ========== MODAL GIA HẠN HỢP ĐỒNG ========== -->
        <div class="modal fade" id="renewContractModal" tabindex="-1">
            <div class="modal-dialog">
                <div class="modal-content">
                    <form action="${pageContext.request.contextPath}/contracts" method="post">
                        <input type="hidden" name="action" value="renew">
                        <input type="hidden" name="contractId" id="renewContractId">
                        <div class="modal-header bg-success text-white">
                            <h5 class="modal-title"><i class="fas fa-redo"></i> Gia Hạn Hợp Đồng</h5>
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                        </div>
                        <div class="modal-body">
                            <p>Xác nhận gia hạn hợp đồng <strong id="renewContractCode"></strong>?</p>
                            <div class="mb-3">
                                <label class="form-label">Thời Hạn Gia Hạn <span class="text-danger">*</span></label>
                                <select class="form-select" name="renewalPeriod" required>
                                    <option value="3">3 Tháng</option>
                                    <option value="6">6 Tháng</option>
                                    <option value="12" selected>12 Tháng</option>
                                    <option value="24">24 Tháng</option>
                                </select>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Ghi Chú Gia Hạn</label>
                                <textarea class="form-control" name="renewalNote" rows="3"></textarea>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                            <button type="submit" class="btn btn-success">Xác Nhận Gia Hạn</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <!-- ========== MODAL KÍCH HOẠT HỢP ĐỒNG ========== -->
        <div class="modal fade" id="activateContractModal" tabindex="-1">
            <div class="modal-dialog">
                <div class="modal-content">
                    <form action="${pageContext.request.contextPath}/contracts" method="post">
                        <input type="hidden" name="action" value="activate">
                        <input type="hidden" name="contractId" id="activateContractId">
                        <div class="modal-header bg-success text-white">
                            <h5 class="modal-title"><i class="fas fa-check"></i> Kích Hoạt Hợp Đồng</h5>
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                        </div>
                        <div class="modal-body">
                            <p>Xác nhận kích hoạt hợp đồng <strong id="activateContractCode"></strong>?</p>
                            <div class="alert alert-info">
                                <i class="fas fa-info-circle"></i> Hợp đồng sẽ bắt đầu có hiệu lực ngay sau khi được kích hoạt.
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                            <button type="submit" class="btn btn-success">Xác Nhận</button>
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
                }

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

                // ========== REFRESH PAGE ==========
                function refreshPage() {
                    location.reload();
                }

                // ========== VIEW CONTRACT DETAILS ==========
                function viewContract(id) {
                    // Sample data - trong thực tế sẽ lấy từ server
                    const contracts = {
                        1: {
                            code: '#CT001',
                            customer: 'Công Ty TNHH ABC',
                            type: 'Dịch Vụ',
                            status: 'Hiệu Lực',
                            startDate: '01/01/2025',
                            endDate: '31/12/2025',
                            value: '250,000,000',
                            terms: 'Các điều khoản và điều kiện của hợp đồng dịch vụ...',
                            notes: 'Ghi chú về hợp đồng...'
                        },
                        2: {
                            code: '#CT002',
                            customer: 'Công Ty Cổ Phần XYZ',
                            type: 'Bảo Trì',
                            status: 'Hiệu Lực',
                            startDate: '15/03/2025',
                            endDate: '14/03/2026',
                            value: '180,000,000',
                            terms: 'Các điều khoản bảo trì định kỳ theo lịch...',
                            notes: 'Bảo trì hàng tháng'
                        },
                        3: {
                            code: '#CT003',
                            customer: 'Doanh Nghiệp Tư Nhân 123',
                            type: 'Hỗ Trợ',
                            status: 'Chờ Kích Hoạt',
                            startDate: '20/02/2025',
                            endDate: '19/11/2025',
                            value: '95,000,000',
                            terms: 'Điều khoản hỗ trợ kỹ thuật 24/7...',
                            notes: 'Đang chờ xác nhận từ khách hàng'
                        },
                        4: {
                            code: '#CT004',
                            customer: 'Công Ty TNHH DEF',
                            type: 'Dịch Vụ',
                            status: 'Sắp Hết Hạn',
                            startDate: '10/06/2024',
                            endDate: '09/06/2025',
                            value: '320,000,000',
                            terms: 'Điều khoản dịch vụ toàn diện...',
                            notes: 'Cần liên hệ gia hạn'
                        },
                        5: {
                            code: '#CT005',
                            customer: 'Tập Đoàn GHI',
                            type: 'Bảo Trì',
                            status: 'Đã Hết Hạn',
                            startDate: '05/01/2024',
                            endDate: '04/01/2025',
                            value: '450,000,000',
                            terms: 'Bảo trì định kỳ cho hệ thống lớn...',
                            notes: 'Hết hạn cần làm mới'
                        }
                    };

                    const contract = contracts[id];
                    if (contract) {
                        document.getElementById('viewContractId').textContent = contract.code;
                        document.getElementById('viewCustomer').textContent = contract.customer;
                        document.getElementById('viewType').textContent = contract.type;
                        document.getElementById('viewStatus').innerHTML = '<span class="badge badge-active">' + contract.status + '</span>';
                        document.getElementById('viewStartDate').textContent = contract.startDate;
                        document.getElementById('viewEndDate').textContent = contract.endDate;
                        document.getElementById('viewValue').textContent = contract.value;
                        document.getElementById('viewTerms').textContent = contract.terms;
                        document.getElementById('viewNotes').textContent = contract.notes;

                        const modal = new bootstrap.Modal(document.getElementById('viewContractModal'));
                        modal.show();
                    }
                }

                // ========== EDIT CONTRACT ==========
                function editContract(id) {
                    // Sample data
                    const contracts = {
                        1: {type: 'Service', status: 'Active', endDate: '2025-12-31', value: '250000000', terms: 'Các điều khoản...', notes: 'Ghi chú...'},
                        2: {type: 'Maintenance', status: 'Active', endDate: '2026-03-14', value: '180000000', terms: 'Bảo trì...', notes: 'Hàng tháng'},
                        3: {type: 'Support', status: 'Pending', endDate: '2025-11-19', value: '95000000', terms: 'Hỗ trợ...', notes: 'Chờ xác nhận'},
                        4: {type: 'Service', status: 'Active', endDate: '2025-06-09', value: '320000000', terms: 'Toàn diện...', notes: 'Cần gia hạn'},
                        5: {type: 'Maintenance', status: 'Expired', endDate: '2025-01-04', value: '450000000', terms: 'Định kỳ...', notes: 'Hết hạn'}
                    };

                    const contract = contracts[id];
                    if (contract) {
                        document.getElementById('editContractId').value = id;
                        document.getElementById('editContractType').value = contract.type;
                        document.getElementById('editStatus').value = contract.status;
                        document.getElementById('editEndDate').value = contract.endDate;
                        document.getElementById('editValue').value = contract.value;
                        document.getElementById('editTerms').value = contract.terms;
                        document.getElementById('editNotes').value = contract.notes;

                        const modal = new bootstrap.Modal(document.getElementById('editContractModal'));
                        modal.show();
                    }
                }

                // ========== RENEW CONTRACT ==========
                function renewContract(id) {
                    const contractCodes = {
                        1: '#CT001',
                        2: '#CT002',
                        3: '#CT003',
                        4: '#CT004',
                        5: '#CT005'
                    };

                    document.getElementById('renewContractId').value = id;
                    document.getElementById('renewContractCode').textContent = contractCodes[id];

                    const modal = new bootstrap.Modal(document.getElementById('renewContractModal'));
                    modal.show();
                }

                // ========== ACTIVATE CONTRACT ==========
                function activateContract(id) {
                    const contractCodes = {
                        3: '#CT003'
                    };

                    document.getElementById('activateContractId').value = id;
                    document.getElementById('activateContractCode').textContent = contractCodes[id];

                    const modal = new bootstrap.Modal(document.getElementById('activateContractModal'));
                    modal.show();
                }

                // ========== SCROLL TO TOP ==========
                function scrollToTop() {
                    window.scrollTo({top: 0, behavior: 'smooth'});
                }

                // Show/hide scroll to top button
                window.addEventListener('scroll', function () {
                    const scrollBtn = document.getElementById('scrollToTop');
                    if (window.pageYOffset > 300) {
                        scrollBtn.classList.add('show');
                    } else {
                        scrollBtn.classList.remove('show');
                    }
                });

                // ========== FILTER STATUS CHANGE ==========
                document.getElementById('filterStatus')?.addEventListener('change', function () {
                    this.form.submit();
                });

                // ========== FORM VALIDATION ==========
                document.getElementById('createContractForm')?.addEventListener('submit', function (e) {
                    const startDate = new Date(this.startDate.value);
                    const endDate = new Date(this.endDate.value);

                    if (endDate <= startDate) {
                        e.preventDefault();
                        showToast('Ngày kết thúc phải sau ngày bắt đầu!', 'error');
                        return false;
                    }
                });

                document.getElementById('editContractForm')?.addEventListener('submit', function (e) {
                    const value = this.contractValue.value;

                    if (value <= 0) {
                        e.preventDefault();
                        showToast('Giá trị hợp đồng phải lớn hơn 0!', 'error');
                        return false;
                    }
                });

                // ========== AUTO HIDE ALERTS ==========
                window.addEventListener('load', function () {
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