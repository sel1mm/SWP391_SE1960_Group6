<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Yêu cầu - Support Staff</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .status-badge {
            font-size: 0.8rem;
            padding: 0.25rem 0.5rem;
        }
        .priority-high { color: #dc3545; font-weight: bold; }
        .priority-medium { color: #fd7e14; font-weight: bold; }
        .priority-low { color: #198754; font-weight: bold; }
        .card-stats {
            border-left: 4px solid #007bff;
        }
        .card-stats.pending { border-left-color: #ffc107; }
        .card-stats.awaiting { border-left-color: #17a2b8; }
        .card-stats.approved { border-left-color: #28a745; }
        .card-stats.rejected { border-left-color: #dc3545; }
        .table-responsive {
            max-height: 600px;
            overflow-y: auto;
        }
        .btn-forward {
            background-color: #17a2b8;
            border-color: #17a2b8;
            color: white;
        }
        .btn-forward:hover {
            background-color: #138496;
            border-color: #117a8b;
            color: white;
        }
    </style>
</head>
<body>
    <div class="container-fluid">
        <!-- Header -->
        <div class="row mb-4">
            <div class="col-12">
                <div class="d-flex justify-content-between align-items-center">
                    <h2><i class="fas fa-tasks"></i> Quản lý Yêu cầu Dịch vụ</h2>
                    <div>
                        <a href="dashboard.jsp" class="btn btn-outline-secondary">
                            <i class="fas fa-home"></i> Trang chủ
                        </a>
                        <a href="logout" class="btn btn-outline-danger">
                            <i class="fas fa-sign-out-alt"></i> Đăng xuất
                        </a>
                    </div>
                </div>
            </div>
        </div>

        <!-- Alert Messages -->
        <c:if test="${not empty sessionScope.success}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="fas fa-check-circle"></i> ${sessionScope.success}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <c:remove var="success" scope="session"/>
        </c:if>

        <c:if test="${not empty sessionScope.error}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fas fa-exclamation-circle"></i> ${sessionScope.error}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <c:remove var="error" scope="session"/>
        </c:if>

        <!-- Statistics Cards -->
        <div class="row mb-4">
            <div class="col-md-3">
                <div class="card card-stats pending">
                    <div class="card-body">
                        <div class="d-flex justify-content-between">
                            <div>
                                <h5 class="card-title text-muted">Chờ xử lý</h5>
                                <h3 class="text-warning">${pendingCount}</h3>
                            </div>
                            <div class="align-self-center">
                                <i class="fas fa-clock fa-2x text-warning"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card card-stats awaiting">
                    <div class="card-body">
                        <div class="d-flex justify-content-between">
                            <div>
                                <h5 class="card-title text-muted">Chờ duyệt</h5>
                                <h3 class="text-info">${awaitingApprovalCount}</h3>
                            </div>
                            <div class="align-self-center">
                                <i class="fas fa-hourglass-half fa-2x text-info"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card card-stats approved">
                    <div class="card-body">
                        <div class="d-flex justify-content-between">
                            <div>
                                <h5 class="card-title text-muted">Đã duyệt</h5>
                                <h3 class="text-success">${approvedCount}</h3>
                            </div>
                            <div class="align-self-center">
                                <i class="fas fa-check-circle fa-2x text-success"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card card-stats rejected">
                    <div class="card-body">
                        <div class="d-flex justify-content-between">
                            <div>
                                <h5 class="card-title text-muted">Từ chối</h5>
                                <h3 class="text-danger">${rejectedCount}</h3>
                            </div>
                            <div class="align-self-center">
                                <i class="fas fa-times-circle fa-2x text-danger"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Search and Filter -->
        <div class="row mb-3">
            <div class="col-md-6">
                <form method="get" action="supportStaffRequests" class="d-flex">
                    <input type="hidden" name="action" value="search">
                    <input type="text" class="form-control me-2" name="keyword" 
                           placeholder="Tìm kiếm theo mô tả, ID yêu cầu..." 
                           value="${keyword}">
                    <button type="submit" class="btn btn-outline-primary">
                        <i class="fas fa-search"></i> Tìm kiếm
                    </button>
                </form>
            </div>
            <div class="col-md-6">
                <form method="get" action="supportStaffRequests" class="d-flex">
                    <input type="hidden" name="action" value="filter">
                    <select name="priority" class="form-select me-2">
                        <option value="">Tất cả mức độ ưu tiên</option>
                        <option value="High" ${filterPriority == 'High' ? 'selected' : ''}>Cao</option>
                        <option value="Medium" ${filterPriority == 'Medium' ? 'selected' : ''}>Trung bình</option>
                        <option value="Low" ${filterPriority == 'Low' ? 'selected' : ''}>Thấp</option>
                    </select>
                    <button type="submit" class="btn btn-outline-secondary">
                        <i class="fas fa-filter"></i> Lọc
                    </button>
                </form>
            </div>
        </div>

        <!-- Clear Filters -->
        <c:if test="${searchMode || filterMode}">
            <div class="row mb-3">
                <div class="col-12">
                    <a href="supportStaffRequests" class="btn btn-sm btn-outline-secondary">
                        <i class="fas fa-times"></i> Xóa bộ lọc
                    </a>
                </div>
            </div>
        </c:if>

        <!-- Service Requests Table -->
        <div class="card">
            <div class="card-header">
                <h5 class="mb-0">
                    <i class="fas fa-list"></i> Danh sách Yêu cầu Chờ xử lý
                    <span class="badge bg-warning ms-2">${requests.size()}</span>
                </h5>
            </div>
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover mb-0">
                        <thead class="table-light">
                            <tr>
                                <th>ID</th>
                                <th>Khách hàng</th>
                                <th>Thiết bị</th>
                                <th>Mô tả</th>
                                <th>Mức độ</th>
                                <th>Loại</th>
                                <th>Ngày tạo</th>
                                <th>Trạng thái</th>
                                <th>Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty requests}">
                                    <tr>
                                        <td colspan="9" class="text-center py-4">
                                            <i class="fas fa-inbox fa-3x text-muted mb-3"></i>
                                            <p class="text-muted">Không có yêu cầu nào đang chờ xử lý</p>
                                        </td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="request" items="${requests}">
                                        <tr>
                                            <td><strong>#${request.requestId}</strong></td>
                                            <td>${request.customerName}</td>
                                            <td>${request.equipmentName}</td>
                                            <td>
                                                <div style="max-width: 200px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" 
                                                     title="${request.description}">
                                                    ${request.description}
                                                </div>
                                            </td>
                                            <td>
                                                <span class="priority-${request.priorityLevel.toLowerCase()}">
                                                    <c:choose>
                                                        <c:when test="${request.priorityLevel == 'High'}">Cao</c:when>
                                                        <c:when test="${request.priorityLevel == 'Medium'}">Trung bình</c:when>
                                                        <c:when test="${request.priorityLevel == 'Low'}">Thấp</c:when>
                                                        <c:otherwise>${request.priorityLevel}</c:otherwise>
                                                    </c:choose>
                                                </span>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${request.requestType == 'Service'}">Dịch vụ</c:when>
                                                    <c:when test="${request.requestType == 'Warranty'}">Bảo hành</c:when>
                                                    <c:when test="${request.requestType == 'InformationUpdate'}">Cập nhật thông tin</c:when>
                                                    <c:otherwise>${request.requestType}</c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <fmt:formatDate value="${request.requestDate}" pattern="dd/MM/yyyy HH:mm"/>
                                            </td>
                                            <td>
                                                <span class="badge bg-warning status-badge">Chờ xử lý</span>
                                            </td>
                                            <td>
                                                <button type="button" class="btn btn-sm btn-forward" 
                                                        data-bs-toggle="modal" 
                                                        data-bs-target="#forwardModal"
                                                        data-request-id="${request.requestId}"
                                                        data-request-desc="${request.description}">
                                                    <i class="fas fa-share"></i> Chuyển tiếp
                                                </button>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- Forward Modal -->
    <div class="modal fade" id="forwardModal" tabindex="-1" aria-labelledby="forwardModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="forwardModalLabel">
                        <i class="fas fa-share"></i> Chuyển tiếp Yêu cầu
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <form method="post" action="supportStaffRequests">
                    <div class="modal-body">
                        <input type="hidden" name="action" value="forward">
                        <input type="hidden" name="requestId" id="modalRequestId">
                        
                        <div class="mb-3">
                            <label class="form-label"><strong>Yêu cầu:</strong></label>
                            <p id="modalRequestDesc" class="text-muted"></p>
                        </div>
                        
                        <div class="mb-3">
                            <label for="technicianId" class="form-label">
                                <i class="fas fa-user-cog"></i> Chọn Kỹ thuật viên <span class="text-danger">*</span>
                            </label>
                            <select name="technicianId" id="technicianId" class="form-select" required>
                                <option value="">-- Chọn kỹ thuật viên --</option>
                                <c:forEach var="technician" items="${technicians}">
                                    <option value="${technician.accountId}">
                                        ${technician.fullName} (${technician.email})
                                    </option>
                                </c:forEach>
                            </select>
                            <div class="form-text">
                                Yêu cầu sẽ được chuyển sang trạng thái "Chờ duyệt" và gán cho kỹ thuật viên được chọn.
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                            <i class="fas fa-times"></i> Hủy
                        </button>
                        <button type="submit" class="btn btn-forward">
                            <i class="fas fa-share"></i> Chuyển tiếp
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Handle forward modal
        document.addEventListener('DOMContentLoaded', function() {
            const forwardModal = document.getElementById('forwardModal');
            
            forwardModal.addEventListener('show.bs.modal', function(event) {
                const button = event.relatedTarget;
                const requestId = button.getAttribute('data-request-id');
                const requestDesc = button.getAttribute('data-request-desc');
                
                document.getElementById('modalRequestId').value = requestId;
                document.getElementById('modalRequestDesc').textContent = requestDesc;
                
                // Reset technician selection
                document.getElementById('technicianId').value = '';
            });
        });
    </script>
</body>
</html>