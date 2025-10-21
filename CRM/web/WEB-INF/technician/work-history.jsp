<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<div class="container-fluid">
  <div class="row mb-3 align-items-center">
    <div class="col">
      <h1 class="h4 crm-page-title">Work History</h1>
      <p class="text-muted">View your completed tasks and submitted reports</p>
    </div>
    <div class="col-auto">
      <a class="btn btn-outline-primary" href="${pageContext.request.contextPath}/technician/tasks">
        <i class="bi bi-list-task me-1"></i>Current Tasks
      </a>
      <a class="btn btn-primary" href="${pageContext.request.contextPath}/technician/reports">
        <i class="bi bi-clipboard-plus me-1"></i>My Reports
      </a>
    </div>
  </div>

  <!-- Search -->
  <div class="card crm-card-shadow mb-3">
    <div class="card-body">
      <form id="workHistorySearchForm" class="row g-2 align-items-center" method="get" action="${pageContext.request.contextPath}/technician/work-history">
        <div class="col-12 col-md-6">
          <input type="text" name="q" value="${searchQuery}" class="form-control" placeholder="Search tasks and reports..."/>
        </div>
        <div class="col-6 col-md-3 text-end">
          <button class="btn btn-secondary" type="submit"><i class="bi bi-search me-1"></i>Search</button>
        </div>
      </form>
    </div>
  </div>

  <div class="row">
    <div class="col-lg-6">
      <div class="card crm-card-shadow">
        <div class="card-header d-flex justify-content-between align-items-center">
          <h5 class="mb-0">Completed Tasks</h5>
          <span class="badge bg-success">${totalCompletedTasks} completed</span>
        </div>
        <div class="card-body">
          <c:choose>
            <c:when test="${not empty completedTasks}">
              <div class="list-group list-group-flush">
                <c:forEach var="task" items="${completedTasks}">
                  <div class="list-group-item">
                    <div class="d-flex w-100 justify-content-between">
                      <h6 class="mb-1">${fn:escapeXml(task.taskType)}</h6>
                      <small class="text-muted">#${task.taskId}</small>
                    </div>
                    <p class="mb-1">${fn:escapeXml(task.taskDetails)}</p>
                    <small class="text-success">
                      <i class="bi bi-calendar-check me-1"></i>Completed: ${task.endDate}
                    </small>
                  </div>
                </c:forEach>
              </div>
            </c:when>
            <c:otherwise>
              <div class="text-center py-4">
                <div class="text-muted">
                  <i class="bi bi-check-circle fs-1 d-block mb-2 text-success"></i>
                  <p>No completed tasks found</p>
                  <small>Tasks marked as "Completed" will appear here</small>
                </div>
              </div>
            </c:otherwise>
          </c:choose>
        </div>
      </div>
    </div>
    
    <div class="col-lg-6">
      <div class="card crm-card-shadow">
        <div class="card-header d-flex justify-content-between align-items-center">
          <h5 class="mb-0">Submitted Reports</h5>
          <span class="badge bg-primary">${totalSubmittedReports} reports</span>
        </div>
        <div class="card-body">
          <c:choose>
            <c:when test="${not empty submittedReports}">
              <div class="list-group list-group-flush">
                <c:forEach var="report" items="${submittedReports}">
                  <div class="list-group-item">
                    <div class="d-flex w-100 justify-content-between">
                      <h6 class="mb-1">Repair Report #${report.reportId}</h6>
                      <small class="text-muted">$${report.estimatedCost}</small>
                    </div>
                    <p class="mb-1">${fn:escapeXml(report.details)}</p>
                    <small class="text-primary">
                      <i class="bi bi-calendar-event me-1"></i>Submitted: ${report.repairDate}
                    </small>
                  </div>
                </c:forEach>
              </div>
            </c:when>
            <c:otherwise>
              <div class="text-center py-4">
                <div class="text-muted">
                  <i class="bi bi-clipboard-check fs-1 d-block mb-2 text-primary"></i>
                  <p>No submitted reports found</p>
                  <small>Your repair reports will appear here</small>
                </div>
              </div>
            </c:otherwise>
          </c:choose>
        </div>
      </div>
    </div>
  </div>
  
  <!-- Pagination -->
  <c:if test="${totalPages > 1}">
    <div class="card crm-card-shadow mt-3">
      <div class="card-footer">
        <nav aria-label="Work history pagination">
          <ul class="pagination pagination-sm justify-content-center mb-0">
            <c:if test="${currentPage > 1}">
              <li class="page-item">
                <a class="page-link" href="${pageContext.request.contextPath}/technician/work-history?page=${currentPage - 1}&q=${searchQuery}">Previous</a>
              </li>
            </c:if>
            
            <c:forEach begin="1" end="${totalPages}" var="pageNum">
              <c:if test="${pageNum >= currentPage - 2 && pageNum <= currentPage + 2}">
                <li class="page-item ${pageNum == currentPage ? 'active' : ''}">
                  <a class="page-link" href="${pageContext.request.contextPath}/technician/work-history?page=${pageNum}&q=${searchQuery}">${pageNum}</a>
                </li>
              </c:if>
            </c:forEach>
            
            <c:if test="${currentPage < totalPages}">
              <li class="page-item">
                <a class="page-link" href="${pageContext.request.contextPath}/technician/work-history?page=${currentPage + 1}&q=${searchQuery}">Next</a>
              </li>
            </c:if>
          </ul>
        </nav>
      </div>
    </div>
  </c:if>
</div>
