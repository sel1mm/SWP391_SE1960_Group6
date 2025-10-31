<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
    <title>Danh Sách Yêu Cầu Khách Hàng</title>
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
        
        .error-message {
            display: none;
            color: red;
            font-size: 0.9em;
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
            <!-- Header + Button -->
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h2><i class="fas fa-list text-dark"></i> Danh Sách Yêu Cầu Khách Hàng</h2>
                <div class="d-flex align-items-center gap-3">
                    <button class="btn btn-dark" data-bs-toggle="modal" data-bs-target="#createRequestModal">
                        <i class="fas fa-plus-circle me-2"></i> Tạo Yêu Cầu Mới
                    </button>
                    <span>Xin chào, <strong>${sessionScope.session_login.username}</strong></span>
                </div>
            </div>

           <!-- Search & Filter -->
<div class="card mb-4">
  <div class="card-body">
    <form action="viewCustomerRequest" method="GET">
      <input type="hidden" name="action" value="search"/>

      <!-- Hàng 1: Search + Dropdowns -->
      <div class="row g-3 mb-2">
        <div class="col-md-4">
          <label class="form-label fw-bold">Tìm kiếm</label>
          <input type="text" class="form-control" name="keyword"
                 placeholder="Tên KH, điện thoại, mã hợp đồng, serial thiết bị..."
                 value="${param.keyword}">
        </div>

        <div class="col-md-2">
          <label class="form-label fw-bold">Trạng thái</label>
          <select name="status" class="form-select">
            <option value="">Tất cả</option>
            <option value="Pending" ${param.status == 'Pending' ? 'selected' : ''}>Pending</option>
            <option value="Awaiting Approval" ${param.status == 'Awaiting Approval' ? 'selected' : ''}>Awaiting Approval</option>
            <option value="Approved" ${param.status == 'Approved' ? 'selected' : ''}>Approved</option>
            <option value="Completed" ${param.status == 'Completed' ? 'selected' : ''}>Completed</option>
            <option value="Rejected" ${param.status == 'Rejected' ? 'selected' : ''}>Rejected</option>
            <option value="Cancelled" ${param.status == 'Cancelled' ? 'selected' : ''}>Cancelled</option>
          </select>
        </div>

        <div class="col-md-3">
          <label class="form-label fw-bold">Loại yêu cầu</label>
          <select name="requestType" class="form-select">
            <option value="">Tất cả</option>
            <option value="Service" ${param.requestType == 'Service' ? 'selected' : ''}>Service</option>
            <option value="Warranty" ${param.requestType == 'Warranty' ? 'selected' : ''}>Warranty</option>
            <option value="InformationUpdate" ${param.requestType == 'InformationUpdate' ? 'selected' : ''}>Information Update</option>
          </select>
        </div>

        <div class="col-md-3">
          <label class="form-label fw-bold">Mức độ ưu tiên</label>
          <select name="priorityLevel" class="form-select">
            <option value="">Tất cả</option>
            <option value="Normal" ${param.priorityLevel == 'Normal' ? 'selected' : ''}>Normal</option>
            <option value="High" ${param.priorityLevel == 'High' ? 'selected' : ''}>High</option>
            <option value="Urgent" ${param.priorityLevel == 'Urgent' ? 'selected' : ''}>Urgent</option>
          </select>
        </div>
      </div>

      <!-- Hàng 2: Date range -->
      <div class="row g-3 mb-2 align-items-end">
        <div class="col-md-3">
          <label class="form-label fw-bold">Từ ngày</label>
          <input type="date" class="form-control" name="fromDate" value="${param.fromDate}">
        </div>

        <div class="col-md-3">
          <label class="form-label fw-bold">Đến ngày</label>
          <input type="date" class="form-control" name="toDate" value="${param.toDate}">
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
          <a href="viewCustomerRequest" class="btn btn-outline-dark">
            <i class="fas fa-sync-alt me-1"></i> Làm mới
          </a>
        </div>
      </div>
    </form>
  </div>
</div>


            <!-- Request Table -->
            <div class="card">
                <div class="card-header">
                    <h5 class="mb-0"><i class="fas fa-clipboard-list"></i> Danh sách yêu cầu</h5>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover mb-0">
                            <thead class="table-light">
                            <tr>
                                <th>ID</th>
                                <th>Khách hàng</th>
                                <th>Thiết bị</th>
                                <th>Loại yêu cầu</th>
                                <th>Ưu tiên</th>
                                <th>Ngày tạo</th>
                                <th>Trạng thái</th>
                                <th>Thao tác</th>
                            </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="req" items="${requestList}">
                                    <tr 
                                        data-requestid="${req.requestId}"
                                        data-customer="${req.customerName}"
                                        data-customeremail="${req.customerEmail}"
                                        data-customerphone="${req.customerPhone}"
                                        data-contracttype="${req.contractType}"
                                        data-contractstatus="${req.contractStatus}"
                                        data-equipmentmodel="${req.equipmentModel}"
                                        data-equipmentdesc="${req.equipmentDescription}"
                                        data-serialnumber="${req.serialNumber}"
                                        data-priority="${req.priorityLevel}"
                                        data-status="${req.status}"
                                        data-requesttype="${req.requestType}"
                                        data-date="${req.requestDate}"
                                        data-description="${req.description}">

                                        <td><strong>#${req.requestId}</strong></td>
                                        <td>${req.customerName}</td>
                                        <td>${req.equipmentModel}</td>
                                        <td><span class="badge bg-info text-dark">${req.requestType}</span></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${req.priorityLevel eq 'Urgent'}">
                                                    <span class="badge bg-danger">Urgent</span>
                                                </c:when>
                                                <c:when test="${req.priorityLevel eq 'High'}">
                                                    <span class="badge bg-warning text-dark">High</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-secondary">Normal</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>${req.requestDate}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${req.status eq 'Pending'}">
                                                    <span class="badge bg-warning text-dark">Pending</span>
                                                </c:when>
                                                <c:when test="${req.status eq 'Approved'}">
                                                    <span class="badge bg-success">Approved</span>
                                                </c:when>
                                                <c:when test="${req.status eq 'Completed'}">
                                                    <span class="badge bg-primary">Completed</span>
                                                </c:when>
                                                <c:when test="${req.status eq 'Rejected'}">
                                                    <span class="badge bg-danger">Rejected</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-secondary">${req.status}</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <div class="btn-group">
                                                <!-- Nếu trạng thái là Completed, Canceled hoặc Rejected -->
                                                <c:if test="${req.status eq 'Completed' or req.status eq 'Canceled' or req.status eq 'Rejected'}">
                                                    <button class="btn btn-sm btn-outline-dark" title="Xem chi tiết"
                                                            onclick="viewDetails('${req.requestId}')">
                                                        <i class="fas fa-eye"></i>
                                                    </button>
                                                </c:if>

                                                <!-- Ngược lại, hiển thị theo loại yêu cầu -->
                                                <c:if test="${req.status ne 'Completed' and req.status ne 'Canceled' and req.status ne 'Rejected'}">
                                                    <!-- Nếu loại yêu cầu là Service hoặc Warranty -->
                                                    <c:if test="${req.requestType eq 'Service' or req.requestType eq 'Warranty'}">
                                                        <!-- Luôn có nút xem chi tiết -->
                                                        <button class="btn btn-sm btn-outline-dark" title="Xem chi tiết"
                                                                onclick="viewDetails('${req.requestId}')">
                                                            <i class="fas fa-eye"></i>
                                                        </button>

                                                        <!-- Nếu trạng thái là Pending thì có thêm nút Chuyển tiếp -->
                                                        <c:if test="${req.status eq 'Pending'}">
                                                            <button class="btn btn-sm btn-outline-primary" title="Chuyển tiếp"
                                                                    onclick="forwardRequest('${req.requestId}')">
                                                                <i class="fas fa-share"></i>
                                                            </button>
                                                        </c:if>
                                                    </c:if>

                                                    <!-- Nếu loại yêu cầu là InformationUpdate -->
                                                    <c:if test="${req.requestType eq 'InformationUpdate'}">
                                                        <!-- Luôn có nút xem chi tiết -->
                                                        <button class="btn btn-sm btn-outline-dark" title="Xem chi tiết"
                                                                onclick="viewDetails('${req.requestId}')">
                                                            <i class="fas fa-eye"></i>
                                                        </button>

                                                        <!-- Nút sửa thông tin khách hàng -->
                                                        <button class="btn btn-sm btn-outline-success" title="Sửa thông tin khách hàng"
                                                                onclick="editCustomerInfo('${req.requestId}')">
                                                            <i class="fas fa-edit"></i>
                                                        </button>

                                                        <!-- Nút hủy yêu cầu -->
                                                        <button class="btn btn-sm btn-outline-danger" title="Hủy yêu cầu"
                                                                onclick="cancelRequest('${req.requestId}')">
                                                            <i class="fas fa-times"></i>
                                                        </button>
                                                    </c:if>
                                                </c:if>

                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>


                            <c:if test="${empty requestList}">
                                <tr>
                                    <td colspan="8" class="text-center py-4">
                                        <i class="fas fa-clipboard fa-3x text-muted mb-3"></i>
                                        <h5 class="text-muted">Không có yêu cầu nào</h5>
                                        <p class="text-muted">Khách hàng chưa gửi yêu cầu dịch vụ nào.</p>
                                    </td>
                                </tr>
                            </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Pagination -->
                <c:if test="${totalPages >= 1}">
    <!-- ✅ Giữ lại toàn bộ filter khi chuyển trang -->
    <c:url var="baseUrl" value="viewCustomerRequest">
        <c:param name="keyword" value="${paramKeyword}" />
        <c:param name="status" value="${paramStatus}" />
        <c:param name="requestType" value="${paramRequestType}" />
        <c:param name="priorityLevel" value="${paramPriority}" />
        <c:param name="fromDate" value="${paramFromDate}" />
        <c:param name="toDate" value="${paramToDate}" />
    </c:url>

    <nav aria-label="Page navigation" class="mt-4">
        <ul class="pagination justify-content-center">
            <!-- Nút Trước -->
            <li class="page-item ${currentPageNumber <= 1 ? 'disabled' : ''}">
                <a class="page-link" href="${baseUrl}&page=${currentPageNumber - 1}">
                    <i class="fas fa-chevron-left"></i> Trước
                </a>
            </li>

            <!-- Danh sách trang -->
            <c:forEach var="i" begin="1" end="${totalPages}">
                <li class="page-item ${i == currentPageNumber ? 'active' : ''}">
                    <a class="page-link" href="${baseUrl}&page=${i}">${i}</a>
                </li>
            </c:forEach>

            <!-- Nút Tiếp -->
            <li class="page-item ${currentPageNumber >= totalPages ? 'disabled' : ''}">
                <a class="page-link" href="${baseUrl}&page=${currentPageNumber + 1}">
                    Tiếp <i class="fas fa-chevron-right"></i>
                </a>
            </li>
        </ul>
    </nav>

    <!-- Thông tin trang -->
    <div class="text-center text-muted mb-3">
        <small>
            Trang <strong>${currentPageNumber}</strong> / <strong>${totalPages}</strong> |
            Hiển thị <strong>${fn:length(requestList)}</strong> yêu cầu
        </small>
    </div>
</c:if>

            </div>
        </div>
    </div>
</div>

<!-- Modal: Create Service Request -->
<div class="modal fade" id="createRequestModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <form method="post" id="createRequestForm" action="createServiceRequest">
            <div class="modal-content">
                <div class="modal-header bg-dark text-white">
                    <h5 class="modal-title"><i class="fas fa-plus-circle me-2"></i> Tạo Yêu Cầu Dịch Vụ</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>

                <div class="modal-body">
                    <h6 class="fw-bold mb-3">Thông tin khách hàng</h6>
                    <div class="mb-3">
                        <label>Khách hàng <span class="text-danger">*</span></label>
                        <select name="customerId" id="customerSelect" class="form-select" required>
                            <option value="">-- Chọn khách hàng --</option>
                            <c:forEach var="c" items="${customerList}">
                                <option value="${c.accountId}">${c.fullName} (${c.email})</option>
                            </c:forEach>
                        </select>
                    </div>

                    <h6 class="fw-bold mb-3">Thiết bị liên quan</h6>
                    <div class="mb-3">
                        <label>Thiết bị <span class="text-danger">*</span></label>
                        <!-- Dropdown multiple -->
                        <div class="dropdown w-100">
                            <button class="btn btn-outline-dark dropdown-toggle w-100 text-start" 
                                    type="button" 
                                    id="equipmentDropdown" 
                                    data-bs-toggle="dropdown" 
                                    data-bs-auto-close="outside"
                                    aria-expanded="false">
                                <i class="fas fa-list"></i> -- Chọn thiết bị --
                            </button>
                            <ul class="dropdown-menu w-100 p-2" 
                                id="equipmentDropdownList"
                                style="max-height: 300px; overflow-y: auto;">
                                <!-- Thiết bị sẽ được đổ bằng JS -->
                            </ul>
                        </div>

                        <!-- ✅ Phần hiển thị thiết bị đã chọn -->
                        <div id="selectedEquipmentDisplay" class="mt-3"></div>

                        <input type="hidden" name="equipmentIds" id="equipmentIds">
                        <small class="form-text text-muted">
                            <i class="fas fa-info-circle"></i> Bạn có thể chọn nhiều thiết bị cùng lúc
                        </small>
                    </div>

                    <h6 class="fw-bold mb-3">Loại yêu cầu</h6>
                    <div class="mb-3">
                        <select name="requestType" class="form-select" required>
                            <option value="Service">Service</option>
                            <option value="Warranty">Warranty</option>
                        </select>
                    </div>

                    <h6 class="fw-bold mb-3">Mức độ ưu tiên</h6>
                    <div class="mb-3">
                        <select name="priorityLevel" class="form-select" required>
                            <option value="Normal">Normal</option>
                            <option value="High">High</option>
                            <option value="Urgent">Urgent</option>
                        </select>
                    </div>

                    <h6 class="fw-bold mb-3">Mô tả yêu cầu</h6>
                    <div class="mb-3">
                        <textarea name="description" class="form-control" rows="3" maxlength="1000"
                                  placeholder="Mô tả chi tiết vấn đề khách hàng gặp phải..." required></textarea>
                    </div>
                </div>

                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                    <button type="submit" class="btn btn-dark">
                        <i class="fas fa-save me-2"></i> Lưu Yêu Cầu
                    </button>
                </div>
            </div>
        </form>
    </div>
</div>

<!-- Modal: View Service Request Details -->
<div class="modal fade" id="viewRequestModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header bg-dark text-white">
                <h5 class="modal-title">
                    <i class="fas fa-eye me-2"></i> Chi Tiết Yêu Cầu Dịch Vụ
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>

            <div class="modal-body">
                <table class="table table-bordered">
                    <tr><th style="width:30%">Mã yêu cầu</th><td id="detail-requestId"></td></tr>
                    <tr><th>Khách hàng</th><td id="detail-customer"></td></tr>
                    <tr><th>Email khách hàng</th><td id="detail-customerEmail"></td></tr>
                    <tr><th>Số điện thoại</th><td id="detail-customerPhone"></td></tr>
                    <tr><th>Loại yêu cầu</th><td id="detail-requestType"></td></tr>
                    <tr><th>Mức độ ưu tiên</th><td id="detail-priority"></td></tr>
                    <tr><th>Trạng thái</th><td id="detail-status"></td></tr>
                    <tr><th>Ngày tạo</th><td id="detail-date"></td></tr>

                    <!-- Các dòng liên quan đến hợp đồng và thiết bị (sẽ bị ẩn nếu là InformationUpdate) -->
                    <tr class="info-only"><th>Loại hợp đồng</th><td id="detail-contractType"></td></tr>
                    <tr class="info-only"><th>Trạng thái hợp đồng</th><td id="detail-contractStatus"></td></tr>
                    <tr class="info-only"><th>Thiết bị</th><td id="detail-equipmentModel"></td></tr>
                    <tr class="info-only"><th>Serial Number</th><td id="detail-serialNumber"></td></tr>
                    <tr class="info-only"><th>Mô tả thiết bị</th><td id="detail-equipmentDesc"></td></tr>

                    <tr><th>Mô tả yêu cầu</th><td id="detail-description"></td></tr>
                </table>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
            </div>
        </div>
    </div>
</div>

<!-- Modal Sửa -->
<div class="modal fade" id="editUserModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <form id="editUserForm" method="post" action="viewCustomerRequest">
            <input type="hidden" name="action" value="edit"/>
            <input type="hidden" name="id" id="editId"/>
            <input type="hidden" name="requestId" id="editRequestId"/>

            <div class="modal-content">
                <div class="modal-header bg-dark text-white">
                    <h5 class="modal-title">Sửa Thông Tin Người Dùng</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>

                <div class="modal-body">
                    <!-- STEP 1 -->
                    <div id="step1">
                        <h6 class="fw-bold mb-3">Thông tin tài khoản</h6>

                        <div class="mb-3">
                            <label>Tên đăng nhập</label>
                            <input type="text" id="editUsername" name="username" class="form-control" readonly>
                        </div>

                        <div class="mb-3">
                            <label>Họ và tên <span class="text-danger">*</span></label>
                            <input type="text" id="editFullName" name="fullName" class="form-control" required maxlength="50"
                                   pattern="^[A-Za-zÀ-ỹ\s]{2,50}$"
                                   title="Chỉ gồm chữ cái và khoảng trắng (2–50 ký tự).">
                            <div id="editFullNameError" class="error-message">Họ tên không hợp lệ</div>
                        </div>

                        <div class="mb-3">
                            <label>Email <span class="text-danger">*</span></label>
                            <input type="email" id="editEmail" name="email" class="form-control" required maxlength="100"
                                   pattern="[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
                                   title="Email không hợp lệ. Ví dụ: example@gmail.com">
                            <div id="editEmailError" class="error-message">Email không hợp lệ</div>
                        </div>

                        <div class="mb-3">
                            <label>Số điện thoại <span class="text-danger">*</span></label>
                            <input type="tel" id="editPhone" name="phone" class="form-control" required maxlength="10"
                                   pattern="(03|05|07|08|09)[0-9]{8}"
                                   title="Phải bắt đầu bằng 03, 05, 07, 08, 09 và có 10 chữ số.">
                            <div id="editPhoneError" class="error-message">Số điện thoại không hợp lệ</div>
                        </div>

                        <div class="mb-3">
                            <label>Trạng thái <span class="text-danger">*</span></label>
                            <select id="editStatus" name="status" class="form-select" required
                                    title="Vui lòng chọn trạng thái hoạt động.">
                                <option value="Active">Active</option>
                                <option value="Inactive">Inactive</option>
                            </select>
                        </div>

                        <div class="mb-3">
                            <label>Mật khẩu mới</label>
                            <input type="password" id="editPassword" name="password" class="form-control"
                                   minlength="6" maxlength="30"
                                   pattern="^(?=.*[A-Za-z0-9])[A-Za-z0-9!@#$%^&*()_+=-]{6,30}$"
                                   title="Mật khẩu 6–30 ký tự, không chứa khoảng trắng.">
                            <div id="editPasswordError" class="error-message">Mật khẩu không hợp lệ</div>
                            <small class="text-muted">Để trống nếu không muốn thay đổi</small>
                        </div>

                        <!-- Confirm password (ẩn mặc định) -->
                        <div class="mb-3 d-none" id="editConfirmPasswordGroup">
                            <label>Xác nhận mật khẩu mới</label>
                            <input type="password" id="editConfirmPassword" class="form-control" minlength="6" maxlength="30">
                            <div id="editConfirmPasswordError" class="error-message">Mật khẩu không trùng khớp</div>
                        </div>


                    </div>

                    <!-- STEP 2 -->
                    <div id="step2" class="d-none">
                        <h6 class="fw-bold mb-3">Thông tin hồ sơ</h6>

                        <div class="mb-3">
                            <label>Địa chỉ</label>
                            <input type="text" id="editAddress" name="address" class="form-control" maxlength="100">
                        </div>

                        <div class="mb-3">
                            <label>Ngày sinh</label>
                            <input type="date" id="editDateOfBirth" name="dateOfBirth" class="form-control"
                                   max="9999-12-31"
                                   title="Ngày sinh không được ở tương lai.">
                            <div id="editDobError" class="error-message">Ngày sinh không hợp lệ</div>
                        </div>

                        <div class="mb-3">
                            <label>Ảnh đại diện (URL)</label>
                            <input type="url" id="editAvatarUrl" name="avatarUrl" class="form-control"
                                   maxlength="200"
                                   pattern="^(https?:\/\/.*\.(?:png|jpg|jpeg|gif|webp|svg))$"
                                   title="URL ảnh phải bắt đầu bằng http hoặc https và kết thúc bằng đuôi ảnh (.jpg, .png, .gif, v.v.)">
                            <div id="editAvatarError" class="error-message">URL ảnh đại diện không hợp lệ</div>
                        </div>

                        <div class="mb-3">
                            <label>CCCD/CMND</label>
                            <input type="text" id="editNationalId" name="nationalId" class="form-control"
                                   minlength="9" maxlength="12"
                                   pattern="^[0-9]{9,12}$"
                                   title="CCCD/CMND chỉ gồm số, dài từ 9–12 ký tự.">
                            <div id="editNationalIdError" class="error-message">CCCD/CMND không hợp lệ</div>
                        </div>

                        <div class="mb-3">
                            <label>Xác thực tài khoản <span class="text-danger">*</span></label>
                            <select id="editVerified" name="verified" class="form-select" required
                                    title="Vui lòng chọn trạng thái xác thực.">
                                <option value="">-- Chọn trạng thái --</option>
                                <option value="0">Chưa xác thực</option>
                                <option value="1">Đã xác thực</option>
                            </select>
                        </div>

                        <div class="mb-3">
                            <label>Ghi chú thêm</label>
                            <textarea id="editExtraData" name="extraData" class="form-control" rows="2" maxlength="100"></textarea>
                        </div>
                    </div>
                </div>

                <div class="modal-footer d-flex justify-content-between">
                    <button type="button" id="prevStep" class="btn btn-secondary d-none">← Quay lại</button>
                    <button type="button" id="nextStep" class="btn btn-dark">Tiếp →</button>
                    <button type="submit" id="submitBtn" class="btn btn-dark d-none">Cập nhật</button>
                </div>
            </div>
        </form>
    </div>
</div>




<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script>
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

function viewDetails(id) {
    console.log("ID nhận được:", id);
    const row = document.querySelector("tr[data-requestid='" + id + "']");
    if (!row) {
        console.warn("Không tìm thấy row có data-requestid=", id);
        return;
    }

    const get = name => row.dataset[name] || "(Không có thông tin)";
    const type = get("requesttype");

    // Gán dữ liệu
    document.getElementById("detail-requestId").innerText = "#" + id;
    document.getElementById("detail-customer").innerText = get("customer");
    document.getElementById("detail-customerEmail").innerText = get("customeremail");
    document.getElementById("detail-customerPhone").innerText = get("customerphone");
    document.getElementById("detail-requestType").innerText = type;
    document.getElementById("detail-priority").innerText = get("priority");
    document.getElementById("detail-status").innerText = get("status");
    document.getElementById("detail-date").innerText = get("date");
    document.getElementById("detail-contractType").innerText = get("contracttype");
    document.getElementById("detail-contractStatus").innerText = get("contractstatus");
    document.getElementById("detail-equipmentModel").innerText = get("equipmentmodel");
    document.getElementById("detail-serialNumber").innerText = get("serialnumber");
    document.getElementById("detail-equipmentDesc").innerText = get("equipmentdesc");
    document.getElementById("detail-description").innerText = get("description");

    // Ẩn/hiện các dòng liên quan đến hợp đồng & thiết bị
    document.querySelectorAll(".info-only").forEach(rowEl => {
        if (type === "InformationUpdate") {
            rowEl.style.display = "none";
        } else {
            rowEl.style.display = "";
        }
    });

    // Hiển thị modal
    new bootstrap.Modal(document.getElementById("viewRequestModal")).show();
}


function forwardRequest(id) {
    Swal.fire({
        title: 'Chuyển tiếp yêu cầu?',
        text: 'Bạn có muốn chuyển yêu cầu này cho Tech Manager?',
        icon: 'question',
        showCancelButton: true,
        confirmButtonText: 'Chuyển tiếp',
        cancelButtonText: 'Hủy',
        confirmButtonColor: '#000'
    }).then(async (result) => {
        if (result.isConfirmed) {
            try {
                const res = await fetch(
    'updateRequestStatus?requestId=' + id + '&status=' + encodeURIComponent('Awaiting Approval'),
    { method: 'GET' }
);


                if (!res.ok) throw new Error(`HTTP ${res.status}`);

                Swal.fire({
                    icon: 'success',
                    title: 'Thành công!',
                    text: 'Yêu cầu đã được chuyển tiếp.',
                    confirmButtonColor: '#000'
                }).then(() => window.location.reload());

            } catch (err) {
                console.error('❌ Lỗi khi cập nhật trạng thái:', err);
                Swal.fire({
                    icon: 'error',
                    title: 'Thất bại!',
                    text: 'Không thể cập nhật trạng thái yêu cầu.',
                    confirmButtonColor: '#000'
                });
            }
        }
    });
}

function cancelRequest(id) {
    Swal.fire({
        title: 'Hủy yêu cầu?',
        text: `Bạn có chắc chắn muốn hủy yêu cầu #${id}?`,
        icon: 'warning',
        showCancelButton: true,
        confirmButtonText: 'Hủy yêu cầu',
        cancelButtonText: 'Quay lại',
        confirmButtonColor: '#d33'
    }).then(async (result) => {
        if (result.isConfirmed) {
            try {
                const res = await fetch(
    'updateRequestStatus?requestId=' + id + '&status=' + encodeURIComponent('Rejected'),
    { method: 'GET' }
);


                if (!res.ok) throw new Error(`HTTP ${res.status}`);

                Swal.fire({
                    icon: 'success',
                    title: 'Thành công!',
                    text: 'Yêu cầu đã bị hủy.',
                    confirmButtonColor: '#000'
                }).then(() => window.location.reload());

            } catch (err) {
                console.error('❌ Lỗi khi cập nhật trạng thái:', err);
                Swal.fire({
                    icon: 'error',
                    title: 'Thất bại!',
                    text: 'Không thể cập nhật trạng thái yêu cầu.',
                    confirmButtonColor: '#000'
                });
            }
        }
    });
}



async function editCustomerInfo(requestId) {
    console.log("🟩 RequestID nhận được:", requestId);

    const rows = document.querySelectorAll("tr[data-requestid]");
    let row = null;
    rows.forEach(r => {
        if (String(r.dataset.requestid).trim() === String(requestId).trim()) {
            row = r;
        }
    });

    if (!row) {
        Swal.fire({
            icon: 'error',
            title: 'Không tìm thấy yêu cầu',
            text: 'Không thể xác định thông tin khách hàng để sửa.',
            confirmButtonColor: '#000'
        });
        return;
    }

    const email = row.dataset.customeremail;
    console.log("📩 Email khách hàng:", email);

    try {
        const res = await fetch("customerManagement?action=getById&email=" + encodeURIComponent(email));
        if (!res.ok) throw new Error("Không thể tải thông tin khách hàng từ server");

        const data = await res.json();
        console.log("📦 Dữ liệu khách hàng trả về:", data);

        const account = data.account;
        const profile = data.profile || {};

        // ✅ Đổ dữ liệu account
        document.getElementById("editId").value = account.accountId;
        document.getElementById("editUsername").value = account.username;
        document.getElementById("editFullName").value = account.fullName;
        document.getElementById("editEmail").value = account.email;
        document.getElementById("editPhone").value = account.phone;
        document.getElementById("editStatus").value = account.status || "Active";
        document.getElementById("editPassword").value = "";
        document.getElementById("editConfirmPassword").value = "";
        document.getElementById("editConfirmPasswordGroup").classList.add("d-none");
        document.getElementById("editRequestId").value = requestId;

        // ✅ Đổ dữ liệu profile
        if (document.getElementById("editAddress"))
            document.getElementById("editAddress").value = profile.address || "";

        if (document.getElementById("editNationalId"))
            document.getElementById("editNationalId").value = profile.nationalId || "";

        if (document.getElementById("editDateOfBirth"))
            document.getElementById("editDateOfBirth").value = profile.dateOfBirth || "";

        if (document.getElementById("editVerified"))
            document.getElementById("editVerified").value = profile.verified ? "1" : "0";

        if (document.getElementById("editExtraData"))
            document.getElementById("editExtraData").value = profile.extraData || "";
        
        document.querySelectorAll("#editUserForm .error-message").forEach(el => el.style.display = "none");

        // ✅ Hiển thị modal
        const modal = new bootstrap.Modal(document.getElementById("editUserModal"));
        modal.show();

    } catch (err) {
        console.error("❌ Lỗi khi tải dữ liệu khách hàng:", err);
        Swal.fire({
            icon: 'error',
            title: 'Không thể tải dữ liệu',
            text: err.message,
            confirmButtonColor: '#000'
        });
    }
}


document.addEventListener("change", function (e) {
    if (e.target && e.target.id === "customerSelect") {
        const customerId = e.target.value;
        console.log("Selected customerId:", customerId);
        if (!customerId) return;

const ctx = window.location.pathname.split("/")[1]; 
const url = "/" + ctx + "/loadContractsAndEquipment?customerId=" + encodeURIComponent(customerId);
        console.log("🔗 Fetch URL:", url);

        fetch(url)
            .then(res => res.json())
            .then(data => {
                console.log("✅ Data thiết bị:", data);
                const dropdownList = document.getElementById("equipmentDropdownList");
                dropdownList.innerHTML = "";

                if (data.equipment && data.equipment.length > 0) {
                    data.equipment.forEach(eq => {
                        const li = document.createElement("li");
                        li.innerHTML =
                            '<div class="form-check px-3">' +
                                '<input class="form-check-input equipment-checkbox" ' +
                                       'type="checkbox" ' +
                                       'value="' + eq.equipmentId + '" ' +
                                       'id="equip-' + eq.equipmentId + '">' +
                                '<label class="form-check-label" for="equip-' + eq.equipmentId + '">' +
                                    eq.model + ' (' + eq.serialNumber + ')' +
                                '</label>' +
                            '</div>';
                        dropdownList.appendChild(li);
                    });
                     updateSelectedEquipment();
                } else {
                    dropdownList.innerHTML = "<li class='px-3 text-muted'>Không có thiết bị nào.</li>";
                }
            })
            .catch(err => console.error("❌ Lỗi load thiết bị:", err));
    }
});


// Lắng nghe khi chọn/bỏ chọn checkbox thiết bị
document.addEventListener("change", function (e) {
    if (e.target.classList.contains("equipment-checkbox")) {
        updateSelectedEquipment();
    }
});

// ✅ Hàm cập nhật hiển thị thiết bị đã chọn
function updateSelectedEquipment() {
    const checkboxes = document.querySelectorAll('.equipment-checkbox:checked');
    const display = document.getElementById('selectedEquipmentDisplay');
    const dropdownBtn = document.getElementById('equipmentDropdown');
    
    // Lấy danh sách ID đã chọn
    const selected = Array.from(checkboxes).map(cb => cb.value);
    document.getElementById('equipmentIds').value = selected.join(',');
    
    // Cập nhật text button dropdown
    if (selected.length > 0) {
        dropdownBtn.innerHTML = `<i class="fas fa-check-circle text-success"></i> Đã chọn ${selected.length} thiết bị`;
    } else {
        dropdownBtn.innerHTML = '<i class="fas fa-list"></i> -- Chọn thiết bị --';
    }
    
    // Hiển thị danh sách thiết bị đã chọn
    if (checkboxes.length === 0) {
        display.innerHTML = '';
        return;
    }
    
    let html = '<div class="alert alert-info mb-0">' +
               '<strong><i class="fas fa-tools"></i> Đã chọn ' + checkboxes.length + ' thiết bị:</strong>' +
               '<ul class="mb-0 mt-2 ps-3">';
    
    checkboxes.forEach(cb => {
        const label = document.querySelector('label[for="' + cb.id + '"]');
        if (label) {
            const equipmentText = label.textContent.trim();
            html += '<li>' + equipmentText + '</li>';
        }
    });
    
    html += '</ul></div>';
    display.innerHTML = html;
}

// ✅ Cập nhật listener khi chọn thiết bị
document.addEventListener("change", function (e) {
    if (e.target.classList.contains("equipment-checkbox")) {
        updateSelectedEquipment();
    }
});


// ✅ Khi mở modal, ẩn toàn bộ thông báo lỗi
document.addEventListener("DOMContentLoaded", function () {
    console.log("✅ DOM loaded, khởi tạo các listener validate...");

    const editForm = document.getElementById("editUserForm");
    const step1 = document.getElementById("step1");
    const step2 = document.getElementById("step2");
    const nextBtn = document.getElementById("nextStep");
    const prevBtn = document.getElementById("prevStep");
    const submitBtn = document.getElementById("submitBtn");

    /* ========== Ẩn/hiện confirm password ========== */
    const editPassword = document.getElementById("editPassword");
    const confirmGroup = document.getElementById("editConfirmPasswordGroup");
    if (editPassword) {
        editPassword.addEventListener("input", function () {
            if (this.value.trim() !== "") confirmGroup.classList.remove("d-none");
            else {
                confirmGroup.classList.add("d-none");
                document.getElementById("editConfirmPassword").value = "";
            }
        });
    }

    /* ========== Hàm kiểm tra mật khẩu khớp ========== */
    function checkEditPasswordMatch() {
        const pass = document.getElementById("editPassword").value.trim();
        const confirm = document.getElementById("editConfirmPassword").value.trim();
        const error = document.getElementById("editConfirmPasswordError");
        if (pass !== "" && pass !== confirm) {
            error.textContent = "Mật khẩu xác nhận không trùng khớp.";
            error.style.display = "block";
            return false;
        } else {
            error.style.display = "none";
            return true;
        }
    }

    /* ========== Validate Step 1 ========== */
    function validateStep1() {
    let valid = true;
    const fullName = document.getElementById("editFullName");
    const email = document.getElementById("editEmail");
    const phone = document.getElementById("editPhone");
    const password = document.getElementById("editPassword");
    const confirmPassword = document.getElementById("editConfirmPassword");

    const namePattern = /^[A-Za-zÀ-ỹ\s]{2,50}$/;
    const emailPattern = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
    const phonePattern = /^(03|05|07|08|09)[0-9]{8}$/;
    const passwordPattern = /^(?=.*[A-Za-z0-9])[A-Za-z0-9!@#$%^&*()_+=-]{6,30}$/;

    // Họ tên
    if (!namePattern.test(fullName.value.trim())) {
        document.getElementById("editFullNameError").style.display = "block";
        valid = false;
    } else document.getElementById("editFullNameError").style.display = "none";

    // Email
    if (!emailPattern.test(email.value.trim())) {
        document.getElementById("editEmailError").style.display = "block";
        valid = false;
    } else document.getElementById("editEmailError").style.display = "none";

    // Số điện thoại
    if (!phonePattern.test(phone.value.trim())) {
        document.getElementById("editPhoneError").style.display = "block";
        valid = false;
    } else document.getElementById("editPhoneError").style.display = "none";

    // Mật khẩu
    if (password.value.trim() !== "") {
        if (!passwordPattern.test(password.value.trim())) {
            document.getElementById("editPasswordError").textContent = "Mật khẩu không hợp lệ (6–30 ký tự, không chứa khoảng trắng)";
            document.getElementById("editPasswordError").style.display = "block";
            valid = false;
        } else {
            document.getElementById("editPasswordError").style.display = "none";
        }

        // Xác nhận mật khẩu
        if (!checkEditPasswordMatch()) valid = false;
    } else {
        document.getElementById("editPasswordError").style.display = "none";
        document.getElementById("editConfirmPasswordError").style.display = "none";
    }

    return valid;
}


    /* ========== Validate Step 2 ========== */
    function validateStep2() {
        let valid = true;
        const nationalId = document.getElementById("editNationalId").value.trim();
        const nationalIdPattern = /^[0-9]{9,12}$/;
        if (nationalId && !nationalIdPattern.test(nationalId)) {
            document.getElementById("editNationalIdError").style.display = "block";
            valid = false;
        } else document.getElementById("editNationalIdError").style.display = "none";
        return valid;
    }

    /* ========== Nút Tiếp → ========== */
    nextBtn.addEventListener("click", function () {
        if (validateStep1()) {
            step1.classList.add("d-none");
            step2.classList.remove("d-none");
            nextBtn.classList.add("d-none");
            prevBtn.classList.remove("d-none");
            submitBtn.classList.remove("d-none");
        } else {
            Swal.fire({
                icon: 'error',
                title: 'Thông tin chưa hợp lệ!',
                text: 'Vui lòng kiểm tra lại trước khi tiếp tục.',
                confirmButtonColor: '#000'
            });
        }
    });

    /* ========== Nút Quay lại ← ========== */
    prevBtn.addEventListener("click", function () {
        step2.classList.add("d-none");
        step1.classList.remove("d-none");
        nextBtn.classList.remove("d-none");
        prevBtn.classList.add("d-none");
        submitBtn.classList.add("d-none");
    });

    /* ========== Nút Gửi form ========== */
    editForm.addEventListener("submit", function (e) {
        if (!validateStep1() || !validateStep2()) {
            e.preventDefault();
            Swal.fire({
                icon: 'error',
                title: 'Thông tin chưa hợp lệ!',
                text: 'Vui lòng kiểm tra lại trước khi cập nhật!',
                confirmButtonColor: '#000'
            });
        }
    });
});

// Sau khi submit form thành công, cập nhật trạng thái request
document.getElementById("editUserForm").addEventListener("submit", async function (e) {
    e.preventDefault();
    const formData = new FormData(this);

    try {
        // ✅ Context path JSP sẽ render đúng (ví dụ: /MyCRMSystem)
        const res = await fetch(`${pageContext.request.contextPath}/viewCustomerRequest`, {
    method: "POST",
    body: formData
});


        if (!res.ok) throw new Error(`HTTP ${res.status}`);
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
    } catch (err) {
        console.error("❌ Lỗi khi gửi request:", err);
        Swal.fire({
            icon: "error",
            title: "Thất bại!",
            text: "Không thể gửi dữ liệu đến server!",
            confirmButtonColor: "#000"
        });
    }
});


document.addEventListener("DOMContentLoaded", () => {
    const form = document.getElementById("createRequestForm");

    form.addEventListener("submit", async function (e) {
        e.preventDefault(); // ❌ chặn form reload
        const formData = new FormData(this);

        try {
            // Gửi form qua servlet
            const res = await fetch("createServiceRequest", {
                method: "POST",
                body: formData
            });

            const result = await res.json();
            console.log("✅ Kết quả trả về:", result);

            if (result.success) {
                // ✅ Hiện thông báo thành công ngay
                Swal.fire({
                    icon: "success",
                    title: "Thành công!",
                    text: result.message,
                    confirmButtonColor: "#000"
                }).then(() => {
                    // Đóng modal + refresh list
                    const modal = bootstrap.Modal.getInstance(document.getElementById("createRequestModal"));
                    modal.hide();
                    window.location.reload();
                });
            } else {
                // ❌ Hiện thông báo lỗi
                Swal.fire({
                    icon: "error",
                    title: "Thất bại!",
                    text: result.message,
                    confirmButtonColor: "#000"
                });
            }

        } catch (err) {
            console.error("❌ Lỗi khi gửi yêu cầu:", err);
            Swal.fire({
                icon: "error",
                title: "Lỗi!",
                text: "Không thể gửi yêu cầu. Vui lòng thử lại.",
                confirmButtonColor: "#000"
            });
        }
    });
});

</script>
</body>
</html>
