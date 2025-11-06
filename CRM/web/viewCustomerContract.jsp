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
        
        .appendix-item {
            border-left: 3px solid #0d6efd;
            padding: 10px;
            margin-bottom: 10px;
            background-color: #f8f9fa;
            border-radius: 4px;
        }

        .equipment-selection {
            max-height: 400px;
            overflow-y: auto;
            border: 1px solid #dee2e6;
            padding: 10px;
            border-radius: 5px;
            background-color: #fff;
        }

        .equipment-item {
            padding: 8px;
            margin-bottom: 5px;
            background: white;
            border: 1px solid #e0e0e0;
            border-radius: 4px;
            transition: background-color 0.2s;
        }

        .equipment-item:hover {
            background: #f8f9fa;
        }

        .equipment-item .form-check {
            margin-bottom: 0;
        }

        .equipment-item .form-check-label {
            cursor: pointer;
            width: 100%;
        }

        .category-badge {
            font-size: 0.7rem;
            padding: 2px 6px;
            border-radius: 3px;
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
                                                        onclick="viewContractDetailsWithAppendix('${contract.contractId}')">
                                                    <i class="fas fa-eye"></i>
                                                </button>
                                                
                                                <button class="btn btn-sm btn-outline-primary" 
                                                        title="Xem thiết bị"
                                                        onclick="viewEquipmentList('${contract.contractId}')">
                                                    <i class="fas fa-tools"></i>
                                                </button>
                                                    
                                                    <button class="btn btn-sm btn-outline-warning" 
                                                            title="Thêm phụ lục"
                                                            onclick="openAddAppendixModal('${contract.contractId}', '${contract.customerName}')">
                                                        <i class="fas fa-file-medical"></i>
                                                    </button>

                                                <c:if test="${not empty contract.documentUrl}">
                                                    <button class="btn btn-sm btn-outline-success" 
                                                            title="Xem hợp đồng"
                                                            onclick="viewContractDocument('${contract.documentUrl}')">
                                                        <i class="fas fa-file-pdf"></i>
                                                    </button>
                                                </c:if>
                                                        
                                                <c:if test="${contract.canDelete}">
                                                    <button class="btn btn-sm btn-outline-danger" 
                                                            title="Xóa hợp đồng"
                                                            onclick="deleteContract('${contract.contractId}', '${contract.customerName}')">
                                                        <i class="fas fa-trash"></i>
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
                
                <h6 class="fw-bold mb-3 mt-4">
                    <i class="fas fa-file-medical"></i> Phụ lục hợp đồng 
                    (<span id="appendixCount">0</span>)
                </h6>
                <div id="appendixListContainer">
                    <p class="text-muted">Chưa có phụ lục nào</p>
                </div>
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
    <div class="modal-dialog modal-xl">
        <div class="modal-content">
            <div class="modal-header bg-dark text-white">
                <h5 class="modal-title">
                    <i class="fas fa-plus-circle me-2"></i> Tạo hợp đồng mới
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>

            <form id="createContractForm" enctype="multipart/form-data">
                <div class="modal-body">
                    <div class="row">
                        <!-- Cột trái: Thông tin hợp đồng -->
                        <div class="col-md-6">
                            <h6 class="fw-bold mb-3">
                                <i class="fas fa-file-contract"></i> Thông tin hợp đồng
                            </h6>

                            <div class="mb-3">
                                <label class="form-label fw-bold">
                                    Khách hàng <span class="text-danger">*</span>
                                </label>
                                <select name="customerId" id="contract-customerSelect" class="form-select" required>
                                    <option value="">-- Chọn khách hàng --</option>
                                    <c:forEach var="c" items="${customerList}">
                                        <option value="${c.accountId}">${c.fullName} (${c.email})</option>
                                    </c:forEach>
                                </select>
                                <div class="invalid-feedback">Vui lòng chọn khách hàng</div>
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold">
                                    Loại hợp đồng <span class="text-danger">*</span>
                                </label>
                                <select name="contractType" class="form-select" required>
                                    <option value="">-- Chọn loại --</option>
                                    <option value="Warranty">Bảo hành</option>
                                    <option value="Maintenance">Bảo trì</option>
                                    <option value="Sales">Mua bán</option>
                                </select>
                                <div class="invalid-feedback">Vui lòng chọn loại hợp đồng</div>
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold">
                                    Ngày ký hợp đồng <span class="text-danger">*</span>
                                </label>
                                <input type="date" 
                                       name="contractDate" 
                                       id="contractDate"
                                       class="form-control" 
                                       max="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>"
                                       required>
                                <small class="text-muted">
                                    <i class="fas fa-info-circle"></i> Ngày ký không được ở tương lai
                                </small>
                                <div class="invalid-feedback">Vui lòng chọn ngày ký hợp lệ</div>
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold">
                                    Trạng thái <span class="text-danger">*</span>
                                </label>
                                <select name="status" class="form-select" required>
                                    <option value="Active" selected>Active</option>
                                    <option value="Completed">Completed</option>
                                    <option value="Cancelled">Cancelled</option>
                                </select>
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold">
                                    Chi tiết hợp đồng <span class="text-danger">*</span>
                                </label>
                                <textarea name="details" 
                                          id="contract-details"
                                          class="form-control" 
                                          rows="3" 
                                          placeholder="Nhập chi tiết hợp đồng..." 
                                          required
                                          minlength="10"
                                          maxlength="255"></textarea>
                                <small class="text-muted">
                                    <span id="contract-detailsCount">0</span>/255 ký tự (tối thiểu 10)
                                </small>
                                <div class="invalid-feedback">Chi tiết phải từ 10-255 ký tự</div>
                            </div>
                        </div>

                        <!-- Cột phải: Chọn thiết bị -->
                        <div class="col-md-6">
                            <h6 class="fw-bold mb-3">
                                <i class="fas fa-tools"></i> Chọn thiết bị <span class="text-danger">*</span>
                            </h6>

                            <div class="mb-3">
                                <input type="text" 
                                       id="contract-equipmentSearch" 
                                       class="form-control" 
                                       placeholder="🔍 Tìm kiếm thiết bị...">
                            </div>

                            <div class="equipment-selection" id="contract-equipmentList">
                                <div class="text-center text-muted py-4">
                                    <i class="fas fa-info-circle"></i> Vui lòng chọn khách hàng trước
                                </div>
                            </div>

                            <div class="mt-3">
                                <h6 class="fw-bold">
                                    Thiết bị đã chọn (<span id="contract-selectedCount">0</span>)
                                    <span class="text-danger">*</span>
                                </h6>
                                <div id="contract-selectedEquipmentList" 
                                     class="border rounded p-2" 
                                     style="min-height: 100px;">
                                    <p class="text-muted text-center mb-0">Chưa có thiết bị nào được chọn</p>
                                </div>
                                <div class="invalid-feedback d-block" id="contract-equipmentError" style="display: none;"></div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-dark">
                        <i class="fas fa-save me-1"></i> Lưu hợp đồng
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Modal: Add Contract Appendix -->
<div class="modal fade" id="addAppendixModal" tabindex="-1">
    <div class="modal-dialog modal-xl">
        <div class="modal-content">
            <div class="modal-header bg-dark text-white text-dark">
                <h5 class="modal-title">
                    <i class="fas fa-file-medical me-2"></i> Thêm Phụ Lục Hợp Đồng
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>

            <form id="addAppendixForm">
                <input type="hidden" id="appendix-contractId" name="contractId">
                
                <div class="modal-body">
                    <div class="alert alert-info">
                        <i class="fas fa-info-circle"></i> 
                        Hợp đồng: <strong id="appendix-contractInfo"></strong>
                    </div>

                    <div class="row">
                        <!-- Thông tin phụ lục -->
                        <div class="col-md-6">
                            <h6 class="fw-bold mb-3">
                                <i class="fas fa-clipboard"></i> Thông tin phụ lục
                            </h6>

                            <div class="mb-3">
                                <label class="form-label fw-bold">Loại phụ lục <span class="text-danger">*</span></label>
                                <select name="appendixType" class="form-select" required>
                                    <option value="">-- Chọn loại --</option>
                                    <option value="AddEquipment">Thêm thiết bị</option>
                                    <option value="Other">Khác</option>
                                </select>
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold">Tên phụ lục <span class="text-danger">*</span></label>
                                <input type="text" name="appendixName" class="form-control" 
                                       placeholder="VD: Phụ lục 01 - Thêm thiết bị máy in" required>
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold">Mô tả</label>
                                <textarea name="description" class="form-control" rows="3"
                                          placeholder="Mô tả chi tiết về phụ lục..."></textarea>
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold">
                                    Ngày hiệu lực <span class="text-danger">*</span>
                                </label>
                                <input type="date" 
                                       name="effectiveDate" 
                                       class="form-control" 
                                       min="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>"
                                       value="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>"
                                       required>
                                <small class="text-muted">
                                    <i class="fas fa-info-circle"></i> Ngày hiệu lực không được nhỏ hơn ngày hiện tại
                                </small>
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold">Trạng thái</label>
                                <select name="status" class="form-select">
                                    <option value="Draft">Bản nháp</option>
                                    <option value="Approved" selected>Đã duyệt</option>
                                    <option value="Archived">Lưu trữ</option>
                                </select>
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold">
                                    <i class="fas fa-file-upload"></i> File đính kèm 
                                    <span class="text-danger">*</span>
                                    <small class="text-muted">(PDF, Word, Excel - Max 10MB)</small>
                                </label>
                                <input type="file" 
                                       name="fileAttachment" 
                                       id="fileAttachment" 
                                       class="form-control" 
                                       accept=".pdf,.doc,.docx,.xls,.xlsx"
                                       required>
                                <small class="text-muted">
                                    <i class="fas fa-info-circle"></i> Bắt buộc phải chọn file. Định dạng hỗ trợ: PDF, DOC, DOCX, XLS, XLSX
                                </small>
                                <div id="filePreview" class="mt-2"></div>
                            </div>
                        </div>

                        <!-- Chọn thiết bị -->
                        <div class="col-md-6">
                            <h6 class="fw-bold mb-3">
                                <i class="fas fa-tools"></i> Chọn thiết bị thêm vào
                            </h6>

                            <div class="mb-3">
                                <input type="text" id="appendix-equipmentSearch" class="form-control" 
                                       placeholder="🔍 Tìm kiếm thiết bị (Model, Serial Number)...">
                            </div>

                            <div class="equipment-selection" id="appendix-equipmentList">
                                <div class="text-center text-muted py-4">
                                    <i class="fas fa-spinner fa-spin"></i> Đang tải danh sách thiết bị...
                                </div>
                            </div>

                            <div class="mt-3">
                                <h6 class="fw-bold">
                                    Thiết bị đã chọn (<span id="appendix-selectedCount">0</span>)
                                    <span class="text-danger appendix-equipment-required">*</span>
                                </h6>
                                
                                <div id="appendix-selectedEquipmentList" class="border rounded p-2" style="min-height: 100px;">
                                    <p class="text-muted text-center mb-0">Chưa có thiết bị nào được chọn</p>
                                </div>
                            </div>

                            <!-- <div class="mt-3">
                                <label class="form-label fw-bold">
                                    <i class="fas fa-dollar-sign"></i> Tổng giá trị 
                                    <span class="badge bg-success" id="totalAmountDisplay">0 VNĐ</span>
                                </label>
                                <input type="number" name="totalAmount" class="form-control" 
                                       step="0.01" min="0" placeholder="0.00" readonly 
                                       style="background-color: #f8f9fa;">
                                <small class="text-muted">Tự động tính từ thiết bị đã chọn</small>
                            </div> -->
                        </div>
                    </div>
                </div>

                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-dark">
                        <i class="fas fa-save me-1"></i> Lưu phụ lục
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>
                                       
<!-- Modal: Edit Contract Appendix -->
<div class="modal fade" id="editAppendixModal" tabindex="-1">
    <div class="modal-dialog modal-xl">
        <div class="modal-content">
            <div class="modal-header bg-dark text-white">
                <h5 class="modal-title">
                    <i class="fas fa-edit me-2"></i> Chỉnh Sửa Phụ Lục Hợp Đồng
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>

            <form id="editAppendixForm" enctype="multipart/form-data">
                <input type="hidden" id="edit-appendixId" name="appendixId">
                
                <div class="modal-body">
                    <div class="alert alert-warning">
                        <i class="fas fa-exclamation-triangle"></i> 
                        Bạn chỉ có thể chỉnh sửa phụ lục trong vòng 15 ngày kể từ ngày tạo
                    </div>

                    <div class="row">
                        <!-- Thông tin phụ lục -->
                        <div class="col-md-6">
                            <h6 class="fw-bold mb-3">
                                <i class="fas fa-clipboard"></i> Thông tin phụ lục
                            </h6>

                            <div class="mb-3">
                                <label class="form-label fw-bold">
                                    Loại phụ lục <span class="text-danger">*</span>
                                </label>
                                <select name="appendixType" id="edit-appendixType" class="form-select" required>
                                    <option value="">-- Chọn loại --</option>
                                    <option value="AddEquipment">Thêm thiết bị</option>
                                    <option value="Other">Khác</option>
                                </select>
                                <div class="invalid-feedback">Vui lòng chọn loại phụ lục</div>
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold">
                                    Tên phụ lục <span class="text-danger">*</span>
                                </label>
                                <input type="text" 
                                       name="appendixName" 
                                       id="edit-appendixName" 
                                       class="form-control" 
                                       minlength="1"
                                       maxlength="255"
                                       required>
                                <div class="invalid-feedback">Vui lòng nhập tên phụ lục (1-255 ký tự)</div>
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold">
                                    Mô tả <span class="text-danger">*</span>
                                </label>
                                <textarea name="description" 
                                          id="edit-description" 
                                          class="form-control" 
                                          rows="3"
                                          minlength="1"
                                          maxlength="1000"
                                          required></textarea>
                                <small class="text-muted">
                                    <span id="edit-charCount">0</span>/1000 ký tự
                                </small>
                                <div class="invalid-feedback">Vui lòng nhập mô tả (1-1000 ký tự)</div>
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold">
                                    Ngày hiệu lực <span class="text-danger">*</span>
                                </label>
                                <input type="date" 
                                       name="effectiveDate" 
                                       id="edit-effectiveDate" 
                                       class="form-control" 
                                       min="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>"
                                       required>
                                <small class="text-muted">
                                    <i class="fas fa-info-circle"></i> Ngày hiệu lực không được nhỏ hơn ngày hiện tại
                                </small>
                                <div class="invalid-feedback">Ngày hiệu lực không hợp lệ</div>
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold">Trạng thái</label>
                                <select name="status" id="edit-status" class="form-select">
                                    <option value="Draft">Bản nháp</option>
                                    <option value="Approved">Đã duyệt</option>
                                    <option value="Archived">Lưu trữ</option>
                                </select>
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold">
                                    <i class="fas fa-file-upload"></i> File đính kèm <span class="text-danger">*</span>
                                    <small class="text-muted">(PDF, Word, Excel - Max 10MB)</small>
                                </label>
                                <input type="file" 
                                       name="fileAttachment" 
                                       id="edit-fileAttachment" 
                                       class="form-control" 
                                       accept=".pdf,.doc,.docx,.xls,.xlsx">
                                <small class="text-muted">
                                    <i class="fas fa-info-circle"></i> Bắt buộc chọn file mới hoặc giữ file hiện tại
                                </small>
                                <div id="edit-filePreview" class="mt-2"></div>
                                <div id="edit-currentFile" class="mt-2"></div>
                                <div class="invalid-feedback" id="edit-fileError"></div>
                            </div>
                        </div>

                        <!-- Chọn thiết bị -->
                        <div class="col-md-6">
                            <h6 class="fw-bold mb-3">
                                <i class="fas fa-tools"></i> Chọn thiết bị <span class="text-danger">*</span>
                            </h6>

                            <div class="mb-3">
                                <input type="text" id="edit-equipmentSearch" class="form-control" 
                                       placeholder="🔍 Tìm kiếm thiết bị...">
                            </div>

                            <div class="equipment-selection" id="edit-equipmentList">
                                <div class="text-center text-muted py-4">
                                    <i class="fas fa-spinner fa-spin"></i> Đang tải...
                                </div>
                            </div>

                            <div class="mt-3">
                                <h6 class="fw-bold">
                                    Thiết bị đã chọn (<span id="edit-selectedCount">0</span>) 
                                    <span class="text-danger">*</span>
                                </h6>
                                <div id="edit-selectedEquipmentList" 
                                     class="border rounded p-2" 
                                     style="min-height: 100px; max-height: 200px; overflow-y: auto;">
                                    <p class="text-muted text-center mb-0">Chưa có thiết bị nào được chọn</p>
                                </div>
                                <div class="invalid-feedback d-block" id="edit-equipmentError"></div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-dark">
                        <i class="fas fa-save me-1"></i> Cập nhật
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>
                                       
                                       <!-- Modal: View Contract Appendix (Read-only) -->
<div class="modal fade" id="viewAppendixModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header bg-info text-white">
                <h5 class="modal-title">
                    <i class="fas fa-eye me-2"></i> Xem Chi Tiết Phụ Lục
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>

            <div class="modal-body">
                <div class="alert alert-info">
                    <i class="fas fa-info-circle"></i> 
                    <strong>Chế độ chỉ xem:</strong> Phụ lục này có yêu cầu dịch vụ đang xử lý, không thể chỉnh sửa.
                </div>

                <div class="row">
                    <!-- Thông tin phụ lục -->
                    <div class="col-md-6">
                        <h6 class="fw-bold mb-3">
                            <i class="fas fa-clipboard"></i> Thông tin phụ lục
                        </h6>

                        <div class="mb-3">
                            <label class="form-label fw-bold">Loại phụ lục</label>
                            <input type="text" id="view-appendixType" class="form-control" readonly>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-bold">Tên phụ lục</label>
                            <input type="text" id="view-appendixName" class="form-control" readonly>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-bold">Mô tả</label>
                            <textarea id="view-description" class="form-control" rows="3" readonly></textarea>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-bold">Ngày hiệu lực</label>
                            <input type="text" id="view-effectiveDate" class="form-control" readonly>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-bold">Trạng thái</label>
                            <input type="text" id="view-status" class="form-control" readonly>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-bold">
                                <i class="fas fa-file-download"></i> File đính kèm
                            </label>
                            <div id="view-fileDisplay"></div>
                        </div>
                    </div>

                    <!-- Danh sách thiết bị (chỉ hiển thị) -->
                    <div class="col-md-6">
                        <h6 class="fw-bold mb-3">
                            <i class="fas fa-tools"></i> Danh sách thiết bị 
                            (<span id="view-equipmentCount">0</span>)
                        </h6>

                        <div id="view-equipmentList" 
                             class="border rounded p-3" 
                             style="max-height: 400px; overflow-y: auto; background-color: #f8f9fa;">
                            <p class="text-muted text-center mb-0">Chưa có thiết bị nào</p>
                        </div>
                    </div>
                </div>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                    <i class="fas fa-times"></i> Đóng
                </button>
            </div>
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

// Biến global để lưu danh sách thiết bị đã chọn và danh sách đầy đủ
let selectedEquipment = [];
let allEquipment = [];

// Mở modal thêm phụ lục
// Reset form khi mở modal
async function openAddAppendixModal(contractId, customerName) {
    console.log('===== OPEN ADD APPENDIX MODAL =====');
    console.log('Received contractId:', contractId, 'Type:', typeof contractId);
    console.log('Received customerName:', customerName);
    
    if (!contractId || contractId === 'undefined' || contractId === 'null') {
        Swal.fire({
            icon: 'error',
            title: 'Lỗi',
            text: 'Contract ID không hợp lệ. Vui lòng thử lại.',
            confirmButtonColor: '#000'
        });
        console.error('Invalid contractId:', contractId);
        return;
    }
    
    // Reset
    selectedEquipment = [];
    allEquipment = [];
    
    // Reset form
    const form = document.getElementById('addAppendixForm');
    if (form) {
        form.reset();
    }
    
    // Clear file preview
    clearFileInput();
    
    // SET contractId vào hidden input
    const hiddenInput = document.getElementById('appendix-contractId');
    if (hiddenInput) {
        hiddenInput.value = contractId;
        console.log('✓ Set hidden input value:', hiddenInput.value);
    } else {
        console.error('✗ Không tìm thấy hidden input #appendix-contractId');
    }
    
    // Hiển thị thông tin hợp đồng
    const infoSpan = document.getElementById('appendix-contractInfo');
    if (infoSpan) {
        infoSpan.innerText = '#' + contractId + ' - ' + customerName;
        console.log('✓ Set info span:', infoSpan.innerText);
    } else {
        console.error('✗ Không tìm thấy span #appendix-contractInfo');
    }
    
    // ✅ Reset search với ID MỚI
    const searchInput = document.getElementById('appendix-equipmentSearch');
    if (searchInput) {
        searchInput.value = '';
    }
    
    // Set ngày hiệu lực mặc định là hôm nay
    const effectiveDateInput = document.querySelector('#addAppendixModal input[name="effectiveDate"]');
    if (effectiveDateInput) {
        const today = new Date().toISOString().split('T')[0];
        effectiveDateInput.value = today;
    }
    
    // ✅ Reset UI indicators
    const requiredIndicators = document.querySelectorAll('.appendix-equipment-required');
    const optionalIndicators = document.querySelectorAll('.appendix-equipment-optional');
    requiredIndicators.forEach(el => el.style.display = 'none');
    optionalIndicators.forEach(el => el.style.display = 'none');
    
    // Load equipment
    console.log('Loading available equipment...');
    await loadAvailableEquipment();
    
    // Show modal
    const modalElement = document.getElementById('addAppendixModal');
    if (modalElement) {
        const modal = new bootstrap.Modal(modalElement);
        modal.show();
        console.log('✓ Modal shown');
    } else {
        console.error('✗ Không tìm thấy modal #addAppendixModal');
    }
    
    console.log('===== END OPEN MODAL =====');
}

// Load danh sách thiết bị
async function loadAvailableEquipment() {
    const container = document.getElementById('appendix-equipmentList'); 
    try {
        const ctx = window.location.pathname.split("/")[1];
        const response = await fetch("/" + ctx + "/getAvailableEquipment");
        
        if (!response.ok) throw new Error("Không thể tải danh sách thiết bị");
        
        const data = await response.json();
        
        if (data.equipment && data.equipment.length > 0) {
            allEquipment = data.equipment;
            renderEquipmentList(allEquipment);
        } else {
            container.innerHTML = '<p class="text-center text-muted">Không có thiết bị khả dụng</p>';
        }
    } catch (error) {
        console.error("Error:", error);
        container.innerHTML = '<div class="alert alert-danger">Không thể tải danh sách thiết bị</div>';
    }
}

// Render danh sách thiết bị cho APPENDIX
function renderEquipmentList(equipmentList) {
    const container = document.getElementById('appendix-equipmentList');
    
    if (!equipmentList || equipmentList.length === 0) {
        container.innerHTML = '<p class="text-center text-muted">Không tìm thấy thiết bị nào</p>';
        return;
    }
    
    let html = '';
    equipmentList.forEach(function(eq) {
        const categoryBadgeClass = eq.categoryType === 'Equipment' ? 'bg-primary' : 'bg-secondary';
        
        html += '<div class="equipment-item" data-id="' + eq.equipmentId + '" data-category="' + (eq.categoryId || '') + '">' +
            '<div class="form-check">' +
            '<input class="form-check-input appendix-equipment-checkbox" ' + 
            'type="checkbox" ' +
            'value="' + eq.equipmentId + '" ' +
            'data-model="' + (eq.model || '') + '" ' +
            'data-serial="' + (eq.serialNumber || '') + '" ' +
            'onchange="toggleEquipment(this)">' +
            '<label class="form-check-label">' +
            '<strong>' + (eq.model || 'N/A') + '</strong> - <code>' + (eq.serialNumber || 'N/A') + '</code>' +
            (eq.categoryName ? '<span class="badge category-badge ' + categoryBadgeClass + ' ms-2">' + eq.categoryName + '</span>' : '') +
            '<br><small class="text-muted">' + (eq.description || '') + '</small>' +
            '</label>' +
            '</div>' +
            '</div>';
    });
    container.innerHTML = html;
}

// Toggle chọn thiết bị
function toggleEquipment(checkbox) {
    const equipmentId = checkbox.value;
    const model = checkbox.dataset.model;
    const serial = checkbox.dataset.serial;
    
    if (checkbox.checked) {
        selectedEquipment.push({
            equipmentId: equipmentId,
            model: model,
            serialNumber: serial
        });
    } else {
        selectedEquipment = selectedEquipment.filter(function(e) {
            return e.equipmentId !== equipmentId;
        });
    }
    
    updateSelectedEquipmentDisplay();
    // Xóa dòng: updateTotalAmount();
}

// Cập nhật hiển thị thiết bị đã chọn
function updateSelectedEquipmentDisplay() {
    const container = document.getElementById('appendix-selectedEquipmentList'); // ✅ ĐỔI ID
    const countSpan = document.getElementById('appendix-selectedCount'); // ✅ ĐỔI ID
    
    countSpan.innerText = selectedEquipment.length;
    
    if (selectedEquipment.length === 0) {
        container.innerHTML = '<p class="text-muted text-center mb-0">Chưa có thiết bị nào được chọn</p>';
        return;
    }
    
    let html = '<div class="list-group list-group-flush">';
    selectedEquipment.forEach(function(eq, index) {
        html += '<div class="list-group-item d-flex justify-content-between align-items-center py-2">' +
            '<div class="flex-grow-1">' +
            '<strong>' + (index + 1) + '. ' + eq.model + '</strong>' +
            '<br><small class="text-muted">' + eq.serialNumber + '</small>' +
            '</div>' +
            '<button type="button" class="btn btn-sm btn-danger" ' +
            'onclick="removeEquipment(\'' + eq.equipmentId + '\')">' +
            '<i class="fas fa-times"></i>' +
            '</button>' +
            '</div>';
    });
    html += '</div>';
    
    container.innerHTML = html;
}

// Cập nhật tổng giá trị
//function updateTotalAmount() {
//    let total = 0;
//    selectedEquipment.forEach(function(eq) {
//        total += eq.price || 0;
//    });
//    
//    const totalInput = document.querySelector('input[name="totalAmount"]');
//    if (totalInput) {
//        totalInput.value = total.toFixed(2);
//        
//        // Hiển thị tổng tiền bằng VNĐ format
//        const totalDisplay = document.getElementById('totalAmountDisplay');
//        if (totalDisplay) {
//            totalDisplay.innerText = total.toLocaleString('vi-VN') + ' VNĐ';
//        }
//    }
//}

// Xóa thiết bị khỏi danh sách đã chọn
function removeEquipment(equipmentId) {
    selectedEquipment = selectedEquipment.filter(function(e) {
        return e.equipmentId !== equipmentId;
    });
    
    const checkbox = document.querySelector('.appendix-equipment-checkbox[value="' + equipmentId + '"]');
    if (checkbox) checkbox.checked = false;
    
    updateSelectedEquipmentDisplay();
}

// Tìm kiếm thiết bị
document.addEventListener('DOMContentLoaded', function() {
    const searchInput = document.getElementById('appendix-equipmentSearch'); 
    if (searchInput) {
        searchInput.addEventListener('input', function(e) {
            filterEquipment();
        });
    }
});

function filterEquipment() {
    const keyword = document.getElementById('appendix-equipmentSearch').value.toLowerCase(); 
    
    let filtered = allEquipment;
    
    if (keyword) {
        filtered = filtered.filter(function(eq) {
            const model = (eq.model || '').toLowerCase();
            const serial = (eq.serialNumber || '').toLowerCase();
            const desc = (eq.description || '').toLowerCase();
            return model.includes(keyword) || serial.includes(keyword) || desc.includes(keyword);
        });
    }
    
    renderEquipmentList(filtered);
    
    // Restore checked state
    selectedEquipment.forEach(function(selected) {
        const checkbox = document.querySelector('.appendix-equipment-checkbox[value="' + selected.equipmentId + '"]'); // ✅ ĐỔI CLASS
        if (checkbox) checkbox.checked = true;
    });
}

// Submit form thêm phụ lục
//document.getElementById('addAppendixForm').addEventListener('submit', async function(e) {
//    e.preventDefault();
//    
//    console.log('===== SUBMIT ADD APPENDIX FORM =====');
//    
//    // Lấy contractId từ hidden input
//    const contractIdInput = document.getElementById('appendix-contractId');
//    const contractId = contractIdInput ? contractIdInput.value : null;
//    
//    console.log('Contract ID from hidden input:', contractId);
//    console.log('Type:', typeof contractId);
//    console.log('Is empty?', !contractId || contractId.trim() === '');
//    
//    // Validate contractId
//    if (!contractId || contractId.trim() === '') {
//        Swal.fire({
//            icon: 'error',
//            title: 'Lỗi',
//            text: 'Contract ID không được để trống. Vui lòng đóng modal và thử lại.',
//            confirmButtonColor: '#000'
//        });
//        console.error('✗ Contract ID is empty!');
//        return;
//    }
//    
//    // Validate equipment selection
//    if (selectedEquipment.length === 0) {
//        Swal.fire({
//            icon: 'warning',
//            title: 'Chưa chọn thiết bị',
//            text: 'Vui lòng chọn ít nhất một thiết bị để thêm vào phụ lục',
//            confirmButtonColor: '#000'
//        });
//        console.warn('✗ No equipment selected');
//        return;
//    }
//    
//    console.log('Selected equipment count:', selectedEquipment.length);
//    console.log('Selected equipment:', selectedEquipment);
//    
//    // Tạo FormData
//    const formData = new FormData(this);
//    
//    // ĐẢM BẢO contractId được thêm vào
//    formData.set('contractId', contractId.trim());
//    
//    // Thêm equipment IDs
//    const equipmentIds = selectedEquipment.map(e => parseInt(e.equipmentId));
//    formData.append('equipmentIds', JSON.stringify(equipmentIds));
//    
//    // Debug: Log tất cả form data
//    console.log('===== FORM DATA =====');
//    for (let pair of formData.entries()) {
//        console.log(pair[0] + ':', pair[1]);
//    }
//    console.log('=====================');
//    
//    try {
//        const ctx = window.location.pathname.split("/")[1];
//        const url = "/" + ctx + "/addContractAppendix";
//        
//        console.log('Sending POST to:', url);
//        
//        const response = await fetch(url, {
//            method: 'POST',
//            body: formData
//        });
//        
//        console.log('Response status:', response.status);
//        
//        const result = await response.json();
//        console.log('Response result:', result);
//        
//        if (result.success) {
//            Swal.fire({
//                icon: 'success',
//                title: 'Thành công!',
//                text: result.message || 'Đã thêm phụ lục hợp đồng thành công',
//                confirmButtonColor: '#000'
//            }).then(function() {
//                const modalElement = document.getElementById('addAppendixModal');
//                const modalInstance = bootstrap.Modal.getInstance(modalElement);
//                if (modalInstance) {
//                    modalInstance.hide();
//                }
//                window.location.reload();
//            });
//        } else {
//            Swal.fire({
//                icon: 'error',
//                title: 'Thất bại!',
//                text: result.message || 'Không thể thêm phụ lục',
//                confirmButtonColor: '#000'
//            });
//        }
//    } catch (error) {
//        console.error('✗ Error:', error);
//        Swal.fire({
//            icon: 'error',
//            title: 'Lỗi hệ thống',
//            text: 'Không thể kết nối đến server: ' + error.message,
//            confirmButtonColor: '#000'
//        });
//    }
//    
//    console.log('===== END SUBMIT =====');
//});

// Các function khác giữ nguyên
// ✅ CẬP NHẬT FUNCTION viewContractDetailsWithAppendix
async function viewContractDetailsWithAppendix(contractId) {
    viewContractDetails(contractId);
    
    try {
        const ctx = window.location.pathname.split("/")[1];
        const response = await fetch("/" + ctx + "/getContractAppendix?contractId=" + contractId);
        
        if (!response.ok) throw new Error("Không thể tải phụ lục");
        
        const data = await response.json();
        const container = document.getElementById('appendixListContainer');
        const countSpan = document.getElementById('appendixCount');
        
        if (data.appendixes && data.appendixes.length > 0) {
            countSpan.innerText = data.appendixes.length;
            
            let html = '';
            data.appendixes.forEach(function(app) {
                const statusBadge = app.status === 'Approved' ? 'bg-success' :
                                  app.status === 'Draft' ? 'bg-warning' : 'bg-secondary';
                const typeLabel = app.appendixType === 'AddEquipment' ? 'Thêm thiết bị' : 'Khác';
                
                console.log('Appendix #' + app.appendixId + ':', {
                    type: app.appendixType,
                    canEdit: app.canEdit,
                    canDelete: app.canDelete,
                    equipmentCount: app.equipmentCount
                });
                
                html += '<div class="appendix-item">' +
                    '<div class="d-flex justify-content-between align-items-start">' +
                    '<div class="flex-grow-1">' +
                    '<h6 class="mb-1">' +
                    '<i class="fas fa-file-alt"></i> ' + app.appendixName +
                    '<span class="badge ' + statusBadge + ' ms-2">' + app.status + '</span>' +
                    '<span class="badge bg-info ms-1">' + typeLabel + '</span>' +
                    '</h6>' +
                    '<p class="mb-1 text-muted small">' + (app.description || 'Không có mô tả') + '</p>' +
                    '<p class="mb-1">' +
                    '<i class="fas fa-calendar"></i> Hiệu lực: <strong>' + app.effectiveDate + '</strong> | ' +
                    '<i class="fas fa-tools"></i> Số thiết bị: <strong>' + (app.equipmentCount || 0) + '</strong>' +
                    '</p>' +
                    '</div>' +
                    '<div class="btn-group">';
                
                // NÚT XEM FILE
                if (app.fileAttachment) {
                    html += '<a href="' + app.fileAttachment + '" target="_blank" ' +
                           'class="btn btn-sm btn-outline-success" title="Xem file đính kèm">' +
                           '<i class="fas fa-file-download"></i>' +
                           '</a>';
                }
                
                // NÚT XEM THIẾT BỊ (chỉ hiện nếu có thiết bị)
                if (app.equipmentCount > 0) {
                    html += '<button type="button" class="btn btn-sm btn-outline-info" ' +
                           'onclick="viewAppendixEquipment(' + app.appendixId + ')" ' +
                           'title="Xem thiết bị">' +
                           '<i class="fas fa-list"></i>' +
                           '</button>';
                }
                
                // Trong hàm viewContractDetailsWithAppendix(), phần render appendix list
                if (app.canEdit) {
                    // Có thể sửa → Hiển thị nút EDIT
                    html += '<button type="button" class="btn btn-sm btn-outline-warning" ' +
                           'onclick="openEditAppendixModal(' + app.appendixId + ')" ' +
                           'title="Chỉnh sửa">' +
                           '<i class="fas fa-edit"></i>' +
                           '</button>';
                } else {
                    // Không thể sửa → Hiển thị nút VIEW (Read-only)
                    html += '<button type="button" class="btn btn-sm btn-outline-info" ' +
                           'onclick="openViewAppendixModal(' + app.appendixId + ')" ' +
                           'title="Xem chi tiết (chỉ đọc)">' +
                           '<i class="fas fa-eye"></i>' +
                           '</button>';
                }
                
                // NÚT XÓA
                if (app.canDelete) {
                    html += '<button type="button" class="btn btn-sm btn-outline-danger" ' +
                           'onclick="deleteAppendix(' + app.appendixId + ', \'' + app.appendixType + '\')" ' +
                           'title="Xóa">' +
                           '<i class="fas fa-trash"></i>' +
                           '</button>';
                } else {
                    html += '<button type="button" class="btn btn-sm btn-outline-secondary" disabled ' +
                           'title="Không thể xóa (đã quá 15 ngày hoặc có yêu cầu đang xử lý)">' +
                           '<i class="fas fa-lock"></i>' +
                           '</button>';
                }
                
                html += '</div>' +
                    '</div>' +
                    '</div>';
            });
            
            container.innerHTML = html;
        } else {
            countSpan.innerText = '0';
            container.innerHTML = '<p class="text-muted">Chưa có phụ lục nào</p>';
        }
    } catch (error) {
        console.error("Error:", error);
        document.getElementById('appendixListContainer').innerHTML = 
            '<div class="alert alert-warning">Không thể tải danh sách phụ lục</div>';
    }
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
                      '<th>Nguồn</th>' +
                      '</tr>' +
                      '</thead><tbody>';
            
            data.equipment.forEach((eq, index) => {
                // Xác định nguồn: nếu có startDate thì là Contract, không thì là Appendix
                const source = eq.startDate ? 'Hợp đồng' : 'Phụ lục';
                const sourceBadge = eq.startDate ? 'bg-primary' : 'bg-warning';
                
                html += '<tr>' +
                       '<td>' + (index + 1) + '</td>' +
                       '<td><strong>' + eq.model + '</strong></td>' +
                       '<td><code>' + eq.serialNumber + '</code></td>' +
                       '<td>' + (eq.description || '-') + '</td>' +
                       '<td><span class="badge ' + sourceBadge + '">' + source + '</span></td>' +
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

async function viewAppendixEquipment(appendixId) {
    try {
        const ctx = window.location.pathname.split("/")[1];
        const response = await fetch("/" + ctx + "/getAppendixEquipment?appendixId=" + appendixId);
        
        if (!response.ok) throw new Error("Không thể tải thiết bị");
        
        const data = await response.json();
        
        let html = '<div class="mt-2"><h6>Danh sách thiết bị:</h6><ul class="list-group">';
        
        if (data.equipment && data.equipment.length > 0) {
            data.equipment.forEach(function(eq, index) {
                html += '<li class="list-group-item">' +
                    '<strong>' + (index + 1) + '. ' + (eq.model || 'N/A') + '</strong> - ' + (eq.serialNumber || 'N/A') +
                    (eq.description ? '<br><small class="text-muted">' + eq.description + '</small>' : '') +
                    (eq.note ? '<br><small class="text-success">Ghi chú: ' + eq.note + '</small>' : '') +
                    '</li>';
            });
        } else {
            html += '<li class="list-group-item text-muted">Không có thiết bị nào</li>';
        }
        
        html += '</ul></div>';
        
        Swal.fire({
            title: 'Thiết bị trong phụ lục',
            html: html,
            width: 600,
            confirmButtonColor: '#000'
        });
    } catch (error) {
        console.error("Error:", error);
        Swal.fire({
            icon: 'error',
            title: 'Lỗi',
            text: 'Không thể tải danh sách thiết bị',
            confirmButtonColor: '#000'
        });
    }
}

// ===== SINGLE FORM SUBMIT HANDLER =====
document.addEventListener('DOMContentLoaded', function() {
    const form = document.getElementById('addAppendixForm');
    
    if (!form) {
        console.error('Form #addAppendixForm not found!');
        return;
    }
    
    console.log('Registering submit handler for addAppendixForm');
    
    form.addEventListener('submit', async function(e) {
        e.preventDefault();
        e.stopPropagation();
        
        console.log('===== FORM SUBMIT EVENT =====');
        
        // 1. Kiểm tra hidden input
        const hiddenInput = document.getElementById('appendix-contractId');
        console.log('Hidden input element:', hiddenInput);
        console.log('Hidden input value:', hiddenInput ? hiddenInput.value : 'NOT FOUND');
        
        const contractId = hiddenInput ? hiddenInput.value : null;
        
        // 2. Validate contractId
        if (!contractId || contractId.trim() === '') {
            console.error('ERROR: contractId is empty!');
            Swal.fire({
                icon: 'error',
                title: 'Lỗi',
                text: 'Contract ID không được để trống',
                confirmButtonColor: '#000'
            });
            return;
        }
        
        console.log('✓ contractId validated:', contractId);
        
        // 3. Validate loại phụ lục
        const appendixTypeSelect = document.querySelector('select[name="appendixType"]');
        const appendixType = appendixTypeSelect ? appendixTypeSelect.value : '';
        
        if (!appendixType) {
            console.error('ERROR: Appendix type not selected!');
            Swal.fire({
                icon: 'error',
                title: 'Thiếu thông tin',
                text: 'Vui lòng chọn loại phụ lục',
                confirmButtonColor: '#000'
            });
            appendixTypeSelect.focus();
            return;
        }
        
        console.log('✓ appendixType:', appendixType);
        
        // 4. Validate equipment selection - CHỈ BẮT BUỘC với AddEquipment
        if (appendixType === 'AddEquipment') {
            if (!selectedEquipment || selectedEquipment.length === 0) {
                console.warn('ERROR: No equipment selected for AddEquipment type');
                Swal.fire({
                    icon: 'warning',
                    title: 'Chưa chọn thiết bị',
                    text: 'Loại phụ lục "Thêm thiết bị" yêu cầu chọn ít nhất một thiết bị',
                    confirmButtonColor: '#000'
                });
                return;
            }
            console.log('✓ Equipment count:', selectedEquipment.length);
        } else {
            console.log('ℹ Appendix type is "Other", equipment not required');
            console.log('Selected equipment count:', selectedEquipment.length);
        }
        
        // 5. Validate ngày hiệu lực
        const effectiveDateInput = document.querySelector('input[name="effectiveDate"]');
        if (effectiveDateInput && effectiveDateInput.value) {
            const effectiveDate = new Date(effectiveDateInput.value);
            const today = new Date();
            today.setHours(0, 0, 0, 0);
            
            if (effectiveDate < today) {
                console.error('ERROR: Effective date is in the past!');
                Swal.fire({
                    icon: 'error',
                    title: 'Ngày không hợp lệ',
                    text: 'Ngày hiệu lực không được nhỏ hơn ngày hiện tại',
                    confirmButtonColor: '#000'
                });
                effectiveDateInput.focus();
                return;
            }
        }
        
        console.log('✓ effectiveDate validated');
        
        // 6. Validate file đính kèm - BẮT BUỘC
        const fileInput = document.getElementById('fileAttachment');
        if (!fileInput || !fileInput.files || fileInput.files.length === 0) {
            console.error('ERROR: No file selected!');
            Swal.fire({
                icon: 'error',
                title: 'Thiếu file đính kèm',
                text: 'Vui lòng chọn file đính kèm (PDF, Word hoặc Excel)',
                confirmButtonColor: '#000'
            });
            if (fileInput) fileInput.focus();
            return;
        }
        
        const file = fileInput.files[0];
        console.log('✓ File selected:', file.name, file.size, 'bytes');
        
        // Validate file type
        const allowedExtensions = ['.pdf', '.doc', '.docx', '.xls', '.xlsx'];
        const fileName = file.name.toLowerCase();
        const isValidType = allowedExtensions.some(ext => fileName.endsWith(ext));
        
        if (!isValidType) {
            console.error('ERROR: Invalid file type!');
            Swal.fire({
                icon: 'error',
                title: 'Loại file không hợp lệ',
                text: 'Chỉ chấp nhận file PDF, Word (DOC/DOCX) hoặc Excel (XLS/XLSX)',
                confirmButtonColor: '#000'
            });
            fileInput.focus();
            return;
        }
        
        console.log('✓ File type validated');
        
        // Validate file size (max 10MB)
        const maxSize = 10 * 1024 * 1024;
        if (file.size > maxSize) {
            console.error('ERROR: File too large!');
            Swal.fire({
                icon: 'error',
                title: 'File quá lớn',
                text: 'Kích thước file không được vượt quá 10MB',
                confirmButtonColor: '#000'
            });
            fileInput.focus();
            return;
        }
        
        console.log('✓ File size validated');
        
        // 7. Tạo FormData
        const formData = new FormData(form);
        
        // 8. ĐẢM BẢO contractId được set
        formData.set('contractId', contractId.trim());
        
        // 9. Thêm equipment IDs (có thể là mảng rỗng nếu type = Other)
        const equipmentIds = selectedEquipment.map(e => parseInt(e.equipmentId));
        formData.append('equipmentIds', JSON.stringify(equipmentIds));
        
        // 10. Log FormData
        console.log('===== FormData entries =====');
        for (let [key, value] of formData.entries()) {
            if (value instanceof File) {
                console.log(key + ': [File]', value.name, value.size, 'bytes');
            } else {
                console.log(key + ':', value);
            }
        }
        console.log('================================');
        
        // 11. Gửi request
        try {
            const ctx = window.location.pathname.split("/")[1];
            const url = "/" + ctx + "/addContractAppendix";
            
            console.log('Sending POST to:', url);
            
            const response = await fetch(url, {
                method: 'POST',
                body: formData
            });
            
            console.log('Response status:', response.status);
            console.log('Response ok:', response.ok);
            
            const result = await response.json();
            console.log('Response data:', result);
            
            if (result.success) {
                await Swal.fire({
                    icon: 'success',
                    title: 'Thành công!',
                    text: result.message || 'Đã thêm phụ lục thành công',
                    confirmButtonColor: '#000'
                });
                
                // Close modal
                const modalElement = document.getElementById('addAppendixModal');
                const modalInstance = bootstrap.Modal.getInstance(modalElement);
                if (modalInstance) {
                    modalInstance.hide();
                }
                
                // Reload page
                window.location.reload();
            } else {
                Swal.fire({
                    icon: 'error',
                    title: 'Thất bại!',
                    text: result.message || 'Không thể thêm phụ lục',
                    confirmButtonColor: '#000'
                });
            }
        } catch (error) {
            console.error('ERROR:', error);
            Swal.fire({
                icon: 'error',
                title: 'Lỗi hệ thống',
                text: error.message,
                confirmButtonColor: '#000'
            });
        }
        
        console.log('===== END FORM SUBMIT =====');
    });
    
    console.log('✓ Submit handler registered successfully');
});

// Thêm event listener cho appendixType select
document.addEventListener('DOMContentLoaded', function() {
    const appendixTypeSelect = document.querySelector('#addAppendixModal select[name="appendixType"]');
    
    if (appendixTypeSelect) {
        appendixTypeSelect.addEventListener('change', function(e) {
            const selectedType = e.target.value;
            const equipmentHeader = document.getElementById('appendix-equipment-header'); // ✅ ĐỔI ID
            
            // Update UI indicators
            const requiredIndicators = document.querySelectorAll('.appendix-equipment-required'); // ✅ ĐỔI CLASS
            const optionalIndicators = document.querySelectorAll('.appendix-equipment-optional'); // ✅ ĐỔI CLASS
            
            if (selectedType === 'AddEquipment') {
                requiredIndicators.forEach(el => el.style.display = 'inline');
                optionalIndicators.forEach(el => el.style.display = 'none');
                
                Swal.fire({
                    icon: 'info',
                    title: 'Phụ lục thêm thiết bị',
                    text: 'Bạn phải chọn ít nhất một thiết bị cho loại phụ lục này',
                    timer: 2000,
                    showConfirmButton: false
                });
            } else if (selectedType === 'Other') {
                requiredIndicators.forEach(el => el.style.display = 'none');
                optionalIndicators.forEach(el => el.style.display = 'inline');
                
                Swal.fire({
                    icon: 'info',
                    title: 'Phụ lục thông tin',
                    text: 'Không cần chọn thiết bị cho loại phụ lục này',
                    timer: 2000,
                    showConfirmButton: false
                });
            }
        });
    }
});

// Thêm vào DOMContentLoaded
document.addEventListener('DOMContentLoaded', function() {
    const appendixTypeSelect = document.querySelector('#addAppendixModal select[name="appendixType"]');
    
    if (appendixTypeSelect) {
        appendixTypeSelect.addEventListener('change', function(e) {
            const selectedType = e.target.value;
            
            // Update UI indicators
            const requiredIndicators = document.querySelectorAll('#equipment-required-indicator, #selected-required-indicator');
            const optionalIndicator = document.getElementById('equipment-optional-indicator');
            
            if (selectedType === 'AddEquipment') {
                requiredIndicators.forEach(el => el.style.display = 'inline');
                if (optionalIndicator) optionalIndicator.style.display = 'none';
            } else if (selectedType === 'Other') {
                requiredIndicators.forEach(el => el.style.display = 'none');
                if (optionalIndicator) optionalIndicator.style.display = 'inline';
            }
        });
    }
});

// ===== REAL-TIME DATE VALIDATION =====
document.addEventListener('DOMContentLoaded', function() {
    const effectiveDateInput = document.querySelector('#addAppendixModal input[name="effectiveDate"]');
    
    if (effectiveDateInput) {
        // Set min date to today
        const today = new Date().toISOString().split('T')[0];
        effectiveDateInput.setAttribute('min', today);
        
        // Validate on change
        effectiveDateInput.addEventListener('change', function(e) {
            const selectedDate = new Date(e.target.value);
            const todayDate = new Date();
            todayDate.setHours(0, 0, 0, 0);
            
            if (selectedDate < todayDate) {
                Swal.fire({
                    icon: 'warning',
                    title: 'Cảnh báo',
                    text: 'Ngày hiệu lực không được nhỏ hơn ngày hiện tại',
                    confirmButtonColor: '#000'
                });
                // Reset về ngày hôm nay
                e.target.value = today;
            }
        });
        
        console.log('✓ Date validation registered');
    }
});

// ===== FILE PREVIEW =====
// ===== FILE PREVIEW WITH VALIDATION =====
document.addEventListener('DOMContentLoaded', function() {
    const fileInput = document.getElementById('fileAttachment');
    if (fileInput) {
        fileInput.addEventListener('change', function(e) {
            const file = e.target.files[0];
            const preview = document.getElementById('filePreview');
            
            if (file) {
                // Kiểm tra file type
                const allowedExtensions = ['.pdf', '.doc', '.docx', '.xls', '.xlsx'];
                const fileName = file.name.toLowerCase();
                const isValidType = allowedExtensions.some(ext => fileName.endsWith(ext));
                
                if (!isValidType) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Loại file không hợp lệ',
                        text: 'Chỉ chấp nhận file PDF, Word (DOC/DOCX) hoặc Excel (XLS/XLSX)',
                        confirmButtonColor: '#000'
                    });
                    fileInput.value = '';
                    preview.innerHTML = '';
                    return;
                }
                
                // Kiểm tra kích thước (max 10MB)
                if (file.size > 10 * 1024 * 1024) {
                    Swal.fire({
                        icon: 'error',
                        title: 'File quá lớn',
                        text: 'Vui lòng chọn file nhỏ hơn 10MB',
                        confirmButtonColor: '#000'
                    });
                    fileInput.value = '';
                    preview.innerHTML = '';
                    return;
                }
                
                // Hiển thị thông tin file
                const fileIcon = getFileIcon(file.name);
                preview.innerHTML = '<div class="alert alert-success">' +
                    '<i class="' + fileIcon + ' me-2"></i>' +
                    '<strong>' + file.name + '</strong> ' +
                    '<small>(' + formatFileSize(file.size) + ')</small>' +
                    '<button type="button" class="btn btn-sm btn-link text-danger float-end" onclick="clearFileInput()">' +
                    '<i class="fas fa-times"></i> Xóa' +
                    '</button>' +
                    '</div>';
            } else {
                preview.innerHTML = '';
            }
        });
    }
});

function clearFileInput() {
    // Clear cho modal Add Appendix
    const fileInput = document.getElementById('fileAttachment');
    const preview = document.getElementById('filePreview');
    if (fileInput) fileInput.value = '';
    if (preview) preview.innerHTML = '';
}

function getFileIcon(filename) {
    const ext = filename.split('.').pop().toLowerCase();
    switch(ext) {
        case 'pdf': return 'fas fa-file-pdf text-danger';
        case 'doc':
        case 'docx': return 'fas fa-file-word text-primary';
        case 'xls':
        case 'xlsx': return 'fas fa-file-excel text-success';
        default: return 'fas fa-file';
    }
}

function formatFileSize(bytes) {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i];
}

// ===== EDIT APPENDIX =====
let editSelectedEquipment = [];
let editAllEquipment = [];
let editHasCurrentFile = false; // Biến để track xem có file hiện tại không

async function openEditAppendixModal(appendixId) {
    console.log('===== OPEN EDIT APPENDIX MODAL =====');
    console.log('Appendix ID:', appendixId);
    
    editSelectedEquipment = [];
    editAllEquipment = [];
    editHasCurrentFile = false;
    
    // Reset validation
    const form = document.getElementById('editAppendixForm');
    if (form) {
        form.classList.remove('was-validated');
        // Clear all error messages
        document.querySelectorAll('.invalid-feedback').forEach(el => el.style.display = 'none');
    }
    
    try {
        const ctx = window.location.pathname.split("/")[1];
        const response = await fetch("/" + ctx + "/getAppendixDetails?appendixId=" + appendixId);
        
        if (!response.ok) throw new Error("Không thể tải thông tin phụ lục");
        
        const data = await response.json();
        
        if (!data.success) {
            Swal.fire({
                icon: 'error',
                title: 'Lỗi',
                text: data.message,
                confirmButtonColor: '#000'
            });
            return;
        }
        
        const appendix = data.appendix;
        const equipment = data.equipment || [];
        
        // Fill form
        document.getElementById('edit-appendixId').value = appendix.appendixId;
        document.getElementById('edit-appendixType').value = appendix.appendixType;
        document.getElementById('edit-appendixName').value = appendix.appendixName;
        
        const descriptionTextarea = document.getElementById('edit-description');
        descriptionTextarea.value = appendix.description || '';
        updateEditCharCount(); // Cập nhật số ký tự
        
        document.getElementById('edit-effectiveDate').value = appendix.effectiveDate;
        document.getElementById('edit-status').value = appendix.status;
        
        // Hiển thị file hiện tại
        const currentFileDiv = document.getElementById('edit-currentFile');
        if (appendix.fileAttachment) {
            editHasCurrentFile = true;
            const fileIcon = getFileIcon(appendix.fileAttachment);
            const fileName = appendix.fileAttachment.split('/').pop();
            currentFileDiv.innerHTML = '<div class="alert alert-success">' +
                '<i class="' + fileIcon + ' me-2"></i>' +
                '<strong>File hiện tại:</strong> ' + fileName +
                '<br><small class="text-muted">Để trống nếu không muốn thay đổi file</small>' +
                '</div>';
        } else {
            editHasCurrentFile = false;
            currentFileDiv.innerHTML = '<div class="alert alert-warning">' +
                '<i class="fas fa-exclamation-triangle me-2"></i>' +
                '<strong>Chưa có file đính kèm</strong> - Vui lòng chọn file mới' +
                '</div>';
        }
        
        // Load available equipment
        await loadEditAvailableEquipment();
        
        // Pre-select equipment
        editSelectedEquipment = equipment.map(eq => ({
            equipmentId: eq.equipmentId.toString(),
            model: eq.model,
            serialNumber: eq.serialNumber
        }));
        
        updateEditSelectedEquipmentDisplay();
        
        // Check checkboxes
        editSelectedEquipment.forEach(selected => {
            const checkbox = document.querySelector('#edit-equipmentList .equipment-checkbox[value="' + selected.equipmentId + '"]');
            if (checkbox) checkbox.checked = true;
        });
        
        // Show modal
        new bootstrap.Modal(document.getElementById('editAppendixModal')).show();
        
    } catch (error) {
        console.error("Error:", error);
        Swal.fire({
            icon: 'error',
            title: 'Lỗi',
            text: 'Không thể tải thông tin phụ lục',
            confirmButtonColor: '#000'
        });
    }
}

async function loadEditAvailableEquipment() {
    const container = document.getElementById('edit-equipmentList');
    try {
        const ctx = window.location.pathname.split("/")[1];
        const response = await fetch("/" + ctx + "/getAvailableEquipment");
        
        if (!response.ok) throw new Error("Không thể tải danh sách thiết bị");
        
        const data = await response.json();
        
        if (data.equipment && data.equipment.length > 0) {
            editAllEquipment = data.equipment;
            renderEditEquipmentList(editAllEquipment);
        } else {
            container.innerHTML = '<p class="text-center text-muted">Không có thiết bị khả dụng</p>';
        }
    } catch (error) {
        console.error("Error:", error);
        container.innerHTML = '<div class="alert alert-danger">Không thể tải danh sách thiết bị</div>';
    }
}

function renderEditEquipmentList(equipmentList) {
    const container = document.getElementById('edit-equipmentList');
    
    if (!equipmentList || equipmentList.length === 0) {
        container.innerHTML = '<p class="text-center text-muted">Không tìm thấy thiết bị nào</p>';
        return;
    }
    
    let html = '';
    equipmentList.forEach(function(eq) {
        const categoryBadgeClass = eq.categoryType === 'Equipment' ? 'bg-primary' : 'bg-secondary';
        
        html += '<div class="equipment-item" data-id="' + eq.equipmentId + '">' +
            '<div class="form-check">' +
            '<input class="form-check-input equipment-checkbox" ' +
            'type="checkbox" ' +
            'value="' + eq.equipmentId + '" ' +
            'data-model="' + (eq.model || '') + '" ' +
            'data-serial="' + (eq.serialNumber || '') + '" ' +
            'onchange="toggleEditEquipment(this)">' +
            '<label class="form-check-label">' +
            '<strong>' + (eq.model || 'N/A') + '</strong> - <code>' + (eq.serialNumber || 'N/A') + '</code>' +
            (eq.categoryName ? '<span class="badge category-badge ' + categoryBadgeClass + ' ms-2">' + eq.categoryName + '</span>' : '') +
            '<br><small class="text-muted">' + (eq.description || '') + '</small>' +
            '</label>' +
            '</div>' +
            '</div>';
    });
    container.innerHTML = html;
}

function toggleEditEquipment(checkbox) {
    const equipmentId = checkbox.value;
    const model = checkbox.dataset.model;
    const serial = checkbox.dataset.serial;
    
    if (checkbox.checked) {
        editSelectedEquipment.push({
            equipmentId: equipmentId,
            model: model,
            serialNumber: serial
        });
    } else {
        editSelectedEquipment = editSelectedEquipment.filter(function(e) {
            return e.equipmentId !== equipmentId;
        });
    }
    
    updateEditSelectedEquipmentDisplay();
    
    // Clear error message khi có thiết bị được chọn
    if (editSelectedEquipment.length > 0) {
        document.getElementById('edit-equipmentError').style.display = 'none';
    }
}

function updateEditSelectedEquipmentDisplay() {
    const container = document.getElementById('edit-selectedEquipmentList');
    const countSpan = document.getElementById('edit-selectedCount');
    
    countSpan.innerText = editSelectedEquipment.length;
    
    if (editSelectedEquipment.length === 0) {
        container.innerHTML = '<p class="text-muted text-center mb-0">Chưa có thiết bị nào được chọn</p>';
        return;
    }
    
    let html = '<div class="list-group list-group-flush">';
    editSelectedEquipment.forEach(function(eq, index) {
        html += '<div class="list-group-item d-flex justify-content-between align-items-center py-2">' +
            '<div class="flex-grow-1">' +
            '<strong>' + (index + 1) + '. ' + eq.model + '</strong>' +
            '<br><small class="text-muted">' + eq.serialNumber + '</small>' +
            '</div>' +
            '<button type="button" class="btn btn-sm btn-danger" ' +
            'onclick="removeEditEquipment(\'' + eq.equipmentId + '\')">' +
            '<i class="fas fa-times"></i>' +
            '</button>' +
            '</div>';
    });
    html += '</div>';
    
    container.innerHTML = html;
}

function removeEditEquipment(equipmentId) {
    editSelectedEquipment = editSelectedEquipment.filter(function(e) {
        return e.equipmentId !== equipmentId;
    });
    
    const checkbox = document.querySelector('#edit-equipmentList .equipment-checkbox[value="' + equipmentId + '"]');
    if (checkbox) checkbox.checked = false;
    
    updateEditSelectedEquipmentDisplay();
}

// ===== CHARACTER COUNT FOR DESCRIPTION =====
function updateEditCharCount() {
    const textarea = document.getElementById('edit-description');
    const countSpan = document.getElementById('edit-charCount');
    if (textarea && countSpan) {
        countSpan.innerText = textarea.value.length;
        
        // Đổi màu khi gần đến giới hạn
        if (textarea.value.length > 900) {
            countSpan.classList.add('text-danger');
        } else if (textarea.value.length > 700) {
            countSpan.classList.add('text-warning');
            countSpan.classList.remove('text-danger');
        } else {
            countSpan.classList.remove('text-danger', 'text-warning');
        }
    }
}

// ===== FILE PREVIEW FOR EDIT =====
document.addEventListener('DOMContentLoaded', function() {
    const editFileInput = document.getElementById('edit-fileAttachment');
    if (editFileInput) {
        editFileInput.addEventListener('change', function(e) {
            const file = e.target.files[0];
            const preview = document.getElementById('edit-filePreview');
            const errorDiv = document.getElementById('edit-fileError');
            
            if (file) {
                // Validate file type
                const allowedExtensions = ['.pdf', '.doc', '.docx', '.xls', '.xlsx'];
                const fileName = file.name.toLowerCase();
                const isValidType = allowedExtensions.some(ext => fileName.endsWith(ext));
                
                if (!isValidType) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Loại file không hợp lệ',
                        text: 'Chỉ chấp nhận file PDF, Word (DOC/DOCX) hoặc Excel (XLS/XLSX)',
                        confirmButtonColor: '#000'
                    });
                    editFileInput.value = '';
                    preview.innerHTML = '';
                    errorDiv.innerText = 'Loại file không hợp lệ';
                    errorDiv.style.display = 'block';
                    return;
                }
                
                // Validate file size (max 10MB)
                if (file.size > 10 * 1024 * 1024) {
                    Swal.fire({
                        icon: 'error',
                        title: 'File quá lớn',
                        text: 'Vui lòng chọn file nhỏ hơn 10MB',
                        confirmButtonColor: '#000'
                    });
                    editFileInput.value = '';
                    preview.innerHTML = '';
                    errorDiv.innerText = 'File quá lớn (tối đa 10MB)';
                    errorDiv.style.display = 'block';
                    return;
                }
                
                // Show preview
                const fileIcon = getFileIcon(file.name);
                preview.innerHTML = '<div class="alert alert-info">' +
                    '<i class="' + fileIcon + ' me-2"></i>' +
                    '<strong>File mới:</strong> ' + file.name + ' ' +
                    '<small>(' + formatFileSize(file.size) + ')</small>' +
                    '<button type="button" class="btn btn-sm btn-link text-danger float-end" onclick="clearEditFileInput()">' +
                    '<i class="fas fa-times"></i> Xóa' +
                    '</button>' +
                    '</div>';
                
                errorDiv.style.display = 'none';
            } else {
                preview.innerHTML = '';
            }
        });
    }
    
    // Character counter for edit description
    const editDescTextarea = document.getElementById('edit-description');
    if (editDescTextarea) {
        editDescTextarea.addEventListener('input', updateEditCharCount);
    }
});

function clearEditFileInput() {
    const fileInput = document.getElementById('edit-fileAttachment');
    const preview = document.getElementById('edit-filePreview');
    if (fileInput) fileInput.value = '';
    if (preview) preview.innerHTML = '';
}

// ===== EDIT FORM VALIDATION & SUBMIT =====
document.addEventListener('DOMContentLoaded', function() {
    const editForm = document.getElementById('editAppendixForm');
    
    if (editForm) {
        editForm.addEventListener('submit', async function(e) {
            e.preventDefault();
            e.stopPropagation();
            
            console.log('=== EDIT FORM SUBMIT ===');
            
            let isValid = true;
            const errorMessages = [];
            
            // 1. Validate Equipment Selection
            if (editSelectedEquipment.length === 0) {
                isValid = false;
                errorMessages.push('Vui lòng chọn ít nhất một thiết bị');
                const errorDiv = document.getElementById('edit-equipmentError');
                errorDiv.innerText = 'Vui lòng chọn ít nhất một thiết bị';
                errorDiv.style.display = 'block';
            } else {
                document.getElementById('edit-equipmentError').style.display = 'none';
            }
            
            // 2. Validate Description (1-1000 chars)
            const descTextarea = document.getElementById('edit-description');
            const descValue = descTextarea.value.trim();
            if (descValue.length < 1 || descValue.length > 1000) {
                isValid = false;
                errorMessages.push('Mô tả phải từ 1-1000 ký tự');
                descTextarea.classList.add('is-invalid');
            } else {
                descTextarea.classList.remove('is-invalid');
            }
            
            // 3. Validate Effective Date
            const effectiveDateInput = document.getElementById('edit-effectiveDate');
            if (effectiveDateInput.value) {
                const effectiveDate = new Date(effectiveDateInput.value);
                const today = new Date();
                today.setHours(0, 0, 0, 0);
                
                if (effectiveDate < today) {
                    isValid = false;
                    errorMessages.push('Ngày hiệu lực không được nhỏ hơn ngày hiện tại');
                    effectiveDateInput.classList.add('is-invalid');
                } else {
                    effectiveDateInput.classList.remove('is-invalid');
                }
            }
            
            // 4. Validate File (phải có file hiện tại HOẶC chọn file mới)
            const fileInput = document.getElementById('edit-fileAttachment');
            const hasNewFile = fileInput.files && fileInput.files.length > 0;
            
            if (!editHasCurrentFile && !hasNewFile) {
                isValid = false;
                errorMessages.push('Vui lòng chọn file đính kèm');
                const errorDiv = document.getElementById('edit-fileError');
                errorDiv.innerText = 'Vui lòng chọn file đính kèm';
                errorDiv.style.display = 'block';
            } else {
                document.getElementById('edit-fileError').style.display = 'none';
            }
            
            // 5. HTML5 validation
            if (!editForm.checkValidity()) {
                isValid = false;
                editForm.classList.add('was-validated');
            }
            
            // Show errors if any
            if (!isValid) {
                Swal.fire({
                    icon: 'error',
                    title: 'Thông tin chưa hợp lệ',
                    html: errorMessages.join('<br>'),
                    confirmButtonColor: '#000'
                });
                return;
            }
            
            // All validations passed, proceed with submission
            const formData = new FormData(editForm);
            const equipmentIds = editSelectedEquipment.map(e => parseInt(e.equipmentId));
            formData.append('equipmentIds', JSON.stringify(equipmentIds));
            
            try {
                const ctx = window.location.pathname.split("/")[1];
                const url = "/" + ctx + "/updateContractAppendix";
                
                console.log('Sending POST to:', url);
                
                const response = await fetch(url, {
                    method: 'POST',
                    body: formData
                });
                
                console.log('Response status:', response.status);
                
                // Check if response is JSON
                const contentType = response.headers.get('Content-Type');
                if (!contentType || !contentType.includes('application/json')) {
                    const text = await response.text();
                    console.error('Response is not JSON:', text.substring(0, 500));
                    
                    Swal.fire({
                        icon: 'error',
                        title: 'Lỗi server',
                        text: 'Server trả về lỗi. Vui lòng kiểm tra console.',
                        confirmButtonColor: '#000'
                    });
                    return;
                }
                
                const result = await response.json();
                console.log('Response data:', result);
                
                if (result.success) {
                    await Swal.fire({
                        icon: 'success',
                        title: 'Thành công!',
                        text: result.message,
                        confirmButtonColor: '#000'
                    });
                    
                    bootstrap.Modal.getInstance(document.getElementById('editAppendixModal')).hide();
                    window.location.reload();
                } else {
                    Swal.fire({
                        icon: 'error',
                        title: 'Thất bại!',
                        text: result.message,
                        confirmButtonColor: '#000'
                    });
                }
            } catch (error) {
                console.error('ERROR:', error);
                Swal.fire({
                    icon: 'error',
                    title: 'Lỗi hệ thống',
                    text: 'Không thể kết nối: ' + error.message,
                    confirmButtonColor: '#000'
                });
            }
        });
    }
});

// ===== DELETE APPENDIX =====
async function deleteAppendix(appendixId, appendixType) {
    console.log('=== DELETE APPENDIX ===');
    console.log('Appendix ID:', appendixId);
    console.log('Appendix Type:', appendixType);
    
    let warningMessage = '<p>Bạn có chắc chắn muốn xóa phụ lục này?</p>';
    
    // ✅ Message khác nhau tùy loại phụ lục
    if (appendixType === 'AddEquipment') {
        warningMessage += '<div class="alert alert-warning mt-3 mb-0">' +
                        '<i class="fas fa-exclamation-triangle"></i> ' +
                        '<strong>Lưu ý:</strong> Tất cả thiết bị và các yêu cầu dịch vụ có trạng thái <strong>Pending</strong> ' +
                        'liên quan đến phụ lục này sẽ bị xóa cùng!' +
                        '</div>';
    } else {
        warningMessage += '<div class="alert alert-info mt-3 mb-0">' +
                        '<i class="fas fa-info-circle"></i> ' +
                        'Đây là phụ lục thông tin, không có thiết bị liên quan.' +
                        '</div>';
    }
    
    const result = await Swal.fire({
        title: 'Xác nhận xóa',
        html: warningMessage,
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#d33',
        cancelButtonColor: '#6c757d',
        confirmButtonText: '<i class="fas fa-trash"></i> Xóa',
        cancelButtonText: '<i class="fas fa-times"></i> Hủy',
        customClass: {
            confirmButton: 'btn btn-danger',
            cancelButton: 'btn btn-secondary'
        }
    });
    
    if (!result.isConfirmed) return;
    
    try {
        const ctx = window.location.pathname.split("/")[1];
        const formData = new FormData();
        formData.append('appendixId', appendixId);
        
        console.log('Sending delete request...');
        
        const response = await fetch("/" + ctx + "/deleteContractAppendix", {
            method: 'POST',
            body: formData
        });
        
        console.log('Response status:', response.status);
        
        const data = await response.json();
        console.log('Response data:', data);
        
        if (data.success) {
            await Swal.fire({
                icon: 'success',
                title: 'Đã xóa!',
                html: '<p>' + data.message + '</p>',
                confirmButtonColor: '#000',
                timer: 2000
            });
            
            window.location.reload();
        } else {
            Swal.fire({
                icon: 'error',
                title: 'Không thể xóa',
                html: '<p>' + data.message + '</p>' +
                      '<small class="text-muted">Kiểm tra console để biết chi tiết</small>',
                confirmButtonColor: '#000'
            });
        }
    } catch (error) {
        console.error('ERROR:', error);
        Swal.fire({
            icon: 'error',
            title: 'Lỗi hệ thống',
            text: 'Không thể kết nối đến server: ' + error.message,
            confirmButtonColor: '#000'
        });
    }
}

// ===== TẠO HỢP ĐỒNG MỚI =====
let contractSelectedEquipment = [];
let contractAllEquipment = [];

// Character counter cho details
document.addEventListener('DOMContentLoaded', function() {
    const detailsTextarea = document.getElementById('contract-details');
    if (detailsTextarea) {
        detailsTextarea.addEventListener('input', function() {
            const count = this.value.length;
            document.getElementById('contract-detailsCount').innerText = count;
            
            if (count < 10 || count > 255) {
                this.classList.add('is-invalid');
            } else {
                this.classList.remove('is-invalid');
            }
        });
    }
    
    // Date validation
    const contractDateInput = document.getElementById('contractDate');
    if (contractDateInput) {
        const today = new Date().toISOString().split('T')[0];
        contractDateInput.setAttribute('max', today);
        
        contractDateInput.addEventListener('change', function() {
            const selectedDate = new Date(this.value);
            const todayDate = new Date();
            todayDate.setHours(0, 0, 0, 0);
            
            if (selectedDate > todayDate) {
                Swal.fire({
                    icon: 'warning',
                    title: 'Ngày không hợp lệ',
                    text: 'Ngày ký hợp đồng không được ở tương lai',
                    confirmButtonColor: '#000'
                });
                this.value = today;
            }
        });
    }
});

// Khi chọn khách hàng, load thiết bị available
document.addEventListener('change', function(e) {
    if (e.target && e.target.id === 'contract-customerSelect') {
        const customerId = e.target.value;
        contractSelectedEquipment = [];
        
        if (!customerId) {
            document.getElementById('contract-equipmentList').innerHTML = 
                '<div class="text-center text-muted py-4">' +
                '<i class="fas fa-info-circle"></i> Vui lòng chọn khách hàng trước' +
                '</div>';
            updateContractSelectedEquipmentDisplay();
            return;
        }
        
        loadContractAvailableEquipment(customerId);
    }
});

async function loadContractAvailableEquipment(customerId) {
    const container = document.getElementById('contract-equipmentList');
    container.innerHTML = '<div class="text-center py-4"><i class="fas fa-spinner fa-spin"></i> Đang tải...</div>';
    
    try {
        const ctx = window.location.pathname.split("/")[1];
        const response = await fetch("/" + ctx + "/getAvailableEquipmentForCustomer?customerId=" + customerId);
        
        if (!response.ok) throw new Error("Không thể tải danh sách thiết bị");
        
        const data = await response.json();
        
        if (data.equipment && data.equipment.length > 0) {
            contractAllEquipment = data.equipment;
            renderContractEquipmentList(contractAllEquipment);
        } else {
            container.innerHTML = '<p class="text-center text-muted">Không có thiết bị khả dụng cho khách hàng này</p>';
        }
    } catch (error) {
        console.error("Error:", error);
        container.innerHTML = '<div class="alert alert-danger">Không thể tải danh sách thiết bị</div>';
    }
}

function renderContractEquipmentList(equipmentList) {
    const container = document.getElementById('contract-equipmentList');
    
    if (!equipmentList || equipmentList.length === 0) {
        container.innerHTML = '<p class="text-center text-muted">Không tìm thấy thiết bị nào</p>';
        return;
    }
    
    let html = '';
    equipmentList.forEach(function(eq) {
        html += '<div class="equipment-item" data-id="' + eq.equipmentId + '">' +
            '<div class="form-check">' +
            '<input class="form-check-input contract-equipment-checkbox" ' +
            'type="checkbox" ' +
            'value="' + eq.equipmentId + '" ' +
            'data-model="' + (eq.model || '') + '" ' +
            'data-serial="' + (eq.serialNumber || '') + '" ' +
            'onchange="toggleContractEquipment(this)">' +
            '<label class="form-check-label">' +
            '<strong>' + (eq.model || 'N/A') + '</strong> - <code>' + (eq.serialNumber || 'N/A') + '</code>' +
            '<br><small class="text-muted">' + (eq.description || '') + '</small>' +
            '</label>' +
            '</div>' +
            '</div>';
    });
    container.innerHTML = html;
}

function toggleContractEquipment(checkbox) {
    const equipmentId = checkbox.value;
    const model = checkbox.dataset.model;
    const serial = checkbox.dataset.serial;
    
    if (checkbox.checked) {
        contractSelectedEquipment.push({
            equipmentId: equipmentId,
            model: model,
            serialNumber: serial
        });
    } else {
        contractSelectedEquipment = contractSelectedEquipment.filter(function(e) {
            return e.equipmentId !== equipmentId;
        });
    }
    
    updateContractSelectedEquipmentDisplay();
    
    // Clear error message
    if (contractSelectedEquipment.length > 0) {
        document.getElementById('contract-equipmentError').style.display = 'none';
    }
}

function updateContractSelectedEquipmentDisplay() {
    const container = document.getElementById('contract-selectedEquipmentList');
    const countSpan = document.getElementById('contract-selectedCount');
    
    countSpan.innerText = contractSelectedEquipment.length;
    
    if (contractSelectedEquipment.length === 0) {
        container.innerHTML = '<p class="text-muted text-center mb-0">Chưa có thiết bị nào được chọn</p>';
        return;
    }
    
    let html = '<div class="list-group list-group-flush">';
    contractSelectedEquipment.forEach(function(eq, index) {
        html += '<div class="list-group-item d-flex justify-content-between align-items-center py-2">' +
            '<div class="flex-grow-1">' +
            '<strong>' + (index + 1) + '. ' + eq.model + '</strong>' +
            '<br><small class="text-muted">' + eq.serialNumber + '</small>' +
            '</div>' +
            '<button type="button" class="btn btn-sm btn-danger" ' +
            'onclick="removeContractEquipment(\'' + eq.equipmentId + '\')">' +
            '<i class="fas fa-times"></i>' +
            '</button>' +
            '</div>';
    });
    html += '</div>';
    
    container.innerHTML = html;
}

function removeContractEquipment(equipmentId) {
    contractSelectedEquipment = contractSelectedEquipment.filter(function(e) {
        return e.equipmentId !== equipmentId;
    });
    
    const checkbox = document.querySelector('.contract-equipment-checkbox[value="' + equipmentId + '"]');
    if (checkbox) checkbox.checked = false;
    
    updateContractSelectedEquipmentDisplay();
}

// Search equipment
document.addEventListener('DOMContentLoaded', function() {
    const searchInput = document.getElementById('contract-equipmentSearch');
    if (searchInput) {
        searchInput.addEventListener('input', function(e) {
            filterContractEquipment();
        });
    }
});

function filterContractEquipment() {
    const keyword = document.getElementById('contract-equipmentSearch').value.toLowerCase();
    
    let filtered = contractAllEquipment;
    
    if (keyword) {
        filtered = filtered.filter(function(eq) {
            const model = (eq.model || '').toLowerCase();
            const serial = (eq.serialNumber || '').toLowerCase();
            const desc = (eq.description || '').toLowerCase();
            return model.includes(keyword) || serial.includes(keyword) || desc.includes(keyword);
        });
    }
    
    renderContractEquipmentList(filtered);
    
    // Restore checked state
    contractSelectedEquipment.forEach(function(selected) {
        const checkbox = document.querySelector('.contract-equipment-checkbox[value="' + selected.equipmentId + '"]');
        if (checkbox) checkbox.checked = true;
    });
}

// Submit form
document.addEventListener('DOMContentLoaded', function() {
    const form = document.getElementById('createContractForm');
    
    if (form) {
        form.addEventListener('submit', async function(e) {
            e.preventDefault();
            e.stopPropagation();
            
            let isValid = true;
            const errorMessages = [];
            
            // 1. Validate Customer
            const customerSelect = document.getElementById('contract-customerSelect');
            if (!customerSelect.value) {
                isValid = false;
                errorMessages.push('Vui lòng chọn khách hàng');
                customerSelect.classList.add('is-invalid');
            } else {
                customerSelect.classList.remove('is-invalid');
            }
            
            // 2. Validate Details (10-255 chars, không chỉ space)
            const detailsTextarea = document.getElementById('contract-details');
            const details = detailsTextarea.value.trim();
            if (details.length < 10 || details.length > 255) {
                isValid = false;
                errorMessages.push('Chi tiết hợp đồng phải từ 10-255 ký tự');
                detailsTextarea.classList.add('is-invalid');
            } else {
                detailsTextarea.classList.remove('is-invalid');
            }
            
            // 3. Validate Date
            const contractDateInput = document.getElementById('contractDate');
            if (contractDateInput.value) {
                const selectedDate = new Date(contractDateInput.value);
                const today = new Date();
                today.setHours(0, 0, 0, 0);
                
                if (selectedDate > today) {
                    isValid = false;
                    errorMessages.push('Ngày ký hợp đồng không được ở tương lai');
                    contractDateInput.classList.add('is-invalid');
                } else {
                    contractDateInput.classList.remove('is-invalid');
                }
            }
            
            // 4. Validate Equipment Selection
            if (contractSelectedEquipment.length === 0) {
                isValid = false;
                errorMessages.push('Vui lòng chọn ít nhất một thiết bị');
                const errorDiv = document.getElementById('contract-equipmentError');
                errorDiv.innerText = 'Vui lòng chọn ít nhất một thiết bị';
                errorDiv.style.display = 'block';
            } else {
                document.getElementById('contract-equipmentError').style.display = 'none';
            }
            
            // 5. HTML5 validation
            if (!form.checkValidity()) {
                isValid = false;
                form.classList.add('was-validated');
            }
            
            if (!isValid) {
                Swal.fire({
                    icon: 'error',
                    title: 'Thông tin chưa hợp lệ',
                    html: errorMessages.join('<br>'),
                    confirmButtonColor: '#000'
                });
                return;
            }
            
            // All validations passed
            const formData = new FormData(form);
            const equipmentIds = contractSelectedEquipment.map(e => parseInt(e.equipmentId));
            formData.append('equipmentIds', JSON.stringify(equipmentIds));
            
            try {
                const ctx = window.location.pathname.split("/")[1];
                const response = await fetch("/" + ctx + "/createContract", {
                    method: 'POST',
                    body: formData
                });
                
                const result = await response.json();
                
                if (result.success) {
                    await Swal.fire({
                        icon: 'success',
                        title: 'Thành công!',
                        text: result.message || 'Đã tạo hợp đồng thành công',
                        confirmButtonColor: '#000'
                    });
                    
                    const modalElement = document.getElementById('createContractModal');
                    const modalInstance = bootstrap.Modal.getInstance(modalElement);
                    if (modalInstance) {
                        modalInstance.hide();
                    }
                    
                    window.location.reload();
                } else {
                    Swal.fire({
                        icon: 'error',
                        title: 'Thất bại!',
                        text: result.message || 'Không thể tạo hợp đồng',
                        confirmButtonColor: '#000'
                    });
                }
            } catch (error) {
                console.error('ERROR:', error);
                Swal.fire({
                    icon: 'error',
                    title: 'Lỗi hệ thống',
                    text: error.message,
                    confirmButtonColor: '#000'
                });
            }
        });
    }
});

// Reset modal when opening
// Thêm vào đầu function openCreateContractModal()
function openCreateContractModal() {
    console.log('=== OPEN CREATE CONTRACT MODAL ===');
    
    const form = document.getElementById('createContractForm');
    if (form) {
        form.reset();
        form.classList.remove('was-validated');
        console.log('✓ Form reset');
    } else {
        console.error('✗ Form not found');
    }
    
    contractSelectedEquipment = [];
    contractAllEquipment = [];
    
    const equipmentList = document.getElementById('contract-equipmentList');
    if (equipmentList) {
        equipmentList.innerHTML = 
            '<div class="text-center text-muted py-4">' +
            '<i class="fas fa-info-circle"></i> Vui lòng chọn khách hàng trước' +
            '</div>';
        console.log('✓ Equipment list reset');
    } else {
        console.error('✗ Equipment list not found');
    }
    
    updateContractSelectedEquipmentDisplay();
    
    document.getElementById('contract-detailsCount').innerText = '0';
    
    const errorDiv = document.getElementById('contract-equipmentError');
    if (errorDiv) {
        errorDiv.style.display = 'none';
    }
    
    try {
        new bootstrap.Modal(document.getElementById('createContractModal')).show();
        console.log('✓ Modal shown');
    } catch (e) {
        console.error('✗ Error showing modal:', e);
    }
    
    console.log('===== END OPEN MODAL =====');
}

// ===== XÓA HỢP ĐỒNG =====
async function deleteContract(contractId, customerName) {
    try {
        // ✅ Lấy thông tin chi tiết về requests trước
        const ctx = window.location.pathname.split("/")[1];
        const infoResponse = await fetch("/" + ctx + "/getContractDeletionInfo?contractId=" + contractId);
        const infoData = await infoResponse.json();
        
        let warningMessage = '<p>Bạn có chắc chắn muốn xóa hợp đồng <strong>#' + contractId + 
                           '</strong> của khách hàng <strong>' + customerName + '</strong>?</p>';
        
        // ✅ Hiển thị thông tin về requests sẽ bị xóa
        if (infoData.success && infoData.info) {
            const info = infoData.info;
            const totalRequests = info.totalRequests || 0;
            const pendingRequests = info.pendingRequests || 0;
            const cancelledRequests = info.cancelledRequests || 0;
            const activeRequests = info.activeRequests || 0;
            
            if (totalRequests > 0) {
                warningMessage += '<div class="alert alert-info mt-3 mb-0">' +
                                '<i class="fas fa-info-circle"></i> ' +
                                '<strong>Thông tin yêu cầu dịch vụ:</strong>' +
                                '<ul class="mb-0 mt-2">' +
                                '<li>Tổng số yêu cầu: <strong>' + totalRequests + '</strong></li>';
                
                if (pendingRequests > 0) {
                    warningMessage += '<li class="text-warning">Pending: <strong>' + pendingRequests + '</strong> (sẽ bị xóa)</li>';
                }
                if (cancelledRequests > 0) {
                    warningMessage += '<li class="text-secondary">Cancelled: <strong>' + cancelledRequests + '</strong> (sẽ bị xóa)</li>';
                }
                if (activeRequests > 0) {
                    warningMessage += '<li class="text-danger">Đang xử lý: <strong>' + activeRequests + '</strong> (không thể xóa)</li>';
                }
                
                warningMessage += '</ul></div>';
            }
        }
        
        warningMessage += '<div class="alert alert-danger mt-3 mb-0">' +
                        '<i class="fas fa-exclamation-triangle"></i> ' +
                        '<strong>CẢNH BÁO:</strong> Hành động này sẽ <strong>XÓA VĨNH VIỄN</strong> hợp đồng khỏi hệ thống!' +
                        '<br><small>Tất cả dữ liệu liên quan (thiết bị, yêu cầu Pending/Cancelled) sẽ bị xóa và KHÔNG THỂ KHÔI PHỤC!</small>' +
                        '</div>';
        
        const result = await Swal.fire({
            title: 'Xác nhận xóa vĩnh viễn hợp đồng',
            html: warningMessage,
            icon: 'error',
            showCancelButton: true,
            confirmButtonColor: '#d33',
            cancelButtonColor: '#6c757d',
            confirmButtonText: '<i class="fas fa-trash"></i> Xóa vĩnh viễn',
            cancelButtonText: '<i class="fas fa-times"></i> Hủy',
            width: '600px',
            customClass: {
                confirmButton: 'btn btn-danger',
                cancelButton: 'btn btn-secondary'
            }
        });
        
        if (!result.isConfirmed) return;
        
        // ✅ Confirmation thứ 2 để chắc chắn
        const confirmAgain = await Swal.fire({
            title: 'Xác nhận lần cuối',
            html: '<p class="text-danger fw-bold">Bạn THỰC SỰ muốn xóa hợp đồng #' + contractId + '?</p>' +
                  '<p class="text-muted">Dữ liệu sẽ bị xóa vĩnh viễn và không thể khôi phục!</p>',
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#d33',
            cancelButtonColor: '#6c757d',
            confirmButtonText: 'Tôi chắc chắn, XÓA!',
            cancelButtonText: 'Không, hủy bỏ'
        });
        
        if (!confirmAgain.isConfirmed) return;
        
        // ✅ Thực hiện xóa
        const formData = new FormData();
        formData.append('contractId', contractId);
        
        console.log('Deleting contract:', contractId);
        
        const response = await fetch("/" + ctx + "/deleteContract", {
            method: 'POST',
            body: formData
        });
        
        console.log('Response status:', response.status);
        
        const data = await response.json();
        console.log('Response data:', data);
        
        if (data.success) {
            let successMessage = '<p>' + data.message + '</p>';
            
            if (data.deletedRequests && data.deletedRequests > 0) {
                successMessage += '<small class="text-info">' +
                                '<i class="fas fa-check-circle"></i> ' +
                                'Đã xóa ' + data.deletedRequests + ' yêu cầu dịch vụ Pending/Cancelled' +
                                '</small><br>';
            }
            
            successMessage += '<small class="text-muted">Hợp đồng đã được xóa vĩnh viễn khỏi hệ thống</small>';
            
            await Swal.fire({
                icon: 'success',
                title: 'Đã xóa!',
                html: successMessage,
                confirmButtonColor: '#000',
                timer: 4000
            });
            
            window.location.reload();
        } else {
            Swal.fire({
                icon: 'error',
                title: 'Không thể xóa',
                html: '<p>' + data.message + '</p>',
                confirmButtonColor: '#000'
            });
        }
    } catch (error) {
        console.error('ERROR:', error);
        Swal.fire({
            icon: 'error',
            title: 'Lỗi hệ thống',
            text: 'Không thể kết nối đến server: ' + error.message,
            confirmButtonColor: '#000'
        });
    }
}

async function openViewAppendixModal(appendixId) {
    console.log('=== OPEN VIEW APPENDIX MODAL ===');
    console.log('Appendix ID:', appendixId);
    
    try {
        const ctx = window.location.pathname.split("/")[1];
        const response = await fetch("/" + ctx + "/viewAppendixDetails?appendixId=" + appendixId);
        
        if (!response.ok) throw new Error("Không thể tải thông tin phụ lục");
        
        const data = await response.json();
        
        if (!data.success) {
            Swal.fire({
                icon: 'error',
                title: 'Lỗi',
                text: data.message,
                confirmButtonColor: '#000'
            });
            return;
        }
        
        const appendix = data.appendix;
        const equipment = data.equipment || [];
        
        // Hiển thị thông tin phụ lục
        document.getElementById('view-appendixType').value = 
            appendix.appendixType === 'AddEquipment' ? 'Thêm thiết bị' : 'Khác';
        document.getElementById('view-appendixName').value = appendix.appendixName;
        document.getElementById('view-description').value = appendix.description || '';
        document.getElementById('view-effectiveDate').value = appendix.effectiveDate;
        document.getElementById('view-status').value = appendix.status;
        
        // Hiển thị file
        const fileDisplay = document.getElementById('view-fileDisplay');
        if (appendix.fileAttachment) {
            const fileName = appendix.fileAttachment.split('/').pop();
            const fileIcon = getFileIcon(appendix.fileAttachment);
            fileDisplay.innerHTML = 
                '<a href="' + appendix.fileAttachment + '" target="_blank" class="btn btn-outline-success btn-sm">' +
                '<i class="' + fileIcon + ' me-2"></i>' + fileName +
                '</a>';
        } else {
            fileDisplay.innerHTML = '<span class="text-muted">Không có file</span>';
        }
        
        // Hiển thị danh sách thiết bị
        const equipmentContainer = document.getElementById('view-equipmentList');
        const countSpan = document.getElementById('view-equipmentCount');
        
        countSpan.innerText = equipment.length;
        
        if (equipment.length === 0) {
            equipmentContainer.innerHTML = '<p class="text-muted text-center mb-0">Chưa có thiết bị nào</p>';
        } else {
            let html = '<div class="list-group list-group-flush">';
            equipment.forEach(function(eq, index) {
                html += '<div class="list-group-item bg-white">' +
                    '<div class="d-flex align-items-start">' +
                    '<div class="me-2">' +
                    '<span class="badge bg-primary rounded-circle">' + (index + 1) + '</span>' +
                    '</div>' +
                    '<div class="flex-grow-1">' +
                    '<strong>' + (eq.model || 'N/A') + '</strong>' +
                    '<br><small class="text-muted"><code>' + (eq.serialNumber || 'N/A') + '</code></small>' +
                    (eq.description ? '<br><small class="text-secondary">' + eq.description + '</small>' : '') +
                    '</div>' +
                    '</div>' +
                    '</div>';
            });
            html += '</div>';
            equipmentContainer.innerHTML = html;
        }
        
        // Show modal
        new bootstrap.Modal(document.getElementById('viewAppendixModal')).show();
        
    } catch (error) {
        console.error("Error:", error);
        Swal.fire({
            icon: 'error',
            title: 'Lỗi',
            text: 'Không thể tải thông tin phụ lục',
            confirmButtonColor: '#000'
        });
    }
}
</script>
</body>
</html>