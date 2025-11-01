<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
    <title>Quản Lý Hợp Đồng Khách Hàng</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #f4f4f4;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        .sidebar {
            min-height: 100vh;
            background-color: #111;
            color: #fff;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            padding-bottom: 20px;
        }
        .sidebar .nav-link {
            color: #ccc;
            padding: 10px 15px;
            border-radius: 6px;
            margin-bottom: 5px;
            transition: all 0.3s ease;
        }
        .sidebar .nav-link:hover,
        .sidebar .nav-link.fw-bold {
            background-color: #fff;
            color: #000;
            font-weight: 600;
        }
        .main-content {
            background-color: #fff;
            min-height: 100vh;
        }
        .table-hover tbody tr:hover {
            background-color: rgba(0, 0, 0, 0.05);
        }
        .card-header {
            background-color: #000;
            color: #fff;
        }
        .badge-equipment-count {
            background-color: #0d6efd;
            color: white;
            font-size: 0.75rem;
            padding: 0.25rem 0.5rem;
            border-radius: 10px;
        }
        .warning-icon {
            color: #dc3545;
            animation: pulse 1.5s infinite;
        }
        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.5; }
        }
        .customer-tooltip {
            position: relative;
            cursor: pointer;
        }
        .customer-tooltip:hover .tooltip-content {
            display: block;
        }
        .tooltip-content {
            display: none;
            position: absolute;
            background: #333;
            color: #fff;
            padding: 10px;
            border-radius: 6px;
            z-index: 1000;
            min-width: 200px;
            font-size: 0.85rem;
            top: 100%;
            left: 0;
            margin-top: 5px;
        }
    </style>
</head>

<body>
<div class="container-fluid">
    <div class="row">
        <!-- Sidebar -->
                <div class="col-md-2 sidebar p-4 d-flex flex-column">
                    <div>
                        <h4 class="text-center mb-4">
                            <i class="fas fa-cogs"></i> CRM CSS
                        </h4>
                        <nav class="nav flex-column">
                            <c:if test="${sessionScope.session_role eq 'Admin' || sessionScope.session_role eq 'Customer Support Staff'}">
                                <a class="nav-link ${currentPage eq 'dashboard' ? 'fw-bold bg-white text-dark' : ''}" href="dashboard.jsp">
                                    <i class="fas fa-palette me-2"></i> Trang chủ
                                </a>
                            </c:if>

                            <c:if test="${sessionScope.session_role eq 'Customer Support Staff'}">
                                <a class="nav-link ${currentPage eq 'users' ? 'fw-bold bg-white text-dark' : ''}" href="customerManagement">
                                    <i class="fas fa-users me-2"></i> Quản lý khách hàng
                                </a>
                            </c:if>
                            
                            <c:if test="${sessionScope.session_role eq 'Customer Support Staff'}">
                                <a class="nav-link ${currentPage eq 'users' ? 'fw-bold bg-white text-dark' : ''}" href="viewCustomerContracts">
                                    <i class="fas fa-file-contract me-2"></i> Quản lý hợp đồng
                                </a>
                            </c:if>
                            
                            <c:if test="${sessionScope.session_role eq 'Customer Support Staff'}">
                                <a class="nav-link ${currentPage eq 'users' ? 'fw-bold bg-white text-dark' : ''}" href="viewCustomerRequest">
                                    <i class="fas fa-clipboard-list"></i> Quản lý yêu cầu
                                </a>
                            </c:if>

                            <c:if test="${sessionScope.session_role eq 'Customer Support Staff'}">
                                <a  href="manageProfile" class="nav-link ${currentPage eq 'profile' ? 'fw-bold bg-white text-dark' : ''}">
                                    <i class="fas fa-user-circle me-2"></i><span> Hồ Sơ</span>
                                </a>
                            </c:if>
                        </nav>
                    </div>

                    <div class="mt-auto logout-section text-center">
                        <hr style="border-color: rgba(255,255,255,0.2);">
                        <button class="btn btn-outline-light w-100" onclick="logout()" style="border-radius: 10px;">
                            <i class="fas fa-sign-out-alt me-2"></i> Đăng xuất
                        </button>
                    </div>
                </div>

        <!-- Main Content -->
        <div class="col-md-10 main-content p-4">
            <!-- Header -->
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h2><i class="fas fa-file-contract text-dark"></i> Quản Lý Hợp Đồng Khách Hàng</h2>

                <div class="d-flex align-items-center gap-3">
                    <button class="btn btn-dark" onclick="openCreateContractModal()">
                        <i class="fas fa-plus-circle me-1"></i> Tạo hợp đồng
                    </button>
                    <span>Xin chào, <strong>${sessionScope.session_login.username}</strong></span>
                </div>
            </div>

            <!-- Search & Filter -->
            <div class="card mb-4">
                <div class="card-body">
                    <form action="viewCustomerContracts" method="GET">      
                        <!-- Hàng 1: Search + Trạng thái -->
                        <div class="row g-3 mb-2">
                            <div class="col-md-6">
                                <label class="form-label fw-bold">
                                    <i class="fas fa-search"></i> Tìm kiếm
                                </label>
                                <input type="text" class="form-control" name="keyword"
                                       placeholder="Tên khách hàng / SĐT / Email / Username..."
                                       value="${param.keyword}">
                            </div>

                            <div class="col-md-3">
                                <label class="form-label fw-bold">
                                    <i class="fas fa-toggle-on"></i> Trạng thái
                                </label>
                                <select name="status" class="form-select">
                                    <option value="">Tất cả</option>
                                    <option value="Active" ${param.status == 'Active' ? 'selected' : ''}>Active</option>
                                    <option value="Completed" ${param.status == 'Completed' ? 'selected' : ''}>Completed</option>
                                    <option value="Cancelled" ${param.status == 'Cancelled' ? 'selected' : ''}>Cancelled</option>
                                </select>
                            </div>

                            <!-- Nếu bạn muốn hiển thị loại hợp đồng -->
                            <!--
                            <div class="col-md-3">
                                <label class="form-label fw-bold">
                                    <i class="fas fa-clipboard-list"></i> Loại hợp đồng
                                </label>
                                <select name="contractType" class="form-select">
                                    <option value="">Tất cả</option>
                                    <option value="Rental" ${param.contractType == 'Rental' ? 'selected' : ''}>Rental</option>
                                    <option value="Purchase" ${param.contractType == 'Purchase' ? 'selected' : ''}>Purchase</option>
                                    <option value="Maintenance" ${param.contractType == 'Maintenance' ? 'selected' : ''}>Maintenance</option>
                                </select>
                            </div>
                            -->
                        </div>

                        <!-- Hàng 2: Lọc ngày -->
                        <div class="row g-3 mb-2">
                            <div class="col-md-3">
                                <label class="form-label fw-bold">
                                    <i class="fas fa-calendar-alt"></i> Từ ngày ký
                                </label>
                                <input type="date" class="form-control" id="fromDate" name="fromDate" value="${param.fromDate}">
                            </div>

                            <div class="col-md-3">
                                <label class="form-label fw-bold">
                                    <i class="fas fa-calendar-alt"></i> Đến ngày ký
                                </label>
                                <input type="date" class="form-control" id="toDate" name="toDate" value="${param.toDate}">
                            </div>
                        </div>

                        <!-- Hàng 3: Buttons -->
                        <div class="row g-3">
                            <div class="col-md-3 d-grid">
                                <button type="submit" class="btn btn-dark">
                                    <i class="fas fa-search me-1"></i> Tìm kiếm
                                </button>
                            </div>
                            <div class="col-md-3 d-grid">
                                <a href="viewCustomerContracts" class="btn btn-outline-dark">
                                    <i class="fas fa-sync-alt me-1"></i> Làm mới
                                </a>
                            </div>
                        </div>

                    </form>
                </div>
            </div>

            <!-- Contracts Table -->
            <div class="card">
                <div class="card-header">
                    <h5 class="mb-0"><i class="fas fa-list"></i> Danh sách hợp đồng</h5>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover mb-0">
                            <thead class="table-light">
                            <tr>
                                <th>Mã hợp đồng</th>
                                <th>Khách hàng</th>
                                <th>Ngày ký</th>
                                <th>Trạng thái</th>
                                <th>Chi tiết</th>
                                <th>Lịch sử Yêu cầu</th>
                                <th>Thao tác</th>
                            </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="contract" items="${contractList}" varStatus="status">
                                    <tr 
                                        data-contractid="${contract.contractId}"
                                        data-customerid="${contract.customerId}"
                                        data-customername="${contract.customerName}"
                                        data-customeremail="${contract.customerEmail}"
                                        data-customerphone="${contract.customerPhone}"
                                        data-customeraddress="${contract.customerAddress}"
                                        data-verified="${contract.verified}"
                                        data-contracttype="${contract.contractType}"
                                        data-contractdate="${contract.contractDate}"
                                        data-startdate="${contract.startDate}"
                                        data-enddate="${contract.endDate}"
                                        data-status="${contract.status}"
                                        data-details="${contract.details}"
                                        data-equipmentcount="${contract.equipmentCount}">

                                        <td><strong>#${contract.contractId}</strong></td>
                                        
                                        <!-- Khách hàng với tooltip -->
                                        <td>
                                            <div class="customer-tooltip">
                                                <span class="text-primary" style="cursor: pointer;">
                                                    ${contract.customerName}
                                                </span>
                                                <div class="tooltip-content">
                                                    <strong>${contract.customerName}</strong><br>
                                                    <i class="fas fa-phone"></i> ${contract.customerPhone}<br>
                                                    <i class="fas fa-envelope"></i> ${contract.customerEmail}<br>
                                                    <i class="fas fa-check-circle ${contract.verified ? 'text-success' : 'text-danger'}"></i> 
                                                    ${contract.verified ? 'Đã xác thực' : 'Chưa xác thực'}
                                                </div>
                                            </div>
                                        </td>

                                        <!--
                                        <td>
                                            <c:choose>
                                                <c:when test="${contract.contractType eq 'Rental'}">
                                                    <span class="badge bg-info">Rental</span>
                                                </c:when>
                                                <c:when test="${contract.contractType eq 'Purchase'}">
                                                    <span class="badge bg-success">Purchase</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-secondary">Maintenance</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td> 
                                        -->
                                        
                                        <td>${contract.contractDate}</td>

                                        <td>
                                            <c:choose>
                                                <c:when test="${contract.status eq 'Active'}">
                                                    <span class="badge bg-success">Active</span>
                                                </c:when>
                                                <c:when test="${contract.status eq 'Completed'}">
                                                    <span class="badge bg-primary">Completed</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-danger">Cancelled</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>

                                        <td>
                                            <small class="text-muted">${contract.details}</small>
                                        </td>


                                        <!-- Số yêu cầu liên quan -->
                                        <td class="text-center">
                                            <button class="btn btn-sm btn-outline-info" 
                                                    onclick="viewServiceRequests('${contract.contractId}')">
                                                <i class="fas fa-clipboard-list"></i> 
                                                ${contract.requestCount > 0 ? contract.requestCount : '0'}
                                            </button>
                                        </td>

                                        <td>
                                            <div class="btn-group">
                                                <button class="btn btn-sm btn-outline-dark" 
                                                        title="Xem chi tiết"
                                                        onclick="viewContractDetails('${contract.contractId}')">
                                                    <i class="fas fa-eye"></i>
                                                </button>
                                                
                                                <button class="btn btn-sm btn-outline-primary" 
                                                        title="Xem thiết bị"
                                                        onclick="viewEquipmentList('${contract.contractId}')">
                                                    <i class="fas fa-tools"></i>
                                                </button>

                                                <c:if test="${not empty contract.documentUrl}">
                                                    <button class="btn btn-sm btn-outline-success" 
                                                            title="Xem hợp đồng"
                                                            onclick="viewContractDocument('${contract.documentUrl}')">
                                                        <i class="fas fa-file-pdf"></i>
                                                    </button>
                                                </c:if>

                                                <!-- <button class="btn btn-sm btn-outline-warning" 
                                                        title="Tạo Service Request"
                                                        onclick="createServiceRequestFromContract('${contract.contractId}', '${contract.customerId}')">
                                                    <i class="fas fa-plus-circle"></i>
                                                </button> -->
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>

                            <c:if test="${empty contractList}">
                                <tr>
                                    <td colspan="10" class="text-center py-4">
                                        <i class="fas fa-folder-open fa-3x text-muted mb-3"></i>
                                        <h5 class="text-muted">Không có hợp đồng nào</h5>
                                        <p class="text-muted">Chưa có hợp đồng nào được tạo.</p>
                                    </td>
                                </tr>
                            </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Pagination -->
                <c:if test="${totalPages >= 1}">
                    <c:url var="baseUrl" value="viewCustomerContracts">
                        <c:param name="keyword" value="${param.keyword}" />
                        <c:param name="status" value="${param.status}" />
                        <c:param name="contractType" value="${param.contractType}" />
                        <c:param name="contractDate" value="${param.contractDate}" />
                    </c:url>

                    <nav aria-label="Page navigation" class="mt-4">
                        <ul class="pagination justify-content-center">
                            <li class="page-item ${currentPageNumber <= 1 ? 'disabled' : ''}">
                                <a class="page-link" href="${baseUrl}&page=${currentPageNumber - 1}">
                                    <i class="fas fa-chevron-left"></i> Trước
                                </a>
                            </li>

                            <c:forEach var="i" begin="1" end="${totalPages}">
                                <li class="page-item ${i == currentPageNumber ? 'active' : ''}">
                                    <a class="page-link" href="${baseUrl}&page=${i}">${i}</a>
                                </li>
                            </c:forEach>

                            <li class="page-item ${currentPageNumber >= totalPages ? 'disabled' : ''}">
                                <a class="page-link" href="${baseUrl}&page=${currentPageNumber + 1}">
                                    Tiếp <i class="fas fa-chevron-right"></i>
                                </a>
                            </li>
                        </ul>
                    </nav>

                    <div class="text-center text-muted mb-3">
                        <small>
                            Trang <strong>${currentPageNumber}</strong> / <strong>${totalPages}</strong> |
                            Hiển thị <strong>${fn:length(contractList)}</strong> hợp đồng
                        </small>
                    </div>
                </c:if>
            </div>
        </div>
    </div>
</div>

<!-- Modal: View Contract Details -->
<div class="modal fade" id="contractDetailsModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header bg-dark text-white">
                <h5 class="modal-title">
                    <i class="fas fa-file-contract me-2"></i> Chi Tiết Hợp Đồng
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>

            <div class="modal-body">
                <h6 class="fw-bold mb-3"><i class="fas fa-info-circle"></i> Thông tin hợp đồng</h6>
                <table class="table table-bordered">
                    <tr><th style="width:30%">Mã hợp đồng</th><td id="detail-contractId"></td></tr>
                    <tr><th>Loại hợp đồng</th><td id="detail-contractType"></td></tr>
                    <tr><th>Ngày ký</th><td id="detail-contractDate"></td></tr>
                    <tr><th>Trạng thái</th><td id="detail-status"></td></tr>
                    <tr><th>Chi tiết</th><td id="detail-details"></td></tr>
                </table>

                <h6 class="fw-bold mb-3 mt-4"><i class="fas fa-user"></i> Thông tin khách hàng</h6>
                <table class="table table-bordered">
                    <tr><th style="width:30%">Họ tên</th><td id="detail-customerName"></td></tr>
                    <tr><th>Email</th><td id="detail-customerEmail"></td></tr>
                    <tr><th>Số điện thoại</th><td id="detail-customerPhone"></td></tr>
                </table>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
            </div>
        </div>
    </div>
</div>

<!-- Modal: View Equipment List -->
<div class="modal fade" id="equipmentListModal" tabindex="-1">
    <div class="modal-dialog modal-xl">
        <div class="modal-content">
            <div class="modal-header bg-dark text-white">
                <h5 class="modal-title">
                    <i class="fas fa-tools me-2"></i> Danh Sách Thiết Bị Trong Hợp Đồng
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>

            <div class="modal-body">
                <div id="equipmentListContent">
                    <div class="text-center py-4">
                        <div class="spinner-border" role="status">
                            <span class="visually-hidden">Loading...</span>
                        </div>
                    </div>
                </div>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
            </div>
        </div>
    </div>
</div>

<!-- Modal: View Service Requests -->
<div class="modal fade" id="serviceRequestsModal" tabindex="-1">
    <div class="modal-dialog modal-xl">
        <div class="modal-content">
            <div class="modal-header bg-dark text-white">
                <h5 class="modal-title">
                    <i class="fas fa-clipboard-list me-2"></i> Lịch Sử Service Request
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>

            <div class="modal-body">
                <div id="serviceRequestsContent">
                    <div class="text-center py-4">
                        <div class="spinner-border" role="status">
                            <span class="visually-hidden">Loading...</span>
                        </div>
                    </div>
                </div>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
            </div>
        </div>
    </div>
</div>

<!-- Modal: Create Contract -->
<div class="modal fade" id="createContractModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header bg-dark text-white">
                <h5 class="modal-title">
                    <i class="fas fa-plus-circle me-2"></i> Tạo hợp đồng mới
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>

            <form id="createContractForm">
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label fw-bold">Loại hợp đồng</label>
                        <select name="contractType" class="form-select" required>
                            <option value="">-- Chọn loại --</option>
                            <option value="Rental">Rental</option>
                            <option value="Purchase">Purchase</option>
                            <option value="Maintenance">Maintenance</option>
                        </select>
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-bold">Chi tiết hợp đồng</label>
                        <textarea name="details" class="form-control" rows="3" placeholder="Nhập chi tiết hợp đồng..." required></textarea>
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-bold">Ngày ký hợp đồng</label>
                        <input type="date" name="contractDate" class="form-control" required>
                    </div>
                </div>

                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-dark">Lưu hợp đồng</button>
                </div>
            </form>
        </div>
    </div>
</div>


<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script>
document.addEventListener("DOMContentLoaded", () => {
    const fromDate = document.getElementById("fromDate");
    const toDate = document.getElementById("toDate");
    const form = document.querySelector("form[action='viewCustomerContracts']");

    form.addEventListener("submit", e => {
        if (fromDate.value && toDate.value && fromDate.value > toDate.value) {
            e.preventDefault();
            Swal.fire({
                icon: "error",
                title: "Ngày không hợp lệ",
                text: "Ngày đến phải lớn hơn hoặc bằng ngày bắt đầu.",
                confirmButtonColor: "#000"
            });
        }
    });
});
    
function logout() {
    Swal.fire({
        title: 'Đăng xuất?',
        text: 'Bạn có chắc chắn muốn đăng xuất?',
        icon: 'question',
        showCancelButton: true,
        confirmButtonText: 'Đăng xuất',
        cancelButtonText: 'Hủy',
        confirmButtonColor: '#000'
    }).then(result => {
        if (result.isConfirmed) {
            window.location.href = 'logout';
        }
    });
}

function viewContractDetails(contractId) {
    const row = document.querySelector("tr[data-contractid='" + contractId + "']");
    if (!row) return;

    const get = name => row.dataset[name] || "(Không có thông tin)";

    document.getElementById("detail-contractId").innerText = "#" + contractId;
    document.getElementById("detail-contractType").innerText = get("contracttype");
    document.getElementById("detail-contractDate").innerText = get("contractdate");
    document.getElementById("detail-status").innerText = get("status");
    document.getElementById("detail-details").innerText = get("details");
    document.getElementById("detail-customerName").innerText = get("customername");
    document.getElementById("detail-customerEmail").innerText = get("customeremail");
    document.getElementById("detail-customerPhone").innerText = get("customerphone");
    

    new bootstrap.Modal(document.getElementById("contractDetailsModal")).show();
}

async function viewEquipmentList(contractId) {
    const modal = new bootstrap.Modal(document.getElementById("equipmentListModal"));
    modal.show();

    const content = document.getElementById("equipmentListContent");
    
    try {
        const ctx = window.location.pathname.split("/")[1];
        const response = await fetch("/" + ctx + "/getContractEquipment?contractId=" + contractId);
        
        if (!response.ok) throw new Error("Không thể tải danh sách thiết bị");
        
        const data = await response.json();
        
        if (data.equipment && data.equipment.length > 0) {
            let html = '<div class="table-responsive">' +
                      '<table class="table table-hover">' +
                      '<thead class="table-light">' +
                      '<tr>' +
                      '<th>#</th>' +
                      '<th>Model</th>' +
                      '<th>Serial Number</th>' +
                      '<th>Mô tả</th>' +
                      '<th>Ngày lắp</th>' +
                      '<th>Ngày bắt đầu</th>' +
                      '<th>Ngày kết thúc</th>' +
                      '<th>Giá</th>' +
                      '</tr>' +
                      '</thead><tbody>';
            
            data.equipment.forEach((eq, index) => {
                html += '<tr>' +
                       '<td>' + (index + 1) + '</td>' +
                       '<td><strong>' + eq.model + '</strong></td>' +
                       '<td><code>' + eq.serialNumber + '</code></td>' +
                       '<td>' + (eq.description || '-') + '</td>' +
                       '<td>' + (eq.installDate || '-') + '</td>' +
                       '<td>' + (eq.startDate || '-') + '</td>' +
                       '<td>' + (eq.endDate || '-') + '</td>' +
                       '<td>' + (eq.price ? eq.price.toLocaleString('vi-VN') + ' VNĐ' : '-') + '</td>' +
                       '</tr>';
            });
            
            html += '</tbody></table></div>';
            content.innerHTML = html;
        } else {
            content.innerHTML = '<div class="text-center py-4">' +
                              '<i class="fas fa-box-open fa-3x text-muted mb-3"></i>' +
                              '<h5 class="text-muted">Không có thiết bị nào</h5>' +
                              '</div>';
        }
    } catch (error) {
        console.error("Error:", error);
        content.innerHTML = '<div class="alert alert-danger">Không thể tải danh sách thiết bị</div>';
    }
}

async function viewServiceRequests(contractId) {
    const modal = new bootstrap.Modal(document.getElementById("serviceRequestsModal"));
    modal.show();

    const content = document.getElementById("serviceRequestsContent");
    
    try {
        const ctx = window.location.pathname.split("/")[1];
        const response = await fetch("/" + ctx + "/getContractRequests?contractId=" + contractId);
        
        if (!response.ok) throw new Error("Không thể tải lịch sử yêu cầu");
        
        const data = await response.json();
        
        if (data.requests && data.requests.length > 0) {
            let html = '<div class="table-responsive">' +
                      '<table class="table table-hover">' +
                      '<thead class="table-light">' +
                      '<tr>' +
                      '<th>Mã Yêu Cầu</th>' +
                      '<th>Thiết bị</th>' +
                      '<th>Loại yêu cầu</th>' +
                      '<th>Mức độ</th>' +
                      '<th>Trạng thái</th>' +
                      '<th>Ngày tạo</th>' +
                      '<th>Mô tả</th>' +
                      '</tr>' +
                      '</thead><tbody>';
            
            data.requests.forEach(req => {
                const priorityBadge = req.priorityLevel === 'Urgent' ? 'bg-danger' : 
                                    req.priorityLevel === 'High' ? 'bg-warning' : 'bg-secondary';
                const statusBadge = req.status === 'Completed' ? 'bg-primary' :
                                  req.status === 'Approved' ? 'bg-success' :
                                  req.status === 'Pending' ? 'bg-warning' : 'bg-danger';
                
                html += '<tr>' +
                       '<td><strong>#' + req.requestId + '</strong></td>' +
                       '<td>' + (req.equipmentModel || '-') + '</td>' +
                       '<td><span class="badge bg-info">' + req.requestType + '</span></td>' +
                       '<td><span class="badge ' + priorityBadge + '">' + req.priorityLevel + '</span></td>' +
                       '<td><span class="badge ' + statusBadge + '">' + req.status + '</span></td>' +
                       '<td>' + req.requestDate + '</td>' +
                       '<td>' + (req.description ? req.description.substring(0, 50) + '...' : '-') + '</td>' +
                       '</tr>';
            });
            
            html += '</tbody></table></div>';
            content.innerHTML = html;
        } else {
            content.innerHTML = '<div class="text-center py-4">' +
                              '<i class="fas fa-clipboard fa-3x text-muted mb-3"></i>' +
                              '<h5 class="text-muted">Chưa có yêu cầu nào</h5>' +
                              '</div>';
        }
    } catch (error) {
        console.error("Error:", error);
        content.innerHTML = '<div class="alert alert-danger">Không thể tải lịch sử yêu cầu</div>';
    }
}

function viewContractDocument(documentUrl) {
    if (!documentUrl) {
        Swal.fire({
            icon: 'warning',
            title: 'Không có tài liệu',
            text: 'Hợp đồng này chưa có file scan.',
            confirmButtonColor: '#000'
        });
        return;
    }
    
    // Mở file trong tab mới
    window.open(documentUrl, '_blank');
}

function createServiceRequestFromContract(contractId, customerId) {
    Swal.fire({
        title: 'Tạo Service Request',
        text: 'Bạn muốn tạo yêu cầu dịch vụ cho hợp đồng này?',
        icon: 'question',
        showCancelButton: true,
        confirmButtonText: 'Tạo yêu cầu',
        cancelButtonText: 'Hủy',
        confirmButtonColor: '#000'
    }).then(result => {
        if (result.isConfirmed) {
            // Chuyển đến trang tạo request với thông tin hợp đồng
            window.location.href = 'viewCustomerRequest?action=create&contractId=' + contractId + '&customerId=' + customerId;
        }
    });
}

function openCreateContractModal() {
    new bootstrap.Modal(document.getElementById("createContractModal")).show();
}

document.getElementById("createContractForm").addEventListener("submit", async function (e) {
    e.preventDefault();
    const formData = new FormData(this);
    try {
        const ctx = window.location.pathname.split("/")[1];
        const res = await fetch(`/${ctx}/createContract`, {
            method: "POST",
            body: formData
        });
        const result = await res.json();
        if (result.success) {
            Swal.fire({
                icon: "success",
                title: "Thành công!",
                text: result.message,
                confirmButtonColor: "#000"
            }).then(() => window.location.reload());
        } else {
            Swal.fire({
                icon: "error",
                title: "Thất bại!",
                text: result.message,
                confirmButtonColor: "#000"
            });
        }
    } catch (error) {
        console.error(error);
        Swal.fire({
            icon: "error",
            title: "Lỗi hệ thống!",
            text: "Không thể tạo hợp đồng. Vui lòng thử lại sau.",
            confirmButtonColor: "#000"
        });
    }
});

</script>
</body>
</html>