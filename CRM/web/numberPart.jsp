<%-- 
    Document   : numberPart (OPTIMIZED)
    Created on : Oct 11, 2025
    Author     : Admin
--%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
        <title>CRM System - Danh sách hàng tồn kho</title>

        <style>
           
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }
            
            body {
                font-family: 'Inter', system-ui, -apple-system, "Segoe UI", Roboto, sans-serif;
                background: #f8f9fc;
                color: #333;
                line-height: 1.6;
                -webkit-font-smoothing: antialiased;
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
                transition: all 0.3s;
            }

            .sidebar a:hover {
                background: rgba(255,255,255,0.08);
                padding-left: 24px;
            }

            /* Content */
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
                margin-left: 8px;
                color: #666;
                font-weight: 600;
                margin-bottom: 16px;
            }

            /* Messages */
            .success-message {
                background: #d4edda;
                color: #155724;
                padding: 12px 20px;
                border-radius: 8px;
                margin: 10px 8px;
                border: 1px solid #c3e6cb;
                display: flex;
                align-items: center;
                gap: 10px;
            }

            .error-message {
                background: #f8d7da;
                color: #721c24;
                padding: 12px 20px;
                border-radius: 8px;
                margin: 10px 8px;
                border: 1px solid #f5c6cb;
                display: flex;
                align-items: center;
                gap: 10px;
            }

            /* Search Filter Container */
            .search-filter-container {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin: 12px 8px 20px;
                background: #fff;
                padding: 14px 18px;
                border-radius: 10px;
                box-shadow: 0 2px 6px rgba(0,0,0,0.06);
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
                padding: 10px 14px;
                border: 1px solid #e3e6ee;
                border-radius: 8px;
                font-size: 14px;
                outline: none;
            }

            .search-input {
                width: 320px;
                background: #fafbfc;
            }

            .search-input:focus, .filter-select:focus {
                border-color: #667eea;
                box-shadow: 0 0 0 4px rgba(102,126,234,0.06);
            }

            .btn-search, .btn-new {
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

            .btn-search:hover, .btn-new:hover {
                transform: translateY(-1px);
                box-shadow: 0 6px 18px rgba(102,126,234,0.15);
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

            .btn-edit, .btn-delete {
                color: white;
                border: none;
                padding: 8px 12px;
                border-radius: 6px;
                cursor: pointer;
                transition: 0.3s;
                display: inline-flex;
                align-items: center;
                gap: 6px;
                font-size: 13px;
                font-weight: 500;
                margin-right: 5px;
            }

            .btn-edit {
                background: #4a69bd;
            }

            .btn-delete {
                background: #e55039;
            }

            .btn-edit:hover, .btn-delete:hover {
                background: #28a745;
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

            .pagination a:hover, .pagination a.active {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                border: none;
            }

            /* Form Popup */
            .form-overlay {
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                background: rgba(0,0,0,0.6);
                display: none;
                justify-content: center;
                align-items: center;
                z-index: 2000;
            }

            .form-container {
                background: #fff;
                padding: 30px 25px;
                border-radius: 12px;
                width: 450px;
                max-width: 95%;
                box-shadow: 0 8px 30px rgba(0,0,0,0.25);
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
                color: #555;
                display: block;
            }

            .form-container input[type="text"],
            .form-container input[type="number"] {
                width: 100%;
                padding: 10px 12px;
                border: 1px solid #ccc;
                border-radius: 8px;
                font-size: 14px;
                outline: none;
                transition: all 0.2s ease;
            }

            .form-container input:focus {
                border-color: #667eea;
                box-shadow: 0 0 0 4px rgba(102,126,234,0.1);
            }

            #formMessage {
                font-size: 13px;
                color: #e74c3c;
                text-align: center;
                min-height: 18px;
                margin-top: 10px;
                font-weight: 600;
            }

            .form-buttons {
                display: flex;
                justify-content: space-between;
                gap: 10px;
                margin-top: 20px;
            }

            .btn-save, .btn-cancel {
                padding: 10px 18px;
                border-radius: 8px;
                font-weight: 600;
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
            }

            .btn-cancel {
                background: #6c757d;
                color: #fff;
            }

            .btn-cancel:hover {
                background: #5a6268;
            }

            @media (max-width: 900px) {
                .content { 
                    padding: 18px; 
                    margin-left: 0; 
                    width: 100%; 
                }
                .sidebar { 
                    display: none; 
                }
                .search-input {
                    width: 100%;
                }
            }
  /* Giới hạn độ rộng các cột - THÊM VÀO PHẦN <style> */
.inventory-table thead tr th:nth-child(1) { width: 8%; }   /* Part ID */
.inventory-table thead tr th:nth-child(2) { width: 10%; }  /* Inventory ID */
.inventory-table thead tr th:nth-child(3) { width: 20%; }  /* Part Name */
.inventory-table thead tr th:nth-child(4) { width: 10%; }  /* Quantity */
.inventory-table thead tr th:nth-child(5) { width: 15%; }  /* Last Updated By */
.inventory-table thead tr th:nth-child(6) { width: 15%; }  /* Last Update Time */
.inventory-table thead tr th:nth-child(7) { width: 19%; }  /* Last Update Time */
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
            </div>

            <!-- Content -->
            <div class="content">
                <h2>Danh sách hàng tồn kho</h2>

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
                    <form action="numberPart" method="POST" style="display:flex; width:100%; align-items:center; gap:10px;">
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
                                <option value="partName" ${param.filter == 'partName' ? 'selected' : ''}>By Part Name</option>
                                <option value="unitPrice" ${param.filter == 'unitPrice' ? 'selected' : ''}>By Unit Price</option>
                                <option value="updatePerson" ${param.filter == 'updatePerson' ? 'selected' : ''}>By Update Person</option>
                                <option value="updateDate" ${param.filter == 'updateDate' ? 'selected' : ''}>By Update Date</option>
                            </select>

                            <button type="button" class="btn-new" onclick="openForm('new')">
                                <i class="fas fa-plus"></i> New Part
                            </button>
                        </div>
                    </form>
                </div>

                <!-- Table -->
                <table class="inventory-table">
                    <thead>
                        <tr>
                            <th>Part ID</th>
                            <th>Part Name</th>
                            <th>Description</th>
                            <th>Unit Price</th>
                            <th>Last Updated By</th>
                            <th>Last Update Time</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${list}" var="ls">
                            <tr>
                                <td>${ls.partId}</td>
                                <td>${ls.partName}</td>
                                <td>${ls.description}</td>
                                <td>${ls.unitPrice}</td>
                                <td>${ls.userName}</td>
                                <td>${ls.lastUpdatedDate}</td>
                                <td>
                                    <button type="button" class="btn-edit" 
                                            onclick="openForm('edit', 
                                            '${ls.partId}', 
                                            '${ls.partName}',
                                            '${ls.description}', 
                                            '${ls.unitPrice}')">
                                        <i class="fas fa-edit"></i> Edit
                                    </button>
                                    <button type="button" class="btn-delete" 
                                            onclick="confirmDelete(${ls.partId})">
                                        <i class="fas fa-trash"></i> Delete
                                    </button>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>

                <!-- Form Popup -->
                <div class="form-overlay" id="formOverlay">
                    <div class="form-container">
                        <h2 id="formTitle">Add New Part</h2>
                        <form action="numberPart" method="POST" id="partForm">
                            <input type="hidden" name="action" id="actionInput" value="add">
                            <input type="hidden" name="partId" id="partId">

                            <label>Part Name *</label>
                            <input type="text" name="partName" id="partName" required>

                            <label>Description *</label>
                            <input type="text" name="description" id="partDescription" required>

                            <label>Unit Price *</label>
                            <input type="number" name="unitPrice" id="partPrice" step="0.01" required>

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
            // Open form Add/Edit
            function openForm(mode, partId = '', partName = '', description = '', unitPrice = '') {
                const overlay = document.getElementById("formOverlay");
                const title = document.getElementById("formTitle");
                const actionInput = document.getElementById("actionInput");
                
                overlay.style.display = "flex";
                document.getElementById("formMessage").textContent = "";

                if (mode === "new") {
                    title.textContent = "Add New Part";
                    actionInput.value = "add";
                    document.getElementById("partId").value = "";
                    document.getElementById("partName").value = "";
                    document.getElementById("partDescription").value = "";
                    document.getElementById("partPrice").value = "";
                } else {
                    title.textContent = "Edit Part";
                    actionInput.value = "edit";
                    document.getElementById("partId").value = partId;
                    document.getElementById("partName").value = partName;
                    document.getElementById("partDescription").value = description;
                    document.getElementById("partPrice").value = unitPrice;
                }
            }

            // Close form
            function closeForm() {
                document.getElementById("formOverlay").style.display = "none";
            }

            // Confirm delete
            function confirmDelete(partId) {
                if (confirm("Bạn có chắc muốn xóa Part ID = " + partId + " ?")) {
                    const form = document.createElement('form');
                    form.method = 'POST';
                    form.action = 'numberPart';
                    
                    const actionInput = document.createElement('input');
                    actionInput.type = 'hidden';
                    actionInput.name = 'action';
                    actionInput.value = 'delete';
                    
                    const idInput = document.createElement('input');
                    idInput.type = 'hidden';
                    idInput.name = 'partId';
                    idInput.value = partId;
                    
                    form.appendChild(actionInput);
                    form.appendChild(idInput);
                    document.body.appendChild(form);
                    form.submit();
                }
            }

            // Close popup when click outside
            document.getElementById("formOverlay").addEventListener('click', function(e) {
                if (e.target === this) {
                    closeForm();
                }
            });

            // Pagination logic
            let currentPage = 1;
            const rowsPerPage = 10;

            function renderTable() {
                const tableBody = document.querySelector(".inventory-table tbody");
                if (!tableBody) return;

                const keyword = document.querySelector(".search-input").value.toLowerCase();
                const rows = Array.from(tableBody.rows);

                const filteredRows = rows.filter(row => {
                    return Array.from(row.cells).slice(0, 6)
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
                    btn.onclick = e => { e.preventDefault(); onClick(); };
                    return btn;
                }

                pagination.appendChild(createBtn("« First", () => { currentPage = 1; renderTable(); }));
                pagination.appendChild(createBtn("‹ Prev", () => { if(currentPage>1){ currentPage--; renderTable(); }}));

                let start = Math.max(currentPage - 2, 1);
                let end = Math.min(start + 4, totalPages);
                for (let i = start; i <= end; i++) {
                    pagination.appendChild(createBtn(i, () => { currentPage = i; renderTable(); }, i===currentPage));
                }

                pagination.appendChild(createBtn("Next ›", () => { if(currentPage<totalPages){ currentPage++; renderTable(); }}));
                pagination.appendChild(createBtn("Last »", () => { currentPage = totalPages; renderTable(); }));
            }

            document.querySelector(".search-input").addEventListener("input", () => {
                currentPage = 1;
                renderTable();
            });

            document.addEventListener("DOMContentLoaded", renderTable);
        </script>
    </body>
</html>