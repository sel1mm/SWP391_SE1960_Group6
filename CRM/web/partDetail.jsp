<%-- 
    Document   : partDetail (COMPLETE FIXED VERSION)
    Author     : Admin
--%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
        <title>CRM System - Chi tiết thiết bị</title>

        <style>
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }

            body {
                font-family: 'Inter', system-ui, -apple-system, "Segoe UI", Roboto, sans-serif;
                background: #ffffff;
                color: #1a1a1a;
                line-height: 1.6;
                min-height: 100vh;
            }

            /* NAVBAR */
            .navbar {
                background: #000000;
                padding: 1rem 0;
                box-shadow: 0 2px 8px rgba(0,0,0,0.1);
                position: sticky;
                top: 0;
                z-index: 1000;
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
                font-size: 28px;
                font-weight: 700;
                letter-spacing: -0.5px;
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
                transition: all 0.3s ease;
                padding: 8px 16px;
                border-radius: 6px;
            }

            .nav-links a:hover {
                background: rgba(255,255,255,0.15);
                transform: translateY(-1px);
            }

            /* SIDEBAR */
            .sidebar {
                width: 250px;
                min-height: calc(100vh - 77px);
                position: fixed;
                top: 77px;
                left: 0;
                background: #000000;
                display: flex;
                flex-direction: column;
                justify-content: space-between;
                box-shadow: 2px 0 8px rgba(0,0,0,0.1);
            }

            .sidebar a {
                color: white;
                text-decoration: none;
                padding: 15px 20px;
                font-size: 15px;
                display: flex;
                align-items: center;
                gap: 12px;
                transition: all 0.3s ease;
                font-weight: 500;
            }

            .sidebar a:hover {
                background: rgba(255,255,255,0.15);
                padding-left: 24px;
            }

            .sidebar a i {
                min-width: 20px;
                text-align: center;
            }

            /* CONTAINER & CONTENT */
            .container {
                display: flex;
            }

            .content {
                margin-left: 250px;
                padding: 40px;
                background: #ffffff;
                min-height: calc(100vh - 77px);
                width: calc(100% - 250px);
            }

            .content h2 {
                color: #1a1a1a;
                font-weight: 700;
                margin-bottom: 24px;
                font-size: 28px;
            }

            /* SEARCH & FILTER */
            .search-filter-container {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin: 0 0 24px;
                background: #f8f9fa;
                padding: 16px 20px;
                border-radius: 12px;
                border: 1px solid #e9ecef;
                flex-wrap: wrap;
                gap: 10px;
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
            }

            .search-input, .filter-select {
                padding: 11px 16px;
                border: 1px solid #dee2e6;
                border-radius: 8px;
                font-size: 14px;
                outline: none;
                background: white;
                color: #1a1a1a;
                transition: all 0.2s ease;
            }

            .search-input {
                width: 320px;
            }

            .search-input:focus, .filter-select:focus {
                border-color: #000000;
                box-shadow: 0 0 0 3px rgba(0,0,0,0.05);
            }

            .btn-search, .btn-new {
                background: #000000;
                color: white;
                border: none;
                padding: 11px 20px;
                border-radius: 8px;
                cursor: pointer;
                font-weight: 600;
                transition: all 0.25s ease;
                display: inline-flex;
                align-items: center;
                gap: 8px;
                font-size: 14px;
            }

            .btn-search:hover, .btn-new:hover {
                background: #1a1a1a;
                transform: translateY(-2px);
                box-shadow: 0 4px 12px rgba(0,0,0,0.2);
            }

            /* TABLE */
            .inventory-table {
                width: 100%;
                margin: 0 auto;
                border-collapse: collapse;
                background: white;
                border-radius: 12px;
                overflow: hidden;
                box-shadow: 0 1px 3px rgba(0,0,0,0.08);
                border: 1px solid #e9ecef;
            }

            .inventory-table thead tr th {
                background: #000000;
                color: white;
                padding: 14px 16px;
                text-align: left;
                font-weight: 600;
                font-size: 13px;
                text-transform: uppercase;
                letter-spacing: 0.5px;
            }

            .inventory-table thead tr th:nth-child(1) { width: 5%; }
            .inventory-table thead tr th:nth-child(2) { width: 5%; }
            .inventory-table thead tr th:nth-child(3) { width: 15%; }
            .inventory-table thead tr th:nth-child(4) { width: 10%; }
            .inventory-table thead tr th:nth-child(5) { width: 15%; }
            .inventory-table thead tr th:nth-child(6) { width: 15%; }
            .inventory-table thead tr th:nth-child(7) { width: 19%; }
            .inventory-table thead tr th:nth-child(8) { width: 18%; }

            .inventory-table tbody td {
                padding: 14px 16px;
                border-bottom: 1px solid #e9ecef;
                font-size: 14px;
                color: #495057;
            }

            .inventory-table tbody tr:hover {
                background-color: #f8f9fa;
            }

            .inventory-table tbody tr:last-child td {
                border-bottom: none;
            }

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
                background-color: #fff8e1;
            }

            /* BUTTONS */
            .btn-edit, .btn-delete {
                color: white;
                border: none;
                padding: 8px 14px;
                border-radius: 6px;
                cursor: pointer;
                transition: all 0.3s ease;
                display: inline-flex;
                align-items: center;
                gap: 6px;
                font-size: 13px;
                font-weight: 500;
            }

            .btn-edit {
                background: #0d6efd;
                margin-bottom: 8px;
            }

            .btn-delete {
                background: #dc3545;
            }

            .btn-edit:hover {
                background: #0b5ed7;
                transform: translateY(-1px);
                box-shadow: 0 2px 8px rgba(13,110,253,0.3);
            }
            
            .btn-delete:hover {
                background: #bb2d3b;
                transform: translateY(-1px);
                box-shadow: 0 2px 8px rgba(220,53,69,0.3);
            }

            /* PAGINATION */
            .pagination {
                display: flex;
                justify-content: center;
                align-items: center;
                gap: 10px;
                margin: 24px 0 60px;
            }

            .pagination a {
                padding: 9px 15px;
                border-radius: 8px;
                background: white;
                color: #1a1a1a;
                text-decoration: none;
                font-weight: 600;
                border: 1px solid #dee2e6;
                transition: all 0.2s ease;
            }

            .pagination a:hover, .pagination a.active {
                background: #000000;
                color: white;
                border-color: #000000;
                transform: translateY(-1px);
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
                backdrop-filter: blur(4px);
            }

            .form-container {
                background: #fff;
                padding: 32px 28px;
                border-radius: 12px;
                width: 480px;
                max-width: 95%;
                box-shadow: 0 10px 40px rgba(0,0,0,0.3);
            }

            #partDetailFormTitle {
                margin-bottom: 24px;
                font-size: 24px;
                font-weight: 700;
                color: #1a1a1a;
                text-align: center;
            }

            .form-container label {
                font-weight: 600;
                margin-bottom: 6px;
                margin-top: 14px;
                color: #1a1a1a;
                display: block;
                font-size: 14px;
            }

            .form-container input[type="text"],
            .form-container input[type="number"],
            .form-container select {
                width: 100%;
                padding: 11px 14px;
                border: 1px solid #dee2e6;
                border-radius: 8px;
                font-size: 14px;
                outline: none;
                transition: all 0.2s ease;
                color: #1a1a1a;
            }

            .form-container input:focus,
            .form-container select:focus {
                border-color: #000000;
                box-shadow: 0 0 0 3px rgba(0,0,0,0.05);
            }

            #partDetailFormMessage {
                font-size: 13px;
                color: #dc3545;
                text-align: center;
                min-height: 18px;
                margin-top: 10px;
            }

            .form-buttons {
                display: flex;
                justify-content: space-between;
                gap: 10px;
                margin-top: 20px;
            }

            .btn-save, .btn-cancel {
                padding: 11px 20px;
                border-radius: 8px;
                font-weight: 600;
                font-size: 14px;
                border: none;
                cursor: pointer;
                transition: all 0.2s ease;
                flex: 1;
            }

            .btn-save {
                background: #198754;
                color: #fff;
            }

            .btn-save:hover {
                background: #157347;
                transform: translateY(-1px);
                box-shadow: 0 4px 12px rgba(25,135,84,0.3);
            }

            .btn-cancel {
                background: #6c757d;
                color: #fff;
            }

            .btn-cancel:hover {
                background: #5a6268;
                transform: translateY(-1px);
            }

            /* MESSAGES */
            .success-message {
                background: #d1e7dd;
                color: #0f5132;
                padding: 12px 20px;
                border-radius: 8px;
                margin: 0 0 20px;
                border: 1px solid #badbcc;
                display: flex;
                align-items: center;
                gap: 10px;
            }

            .error-message {
                background: #f8d7da;
                color: #842029;
                padding: 12px 20px;
                border-radius: 8px;
                margin: 0 0 20px;
                border: 1px solid #f5c2c7;
                display: flex;
                align-items: center;
                gap: 10px;
            }

            .success-message, .error-message {
                transition: all 0.5s ease;
            }

            .message-fade-out {
                opacity: 0;
                transform: translateY(-20px);
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
                .search-filter-container {
                    flex-direction: column;
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
                    <a href="login" class="btn-login">Xin chào ${sessionScope.username}</a>
                </div>
            </div>
        </nav>

        <div class="container">
            <!-- Sidebar -->
            <div class="sidebar">
                <div>
                    <a href="storekeeper"><i class="fas fa-user-cog"></i><span>Trang chủ</span></a>
                    <a href="manageProfile"><i class="fas fa-tachometer-alt"></i><span>Quản lý người dùng</span></a>
                    <a href="#"><i class="fas fa-chart-line"></i><span>Thống kê</span></a>
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
                <h2>Chi tiết thiết bị</h2>

                <!-- Success/Error Messages -->
                <c:if test="${not empty successMessage}">
                    <div class="success-message">
                        <i class="fas fa-check-circle"></i> ${successMessage}
                    </div>
                </c:if>
                <c:if test="${not empty errorMessage}">
                    <div class="error-message">
                        <i class="fas fa-exclamation-circle"></i> ${errorMessage}
                    </div>
                </c:if>

                <!-- Search & Filter -->
                <div class="search-filter-container">
                    <form action="partDetail" method="POST" style="display:flex; width:100%; align-items:center; gap:10px; flex-wrap:wrap;">
                        <div class="search-group">
                            <input type="text" placeholder="Nhập từ khoá..." name="keyword"
                                   value="${param.keyword}" class="search-input"/>
                            <button type="submit" class="btn-search"> 
                                <i class="fas fa-search"></i> Search
                            </button>
                        </div>

                        <div class="filter-group">
                            <select name="filter" class="filter-select" onchange="this.form.submit()">
                                <option value="">-- Filter by --</option>
                                <option value="partId" ${param.filter == 'partId' ? 'selected' : ''}>By Part ID</option>
                                <option value="inventoryId" ${param.filter == 'inventoryId' ? 'selected' : ''}>By PartDetail ID</option>
                                <option value="partName" ${param.filter == 'partName' ? 'selected' : ''}>By Serial Name</option>
                            </select>

                            <button type="button" class="btn-new" onclick="openPartDetailForm('new')">
                                <i class="fas fa-plus"></i> New Part
                            </button>
                        </div>
                    </form>
                </div>

                <!-- Table -->
                <table class="inventory-table">
                    <thead>
                        <tr>
                            <th>PartDetailId</th>
                            <th>PartId</th>
                            <th>SerialNumber</th>
                            <th>Status</th>
                            <th>Location</th>
                            <th>LastUpdatedBy</th>
                            <th>LastUpdatedDate</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${list}" var="ls">
                            <tr>
                                <td>${ls.partDetailId}</td>
                                <td>${ls.partId}</td>
                                <td>${ls.serialNumber}</td>
                                <td>${ls.status}</td>
                                <td>${ls.location}</td>
                                <td>${ls.username}</td>
                                <td>${ls.lastUpdatedDate}</td>
                                <td>
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
                                            onclick="confirmDelete(${ls.partDetailId})">
                                        <i class="fas fa-trash"></i> Delete
                                    </button>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>

                <!-- FORM POPUP -->
                <div class="form-overlay" id="partDetailFormOverlay">
                    <div class="form-container">
                        <h2 id="partDetailFormTitle">Add New Part Detail</h2>
                        <form action="partDetail" method="POST" id="partDetailForm">
                            <input type="hidden" name="action" id="partDetailAction" value="add">
                            <input type="hidden" name="partDetailId" id="partDetailId">

                            <label>Part ID *</label>
                            <input type="number" name="partId" id="partId" required>

                            <label>Serial Number *</label>
                            <input type="text" name="serialNumber" id="serialNumber" required maxlength="30">

                            <label>Status *</label>
                            <select name="status" id="status" required>
                                <option value="Available">Available</option>
                                <option value="InUse">In Use</option>
                                <option value="Faulty">Faulty</option>
                                <option value="Retired">Retired</option>
                            </select>

                            <label>Location *</label>
                            <input type="text" name="location" id="location" required>

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
            function openPartDetailForm(mode, partDetailId = '', partId = '', serialNumber = '', status = 'Available', location = '') {
                const overlay = document.getElementById("partDetailFormOverlay");
                const title = document.getElementById("partDetailFormTitle");
                const actionInput = document.getElementById("partDetailAction");

                overlay.style.display = "flex";
                document.getElementById("partDetailFormMessage").textContent = "";

                if (mode === "new") {
                    title.textContent = "Add New Part Detail";
                    actionInput.value = "add";
                    document.getElementById("partDetailId").value = "";
                    document.getElementById("partId").value = "";
                    document.getElementById("serialNumber").value = "";
                    document.getElementById("status").value = "Available";
                    document.getElementById("location").value = "";
                } else {
                    title.textContent = "Edit Part Detail";
                    actionInput.value = "edit";
                    document.getElementById("partDetailId").value = partDetailId;
                    document.getElementById("partId").value = partId;
                    document.getElementById("serialNumber").value = serialNumber;
                    document.getElementById("status").value = status;
                    document.getElementById("location").value = location;
                }
            }

            function closePartDetailForm() {
                document.getElementById("partDetailFormOverlay").style.display = "none";
            }

            function confirmDelete(partDetailId) {
                if (confirm("Bạn có chắc muốn xóa PartDetailId = " + partDetailId + " ?")) {
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
                    idInput.value = partDetailId;

                    form.appendChild(actionInput);
                    form.appendChild(idInput);
                    document.body.appendChild(form);
                    form.submit();
                }
            }

            document.getElementById("partDetailFormOverlay").addEventListener('click', function (e) {
                if (e.target === this) {
                    closePartDetailForm();
                }
            });

            let currentPage = 1;
            const rowsPerPage = 10;

            function renderPartDetailTable() {
                const tableBody = document.querySelector(".inventory-table tbody");
                if (!tableBody) return;

                const keyword = document.querySelector(".search-input").value.toLowerCase();
                const rows = Array.from(tableBody.rows);

                const filteredRows = rows.filter(row => {
                    return Array.from(row.cells).slice(0, 7)
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

            document.querySelector(".search-input").addEventListener("input", () => {
                currentPage = 1;
                renderPartDetailTable();
            });

            document.addEventListener("DOMContentLoaded", renderPartDetailTable);
            
            document.addEventListener("DOMContentLoaded", function() {
                const messages = document.querySelectorAll(".success-message, .error-message");
                
                messages.forEach(function(msg) {
                    setTimeout(function() {
                        msg.classList.add("message-fade-out");
                        setTimeout(function() {
                            msg.style.display = "none";
                        }, 500);
                    }, 5000);
                });
            });
        </script>
    </body>
</html>