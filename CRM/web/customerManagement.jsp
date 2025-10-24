<%@page contentType="text/html" pageEncoding="UTF-8"%> 
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
    <head>
        <title>Quản Lý Người Dùng</title>
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

            .sidebar h4 {
                font-weight: 600;
                letter-spacing: 0.5px;
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

            .card {
                border: none;
                border-radius: 10px;
                box-shadow: 0 0.125rem 0.25rem rgba(0,0,0,0.075);
            }

            .search-box {
                border-radius: 25px;
                border: 1.5px solid #ddd;
                padding: 6px 10px;
                transition: 0.2s ease-in-out;
            }

            .search-box:focus {
                border-color: #000;
                box-shadow: 0 0 0 0.2rem rgba(0,0,0,0.2);
                outline: none;
            }

            .btn-custom {
                border-radius: 20px;
                padding: 8px 20px;
                white-space: nowrap;
            }

            .btn-dark {
                background-color: #000;
                border-color: #000;
            }

            .btn-dark:hover {
                background-color: #333;
            }

            .btn-outline-dark:hover {
                background-color: #000;
                color: #fff;
            }

            .user-table th,
            .user-table td {
                vertical-align: middle;
                white-space: nowrap;
            }

            .user-table td.actions {
                min-width: 160px;
            }

            .user-table td.email-cell {
                white-space: normal;
                word-break: break-word;
            }

            .table-light {
                background-color: #f1f1f1;
            }

            .card-header {
                background-color: #000;
                color: white;
            }

            .swal2-confirm.btn-danger {
                background-color: #000 !important;
            }

            .error-message {
                color: red;
                font-size: 0.85rem;
                display: none;
                margin-top: 4px;
            }
            input:invalid {
                border-color: #dc3545;
            }
            input:valid {
                border-color: #28a745;
            }

            .logout-section .btn-outline-light {
                border: 1px solid rgba(255,255,255,0.4);
                color: #fff;
                font-weight: 500;
                transition: all 0.3s ease;
            }

            .logout-section .btn-outline-light:hover {
                background-color: #fff;
                color: #000;
                border-color: #fff;
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
                            <i class="fas fa-cogs"></i> Quản lý
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
                        </nav>
                    </div>

                    <div class="mt-auto logout-section text-center">
                        <hr style="border-color: rgba(255,255,255,0.2);">
                        <button class="btn btn-outline-light w-100" onclick="logout()" style="border-radius: 10px;">
                            <i class="fas fa-sign-out-alt me-2"></i> Đăng xuất
                        </button>
                    </div>
                </div>


                <div class="col-md-10 main-content p-4">
                    <c:if test="${not empty sessionScope.message}">
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            <i class="fas fa-exclamation-triangle"></i> ${sessionScope.message}
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                        <c:remove var="message" scope="session" />
                    </c:if>

                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <h2><i class="fas fa-users text-dark"></i> Quản Lý Khách Hàng</h2>
                        <div class="d-flex align-items-center">
                            <span class="me-3">Xin chào, <strong>${sessionScope.session_login.username}</strong></span>
                        </div>
                    </div>

                    <div class="card mb-4">
                        <div class="card-body">
                            <div class="d-flex flex-wrap justify-content-between align-items-center gap-3">

                                <form class="row g-3 align-items-center flex-grow-1" action="customerManagement" method="GET">
                                    <input type="hidden" name="action" value="search">

                                    <div class="col-md-5">
                                        <div class="input-group">
                                            <input type="text" class="form-control search-box"
                                                   name="searchName" placeholder="Tìm kiếm theo username, email hoặc họ tên..."
                                                   value="${param.searchName}">
                                        </div>
                                    </div>

                                    <div class="col-md-3">
                                        <select name="status" class="form-select">
                                            <option value="">Tất cả trạng thái</option>
                                            <option value="Active" ${param.status == 'Active' ? 'selected' : ''}>Active</option>
                                            <option value="Inactive" ${param.status == 'Inactive' ? 'selected' : ''}>Inactive</option>
                                        </select>
                                    </div>

                                    <div class="col-md-2 d-grid">
                                        <button type="submit" class="btn btn-dark btn-custom">
                                            <i class="fas fa-search"></i> Tìm Kiếm
                                        </button>
                                    </div>
                                </form>

                                <div class="d-flex gap-2">
                                    <button class="btn btn-dark btn-custom" data-bs-toggle="modal" data-bs-target="#addUserModal">
                                        <i class="fas fa-plus"></i> Thêm Người Dùng
                                    </button>
                                    <a href="customerManagement" class="btn btn-outline-dark btn-custom">
                                        <i class="fas fa-sync-alt"></i> Làm Mới
                                    </a>
                                </div>

                            </div>
                        </div>
                    </div>


                    <div class="card">
                        <div class="card-header">
                            <h5 class="mb-0"><i class="fas fa-user-friends"></i> Danh Sách Người Dùng</h5>
                        </div>
                        <div class="card-body p-0">
                            <div class="table-responsive">
                                <table class="table table-hover mb-0 user-table">
                                    <thead class="table-light">
                                        <tr>
                                            <th>ID</th>
                                            <th>Username</th>
                                            <th>Full Name</th>
                                            <th>Email</th>
                                            <th>Phone</th>
                                            <th>Status</th>
                                            <th>Actions</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="acc" items="${userList}">
                                            <tr>
                                                <td><strong>#${acc.accountId}</strong></td>
                                                <td><i class="fas fa-user-circle me-2 text-dark"></i>${acc.username}</td>
                                                <td>${acc.fullName}</td>
                                                <td class="email-cell text-muted">${acc.email}</td>
                                                <td>${acc.phone}</td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${acc.status eq 'Active'}">
                                                            <span class="badge bg-success">Active</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge bg-secondary">Inactive</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td class="actions">
                                                    <div class="btn-group">
                                                        <button class="btn btn-sm btn-outline-dark"
                                                            onclick="openEditModal(
                                                                ${acc.accountId},
                                                                '${acc.username}',
                                                                '${acc.fullName}',
                                                                '${acc.email}',
                                                                '${acc.phone}',
                                                                '${acc.status}',
                                                                '${empty acc.profile.address ? "" : acc.profile.address}',
                                                                '${empty acc.profile.dateOfBirth ? "" : acc.profile.dateOfBirth}',
                                                                '${empty acc.profile.avatarUrl ? "" : acc.profile.avatarUrl}',
                                                                '${empty acc.profile.nationalId ? "" : acc.profile.nationalId}',
                                                                '${acc.profile.verified ? 1 : 0}',
                                                                '${empty acc.profile.extraData ? "" : acc.profile.extraData}'
                                                            )"
                                                            title="Sửa">
                                                            <i class="fas fa-edit"></i>
                                                        </button>


                                                        <c:choose>
                                                            <c:when test="${acc.status eq 'Active'}">
                                                                <button class="btn btn-sm btn-outline-danger"
                                                                        onclick="confirmDelete(${acc.accountId}, 'Active')"
                                                                        title="Vô hiệu hóa tài khoản">
                                                                    <i class="fas fa-user-slash"></i>
                                                                </button>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <button class="btn btn-sm btn-outline-primary"
                                                                        onclick="confirmDelete(${acc.accountId}, 'Inactive')"
                                                                        title="Kích hoạt lại tài khoản">
                                                                    <i class="fas fa-user-check"></i>
                                                                </button>
                                                            </c:otherwise>
                                                        </c:choose>

                                                    </div>
                                                </td>
                                            </tr>
                                        </c:forEach>

                                        <c:if test="${empty userList}">
                                            <tr>
                                                <td colspan="7" class="text-center py-4">
                                                    <i class="fas fa-user-times fa-3x text-muted mb-3"></i>
                                                    <h5 class="text-muted">Chưa có người dùng nào</h5>
                                                    <p class="text-muted">Hãy thêm người dùng mới để bắt đầu</p>
                                                </td>
                                            </tr>
                                        </c:if>
                                    </tbody>
                                </table>
                            </div>
                        </div>

                        <c:if test="${totalPages >= 1}">
                            <nav aria-label="Page navigation" class="mt-4">
                                <ul class="pagination justify-content-center">

                                    <!-- Nút TRƯỚC -->
                                    <li class="page-item ${currentPageNumber <= 1 ? 'disabled' : ''}">
                                        <c:choose>
                                            <c:when test="${currentPageNumber > 1}">
                                                <c:url var="prevUrl" value="customerManagement">
                                                    <c:param name="page" value="${currentPageNumber - 1}" />
                                                    <c:param name="action" value="search" />
                                                    <c:if test="${not empty param.searchName}">
                                                        <c:param name="searchName" value="${fn:trim(param.searchName)}" />
                                                    </c:if>
                                                    <c:if test="${not empty param.status}">
                                                        <c:param name="status" value="${fn:trim(param.status)}" />
                                                    </c:if>
                                                </c:url>
                                                <a class="page-link" href="${prevUrl}">
                                                    <i class="fas fa-chevron-left"></i> Trước
                                                </a>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="page-link"><i class="fas fa-chevron-left"></i> Trước</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </li>

                                    <!-- Các trang -->
                                    <c:forEach var="i" begin="1" end="${totalPages}">
                                        <li class="page-item ${i == currentPageNumber ? 'active' : ''}">
                                            <c:choose>
                                                <c:when test="${i != currentPageNumber}">
                                                    <c:url var="pageUrl" value="customerManagement">
                                                        <c:param name="page" value="${i}" />
                                                        <c:param name="action" value="search" />
                                                        <c:if test="${not empty param.searchName}">
                                                            <c:param name="searchName" value="${fn:trim(param.searchName)}" />
                                                        </c:if>
                                                        <c:if test="${not empty param.status}">
                                                            <c:param name="status" value="${fn:trim(param.status)}" />
                                                        </c:if>
                                                    </c:url>
                                                    <a class="page-link" href="${pageUrl}">${i}</a>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="page-link">${i}</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </li>
                                    </c:forEach>

                                    <!-- Nút TIẾP -->
                                    <li class="page-item ${currentPageNumber >= totalPages ? 'disabled' : ''}">
                                        <c:choose>
                                            <c:when test="${currentPageNumber < totalPages}">
                                                <c:url var="nextUrl" value="customerManagement">
                                                    <c:param name="page" value="${currentPageNumber + 1}" />
                                                    <c:param name="action" value="search" />
                                                    <c:if test="${not empty param.searchName}">
                                                        <c:param name="searchName" value="${fn:trim(param.searchName)}" />
                                                    </c:if>
                                                    <c:if test="${not empty param.status}">
                                                        <c:param name="status" value="${fn:trim(param.status)}" />
                                                    </c:if>
                                                </c:url>
                                                <a class="page-link" href="${nextUrl}">
                                                    Tiếp <i class="fas fa-chevron-right"></i>
                                                </a>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="page-link">Tiếp <i class="fas fa-chevron-right"></i></span>
                                                </c:otherwise>
                                            </c:choose>
                                    </li>
                                </ul>
                            </nav>

                            <!-- Thông tin trang -->
                            <div class="text-center text-muted mb-3">
                                <small>
                                    Trang <strong>${currentPageNumber}</strong> / <strong>${totalPages}</strong> |
                                    Hiển thị <strong>${fn:length(userList)}</strong> người dùng
                                </small>
                            </div>
                        </c:if>

                    </div>


                    <!-- Form ẩn -->
                    <form id="deleteForm" method="post" action="customerManagement" style="display:none;">
                        <input type="hidden" name="action" value="delete"/>
                        <input type="hidden" name="id" id="deleteUserId"/>
                    </form>

                  <!-- Modal thêm -->
<div class="modal fade" id="addUserModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <form id="addUserForm" method="post" action="customerManagement">
            <input type="hidden" name="action" value="add"/>
            <div class="modal-content">
                <div class="modal-header bg-dark text-white">
                    <h5 class="modal-title">Thêm Người Dùng</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>

                <div class="modal-body">

                    <!-- STEP 1 -->
                    <div id="addStep1">
                        <h6 class="fw-bold mb-3">Thông tin tài khoản</h6>

                        <div class="mb-3">
                            <label>Tên đăng nhập <span class="text-danger">*</span></label>
                            <input type="text" name="username" id="addUsername" class="form-control" required maxlength="20"
                                   pattern="[A-Za-z0-9]+" title="Chỉ gồm chữ và số, không có ký tự đặc biệt.">
                            <div id="addUsernameError" class="error-message">Tên đăng nhập không hợp lệ</div>
                        </div>

                        <div class="mb-3">
                            <label>Họ và tên <span class="text-danger">*</span></label>
                            <input type="text" name="fullName" id="addFullName" class="form-control" required maxlength="50"
                                   pattern="^[A-Za-zÀ-ỹ\s]{2,50}$" title="Chỉ gồm chữ cái và khoảng trắng.">
                            <div id="addFullNameError" class="error-message">Họ tên không hợp lệ</div>
                        </div>

                        <div class="mb-3">
                            <label>Email <span class="text-danger">*</span></label>
                            <input type="email" name="email" id="addEmail" class="form-control" required maxlength="100"
                                   pattern="[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
                                   title="Email không hợp lệ. Ví dụ: example@gmail.com">
                            <div id="addEmailError" class="error-message">Email không hợp lệ</div>
                        </div>

                        <div class="mb-3">
                            <label>Số điện thoại <span class="text-danger">*</span></label>
                            <input type="tel" name="phone" id="addPhone" class="form-control" required maxlength="10"
                                   pattern="(03|05|07|08|09)[0-9]{8}"
                                   title="Phải bắt đầu bằng 03, 05, 07, 08, 09 và có 10 chữ số.">
                            <div id="addPhoneError" class="error-message">Số điện thoại không hợp lệ</div>
                        </div>

                        <div class="mb-3">
                            <label>Mật khẩu <span class="text-danger">*</span></label>
                            <input type="password" name="password" id="addPassword" class="form-control" required
                                minlength="6" maxlength="30"
                                pattern="^(?=.*[A-Za-z0-9])[A-Za-z0-9!@#$%^&*()_+=-]{6,30}$"
                                title="Mật khẩu không được có khoảng trắng.">

                            <div id="addPasswordError" class="error-message">Mật khẩu tối thiểu 6 ký tự</div>
                        </div>
                    </div>

                    <!-- STEP 2 -->
                    <div id="addStep2" class="d-none">
                        <h6 class="fw-bold mb-3">Thông tin hồ sơ</h6>

                        <div class="mb-3">
                            <label>Địa chỉ</label>
                            <input type="text" name="address" id="addAddress" class="form-control" maxlength="100">
                        </div>

                        <div class="mb-3">
                            <label>Ngày sinh</label>
                            <input type="date" name="dateOfBirth" id="addDateOfBirth" class="form-control"
                                max="9999-12-31"
                                title="Ngày sinh không được ở tương lai.">

                            <div id="addDobError" class="error-message">Ngày sinh không hợp lệ</div>
                        </div>

                        <div class="mb-3">
                            <label>Ảnh đại diện (URL)</label>
                            <input type="url" name="avatarUrl" id="addAvatarUrl" class="form-control"
                                maxlength="200"
                                pattern="^(https?:\/\/.*\.(?:png|jpg|jpeg|gif|webp|svg))$"
                                title="URL ảnh phải bắt đầu bằng http hoặc https và kết thúc bằng đuôi ảnh (.jpg, .png, .gif, v.v.)">

                            <div id="addAvatarError" class="error-message">URL ảnh đại diện không hợp lệ</div>
                        </div>

                        <div class="mb-3">
                            <label>CCCD/CMND</label>
                            <input type="text" name="nationalId" id="addNationalId" class="form-control"
                                minlength="9" maxlength="12"
                                pattern="^[0-9]{9,12}$"
                                title="CCCD/CMND chỉ gồm số, dài từ 9–12 ký tự.">

                            <div id="addNationalIdError" class="error-message">CMND/CCCD không hợp lệ</div>
                        </div>

                        <div class="mb-3">
                            <label>Xác thực tài khoản <span class="text-danger">*</span></label>
                                <select name="verified" id="addVerified" class="form-select" required
                                        title="Vui lòng chọn trạng thái xác thực.">
                                    <option value="">-- Chọn trạng thái --</option>
                                    <option value="0">Chưa xác thực</option>
                                    <option value="1">Đã xác thực</option>
                                </select>

                        </div>

                        <div class="mb-3">
                            <label>Ghi chú thêm</label>
                            <textarea name="extraData" id="addExtraData" class="form-control" rows="2" maxlength="100"></textarea>
                        </div>
                    </div>
                </div>

                <div class="modal-footer d-flex justify-content-between">
                    <button type="button" id="addPrevStep" class="btn btn-secondary d-none">← Quay lại</button>
                    <button type="button" id="addNextStep" class="btn btn-dark">Tiếp →</button>
                    <button type="submit" id="addSubmitBtn" class="btn btn-dark d-none">Lưu</button>
                </div>
            </div>
        </form>
    </div>
    
</div>
                  

<!-- Modal Sửa -->
<div class="modal fade" id="editUserModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <form id="editUserForm" method="post" action="customerManagement">
            <input type="hidden" name="action" value="edit"/>
            <input type="hidden" name="id" id="editId"/>

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

                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
        <script>
document.addEventListener("DOMContentLoaded", function () {

    // ========== VALIDATE FORM THÊM NGƯỜI DÙNG ==========
    const addForm = document.getElementById("addUserForm");
    const addStep1 = document.getElementById("addStep1");
    const addStep2 = document.getElementById("addStep2");
    const addNextBtn = document.getElementById("addNextStep");
    const addPrevBtn = document.getElementById("addPrevStep");
    const addSubmitBtn = document.getElementById("addSubmitBtn");

    if (addForm) {

        addNextBtn.addEventListener("click", function () {
            if (validateAddStep1()) {
                addStep1.classList.add("d-none");
                addStep2.classList.remove("d-none");
                addNextBtn.classList.add("d-none");
                addPrevBtn.classList.remove("d-none");
                addSubmitBtn.classList.remove("d-none");
            } else {
                Swal.fire({
                    icon: 'error',
                    title: 'Thông tin chưa hợp lệ',
                    text: 'Vui lòng nhập đúng định dạng trước khi tiếp tục!',
                    confirmButtonColor: '#000'
                });
            }
        });

        addPrevBtn.addEventListener("click", function () {
            addStep2.classList.add("d-none");
            addStep1.classList.remove("d-none");
            addNextBtn.classList.remove("d-none");
            addPrevBtn.classList.add("d-none");
            addSubmitBtn.classList.add("d-none");
        });

        addForm.addEventListener("submit", function (e) {
            let valid = validateAddStep1() && validateAddStep2();
            if (!valid) {
                e.preventDefault();
                Swal.fire({
                    icon: 'error',
                    title: 'Thông tin chưa hợp lệ',
                    text: 'Vui lòng kiểm tra lại các trường bị lỗi trước khi lưu!',
                    confirmButtonColor: '#000'
                });
            } else {
                Swal.fire({
                    icon: 'success',
                    title: 'Thêm người dùng thành công!',
                    showConfirmButton: false,
                    timer: 1500
                });
            }
        });

        // Ẩn lỗi khi người dùng nhập lại
        document.querySelectorAll("#addUserForm input, #addUserForm textarea, #addUserForm select").forEach(input => {
            input.addEventListener("input", function () {
                const error = this.parentElement.querySelector(".error-message");
                if (error) error.style.display = "none";
            });
        });
    }

    // STEP 1 - ACCOUNT INFO
    function validateAddStep1() {
        let valid = true;
        const username = document.getElementById("addUsername");
        const fullName = document.getElementById("addFullName");
        const email = document.getElementById("addEmail");
        const phone = document.getElementById("addPhone");
        const password = document.getElementById("addPassword");

        const usernamePattern = /^[A-Za-z0-9]+$/;
        const fullNamePattern = /^[A-Za-zÀ-ỹ\s]{2,50}$/;
        const emailPattern = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
        const phonePattern = /^(03|05|07|08|09)[0-9]{8}$/;
        const passwordPattern = /^(?=.*[A-Za-z0-9])[A-Za-z0-9!@#$%^&*()_+=-]{6,30}$/;

        if (!usernamePattern.test(username.value.trim()) || username.value.trim().length === 0) {
            document.getElementById("addUsernameError").style.display = "block";
            valid = false;
        } else document.getElementById("addUsernameError").style.display = "none";

        if (!fullNamePattern.test(fullName.value.trim())) {
            document.getElementById("addFullNameError").style.display = "block";
            valid = false;
        } else document.getElementById("addFullNameError").style.display = "none";

        if (!emailPattern.test(email.value.trim())) {
            document.getElementById("addEmailError").style.display = "block";
            valid = false;
        } else document.getElementById("addEmailError").style.display = "none";

        if (!phonePattern.test(phone.value.trim())) {
            document.getElementById("addPhoneError").style.display = "block";
            valid = false;
        } else document.getElementById("addPhoneError").style.display = "none";

        if (!passwordPattern.test(password.value.trim())) {
            document.getElementById("addPasswordError").style.display = "block";
            valid = false;
        } else document.getElementById("addPasswordError").style.display = "none";

        return valid;
    }

    // STEP 2 - PROFILE INFO
    function validateAddStep2() {
        let valid = true;
        const dateOfBirth = document.getElementById("addDateOfBirth").value.trim();
        const avatarUrl = document.getElementById("addAvatarUrl").value.trim();
        const nationalId = document.getElementById("addNationalId").value.trim();
        const verified = document.getElementById("addVerified").value;

        const urlPattern = /^(https?:\/\/.*\.(?:png|jpg|jpeg|gif|webp|svg))$/i;
        const nationalIdPattern = /^[0-9]{9,12}$/;

        // Ngày sinh
        if (dateOfBirth) {
            const dob = new Date(dateOfBirth);
            const now = new Date();
            const age = now.getFullYear() - dob.getFullYear();
            if (dob > now) {
                document.getElementById("addDobError").textContent = "Ngày sinh không được ở tương lai.";
                document.getElementById("addDobError").style.display = "block";
                valid = false;
            } else if (age < 10) {
                document.getElementById("addDobError").textContent = "Tuổi phải từ 10 trở lên.";
                document.getElementById("addDobError").style.display = "block";
                valid = false;
            } else {
                document.getElementById("addDobError").style.display = "none";
            }
        }

        // Avatar URL
        if (avatarUrl && (!urlPattern.test(avatarUrl) || avatarUrl.length > 200)) {
            document.getElementById("addAvatarError").style.display = "block";
            valid = false;
        } else document.getElementById("addAvatarError").style.display = "none";

        // CCCD
        if (nationalId && !nationalIdPattern.test(nationalId)) {
            document.getElementById("addNationalIdError").style.display = "block";
            valid = false;
        } else document.getElementById("addNationalIdError").style.display = "none";

        // Verified
        if (verified === "") {
            Swal.fire({
                icon: 'error',
                title: 'Chưa chọn trạng thái xác thực!',
                text: 'Vui lòng chọn "Đã xác thực" hoặc "Chưa xác thực".',
                confirmButtonColor: '#000'
            });
            valid = false;
        }

        return valid;
    }

    // ========== VALIDATE FORM SỬA NGƯỜI DÙNG ==========
    const step1 = document.getElementById("step1");
    const step2 = document.getElementById("step2");
    const nextBtn = document.getElementById("nextStep");
    const prevBtn = document.getElementById("prevStep");
    const submitBtn = document.getElementById("submitBtn");
    const editForm = document.getElementById("editUserForm");

    if (editForm) {
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
                    title: 'Thông tin chưa hợp lệ',
                    text: 'Vui lòng nhập đúng định dạng trước khi tiếp tục!',
                    confirmButtonColor: '#000'
                });
            }
        });

        prevBtn.addEventListener("click", function () {
            step2.classList.add("d-none");
            step1.classList.remove("d-none");
            nextBtn.classList.remove("d-none");
            prevBtn.classList.add("d-none");
            submitBtn.classList.add("d-none");
        });

        editForm.addEventListener("submit", function (e) {
            let valid = validateStep1() && validateStep2();
            if (!valid) {
                e.preventDefault();
                Swal.fire({
                    icon: 'error',
                    title: 'Thông tin chưa hợp lệ',
                    text: 'Vui lòng kiểm tra lại trước khi cập nhật!',
                    confirmButtonColor: '#000'
                });
            } else {
                Swal.fire({
                    icon: 'success',
                    title: 'Cập nhật thành công!',
                    showConfirmButton: false,
                    timer: 1500
                });
            }
        });

        // STEP 1 - EDIT
        function validateStep1() {
            let valid = true;
            const fullName = document.getElementById("editFullName");
            const email = document.getElementById("editEmail");
            const phone = document.getElementById("editPhone");
            const password = document.getElementById("editPassword");

            const fullNamePattern = /^[A-Za-zÀ-ỹ\s]{2,50}$/;
            const emailPattern = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
            const phonePattern = /^(03|05|07|08|09)[0-9]{8}$/;
            const passwordPattern = /^(?=.*[A-Za-z0-9])[A-Za-z0-9!@#$%^&*()_+=-]{6,30}$/;

            if (!fullNamePattern.test(fullName.value.trim())) {
                document.getElementById("editFullNameError").style.display = "block";
                valid = false;
            } else document.getElementById("editFullNameError").style.display = "none";

            if (!emailPattern.test(email.value.trim())) {
                document.getElementById("editEmailError").style.display = "block";
                valid = false;
            } else document.getElementById("editEmailError").style.display = "none";

            if (!phonePattern.test(phone.value.trim())) {
                document.getElementById("editPhoneError").style.display = "block";
                valid = false;
            } else document.getElementById("editPhoneError").style.display = "none";

            if (password.value.trim() !== "" && !passwordPattern.test(password.value.trim())) {
                document.getElementById("editPasswordError").style.display = "block";
                valid = false;
            } else document.getElementById("editPasswordError").style.display = "none";

            return valid;
        }

        // STEP 2 - EDIT
        function validateStep2() {
            let valid = true;
            const dateOfBirth = document.getElementById("editDateOfBirth").value.trim();
            const avatarUrl = document.getElementById("editAvatarUrl").value.trim();
            const nationalId = document.getElementById("editNationalId").value.trim();
            const verified = document.getElementById("editVerified").value;

            const urlPattern = /^(https?:\/\/.*\.(?:png|jpg|jpeg|gif|webp|svg))$/i;
            const nationalIdPattern = /^[0-9]{9,12}$/;

            if (dateOfBirth) {
                const dob = new Date(dateOfBirth);
                const now = new Date();
                const age = now.getFullYear() - dob.getFullYear();
                if (dob > now) {
                    document.getElementById("editDobError").textContent = "Ngày sinh không được ở tương lai.";
                    document.getElementById("editDobError").style.display = "block";
                    valid = false;
                } else if (age < 10) {
                    document.getElementById("editDobError").textContent = "Tuổi phải từ 10 trở lên.";
                    document.getElementById("editDobError").style.display = "block";
                    valid = false;
                } else {
                    document.getElementById("editDobError").style.display = "none";
                }
            }

            if (avatarUrl && (!urlPattern.test(avatarUrl) || avatarUrl.length > 200)) {
                document.getElementById("editAvatarError").style.display = "block";
                valid = false;
            } else document.getElementById("editAvatarError").style.display = "none";

            if (nationalId && !nationalIdPattern.test(nationalId)) {
                document.getElementById("editNationalIdError").style.display = "block";
                valid = false;
            } else document.getElementById("editNationalIdError").style.display = "none";

            if (verified === "") {
                Swal.fire({
                    icon: 'error',
                    title: 'Chưa chọn trạng thái xác thực!',
                    text: 'Vui lòng chọn "Đã xác thực" hoặc "Chưa xác thực".',
                    confirmButtonColor: '#000'
                });
                valid = false;
            }

            return valid;
        }

        // Ẩn lỗi khi người dùng gõ lại
        document.querySelectorAll("#editUserForm input, #editUserForm textarea, #editUserForm select").forEach(input => {
            input.addEventListener("input", function () {
                const error = this.parentElement.querySelector(".error-message");
                if (error) error.style.display = "none";
            });
        });
    }
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

function confirmDelete(id, status) {
    const isActive = status && status.trim().toLowerCase() === "active";

    Swal.fire({
        title: isActive ? 'Vô hiệu hóa tài khoản?' : 'Kích hoạt lại tài khoản?',
        text: isActive 
            ? 'Tài khoản này sẽ bị chuyển sang trạng thái Inactive!' 
            : 'Tài khoản này sẽ được kích hoạt trở lại!',
        icon: isActive ? 'warning' : 'question',
        showCancelButton: true,
        confirmButtonText: isActive ? 'Vô hiệu hóa' : 'Kích hoạt',
        cancelButtonText: 'Hủy',
        confirmButtonColor: isActive ? '#d33' : '#28a745'
    }).then(result => {
        if (result.isConfirmed) {
            document.getElementById("deleteUserId").value = id;
            document.getElementById("deleteForm").submit();
        }
    });
}


function openEditModal(id, username, fullName, email, phone, status, address, dateOfBirth, avatarUrl, nationalId, verified, extraData) {
    document.getElementById("editId").value = id;
    document.getElementById("editUsername").value = username;
    document.getElementById("editFullName").value = fullName;
    document.getElementById("editEmail").value = email;
    document.getElementById("editPhone").value = phone;
    document.getElementById("editStatus").value = status;
    document.getElementById("editAddress").value = address;
    document.getElementById("editDateOfBirth").value = dateOfBirth;
    document.getElementById("editAvatarUrl").value = avatarUrl;
    document.getElementById("editNationalId").value = nationalId;
    document.getElementById("editVerified").value = verified;
    document.getElementById("editExtraData").value = extraData;

    // Reset modal về Step 1 mỗi lần mở
    document.getElementById("step1").classList.remove("d-none");
    document.getElementById("step2").classList.add("d-none");
    document.getElementById("nextStep").classList.remove("d-none");
    document.getElementById("prevStep").classList.add("d-none");
    document.getElementById("submitBtn").classList.add("d-none");

    new bootstrap.Modal(document.getElementById("editUserModal")).show();
}
</script>
    </body>
</html>
