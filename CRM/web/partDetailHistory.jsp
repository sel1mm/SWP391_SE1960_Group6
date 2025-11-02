<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
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

/* NAVBAR */
.navbar {
    background: #000000;
    padding: 1rem 0;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    position: sticky;
    top: 0;
    z-index: 1000;
}

.nav-container {
    max-width: 100%;
    padding: 0 2rem;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.logo {
    color: white;
    font-size: 24px;
    font-weight: 600;
}

.nav-links {
    display: flex;
    gap: 30px;
    align-items: center;
}

.nav-links a {
    color: white;
    text-decoration: none;
    font-weight: 400;
    font-size: 14px;
    transition: all 0.3s ease;
    padding: 8px 16px;
    border-radius: 4px;
}

.nav-links a:hover {
    background: rgba(255,255,255,0.1);
}

/* SIDEBAR */
.sidebar {
    width: 220px;
    min-height: calc(100vh - 65px);
    position: fixed;
    top: 65px;
    left: 0;
    background: #000000;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    box-shadow: 2px 0 4px rgba(0,0,0,0.1);
}

.sidebar a {
    color: white;
    text-decoration: none;
    padding: 12px 20px;
    font-size: 14px;
    display: flex;
    align-items: center;
    gap: 12px;
    transition: all 0.2s ease;
    font-weight: 400;
    border-left: 3px solid transparent;
}

.sidebar a:hover, .sidebar a.active {
    background: rgba(255,255,255,0.08);
    border-left: 3px solid white;
}

/* CONTENT */
.content {
    margin-left: 220px;
    padding: 30px 40px;
    background: #f5f5f5;
    min-height: calc(100vh - 65px);
    width: calc(100% - 220px);
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
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
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
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    margin-bottom: 20px;
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
}

/* TABLE - ✅ CẬP NHẬT CHO 11 CỘT */
.stats-table {
    width: 100%;
    background: white;
    border-collapse: collapse;
    border-radius: 8px;
    overflow: hidden;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    table-layout: fixed;
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

/* ✅ COLUMN WIDTHS - 12 CỘT */
.stats-table thead th:nth-child(1) { width: 3%; }   /* ID */
.stats-table thead th:nth-child(2) { width: 9%; }   /* Serial Number */
.stats-table thead th:nth-child(3) { width: 9%; }   /* Part Name */
.stats-table thead th:nth-child(4) { width: 8%; }   /* Category */
.stats-table thead th:nth-child(5) { width: 7%; }   /* Hành động */
.stats-table thead th:nth-child(6) { width: 7%; }   /* Trạng thái cũ */
.stats-table thead th:nth-child(7) { width: 7%; }   /* Trạng thái mới */
.stats-table thead th:nth-child(8) { width: 9%; }   /* Location */
.stats-table thead th:nth-child(9) { width: 8%; }   /* Người thực hiện */
.stats-table thead th:nth-child(10) { width: 11%; } /* Thời gian */
.stats-table thead th:nth-child(11) { width: 11%; } /* Ghi chú */
.stats-table thead th:nth-child(12) { width: 11%; } /* Action - MỚI */

.stats-table tbody td {
    padding: 12px 16px;
    border-bottom: 1px solid #e0e0e0;
    font-size: 13px;
    color: #666;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}

.stats-table tbody tr:hover {
    background-color: #f8f9fa;
}

.stats-table tbody tr:last-child td {
    border-bottom: none;
}

/* Hover để xem full text cho Ghi chú */
.stats-table tbody td:nth-child(11):hover {
    white-space: normal;
    overflow: visible;
    word-wrap: break-word;
    background-color: #fffbea;
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
    background: rgba(0,0,0,0.6);
    display: none;
    justify-content: center;
    align-items: center;
    z-index: 3000;
    animation: fadeIn 0.3s ease;
}

.modal-overlay.show {
    display: flex;
}

@keyframes fadeIn {
    from { opacity: 0; }
    to { opacity: 1; }
}

.modal-container {
    background: white;
    border-radius: 12px;
    width: 600px;
    max-width: 95%;
    max-height: 90vh;
    overflow-y: auto;
    box-shadow: 0 10px 40px rgba(0,0,0,0.3);
    animation: slideUp 0.3s ease;
}

@keyframes slideUp {
    from { 
        transform: translateY(50px);
        opacity: 0;
    }
    to { 
        transform: translateY(0);
        opacity: 1;
    }
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

.status-badge.new {
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
    color: #666;
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
    .stats-overview {
        grid-template-columns: 1fr 1fr;
    }
    .filter-form {
        grid-template-columns: 1fr;
    }
}
    </style>
</head>

<body>
    <!-- Navbar -->
    <nav class="navbar">
        <div class="nav-container">
            <div class="logo">CRM System</div>
            <div class="nav-links">
                <a href="#"><i class="fas fa-envelope"></i> Tin nhắn</a>
                <a href="#"><i class="fas fa-bell"></i> Thông báo</a>
                <a href="login">Xin chào ${sessionScope.session_login.fullName}</a>
            </div>
        </div>
    </nav>

    <div class="container">
        <!-- Sidebar -->
        <div class="sidebar">
            <div class="sidebar navbar nav-container2">
                <a href="storekeeper"><i class="fas fa-user-cog"></i><span>Trang chủ</span></a>
                <a href="manageProfile"><i class="fas fa-user-circle"></i><span>Hồ Sơ</span></a>
                <a href="#"><i class="fas fa-chart-line"></i><span>Thống kê</span></a>
                <a href="numberPart"><i class="fas fa-list"></i><span>Danh sách linh kiện</span></a>
                <a href="numberEquipment"><i class="fas fa-list"></i><span>Danh sách thiết bị </span></a>
                <a href="PartDetailHistoryServlet" class="active"><i class="fas fa-history"></i><span>Lịch sử giao dịch</span></a>
                <a href="partDetail"><i class="fas fa-truck-loading"></i><span>Chi tiết linh kiện</span></a>
                 <a href="category" class="active"><i class="fas fa-tags"></i><span>Quản lý danh mục</span></a>
                <a href="logout" style="margin-top: auto; background: rgba(255, 255, 255, 0.05); border-top: 1px solid rgba(255,255,255,0.1); text-align: center; font-weight: 500;">
                    <i class="fas fa-sign-out-alt"></i><span>Đăng xuất</span>
                </a>
            </div>
        </div>

        <!-- Content -->
        <div class="content">
            <div class="page-header">
                <h2><i class="fas fa-history"></i> Lịch sử linh kiện</h2>
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

            <!-- History Table - ✅ THÊM CỘT ACTION -->
            <h3 class="section-title">
                <i class="fas fa-list"></i> 
                Lịch sử chi tiết
                <span class="count">${totalCount} bản ghi</span>
            </h3>
            <table class="stats-table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Serial Number</th>
                        <th>Part Name</th>
                        <th>Category</th>
                        <th>Hành động</th>
                        <th>Trạng thái cũ</th>
                        <th>Trạng thái mới</th>
                        <th>Location</th>
                        <th>Người thực hiện</th>
                        <th>Thời gian</th>
                        <th>Ghi chú</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${not empty historyList}">
                            <c:forEach items="${historyList}" var="item">
                                <tr>
                                    <td>${item.historyId}</td>
                                    <td><strong>${item.serialNumber}</strong></td>
                                    <td>${item.partName}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty item.categoryName}">
                                                <span style="background: #e7f3ff; padding: 3px 8px; border-radius: 4px; font-size: 12px; font-weight: 500; color: #0066cc;">
                                                    ${item.categoryName}
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span style="color: #999; font-style: italic;">N/A</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
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
                                    <td>${item.location}</td>
                                    <td>
                                        <i class="fas fa-user"></i> ${item.username}
                                    </td>
                                    <td>
                                        <fmt:formatDate value="${item.changedDate}" pattern="dd/MM/yyyy HH:mm:ss"/>
                                    </td>
                                    <td>
                                        ${item.notes}
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
                                <td colspan="12">
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

            <!-- ✅ MODAL DETAILS -->
            <div class="modal-overlay" id="detailsModal">
                <div class="modal-container">
                    <div class="modal-header">
                        <h3><i class="fas fa-info-circle"></i> Chi tiết lịch sử</h3>
                        <button class="modal-close" onclick="closeModal()">
                            <i class="fas fa-times"></i>
                        </button>
                    </div>
                    <div class="modal-body">
                        <!-- Thông tin cơ bản -->
                        <div class="detail-section">
                            <h4><i class="fas fa-clipboard-list"></i> Thông tin cơ bản</h4>
                            <div class="detail-grid">
                                <div class="detail-label">History ID:</div>
                                <div class="detail-value" id="modal-historyId">-</div>
                                
                                <div class="detail-label">Serial Number:</div>
                                <div class="detail-value"><strong id="modal-serialNumber">-</strong></div>
                                
                                <div class="detail-label">Part Name:</div>
                                <div class="detail-value" id="modal-partName">-</div>
                                
                                <div class="detail-label">Category:</div>
                                <div class="detail-value" id="modal-category">-</div>
                                
                                <div class="detail-label">Location:</div>
                                <div class="detail-value" id="modal-location">-</div>
                            </div>
                        </div>

                        <!-- Thông tin thay đổi -->
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

                        <!-- Thông tin người thực hiện -->
                        <div class="detail-section">
                            <h4><i class="fas fa-user-clock"></i> Thông tin người thực hiện</h4>
                            <div class="detail-grid">
                                <div class="detail-label">Người thực hiện:</div>
                                <div class="detail-value"><i class="fas fa-user"></i> <span id="modal-username">-</span></div>
                                
                                <div class="detail-label">Thời gian:</div>
                                <div class="detail-value"><i class="fas fa-clock"></i> <span id="modal-time">-</span></div>
                            </div>
                        </div>

                        <!-- Ghi chú -->
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

    <script>
        // ========== MODAL FUNCTIONS ==========
        function showDetails(historyId, serialNumber, partName, category, oldStatus, newStatus, location, username, time, notes, actionType) {
            // Set basic info
            document.getElementById('modal-historyId').textContent = historyId;
            document.getElementById('modal-serialNumber').textContent = serialNumber;
            document.getElementById('modal-partName').textContent = partName || '-';
            document.getElementById('modal-category').innerHTML = category !== 'N/A' 
                ? '<span style="background: #e7f3ff; padding: 4px 10px; border-radius: 6px; font-weight: 500; color: #0066cc;">' + category + '</span>'
                : '<span style="color: #999; font-style: italic;">N/A</span>';
            document.getElementById('modal-location').textContent = location || '-';
            
            // Set action type
            const actionBadge = actionType === 'add' 
                ? '<span class="action-badge add"><i class="fas fa-plus"></i> Thêm mới</span>'
                : '<span class="action-badge update"><i class="fas fa-edit"></i> Cập nhật</span>';
            document.getElementById('modal-actionType').innerHTML = actionBadge;
            
            // Set status change
            const oldStatusClass = oldStatus.toLowerCase().replace(/\s+/g, '');
            const newStatusClass = newStatus.toLowerCase().replace(/\s+/g, '');
            
            document.getElementById('modal-oldStatus').innerHTML = 
                '<span class="status-badge ' + oldStatusClass + '">' + oldStatus + '</span>';
            document.getElementById('modal-newStatus').innerHTML = 
                '<span class="status-badge ' + newStatusClass + '">' + newStatus + '</span>';
            
            // Set user and time
            document.getElementById('modal-username').textContent = username || '-';
            document.getElementById('modal-time').textContent = time || '-';
            
            // Set notes
            document.getElementById('modal-notes').textContent = notes || 'Không có ghi chú';
            
            // Show modal
            document.getElementById('detailsModal').classList.add('show');
            document.body.style.overflow = 'hidden';
        }

        function closeModal() {
            document.getElementById('detailsModal').classList.remove('show');
            document.body.style.overflow = 'auto';
        }

        // Close modal when clicking outside
        document.addEventListener('DOMContentLoaded', function() {
            const modal = document.getElementById('detailsModal');
            if (modal) {
                modal.addEventListener('click', function(e) {
                    if (e.target === this) {
                        closeModal();
                    }
                });
            }
        });

        // Close modal with ESC key
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                closeModal();
            }
        });

    <script>
        // ========== MODAL FUNCTIONS ==========
        function showDetails(button) {
            // Get data from button attributes
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
            
            console.log('=== Modal Data ===');
            console.log('History ID:', historyId);
            console.log('Serial:', serialNumber);
            console.log('Category:', category);
            console.log('Notes:', notes);
            
            // Set basic info
            document.getElementById('modal-historyId').textContent = historyId || '-';
            document.getElementById('modal-serialNumber').textContent = serialNumber || '-';
            document.getElementById('modal-partName').textContent = partName || '-';
            
            // Set category
            const categoryEl = document.getElementById('modal-category');
            if (category && category !== 'N/A' && category !== 'null') {
                categoryEl.innerHTML = '<span style="background: #e7f3ff; padding: 4px 10px; border-radius: 6px; font-weight: 500; color: #0066cc;">' + category + '</span>';
            } else {
                categoryEl.innerHTML = '<span style="color: #999; font-style: italic;">N/A</span>';
            }
            
            document.getElementById('modal-location').textContent = location || '-';
            
            // Set action type
            const actionBadge = actionType === 'add' 
                ? '<span class="action-badge add"><i class="fas fa-plus"></i> Thêm mới</span>'
                : '<span class="action-badge update"><i class="fas fa-edit"></i> Cập nhật</span>';
            document.getElementById('modal-actionType').innerHTML = actionBadge;
            
            // Set status change
            const oldStatusClass = oldStatus.toLowerCase().replace(/\s+/g, '');
            const newStatusClass = newStatus.toLowerCase().replace(/\s+/g, '');
            
            document.getElementById('modal-oldStatus').innerHTML = 
                '<span class="status-badge ' + oldStatusClass + '">' + oldStatus + '</span>';
            document.getElementById('modal-newStatus').innerHTML = 
                '<span class="status-badge ' + newStatusClass + '">' + newStatus + '</span>';
            
            // Set user and time
            document.getElementById('modal-username').textContent = username || '-';
            document.getElementById('modal-time').textContent = time || '-';
            
            // Set notes
            document.getElementById('modal-notes').textContent = notes || 'Không có ghi chú';
            
            // Show modal
            document.getElementById('detailsModal').classList.add('show');
            document.body.style.overflow = 'hidden';
        }

        function closeModal() {
            document.getElementById('detailsModal').classList.remove('show');
            document.body.style.overflow = 'auto';
        }

        // Event delegation for Details buttons
        document.addEventListener('DOMContentLoaded', function() {
            // Add click event to all detail buttons
            document.querySelectorAll('.btn-details').forEach(function(button) {
                button.addEventListener('click', function() {
                    showDetails(this);
                });
            });
            
            // Close modal when clicking outside
            const modal = document.getElementById('detailsModal');
            if (modal) {
                modal.addEventListener('click', function(e) {
                    if (e.target === this) {
                        closeModal();
                    }
                });
            }
            
            // Auto set default dates if empty
            const fromDate = document.querySelector('input[name="fromDate"]');
            const toDate = document.querySelector('input[name="toDate"]');
            
            if (fromDate && !fromDate.value) {
                const date = new Date();
                date.setDate(1); // First day of month
                fromDate.value = date.toISOString().split('T')[0];
            }
            
            if (toDate && !toDate.value) {
                const date = new Date();
                toDate.value = date.toISOString().split('T')[0];
            }
        });

        // Close modal with ESC key
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                closeModal();
            }
        });
    </script>
</body>
</html>