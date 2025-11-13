<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Chỉnh Sửa Người Dùng</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    </head>
    <body>
        <div class="container-fluid">
            <div class="row">
                <!-- Sidebar -->
                <div class="col-md-2 bg-dark min-vh-100 d-flex flex-column justify-content-between">
                    <div class="p-3">
                        <h4 class="text-white">Hệ Thống CRM</h4>
                        <ul class="nav flex-column">
                            <li class="nav-item">
                                <a class="nav-link text-white" href="${pageContext.request.contextPath}/home.jsp">
                                    <i class="fas fa-home"></i> Trang Chủ
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link text-white active" href="${pageContext.request.contextPath}/admin.jsp">
                                    <i class="fas fa-tachometer-alt"></i> Bảng Điều Khiển
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link text-white" href="${pageContext.request.contextPath}/user/list">
                                    <i class="fas fa-users"></i> Người Dùng
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link text-white" href="${pageContext.request.contextPath}/role/list">
                                    <i class="fas fa-user-tag"></i> Vai Trò
                                </a>
                            </li>
                        </ul>
                    </div>
                    <div class="p-3 border-top border-secondary">
                        <a href="${pageContext.request.contextPath}/logout"
                           class="btn btn-outline-light w-100 d-flex align-items-center justify-content-center gap-2">
                            <i class="fas fa-sign-out-alt"></i> Đăng Xuất
                        </a>
                    </div>
                </div>

                <!-- Main Content -->
                <div class="col-md-10">
                    <div class="p-4">
                        <div class="d-flex justify-content-between align-items-center mb-4">
                            <h2><i class="fas fa-user-edit"></i> Chỉnh Sửa Người Dùng</h2>
                            <a href="${pageContext.request.contextPath}/user/list" class="btn btn-secondary">
                                <i class="fas fa-arrow-left"></i> Quay Lại Danh Sách
                            </a>
                        </div>

                        <c:if test="${not empty error}">
                            <script>
                                document.addEventListener("DOMContentLoaded", () => {
                                    const alertBox = document.querySelector(".alert-danger");
                                    if (alertBox) {
                                        alertBox.scrollIntoView({behavior: "smooth", block: "start"});
                                    }
                                });
                            </script>
                        </c:if>

                        <!-- Messages -->
                        <c:if test="${not empty message}">
                            <div class="alert alert-success alert-dismissible fade show" role="alert">
                                ${message}
                                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                            </div>
                        </c:if>

                        <c:if test="${not empty error}">
                            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                ${error}
                                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                            </div>
                        </c:if>

                        <c:if test="${not empty user}">
                            <!-- Edit User Form -->
                            <div class="card">
                                <div class="card-body">
                                    <form action="${pageContext.request.contextPath}/user/update" method="POST">
                                        <input type="hidden" name="id" value="${user.accountId}">

                                        <div class="row">
                                            <div class="col-md-6">
                                                <div class="mb-3">
                                                    <label for="username" class="form-label">Tên Đăng Nhập <span class="text-danger">*</span></label>
                                                    <input type="text" class="form-control" readonly id="username" name="username" 
                                                           value="${user.username}" required>
                                                </div>
                                            </div>
                                            <div class="col-md-6">
                                                <div class="mb-3">
                                                    <label for="email" class="form-label">Email <span class="text-danger">*</span></label>
                                                    <input type="email" class="form-control" id="email" name="email" 
                                                           value="${user.email}" required>
                                                </div>
                                            </div>
                                        </div>

                                        <div class="row">
                                            <div class="col-md-6">
                                                <div class="mb-3">
                                                    <label for="fullName" class="form-label">Họ Và Tên</label>
                                                    <input type="text" class="form-control" id="fullName" name="fullName" 
                                                           value="${user.fullName}">
                                                </div>
                                            </div>
                                            <div class="col-md-6">
                                                <div class="mb-3">
                                                    <label for="phone" class="form-label">Số Điện Thoại</label>
                                                    <input type="tel" class="form-control" id="phone" name="phone" 
                                                           value="${user.phone}">
                                                </div>
                                            </div>
                                        </div>

                                        <div class="row">
                                            <div class="col-md-6">
                                                <div class="mb-3">
                                                    <label for="status" class="form-label">Trạng Thái</label>
                                                    <select class="form-select" id="status" name="status">
                                                        <option value="Active" ${user.status == 'Active' ? 'selected' : ''}>Hoạt Động</option>
                                                        <option value="Inactive" ${user.status == 'Inactive' ? 'selected' : ''}>Không Hoạt Động</option>
                                                    </select>
                                                </div>
                                            </div>
                                            <div class="col-md-6">
                                                <div class="mb-3">
                                                    <label class="form-label">Ngày Tạo</label>
                                                    <input type="text" class="form-control" 
                                                           value="<fmt:formatDate value='${user.createdAt}' pattern='dd/MM/yyyy HH:mm'/>" 
                                                           readonly>
                                                </div>
                                            </div>
                                        </div>

                                        <div class="d-flex justify-content-end gap-2">
                                            <a href="${pageContext.request.contextPath}/user/list" class="btn btn-secondary">
                                                <i class="fas fa-times"></i> Hủy
                                            </a>
                                            <button type="submit" class="btn btn-primary">
                                                <i class="fas fa-save"></i> Cập Nhật
                                            </button>
                                        </div>
                                    </form>
                                </div>
                            </div>

                            <!-- Change Password Form -->
                            <div class="card mt-4">
                                <div class="card-header">
                                    <h5><i class="fas fa-key"></i> Đổi Mật Khẩu</h5>
                                </div>
                                <div class="card-body">
                                    <form action="${pageContext.request.contextPath}/user/updatePassword" method="POST">
                                        <input type="hidden" name="id" value="${user.accountId}">

                                        <div class="row">
                                            <div class="col-md-6">
                                                <div class="mb-3">
                                                    <label for="newPassword" class="form-label">Mật Khẩu Mới</label>
                                                    <input type="password" class="form-control" id="newPassword" name="newPassword" required>
                                                </div>
                                            </div>
                                            <div class="col-md-6">
                                                <div class="mb-3">
                                                    <label for="confirmPassword" class="form-label">Xác Nhận Mật Khẩu</label>
                                                    <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" required>
                                                </div>
                                            </div>
                                        </div>

                                        <div class="d-flex justify-content-end">
                                            <button type="submit" class="btn btn-warning">
                                                <i class="fas fa-key"></i> Đổi Mật Khẩu
                                            </button>
                                        </div>
                                    </form>
                                </div>
                            </div>

                            <!-- User Roles -->
                            <c:if test="${not empty userRoles}">
                                <div class="card mt-4">
                                    <div class="card-header d-flex justify-content-between align-items-center">
                                        <h5><i class="fas fa-user-tag"></i> Vai Trò Hiện Tại</h5>
                                        <a href="${pageContext.request.contextPath}/user/roles?id=${user.accountId}" 
                                           class="btn btn-sm btn-outline-primary">
                                            <i class="fas fa-edit"></i> Quản Lý Vai Trò
                                        </a>
                                    </div>
                                    <div class="card-body">
                                        <div class="row">
                                            <c:forEach var="userRole" items="${userRoles}">
                                                <c:forEach var="role" items="${roles}">
                                                    <c:if test="${userRole.roleId == role.roleId}">
                                                        <div class="col-md-3">
                                                            <span class="badge bg-primary me-2">${role.roleName}</span>
                                                        </div>
                                                    </c:if>
                                                </c:forEach>
                                            </c:forEach>
                                        </div>
                                    </div>
                                </div>
                            </c:if>
                        </c:if>
                    </div>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            document.getElementById('confirmPassword').addEventListener('input', function () {
                const password = document.getElementById('newPassword').value;
                const confirmPassword = this.value;

                if (password !== confirmPassword) {
                    this.setCustomValidity('Mật khẩu không khớp');
                } else {
                    this.setCustomValidity('');
                }
            });
        </script>
    </body>
</html>