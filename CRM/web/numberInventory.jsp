<%-- 
    Document   : numberInventory
    Created on : Oct 12, 2025, 10:19:54 PM
    Author     : Admin
--%>
<%@ page import="java.util.List" %>
<%@ page import="model.PartDetail" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <!-- Import Inter font -->
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
        <title>CRM System - Quản lý Hàng tồn kho</title>
        <style>
            /* Reset */
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }

            body {
                font-family: 'Inter', system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial;
                background: #f8f9fc;
                color: #333;
                line-height: 1.6;
                font-weight: 400;
            }

            /* Navbar */
            .navbar {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                padding: 0;
                box-shadow: 0 4px 20px rgba(0,0,0,0.1);
                position: sticky;
                top: 0;
                z-index: 1000;
            }

            .nav-container {
                max-width: 1200px;
                margin: 0 auto;
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: 1rem 2rem;
            }

            .logo {
                color: white;
                font-size: 28px;
                font-weight: 700;
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
                font-weight: 500;
                font-size: 15px;
                transition: all 0.3s;
                padding: 8px 16px;
                border-radius: 6px;
            }

            .nav-links a:hover {
                background: rgba(255,255,255,0.12);
            }

            /* Sidebar */
            .sidebar {
                max-width: 250px;
                height: 100vh;
                margin-top: 77px;
                position: fixed;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                display: flex;
                flex-direction: column;
                padding-top: 20px;
                left: 0;
                top: 0;
                overflow: auto;
            }

            .sidebar a {
                color: white;
                text-decoration: none;
                padding: 14px 20px;
                font-size: 15px;
                display: flex;
                align-items: center;
                gap: 12px;
                transition: background 0.3s, padding-left 0.15s;
            }

            .sidebar a:hover {
                background: rgba(255,255,255,0.08);
                padding-left: 24px;
            }

            .container {
                display: flex;
                margin-top: 60px;
            }

            .content {
                margin-left: 250px;
                padding: 30px;
                background: #f4f6f8;
                min-height: calc(100vh - 60px);
                width: calc(100% - 250px);
            }

            .content h2 {
                color: #666;
                font-weight: 600;
                margin-bottom: 16px;
            }

            /* Search + Filter */
            .search-filter-container {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin: 12px 8px 20px;
                background: #fff;
                padding: 14px 18px;
                border-radius: 10px;
                box-shadow: 0 2px 6px rgba(0,0,0,0.06);
            }

            .search-group {
                display: flex;
                gap: 10px;
                align-items: center;
            }

            .search-input {
                padding: 10px 14px;
                border: 1px solid #e3e6ee;
                border-radius: 8px;
                width: 320px;
                font-size: 14px;
                outline: none;
                background: #fafbfc;
            }

            .btn-search {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                border: none;
                padding: 10px 18px;
                border-radius: 8px;
                cursor: pointer;
                font-weight: 600;
                transition: 0.25s;
                display: inline-flex;
                align-items: center;
                gap: 8px;
            }

            .filter-select {
                padding: 10px 14px;
                border-radius: 8px;
                border: 1px solid #e3e6ee;
                font-size: 14px;
                outline: none;
                cursor: pointer;
                background: white;
                min-width: 190px;
            }

            /* Table */
            .inventory-table {
                width: 95%;
                margin: 12px auto 0;
                border-collapse: collapse;
                background: white;
                border-radius: 12px;
                overflow: hidden;
                box-shadow: 0 2px 8px rgba(0,0,0,0.06);
            }

            .inventory-table thead tr th {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                padding: 12px 16px;
                text-align: left;
                font-weight: 600;
                font-size: 14px;
            }

            .inventory-table tbody td {
                padding: 12px 16px;
                border-bottom: 1px solid #f0f2f6;
                font-size: 14px;
                color: #333;
            }

            .inventory-table tbody tr:hover {
                background-color: #f2f6ff;
            }

            /* Pagination */
            .pagination {
                display: flex;
                justify-content: center;
                align-items: center;
                gap: 10px;
                margin: 24px 0 60px;
            }

            .pagination a {
                padding: 8px 14px;
                border-radius: 8px;
                background: white;
                color: #333;
                text-decoration: none;
                font-weight: 600;
                border: 1px solid #e6e8ef;
                transition: all 0.2s ease;
            }

            .pagination a.active {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                border: none;
            }

            @media (max-width: 900px) {
                .content {
                    margin-left: 0;
                    width: 100%;
                    padding: 18px;
                }

                .sidebar {
                    display: none;
                }
            }
            .btn-detail {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                border: none;
                padding: 8px 14px;
                border-radius: 8px;
                cursor: pointer;
                font-size: 13px;
                font-weight: 600;
                display: inline-flex;
                align-items: center;
                gap: 6px;
                transition: all 0.25s ease;
            }

            .btn-detail:hover {
                opacity: 0.9;
                transform: translateY(-1px);
                box-shadow: 0 3px 8px rgba(0, 0, 0, 0.15);
            }
            /* Bảng chi tiết */
            .detail-form {
                background: #f9f9ff;
                padding: 20px;
                border-radius: 10px;
                margin-top: 10px;
                box-shadow: 0 3px 6px rgba(0,0,0,0.08);
                animation: fadeIn 0.3s ease-in-out;
            }

            .detail-form h4 {
                margin-bottom: 12px;
                color: #5a5a9e;
            }

            .detail-form table {
                width: 100%;
                border-collapse: collapse;
            }

            .detail-form th, .detail-form td {
                border: 1px solid #ddd;
                padding: 10px;
                font-size: 14px;
                text-align: center;
            }

            .detail-form th {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
            }
            /* Giới hạn độ rộng các cột - THÊM VÀO PHẦN <style> */
            .inventory-table thead tr th:nth-child(1) {
                width: 8%;
            }   /* Part ID */
            .inventory-table thead tr th:nth-child(2) {
                width: 10%;
            }  /* Inventory ID */
            .inventory-table thead tr th:nth-child(3) {
                width: 25%;
            }  /* Part Name */
            .inventory-table thead tr th:nth-child(4) {
                width: 10%;
            }  /* Quantity */
            .inventory-table thead tr th:nth-child(5) {
                width: 15%;
            }  /* Last Updated By */
            .inventory-table thead tr th:nth-child(6) {
                width: 15%;
            }  /* Last Update Time */

            /* Giới hạn text quá dài trong Part Name */
            .inventory-table tbody td:nth-child(3) {
                max-width: 300px;
                overflow: hidden;
                text-overflow: ellipsis;
                white-space: nowrap;
            }

            /* Hover để xem full text */
            .inventory-table tbody td:nth-child(3):hover {
                white-space: normal;
                overflow: visible;
                word-wrap: break-word;
                background-color: #fff3cd;
            }

            /* Đảm bảo table có table-layout fixed */
            .inventory-table {
                table-layout: fixed;  /* QUAN TRỌNG */
                width: 95%;
                margin: 12px auto 0;
                border-collapse: collapse;
                background: white;
                border-radius: 12px;
                overflow: hidden;
                box-shadow: 0 2px 8px rgba(0,0,0,0.06);
            }
            @keyframes fadeIn {
                from {
                    opacity: 0;
                    transform: translateY(-10px);
                }
                to {
                    opacity: 1;
                    transform: translateY(0);
                }
            }

            .sidebar {
                max-width: 250px;
                height: 610px;
                margin-top: 77px;
                position: fixed;
                display: flex;
                flex-direction: column;
                justify-content: space-between;
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
                    <a href="#contact">Avatar</a>
                    <a href="login" class="btn-login">Xin chào ${sessionScope.username}</a>
                </div>
            </div>
        </nav>

        <form action="numberInventory" method="POST" id="filterForm">
            <input type="hidden" name="action" id="actionInput" value="">

            <div class="container">
                <!-- Sidebar -->
                <div class="sidebar navbar nav-container2">
                    <a href="storekeeper"><i class="fas fa-user-cog"></i><span>Trang chủ</span></a>
                    <a href="manageProfile"><i class="fas fa-tachometer-alt" ></i><span>Quản lý người dùng</span></a>
                    <a href="#"><i class="fas fa-chart-line"></i><span>Thống kê</span></a>
                    <a href="numberInventory"><i class="fas fa-boxes"></i><span>Số lượng tồn kho</span></a>
                    <a href="numberPart"><i class="fas fa-list"></i><span>Danh sách hàng tồn kho</span></a>
                    <a href="transactionHistory"><i class="fas fa-history"></i><span>Lịch sử giao dịch</span></a>
                    <a href="partRequest"><i class="fas fa-tools"></i><span>Yêu cầu thiết bị</span></a>
                    <a href="#"><i class="fas fa-file-invoice"></i><span>Danh sách hóa đơn</span></a>
                    <a href="#"><i class="fas fa-wrench"></i><span>Báo cáo sửa chữa</span></a>
                    <a href="partDetail"><i class="fas fa-truck-loading"></i><span>Chi tiết thiết bị </span></a>
                    <!-- Nút Đăng xuất -->
                    <a href="logout" style="
                       margin-top: auto;
                       background: rgba(255, 255, 255, 0.15);
                       border-top: 1px solid rgba(255,255,255,0.2);
                       text-align: center;
                       font-weight: 500;
                       ">
                        <i class="fas fa-sign-out-alt"></i><span>Đăng xuất</span>
                    </a>

                </div>

                <!-- Content -->
                <div class="content">
                    <h2>Số lượng hàng tồn kho</h2>

                    <!-- Search & Filter -->
                    <div class="search-filter-container">
                        <div class="search-group">
                            <input type="text" placeholder="Nhập từ khoá..." name="keyword" class="search-input">
                            <button type="submit" class="btn-search"><i class="fas fa-search"></i> Search</button>
                        </div>

                        <div class="filter-group">
                            <select name="filter" class="filter-select"
                                    onchange="document.getElementById('actionInput').value = 'filter'; document.getElementById('filterForm').submit()">
                                <option value="">-- Filter by --</option>
                                <option value="partId" <%= "partId".equals(request.getParameter("filter")) ? "selected" : "" %>>By Part ID</option>
                                <option value="inventoryId" <%= "inventoryId".equals(request.getParameter("filter")) ? "selected" : "" %>>By Inventory ID</option>
                                <option value="partName" <%= "partName".equals(request.getParameter("filter")) ? "selected" : "" %>>By Part Name</option>
                                <option value="quantity" <%= "quantity".equals(request.getParameter("filter")) ? "selected" : "" %>>By Quantity</option>
                                <option value="lastUpdatePerson" <%= "lastUpdatePerson".equals(request.getParameter("filter")) ? "selected" : "" %>>By Last Update Person</option>
                                <option value="lastUpdateTime" <%= "lastUpdateTime".equals(request.getParameter("filter")) ? "selected" : "" %>>By Last Update Time</option>
                            </select>
                        </div>
                    </div>

                    <!-- Table -->
                    <table class="inventory-table">
                        <thead>
                            <tr>
                                <th>Part ID</th>
                                <th>Inventory ID</th>
                                <th>Part Name</th>
                                <th>Quantity</th>
                                <th>Last Updated By</th>
                                <th>Last Update Time</th>

                            </tr>
                        </thead>
                        <tbody id="inventoryTableBody">
                            <c:forEach items="${list}" var="ls">
                                <tr>
                                    <td>${ls.partId}</td>
                                    <td>${ls.inventoryId}</td>
                                    <td>${ls.partName}</td>
                                    <td>${ls.quantity}</td>
                                    <td>${ls.username}</td>
                                    <td>${ls.lastUpdatedDate}</td>

                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>

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
        </form>
        <script src="js/validatePartForm.js"></script>
        <script>
                                        let currentPage = 1;
                                        const rowsPerPage = 10;

                                        function renderInventoryTable() {
                                            const tableBody = document.getElementById("inventoryTableBody");
                                            if (!tableBody)
                                                return;

                                            const rows = Array.from(tableBody.rows);
                                            const totalPages = Math.ceil(rows.length / rowsPerPage);

                                            if (rows.length === 0) {
                                                const pagination = document.querySelector(".pagination");
                                                if (pagination)
                                                    pagination.innerHTML = "";
                                                return;
                                            }

                                            if (currentPage > totalPages)
                                                currentPage = totalPages;
                                            if (currentPage < 1)
                                                currentPage = 1;

                                            rows.forEach(row => row.style.display = "none");

                                            const start = (currentPage - 1) * rowsPerPage;
                                            const end = start + rowsPerPage;
                                            rows.slice(start, end).forEach(row => row.style.display = "");

                                            renderPagination(totalPages);
                                        }

                                        function renderPagination(totalPages) {
                                            const pagination = document.querySelector(".pagination");
                                            if (!pagination)
                                                return;
                                            pagination.innerHTML = "";

                                            function createPageButton(text, onClick, isActive = false) {
                                                const btn = document.createElement("a");
                                                btn.href = "#";
                                                btn.textContent = text;
                                                if (isActive)
                                                    btn.classList.add("active");
                                                btn.onclick = e => {
                                                    e.preventDefault();
                                                    onClick();
                                                };
                                                return btn;
                                            }

                                            pagination.appendChild(createPageButton("« First", () => {
                                                currentPage = 1;
                                                renderInventoryTable();
                                                scrollToTopOfTable();
                                            }));
                                            pagination.appendChild(createPageButton("‹ Prev", () => {
                                                if (currentPage > 1) {
                                                    currentPage--;
                                                    renderInventoryTable();
                                                    scrollToTopOfTable();
                                                }
                                            }));

                                            let start = Math.max(currentPage - 2, 1);
                                            let end = start + 4;
                                            if (end > totalPages) {
                                                end = totalPages;
                                                start = Math.max(end - 4, 1);
                                            }

                                            for (let i = start; i <= end; i++) {
                                                pagination.appendChild(createPageButton(i, () => {
                                                    currentPage = i;
                                                    renderInventoryTable();
                                                    scrollToTopOfTable();
                                                }, i === currentPage));
                                            }

                                            pagination.appendChild(createPageButton("Next ›", () => {
                                                if (currentPage < totalPages) {
                                                    currentPage++;
                                                    renderInventoryTable();
                                                    scrollToTopOfTable();
                                                }
                                            }));
                                            pagination.appendChild(createPageButton("Last »", () => {
                                                currentPage = totalPages;
                                                renderInventoryTable();
                                                scrollToTopOfTable();
                                            }));
                                        }

                                        function scrollToTopOfTable() {
                                            const table = document.querySelector(".inventory-table");
                                            if (table)
                                                table.scrollIntoView({behavior: "smooth", block: "start"});
                                        }

                                        // Hàm fetch chi tiết từ Servlet


                                        // Tạo hàng chi tiết, kể cả khi rỗng


                                        // Sự kiện click Details
                                        document.addEventListener("DOMContentLoaded", () => {
                                            renderInventoryTable();

                                            document.querySelectorAll(".btn-detail").forEach(btn => {
                                                btn.addEventListener("click", function () {
                                                    const row = this.closest("tr");
                                                    const existingDetailRow = row.nextElementSibling;

                                                    // Nếu đã mở -> đóng
                                                    if (existingDetailRow && existingDetailRow.classList.contains("detail-row")) {
                                                        existingDetailRow.remove();
                                                        return;
                                                    }

                                                    // Đóng tất cả hàng chi tiết khác
                                                    document.querySelectorAll(".detail-row").forEach(r => r.remove());

                                                    const partId = this.getAttribute("data-part-id");

                                                    fetchPartDetails(partId, (details) => {
                                                        const detailRow = createDetailRow(details);
                                                        row.insertAdjacentElement("afterend", detailRow);
                                                    });
                                                });
                                            });
                                        });

        </script>
    </body>
</html>