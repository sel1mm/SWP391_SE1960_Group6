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
      <h1 class="h4 crm-page-title">Contracts</h1>
      <p class="text-muted">Manage customer contracts and equipment agreements</p>
    </div>
    <div class="col-auto">
      <a class="btn btn-outline-primary" href="${pageContext.request.contextPath}/technician/contracts?action=equipment">
        <i class="bi bi-gear me-1"></i>View Equipment
      </a>
      <a class="btn btn-success" href="${pageContext.request.contextPath}/technician/contracts?action=create">
        <i class="bi bi-plus-circle me-1"></i>New Contract
      </a>
      <a class="btn btn-primary" href="${pageContext.request.contextPath}/technician/tasks">
        <i class="bi bi-list-task me-1"></i>My Tasks
      </a>
    </div>
  </div>

  <!-- Search and Filter -->
  <div class="card crm-card-shadow mb-3">
    <div class="card-body">
      <form id="contractSearchForm" class="row g-2 align-items-center" method="get" action="${pageContext.request.contextPath}/technician/contracts">
        <div class="col-12 col-md-6">
          <input type="text" name="q" value="${searchQuery}" class="form-control" placeholder="Search by contract ID, customer name, or details"/>
        </div>
        <div class="col-6 col-md-3">
          <select class="form-select" name="status">
            <option value="">All Statuses</option>
            <option value="Active" ${statusFilter == 'Active' ? 'selected' : ''}>Active</option>
            <option value="Completed" ${statusFilter == 'Completed' ? 'selected' : ''}>Completed</option>
            <option value="Cancelled" ${statusFilter == 'Cancelled' ? 'selected' : ''}>Cancelled</option>
          </select>
        </div>
        <div class="col-6 col-md-3 text-end">
          <button class="btn btn-secondary" type="submit"><i class="bi bi-search me-1"></i>Search</button>
        </div>
      </form>
    </div>
  </div>

  <div class="card crm-card-shadow">
    <div class="card-header d-flex justify-content-between align-items-center">
      <h5 class="mb-0">Contract List</h5>
      <span class="badge bg-primary">${totalContracts} contracts</span>
    </div>
    <div class="table-responsive">
      <table class="table align-middle mb-0">
        <thead class="table-light">
          <tr>
            <th>#</th>
            <th>Contract ID</th>
            <th>Customer</th>
            <th>Contract Type</th>
            <th>Equipment</th>
            <th>Status</th>
            <th>Contract Date</th>
            <th>Details</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody id="contracts-table-body">
        <c:choose>
          <c:when test="${not empty contracts}">
            <c:forEach var="contractWithEquipment" items="${contracts}" varStatus="st">
              <c:set var="contract" value="${contractWithEquipment.contract}"/>
              <tr>
                <td>${(currentPage - 1) * pageSize + st.index + 1}</td>
                <td><strong>#${contract.contractId}</strong></td>
                <td>
                  <div class="d-flex align-items-center">
                    <i class="bi bi-person-circle me-2"></i>
                    <div>
                      <div class="fw-bold">${fn:escapeXml(contractWithEquipment.customerName)}</div>
                    </div>
                  </div>
                </td>
                <td>${fn:escapeXml(contract.contractType)}</td>
                <td>
                  <c:choose>
                    <c:when test="${contractWithEquipment.equipment != null}">
                      <div class="d-flex align-items-center">
                        <i class="bi bi-gear me-2 text-primary"></i>
                        <div>
                          <div class="fw-bold">${fn:escapeXml(contractWithEquipment.equipment.model)}</div>
                          <small class="text-muted">SN: ${fn:escapeXml(contractWithEquipment.equipment.serialNumber)}</small>
                        </div>
                      </div>
                    </c:when>
                    <c:otherwise>
                      <span class="text-muted">
                        <i class="bi bi-dash-circle me-1"></i>No Equipment
                      </span>
                    </c:otherwise>
                  </c:choose>
                </td>
                <td>
                  <c:set var="status" value="${contract.status}"/>
                  <c:choose>
                    <c:when test="${status == 'Active'}">
                      <span class="badge bg-success">Active</span>
                    </c:when>
                    <c:when test="${status == 'Completed'}">
                      <span class="badge bg-primary">Completed</span>
                    </c:when>
                    <c:when test="${status == 'Cancelled'}">
                      <span class="badge bg-danger">Cancelled</span>
                    </c:when>
                    <c:otherwise>
                      <span class="badge bg-dark">${contract.status}</span>
                    </c:otherwise>
                  </c:choose>
                </td>
                <td>
                  <i class="bi bi-calendar-event me-1"></i>${contract.contractDate}
                </td>
                <td>
                  <c:choose>
                    <c:when test="${contract.details != null && !contract.details.isEmpty()}">
                      <div class="text-truncate" style="max-width:200px;" title="${fn:escapeXml(contract.details)}">
                        ${fn:escapeXml(contract.details)}
                      </div>
                    </c:when>
                    <c:otherwise>
                      <span class="text-muted">No details</span>
                    </c:otherwise>
                  </c:choose>
                </td>
                <td class="text-end">
                  <a class="btn btn-sm btn-outline-secondary" 
                     href="${pageContext.request.contextPath}/technician/contracts?action=contractDetail&contractId=${contract.contractId}" 
                     title="View Details">
                    <i class="bi bi-eye"></i>
                  </a>
                </td>
              </tr>
            </c:forEach>
          </c:when>
          <c:otherwise>
            <tr>
              <td colspan="9" class="text-center py-4">
                <div class="text-muted">
                  <i class="bi bi-file-earmark fs-1 d-block mb-2"></i>
                  <p>No contracts found</p>
                  <small>Contracts will appear here when available</small>
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
        <nav aria-label="Contract pagination">
          <ul class="pagination pagination-sm justify-content-center mb-0">
            <c:if test="${currentPage > 1}">
              <li class="page-item">
                <a class="page-link" href="${pageContext.request.contextPath}/technician/contracts?page=${currentPage - 1}&q=${searchQuery}&status=${statusFilter}">Previous</a>
              </li>
            </c:if>
            
            <c:forEach begin="1" end="${totalPages}" var="pageNum">
              <c:if test="${pageNum >= currentPage - 2 && pageNum <= currentPage + 2}">
                <li class="page-item ${pageNum == currentPage ? 'active' : ''}">
                  <a class="page-link" href="${pageContext.request.contextPath}/technician/contracts?page=${pageNum}&q=${searchQuery}&status=${statusFilter}">${pageNum}</a>
                </li>
              </c:if>
            </c:forEach>
            
            <c:if test="${currentPage < totalPages}">
              <li class="page-item">
                <a class="page-link" href="${pageContext.request.contextPath}/technician/contracts?page=${currentPage + 1}&q=${searchQuery}&status=${statusFilter}">Next</a>
              </li>
            </c:if>
          </ul>
        </nav>
      </div>
    </c:if>
  </div>
</div>
