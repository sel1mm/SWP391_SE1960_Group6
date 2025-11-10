<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <title>CRM System - Danh sách thiết bị</title>

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

        .content h2 {
            margin: 0 0 30px 0;
            color: #333;
            font-size: 28px;
            font-weight: 600;
        }

        .alert {
            padding: 12px 20px;
            border-radius: 6px;
            margin-bottom: 20px;
            font-size: 14px;
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 10px;
            animation: slideDown 0.3s ease;
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

        .alert-close {
            margin-left: auto;
            cursor: pointer;
            font-size: 18px;
            opacity: 0.7;
            transition: opacity 0.2s;
        }

        .alert-close:hover {
            opacity: 1;
        }

        @keyframes slideDown {
            from {
                transform: translateY(-20px);
                opacity: 0;
            }
            to {
                transform: translateY(0);
                opacity: 1;
            }
        }

        /* ===== SEARCH & FILTER SECTION ===== */
        .search-filter-container {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            border: 1px solid #e0e0e0;
            margin-bottom: 20px;
        }

        .filter-row {
            display: flex;
            gap: 15px;
            align-items: flex-end;
            flex-wrap: wrap;
        }

        .filter-group {
            flex: 1;
            min-width: 200px;
        }

        .filter-group label {
            display: block;
            font-size: 13px;
            font-weight: 600;
            color: #555;
            margin-bottom: 6px;
        }

        .filter-group input[type="text"],
        .filter-group select {
            width: 100%;
            padding: 9px 12px;
            border: 1px solid #d0d0d0;
            border-radius: 6px;
            font-size: 14px;
            background: #fafafa;
            transition: all 0.2s;
        }

        .filter-group input[type="text"]:focus,
        .filter-group select:focus {
            outline: none;
            border-color: #007bff;
            background: white;
            box-shadow: 0 0 0 3px rgba(0,123,255,0.1);
        }

        .filter-buttons {
            display: flex;
            gap: 10px;
            align-items: flex-end;
        }

        .btn-filter, .btn-reset, .btn-new {
            padding: 9px 18px;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-weight: 500;
            transition: all 0.2s;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            font-size: 14px;
            white-space: nowrap;
        }

        .btn-filter {
            background: #007bff;
            color: white;
        }

        .btn-filter:hover {
            background: #0056b3;
            transform: translateY(-1px);
            box-shadow: 0 2px 6px rgba(0,123,255,0.3);
        }

        .btn-reset {
            background: #6c757d;
            color: white;
        }

        .btn-reset:hover {
            background: #5a6268;
            transform: translateY(-1px);
            box-shadow: 0 2px 6px rgba(108,117,125,0.3);
        }

        .btn-new {
            background: #28a745;
            color: white;
        }

        .btn-new:hover {
            background: #218838;
            transform: translateY(-1px);
            box-shadow: 0 2px 6px rgba(40,167,69,0.3);
        }

        .summary-table {
            width: 100%;
            border-collapse: collapse;
            background: white;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            border: 1px solid #e0e0e0;
            margin-bottom: 20px;
        }

        .summary-table thead tr th {
            background: #f8f9fa;
            color: #333;
            padding: 12px 16px;
            text-align: left;
            font-weight: 600;
            font-size: 13px;
            border-bottom: 2px solid #dee2e6;
        }

        .summary-table tbody td {
            padding: 12px 16px;
            border-bottom: 1px solid #e0e0e0;
            font-size: 13px;
            color: #666;
        }

        .summary-table tbody tr:hover {
            background-color: #f0f0f0;
        }

        .detail-table-container {
            padding: 0;
            background: #f8f9fa;
            display: none;
        }

        .detail-table-container.show {
            display: block;
        }

        .detail-table {
            width: 100%;
            border-collapse: collapse;
            margin: 15px 0;
        }

        .detail-table thead tr th {
            background: #e9ecef;
            color: #495057;
            padding: 10px 14px;
            text-align: left;
            font-weight: 600;
            font-size: 12px;
            border-bottom: 1px solid #dee2e6;
        }

        .detail-table tbody td {
            padding: 10px 14px;
            border-bottom: 1px solid #e9ecef;
            font-size: 12px;
            color: #666;
            background: white;
        }

        .detail-table tbody tr:hover {
            background-color: #f8f9fa;
        }

        .btn-edit, .btn-delete {
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
            margin-right: 4px;
        }

        .btn-edit {
            background: #007bff;
        }

        .btn-delete {
            background: #dc3545;
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

        .mode-selection {
            display: flex;
            gap: 10px;
            margin-bottom: 20px;
        }

        .mode-btn {
            flex: 1;
            padding: 10px;
            border: 2px solid #dee2e6;
            background: white;
            border-radius: 6px;
            cursor: pointer;
            transition: all 0.2s;
            font-size: 13px;
            font-weight: 500;
            text-align: center;
        }

        .mode-btn:hover {
            border-color: #007bff;
            background: #f8f9fa;
        }

        .mode-btn.active {
            border-color: #007bff;
            background: #007bff;
            color: white;
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
        .form-container input[type="date"],
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
        }

        .delete-modal-content {
            background: white;
            padding: 30px;
            border-radius: 10px;
            width: 450px;
            max-width: 90%;
            box-shadow: 0 8px 30px rgba(0,0,0,0.3);
            text-align: center;
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
        }

        .btn-confirm-delete {
            background: #dc3545;
            color: white;
        }

        .btn-cancel-delete {
            background: #6c757d;
            color: white;
        }

        .toggle-icon {
            cursor: pointer;
            transition: transform 0.3s ease;
            display: inline-block;
            margin-right: 8px;
            color: #007bff;
        }

        .toggle-icon.open {
            transform: rotate(90deg);
        }

        .loading-spinner {
            display: inline-block;
            width: 16px;
            height: 16px;
            border: 2px solid #f3f3f3;
            border-top: 2px solid #007bff;
            border-radius: 50%;
            animation: spin 1s linear infinite;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        .hidden {
            display: none !important;
        }

        .no-results {
            text-align: center;
            padding: 40px 20px;
            color: #999;
            font-size: 16px;
        }

        .no-results i {
            font-size: 48px;
            margin-bottom: 15px;
            display: block;
            color: #ccc;
        }

        /* ===== PAGINATION STYLES ===== */
        .pagination-container {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 15px;
            margin-top: 25px;
            padding: 20px;
            background: white;
            border-radius: 8px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }

        .pagination {
            display: flex;
            gap: 5px;
            list-style: none;
        }

        .pagination a, .pagination span {
            padding: 8px 14px;
            border: 1px solid #dee2e6;
            border-radius: 6px;
            text-decoration: none;
            color: #495057;
            font-weight: 500;
            font-size: 14px;
            transition: all 0.2s;
            display: inline-block;
        }

        .pagination a:hover {
            background: #007bff;
            color: white;
            border-color: #007bff;
            transform: translateY(-1px);
        }

        .pagination .active {
            background: #007bff;
            color: white;
            border-color: #007bff;
            font-weight: 600;
        }

        .pagination .disabled {
            color: #adb5bd;
            pointer-events: none;
            opacity: 0.5;
        }

        .page-info {
            color: #666;
            font-size: 14px;
            font-weight: 500;
        }
    </style>
</head>

<body>
    <div class="sidebar">
        <div class="sidebar-logo">CRM System</div>
        <div class="sidebar-menu">
            <a href="statistic" class="active"><i class="fas fa-home"></i><span>Trang chủ</span></a>
            <a href="manageProfile"><i class="fas fa-user-circle"></i><span>Hồ Sơ</span></a>
            <a href="storekeeper"><i class="fas fa-chart-line"></i><span>Thống kê</span></a>
            <a href="numberPart"><i class="fas fa-list"></i><span>Danh sách linh kiện</span></a>
            <a href="numberEquipment"><i class="fas fa-list"></i><span>Danh sách thiết bị</span></a>
            <a href="PartDetailHistoryServlet"><i class="fas fa-history"></i><span>Lịch sử giao dịch</span></a>
            <a href="partDetail"><i class="fas fa-truck-loading"></i><span>Chi tiết linh kiện</span></a>
            <a href="category"><i class="fas fa-tags"></i><span>Quản lý danh mục</span></a>
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
            <h2>Danh sách thiết bị</h2>

            <c:if test="${not empty sessionScope.successMessage}">
                <div class="alert alert-success">
                    <i class="fas fa-check-circle"></i>
                    <span>${sessionScope.successMessage}</span>
                    <span class="alert-close" onclick="this.parentElement.remove()">×</span>
                </div>
                <c:remove var="successMessage" scope="session"/>
            </c:if>

            <c:if test="${not empty sessionScope.errorMessage}">
                <div class="alert alert-error">
                    <i class="fas fa-exclamation-circle"></i>
                    <span>${sessionScope.errorMessage}</span>
                    <span class="alert-close" onclick="this.parentElement.remove()">×</span>
                </div>
                <c:remove var="errorMessage" scope="session"/>
            </c:if>

            <!-- ===== SEARCH & FILTER SECTION ===== -->
            <div class="search-filter-container">
                <form action="numberEquipment" method="GET" id="filterForm">
                    <div class="filter-row">
                        <div class="filter-group">
                            <label><i class="fas fa-search"></i> Search (Model / Description)</label>
                            <input type="text" name="search" id="searchInput" 
                                   placeholder="Nhập từ khóa tìm kiếm..." 
                                   value="${param.search != null ? param.search : ''}">
                        </div>

                                <div class="filter-group">
                            <label><i class="fas fa-filter"></i> Category</label>
                            <select name="categoryFilter" id="categoryFilter">
                                <option value="">-- All Categories --</option>
                                <c:forEach items="${categories}" var="cat">
                                    <option value="${cat.categoryId}" 
                                            ${param.categoryFilter eq cat.categoryId ? 'selected' : ''}>
                                        ${cat.categoryName}
                                    </option>
                                </c:forEach>
                            </select>
                        </div>

                        <div class="filter-group">
                            <label><i class="fas fa-sort"></i> Sort by Name</label>
                            <select name="sortByName" id="sortByName">
                                <option value="">-- Default --</option>
                                <option value="asc" ${param.sortByName == 'asc' ? 'selected' : ''}>A-Z</option>
                                <option value="desc" ${param.sortByName == 'desc' ? 'selected' : ''}>Z-A</option>
                            </select>
                        </div>

                        <div class="filter-buttons">
                            <button type="submit" class="btn-filter">
                                <i class="fas fa-search"></i> Apply
                            </button>
                            <button type="button" class="btn-reset" onclick="resetFilters()">
                                <i class="fas fa-redo"></i> Reset
                            </button>
                            <button type="button" class="btn-new" onclick="openForm('new')">
                                <i class="fas fa-plus"></i> New
                            </button>
                        </div>
                    </div>
                </form>
            </div>

            <!-- ===== EQUIPMENT TABLE ===== -->
            <c:choose>
                <c:when test="${not empty groupedList}">
                    <table class="summary-table">
                        <thead>
                            <tr>
                                <th style="width: 7.5%"></th>
                                <th style="width: 27.5%">Model</th>
                                <th style="width: 22.5%">Category</th>
                                <th style="width: 42.5%">Description</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach items="${groupedList}" var="group" varStatus="status">
                                <tr class="summary-row" data-model="${group.model}" 
                                    data-category="${group.categoryId}" 
                                    data-category-name="${group.categoryName}"
                                    data-description="${group.description}"
                                    data-index="${status.index}">
                                    <td>
                                        <i class="fas fa-chevron-right toggle-icon" 
                                           onclick="toggleDetailByIndex(${status.index})"></i>
                                    </td>
                                    <td>${group.model}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty group.categoryName}">
                                                ${group.categoryName}
                                            </c:when>
                                            <c:otherwise>N/A</c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>${group.description}</td>
                                </tr>
                                <tr class="detail-row" id="detail-${status.index}" style="display: none;">
                                    <td colspan="5" style="padding: 0;">
                                        <div class="detail-table-container" id="container-${status.index}">
                                            <table class="detail-table">
                                                <thead>
                                                    <tr>
                                                        <th>Equipment ID</th>
                                                        <th>Serial Number</th>
                                                        <th>Install Date</th>
                                                        <th>Updated By</th>
                                                        <th>Update Date</th>
                                                        <th>Action</th>
                                                    </tr>
                                                </thead>
                                                <tbody id="tbody-${status.index}">
                                                </tbody>
                                            </table>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>

                    <!-- ===== PAGINATION ===== -->
                    <c:if test="${totalPages > 1}">
                        <div class="pagination-container">
                            <div class="page-info">
                                Trang ${currentPage} / ${totalPages} (Tổng ${totalRecords} models)
                            </div>
                            <ul class="pagination">
                                <!-- First Page -->
                                <li>
                                    <a href="?page=1&search=${param.search}&categoryFilter=${param.categoryFilter}&sortByName=${param.sortByName}" 
                                       class="${currentPage == 1 ? 'disabled' : ''}">
                                        <i class="fas fa-angle-double-left"></i>
                                    </a>
                                </li>
                                
                                <!-- Previous Page -->
                                <li>
                                    <a href="?page=${currentPage - 1}&search=${param.search}&categoryFilter=${param.categoryFilter}&sortByName=${param.sortByName}" 
                                       class="${currentPage == 1 ? 'disabled' : ''}">
                                        <i class="fas fa-angle-left"></i>
                                    </a>
                                </li>

                                <!-- Page Numbers -->
                                <c:forEach begin="${startPage}" end="${endPage}" var="i">
                                    <li>
                                        <c:choose>
                                            <c:when test="${i == currentPage}">
                                                <span class="active">${i}</span>
                                            </c:when>
                                            <c:otherwise>
                                                <a href="?page=${i}&search=${param.search}&categoryFilter=${param.categoryFilter}&sortByName=${param.sortByName}">
                                                    ${i}
                                                </a>
                                            </c:otherwise>
                                        </c:choose>
                                    </li>
                                </c:forEach>

                                <!-- Next Page -->
                                <li>
                                    <a href="?page=${currentPage + 1}&search=${param.search}&categoryFilter=${param.categoryFilter}&sortByName=${param.sortByName}" 
                                       class="${currentPage == totalPages ? 'disabled' : ''}">
                                        <i class="fas fa-angle-right"></i>
                                    </a>
                                </li>

                                <!-- Last Page -->
                                <li>
                                    <a href="?page=${totalPages}&search=${param.search}&categoryFilter=${param.categoryFilter}&sortByName=${param.sortByName}" 
                                       class="${currentPage == totalPages ? 'disabled' : ''}">
                                        <i class="fas fa-angle-double-right"></i>
                                    </a>
                                </li>
                            </ul>
                        </div>
                    </c:if>
                </c:when>
                <c:otherwise>
                    <div class="no-results">
                        <i class="fas fa-search"></i>
                        <p>Không tìm thấy thiết bị nào phù hợp với bộ lọc</p>
                    </div>
                </c:otherwise>
            </c:choose>

            <!-- ===== ADD/EDIT FORM MODAL ===== -->
            <div class="form-overlay" id="formOverlay">
                <div class="form-container">
                    <h2 id="formTitle">Add New Equipment</h2>
                    
                    <div class="mode-selection" id="modeSelection">
                        <div class="mode-btn active" id="existingModelBtn" onclick="selectMode('existing')">
                            <i class="fas fa-plus-circle"></i> Thêm thiết bị (Model có sẵn)
                        </div>
                        <div class="mode-btn" id="newModelBtn" onclick="selectMode('new')">
                            <i class="fas fa-star"></i> Thêm thiết bị (Model chưa được tạo)
                        </div>
                    </div>

                    <form action="numberEquipment" method="POST" id="equipmentForm" onsubmit="return validateForm()">
                        <input type="hidden" name="action" id="actionInput" value="add">
                        <input type="hidden" name="equipmentId" id="equipmentId">
                        <input type="hidden" name="addMode" id="addModeInput" value="existing">

                        <div id="modelSelectionGroup">
                            <label>Chọn Model *</label>
                            <select name="selectedModel" id="selectedModel">
                                <option value="">-- Chọn Model --</option>
                                <c:forEach items="${allModels}" var="model">
                                    <option value="${model}">
                                        ${model}
                                    </option>
                                </c:forEach>
                            </select>
                        </div>

                        <div id="newModelFields" class="hidden">
                            <label>Model * (Tối thiểu 3 ký tự)</label>
                            <input type="text" name="model" id="model" 
                                   minlength="3" maxlength="50" placeholder="Nhập model">

                            <label>Category</label>
                            <select name="categoryId" id="categoryId">
                                <option value="">-- Select Category --</option>
                                <c:forEach items="${categories}" var="cat">
                                    <option value="${cat.categoryId}">${cat.categoryName}</option>
                                </c:forEach>
                            </select>

                            <label>Description * (10-100 ký tự)</label>
                            <input type="text" name="description" id="description" 
                                   minlength="10" maxlength="100" placeholder="Nhập mô tả">
                        </div>

                        <label>Serial Number * (3-30 ký tự)</label>
                        <input type="text" name="serialNumber" id="serialNumber" required 
                               minlength="3" maxlength="30" placeholder="Nhập serial number">

                        <label>Install Date *</label>
                        <input type="date" name="installDate" id="installDate" required>

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

            <!-- ===== DELETE CONFIRMATION MODAL ===== -->
            <div class="delete-modal" id="deleteModal">
                <div class="delete-modal-content">
                    <div class="delete-modal-icon">
                        <i class="fas fa-exclamation-triangle"></i>
                    </div>
                    <h3>Xác nhận xóa</h3>
                    <p id="deleteModalMessage">Bạn có chắc muốn xóa equipment này?</p>
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
        </div>
    </div>

    <script>
        let deleteEquipmentId = null;
        let loadedRows = {};
        let currentMode = 'existing';

        function resetFilters() {
            window.location.href = 'numberEquipment';
        }

        function toggleDetailByIndex(index) {
            const detailRow = document.getElementById('detail-' + index);
            const summaryRow = document.querySelector('[data-index="' + index + '"]');
            const icon = summaryRow ? summaryRow.querySelector('.toggle-icon') : null;
            const container = document.getElementById('container-' + index);
            const model = summaryRow ? summaryRow.getAttribute('data-model') : null;
            
            if (!detailRow || !icon || !container || !model) {
                console.error('Cannot find elements');
                return;
            }
            
            if (detailRow.style.display === 'none' || detailRow.style.display === '') {
                detailRow.style.display = 'table-row';
                icon.classList.add('open');
                container.classList.add('show');
                
                if (!loadedRows[index]) {
                    loadDetailData(index, model);
                    loadedRows[index] = true;
                }
            } else {
                detailRow.style.display = 'none';
                icon.classList.remove('open');
                container.classList.remove('show');
            }
        }

        function loadDetailData(index, model) {
            const tbody = document.getElementById('tbody-' + index);
            tbody.innerHTML = '<tr><td colspan="6" style="text-align:center;"><span class="loading-spinner"></span> Loading...</td></tr>';
            
            fetch('numberEquipment?action=getDetailByModel&model=' + encodeURIComponent(model))
                .then(response => response.json())
                .then(data => {
                    tbody.innerHTML = '';
                    
                    if (data.length === 0) {
                        tbody.innerHTML = '<tr><td colspan="6" style="text-align:center;">Không có dữ liệu</td></tr>';
                        return;
                    }
                    
                    data.forEach(item => {
                        const row = document.createElement('tr');
                        const sn = String(item.serialNumber).replace(/'/g, "\\'");
                        const installDate = item.installDate || '';
                        
                        row.innerHTML = 
                            '<td>' + item.equipmentId + '</td>' +
                            '<td>' + item.serialNumber + '</td>' +
                            '<td>' + (item.installDate || 'N/A') + '</td>' +
                            '<td>' + (item.username || 'N/A') + '</td>' +
                            '<td>' + (item.lastUpdatedDate || 'N/A') + '</td>' +
                            '<td>' +
                                '<button class="btn-edit" onclick="openForm(\'edit\', ' + item.equipmentId + ', \'' + sn + '\', \'' + installDate + '\')">' +
                                    '<i class="fas fa-edit"></i> Edit' +
                                '</button>' +
                                '<button class="btn-delete" onclick="showDeleteModal(' + item.equipmentId + ', \'' + sn + '\', \'' + item.model + '\')">' +
                                    '<i class="fas fa-trash"></i> Delete' +
                                '</button>' +
                            '</td>';
                        tbody.appendChild(row);
                    });
                })
                .catch(error => {
                    tbody.innerHTML = '<tr><td colspan="6" style="text-align:center; color:red;">Lỗi: ' + error.message + '</td></tr>';
                });
        }

        function selectMode(mode) {
            currentMode = mode;
            document.getElementById('addModeInput').value = mode;
            
            const existingBtn = document.getElementById('existingModelBtn');
            const newBtn = document.getElementById('newModelBtn');
            const modelSelectionGroup = document.getElementById('modelSelectionGroup');
            const newModelFields = document.getElementById('newModelFields');
            
            if (mode === 'existing') {
                existingBtn.classList.add('active');
                newBtn.classList.remove('active');
                modelSelectionGroup.classList.remove('hidden');
                newModelFields.classList.add('hidden');
                
                document.getElementById('model').value = '';
                document.getElementById('categoryId').value = '';
                document.getElementById('description').value = '';
            } else {
                newBtn.classList.add('active');
                existingBtn.classList.remove('active');
                modelSelectionGroup.classList.add('hidden');
                newModelFields.classList.remove('hidden');
                
                document.getElementById('selectedModel').value = '';
            }
        }

        function openForm(mode, equipmentId, serialNumber, installDate) {
            const overlay = document.getElementById("formOverlay");
            const title = document.getElementById("formTitle");
            const actionInput = document.getElementById("actionInput");
            const formMessage = document.getElementById("formMessage");
            const modeSelection = document.getElementById("modeSelection");
            const modelSelectionGroup = document.getElementById("modelSelectionGroup");
            const newModelFields = document.getElementById("newModelFields");
            
            const serialNumberInput = document.getElementById("serialNumber");
            const installDateInput = document.getElementById("installDate");

            overlay.style.display = "flex";
            formMessage.textContent = "";

            if (mode === "new") {
                title.textContent = "Add New Equipment";
                actionInput.value = "add";
                modeSelection.classList.remove('hidden');
                
                document.getElementById("equipmentId").value = "";
                serialNumberInput.value = "";
                document.getElementById("selectedModel").value = "";
                document.getElementById("model").value = "";
                document.getElementById("categoryId").value = "";
                document.getElementById("description").value = "";
                installDateInput.value = "";
                
                selectMode('existing');
                
            } else if (mode === "edit") {
                title.textContent = "Edit Equipment";
                actionInput.value = "edit";
                modeSelection.classList.add('hidden');
                modelSelectionGroup.classList.add('hidden');
                newModelFields.classList.add('hidden');
                
                document.getElementById("equipmentId").value = equipmentId || "";
                serialNumberInput.value = serialNumber || "";
                installDateInput.value = installDate || "";
            }
        }

        function closeForm() {
            document.getElementById("formOverlay").style.display = "none";
        }

        function validateForm() {
            const actionInput = document.getElementById("actionInput").value;
            const serialNumber = document.getElementById("serialNumber").value.trim();
            const formMessage = document.getElementById("formMessage");
            
            if (serialNumber.length < 3 || serialNumber.length > 30) {
                formMessage.textContent = "❌ Serial Number phải từ 3-30 ký tự!";
                return false;
            }
            
            if (actionInput === 'edit') {
                return true;
            }
            
            const addMode = document.getElementById("addModeInput").value;
            
            if (addMode === 'existing') {
                const selectedModel = document.getElementById("selectedModel").value;
                if (!selectedModel) {
                    formMessage.textContent = "❌ Vui lòng chọn Model!";
                    return false;
                }
            } else {
                const model = document.getElementById("model").value.trim();
                const description = document.getElementById("description").value.trim();
                
                if (model.length < 3) {
                    formMessage.textContent = "❌ Model phải có ít nhất 3 ký tự!";
                    return false;
                }
                
                if (description.length < 10 || description.length > 100) {
                    formMessage.textContent = "❌ Mô tả phải từ 10-100 ký tự!";
                    return false;
                }
            }
            
            return true;
        }

        function showDeleteModal(equipmentId, serialNumber, model) {
            deleteEquipmentId = equipmentId;
            const modal = document.getElementById("deleteModal");
            const message = document.getElementById("deleteModalMessage");
            
            message.innerHTML = "Bạn có chắc muốn xóa Equipment:<br><strong>" + model + 
                              "</strong><br>Serial: <strong>" + serialNumber + "</strong>?";
            modal.style.display = "flex";
        }

        function closeDeleteModal() {
            document.getElementById("deleteModal").style.display = "none";
            deleteEquipmentId = null;
        }
        
        function confirmDeleteAction() {
            if (deleteEquipmentId) {
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = 'numberEquipment';

                const actionInput = document.createElement('input');
                actionInput.type = 'hidden';
                actionInput.name = 'action';
                actionInput.value = 'delete';

                const idInput = document.createElement('input');
                idInput.type = 'hidden';
                idInput.name = 'equipmentId';
                idInput.value = deleteEquipmentId;

                form.appendChild(actionInput);
                form.appendChild(idInput);
                document.body.appendChild(form);
                form.submit();
            }
        }

        document.getElementById("formOverlay").addEventListener('click', function (e) {
            if (e.target === this) closeForm();
        });

        document.getElementById("deleteModal").addEventListener('click', function (e) {
            if (e.target === this) closeDeleteModal();
        });

        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                closeForm();
                closeDeleteModal();
            }
        });

        document.addEventListener('DOMContentLoaded', function() {
            const alerts = document.querySelectorAll('.alert');
            alerts.forEach(alert => {
                setTimeout(() => {
                    alert.style.transition = 'opacity 0.3s ease';
                    alert.style.opacity = '0';
                    setTimeout(() => alert.remove(), 300);
                }, 5000);
            });
        });
    </script>
</body>
</html>