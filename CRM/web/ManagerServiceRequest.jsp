<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manager Service Request</title>
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
        
        #toastContainer {
            position: fixed;
            top: 80px;
            right: 20px;
            z-index: 99999;
            width: 350px;
            max-width: 90vw;
        }
        
        .toast-notification {
            background: white;
            border-radius: 10px;
            padding: 15px 20px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            display: flex;
            align-items: center;
            gap: 15px;
            margin-bottom: 10px;
            animation: slideInRight 0.4s ease-out;
        }
        
        @keyframes slideInRight {
            from {
                transform: translateX(400px);
                opacity: 0;
            }
            to {
                transform: translateX(0);
                opacity: 1;
            }
        }
        
        .toast-notification.hiding {
            animation: slideOutRight 0.4s ease-out forwards;
        }
        
        @keyframes slideOutRight {
            from {
                transform: translateX(0);
                opacity: 1;
            }
            to {
                transform: translateX(400px);
                opacity: 0;
            }
        }
        
        .toast-notification.success {
            border-left: 4px solid #198754;
        }
        
        .toast-notification.error {
            border-left: 4px solid #dc3545;
        }
        
        .toast-notification.info {
            border-left: 4px solid #0dcaf0;
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
        
        .toast-icon.info {
            color: #0dcaf0;
        }
        
        .toast-content {
            flex: 1;
        }
        
        .toast-close {
            background: none;
            border: none;
            cursor: pointer;
            color: #999;
            padding: 0;
            font-size: 18px;
            transition: color 0.2s;
        }
        
        .toast-close:hover {
            color: #333;
        }
    </style>
</head>
<body>
    <div id="toastContainer"></div>

    <div class="container main-container">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2><i class="fas fa-clipboard-list"></i> Yêu Cầu Dịch Vụ Của Tôi</h2>
            <div class="d-flex gap-2">
                <button class="btn btn-secondary" onclick="refreshPage()">
                    <i class="fas fa-sync"></i> Làm Mới
                </button>
                <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#createModal">
                    <i class="fas fa-plus"></i> Tạo Yêu Cầu Mới
                </button>
            </div>
        </div>

        <%
            String errorMsg = (String) session.getAttribute("error");
            String successMsg = (String) session.getAttribute("success");
            String infoMsg = (String) session.getAttribute("info");
        %>
        
        <% if (errorMsg != null || successMsg != null || infoMsg != null) { %>
        <script>
            window.onload = function() {
                <% if (errorMsg != null) { 
                    session.removeAttribute("error");
                %>
                    setTimeout(function() {
                        showToast('<%= errorMsg.replace("'", "\\'").replace("\"", "\\\"") %>', 'error');
                    }, 100);
                <% } %>
                
                <% if (successMsg != null) { 
                    session.removeAttribute("success");
                %>
                    setTimeout(function() {
                        showToast('<%= successMsg.replace("'", "\\'").replace("\"", "\\\"") %>', 'success');
                    }, 100);
                <% } %>
                
                <% if (infoMsg != null) { 
                    session.removeAttribute("info");
                %>
                    setTimeout(function() {
                        showToast('<%= infoMsg.replace("'", "\\'").replace("\"", "\\\"") %>', 'info');
                    }, 100);
                <% } %>
            };
        </script>
        <% } %>

        <!-- THỐNG KÊ -->
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
                            <h6>Đã Duyệt</h6>
                            <h2>${inProgressCount}</h2>
                        </div>
                        <i class="fas fa-spinner"></i>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stats-card bg-danger text-white">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <h6>Đã Hủy</h6>
                            <h2>${cancelledCount}</h2>
                        </div>
                        <i class="fas fa-times-circle"></i>
                    </div>
                </div>
            </div>
        </div>

        <!-- SEARCH & FILTER BAR -->
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
                        <option value="Approved" ${filterStatus == 'Approved' ? 'selected' : ''}>Đã Duyệt</option>
                        <option value="Completed" ${filterStatus == 'Completed' ? 'selected' : ''}>Hoàn Thành</option>
                        <option value="Rejected" ${filterStatus == 'Rejected' ? 'selected' : ''}>Bị từ chối</option>
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

        <!-- BẢNG DANH SÁCH -->
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
                        <c:forEach var="req" items="${requests}">
                            <tr>
                                <td><strong>#${req.requestId}</strong></td>
                                <td>${req.contractId}</td>
                                <td>${req.equipmentId}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${req.description.length() > 60}">
                                            ${req.description.substring(0, 60)}...
                                        </c:when>
                                        <c:otherwise>
                                            ${req.description}
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <fmt:formatDate value="${req.requestDate}" pattern="dd/MM/yyyy"/>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${req.status == 'Pending'}"><span class="badge badge-pending">Chờ Xử Lý</span></c:when>
                                        <c:when test="${req.status == 'Approved'}"><span class="badge badge-inprogress">Đã Duyệt</span></c:when>
                                        <c:when test="${req.status == 'Completed'}"><span class="badge badge-completed">Hoàn Thành</span></c:when>
                                        <c:when test="${req.status == 'Rejected'}"><span class="badge badge-cancelled">Bị từ chối</span></c:when>
                                        <c:when test="${req.status == 'Cancelled'}"><span class="badge badge-cancelled">Đã Hủy</span></c:when>
                                    </c:choose>
                                </td>
                                <td>
                                    <button class="btn btn-sm btn-info btn-action btn-view"
                                            data-id="${req.requestId}"
                                            data-contract-id="${req.contractId}"
                                            data-equipment-id="${req.equipmentId}"
                                            data-description="${fn:escapeXml(req.description)}"
                                            data-request-date="<fmt:formatDate value="${req.requestDate}" pattern="dd/MM/yyyy"/>"
                                            data-status="${req.status}"
                                            data-priority="${req.priorityLevel}">
                                        <i class="fas fa-eye"></i> Chi Tiết
                                    </button>
                                    
                                    <c:if test="${req.status == 'Pending'}">
                                        <button class="btn btn-sm btn-warning btn-action btn-edit"
                                                data-id="${req.requestId}"
                                                data-description="${fn:escapeXml(req.description)}"
                                                data-priority="${req.priorityLevel}">
                                            <i class="fas fa-edit"></i> Sửa
                                        </button>
                                        <button class="btn btn-sm btn-danger btn-action btn-cancel"
                                                data-id="${req.requestId}">
                                            <i class="fas fa-times-circle"></i> Hủy
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

            <!-- PHÂN TRANG -->
            <c:if test="${totalPages > 1}">
                <nav aria-label="Page navigation" class="mt-4">
                    <ul class="pagination justify-content-center">
                        <li class="page-item ${currentPage <= 1 ? 'disabled' : ''}">
                            <c:if test="${currentPage > 1}">
                                <a class="page-link" href="?page=${currentPage - 1}${filterStatus != null ? '&status='.concat(filterStatus) : ''}${keyword != null ? '&keyword='.concat(keyword) : ''}&action=${filterMode ? 'filter' : (searchMode ? 'search' : '')}">
                                    <i class="fas fa-chevron-left"></i> Trước
                                </a>
                            </c:if>
                            <c:if test="${currentPage <= 1}">
                                <span class="page-link">
                                    <i class="fas fa-chevron-left"></i> Trước
                                </span>
                            </c:if>
                        </li>
                        
                        <c:forEach var="i" begin="1" end="${totalPages}">
                            <li class="page-item ${i == currentPage ? 'active' : ''}">
                                <c:if test="${i != currentPage}">
                                    <a class="page-link" href="?page=${i}${filterStatus != null ? '&status='.concat(filterStatus) : ''}${keyword != null ? '&keyword='.concat(keyword) : ''}&action=${filterMode ? 'filter' : (searchMode ? 'search' : '')}">
                                        ${i}
                                    </a>
                                </c:if>
                                <c:if test="${i == currentPage}">
                                    <span class="page-link">${i}</span>
                                </c:if>
                            </li>
                        </c:forEach>
                        
                        <li class="page-item ${currentPage >= totalPages ? 'disabled' : ''}">
                            <c:if test="${currentPage < totalPages}">
                                <a class="page-link" href="?page=${currentPage + 1}${filterStatus != null ? '&status='.concat(filterStatus) : ''}${keyword != null ? '&keyword='.concat(keyword) : ''}&action=${filterMode ? 'filter' : (searchMode ? 'search' : '')}">
                                    Tiếp <i class="fas fa-chevron-right"></i>
                                </a>
                            </c:if>
                            <c:if test="${currentPage >= totalPages}">
                                <span class="page-link">
                                    Tiếp <i class="fas fa-chevron-right"></i>
                                </span>
                            </c:if>
                        </li>
                    </ul>
                </nav>
                
                <div class="text-center text-muted mb-3">
                    <small>
                        Trang <strong>${currentPage}</strong> của <strong>${totalPages}</strong> 
                        | Hiển thị <strong>${fn:length(requests)}</strong> yêu cầu
                    </small>
                </div>
            </c:if>
        </div>
    </div>

    <!-- ========== MODAL TẠO YÊU CẦU MỚI - CÓ PRIORITY ========== -->
    <div class="modal fade" id="createModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <form action="${pageContext.request.contextPath}/managerServiceRequest" method="post">
                    <input type="hidden" name="action" value="CreateServiceRequest">
                    <div class="modal-header bg-primary text-white">
                        <h5 class="modal-title"><i class="fas fa-plus"></i> Tạo Yêu Cầu Dịch Vụ Mới</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div class="mb-3">
                            <label class="form-label">Mã Hợp Đồng <span class="text-danger">*</span></label>
                            <input type="number" class="form-control" name="contractId" placeholder="Nhập mã hợp đồng của bạn" required>
                            <small class="form-text text-muted">Nhập mã hợp đồng đã ký với công ty</small>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Mã Thiết Bị <span class="text-danger">*</span></label>
                            <input type="number" class="form-control" name="equipmentId" placeholder="Nhập mã thiết bị cần bảo trì" required>
                            <small class="form-text text-muted">Nhập mã thiết bị cần yêu cầu dịch vụ</small>
                        </div>
                        
                        <!-- ⭐ MỨC ĐỘ ƯU TIÊN - PHẦN MỚI THÊM -->
                        <div class="mb-3">
                            <label class="form-label">Mức Độ Ưu Tiên <span class="text-danger">*</span></label>
                            <select class="form-select" name="priorityLevel" required>
                                <option value="Normal" selected> Bình Thường </option>
                                <option value="High"> Cao</option>
                                <option value="Urgent"> Khẩn Cấp </option>
                            </select>
                            <small class="form-text text-muted">Chọn mức độ ưu tiên phù hợp với tình trạng thiết bị</small>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label">Mô Tả Vấn Đề <span class="text-danger">*</span></label>
                            <textarea class="form-control" name="description" rows="5" placeholder="Mô tả chi tiết vấn đề bạn đang gặp phải..." required></textarea>
                            <small class="form-text text-muted">Tối thiểu 10 ký tự. Mô tả càng chi tiết càng giúp xử lý nhanh hơn.</small>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                        <button type="submit" class="btn btn-primary"><i class="fas fa-paper-plane"></i> Gửi Yêu Cầu</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- MODAL HỦY -->
    <div class="modal fade" id="cancelModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <form action="${pageContext.request.contextPath}/managerServiceRequest" method="post">
                    <input type="hidden" name="action" value="CancelServiceRequest">
                    <div class="modal-header bg-danger text-white">
                        <h5 class="modal-title"><i class="fas fa-exclamation-triangle"></i> Xác Nhận Hủy</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <p>Bạn có chắc chắn muốn hủy yêu cầu <strong id="cancelRequestIdDisplay"></strong> không?</p>
                        <input type="hidden" name="requestId" id="cancelRequestId">
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Không</button>
                        <button type="submit" class="btn btn-danger">Có, Hủy Yêu Cầu</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- MODAL XEM CHI TIẾT -->
    <div class="modal fade" id="viewModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header bg-info text-white">
                    <h5 class="modal-title"><i class="fas fa-file-alt"></i> Chi Tiết Yêu Cầu</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="row mb-3">
                        <div class="col-md-6"><strong>Mã Yêu Cầu:</strong> <p class="fw-normal" id="viewRequestId"></p></div>
                        <div class="col-md-6"><strong>Ngày Tạo:</strong> <p class="fw-normal" id="viewRequestDate"></p></div>
                    </div>
                    <div class="row mb-3">
                        <div class="col-md-6"><strong>Mã Hợp Đồng:</strong> <p class="fw-normal" id="viewContractId"></p></div>
                        <div class="col-md-6"><strong>Mã Thiết Bị:</strong> <p class="fw-normal" id="viewEquipmentId"></p></div>
                    </div>
                    <div class="row mb-3">
                        <div class="col-md-6"><strong>Trạng Thái:</strong> <span class="badge" id="viewStatus"></span></div>
                        <div class="col-md-6"><strong>Mức Độ Ưu Tiên:</strong> <span class="badge" id="viewPriority"></span></div>
                    </div>
                    <div class="mb-3">
                        <strong>Mô Tả Vấn Đề:</strong>
                        <div class="border rounded p-3 bg-light" id="viewDescription" style="white-space: pre-wrap;"></div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                </div>
            </div>
        </div>
    </div>

    <!-- MODAL SỬA -->
    <div class="modal fade" id="editModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <form action="${pageContext.request.contextPath}/managerServiceRequest" method="post">
                    <input type="hidden" name="action" value="UpdateServiceRequest">
                    <div class="modal-header bg-warning text-dark">
                        <h5 class="modal-title"><i class="fas fa-edit"></i> Chỉnh Sửa Yêu Cầu</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <input type="hidden" name="requestId" id="editRequestId">
                        <div class="mb-3">
                            <label class="form-label">Mức Độ Ưu Tiên</label>
                            <select class="form-select" name="priorityLevel" id="editPriorityLevel" required>
                                <option value="Normal">Bình Thường</option>
                                <option value="High">Cao</option>
                                <option value="Urgent">Khẩn Cấp</option>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Mô Tả Vấn Đề</label>
                            <textarea class="form-control" name="description" id="editDescription" rows="5" required></textarea>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                        <button type="submit" class="btn btn-warning">Lưu Thay Đổi</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        let currentToastTimeout = null;

        function showToast(message, type) {
            const container = document.getElementById('toastContainer');
            if (currentToastTimeout) {
                clearTimeout(currentToastTimeout);
            }
            
            let iconClass = 'fa-check-circle';
            if (type === 'error') iconClass = 'fa-exclamation-circle';
            if (type === 'info') iconClass = 'fa-info-circle';
            
            const toastDiv = document.createElement('div');
            toastDiv.className = 'toast-notification ' + type;
            
            const iconDiv = document.createElement('div');
            iconDiv.className = 'toast-icon ' + type;
            iconDiv.innerHTML = '<i class="fas ' + iconClass + '"></i>';
            
            const contentDiv = document.createElement('div');
            contentDiv.className = 'toast-content';
            contentDiv.textContent = message;
            
            const closeBtn = document.createElement('button');
            closeBtn.className = 'toast-close';
            closeBtn.type = 'button';
            closeBtn.innerHTML = '<i class="fas fa-times"></i>';
            closeBtn.onclick = hideToast;
            
            toastDiv.appendChild(iconDiv);
            toastDiv.appendChild(contentDiv);
            toastDiv.appendChild(closeBtn);
            
            container.innerHTML = '';
            container.appendChild(toastDiv);
            
            currentToastTimeout = setTimeout(hideToast, 5000);
        }

        function hideToast() {
            const container = document.getElementById('toastContainer');
            const toast = container.querySelector('.toast-notification');
            if (toast) {
                toast.classList.add('hiding');
                setTimeout(() => {
                    container.innerHTML = '';
                }, 400);
            }
            if (currentToastTimeout) {
                clearTimeout(currentToastTimeout);
                currentToastTimeout = null;
            }
        }

        function refreshPage() {
            window.location.href = "${pageContext.request.contextPath}/managerServiceRequest";
        }

        function viewRequest(id, contractId, equipmentId, description, requestDate, status, priorityLevel) {
            document.getElementById('viewRequestId').textContent = '#' + id;
            document.getElementById('viewContractId').textContent = contractId;
            document.getElementById('viewEquipmentId').textContent = equipmentId;
            document.getElementById('viewDescription').textContent = description;
            document.getElementById('viewRequestDate').textContent = requestDate;

            const statusBadge = document.getElementById('viewStatus');
            const statusMap = {
                'Pending': { className: 'badge-pending', text: 'Chờ Xử Lý' },
                'Approved': { className: 'badge-inprogress', text: 'Đã Duyệt' },
                'Completed': { className: 'badge-completed', text: 'Hoàn Thành' },
                'Rejected': { className: 'badge-cancelled', text: 'Bị từ chối' },
                'Cancelled': { className: 'badge-cancelled', text: 'Đã Hủy' }
            };
            const statusInfo = statusMap[status] || { className: 'bg-secondary', text: status };
            statusBadge.className = 'badge ' + statusInfo.className;
            statusBadge.textContent = statusInfo.text;

            const priorityBadge = document.getElementById('viewPriority');
            const priorityMap = {
                'Normal': { className: 'bg-secondary', text: 'Bình Thường' },
                'High': { className: 'bg-warning text-dark', text: 'Cao' },
                'Urgent': { className: 'bg-danger', text: 'Khẩn Cấp' }
            };
            const priorityInfo = priorityMap[priorityLevel] || { className: 'bg-dark', text: priorityLevel };
            priorityBadge.className = 'badge ' + priorityInfo.className;
            priorityBadge.textContent = priorityInfo.text;

            new bootstrap.Modal(document.getElementById('viewModal')).show();
        }

        function editRequest(id, description, priorityLevel) {
            document.getElementById('editRequestId').value = id;
            document.getElementById('editDescription').value = description;
            document.getElementById('editPriorityLevel').value = priorityLevel;
            new bootstrap.Modal(document.getElementById('editModal')).show();
        }

        function confirmCancel(id) {
            document.getElementById('cancelRequestId').value = id;
            document.getElementById('cancelRequestIdDisplay').textContent = '#' + id;
            new bootstrap.Modal(document.getElementById('cancelModal')).show();
        }
        
        window.addEventListener('DOMContentLoaded', function () {
            document.querySelectorAll('.btn-view').forEach(button => {
                button.addEventListener('click', function () {
                    const data = this.dataset;
                    viewRequest(
                        data.id, 
                        data.contractId, 
                        data.equipmentId, 
                        data.description, 
                        data.requestDate, 
                        data.status, 
                        data.priority
                    );
                });
            });

            document.querySelectorAll('.btn-edit').forEach(button => {
                button.addEventListener('click', function () {
                    const data = this.dataset;
                    editRequest(data.id, data.description, data.priority);
                });
            });

            document.querySelectorAll('.btn-cancel').forEach(button => {
                button.addEventListener('click', function () {
                    confirmCancel(this.dataset.id);
                });
            });
        });
    </script>
</body>
</html>