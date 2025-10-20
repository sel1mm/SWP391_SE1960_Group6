<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<div class="container-fluid">
    <div class="row mb-3 align-items-center">
        <div class="col">
            <h1 class="h4 crm-page-title">Task Activity</h1>
        </div>
        <div class="col-auto">
            <a href="${pageContext.request.contextPath}/technician/tasks" class="btn btn-outline-secondary">
                <i class="bi bi-list-task me-1"></i>View All Tasks
            </a>
        </div>
    </div>

    <c:if test="${not empty param.success}">
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="bi bi-check-circle me-2"></i>${fn:escapeXml(param.success)}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <c:if test="${not empty param.error}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="bi bi-exclamation-triangle me-2"></i>${fn:escapeXml(param.error)}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <div class="card crm-card-shadow">
        <div class="card-header">
            <h5 class="mb-0">Recent Task Activities</h5>
        </div>
        <div class="card-body p-0">
            <c:choose>
                <c:when test="${not empty recentTasks}">
                    <div class="table-responsive">
                        <table class="table align-middle mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th>Task ID</th>
                                    <th>Request ID</th>
                                    <th>Type</th>
                                    <th>Details</th>
                                    <th>Status</th>
                                    <th>Scheduled Date</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="task" items="${recentTasks}">
                                    <tr>
                                        <td>${task.taskId}</td>
                                        <td>${task.requestId}</td>
                                        <td>${fn:escapeXml(task.taskType)}</td>
                                        <td>
                                            <div class="text-truncate" style="max-width: 200px;" title="${fn:escapeXml(task.taskDetails)}">
                                                ${fn:escapeXml(task.taskDetails)}
                                            </div>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${task.status == 'Assigned'}">
                                                    <span class="badge bg-primary">Assigned</span>
                                                </c:when>
                                                <c:when test="${task.status == 'InProgress'}">
                                                    <span class="badge bg-info text-dark">In Progress</span>
                                                </c:when>
                                                <c:when test="${task.status == 'Scheduled'}">
                                                    <span class="badge bg-secondary">Scheduled</span>
                                                </c:when>
                                                <c:when test="${task.status == 'Completed'}">
                                                    <span class="badge bg-success">Completed</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-secondary">${fn:escapeXml(task.status)}</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>${task.scheduledDate}</td>
                                        <td>
                                            <a href="${pageContext.request.contextPath}/technician/task-detail?id=${task.taskId}" class="btn btn-sm btn-outline-info">
                                                <i class="bi bi-eye"></i> View
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="text-center py-4">
                        <i class="bi bi-activity text-muted" style="font-size: 3rem;"></i>
                        <p class="text-muted mt-2">No recent task activities found.</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>
