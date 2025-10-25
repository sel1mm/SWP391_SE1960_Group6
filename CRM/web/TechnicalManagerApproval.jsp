<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Duyệt Yêu Cầu Dịch Vụ - Quản Lý Kỹ Thuật</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #f8f9fa;
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            margin: 0;
            padding: 0;
        }

        /* Sidebar Styles */
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
                box-shadow: 4px 0 10px rgba(0,0,0,0.1);
                display: flex;
                flex-direction: column;
            }


        .sidebar-header {
            padding: 25px 20px;
            border-bottom: 1px solid rgba(255,255,255,0.1);
        }

        .sidebar-header h4 {
            color: white;
            margin: 0;
            font-weight: 600;
            font-size: 1.4rem;
        }

        .sidebar-header .subtitle {
            color: rgba(255,255,255,0.8);
            font-size: 0.9rem;
            margin-top: 5px;
        }

        .sidebar-nav {
            padding: 20px 0;
        }

        .nav-item {
            margin-bottom: 5px;
        }

        .nav-link {
            color: rgba(255,255,255,0.8) !important;
            padding: 15px 25px;
            border-radius: 0;
            transition: all 0.3s ease;
            border-left: 3px solid transparent;
            display: flex;
            align-items: center;
            text-decoration: none;
        }

        .nav-link:hover {
            background-color: rgba(255,255,255,0.1);
            color: white !important;
            border-left-color: #ffc107;
            transform: translateX(5px);
        }

        .nav-link.active {
            background-color: rgba(255,255,255,0.15);
            color: white !important;
            border-left-color: #ffc107;
            font-weight: 600;
        }

        .nav-link i {
            margin-right: 12px;
            width: 20px;
            text-align: center;
            font-size: 1.1rem;
        }

        /* Main Content */
        .main-content {
            margin-left: 280px;
            min-height: 100vh;
            background-color: #f8f9fa;
        }

        .content-wrapper {
            padding: 30px;
        }

        /* Mobile Responsive */
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
            
            .mobile-toggle {
                display: block !important;
            }
        }

        .mobile-toggle {
            display: none;
            position: fixed;
            top: 20px;
            left: 20px;
            z-index: 1001;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            padding: 10px 15px;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        }

        .stats-card {
            border-radius: 15px;
            padding: 25px;
            margin-bottom: 25px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            transition: all 0.3s ease;
        }

        .stats-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 25px rgba(0,0,0,0.15);
        }

        .stats-card i {
            font-size: 3rem;
            opacity: 0.8;
            margin-bottom: 10px;
        }

        .table-container {
            background: white;
            border-radius: 15px;
            padding: 30px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }

        .search-filter-bar {
            background: white;
            padding: 25px;
            border-radius: 15px;
            margin-bottom: 25px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }

        .btn-action {
            padding: 8px 16px;
            margin: 0 3px;
            border-radius: 8px;
            font-weight: 500;
            transition: all 0.3s;
        }

        .btn-action:hover {
            transform: translateY(-2px);
        }

        .badge-pending {
            background: #ffc107;
            color: #000;
            font-size: 12px;
            padding: 6px 12px;
            border-radius: 20px;
        }

        .badge-urgent {
            background: #dc3545;
            color: white;
            font-size: 12px;
            padding: 6px 12px;
            border-radius: 20px;
            animation: pulse 2s infinite;
        }

        .badge-high {
            background: #fd7e14;
            color: white;
            font-size: 12px;
            padding: 6px 12px;
            border-radius: 20px;
        }

        .badge-normal {
            background: #20c997;
            color: white;
            font-size: 12px;
            padding: 6px 12px;
            border-radius: 20px;
        }

        @keyframes pulse {
            0% { box-shadow: 0 0 0 0 rgba(220, 53, 69, 0.7); }
            70% { box-shadow: 0 0 0 10px rgba(220, 53, 69, 0); }
            100% { box-shadow: 0 0 0 0 rgba(220, 53, 69, 0); }
        }

        /* Priority indicators */
        .priority-indicator {
            display: inline-block;
            width: 8px;
            height: 8px;
            border-radius: 50%;
            margin-right: 8px;
        }

        .priority-urgent {
            background-color: #dc3545;
            animation: pulse 2s infinite;
        }

        .priority-high {
            background-color: #fd7e14;
        }

        .priority-normal {
            background-color: #20c997;
        }

        /* Toast notifications */
        #toastContainer {
            position: fixed;
            top: 20px;
            right: -400px;
            z-index: 9999;
            width: 380px;
            transition: right 0.5s ease-in-out;
        }

        #toastContainer.show {
            right: 20px;
        }

        .toast-notification {
            background: white;
            border-radius: 12px;
            padding: 20px;
            box-shadow: 0 8px 25px rgba(0,0,0,0.15);
            display: flex;
            align-items: center;
            gap: 15px;
            margin-bottom: 10px;
            border-left: 4px solid;
        }

        .toast-notification.success {
            border-left-color: #198754;
        }

        .toast-notification.error {
            border-left-color: #dc3545;
        }

        .toast-notification.warning {
            border-left-color: #ffc107;
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

        .toast-icon.warning {
            color: #ffc107;
        }

        .toast-content {
            flex: 1;
        }

        .toast-close {
            background: none;
            border: none;
            font-size: 20px;
            cursor: pointer;
            color: #6c757d;
            padding: 0;
            width: 20px;
            height: 20px;
        }

        .toast-close:hover {
            color: #000;
        }

        /* Modal enhancements */
        .modal-header {
            background: white;
            color: #667eea;
            border-radius: 15px 15px 0 0;
            border-bottom: 2px solid #667eea;
        }

        .modal-content {
            border-radius: 15px;
            border: none;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
        }

        .modal-footer {
            border-radius: 0 0 15px 15px;
        }

        /* Form enhancements */
        .form-control:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 0.2rem rgba(102, 126, 234, 0.25);
        }

        .form-label {
            font-weight: 600;
            color: #2d3748;
            margin-bottom: 8px;
        }

        /* Request details card */
        .request-details-card {
            background: #f8f9fc;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
            border-left: 4px solid #667eea;
        }

        .request-details-card h6 {
            color: #667eea;
            margin-bottom: 15px;
            font-weight: 600;
        }

        .detail-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 10px;
            padding: 8px 0;
            border-bottom: 1px solid #e9ecef;
        }

        .detail-row:last-child {
            border-bottom: none;
            margin-bottom: 0;
        }

        .detail-label {
            font-weight: 600;
            color: #4a5568;
        }

        .detail-value {
            color: #2d3748;
            text-align: right;
        }

        /* Responsive design */
        @media (max-width: 768px) {
            .stats-card {
                text-align: center;
                margin-bottom: 15px;
            }

            .btn-action {
                padding: 6px 12px;
                font-size: 14px;
            }

            .search-filter-bar {
                padding: 20px;
            }

            .table-container {
                padding: 20px;
            }
        }

        /* Loading animation */
        .loading {
            display: inline-block;
            width: 20px;
            height: 20px;
            border: 3px solid #f3f3f3;
            border-top: 3px solid #667eea;
            border-radius: 50%;
            animation: spin 1s linear infinite;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        /* Modern Card Enhancements */
        .card {
            border: none;
            border-radius: 16px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.08);
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            overflow: hidden;
            backdrop-filter: blur(10px);
            background: rgba(255,255,255,0.95);
        }

        .card:hover {
            transform: translateY(-4px);
            box-shadow: 0 12px 40px rgba(0,0,0,0.15);
        }

        .card-header {
            background: white;
            color: #667eea;
            border: none;
            border-bottom: 2px solid #667eea;
            padding: 24px 30px;
            font-weight: 600;
            position: relative;
            overflow: hidden;
        }

        .card-header::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(102, 126, 234, 0.05);
            pointer-events: none;
        }

        /* Modern Table Styling */
        .table {
            margin-bottom: 0;
            border-radius: 12px;
            overflow: hidden;
        }

        .table th {
            background: white;
            border-top: none;
            border-bottom: 2px solid #667eea;
            font-weight: 700;
            color: #667eea;
            padding: 20px 16px;
            font-size: 0.9rem;
            text-transform: uppercase;
            letter-spacing: 1px;
            position: relative;
            text-shadow: 0 1px 2px rgba(0,0,0,0.1);
            border-bottom: 3px solid rgba(255,255,255,0.2);
        }

        .table th::after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 0;
            right: 0;
            height: 2px;
            background: rgba(102, 126, 234, 0.2);
        }

        .table td {
            padding: 18px 16px;
            vertical-align: middle;
            border-color: #e9ecef;
            font-size: 0.9rem;
        }

        .table tbody tr {
            transition: all 0.3s ease;
        }

        .table tbody tr:hover {
            background: rgba(102, 126, 234, 0.08);
            box-shadow: 0 2px 8px rgba(102, 126, 234, 0.15);
        }

        /* Modern Button Styling */
        .btn {
            border-radius: 12px;
            font-weight: 600;
            padding: 12px 24px;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            border: none;
            position: relative;
            overflow: hidden;
        }

        .btn::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: rgba(255,255,255,0.2);
            transition: left 0.5s;
        }

        .btn:hover::before {
            left: 100%;
        }

        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(102, 126, 234, 0.6);
        }

        .btn-success {
            background: #28a745;
            box-shadow: 0 4px 15px rgba(40, 167, 69, 0.4);
        }

        .btn-success:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(40, 167, 69, 0.6);
        }

        .btn-danger {
            background: #dc3545;
            box-shadow: 0 4px 15px rgba(220, 53, 69, 0.4);
        }

        .btn-danger:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(220, 53, 69, 0.6);
        }

        /* Fix Bootstrap nav-tabs styling conflicts */
        .nav-tabs {
            border-bottom: 1px solid #dee2e6;
            margin-bottom: 20px;
        }

        .nav-tabs .nav-link {
            color: #495057 !important;
            background-color: transparent !important;
            border: 1px solid transparent;
            border-top-left-radius: 0.375rem;
            border-top-right-radius: 0.375rem;
            padding: 12px 20px;
            margin-bottom: -1px;
            transition: all 0.3s ease;
        }

        .nav-tabs .nav-link:hover {
            color: #667eea !important;
            background-color: #f8f9fa !important;
            border-color: #e9ecef #e9ecef #dee2e6;
            transform: none;
            border-left: 1px solid #e9ecef !important;
        }

        .nav-tabs .nav-link.active,
        .nav-tabs .nav-item.show .nav-link {
            color: #667eea !important;
            background-color: #fff !important;
            border-color: #dee2e6 #dee2e6 #fff;
            font-weight: 600;
            transform: none;
            border-left: 1px solid #dee2e6 !important;
        }

        .nav-tabs .nav-link i {
            margin-right: 8px;
            width: auto;
        }

        .nav-tabs .badge {
            font-size: 0.75rem;
        }
    </style>
</head>
<body>
    <!-- Toast Container -->
    <div id="toastContainer"></div>

    <!-- Mobile Toggle Button -->
    <button class="mobile-toggle" onclick="toggleSidebar()">
        <i class="fas fa-bars"></i>
    </button>

    <!-- Sidebar -->
    <div class="sidebar" id="sidebar">
        <div class="sidebar-header">
            <h4><i class="fas fa-tools me-2"></i>CRM System</h4>
            <div class="subtitle">Technical Manager</div>
        </div>
        <ul class="nav flex-column">
            <li class="nav-item">
                <a class="nav-link" href="dashboard.jsp">
                    <i class="fas fa-tachometer-alt me-2"></i>Dashboard
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link active" href="technicalManagerApproval">
                    <i class="fas fa-clipboard-check me-2"></i>Duyệt Yêu Cầu
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="assignWork">
                    <i class="fas fa-user-plus me-2"></i>Phân Công Công Việc
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="scheduleMaintenance">
                    <i class="fas fa-calendar-alt me-2"></i>Lập Lịch Bảo Trì
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="reviewMaintenanceReport">
                    <i class="fas fa-file-alt me-2"></i>Xem Báo Cáo Bảo Trì
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="manageProfile.jsp">
                    <i class="fas fa-cog me-2"></i>Cài Đặt
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="logout">
                    <i class="fas fa-sign-out-alt me-2"></i>Đăng Xuất
                </a>
            </li>
        </ul>
    </div>

    <!-- Main Content -->
    <div class="main-content">
        <div class="content-wrapper">
            <!-- Header -->
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h2><i class="fas fa-clipboard-check text-primary"></i> Duyệt Yêu Cầu Dịch Vụ</h2>
                    <p class="text-muted mb-0">
                        <c:choose>
                            <c:when test="${viewMode == 'history'}">
                                Xem lịch sử tất cả các yêu cầu dịch vụ
                            </c:when>
                            <c:otherwise>
                                Xem xét và xử lý các yêu cầu được giao cho bạn
                            </c:otherwise>
                        </c:choose>
                    </p>
                </div>
                <div class="d-flex gap-2">
                    <button class="btn btn-outline-primary" onclick="refreshPage()">
                        <i class="fas fa-sync-alt"></i> Làm Mới
                    </button>
                    <button class="btn btn-outline-info" onclick="exportToExcel()">
                        <i class="fas fa-download"></i> Xuất Excel
                    </button>
                </div>
            </div>

            <!-- View Mode Navigation -->
            <div class="mb-4">
                <ul class="nav nav-tabs">
                    <li class="nav-item">
                        <a class="nav-link ${viewMode != 'history' ? 'active' : ''}" 
                           href="${pageContext.request.contextPath}/technicalManagerApproval">
                            <i class="fas fa-tasks"></i> Yêu Cầu Được Giao
                            <c:if test="${awaitingApprovalCount > 0}">
                                <span class="badge bg-warning text-dark ms-2">${awaitingApprovalCount}</span>
                            </c:if>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link ${viewMode == 'history' ? 'active' : ''}" 
                           href="${pageContext.request.contextPath}/technicalManagerApproval?action=history">
                            <i class="fas fa-history"></i> Lịch Sử Tất Cả
                        </a>
                    </li>
                </ul>
            </div>
        </div>


        <!-- Alert Messages từ session -->
        <%
            String errorMsg = (String) session.getAttribute("error");
            String successMsg = (String) session.getAttribute("success");

            if (errorMsg != null) {
                session.removeAttribute("error");
        %>
            <script>
                window.addEventListener('load', function() {
                    showToast('<%= errorMsg %>', 'error');
                });
            </script>
        <%
            }

            if (successMsg != null) {
                session.removeAttribute("success");
        %>
            <script>
                window.addEventListener('load', function() {
                    showToast('<%= successMsg %>', 'success');
                });
            </script>
        <%
            }
        %>

        <!-- Statistics Cards -->
        <div class="row mb-4">
            <c:choose>
                <c:when test="${viewMode == 'history'}">
                    <!-- History View Statistics -->
                    <div class="col-md-4">
                        <div class="stats-card bg-info text-white">
                            <div class="text-center">
                                <i class="fas fa-list"></i>
                                <h4 class="mt-2">${totalCount}</h4>
                                <p>Tổng Yêu Cầu</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="stats-card bg-success text-white">
                            <div class="text-center">
                                <i class="fas fa-check-circle"></i>
                                <h4 class="mt-2">${approvedCount}</h4>
                                <p>Đã Duyệt</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="stats-card bg-danger text-white">
                            <div class="text-center">
                                <i class="fas fa-times-circle"></i>
                                <h4 class="mt-2">${rejectedCount}</h4>
                                <p>Đã Từ Chối</p>
                            </div>
                        </div>
                    </div>
                   
                </c:when>
                <c:otherwise>
                    <!-- Assigned Requests View Statistics -->
                    <div class="col-md-3">
                        <div class="stats-card bg-primary text-white">
                            <div class="text-center">
                                <i class="fas fa-clock"></i>
                                <h4 class="mt-2">${awaitingApprovalCount}</h4>
                                <p>Chờ Duyệt</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stats-card bg-warning text-dark">
                            <div class="text-center">
                                <i class="fas fa-exclamation-triangle"></i>
                                <h4 class="mt-2">${urgentCount}</h4>
                                <p>Cần Khẩn Cấp</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stats-card bg-info text-white">
                            <div class="text-center">
                                <i class="fas fa-calendar-day"></i>
                                <h4 class="mt-2">${todayCount}</h4>
                                <p>Hôm Nay</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stats-card bg-success text-white">
                            <div class="text-center">
                                <i class="fas fa-check-circle"></i>
                                <h4 class="mt-2">${approvedToday}</h4>
                                <p>Đã Duyệt Hôm Nay</p>
                            </div>
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- Search & Filter Bar -->
        <div class="search-filter-bar">
            <form action="${pageContext.request.contextPath}/technicalManagerApproval" method="get" class="row g-3">
                <input type="hidden" name="viewMode" value="${viewMode}">
                <input type="hidden" name="technicianId" value="${technicianId}">
                <div class="col-md-4">
                    <div class="input-group">
                        <input type="text" class="form-control" name="keyword"
                               placeholder="Tìm kiếm theo mô tả, khách hàng..." value="${keyword}">
                        <button class="btn btn-primary" type="submit" name="action" value="search">
                            <i class="fas fa-search"></i>
                        </button>
                    </div>
                </div>
                <div class="col-md-3">
                    <select class="form-select" name="priority" id="filterPriority">
                        <option value="">-- Tất Cả Mức Độ --</option>
                        <option value="Urgent" ${filterPriority == 'Urgent' ? 'selected' : ''}>Khẩn Cấp</option>
                        <option value="High" ${filterPriority == 'High' ? 'selected' : ''}>Cao</option>
                        <option value="Normal" ${filterPriority == 'Normal' ? 'selected' : ''}>Bình Thường</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <select class="form-select" name="urgency" id="filterUrgency">
                        <option value="">-- Tình Trạng Khẩn --</option>
                        <option value="Urgent" ${filterUrgency == 'Urgent' ? 'selected' : ''}>Cần Duyệt Gấp</option>
                        <option value="High" ${filterUrgency == 'High' ? 'selected' : ''}>Ưu Tiên Cao</option>
                        <option value="Normal" ${filterUrgency == 'Normal' ? 'selected' : ''}>Bình Thường</option>
                    </select>
                </div>
                <div class="col-md-2">
                    <button type="submit" name="action" value="filter" class="btn btn-info w-100">
                        <i class="fas fa-filter"></i> Lọc
                    </button>
                </div>
            </form>
            <c:if test="${searchMode || filterMode}">
                <div class="mt-3">
                    <a href="${pageContext.request.contextPath}/technicalManagerApproval?viewMode=${viewMode}&technicianId=${technicianId}" class="btn btn-sm btn-secondary">
                        <i class="fas fa-times"></i> Xóa Bộ Lọc
                    </a>
                </div>
            </c:if>
        </div>

        <!-- Requests Table -->
        <div class="table-container">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h5>
                    <i class="fas fa-list"></i> 
                    <c:choose>
                        <c:when test="${viewMode == 'history'}">
                            Lịch Sử Tất Cả Yêu Cầu
                        </c:when>
                        <c:otherwise>
                            Danh Sách Yêu Cầu Được Giao
                        </c:otherwise>
                    </c:choose>
                </h5>
                <div class="d-flex align-items-center gap-2">
                    <span class="text-muted">Tổng cộng: <strong>${requests.size()}</strong> yêu cầu</span>
                </div>
            </div>

            <div class="table-responsive">
                <table class="table table-hover">
                    <thead class="table-light">
                        <tr>
                            <th>Mã YC</th>
                            <th>Khách Hàng</th>
                            <th>Thiết Bị</th>
                            <th>Mô Tả</th>
                            <th>Ưu Tiên</th>
                            <th>Trạng Thái</th>
                            <th>Ngày Tạo</th>
                            <c:if test="${viewMode != 'history'}">
                                <th>Số Ngày Chờ</th>
                            </c:if>
                            <th>Thao Tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="request" items="${requests}">
                            <tr class="request-row" data-request-id="${request.requestId}">
                                <td>
                                    <strong>#${request.requestId}</strong>
                                    <div class="priority-indicator priority-${request.priorityLevel.toLowerCase()}"></div>
                                </td>
                                <td>
                                    <div><strong>${request.customerName}</strong></div>
                                    <small class="text-muted">${request.customerEmail}</small>
                                </td>
                                <td>
                                    <div><strong>${request.equipmentName}</strong></div>
                                    <small class="text-muted">SN: ${request.serialNumber}</small>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${request.description.length() > 80}">
                                            ${request.description.substring(0, 80)}...
                                        </c:when>
                                        <c:otherwise>
                                            ${request.description}
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${request.priorityLevel == 'Urgent'}">
                                            <span class="badge badge-urgent">
                                                <i class="fas fa-exclamation-circle"></i> Khẩn Cấp
                                            </span>
                                        </c:when>
                                        <c:when test="${request.priorityLevel == 'High'}">
                                            <span class="badge badge-high">
                                                <i class="fas fa-arrow-up"></i> Cao
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge badge-normal">
                                                <i class="fas fa-minus"></i> Bình Thường
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${request.status == 'Awaiting Approval'}">
                                            <span class="badge bg-warning text-dark">
                                                <i class="fas fa-clock"></i> Chờ Duyệt
                                            </span>
                                        </c:when>
                                        <c:when test="${request.status == 'Approved'}">
                                            <span class="badge bg-success">
                                                <i class="fas fa-check"></i> Đã Duyệt
                                            </span>
                                        </c:when>
                                        <c:when test="${request.status == 'Rejected'}">
                                            <span class="badge bg-danger">
                                                <i class="fas fa-times"></i> Từ Chối
                                            </span>
                                        </c:when>
                                        <c:when test="${request.status == 'Pending'}">
                                            <span class="badge bg-secondary">
                                                <i class="fas fa-hourglass-half"></i> Chờ Xử Lý
                                            </span>
                                        </c:when>
                                        <c:when test="${request.status == 'Completed'}">
                                            <span class="badge bg-info">
                                                <i class="fas fa-check-circle"></i> Hoàn Thành
                                            </span>
                                        </c:when>
                                        <c:when test="${request.status == 'Cancelled'}">
                                            <span class="badge bg-warning">
                                                <i class="fas fa-ban"></i> Đã Hủy
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge bg-light text-dark">${request.status}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <fmt:formatDate value="${request.requestDate}" pattern="dd/MM/yyyy"/>
                                    <br>
                                    <small class="text-muted">
                                        <fmt:formatDate value="${request.requestDate}" pattern="HH:mm"/>
                                    </small>
                                </td>
                                <c:if test="${viewMode != 'history'}">
                                    <td>
                                        <span class="badge ${request.daysPending >= 7 ? 'bg-danger' : request.daysPending >= 3 ? 'bg-warning' : 'bg-info'}">
                                            ${request.daysPending} ngày
                                        </span>
                                    </td>
                                </c:if>
                                <td>
                                    <div class="d-flex gap-1">
                                        <c:choose>
                                            <c:when test="${viewMode == 'history'}">
                                                <button class="btn btn-sm btn-info request-action-btn"
                                                        data-action="view"
                                                        data-request-id="<c:out value='${request.requestId}' escapeXml='true'/>"
                                                        title="Chi Tiết">
                                                    <i class="fas fa-eye"></i>
                                                </button>
                                            </c:when>
                                            <c:when test="${request.status == 'Awaiting Approval'}">
                                                <button class="btn btn-sm btn-success request-action-btn"
                                                        data-action="approve"
                                                        data-request-id="<c:out value='${request.requestId}' escapeXml='true'/>"
                                                        data-customer-name="<c:out value='${request.customerName}' escapeXml='true'/>"
                                                        data-equipment-name="<c:out value='${request.equipmentName}' escapeXml='true'/>"
                                                        title="Duyệt">
                                                    <i class="fas fa-check"></i>
                                                </button>
                                                <button class="btn btn-sm btn-danger request-action-btn"
                                                        data-action="reject"
                                                        data-request-id="<c:out value='${request.requestId}' escapeXml='true'/>"
                                                        data-customer-name="<c:out value='${request.customerName}' escapeXml='true'/>"
                                                        data-equipment-name="<c:out value='${request.equipmentName}' escapeXml='true'/>"
                                                        title="Từ Chối">
                                                    <i class="fas fa-times"></i>
                                                </button>
                                                <button class="btn btn-sm btn-info request-action-btn"
                                                        data-action="view"
                                                        data-request-id="<c:out value='${request.requestId}' escapeXml='true'/>"
                                                        title="Chi Tiết">
                                                    <i class="fas fa-eye"></i>
                                                </button>
                                            </c:when>
                                            <c:otherwise>
                                                <button class="btn btn-sm btn-info request-action-btn"
                                                        data-action="view"
                                                        data-request-id="<c:out value='${request.requestId}' escapeXml='true'/>"
                                                        title="Chi Tiết">
                                                    <i class="fas fa-eye"></i>
                                                </button>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty requests}">
                            <tr>
                                <td colspan="${viewMode == 'history' ? '8' : '9'}" class="text-center py-5">
                                    <i class="fas fa-inbox fa-4x text-muted mb-3"></i>
                                    <c:choose>
                                        <c:when test="${viewMode == 'history'}">
                                            <h5 class="text-muted">Không có lịch sử yêu cầu</h5>
                                            <p class="text-muted">Chưa có yêu cầu nào được xử lý</p>
                                        </c:when>
                                        <c:otherwise>
                                            <h5 class="text-muted">Không có yêu cầu nào được giao</h5>
                                            <p class="text-muted">Chưa có yêu cầu nào được giao cho kỹ thuật viên này</p>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
</div>
            </div>
        </div>
    </div>

    <!-- View Details Modal -->
    <div class="modal fade" id="viewModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="fas fa-file-alt"></i> Chi Tiết Yêu Cầu Dịch Vụ</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="request-details-card">
                        <h6><i class="fas fa-info-circle"></i> Thông Tin Cơ Bản</h6>
                        <div class="detail-row">
                            <span class="detail-label">Mã Yêu Cầu:</span>
                            <span class="detail-value" id="viewRequestId"></span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Ngày Tạo:</span>
                            <span class="detail-value" id="viewRequestDate"></span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Trạng Thái:</span>
                            <span class="detail-value" id="viewStatus"></span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Mức Độ Ưu Tiên:</span>
                            <span class="detail-value" id="viewPriority"></span>
                        </div>
                    </div>

                    <div class="request-details-card">
                        <h6><i class="fas fa-user"></i> Thông Tin Khách Hàng</h6>
                        <div class="detail-row">
                            <span class="detail-label">Tên Khách Hàng:</span>
                            <span class="detail-value" id="viewCustomerName"></span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Email:</span>
                            <span class="detail-value" id="viewCustomerEmail"></span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Số Điện Thoại:</span>
                            <span class="detail-value" id="viewCustomerPhone"></span>
                        </div>
                    </div>

                    <div class="request-details-card">
                        <h6><i class="fas fa-cog"></i> Thông Tin Thiết Bị</h6>
                        <div class="detail-row">
                            <span class="detail-label">Mã Thiết Bị:</span>
                            <span class="detail-value" id="viewEquipmentId"></span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Model:</span>
                            <span class="detail-value" id="viewEquipmentModel"></span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Serial Number:</span>
                            <span class="detail-value" id="viewEquipmentSerial"></span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Loại Hợp Đồng:</span>
                            <span class="detail-value" id="viewContractType"></span>
                        </div>
                    </div>

                    <div class="request-details-card">
                        <h6><i class="fas fa-align-left"></i> Mô Tả Vấn Đề</h6>
                        <div class="border rounded p-3 bg-light" id="viewDescription" style="white-space: pre-wrap; max-height: 200px; overflow-y: auto;"></div>
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

    <!-- Approve Modal -->
    <div class="modal fade" id="approveModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <form action="${pageContext.request.contextPath}/technicalManagerApproval" method="post">
                    <input type="hidden" name="action" value="approve">
                    <input type="hidden" name="requestId" id="approveRequestId">
                    <div class="modal-header bg-success text-white">
                        <h5 class="modal-title"><i class="fas fa-check-circle"></i> Duyệt Yêu Cầu Dịch Vụ</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div class="alert alert-success">
                            <i class="fas fa-info-circle"></i>
                            Bạn đang duyệt yêu cầu cho: <strong id="approveCustomerName"></strong>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Dự Kiến Thời Gian Thực Hiện (giờ) <span class="text-danger">*</span></label>
                            <input type="number" class="form-control" name="estimatedEffort" step="0.5" min="0.5" max="100" required>
                            <small class="form-text text-muted">Ước tính thời gian cần thiết để hoàn thành</small>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Kỹ Năng Yêu Cầu</label>
                            <input type="text" class="form-control" name="recommendedSkills"
                                   placeholder="Ví dụ: Electrical, HVAC, Mechanical">
                            <small class="form-text text-muted">Các kỹ năng cần thiết để thực hiện yêu cầu này</small>
                        </div>

                       

                        <div class="mb-3">
                            <label class="form-label">Ghi Chú Duyệt</label>
                            <textarea class="form-control" name="approvalNotes" rows="3"
                                      placeholder="Ghi chú cho khách hàng về việc duyệt yêu cầu..."></textarea>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Ghi Chú Nội Bộ</label>
                            <textarea class="form-control" name="internalNotes" rows="3"
                                      placeholder="Ghi chú nội bộ cho kỹ thuật viên..."></textarea>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                            <i class="fas fa-times"></i> Hủy
                        </button>
                        <button type="submit" class="btn btn-success">
                            <i class="fas fa-check"></i> Duyệt Yêu Cầu
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Reject Modal -->
    <div class="modal fade" id="rejectModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <form action="${pageContext.request.contextPath}/technicalManagerApproval" method="post">
                    <input type="hidden" name="action" value="reject">
                    <input type="hidden" name="requestId" id="rejectRequestId">
                    <div class="modal-header bg-danger text-white">
                        <h5 class="modal-title"><i class="fas fa-times-circle"></i> Từ Chối Yêu Cầu Dịch Vụ</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div class="alert alert-danger">
                            <i class="fas fa-exclamation-triangle"></i>
                            Bạn đang từ chối yêu cầu của: <strong id="rejectCustomerName"></strong>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Lý Do Từ Chối <span class="text-danger">*</span></label>
                            <select class="form-select" name="rejectionReason" required>
                                <option value="">-- Chọn Lý Do --</option>
                                <option value="Không thuộc phạm vi bảo hành">Không thuộc phạm vi bảo hành</option>
                                <option value="Thiếu thông tin cần thiết">Thiếu thông tin cần thiết</option>
                                <option value="Thiết bị không đủ điều kiện">Thiết bị không đủ điều kiện</option>
                                <option value="Trùng lặp với yêu cầu khác">Trùng lặp với yêu cầu khác</option>
                                <option value="Vấn đề không rõ ràng">Vấn đề không rõ ràng</option>
                                <option value="Khác">Khác</option>
                            </select>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Ghi Chú Từ Chối</label>
                            <textarea class="form-control" name="rejectionNotes" rows="4"
                                      placeholder="Giải thích chi tiết lý do từ chối cho khách hàng..."></textarea>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Ghi Chú Nội Bộ</label>
                            <textarea class="form-control" name="internalNotes" rows="3"
                                      placeholder="Ghi chú nội bộ về việc từ chối..."></textarea>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                            <i class="fas fa-times"></i> Hủy
                        </button>
                        <button type="submit" class="btn btn-danger">
                            <i class="fas fa-times"></i> Từ Chối Yêu Cầu
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Toast notification functions
        let currentToastTimeout = null;

        function showToast(message, type) {
            const container = document.getElementById('toastContainer');
            container.innerHTML = '';

            if (currentToastTimeout) {
                clearTimeout(currentToastTimeout);
            }

            const toast = document.createElement('div');
            toast.className = 'toast-notification ' + type;

            let iconClass = type === 'success' ? 'fa-check-circle' : (type === 'warning' ? 'fa-exclamation-triangle' : 'fa-exclamation-circle');

            toast.innerHTML = '<div class="toast-icon ' + type + '"><i class="fas ' + iconClass + '"></i></div>' +
                            '<div class="toast-content">' + message + '</div>' +
                            '<button class="toast-close" onclick="hideToast()"><i class="fas fa-times"></i></button>';

            container.appendChild(toast);

            setTimeout(function() {
                container.classList.add('show');
            }, 10);

            currentToastTimeout = setTimeout(function() {
                hideToast();
            }, 5000);
        }

        function hideToast() {
            const container = document.getElementById('toastContainer');
            container.classList.remove('show');
            setTimeout(function() {
                container.innerHTML = '';
            }, 500);
            if (currentToastTimeout) {
                clearTimeout(currentToastTimeout);
                currentToastTimeout = null;
            }
        }

        // Loading functions
        function showLoading() {
            // Create loading overlay if it doesn't exist
            let loadingOverlay = document.getElementById('loadingOverlay');
            if (!loadingOverlay) {
                loadingOverlay = document.createElement('div');
                loadingOverlay.id = 'loadingOverlay';
                loadingOverlay.style.cssText = `
                    position: fixed;
                    top: 0;
                    left: 0;
                    width: 100%;
                    height: 100%;
                    background: rgba(0, 0, 0, 0.5);
                    display: flex;
                    justify-content: center;
                    align-items: center;
                    z-index: 9999;
                `;
                loadingOverlay.innerHTML = `
                    <div style="background: white; padding: 20px; border-radius: 10px; text-align: center;">
                        <div class="spinner-border text-primary" role="status">
                            <span class="visually-hidden">Loading...</span>
                        </div>
                        <div style="margin-top: 10px; color: #667eea;">Đang tải...</div>
                    </div>
                `;
                document.body.appendChild(loadingOverlay);
            }
            loadingOverlay.style.display = 'flex';
        }

        function hideLoading() {
            const loadingOverlay = document.getElementById('loadingOverlay');
            if (loadingOverlay) {
                loadingOverlay.style.display = 'none';
            }
        }

        // Approve request function
        function approveRequest(requestId, customerName, equipmentName) {
            document.getElementById('approveRequestId').value = requestId;
            document.getElementById('approveCustomerName').textContent = customerName;
            var approveModal = new bootstrap.Modal(document.getElementById('approveModal'));
            approveModal.show();
        }

        // Reject request function
        function rejectRequest(requestId, customerName, equipmentName) {
            document.getElementById('rejectRequestId').value = requestId;
            document.getElementById('rejectCustomerName').textContent = customerName;
            var rejectModal = new bootstrap.Modal(document.getElementById('rejectModal'));
            rejectModal.show();
        }

        // View request details function
        function viewRequestDetails(requestId) {
            // Show loading state
            showLoading();
            
            // Make AJAX call to get request details
            fetch('technicalManagerApproval', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: 'action=getRequestDetails&requestId=' + requestId
            })
            .then(response => response.json())
            .then(data => {
                hideLoading();
                
                if (data.error) {
                    showToast('Lỗi: ' + data.error, 'error');
                    return;
                }
                
                // Populate modal with data
                document.getElementById('viewRequestId').textContent = data.requestId;
                document.getElementById('viewRequestDate').textContent = formatDate(data.requestDate);
                document.getElementById('viewStatus').innerHTML = getStatusBadge(data.status);
                document.getElementById('viewPriority').innerHTML = getPriorityBadge(data.priorityLevel);
                
                document.getElementById('viewCustomerName').textContent = data.customerName || 'N/A';
                document.getElementById('viewCustomerEmail').textContent = data.customerEmail || 'N/A';
                document.getElementById('viewCustomerPhone').textContent = data.customerPhone || 'N/A';
                
                document.getElementById('viewEquipmentId').textContent = data.equipmentId || 'N/A';
                document.getElementById('viewEquipmentModel').textContent = data.equipmentName || 'N/A';
                document.getElementById('viewEquipmentSerial').textContent = data.serialNumber || 'N/A';
                document.getElementById('viewContractType').textContent = data.contractType || 'N/A';
                
                document.getElementById('viewDescription').textContent = data.description || 'Không có mô tả';
                
                // Show modal
                var viewModal = new bootstrap.Modal(document.getElementById('viewModal'));
                viewModal.show();
            })
            .catch(error => {
                hideLoading();
                console.error('Error:', error);
                showToast('Lỗi khi tải chi tiết yêu cầu', 'error');
            });
        }
        
        // Helper function to format date
        function formatDate(dateString) {
            if (!dateString) return 'N/A';
            const date = new Date(dateString);
            return date.toLocaleDateString('vi-VN') + ' ' + date.toLocaleTimeString('vi-VN');
        }
        
        // Helper function to get status badge
        function getStatusBadge(status) {
            const statusMap = {
                'Pending': '<span class="badge bg-warning">Chờ duyệt</span>',
                'Approved': '<span class="badge bg-success">Đã duyệt</span>',
                'Rejected': '<span class="badge bg-danger">Từ chối</span>',
                'Completed': '<span class="badge bg-info">Hoàn thành</span>'
            };
            return statusMap[status] || '<span class="badge bg-secondary">' + status + '</span>';
        }
        
        // Helper function to get priority badge
        function getPriorityBadge(priority) {
            const priorityMap = {
                'Urgent': '<span class="badge bg-danger"><i class="fas fa-exclamation-triangle"></i> Khẩn cấp</span>',
                'High': '<span class="badge bg-warning"><i class="fas fa-arrow-up"></i> Cao</span>',
                'Normal': '<span class="badge bg-info"><i class="fas fa-minus"></i> Bình thường</span>',
                'Low': '<span class="badge bg-secondary"><i class="fas fa-arrow-down"></i> Thấp</span>'
            };
            return priorityMap[priority] || '<span class="badge bg-secondary">' + priority + '</span>';
        }

        // Refresh page function
        function refreshPage() {
            window.location.reload();
        }

        // Export to Excel function
        function exportToExcel() {
            showToast('Tính năng xuất Excel đang được phát triển', 'info');
        }

        // Auto-refresh every 30 seconds
        setInterval(function() {
            // You can implement auto-refresh logic here if needed
        }, 30000);

        // Toggle sidebar function
        function toggleSidebar() {
            const sidebar = document.getElementById('sidebar');
            sidebar.classList.toggle('show');
        }

        // Close sidebar when clicking outside on mobile
        document.addEventListener('click', function(event) {
            const sidebar = document.getElementById('sidebar');
            const toggleBtn = document.querySelector('.mobile-toggle');
            
            if (window.innerWidth <= 768 && 
                !sidebar.contains(event.target) && 
                !toggleBtn.contains(event.target)) {
                sidebar.classList.remove('show');
            }
        });

        // Event delegation for request action buttons
        document.addEventListener('click', function(event) {
            if (event.target.closest('.request-action-btn')) {
                const button = event.target.closest('.request-action-btn');
                const action = button.getAttribute('data-action');
                const requestId = button.getAttribute('data-request-id');
                
                if (action === 'view') {
                    viewRequestDetails(requestId);
                } else if (action === 'approve') {
                    const customerName = button.getAttribute('data-customer-name');
                    const equipmentName = button.getAttribute('data-equipment-name');
                    approveRequest(requestId, customerName, equipmentName);
                } else if (action === 'reject') {
                    const customerName = button.getAttribute('data-customer-name');
                    const equipmentName = button.getAttribute('data-equipment-name');
                    rejectRequest(requestId, customerName, equipmentName);
                }
            }
        });
    </script>
</body>
</html>