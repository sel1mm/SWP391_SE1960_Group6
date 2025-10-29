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
  <c:if test="${not empty successMessage}">
    <div class="alert alert-success alert-dismissible fade show" role="alert">
      <i class="bi bi-check-circle me-2"></i>${successMessage}
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
      <h1 class="h4 crm-page-title">Repair Reports</h1>
      <p class="text-muted">Create and manage repair reports for service requests</p>
    </div>
    <div class="col-auto">
      <a class="btn btn-outline-primary" href="${pageContext.request.contextPath}/technician/tasks">
        <i class="bi bi-list-task me-1"></i>View Tasks
      </a>
      <a class="btn btn-primary" href="${pageContext.request.contextPath}/technician/reports?action=create">
        <i class="bi bi-clipboard-plus me-1"></i>New Report
      </a>
    </div>
  </div>

  <div class="card crm-card-shadow">
    <div class="card-body">
      <form id="reportSearchForm" class="row g-2 align-items-center" method="get" action="${pageContext.request.contextPath}/technician/reports">
        <div class="col-12 col-md-6">
          <input type="text" name="q" value="${param.q}" class="form-control" placeholder="Search by details, diagnosis, or report ID"/>
        </div>
        <div class="col-6 col-md-3">
          <select class="form-select" name="status">
            <option value="">All Statuses</option>
            <option value="Pending" ${param.status == 'Pending' ? 'selected' : ''}>Pending</option>
            <option value="Approved" ${param.status == 'Approved' ? 'selected' : ''}>Approved</option>
            <option value="Rejected" ${param.status == 'Rejected' ? 'selected' : ''}>Rejected</option>
            <option value="In Review" ${param.status == 'In Review' ? 'selected' : ''}>In Review</option>
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
      <h5 class="mb-0">Report List</h5>
      <span class="badge bg-primary">${totalReports} reports</span>
    </div>
    <div class="table-responsive">
      <table class="table align-middle mb-0">
        <thead class="table-light">
          <tr>
            <th>#</th>
            <th>Report ID</th>
            <th>Customer</th>
            <th>Request ID</th>
            <th class="d-none d-md-table-cell">Details</th>
            <th>Diagnosis</th>
            <th>Estimated Cost</th>
            <th>Status</th>
            <th>Repair Date</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody id="reports-table-body">
        <c:choose>
          <c:when test="${not empty reportsWithCustomer}">
            <c:forEach var="reportWithCustomer" items="${reportsWithCustomer}" varStatus="st">
              <tr>
                <td>${(currentPage - 1) * pageSize + st.index + 1}</td>
                <td><strong>#${reportWithCustomer.report.reportId}</strong></td>
                <td>
<<<<<<< HEAD
                  <c:choose>
                    <c:when test="${report.requestId != null}">
                      <a href="#" class="text-decoration-none">#${report.requestId}</a>
=======
                  <div class="fw-bold">${fn:escapeXml(reportWithCustomer.customerName)}</div>
                  <small class="text-muted">ID: ${reportWithCustomer.customerId}</small>
                </td>
                <td>
                  <c:choose>
                    <c:when test="${reportWithCustomer.report.requestId != null}">
                      <a href="#" class="text-decoration-none">#${reportWithCustomer.report.requestId}</a>
>>>>>>> main
                    </c:when>
                    <c:otherwise>
                      <span class="text-muted">General Report</span>
                    </c:otherwise>
                  </c:choose>
                </td>
                <td class="d-none d-md-table-cell">
                  <div class="text-truncate" style="max-width:200px;" title="${fn:escapeXml(reportWithCustomer.report.details)}">
                    ${fn:escapeXml(reportWithCustomer.report.details)}
                  </div>
                </td>
                <td>
                  <div class="text-truncate" style="max-width:150px;" title="${fn:escapeXml(reportWithCustomer.report.diagnosis)}">
                    ${fn:escapeXml(reportWithCustomer.report.diagnosis)}
                  </div>
                </td>
                <td>
                  <span class="fw-bold text-success">$${reportWithCustomer.report.estimatedCost}</span>
                </td>
                <td>
                  <c:set var="status" value="${reportWithCustomer.report.quotationStatus}"/>
                  <c:choose>
                    <c:when test="${status == 'Pending'}">
                      <span class="badge bg-warning">Pending</span>
                    </c:when>
                    <c:when test="${status == 'Approved'}">
                      <span class="badge bg-success">Approved</span>
                    </c:when>
                    <c:when test="${status == 'Rejected'}">
                      <span class="badge bg-danger">Rejected</span>
                    </c:when>
                    <c:when test="${status == 'In Review'}">
                      <span class="badge bg-info">In Review</span>
                    </c:when>
                    <c:otherwise>
                      <span class="badge bg-dark">${reportWithCustomer.report.quotationStatus}</span>
                    </c:otherwise>
                  </c:choose>
                </td>
                <td>
                  <c:choose>
                    <c:when test="${reportWithCustomer.report.repairDate != null}">
                      ${reportWithCustomer.report.repairDate}
                    </c:when>
                    <c:otherwise>
                      <span class="text-muted">Not set</span>
                    </c:otherwise>
                  </c:choose>
                </td>
                <td class="text-end">
                  <a class="btn btn-sm btn-outline-secondary" href="${pageContext.request.contextPath}/technician/reports?action=detail&reportId=${reportWithCustomer.report.reportId}" title="View Details">
                    <i class="bi bi-eye"></i>
                  </a>
                  <c:if test="${status == 'Pending'}">
                    <a class="btn btn-sm btn-primary" href="${pageContext.request.contextPath}/technician/reports?action=edit&reportId=${reportWithCustomer.report.reportId}" title="Edit Report">
                      <i class="bi bi-pencil"></i>
                    </a>
                  </c:if>
                </td>
              </tr>
            </c:forEach>
          </c:when>
          <c:otherwise>
            <tr>
              <td colspan="10" class="text-center py-4">
                <div class="text-muted">
                  <i class="bi bi-clipboard fs-1 d-block mb-2"></i>
                  <p>No reports found</p>
                  <small>Your repair reports will appear here</small>
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
        <nav aria-label="Report pagination">
          <ul class="pagination pagination-sm justify-content-center mb-0">
            <c:if test="${currentPage > 1}">
              <li class="page-item">
                <a class="page-link" href="${pageContext.request.contextPath}/technician/reports?page=${currentPage - 1}&q=${param.q}&status=${param.status}">Previous</a>
              </li>
            </c:if>
            
            <c:forEach begin="1" end="${totalPages}" var="pageNum">
              <c:if test="${pageNum >= currentPage - 2 && pageNum <= currentPage + 2}">
                <li class="page-item ${pageNum == currentPage ? 'active' : ''}">
                  <a class="page-link" href="${pageContext.request.contextPath}/technician/reports?page=${pageNum}&q=${param.q}&status=${param.status}">${pageNum}</a>
                </li>
              </c:if>
            </c:forEach>
            
            <c:if test="${currentPage < totalPages}">
              <li class="page-item">
                <a class="page-link" href="${pageContext.request.contextPath}/technician/reports?page=${currentPage + 1}&q=${param.q}&status=${param.status}">Next</a>
              </li>
            </c:if>
          </ul>
        </nav>
      </div>
    </c:if>
  </div>
</div>
