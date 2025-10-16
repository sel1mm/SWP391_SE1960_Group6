<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="contextPath" value='${pageContext.request.contextPath}'/>
<aside class="col-12 col-md-3 col-lg-2 p-0 crm-sidebar">
  <div class="d-flex flex-column p-3">
    <h6 class="text-muted px-2">Navigation</h6>
    <ul class="nav nav-pills flex-column mb-auto">
      <li class="nav-item">
        <a href="${contextPath}/dashboard.jsp" class="nav-link text-dark">
          <i class="bi bi-speedometer2 me-2"></i>Dashboard
        </a>
      </li>
      <li>
        <a href="${contextPath}/technician/tasks" class="nav-link text-dark">
          <i class="bi bi-list-task me-2"></i>Technician Tasks
        </a>
      </li>
      <li>
        <a href="${contextPath}/technicalManagerApproval" class="nav-link text-dark">
          <i class="bi bi-clipboard-check me-2"></i>Manager Approval
        </a>
      </li>
    </ul>
  </div>
</aside>


