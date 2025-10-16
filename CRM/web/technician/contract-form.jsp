<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="../layouts/layout.jsp"/>
<c:set var="pageTitle" value="New Contract"/>
<div class="container-fluid">
  <div class="row mb-3">
    <div class="col"><h1 class="h4">Create Equipment Contract</h1></div>
  </div>
  <div class="card crm-card-shadow">
    <div class="card-body">
      <form method="post" action="${pageContext.request.contextPath}/technician/contracts">
        <div class="row g-3">
          <div class="col-md-6">
            <label class="form-label">Equipment Name</label>
            <input type="text" class="form-control" name="equipmentName" required maxlength="255"/>
          </div>
          <div class="col-md-3">
            <label class="form-label">Quantity</label>
            <input type="number" class="form-control" name="quantity" min="1" required/>
          </div>
          <div class="col-md-3">
            <label class="form-label">Unit Price (optional)</label>
            <input type="number" class="form-control" name="unitPrice" step="0.01"/>
          </div>
          <div class="col-md-12">
            <label class="form-label">Description/Notes</label>
            <textarea class="form-control" name="description" rows="3"></textarea>
          </div>
          <div class="col-md-4">
            <label class="form-label">Date</label>
            <input type="date" class="form-control" name="date"/>
          </div>
          <div class="col-md-4">
            <label class="form-label">Task ID (optional)</label>
            <input type="number" class="form-control" name="taskId" value="${param.taskId}"/>
          </div>
          <div class="col-md-4">
            <label class="form-label">Technician ID</label>
            <input type="number" class="form-control" name="technicianId" value="${sessionScope.session_login_id}" readonly/>
          </div>
        </div>
        <div class="mt-3 d-flex justify-content-end gap-2">
          <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/technician/tasks">Cancel</a>
          <button class="btn btn-primary" type="submit">Save Contract</button>
        </div>
      </form>
    </div>
  </div>
</div>
<jsp:include page="../layouts/layout_end.jsp"/>


