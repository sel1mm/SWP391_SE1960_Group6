<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <title>CRM System - Lịch sử thiết bị</title>

    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f5f5f5;
            color: #333;
            line-height: 1.6;
            min-height: 100vh;
        }

        /* Sidebar - Full Height */
        .sidebar {
            width: 220px;
            height: 100vh;
            position: fixed;
            top: 0;
            left: 0;
            background: #000000;
            display: flex;
            flex-direction: column;
            box-shadow: 2px 0 4px rgba(0,0,0,0.1);
            z-index: 1001;
        }

        .sidebar-logo {
            color: white;
            font-size: 24px;
            font-weight: 600;
            padding: 1rem 1.25rem;
            border-bottom: 1px solid rgba(255,255,255,0.1);
            display: flex;
            align-items: center;
            gap: 10px;
            height: 65px;
        }

        .sidebar-menu {
            flex: 1;
            overflow-y: auto;
            padding-top: 10px;
        }

        .sidebar a {
            color: white;
            text-decoration: none;
            padding: 12px 20px;
            font-size: 14px;
            display: flex;
            align-items: center;
            gap: 12px;
            transition: all 0.2s;
            border-left: 3px solid transparent;
        }

        .sidebar a:hover, .sidebar a.active {
            background: rgba(255,255,255,0.08);
            border-left: 3px solid white;
        }

        .sidebar a i {
            min-width: 18px;
            text-align: center;
            font-size: 16px;
        }

        .sidebar .logout-btn {
            margin-top: auto;
            background: rgba(255, 255, 255, 0.05);
            border-top: 1px solid rgba(255,255,255,0.1);
            text-align: center;
            font-weight: 500;
        }

        /* Top Navbar - Right Side Only */
        .navbar {
            background: #f5f5f5;
            padding: 1rem 2rem;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            position: fixed;
            top: 0;
            left: 220px;
            right: 0;
            z-index: 1000;
            height: 65px;
            display: flex;
            justify-content: flex-end;
            align-items: center;
            border-bottom: 1px solid #e0e0e0;
        }

        .user-info {
            color: #2c5f6f;
            font-weight: 600;
            font-size: 14px;
            padding: 8px 20px;
            background: #d4f1f4;
            border-radius: 6px;
            border: 1px solid #b8e6e9;
        }

        /* Main Content */
        .container {
            margin-left: 220px;
            margin-top: 65px;
            min-height: calc(100vh - 65px);
        }

        .content {
            padding: 30px 40px;
            background: #f5f5f5;
        }

        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
        }

        .page-header h2 {
            color: #333;
            font-weight: 600;
            font-size: 28px;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .btn-export {
            background: #28a745;
            color: white;
            border: none;
            padding: 9px 18px;
            border-radius: 6px;
            cursor: pointer;
            font-weight: 500;
            transition: all 0.2s ease;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            font-size: 14px;
        }

        .btn-export:hover {
            background: #218838;
            transform: translateY(-1px);
            box-shadow: 0 2px 6px rgba(40,167,69,0.3);
        }

        /* STATISTICS CARDS */
        .stats-overview {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .stat-card {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            border: 1px solid #e0e0e0;
            border-left: 4px solid #007bff;
            transition: transform 0.2s;
        }

        .stat-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.15);
        }

        .stat-card.added { border-left-color: #28a745; }
        .stat-card.changed { border-left-color: #ffc107; }
        .stat-card.total { border-left-color: #17a2b8; }

        .stat-card h3 {
            font-size: 14px;
            color: #666;
            margin-bottom: 10px;
            font-weight: 500;
        }

        .stat-card .number {
            font-size: 32px;
            font-weight: 700;
            color: #333;
        }

        .stat-card .icon {
            float: right;
            font-size: 24px;
            opacity: 0.3;
        }

        .stat-card.added .icon { color: #28a745; }
        .stat-card.changed .icon { color: #ffc107; }
        .stat-card.total .icon { color: #17a2b8; }

        /* FILTER PANEL */
        .filter-panel {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            margin-bottom: 20px;
            border: 1px solid #e0e0e0;
        }

        .filter-form {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            align-items: end;
        }

        .form-group {
            display: flex;
            flex-direction: column;
        }

        .form-group label {
            font-weight: 500;
            margin-bottom: 6px;
            color: #666;
            font-size: 14px;
        }

        .form-group select,
        .form-group input {
            padding: 9px 12px;
            border: 1px solid #d0d0d0;
            border-radius: 6px;
            font-size: 14px;
            outline: none;
            background: #fafafa;
            transition: all 0.2s ease;
        }

        .form-group select:focus,
        .form-group input:focus {
            border-color: #999;
            box-shadow: 0 0 0 3px rgba(0,0,0,0.05);
            background: white;
        }

        .btn-filter {
            background: #007bff;
            color: white;
            border: none;
            padding: 9px 18px;
            border-radius: 6px;
            cursor: pointer;
            font-weight: 500;
            transition: all 0.2s ease;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            font-size: 14px;
        }

        .btn-filter:hover {
            background: #0056b3;
            transform: translateY(-1px);
            box-shadow: 0 2px 6px rgba(0,123,255,0.3);
        }

        /* TABLE */
        .stats-table {
            width: 100%;
            background: white;
            border-collapse: collapse;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            table-layout: fixed;
            border: 1px solid #e0e0e0;
        }

        .stats-table thead tr {
            background: #f8f9fa;
            border-bottom: 2px solid #dee2e6;
        }

        .stats-table thead th {
            padding: 12px 16px;
            text-align: left;
            font-weight: 600;
            font-size: 13px;
            color: #333;
        }

        /* Adjusted column widths - removed 3 columns */
        .stats-table thead th:nth-child(1) { width: 5%; }
        .stats-table thead th:nth-child(2) { width: 15%; }
        .stats-table thead th:nth-child(3) { width: 15%; }
        .stats-table thead th:nth-child(4) { width: 10%; }
        .stats-table thead th:nth-child(5) { width: 10%; }
        .stats-table thead th:nth-child(6) { width: 10%; }
        .stats-table thead th:nth-child(7) { width: 12%; }
        .stats-table thead th:nth-child(8) { width: 13%; }
        .stats-table thead th:nth-child(9) { width: 10%; }

        .stats-table tbody td {
            padding: 12px 16px;
            border-bottom: 1px solid #e0e0e0;
            font-size: 13px;
            color: #666;
        }

        .stats-table tbody tr:hover {
            background-color: #f0f0f0;
        }

        .stats-table tbody tr:last-child td {
            border-bottom: none;
        }

        /* BUTTON DETAILS */
        .btn-details {
            background: #17a2b8;
            color: white;
            border: none;
            padding: 6px 14px;
            border-radius: 6px;
            cursor: pointer;
            font-weight: 500;
            transition: all 0.2s ease;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-size: 13px;
        }

        .btn-details:hover {
            background: #138496;
            transform: translateY(-1px);
            box-shadow: 0 2px 6px rgba(23,162,184,0.3);
        }

        /* MODAL */
        .modal-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.5);
            display: none;
            justify-content: center;
            align-items: center;
            z-index: 3000;
        }

        .modal-overlay.show {
            display: flex;
        }

        .modal-container {
            background: white;
            border-radius: 12px;
            width: 700px;
            max-width: 95%;
            max-height: 90vh;
            overflow-y: auto;
            box-shadow: 0 10px 40px rgba(0,0,0,0.3);
        }

        .modal-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px 25px;
            border-radius: 12px 12px 0 0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .modal-header h3 {
            font-size: 20px;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .modal-close {
            background: rgba(255,255,255,0.2);
            border: none;
            color: white;
            width: 32px;
            height: 32px;
            border-radius: 50%;
            cursor: pointer;
            font-size: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.2s;
        }

        .modal-close:hover {
            background: rgba(255,255,255,0.3);
            transform: rotate(90deg);
        }

        .modal-body {
            padding: 25px;
        }

        .detail-section {
            margin-bottom: 20px;
        }

        .detail-section h4 {
            color: #667eea;
            font-size: 14px;
            font-weight: 600;
            margin-bottom: 12px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .detail-grid {
            display: grid;
            grid-template-columns: 140px 1fr;
            gap: 12px;
            background: #f8f9fa;
            padding: 15px;
            border-radius: 8px;
            border-left: 3px solid #667eea;
        }

        .detail-label {
            font-weight: 600;
            color: #666;
            font-size: 13px;
        }

        .detail-value {
            color: #333;
            font-size: 13px;
            word-wrap: break-word;
        }

        .detail-value strong {
            color: #667eea;
            font-weight: 600;
        }

        .status-change-flow {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-top: 8px;
        }

        .status-change-flow .arrow {
            color: #667eea;
            font-size: 20px;
        }

        .modal-footer {
            padding: 15px 25px;
            background: #f8f9fa;
            border-radius: 0 0 12px 12px;
            display: flex;
            justify-content: flex-end;
        }

        .btn-close-modal {
            background: #6c757d;
            color: white;
            border: none;
            padding: 10px 24px;
            border-radius: 6px;
            cursor: pointer;
            font-weight: 500;
            font-size: 14px;
            transition: all 0.2s;
        }

        .btn-close-modal:hover {
            background: #5a6268;
            transform: translateY(-1px);
        }

        /* STATUS BADGES */
        .status-badge {
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 500;
            display: inline-block;
        }

        .status-badge.inuse {
            background: #d4edda;
            color: #155724;
        }

        .status-badge.fault, .status-badge.faulty {
            background: #f8d7da;
            color: #721c24;
        }

        .status-badge.available {
            background: #fff3cd;
            color: #856404;
        }

        .status-badge.retired {
            background: #e2e3e5;
            color: #383d41;
        }

        .status-badge.new, .status-badge.mớitạo {
            background: #d1ecf1;
            color: #0c5460;
        }

        /* ACTION TYPE BADGE */
        .action-badge {
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 11px;
            font-weight: 600;
            display: inline-block;
            text-transform: uppercase;
        }

        .action-badge.add {
            background: #d4edda;
            color: #155724;
        }

        .action-badge.update {
            background: #fff3cd;
            color: #856404;
        }

        /* NO DATA */
        .no-data {
            text-align: center;
            padding: 40px;
            color: #999;
            font-size: 16px;
        }

        .no-data i {
            font-size: 48px;
            margin-bottom: 10px;
            display: block;
        }

        .section-title {
            color: #333;
            font-size: 18px;
            font-weight: 600;
            margin: 20px 0 15px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .section-title .count {
            background: #007bff;
            color: white;
            padding: 2px 10px;
            border-radius: 12px;
            font-size: 14px;
        }

        /* PAGINATION */
        .pagination {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 8px;
            margin-top: 20px;
            padding: 20px;
            background: white;
            border-radius: 8px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }

        .pagination button {
            padding: 8px 14px;
            border: 1px solid #dee2e6;
            background: white;
            color: #333;
            border-radius: 6px;
            cursor: pointer;
            font-weight: 500;
            transition: all 0.2s;
            font-size: 14px;
        }

        .pagination button:hover:not(:disabled) {
            background: #007bff;
            color: white;
            border-color: #007bff;
        }

        .pagination button.active {
            background: #007bff;
            color: white;
            border-color: #007bff;
        }

        .pagination button:disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }

        .pagination .page-info {
            margin: 0 15px;
            color: #666;
            font-size: 14px;
        }

        /* RESPONSIVE */
        @media (max-width: 900px) {
            .content {
                margin-left: 0;
                width: 100%;
                padding: 20px;
            }
            .sidebar {
                display: none;
            }
            .navbar {
                left: 0;
            }
            .container {
                margin-left: 0;
            }
            .stats-overview {
                grid-template-columns: 1fr 1fr;
            }
            .filter-form {
                grid-template-columns: 1fr;
            }
        }
        /* ========== FLOATING CHATBOT STYLES ========== */

/* Chat Button */
.chat-button {
    position: fixed;
    bottom: 30px;
    right: 30px;
    width: 60px;
    height: 60px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    box-shadow: 0 4px 20px rgba(102, 126, 234, 0.4);
    transition: all 0.3s ease;
    z-index: 1002;
    border: none;
}

.chat-button:hover {
    transform: scale(1.1);
    box-shadow: 0 6px 30px rgba(102, 126, 234, 0.6);
}

.chat-button.active {
    background: #ff6b6b;
}

.chat-button i {
    font-size: 26px;
    color: white;
}

/* Chat Widget */
.chat-widget {
    position: fixed;
    bottom: 100px;
    right: 30px;
    width: 400px;
    height: 600px;
    background: white;
    border-radius: 20px;
    box-shadow: 0 10px 40px rgba(0,0,0,0.3);
    display: none;
    flex-direction: column;
    overflow: hidden;
    z-index: 1001;
    animation: slideUp 0.3s ease-out;
}

.chat-widget.active {
    display: flex;
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

.chat-widget-header {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    padding: 20px;
    text-align: center;
    font-size: 18px;
    font-weight: bold;
}

.chat-widget-messages {
    flex: 1;
    padding: 20px;
    overflow-y: auto;
    background: #f5f5f5;
}

.chat-widget-message {
    margin-bottom: 15px;
    animation: fadeIn 0.3s;
}

@keyframes fadeIn {
    from { opacity: 0; transform: translateY(10px); }
    to { opacity: 1; transform: translateY(0); }
}

.chat-widget-message.user {
    text-align: right;
}

.chat-widget-message-content {
    display: inline-block;
    padding: 12px 18px;
    border-radius: 18px;
    max-width: 80%;
    word-wrap: break-word;
    line-height: 1.4;
}

.chat-widget-message.user .chat-widget-message-content {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
}

.chat-widget-message.ai .chat-widget-message-content {
    background: white;
    color: #333;
    box-shadow: 0 2px 5px rgba(0,0,0,0.1);
}

.chat-widget-message.error .chat-widget-message-content {
    background: #ff6b6b;
    color: white;
}

.typing-indicator {
    display: none;
    padding: 10px;
    text-align: left;
}

.typing-indicator.show {
    display: block;
}

.typing-dot {
    display: inline-block;
    width: 8px;
    height: 8px;
    border-radius: 50%;
    background: #999;
    margin: 0 2px;
    animation: typing 1.4s infinite;
}

.typing-dot:nth-child(2) { animation-delay: 0.2s; }
.typing-dot:nth-child(3) { animation-delay: 0.4s; }

@keyframes typing {
    0%, 60%, 100% { transform: translateY(0); }
    30% { transform: translateY(-10px); }
}

.chat-widget-input-area {
    padding: 20px;
    background: white;
    border-top: 1px solid #e0e0e0;
}

.chat-widget-input-wrapper {
    display: flex;
    gap: 10px;
}

#chatMessageInput {
    flex: 1;
    padding: 12px 18px;
    border: 2px solid #e0e0e0;
    border-radius: 25px;
    font-size: 14px;
    outline: none;
    transition: border-color 0.3s;
}

#chatMessageInput:focus {
    border-color: #667eea;
}

#chatSendButton {
    padding: 12px 25px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    border: none;
    border-radius: 25px;
    cursor: pointer;
    font-weight: bold;
    transition: transform 0.2s;
}

#chatSendButton:hover:not(:disabled) {
    transform: scale(1.05);
}

#chatSendButton:disabled {
    opacity: 0.6;
    cursor: not-allowed;
}

.chat-widget-messages::-webkit-scrollbar {
    width: 6px;
}

.chat-widget-messages::-webkit-scrollbar-track {
    background: #f1f1f1;
}

.chat-widget-messages::-webkit-scrollbar-thumb {
    background: #888;
    border-radius: 3px;
}

.chat-widget-messages::-webkit-scrollbar-thumb:hover {
    background: #555;
}
    </style>
</head>

<body>
    <!-- Sidebar Full Height -->
    <div class="sidebar">
        <div class="sidebar-logo">CRM System</div>
        <div class="sidebar-menu">
            <a href="statistic"><i class="fas fa-home"></i><span>Trang chủ</span></a>
            <a href="manageProfile"><i class="fas fa-user-circle"></i><span>Hồ Sơ</span></a>
            <a href="storekeeper"><i class="fas fa-chart-line"></i><span>Thống kê</span></a>
            <a href="numberPart"><i class="fas fa-list"></i><span>Danh sách linh kiện</span></a>
            <a href="numberEquipment"><i class="fas fa-list"></i><span>Danh sách thiết bị</span></a>
            <a href="PartDetailHistoryServlet" class="active"><i class="fas fa-history"></i><span>Lịch sử giao dịch</span></a>
            <a href="partDetail"><i class="fas fa-truck-loading"></i><span>Chi tiết linh kiện</span></a>
            <a href="category"><i class="fas fa-tags"></i><span>Quản lý danh mục</span></a>
        </div>
        <a href="logout" class="logout-btn">
            <i class="fas fa-sign-out-alt"></i><span>Đăng xuất</span>
        </a>
    </div>

    <!-- Top Navbar (Right Side Only) -->
    <nav class="navbar">
        <div class="user-info">
            Xin chào ${sessionScope.username}
        </div>
    </nav>

    <!-- Main Content -->
    <div class="container">
        <div class="content">
            <div class="page-header">
                <h2><i class="fas fa-history"></i> Lịch sử thiết bị</h2>
                <button class="btn-export" onclick="window.print()">
                    <i class="fas fa-print"></i> In báo cáo
                </button>
            </div>

            <!-- Statistics Overview -->
            <c:if test="${not empty overview}">
                <div class="stats-overview">
                    <div class="stat-card added">
                        <i class="fas fa-plus-circle icon"></i>
                        <h3>Thêm mới</h3>
                        <div class="number">${overview.addedCount}</div>
                    </div>
                    <div class="stat-card changed">
                        <i class="fas fa-exchange-alt icon"></i>
                        <h3>Thay đổi trạng thái</h3>
                        <div class="number">${overview.changedCount}</div>
                    </div>
                    <div class="stat-card total">
                        <i class="fas fa-clipboard-list icon"></i>
                        <h3>Tổng lịch sử</h3>
                        <div class="number">${overview.totalCount}</div>
                    </div>
                </div>
            </c:if>

            <!-- Filter Panel -->
            <div class="filter-panel">
                <form action="PartDetailHistoryServlet" method="GET" class="filter-form">
                    <div class="form-group">
                        <label><i class="fas fa-calendar"></i> Từ ngày</label>
                        <input type="date" name="fromDate" value="${fromDate}">
                    </div>

                    <div class="form-group">
                        <label><i class="fas fa-calendar"></i> Đến ngày</label>
                        <input type="date" name="toDate" value="${toDate}">
                    </div>

                    <div class="form-group">
                        <label><i class="fas fa-filter"></i> Loại hành động</label>
                        <select name="actionType">
                            <option value="all" ${actionType == 'all' ? 'selected' : ''}>Tất cả</option>
                            <option value="add" ${actionType == 'add' ? 'selected' : ''}>Thêm mới</option>
                            <option value="update" ${actionType == 'update' ? 'selected' : ''}>Thay đổi trạng thái</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label><i class="fas fa-search"></i> Tìm Serial Number</label>
                        <input type="text" name="keyword" placeholder="Nhập serial..." value="${keyword}">
                    </div>

                    <div class="form-group">
                        <button type="submit" class="btn-filter">
                            <i class="fas fa-search"></i> Tìm kiếm
                        </button>
                    </div>
                </form>
            </div>

            <!-- History Table -->
            <h3 class="section-title">
                <i class="fas fa-list"></i> 
                Lịch sử chi tiết
                <span class="count" id="totalRecords">${totalCount} bản ghi</span>
            </h3>
            <table class="stats-table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Serial Number</th>
                        <th>Part Name</th>
                        <th>Hành động</th>
                        <th>Trạng thái cũ</th>
                        <th>Trạng thái mới</th>
                        <th>Người thực hiện</th>
                        <th>Thời gian</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody id="tableBody">
                    <c:choose>
                        <c:when test="${not empty historyList}">
                            <c:forEach items="${historyList}" var="item">
                                <tr data-category="${item.categoryName != null ? item.categoryName : 'N/A'}"
                                    data-location="${item.location}"
                                    data-notes="${item.notes}">
                                    <td>${item.historyId}</td>
                                    <td><strong>${item.serialNumber}</strong></td>
                                    <td>${item.partName}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${empty item.oldStatus}">
                                                <span class="action-badge add">
                                                    <i class="fas fa-plus"></i> Thêm mới
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="action-badge update">
                                                    <i class="fas fa-edit"></i> Cập nhật
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${empty item.oldStatus}">
                                                <span class="status-badge new">Mới tạo</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="status-badge ${item.oldStatus.toLowerCase()}">${item.oldStatus}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <span class="status-badge ${item.newStatus.toLowerCase()}">${item.newStatus}</span>
                                    </td>
                                    <td>
                                        <i class="fas fa-user"></i> ${item.username}
                                    </td>
                                    <td>
                                        <fmt:formatDate value="${item.changedDate}" pattern="dd/MM/yyyy HH:mm:ss"/>
                                    </td>
                                    <td>
                                        <button class="btn-details" 
                                                data-history-id="${item.historyId}"
                                                data-serial="${item.serialNumber}"
                                                data-part-name="${item.partName}"
                                                data-category="${item.categoryName != null ? item.categoryName : 'N/A'}"
                                                data-old-status="${empty item.oldStatus ? 'Mới tạo' : item.oldStatus}"
                                                data-new-status="${item.newStatus}"
                                                data-location="${item.location}"
                                                data-username="${item.username}"
                                                data-time="<fmt:formatDate value='${item.changedDate}' pattern='dd/MM/yyyy HH:mm:ss'/>"
                                                data-notes="${item.notes}"
                                                data-action-type="${empty item.oldStatus ? 'add' : 'update'}">
                                            <i class="fas fa-info-circle"></i> Details
                                        </button>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="9">
                                    <div class="no-data">
                                        <i class="fas fa-inbox"></i>
                                        <p>Không có dữ liệu lịch sử</p>
                                    </div>
                                </td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>

            <!-- Pagination -->
            <div class="pagination" id="pagination">
                <button id="firstBtn" onclick="goToPage(1)">
                    <i class="fas fa-angle-double-left"></i>
                </button>
                <button id="prevBtn" onclick="previousPage()">
                    <i class="fas fa-angle-left"></i> Trước
                </button>
                <div class="page-info">
                    Trang <strong id="currentPage">1</strong> / <strong id="totalPages">1</strong>
                </div>
                <button id="nextBtn" onclick="nextPage()">
                    Sau <i class="fas fa-angle-right"></i>
                </button>
                <button id="lastBtn" onclick="goToLastPage()">
                    <i class="fas fa-angle-double-right"></i>
                </button>
            </div>

            <!-- MODAL DETAILS -->
            <div class="modal-overlay" id="detailsModal">
                <div class="modal-container">
                    <div class="modal-header">
                        <h3><i class="fas fa-info-circle"></i> Chi tiết lịch sử</h3>
                        <button class="modal-close" onclick="closeModal()">
                            <i class="fas fa-times"></i>
                        </button>
                    </div>
                    <div class="modal-body">
                        <div class="detail-section">
                            <h4><i class="fas fa-microchip"></i> Thông tin thiết bị</h4>
                            <div class="detail-grid">
                                <div class="detail-label">History ID:</div>
                                <div class="detail-value" id="modal-historyId">-</div>
                                
                                <div class="detail-label">Serial Number:</div>
                                <div class="detail-value"><strong id="modal-serialNumber">-</strong></div>
                                
                                <div class="detail-label">Part Name:</div>
                                <div class="detail-value" id="modal-partName">-</div>
                            </div>
                        </div>

                        <div class="detail-section">
                            <h4><i class="fas fa-clipboard-list"></i> Thông tin bổ sung</h4>
                            <div class="detail-grid">
                                <div class="detail-label">Category:</div>
                                <div class="detail-value" id="modal-category">-</div>
                                
                                <div class="detail-label">Location:</div>
                                <div class="detail-value" id="modal-location">-</div>
                            </div>
                        </div>

                        <div class="detail-section">
                            <h4><i class="fas fa-exchange-alt"></i> Thông tin thay đổi</h4>
                            <div class="detail-grid">
                                <div class="detail-label">Loại hành động:</div>
                                <div class="detail-value" id="modal-actionType">-</div>
                                
                                <div class="detail-label" style="grid-column: 1 / -1;">Trạng thái:</div>
                                <div style="grid-column: 1 / -1;">
                                    <div class="status-change-flow">
                                        <span id="modal-oldStatus">-</span>
                                        <span class="arrow"><i class="fas fa-arrow-right"></i></span>
                                        <span id="modal-newStatus">-</span>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="detail-section">
                            <h4><i class="fas fa-user-clock"></i> Thông tin người thực hiện</h4>
                            <div class="detail-grid">
                                <div class="detail-label">Người thực hiện:</div>
                                <div class="detail-value"><i class="fas fa-user"></i> <span id="modal-username">-</span></div>
                                
                                <div class="detail-label">Thời gian:</div>
                                <div class="detail-value"><i class="fas fa-clock"></i> <span id="modal-time">-</span></div>
                            </div>
                        </div>

                        <div class="detail-section">
                            <h4><i class="fas fa-sticky-note"></i> Ghi chú</h4>
                            <div class="detail-grid">
                                <div style="grid-column: 1 / -1;">
                                    <div class="detail-value" id="modal-notes" style="white-space: pre-wrap;">-</div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button class="btn-close-modal" onclick="closeModal()">
                            <i class="fas fa-times"></i> Đóng
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>
<!-- Floating Chat Button -->
<button class="chat-button" id="chatButton">
    <i class="fas fa-robot"></i>
</button>

<!-- Chat Widget -->
<div class="chat-widget" id="chatWidget">
    <div class="chat-widget-header">
        🤖 ChatGPT Assistant
    </div>
    
    <div class="chat-widget-messages" id="chatWidgetMessages">
        <div class="chat-widget-message ai">
            <div class="chat-widget-message-content">
                Xin chào! Tôi là trợ lý AI. Tôi có thể giúp gì cho bạn?
            </div>
        </div>
    </div>

    <div class="typing-indicator" id="chatTypingIndicator">
        <span class="typing-dot"></span>
        <span class="typing-dot"></span>
        <span class="typing-dot"></span>
    </div>
    
    <div class="chat-widget-input-area">
        <div class="chat-widget-input-wrapper">
            <input 
                type="text" 
                id="chatMessageInput" 
                placeholder="Nhập tin nhắn của bạn..."
                autocomplete="off"
            >
            <button id="chatSendButton">Gửi</button>
        </div>
    </div>
</div>
    <script>
        // Pagination Variables
        let currentPage = 1;
        const rowsPerPage = 10;
        let allRows = [];

        // Initialize on page load
        document.addEventListener('DOMContentLoaded', function() {
            // Get all table rows (excluding no-data rows)
            const tableBody = document.getElementById('tableBody');
            const allTableRows = Array.from(tableBody.querySelectorAll('tr'));
            
            // Filter out "no data" rows
            allRows = allTableRows.filter(row => !row.querySelector('.no-data'));
            
            // Only paginate if there are actual data rows
            if (allRows.length > 0) {
                displayPage(1);
            } else {
                // Hide pagination if no data
                document.getElementById('pagination').style.display = 'none';
            }
            
            // Add event listeners to detail buttons
            document.querySelectorAll('.btn-details').forEach(function(button) {
                button.addEventListener('click', function() {
                    showDetails(this);
                });
            });
            
            // Modal click outside to close
            const modal = document.getElementById('detailsModal');
            if (modal) {
                modal.addEventListener('click', function(e) {
                    if (e.target === this) {
                        closeModal();
                    }
                });
            }
            
            // Set default dates if empty
            const fromDate = document.querySelector('input[name="fromDate"]');
            const toDate = document.querySelector('input[name="toDate"]');
            
            if (fromDate && !fromDate.value) {
                const date = new Date();
                date.setDate(1);
                fromDate.value = date.toISOString().split('T')[0];
            }
            
            if (toDate && !toDate.value) {
                const date = new Date();
                toDate.value = date.toISOString().split('T')[0];
            }
        });

        // Display specific page
        function displayPage(page) {
            const totalPages = Math.ceil(allRows.length / rowsPerPage);
            
            // Validate page number
            if (page < 1) page = 1;
            if (page > totalPages) page = totalPages;
            
            currentPage = page;
            
            const startIndex = (page - 1) * rowsPerPage;
            const endIndex = startIndex + rowsPerPage;
            
            // Hide all rows
            allRows.forEach(row => row.style.display = 'none');
            
            // Show only rows for current page
            for (let i = startIndex; i < endIndex && i < allRows.length; i++) {
                allRows[i].style.display = '';
            }
            
            // Update pagination UI
            updatePaginationUI(totalPages);
        }

        // Update pagination buttons and info
        function updatePaginationUI(totalPages) {
            document.getElementById('currentPage').textContent = currentPage;
            document.getElementById('totalPages').textContent = totalPages;
            
            // Enable/disable buttons
            document.getElementById('firstBtn').disabled = currentPage === 1;
            document.getElementById('prevBtn').disabled = currentPage === 1;
            document.getElementById('nextBtn').disabled = currentPage === totalPages;
            document.getElementById('lastBtn').disabled = currentPage === totalPages;
        }

        // Navigation functions
        function nextPage() {
            const totalPages = Math.ceil(allRows.length / rowsPerPage);
            if (currentPage < totalPages) {
                displayPage(currentPage + 1);
            }
        }

        function previousPage() {
            if (currentPage > 1) {
                displayPage(currentPage - 1);
            }
        }

        function goToPage(page) {
            displayPage(page);
        }

        function goToLastPage() {
            const totalPages = Math.ceil(allRows.length / rowsPerPage);
            displayPage(totalPages);
        }

        // Show details modal
        function showDetails(button) {
            const historyId = button.getAttribute('data-history-id');
            const serialNumber = button.getAttribute('data-serial');
            const partName = button.getAttribute('data-part-name');
            const category = button.getAttribute('data-category');
            const oldStatus = button.getAttribute('data-old-status');
            const newStatus = button.getAttribute('data-new-status');
            const location = button.getAttribute('data-location');
            const username = button.getAttribute('data-username');
            const time = button.getAttribute('data-time');
            const notes = button.getAttribute('data-notes');
            const actionType = button.getAttribute('data-action-type');
            
            document.getElementById('modal-historyId').textContent = historyId || '-';
            document.getElementById('modal-serialNumber').textContent = serialNumber || '-';
            document.getElementById('modal-partName').textContent = partName || '-';
            
            const categoryEl = document.getElementById('modal-category');
            if (category && category !== 'N/A' && category !== 'null') {
                categoryEl.innerHTML = '<span style="background: #e7f3ff; padding: 4px 10px; border-radius: 6px; font-weight: 500; color: #0066cc;">' + category + '</span>';
            } else {
                categoryEl.innerHTML = '<span style="color: #999; font-style: italic;">N/A</span>';
            }
            
            document.getElementById('modal-location').textContent = location || '-';
            
            const actionBadge = actionType === 'add' 
                ? '<span class="action-badge add"><i class="fas fa-plus"></i> Thêm mới</span>'
                : '<span class="action-badge update"><i class="fas fa-edit"></i> Cập nhật</span>';
            document.getElementById('modal-actionType').innerHTML = actionBadge;
            
            const oldStatusClass = oldStatus.toLowerCase().replace(/\s+/g, '');
            const newStatusClass = newStatus.toLowerCase().replace(/\s+/g, '');
            
            document.getElementById('modal-oldStatus').innerHTML = 
                '<span class="status-badge ' + oldStatusClass + '">' + oldStatus + '</span>';
            document.getElementById('modal-newStatus').innerHTML = 
                '<span class="status-badge ' + newStatusClass + '">' + newStatus + '</span>';
            
            document.getElementById('modal-username').textContent = username || '-';
            document.getElementById('modal-time').textContent = time || '-';
            document.getElementById('modal-notes').textContent = notes || 'Không có ghi chú';
            
            document.getElementById('detailsModal').classList.add('show');
            document.body.style.overflow = 'hidden';
        }

        // Close modal
        function closeModal() {
            document.getElementById('detailsModal').classList.remove('show');
            document.body.style.overflow = 'auto';
        }
// ========== CHATBOT FUNCTIONALITY ==========
const chatButton = document.getElementById('chatButton');
const chatWidget = document.getElementById('chatWidget');
const chatMessageInput = document.getElementById('chatMessageInput');
const chatSendButton = document.getElementById('chatSendButton');
const chatWidgetMessages = document.getElementById('chatWidgetMessages');
const chatTypingIndicator = document.getElementById('chatTypingIndicator');

// Toggle chat widget
chatButton.addEventListener('click', function() {
    chatWidget.classList.toggle('active');
    chatButton.classList.toggle('active');
    
    if (chatWidget.classList.contains('active')) {
        chatMessageInput.focus();
        chatButton.innerHTML = '<i class="fas fa-times"></i>';
    } else {
        chatButton.innerHTML = '<i class="fas fa-robot"></i>';
    }
});

// Send message on Enter
chatMessageInput.addEventListener('keypress', function(e) {
    if (e.key === 'Enter' && !chatSendButton.disabled) {
        sendChatMessage();
    }
});

// Send message on button click
chatSendButton.addEventListener('click', sendChatMessage);

function sendChatMessage() {
    const message = chatMessageInput.value.trim();
    
    if (!message) {
        return;
    }

    // Display user message
    addChatMessage('user', message);
    
    // Clear input
    chatMessageInput.value = '';
    
    // Disable input
    chatSendButton.disabled = true;
    chatMessageInput.disabled = true;
    
    // Show typing indicator
    chatTypingIndicator.classList.add('show');
    scrollChatToBottom();

    // Send request to servlet
    fetch('AskGeminiServlet', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'q=' + encodeURIComponent(message)
    })
    .then(response => response.json())
    .then(data => {
        chatTypingIndicator.classList.remove('show');

        // If server returns error
        if (data.error) {
            addChatMessage('error', data.error);
            return;
        }

        // ONLY display natural language answer (no table, no SQL)
        if (data.ai_answer) {
            addChatMessage('ai', data.ai_answer);
        } else {
            addChatMessage('ai', 'Xin lỗi, tôi không thể trả lời câu hỏi này.');
        }
    })
    .catch(error => {
        chatTypingIndicator.classList.remove('show');
        addChatMessage('error', 'Không thể kết nối đến server');
        console.error('Error:', error);
    })
    .finally(() => {
        chatSendButton.disabled = false;
        chatMessageInput.disabled = false;
        chatMessageInput.focus();
    });
}

function addChatMessage(type, content) {
    const messageDiv = document.createElement('div');
    messageDiv.className = 'chat-widget-message ' + type;
    
    const contentDiv = document.createElement('div');
    contentDiv.className = 'chat-widget-message-content';
    contentDiv.textContent = content;
    
    messageDiv.appendChild(contentDiv);
    chatWidgetMessages.appendChild(messageDiv);
    
    scrollChatToBottom();
}

function scrollChatToBottom() {
    chatWidgetMessages.scrollTop = chatWidgetMessages.scrollHeight;
}
        // Keyboard shortcuts
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                closeModal();
            }
        });
    </script>
</body>
</html>