<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="container-fluid">
  <div class="row mb-3 align-items-center">
    <div class="col">
      <h1 class="h4 crm-page-title">Lịch sử công việc</h1>
      <p class="text-muted">Xem toàn bộ công việc và báo cáo đã gửi của bạn</p>
    </div>
    <div class="col-auto">
      <a class="btn btn-outline-primary" href="${pageContext.request.contextPath}/technician/tasks">
        <i class="bi bi-list-task me-1"></i>Công việc hiện tại
      </a>
      <a class="btn btn-primary" href="${pageContext.request.contextPath}/technician/reports">
        <i class="bi bi-clipboard-plus me-1"></i>Báo cáo của tôi
      </a>
    </div>
  </div>

  <!-- Search and Filter -->
  <div class="card crm-card-shadow mb-3">
    <div class="card-body">
      <form id="workHistorySearchForm" class="row g-2 align-items-center" method="get" action="${pageContext.request.contextPath}/technician/work-history">
        <div class="col-12 col-md-4">
          <input type="text" name="q" value="${searchQuery}" class="form-control" placeholder="Tìm kiếm công việc và báo cáo..."/>
        </div>
        <div class="col-6 col-md-3">
          <select class="form-select" name="status">
            <option value="">Tất cả trạng thái</option>
            <option value="Assigned" ${statusFilter == 'Assigned' ? 'selected' : ''}>Đã giao</option>
            <option value="In Progress" ${statusFilter == 'In Progress' ? 'selected' : ''}>Đang thực hiện</option>
            <option value="Completed" ${statusFilter == 'Completed' ? 'selected' : ''}>Hoàn thành</option>
            <option value="Failed" ${statusFilter == 'Failed' ? 'selected' : ''}>Thất bại</option>
          </select>
        </div>
        <div class="col-6 col-md-3 text-end">
          <button class="btn btn-secondary" type="submit"><i class="bi bi-search me-1"></i>Tìm kiếm</button>
        </div>
      </form>
    </div>
  </div>

  <div class="row">
    <div class="col-lg-8">
      <div class="card crm-card-shadow">
        <div class="card-header d-flex justify-content-between align-items-center">
          <h5 class="mb-0">Tất cả công việc</h5>
          <span class="badge bg-primary">${totalTasks} công việc</span>
        </div>
        <div class="card-body">
          <c:choose>
            <c:when test="${not empty allTasks}">
              <div class="table-responsive">
                <table class="table table-hover">
                  <thead>
                    <tr>
                      <th>Mã công việc</th>
                      <th>Loại</th>
                      <th>Chi tiết</th>
                      <th>Trạng thái</th>
                      <th>Ngày bắt đầu</th>
                      <th>Ngày kết thúc</th>
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
                              <span class="badge bg-warning">Đang chờ</span>
                            </c:when>
                            <c:when test="${status == 'Assigned'}">
                              <span class="badge bg-info">Đã giao</span>
                            </c:when>
                            <c:when test="${status == 'In Progress'}">
                              <span class="badge bg-primary">Đang thực hiện</span>
                            </c:when>
                            <c:when test="${status == 'Completed'}">
                              <span class="badge bg-success">Hoàn thành</span>
                            </c:when>
                            <c:when test="${status == 'On Hold'}">
                              <span class="badge bg-secondary">Tạm hoãn</span>
                            </c:when>
                            <c:when test="${status == 'Cancelled'}">
                              <span class="badge bg-danger">Đã hủy</span>
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
                              <span class="text-muted">Chưa đặt</span>
                            </c:otherwise>
                          </c:choose>
                        </td>
                        <td>
                          <c:choose>
                            <c:when test="${task.endDate != null}">
                              ${task.endDate}
                            </c:when>
                            <c:otherwise>
                              <span class="text-muted">Chưa đặt</span>
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
                <nav aria-label="Phân trang công việc">
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
                  <p>Không tìm thấy công việc</p>
                  <small>Các công việc được giao cho bạn sẽ hiển thị tại đây</small>
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
          <h5 class="mb-0">Báo cáo đã gửi</h5>
          <span class="badge bg-primary">${totalSubmittedReports} báo cáo</span>
        </div>
        <div class="card-body">
          <c:choose>
            <c:when test="${not empty submittedReports}">
              <div class="list-group list-group-flush">
                <c:forEach var="report" items="${submittedReports}">
                  <div class="list-group-item">
                    <div class="d-flex w-100 justify-content-between">
                      <h6 class="mb-1">Báo cáo #${report.reportId}</h6>
                      <small class="text-muted">₫<fmt:formatNumber value="${report.estimatedCost * 26000}" type="number" maxFractionDigits="0"/></small>
                    </div>
                    <p class="mb-1">${fn:escapeXml(report.details)}</p>
                    <small class="text-primary">
                      <i class="bi bi-calendar-event me-1"></i>Đã gửi: ${report.repairDate}
                    </small>
                  </div>
                </c:forEach>
              </div>
            </c:when>
            <c:otherwise>
              <div class="text-center py-4">
                <div class="text-muted">
                  <i class="bi bi-file-earmark-text fs-1 d-block mb-2"></i>
                  <p>Không tìm thấy báo cáo</p>
                  <small>Các báo cáo bạn đã gửi sẽ hiển thị tại đây</small>
                </div>
              </div>
            </c:otherwise>
          </c:choose>
        </div>
      </div>
    </div>
  </div>
</div>