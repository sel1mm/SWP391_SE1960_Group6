<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<div class="container-fluid">
  <div class="row mb-3 align-items-center">
    <div class="col">
      <h1 class="h4 crm-page-title">Technician Dashboard</h1>
      <p class="text-muted">Welcome to your technician workspace</p>
    </div>
    <div class="col-auto">
      <a class="btn btn-primary" href="${pageContext.request.contextPath}/technician/tasks">
        <i class="bi bi-list-task me-1"></i>View My Tasks
      </a>
    </div>
  </div>

  <!-- Quick Stats Cards -->
  <div class="row mb-4">
    <div class="col-md-3">
      <div class="card crm-card-shadow text-center">
        <div class="card-body">
          <i class="bi bi-list-task fs-1 text-primary mb-2"></i>
          <h5 class="card-title">My Tasks</h5>
          <p class="card-text">View and manage assigned tasks</p>
          <a href="${pageContext.request.contextPath}/technician/tasks" class="btn btn-outline-primary">View Tasks</a>
        </div>
      </div>
    </div>
    <div class="col-md-3">
      <div class="card crm-card-shadow text-center">
        <div class="card-body">
          <i class="bi bi-clipboard-plus fs-1 text-success mb-2"></i>
          <h5 class="card-title">Repair Reports</h5>
          <p class="card-text">Create and manage repair reports</p>
          <a href="${pageContext.request.contextPath}/technician/reports" class="btn btn-outline-success">View Reports</a>
        </div>
      </div>
    </div>
    <div class="col-md-3">
      <div class="card crm-card-shadow text-center">
        <div class="card-body">
          <i class="bi bi-file-earmark-text fs-1 text-info mb-2"></i>
          <h5 class="card-title">Contracts</h5>
          <p class="card-text">View customer contracts</p>
          <a href="${pageContext.request.contextPath}/technician/contracts" class="btn btn-outline-info">View Contracts</a>
        </div>
      </div>
    </div>
    <div class="col-md-3">
      <div class="card crm-card-shadow text-center">
        <div class="card-body">
          <i class="bi bi-gear fs-1 text-warning mb-2"></i>
          <h5 class="card-title">Equipment</h5>
          <p class="card-text">View equipment information</p>
          <a href="${pageContext.request.contextPath}/technician/contracts?action=equipment" class="btn btn-outline-warning">View Equipment</a>
        </div>
      </div>
    </div>
  </div>

  <!-- Quick Actions -->
  <div class="row">
    <div class="col-lg-8">
      <div class="card crm-card-shadow">
        <div class="card-header">
          <h5 class="mb-0">Quick Actions</h5>
        </div>
        <div class="card-body">
          <div class="row">
            <div class="col-md-6">
              <div class="d-grid gap-2">
                <a class="btn btn-primary" href="${pageContext.request.contextPath}/technician/tasks">
                  <i class="bi bi-list-task me-2"></i>View My Tasks
                </a>
                <a class="btn btn-success" href="${pageContext.request.contextPath}/technician/reports?action=create">
                  <i class="bi bi-clipboard-plus me-2"></i>Create Repair Report
                </a>
                <a class="btn btn-info" href="${pageContext.request.contextPath}/technician/contracts">
                  <i class="bi bi-file-earmark-text me-2"></i>View Contracts
                </a>
              </div>
            </div>
            <div class="col-md-6">
              <div class="d-grid gap-2">
                <a class="btn btn-warning" href="${pageContext.request.contextPath}/technician/contracts?action=equipment">
                  <i class="bi bi-gear me-2"></i>View Equipment
                </a>
                <a class="btn btn-secondary" href="${pageContext.request.contextPath}/technician/work-history">
                  <i class="bi bi-clock-history me-2"></i>Work History
                </a>
                <a class="btn btn-outline-primary" href="${pageContext.request.contextPath}/manageProfile">
                  <i class="bi bi-person me-2"></i>My Profile
                </a>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    
    <div class="col-lg-4">
      <div class="card crm-card-shadow">
        <div class="card-header">
          <h5 class="mb-0">System Status</h5>
        </div>
        <div class="card-body">
          <div class="mb-3">
            <div class="d-flex justify-content-between align-items-center">
              <span>Database Connection</span>
              <span class="badge bg-success">Active</span>
            </div>
          </div>
          <div class="mb-3">
            <div class="d-flex justify-content-between align-items-center">
              <span>System Status</span>
              <span class="badge bg-success">Online</span>
            </div>
          </div>
          <div class="mb-3">
            <div class="d-flex justify-content-between align-items-center">
              <span>Last Login</span>
              <small class="text-muted">Just now</small>
            </div>
          </div>
        </div>
      </div>
      
      <div class="card crm-card-shadow mt-3">
        <div class="card-header">
          <h5 class="mb-0">Help & Support</h5>
        </div>
        <div class="card-body">
          <div class="d-grid gap-2">
            <a class="btn btn-outline-primary btn-sm" href="#">
              <i class="bi bi-question-circle me-1"></i>User Guide
            </a>
            <a class="btn btn-outline-secondary btn-sm" href="#">
              <i class="bi bi-telephone me-1"></i>Contact Support
            </a>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>