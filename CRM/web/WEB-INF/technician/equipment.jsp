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
      <nav aria-label="breadcrumb">
        <ol class="breadcrumb mb-0">
          <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/technician/contracts">Contracts</a></li>
          <li class="breadcrumb-item active">Equipment</li>
        </ol>
      </nav>
      <h1 class="h4 crm-page-title mt-2">Equipment</h1>
      <p class="text-muted">View equipment information and specifications</p>
    </div>
    <div class="col-auto">
      <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/technician/contracts">
        <i class="bi bi-arrow-left me-1"></i>Back to Contracts
      </a>
      <a class="btn btn-primary" href="${pageContext.request.contextPath}/technician/tasks">
        <i class="bi bi-list-task me-1"></i>My Tasks
      </a>
    </div>
  </div>

  <div class="card crm-card-shadow">
    <div class="card-body">
      <form id="equipmentSearchForm" class="row g-2 align-items-center" method="get" action="${pageContext.request.contextPath}/technician/contracts">
        <input type="hidden" name="action" value="equipment">
        <div class="col-12 col-md-6">
          <input type="text" name="q" value="${param.q}" class="form-control" placeholder="Search by model, description, or serial number"/>
        </div>
        <div class="col-6 col-md-3 text-end">
          <button class="btn btn-secondary" type="submit"><i class="bi bi-search me-1"></i>Search</button>
        </div>
        <div class="col-6 col-md-3 text-end">
          <a class="btn btn-outline-primary" href="${pageContext.request.contextPath}/technician/contracts?action=equipment">
            <i class="bi bi-arrow-clockwise me-1"></i>Reset
          </a>
        </div>
      </form>
    </div>
  </div>

  <div class="card mt-3 crm-card-shadow">
    <div class="card-header d-flex justify-content-between align-items-center">
      <h5 class="mb-0">Equipment List</h5>
      <span class="badge bg-primary">${totalEquipment} equipment</span>
    </div>
    <div class="table-responsive">
      <table class="table align-middle mb-0">
        <thead class="table-light">
          <tr>
            <th>#</th>
            <th>Equipment ID</th>
            <th>Serial Number</th>
            <th>Model</th>
            <th class="d-none d-md-table-cell">Description</th>
            <th>Install Date</th>
            <th>Last Updated</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody id="equipment-table-body">
        <c:choose>
          <c:when test="${not empty equipmentList}">
            <c:forEach var="equipment" items="${equipmentList}" varStatus="st">
              <tr>
                <td>${st.index + 1}</td>
                <td><strong>#${equipment.equipmentId}</strong></td>
                <td>
                  <code class="text-primary">${fn:escapeXml(equipment.serialNumber)}</code>
                </td>
                <td>${fn:escapeXml(equipment.model)}</td>
                <td class="d-none d-md-table-cell">
                  <c:choose>
                    <c:when test="${equipment.description != null && !equipment.description.isEmpty()}">
                      <div class="text-truncate" style="max-width:200px;" title="${fn:escapeXml(equipment.description)}">
                        ${fn:escapeXml(equipment.description)}
                      </div>
                    </c:when>
                    <c:otherwise>
                      <span class="text-muted">No description</span>
                    </c:otherwise>
                  </c:choose>
                </td>
                <td>
                  <c:choose>
                    <c:when test="${equipment.installDate != null}">
                      <i class="bi bi-calendar-event me-1"></i>${equipment.installDate}
                    </c:when>
                    <c:otherwise>
                      <span class="text-muted">Not set</span>
                    </c:otherwise>
                  </c:choose>
                </td>
                <td>
                  <c:choose>
                    <c:when test="${equipment.lastUpdatedDate != null}">
                      <small class="text-muted">${equipment.lastUpdatedDate}</small>
                    </c:when>
                    <c:otherwise>
                      <span class="text-muted">Unknown</span>
                    </c:otherwise>
                  </c:choose>
                </td>
                <td class="text-end">
                  <a class="btn btn-sm btn-outline-secondary" 
                     href="${pageContext.request.contextPath}/technician/contracts?action=equipmentDetail&equipmentId=${equipment.equipmentId}" 
                     title="View Details">
                    <i class="bi bi-eye"></i>
                  </a>
                </td>
              </tr>
            </c:forEach>
          </c:when>
          <c:otherwise>
            <tr>
              <td colspan="8" class="text-center py-4">
                <div class="text-muted">
                  <i class="bi bi-gear fs-1 d-block mb-2"></i>
                  <p>No equipment found</p>
                  <small>Equipment will appear here when available</small>
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
        <nav aria-label="Equipment pagination">
          <ul class="pagination pagination-sm justify-content-center mb-0">
            <c:forEach begin="1" end="${totalPages}" var="pageNum">
              <li class="page-item ${pageNum == currentPage ? 'active' : ''}">
                <a class="page-link" href="${pageContext.request.contextPath}/technician/contracts?action=equipment&page=${pageNum}&q=${param.q}">${pageNum}</a>
              </li>
            </c:forEach>
          </ul>
        </nav>
      </div>
    </c:if>
  </div>
</div>
