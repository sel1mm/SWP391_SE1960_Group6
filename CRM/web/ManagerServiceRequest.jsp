<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Yêu Cầu Dịch Vụ - Customer</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #f8f9fa;
        }
        .main-container {
            padding: 30px 0;
        }
        .stats-card {
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .stats-card i {
            font-size: 2.5rem;
            opacity: 0.8;
        }
        .table-container {
            background: white;
            border-radius: 10px;
            padding: 25px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .badge-pending {
            background-color: #ffc107;
            color: #000;
        }
        .badge-inprogress {
            background-color: #0dcaf0;
        }
        .badge-completed {
            background-color: #198754;
        }
        .badge-cancelled {
            background-color: #dc3545;
        }
        .search-filter-bar {
            background: white;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .btn-action {
            padding: 5px 10px;
            margin: 0 2px;
        }
        
        /* CSS cho Toast - Trượt từ phải sang trái */
        #toastContainer {
            position: fixed;
            top: 20px;
            right: -400px;
            z-index: 9999;
            width: 350px;
            transition: right 0.5s ease-in-out;
        }
        
        #toastContainer.show {
            right: 20px;
        }
        
        .toast-notification {
            background: white;
            border-radius: 10px;
            padding: 15px 20px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .toast-notification.success {
            border-left: 4px solid #198754;
        }
        
        .toast-notification.error {
            border-left: 4px solid #dc3545;
        }
        
        .toast-notification.warning {
            border-left: 4px solid #ffc107;
        }
        
        .toast-icon {
            font-size: 24px;
            flex-shrink: 0;
        }
        
        .toast-icon.success {
            color: #198754;
        }
        
        .toast-icon.error {
            color: #dc3545;
        }
        
        .toast-icon.warning {
            color: #ffc107;
        }
        
        .toast-content {
            flex: 1;
        }
        
        .toast-close {
            background: none;
            border: none;
            font-size: 20px;
            cursor: pointer;
            color: #6c757d;
            padding: 0;
            width: 20px;
            height: 20px;
        }
        
        .toast-close:hover {
            color: #000;
        }
    </style>
</head>
<body>
    <!-- Toast Container -->
    <div id="toastContainer"></div>

    <div class="container main-container">
        <!-- Header -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2><i class="fas fa-clipboard-list"></i> Yêu Cầu Dịch Vụ Của Tôi</h2>
            <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#createModal">
                <i class="fas fa-plus"></i> Tạo Yêu Cầu Mới
            </button>
        </div>

        <!-- Alert Messages từ session - trigger toast -->
        <%
            String errorMsg = (String) session.getAttribute("error");
            String successMsg = (String) session.getAttribute("success");
            
            if (errorMsg != null) {
                session.removeAttribute("error");
        %>
            <script>
                window.addEventListener('load', function() {
                    showToast('<%= errorMsg %>', 'error');
                });
            </script>
        <%
            }
            
            if (successMsg != null) {
                session.removeAttribute("success");
        %>
            <script>
                window.addEventListener('load', function() {
                    showToast('<%= successMsg %>', 'success');
                });
            </script>
        <%
            }
        %>

        <!-- Statistics Cards -->
        <div class="row">
            <div class="col-md-3">
                <div class="stats-card bg-primary text-white">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <h6>Tổng Yêu Cầu</h6>
                            <h2>${totalRequests}</h2>
                        </div>
                        <i class="fas fa-clipboard-list"></i>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stats-card bg-warning text-dark">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <h6>Chờ Xử Lý</h6>
                            <h2>${pendingCount}</h2>
                        </div>
                        <i class="fas fa-clock"></i>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stats-card bg-info text-white">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <h6>Đang Xử Lý</h6>
                            <h2>${inProgressCount}</h2>
                        </div>
                        <i class="fas fa-spinner"></i>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stats-card bg-success text-white">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <h6>Hoàn Thành</h6>
                            <h2>${completedCount}</h2>
                        </div>
                        <i class="fas fa-check-circle"></i>
                    </div>
                </div>
            </div>
        </div>

        <!-- Search & Filter Bar -->
        <div class="search-filter-bar">
            <form action="${pageContext.request.contextPath}/managerServiceRequest" method="get" class="row g-3">
                <div class="col-md-6">
                    <div class="input-group">
                        <input type="text" class="form-control" name="keyword" 
                               placeholder="Tìm kiếm theo mô tả, ID..." value="${keyword}">
                        <button class="btn btn-primary" type="submit" name="action" value="search">
                            <i class="fas fa-search"></i> Tìm Kiếm
                        </button>
                    </div>
                </div>
                <div class="col-md-4">
                    <select class="form-select" name="status" id="filterStatus">
                        <option value="">-- Tất Cả Trạng Thái --</option>
                        <option value="Pending" ${filterStatus == 'Pending' ? 'selected' : ''}>Chờ Xử Lý</option>
                        <option value="In Progress" ${filterStatus == 'In Progress' ? 'selected' : ''}>Đang Xử Lý</option>
                        <option value="Completed" ${filterStatus == 'Completed' ? 'selected' : ''}>Hoàn Thành</option>
                        <option value="Cancelled" ${filterStatus == 'Cancelled' ? 'selected' : ''}>Đã Hủy</option>
                    </select>
                </div>
                <div class="col-md-2">
                    <button type="submit" name="action" value="filter" class="btn btn-info w-100">
                        <i class="fas fa-filter"></i> Lọc
                    </button>
                </div>
            </form>
            <c:if test="${searchMode || filterMode}">
                <div class="mt-2">
                    <a href="${pageContext.request.contextPath}/managerServiceRequest" class="btn btn-sm btn-secondary">
                        <i class="fas fa-times"></i> Xóa Bộ Lọc
                    </a>
                </div>
            </c:if>
        </div>

        <!-- Table -->
        <div class="table-container">
            <div class="table-responsive">
                <table class="table table-hover">
                    <thead class="table-light">
                        <tr>
                            <th>Mã YC</th>
                            <th>Hợp Đồng</th>
                            <th>Thiết Bị</th>
                            <th>Mô Tả</th>
                            <th>Ngày Tạo</th>
                            <th>Trạng Thái</th>
                            <th>Thao Tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="request" items="${requests}">
                            <tr>
                                <td><strong>#${request.requestId}</strong></td>
                                <td>${request.contractId}</td>
                                <td>${request.equipmentId}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${request.description.length() > 60}">
                                            ${request.description.substring(0, 60)}...
                                        </c:when>
                                        <c:otherwise>
                                            ${request.description}
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <fmt:formatDate value="${request.requestDate}" pattern="dd/MM/yyyy"/>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${request.status == 'Pending'}">
                                            <span class="badge badge-pending">Chờ Xử Lý</span>
                                        </c:when>
                                        <c:when test="${request.status == 'In Progress'}">
                                            <span class="badge badge-inprogress">Đang Xử Lý</span>
                                        </c:when>
                                        <c:when test="${request.status == 'Completed'}">
                                            <span class="badge badge-completed">Hoàn Thành</span>
                                        </c:when>
                                        <c:when test="${request.status == 'Cancelled'}">
                                            <span class="badge badge-cancelled">Đã Hủy</span>
                                        </c:when>
                                    </c:choose>
                                </td>
                                <td>
                                    <button class="btn btn-sm btn-info btn-action" 
                                            onclick="viewRequest('${request.requestId}', '${request.contractId}', '${request.equipmentId}', '${request.description}', '<fmt:formatDate value="${request.requestDate}" pattern="dd/MM/yyyy"/>', '${request.status}', '${request.priorityLevel}')">
                                        <i class="fas fa-eye"></i> Chi Tiết
                                    </button>
                                    
                                    <!-- Chỉ hiển thị nút Edit nếu status = Pending -->
                                    <c:if test="${request.status == 'Pending'}">
                                        <button class="btn btn-sm btn-warning btn-action" 
                                                onclick="editRequest('${request.requestId}', '${request.description}', '${request.priorityLevel}')">
                                            <i class="fas fa-edit"></i> Sửa
                                        </button>
                                    </c:if>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty requests}">
                            <tr>
                                <td colspan="7" class="text-center py-4">
                                    <i class="fas fa-inbox fa-3x text-muted mb-3"></i>
                                    <p class="text-muted">Bạn chưa có yêu cầu dịch vụ nào</p>
                                    <button class="btn btn-primary mt-2" data-bs-toggle="modal" data-bs-target="#createModal">
                                        <i class="fas fa-plus"></i> Tạo Yêu Cầu Đầu Tiên
                                    </button>
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Create Modal -->
    <div class="modal fade" id="createModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <form action="${pageContext.request.contextPath}/managerServiceRequest?action=CreateServiceRequest" method="post">
                    <div class="modal-header bg-primary text-white">
                        <h5 class="modal-title"><i class="fas fa-plus"></i> Tạo Yêu Cầu Dịch Vụ Mới</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div class="alert alert-info">
                            <i class="fas fa-info-circle"></i> Vui lòng điền đầy đủ thông tin. Chúng tôi sẽ liên hệ bạn trong thời gian sớm nhất.
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label">Mã Hợp Đồng <span class="text-danger">*</span></label>
                            <input type="number" class="form-control" name="contractId" 
                                   placeholder="Nhập mã hợp đồng của bạn">
                            <small class="form-text text-muted">Mã hợp đồng được cung cấp khi ký hợp đồng</small>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label">Mã Thiết Bị <span class="text-danger">*</span></label>
                            <input type="number" class="form-control" name="equipmentId" 
                                   placeholder="Nhập mã thiết bị cần bảo trì">
                            <small class="form-text text-muted">Mã thiết bị có trên tem dán thiết bị</small>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label">Mô Tả Vấn Đề <span class="text-danger">*</span></label>
                            <textarea class="form-control" name="description" rows="5" 
                                      placeholder="Mô tả chi tiết vấn đề bạn đang gặp phải với thiết bị..."></textarea>
                            <small class="form-text text-muted">Mô tả chi tiết giúp chúng tôi hỗ trợ bạn tốt hơn</small>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                            <i class="fas fa-times"></i> Hủy
                        </button>
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-paper-plane"></i> Gửi Yêu Cầu
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- View Detail Modal -->
    <div class="modal fade" id="viewModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header bg-info text-white">
                    <h5 class="modal-title"><i class="fas fa-file-alt"></i> Chi Tiết Yêu Cầu</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <strong><i class="fas fa-hashtag"></i> Mã Yêu Cầu:</strong>
                            <p class="ms-4" id="viewRequestId"></p>
                        </div>
                        <div class="col-md-6">
                            <strong><i class="fas fa-calendar"></i> Ngày Tạo:</strong>
                            <p class="ms-4" id="viewRequestDate"></p>
                        </div>
                    </div>
                    
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <strong><i class="fas fa-file-contract"></i> Mã Hợp Đồng:</strong>
                            <p class="ms-4" id="viewContractId"></p>
                        </div>
                        <div class="col-md-6">
                            <strong><i class="fas fa-cog"></i> Mã Thiết Bị:</strong>
                            <p class="ms-4" id="viewEquipmentId"></p>
                        </div>
                    </div>
                    
                    <div class="mb-3">
                        <strong><i class="fas fa-info-circle"></i> Trạng Thái:</strong>
                        <p class="ms-4">
                            <span class="badge" id="viewStatus"></span>
                        </p>
                    </div>
                    
                    <div class="mb-3">
                        <strong><i class="fas fa-align-left"></i> Mô Tả Vấn Đề:</strong>
                        <div class="border rounded p-3 bg-light ms-4" id="viewDescription" style="white-space: pre-wrap;"></div>
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

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Biến lưu timeout
        let currentToastTimeout = null;
        
        // Hàm hiển thị toast
        function showToast(message, type) {
            const container = document.getElementById('toastContainer');
            container.innerHTML = '';
            
            if (currentToastTimeout) {
                clearTimeout(currentToastTimeout);
            }
            
            const toast = document.createElement('div');
            toast.className = 'toast-notification ' + type;
            
            let iconClass = type === 'success' ? 'fa-check-circle' : (type === 'warning' ? 'fa-exclamation-triangle' : 'fa-exclamation-circle');
            
            toast.innerHTML = '<div class="toast-icon ' + type + '"><i class="fas ' + iconClass + '"></i></div>' +
                            '<div class="toast-content">' + message + '</div>' +
                            '<button class="toast-close" onclick="hideToast()"><i class="fas fa-times"></i></button>';
            
            container.appendChild(toast);
            
            setTimeout(function() {
                container.classList.add('show');
            }, 10);
            
            currentToastTimeout = setTimeout(function() {
                hideToast();
            }, 5000);
        }
        
        // Hàm ẩn toast
        function hideToast() {
            const container = document.getElementById('toastContainer');
            container.classList.remove('show');
            setTimeout(function() {
                container.innerHTML = '';
            }, 500);
            if (currentToastTimeout) {
                clearTimeout(currentToastTimeout);
                currentToastTimeout = null;
            }
        }

        // Hàm xem chi tiết
        function viewRequest(id, contractId, equipmentId, description, requestDate, status) {
            document.getElementById('viewRequestId').textContent = '#' + id;
            document.getElementById('viewContractId').textContent = contractId;
            document.getElementById('viewEquipmentId').textContent = equipmentId;
            document.getElementById('viewDescription').textContent = description;
            document.getElementById('viewRequestDate').textContent = requestDate;
            
            const statusBadge = document.getElementById('viewStatus');
            statusBadge.className = 'badge ';
            
            switch(status) {
                case 'Pending':
                    statusBadge.className += 'badge-pending';
                    statusBadge.textContent = 'Chờ Xử Lý';
                    break;
                case 'In Progress':
                    statusBadge.className += 'badge-inprogress';
                    statusBadge.textContent = 'Đang Xử Lý';
                    break;
                case 'Completed':
                    statusBadge.className += 'badge-completed';
                    statusBadge.textContent = 'Hoàn Thành';
                    break;
                case 'Cancelled':
                    statusBadge.className += 'badge-cancelled';
                    statusBadge.textContent = 'Đã Hủy';
                    break;
            }
            
            var viewModal = new bootstrap.Modal(document.getElementById('viewModal'));
            viewModal.show();
        }
    </script>
</body>
</html>