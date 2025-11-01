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
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    background: #f5f5f5;
    color: #333;
    line-height: 1.6;
    -webkit-font-smoothing: antialiased;
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
    z-index: 100;
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

/* Content */
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
}

/* Messages */
.success-message {
    background: #d4edda;
    color: #155724;
    padding: 12px 20px;
    border-radius: 6px;
    margin: 0 0 20px 0;
    border: 1px solid #c3e6cb;
    display: flex;
    align-items: center;
    gap: 10px;
    font-size: 14px;
}

.error-message {
    background: #f8d7da;
    color: #721c24;
    padding: 12px 20px;
    border-radius: 6px;
    margin: 0 0 20px 0;
    border: 1px solid #f5c6cb;
    display: flex;
    align-items: center;
    gap: 10px;
    font-size: 14px;
}

/* ========== DETAIL PANEL - THÊM MỚI ========== */
.detail-panel {
    background: linear-gradient(135deg, #e8f0fe 0%, #f0f4ff 100%);
    border: 2px solid #4285f4;
    border-radius: 12px;
    padding: 25px;
    margin-bottom: 25px;
    box-shadow: 0 4px 12px rgba(66, 133, 244, 0.15);
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
    border-radius: 10px;
    border-left: 5px solid;
    box-shadow: 0 2px 8px rgba(0,0,0,0.08);
    transition: all 0.3s;
}

.status-card:hover {
    transform: translateY(-3px);
    box-shadow: 0 4px 16px rgba(0,0,0,0.12);
}

.status-card.available {
    border-left-color: #28a745;
}

.status-card.fault {
    border-left-color: #ffc107;
}

.status-card.inuse {
    border-left-color: #17a2b8;
}

.status-card.retired {
    border-left-color: #6c757d;
}

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
    transition: 0.2s;
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

.inventory-table tbody td {
    padding: 12px 16px;
    border-bottom: 1px solid #e0e0e0;
    font-size: 13px;
    color: #666;
}

.inventory-table tbody tr:hover {
    background-color: #f0f0f0;
}

.btn-edit, .btn-delete, .btn-detail {
    color: white;
    border: none;
    padding: 7px 12px;
    border-radius: 6px;
    cursor: pointer;
    transition: 0.2s;
    display: inline-flex;
    align-items: center;
    gap: 6px;
    font-size: 13px;
    font-weight: 500;
    margin-right: 5px;
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
.form-container input[type="number"] {
    width: 100%;
    padding: 9px 12px;
    border: 1px solid #d0d0d0;
    border-radius: 6px;
    font-size: 14px;
    outline: none;
    transition: all 0.2s ease;
    background: #fafafa;
}

.form-container input:focus {
    border-color: #999;
    box-shadow: 0 0 0 3px rgba(0,0,0,0.05);
    background: white;
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

/* Column widths - CẬP NHẬT ĐỂ CÓ 8 CỘT */
.inventory-table thead tr th:nth-child(1) { width: 7%; }  /* Part ID */
.inventory-table thead tr th:nth-child(2) { width: 12%; } /* Part Name */
.inventory-table thead tr th:nth-child(3) { width: 16%; } /* Description */
.inventory-table thead tr th:nth-child(4) { width: 8%; }  /* Unit Price */
.inventory-table thead tr th:nth-child(5) { width: 7%; }  /* Quantity */
.inventory-table thead tr th:nth-child(6) { width: 11%; } /* Last Updated By */
.inventory-table thead tr th:nth-child(7) { width: 11%; } /* Last Update Time */
.inventory-table thead tr th:nth-child(8) { width: 28%; } /* Action */

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

/* Highlight quantity */
.inventory-table tbody td:nth-child(5) {
    font-weight: 600;
    color: #28a745;
}

.success-message, .error-message {
    transition: all 0.5s ease;
}

.message-fade-out {
    opacity: 0;
    transform: translateY(-20px);
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
    .search-filter-container form {
        flex-direction: column;
    }
    .filter-group {
        width: 100%;
        justify-content: space-between;
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

                <!-- ========== DETAIL PANEL - THÊM MỚI ========== -->
                <c:if test="${showDetail && selectedPart != null}">
                    <div class="detail-panel">
                        <div class="detail-header">
                            <h3>
                                <i class="fas fa-chart-pie"></i> 
                                Chi tiết trạng thái: ${selectedPart.partName}
                            </h3>
                            <form action="numberPart" method="get" style="display: inline;">
                                <button type="submit" class="btn-close-detail">
                                    <i class="fas fa-times"></i> Đóng
                                </button>
                            </form>
                        </div>
                        
                        <div class="status-grid">
                            <div class="status-card available">
                                <h4><i class="fas fa-check-circle"></i> Available (Sẵn sàng)</h4>
                                <div class="count">${statusCount['Available']}</div>
                            </div>
                            
                            <div class="status-card fault">
                                <h4><i class="fas fa-exclamation-triangle"></i> Fault (Lỗi)</h4>
                                <div class="count">${statusCount['Fault']}</div>
                            </div>
                            
                            <div class="status-card inuse">
                                <h4><i class="fas fa-tools"></i> InUse (Đang dùng)</h4>
                                <div class="count">${statusCount['InUse']}</div>
                            </div>
                            
                            <div class="status-card retired">
                                <h4><i class="fas fa-archive"></i> Retired (Ngừng dùng)</h4>
                                <div class="count">${statusCount['Retired']}</div>
                            </div>
                        </div>
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
                                <option value="quantity" ${param.filter == 'quantity' ? 'selected' : ''}>By Quantity</option>
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
                            <th>Quantity</th>
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
                                <td>${ls.quantity}</td>
                                <td>${ls.userName}</td>
                                <td>${ls.lastUpdatedDate}</td>
                                <td>
                                    <!-- ========== NÚT DETAIL - THÊM MỚI ========== -->
                                    <form action="numberPart" method="post" style="display: inline;">
                                        <input type="hidden" name="action" value="detail">
                                        <input type="hidden" name="partId" value="${ls.partId}">
                                        <button type="submit" class="btn-detail">
                                            <i class="fas fa-info-circle"></i> Detail
                                        </button>
                                    </form>
                                    
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
        <form action="numberPart" method="POST" id="partForm" onsubmit="return validateForm()">
            <input type="hidden" name="action" id="actionInput" value="add">
            <input type="hidden" name="partId" id="partId">

            <label>Part Name * (Tối thiểu 3 ký tự)</label>
            <input type="text" name="partName" id="partName" required 
                   minlength="3" maxlength="30"
                   placeholder="Nhập tên part (ít nhất 3 ký tự)">

            <label>Description * (10-100 ký tự)</label>
            <input type="text" name="description" id="partDescription" required 
                   minlength="10" maxlength="100"
                   placeholder="Nhập mô tả (10-100 ký tự)">

            <label>Unit Price *</label>
            <input type="number" name="unitPrice" id="partPrice" 
                   step="0.01" required min="0.01" max="9999999.99"
                   placeholder="Nhập giá (0 < giá < 10,000,000)">

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
    // ========== FORM FUNCTIONS ==========
    function openForm(mode, partId = '', partName = '', description = '', unitPrice = '') {
        const overlay = document.getElementById("formOverlay");
        const title = document.getElementById("formTitle");
        const actionInput = document.getElementById("actionInput");
        const formMessage = document.getElementById("formMessage");

        overlay.style.display = "flex";
        formMessage.textContent = "";
        formMessage.style.color = "#dc3545";

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

    function closeForm() {
        document.getElementById("formOverlay").style.display = "none";
        document.getElementById("formMessage").textContent = "";
    }

    function validateForm() {
        const partName = document.getElementById("partName").value.trim();
        const description = document.getElementById("partDescription").value.trim();
        const unitPrice = parseFloat(document.getElementById("partPrice").value);
        const formMessage = document.getElementById("formMessage");
        
        formMessage.textContent = "";
        formMessage.style.color = "#dc3545";
        
        // Validate Part Name (min 3, max 30)
        if (partName.length < 3) {
            formMessage.textContent = "❌ Tên Part phải có ít nhất 3 ký tự!";
            return false;
        }
        
        if (partName.length > 30) {
            formMessage.textContent = "❌ Tên Part không được vượt quá 30 ký tự!";
            return false;
        }
        
        // Validate Description (min 10, max 100)
        if (description.length < 10) {
            formMessage.textContent = "❌ Mô tả phải có ít nhất 10 ký tự!";
            return false;
        }
        
        if (description.length > 100) {
            formMessage.textContent = "❌ Mô tả không được vượt quá 100 ký tự!";
            return false;
        }
        
        // Validate Unit Price (0 < price < 10,000,000)
        if (isNaN(unitPrice) || unitPrice <= 0 || unitPrice >= 10000000) {
            formMessage.textContent = "❌ Giá phải lớn hơn 0 và nhỏ hơn 10,000,000!";
            return false;
        }
        
        return true;
    }

    // ========== DELETE FUNCTION ==========
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

    // ========== PAGINATION VARIABLES ==========
    let currentPage = 1;
    const rowsPerPage = 10;

    // ========== TABLE RENDERING ==========
    function renderTable() {
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

    // ========== EVENT LISTENERS ==========
    document.addEventListener("DOMContentLoaded", function() {
        // Initialize table on page load
        renderTable();

        // Search input listener
        const searchInput = document.querySelector(".search-input");
        if (searchInput) {
            searchInput.addEventListener("input", () => {
                currentPage = 1;
                renderTable();
            });
        }

        // Form overlay click to close
        const formOverlay = document.getElementById("formOverlay");
        if (formOverlay) {
            formOverlay.addEventListener('click', function (e) {
                if (e.target === this) {
                    closeForm();
                }
            });
        }

        // Real-time character counter for Part Name
        const partNameInput = document.getElementById("partName");
        if (partNameInput) {
            partNameInput.addEventListener("input", function() {
                const length = this.value.length;
                const formMessage = document.getElementById("formMessage");
                
                if (length === 0) {
                    formMessage.textContent = "";
                } else if (length < 3) {
                    formMessage.textContent = `⚠️ Tên Part: Còn thiếu ${3 - length} ký tự`;
                    formMessage.style.color = "#ff9800";
                } else if (length > 30) {
                    formMessage.textContent = `❌ Tên Part: Vượt quá ${length - 30} ký tự`;
                    formMessage.style.color = "#dc3545";
                } else {
                    formMessage.textContent = `✓ Tên Part: ${length}/30 ký tự`;
                    formMessage.style.color = "#28a745";
                }
            });
        }

        // Real-time character counter for Description
        const descriptionInput = document.getElementById("partDescription");
        if (descriptionInput) {
            descriptionInput.addEventListener("input", function() {
                const length = this.value.length;
                const formMessage = document.getElementById("formMessage");
                
                if (length === 0) {
                    formMessage.textContent = "";
                } else if (length < 10) {
                    formMessage.textContent = `⚠️ Mô tả: Còn thiếu ${10 - length} ký tự`;
                    formMessage.style.color = "#ff9800";
                } else if (length > 100) {
                    formMessage.textContent = `❌ Mô tả: Vượt quá ${length - 100} ký tự`;
                    formMessage.style.color = "#dc3545";
                } else {
                    formMessage.textContent = `✓ Mô tả: ${length}/100 ký tự`;
                    formMessage.style.color = "#28a745";
                }
            });
        }

        // Auto-hide success/error messages after 5 seconds
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
        <%
            // Xóa message sau khi đã hiển thị
            session.removeAttribute("successMessage");
            session.removeAttribute("errorMessage");
        %>
    </body>
</html>