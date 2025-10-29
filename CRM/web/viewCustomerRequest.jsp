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
                    <a class="nav-link" href="dashboard.jsp"><i class="fas fa-palette me-2"></i> Trang chủ</a>
                    <a class="nav-link" href="customerManagement"><i class="fas fa-users me-2"></i> Quản lý khách hàng</a>
                    <a class="nav-link fw-bold bg-white text-dark" href="viewCustomerRequest"><i class="fas fa-clipboard-list"></i> Quản lý yêu cầu</a>
                    <a class="nav-link" href="manageProfile"><i class="fas fa-user-circle me-2"></i> Hồ Sơ</a>
                </nav>
            </div>

            <div class="mt-auto logout-section text-center">
                <hr style="border-color: rgba(255,255,255,0.2);">
                <button class="btn btn-outline-light w-100" onclick="logout()">
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
                                                    <!-- Luôn có nút chi tiết -->
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
        <form method="post" action="createServiceRequest">
            <div class="modal-content">
                <div class="modal-header bg-dark text-white">
                    <h5 class="modal-title"><i class="fas fa-plus-circle me-2"></i> Tạo Yêu Cầu Dịch Vụ</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>

                <div class="modal-body">
                    <h6 class="fw-bold mb-3">1️⃣ Thông tin khách hàng</h6>
                    <div class="mb-3">
                        <label>Khách hàng <span class="text-danger">*</span></label>
                        <select name="customerId" id="customerSelect" class="form-select" required>
                            <option value="">-- Chọn khách hàng --</option>
                            <c:forEach var="c" items="${customerList}">
                                <option value="${c.accountId}">${c.fullName} (${c.email})</option>
                            </c:forEach>
                        </select>
                    </div>

                    <h6 class="fw-bold mb-3">2️⃣ Hợp đồng liên quan</h6>
                    <div class="mb-3">
                        <label>Hợp đồng <span class="text-danger">*</span></label>
                        <select name="contractId" id="contractSelect" class="form-select" required>
                            <option value="">-- Chọn hợp đồng --</option>
                            <c:forEach var="ct" items="${contractList}">
                                <option value="${ct.contractId}">#${ct.contractId} - ${ct.contractType} (${ct.status})</option>
                            </c:forEach>
                        </select>
                    </div>

                    <h6 class="fw-bold mb-3">3️⃣ Thiết bị</h6>
                    <div class="mb-3">
                        <label>Thiết bị <span class="text-danger">*</span></label>
                        <select name="equipmentId" id="equipmentSelect" class="form-select" required>
                            <option value="">-- Chọn thiết bị --</option>
                            <c:forEach var="equip" items="${equipmentList}">
                                <option value="${equip.equipmentId}">${equip.model} (${equip.serialNumber})</option>
                            </c:forEach>
                        </select>
                    </div>

                    <h6 class="fw-bold mb-3">4️⃣ Loại yêu cầu</h6>
                    <div class="mb-3">
                        <select name="requestType" class="form-select" required>
                            <option value="Service">Service</option>
                            <option value="Warranty">Warranty</option>
                        </select>
                    </div>

                    <h6 class="fw-bold mb-3">5️⃣ Mức độ ưu tiên</h6>
                    <div class="mb-3">
                        <select name="priorityLevel" class="form-select" required>
                            <option value="Normal">Normal</option>
                            <option value="High">High</option>
                            <option value="Urgent">Urgent</option>
                        </select>
                    </div>

                    <h6 class="fw-bold mb-3">6️⃣ Mô tả yêu cầu</h6>
                    <div class="mb-3">
                        <textarea name="description" class="form-control" rows="3"
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
    }).then(result => {
        if (result.isConfirmed) {
            window.location.href = 'forwardRequest?requestId=' + id;
        }
    });
}

function cancelRequest(id) {
    Swal.fire({
        title: 'Hủy yêu cầu?',
        text: 'Bạn có chắc chắn muốn hủy yêu cầu #' + id + '?',
        icon: 'warning',
        showCancelButton: true,
        confirmButtonText: 'Hủy yêu cầu',
        cancelButtonText: 'Quay lại',
        confirmButtonColor: '#d33'
    }).then(result => {
        if (result.isConfirmed) {
            window.location.href = 'cancelRequest?requestId=' + id;
        }
    });
}


document.addEventListener("change", function (e) {
    // Bắt sự kiện change cho phần tử có id = "customerSelect" (dù nằm trong modal)
    if (e.target && e.target.id === "customerSelect") {
        const customerId = e.target.value;
        console.log("Selected customerId:", customerId);

        if (!customerId) {
            console.warn("⚠️ customerId trống, bỏ qua fetch.");
            return;
        }

        // Gọi servlet (dùng encodeURIComponent để tránh lỗi ký tự)
        const url = `${pageContext.request.contextPath}/loadContractsAndEquipment?customerId=\${encodeURIComponent(customerId)}`;
        console.log("🔗 Fetch URL:", url);

        fetch(url)
            .then(res => {
                if (!res.ok) throw new Error(`HTTP error! status: ${res.status}`);
                return res.json();
            })
            .then(data => {
                console.log("✅ Data trả về từ servlet:", data);

                const contractSelect = document.getElementById("contractSelect");
                const equipmentSelect = document.getElementById("equipmentSelect");

                // Reset danh sách trước khi đổ mới
                contractSelect.innerHTML = '<option value="">-- Chọn hợp đồng --</option>';
                equipmentSelect.innerHTML = '<option value="">-- Chọn thiết bị --</option>';

                // Đổ danh sách hợp đồng
                data.contracts.forEach(ct => {
                    contractSelect.innerHTML += `<option value="${ct.contractId}">#${ct.contractId} - ${ct.contractType} (${ct.status})</option>`;
                });

                data.equipment.forEach(eq => {
                    equipmentSelect.innerHTML += `<option value="\${eq.equipmentId}">\${eq.model} (\${eq.serialNumber})</option>`;
                });
            })
            .catch(err => console.error("❌ Lỗi load hợp đồng/thiết bị:", err));
    }
});

</script>
</body>
</html>
