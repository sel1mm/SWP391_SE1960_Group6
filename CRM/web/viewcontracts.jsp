<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Hợp Đồng Của Tôi</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
        <style>
            body {
                background-color: #f4f4f4;
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
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
                width: calc(100% - 260px);
                overflow-x: hidden;
            }

            .sidebar.collapsed ~ .main-content {
                margin-left: 70px;
                width: calc(100% - 70px);
            }

            .content-wrapper {
                padding: 30px;
                max-width: 100%;
            }

            .sidebar.collapsed ~ .main-content {
                margin-left: 70px;
            }

            .main-content {
                background-color: #fff;
                min-height: 100vh;
            }

            .table-hover tbody tr:hover {
                background-color: rgba(0, 0, 0, 0.05);
            }

            .card-header {
                background-color: #000;
                color: #fff;
            }

            .customer-tooltip {
                position: relative;
                cursor: pointer;
            }

            .customer-tooltip:hover .tooltip-content {
                display: block;
            }

            .tooltip-content {
                display: none;
                position: absolute;
                background: #333;
                color: #fff;
                padding: 10px;
                border-radius: 6px;
                z-index: 1000;
                min-width: 200px;
                font-size: 0.85rem;
                top: 100%;
                left: 0;
                margin-top: 5px;
            }

            .appendix-item {
                border-left: 3px solid #0d6efd;
                padding: 10px;
                margin-bottom: 10px;
                background-color: #f8f9fa;
                border-radius: 4px;
            }

            .table-responsive {
                overflow-x: auto;
                -webkit-overflow-scrolling: touch;
            }

            .table {
                width: 100%;
                margin-bottom: 0;
            }

            .table th,
            .table td {
                white-space: nowrap;
                vertical-align: middle;
            }
            .search-filter-bar {
                background: white;
                padding: 20px;
                border-radius: 10px;
                margin-bottom: 20px;
                box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            }

            /* ✨ ENHANCED Custom badge styles for contract types - Màu sắc rõ ràng và đẹp hơn */
            .badge-gradient {
                padding: 8px 14px;
                border-radius: 20px;
                font-weight: 600;
                font-size: 0.85rem;
                box-shadow: 0 2px 8px rgba(0,0,0,0.15);
                transition: all 0.3s ease;
                display: inline-flex;
                align-items: center;
                gap: 6px;
            }

            .badge-gradient:hover {
                transform: translateY(-2px);
                box-shadow: 0 4px 12px rgba(0,0,0,0.25);
            }

            .badge-gradient i {
                font-size: 0.9rem;
            }

            /* Sales - Màu tím đậm sang trọng */
            .badge-sales {
                background: linear-gradient(135deg, #6a11cb 0%, #2575fc 100%);
                color: white;
            }

            .badge-sales:hover {
                box-shadow: 0 4px 12px rgba(106, 17, 203, 0.4);
            }

            /* Warranty - Màu cam rực rỡ */
            .badge-warranty {
                background: linear-gradient(135deg, #f2994a 0%, #f2c94c 100%);
                color: white;
            }

            .badge-warranty:hover {
                box-shadow: 0 4px 12px rgba(242, 153, 74, 0.4);
            }

            /* Maintenance/Bảo trì - Màu xanh cyan sáng */
            .badge-maintenance {
                background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%);
                color: white;
            }

            .badge-maintenance:hover {
                box-shadow: 0 4px 12px rgba(17, 153, 142, 0.4);
            }

            /* Appendix/Phụ lục - Màu hồng pastel */
            .badge-appendix {
                background: linear-gradient(135deg, #ec008c 0%, #fc6767 100%);
                color: white;
            }

            .badge-appendix:hover {
                box-shadow: 0 4px 12px rgba(236, 0, 140, 0.4);
            }

            /* Main Contract/Hợp đồng chính - Màu xanh navy chuyên nghiệp */
            .badge-contract {
                background: linear-gradient(135deg, #1e3799 0%, #0c2461 100%);
                color: white;
            }

            .badge-contract:hover {
                box-shadow: 0 4px 12px rgba(30, 55, 153, 0.4);
            }

            /* Unknown/Không xác định - Màu xám */
            .badge-unknown {
                background: linear-gradient(135deg, #636e72 0%, #2d3436 100%);
                color: white;
            }

            .badge-unknown:hover {
                box-shadow: 0 4px 12px rgba(99, 110, 114, 0.4);
            }

            /* ✨ Animation cho badge */
            .badge-gradient {
                position: relative;
                overflow: hidden;
            }

            .badge-gradient::before {
                content: '';
                position: absolute;
                top: 0;
                left: -100%;
                width: 100%;
                height: 100%;
                background: rgba(255, 255, 255, 0.2);
                transition: left 0.5s ease;
            }

            .badge-gradient:hover::before {
                left: 100%;
            }

            /* Pulsing effect cho badge quan trọng */
            @keyframes pulse {
                0%, 100% {
                    box-shadow: 0 2px 8px rgba(0,0,0,0.15);
                }
                50% {
                    box-shadow: 0 4px 16px rgba(0,0,0,0.25);
                }
            }

            .badge-gradient.important {
                animation: pulse 2s infinite;
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

            /* SCROLL TO TOP BUTTON */
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

            /* RESPONSIVE FOOTER */
            @media (max-width: 768px) {
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
            /* 🎯 CHỈ THAY ĐỔI MÀU - KHÔNG THAY ĐỔI CẤU TRÚC */

            /* Màu xanh lá sáng cho "Đang hoạt động" */
            .text-success {
                color: #10b981 !important;
            }

            /* Màu xanh dương sáng cho "Đã hoàn thành" */
            .text-primary {
                color: #3b82f6 !important;
            }

            /* Loại bỏ độ mờ của icon */
            .card-body > div > div {
                opacity: 1 !important;
            }

            /* Thêm bóng cho icon success */
            .card-body .text-success i {
                filter: drop-shadow(0 2px 6px rgba(16, 185, 129, 0.4));
            }

            /* Thêm bóng cho icon primary */
            .card-body .text-primary i {
                filter: drop-shadow(0 2px 6px rgba(59, 130, 246, 0.4));
            }

        </style>
    </head>

    <body>

        <div class="row">
            <!-- SIDEBAR -->
            <div class="sidebar" id="sidebar">
                <div class="sidebar-toggle" onclick="toggleSidebar()">
                    <i class="fas fa-chevron-left" id="toggleIcon"></i>
                </div>

                <div class="sidebar-header">
                    <a href="#" class="sidebar-brand">                
                        <span>CRM System</span>
                    </a>
                </div>

                <div class="sidebar-menu">
                    <div class="menu-section">
                        <a href="${pageContext.request.contextPath}/dashbroadCustomer.jsp" class="menu-item">
                            <i class="fas fa-home"></i>
                            <span>Dashboard</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/managerServiceRequest" class="menu-item">
                            <i class="fas fa-clipboard-list"></i>
                            <span>Yêu Cầu Dịch Vụ</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/viewcontracts" class="menu-item active">
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

            <!-- Main Content -->
            <div class="main-content">
                <div class="content-wrapper">
                    <!-- Header -->
                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <h2><i class="fas fa-file-contract text-dark"></i> Hợp Đồng Của Tôi</h2>
                        <div class="d-flex align-items-center gap-3">
                            <span>Xin chào, <strong>${sessionScope.session_login.username}</strong></span>
                        </div>
                    </div>

                    <!-- Statistics Cards -->
                    <div class="row mb-4">
                        <div class="col-md-6">
                            <div class="card border-0 shadow-sm">
                                <div class="card-body">
                                    <div class="d-flex justify-content-between align-items-center">
                                        <div>
                                            <h6 class="text-muted mb-1">Đang hoạt động</h6>
                                            <h3 class="mb-0 text-success" id="activeCount">${activeCount}</h3>
                                        </div>
                                        <div class="text-success" style="font-size: 3rem; opacity: 0.3;">
                                            <i class="fas fa-check-circle"></i>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="card border-0 shadow-sm">
                                <div class="card-body">
                                    <div class="d-flex justify-content-between align-items-center">
                                        <div>
                                            <h6 class="text-muted mb-1">Đã hoàn thành</h6>
                                            <h3 class="mb-0 text-primary" id="completedCount">${completedCount}</h3>
                                        </div>
                                        <div class="text-primary" style="font-size: 3rem; opacity: 0.3;">
                                            <i class="fas fa-flag-checkered"></i>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Search & Filter -->
                    <div class="search-filter-bar">
                        <form action="viewcontracts" method="GET">      
                            <!-- Hàng 1: Search + Dropdowns -->
                            <div class="row g-3 mb-2">
                                <div class="col-md-3">
                                    <label class="form-label fw-bold">
                                        <i class="fas fa-search"></i> Tìm kiếm
                                    </label>
                                    <input type="text" class="form-control" name="keyword"
                                           placeholder="Mã hợp đồng, loại hợp đồng..."
                                           value="${param.keyword}">
                                </div>

                                <div class="col-md-2">
                                    <label class="form-label fw-bold">
                                        <i class="fas fa-toggle-on"></i> Trạng thái
                                    </label>
                                    <select name="status" class="form-select">
                                        <option value="">Tất cả</option>
                                        <optgroup label="Hợp đồng chính">
                                            <option value="Active" ${param.status == 'Active' ? 'selected' : ''}>Active</option>
                                            <option value="Completed" ${param.status == 'Completed' ? 'selected' : ''}>Completed</option>
                                            <option value="Cancelled" ${param.status == 'Cancelled' ? 'selected' : ''}>Cancelled</option>
                                        </optgroup>
                                        <optgroup label="Phụ lục">
                                            <option value="Approved" ${param.status == 'Approved' ? 'selected' : ''}>Đã duyệt</option>
                                            <option value="Draft" ${param.status == 'Draft' ? 'selected' : ''}>Bản nháp</option>
                                            <option value="Archived" ${param.status == 'Archived' ? 'selected' : ''}>Lưu trữ</option>
                                        </optgroup>
                                    </select>
                                </div>

                                <div class="col-md-3">
                                    <label class="form-label fw-bold">
                                        <i class="fas fa-file-contract"></i> Loại hợp đồng
                                    </label>
                                    <select name="contractType" class="form-select">
                                        <option value="">Tất cả</option>
                                        <option value="Sales" ${param.contractType == 'Sales' ? 'selected' : ''}>Mua bán (Sales)</option>
                                        <option value="Warranty" ${param.contractType == 'Warranty' ? 'selected' : ''}>Bảo hành (Warranty)</option>
                                        <option value="Maintenance" ${param.contractType == 'Maintenance' ? 'selected' : ''}>Bảo trì (Maintenance)</option>
                                        <option value="Bảo trì" ${param.contractType == 'Bảo trì' ? 'selected' : ''}>Bảo trì</option>
                                    </select>
                                </div>

                                <div class="col-md-4">
                                    <label class="form-label fw-bold">
                                        <i class="fas fa-sort"></i> Sắp xếp
                                    </label>
                                    <select name="sortBy" class="form-select">
                                        <option value="newest" ${param.sortBy == 'newest' ? 'selected' : ''}>Mới nhất</option>
                                        <option value="oldest" ${param.sortBy == 'oldest' ? 'selected' : ''}>Cũ nhất</option>
                                        <option value="id_asc" ${param.sortBy == 'id_asc' ? 'selected' : ''}>Mã HĐ A-Z</option>
                                        <option value="id_desc" ${param.sortBy == 'id_desc' ? 'selected' : ''}>Mã HĐ Z-A</option>
                                    </select>
                                </div>
                            </div>

                            <!-- Hàng 2: Date range -->
                            <div class="row g-3 mb-2 align-items-end">
                                <div class="col-md-3">
                                    <label class="form-label fw-bold">
                                        <i class="fas fa-calendar-alt"></i> Từ ngày ký
                                    </label>
                                    <input type="date" class="form-control" name="fromDate" value="${param.fromDate}">
                                </div>

                                <div class="col-md-3">
                                    <label class="form-label fw-bold">
                                        <i class="fas fa-calendar-alt"></i> Đến ngày ký
                                    </label>
                                    <input type="date" class="form-control" name="toDate" value="${param.toDate}">
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
                                    <a href="viewcontracts" class="btn btn-outline-dark">
                                        <i class="fas fa-sync-alt me-1"></i> Làm mới
                                    </a>
                                </div>
                            </div>
                        </form>
                    </div>

                    <!-- Contracts Table -->
                    <div class="card">
                        <div class="card-header">
                            <h5 class="mb-0"><i class="fas fa-list"></i> Danh sách hợp đồng</h5>
                        </div>
                        <div class="card-body p-0">
                            <div class="table-responsive">
                                <table class="table table-hover mb-0">
                                    <thead class="table-light">
                                        <tr>
                                            <th>Mã hợp đồng</th>
                                            <th>Loại hợp đồng</th>
                                            <th>Ngày ký</th>
                                            <th>Trạng thái</th>
                                            <th>Chi tiết</th>
                                            <th>Lịch sử Yêu cầu</th>
                                            <th>Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="contract" items="${contractList}" varStatus="status">
                                            <tr 
                                                data-contractid="${contract.contractId}"
                                                data-customerid="${contract.customerId}"
                                                data-customername="${contract.customerName}"
                                                data-customeremail="${contract.customerEmail}"
                                                data-customerphone="${contract.customerPhone}"
                                                data-customeraddress="${contract.customerAddress}"
                                                data-verified="${contract.verified}"
                                                data-contracttype="${contract.contractType}"
                                                data-contractdate="${contract.contractDate}"
                                                data-startdate="${contract.startDate}"
                                                data-enddate="${contract.endDate}"
                                                data-status="${contract.status}"
                                                data-details="${contract.details}"
                                                data-equipmentcount="${contract.equipmentCount}">

                                                <td><strong>#${contract.contractId}</strong></td>

                                                <!-- Cột Loại Hợp Đồng -->
                                                <td>
                                                    <c:choose>
                                                        <%-- Sales - Tím đậm --%>
                                                        <c:when test="${contract.contractType eq 'Sales'}">
                                                            <span class="badge badge-gradient badge-sales">
                                                                <i class="fas fa-shopping-cart"></i> 
                                                                <span>Sales</span>
                                                            </span>
                                                        </c:when>

                                                        <%-- Warranty - Cam --%>
                                                        <c:when test="${contract.contractType eq 'Warranty'}">
                                                            <span class="badge badge-gradient badge-warranty">
                                                                <i class="fas fa-shield-alt"></i> 
                                                                <span>Warranty</span>
                                                            </span>
                                                        </c:when>

                                                        <%-- Bảo trì - Xanh lá --%>
                                                        <c:when test="${contract.contractType eq 'Bảo trì' or contract.contractType eq 'Maintenance'}">
                                                            <span class="badge badge-gradient badge-maintenance">
                                                                <i class="fas fa-tools"></i> 
                                                                <span>Bảo Trì</span>
                                                            </span>
                                                        </c:when>

                                                        <%-- Phụ lục - Hồng --%>
                                                        <c:when test="${contract.contractType eq 'Appendix'}">
                                                            <span class="badge badge-gradient badge-appendix">
                                                                <i class="fas fa-file-plus"></i> 
                                                                <span>Phụ Lục</span>
                                                            </span>
                                                        </c:when>

                                                        <%-- Hợp đồng chính - Navy --%>
                                                        <c:when test="${contract.contractType eq 'MainContract' or empty contract.contractType}">
                                                            <span class="badge badge-gradient badge-contract">
                                                                <i class="fas fa-file-contract"></i> 
                                                                <span>Hợp Đồng</span>
                                                            </span>
                                                        </c:when>

                                                        <%-- Không xác định - Xám --%>
                                                        <c:otherwise>
                                                            <span class="badge badge-gradient badge-unknown">
                                                                <i class="fas fa-question"></i> 
                                                                <span>${contract.contractType}</span>
                                                            </span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>${contract.contractDate}</td>

                                                <td>
                                                    <c:choose>
                                                        <%-- Trạng thái hợp đồng chính --%>
                                                        <c:when test="${contract.status eq 'Active'}">
                                                            <span class="badge bg-success">Active</span>
                                                        </c:when>
                                                        <c:when test="${contract.status eq 'Completed'}">
                                                            <span class="badge bg-primary">Completed</span>
                                                        </c:when>
                                                        <c:when test="${contract.status eq 'Cancelled'}">
                                                            <span class="badge bg-danger">Cancelled</span>
                                                        </c:when>

                                                        <%-- Trạng thái hợp đồng phụ lục --%>
                                                        <c:when test="${contract.status eq 'Approved'}">
                                                            <span class="badge bg-success">Đã duyệt</span>
                                                        </c:when>
                                                        <c:when test="${contract.status eq 'Draft'}">
                                                            <span class="badge bg-warning text-dark">Bản nháp</span>
                                                        </c:when>
                                                        <c:when test="${contract.status eq 'Archived'}">
                                                            <span class="badge bg-secondary">Lưu trữ</span>
                                                        </c:when>

                                                        <%-- Trạng thái không xác định --%>
                                                        <c:otherwise>
                                                            <span class="badge bg-secondary">${contract.status}</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>

                                                <td>
                                                    <small class="text-muted">${contract.details}</small>
                                                </td>

                                                <!-- Số yêu cầu liên quan -->
                                                <td class="text-center">
                                                    <button class="btn btn-sm btn-outline-info" 
                                                            onclick="viewServiceRequests('${contract.contractId}')">
                                                        <i class="fas fa-clipboard-list"></i> 
                                                        ${contract.requestCount > 0 ? contract.requestCount : '0'}
                                                    </button>
                                                </td>

                                                <td>
                                                    <div class="btn-group">
                                                        <button class="btn btn-sm btn-outline-dark" 
                                                                title="Xem chi tiết"
                                                                onclick="viewContractDetailsWithAppendix('${contract.contractId}')">
                                                            <i class="fas fa-eye"></i>
                                                        </button>

                                                        <button class="btn btn-sm btn-outline-primary" 
                                                                title="Xem thiết bị"
                                                                onclick="viewEquipmentList('${contract.contractId}')">
                                                            <i class="fas fa-tools"></i>
                                                        </button>

                                                        <c:if test="${not empty contract.documentUrl}">
                                                            <button class="btn btn-sm btn-outline-success" 
                                                                    title="Xem hợp đồng"
                                                                    onclick="viewContractDocument('${contract.documentUrl}')">
                                                                <i class="fas fa-file-pdf"></i>
                                                            </button>
                                                        </c:if>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:forEach>

                                        <c:if test="${empty contractList}">
                                            <tr>
                                                <td colspan="7" class="text-center py-4">
                                                    <i class="fas fa-folder-open fa-3x text-muted mb-3"></i>
                                                    <h5 class="text-muted">Không có hợp đồng nào</h5>
                                                    <p class="text-muted">Bạn chưa có hợp đồng nào trong hệ thống.</p>
                                                </td>
                                            </tr>
                                        </c:if>
                                    </tbody>
                                </table>
                            </div>
                        </div>

                        <!-- Pagination -->
                        <c:if test="${totalPages >= 1}">
                            <c:url var="baseUrl" value="viewcontracts">
                                <c:param name="keyword" value="${param.keyword}" />
                                <c:param name="status" value="${param.status}" />
                                <c:param name="fromDate" value="${param.fromDate}" />
                                <c:param name="toDate" value="${param.toDate}" />
                            </c:url>

                            <nav aria-label="Page navigation" class="mt-4">
                                <ul class="pagination justify-content-center">
                                    <li class="page-item ${currentPageNumber <= 1 ? 'disabled' : ''}">
                                        <a class="page-link" href="${baseUrl}&page=${currentPageNumber - 1}">
                                            <i class="fas fa-chevron-left"></i> Trước
                                        </a>
                                    </li>

                                    <c:forEach var="i" begin="1" end="${totalPages}">
                                        <li class="page-item ${i == currentPageNumber ? 'active' : ''}">
                                            <a class="page-link" href="${baseUrl}&page=${i}">${i}</a>
                                        </li>
                                    </c:forEach>

                                    <li class="page-item ${currentPageNumber >= totalPages ? 'disabled' : ''}">
                                        <a class="page-link" href="${baseUrl}&page=${currentPageNumber + 1}">
                                            Tiếp <i class="fas fa-chevron-right"></i>
                                        </a>
                                    </li>
                                </ul>
                            </nav>

                            <div class="text-center text-muted mb-3">
                                <small>
                                    Trang <strong>${currentPageNumber}</strong> / <strong>${totalPages}</strong> |
                                    Hiển thị <strong>${fn:length(contractList)}</strong> hợp đồng
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
                                <p class="footer-about">Giải pháp quản lý khách hàng toàn diện, giúp doanh nghiệp tối ưu hóa quy trình và nâng cao chất lượng dịch vụ.</p>
                                <p class="footer-version"><strong>Version:</strong> 1.0.0<br><strong>Phiên bản:</strong> Enterprise Edition</p>
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
                            <p class="footer-copyright">&copy; 2025 CRM System. All rights reserved. | Phát triển bởi <strong>Group 6</strong></p>
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


            <!-- Modal: View Contract Details -->
            <div class="modal fade" id="contractDetailsModal" tabindex="-1">
                <div class="modal-dialog modal-lg">
                    <div class="modal-content">
                        <div class="modal-header bg-dark text-white">
                            <h5 class="modal-title">
                                <i class="fas fa-file-contract me-2"></i> Chi Tiết Hợp Đồng
                            </h5>
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                        </div>

                        <div class="modal-body">
                            <h6 class="fw-bold mb-3"><i class="fas fa-info-circle"></i> Thông tin hợp đồng</h6>
                            <table class="table table-bordered">
                                <tr><th style="width:30%">Mã hợp đồng</th><td id="detail-contractId"></td></tr>
                                <tr><th>Loại hợp đồng</th><td id="detail-contractType"></td></tr>
                                <tr><th>Ngày ký</th><td id="detail-contractDate"></td></tr>
                                <tr><th>Trạng thái</th><td id="detail-status"></td></tr>
                                <tr><th>Chi tiết</th><td id="detail-details"></td></tr>
                            </table>

                            <h6 class="fw-bold mb-3 mt-4"><i class="fas fa-user"></i> Thông tin khách hàng</h6>
                            <table class="table table-bordered">
                                <tr><th style="width:30%">Họ tên</th><td id="detail-customerName"></td></tr>
                                <tr><th>Email</th><td id="detail-customerEmail"></td></tr>
                                <tr><th>Số điện thoại</th><td id="detail-customerPhone"></td></tr>
                            </table>

                            <h6 class="fw-bold mb-3 mt-4">
                                <i class="fas fa-file-medical"></i> Phụ lục hợp đồng 
                                (<span id="appendixCount">0</span>)
                            </h6>
                            <div id="appendixListContainer">
                                <p class="text-muted">Chưa có phụ lục nào</p>
                            </div>
                        </div>

                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Modal: View Equipment List -->
            <div class="modal fade" id="equipmentListModal" tabindex="-1">
                <div class="modal-dialog modal-xl">
                    <div class="modal-content">
                        <div class="modal-header bg-dark text-white">
                            <h5 class="modal-title">
                                <i class="fas fa-tools me-2"></i> Danh Sách Thiết Bị Trong Hợp Đồng
                            </h5>
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                        </div>

                        <div class="modal-body">
                            <div id="equipmentListContent">
                                <div class="text-center py-4">
                                    <div class="spinner-border" role="status">
                                        <span class="visually-hidden">Loading...</span>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Modal: View Service Requests -->
            <div class="modal fade" id="serviceRequestsModal" tabindex="-1">
                <div class="modal-dialog modal-xl">
                    <div class="modal-content">
                        <div class="modal-header bg-dark text-white">
                            <h5 class="modal-title">
                                <i class="fas fa-clipboard-list me-2"></i> Lịch Sử Service Request
                            </h5>
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                        </div>

                        <div class="modal-body">
                            <div id="serviceRequestsContent">
                                <div class="text-center py-4">
                                    <div class="spinner-border" role="status">
                                        <span class="visually-hidden">Loading...</span>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                        </div>
                    </div>
                </div>
            </div>

            <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
            <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
            <script>
                    document.addEventListener("DOMContentLoaded", () => {
                        const fromDate = document.querySelector("input[name='fromDate']");
                        const toDate = document.querySelector("input[name='toDate']");
                        const form = document.querySelector("form[action='viewcontracts']");

                        if (form && fromDate && toDate) {
                            form.addEventListener("submit", e => {
                                if (fromDate.value && toDate.value && fromDate.value > toDate.value) {
                                    e.preventDefault();
                                    Swal.fire({
                                        icon: "error",
                                        title: "Ngày không hợp lệ",
                                        text: "Ngày đến phải lớn hơn hoặc bằng ngày bắt đầu.",
                                        confirmButtonColor: "#000"
                                    });
                                }
                            });
                        }
                    });

                    function logout() {
                        Swal.fire({
                            title: 'Đăng xuất?',
                            text: 'Bạn có chắc chắn muốn đăng xuất?',
                            icon: 'question',
                            showCancelButton: true,
                            confirmButtonText: 'Đăng xuất',
                            cancelButtonText: 'Hủy',
                            confirmButtonColor: '#000'
                        }).then(result => {
                            if (result.isConfirmed) {
                                window.location.href = 'logout';
                            }
                        });
                    }

                    function viewContractDetails(contractId) {
                        const row = document.querySelector("tr[data-contractid='" + contractId + "']");
                        if (!row)
                            return;

                        const get = name => row.dataset[name] || "(Không có thông tin)";

                        document.getElementById("detail-contractId").innerText = "#" + contractId;
                        document.getElementById("detail-contractType").innerText = get("contracttype");
                        document.getElementById("detail-contractDate").innerText = get("contractdate");
                        document.getElementById("detail-status").innerText = get("status");
                        document.getElementById("detail-details").innerText = get("details");
                        document.getElementById("detail-customerName").innerText = get("customername");
                        document.getElementById("detail-customerEmail").innerText = get("customeremail");
                        document.getElementById("detail-customerPhone").innerText = get("customerphone");

                        new bootstrap.Modal(document.getElementById("contractDetailsModal")).show();
                    }

                    async function viewEquipmentList(contractId) {
                        const modal = new bootstrap.Modal(document.getElementById("equipmentListModal"));
                        modal.show();

                        const content = document.getElementById("equipmentListContent");

                        try {
                            const ctx = window.location.pathname.split("/")[1];
                            const response = await fetch("/" + ctx + "/getContractEquipment?contractId=" + contractId);

                            if (!response.ok)
                                throw new Error("Không thể tải danh sách thiết bị");

                            const data = await response.json();

                            if (data.equipment && data.equipment.length > 0) {
                                let html = '<div class="table-responsive">' +
                                        '<table class="table table-hover">' +
                                        '<thead class="table-light">' +
                                        '<tr>' +
                                        '<th>#</th>' +
                                        '<th>Model</th>' +
                                        '<th>Serial Number</th>' +
                                        '<th>Mô tả</th>' +
                                        '<th>Nguồn</th>' +
                                        '</tr>' +
                                        '</thead><tbody>';

                                data.equipment.forEach((eq, index) => {
                                    const source = eq.startDate ? 'Hợp đồng' : 'Phụ lục';
                                    const sourceBadge = eq.startDate ? 'bg-primary' : 'bg-warning';

                                    html += '<tr>' +
                                            '<td>' + (index + 1) + '</td>' +
                                            '<td><strong>' + eq.model + '</strong></td>' +
                                            '<td><code>' + eq.serialNumber + '</code></td>' +
                                            '<td>' + (eq.description || '-') + '</td>' +
                                            '<td><span class="badge ' + sourceBadge + '">' + source + '</span></td>' +
                                            '</tr>';
                                });

                                html += '</tbody></table></div>';
                                content.innerHTML = html;
                            } else {
                                content.innerHTML = '<div class="text-center py-4">' +
                                        '<i class="fas fa-box-open fa-3x text-muted mb-3"></i>' +
                                        '<h5 class="text-muted">Không có thiết bị nào</h5>' +
                                        '</div>';
                            }
                        } catch (error) {
                            console.error("Error:", error);
                            content.innerHTML = '<div class="alert alert-danger">Không thể tải danh sách thiết bị</div>';
                        }
                    }

                    async function viewServiceRequests(contractId) {
                        const modal = new bootstrap.Modal(document.getElementById("serviceRequestsModal"));
                        modal.show();

                        const content = document.getElementById("serviceRequestsContent");

                        try {
                            const ctx = window.location.pathname.split("/")[1];
                            const response = await fetch("/" + ctx + "/getContractRequests?contractId=" + contractId);

                            if (!response.ok)
                                throw new Error("Không thể tải lịch sử yêu cầu");

                            const data = await response.json();

                            if (data.requests && data.requests.length > 0) {
                                let html = '<div class="table-responsive">' +
                                        '<table class="table table-hover">' +
                                        '<thead class="table-light">' +
                                        '<tr>' +
                                        '<th>Mã Yêu Cầu</th>' +
                                        '<th>Thiết bị</th>' +
                                        '<th>Loại yêu cầu</th>' +
                                        '<th>Mức độ</th>' +
                                        '<th>Trạng thái</th>' +
                                        '<th>Ngày tạo</th>' +
                                        '<th>Mô tả</th>' +
                                        '</tr>' +
                                        '</thead><tbody>';

                                data.requests.forEach(req => {
                                    const priorityBadge = req.priorityLevel === 'Urgent' ? 'bg-danger' :
                                            req.priorityLevel === 'High' ? 'bg-warning' : 'bg-secondary';
                                    const statusBadge = req.status === 'Completed' ? 'bg-primary' :
                                            req.status === 'Approved' ? 'bg-success' :
                                            req.status === 'Pending' ? 'bg-warning' : 'bg-danger';

                                    html += '<tr>' +
                                            '<td><strong>#' + req.requestId + '</strong></td>' +
                                            '<td>' + (req.equipmentModel || '-') + '</td>' +
                                            '<td><span class="badge bg-info">' + req.requestType + '</span></td>' +
                                            '<td><span class="badge ' + priorityBadge + '">' + req.priorityLevel + '</span></td>' +
                                            '<td><span class="badge ' + statusBadge + '">' + req.status + '</span></td>' +
                                            '<td>' + req.requestDate + '</td>' +
                                            '<td>' + (req.description ? req.description.substring(0, 50) + '...' : '-') + '</td>' +
                                            '</tr>';
                                });

                                html += '</tbody></table></div>';
                                content.innerHTML = html;
                            } else {
                                content.innerHTML = '<div class="text-center py-4">' +
                                        '<i class="fas fa-clipboard fa-3x text-muted mb-3"></i>' +
                                        '<h5 class="text-muted">Chưa có yêu cầu nào</h5>' +
                                        '</div>';
                            }
                        } catch (error) {
                            console.error("Error:", error);
                            content.innerHTML = '<div class="alert alert-danger">Không thể tải lịch sử yêu cầu</div>';
                        }
                    }

                    function viewContractDocument(documentUrl) {
                        if (!documentUrl) {
                            Swal.fire({
                                icon: 'warning',
                                title: 'Không có tài liệu',
                                text: 'Hợp đồng này chưa có file scan.',
                                confirmButtonColor: '#000'
                            });
                            return;
                        }

                        window.open(documentUrl, '_blank');
                    }

                    function createServiceRequestFromContract(contractId, customerId) {
                        Swal.fire({
                            title: 'Tạo Service Request',
                            text: 'Bạn muốn tạo yêu cầu dịch vụ cho hợp đồng này?',
                            icon: 'question',
                            showCancelButton: true,
                            confirmButtonText: 'Tạo yêu cầu',
                            cancelButtonText: 'Hủy',
                            confirmButtonColor: '#000'
                        }).then(result => {
                            if (result.isConfirmed) {
                                window.location.href = 'viewCustomerRequest?action=create&contractId=' + contractId + '&customerId=' + customerId;
                            }
                        });
                    }

                    async function viewContractDetailsWithAppendix(contractId) {
                        viewContractDetails(contractId);

                        try {
                            const ctx = window.location.pathname.split("/")[1];
                            const response = await fetch("/" + ctx + "/getContractAppendix?contractId=" + contractId);

                            if (!response.ok)
                                throw new Error("Không thể tải phụ lục");

                            const data = await response.json();
                            const container = document.getElementById('appendixListContainer');
                            const countSpan = document.getElementById('appendixCount');

                            if (data.appendixes && data.appendixes.length > 0) {
                                countSpan.innerText = data.appendixes.length;

                                let html = '';
                                data.appendixes.forEach(function (app) {
                                    const statusBadge = app.status === 'Approved' ? 'bg-success' :
                                            app.status === 'Draft' ? 'bg-warning' : 'bg-secondary';
                                    const typeLabel = app.appendixType === 'AddEquipment' ? 'Thêm thiết bị' :
                                            app.appendixType === 'RepairPart' ? 'Thay linh kiện' :
                                            app.appendixType === 'ExtendTerm' ? 'Gia hạn' : 'Khác';

                                    html += '<div class="appendix-item">' +
                                            '<div class="d-flex justify-content-between align-items-start">' +
                                            '<div class="flex-grow-1">' +
                                            '<h6 class="mb-1">' +
                                            '<i class="fas fa-file-alt"></i> ' + app.appendixName +
                                            '<span class="badge ' + statusBadge + ' ms-2">' + app.status + '</span>' +
                                            '<span class="badge bg-info ms-1">' + typeLabel + '</span>' +
                                            '</h6>' +
                                            '<p class="mb-1 text-muted small">' + (app.description || 'Không có mô tả') + '</p>' +
                                            '<p class="mb-1">' +
                                            '<i class="fas fa-calendar"></i> Hiệu lực: <strong>' + app.effectiveDate + '</strong> | ' +
                                            '<i class="fas fa-tools"></i> Số thiết bị: <strong>' + (app.equipmentCount || 0) + '</strong>' +
                                            '</p>' +
                                            '</div>' +
                                            '<div class="btn-group">' +
                                            (app.fileAttachment ?
                                                    '<a href="' + app.fileAttachment + '" target="_blank" class="btn btn-sm btn-outline-success" title="Xem file đính kèm">' +
                                                    '<i class="fas fa-file-download"></i>' +
                                                    '</a>' : '') +
                                            '<button type="button" class="btn btn-sm btn-outline-info" ' +
                                            'onclick="viewAppendixEquipment(' + app.appendixId + ')" ' +
                                            'title="Xem thiết bị">' +
                                            '<i class="fas fa-list"></i>' +
                                            '</button>' +
                                            '</div>' +
                                            '</div>' +
                                            '</div>';
                                });

                                container.innerHTML = html;
                            } else {
                                countSpan.innerText = '0';
                                container.innerHTML = '<p class="text-muted">Chưa có phụ lục nào</p>';
                            }
                        } catch (error) {
                            console.error("Error:", error);
                            document.getElementById('appendixListContainer').innerHTML =
                                    '<div class="alert alert-warning">Không thể tải danh sách phụ lục</div>';
                        }
                    }

                    async function viewAppendixEquipment(appendixId) {
                        try {
                            const ctx = window.location.pathname.split("/")[1];
                            const response = await fetch("/" + ctx + "/getAppendixEquipment?appendixId=" + appendixId);

                            if (!response.ok)
                                throw new Error("Không thể tải thiết bị");

                            const data = await response.json();

                            let html = '<div class="mt-2"><h6>Danh sách thiết bị:</h6><ul class="list-group">';

                            if (data.equipment && data.equipment.length > 0) {
                                data.equipment.forEach(function (eq, index) {
                                    html += '<li class="list-group-item">' +
                                            '<strong>' + (index + 1) + '. ' + (eq.model || 'N/A') + '</strong> - ' + (eq.serialNumber || 'N/A') +
                                            (eq.description ? '<br><small class="text-muted">' + eq.description + '</small>' : '') +
                                            (eq.note ? '<br><small class="text-success">Ghi chú: ' + eq.note + '</small>' : '') +
                                            '</li>';
                                });
                            } else {
                                html += '<li class="list-group-item text-muted">Không có thiết bị nào</li>';
                            }

                            html += '</ul></div>';

                            Swal.fire({
                                title: 'Thiết bị trong phụ lục',
                                html: html,
                                width: 600,
                                confirmButtonColor: '#000'
                            });
                        } catch (error) {
                            console.error("Error:", error);
                            Swal.fire({
                                icon: 'error',
                                title: 'Lỗi',
                                text: 'Không thể tải danh sách thiết bị',
                                confirmButtonColor: '#000'
                            });
                        }
                    }








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

                    // Show/Hide Scroll to Top Button
                    window.addEventListener('scroll', function () {
                        const scrollBtn = document.getElementById('scrollToTop');
                        if (scrollBtn) {
                            if (window.pageYOffset > 300) {
                                scrollBtn.classList.add('show');
                            } else {
                                scrollBtn.classList.remove('show');
                            }
                        }
                    });

            </script>
    </body>
</html>