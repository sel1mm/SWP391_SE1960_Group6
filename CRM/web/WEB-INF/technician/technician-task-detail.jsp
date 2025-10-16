<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<div class="container-fluid">
  <nav aria-label="breadcrumb" class="mb-3">
    <ol class="breadcrumb">
      <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/technician/dashboard">Dashboard</a></li>
      <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/technician/tasks">Tasks</a></li>
      <li class="breadcrumb-item active" aria-current="page">#${task.id}</li>
    </ol>
  </nav>

  <div class="row g-3">
    <div class="col-lg-8">
      <div class="card crm-card-shadow">
        <div class="card-body">
          <div class="d-flex justify-content-between align-items-start">
            <h1 class="h4 mb-0">${fn:escapeXml(task.title)}</h1>
            <c:set var="_s" value="${task.status}"/>
            <c:choose>
              <c:when test="${_s == 'Pending'}"><span class="badge badge-status-pending" data-task-status-badge="${task.id}">Pending</span></c:when>
              <c:when test="${_s == 'In Progress'}"><span class="badge badge-status-inprogress" data-task-status-badge="${task.id}">In Progress</span></c:when>
              <c:when test="${_s == 'Completed'}"><span class="badge badge-status-completed" data-task-status-badge="${task.id}">Completed</span></c:when>
              <c:when test="${_s == 'On Hold'}"><span class="badge badge-status-onhold" data-task-status-badge="${task.id}">On Hold</span></c:when>
              <c:otherwise><span class="badge bg-secondary" data-task-status-badge="${task.id}">${task.status}</span></c:otherwise>
            </c:choose>
          </div>
          <div class="text-muted small mt-2">
            <span class="me-3"><i class="bi bi-flag"></i> ${task.priority}</span>
            <span class="me-3"><i class="bi bi-calendar-date"></i> Due: ${task.dueDate}</span>
            <span><i class="bi bi-clock"></i> Assigned: ${task.assignedDate}</span>
          </div>
          <hr/>
          <div style="white-space: pre-wrap;">${fn:escapeXml(task.description)}</div>
        </div>
      </div>

      <div class="card crm-card-shadow mt-3">
        <div class="card-header">Activity</div>
        <div class="card-body">
          <c:choose>
            <c:when test="${not empty activity}">
              <ul class="list-group list-group-flush">
                <c:forEach var="a" items="${activity}">
                  <li class="list-group-item">${fn:escapeXml(a)}</li>
                </c:forEach>
              </ul>
            </c:when>
            <c:otherwise>
              <c:if test="${param.dev == 'true'}">
                <ul class="list-group list-group-flush">
                  <li class="list-group-item">Status changed to In Progress on 2025-10-12</li>
                  <li class="list-group-item">Task assigned to you on 2025-10-10</li>
                </ul>
              </c:if>
            </c:otherwise>
          </c:choose>
        </div>
      </div>
    </div>

    <div class="col-lg-4">
      <div class="card crm-card-shadow">
        <div class="card-header">Equipment Needed</div>
        <div class="card-body">
          <c:choose>
            <c:when test="${not empty task.equipmentNeeded}">
              <div>${fn:escapeXml(task.equipmentNeeded)}</div>
            </c:when>
            <c:otherwise><span class="text-muted">None specified</span></c:otherwise>
          </c:choose>
        </div>
      </div>

      <div class="card crm-card-shadow mt-3">
        <div class="card-header">Quick Actions</div>
        <div class="card-body d-grid gap-2">
          <a class="btn btn-primary" href="#update-status" data-bs-toggle="modal" data-bs-target="#updateStatusModal"><i class="bi bi-pencil me-1"></i> Update Status</a>
          <a class="btn btn-outline-primary" href="${pageContext.request.contextPath}/technician/contracts?taskId=${task.id}"><i class="bi bi-file-earmark-plus me-1"></i> Create Contract</a>
          <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/technician/reports?taskId=${task.id}"><i class="bi bi-clipboard-plus me-1"></i> Submit Report</a>
        </div>
      </div>
    </div>
  </div>
</div>

<jsp:include page="/technician/task-update-form.jsp"/>


