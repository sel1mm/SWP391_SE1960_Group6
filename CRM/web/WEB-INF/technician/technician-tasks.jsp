<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<div class="container-fluid">
    <div class="row mb-3 align-items-center">
        <div class="col">
            <h1 class="h4 crm-page-title">Assigned Work Tasks</h1>
        </div>
        <div class="col-auto">
            <!-- Quick action buttons -->
            <a href="${pageContext.request.contextPath}/technician/reports" class="btn btn-outline-secondary me-2">
                <i class="bi bi-file-earmark-text me-1"></i>New Report
            </a>
            <a href="${pageContext.request.contextPath}/technician/contracts" class="btn btn-outline-secondary">
                <i class="bi bi-journal-text me-1"></i>View Contracts
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
            <h5 class="mb-0">Your Current Tasks</h5>
        </div>
        <div class="card-body p-0">
            <c:choose>
                <c:when test="${not empty tasks}">
                    <div class="table-responsive">
                        <table class="table align-middle mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th>Task ID</th>
                                    <th>Request ID</th>
                                    <th>Type</th>
                                    <th>Details</th>
                                    <th>Start Date</th>
                                    <th>End Date</th>
                                    <th>Status</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="task" items="${tasks}">
                                    <tr>
                                        <td>${task.taskId}</td>
                                        <td>${task.requestId}</td>
                                        <td>${fn:escapeXml(task.taskType)}</td>
                                        <td>
                                            <div class="text-truncate" style="max-width: 250px;" title="${fn:escapeXml(task.taskDetails)}">
                                                ${fn:escapeXml(task.taskDetails)}
                                            </div>
                                        </td>
                                        <td>${task.startDate}</td>
                                        <td>${task.endDate}</td>
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
                                        <td>
                                            <button class="btn btn-sm btn-outline-info" onclick="viewTaskDetail(${task.taskId})">
                                                <i class="bi bi-eye"></i> View
                                            </button>
                                            <c:if test="${task.status == 'Assigned'}">
                                                <button class="btn btn-sm btn-success" onclick="acceptTask(${task.taskId})">
                                                    <i class="bi bi-check"></i> Accept
                                                </button>
                                            </c:if>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="text-center py-4">
                        <i class="bi bi-clipboard-check text-muted" style="font-size: 3rem;"></i>
                        <p class="text-muted mt-2">No assigned work tasks found.</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>

<!-- Task Acceptance Modal -->
<div class="modal fade" id="acceptTaskModal" tabindex="-1" aria-labelledby="acceptTaskModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="acceptTaskModalLabel">Accept Task</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form id="acceptTaskForm" method="post" action="${pageContext.request.contextPath}/technician/tasks">
                <div class="modal-body">
                    <input type="hidden" name="action" value="accept">
                    <input type="hidden" id="acceptTaskId" name="taskId" value="">
                    
                    <div class="mb-3">
                        <label class="form-label">Start Date <span class="text-danger">*</span></label>
                        <input type="date" class="form-control" id="startDate" name="startDate" required>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label">End Date <span class="text-danger">*</span></label>
                        <input type="date" class="form-control" id="endDate" name="endDate" required>
                    </div>
                    
                    <div class="alert alert-info">
                        <i class="bi bi-info-circle me-2"></i>
                        The system will check for workload conflicts before accepting this task.
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-success">Accept Task</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    function viewTaskDetail(taskId) {
        // Placeholder for viewing task details
        alert('Viewing details for Task ID: ' + taskId);
    }

    function acceptTask(taskId) {
        document.getElementById('acceptTaskId').value = taskId;
        
        // Set minimum date to today
        const today = new Date().toISOString().split('T')[0];
        document.getElementById('startDate').setAttribute('min', today);
        document.getElementById('endDate').setAttribute('min', today);
        
        new bootstrap.Modal(document.getElementById('acceptTaskModal')).show();
    }

    // Set minimum date to today on page load
    document.addEventListener('DOMContentLoaded', function() {
        const today = new Date().toISOString().split('T')[0];
        document.getElementById('startDate').setAttribute('min', today);
        document.getElementById('endDate').setAttribute('min', today);
    });
</script>