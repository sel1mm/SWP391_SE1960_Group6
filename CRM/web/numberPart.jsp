<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <title>CRM System - Danh sách linh kiện</title>

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

        .content h2 {
            margin: 0 0 30px 0;
            color: #333;
            font-size: 28px;
            font-weight: 600;
        }

        /* Success/Error Messages */
        .alert {
            padding: 14px 20px;
            margin-bottom: 20px;
            border-radius: 8px;
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 10px;
            animation: slideDown 0.3s ease;
        }

        @keyframes slideDown {
            from {
                opacity: 0;
                transform: translateY(-10px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .alert-success {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }

        .alert-error {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }

        /* DETAIL PANEL */
        .detail-panel {
            background: linear-gradient(135deg, #e8f0fe 0%, #f0f4ff 100%);
            border: 2px solid #4285f4;
            border-radius: 8px;
            padding: 25px;
            margin-bottom: 25px;
            box-shadow: 0 2px 8px rgba(66, 133, 244, 0.15);
        }

        .detail-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        .detail-header h3 {
            color: #1967d2;
            font-size: 20px;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .btn-close-detail {
            padding: 8px 20px;
            background: #dc3545;
            color: white;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-weight: 500;
            font-size: 14px;
            transition: all 0.2s;
        }

        .btn-close-detail:hover {
            background: #c82333;
            transform: translateY(-1px);
            box-shadow: 0 2px 6px rgba(220,53,69,0.3);
        }

        .status-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 15px;
            margin-top: 15px;
        }

        .status-card {
            background: white;
            padding: 20px;
            border-radius: 8px;
            border-left: 5px solid;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            transition: all 0.2s;
        }

        .status-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.15);
        }

        .status-card.available { border-left-color: #28a745; }
        .status-card.fault { border-left-color: #ffc107; }
        .status-card.inuse { border-left-color: #17a2b8; }
        .status-card.retired { border-left-color: #6c757d; }

        .status-card h4 {
            font-size: 12px;
            color: #666;
            margin-bottom: 12px;
            text-transform: uppercase;
            letter-spacing: 0.8px;
            font-weight: 600;
        }

        .status-card .count {
            font-size: 32px;
            font-weight: 700;
            color: #333;
            line-height: 1;
        }

        /* Search Filter Container */
        .search-filter-container {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin: 0 0 20px 0;
            background: white;
            padding: 16px 20px;
            border-radius: 8px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            border: 1px solid #e0e0e0;
            flex-wrap: wrap;
            gap: 10px;
        }

        .search-filter-container form {
            display: flex;
            width: 100%;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
        }

        .search-group {
            display: flex;
            gap: 10px;
            align-items: center;
            flex: 1 1 300px;
        }

        .filter-group {
            display: flex;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
        }

        .search-input, .filter-select {
            padding: 9px 14px;
            border: 1px solid #d0d0d0;
            border-radius: 6px;
            font-size: 14px;
            outline: none;
            background: #fafafa;
            transition: all 0.2s;
        }

        .search-input {
            width: 300px;
        }

        .search-input:focus, .filter-select:focus {
            border-color: #999;
            box-shadow: 0 0 0 3px rgba(0,0,0,0.05);
            background: white;
        }

        .btn-search {
            background: #007bff;
            color: white;
            border: none;
            padding: 9px 18px;
            border-radius: 6px;
            cursor: pointer;
            font-weight: 500;
            transition: all 0.2s;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            font-size: 14px;
        }

        .btn-new {
            background: #28a745;
            color: white;
            border: none;
            padding: 9px 18px;
            border-radius: 6px;
            cursor: pointer;
            font-weight: 500;
            transition: all 0.2s;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            font-size: 14px;
        }

        .btn-search:hover {
            background: #0056b3;
            transform: translateY(-1px);
            box-shadow: 0 2px 6px rgba(0,123,255,0.3);
        }

        .btn-new:hover {
            background: #218838;
            transform: translateY(-1px);
            box-shadow: 0 2px 6px rgba(40,167,69,0.3);
        }

        /* Table */
        .inventory-table {
            table-layout: fixed;
            width: 100%;
            margin: 0 0 20px 0;
            border-collapse: collapse;
            background: white;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            border: 1px solid #e0e0e0;
        }

        .inventory-table thead tr th {
            background: #f8f9fa;
            color: #333;
            padding: 12px 16px;
            text-align: left;
            font-weight: 600;
            font-size: 13px;
            border-bottom: 2px solid #dee2e6;
        }

         .inventory-table thead tr th:nth-child(1) { width: 5%; }
        .inventory-table thead tr th:nth-child(2) { width: 12%; }
        .inventory-table thead tr th:nth-child(3) { width: 10%; }
        .inventory-table thead tr th:nth-child(4) { width: 15%; }
        .inventory-table thead tr th:nth-child(5) { width: 8%; }
        .inventory-table thead tr th:nth-child(6) { width: 9%; }
        .inventory-table thead tr th:nth-child(7) { width: 10%; }
        .inventory-table thead tr th:nth-child(8) { width: 31%; }

        .inventory-table tbody td {
            padding: 12px 16px;
            border-bottom: 1px solid #e0e0e0;
            font-size: 13px;
            color: #666;
        }

        .inventory-table tbody tr:hover {
            background-color: #f0f0f0;
        }

        .inventory-table tbody tr:last-child td {
            border-bottom: none;
        }

        .inventory-table tbody td:nth-child(6) {
            font-weight: 600;
            color: #28a745;
        }

        /* ✅ BUTTONS - HORIZONTAL LAYOUT */
        .btn-edit, .btn-delete, .btn-detail {
            color: white;
            border: none;
            padding: 5px 10px;
            border-radius: 4px;
            cursor: pointer;
            transition: all 0.2s ease;
            display: inline-flex;
            align-items: center;
            gap: 4px;
            font-size: 11px;
            font-weight: 500;
        }

        .btn-detail {
            background: #17a2b8;
        }

        .btn-edit {
            background: #007bff;
        }

        .btn-delete {
            background: #dc3545;
        }

        .btn-detail:hover {
            background: #138496;
            transform: translateY(-1px);
            box-shadow: 0 2px 6px rgba(23,162,184,0.3);
        }

        .btn-edit:hover {
            background: #0056b3;
            transform: translateY(-1px);
            box-shadow: 0 2px 6px rgba(0,123,255,0.3);
        }

        .btn-delete:hover {
            background: #c82333;
            transform: translateY(-1px);
            box-shadow: 0 2px 6px rgba(220,53,69,0.3);
        }

        /* ✅ ACTION COLUMN - HORIZONTAL LAYOUT */
        .inventory-table tbody td:nth-child(9) {
            padding: 8px;
        }

        .inventory-table tbody td:nth-child(9) > div {
            display: flex;
            gap: 4px;
            align-items: center;
            justify-content: center;
        }

        /* DELETE CONFIRMATION MODAL */
        .delete-modal {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.6);
            display: none;
            justify-content: center;
            align-items: center;
            z-index: 3000;
            animation: fadeIn 0.2s ease;
        }

        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }

        .delete-modal-content {
            background: white;
            padding: 30px;
            border-radius: 10px;
            width: 450px;
            max-width: 90%;
            box-shadow: 0 8px 30px rgba(0,0,0,0.3);
            text-align: center;
            animation: slideUp 0.3s ease;
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

        .delete-modal-icon {
            font-size: 50px;
            color: #dc3545;
            margin-bottom: 15px;
        }

        .delete-modal h3 {
            color: #333;
            margin-bottom: 10px;
            font-size: 22px;
        }

        .delete-modal p {
            color: #666;
            margin-bottom: 25px;
            font-size: 14px;
            line-height: 1.6;
        }

        .delete-modal-buttons {
            display: flex;
            gap: 10px;
            justify-content: center;
        }

        .btn-confirm-delete, .btn-cancel-delete {
            padding: 10px 25px;
            border: none;
            border-radius: 6px;
            font-weight: 500;
            font-size: 14px;
            cursor: pointer;
            transition: all 0.2s ease;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        .btn-confirm-delete {
            background: #dc3545;
            color: white;
        }

        .btn-confirm-delete:hover {
            background: #c82333;
            transform: translateY(-2px);
            box-shadow: 0 4px 10px rgba(220,53,69,0.4);
        }

        .btn-cancel-delete {
            background: #6c757d;
            color: white;
        }

        .btn-cancel-delete:hover {
            background: #5a6268;
        }

        /* Pagination */
        .pagination {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 8px;
            margin: 20px 0 40px;
        }

        .pagination a {
            padding: 7px 12px;
            border-radius: 6px;
            background: white;
            color: #666;
            text-decoration: none;
            font-weight: 500;
            border: 1px solid #e0e0e0;
            transition: all 0.2s ease;
            font-size: 13px;
        }

        .pagination a:hover {
            background: #f8f9fa;
            border-color: #ccc;
            color: #333;
        }

        .pagination a.active {
            background: #007bff;
            color: white;
            border-color: #007bff;
        }

        /* Form Popup */
        .form-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.5);
            display: none;
            justify-content: center;
            align-items: center;
            z-index: 2000;
        }

        .form-container {
            background: #fff;
            padding: 30px;
            border-radius: 8px;
            width: 450px;
            max-width: 95%;
            box-shadow: 0 4px 20px rgba(0,0,0,0.2);
        }

        #formTitle {
            margin-bottom: 20px;
            font-size: 22px;
            font-weight: 600;
            color: #333;
            text-align: center;
        }

        .form-container label {
            font-weight: 500;
            margin-bottom: 6px;
            margin-top: 12px;
            color: #666;
            display: block;
            font-size: 14px;
        }

        .form-container input[type="text"],
        .form-container input[type="number"],
        .form-container select {
            width: 100%;
            padding: 9px 12px;
            border: 1px solid #d0d0d0;
            border-radius: 6px;
            font-size: 14px;
            outline: none;
            transition: all 0.2s ease;
            background: #fafafa;
        }

        .form-container input:focus,
        .form-container select:focus {
            border-color: #999;
            box-shadow: 0 0 0 3px rgba(0,0,0,0.05);
            background: white;
        }

        #formMessage {
            font-size: 13px;
            color: #dc3545;
            text-align: center;
            min-height: 18px;
            margin-top: 10px;
            font-weight: 500;
        }

        .form-buttons {
            display: flex;
            justify-content: space-between;
            gap: 10px;
            margin-top: 20px;
        }

        .btn-save, .btn-cancel {
            padding: 9px 18px;
            border-radius: 6px;
            font-weight: 500;
            font-size: 14px;
            border: none;
            cursor: pointer;
            transition: all 0.2s ease;
            flex: 1;
        }

        .btn-save {
            background: #28a745;
            color: #fff;
        }

        .btn-save:hover {
            background: #218838;
            transform: translateY(-1px);
            box-shadow: 0 2px 6px rgba(40,167,69,0.3);
        }

        .btn-cancel {
            background: #6c757d;
            color: #fff;
        }

        .btn-cancel:hover {
            background: #5a6268;
            transform: translateY(-1px);
            box-shadow: 0 2px 6px rgba(108,117,125,0.3);
        }

        /* RESPONSIVE */
        @media (max-width: 900px) {
            .content {
                padding: 20px;
                margin-left: 0;
                width: 100%;
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
            .search-input {
                width: 100%;
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
            <a href="numberPart" class="active"><i class="fas fa-list"></i><span>Danh sách linh kiện</span></a>
            <a href="numberEquipment"><i class="fas fa-list"></i><span>Danh sách thiết bị</span></a>
            <a href="PartDetailHistoryServlet"><i class="fas fa-history"></i><span>Lịch sử giao dịch</span></a>
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
            <h2>Danh sách linh kiện</h2>

            <!-- Success/Error Messages -->
            <c:if test="${not empty sessionScope.successMessage}">
                <div class="alert alert-success">
                    <i class="fas fa-check-circle"></i>
                    ${sessionScope.successMessage}
                </div>
                <c:remove var="successMessage" scope="session"/>
            </c:if>

            <c:if test="${not empty sessionScope.errorMessage}">
                <div class="alert alert-error">
                    <i class="fas fa-exclamation-circle"></i>
                    ${sessionScope.errorMessage}
                </div>
                <c:remove var="errorMessage" scope="session"/>
            </c:if>

            <!-- DETAIL PANEL -->
            <c:if test="${showDetail && selectedPart != null}">
                <div class="detail-panel">
                    <div class="detail-header">
                        <h3>
                            <i class="fas fa-chart-pie"></i> 
                            Chi tiết trạng thái: ${selectedPart.partName}
                        </h3>
                        <form action="numberPart" method="get" style="display: inline;">
                            <button type="submit" class="btn-close-detail">
                                <i class="fas fa-times"></i> Đóng
                            </button>
                        </form>
                    </div>
                    
                    <div class="status-grid">
                        <div class="status-card available">
                            <h4><i class="fas fa-check-circle"></i> Available (Sẵn sàng)</h4>
                            <div class="count">${statusCount['Available']}</div>
                        </div>
                        
                        <div class="status-card fault">
                            <h4><i class="fas fa-exclamation-triangle"></i> Faulty (Lỗi)</h4>
                            <div class="count">${statusCount['Faulty']}</div>
                        </div>
                        
                        <div class="status-card inuse">
                            <h4><i class="fas fa-tools"></i> InUse (Đang dùng)</h4>
                            <div class="count">${statusCount['InUse']}</div>
                        </div>
                        
                        <div class="status-card retired">
                            <h4><i class="fas fa-archive"></i> Retired (Ngừng dùng)</h4>
                            <div class="count">${statusCount['Retired']}</div>
                        </div>
                    </div>
                </div>
            </c:if>

            <!-- Search & Filter -->
            <div class="search-filter-container">
                <form action="numberPart" method="POST">
                    <div class="search-group">
                        <input type="text" placeholder="Nhập từ khoá..." name="keyword"
                               value="${param.keyword}" class="search-input"/>
                        <button type="submit" class="btn-search"> 
                            <i class="fas fa-search"></i> Search
                        </button>
                    </div>

                    <div class="filter-group">
                        <select name="categoryFilter" class="filter-select" onchange="this.form.submit()">
                            <option value="">-- All Categories --</option>
                            <c:forEach items="${categories}" var="cat">
                                <option value="${cat.categoryId}" ${param.categoryFilter == cat.categoryId ? 'selected' : ''}>
                                    ${cat.categoryName}
                                </option>
                            </c:forEach>
                        </select>
                        
                        <select name="filter" class="filter-select" onchange="this.form.submit()">
                            <option value="">-- Sort by --</option>
                            <option value="partId" ${param.filter == 'partId' ? 'selected' : ''}>By Part ID</option>
                            <option value="partName" ${param.filter == 'partName' ? 'selected' : ''}>By Part Name</option>
                            <option value="category" ${param.filter == 'category' ? 'selected' : ''}>By Category</option>

                            <option value="unitPrice" ${param.filter == 'unitPrice' ? 'selected' : ''}>By Unit Price</option>
                            <option value="updatePerson" ${param.filter == 'updatePerson' ? 'selected' : ''}>By Update Person</option>
                            <option value="updateDate" ${param.filter == 'updateDate' ? 'selected' : ''}>By Update Date</option>
                        </select>

                        <button type="button" class="btn-new" onclick="openForm('new')">
                            <i class="fas fa-plus"></i> New Part
                        </button>
                    </div>
                </form>
            </div>

            <!-- Table -->
            <table class="inventory-table">
                <thead>
                    <tr>
                        <th>Part ID</th>
                        <th>Part Name</th>
                        <th>Category</th>
                        <th>Description</th>
                        <th>Unit Price</th>
                       
                        <th>Last Updated By</th>
                        <th>Last Update Time</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${list}" var="ls">
                        <tr>
                            <td>${ls.partId}</td>
                            <td>${ls.partName}</td>
                            <td>${ls.categoryName != null ? ls.categoryName : 'N/A'}</td>
                            <td>${ls.description}</td>
                            <td><fmt:formatNumber value="${ls.unitPrice * 26000}" type="number" maxFractionDigits="0" groupingUsed="true"/> ₫</td>
                            <td>${ls.userName}</td>
                            <td>${ls.lastUpdatedDate}</td>
                            <td>
                                <div style="display: flex; gap: 8px; align-items: center;">
                                    <form action="numberPart" method="post" style="margin: 0; display: inline;">
                                        <input type="hidden" name="action" value="detail">
                                        <input type="hidden" name="partId" value="${ls.partId}">
                                        <button type="submit" class="btn-detail">
                                            <i class="fas fa-info-circle"></i> Detail
                                        </button>
                                    </form>
                                    
                                    <button type="button" class="btn-edit"
                                            onclick="openForm('edit',
                                                            '${ls.partId}',
                                                            '${ls.partName}',
                                                            '${ls.description}',
                                                            '${ls.unitPrice}',
                                                            '${ls.categoryId}')">
                                        <i class="fas fa-edit"></i> Edit
                                    </button>
                                    
                                    <button type="button" class="btn-delete"
                                            onclick="showDeleteModal('${ls.partId}', '${ls.partName}')">
                                        <i class="fas fa-trash"></i> Delete
                                    </button>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>

            <!-- DELETE CONFIRMATION MODAL -->
            <div class="delete-modal" id="deleteModal">
                <div class="delete-modal-content">
                    <div class="delete-modal-icon">
                        <i class="fas fa-exclamation-triangle"></i>
                    </div>
                    <h3>Xác nhận xóa</h3>
                    <p id="deleteModalMessage">Bạn có chắc muốn xóa part này?</p>
                    <div class="delete-modal-buttons">
                        <button type="button" class="btn-confirm-delete" onclick="confirmDeleteAction()">
                            <i class="fas fa-check"></i> Xác nhận
                        </button>
                        <button type="button" class="btn-cancel-delete" onclick="closeDeleteModal()">
                            <i class="fas fa-times"></i> Hủy
                        </button>
                    </div>
                </div>
            </div>

            <!-- Form Popup -->
            <div class="form-overlay" id="formOverlay">
                <div class="form-container">
                    <h2 id="formTitle">Add New Part</h2>
                    <form action="numberPart" method="POST" id="partForm" onsubmit="return validateForm()">
                        <input type="hidden" name="action" id="actionInput" value="add">
                        <input type="hidden" name="partId" id="partId">

                        <label>Part Name * (Tối thiểu 3 ký tự)</label>
                        <input type="text" name="partName" id="partName" required 
                               minlength="3" maxlength="30"
                               placeholder="Nhập tên part (ít nhất 3 ký tự)">

                        <label>Category</label>
                        <select name="categoryId" id="categoryId" class="filter-select" style="width: 100%; background: #fafafa;">
                            <option value="">-- Select Category --</option>
                            <c:forEach items="${categories}" var="cat">
                                <option value="${cat.categoryId}">${cat.categoryName}</option>
                            </c:forEach>
                        </select>

                        <label>Description * (10-100 ký tự)</label>
                        <input type="text" name="description" id="partDescription" required 
                               minlength="10" maxlength="100"
                               placeholder="Nhập mô tả (10-100 ký tự)">

                        <label>Unit Price *</label>
                        <input type="number" name="unitPrice" id="partPrice" 
                               step="0.01" required min="0.01" max="9999999.99"
                               placeholder="Nhập giá (0 < giá < 10,000,000)">

                        <p id="formMessage"></p>

                        <div class="form-buttons">
                            <button type="submit" class="btn-save">
                                <i class="fas fa-save"></i> Save
                            </button>
                            <button type="button" class="btn-cancel" onclick="closeForm()">
                                <i class="fas fa-times"></i> Cancel
                            </button>
                        </div>
                    </form>
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
            <!-- Pagination -->
            <div class="pagination">
                <a href="#">« First</a>
                <a href="#">‹ Prev</a>
                <a href="#" class="active">1</a>
                <a href="#">2</a>
                <a href="#">3</a>
                <a href="#">Next ›</a>
                <a href="#">Last »</a>
            </div>
        </div>
    </div>

    <script>
        let deletePartId = null;

        // ✅ SHOW DELETE MODAL - FIXED TO AVOID LOCALHOST
        function showDeleteModal(partId, partName) {
            const id = String(partId);
            const name = String(partName);
            
            deletePartId = partId;
            
            const modal = document.getElementById("deleteModal");
            const message = document.getElementById("deleteModalMessage");
            
            // Use string concatenation instead of template literals
            const newHTML = "Bạn có chắc muốn xóa Part:<br><strong>" + name + "</strong> (ID: " + id + ")?";
            
            message.innerHTML = newHTML;
            modal.style.display = "flex";
        }

        // CLOSE DELETE MODAL
        function closeDeleteModal() {
            document.getElementById("deleteModal").style.display = "none";
            deletePartId = null;
        }

        // CONFIRM DELETE ACTION
        function confirmDeleteAction() {
            if (deletePartId) {
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = 'numberPart';

                const actionInput = document.createElement('input');
                actionInput.type = 'hidden';
                actionInput.name = 'action';
                actionInput.value = 'delete';

                const idInput = document.createElement('input');
                idInput.type = 'hidden';
                idInput.name = 'partId';
                idInput.value = deletePartId;

                form.appendChild(actionInput);
                form.appendChild(idInput);
                document.body.appendChild(form);
                form.submit();
            }
        }

        function openForm(mode, partId = '', partName = '', description = '', unitPrice = '', categoryId = '') {
            const overlay = document.getElementById("formOverlay");
            const title = document.getElementById("formTitle");
            const actionInput = document.getElementById("actionInput");
            const formMessage = document.getElementById("formMessage");

            overlay.style.display = "flex";
            formMessage.textContent = "";
            formMessage.style.color = "#dc3545";

            if (mode === "new") {
                title.textContent = "Add New Part";
                actionInput.value = "add";
                document.getElementById("partId").value = "";
                document.getElementById("partName").value = "";
                document.getElementById("categoryId").value = "";
                document.getElementById("partDescription").value = "";
                document.getElementById("partPrice").value = "";
            } else {
                title.textContent = "Edit Part";
                actionInput.value = "edit";
                document.getElementById("partId").value = partId;
                document.getElementById("partName").value = partName;
                document.getElementById("categoryId").value = categoryId;
                document.getElementById("partDescription").value = description;
                document.getElementById("partPrice").value = unitPrice;
            }
        }

        function closeForm() {
            document.getElementById("formOverlay").style.display = "none";
            document.getElementById("formMessage").textContent = "";
        }

        function validateForm() {
            const partName = document.getElementById("partName").value.trim();
            const description = document.getElementById("partDescription").value.trim();
            const unitPrice = parseFloat(document.getElementById("partPrice").value);
            const formMessage = document.getElementById("formMessage");
            
            formMessage.textContent = "";
            formMessage.style.color = "#dc3545";
            
            if (partName.length < 3) {
                formMessage.textContent = "❌ Tên Part phải có ít nhất 3 ký tự!";
                return false;
            }
            
            if (partName.length > 30) {
                formMessage.textContent = "❌ Tên Part không được vượt quá 30 ký tự!";
                return false;
            }
            
            if (description.length < 10) {
                formMessage.textContent = "❌ Mô tả phải có ít nhất 10 ký tự!";
                return false;
            }
            
            if (description.length > 100) {
                formMessage.textContent = "❌ Mô tả không được vượt quá 100 ký tự!";
                return false;
            }
            
            if (isNaN(unitPrice) || unitPrice <= 0 || unitPrice >= 10000000) {
                formMessage.textContent = "❌ Giá phải lớn hơn 0 và nhỏ hơn 10,000,000!";
                return false;
            }
            
            return true;
        }

        let currentPage = 1;
        const rowsPerPage = 10;

        function renderTable() {
            const tableBody = document.querySelector(".inventory-table tbody");
            if (!tableBody) return;

            const keyword = document.querySelector(".search-input").value.toLowerCase();
            const rows = Array.from(tableBody.rows);

            const filteredRows = rows.filter(row => {
                return Array.from(row.cells).slice(0, 8)
                        .some(td => td.innerText.toLowerCase().includes(keyword));
            });

            const totalPages = Math.ceil(filteredRows.length / rowsPerPage);
            if (filteredRows.length === 0) {
                rows.forEach(row => row.style.display = "none");
                return;
            }

            if (currentPage > totalPages) currentPage = totalPages;
            if (currentPage < 1) currentPage = 1;

            rows.forEach(row => row.style.display = "none");
            const start = (currentPage - 1) * rowsPerPage;
            const end = start + rowsPerPage;
            filteredRows.slice(start, end).forEach(row => row.style.display = "");

            renderPagination(totalPages);
        }

        function renderPagination(totalPages) {
            const pagination = document.querySelector(".pagination");
            if (!pagination) return;
            pagination.innerHTML = "";

            function createBtn(text, onClick, active = false) {
                const btn = document.createElement("a");
                btn.href = "#";
                btn.textContent = text;
                if (active) btn.classList.add("active");
                btn.onclick = e => {
                    e.preventDefault();
                    onClick();
                };
                return btn;
            }

            pagination.appendChild(createBtn("« First", () => {
                currentPage = 1;
                renderTable();
            }));
            
            pagination.appendChild(createBtn("‹ Prev", () => {
                if (currentPage > 1) {
                    currentPage--;
                    renderTable();
                }
            }));

            let start = Math.max(currentPage - 2, 1);
            let end = Math.min(start + 4, totalPages);
            for (let i = start; i <= end; i++) {
                pagination.appendChild(createBtn(i, () => {
                    currentPage = i;
                    renderTable();
                }, i === currentPage));
            }

            pagination.appendChild(createBtn("Next ›", () => {
                if (currentPage < totalPages) {
                    currentPage++;
                    renderTable();
                }
            }));
            
            pagination.appendChild(createBtn("Last »", () => {
                currentPage = totalPages;
                renderTable();
            }));
        }

        document.addEventListener("DOMContentLoaded", function() {
            renderTable();

            const searchInput = document.querySelector(".search-input");
            if (searchInput) {
                searchInput.addEventListener("input", () => {
                    currentPage = 1;
                    renderTable();
                });
            }

            const formOverlay = document.getElementById("formOverlay");
            if (formOverlay) {
                formOverlay.addEventListener('click', function (e) {
                    if (e.target === this) {
                        closeForm();
                    }
                });
            }

            const deleteModal = document.getElementById("deleteModal");
            if (deleteModal) {
                deleteModal.addEventListener('click', function (e) {
                    if (e.target === this) {
                        closeDeleteModal();
                    }
                });
            }

            // ESC key to close modals
            document.addEventListener('keydown', function(e) {
                if (e.key === 'Escape') {
                    closeForm();
                    closeDeleteModal();
                }
            });

            const partNameInput = document.getElementById("partName");
            if (partNameInput) {
                partNameInput.addEventListener("input", function() {
                    const length = this.value.length;
                    const formMessage = document.getElementById("formMessage");
                    
                    if (length === 0) {
                        formMessage.textContent = "";
                    } else if (length < 3) {
                        formMessage.textContent = "⚠️ Tên Part: Còn thiếu " + (3 - length) + " ký tự";
                        formMessage.style.color = "#ff9800";
                    } else if (length > 30) {
                        formMessage.textContent = "❌ Tên Part: Vượt quá " + (length - 30) + " ký tự";
                        formMessage.style.color = "#dc3545";
                    } else {
                        formMessage.textContent = "✓ Tên Part: " + length + "/30 ký tự";
                        formMessage.style.color = "#28a745";
                    }
                });
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

            const descriptionInput = document.getElementById("partDescription");
            if (descriptionInput) {
                descriptionInput.addEventListener("input", function() {
                    const length = this.value.length;
                    const formMessage = document.getElementById("formMessage");
                    
                    if (length === 0) {
                        formMessage.textContent = "";
                    } else if (length < 10) {
                        formMessage.textContent = "⚠️ Mô tả: Còn thiếu " + (10 - length) + " ký tự";
                        formMessage.style.color = "#ff9800";
                    } else if (length > 100) {
                        formMessage.textContent = "❌ Mô tả: Vượt quá " + (length - 100) + " ký tự";
                        formMessage.style.color = "#dc3545";
                    } else {
                        formMessage.textContent = "✓ Mô tả: " + length + "/100 ký tự";
                        formMessage.style.color = "#28a745";
                    }
                });
            }

            // Auto-hide alerts after 5 seconds
            const alerts = document.querySelectorAll('.alert');
            alerts.forEach(alert => {
                setTimeout(() => {
                    alert.style.transition = 'opacity 0.5s ease';
                    alert.style.opacity = '0';
                    setTimeout(() => alert.remove(), 500);
                }, 5000);
            });
        });
    </script>
</body>
</html>