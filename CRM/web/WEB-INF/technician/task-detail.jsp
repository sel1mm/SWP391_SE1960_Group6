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
          <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/technician/tasks">Tasks</a></li>
          <li class="breadcrumb-item active">Task #${task.taskId}</li>
        </ol>
      </nav>
      <h1 class="h4 crm-page-title mt-2">Task Details</h1>
    </div>
    <div class="col-auto">
      <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/technician/tasks">
        <i class="bi bi-arrow-left me-1"></i>Back to Tasks
      </a>
      <button class="btn btn-primary" onclick="showStatusUpdateModal(${task.taskId}, '${task.status}')">
        <i class="bi bi-pencil me-1"></i>Update Status
      </button>
    </div>
  </div>

  <div class="row">
    <div class="col-lg-8">
      <div class="card crm-card-shadow">
        <div class="card-header">
          <h5 class="mb-0">Task Information</h5>
        </div>
        <div class="card-body">
          <div class="row">
            <div class="col-md-6">
              <div class="mb-3">
                <label class="form-label fw-bold">Task ID</label>
                <p class="form-control-plaintext">#${task.taskId}</p>
              </div>
              <div class="mb-3">
                <label class="form-label fw-bold">Task Type</label>
                <p class="form-control-plaintext">${fn:escapeXml(task.taskType)}</p>
              </div>
              <div class="mb-3">
                <label class="form-label fw-bold">Status</label>
                <p class="form-control-plaintext">
                  <c:set var="status" value="${task.status}"/>
                  <c:choose>
                    <c:when test="${status == 'Pending'}">
                      <span class="badge bg-warning">Pending</span>
                    </c:when>
                    <c:when test="${status == 'Assigned'}">
                      <span class="badge bg-info">Assigned</span>
                    </c:when>
                    <c:when test="${status == 'In Progress'}">
                      <span class="badge bg-primary">In Progress</span>
                    </c:when>
                    <c:when test="${status == 'Completed'}">
                      <span class="badge bg-success">Completed</span>
                    </c:when>
                    <c:when test="${status == 'On Hold'}">
                      <span class="badge bg-secondary">On Hold</span>
                    </c:when>
                    <c:when test="${status == 'Cancelled'}">
                      <span class="badge bg-danger">Cancelled</span>
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
                <label class="form-label fw-bold">Request ID</label>
                <p class="form-control-plaintext">
                  <c:choose>
                    <c:when test="${task.requestId != null}">
                      <a href="#" class="text-decoration-none">#${task.requestId}</a>
                    </c:when>
                    <c:otherwise>
                      <span class="text-muted">Not linked</span>
                    </c:otherwise>
                  </c:choose>
                </p>
              </div>
              <div class="mb-3">
                <label class="form-label fw-bold">Schedule ID</label>
                <p class="form-control-plaintext">
                  <c:choose>
                    <c:when test="${task.scheduleId != null}">
                      <a href="#" class="text-decoration-none">#${task.scheduleId}</a>
                    </c:when>
                    <c:otherwise>
                      <span class="text-muted">Not scheduled</span>
                    </c:otherwise>
                  </c:choose>
                </p>
              </div>
              <div class="mb-3">
                <label class="form-label fw-bold">Technician ID</label>
                <p class="form-control-plaintext">#${task.technicianId}</p>
              </div>
            </div>
          </div>
          
          <div class="mb-3">
            <label class="form-label fw-bold">Task Details</label>
            <div class="border rounded p-3 bg-light">
              <c:choose>
                <c:when test="${task.taskDetails != null && !task.taskDetails.isEmpty()}">
                  <p class="mb-0">${fn:escapeXml(task.taskDetails)}</p>
                </c:when>
                <c:otherwise>
                  <p class="mb-0 text-muted">No details provided</p>
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
            <label class="form-label fw-bold">Start Date</label>
            <p class="form-control-plaintext">
              <c:choose>
                <c:when test="${task.startDate != null}">
                  <i class="bi bi-calendar-event me-1"></i>${task.startDate}
                </c:when>
                <c:otherwise>
                  <span class="text-muted">Not set</span>
                </c:otherwise>
              </c:choose>
            </p>
          </div>
          <div class="mb-3">
            <label class="form-label fw-bold">End Date</label>
            <p class="form-control-plaintext">
              <c:choose>
                <c:when test="${task.endDate != null}">
                  <i class="bi bi-calendar-event me-1"></i>${task.endDate}
                </c:when>
                <c:otherwise>
                  <span class="text-muted">Not set</span>
                </c:otherwise>
              </c:choose>
            </p>
          </div>
        </div>
      </div>
      
      <div class="card crm-card-shadow mt-3">
        <div class="card-header">
          <h5 class="mb-0">Quick Actions</h5>
        </div>
        <div class="card-body">
          <div class="d-grid gap-2">
            <button class="btn btn-primary" onclick="showStatusUpdateModal(${task.taskId}, '${task.status}')">
              <i class="bi bi-pencil me-1"></i>Update Status
            </button>
            <c:if test="${task.requestId != null}">
              <a class="btn btn-outline-primary" href="${pageContext.request.contextPath}/technician/reports?action=create&requestId=${task.requestId}">
                <i class="bi bi-clipboard-plus me-1"></i>Create Report
              </a>
            </c:if>
            <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/technician/contracts">
              <i class="bi bi-file-earmark-text me-1"></i>View Contracts
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
        <h5 class="modal-title" id="statusUpdateModalLabel">Update Task Status</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <form method="post" action="${pageContext.request.contextPath}/technician/tasks">
        <div class="modal-body">
          <input type="hidden" name="action" value="updateStatus">
          <input type="hidden" name="taskId" id="modalTaskId">
          <div class="mb-3">
            <label for="statusSelect" class="form-label">New Status</label>
            <select class="form-select" name="status" id="statusSelect" required>
              <option value="">Select Status</option>
              <option value="Pending">Pending</option>
              <option value="Assigned">Assigned</option>
              <option value="In Progress">In Progress</option>
              <option value="Completed">Completed</option>
              <option value="On Hold">On Hold</option>
              <option value="Cancelled">Cancelled</option>
            </select>
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
          <button type="submit" class="btn btn-primary">Update Status</button>
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
