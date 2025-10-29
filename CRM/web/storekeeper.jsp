<%-- 
    Document   : customer
    Created on : Oct 10, 2025, 12:30:40 AM
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>





<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
           
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
        
        <title>CRM System - Quản lý Khách hàng Chuyên nghiệp</title>
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

/* Navigation Bar */
.navbar {
    background: #000000;
    padding: 1rem 0;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    position: sticky;
    top: 0;
    z-index: 1000;
    width: 100%;
}

.nav-container {
    max-width: 100%;
    padding: 0 2rem;
    margin: 0;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.logo {
    color: white;
    font-size: 24px;
    font-weight: 600;
    display: flex;
    align-items: center;
    gap: 10px;
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
    transition: all 0.3s;
    padding: 8px 16px;
    border-radius: 4px;
}

.nav-links a:hover {
    background: rgba(255,255,255,0.1);
}

.btn-login {
    background: transparent;
    color: white;
    padding: 8px 16px;
    border-radius: 4px;
    font-weight: 400;
}

/* Sidebar */
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
    transition: all 0.2s;
    border-left: 3px solid transparent;
}

.sidebar a:hover {
    background: rgba(255,255,255,0.08);
    border-left: 3px solid white;
}

.sidebar a i {
    min-width: 18px;
    text-align: center;
    font-size: 16px;
}

.container {
    display: flex;
    margin-top: 0;
    width: 100%;
}

.content {
    margin-left: 220px;
    padding: 30px 40px;
    min-height: calc(100vh - 65px);
    width: calc(100% - 220px);
    background: #f5f5f5;
}

.content h2 {
    margin: 0 0 30px 0;
    color: #333;
    text-align: left;
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

/* Welcome Banner */
.welcome-banner {
    background: linear-gradient(135deg, #d4f1f4 0%, #b8e6e9 100%);
    padding: 24px 30px;
    border-radius: 8px;
    margin-bottom: 30px;
    border-left: 4px solid #5bc0de;
}

.welcome-banner h3 {
    color: #2c5f6f;
    font-size: 20px;
    font-weight: 600;
    margin-bottom: 8px;
    display: flex;
    align-items: center;
    gap: 10px;
}

.welcome-banner h3::before {
    content: 'ℹ️';
    font-size: 24px;
}

.welcome-banner p {
    color: #3d7080;
    font-size: 14px;
    margin: 0;
}

/* KPI Cards */
.kpi-container {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 20px;
    margin-top: 30px;
    margin-bottom: 40px;
}

.kpi-card {
    background: white;
    padding: 20px;
    border-radius: 8px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.1);
    text-align: left;
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

/* Section Headers */
section > p:first-child,
section > h3:first-child {
    font-size: 18px;
    font-weight: 600;
    color: #333;
    margin-bottom: 20px;
    padding-bottom: 10px;
    border-bottom: 2px solid #e0e0e0;
    display: flex;
    align-items: center;
    gap: 8px;
}

section > p:first-child::before,
section > h3:first-child::before {
    content: '📊';
    font-size: 20px;
}

/* Status Container */
.status-container {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 30px;
    margin-top: 30px;
    margin-bottom: 40px;
}

.status-container > div {
    background: white;
    padding: 24px;
    border-radius: 8px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.1);
    border: 1px solid #e0e0e0;
}

.status-container p {
    font-size: 18px;
    font-weight: 600;
    margin: 0 0 20px 0;
    color: #333;
    text-align: left;
}

#inventoryChart {
    width: 180px !important;
    height: 180px !important;
}

#inventoryChart2 {
    width: 180px !important;
    height: 180px !important;
}

.card {
    margin: 0;
    background: transparent;
    padding: 0;
    border-radius: 0;
    box-shadow: none;
    border: none;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 30px;
    width: 100%;
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
    display: inline-block;
}

.label-value {
    font-weight: 600;
    font-size: 15px;
    color: #333;
    margin-left: auto;
}

/* List Container */
.list-container {
    padding: 0;
    display: grid;
    grid-template-columns: 1fr 1fr;
    margin-top: 30px;
    gap: 30px;
}

.left-list, .right-list {
    background: white;
    padding: 24px;
    border-radius: 8px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.1);
    border: 1px solid #e0e0e0;
}

.left-list p, .right-list p {
    color: #333;
    font-weight: 600;
    font-size: 16px;
}

.left-list p.title, 
.right-list p.title {
    float: left;
    font-weight: 600;
    font-size: 16px;
    color: #333;
}

.left-list p.more,
.right-list p.more {
    float: right;
    font-size: 13px;
    color: #666;
    cursor: pointer;
    transition: color 0.3s;
    font-weight: 400;
}

.left-list p.more:hover,
.right-list p.more:hover {
    color: #333;
}

.left-list::after,
.right-list::after {
    content: "";
    display: block;
    clear: both;
}

.list-container table {
    width: 100%;
    margin-top: 20px;
}

.list-container p {
    margin-bottom: 10px;
}

/* Table Styles */
table {
    width: 100%;
    border-collapse: collapse;
    margin-top: 15px;
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

/* Footer */
.footer {
    background: #000000;
    color: white;
    padding: 60px 20px 30px;
    margin-top: 60px;
}

.footer-content {
    max-width: 1200px;
    margin: 0 auto;
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 40px;
    margin-bottom: 40px;
}

.footer-section h3 {
    font-size: 16px;
    margin-bottom: 20px;
    font-weight: 600;
}

.footer-section ul {
    list-style: none;
}

.footer-section ul li {
    margin-bottom: 12px;
}

.footer-section a {
    color: #adb5bd;
    text-decoration: none;
    transition: all 0.3s;
    font-size: 14px;
}

.footer-section a:hover {
    color: white;
    padding-left: 5px;
}

.footer-bottom {
    text-align: center;
    padding-top: 30px;
    border-top: 1px solid #495057;
    color: #adb5bd;
    font-size: 14px;
}
        </style>
    </head>
    <body>
        <nav class="navbar">
            <div class="nav-container">
                <div class="logo">CRM System</div>
                <div class="nav-links">
                    <a href="#"><i class="fas fa-envelope"></i> Tin nhắn</a>
                    <a href="#"><i class="fas fa-bell"></i> Thông báo</a>
                    <a href="#contact">Avatar</a>
                    <a href="login" class="btn-login">Xin chào ${sessionScope.username}</a>
                </div>
            </div>
        </nav>
        
        <form action="storekeeper" method="POST">
            <div class="container">
                <div class="sidebar">
                    <div class="sidebar navbar nav-container2">
                        <a href="storekeeper"><i class="fas fa-user-cog"></i><span>Trang chủ</span></a>
                        <a href="manageProfile"><i class="fas fa-user-circle"></i><span>Hồ Sơ</span></a>
                        <a href="#"><i class="fas fa-chart-line"></i><span>Thống kê</span></a>
                        <a href="numberInventory"><i class="fas fa-boxes"></i><span>Số lượng tồn kho</span></a>
                        <a href="numberPart"><i class="fas fa-list"></i><span>Danh sách hàng tồn kho</span></a>
                        <a href="transactionHistory"><i class="fas fa-history"></i><span>Lịch sử giao dịch</span></a>
                        <a href="partRequest"><i class="fas fa-tools"></i><span>Yêu cầu thiết bị</span></a>
                        <a href="#"><i class="fas fa-file-invoice"></i><span>Danh sách hóa đơn</span></a>
                        <a href="#"><i class="fas fa-wrench"></i><span>Báo cáo sửa chữa</span></a>
                        <a href="partDetail"><i class="fas fa-truck-loading"></i><span>Chi tiết thiệt bị</span></a>
                        <a href="logout" style="margin-top: auto; background: rgba(255, 255, 255, 0.05); border-top: 1px solid rgba(255,255,255,0.1); text-align: center; font-weight: 500;">
                            <i class="fas fa-sign-out-alt"></i><span>Đăng xuất</span>
                        </a>
                    </div>
                </div>
                
                <div class="content">
                    <!--Một số KPI của storekeeper-->
                    <section>
                        <h2>Inventory Management KPIs</h2>
                        
                        <div class="kpi-container">
                            <div class="kpi-card">
                                <h3>Trung bình thời gian hoàn thành sửa chữa</h3>
                                <p>1.2</p>
                            </div>
                            <div class="kpi-card">
                                <h3>Tỉ lệ sử dụng vật dụng trên tổng tồn kho</h3>
                                <p>$341,678</p>
                            </div>
                            <div class="kpi-card">
                                <h3>Số lượng công việc trễ hạn</h3>
                                <p>$412,343</p>
                            </div>
                            <div class="kpi-card">
                                <h3>Tỉ lệ thiết bị được cấp đúng yêu cầu</h3>
                                <p>95.5%</p>
                            </div>
                            <div class="kpi-card">
                                <h3>Số báo cáo chờ xác nhận</h3>
                                <p>16.5</p>
                            </div>
                            <div class="kpi-card">
                                <h3>Tổng số lượng thiết bị trong kho</h3>
                                <p>14.2</p>
                            </div>
                            <div class="kpi-card">
                                <h3>% công việc xong đúng kế hoạch</h3>
                                <p>94.5%</p>
                            </div>
                            <div class="kpi-card">
                                <h3>Số lượng vật tư sắp hết</h3>
                                <p>2.3%</p>
                            </div>
                        </div>
                    </section>
                    
                    <!--Thống kê-->
                    <section>
                        <div class="status-container">
                            <div>
                                <p>Thiết bị</p>
                                <div class="card">
                                    <canvas id="inventoryChart" width="100" height="100"></canvas>
                                    <div class="legend">
                                        <div class="legend-item"><span class="color-dot" style="background:#00b894;"></span> In Stock Items <span class="label-value">134</span></div>
                                        <div class="legend-item"><span class="color-dot" style="background:#6c5ce7;"></span> Out of Stock Items <span class="label-value">7</span></div>
                                        <div class="legend-item"><span class="color-dot" style="background:#fdcb6e;"></span> Low Stock Items <span class="label-value">3</span></div>
                                        <div class="legend-item"><span class="color-dot" style="background:#d63031;"></span> Dead Stock Items <span class="label-value">1</span></div>
                                    </div>
                                </div>
                            </div>
                            
                            <div>
                                <p>Yêu cầu</p>
                                <div class="card">
                                    <canvas id="inventoryChart2" width="100" height="100"></canvas>
                                    <div class="legend">
                                        <div class="legend-item"><span class="color-dot" style="background:#f0ad4e;"></span> Pending Requests <span class="label-value">12</span></div>
                                        <div class="legend-item"><span class="color-dot" style="background:#0275d8;"></span> Approved Requests <span class="label-value">24</span></div>
                                        <div class="legend-item"><span class="color-dot" style="background:#d9534f;"></span> Rejected Requests <span class="label-value">5</span></div>
                                        <div class="legend-item"><span class="color-dot" style="background:#5cb85c;"></span> Completed Requests <span class="label-value">18</span></div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </section>
                    
                    <section>
                        <div class="list-container">
                            <div class="left-list">
                                <p class="title">Thiết bị được sử dụng nhiều</p>
                                <p class="more">Xem thêm <i class="fa-solid fa-arrow-right"></i></p>
                                <table border="1">
                                    <thead>
                                        <tr>
                                            <th>InventoryId</th>
                                            <th>PartId</th>
                                            <th>PartName</th>
                                            <th>Quantity</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td></td>
                                            <td></td>
                                            <td></td>
                                            <td></td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                            
                            <div class="right-list">
                                <p class="title">Thiết bị sắp hết</p>
                                <p class="more">Xem thêm <i class="fa-solid fa-arrow-right"></i></p>
                                <table border="1">
                                    <thead>
                                        <tr>
                                            <th>PartID</th>
                                            <th>PartName</th>
                                            <th>Description</th>
                                            <th>Unit Price</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td></td>
                                            <td></td>
                                            <td></td>
                                            <td></td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </section>
                </div>
            </div>
        </form>

        <script>
            const ctx = document.getElementById('inventoryChart').getContext('2d');
            new Chart(ctx, {  
                type: 'doughnut',
                data: {
                    labels: ['In Stock', 'Out of Stock', 'Low Stock', 'Dead Stock'],
                    datasets: [{
                        data: [134, 7, 3, 1],
                        backgroundColor: ['#00b894', '#6c5ce7', '#fdcb6e', '#d63031'],
                        borderWidth: 0
                    }]
                },
                options: {
                    cutout: '70%',
                    plugins: { legend: { display: false } }
                }
            });
            
            const ltx = document.getElementById('inventoryChart2').getContext('2d');
            new Chart(ltx, {
                type: 'doughnut',
                data: {
                    labels: ['Pending', 'Approved', 'Rejected', 'Completed'],
                    datasets: [{
                        data: [12, 24, 5, 18],
                        backgroundColor: ['#f0ad4e', '#0275d8', '#d9534f', '#5cb85c'],
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