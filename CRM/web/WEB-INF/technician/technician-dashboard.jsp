<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<div class="container-fluid">
  <div class="row mb-3 align-items-center">
    <div class="col">
      <h1 class="h4 crm-page-title">Bảng điều khiển Kỹ thuật viên</h1>
      <p class="text-muted">Chào mừng đến với không gian làm việc của bạn</p>
    </div>
    <div class="col-auto">
      <a class="btn btn-primary" href="${pageContext.request.contextPath}/technician/tasks">
        <i class="bi bi-list-task me-1"></i>Xem công việc của tôi
      </a>
    </div>
  </div>

  <!-- Quick Stats Cards -->
  <div class="row mb-4">
    <div class="col-md-3">
      <div class="card crm-card-shadow text-center">
        <div class="card-body">
          <i class="bi bi-list-task fs-1 text-primary mb-2"></i>
          <h5 class="card-title">Công việc của tôi</h5>
          <p class="card-text">Xem và quản lý các công việc được giao</p>
          <a href="${pageContext.request.contextPath}/technician/tasks" class="btn btn-outline-primary">Xem công việc</a>
        </div>
      </div>
    </div>
    <div class="col-md-3">
      <div class="card crm-card-shadow text-center">
        <div class="card-body">
          <i class="bi bi-clipboard-plus fs-1 text-success mb-2"></i>
          <h5 class="card-title">Báo cáo sửa chữa</h5>
          <p class="card-text">Tạo và quản lý báo cáo sửa chữa</p>
          <a href="${pageContext.request.contextPath}/technician/reports" class="btn btn-outline-success">Xem báo cáo</a>
        </div>
      </div>
    </div>
    <div class="col-md-3">
      <div class="card crm-card-shadow text-center">
        <div class="card-body">
          <i class="bi bi-file-earmark-text fs-1 text-info mb-2"></i>
          <h5 class="card-title">Hợp đồng</h5>
          <p class="card-text">Xem hợp đồng khách hàng</p>
          <a href="${pageContext.request.contextPath}/technician/contracts" class="btn btn-outline-info">Xem hợp đồng</a>
        </div>
      </div>
    </div>
    <div class="col-md-3">
      <div class="card crm-card-shadow text-center">
        <div class="card-body">
          <i class="bi bi-gear fs-1 text-warning mb-2"></i>
          <h5 class="card-title">Thiết bị</h5>
          <p class="card-text">Xem thông tin thiết bị</p>
          <a href="${pageContext.request.contextPath}/technician/contracts?action=equipment" class="btn btn-outline-warning">Xem thiết bị</a>
        </div>
      </div>
    </div>
  </div>

  <!-- Quick Actions -->
  <div class="row">
    <div class="col-lg-8">
      <div class="card crm-card-shadow">
        <div class="card-header">
          <h5 class="mb-0">Thao tác nhanh</h5>
        </div>
        <div class="card-body">
          <div class="row">
            <div class="col-md-6">
              <div class="d-grid gap-2">
                <a class="btn btn-primary" href="${pageContext.request.contextPath}/technician/tasks">
                  <i class="bi bi-list-task me-2"></i>Xem công việc của tôi
                </a>
                <a class="btn btn-success" href="${pageContext.request.contextPath}/technician/reports?action=create">
                  <i class="bi bi-clipboard-plus me-2"></i>Tạo báo cáo sửa chữa
                </a>
                <a class="btn btn-info" href="${pageContext.request.contextPath}/technician/contracts">
                  <i class="bi bi-file-earmark-text me-2"></i>Xem hợp đồng
                </a>
              </div>
            </div>
            <div class="col-md-6">
              <div class="d-grid gap-2">
                <a class="btn btn-warning" href="${pageContext.request.contextPath}/technician/contracts?action=equipment">
                  <i class="bi bi-gear me-2"></i>Xem thiết bị
                </a>
                <a class="btn btn-secondary" href="${pageContext.request.contextPath}/technician/work-history">
                  <i class="bi bi-clock-history me-2"></i>Lịch sử công việc
                </a>
                <a class="btn btn-outline-primary" href="${pageContext.request.contextPath}/manageProfile">
                  <i class="bi bi-person me-2"></i>Hồ sơ của tôi
                </a>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    
    <div class="col-lg-4">
      <div class="card crm-card-shadow">
        <div class="card-header">
          <h5 class="mb-0">Trợ giúp & Hỗ trợ</h5>
        </div>
        <div class="card-body">
          <div class="d-grid gap-2">
            <a class="btn btn-outline-primary btn-sm" href="#">
              <i class="bi bi-question-circle me-1"></i>Hướng dẫn sử dụng
            </a>
            <a class="btn btn-outline-secondary btn-sm" href="#">
              <i class="bi bi-telephone me-1"></i>Liên hệ hỗ trợ
            </a>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>