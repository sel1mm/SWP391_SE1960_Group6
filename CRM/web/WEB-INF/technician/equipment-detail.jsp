<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<div class="container-fluid">
  <!-- Success/Error Messages -->
  <c:if test="${not empty success}">
    <div class="alert alert-success alert-dismissible fade show" role="alert">
      <i class="bi bi-check-circle me-2"></i>${success}
      <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
  </c:if>
  <c:if test="${not empty error}">
    <div class="alert alert-danger alert-dismissible fade show" role="alert">
      <i class="bi bi-exclamation-triangle me-2"></i>${error}
      <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
  </c:if>

  <div class="row mb-3 align-items-center">
    <div class="col">
      <nav aria-label="breadcrumb">
        <ol class="breadcrumb mb-0">
          <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/technician/contracts?action=equipment">Thiết bị</a></li>
          <li class="breadcrumb-item active">Thiết bị #${equipment.equipmentId}</li>
        </ol>
      </nav>
      <h1 class="h4 crm-page-title mt-2">Chi tiết thiết bị</h1>
    </div>
    <div class="col-auto">
      <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/technician/contracts?action=equipment">
        <i class="bi bi-arrow-left me-1"></i>Quay lại thiết bị
      </a>
      <a class="btn btn-primary" href="${pageContext.request.contextPath}/technician/tasks">
        <i class="bi bi-list-task me-1"></i>Công việc của tôi
      </a>
    </div>
  </div>

  <div class="row">
    <div class="col-lg-8">
      <div class="card crm-card-shadow">
        <div class="card-header">
          <h5 class="mb-0">Thông tin thiết bị</h5>
        </div>
        <div class="card-body">
          <div class="row">
            <div class="col-md-6">
              <div class="mb-3">
                <label class="form-label fw-bold">Mã thiết bị</label>
                <p class="form-control-plaintext">#${equipment.equipmentId}</p>
              </div>
              <div class="mb-3">
                <label class="form-label fw-bold">Số seri</label>
                <p class="form-control-plaintext">
                  <code class="text-primary fs-5">${fn:escapeXml(equipment.serialNumber)}</code>
                </p>
              </div>
              <div class="mb-3">
                <label class="form-label fw-bold">Mẫu thiết bị</label>
                <p class="form-control-plaintext">${fn:escapeXml(equipment.model)}</p>
              </div>
            </div>
            <div class="col-md-6">
              <div class="mb-3">
                <label class="form-label fw-bold">Ngày lắp đặt</label>
                <p class="form-control-plaintext">
                  <c:choose>
                    <c:when test="${equipment.installDate != null}">
                      <i class="bi bi-calendar-event me-1"></i>${equipment.installDate}
                    </c:when>
                    <c:otherwise>
                      <span class="text-muted">Chưa đặt</span>
                    </c:otherwise>
                  </c:choose>
                </p>
              </div>
              <div class="mb-3">
                <label class="form-label fw-bold">Cập nhật lần cuối bởi</label>
                <p class="form-control-plaintext">#${equipment.lastUpdatedBy}</p>
              </div>
              <div class="mb-3">
                <label class="form-label fw-bold">Ngày cập nhật cuối</label>
                <p class="form-control-plaintext">
                  <c:choose>
                    <c:when test="${equipment.lastUpdatedDate != null}">
                      <i class="bi bi-calendar-event me-1"></i>${equipment.lastUpdatedDate}
                    </c:when>
                    <c:otherwise>
                      <span class="text-muted">Không xác định</span>
                    </c:otherwise>
                  </c:choose>
                </p>
              </div>
            </div>
          </div>
          
          <div class="mb-3">
            <label class="form-label fw-bold">Mô tả</label>
            <div class="border rounded p-3 bg-light">
              <c:choose>
                <c:when test="${equipment.description != null && !equipment.description.isEmpty()}">
                  <p class="mb-0">${fn:escapeXml(equipment.description)}</p>
                </c:when>
                <c:otherwise>
                  <p class="mb-0 text-muted">Không có mô tả</p>
                </c:otherwise>
              </c:choose>
            </div>
          </div>
        </div>
      </div>
    </div>
    
    <div class="col-lg-4">
      <div class="card crm-card-shadow">
        <div class="card-header">
          <h5 class="mb-0">Trạng thái thiết bị</h5>
        </div>
        <div class="card-body">
          <div class="text-center">
            <i class="bi bi-gear fs-1 text-primary"></i>
            <p class="mt-2 mb-0">Thiết bị đang hoạt động</p>
            <small class="text-muted">Thiết bị này đang vận hành bình thường</small>
          </div>
          
          <hr>
          
          <div class="mb-3">
            <label class="form-label fw-bold">Trạng thái lắp đặt</label>
            <p class="form-control-plaintext">
              <c:choose>
                <c:when test="${equipment.installDate != null}">
                  <span class="badge bg-success">Đã lắp đặt</span>
                </c:when>
                <c:otherwise>
                  <span class="badge bg-warning">Chưa lắp đặt</span>
                </c:otherwise>
              </c:choose>
            </p>
          </div>
          
          <div class="mb-3">
            <label class="form-label fw-bold">Trạng thái bảo trì</label>
            <p class="form-control-plaintext">
              <span class="badge bg-info">Bảo trì định kỳ</span>
            </p>
          </div>
        </div>
      </div>
      
      <div class="card crm-card-shadow mt-3">
        <div class="card-header">
          <h5 class="mb-0">Thao tác nhanh</h5>
        </div>
        <div class="card-body">
          <div class="d-grid gap-2">
            <a class="btn btn-primary" href="${pageContext.request.contextPath}/technician/tasks">
              <i class="bi bi-list-task me-1"></i>Xem công việc của tôi
            </a>
            <a class="btn btn-outline-primary" href="${pageContext.request.contextPath}/technician/reports?action=create">
              <i class="bi bi-clipboard-plus me-1"></i>Tạo báo cáo
            </a>
            <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/technician/contracts">
              <i class="bi bi-file-earmark-text me-1"></i>Xem hợp đồng
            </a>
          </div>
        </div>
      </div>
      
      <div class="card crm-card-shadow mt-3">
        <div class="card-header">
          <h5 class="mb-0">Thông tin thiết bị</h5>
        </div>
        <div class="card-body">
          <div class="row text-center">
            <div class="col-6">
              <div class="border rounded p-2">
                <i class="bi bi-hash fs-4 text-primary"></i>
                <p class="mb-0 fw-bold">${equipment.equipmentId}</p>
                <small class="text-muted">Mã thiết bị</small>
              </div>
            </div>
            <div class="col-6">
              <div class="border rounded p-2">
                <i class="bi bi-tag fs-4 text-success"></i>
                <p class="mb-0 fw-bold">${fn:substring(equipment.serialNumber, 0, 8)}...</p>
                <small class="text-muted">Số seri</small>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
