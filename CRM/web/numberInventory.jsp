<%@ page import="java.util.List" %>
<%@ page import="model.PartDetail" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html" pageEncoding="UTF-8" %>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
        <title>CRM System - Quản lý Hàng tồn kho</title>
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
    font-weight: 400;
    min-height: 100vh;
}

/* Navbar */
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
    background: #f5f5f5;
    min-height: calc(100vh - 65px);
    width: calc(100% - 220px);
}

.content h2 {
    margin: 0 0 30px 0;
    color: #333;
    text-align: left;
    font-size: 28px;
    font-weight: 600;
}

/* Search + Filter */
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
}

.search-group {
    display: flex;
    gap: 10px;
    align-items: center;
}

.search-input {
    padding: 9px 14px;
    border: 1px solid #d0d0d0;
    border-radius: 6px;
    width: 300px;
    font-size: 14px;
    outline: none;
    background: #fafafa;
    transition: all 0.2s;
}

.search-input:focus {
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
    transition: 0.2s;
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

.filter-select {
    padding: 9px 14px;
    border-radius: 6px;
    border: 1px solid #d0d0d0;
    font-size: 14px;
    outline: none;
    cursor: pointer;
    background: #fafafa;
    min-width: 180px;
    transition: all 0.2s;
}

.filter-select:focus {
    border-color: #999;
    box-shadow: 0 0 0 3px rgba(0,0,0,0.05);
    background: white;
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

.inventory-table tbody td {
    padding: 12px 16px;
    border-bottom: 1px solid #e0e0e0;
    font-size: 13px;
    color: #666;
}

.inventory-table tbody tr:nth-child(even) {
    background-color: #fafafa;
}

.inventory-table tbody tr:hover {
    background-color: #f0f0f0;
}

/* Column widths */
.inventory-table thead tr th:nth-child(1) { width: 8%; }
.inventory-table thead tr th:nth-child(2) { width: 10%; }
.inventory-table thead tr th:nth-child(3) { width: 25%; }
.inventory-table thead tr th:nth-child(4) { width: 10%; }
.inventory-table thead tr th:nth-child(5) { width: 15%; }
.inventory-table thead tr th:nth-child(6) { width: 15%; }

.inventory-table tbody td:nth-child(3) {
    max-width: 300px;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}

.inventory-table tbody td:nth-child(3):hover {
    white-space: normal;
    overflow: visible;
    word-wrap: break-word;
    background-color: #fffbea;
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

.btn-detail {
    background: #28a745;
    color: white;
    border: none;
    padding: 7px 14px;
    border-radius: 6px;
    cursor: pointer;
    font-size: 13px;
    font-weight: 500;
    display: inline-flex;
    align-items: center;
    gap: 6px;
    transition: all 0.2s ease;
}

.btn-detail:hover {
    background: #218838;
    transform: translateY(-1px);
    box-shadow: 0 2px 6px rgba(40,167,69,0.3);
}

.detail-form {
    background: #f8f9fa;
    padding: 20px;
    border-radius: 8px;
    margin-top: 10px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.1);
    animation: fadeIn 0.3s ease-in-out;
    border: 1px solid #e0e0e0;
}

.detail-form h4 {
    margin-bottom: 12px;
    color: #333;
    font-size: 16px;
    font-weight: 600;
}

.detail-form table {
    width: 100%;
    border-collapse: collapse;
    background: white;
    border-radius: 6px;
    overflow: hidden;
}

.detail-form th, .detail-form td {
    border: 1px solid #e0e0e0;
    padding: 10px;
    font-size: 13px;
    text-align: center;
}

.detail-form th {
    background: #f8f9fa;
    color: #333;
    font-weight: 600;
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

@media (max-width: 900px) {
    .content {
        margin-left: 0;
        width: 100%;
        padding: 18px;
    }

    .sidebar {
        display: none;
    }
    
    .search-filter-container {
        flex-direction: column;
        gap: 12px;
        align-items: stretch;
    }
    
    .search-input {
        width: 100%;
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
                    <a href="#contact">Avatar</a>
                    <a href="login" class="btn-login">Xin chào ${sessionScope.username}</a>
                </div>
            </div>
        </nav>

        <form action="numberInventory" method="POST" id="filterForm">
            <input type="hidden" name="action" id="actionInput" value="">

            <div class="container">
                <!-- Sidebar -->
                <div class="sidebar">
                    <div class="sidebar navbar nav-container2">
                        <a href="storekeeper"><i class="fas fa-user-cog"></i><span>Trang chủ</span></a>
                       <a href="manageProfile"><i class="fas fa-user-circle"></i><span>Hồ Sơ</span></a>
                        <a href="#"><i class="fas fa-chart-line"></i><span>Thống kê</span></a>
                        <a href="numberInventory"><i class="fas fa-boxes"></i><span>Số lượng tồn kho</span></a>
                        <a href="numberPart"><i class="fas fa-list"></i><span>Danh sách hàng tồn kho</span></a>
                        <a href="PartDetailHistoryServlet"><i class="fas fa-history"></i><span>Lịch sử giao dịch</span></a>
                        <a href="partRequest"><i class="fas fa-tools"></i><span>Yêu cầu thiết bị</span></a>
                        <a href="#"><i class="fas fa-file-invoice"></i><span>Danh sách hóa đơn</span></a>
                        <a href="#"><i class="fas fa-wrench"></i><span>Báo cáo sửa chữa</span></a>
                        <a href="partDetail"><i class="fas fa-truck-loading"></i><span>Chi tiết thiết bị</span></a>
                        <a href="logout" style="margin-top: auto; background: rgba(255, 255, 255, 0.05); border-top: 1px solid rgba(255,255,255,0.1); text-align: center; font-weight: 500;">
                            <i class="fas fa-sign-out-alt"></i><span>Đăng xuất</span>
                        </a>
                    </div>
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

            document.addEventListener("DOMContentLoaded", () => {
                renderInventoryTable();

                document.querySelectorAll(".btn-detail").forEach(btn => {
                    btn.addEventListener("click", function () {
                        const row = this.closest("tr");
                        const existingDetailRow = row.nextElementSibling;

                        if (existingDetailRow && existingDetailRow.classList.contains("detail-row")) {
                            existingDetailRow.remove();
                            return;
                        }

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
        <%
            // Xóa message sau khi đã hiển thị
            session.removeAttribute("successMessage");
            session.removeAttribute("errorMessage");
        %>
    </body>
</html>