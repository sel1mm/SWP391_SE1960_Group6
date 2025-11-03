<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <title>CRM System - Quản lý Kho</title>
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
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .content h2::before {
            content: '⚙️';
            font-size: 32px;
        }

        /* KPI Cards */
        .kpi-container {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
            margin-bottom: 40px;
        }

        .kpi-card {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            border: 1px solid #e0e0e0;
            transition: all 0.3s;
        }

        .kpi-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.15);
        }

        .kpi-card h3 {
            font-size: 13px;
            color: #666;
            margin-bottom: 12px;
            font-weight: 500;
        }

        .kpi-card p {
            font-size: 26px;
            font-weight: 600;
            margin: 0;
            color: #333;
        }

        /* Chart Container */
        .chart-container {
            background: white;
            padding: 24px;
            border-radius: 8px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            border: 1px solid #e0e0e0;
            margin-bottom: 40px;
        }

        .chart-container > p {
            font-size: 18px;
            font-weight: 600;
            margin: 0 0 20px 0;
            color: #333;
        }

        .card {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 30px;
        }

        #inventoryChart {
            width: 180px !important;
            height: 180px !important;
        }

        .legend {
            display: flex;
            flex-direction: column;
            gap: 10px;
        }

        .legend-item {
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 13px;
            color: #666;
        }

        .color-dot {
            width: 12px;
            height: 12px;
            border-radius: 50%;
        }

        .label-value {
            font-weight: 600;
            font-size: 15px;
            color: #333;
            margin-left: auto;
        }

        /* List Container */
        .list-container {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 30px;
            margin-top: 30px;
        }

        .left-list, .right-list {
            background: white;
            padding: 24px;
            border-radius: 8px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            border: 1px solid #e0e0e0;
        }

        .left-list::after, .right-list::after {
            content: "";
            display: block;
            clear: both;
        }

        .title {
            float: left;
            font-weight: 600;
            font-size: 16px;
            color: #333;
            margin-bottom: 20px;
        }

        .more {
            float: right;
            font-size: 13px;
            color: #666;
            cursor: pointer;
            transition: color 0.3s;
            font-weight: 400;
        }

        .more:hover {
            color: #333;
        }

        /* Table Styles */
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
            background-color: white;
        }

        th, td {
            border: 1px solid #e0e0e0;
            padding: 10px 12px;
            text-align: left;
            font-size: 13px;
        }

        th {
            background-color: #f8f9fa;
            color: #333;
            font-weight: 600;
            border-bottom: 2px solid #dee2e6;
        }

        tr:nth-child(even) {
            background-color: #fafafa;
        }

        tr:hover {
            background-color: #f0f0f0;
        }

        td {
            color: #666;
        }

        .empty-row {
            text-align: center;
            color: #999;
            font-style: italic;
        }
    </style>
</head>
<body>
    <!-- Sidebar Full Height -->
    <div class="sidebar">
        <div class="sidebar-logo">CRM System</div>
        <div class="sidebar-menu">
            <a href="storekeeper" class="active"><i class="fas fa-home"></i><span>Trang chủ</span></a>
            <a href="manageProfile"><i class="fas fa-user-circle"></i><span>Hồ Sơ</span></a>
            <a href="#"><i class="fas fa-chart-line"></i><span>Thống kê</span></a>
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

    <!-- Top Navbar (Right Side Only) -->
    <nav class="navbar">
        <div class="user-info">
            Xin chào ${sessionScope.username}
        </div>
    </nav>

    <!-- Main Content -->
    <div class="container">
        <div class="content">
            <!-- KPI Section -->
            <section>
                <h2>Chỉ số quản lý kho</h2>
                
                <div class="kpi-container">
                    <div class="kpi-card">
                        <h3>Tổng số loại thiết bị trong kho</h3>
                        <p>${totalEquipmentTypes}</p>
                    </div>
                    <div class="kpi-card">
                        <h3>Tổng số loại linh kiện trong kho</h3>
                        <p>${totalPartTypes}</p>
                    </div>
                    <div class="kpi-card">
                        <h3>Tổng số loại linh kiện sắp hết</h3>
                        <p>${lowStockCount}</p>
                    </div>
                    <div class="kpi-card">
                        <h3>Tổng số linh kiện sẵn sàng trong kho</h3>
                        <p>${availableCount}</p>
                    </div>
                    <div class="kpi-card">
                        <h3>Tổng số linh kiện bị hỏng trong kho</h3>
                        <p>${faultyCount}</p>
                    </div>
                    <div class="kpi-card">
                        <h3>Tổng số linh kiện đang được sử dụng</h3>
                        <p>${inUseCount}</p>
                    </div>
                    <div class="kpi-card">
                        <h3>% Tổng số linh kiện sẵn sàng</h3>
                        <p>${availablePercent}%</p>
                    </div>
                    <div class="kpi-card">
                        <h3>% Số lượng linh kiện ngừng dùng</h3>
                        <p>${retiredPercent}%</p>
                    </div>
                </div>
            </section>
            
            <!-- Chart Section -->
            <section>
                <div class="chart-container">
                    <p>Tình trạng linh kiện</p>
                    <div class="card">
                        <canvas id="inventoryChart"></canvas>
                        <div class="legend">
                            <div class="legend-item">
                                <span class="color-dot" style="background:#00b894;"></span> 
                                Linh kiện có sẵn
                                <span class="label-value">${chartInStock}</span>
                            </div>
                            <div class="legend-item">
                                <span class="color-dot" style="background:#6c5ce7;"></span> 
                                Linh kiện hết hàng
                                <span class="label-value">${chartOutOfStock}</span>
                            </div>
                            <div class="legend-item">
                                <span class="color-dot" style="background:#fdcb6e;"></span> 
                                Linh kiện sắp hết
                                <span class="label-value">${chartLowStock}</span>
                            </div>
                            <div class="legend-item">
                                <span class="color-dot" style="background:#d63031;"></span> 
                                Linh kiện ngừng dùng
                                <span class="label-value">${chartDeadStock}</span>
                            </div>
                        </div>
                    </div>
                </div>
            </section>
            
            <!-- Tables Section -->
            <section>
                <div class="list-container">
                    <div class="left-list">
                        <p class="title">Linh kiện sắp hết</p>
                        <a href="numberPart" class="more">Xem thêm <i class="fa-solid fa-arrow-right"></i></a>
                        <table border="1">
                            <thead>
                                <tr>
                                    <th>Part ID</th>
                                    <th>Tên linh kiện</th>
                                    <th>Danh mục</th>
                                    <th>Số lượng</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${not empty lowStockParts}">
                                        <c:forEach var="part" items="${lowStockParts}">
                                            <tr>
                                                <td>${part.partId}</td>
                                                <td>${part.partName}</td>
                                                <td>${part.categoryName != null ? part.categoryName : 'N/A'}</td>
                                                <td>${part.quantity}</td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="4" class="empty-row">Không có linh kiện sắp hết</td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>
                    
                    <div class="right-list">
                        <p class="title">Những linh kiện được sử dụng nhiều</p>
                        <a href="numberPart" class="more">Xem thêm <i class="fa-solid fa-arrow-right"></i></a>
                        <table border="1">
                            <thead>
                                <tr>
                                    <th>Part ID</th>
                                    <th>Tên linh kiện</th>
                                    <th>Danh mục</th>
                                    <th>Đang dùng</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${not empty mostUsedParts}">
                                        <c:forEach var="part" items="${mostUsedParts}">
                                            <tr>
                                                <td>${part.partId}</td>
                                                <td>${part.partName}</td>
                                                <td>${part.categoryName != null ? part.categoryName : 'N/A'}</td>
                                                <td>${part.quantity}</td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="4" class="empty-row">Không có dữ liệu</td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>
                </div>
            </section>
        </div>
    </div>

    <script>
        // Chart: Equipment Status - DỮ LIỆU THẬT TỪ SERVER
        const ctx = document.getElementById('inventoryChart').getContext('2d');
        new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: ['Có sẵn', 'Hết hàng', 'Sắp hết', 'Ngừng dùng'],
                datasets: [{
                    data: [
                        ${chartInStock}, 
                        ${chartOutOfStock}, 
                        ${chartLowStock}, 
                        ${chartDeadStock}
                    ],
                    backgroundColor: ['#00b894', '#6c5ce7', '#fdcb6e', '#d63031'],
                    borderWidth: 0
                }]
            },
            options: {
                cutout: '70%',
                plugins: { legend: { display: false } }
            }
        });
    </script>
</body>
</html>