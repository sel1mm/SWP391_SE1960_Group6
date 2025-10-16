<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<div class="container-fluid">
  <div class="d-flex justify-content-between align-items-center mb-3">
    <h1 class="h4 tech-section-title mb-0">Technician Dashboard</h1>
  </div>
  <div class="tech-features-grid">
    <a class="tech-card" href="${pageContext.request.contextPath}/technician/tasks">
      <div class="icon"><i class="bi bi-list-task"></i></div>
      <h5>Technician Tasks</h5>
      <p>View and manage assigned tasks</p>
    </a>
    <a class="tech-card" href="${pageContext.request.contextPath}/technician/storekeeper">
      <div class="icon"><i class="bi bi-box-seam"></i></div>
      <h5>Storekeeper</h5>
      <p>Check inventory and request parts</p>
    </a>
    <a class="tech-card" href="${pageContext.request.contextPath}/technician/approved-request">
      <div class="icon"><i class="bi bi-clipboard-check"></i></div>
      <h5>Approved Requests</h5>
      <p>View approved maintenance requests</p>
    </a>
    <a class="tech-card" href="${pageContext.request.contextPath}/technician/work-history">
      <div class="icon"><i class="bi bi-clock-history"></i></div>
      <h5>Work History</h5>
      <p>Review your job history</p>
    </a>
    <a class="tech-card" href="${pageContext.request.contextPath}/technician/contract-history">
      <div class="icon"><i class="bi bi-file-text"></i></div>
      <h5>Contract History</h5>
      <p>See related customer contracts</p>
    </a>
  </div>
</div>


