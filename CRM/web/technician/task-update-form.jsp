<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<div class="modal fade" id="updateStatusModal" tabindex="-1" aria-labelledby="updateStatusLabel" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="updateStatusLabel">Update Status</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <form method="post" action="${pageContext.request.contextPath}/technician/tasks/status">
        <div class="modal-body">
          <input type="hidden" name="taskId" value="${task.id}"/>
          <div class="mb-3">
            <label class="form-label">Current Status</label>
            <input type="text" class="form-control" value="${task.status}" disabled/>
          </div>
          <div class="mb-3">
            <label class="form-label">New Status</label>
            <select class="form-select" name="status" required>
              <option value="Pending">Pending</option>
              <option value="In Progress">In Progress</option>
              <option value="Completed">Completed</option>
              <option value="On Hold">On Hold</option>
            </select>
          </div>
          <div class="mb-3">
            <label class="form-label">Comment (optional)</label>
            <textarea class="form-control" name="comment" rows="3"></textarea>
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
          <button type="submit" class="btn btn-primary">Save</button>
        </div>
      </form>
    </div>
  </div>
</div>


