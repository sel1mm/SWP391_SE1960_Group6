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

        /* DETAIL PANEL */
        .detail-panel {
            background: linear-gradient(135deg, #e8f0fe 0%, #f0f4ff 100%);
            border: 2px solid #4285f4;
            border-radius: 8px;
            padding: 25px;
            margin-bottom: 25px;
            box-shadow: 0 2px 8px rgba(66, 133, 244, 0.15);
            border: 1px solid #e0e0e0;
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

        .status-card.active { border-left-color: #28a745; }
        .status-card.repair { border-left-color: #dc3545; }
        .status-card.maintenance { border-left-color: #ffc107; }

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

        .inventory-table thead tr th:nth-child(1) { width: 6%; }
        .inventory-table thead tr th:nth-child(2) { width: 11%; }
        .inventory-table thead tr th:nth-child(3) { width: 10%; }
        .inventory-table thead tr th:nth-child(4) { width: 10%; }
        .inventory-table thead tr th:nth-child(5) { width: 14%; }
        .inventory-table thead tr th:nth-child(6) { width: 9%; }
        .inventory-table thead tr th:nth-child(7) { width: 10%; }
        .inventory-table thead tr th:nth-child(8) { width: 10%; }
        .inventory-table thead tr th:nth-child(9) { width: 20%; }

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

        /* ✅ BUTTONS - HORIZONTAL LAYOUT LIKE PARTDETAIL */
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

        .form-container input:disabled {
            background: #e9ecef;
            cursor: not-allowed;
            color: #6c757d;
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
    </style>
</head>

<body>
    <!-- Sidebar Full Height -->
    <div class="sidebar">
        <div class="sidebar-logo">CRM System</div>
        <div class="sidebar-menu">
            <a href="storekeeper"><i class="fas fa-home"></i><span>Trang chủ</span></a>
            <a href="manageProfile"><i class="fas fa-user-circle"></i><span>Hồ Sơ</span></a>
            <a href="#"><i class="fas fa-chart-line"></i><span>Thống kê</span></a>
            <a href="numberPart"><i class="fas fa-list"></i><span>Danh sách linh kiện</span></a>
            <a href="numberEquipment" class="active"><i class="fas fa-list"></i><span>Danh sách thiết bị</span></a>
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
            <h2>Danh sách thiết bị</h2>

            <!-- DETAIL PANEL -->
            <c:if test="${showDetail && selectedEquipment != null}">
                <div class="detail-panel">
                    <div class="detail-header">
                        <h3>
                            <i class="fas fa-chart-pie"></i> 
                            Chi tiết trạng thái: ${selectedEquipment.model}
                        </h3>
                        <form action="numberEquipment" method="get" style="display: inline;">
                            <button type="submit" class="btn-close-detail">
                                <i class="fas fa-times"></i> Đóng
                            </button>
                        </form>
                    </div>
                    
                    <div class="status-grid">
                        <div class="status-card active">
                            <h4><i class="fas fa-check-circle"></i> Active (Hoạt động)</h4>
                            <div class="count">${statusCount['Active']}</div>
                        </div>
                        
                        <div class="status-card repair">
                            <h4><i class="fas fa-tools"></i> Repair (Sửa chữa)</h4>
                            <div class="count">${statusCount['Repair']}</div>
                        </div>
                        
                        <div class="status-card maintenance">
                            <h4><i class="fas fa-wrench"></i> Maintenance (Bảo trì)</h4>
                            <div class="count">${statusCount['Maintenance']}</div>
                        </div>
                    </div>
                </div>
            </c:if>

            <!-- Search & Filter -->
            <div class="search-filter-container">
                <form action="numberEquipment" method="POST">
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
                            <option value="equipmentId" ${param.filter == 'equipmentId' ? 'selected' : ''}>By Equipment ID</option>
                            <option value="serialNumber" ${param.filter == 'serialNumber' ? 'selected' : ''}>By Serial Number</option>
                            <option value="model" ${param.filter == 'model' ? 'selected' : ''}>By Model</option>
                            <option value="category" ${param.filter == 'category' ? 'selected' : ''}>By Category</option>
                            <option value="installDate" ${param.filter == 'installDate' ? 'selected' : ''}>By Install Date</option>
                            <option value="updatePerson" ${param.filter == 'updatePerson' ? 'selected' : ''}>By Update Person</option>
                            <option value="updateDate" ${param.filter == 'updateDate' ? 'selected' : ''}>By Update Date</option>
                        </select>

                        <button type="button" class="btn-new" onclick="openForm('new')">
                            <i class="fas fa-plus"></i> New Equipment
                        </button>
                    </div>
                </form>
            </div>

            <!-- Table -->
            <table class="inventory-table">
                <thead>
                    <tr>
                        <th>Equipment ID</th>
                        <th>Serial Number</th>
                        <th>Model</th>
                        <th>Category</th>
                        <th>Description</th>
                        <th>Install Date</th>
                        <th>Last Updated By</th>
                        <th>Last Update Time</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${list}" var="equipment">
                        <tr>
                            <td>${equipment.equipmentId}</td>
                            <td>${equipment.serialNumber}</td>
                            <td>${equipment.model}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${not empty equipment.categoryName}">
                                        ${equipment.categoryName}
                                    </c:when>
                                    <c:otherwise>
                                        N/A
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>${equipment.description}</td>
                            <td>${equipment.installDate}</td>
                            <td>${equipment.username}</td>
                            <td>${equipment.lastUpdatedDate}</td>
                            <td>
                                <div>
                                    <form action="numberEquipment" method="post" style="margin: 0; display: inline;">
                                        <input type="hidden" name="action" value="detail">
                                        <input type="hidden" name="equipmentId" value="${equipment.equipmentId}">
                                        <button type="submit" class="btn-detail">
                                            <i class="fas fa-info-circle"></i> Detail
                                        </button>
                                    </form>
                                    
                                    <button type="button" class="btn-edit"
                                            onclick="openForm('edit',
                                                            '${equipment.equipmentId}',
                                                            '${equipment.serialNumber}',
                                                            '${equipment.model}',
                                                            '${equipment.description}',
                                                            '${equipment.installDate}',
                                                            '${equipment.categoryId}')">
                                        <i class="fas fa-edit"></i> Edit
                                    </button>
                                    
                                    <button type="button" class="btn-delete"
                                            onclick="showDeleteModal('${equipment.equipmentId}', '${equipment.serialNumber}', '${equipment.model}')">
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

            <!-- Form Popup -->
            <div class="form-overlay" id="formOverlay">
                <div class="form-container">
                    <h2 id="formTitle">Add New Equipment</h2>
                    <form action="numberEquipment" method="POST" id="equipmentForm" onsubmit="return validateForm()">
                        <input type="hidden" name="action" id="actionInput" value="add">
                        <input type="hidden" name="equipmentId" id="equipmentId">

                        <label>Serial Number * (3-30 ký tự)</label>
                        <input type="text" name="serialNumber" id="serialNumber" required 
                               minlength="3" maxlength="30"
                               placeholder="Nhập serial number (3-30 ký tự)">

                        <label>Model * (Tối thiểu 3 ký tự)</label>
                        <input type="text" name="model" id="model" required 
                               minlength="3" maxlength="50"
                               placeholder="Nhập model (ít nhất 3 ký tự)">

                        <label>Category</label>
                        <select name="categoryId" id="categoryId" class="filter-select" style="width: 100%; background: #fafafa;">
                            <option value="">-- Select Category --</option>
                            <c:forEach items="${categories}" var="cat">
                                <option value="${cat.categoryId}">${cat.categoryName}</option>
                            </c:forEach>
                        </select>

                        <label>Description * (10-100 ký tự)</label>
                        <input type="text" name="description" id="description" required 
                               minlength="10" maxlength="100"
                               placeholder="Nhập mô tả (10-100 ký tự)">

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
        let deleteEquipmentId = null;

        // ✅ SHOW DELETE MODAL - FIXED TO AVOID LOCALHOST DISPLAY
        function showDeleteModal(equipmentId, serialNumber, model) {
            // Convert to string to ensure no issues
            const id = String(equipmentId);
            const sn = String(serialNumber);
            const mdl = String(model);
            
            deleteEquipmentId = equipmentId;
            
            const modal = document.getElementById("deleteModal");
            const message = document.getElementById("deleteModalMessage");
            
            // Use string concatenation instead of template literals
            const newHTML = "Bạn có chắc muốn xóa Equipment:<br><strong>" + mdl + "</strong><br>Serial: <strong>" + sn + "</strong> (ID: " + id + ")?";
            
            message.innerHTML = newHTML;
            modal.style.display = "flex";
        }

        // CLOSE DELETE MODAL
        function closeDeleteModal() {
            document.getElementById("deleteModal").style.display = "none";
            deleteEquipmentId = null;
        }

        // CONFIRM DELETE ACTION
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

        function openForm(mode, equipmentId = '', serialNumber = '', model = '', description = '', installDate = '', categoryId = '') {
            const overlay = document.getElementById("formOverlay");
            const title = document.getElementById("formTitle");
            const actionInput = document.getElementById("actionInput");
            const formMessage = document.getElementById("formMessage");
            const installDateInput = document.getElementById("installDate");

            overlay.style.display = "flex";
            formMessage.textContent = "";
            formMessage.style.color = "#dc3545";

            if (mode === "new") {
                title.textContent = "Add New Equipment";
                actionInput.value = "add";
                document.getElementById("equipmentId").value = "";
                document.getElementById("serialNumber").value = "";
                document.getElementById("model").value = "";
                document.getElementById("categoryId").value = "";
                document.getElementById("description").value = "";
                document.getElementById("installDate").value = "";
                
                installDateInput.disabled = false;
                installDateInput.style.background = "#fafafa";
            } else {
                title.textContent = "Edit Equipment";
                actionInput.value = "edit";
                document.getElementById("equipmentId").value = equipmentId;
                document.getElementById("serialNumber").value = serialNumber;
                document.getElementById("model").value = model;
                document.getElementById("categoryId").value = categoryId;
                document.getElementById("description").value = description;
                document.getElementById("installDate").value = installDate;
                
                installDateInput.disabled = true;
                installDateInput.style.background = "#e9ecef";
            }
        }

        function closeForm() {
            document.getElementById("formOverlay").style.display = "none";
            document.getElementById("formMessage").textContent = "";
        }

        function validateForm() {
            const serialNumber = document.getElementById("serialNumber").value.trim();
            const model = document.getElementById("model").value.trim();
            const description = document.getElementById("description").value.trim();
            const installDate = document.getElementById("installDate").value;
            const formMessage = document.getElementById("formMessage");
            const actionInput = document.getElementById("actionInput").value;
            
            formMessage.textContent = "";
            formMessage.style.color = "#dc3545";
            
            if (serialNumber.length < 3) {
                formMessage.textContent = "❌ Serial Number phải có ít nhất 3 ký tự!";
                return false;
            }
            
            if (serialNumber.length > 30) {
                formMessage.textContent = "❌ Serial Number không được vượt quá 30 ký tự!";
                return false;
            }
            
            if (model.length < 3) {
                formMessage.textContent = "❌ Model phải có ít nhất 3 ký tự!";
                return false;
            }
            
            if (model.length > 50) {
                formMessage.textContent = "❌ Model không được vượt quá 50 ký tự!";
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
            
            if (actionInput === "add" && !installDate) {
                formMessage.textContent = "❌ Vui lòng chọn ngày lắp đặt!";
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

            const serialNumberInput = document.getElementById("serialNumber");
            if (serialNumberInput) {
                serialNumberInput.addEventListener("input", function() {
                    const length = this.value.length;
                    const formMessage = document.getElementById("formMessage");
                    
                    if (length === 0) {
                        formMessage.textContent = "";
                    } else if (length < 3) {
                        formMessage.textContent = "⚠️ Serial Number: Còn thiếu " + (3 - length) + " ký tự";
                        formMessage.style.color = "#ff9800";
                    } else if (length > 30) {
                        formMessage.textContent = "❌ Serial Number: Vượt quá " + (length - 30) + " ký tự";
                        formMessage.style.color = "#dc3545";
                    } else {
                        formMessage.textContent = "✓ Serial Number: " + length + "/30 ký tự";
                        formMessage.style.color = "#28a745";
                    }
                });
            }

            const modelInput = document.getElementById("model");
            if (modelInput) {
                modelInput.addEventListener("input", function() {
                    const length = this.value.length;
                    const formMessage = document.getElementById("formMessage");
                    
                    if (length === 0) {
                        formMessage.textContent = "";
                    } else if (length < 3) {
                        formMessage.textContent = "⚠️ Model: Còn thiếu " + (3 - length) + " ký tự";
                        formMessage.style.color = "#ff9800";
                    } else if (length > 50) {
                        formMessage.textContent = "❌ Model: Vượt quá " + (length - 50) + " ký tự";
                        formMessage.style.color = "#dc3545";
                    } else {
                        formMessage.textContent = "✓ Model: " + length + "/50 ký tự";
                        formMessage.style.color = "#28a745";
                    }
                });
            }

            const descriptionInput = document.getElementById("description");
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
        });
    </script>

    <c:remove var="successMessage" scope="session" />
    <c:remove var="errorMessage" scope="session" />
</body>
</html>