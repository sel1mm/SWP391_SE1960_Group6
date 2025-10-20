<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="container-fluid">
  <div class="row mb-3">
    <div class="col"><h1 class="h4">Submit Repair Report</h1></div>
  </div>
  <div class="card crm-card-shadow">
    <div class="card-body">
      <form method="post" action="${pageContext.request.contextPath}/technician/reports" enctype="multipart/form-data">
        <div class="row g-3">
          <div class="col-md-4">
            <label class="form-label">Task ID</label>
            <input type="number" class="form-control" name="taskId" value="${param.taskId}" required/>
          </div>
          <div class="col-md-8">
            <label class="form-label">Summary</label>
            <input type="text" class="form-control" name="summary" required maxlength="255"/>
          </div>
          <div class="col-12">
            <label class="form-label">Description</label>
            <textarea class="form-control" name="description" rows="5" required></textarea>
          </div>
          <div class="col-12">
            <label class="form-label">Attachment (optional)</label>
            <input type="file" class="form-control" name="attachment"/>
          </div>
        </div>
        <div class="mt-3 d-flex justify-content-end gap-2">
          <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/technician/tasks">Cancel</a>
          <button class="btn btn-primary" type="submit">Submit Report</button>
        </div>
      </form>
    </div>
  </div>
</div>
