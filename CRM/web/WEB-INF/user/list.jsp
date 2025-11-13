<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản Lý Người Dùng</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .table th {
            background-color: #f8f9fa;
        }
        .status-badge {
            font-size: 0.8em;
        }
    </style>
</head>
<body>
    <div class="container-fluid">
        <div class="row">
            <!-- Sidebar -->
            <div class="col-md-2 bg-dark min-vh-100 d-flex flex-column justify-content-between">
                <!-- Phần trên của sidebar -->
                <div class="p-3">
                    <h4 class="text-white">Hệ Thống CRM</h4>
                    <ul class="nav flex-column">
                        <li class="nav-item">
                            <a class="nav-link text-white" href="${pageContext.request.contextPath}/home.jsp">
                                <i class="fas fa-home"></i> Trang chủ
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link text-white active" href="${pageContext.request.contextPath}/admin.jsp">
                                <i class="fas fa-tachometer-alt"></i> Bảng điều khiển
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link text-white" href="${pageContext.request.contextPath}/user/list">
                                <i class="fas fa-users"></i> Người dùng
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link text-white" href="${pageContext.request.contextPath}/role/list">
                                <i class="fas fa-user-tag"></i> Vai trò
                            </a>
                        </li>
                    </ul>
                </div>

                <!-- Nút Logout ở dưới cùng -->
                <div class="p-3 border-top border-secondary">
                    <a href="${pageContext.request.contextPath}/logout"
                       class="btn btn-outline-light w-100 d-flex align-items-center justify-content-center gap-2">
                        <i class="fas fa-sign-out-alt"></i> Đăng xuất
                    </a>
                </div>
            </div>

            <!-- Nội dung chính -->
            <div class="col-md-10">
                <div class="p-4">
                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <h2><i class="fas fa-users"></i> Quản Lý Người Dùng</h2>
                        
                        <a href="${pageContext.request.contextPath}/user/create" class="btn btn-primary">
                            <i class="fas fa-plus"></i> Thêm Người Dùng Mới
                        </a>
                    </div>

                    <!-- Thanh tìm kiếm -->
                    <form class="row mb-3" method="get" action="${pageContext.request.contextPath}/user/list">
                        <div class="col-md-4">
                            <input type="text" class="form-control" name="keyword" 
                                   placeholder="Tìm theo tên đăng nhập, email hoặc họ tên..." 
                                   value="${param.keyword}">
                        </div>
                        <div class="col-md-3">
                            <select name="status" class="form-select">
                                <option value="">Tất cả trạng thái</option>
                                <option value="Active" ${param.status == 'Active' ? 'selected' : ''}>Đang hoạt động</option>
                                <option value="Inactive" ${param.status == 'Inactive' ? 'selected' : ''}>Ngưng hoạt động</option>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <button type="submit" class="btn btn-primary w-100"><i class="fas fa-search"></i> Tìm kiếm</button>
                        </div>
                        <div class="col-md-2">
                            <a href="${pageContext.request.contextPath}/user/list" class="btn btn-secondary w-100">
                                <i class="fas fa-undo"></i> Đặt lại
                            </a>
                        </div>
                    </form>

                    <!-- Thông báo -->
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

                    <!-- Bảng danh sách người dùng -->
                    <div class="card">
                        <div class="card-body">
                            <c:choose>
                                <c:when test="${not empty users}">
                                    <div class="table-responsive">
                                        <table class="table table-striped table-hover">
                                            <thead>
                                                <tr>
                                                    <th>ID</th>
                                                    <th>Tên đăng nhập</th>
                                                    <th>Họ và tên</th>
                                                    <th>Email</th>
                                                    <th>Số điện thoại</th>
                                                    <th>Trạng thái</th>
                                                    <th>Ngày tạo</th>
                                                    <th>Hành động</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach var="user" items="${users}">
                                                    <tr>
                                                        <td>${user.accountId}</td>
                                                        <td>${user.username}</td>
                                                        <td>${user.fullName}</td>
                                                        <td>${user.email}</td>
                                                        <td>${user.phone}</td>
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${user.status == 'Active'}">
                                                                    <span class="badge bg-success status-badge">Đang hoạt động</span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="badge bg-secondary status-badge">Ngưng hoạt động</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                        <td>
                                                            <fmt:formatDate value="${user.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                                        </td>
                                                        <td>
                                                            <div class="btn-group" role="group">
                                                                <a href="${pageContext.request.contextPath}/user/edit?id=${user.accountId}" 
                                                                   class="btn btn-sm btn-outline-primary" title="Chỉnh sửa">
                                                                    <i class="fas fa-edit"></i>
                                                                </a>
                                                                <a href="${pageContext.request.contextPath}/user/roles?id=${user.accountId}" 
                                                                   class="btn btn-sm btn-outline-info" title="Quản lý vai trò">
                                                                    <i class="fas fa-user-tag"></i>
                                                                </a>
                                                                <a href="${pageContext.request.contextPath}/user/delete?id=${user.accountId}" 
                                                                   class="btn btn-sm btn-outline-danger" 
                                                                   onclick="return confirm('Bạn có chắc chắn muốn xóa người dùng này không?')" 
                                                                   title="Xóa">
                                                                    <i class="fas fa-trash"></i>
                                                                </a>
                                                            </div>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </tbody>
                                        </table>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="text-center py-5">
                                        <i class="fas fa-users fa-3x text-muted mb-3"></i>
                                        <h5 class="text-muted">Không có người dùng nào</h5>
                                        <p class="text-muted">Hãy bắt đầu bằng cách thêm người dùng đầu tiên của bạn.</p>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
