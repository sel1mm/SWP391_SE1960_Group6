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
          <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/technician/contracts">Hợp đồng</a></li>
          <li class="breadcrumb-item active">Hợp đồng #${contractWithEquipment.contract.contractId}</li>
        </ol>
      </nav>
      <h1 class="h4 crm-page-title mt-2">Chi tiết hợp đồng</h1>
    </div>
    <div class="col-auto">
      <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/technician/contracts">
        <i class="bi bi-arrow-left me-1"></i>Quay lại hợp đồng
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
          <h5 class="mb-0">Thông tin hợp đồng</h5>
        </div>
        <div class="card-body">
          <div class="row">
            <div class="col-md-6">
              <div class="mb-3">
                <label class="form-label fw-bold">Mã hợp đồng</label>
                <p class="form-control-plaintext">#${contractWithEquipment.contract.contractId}</p>
              </div>
              <div class="mb-3">
                <label class="form-label fw-bold">Khách hàng</label>
                <p class="form-control-plaintext">
                  <i class="bi bi-person-circle me-1"></i>${fn:escapeXml(contractWithEquipment.customerName)}
                </p>
              </div>
              <div class="mb-3">
                <label class="form-label fw-bold">Loại hợp đồng</label>
                <p class="form-control-plaintext">${fn:escapeXml(contractWithEquipment.contract.contractType)}</p>
              </div>
            </div>
            <div class="col-md-6">
              <div class="mb-3">
                <label class="form-label fw-bold">Trạng thái</label>
                <p class="form-control-plaintext">
                  <c:set var="status" value="${contractWithEquipment.contract.status}"/>
                  <c:choose>
                    <c:when test="${status == 'Active'}">
                      <span class="badge bg-success">Đang hiệu lực</span>
                    </c:when>
                    <c:when test="${status == 'Completed'}">
                      <span class="badge bg-primary">Đã hoàn thành</span>
                    </c:when>
                    <c:when test="${status == 'Cancelled'}">
                      <span class="badge bg-danger">Đã hủy</span>
                    </c:when>
                    <c:otherwise>
                      <span class="badge bg-dark">${contractWithEquipment.contract.status}</span>
                    </c:otherwise>
                  </c:choose>
                </p>
              </div>
              <div class="mb-3">
                <label class="form-label fw-bold">Ngày ký</label>
                <p class="form-control-plaintext">
                  <i class="bi bi-calendar-event me-1"></i>${contractWithEquipment.contract.contractDate}
                </p>
              </div>
            </div>
          </div>
          
          <div class="mb-3">
            <label class="form-label fw-bold">Chi tiết</label>
            <div class="border rounded p-3 bg-light">
              <c:choose>
                <c:when test="${contractWithEquipment.contract.details != null && !contractWithEquipment.contract.details.isEmpty()}">
                  <p class="mb-0">${fn:escapeXml(contractWithEquipment.contract.details)}</p>
                </c:when>
                <c:otherwise>
                  <p class="mb-0 text-muted">Không có chi tiết</p>
                </c:otherwise>
              </c:choose>
            </div>
          </div>
        </div>
      </div>
      
      <!-- Equipment Information -->
      <div class="card crm-card-shadow mt-3">
        <div class="card-header d-flex justify-content-between align-items-center">
          <h5 class="mb-0">Thiết bị liên kết</h5>
          <c:choose>
            <c:when test="${contractWithEquipment.equipment != null}">
              <span class="badge bg-success">1 thiết bị</span>
            </c:when>
            <c:otherwise>
              <span class="badge bg-secondary">Không có thiết bị</span>
            </c:otherwise>
          </c:choose>
        </div>
        <div class="card-body">
          <c:choose>
            <c:when test="${contractWithEquipment.equipment != null}">
              <div class="row">
                <div class="col-md-6">
                  <div class="mb-3">
                    <label class="form-label fw-bold">Mã thiết bị</label>
                    <p class="form-control-plaintext">#${contractWithEquipment.equipment.equipmentId}</p>
                  </div>
                  <div class="mb-3">
                    <label class="form-label fw-bold">Mẫu thiết bị</label>
                    <p class="form-control-plaintext">${fn:escapeXml(contractWithEquipment.equipment.model)}</p>
                  </div>
                  <div class="mb-3">
                    <label class="form-label fw-bold">Số seri</label>
                    <p class="form-control-plaintext"><code class="text-primary">${fn:escapeXml(contractWithEquipment.equipment.serialNumber)}</code></p>
                  </div>
                </div>
                <div class="col-md-6">
                  <div class="mb-3">
                    <label class="form-label fw-bold">Trạng thái</label>
                    <p class="form-control-plaintext">
                      <c:choose>
                        <c:when test="${contractWithEquipment.equipment.status == 'InUse'}">
                          <span class="badge bg-warning">Đang sử dụng</span>
                        </c:when>
                        <c:when test="${contractWithEquipment.equipment.status == 'Available'}">
                          <span class="badge bg-success">Sẵn sàng</span>
                        </c:when>
                        <c:when test="${contractWithEquipment.equipment.status == 'Faulty'}">
                          <span class="badge bg-danger">Hỏng</span>
                        </c:when>
                        <c:when test="${contractWithEquipment.equipment.status == 'Retired'}">
                          <span class="badge bg-secondary">Ngưng sử dụng</span>
                        </c:when>
                        <c:otherwise>
                          <span class="badge bg-light text-dark">${contractWithEquipment.equipment.status}</span>
                        </c:otherwise>
                      </c:choose>
                    </p>
                  </div>
                  <div class="mb-3">
                    <label class="form-label fw-bold">Vị trí</label>
                    <p class="form-control-plaintext">
                      <c:choose>
                        <c:when test="${contractWithEquipment.equipment.location != null && !contractWithEquipment.equipment.location.isEmpty()}">
                          <i class="bi bi-geo-alt me-1"></i>${fn:escapeXml(contractWithEquipment.equipment.location)}
                        </c:when>
                        <c:otherwise>
                          <span class="text-muted">Không xác định</span>
                        </c:otherwise>
                      </c:choose>
                    </p>
                  </div>
                  <div class="mb-3">
                    <label class="form-label fw-bold">Đơn giá</label>
                    <p class="form-control-plaintext">$${contractWithEquipment.equipment.unitPrice}</p>
                  </div>
                </div>
              </div>
              
              <c:if test="${contractWithEquipment.equipment.description != null && !contractWithEquipment.equipment.description.isEmpty()}">
                <div class="mb-3">
                  <label class="form-label fw-bold">Mô tả</label>
                  <div class="border rounded p-3 bg-light">
                    <p class="mb-0">${fn:escapeXml(contractWithEquipment.equipment.description)}</p>
                  </div>
                </div>
              </c:if>
            </c:when>
            <c:otherwise>
              <div class="text-center py-4">
                <div class="text-muted">
                  <i class="bi bi-gear fs-1 d-block mb-2"></i>
                  <p>Không có thiết bị liên kết với hợp đồng này</p>
                  <small>Hợp đồng này được tạo mà không gán thiết bị</small>
                </div>
              </div>
            </c:otherwise>
          </c:choose>
        </div>
      </div>
    </div>
    
    <div class="col-lg-4">
      <div class="card crm-card-shadow">
        <div class="card-header">
          <h5 class="mb-0">Tóm tắt hợp đồng</h5>
        </div>
        <div class="card-body">
          <div class="mb-3">
            <label class="form-label fw-bold">Tổng số thiết bị</label>
            <p class="form-control-plaintext fs-5">
              <c:choose>
                <c:when test="${contractWithEquipment.equipment != null}">1 thiết bị</c:when>
                <c:otherwise>0 thiết bị</c:otherwise>
              </c:choose>
            </p>
          </div>
          
          <c:if test="${contractWithEquipment.equipment != null}">
            <div class="mb-3">
              <label class="form-label fw-bold">Chi tiết thiết bị trong hợp đồng</label>
              <div class="border rounded p-2 bg-light">
                <div class="d-flex justify-content-between mb-1">
                  <small>Thiết bị #${contractWithEquipment.equipment.equipmentId}</small>
                  <small class="text-muted">SL: ${contractWithEquipment.quantity}</small>
                </div>
                <c:if test="${contractWithEquipment.price != null}">
                  <div class="d-flex justify-content-between">
                    <small>Giá:</small>
                    <small class="fw-bold">$${contractWithEquipment.price}</small>
                  </div>
                </c:if>
              </div>
            </div>
          </c:if>
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
            <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/technician/contracts?action=equipment">
              <i class="bi bi-gear me-1"></i>Xem tất cả thiết bị
            </a>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
