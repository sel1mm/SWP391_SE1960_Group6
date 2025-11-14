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
  /* CHATBOT RECOMMENDATIONS - Moved to bottom */
        .chatbot-recommendations {
            padding: 12px 15px;
            background: #f8f9fa;
            border-top: 1px solid #e0e0e0;
            max-height: 140px;
            overflow-y: auto;
            transition: all 0.3s ease;
        }

        .chatbot-recommendations.hidden {
            max-height: 0;
            padding: 0;
            border: none;
            overflow: hidden;
        }

        .recommendations-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 8px;
        }

        .recommendations-title {
            font-size: 0.75rem;
            color: #667eea;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 5px;
        }

        .recommendations-toggle {
            background: none;
            border: none;
            color: #667eea;
            cursor: pointer;
            font-size: 0.7rem;
            padding: 2px 8px;
            border-radius: 10px;
            transition: all 0.2s;
        }

        .recommendations-toggle:hover {
            background: rgba(102, 126, 234, 0.1);
        }

        .recommendation-chips {
            display: flex;
            flex-wrap: wrap;
            gap: 6px;
        }

        .recommendation-chip {
            background: white;
            border: 1px solid #e0e0e0;
            border-radius: 15px;
            padding: 5px 10px;
            font-size: 0.7rem;
            color: #333;
            cursor: pointer;
            transition: all 0.3s;
            white-space: nowrap;
            max-width: 100%;
            overflow: hidden;
            text-overflow: ellipsis;
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
        }

        .recommendation-chip:hover {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-color: #667eea;
            transform: translateY(-2px);
            box-shadow: 0 3px 8px rgba(102, 126, 234, 0.3);
        }

        .recommendation-category {
            width: 100%;
            font-size: 0.65rem;
            color: #888;
            margin-top: 6px;
            margin-bottom: 3px;
            font-weight: 500;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .chatbot-recommendations::-webkit-scrollbar {
            width: 4px;
        }

        .chatbot-recommendations::-webkit-scrollbar-thumb {
            background: #ddd;
            border-radius: 10px;
        }

        .chatbot-input {
            padding: 15px;
            background: white;
            border-top: 1px solid #eee;
            display: flex;
            gap: 10px;
        }

        .chatbot-input input {
            flex: 1;
            border: 1px solid #ddd;
            border-radius: 25px;
            padding: 12px 20px;
            font-size: 0.9rem;
            outline: none;
            transition: all 0.3s;
        }

        .chatbot-input input:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }

        .chatbot-send {
            width: 45px;
            height: 45px;
            border-radius: 50%;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border: none;
            color: white;
            cursor: pointer;
            transition: all 0.3s;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .chatbot-send:hover:not(:disabled) {
            transform: scale(1.1);
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
        }

        .chatbot-send:disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }

        @media (max-width: 768px) {
            .chatbot-window {
                width: calc(100vw - 30px);
                right: 15px;
            }
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
                                    <li><a href="tos.jsp">→ Điều khoản sử dụng</a></li>
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
                                <tr><th>Ngày ký</th><td id="detail-contractDate"></td></tr>
                                <tr><th>Trạng thái</th><td id="detail-status"></td></tr>
                                <tr><th>Chi tiết</th><td id="detail-details"></td></tr>
                                <tr>
                                    <th><i class="fas fa-file-download"></i> File đính kèm</th>
                                    <td id="detail-fileAttachment"></td>
                                </tr>
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

            <!-- Modal: View Contract Appendix (Read-only) -->
            <div class="modal fade" id="viewAppendixModal" tabindex="-1">
                <div class="modal-dialog modal-lg">
                    <div class="modal-content">
                        <div class="modal-header bg-info text-white">
                            <h5 class="modal-title">
                                <i class="fas fa-eye me-2"></i> Xem Chi Tiết Phụ Lục
                            </h5>
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                        </div>

                        <div class="modal-body">
                            <div class="alert alert-info">
                                <i class="fas fa-info-circle"></i> 
                                <strong>Chế độ chỉ xem:</strong> Phụ lục này có yêu cầu dịch vụ đang xử lý, không thể chỉnh sửa.
                            </div>

                            <div class="row">
                                <!-- Thông tin phụ lục -->
                                <div class="col-md-6">
                                    <h6 class="fw-bold mb-3">
                                        <i class="fas fa-clipboard"></i> Thông tin phụ lục
                                    </h6>

                                    <div class="mb-3">
                                        <label class="form-label fw-bold">Loại phụ lục</label>
                                        <input type="text" id="view-appendixType" class="form-control" readonly>
                                    </div>

                                    <div class="mb-3">
                                        <label class="form-label fw-bold">Tên phụ lục</label>
                                        <input type="text" id="view-appendixName" class="form-control" readonly>
                                    </div>

                                    <div class="mb-3">
                                        <label class="form-label fw-bold">Mô tả</label>
                                        <textarea id="view-description" class="form-control" rows="3" readonly></textarea>
                                    </div>

                                    <div class="mb-3">
                                        <label class="form-label fw-bold">Ngày hiệu lực</label>
                                        <input type="text" id="view-effectiveDate" class="form-control" readonly>
                                    </div>

                                    <div class="mb-3">
                                        <label class="form-label fw-bold">Trạng thái</label>
                                        <input type="text" id="view-status" class="form-control" readonly>
                                    </div>

                                    <div class="mb-3">
                                        <label class="form-label fw-bold">
                                            <i class="fas fa-file-download"></i> File đính kèm
                                        </label>
                                        <div id="view-fileDisplay"></div>
                                    </div>
                                </div>

                                <!-- Danh sách thiết bị (chỉ hiển thị) -->
                                <div class="col-md-6">
                                    <h6 class="fw-bold mb-3">
                                        <i class="fas fa-tools"></i> Danh sách thiết bị 
                                        (<span id="view-equipmentCount">0</span>)
                                    </h6>

                                    <div id="view-equipmentList" 
                                         class="border rounded p-3" 
                                         style="max-height: 400px; overflow-y: auto; background-color: #f8f9fa;">
                                        <p class="text-muted text-center mb-0">Chưa có thiết bị nào</p>
                                    </div>
                                </div>
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


            <!-- Modal: View Repair Part Appendix Details -->
            <div class="modal fade" id="repairPartAppendixModal" tabindex="-1">
                <div class="modal-dialog modal-xl">
                    <div class="modal-content">
                        <div class="modal-header bg-warning text-dark">
                            <h5 class="modal-title">
                                <i class="fas fa-tools me-2"></i> Chi Tiết Phụ Lục Linh Kiện
                            </h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                        </div>

                        <div class="modal-body">
                            <div class="alert alert-info">
                                <div class="row">
                                    <div class="col-md-6">
                                        <strong><i class="fas fa-file-alt"></i> Tên phụ lục:</strong>
                                        <span id="rp-appendixName"></span>
                                    </div>
                                    <div class="col-md-3">
                                        <strong><i class="fas fa-calendar"></i> Ngày hiệu lực:</strong>
                                        <span id="rp-effectiveDate"></span>
                                    </div>
                                    <div class="col-md-3">
                                        <strong><i class="fas fa-money-bill-wave"></i> Tổng tiền:</strong>
                                        <span id="rp-totalAmount" class="text-success fw-bold"></span>
                                    </div>
                                </div>
                                <div class="mt-2" id="rp-description"></div>
                            </div>

                            <h6 class="fw-bold mb-3">
                                <i class="fas fa-list"></i> Danh sách linh kiện 
                                (<span id="rp-partCount">0</span> linh kiện)
                            </h6>

                            <div id="rp-partsContainer">
                                <div class="text-center py-4">
                                    <i class="fas fa-spinner fa-spin"></i> Đang tải...
                                </div>
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
    </div>
            <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
            <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
           <script>
    // FAQ Data
    const FAQ_DATA = [
        {
            "category": "Giới thiệu chung",
            "questions": [
                {
                    "question": "Hệ thống của bạn cung cấp dịch vụ gì?",
                    "answer": "Hệ thống của chúng tôi cung cấp dịch vụ bảo hành và bảo trì thiết bị cho khách hàng. Khi quý khách mua thiết bị, chúng tôi sẽ tạo hợp đồng và lưu thông tin vào hệ thống. Khi thiết bị cần sửa chữa, quý khách chỉ cần tạo yêu cầu trực tuyến, chúng tôi sẽ xử lý và thực hiện sửa chữa theo quy trình chuyên nghiệp."
                },
                {
                    "question": "Làm thế nào để liên hệ bộ phận hỗ trợ khách hàng?",
                    "answer": "Quý khách có thể liên hệ với bộ phận hỗ trợ khách hàng qua:\n- Hotline: [Số điện thoại]\n- Email: [Địa chỉ email]\n- Chat trực tuyến trên website\n- Hoặc tạo yêu cầu hỗ trợ trực tiếp trên hệ thống"
                }
            ]
        },
        {
            "category": "Yêu cầu dịch vụ",
            "questions": [
                {
                    "question": "Làm thế nào để tạo yêu cầu bảo hành/bảo trì?",
                    "answer": "Để tạo yêu cầu, quý khách thực hiện theo các bước sau:\n\n1. Truy cập trang \"Yêu cầu dịch vụ\"\n2. Nhấn nút \"Tạo yêu cầu mới\" ở góc trên màn hình\n3. Chọn \"Hỗ trợ thiết bị\"\n4. Chọn thiết bị cần bảo hành từ danh sách (chỉ hiển thị thiết bị trong hợp đồng và chưa đang bảo hành)\n5. Chọn mức độ ưu tiên cho yêu cầu\n6. Mô tả chi tiết vấn đề của thiết bị\n7. Kiểm tra lại thông tin và nhấn \"Gửi yêu cầu\"\n\nSau khi gửi yêu cầu, chúng tôi sẽ xử lý và gửi báo giá. Khi quý khách thanh toán, chúng tôi sẽ tiến hành sửa chữa ngay."
                },
                {
                    "question": "Thời gian xử lý yêu cầu mất bao lâu?",
                    "answer": "Thời gian tạo yêu cầu trên hệ thống rất nhanh (chỉ vài phút). Tuy nhiên, thời gian xử lý yêu cầu phụ thuộc vào:\n\n- Mức độ ưu tiên của yêu cầu\n- Tình trạng và mức độ hỏng hóc của thiết bị\n- Khả năng sẵn có của phụ tùng thay thế\n\nThông thường:\n- Yêu cầu khẩn cấp: 24-48 giờ\n- Yêu cầu thường: 3-5 ngày làm việc\n- Yêu cầu không khẩn: 5-7 ngày làm việc"
                },
                {
                    "question": "Các trạng thái của yêu cầu dịch vụ có ý nghĩa gì?",
                    "answer": "Yêu cầu của quý khách sẽ đi qua các trạng thái sau:\n\n1. **Chờ xác nhận**: Yêu cầu vừa được tạo và đang chờ bộ phận hỗ trợ khách hàng xác nhận\n\n2. **Chờ xử lý**: Bộ phận hỗ trợ đã chuyển yêu cầu cho trưởng bộ phận kỹ thuật để phân công\n\n3. **Đang xử lý**: Trưởng bộ phận kỹ thuật đã giao việc cho kỹ thuật viên. Quý khách sẽ nhận được báo giá chi tiết. Quý khách có thể chấp nhận hoặc từ chối từng hạng mục trong báo giá\n\n4. **Đang sửa chữa**: Kỹ thuật viên đang thực hiện sửa chữa các hạng mục đã được thanh toán\n\n5. **Hoàn thành**: Thiết bị đã được sửa chữa xong và sẵn sàng giao lại cho quý khách\n\n6. **Đã hủy**: Yêu cầu đã bị hủy bởi quý khách hoặc hệ thống"
                },
                {
                    "question": "Tôi có thể hủy yêu cầu đã tạo không?",
                    "answer": "Có, quý khách có thể hủy yêu cầu khi:\n- Yêu cầu đang ở trạng thái \"Chờ xác nhận\" hoặc \"Chờ xử lý\"\n- Chưa thanh toán báo giá\n\nĐể hủy yêu cầu:\n1. Vào trang \"Yêu cầu dịch vụ\"\n2. Chọn yêu cầu cần hủy\n3. Nhấn nút \"Hủy yêu cầu\"\n4. Xác nhận hủy\n\nLưu ý: Sau khi đã thanh toán và kỹ thuật viên bắt đầu sửa chữa, quý khách không thể hủy yêu cầu."
                }
            ]
        },
        {
            "category": "Hợp đồng",
            "questions": [
                {
                    "question": "Làm thế nào để xem thông tin hợp đồng?",
                    "answer": "Để xem thông tin hợp đồng:\n\n1. Truy cập trang \"Hợp đồng\"\n2. Xem danh sách tất cả các hợp đồng của quý khách\n3. Nhấn vào nút \"Danh sách thiết bị\" để xem chi tiết các thiết bị trong từng hợp đồng\n\nTại đây, quý khách có thể xem:\n- Mã hợp đồng\n- Loại hợp đồng (mua bán, bảo hành, bảo trì)\n- Ngày bắt đầu và ngày kết thúc\n- Trạng thái hợp đồng\n- Danh sách thiết bị được bảo hành/bảo trì"
                },
                {
                    "question": "Làm thế nào để tạo hợp đồng mới?",
                    "answer": "Để tạo hợp đồng mới, quý khách vui lòng liên hệ trực tiếp với bộ phận hỗ trợ khách hàng qua:\n\n- Hotline: [Số điện thoại]\n- Email: [Địa chỉ email]\n- Đến trực tiếp văn phòng\n\nCác loại hợp đồng chúng tôi cung cấp:\n- Hợp đồng mua bán thiết bị\n- Hợp đồng bảo hành\n- Hợp đồng bảo trì định kỳ\n\nNhân viên hỗ trợ sẽ tư vấn và hướng dẫn quý khách hoàn tất thủ tục ký kết hợp đồng."
                },
                {
                    "question": "Chính sách bảo hành như thế nào?",
                    "answer": "Chính sách bảo hành của chúng tôi bao gồm:\n\n**Thời gian bảo hành:**\n- Theo thỏa thuận trong hợp đồng (thường từ 12-36 tháng)\n\n**Phạm vi bảo hành:**\n- Lỗi do nhà sản xuất\n- Hỏng hóc trong quá trình sử dụng bình thường\n- Bảo hành miễn phí phụ tùng và chi phí sửa chữa\n\n**Không bảo hành:**\n- Hư hỏng do sử dụng sai cách\n- Thiết bị bị va đập, rơi vỡ\n- Can thiệp sửa chữa bởi bên thứ ba\n- Thiết bị hết hạn bảo hành\n\nVui lòng tham khảo chi tiết trong hợp đồng của quý khách."
                }
            ]
        },
        {
            "category": "Hóa đơn & Thanh toán",
            "questions": [
                {
                    "question": "Làm thế nào để xem hóa đơn?",
                    "answer": "Để xem hóa đơn:\n\n1. Truy cập trang \"Hóa đơn\"\n2. Xem danh sách tất cả các hóa đơn\n\nThông tin hiển thị bao gồm:\n- Mã hóa đơn\n- Số tiền cần thanh toán\n- Ngày phát hành hóa đơn\n- Hạn thanh toán\n- Trạng thái (Chờ thanh toán, Đã thanh toán, Quá hạn)\n- Chi tiết các hạng mục trong hóa đơn"
                },
                {
                    "question": "Làm thế nào để thanh toán hóa đơn?",
                    "answer": "Quý khách có thể thanh toán hóa đơn qua các phương thức sau:\n\n**1. Thanh toán trực tuyến:**\n- Chuyển khoản ngân hàng\n- Ví điện tử (Momo, ZaloPay, VNPay)\n- Thẻ ATM/Thẻ tín dụng\n\n**2. Thanh toán trực tiếp:**\n- Tại văn phòng công ty\n- Thu tiền tận nơi (với một số trường hợp)\n\n**Cách thanh toán:**\n1. Vào trang \"Hóa đơn\"\n2. Chọn hóa đơn cần thanh toán\n3. Nhấn \"Thanh toán\"\n4. Chọn phương thức thanh toán\n5. Làm theo hướng dẫn\n\nSau khi thanh toán thành công, hệ thống sẽ cập nhật trạng thái hóa đơn và gửi biên lai qua email."
                },
                {
                    "question": "Điều gì xảy ra nếu tôi không thanh toán đúng hạn?",
                    "answer": "Nếu hóa đơn không được thanh toán đúng hạn:\n\n- Yêu cầu sửa chữa sẽ bị tạm dừng\n- Hóa đơn chuyển sang trạng thái \"Quá hạn\"\n- Có thể phát sinh phí phạt chậm thanh toán (theo hợp đồng)\n- Ảnh hưởng đến các yêu cầu dịch vụ tiếp theo\n\nVui lòng liên hệ bộ phận hỗ trợ nếu quý khách gặp khó khăn trong việc thanh toán để được tư vấn và hỗ trợ."
                }
            ]
        },
        {
            "category": "Thiết bị",
            "questions": [
                {
                    "question": "Làm thế nào để xem thông tin thiết bị?",
                    "answer": "Để xem thông tin thiết bị:\n\n1. Truy cập trang \"Thiết bị\"\n2. Xem danh sách tất cả thiết bị từ các hợp đồng của quý khách\n3. Nhấn vào \"Chi tiết\" để xem thông tin chi tiết\n\n**Thông tin hiển thị:**\n- Tên thiết bị\n- Mã thiết bị / Serial number\n- Hợp đồng liên quan\n- Trạng thái thiết bị (Đang hoạt động, Đang bảo hành, Đã hỏng)\n- Ngày mua / Ngày kích hoạt bảo hành\n- Thời hạn bảo hành còn lại\n\n**Nếu thiết bị đang được sửa chữa:**\n- Ngày bắt đầu sửa chữa\n- Kỹ thuật viên phụ trách\n- Dự kiến hoàn thành\n- Vấn đề đang được xử lý"
                },
                {
                    "question": "Tại sao một số thiết bị không hiển thị khi tạo yêu cầu?",
                    "answer": "Thiết bị sẽ không hiển thị trong danh sách tạo yêu cầu khi:\n\n- Thiết bị đang trong quá trình bảo hành/sửa chữa\n- Thiết bị không thuộc hợp đồng còn hiệu lực\n- Thiết bị đã hết hạn bảo hành và chưa gia hạn\n- Hợp đồng liên quan đã hết hạn hoặc bị hủy\n\nNếu quý khách cần sửa chữa thiết bị không có trong danh sách, vui lòng liên hệ bộ phận hỗ trợ để được tư vấn về việc gia hạn hợp đồng hoặc tạo hợp đồng mới."
                }
            ]
        },
        {
            "category": "Tài khoản & Bảo mật",
            "questions": [
                {
                    "question": "Làm thế nào để thay đổi thông tin cá nhân?",
                    "answer": "Để thay đổi thông tin cá nhân:\n\n1. Truy cập trang \"Hồ sơ\"\n2. Xem thông tin hiện tại của quý khách\n3. Nhấn nút \"Chỉnh sửa thông tin\"\n4. Cập nhật các thông tin cần thay đổi\n5. Nhấn \"Lưu thay đổi\"\n\n**Thông tin có thể chỉnh sửa:**\n- Họ và tên\n- Số điện thoại\n- Địa chỉ\n- Số CMND/CCCD\n- Ngày sinh\n\n**Lưu ý về email:**\n- Để thay đổi email, hệ thống sẽ gửi mã OTP đến email mới\n- Quý khách cần xác thực mã OTP để hoàn tất thay đổi\n- Việc này đảm bảo email mới thuộc quyền sở hữu của quý khách"
                },
                {
                    "question": "Làm thế nào để đổi mật khẩu?",
                    "answer": "Để đổi mật khẩu:\n\n1. Truy cập trang \"Hồ sơ\"\n2. Nhấn nút \"Đổi mật khẩu\"\n3. Nhập mật khẩu cũ\n4. Nhập mật khẩu mới (tối thiểu 8 ký tự, bao gồm chữ hoa, chữ thường, số)\n5. Xác nhận mật khẩu mới\n6. Nhấn \"Cập nhật\"\n\n**Lưu ý bảo mật:**\n- Không chia sẻ mật khẩu với người khác\n- Thay đổi mật khẩu định kỳ (3-6 tháng)\n- Sử dụng mật khẩu mạnh và khác biệt với các tài khoản khác\n- Nếu quên mật khẩu, sử dụng chức năng \"Quên mật khẩu\" ở trang đăng nhập"
                },
                {
                    "question": "Tôi quên mật khẩu, phải làm sao?",
                    "answer": "Nếu quên mật khẩu:\n\n1. Tại trang đăng nhập, nhấn \"Quên mật khẩu?\"\n2. Nhập email đã đăng ký\n3. Hệ thống sẽ gửi mã OTP đến email\n4. Nhập mã OTP để xác thực\n5. Tạo mật khẩu mới\n6. Đăng nhập lại với mật khẩu mới\n\nNếu không nhận được email:\n- Kiểm tra hộp thư spam/junk\n- Đợi 1-2 phút và thử lại\n- Liên hệ bộ phận hỗ trợ nếu vẫn không nhận được"
                }
            ]
        }
    ];

    // Initialize when page loads
    document.addEventListener('DOMContentLoaded', function() {
        showNewRecommendations();
    });

    function showNewRecommendations() {
        const container = document.getElementById('recommendationChips');
        if (!container) return;

        container.innerHTML = '';

        const allQuestions = FAQ_DATA.flatMap(category => 
            category.questions.map(q => ({
                question: q.question,
                category: category.category
            }))
        );

        const shuffled = [...allQuestions].sort(() => 0.5 - Math.random());
        const selectedQuestions = shuffled.slice(0, 6);

        const questionsByCategory = {};
        selectedQuestions.forEach(item => {
            if (!questionsByCategory[item.category]) {
                questionsByCategory[item.category] = [];
            }
            questionsByCategory[item.category].push(item.question);
        });

        Object.entries(questionsByCategory).forEach(([category, questions]) => {
            const categoryDiv = document.createElement('div');
            categoryDiv.className = 'recommendation-category';
            categoryDiv.textContent = category;
            container.appendChild(categoryDiv);

            questions.forEach(question => {
                const chip = document.createElement('div');
                chip.className = 'recommendation-chip';
                chip.textContent = question;
                chip.title = question;
                chip.onclick = () => sendRecommendedQuestion(question);
                container.appendChild(chip);
            });
        });
    }

    function sendRecommendedQuestion(question) {
        const input = document.getElementById('chatInput');
        input.value = question;
        sendMessage();
    }

    function toggleRecommendations() {
        showNewRecommendations();
    }

    function hideRecommendations() {
        const recommendations = document.getElementById('chatbotRecommendations');
        if (recommendations) {
            recommendations.classList.add('hidden');
        }
    }

    function showRecommendations() {
        const recommendations = document.getElementById('chatbotRecommendations');
        if (recommendations) {
            recommendations.classList.remove('hidden');
            showNewRecommendations();
        }
    }

    function toggleChatbot() {
        const chatWindow = document.getElementById('chatbotWindow');
        chatWindow.classList.toggle('active');
        
        if (chatWindow.classList.contains('active')) {
            showRecommendations();
            setTimeout(() => {
                document.getElementById('chatInput').focus();
            }, 300);
        }
    }

    function handleKeyPress(event) {
        if (event.key === 'Enter') {
            sendMessage();
        }
    }

    function addMessage(content, isUser = false) {
        const messagesDiv = document.getElementById('chatMessages');
        const messageDiv = document.createElement('div');
        messageDiv.className = `message ${isUser ? 'user' : 'bot'}`;
        
        const avatar = document.createElement('div');
        avatar.className = 'message-avatar';
        avatar.innerHTML = isUser ? '<i class="fas fa-user"></i>' : '<i class="fas fa-robot"></i>';
        
        const contentDiv = document.createElement('div');
        contentDiv.className = 'message-content';
        
        if (isUser) {
            contentDiv.textContent = content;
            messageDiv.appendChild(contentDiv);
            messageDiv.appendChild(avatar);
        } else {
            contentDiv.innerHTML = formatMessage(content);
            messageDiv.appendChild(avatar);
            messageDiv.appendChild(contentDiv);
        }
        
        messagesDiv.appendChild(messageDiv);
        messagesDiv.scrollTop = messagesDiv.scrollHeight;
    }

    function showTyping() {
        const messagesDiv = document.getElementById('chatMessages');
        const typingDiv = document.createElement('div');
        typingDiv.className = 'message bot';
        typingDiv.id = 'typingIndicator';
        
        const avatar = document.createElement('div');
        avatar.className = 'message-avatar';
        avatar.innerHTML = '<i class="fas fa-robot"></i>';
        
        const typing = document.createElement('div');
        typing.className = 'typing-indicator';
        typing.innerHTML = '<div class="typing-dot"></div><div class="typing-dot"></div><div class="typing-dot"></div>';
        
        typingDiv.appendChild(avatar);
        typingDiv.appendChild(typing);
        messagesDiv.appendChild(typingDiv);
        messagesDiv.scrollTop = messagesDiv.scrollHeight;
    }

    function hideTyping() {
        const typing = document.getElementById('typingIndicator');
        if (typing) {
            typing.remove();
        }
    }

    async function sendMessage() {
        const input = document.getElementById('chatInput');
        const sendBtn = document.getElementById('sendBtn');
        const question = input.value.trim();
        
        if (!question) return;
        
        hideRecommendations();
        
        addMessage(question, true);
        input.value = '';
        
        input.disabled = true;
        sendBtn.disabled = true;
        
        showTyping();
        
        try {
            const response = await fetch('${pageContext.request.contextPath}/askGemini', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ q: question })
            });
            
            const data = await response.json();
            hideTyping();
            
            if (data.success && data.answer) {
                addMessage(data.answer, false);
            } else {
                addMessage(data.error || 'Xin lỗi, có lỗi xảy ra. Vui lòng thử lại.', false);
            }
            
            setTimeout(() => {
                showRecommendations();
            }, 500);
            
        } catch (error) {
            hideTyping();
            addMessage('Xin lỗi, không thể kết nối đến server. Vui lòng thử lại sau.', false);
            console.error('Error:', error);
            
            setTimeout(() => {
                showRecommendations();
            }, 500);
        } finally {
            input.disabled = false;
            sendBtn.disabled = false;
            input.focus();
        }
    }

    function formatMessage(text) {
        if (!text) return '';
        
        let formatted = text.replace(/\n/g, '<br>');
        formatted = formatted.replace(/(\d+\.)\s/g, '<br>$1 ');
        formatted = formatted.replace(/^- /gm, '<br>• ');
        formatted = formatted.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>');
        formatted = formatted.replace(/([A-Z][^.!?]*:\s*)/g, '<strong>$1</strong>');
        
        return formatted;
    }
</script>
    </body>
</html>