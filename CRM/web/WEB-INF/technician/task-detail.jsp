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
          <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/technician/tasks">Công việc</a></li>
          <li class="breadcrumb-item active">Công việc #${task.taskId}</li>
        </ol>
      </nav>
      <h1 class="h4 crm-page-title mt-2">Chi tiết công việc</h1>
    </div>
    <div class="col-auto">
      <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/technician/tasks">
        <i class="bi bi-arrow-left me-1"></i>Quay lại công việc
      </a>
      <button class="btn btn-primary" onclick="showStatusUpdateModal(${task.taskId}, '${task.status}')">
        <i class="bi bi-pencil me-1"></i>Cập nhật trạng thái
      </button>
    </div>
  </div>

  <div class="row">
    <div class="col-lg-8">
      <div class="card crm-card-shadow">
        <div class="card-header">
          <h5 class="mb-0">Thông tin công việc</h5>
        </div>
        <div class="card-body">
          <div class="row">
            <div class="col-md-6">
              <div class="mb-3">
                <label class="form-label fw-bold">Mã công việc</label>
                <p class="form-control-plaintext">#${task.taskId}</p>
              </div>
              <div class="mb-3">
                <label class="form-label fw-bold">Loại công việc</label>
                <p class="form-control-plaintext">${fn:escapeXml(task.taskType)}</p>
              </div>
              <div class="mb-3">
                <label class="form-label fw-bold">Trạng thái</label>
                <p class="form-control-plaintext">
                  <c:set var="status" value="${task.status}"/>
                  <c:choose>
                    <c:when test="${status == 'Pending'}">
                      <span class="badge bg-warning">Đang chờ</span>
                    </c:when>
                    <c:when test="${status == 'Assigned'}">
                      <span class="badge bg-info">Đã giao</span>
                    </c:when>
                    <c:when test="${status == 'In Progress'}">
                      <span class="badge bg-primary">Đang thực hiện</span>
                    </c:when>
                    <c:when test="${status == 'Completed'}">
                      <span class="badge bg-success">Hoàn thành</span>
                    </c:when>
                    <c:when test="${status == 'Failed'}">
                      <span class="badge bg-danger">Thất bại</span>
                    </c:when>
                    <c:when test="${status == 'On Hold'}">
                      <span class="badge bg-secondary">Tạm hoãn</span>
                    </c:when>
                    <c:when test="${status == 'Cancelled'}">
                      <span class="badge bg-danger">Đã hủy</span>
                    </c:when>
                    <c:otherwise>
                      <span class="badge bg-dark">${task.status}</span>
                    </c:otherwise>
                  </c:choose>
                </p>
              </div>
            </div>
            <div class="col-md-6">
              <div class="mb-3">
                <label class="form-label fw-bold">Mã yêu cầu</label>
                <p class="form-control-plaintext">
                  <c:choose>
                    <c:when test="${task.requestId != null}">
                      <a href="#" class="text-decoration-none">#${task.requestId}</a>
                      <c:if test="${task.scheduleId != null}">
                        <div class="text-muted small">Liên kết từ lịch trình #${task.scheduleId}</div>
                      </c:if>
                    </c:when>
                    <c:otherwise>
                      <span class="text-muted">Chưa liên kết</span>
                    </c:otherwise>
                  </c:choose>
                </p>
              </div>
              <div class="mb-3">
                <label class="form-label fw-bold">Mã lịch trình</label>
                <p class="form-control-plaintext">
                  <c:choose>
                    <c:when test="${task.scheduleId != null}">
                      <a href="#" class="text-decoration-none">#${task.scheduleId}</a>
                    </c:when>
                    <c:otherwise>
                      <span class="text-muted">Chưa lên lịch</span>
                    </c:otherwise>
                  </c:choose>
                </p>
              </div>
              <div class="mb-3">
                <label class="form-label fw-bold">Mã kỹ thuật viên</label>
                <p class="form-control-plaintext">#${task.technicianId}</p>
              </div>
            </div>
          </div>
          
          <div class="mb-3">
            <label class="form-label fw-bold">Chi tiết công việc</label>
            <div class="border rounded p-3 bg-light">
              <c:choose>
                <c:when test="${task.taskDetails != null && !task.taskDetails.isEmpty()}">
                  <p class="mb-0">${fn:escapeXml(task.taskDetails)}</p>
                </c:when>
                <c:otherwise>
                  <p class="mb-0 text-muted">Không có chi tiết</p>
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
          <h5 class="mb-0">Timeline</h5>
        </div>
        <div class="card-body">
          <div class="mb-3">
            <label class="form-label fw-bold">Ngày bắt đầu</label>
            <p class="form-control-plaintext">
              <c:choose>
                <c:when test="${task.startDate != null}">
                  <i class="bi bi-calendar-event me-1"></i>${task.startDate}
                </c:when>
                <c:otherwise>
                  <span class="text-muted">Chưa đặt</span>
                </c:otherwise>
              </c:choose>
            </p>
          </div>
          <div class="mb-3">
            <label class="form-label fw-bold">Ngày kết thúc</label>
            <p class="form-control-plaintext">
              <c:choose>
                <c:when test="${task.endDate != null}">
                  <i class="bi bi-calendar-event me-1"></i>${task.endDate}
                </c:when>
                <c:otherwise>
                  <span class="text-muted">Chưa đặt</span>
                </c:otherwise>
              </c:choose>
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
            <button class="btn btn-primary" onclick="showStatusUpdateModal(${task.taskId}, '${task.status}')">
              <i class="bi bi-pencil me-1"></i>Cập nhật trạng thái
            </button>
            <c:choose>
              <c:when test="${task.requestId != null}">
                <c:choose>
                  <c:when test="${not empty existingReport}">
                    <a class="btn btn-outline-primary" href="${pageContext.request.contextPath}/technician/reports?action=edit&reportId=${existingReport.reportId}">
                      <i class="bi bi-clipboard-check me-1"></i>Chỉnh sửa báo cáo
                    </a>
                  </c:when>
                  <c:otherwise>
                    <a class="btn btn-outline-primary" href="${pageContext.request.contextPath}/technician/reports?action=create&requestId=${task.requestId}">
                      <i class="bi bi-clipboard-plus me-1"></i>Tạo báo cáo
                    </a>
                  </c:otherwise>
                </c:choose>
              </c:when>
              <c:otherwise>
                <%-- Scheduled Tasks (scheduleId != null && requestId == null): Hide Create Repair Report button --%>
                <c:choose>
                  <c:when test="${task.scheduleId != null && task.requestId == null}">
                    <%-- Scheduled Task: No repair report button shown --%>
                  </c:when>
                  <c:when test="${task.scheduleId != null}">
                    <%-- Schedule linked to request: Show report button --%>
                    <c:choose>
                      <c:when test="${not empty existingReport}">
                        <a class="btn btn-outline-primary" href="${pageContext.request.contextPath}/technician/reports?action=edit&reportId=${existingReport.reportId}">
                          <i class="bi bi-clipboard-check me-1"></i>Chỉnh sửa báo cáo
                        </a>
                      </c:when>
                      <c:otherwise>
                        <a class="btn btn-outline-primary" href="${pageContext.request.contextPath}/technician/reports?action=create&scheduleId=${task.scheduleId}">
                          <i class="bi bi-clipboard-plus me-1"></i>Tạo báo cáo
                        </a>
                      </c:otherwise>
                    </c:choose>
                  </c:when>
                  <c:otherwise>
                    <button class="btn btn-outline-secondary" type="button" disabled title="Công việc này không được liên kết với bất kỳ yêu cầu dịch vụ hoặc lịch trình nào">
                      <i class="bi bi-clipboard-x me-1"></i>Báo cáo không khả dụng
                    </button>
                  </c:otherwise>
                </c:choose>
              </c:otherwise>
            </c:choose>
            <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/technician/contracts">
              <i class="bi bi-file-earmark-text me-1"></i>Xem hợp đồng
            </a>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>

<!-- Status Update Modal -->
<div class="modal fade" id="statusUpdateModal" tabindex="-1" aria-labelledby="statusUpdateModalLabel" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="statusUpdateModalLabel">Cập nhật trạng thái công việc</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Đóng"></button>
      </div>
      <form method="post" action="${pageContext.request.contextPath}/technician/tasks">
        <div class="modal-body">
          <input type="hidden" name="action" value="updateStatus">
          <input type="hidden" name="taskId" id="modalTaskId">
          <!-- Preserve filter parameters (if coming from task list) -->
          <input type="hidden" name="q" id="preserveQ" value="">
          <input type="hidden" name="status" id="preserveStatus" value="">
          <input type="hidden" name="page" id="preservePage" value="">
          <div class="mb-3">
            <label for="statusSelect" class="form-label">Trạng thái mới</label>
            <select class="form-select" name="newStatus" id="statusSelect" required>
              <option value="">Chọn trạng thái</option>
              <option value="Pending">Đang chờ</option>
              <option value="Assigned">Đã giao</option>
              <option value="In Progress">Đang thực hiện</option>
              <option value="Completed">Hoàn thành</option>
              <option value="Failed">Thất bại</option>
              <option value="On Hold">Tạm hoãn</option>
              <option value="Cancelled">Đã hủy</option>
            </select>
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
          <button type="submit" class="btn btn-primary">Cập nhật trạng thái</button>
        </div>
      </form>
    </div>
  </div>
</div>

<script>
function showStatusUpdateModal(taskId, currentStatus) {
  document.getElementById('modalTaskId').value = taskId;
  document.getElementById('statusSelect').value = currentStatus;
  new bootstrap.Modal(document.getElementById('statusUpdateModal')).show();
}
</script>
