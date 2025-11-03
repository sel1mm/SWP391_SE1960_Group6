<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <title>CRM System - Chi tiết thiết bị</title>

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

        /* ✅ SUCCESS & ERROR MESSAGES */
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

        /* SEARCH & FILTER */
        .search-filter-container {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin: 0 0 20px;
            background: white;
            padding: 16px 20px;
            border-radius: 8px;
            border: 1px solid #e0e0e0;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
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
            color: #333;
            transition: all 0.2s ease;
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
            transition: all 0.2s ease;
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
            transition: all 0.2s ease;
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

        /* ✅ TABLE - OPTIMIZED WIDTH - NO HORIZONTAL SCROLL */
        .table-wrapper {
            background: white;
            border-radius: 8px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            border: 1px solid #e0e0e0;
            overflow-x: auto;
        }

        .inventory-table {
            width: 100%;
            border-collapse: collapse;
            table-layout: fixed;
        }

        .inventory-table thead tr th {
            background: #f8f9fa;
            color: #333;
            padding: 10px 8px;
            text-align: center;
            font-weight: 600;
            font-size: 12px;
            border-bottom: 2px solid #dee2e6;
            white-space: nowrap;
            vertical-align: middle;
        }

        /* ✅ OPTIMIZED COLUMN WIDTHS - FIT SCREEN PERFECTLY */
        .inventory-table thead tr th:nth-child(1) { width: 6%; }   /* PartDetailId */
        .inventory-table thead tr th:nth-child(2) { width: 5%; }   /* PartId */
        .inventory-table thead tr th:nth-child(3) { width: 9%; }   /* Category */
        .inventory-table thead tr th:nth-child(4) { width: 11%; }  /* PartName */
        .inventory-table thead tr th:nth-child(5) { width: 10%; }  /* SerialNumber */
        .inventory-table thead tr th:nth-child(6) { width: 7%; }   /* Status */
        .inventory-table thead tr th:nth-child(7) { width: 14%; }  /* Location */
        .inventory-table thead tr th:nth-child(8) { width: 9%; }   /* LastUpdatedBy */
        .inventory-table thead tr th:nth-child(9) { width: 9%; }   /* LastUpdatedDate */
        .inventory-table thead tr th:nth-child(10) { width: 20%; } /* Action */

        .inventory-table tbody td {
            padding: 10px 8px;
            border-bottom: 1px solid #e0e0e0;
            font-size: 12px;
            color: #666;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
            text-align: center;
            vertical-align: middle;
        }

        .inventory-table tbody tr:hover {
            background-color: #f8f9fa;
        }

        .inventory-table tbody tr:last-child td {
            border-bottom: none;
        }

        /* ✅ LOCATION & PARTNAME COLUMN - SHOW FULL TEXT ON HOVER */
        .inventory-table tbody td:nth-child(4),
        .inventory-table tbody td:nth-child(7) {
            position: relative;
        }

        .inventory-table tbody td:nth-child(4):hover,
        .inventory-table tbody td:nth-child(7):hover {
            white-space: normal;
            word-wrap: break-word;
            background-color: #fffbea;
            z-index: 10;
        }

        /* ✅ BUTTONS - HORIZONTAL LAYOUT - CENTERED */
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
        }

        .btn-edit {
            background: #007bff;
        }

        .btn-delete {
            background: #dc3545;
            margin-left: 4px;
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

        .inventory-table tbody td:nth-child(10) {
            padding: 8px;
        }

        .inventory-table tbody td:nth-child(10) > div {
            display: flex;
            gap: 4px;
            align-items: center;
            justify-content: center;
        }

        /* PAGINATION */
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

        /* ✅ DELETE CONFIRMATION MODAL */
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
            width: 400px;
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

        /* FORM POPUP */
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
            animation: fadeIn 0.2s ease;
        }

        .form-container {
            background: #fff;
            padding: 30px;
            border-radius: 8px;
            width: 480px;
            max-width: 95%;
            box-shadow: 0 4px 20px rgba(0,0,0,0.2);
            animation: slideUp 0.3s ease;
        }

        #partDetailFormTitle {
            margin-bottom: 24px;
            font-size: 22px;
            font-weight: 600;
            color: #333;
            text-align: center;
        }

        .form-container label {
            font-weight: 500;
            margin-bottom: 6px;
            margin-top: 14px;
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
            color: #333;
            background: #fafafa;
        }

        .form-container input:focus,
        .form-container select:focus {
            border-color: #999;
            box-shadow: 0 0 0 3px rgba(0,0,0,0.05);
            background: white;
        }

        .form-container input:disabled,
        .form-container select:disabled {
            background: #e9ecef;
            cursor: not-allowed;
            color: #6c757d;
        }

        #partDetailFormMessage {
            font-size: 13px;
            text-align: center;
            min-height: 18px;
            margin-top: 10px;
            font-weight: 500;
        }

        .form-container small {
            display: block;
            margin-top: 4px;
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
            <a href="numberEquipment"><i class="fas fa-list"></i><span>Danh sách thiết bị</span></a>
            <a href="PartDetailHistoryServlet"><i class="fas fa-history"></i><span>Lịch sử giao dịch</span></a>
            <a href="partDetail" class="active"><i class="fas fa-truck-loading"></i><span>Chi tiết linh kiện</span></a>
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
            <h2>Chi tiết thiết bị</h2>

            <!-- ✅ SUCCESS & ERROR MESSAGES -->
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

            <!-- Search & Filter -->
            <div class="search-filter-container">
                <form action="partDetail" method="POST">
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
                            <option value="inventoryId" ${param.filter == 'inventoryId' ? 'selected' : ''}>By PartDetail ID</option>
                            <option value="category" ${param.filter == 'category' ? 'selected' : ''}>By Category</option>
                            <option value="partName" ${param.filter == 'partName' ? 'selected' : ''}>By Part Name</option>
                            <option value="status" ${param.filter == 'status' ? 'selected' : ''}>By Status</option>
                        </select>

                        <button type="button" class="btn-new" onclick="openPartDetailForm('new')">
                            <i class="fas fa-plus"></i> New Part
                        </button>
                    </div>
                </form>
            </div>

            <!-- ✅ TABLE WITH WRAPPER - NO HORIZONTAL SCROLL -->
            <div class="table-wrapper">
                <table class="inventory-table">
                    <thead>
                        <tr>
                            <th>DetailID</th>
                            <th>PartID</th>
                            <th>Category</th>
                            <th>Serial Number</th>
                            <th>Status</th>
                            <th>Location</th>
                            <th>Updated By</th>
                            <th>Updated Date</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${list}" var="ls">
                            <tr>
                                <td>${ls.partDetailId}</td>
                                <td>${ls.partId}</td>
                                <td>${ls.categoryName != null ? ls.categoryName : 'N/A'}</td>
                                <td>${ls.serialNumber}</td>
                                <td>${ls.status}</td>
                                <td title="${ls.location}">${ls.location}</td>
                                <td>${ls.username}</td>
                                <td>${ls.lastUpdatedDate}</td>
                                <td>
                                    <div>
                                        <button type="button" class="btn-edit" 
                                                onclick="openPartDetailForm('edit',
                                                                '${ls.partDetailId}',
                                                                '${ls.partId}',
                                                                '${ls.serialNumber}',
                                                                '${ls.status}',
                                                                '${ls.location}')">
                                            <i class="fas fa-edit"></i> Edit
                                        </button>
                                        <button type="button" class="btn-delete" 
                                                onclick="showDeleteModal(${ls.partDetailId}, '${ls.serialNumber}')">
                                            <i class="fas fa-trash"></i> Delete
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>

            <!-- ✅ DELETE CONFIRMATION MODAL -->
            <div class="delete-modal" id="deleteModal">
                <div class="delete-modal-content">
                    <div class="delete-modal-icon">
                        <i class="fas fa-exclamation-triangle"></i>
                    </div>
                    <h3>Xác nhận xóa</h3>
                    <p id="deleteModalMessage">Bạn có chắc muốn xóa Part Detail này?</p>
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

            <!-- FORM POPUP -->
            <div class="form-overlay" id="partDetailFormOverlay">
                <div class="form-container">
                    <h2 id="partDetailFormTitle">Add New Part Detail</h2>
                    <form action="partDetail" method="POST" id="partDetailForm" onsubmit="return validatePartDetailForm()">
                        <input type="hidden" name="action" id="partDetailAction" value="add">
                        <input type="hidden" name="partDetailId" id="partDetailId">
                        <input type="hidden" name="oldStatus" id="oldStatus">

                        <label>Part ID *</label>
                        <input type="number" name="partId" id="partId" required min="1">

                        <label>Serial Number * (Format: AAA-XXX-YYYY)</label>
                        <input type="text" name="serialNumber" id="serialNumber" required 
                               maxlength="13" placeholder="VD: SNK-001-2024"
                               pattern="[A-Z]{3}-\d{3}-\d{4}"
                               title="Format: AAA-XXX-YYYY (VD: SNK-001-2024)">
                        <small style="color: #666; font-size: 12px;">Ví dụ: SNK-001-2024, PRD-123-2025</small>

                        <label>Status *</label>
                        <select name="status" id="status" required>
                            <option value="Available">Available</option>
                            <option value="Faulty">Faulty</option>
                            <option value="Retired">Retired</option>
                        </select>
                        <small id="statusWarning" style="color: #dc3545; font-size: 12px; display: none;">
                            ⚠️ Lưu ý: Sau khi chuyển sang InUse, không thể thay đổi trạng thái nữa!
                        </small>

                        <label>Location * (Tối thiểu 5 ký tự)</label>
                        <input type="text" name="location" id="location" required 
                               minlength="5" maxlength="50" placeholder="Nhập vị trí (ít nhất 5 ký tự)">

                        <p id="partDetailFormMessage"></p>

                        <div class="form-buttons">
                            <button type="submit" class="btn-save">
                                <i class="fas fa-save"></i> Save
                            </button>
                            <button type="button" class="btn-cancel" onclick="closePartDetailForm()">
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
        let deletePartDetailId = null;

        // ✅ SHOW DELETE MODAL
        function showDeleteModal(partDetailId, serialNumber) {
            deletePartDetailId = partDetailId;
            const modal = document.getElementById("deleteModal");
            const message = document.getElementById("deleteModalMessage");
            message.innerHTML = "Bạn có chắc muốn xóa Part Detail:<br><strong>" + serialNumber + "</strong> (ID: " + partDetailId + ")?";
            modal.style.display = "flex";
        }

        // ✅ CLOSE DELETE MODAL
        function closeDeleteModal() {
            document.getElementById("deleteModal").style.display = "none";
            deletePartDetailId = null;
        }

        // ✅ CONFIRM DELETE ACTION
        function confirmDeleteAction() {
            if (deletePartDetailId) {
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = 'partDetail';

                const actionInput = document.createElement('input');
                actionInput.type = 'hidden';
                actionInput.name = 'action';
                actionInput.value = 'delete';

                const idInput = document.createElement('input');
                idInput.type = 'hidden';
                idInput.name = 'partDetailId';
                idInput.value = deletePartDetailId;

                form.appendChild(actionInput);
                form.appendChild(idInput);
                document.body.appendChild(form);
                form.submit();
            }
        }

        // ✅ OPEN FORM (ADD/EDIT) - FIXED STATUS LOGIC
        function openPartDetailForm(mode, partDetailId = '', partId = '', serialNumber = '', status = '', location = '') {
            const overlay = document.getElementById("partDetailFormOverlay");
            const title = document.getElementById("partDetailFormTitle");
            const actionInput = document.getElementById("partDetailAction");
            const formMessage = document.getElementById("partDetailFormMessage");
            const statusSelect = document.getElementById("status");
            const statusWarning = document.getElementById("statusWarning");

            overlay.style.display = "flex";
            formMessage.textContent = "";
            formMessage.style.color = "#dc3545";
            statusWarning.style.display = "none";

            // ✅ RESET ALL INPUTS TO ENABLED
            document.getElementById("partId").disabled = false;
            document.getElementById("serialNumber").disabled = false;
            document.getElementById("location").disabled = false;
            statusSelect.disabled = false;

            if (mode === "new") {
                title.textContent = "Add New Part Detail";
                actionInput.value = "add";
                document.getElementById("partDetailId").value = "";
                document.getElementById("partId").value = "";
                document.getElementById("serialNumber").value = "";
                document.getElementById("location").value = "";
                document.getElementById("oldStatus").value = "";

                // ✅ KHI ADD: KHÔNG CHO CHỌN INUSE
                statusSelect.innerHTML = `
                    <option value="Available">Available</option>
                    <option value="Faulty">Faulty</option>
                    <option value="Retired">Retired</option>
                `;
                statusSelect.value = "Available";

            } else {
                // ✅ EDIT MODE
                title.textContent = "Edit Part Detail";
                actionInput.value = "edit";
                document.getElementById("partDetailId").value = partDetailId;
                document.getElementById("partId").value = partId;
                document.getElementById("serialNumber").value = serialNumber;
                document.getElementById("location").value = location;
                document.getElementById("oldStatus").value = status;

                // ✅ NẾU ĐANG LÀ INUSE → KHÓA TẤT CẢ
                if (status === 'InUse') {
                    statusSelect.innerHTML = `<option value="InUse">InUse (Locked)</option>`;
                    statusSelect.value = "InUse";
                    statusSelect.disabled = true;

                    document.getElementById("partId").disabled = true;
                    document.getElementById("serialNumber").disabled = true;
                    document.getElementById("location").disabled = true;

                    formMessage.textContent = "⚠️ Trạng thái InUse không thể chỉnh sửa!";
                    formMessage.style.color = "#dc3545";

                } else {
                    // ✅ NẾU CHƯA PHẢI INUSE → CHO PHÉP CHỌN TẤT CẢ (BAO GỒM INUSE)
                    statusSelect.innerHTML = `
                        <option value="Available">Available</option>
                        <option value="InUse">InUse</option>
                        <option value="Faulty">Faulty</option>
                        <option value="Retired">Retired</option>
                    `;
                    statusSelect.value = status;
                }
            }
        }

        // ✅ CLOSE FORM
        function closePartDetailForm() {
            document.getElementById("partDetailFormOverlay").style.display = "none";
            document.getElementById("partDetailFormMessage").textContent = "";
            document.getElementById("statusWarning").style.display = "none";
        }

        // ✅ VALIDATE FORM - TRIM DATA
        function validatePartDetailForm() {
            const serialInput = document.getElementById("serialNumber");
            const statusSelect = document.getElementById("status");
            const locationInput = document.getElementById("location");
            const oldStatus = document.getElementById("oldStatus").value;
            const formMessage = document.getElementById("partDetailFormMessage");

            // ✅ TRIM ALL INPUTS
            serialInput.value = serialInput.value.trim();
            locationInput.value = locationInput.value.trim();

            const serialNumber = serialInput.value;
            const status = statusSelect.value;
            const location = locationInput.value;

            formMessage.textContent = "";
            formMessage.style.color = "#dc3545";

            // ✅ VALIDATE SERIAL NUMBER FORMAT
            const serialPattern = /^[A-Z]{3}-\d{3}-\d{4}$/;
            if (!serialPattern.test(serialNumber)) {
                formMessage.textContent = "❌ Serial Number phải theo định dạng: AAA-XXX-YYYY (VD: SNK-001-2024)";
                return false;
            }

            // ✅ VALIDATE LOCATION LENGTH
            if (location.length < 5) {
                formMessage.textContent = "❌ Location phải có ít nhất 5 ký tự!";
                return false;
            }

            if (location.length > 50) {
                formMessage.textContent = "❌ Location không được vượt quá 50 ký tự!";
                return false;
            }

            // ✅ KHÔNG CHO PHÉP EDIT NẾU ĐANG LÀ INUSE
            if (oldStatus === 'InUse') {
                formMessage.textContent = "❌ Không thể chỉnh sửa Part Detail có trạng thái InUse!";
                return false;
            }

            // ✅ CẢNH BÁO KHI CHUYỂN SANG INUSE
            if (status === 'InUse' && oldStatus !== 'InUse') {
                const confirmed = confirm("⚠️ CẢNH BÁO: Sau khi chuyển sang trạng thái InUse, bạn sẽ KHÔNG thể thay đổi lại!\n\nBạn có chắc chắn muốn tiếp tục?");
                if (!confirmed) {
                    return false;
                }
            }

            return true;
        }

        // ✅ PAGINATION LOGIC
        let currentPage = 1;
        const rowsPerPage = 10;

        function renderPartDetailTable() {
            const tableBody = document.querySelector(".inventory-table tbody");
            if (!tableBody) return;

            const keyword = document.querySelector(".search-input").value.toLowerCase().trim();
            const rows = Array.from(tableBody.rows);

            const filteredRows = rows.filter(row => {
                return Array.from(row.cells).slice(0, 9)
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
                renderPartDetailTable();
            }));

            pagination.appendChild(createBtn("‹ Prev", () => {
                if (currentPage > 1) {
                    currentPage--;
                    renderPartDetailTable();
                }
            }));

            let start = Math.max(currentPage - 2, 1);
            let end = Math.min(start + 4, totalPages);
            for (let i = start; i <= end; i++) {
                pagination.appendChild(createBtn(i, () => {
                    currentPage = i;
                    renderPartDetailTable();
                }, i === currentPage));
            }

            pagination.appendChild(createBtn("Next ›", () => {
                if (currentPage < totalPages) {
                    currentPage++;
                    renderPartDetailTable();
                }
            }));

            pagination.appendChild(createBtn("Last »", () => {
                currentPage = totalPages;
                renderPartDetailTable();
            }));
        }

        // ✅ DOM LOADED EVENTS
        document.addEventListener("DOMContentLoaded", function() {
            renderPartDetailTable();

            // ✅ SEARCH INPUT - TRIM
            const searchInput = document.querySelector(".search-input");
            if (searchInput) {
                searchInput.addEventListener("input", () => {
                    currentPage = 1;
                    renderPartDetailTable();
                });
            }

            // ✅ CLOSE MODALS ON OUTSIDE CLICK
            const formOverlay = document.getElementById("partDetailFormOverlay");
            if (formOverlay) {
                formOverlay.addEventListener('click', function (e) {
                    if (e.target === this) {
                        closePartDetailForm();
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

            // ✅ SERIAL NUMBER - AUTO UPPERCASE & VALIDATION
            const serialInput = document.getElementById("serialNumber");
            if (serialInput) {
                serialInput.addEventListener("input", function() {
                    this.value = this.value.toUpperCase().trim();
                    const value = this.value;
                    const formMessage = document.getElementById("partDetailFormMessage");
                    const pattern = /^[A-Z]{3}-\d{3}-\d{4}$/;

                    if (value.length === 0) {
                        formMessage.textContent = "";
                    } else if (pattern.test(value)) {
                        formMessage.textContent = "✓ Serial Number hợp lệ";
                        formMessage.style.color = "#28a745";
                    } else {
                        formMessage.textContent = "⚠️ Format: AAA-XXX-YYYY (VD: SNK-001-2024)";
                        formMessage.style.color = "#ff9800";
                    }
                });
            }

            // ✅ LOCATION INPUT - TRIM & VALIDATION
            const locationInput = document.getElementById("location");
            if (locationInput) {
                locationInput.addEventListener("input", function() {
                    const length = this.value.trim().length;
                    const formMessage = document.getElementById("partDetailFormMessage");

                    if (length === 0) {
                        formMessage.textContent = "";
                    } else if (length < 5) {
                        formMessage.textContent = `⚠️ Location: Còn thiếu ${5 - length} ký tự`;
                        formMessage.style.color = "#ff9800";
                    } else if (length > 50) {
                        formMessage.textContent = `❌ Location: Vượt quá ${length - 50} ký tự`;
                        formMessage.style.color = "#dc3545";
                    } else {
                        formMessage.textContent = `✓ Location: ${length}/50 ký tự`;
                        formMessage.style.color = "#28a745";
                    }
                });
            }

            // ✅ STATUS SELECT - WARNING FOR INUSE
            const statusSelect = document.getElementById("status");
            const statusWarning = document.getElementById("statusWarning");
            if (statusSelect && statusWarning) {
                statusSelect.addEventListener("change", function() {
                    if (this.value === "InUse") {
                        statusWarning.style.display = "block";
                    } else {
                        statusWarning.style.display = "none";
                    }
                });
            }

            // ✅ AUTO HIDE ALERTS AFTER 5 SECONDS
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