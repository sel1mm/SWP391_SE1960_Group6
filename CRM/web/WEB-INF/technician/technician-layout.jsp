<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="contextPath" value='${pageContext.request.contextPath}'/>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title><c:out value="${pageTitle != null ? pageTitle : 'Technician'}"/></title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
  <link href="${contextPath}/assets/css/theme.css" rel="stylesheet">
  <link href="${contextPath}/assets/css/technician.css" rel="stylesheet">
</head>
<body class="page-fade-enter page-fade-enter-active">
<script>window.appContext='${contextPath}';</script>
<div class="container-fluid">
  <div class="row">
    <aside class="col-12 col-md-3 col-lg-2 p-0 crm-sidebar">
      <div class="d-flex flex-column p-3 nav-compact">
        <div class="d-flex align-items-center mb-3">
          <i class="bi bi-tools me-2"></i>
          <strong>Technician</strong>
        </div>
        <ul class="nav nav-pills flex-column mb-auto">
          <li class="nav-item"><a href="${contextPath}/technician/dashboard" class="nav-link text-dark ${activePage == 'dashboard' ? 'active' : ''}"><i class="bi bi-grid me-2"></i>Dashboard</a></li>
          <li><a href="${contextPath}/technician/tasks" class="nav-link text-dark ${activePage == 'tasks' ? 'active' : ''}"><i class="bi bi-list-task me-2"></i>Tasks</a></li>
          <li><a href="${contextPath}/technician/storekeeper" class="nav-link text-dark ${activePage == 'storekeeper' ? 'active' : ''}"><i class="bi bi-box-seam me-2"></i>Storekeeper</a></li>
          <li><a href="${contextPath}/technician/approved-request" class="nav-link text-dark ${activePage == 'approved' ? 'active' : ''}"><i class="bi bi-clipboard-check me-2"></i>Approved Request</a></li>
          <li><a href="${contextPath}/technician/work-history" class="nav-link text-dark ${activePage == 'work' ? 'active' : ''}"><i class="bi bi-clock-history me-2"></i>Work History</a></li>
          <li><a href="${contextPath}/technician/contract-history" class="nav-link text-dark ${activePage == 'contract' ? 'active' : ''}"><i class="bi bi-file-text me-2"></i>Contract History</a></li>
        </ul>
      </div>
    </aside>
    <div class="col-12 col-md-9 col-lg-10 p-0">
      <nav class="navbar navbar-expand bg-white border-bottom">
        <div class="container-fluid">
          <span class="navbar-brand">CRM</span>
          <ul class="navbar-nav ms-auto align-items-center">
            <li class="nav-item me-2"><a class="nav-link" href="#"><i class="bi bi-bell"></i></a></li>
            <li class="nav-item dropdown">
              <a class="nav-link dropdown-toggle d-flex align-items-center" href="#" id="userMenu" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                <i class="bi bi-person-circle me-2"></i> <span>Technician</span>
              </a>
              <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="userMenu">
                <li><a class="dropdown-item" href="${contextPath}/manageProfile.jsp">Profile</a></li>
                <li><a class="dropdown-item" href="#">Settings</a></li>
                <li><hr class="dropdown-divider"></li>
                <li><a class="dropdown-item" href="${contextPath}/logout">Logout</a></li>
              </ul>
            </li>
          </ul>
        </div>
      </nav>
      <main class="p-3 p-md-4">
        <!-- content here by including views -->
        <jsp:include page="${contentView}"/>
      </main>
      <jsp:include page="/layouts/_footer.jsp" />
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="${contextPath}/assets/js/technician.js"></script>
</body>
</html>


