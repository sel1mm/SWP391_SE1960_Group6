<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<div class="container-fluid">
  <div class="row mb-3 align-items-center">
    <div class="col">
      <h1 class="h4 crm-page-title">Work History</h1>
      <p class="text-muted mb-0">View your completed and past work assignments</p>
    </div>
    <div class="col-auto">
      <span class="badge bg-primary">Total: ${totalCount} tasks</span>
    </div>
  </div>

  <!-- Filter Section -->
  <div class="card crm-card-shadow mb-3">
    <div class="card-body">
      <form class="row g-2 align-items-center" method="get" action="${pageContext.request.contextPath}/technician/work-history">
        <div class="col-md-3">
          <label class="form-label small">Status</label>
          <select class="form-select form-select-sm" name="status">
            <option value="">All Statuses</option>
            <option value="Completed" ${param.status == 'Completed' ? 'selected' : ''}>Completed</option>
            <option value="In Progress" ${param.status == 'In Progress' ? 'selected' : ''}>In Progress</option>
            <option value="Pending" ${param.status == 'Pending' ? 'selected' : ''}>Pending</option>
            <option value="On Hold" ${param.status == 'On Hold' ? 'selected' : ''}>On Hold</option>
          </select>
        </div>
        <div class="col-md-3">
          <label class="form-label small">Start Date</label>
          <input type="date" name="startDate" value="${param.startDate}" class="form-control form-control-sm"/>
        </div>
        <div class="col-md-3">
          <label class="form-label small">End Date</label>
          <input type="date" name="endDate" value="${param.endDate}" class="form-control form-control-sm"/>
        </div>
        <div class="col-md-3">
          <label class="form-label small">&nbsp;</label>
          <div class="d-flex gap-2">
            <button class="btn btn-secondary btn-sm" type="submit"><i class="bi bi-search me-1"></i>Filter</button>
            <a class="btn btn-outline-secondary btn-sm" href="${pageContext.request.contextPath}/technician/work-history">Clear</a>
          </div>
        </div>
      </form>
    </div>
  </div>

  <!-- Work History Table -->
  <div class="card crm-card-shadow">
    <div class="card-header d-flex justify-content-between align-items-center">
      <h6 class="mb-0">Work History</h6>
      <small class="text-muted">Page ${currentPage} of ${totalPages}</small>
    </div>
    <div class="table-responsive">
      <table class="table align-middle mb-0">
        <thead class="table-light">
          <tr>
            <th>#</th>
            <th>Task ID</th>
            <th>Title</th>
            <th class="d-none d-md-table-cell">Description</th>
            <th>Status</th>
            <th>Priority</th>
            <th>Assigned Date</th>
            <th>Due Date</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
        <c:choose>
          <c:when test="${not empty workHistory}">
            <c:forEach var="task" items="${workHistory}" varStatus="st">
              <tr>
                <td>${(currentPage - 1) * pageSize + st.index + 1}</td>
                <td>${task.id}</td>
                <td><strong>${fn:escapeXml(task.title)}</strong></td>
                <td class="d-none d-md-table-cell">
                  <div class="text-truncate-2" style="max-width:300px;">${fn:escapeXml(task.description)}</div>
                </td>
                <td>
                  <c:set var="_s" value="${task.status}"/>
                  <c:choose>
                    <c:when test="${_s == 'Completed'}"><span class="badge badge-status-completed">Completed</span></c:when>
                    <c:when test="${_s == 'In Progress'}"><span class="badge badge-status-inprogress">In Progress</span></c:when>
                    <c:when test="${_s == 'Pending'}"><span class="badge badge-status-pending">Pending</span></c:when>
                    <c:when test="${_s == 'On Hold'}"><span class="badge badge-status-onhold">On Hold</span></c:when>
                    <c:otherwise><span class="badge bg-secondary">${task.status}</span></c:otherwise>
                  </c:choose>
                </td>
                <td>
                  <c:choose>
                    <c:when test="${task.priority == 'High'}"><span class="text-danger"><i class="bi bi-exclamation-triangle-fill"></i> High</span></c:when>
                    <c:when test="${task.priority == 'Medium'}"><span class="text-warning"><i class="bi bi-exclamation-circle-fill"></i> Medium</span></c:when>
                    <c:otherwise><span class="text-muted"><i class="bi bi-dash-circle"></i> Low</span></c:otherwise>
                  </c:choose>
                </td>
                <td>
                  <small class="text-muted">${task.assignedDate}</small>
                </td>
                <td>
                  <small class="text-muted">${task.dueDate}</small>
                </td>
                <td class="text-end">
                  <a class="btn btn-sm btn-outline-primary" href="${pageContext.request.contextPath}/technician/task?id=${task.id}">
                    <i class="bi bi-eye"></i> View
                  </a>
                </td>
              </tr>
            </c:forEach>
          </c:when>
          <c:otherwise>
            <tr>
              <td colspan="9" class="text-center py-4">
                <div class="text-muted">
                  <i class="bi bi-inbox display-4"></i>
                  <p class="mt-2">No work history found</p>
                  <small>Try adjusting your filters or check back later.</small>
                </div>
              </td>
            </tr>
          </c:otherwise>
        </c:choose>
        </tbody>
      </table>
    </div>
  </div>

  <!-- Pagination -->
  <c:if test="${totalPages > 1}">
    <nav aria-label="Work history pagination" class="mt-3">
      <ul class="pagination justify-content-center">
        <c:if test="${currentPage > 1}">
          <li class="page-item">
            <a class="page-link" href="?page=${currentPage - 1}&status=${param.status}&startDate=${param.startDate}&endDate=${param.endDate}">Previous</a>
          </li>
        </c:if>
        
        <c:forEach var="i" begin="${Math.max(1, currentPage - 2)}" end="${Math.min(totalPages, currentPage + 2)}">
          <li class="page-item ${i == currentPage ? 'active' : ''}">
            <a class="page-link" href="?page=${i}&status=${param.status}&startDate=${param.startDate}&endDate=${param.endDate}">${i}</a>
          </li>
        </c:forEach>
        
        <c:if test="${currentPage < totalPages}">
          <li class="page-item">
            <a class="page-link" href="?page=${currentPage + 1}&status=${param.status}&startDate=${param.startDate}&endDate=${param.endDate}">Next</a>
          </li>
        </c:if>
      </ul>
    </nav>
  </c:if>
</div>
