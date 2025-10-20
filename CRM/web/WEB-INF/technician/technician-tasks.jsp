<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<div class="container-fluid">
  <div class="row mb-3 align-items-center">
    <div class="col">
      <h1 class="h4 crm-page-title">Assigned Tasks</h1>
    </div>
    <div class="col-auto">
      <a class="btn btn-outline-primary" href="${pageContext.request.contextPath}/technician/contracts"><i class="bi bi-file-earmark-plus me-1"></i>New Contract</a>
      <a class="btn btn-primary" href="${pageContext.request.contextPath}/technician/reports"><i class="bi bi-clipboard-plus me-1"></i>New Report</a>
    </div>
  </div>

  <div class="card crm-card-shadow">
    <div class="card-body">
      <form id="taskSearchForm" class="row g-2 align-items-center" method="get" action="${pageContext.request.contextPath}/technician/tasks">
        <div class="col-12 col-md-6">
          <input type="text" name="q" value="${param.q}" class="form-control" placeholder="Search by title or ID"/>
        </div>
        <div class="col-6 col-md-3">
          <select class="form-select" name="status">
            <option value="">All Statuses</option>
            <option value="Pending" ${param.status == 'Pending' ? 'selected' : ''}>Pending</option>
            <option value="In Progress" ${param.status == 'In Progress' ? 'selected' : ''}>In Progress</option>
            <option value="Completed" ${param.status == 'Completed' ? 'selected' : ''}>Completed</option>
            <option value="On Hold" ${param.status == 'On Hold' ? 'selected' : ''}>On Hold</option>
          </select>
        </div>
        <div class="col-6 col-md-3 text-end">
          <button class="btn btn-secondary" type="submit"><i class="bi bi-search me-1"></i>Search</button>
        </div>
      </form>
    </div>
  </div>

  <div class="card mt-3 crm-card-shadow">
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
            <th>Due Date</th>
            <th></th>
          </tr>
        </thead>
        <tbody id="tasks-table-body">
        <c:choose>
          <c:when test="${not empty tasks}">
            <c:forEach var="t" items="${tasks}" varStatus="st">
              <tr>
                <td>${st.index + 1}</td>
                <td>${t.id}</td>
                <td><a href="${pageContext.request.contextPath}/technician/task-detail?id=${t.id}">${fn:escapeXml(t.title)}</a></td>
                <td class="d-none d-md-table-cell"><div class="text-truncate-2" style="max-width:420px;">${fn:escapeXml(t.description)}</div></td>
                <td>
                  <c:set var="_s" value="${t.status}"/>
                  <c:choose>
                    <c:when test="${_s == 'Pending'}"><span class="badge badge-status-pending" data-task-status-badge="${t.id}">Pending</span></c:when>
                    <c:when test="${_s == 'In Progress'}"><span class="badge badge-status-inprogress" data-task-status-badge="${t.id}">In Progress</span></c:when>
                    <c:when test="${_s == 'Completed'}"><span class="badge badge-status-completed" data-task-status-badge="${t.id}">Completed</span></c:when>
                    <c:when test="${_s == 'On Hold'}"><span class="badge badge-status-onhold" data-task-status-badge="${t.id}">On Hold</span></c:when>
                    <c:otherwise><span class="badge bg-secondary" data-task-status-badge="${t.id}">${t.status}</span></c:otherwise>
                  </c:choose>
                </td>
                <td>
                  <c:choose>
                    <c:when test="${t.priority == 'High'}"><span class="text-danger"><i class="bi bi-exclamation-triangle-fill"></i> High</span></c:when>
                    <c:when test="${t.priority == 'Medium'}"><span class="text-warning"><i class="bi bi-exclamation-circle-fill"></i> Medium</span></c:when>
                    <c:otherwise><span class="text-muted"><i class="bi bi-dash-circle"></i> Low</span></c:otherwise>
                  </c:choose>
                </td>
                <td>${t.dueDate}</td>
                <td class="text-end">
                  <a class="btn btn-sm btn-outline-secondary" href="${pageContext.request.contextPath}/technician/task?id=${t.id}"><i class="bi bi-eye"></i></a>
                  <a class="btn btn-sm btn-primary" href="${pageContext.request.contextPath}/technician/task?id=${t.id}#update-status"><i class="bi bi-pencil"></i></a>
                </td>
              </tr>
            </c:forEach>
          </c:when>
          <c:otherwise>
            <c:if test="${param.dev == 'true'}">
              <c:forEach var="i" begin="1" end="8">
                <tr>
                  <td>${i}</td>
                  <td>${1000 + i}</td>
                  <td><a href="#">Mock Task ${i}</a></td>
                  <td class="d-none d-md-table-cell"><div class="text-truncate-2" style="max-width:420px;">This is a mock task description for UI testing.</div></td>
                  <td><span class="badge badge-status-inprogress">In Progress</span></td>
                  <td><span class="text-warning"><i class="bi bi-exclamation-circle-fill"></i> Medium</span></td>
                  <td>2025-10-20</td>
                  <td class="text-end">
                    <a class="btn btn-sm btn-outline-secondary" href="#"><i class="bi bi-eye"></i></a>
                    <button class="btn btn-sm btn-primary" type="button"><i class="bi bi-pencil"></i></button>
                  </td>
                </tr>
              </c:forEach>
            </c:if>
          </c:otherwise>
        </c:choose>
        </tbody>
      </table>
    </div>
  </div>
</div>


