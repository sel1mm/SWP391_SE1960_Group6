<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<div class="container-fluid">
  <div class="row mb-3 align-items-center">
    <div class="col">
      <h1 class="h4 crm-page-title">Work History</h1>
      <p class="text-muted">View all your tasks and submitted reports</p>
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

  <!-- Search and Filter -->
  <div class="card crm-card-shadow mb-3">
    <div class="card-body">
      <form id="workHistorySearchForm" class="row g-2 align-items-center" method="get" action="${pageContext.request.contextPath}/technician/work-history">
        <div class="col-12 col-md-4">
          <input type="text" name="q" value="${searchQuery}" class="form-control" placeholder="Search tasks and reports..."/>
        </div>
        <div class="col-6 col-md-3">
          <select class="form-select" name="status">
            <option value="">All Statuses</option>
            <option value="Assigned" ${statusFilter == 'Assigned' ? 'selected' : ''}>Assigned</option>
            <option value="In Progress" ${statusFilter == 'In Progress' ? 'selected' : ''}>In Progress</option>
            <option value="Completed" ${statusFilter == 'Completed' ? 'selected' : ''}>Completed</option>
            <option value="Failed" ${statusFilter == 'Failed' ? 'selected' : ''}>Failed</option>
          </select>
        </div>
        <div class="col-6 col-md-3 text-end">
          <button class="btn btn-secondary" type="submit"><i class="bi bi-search me-1"></i>Search</button>
        </div>
      </form>
    </div>
  </div>

  <div class="row">
    <div class="col-lg-8">
      <div class="card crm-card-shadow">
        <div class="card-header d-flex justify-content-between align-items-center">
          <h5 class="mb-0">All Tasks</h5>
          <span class="badge bg-primary">${totalTasks} total</span>
        </div>
        <div class="card-body">
          <c:choose>
            <c:when test="${not empty allTasks}">
              <div class="table-responsive">
                <table class="table table-hover">
                  <thead>
                    <tr>
                      <th>Task ID</th>
                      <th>Type</th>
                      <th>Details</th>
                      <th>Status</th>
                      <th>Start Date</th>
                      <th>End Date</th>
                    </tr>
                  </thead>
                  <tbody>
                    <c:forEach var="task" items="${allTasks}">
                      <tr>
                        <td><strong>#${task.taskId}</strong></td>
                        <td>${fn:escapeXml(task.taskType)}</td>
                        <td>
                          <div class="text-truncate" style="max-width:200px;" title="${fn:escapeXml(task.taskDetails)}">
                            ${fn:escapeXml(task.taskDetails)}
                          </div>
                        </td>
                        <td>
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
                        </td>
                        <td>
                          <c:choose>
                            <c:when test="${task.startDate != null}">
                              ${task.startDate}
                            </c:when>
                            <c:otherwise>
                              <span class="text-muted">Not set</span>
                            </c:otherwise>
                          </c:choose>
                        </td>
                        <td>
                          <c:choose>
                            <c:when test="${task.endDate != null}">
                              ${task.endDate}
                            </c:when>
                            <c:otherwise>
                              <span class="text-muted">Not set</span>
                            </c:otherwise>
                          </c:choose>
                        </td>
                      </tr>
                    </c:forEach>
                  </tbody>
                </table>
              </div>
              
              <!-- Pagination -->
              <c:if test="${totalPages > 1}">
                <nav aria-label="Task pagination">
                  <ul class="pagination justify-content-center">
                    <c:forEach begin="1" end="${totalPages}" var="pageNum">
                      <li class="page-item ${pageNum == currentPage ? 'active' : ''}">
                        <a class="page-link" href="?page=${pageNum}&q=${searchQuery}&status=${statusFilter}">${pageNum}</a>
                      </li>
                    </c:forEach>
                  </ul>
                </nav>
              </c:if>
            </c:when>
            <c:otherwise>
              <div class="text-center py-4">
                <div class="text-muted">
                  <i class="bi bi-clipboard fs-1 d-block mb-2"></i>
                  <p>No tasks found</p>
                  <small>Tasks assigned to you will appear here</small>
                </div>
              </div>
            </c:otherwise>
          </c:choose>
        </div>
      </div>
    </div>
    
    <div class="col-lg-4">
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
                      <h6 class="mb-1">Report #${report.reportId}</h6>
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
                  <i class="bi bi-file-earmark-text fs-1 d-block mb-2"></i>
                  <p>No reports found</p>
                  <small>Your submitted reports will appear here</small>
                </div>
              </div>
            </c:otherwise>
          </c:choose>
        </div>
      </div>
    </div>
  </div>
</div>