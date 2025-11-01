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
    <title>CRM System - Thống kê thiết bị</title>

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

.stat-card.inuse { border-left-color: #28a745; }
.stat-card.faulty { border-left-color: #dc3545; }
.stat-card.available { border-left-color: #ffc107; }
.stat-card.retired { border-left-color: #6c757d; }

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

.stat-card.inuse .icon { color: #28a745; }
.stat-card.faulty .icon { color: #dc3545; }
.stat-card.available .icon { color: #ffc107; }
.stat-card.retired .icon { color: #6c757d; }
.stat-card .icon { color: #007bff; }

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
    grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
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

/* TABLE */
.stats-table {
    width: 100%;
    background: white;
    border-collapse: collapse;
    border-radius: 8px;
    overflow: hidden;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
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

.stats-table tbody td {
    padding: 12px 16px;
    border-bottom: 1px solid #e0e0e0;
    font-size: 13px;
    color: #666;
}

.stats-table tbody tr:hover {
    background-color: #f8f9fa;
}

.stats-table tbody tr:last-child td {
    border-bottom: none;
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

.status-badge.faulty {
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
                <a href="login">Xin chào ${sessionScope.username}</a>
            </div>
        </div>
    </nav>

    <div class="container">
        <!-- Sidebar -->
        <div class="sidebar">
            <div>
                <a href="storekeeper"><i class="fas fa-user-cog"></i><span>Trang chủ</span></a>
                <a href="manageProfile"><i class="fas fa-user-circle"></i><span>Hồ Sơ</span></a>
                <a href="partStatistics" class="active"><i class="fas fa-chart-line"></i><span>Thống kê</span></a>
                <a href="numberInventory"><i class="fas fa-boxes"></i><span>Số lượng tồn kho</span></a>
                <a href="numberPart"><i class="fas fa-list"></i><span>Danh sách hàng tồn kho</span></a>
                <a href="transactionHistory"><i class="fas fa-history"></i><span>Lịch sử giao dịch</span></a>
                <a href="partRequest"><i class="fas fa-tools"></i><span>Yêu cầu thiết bị</span></a>
                <a href="#"><i class="fas fa-file-invoice"></i><span>Danh sách hóa đơn</span></a>
                <a href="#"><i class="fas fa-wrench"></i><span>Báo cáo sửa chữa</span></a>
                <a href="partDetail"><i class="fas fa-truck-loading"></i><span>Chi tiết thiết bị</span></a>
            </div>
            <a href="logout" style="background: rgba(255, 255, 255, 0.1); border-top: 1px solid rgba(255,255,255,0.2); text-align: center; font-weight: 600;">
                <i class="fas fa-sign-out-alt"></i><span>Đăng xuất</span>
            </a>
        </div>

        <!-- Content -->
        <div class="content">
            <div class="page-header">
                <h2><i class="fas fa-chart-bar"></i> Thống kê thiết bị</h2>
                <button class="btn-export" onclick="window.print()">
                    <i class="fas fa-print"></i> In báo cáo
                </button>
            </div>

            <!-- Statistics Overview -->
            <c:if test="${not empty overview}">
                <div class="stats-overview">
                    <div class="stat-card inuse">
                        <i class="fas fa-tools icon"></i>
                        <h3>Đang sử dụng (InUse)</h3>
                        <div class="number">${overview.inUseCount}</div>
                    </div>
                    <div class="stat-card faulty">
                        <i class="fas fa-exclamation-triangle icon"></i>
                        <h3>Hỏng hóc (Faulty)</h3>
                        <div class="number">${overview.faultyCount}</div>
                    </div>
                    <div class="stat-card available">
                        <i class="fas fa-check-circle icon"></i>
                        <h3>Sẵn sàng (Available)</h3>
                        <div class="number">${overview.availableCount}</div>
                    </div>
                    <div class="stat-card retired">
                        <i class="fas fa-archive icon"></i>
                        <h3>Đã loại bỏ (Retired)</h3>
                        <div class="number">${overview.retiredCount}</div>
                    </div>
                    <div class="stat-card">
                        <i class="fas fa-history icon"></i>
                        <h3>Tổng lịch sử thay đổi</h3>
                        <div class="number">${overview.totalChanges}</div>
                    </div>
                </div>
            </c:if>

            <!-- Filter Panel -->
            <div class="filter-panel">
                <form action="partStatistics" method="GET" class="filter-form">
                    <div class="form-group">
                        <label><i class="fas fa-filter"></i> Trạng thái</label>
                        <select name="status">
                            <option value="InUse" ${statusFilter == 'InUse' ? 'selected' : ''}>InUse - Đang sử dụng</option>
                            <option value="Faulty" ${statusFilter == 'Faulty' ? 'selected' : ''}>Faulty - Hỏng hóc</option>
                            <option value="Available" ${statusFilter == 'Available' ? 'selected' : ''}>Available - Sẵn sàng</option>
                            <option value="Retired" ${statusFilter == 'Retired' ? 'selected' : ''}>Retired - Đã loại bỏ</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label><i class="fas fa-calendar"></i> Lọc theo</label>
                        <select name="timeFilter" id="timeFilterSelect" onchange="toggleDateInputs()">
                            <option value="day" ${timeFilter == 'day' ? 'selected' : ''}>Hôm nay</option>
                            <option value="week" ${timeFilter == 'week' ? 'selected' : ''}>Tuần này</option>
                            <option value="month" ${timeFilter == 'month' ? 'selected' : ''}>Tháng này</option>
                            <option value="year" ${timeFilter == 'year' ? 'selected' : ''}>Năm này</option>
                            <option value="custom" ${timeFilter == 'custom' ? 'selected' : ''}>Tùy chỉnh</option>
                        </select>
                    </div>

                    <div class="form-group" id="fromDateGroup" style="display: none;">
                        <label>Từ ngày</label>
                        <input type="date" name="fromDate" value="${fromDate}">
                    </div>

                    <div class="form-group" id="toDateGroup" style="display: none;">
                        <label>Đến ngày</label>
                        <input type="date" name="toDate" value="${toDate}">
                    </div>

                    <div class="form-group">
                        <label><i class="fas fa-eye"></i> Kiểu hiển thị</label>
                        <select name="viewType">
                            <option value="detail" ${viewType == 'detail' ? 'selected' : ''}>Chi tiết từng thiết bị</option>
                            <option value="summary" ${viewType == 'summary' ? 'selected' : ''}>Tổng hợp theo Technician</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <button type="submit" class="btn-filter">
                            <i class="fas fa-search"></i> Xem thống kê
                        </button>
                    </div>
                </form>
            </div>

           <!-- Detail View -->
<c:if test="${viewType == 'detail'}">
    <h3 class="section-title">
        <i class="fas fa-list"></i> 
        Chi tiết: ${statusFilter}
        <span class="count">${totalCount} bản ghi</span>
    </h3>
    <table class="stats-table">
        <thead>
            <tr>
                <th>ID</th>
                <th>Serial Number</th>
                <th>Part Name</th>
                <!-- ✅ BỎ dòng này: <th>Category</th> -->
                <th>Trạng thái cũ</th>
                <th>Trạng thái mới</th>
                <th>Location</th>
                <th>Technician</th>
                <th>Ngày thay đổi</th>
                <th>Ghi chú</th>
            </tr>
        </thead>
        <tbody>
            <c:choose>
                <c:when test="${not empty detailList}">
                    <c:forEach items="${detailList}" var="item">
                        <tr>
                            <td>${item.partDetailId}</td>
                            <td><strong>${item.serialNumber}</strong></td>
                            <td>${item.partName}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${empty item.oldStatus}">
                                        <span style="color: #999; font-style: italic;">Mới tạo</span>
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
                                <i class="fas fa-user-tie"></i> ${item.technicianName}
                            </td>
                            <td>
                                <fmt:formatDate value="${item.changedDate}" pattern="dd/MM/yyyy HH:mm"/>
                            </td>
                            <td style="max-width: 200px; overflow: hidden; text-overflow: ellipsis;">
                                ${item.notes}
                            </td>
                        </tr>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <tr>
                        <td colspan="9">  <!-- ✅ ĐỔI từ 10 thành 9 -->
                            <div class="no-data">
                                <i class="fas fa-inbox"></i>
                                <p>Không có dữ liệu trong khoảng thời gian này</p>
                            </div>
                        </td>
                    </tr>
                </c:otherwise>
            </c:choose>
        </tbody>
    </table>
</c:if>

            <!-- Summary View -->
            <c:if test="${viewType == 'summary'}">
                <h3 class="section-title">
                    <i class="fas fa-users"></i> 
                    Tổng hợp theo Technician: ${statusFilter}
                </h3>
                <table class="stats-table">
                    <thead>
                        <tr>
                            <th>Technician ID</th>
                            <th>Tên Technician</th>
                            <th style="text-align: center;">Tổng số lượt thay đổi</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty techStats}">
                                <c:forEach items="${techStats}" var="tech" varStatus="status">
                                    <tr>
                                        <td>${tech.changedBy}</td>
                                        <td>
                                            <i class="fas fa-user-tie" style="color: #007bff;"></i> 
                                            <strong>${tech.technicianName}</strong>
                                        </td>
                                        <td style="text-align: center;">
                                            <span style="font-size: 20px; font-weight: 700; color: #28a745;">
                                                ${tech.totalChanges}
                                            </span>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="3">
                                        <div class="no-data">
                                            <i class="fas fa-inbox"></i>
                                            <p>Không có dữ liệu trong khoảng thời gian này</p>
                                        </div>
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </c:if>
        </div>
    </div>

    <script>
        function toggleDateInputs() {
            const timeFilter = document.getElementById('timeFilterSelect').value;
            const fromDate = document.getElementById('fromDateGroup');
            const toDate = document.getElementById('toDateGroup');
            
            if (timeFilter === 'custom') {
                fromDate.style.display = 'flex';
                toDate.style.display = 'flex';
            } else {
                fromDate.style.display = 'none';
                toDate.style.display = 'none';
            }
        }
        
        // Initialize on load
        document.addEventListener('DOMContentLoaded', function() {
            toggleDateInputs();
        });
    </script>
</body>
</html>