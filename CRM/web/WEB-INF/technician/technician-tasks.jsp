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
      <h1 class="h4 crm-page-title">My Tasks</h1>
      <p class="text-muted">Tasks assigned to you by the Technical Manager</p>
    </div>
    <div class="col-auto">
      <a class="btn btn-outline-primary" href="${pageContext.request.contextPath}/technician/contracts"><i class="bi bi-file-earmark-text me-1"></i>View Contracts</a>
      <a class="btn btn-primary" href="${pageContext.request.contextPath}/technician/reports?action=create"><i class="bi bi-clipboard-plus me-1"></i>New Report</a>
    </div>
  </div>

  <div class="card crm-card-shadow">
    <div class="card-body">
      <form id="taskSearchForm" class="row g-2 align-items-center" method="get" action="${pageContext.request.contextPath}/technician/tasks">
        <div class="col-12 col-md-6">
          <input type="text" name="q" value="${param.q}" class="form-control" placeholder="Search by task type, details, or ID"/>
        </div>
        <div class="col-6 col-md-3">
          <select class="form-select" name="status">
            <option value="">All Statuses</option>
            <option value="Pending" ${param.status == 'Pending' ? 'selected' : ''}>Pending</option>
            <option value="Assigned" ${param.status == 'Assigned' ? 'selected' : ''}>Assigned</option>
            <option value="In Progress" ${param.status == 'In Progress' ? 'selected' : ''}>In Progress</option>
            <option value="Completed" ${param.status == 'Completed' ? 'selected' : ''}>Completed</option>
            <option value="On Hold" ${param.status == 'On Hold' ? 'selected' : ''}>On Hold</option>
            <option value="Cancelled" ${param.status == 'Cancelled' ? 'selected' : ''}>Cancelled</option>
          </select>
        </div>
        <div class="col-6 col-md-3 text-end">
          <button class="btn btn-secondary" type="submit"><i class="bi bi-search me-1"></i>Search</button>
        </div>
      </form>
    </div>
  </div>

  <div class="card mt-3 crm-card-shadow">
    <div class="card-header d-flex justify-content-between align-items-center">
      <h5 class="mb-0">Task List</h5>
      <span class="badge bg-primary">${totalTasks} tasks</span>
    </div>
    <div class="table-responsive">
      <table class="table align-middle mb-0">
        <thead class="table-light">
          <tr>
            <th>#</th>
            <th>Task ID</th>
            <th>Customer</th>
            <th>Task Type</th>
            <th class="d-none d-md-table-cell">Details</th>
            <th>Status</th>
            <th>Start Date</th>
            <th>End Date</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody id="tasks-table-body">
        <c:choose>
          <c:when test="${not empty tasksWithCustomer}">
            <c:forEach var="taskWithCustomer" items="${tasksWithCustomer}" varStatus="st">
              <tr>
                <td>${(currentPage - 1) * pageSize + st.index + 1}</td>
                <td><strong>#${taskWithCustomer.task.taskId}</strong></td>
                <td>
                  <c:choose>
                    <c:when test="${taskWithCustomer.customerName != null}">
                      <div class="fw-bold">${fn:escapeXml(taskWithCustomer.customerName)}</div>
                      <small class="text-muted">ID: ${taskWithCustomer.customerId}</small>
                    </c:when>
                    <c:otherwise>
                      <span class="text-muted">No customer assigned</span>
                    </c:otherwise>
                  </c:choose>
                </td>
                <td>${fn:escapeXml(taskWithCustomer.task.taskType)}</td>
                <td class="d-none d-md-table-cell">
                  <div class="text-truncate" style="max-width:300px;" title="${fn:escapeXml(taskWithCustomer.task.taskDetails)}">
                    ${fn:escapeXml(taskWithCustomer.task.taskDetails)}
                  </div>
                </td>
                <td>
                  <c:set var="status" value="${taskWithCustomer.task.status}"/>
                  <c:choose>
                    <c:when test="${status == 'Pending'}">
                      <span class="badge bg-warning" data-task-status-badge="${taskWithCustomer.task.taskId}">Pending</span>
                    </c:when>
                    <c:when test="${status == 'Assigned'}">
                      <span class="badge bg-info" data-task-status-badge="${taskWithCustomer.task.taskId}">Assigned</span>
                    </c:when>
                    <c:when test="${status == 'In Progress'}">
                      <span class="badge bg-primary" data-task-status-badge="${taskWithCustomer.task.taskId}">In Progress</span>
                    </c:when>
                    <c:when test="${status == 'Completed'}">
                      <span class="badge bg-success" data-task-status-badge="${taskWithCustomer.task.taskId}">Completed</span>
                    </c:when>
                    <c:when test="${status == 'On Hold'}">
                      <span class="badge bg-secondary" data-task-status-badge="${taskWithCustomer.task.taskId}">On Hold</span>
                    </c:when>
                    <c:when test="${status == 'Cancelled'}">
                      <span class="badge bg-danger" data-task-status-badge="${taskWithCustomer.task.taskId}">Cancelled</span>
                    </c:when>
                    <c:otherwise>
                      <span class="badge bg-dark" data-task-status-badge="${taskWithCustomer.task.taskId}">${taskWithCustomer.task.status}</span>
                    </c:otherwise>
                  </c:choose>
                </td>
                <td>
                  <c:choose>
                    <c:when test="${taskWithCustomer.task.startDate != null}">
                      ${taskWithCustomer.task.startDate}
                    </c:when>
                    <c:otherwise>
                      <span class="text-muted">Not set</span>
                    </c:otherwise>
                  </c:choose>
                </td>
                <td>
                  <c:choose>
                    <c:when test="${taskWithCustomer.task.endDate != null}">
                      ${taskWithCustomer.task.endDate}
                    </c:when>
                    <c:otherwise>
                      <span class="text-muted">Not set</span>
                    </c:otherwise>
                  </c:choose>
                </td>
                <td class="text-end">
                  <a class="btn btn-sm btn-outline-secondary" href="${pageContext.request.contextPath}/technician/tasks?action=detail&taskId=${taskWithCustomer.task.taskId}" title="View Details">
                    <i class="bi bi-eye"></i>
                  </a>
                  <button class="btn btn-sm btn-primary" onclick="showStatusUpdateModal(${taskWithCustomer.task.taskId}, '${taskWithCustomer.task.status}')" title="Update Status">
                    <i class="bi bi-pencil"></i>
                  </button>
                </td>
              </tr>
            </c:forEach>
          </c:when>
          <c:otherwise>
            <tr>
              <td colspan="9" class="text-center py-4">
                <div class="text-muted">
                  <i class="bi bi-inbox fs-1 d-block mb-2"></i>
                  <p>No tasks found</p>
                  <small>Tasks assigned to you will appear here</small>
                </div>
              </td>
            </tr>
          </c:otherwise>
        </c:choose>
        </tbody>
      </table>
    </div>
    
    <!-- Pagination -->
    <c:if test="${totalPages > 1}">
      <div class="card-footer">
        <nav aria-label="Task pagination">
          <ul class="pagination pagination-sm justify-content-center mb-0">
            <c:if test="${currentPage > 1}">
              <li class="page-item">
                <a class="page-link" href="${pageContext.request.contextPath}/technician/tasks?page=${currentPage - 1}&q=${param.q}&status=${param.status}">Previous</a>
              </li>
            </c:if>
            
            <c:forEach begin="1" end="${totalPages}" var="pageNum">
              <c:if test="${pageNum >= currentPage - 2 && pageNum <= currentPage + 2}">
                <li class="page-item ${pageNum == currentPage ? 'active' : ''}">
                  <a class="page-link" href="${pageContext.request.contextPath}/technician/tasks?page=${pageNum}&q=${param.q}&status=${param.status}">${pageNum}</a>
                </li>
              </c:if>
            </c:forEach>
            
            <c:if test="${currentPage < totalPages}">
              <li class="page-item">
                <a class="page-link" href="${pageContext.request.contextPath}/technician/tasks?page=${currentPage + 1}&q=${param.q}&status=${param.status}">Next</a>
              </li>
            </c:if>
          </ul>
        </nav>
      </div>
    </c:if>
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
