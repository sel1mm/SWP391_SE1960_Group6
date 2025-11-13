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

            /* ✅ REPAIR INFO SECTION */
            .repair-info-section {
                background: #fff3cd;
                border: 1px solid #ffc107;
                border-radius: 8px;
                padding: 20px;
                margin-top: 20px;
            }

            .repair-info-section h6 {
                color: #856404;
                font-weight: 600;
                margin-bottom: 15px;
                display: flex;
                align-items: center;
                gap: 8px;
            }

            .info-item {
                display: flex;
                margin-bottom: 12px;
                padding: 8px;
                background: white;
                border-radius: 4px;
            }

            .info-item strong {
                min-width: 150px;
                color: #495057;
            }

            .info-item span {
                color: #212529;
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
            /* ========== CHATBOT STYLES ========== */
            .chatbot-container {
                position: fixed;
                bottom: 30px;
                right: 30px;
                z-index: 99999;
            }

            .chatbot-button {
                width: 60px;
                height: 60px;
                border-radius: 50%;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                border: none;
                box-shadow: 0 4px 20px rgba(102, 126, 234, 0.5);
                cursor: pointer;
                display: flex;
                align-items: center;
                justify-content: center;
                transition: all 0.3s;
                position: relative;
            }

            .chatbot-button:hover {
                transform: scale(1.1);
                box-shadow: 0 6px 25px rgba(102, 126, 234, 0.6);
            }

            .chatbot-button i {
                color: white;
                font-size: 24px;
            }

            .chatbot-badge {
                position: absolute;
                top: -5px;
                right: -5px;
                width: 20px;
                height: 20px;
                background: #ff4757;
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 10px;
                color: white;
                font-weight: bold;
                animation: pulse 2s infinite;
            }

            @keyframes pulse {
                0%, 100% {
                    transform: scale(1);
                }
                50% {
                    transform: scale(1.1);
                }
            }


            .chatbot-window {
                position: fixed;
                bottom: 100px;
                right: 30px;
                width: 420px;
                height: 650px;
                background: white;
                border-radius: 20px;
                box-shadow: 0 10px 40px rgba(0,0,0,0.2);
                display: none;
                flex-direction: column;
                overflow: hidden;
                animation: slideUp 0.3s ease-out;
            }

            @keyframes slideUp {
                from {
                    opacity: 0;
                    transform: translateY(20px);
                }
                to {
                    opacity: 1;
                    transform: translateY(0);
                }
            }

            .chatbot-window.active {
                display: flex;
            }

            .chatbot-header {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                padding: 20px;
                display: flex;
                justify-content: space-between;
                align-items: center;
            }

            .chatbot-header h4 {
                margin: 0;
                font-size: 1.1rem;
                display: flex;
                align-items: center;
                gap: 10px;
            }

            .chatbot-close {
                background: rgba(255,255,255,0.2);
                border: none;
                width: 30px;
                height: 30px;
                border-radius: 50%;
                cursor: pointer;
                color: white;
                transition: all 0.3s;
            }

            .chatbot-close:hover {
                background: rgba(255,255,255,0.3);
            }

            /* ========== CHATBOT RECOMMENDATIONS ========== */
            .chatbot-recommendations {
                padding: 15px 20px;
                background: white;
                border-bottom: 1px solid #eee;
                max-height: 150px;
                overflow-y: auto;
            }

            .recommendations-title {
                font-size: 0.8rem;
                color: #667eea;
                font-weight: 600;
                margin-bottom: 10px;
                display: flex;
                align-items: center;
                gap: 5px;
            }

            .recommendation-chips {
                display: flex;
                flex-wrap: wrap;
                gap: 8px;
            }

            .recommendation-chip {
                background: #f8f9fa;
                border: 1px solid #e0e0e0;
                border-radius: 20px;
                padding: 6px 12px;
                font-size: 0.75rem;
                color: #333;
                cursor: pointer;
                transition: all 0.3s;
                white-space: nowrap;
                max-width: 100%;
                overflow: hidden;
                text-overflow: ellipsis;
            }

            .recommendation-chip:hover {
                background: #667eea;
                color: white;
                border-color: #667eea;
                transform: translateY(-2px);
            }

            .recommendation-category {
                width: 100%;
                font-size: 0.7rem;
                color: #888;
                margin-top: 5px;
                margin-bottom: 3px;
                font-weight: 500;
            }

            /* Scrollbar for recommendations */
            .chatbot-recommendations::-webkit-scrollbar {
                width: 4px;
            }

            .chatbot-recommendations::-webkit-scrollbar-thumb {
                background: #ddd;
                border-radius: 10px;
            }

            .chatbot-messages {
                flex: 1;
                padding: 20px;
                overflow-y: auto;
                background: #f8f9fa;
            }

            .chatbot-messages::-webkit-scrollbar {
                width: 6px;
            }

            .chatbot-messages::-webkit-scrollbar-thumb {
                background: #ddd;
                border-radius: 10px;
            }

            .message {
                margin-bottom: 15px;
                display: flex;
                gap: 10px;
                animation: fadeIn 0.3s;
            }

            @keyframes fadeIn {
                from {
                    opacity: 0;
                    transform: translateY(10px);
                }
                to {
                    opacity: 1;
                    transform: translateY(0);
                }
            }

            .message.bot {
                justify-content: flex-start;
            }

            .message.user {
                justify-content: flex-end;
            }

            .message-avatar {
                width: 35px;
                height: 35px;
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 18px;
                flex-shrink: 0;
            }

            .message.bot .message-avatar {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
            }

            .message.user .message-avatar {
                background: #ffc107;
                color: white;
            }

            .message-content {
                max-width: 70%;
                padding: 12px 16px;
                border-radius: 18px;
                line-height: 1.5;
                font-size: 0.9rem;
            }

            .message.bot .message-content {
                background: white;
                color: #333;
                border-bottom-left-radius: 4px;
                white-space: pre-line;
                word-wrap: break-word;
                overflow-wrap: break-word;
            }

            .message.user .message-content {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                border-bottom-right-radius: 4px;
            }

            .message.bot .message-content strong {
                color: #1e3c72;
                font-weight: 600;
            }

            .typing-indicator {
                display: flex;
                gap: 4px;
                padding: 12px 16px;
                background: white;
                border-radius: 18px;
                width: fit-content;
            }

            .typing-dot {
                width: 8px;
                height: 8px;
                background: #667eea;
                border-radius: 50%;
                animation: typing 1.4s infinite;
            }

            .typing-dot:nth-child(2) {
                animation-delay: 0.2s;
            }
            .typing-dot:nth-child(3) {
                animation-delay: 0.4s;
            }

            @keyframes typing {
                0%, 60%, 100% {
                    transform: translateY(0);
                }
                30% {
                    transform: translateY(-10px);
                }
            }

            .chatbot-input {
                padding: 20px;
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
            #maintenanceHistoryModal .table {
                font-size: 0.9rem;
            }

            #maintenanceHistoryModal .table td {
                vertical-align: middle;
            }

            #maintenanceHistoryModal .badge {
                font-size: 0.8rem;
                padding: 0.35em 0.65em;
            }

            #historyTableBody tr:hover {
                background-color: #f8f9fa;
            }
            /* ✅ FORCE TEXT COLOR CHO MAINTENANCE HISTORY TABLE */
            #maintenanceHistoryModal table,
            #maintenanceHistoryModal table * {
                color: #000 !important;
            }

            #maintenanceHistoryModal tbody tr {
                background-color: #ffffff !important;
            }

            #maintenanceHistoryModal tbody td {
                background-color: #ffffff !important;
                color: #000000 !important;
                padding: 12px 8px !important;
            }

            #maintenanceHistoryModal tbody td strong,
            #maintenanceHistoryModal tbody td span:not(.badge) {
                color: #000000 !important;
            }

            /* ✅ CHỈ BADGE MỚI CÓ MÀU RIÊNG */
            #maintenanceHistoryModal .badge {
                color: inherit !important;
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
                    <a href="${pageContext.request.contextPath}/viewcontracts" class="menu-item">
                        <i class="fas fa-file-contract"></i>
                        <span>Hợp Đồng</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/equipment" class="menu-item active">
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
                <%
                    String errorMsg = (String) session.getAttribute("error");
                    String successMsg = (String) session.getAttribute("success");
                %>

                <% if (errorMsg != null || successMsg != null) { %>
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
                    });
                </script>
                <% } %>

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
                    <form action="${pageContext.request.contextPath}/equipment" method="get">
                        <input type="hidden" name="action" value="search"/>

                        <!-- Hàng 1: Search + Dropdowns -->
                        <div class="row g-3 mb-2">
                            <div class="col-md-3">
                                <label class="form-label fw-bold">Tìm kiếm</label>
                                <input type="text" class="form-control" name="keyword"
                                       placeholder="Tên thiết bị, serial number, mã hợp đồng..."
                                       value="${param.keyword}">
                            </div>

                            <div class="col-md-2">
                                <label class="form-label fw-bold">Trạng thái</label>
                                <select name="status" class="form-select">
                                    <option value="">Tất cả</option>
                                    <option value="Active" ${param.status == 'Active' ? 'selected' : ''}>Đang Hoạt Động</option>
                                    <option value="Repair" ${param.status == 'Repair' ? 'selected' : ''}>Đang Sửa Chữa</option>
                                </select>
                            </div>

                            <div class="col-md-3">
                                <label class="form-label fw-bold">Loại</label>
                                <select name="sourceType" class="form-select">
                                    <option value="">Tất cả</option>
                                    <option value="Hợp Đồng" ${param.sourceType == 'Hợp Đồng' ? 'selected' : ''}>Hợp Đồng</option>
                                    <option value="Phụ Lục" ${param.sourceType == 'Phụ Lục' ? 'selected' : ''}>Phụ Lục</option>
                                </select>
                            </div>

                            <div class="col-md-4">
                                <label class="form-label fw-bold">Sắp xếp</label>
                                <select name="sortBy" class="form-select">
                                    <option value="newest" ${param.sortBy == 'newest' ? 'selected' : ''}>Mới nhất</option>
                                    <option value="oldest" ${param.sortBy == 'oldest' ? 'selected' : ''}>Cũ nhất</option>
                                    <option value="name_asc" ${param.sortBy == 'name_asc' ? 'selected' : ''}>Tên A-Z</option>
                                    <option value="name_desc" ${param.sortBy == 'name_desc' ? 'selected' : ''}>Tên Z-A</option>
                                </select>
                            </div>
                        </div>

                        <!-- Hàng 2: Date range -->
                        <div class="row g-3 mb-2 align-items-end">
                            <div class="col-md-3">
                                <label class="form-label fw-bold">Từ ngày lắp đặt</label>
                                <input type="date" class="form-control" name="fromDate" value="${param.fromDate}">
                            </div>

                            <div class="col-md-3">
                                <label class="form-label fw-bold">Đến ngày lắp đặt</label>
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
                                <a href="${pageContext.request.contextPath}/equipment" class="btn btn-outline-dark">
                                    <i class="fas fa-sync-alt me-1"></i> Làm mới
                                </a>
                            </div>
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
                                            <th>Loại</th>
                                            <th>Mã Hợp Đồng</th>
                                            <th>Ngày Bắt Đầu</th>
                                            <th>Ngày Kết Thúc</th>
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
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${item.sourceType == 'Hợp Đồng'}">
                                                            <span class="badge bg-success">
                                                                <i class="fas fa-file-contract"></i> Hợp Đồng
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${item.sourceType == 'Phụ Lục'}">
                                                            <span class="badge bg-info">
                                                                <i class="fas fa-file-plus"></i> Phụ Lục
                                                            </span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge bg-secondary">
                                                                <i class="fas fa-question"></i> Không xác định
                                                            </span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td><span class="badge bg-primary">${item.contractId}</span></td>

                                                <!-- ✅ NGÀY BẮT ĐẦU -->
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${not empty item.startDate}">
                                                            <i class="fas fa-calendar-plus text-success me-1"></i>
                                                            ${item.startDate}
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="text-muted">
                                                                <i class="fas fa-minus"></i> Chưa có
                                                            </span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>

                                                <!-- ✅ NGÀY KẾT THÚC -->
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${not empty item.endDate}">
                                                            <i class="fas fa-calendar-times text-danger me-1"></i>
                                                            ${item.endDate}
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="text-muted">
                                                                <i class="fas fa-minus"></i> Chưa có
                                                            </span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>

                                                <!-- ✅ TRẠNG THÁI DỰA TRÊN NGÀY -->
                                                <td>
                                                    <c:choose>
                                                        <%-- Logic: Nếu có endDate và ngày hiện tại < endDate thì Active, ngược lại Expired --%>
                                                        <c:when test="${not empty item.endDate}">
                                                            <jsp:useBean id="now" class="java.util.Date"/>
                                                            <fmt:parseDate value="${item.endDate}" pattern="yyyy-MM-dd" var="parsedEndDate"/>

                                                            <c:choose>
                                                                <c:when test="${now.time < parsedEndDate.time}">
                                                                    <span class="badge bg-success">
                                                                        <i class="fas fa-check-circle"></i> Đang Hoạt Động
                                                                    </span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="badge bg-danger">
                                                                        <i class="fas fa-times-circle"></i> Hết Hạn
                                                                    </span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <%-- Nếu không có endDate, sử dụng status từ servlet --%>
                                                            <c:choose>
                                                                <c:when test="${item.status == 'Active'}">
                                                                    <span class="badge bg-success">
                                                                        <i class="fas fa-check-circle"></i> Đang Hoạt Động
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
                                                                    <span class="badge bg-warning text-dark">
                                                                        <i class="fas fa-question-circle"></i> Pending
                                                                    </span>
                                                                </c:otherwise>
                                                            </c:choose>
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
                                                            data-technician-name="${item.technicianName}"
                                                            data-repair-date="${item.repairDate}"
                                                            data-diagnosis="${item.diagnosis}"
                                                            data-repair-details="${item.repairDetails}"
                                                            data-estimated-cost="${item.estimatedCost}"
                                                            data-quotation-status="${item.quotationStatus}"
                                                            data-start-date="${item.startDate}"
                                                            data-end-date="${item.endDate}"
                                                            onclick="viewEquipmentDetail(this)">
                                                        <i class="fas fa-eye"></i> Chi Tiết
                                                    </button>

                                                    <button class="btn btn-sm btn-primary btn-action"
                                                            data-id="${item.equipment.equipmentId}"
                                                            data-model="${item.equipment.model}"
                                                            onclick="viewMaintenanceHistory(this)">
                                                        <i class="fas fa-history"></i> Lịch Sử Bảo Trì
                                                    </button>

                                                    <c:if test="${item.status == 'Active'}">
                                                        <button class="btn btn-sm btn-warning btn-action"
                                                                data-id="${item.equipment.equipmentId}"
                                                                data-contract="${item.contractId}"
                                                                data-serial="${item.equipment.serialNumber}"
                                                                data-model="${item.equipment.model}"
                                                                onclick="createRequest(this)">
                                                            <i class="fas fa-plus-circle"></i> Tạo Đơn
                                                        </button>
                                                    </c:if>

                                                    <c:if test="${item.status != 'Active'}">
                                                        <button disabled 
                                                                title="Thiết bị đang ${item.status == 'Repair' ? 'sửa chữa' : 'bảo trì'}">
                                                        </button>
                                                    </c:if>                                               
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

                    <!-- PHÂN TRANG - GIỮ NGUYÊN -->
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
                                | Hiển thị <strong>${fn:length(equipmentList)}</strong> thiết bị
                            </small>
                        </div>
                    </c:if>
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

            <!-- ✅ MODAL VIEW EQUIPMENT - CẬP NHẬT HIỂN THỊ THÔNG TIN SỬA CHỮA -->
            <div class="modal fade" id="viewModal" tabindex="-1">
                <div class="modal-dialog modal-xl">
                    <div class="modal-content">
                        <div class="modal-header bg-info text-white">
                            <h5 class="modal-title">
                                <i class="fas fa-info-circle"></i> Chi Tiết Thiết Bị
                            </h5>
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                        </div>
                        <div class="modal-body">
                            <!-- THÔNG TIN CƠ BẢN -->
                            <div class="card mb-3">
                                <div class="card-header bg-light">
                                    <h6 class="mb-0"><i class="fas fa-tools"></i> Thông Tin Thiết Bị</h6>
                                </div>
                                <div class="card-body">
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
                            </div>

                            <!-- ✅ THÔNG TIN SỬA CHỮA (CHỈ HIỂN THỊ KHI STATUS = REPAIR) -->
                            <div id="repairInfoSection" style="display: none;">
                                <div class="card border-warning">
                                    <div class="card-header bg-warning text-dark">
                                        <h6 class="mb-0">
                                            <i class="fas fa-wrench"></i> Thông Tin Sửa Chữa
                                        </h6>
                                    </div>
                                    <div class="card-body">
                                        <div class="row mb-3">
                                            <div class="col-md-6">
                                                <strong><i class="fas fa-user-cog"></i> Kỹ Thuật Viên:</strong>
                                                <p class="text-primary fw-bold" id="viewTechnicianName">Đang tải...</p>
                                            </div>
                                            <div class="col-md-6">
                                                <strong><i class="fas fa-calendar-check"></i> Ngày Bắt Đầu Sửa:</strong>
                                                <p id="viewRepairDate">N/A</p>
                                            </div>
                                        </div>                                  
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

            <!-- MODAL CREATE SERVICE REQUEST for Equipment -->
            <div class="modal fade" id="createRequestModal" tabindex="-1">
                <div class="modal-dialog modal-lg">
                    <div class="modal-content">
                        <div class="modal-header bg-warning text-dark">
                            <h5 class="modal-title">
                                <i class="fas fa-plus-circle"></i> Tạo Đơn Hỗ Trợ Thiết Bị
                            </h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                        </div>
                        <form action="${pageContext.request.contextPath}/managerServiceRequest" method="post" id="createRequestForm" onsubmit="return validateEquipmentRequestForm(event)">
                            <input type="hidden" name="action" value="CreateServiceRequest">
                            <input type="hidden" name="supportType" value="equipment">
                            <input type="hidden" name="equipmentIds" id="requestEquipmentId">
                            <input type="hidden" name="contractId" id="requestContractIdValue">

                            <div class="modal-body">
                                <!-- ✅ THÊM MỚI: Loại Yêu Cầu (Request Type) -->
                                <div class="mb-3">
                                    <label class="form-label">
                                        <i class="fas fa-tags"></i> Loại Yêu Cầu 
                                        <span class="text-danger">*</span>
                                    </label>
                                    <select class="form-select" name="requestType" id="equipmentRequestType" required>
                                        <option value="Service">🔧 Service (Dịch vụ sửa chữa)</option>
                                        <option value="Warranty">🛡️ Warranty (Bảo hành)</option>
                                    </select>
                                    <small class="form-text text-muted">
                                        <i class="fas fa-info-circle"></i> Service: Dịch vụ sửa chữa thông thường | Warranty: Sửa chữa theo bảo hành hợp đồng
                                    </small>
                                </div>

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
                                        <select class="form-select" name="priorityLevel" id="equipmentPriorityLevel" required>
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
                                    <textarea class="form-control" name="description" id="equipmentRequestDescription" rows="5" 
                                              placeholder="Mô tả chi tiết vấn đề bạn đang gặp phải với thiết bị..."
                                              minlength="10" maxlength="1000" required
                                              oninput="updateEquipmentCharCount()"></textarea>
                                    <div class="d-flex justify-content-between align-items-center mt-1">
                                        <small class="form-text text-muted">
                                            <i class="fas fa-info-circle"></i> Tối thiểu 10 ký tự, tối đa 1000 ký tự
                                        </small>
                                        <span id="equipmentCharCount" class="text-muted" style="font-size: 0.875rem;">0/1000</span>
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



            <!-- ✅ MODAL LỊCH SỬ BẢO TRÌ - ĐÃ SỬA -->
            <div class="modal fade" id="maintenanceHistoryModal" tabindex="-1">
                <div class="modal-dialog modal-xl">
                    <div class="modal-content">
                        <div class="modal-header bg-primary text-white">
                            <h5 class="modal-title">
                                <i class="fas fa-history"></i> Lịch Sử Bảo Trì - <span id="historyEquipmentName"></span>
                            </h5>
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                        </div>

                        <!-- ✅ THÊM STYLE CHO MODAL BODY -->
                        <div class="modal-body" style="min-height: 400px; max-height: 70vh; overflow-y: auto; padding: 20px;">

                            <!-- Loading spinner -->
                            <div id="historyLoading" class="text-center py-5" style="display: none;">
                                <div class="spinner-border text-primary" role="status" style="width: 3rem; height: 3rem;">
                                    <span class="visually-hidden">Loading...</span>
                                </div>
                                <p class="mt-3 text-muted fw-bold">Đang tải lịch sử bảo trì...</p>
                            </div>

                            <!-- Empty state -->
                            <div id="historyEmpty" class="text-center py-5" style="display: none;">
                                <i class="fas fa-inbox fa-3x text-muted mb-3"></i>
                                <h5 class="text-muted">Chưa có lịch sử bảo trì</h5>
                                <p class="text-muted">Thiết bị này chưa được bảo trì lần nào</p>
                            </div>

                            <!-- History table -->
                            <div id="historyContent" style="display: none;">
                                <div class="table-responsive">
                                    <table class="table table-hover table-bordered mb-0">
                                        <thead class="table-light" style="position: sticky; top: 0; z-index: 10; background-color: #f8f9fa;">
                                            <tr>
                                                <th width="5%" class="text-center">STT</th>
                                                <th width="15%">Kỹ Thuật Viên</th>
                                                <th width="15%">Ngày Giờ Bảo Trì</th>
                                                <th width="12%">Loại Bảo Trì</th>                                           
                                                <th width="12%">Loại Task</th>
                                                <th width="10%">Trạng Thái</th>
                                                <!-- <th width="19%">Chi Tiết</th> -->
                                            </tr>
                                        </thead>
                                        <tbody id="historyTableBody" style="background-color: #ffffff;">
                                            <!-- Data will be inserted here by JavaScript -->
                                        </tbody>
                                    </table>
                                </div>

                                <!-- Pagination for history -->
                                <nav aria-label="History pagination" id="historyPagination" class="mt-3" style="display: none;">
                                    <ul class="pagination justify-content-center mb-0" id="historyPaginationList">
                                        <!-- Pagination will be inserted here by JavaScript -->
                                    </ul>
                                </nav>
                            </div>
                        </div>

                        <div class="modal-footer bg-light">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                                <i class="fas fa-times"></i> Đóng
                            </button>
                        </div>
                    </div>
                </div>
            </div>



            <div class="chatbot-container">
                <button class="chatbot-button" onclick="toggleChatbotWidget()">
                    <i class="fas fa-comment-dots"></i>
                    <span class="chatbot-badge">AI</span>
                </button>

                <div class="chatbot-window" id="chatbotWindowWidget">
                    <div class="chatbot-header">
                        <h4>
                            <i class="fas fa-robot"></i>
                            Trợ lý AI
                        </h4>
                        <button class="chatbot-close" onclick="toggleChatbotWidget()">
                            <i class="fas fa-times"></i>
                        </button>
                    </div>

                    <!-- PHẦN RECOMMENDATIONS -->
                    <div class="chatbot-recommendations" id="chatbotRecommendationsWidget">
                        <div class="recommendations-title">
                            <i class="fas fa-lightbulb"></i>
                            Câu hỏi thường gặp
                        </div>
                        <div class="recommendation-chips" id="recommendationChipsWidget">
                            <!-- Recommendations sẽ được thêm bằng JavaScript -->
                        </div>
                    </div>

                    <div class="chatbot-messages" id="chatMessagesWidget">
                        <div class="message bot">
                            <div class="message-avatar">
                                <i class="fas fa-robot"></i>
                            </div>
                            <div class="message-content">
                                Xin chào! Tôi là trợ lý AI của hệ thống. Tôi có thể giúp bạn trả lời các câu hỏi về dịch vụ, hợp đồng, thiết bị và hóa đơn. Bạn cần hỗ trợ gì?
                            </div>
                        </div>
                    </div>

                    <div class="chatbot-input">
                        <input type="text" id="chatInputWidget" placeholder="Nhập câu hỏi của bạn..." onkeypress="handleKeyPressWidget(event)">
                        <button class="chatbot-send" id="sendBtnWidget" onclick="sendMessageWidget()">
                            <i class="fas fa-paper-plane"></i>
                        </button>
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

                            // ========== ✅ VIEW EQUIPMENT DETAIL - SỬ DỤNG DATA TỪ SERVLET ==========
                            function viewEquipmentDetail(button) {
                                const equipmentId = button.getAttribute('data-id');
                                const model = button.getAttribute('data-model');
                                const serial = button.getAttribute('data-serial');
                                const contract = button.getAttribute('data-contract');
                                const description = button.getAttribute('data-description');
                                const installDate = button.getAttribute('data-install-date');
                                const lastUpdate = button.getAttribute('data-last-update');
                                const status = button.getAttribute('data-status');

                                // ✅ LẤY THÔNG TIN SỬA CHỮA TỪ DATA ATTRIBUTES
                                const technicianName = button.getAttribute('data-technician-name');
                                const repairDate = button.getAttribute('data-repair-date');
                                const diagnosis = button.getAttribute('data-diagnosis');
                                const repairDetails = button.getAttribute('data-repair-details');
                                const estimatedCost = button.getAttribute('data-estimated-cost');
                                const quotationStatus = button.getAttribute('data-quotation-status');

                                // Điền thông tin cơ bản
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

                                // ✅ NẾU THIẾT BỊ ĐANG SỬA CHỮA → HIỂN THỊ THÔNG TIN SỬA CHỮA
                                const repairSection = document.getElementById('repairInfoSection');
                                if (status === 'Repair') {
                                    repairSection.style.display = 'block';

                                    // Hiển thị thông tin sửa chữa từ data attributes
                                    document.getElementById('viewTechnicianName').innerHTML =
                                            '<i class="fas fa-user-check"></i> ' + (technicianName && technicianName !== 'null' ? technicianName : 'Chưa phân công');
                                    document.getElementById('viewRepairDate').textContent =
                                            (repairDate && repairDate !== 'null' ? repairDate : 'N/A');
                                } else {
                                    repairSection.style.display = 'none';
                                }

                                new bootstrap.Modal(document.getElementById('viewModal')).show();
                            }

                            // ========== CREATE REQUEST ==========
                            function createRequest(button) {
                                const equipmentId = button.getAttribute('data-id');
                                const contractId = button.getAttribute('data-contract');
                                const serialNumber = button.getAttribute('data-serial');
                                const equipmentName = button.getAttribute('data-model');

                                // Xử lý contractId - cho phép cả thiết bị có và không có hợp đồng
                                let cleanContractId = '';
                                if (contractId && contractId !== 'N/A') {
                                    cleanContractId = contractId.replace('HD', '').replace('#', '');
                                }

                                document.getElementById('requestEquipmentId').value = equipmentId;
                                document.getElementById('requestContractIdValue').value = cleanContractId;
                                document.getElementById('requestEquipmentName').value = equipmentName;
                                document.getElementById('requestContractId').value = contractId || 'N/A';
                                document.getElementById('requestSerialNumber').value = serialNumber;

                                new bootstrap.Modal(document.getElementById('createRequestModal')).show();
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

                            function refreshPage() {
                                window.location.href = '${pageContext.request.contextPath}/equipment';
                            }

                            function scrollToTop() {
                                window.scrollTo({
                                    top: 0,
                                    behavior: 'smooth'
                                });
                            }

                            // ========== PAGINATION ==========
                            function goToPage(pageNumber) {
                                const form = document.querySelector('form[action*="/equipment"]');
                                if (form) {
                                    // Tạo hidden input cho page number
                                    let pageInput = form.querySelector('input[name="page"]');
                                    if (!pageInput) {
                                        pageInput = document.createElement('input');
                                        pageInput.type = 'hidden';
                                        pageInput.name = 'page';
                                        form.appendChild(pageInput);
                                    }
                                    pageInput.value = pageNumber;

                                    // Submit form
                                    form.submit();
                                }
                            }
                            // ========== CHARACTER COUNT FOR EQUIPMENT REQUEST ==========
                            function updateEquipmentCharCount() {
                                const textarea = document.getElementById('equipmentRequestDescription');
                                const charCount = document.getElementById('equipmentCharCount');
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

                            // ========== VALIDATE EQUIPMENT REQUEST FORM ==========
                            function validateEquipmentRequestForm(event) {
                                const description = document.getElementById('equipmentRequestDescription').value.trim();
                                const priorityLevel = document.getElementById('equipmentPriorityLevel').value;
                                const requestType = document.getElementById('equipmentRequestType').value;

                                if (!requestType) {
                                    event.preventDefault();
                                    showToast('Vui lòng chọn loại yêu cầu!', 'error');
                                    return false;
                                }

                                if (!priorityLevel) {
                                    event.preventDefault();
                                    showToast('Vui lòng chọn mức độ ưu tiên!', 'error');
                                    return false;
                                }

                                if (description.length < 10) {
                                    event.preventDefault();
                                    showToast('Mô tả phải có ít nhất 10 ký tự!', 'error');
                                    document.getElementById('equipmentRequestDescription').focus();
                                    return false;
                                }

                                if (description.length > 1000) {
                                    event.preventDefault();
                                    showToast('Mô tả không được vượt quá 1000 ký tự!', 'error');
                                    document.getElementById('equipmentRequestDescription').focus();
                                    return false;
                                }

                                return true;
                            }

                            // ========== CẬP NHẬT HÀM createRequest ==========
                            function createRequest(button) {
                                const equipmentId = button.getAttribute('data-id');
                                const contractId = button.getAttribute('data-contract');
                                const serialNumber = button.getAttribute('data-serial');
                                const equipmentName = button.getAttribute('data-model');

                                // Xử lý contractId - cho phép cả thiết bị có và không có hợp đồng
                                let cleanContractId = '';
                                if (contractId && contractId !== 'N/A') {
                                    cleanContractId = contractId.replace('HD', '').replace('#', '');
                                }

                                document.getElementById('requestEquipmentId').value = equipmentId;
                                document.getElementById('requestContractIdValue').value = cleanContractId;
                                document.getElementById('requestEquipmentName').value = equipmentName;
                                document.getElementById('requestContractId').value = contractId || 'N/A';
                                document.getElementById('requestSerialNumber').value = serialNumber;

                                // Reset form về giá trị mặc định
                                document.getElementById('equipmentRequestType').value = 'Service';
                                document.getElementById('equipmentPriorityLevel').value = '';
                                document.getElementById('equipmentRequestDescription').value = '';
                                updateEquipmentCharCount();

                                new bootstrap.Modal(document.getElementById('createRequestModal')).show();
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

                            // ========== EVENT LISTENERS ==========
                            document.addEventListener('DOMContentLoaded', function () {
                                // ✅ Event cho textarea trong equipment request modal
                                const equipmentDescriptionTextarea = document.getElementById('equipmentRequestDescription');
                                if (equipmentDescriptionTextarea) {
                                    equipmentDescriptionTextarea.addEventListener('input', updateEquipmentCharCount);
                                }

                                // ✅ Reset form khi đóng modal tạo đơn thiết bị
                                const createRequestModal = document.getElementById('createRequestModal');
                                if (createRequestModal) {
                                    createRequestModal.addEventListener('hidden.bs.modal', function () {
                                        document.getElementById('createRequestForm').reset();
                                        updateEquipmentCharCount();
                                    });

                                    createRequestModal.addEventListener('shown.bs.modal', function () {
                                        updateEquipmentCharCount();
                                    });
                                }

                                // ✅ Add date range validation to search form
                                const searchForm = document.querySelector('form[action*="/equipment"]');
                                if (searchForm) {
                                    searchForm.addEventListener('submit', function (e) {
                                        if (!validateDateRange()) {
                                            e.preventDefault();
                                        }
                                    });
                                }
                            });


                            window.addEventListener('scroll', function () {
                                const scrollBtn = document.getElementById('scrollToTop');
                                if (window.pageYOffset > 300) {
                                    scrollBtn.classList.add('show');
                                } else {
                                    scrollBtn.classList.remove('show');
                                }
                            });

                            window.addEventListener('scroll', function () {
                                const scrollBtn = document.getElementById('scrollToTop');
                                if (window.pageYOffset > 300) {
                                    scrollBtn.classList.add('show');
                                } else {
                                    scrollBtn.classList.remove('show');
                                }
                            });





                            let maintenanceHistoryData = [];
                            const HISTORY_PAGE_SIZE = 10;
                            let currentHistoryPage = 1;

                            function viewMaintenanceHistory(button) {
                                const equipmentId = button.getAttribute('data-id');
                                const equipmentName = button.getAttribute('data-model');

                                console.log('========================================');
                                console.log('🔍 [JS] viewMaintenanceHistory CALLED');
                                console.log('🔍 [JS] Equipment ID:', equipmentId, 'Name:', equipmentName);

                                // ✅ SET EQUIPMENT NAME
                                document.getElementById('historyEquipmentName').textContent = equipmentName;

                                // ✅ RESET STATES TRƯỚC KHI MỞ MODAL
                                document.getElementById('historyLoading').style.display = 'block';
                                document.getElementById('historyEmpty').style.display = 'none';
                                document.getElementById('historyContent').style.display = 'none';

                                // ✅ MỞ MODAL (CHỈ MỘT LẦN)
                                const modalElement = document.getElementById('maintenanceHistoryModal');
                                const modal = new bootstrap.Modal(modalElement);
                                modal.show();

                                console.log('✅ [JS] Modal opened');

                                // ✅ ĐỢI MODAL MỞ XONG RỒI MỚI FETCH DATA
                                setTimeout(() => {
                                    const url = '${pageContext.request.contextPath}/equipment?action=getMaintenanceHistory&equipmentId=' + equipmentId;
                                    console.log('📡 [JS] Fetching from:', url);

                                    fetch(url)
                                            .then(response => {
                                                console.log('📡 [JS] Response status:', response.status);
                                                if (!response.ok) {
                                                    throw new Error('HTTP ' + response.status);
                                                }
                                                return response.text();
                                            })
                                            .then(text => {
                                                console.log('========================================');
                                                console.log('📦 [JS] RAW RESPONSE:');
                                                console.log(text);
                                                console.log('========================================');

                                                // Parse JSON
                                                const data = JSON.parse(text);
                                                console.log('📦 [JS] PARSED DATA:', data);

                                                // ✅ ẨN LOADING
                                                document.getElementById('historyLoading').style.display = 'none';

                                                if (data.success && data.data && data.data.length > 0) {
                                                    console.log('✅ [JS] Found', data.data.length, 'maintenance records');

                                                    // ✅ IN RA TỪNG RECORD
                                                    data.data.forEach((record, index) => {
                                                        console.log('----------------------------');
                                                        console.log('📝 Record ' + (index + 1) + ':');
                                                        console.log('  scheduleId:', record.scheduleId);
                                                        console.log('  technicianName:', record.technicianName, typeof record.technicianName);
                                                        console.log('  scheduledDate:', record.scheduledDate);
                                                        console.log('  maintenanceDateTime:', record.maintenanceDateTime);
                                                        console.log('  scheduleType:', record.scheduleType);
                                                        console.log('  priorityLevel:', record.priorityLevel);
                                                        console.log('  status:', record.status);
                                                        console.log('  taskDetails:', record.taskDetails);
                                                        console.log('  Full object:', record);
                                                        console.log('----------------------------');
                                                    });

                                                    maintenanceHistoryData = data.data;
                                                    currentHistoryPage = 1;

                                                    // ✅ GỌI displayMaintenanceHistory() VỚI TIMEOUT ĐỂ ĐẢM BẢO MODAL ĐÃ RENDER XONG
                                                    setTimeout(() => {
                                                        displayMaintenanceHistory();
                                                    }, 100);

                                                } else {
                                                    console.log('⚠️ [JS] No maintenance history found');
                                                    document.getElementById('historyEmpty').style.display = 'block';
                                                }
                                            })
                                            .catch(error => {
                                                console.error('❌ [JS] Error:', error);
                                                document.getElementById('historyLoading').style.display = 'none';
                                                document.getElementById('historyEmpty').style.display = 'block';
                                            });
                                }, 300); // ✅ ĐỢI 300MS CHO MODAL MỞ XONG

                                console.log('========================================');
                            }

                            function displayMaintenanceHistory() {
                                console.log('🎬 [JS] displayMaintenanceHistory() STARTED');

                                const tbody = document.getElementById('historyTableBody');
                                tbody.innerHTML = '';

                                const totalPages = Math.ceil(maintenanceHistoryData.length / HISTORY_PAGE_SIZE);
                                const startIndex = (currentHistoryPage - 1) * HISTORY_PAGE_SIZE;
                                const endIndex = Math.min(startIndex + HISTORY_PAGE_SIZE, maintenanceHistoryData.length);
                                const pageData = maintenanceHistoryData.slice(startIndex, endIndex);

                                console.log('📊 Total records:', maintenanceHistoryData.length);
                                console.log('📊 Current page:', currentHistoryPage, 'of', totalPages);

                                pageData.forEach((history, index) => {
                                    const row = document.createElement('tr');

                                    // 1. STT
                                    const sttCell = document.createElement('td');
                                    sttCell.className = 'text-center';
                                    sttCell.textContent = startIndex + index + 1;
                                    row.appendChild(sttCell);

                                    // 2. KỸ THUẬT VIÊN
                                    const techCell = document.createElement('td');
                                    const techIcon = document.createElement('i');
                                    techIcon.className = 'fas fa-user-cog text-primary';
                                    const techText = document.createElement('strong');
                                    techText.textContent = history.technicianName || 'Chưa phân công';
                                    techText.style.marginLeft = '8px';
                                    techCell.appendChild(techIcon);
                                    techCell.appendChild(techText);
                                    row.appendChild(techCell);

                                    // 3. NGÀY GIỜ BẢO TRÌ
                                    const dateCell = document.createElement('td');
                                    const dateIcon = document.createElement('i');
                                    dateIcon.className = 'fas fa-calendar-alt text-info';
                                    dateIcon.style.marginRight = '8px';

                                    let formattedDateTime = 'N/A';
                                    let scheduledDateStr = history.scheduledDate || history.maintenanceDateTime;
                                    if (scheduledDateStr) {
                                        try {
                                            const date = new Date(scheduledDateStr.replace(' ', 'T'));
                                            if (!isNaN(date.getTime())) {
                                                formattedDateTime = date.toLocaleDateString('vi-VN') + ' ' +
                                                        date.toLocaleTimeString('vi-VN', {hour: '2-digit', minute: '2-digit'});
                                            }
                                        } catch (e) {
                                            console.error('Date parse error:', e);
                                        }
                                    }

                                    const dateText = document.createTextNode(formattedDateTime);
                                    dateCell.appendChild(dateIcon);
                                    dateCell.appendChild(dateText);
                                    row.appendChild(dateCell);

                                    // 4. LOẠI BẢO TRÌ
                                    const typeCell = document.createElement('td');
                                    const maintenanceType = history.scheduleType || history.maintenanceType || 'N/A';
                                    const typeBadge = document.createElement('span');
                                    typeBadge.className = 'badge';

                                    if (maintenanceType === 'Corrective') {
                                        typeBadge.className += ' bg-warning text-dark';
                                        typeBadge.innerHTML = '<i class="fas fa-wrench me-1"></i>Sửa Chữa';
                                    } else if (maintenanceType === 'Preventive' || maintenanceType === 'Periodic') {
                                        typeBadge.className += ' bg-info';
                                        typeBadge.innerHTML = '<i class="fas fa-calendar-check me-1"></i>Định Kỳ';
                                    } else if (maintenanceType === 'Emergency') {
                                        typeBadge.className += ' bg-danger';
                                        typeBadge.innerHTML = '<i class="fas fa-exclamation-triangle me-1"></i>Khẩn Cấp';
                                    } else {
                                        typeBadge.className += ' bg-secondary';
                                        typeBadge.textContent = 'N/A';
                                    }

                                    typeCell.appendChild(typeBadge);
                                    row.appendChild(typeCell);

                                    // 6. LOẠI TASK
                                    const taskTypeCell = document.createElement('td');
                                    const taskType = history.taskType || 'Scheduled';
                                    const taskBadge = document.createElement('span');
                                    taskBadge.className = 'badge';

                                    if (taskType === 'Request') {
                                        taskBadge.className += ' bg-primary';
                                        taskBadge.innerHTML = '<i class="fas fa-tasks me-1"></i>Request';
                                    } else {
                                        taskBadge.className += ' bg-success';
                                        taskBadge.innerHTML = '<i class="fas fa-clock me-1"></i>Scheduled';
                                    }

                                    taskTypeCell.appendChild(taskBadge);
                                    row.appendChild(taskTypeCell);

                                    // 7. TRẠNG THÁI
                                    const statusCell = document.createElement('td');
                                    const status = history.scheduleStatus || history.status || 'Scheduled';
                                    const statusBadge = document.createElement('span');
                                    statusBadge.className = 'badge';

                                    if (status === 'Completed') {
                                        statusBadge.className += ' bg-success';
                                        statusBadge.innerHTML = '<i class="fas fa-check-circle me-1"></i>Hoàn Thành';
                                    } else if (status === 'In Progress') {
                                        statusBadge.className += ' bg-warning text-dark';
                                        statusBadge.innerHTML = '<i class="fas fa-spinner me-1"></i>Đang Thực Hiện';
                                    } else if (status === 'Assigned') {
                                        statusBadge.className += ' bg-info';
                                        statusBadge.innerHTML = '<i class="fas fa-user-check me-1"></i>Đã Phân Công';
                                    } else if (status === 'Scheduled') {
                                        statusBadge.className += ' bg-primary';
                                        statusBadge.innerHTML = '<i class="fas fa-calendar me-1"></i>Đã Lên Lịch';
                                    } else {
                                        statusBadge.className += ' bg-secondary';
                                        statusBadge.innerHTML = '<i class="fas fa-clock me-1"></i>Chờ Xử Lý';
                                    }

                                    statusCell.appendChild(statusBadge);
                                    row.appendChild(statusCell);

                                    // 8. CHI TIẾT
                                    //                                const detailsCell = document.createElement('td');
                                    //                                detailsCell.style.maxWidth = '200px';
                                    //                                detailsCell.style.wordWrap = 'break-word';
                                    //
                                    //                                const details = history.taskDetails || history.recurrenceRule || '';
                                    //                                if (details && details !== 'null' && details !== 'false' && details.trim() !== '') {
                                    //                                    detailsCell.textContent = details;
                                    //                                } else {
                                    //                                    const emptyText = document.createElement('span');
                                    //                                    emptyText.className = 'text-muted';
                                    //                                    emptyText.textContent = 'Không có mô tả';
                                    //                                    detailsCell.appendChild(emptyText);
                                    //                                }
                                    //
                                    //                                row.appendChild(detailsCell);
                                    tbody.appendChild(row);
                                });

                                // HIỂN THỊ TABLE
                                document.getElementById('historyLoading').style.display = 'none';
                                document.getElementById('historyEmpty').style.display = 'none';
                                document.getElementById('historyContent').style.display = 'block';

                                // PAGINATION
                                if (totalPages > 1) {
                                    displayHistoryPagination(totalPages);
                                } else {
                                    document.getElementById('historyPagination').style.display = 'none';
                                }

                                console.log('✅ [JS] displayMaintenanceHistory() COMPLETED. Rows:', tbody.children.length);
                            }
                            function displayHistoryPagination(totalPages) {
                                const paginationList = document.getElementById('historyPaginationList');
                                paginationList.innerHTML = '';

                                // Previous button
                                const prevLi = document.createElement('li');
                                prevLi.className = 'page-item' + (currentHistoryPage <= 1 ? ' disabled' : '');
                                prevLi.innerHTML = `
                        <a class="page-link" href="javascript:void(0)" onclick="${currentHistoryPage > 1 ? 'goToHistoryPage(' + (currentHistoryPage - 1) + ')' : ''}">
                            <i class="fas fa-chevron-left"></i> Trước
                        </a>
                    `;
                                paginationList.appendChild(prevLi);

                                // Page numbers
                                for (let i = 1; i <= totalPages; i++) {
                                    const li = document.createElement('li');
                                    li.className = 'page-item' + (i === currentHistoryPage ? ' active' : '');
                                    li.innerHTML = `
                            <a class="page-link" href="javascript:void(0)" onclick="goToHistoryPage(${i})">
                ${i}
                            </a>
                        `;
                                    paginationList.appendChild(li);
                                }

                                // Next button
                                const nextLi = document.createElement('li');
                                nextLi.className = 'page-item' + (currentHistoryPage >= totalPages ? ' disabled' : '');
                                nextLi.innerHTML = `
                        <a class="page-link" href="javascript:void(0)" onclick="${currentHistoryPage < totalPages ? 'goToHistoryPage(' + (currentHistoryPage + 1) + ')' : ''}">
                            Tiếp <i class="fas fa-chevron-right"></i>
                        </a>
                    `;
                                paginationList.appendChild(nextLi);

                                document.getElementById('historyPagination').style.display = 'block';
                            }

                            function goToHistoryPage(pageNumber) {
                                currentHistoryPage = pageNumber;
                                displayMaintenanceHistory();
                            }
            </script>


    </body>
</html>
