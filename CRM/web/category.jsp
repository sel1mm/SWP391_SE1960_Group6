<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <title>CRM System - Quản lý danh mục</title>

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
            font-size: 28px;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .btn-add-new {
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

        .btn-add-new:hover {
            background: #218838;
            transform: translateY(-1px);
            box-shadow: 0 2px 6px rgba(40,167,69,0.3);
        }

        /* FILTER & SORT SECTION */
        .sort-section {
            background: white;
            padding: 16px 20px;
            border-radius: 8px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            margin-bottom: 24px;
            border: 1px solid #e0e0e0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .sort-group {
            display: flex;
            gap: 12px;
            align-items: center;
        }

        .sort-group label {
            font-weight: 600;
            color: #666;
            font-size: 14px;
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .sort-select {
            padding: 9px 36px 9px 14px;
            border: 1px solid #d0d0d0;
            border-radius: 6px;
            font-size: 14px;
            outline: none;
            background: #fafafa;
            transition: all 0.2s;
            cursor: pointer;
            min-width: 200px;
            appearance: none;
            background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 12 12'%3E%3Cpath fill='%23333' d='M6 9L1 4h10z'/%3E%3C/svg%3E");
            background-repeat: no-repeat;
            background-position: right 12px center;
        }

        .sort-select:focus {
            border-color: #999;
            box-shadow: 0 0 0 3px rgba(0,0,0,0.05);
            background-color: white;
        }

        .total-count {
            color: #666;
            font-size: 14px;
            font-weight: 500;
        }

        .total-count strong {
            color: #007bff;
            font-size: 16px;
        }

        /* TABLE */
        .table-container {
            background: white;
            border-radius: 8px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            overflow: hidden;
            border: 1px solid #e0e0e0;
        }

        .category-table {
            width: 100%;
            border-collapse: collapse;
        }

        .category-table thead {
            background: #f8f9fa;
            border-bottom: 2px solid #dee2e6;
        }

        .category-table thead th {
            padding: 12px 16px;
            text-align: left;
            font-weight: 600;
            font-size: 13px;
            color: #333;
        }

        .category-table tbody td {
            padding: 12px 16px;
            border-bottom: 1px solid #e0e0e0;
            font-size: 13px;
            color: #666;
        }

        .category-table tbody tr {
            transition: all 0.2s;
        }

        .category-table tbody tr:hover {
            background: #f0f0f0;
        }

        .category-table tbody tr:last-child td {
            border-bottom: none;
        }

        .type-badge {
            display: inline-block;
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .type-badge.part {
            background: #dbeafe;
            color: #1e40af;
        }

        .type-badge.equipment {
            background: #fce7f3;
            color: #9f1239;
        }

        .action-buttons {
            display: flex;
            gap: 8px;
        }

        .btn-icon {
            border: none;
            padding: 8px 14px;
            border-radius: 6px;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 6px;
            transition: all 0.2s;
            font-size: 13px;
            font-weight: 500;
            color: white;
        }

        .btn-edit {
            background: #007bff;
        }

        .btn-edit:hover {
            background: #0056b3;
            transform: translateY(-1px);
            box-shadow: 0 2px 6px rgba(0,123,255,0.3);
        }

        .btn-delete {
            background: #dc3545;
        }

        .btn-delete:hover {
            background: #c82333;
            transform: translateY(-1px);
            box-shadow: 0 2px 6px rgba(220,53,69,0.3);
        }

        /* PAGINATION */
        .pagination-container {
            background: white;
            padding: 16px 20px;
            border-radius: 8px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            margin-top: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border: 1px solid #e0e0e0;
        }

        .pagination-info {
            color: #666;
            font-size: 14px;
        }

        .pagination {
            display: flex;
            gap: 6px;
            align-items: center;
        }

        .pagination a, .pagination span {
            padding: 8px 14px;
            border: 1px solid #d0d0d0;
            border-radius: 6px;
            text-decoration: none;
            color: #333;
            font-size: 14px;
            transition: all 0.2s;
            min-width: 40px;
            text-align: center;
        }

        .pagination a:hover {
            background: #f0f0f0;
            border-color: #999;
        }

        .pagination .active {
            background: #007bff;
            color: white;
            border-color: #007bff;
            font-weight: 600;
        }

        .pagination .disabled {
            opacity: 0.5;
            cursor: not-allowed;
            pointer-events: none;
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

        /* MODAL FORM */
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
            z-index: 2000;
        }

        .modal-overlay.show {
            display: flex;
        }

        .modal-container {
            background: white;
            border-radius: 8px;
            width: 480px;
            max-width: 95%;
            box-shadow: 0 4px 20px rgba(0,0,0,0.2);
        }

        .modal-header {
            padding: 20px 24px;
            border-bottom: 1px solid #e0e0e0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .modal-header h3 {
            font-size: 20px;
            font-weight: 600;
            color: #333;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .modal-close {
            background: #f3f4f6;
            border: none;
            width: 32px;
            height: 32px;
            border-radius: 6px;
            cursor: pointer;
            font-size: 18px;
            color: #666;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.2s;
        }

        .modal-close:hover {
            background: #e5e7eb;
            color: #333;
        }

        .modal-body {
            padding: 24px;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-group label {
            display: block;
            font-weight: 500;
            color: #666;
            margin-bottom: 8px;
            font-size: 14px;
        }

        .form-group label .required {
            color: #dc3545;
        }

        .form-group input,
        .form-group select {
            width: 100%;
            padding: 9px 12px;
            border: 1px solid #d0d0d0;
            border-radius: 6px;
            font-size: 14px;
            outline: none;
            transition: all 0.2s;
            background: #fafafa;
        }

        .form-group input:focus,
        .form-group select:focus {
            border-color: #999;
            box-shadow: 0 0 0 3px rgba(0,0,0,0.05);
            background: white;
        }

        .form-message {
            font-size: 13px;
            margin-top: 12px;
            text-align: center;
            min-height: 20px;
            font-weight: 500;
        }

        .modal-footer {
            padding: 16px 24px;
            background: #f8f9fa;
            border-top: 1px solid #e0e0e0;
            border-radius: 0 0 8px 8px;
            display: flex;
            justify-content: flex-end;
            gap: 10px;
        }

        .btn-modal {
            padding: 9px 18px;
            border-radius: 6px;
            border: none;
            font-weight: 500;
            font-size: 14px;
            cursor: pointer;
            transition: all 0.2s;
        }

        .btn-save {
            background: #28a745;
            color: white;
        }

        .btn-save:hover {
            background: #218838;
            transform: translateY(-1px);
            box-shadow: 0 2px 6px rgba(40,167,69,0.3);
        }

        .btn-cancel {
            background: #6c757d;
            color: white;
        }

        .btn-cancel:hover {
            background: #5a6268;
        }

        .no-data {
            text-align: center;
            padding: 60px 20px;
            color: #999;
        }

        .no-data i {
            font-size: 64px;
            margin-bottom: 16px;
            display: block;
            opacity: 0.5;
        }

        .no-data p {
            font-size: 16px;
            font-weight: 500;
        }

        .alert {
            padding: 12px 16px;
            border-radius: 6px;
            margin-bottom: 20px;
            font-size: 14px;
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 10px;
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
            .page-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 16px;
            }
            .sort-section {
                flex-direction: column;
                gap: 12px;
                align-items: stretch;
            }
            .pagination-container {
                flex-direction: column;
                gap: 12px;
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
    <div class="sidebar">
        <div class="sidebar-logo">CRM System</div>
        <div class="sidebar-menu">
            <a href="statistic"><i class="fas fa-home"></i><span>Trang chủ</span></a>
            <a href="manageProfile"><i class="fas fa-user-circle"></i><span>Hồ Sơ</span></a>
            <a href="storekeeper"><i class="fas fa-chart-line"></i><span>Thống kê</span></a>
            <a href="numberPart"><i class="fas fa-list"></i><span>Danh sách linh kiện</span></a>
            <a href="numberEquipment"><i class="fas fa-list"></i><span>Danh sách thiết bị</span></a>
            <a href="PartDetailHistoryServlet"><i class="fas fa-history"></i><span>Lịch sử giao dịch</span></a>
            <a href="partDetail"><i class="fas fa-truck-loading"></i><span>Chi tiết linh kiện</span></a>
            <a href="category" class="active"><i class="fas fa-tags"></i><span>Quản lý danh mục</span></a>
        </div>
        <a href="logout" class="logout-btn">
            <i class="fas fa-sign-out-alt"></i><span>Đăng xuất</span>
        </a>
    </div>

    <nav class="navbar">
        <div class="user-info">
            Xin chào ${sessionScope.username}
        </div>
    </nav>

    <div class="container">
        <div class="content">
            <div class="page-header">
                <h2><i class="fas fa-tags"></i> Quản lý danh mục</h2>
                <button class="btn-add-new" onclick="openModal('add')">
                    <i class="fas fa-plus"></i> Add New Category
                </button>
            </div>

            <c:if test="${not empty sessionScope.successMessage}">
                <div class="alert alert-success">
                    <i class="fas fa-check-circle"></i>
                    ${sessionScope.successMessage}
                </div>
            </c:if>
            
            <c:if test="${not empty sessionScope.errorMessage}">
                <div class="alert alert-error">
                    <i class="fas fa-exclamation-circle"></i>
                    ${sessionScope.errorMessage}
                </div>
            </c:if>

            <!-- Filter & Sort Section -->
            <div class="sort-section">
                <div class="sort-group">
                    <label><i class="fas fa-filter"></i> Type:</label>
                    <select class="sort-select" id="typeFilter" style="min-width: 150px;">
                        <option value="">All Types</option>
                        <option value="Part" ${typeFilter == 'Part' ? 'selected' : ''}>Part</option>
                        <option value="Equipment" ${typeFilter == 'Equipment' ? 'selected' : ''}>Equipment</option>
                    </select>
                    
                    <label style="margin-left: 20px;"><i class="fas fa-sort"></i> Sort by:</label>
                    <select class="sort-select" id="sortBy">
                        <option value="id-asc" ${sortBy == 'id-asc' ? 'selected' : ''}>ID (Ascending)</option>
                        <option value="id-desc" ${sortBy == 'id-desc' ? 'selected' : ''}>ID (Descending)</option>
                        <option value="name-asc" ${sortBy == 'name-asc' ? 'selected' : ''}>Name (Ascending)</option>
                        <option value="name-desc" ${sortBy == 'name-desc' ? 'selected' : ''}>Name (Descending)</option>
                    </select>
                </div>
                <div class="total-count">
                    Total: <strong>${totalRecords}</strong> categories
                </div>
            </div>

            <!-- Table -->
            <div class="table-container">
                <table class="category-table">
                    <thead>
                        <tr>
                            <th style="width: 10%;">ID</th>
                            <th style="width: 40%;">Category Name</th>
                            <th style="width: 25%;">Type</th>
                            <th style="width: 25%;">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty categoryList}">
                                <c:forEach items="${categoryList}" var="cat">
                                    <tr>
                                        <td>${cat.categoryId}</td>
                                        <td><strong>${cat.categoryName}</strong></td>
                                        <td>
                                            <span class="type-badge ${cat.type.toLowerCase()}">
                                                ${cat.type}
                                            </span>
                                        </td>
                                        <td>
                                            <div class="action-buttons">
                                                <button class="btn-icon btn-edit" 
                                                        data-id="${cat.categoryId}"
                                                        data-name="${cat.categoryName}"
                                                        data-type="${cat.type}"
                                                        title="Edit Category">
                                                    <i class="fas fa-edit"></i> Edit
                                                </button>
                                                <button class="btn-icon btn-delete" 
                                                        data-id="${cat.categoryId}"
                                                        data-name="${cat.categoryName}"
                                                        title="Delete Category">
                                                    <i class="fas fa-trash"></i> Delete
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="4">
                                        <div class="no-data">
                                            <i class="fas fa-inbox"></i>
                                            <p>No categories found</p>
                                        </div>
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>

            <!-- Pagination -->
            <c:if test="${totalPages > 1}">
                <div class="pagination-container">
                    <div class="pagination-info">
                        Showing page <strong>${currentPage}</strong> of <strong>${totalPages}</strong>
                    </div>
                    
                    <div class="pagination">
                        <c:if test="${currentPage > 1}">
                            <a href="?page=1&sortBy=${sortBy}&typeFilter=${typeFilter}">
                                <i class="fas fa-angle-double-left"></i>
                            </a>
                        </c:if>
                        <c:if test="${currentPage == 1}">
                            <span class="disabled">
                                <i class="fas fa-angle-double-left"></i>
                            </span>
                        </c:if>
                        
                        <c:if test="${currentPage > 1}">
                            <a href="?page=${currentPage - 1}&sortBy=${sortBy}&typeFilter=${typeFilter}">
                                <i class="fas fa-angle-left"></i>
                            </a>
                        </c:if>
                        <c:if test="${currentPage == 1}">
                            <span class="disabled">
                                <i class="fas fa-angle-left"></i>
                            </span>
                        </c:if>
                        
                        <c:forEach begin="1" end="${totalPages}" var="i">
                            <c:if test="${i >= currentPage - 2 && i <= currentPage + 2}">
                                <c:choose>
                                    <c:when test="${i == currentPage}">
                                        <span class="active">${i}</span>
                                    </c:when>
                                    <c:otherwise>
                                        <a href="?page=${i}&sortBy=${sortBy}&typeFilter=${typeFilter}">${i}</a>
                                    </c:otherwise>
                                </c:choose>
                            </c:if>
                        </c:forEach>
                        
                        <c:if test="${currentPage < totalPages}">
                            <a href="?page=${currentPage + 1}&sortBy=${sortBy}&typeFilter=${typeFilter}">
                                <i class="fas fa-angle-right"></i>
                            </a>
                        </c:if>
                        <c:if test="${currentPage == totalPages}">
                            <span class="disabled">
                                <i class="fas fa-angle-right"></i>
                            </span>
                        </c:if>
                        
                        <c:if test="${currentPage < totalPages}">
                            <a href="?page=${totalPages}&sortBy=${sortBy}&typeFilter=${typeFilter}">
                                <i class="fas fa-angle-double-right"></i>
                            </a>
                        </c:if>
                        <c:if test="${currentPage == totalPages}">
                            <span class="disabled">
                                <i class="fas fa-angle-double-right"></i>
                            </span>
                        </c:if>
                    </div>
                </div>
            </c:if>
        </div>
    </div>

    <!-- DELETE CONFIRMATION MODAL -->
    <div class="delete-modal" id="deleteModal">
        <div class="delete-modal-content">
            <div class="delete-modal-icon">
                <i class="fas fa-exclamation-triangle"></i>
            </div>
            <h3>Xác nhận xóa</h3>
            <p id="deleteModalMessage">Bạn có chắc muốn xóa category này?</p>
            <small style="color: #999; display: block; margin-bottom: 20px;">
                <i class="fas fa-info-circle"></i> Lưu ý: Xóa sẽ thất bại nếu có Parts/Equipments đang sử dụng category này.
            </small>
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

    <!-- Modal Form -->
    <div class="modal-overlay" id="categoryModal">
        <div class="modal-container">
            <div class="modal-header">
                <h3 id="modalTitle"><i class="fas fa-plus-circle"></i> Add New Category</h3>
                <button class="modal-close" onclick="closeModal()">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            <form action="category" method="POST" id="categoryForm" onsubmit="return validateForm()">
                <input type="hidden" name="action" id="formAction" value="add">
                <input type="hidden" name="categoryId" id="categoryId">
                
                <div class="modal-body">
                    <div class="form-group">
                        <label>Category Name <span class="required">*</span></label>
                        <input type="text" name="categoryName" id="categoryName" 
                               required minlength="3" maxlength="50"
                               placeholder="Enter category name">
                    </div>

                    <div class="form-group">
                        <label>Type <span class="required">*</span></label>
                        <select name="type" id="categoryType" required>
                            <option value="">-- Select Type --</option>
                            <option value="Part">Part</option>
                            <option value="Equipment">Equipment</option>
                        </select>
                    </div>

                    <div class="form-message" id="formMessage"></div>
                </div>

                <div class="modal-footer">
                    <button type="button" class="btn-modal btn-cancel" onclick="closeModal()">
                        <i class="fas fa-times"></i> Cancel
                    </button>
                    <button type="submit" class="btn-modal btn-save">
                        <i class="fas fa-save"></i> Save
                    </button>
                </div>
            </form>
        </div>
    </div>



    <script>
        let deleteCategoryId = null;
        let deleteCategoryName = '';

        // SHOW DELETE MODAL
       // SHOW DELETE MODAL - FIXED
function showDeleteModal(categoryId, categoryName) {
    const id = String(categoryId);
    const name = String(categoryName);
    
    deleteCategoryId = categoryId;
    deleteCategoryName = categoryName;
    
    const modal = document.getElementById("deleteModal");
    const message = document.getElementById("deleteModalMessage");
    
    // Dùng nối chuỗi thay vì template literal
    message.innerHTML = 'Bạn có chắc muốn xóa category:<br><strong>"' + name + '"</strong> (ID: ' + id + ')?';
    
    modal.style.display = "flex";
}

        // CLOSE DELETE MODAL
        function closeDeleteModal() {
            document.getElementById("deleteModal").style.display = "none";
            deleteCategoryId = null;
            deleteCategoryName = '';
        }

        // CONFIRM DELETE ACTION
        function confirmDeleteAction() {
            if (deleteCategoryId) {
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = 'category';

                const actionInput = document.createElement('input');
                actionInput.type = 'hidden';
                actionInput.name = 'action';
                actionInput.value = 'delete';

                const idInput = document.createElement('input');
                idInput.type = 'hidden';
                idInput.name = 'categoryId';
                idInput.value = deleteCategoryId;

                form.appendChild(actionInput);
                form.appendChild(idInput);
                document.body.appendChild(form);
                form.submit();
            }
        }

        function openModal(mode, categoryId = '', categoryName = '', type = '') {
            const modal = document.getElementById('categoryModal');
            const modalTitle = document.getElementById('modalTitle');
            const formAction = document.getElementById('formAction');
            const formMessage = document.getElementById('formMessage');
            
            formMessage.textContent = '';
            formMessage.style.color = '#dc3545';
            
            if (mode === 'add') {
                modalTitle.innerHTML = '<i class="fas fa-plus-circle"></i> Add New Category';
                formAction.value = 'add';
                document.getElementById('categoryId').value = '';
                document.getElementById('categoryName').value = '';
                document.getElementById('categoryType').value = '';
            } else {
                modalTitle.innerHTML = '<i class="fas fa-edit"></i> Edit Category';
                formAction.value = 'edit';
                document.getElementById('categoryId').value = categoryId;
                document.getElementById('categoryName').value = categoryName;
                document.getElementById('categoryType').value = type;
            }
            
            modal.classList.add('show');
            document.body.style.overflow = 'hidden';
        }

        function closeModal() {
            const modal = document.getElementById('categoryModal');
            modal.classList.remove('show');
            document.body.style.overflow = 'auto';
            document.getElementById('formMessage').textContent = '';
        }

        function validateForm() {
            const categoryName = document.getElementById('categoryName').value.trim();
            const type = document.getElementById('categoryType').value;
            const formMessage = document.getElementById('formMessage');
            
            formMessage.textContent = '';
            
            if (categoryName.length < 3) {
                formMessage.textContent = '❌ Category name must be at least 3 characters!';
                return false;
            }
            
            if (categoryName.length > 50) {
                formMessage.textContent = '❌ Category name cannot exceed 50 characters!';
                return false;
            }
            
            if (!type) {
                formMessage.textContent = '❌ Please select a type!';
                return false;
            }
            
            return true;
        }

        function applyFilters() {
            const typeFilter = document.getElementById('typeFilter').value;
            const sortBy = document.getElementById('sortBy').value;
            window.location.href = 'category?typeFilter=' + typeFilter + '&sortBy=' + sortBy;
        }

        document.addEventListener('DOMContentLoaded', function() {
            // Apply filters on change
            document.getElementById('typeFilter').addEventListener('change', applyFilters);
            document.getElementById('sortBy').addEventListener('change', applyFilters);

            document.querySelectorAll('.btn-edit').forEach(function(button) {
                button.addEventListener('click', function() {
                    const id = this.getAttribute('data-id');
                    const name = this.getAttribute('data-name');
                    const type = this.getAttribute('data-type');
                    openModal('edit', id, name, type);
                });
            });

            document.querySelectorAll('.btn-delete').forEach(function(button) {
                button.addEventListener('click', function() {
                    const id = this.getAttribute('data-id');
                    const name = this.getAttribute('data-name');
                    showDeleteModal(id, name);
                });
            });

            const modal = document.getElementById('categoryModal');
            if (modal) {
                modal.addEventListener('click', function(e) {
                    if (e.target === this) {
                        closeModal();
                    }
                });
            }

            const deleteModal = document.getElementById('deleteModal');
            if (deleteModal) {
                deleteModal.addEventListener('click', function(e) {
                    if (e.target === this) {
                        closeDeleteModal();
                    }
                });
            }

            const categoryNameInput = document.getElementById('categoryName');
            if (categoryNameInput) {
                categoryNameInput.addEventListener('input', function() {
                    const length = this.value.length;
                    const formMessage = document.getElementById('formMessage');
                    
                    if (length === 0) {
                        formMessage.textContent = '';
                    } else if (length < 3) {
                        formMessage.textContent = `⚠️ Need ${3 - length} more character(s)`;
                        formMessage.style.color = '#f59e0b';
                    } else if (length > 50) {
                        formMessage.textContent = `❌ Exceeded by ${length - 50} character(s)`;
                        formMessage.style.color = '#dc3545';
                    } else {
                        formMessage.textContent = `✓ ${length}/50 characters`;
                        formMessage.style.color = '#28a745';
                    }
                });
            }

            document.addEventListener('keydown', function(e) {
                if (e.key === 'Escape') {
                    closeModal();
                    closeDeleteModal();
                }
            });

            const alerts = document.querySelectorAll('.alert');
            alerts.forEach(function(alert) {
                setTimeout(function() {
                    alert.style.transition = 'opacity 0.5s';
                    alert.style.opacity = '0';
                    setTimeout(function() {
                        alert.remove();
                    }, 500);
                }, 5000);
            });
        });
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
    </script>

    <%
        session.removeAttribute("successMessage");
        session.removeAttribute("errorMessage");
    %>
</body>
</html>