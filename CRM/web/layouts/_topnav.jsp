<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="contextPath" value='${pageContext.request.contextPath}'/>
<nav class="navbar navbar-expand-lg bg-white border-bottom">
  <div class="container-fluid">
    <a class="navbar-brand fw-semibold" href="${contextPath}/home.jsp">CRM</a>
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#topnav" aria-controls="topnav" aria-expanded="false" aria-label="Toggle navigation">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="topnav">
      <ul class="navbar-nav ms-auto mb-2 mb-lg-0">
        <li class="nav-item">
          <a class="nav-link" href="${contextPath}/technicalManagerApproval">Manager</a>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="${contextPath}/technician/tasks">Technician Tasks</a>
        </li>
        <li class="nav-item dropdown">
          <a class="nav-link dropdown-toggle" href="#" id="userMenu" role="button" data-bs-toggle="dropdown" aria-expanded="false">
            <i class="bi bi-person-circle"></i>
          </a>
          <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="userMenu">
            <li><a class="dropdown-item" href="${contextPath}/manageProfile.jsp">Profile</a></li>
            <li><hr class="dropdown-divider"></li>
            <li><a class="dropdown-item" href="${contextPath}/logout">Logout</a></li>
          </ul>
        </li>
      </ul>
    </div>
  </div>
  </nav>


