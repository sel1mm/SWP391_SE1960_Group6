<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="contextPath" value='${pageContext.request.contextPath}'/>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title><c:out value="${pageTitle != null ? pageTitle : 'CRM'}"/></title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
  <link href="${contextPath}/assets/css/theme.css" rel="stylesheet">
</head>
<body>
<script>window.appContext='${contextPath}';</script>
<div class="container-fluid">
  <div class="row">
    <jsp:include page="_sidebar.jsp" />
    <div class="col-12 col-md-9 col-lg-10 p-0">
      <jsp:include page="_topnav.jsp" />
      <main class="p-3 p-md-4">


