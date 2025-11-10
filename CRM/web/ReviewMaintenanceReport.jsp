<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@page import="model.Account"%>
<%@page import="java.util.List"%>
<%@page import="model.MaintenanceSchedule"%>
<%@page import="model.ServiceRequest"%>
<%@page import="model.WorkAssignment"%>

<%
    // Check if user is logged in and is a Technical Manager
    Account loggedInAccount = (Account) session.getAttribute("session_login");
    String userRole = (String) session.getAttribute("session_role");
    
    if (loggedInAccount == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    if (!"Technical Manager".equals(userRole)) {
        response.sendRedirect("dashboard.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Xem Báo Cáo Bảo Trì - Technical Manager</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="https://cdn.datatables.net/1.11.5/css/dataTables.bootstrap5.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #f8f9fa;
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            margin: 0;
            padding: 0;
        }

      /* SIDEBAR STYLES */
            .sidebar {
                position: fixed;
                top: 0;
                left: 0;
                height: 100vh;
                width: 260px;
                background: #000000;
                padding: 0;
                transition: all 0.3s ease;
                z-index: 1000;
                box-shadow: 4px 0 10px rgba(0,0,0,0.1);
                display: flex;
                flex-direction: column;
            }


        .sidebar-header {
            padding: 25px 20px;
            border-bottom: 1px solid rgba(255,255,255,0.1);
        }

        .sidebar-header h4 {
            color: white;
            margin: 0;
            font-weight: 600;
            font-size: 1.4rem;
        }

        .sidebar-header .subtitle {
            color: rgba(255,255,255,0.8);
            font-size: 0.9rem;
            margin-top: 5px;
        }

        .sidebar-nav {
            padding: 20px 0;
        }

        .nav-item {
            margin-bottom: 5px;
        }

        .nav-link {
            color: rgba(255,255,255,0.8) !important;
            padding: 15px 25px;
            border-radius: 0;
            transition: all 0.3s ease;
            border-left: 3px solid transparent;
            display: flex;
            align-items: center;
            text-decoration: none;
        }

        .nav-link:hover {
            background-color: rgba(255,255,255,0.1);
            color: white !important;
            border-left-color: #ffc107;
            transform: translateX(5px);
        }

        .nav-link.active {
            background-color: rgba(255,255,255,0.15);
            color: white !important;
            border-left-color: #ffc107;
            font-weight: 600;
        }

        .nav-link i {
            margin-right: 12px;
            width: 20px;
            text-align: center;
            font-size: 1.1rem;
        }

        /* Main Content */
        .main-content {
            margin-left: 280px;
            min-height: 100vh;
            background-color: #f8f9fa;
        }

        .content-wrapper {
            padding: 30px;
        }
        
        .sidebar .nav-link {
            color: rgba(255, 255, 255, 0.8);
            padding: 12px 20px;
            border-radius: 8px;
            margin: 5px 15px;
            transition: all 0.3s;
        }
        
        .sidebar .nav-link:hover, .sidebar .nav-link.active {
            background: rgba(255, 255, 255, 0.2);
            color: white;
            transform: translateX(5px);
        }
        
        .main-content {
            margin-left: 250px;
            padding: 20px;
            background-color: #f8f9fa;
            min-height: 100vh;
        }
        
        .card {
            border: none;
            border-radius: 15px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }
        
        .card-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 15px 15px 0 0 !important;
            padding: 15px 20px;
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border: none;
            border-radius: 8px;
            padding: 10px 20px;
            transition: all 0.3s;
        }
        
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
        }
        
        /* Modern Table Styling */
        .table {
            margin-bottom: 0;
            border-radius: 12px;
            overflow: hidden;
        }

        .table th {
            background: white;
            border-top: none;
            border-bottom: 2px solid #667eea;
            font-weight: 700;
            color: #667eea;
            padding: 20px 16px;
            font-size: 0.9rem;
            text-transform: uppercase;
            letter-spacing: 1px;
            position: relative;
            text-shadow: 0 1px 2px rgba(0,0,0,0.1);
            border-bottom: 3px solid rgba(255,255,255,0.2);
        }

        .table th::after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 0;
            right: 0;
            height: 2px;
            background: rgba(102, 126, 234, 0.2);
        }

        .table td {
            padding: 18px 16px;
            vertical-align: middle;
            border-color: #e9ecef;
            font-size: 0.9rem;
        }

        .table tbody tr {
            transition: all 0.3s ease;
        }

        .table tbody tr:hover {
            background: rgba(102, 126, 234, 0.08);
            box-shadow: 0 2px 8px rgba(102, 126, 234, 0.15);
        }
        
        .badge {
            padding: 8px 12px;
            border-radius: 20px;
            font-size: 0.85em;
        }

        .badge-pending {
            background: #ffc107;
            color: #000;
            font-size: 12px;
            padding: 6px 12px;
            border-radius: 20px;
        }

        .badge-urgent {
            background: #dc3545;
            color: white;
            font-size: 12px;
            padding: 6px 12px;
            border-radius: 20px;
            animation: pulse 2s infinite;
        }

        .badge-high {
            background: #fd7e14;
            color: white;
            font-size: 12px;
            padding: 6px 12px;
            border-radius: 20px;
        }

        .badge-normal {
            background: #20c997;
            color: white;
            font-size: 12px;
            padding: 6px 12px;
            border-radius: 20px;
        }

        @keyframes pulse {
            0% { box-shadow: 0 0 0 0 rgba(220, 53, 69, 0.7); }
            70% { box-shadow: 0 0 0 10px rgba(220, 53, 69, 0); }
            100% { box-shadow: 0 0 0 0 rgba(220, 53, 69, 0); }
        }
        
        .alert {
            border-radius: 10px;
            border: none;
        }
        
        .form-control, .form-select {
            border-radius: 8px;
            border: 2px solid #e9ecef;
            transition: all 0.3s;
        }
        
        .form-control:focus, .form-select:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 0.2rem rgba(102, 126, 234, 0.25);
        }
        
        .modal-content {
            border-radius: 15px;
            border: none;
        }
        
        .modal-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 15px 15px 0 0;
        }
        
        .stats-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 15px;
            padding: 20px;
            text-align: center;
            margin-bottom: 20px;
        }
        
        .stats-number {
            font-size: 2.5rem;
            font-weight: bold;
            margin-bottom: 10px;
        }
        
        .stats-label {
            font-size: 0.9rem;
            opacity: 0.9;
        }
        
        .status-pending { background-color: #ffc107; color: #00000; }
.status-approved { background-color: #28a745; color: #00000; }
.status-rejected { background-color: #dc3545; color: #00000; }
.status-revision { background-color: #fd7e14; color: #00000; }
.status-completed { background-color: #17a2b8; color: #00000; }
.status-scheduled { background-color: #007bff; color: #00000; }
.status-in-progress { background-color: #17a2b8; color: #00000; }
.status-pending-review { background-color: #fd7e14; color: #00000; }
.status-cancelled { background-color: #6c757d; color: #00000; }
        
        /* Priority indicators */
        .priority-indicator {
            display: inline-block;
            width: 8px;
            height: 8px;
            border-radius: 50%;
            margin-right: 8px;
        }

        .priority-urgent {
            background-color: #dc3545;
            animation: pulse 2s infinite;
        }

        .priority-high {
            background-color: #fd7e14;
        }

        .priority-normal {
            background-color: #20c997;
        }
        
        .priority-low { background-color: #28a745; }
        .priority-medium { background-color: #ffc107; }
        .priority-high { background-color: #fd7e14; }
        .priority-critical { background-color: #dc3545; }
        
        .report-details {
            background: #f8f9fa;
            border-radius: 10px;
            padding: 15px;
            margin-bottom: 15px;
        }
        
        .report-section {
            margin-bottom: 20px;
        }
        
        .report-section h6 {
            color: #667eea;
            font-weight: 600;
            margin-bottom: 10px;
            border-bottom: 2px solid #e9ecef;
            padding-bottom: 5px;
        }
        
        .action-buttons {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }
        
        .filter-tabs {
            background: white;
            border-radius: 10px;
            padding: 10px;
            margin-bottom: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .filter-tabs .nav-link {
            color: #667eea;
            border-radius: 8px;
            margin: 0 5px;
            transition: all 0.3s;
        }
        
        .filter-tabs .nav-link.active {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
    </style>
</head>
<body>
    <!-- Sidebar -->
    <nav class="sidebar">
        <div class="p-4">
            <h4 style="color: white;"><i class="fas fa-tools me-2"></i>Technical Manager</h4>
            <hr class="text-white">
        </div>
        <ul class="nav flex-column">
            
            <li class="nav-item">
                <a class="nav-link" href="technicalManagerApproval">
                    <i class="fas fa-clipboard-check me-2"></i>Duyệt Yêu Cầu
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="assignWork">
                    <i class="fas fa-user-plus me-2"></i>Phân Công Công Việc
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="scheduleMaintenance">
                    <i class="fas fa-calendar-alt me-2"></i>Lập Lịch Bảo Trì
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link active" href="reviewMaintenanceReport">
                    <i class="fas fa-file-alt me-2"></i>Xem Báo Cáo Bảo Trì
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="manageProfile">
                    <i class="fas fa-cog me-2"></i>Hồ Sơ
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="logout">
                    <i class="fas fa-sign-out-alt me-2"></i>Đăng Xuất
                </a>
            </li>
        </ul>
    </nav>

    <!-- Main Content -->
    <div class="main-content">
        <div class="content-wrapper">
            <div class="container-fluid">
            <!-- Header -->
            <div class="row mb-4">
                <div class="col-12">
                    <h2><i class="fas fa-file-alt me-3"></i>Xem Báo Cáo Bảo Trì</h2>
                    <p class="text-muted">Quản lý và phê duyệt báo cáo bảo trì từ kỹ thuật viên</p>
                </div>
            </div>

            <!-- Alert Messages -->
            <c:if test="${not empty sessionScope.successMessage}">
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <i class="fas fa-check-circle me-2"></i>${sessionScope.successMessage}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
                <c:remove var="successMessage" scope="session"/>
            </c:if>

            <c:if test="${not empty sessionScope.errorMessage}">
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <i class="fas fa-exclamation-circle me-2"></i>${sessionScope.errorMessage}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
                <c:remove var="errorMessage" scope="session"/>
            </c:if>

            <!-- Statistics Cards -->
            <div class="row mb-4">
                <div class="col-md-4">
                    <div class="stats-card">
                        <div class="stats-number">${totalReports}</div>
                        <div class="stats-label">Tổng Báo Cáo</div>
                    </div>
                </div>
                
                <div class="col-md-4">
                    <div class="stats-card">
                        <div class="stats-number">${approvedCount}</div>
                        <div class="stats-label">Đã Duyệt</div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="stats-card">
                        <div class="stats-number">${rejectedCount}</div>
                        <div class="stats-label">Bị Từ Chối</div>
                    </div>
                </div>
            </div>

            <!-- Filter Tabs -->
            <div class="filter-tabs">
                <ul class="nav nav-pills" id="reportTabs" role="tablist">
                    <li class="nav-item" role="presentation">
                        <button class="nav-link active" id="all-tab" data-bs-toggle="pill" 
                                data-bs-target="#all-reports" type="button" role="tab">
                            <i class="fas fa-list me-2"></i>Tất Cả (${totalReports})
                        </button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link" id="pending-tab" data-bs-toggle="pill" 
                                data-bs-target="#pending-reports" type="button" role="tab">
                            <i class="fas fa-clock me-2"></i>Chờ Duyệt (${pendingCount})
                        </button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link" id="completed-tab" data-bs-toggle="pill" 
                                data-bs-target="#completed-reports" type="button" role="tab">
                            <i class="fas fa-check me-2"></i>Hoàn Thành (${completedSchedules.size()})
                        </button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link" id="approved-tab" data-bs-toggle="pill" 
                                data-bs-target="#approved-reports" type="button" role="tab">
                            <i class="fas fa-thumbs-up me-2"></i>Đã Duyệt (${approvedCount})
                        </button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link" id="rejected-tab" data-bs-toggle="pill" 
                                data-bs-target="#rejected-reports" type="button" role="tab">
                            <i class="fas fa-thumbs-down me-2"></i>Bị Từ Chối (${rejectedCount})
                        </button>
                    </li>
                </ul>
            </div>

            <!-- Tab Content -->
            <div class="tab-content" id="reportTabsContent">
                <!-- All Reports Tab -->
                <div class="tab-pane fade show active" id="all-reports" role="tabpanel">
                    <div class="card">
                        <div class="card-header">
                            <h5 class="mb-0"><i class="fas fa-list me-2"></i>Tất Cả Báo Cáo Bảo Trì</h5>
                        </div>
                        <div class="card-body">
                            <div class="table-responsive">
                                <table class="table table-hover" id="allReportsTable">
                                    <thead class="table-light">
                                        <tr>
                                            <th>ID</th>
                                            <th>Yêu Cầu</th>
                                            <th>Hợp Đồng</th>
                                            <th>KTV</th>
                                            <th>Ngày Bảo Trì</th>
                                            <th>Loại</th>
                                            <th>Độ Ưu Tiên</th>
                                            <th>Trạng Thái</th>
                                            <th>Hành Động</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="schedule" items="${allSchedules}">
                                            <tr>
                                                <td>#${schedule.scheduleId}</td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${schedule.requestId != null}">
                                                            #${schedule.requestId}
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="text-muted">N/A</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${schedule.contractId != null}">
                                                            #${schedule.contractId}
                                                            <c:if test="${not empty contractDetailsMap && contractDetailsMap[schedule.contractId] != null}">
                                                                - ${contractDetailsMap[schedule.contractId]}
                                                            </c:if>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="text-muted">N/A</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${schedule.assignedTo != null}">
                                                            KTV 
                                                            <c:if test="${not empty technicianNamesMap && technicianNamesMap[schedule.assignedTo] != null}">
                                                                ${technicianNamesMap[schedule.assignedTo]}
                                                            </c:if>
                                                            (#${schedule.assignedTo})
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="text-muted">N/A</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>${schedule.scheduledDate}</td>
                                                <td>
                                                    <span class="badge bg-info">
                                                        <c:choose>
                                                            <c:when test="${schedule.scheduleType == 'Preventive'}">Bảo Trì Định Kỳ</c:when>
                                                            <c:when test="${schedule.scheduleType == 'Corrective'}">Bảo Trì Sửa Chữa</c:when>
                                                            <c:when test="${schedule.scheduleType == 'Emergency'}">Bảo Trì Khẩn Cấp</c:when>
                                                            <c:when test="${schedule.scheduleType == 'Inspection'}">Kiểm Tra</c:when>
                                                            <c:otherwise>${schedule.scheduleType}</c:otherwise>
                                                        </c:choose>
                                                    </span>
                                                </td>
                                                <td>
                                                    <span class="priority-indicator priority-${schedule.priorityId == 1 ? 'low' : 
                                                                                        schedule.priorityId == 2 ? 'medium' : 
                                                                                        schedule.priorityId == 3 ? 'high' : 'critical'}"></span>
                                                    ${schedule.priorityId == 1 ? 'Thấp' : 
                                                      schedule.priorityId == 2 ? 'Trung Bình' : 
                                                      schedule.priorityId == 3 ? 'Cao' : 'Khẩn Cấp'}
                                                </td>
                                                <td>
                                                    <span class="badge status-${schedule.status.toLowerCase().replace(' ', '-')}">
                                                        <c:choose>
                                                            <c:when test="${schedule.status == 'Pending'}">Chờ Xử Lý</c:when>
                                                            <c:when test="${schedule.status == 'In Progress'}">Đang Thực Hiện</c:when>
                                                            <c:when test="${schedule.status == 'Completed'}">Hoàn Thành</c:when>
                                                            <c:when test="${schedule.status == 'Approved'}">Đã Duyệt</c:when>
                                                            <c:when test="${schedule.status == 'Rejected'}">Bị Từ Chối</c:when>
                                                            <c:when test="${schedule.status == 'Pending Review'}">Chờ Duyệt</c:when>
                                                            <c:when test="${schedule.status == 'Cancelled'}">Đã Hủy</c:when>
                                                            <c:otherwise>${schedule.status}</c:otherwise>
                                                        </c:choose>
                                                    </span>
                                                </td>
                                                <td>
                                                    <div class="btn-group btn-group-sm">
                                                        <button class="btn btn-outline-primary action-btn" 
                                                                data-action="view"
                                                                data-schedule-id="<c:out value='${schedule.scheduleId}' escapeXml='true'/>"
                                                                title="Xem chi tiết">
                                                            <i class="fas fa-eye"></i>
                                                        </button>
                                                        <c:if test="${schedule.status == 'Completed' || schedule.status == 'Pending Review'}">
                                                            <button class="btn btn-outline-success action-btn" 
                                                                    data-action="approve"
                                                                    data-schedule-id="<c:out value='${schedule.scheduleId}' escapeXml='true'/>"
                                                                    title="Phê duyệt">
                                                                <i class="fas fa-check"></i>
                                                            </button>
<!--                                                            <button class="btn btn-outline-danger action-btn" 
                                                                    data-action="reject"
                                                                    data-schedule-id="<c:out value='${schedule.scheduleId}' escapeXml='true'/>"
                                                                    title="Từ chối">
                                                                <i class="fas fa-times"></i>
                                                            </button>-->
                                                            <button class="btn btn-outline-warning action-btn" 
                                                                    data-action="revision"
                                                                    data-schedule-id="<c:out value='${schedule.scheduleId}' escapeXml='true'/>"
                                                                    title="Yêu cầu chỉnh sửa">
                                                                <i class="fas fa-edit"></i>
                                                            </button>
                                                        </c:if>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Pending Reports Tab -->
                <div class="tab-pane fade" id="pending-reports" role="tabpanel">
                    <div class="card">
                        <div class="card-header">
                            <h5 class="mb-0"><i class="fas fa-clock me-2"></i>Báo Cáo Chờ Duyệt</h5>
                        </div>
                        <div class="card-body">
                            <c:choose>
                                <c:when test="${not empty pendingReports}">
                                    <div class="table-responsive">
                                        <table class="table table-hover">
                                            <thead class="table-light">
                                                <tr>
                                                    <th>ID</th>
                                                    <th>Yêu Cầu</th>
                                                    <th>KTV</th>
                                                    <th>Ngày Bảo Trì</th>
                                                    <th>Loại</th>
                                                    <th>Độ Ưu Tiên</th>
                                                    <th>Hành Động</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach var="schedule" items="${pendingReports}">
                                                    <tr>
                                                        <td>#${schedule.scheduleId}</td>
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${schedule.requestId != null}">
                                                                    #${schedule.requestId}
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="text-muted">N/A</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${schedule.assignedTo != null}">
                                                                    KTV 
                                                                    <c:if test="${not empty technicianNamesMap && technicianNamesMap[schedule.assignedTo] != null}">
                                                                        ${technicianNamesMap[schedule.assignedTo]}
                                                                    </c:if>
                                                                    (#${schedule.assignedTo})
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="text-muted">N/A</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                        <td>${schedule.scheduledDate}</td>
                                                        <td>
                                                            <span class="badge bg-info">
                                                                <c:choose>
                                                                    <c:when test="${schedule.scheduleType == 'Preventive'}">Bảo Trì Định Kỳ</c:when>
                                                                    <c:when test="${schedule.scheduleType == 'Corrective'}">Bảo Trì Sửa Chữa</c:when>
                                                                    <c:when test="${schedule.scheduleType == 'Emergency'}">Bảo Trì Khẩn Cấp</c:when>
                                                                    <c:when test="${schedule.scheduleType == 'Inspection'}">Kiểm Tra</c:when>
                                                                    <c:otherwise>${schedule.scheduleType}</c:otherwise>
                                                                </c:choose>
                                                            </span>
                                                        </td>
                                                        <td>
                                                            <span class="priority-indicator priority-${schedule.priorityId == 1 ? 'low' : 
                                                                                                    schedule.priorityId == 2 ? 'medium' : 
                                                                                                    schedule.priorityId == 3 ? 'high' : 'critical'}"></span>
                                                            ${schedule.priorityId == 1 ? 'Thấp' : 
                                                              schedule.priorityId == 2 ? 'Trung Bình' : 
                                                              schedule.priorityId == 3 ? 'Cao' : 'Khẩn Cấp'}
                                                        </td>
                                                        <td>
                                                            <div class="action-buttons">
                                                                <button class="btn btn-sm btn-outline-primary action-btn" 
                                                                        data-action="view"
                                                                        data-schedule-id="<c:out value='${schedule.scheduleId}' escapeXml='true'/>">
                                                                    <i class="fas fa-eye me-1"></i>Xem
                                                                </button>
                                                                <button class="btn btn-sm btn-success action-btn" 
                                                                        data-action="approve"
                                                                        data-schedule-id="<c:out value='${schedule.scheduleId}' escapeXml='true'/>">
                                                                    <i class="fas fa-check me-1"></i>Duyệt
                                                                </button>
                                                                <button class="btn btn-sm btn-danger action-btn" 
                                                                        data-action="reject"
                                                                        data-schedule-id="<c:out value='${schedule.scheduleId}' escapeXml='true'/>">
                                                                    <i class="fas fa-times me-1"></i>Từ Chối
                                                                </button>
                                                                <button class="btn btn-sm btn-warning action-btn" 
                                                                        data-action="revision"
                                                                        data-schedule-id="<c:out value='${schedule.scheduleId}' escapeXml='true'/>">
                                                                    <i class="fas fa-edit me-1"></i>Chỉnh Sửa
                                                                </button>
                                                            </div>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </tbody>
                                        </table>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="text-center py-5">
                                        <i class="fas fa-inbox fa-3x text-muted mb-3"></i>
                                        <h5 class="text-muted">Không có báo cáo nào chờ duyệt</h5>
                                        <p class="text-muted">Tất cả báo cáo đã được xử lý</p>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>

                <!-- Completed Reports Tab -->
                <div class="tab-pane fade" id="completed-reports" role="tabpanel">
                    <div class="card">
                        <div class="card-header">
                            <h5 class="mb-0"><i class="fas fa-check me-2"></i>Báo Cáo Hoàn Thành</h5>
                        </div>
                        <div class="card-body">
                            <c:choose>
                                <c:when test="${not empty completedSchedules}">
                                    <div class="table-responsive">
                                        <table class="table table-hover">
                                            <thead class="table-light">
                                                <tr>
                                                    <th>ID</th>
                                                    <th>Yêu Cầu</th>
                                                    <th>KTV</th>
                                                    <th>Ngày Bảo Trì</th>
                                                    <th>Loại</th>
                                                    <th>Hành Động</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach var="schedule" items="${completedSchedules}">
                                                    <tr>
                                                        <td>#${schedule.scheduleId}</td>
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${schedule.requestId != null}">
                                                                    #${schedule.requestId}
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="text-muted">N/A</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${schedule.assignedTo != null}">
                                                            KTV 
                                                            <c:if test="${not empty technicianNamesMap && technicianNamesMap[schedule.assignedTo] != null}">
                                                                ${technicianNamesMap[schedule.assignedTo]}
                                                            </c:if>
                                                            (#${schedule.assignedTo})
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="text-muted">N/A</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                        <td>${schedule.scheduledDate}</td>
                                                        <td>
                                                            <span class="badge bg-info">
                                                                <c:choose>
                                                                    <c:when test="${schedule.scheduleType == 'Preventive'}">Bảo Trì Định Kỳ</c:when>
                                                                    <c:when test="${schedule.scheduleType == 'Corrective'}">Bảo Trì Sửa Chữa</c:when>
                                                                    <c:when test="${schedule.scheduleType == 'Emergency'}">Bảo Trì Khẩn Cấp</c:when>
                                                                    <c:when test="${schedule.scheduleType == 'Inspection'}">Kiểm Tra</c:when>
                                                                    <c:otherwise>${schedule.scheduleType}</c:otherwise>
                                                                </c:choose>
                                                            </span>
                                                        </td>
                                                        <td>
                                                            <div class="action-buttons">
                                                                <button class="btn btn-sm btn-outline-primary action-btn" 
                                                                        data-action="view"
                                                                        data-schedule-id="<c:out value='${schedule.scheduleId}' escapeXml='true'/>">
                                                                    <i class="fas fa-eye me-1"></i>Xem Chi Tiết
                                                                </button>
                                                                <button class="btn btn-sm btn-success action-btn" 
                                                                        data-action="approve"
                                                                        data-schedule-id="<c:out value='${schedule.scheduleId}' escapeXml='true'/>">
                                                                    <i class="fas fa-check me-1"></i>Phê Duyệt
                                                                </button>
                                                            </div>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </tbody>
                                        </table>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="text-center py-5">
                                        <i class="fas fa-inbox fa-3x text-muted mb-3"></i>
                                        <h5 class="text-muted">Không có báo cáo hoàn thành nào</h5>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>

                <!-- Approved Reports Tab -->
                <div class="tab-pane fade" id="approved-reports" role="tabpanel">
                    <div class="card">
                        <div class="card-header">
                            <h5 class="mb-0"><i class="fas fa-thumbs-up me-2"></i>Báo Cáo Đã Duyệt</h5>
                        </div>
                        <div class="card-body">
                            <c:choose>
                                <c:when test="${not empty approvedReports}">
                                    <div class="table-responsive">
                                        <table class="table table-hover">
                                            <thead class="table-light">
                                                <tr>
                                                    <th>ID</th>
                                                    <th>Yêu Cầu</th>
                                                    <th>KTV</th>
                                                    <th>Ngày Bảo Trì</th>
                                                    <th>Loại</th>
                                                    <th>Hành Động</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach var="schedule" items="${approvedReports}">
                                                    <tr>
                                                        <td>#${schedule.scheduleId}</td>
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${schedule.requestId != null}">
                                                                    #${schedule.requestId}
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="text-muted">N/A</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${schedule.assignedTo != null}">
                                                                    KTV 
                                                                    <c:if test="${not empty technicianNamesMap && technicianNamesMap[schedule.assignedTo] != null}">
                                                                        ${technicianNamesMap[schedule.assignedTo]}
                                                                    </c:if>
                                                                    (#${schedule.assignedTo})
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="text-muted">N/A</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                        <td>${schedule.scheduledDate}</td>
                                                        <td>
                                                            <span class="badge bg-info">${schedule.scheduleType}</span>
                                                        </td>
                                                        <td>
                                                            <button class="btn btn-sm btn-outline-primary action-btn" 
                                                                    data-action="view"
                                                                    data-schedule-id="<c:out value='${schedule.scheduleId}' escapeXml='true'/>">
                                                                <i class="fas fa-eye me-1"></i>Xem Chi Tiết
                                                            </button>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </tbody>
                                        </table>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="text-center py-5">
                                        <i class="fas fa-inbox fa-3x text-muted mb-3"></i>
                                        <h5 class="text-muted">Chưa có báo cáo nào được duyệt</h5>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>

                <!-- Rejected Reports Tab -->
                <div class="tab-pane fade" id="rejected-reports" role="tabpanel">
                    <div class="card">
                        <div class="card-header">
                            <h5 class="mb-0"><i class="fas fa-thumbs-down me-2"></i>Báo Cáo Bị Từ Chối</h5>
                        </div>
                        <div class="card-body">
                            <c:choose>
                                <c:when test="${not empty rejectedReports}">
                                    <div class="table-responsive">
                                        <table class="table table-hover">
                                            <thead class="table-light">
                                                <tr>
                                                    <th>ID</th>
                                                    <th>Yêu Cầu</th>
                                                    <th>KTV</th>
                                                    <th>Ngày Bảo Trì</th>
                                                    <th>Loại</th>
                                                    <th>Hành Động</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach var="schedule" items="${rejectedReports}">
                                                    <tr>
                                                        <td>#${schedule.scheduleId}</td>
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${schedule.requestId != null}">
                                                                    #${schedule.requestId}
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="text-muted">N/A</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${schedule.assignedTo != null}">
                                                                    KTV 
                                                                    <c:if test="${not empty technicianNamesMap && technicianNamesMap[schedule.assignedTo] != null}">
                                                                        ${technicianNamesMap[schedule.assignedTo]}
                                                                    </c:if>
                                                                    (#${schedule.assignedTo})
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="text-muted">N/A</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                        <td>${schedule.scheduledDate}</td>
                                                        <td>
                                                            <span class="badge bg-info">${schedule.scheduleType}</span>
                                                        </td>
                                                        <td>
                                                            <button class="btn btn-sm btn-outline-primary action-btn" 
                                                                    data-action="view"
                                                                    data-schedule-id="<c:out value='${schedule.scheduleId}' escapeXml='true'/>">
                                                                <i class="fas fa-eye me-1"></i>Xem Chi Tiết
                                                            </button>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </tbody>
                                        </table>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="text-center py-5">
                                        <i class="fas fa-inbox fa-3x text-muted mb-3"></i>
                                        <h5 class="text-muted">Không có báo cáo nào bị từ chối</h5>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Report Details Modal -->
    <div class="modal fade" id="reportDetailsModal" tabindex="-1">
        <div class="modal-dialog modal-xl">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="fas fa-file-alt me-2"></i>Chi Tiết Báo Cáo Bảo Trì</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body" id="reportDetailsContent">
                    <!-- Content will be loaded dynamically -->
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Approve Report Modal -->
    <div class="modal fade" id="approveReportModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="fas fa-check me-2"></i>Phê Duyệt Báo Cáo</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <form action="reviewMaintenanceReport" method="post">
                    <div class="modal-body">
                        <input type="hidden" name="action" value="approveReport">
                        <input type="hidden" name="scheduleId" id="approveScheduleId">
                        
                        <div class="mb-3">
                            <label for="approvalComments" class="form-label">Nhận Xét Phê Duyệt</label>
                            <textarea class="form-control" id="approvalComments" name="approvalComments" 
                                      rows="4" placeholder="Nhập nhận xét về báo cáo (tùy chọn)..."></textarea>
                        </div>
                        
                        <div class="alert alert-info">
                            <i class="fas fa-info-circle me-2"></i>
                            Bạn có chắc chắn muốn phê duyệt báo cáo bảo trì này?
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                        <button type="submit" class="btn btn-success">
                            <i class="fas fa-check me-2"></i>Phê Duyệt
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Reject Report Modal -->
    <div class="modal fade" id="rejectReportModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="fas fa-times me-2"></i>Từ Chối Báo Cáo</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <form action="reviewMaintenanceReport" method="post">
                    <div class="modal-body">
                        <input type="hidden" name="action" value="rejectReport">
                        <input type="hidden" name="scheduleId" id="rejectScheduleId">
                        
                        <div class="mb-3">
                            <label for="rejectionReason" class="form-label">Lý Do Từ Chối <span class="text-danger">*</span></label>
                            <textarea class="form-control" id="rejectionReason" name="rejectionReason" 
                                      rows="4" placeholder="Nhập lý do từ chối báo cáo..." required></textarea>
                        </div>
                        
                        <div class="alert alert-warning">
                            <i class="fas fa-exclamation-triangle me-2"></i>
                            Báo cáo sẽ được đánh dấu là bị từ chối và kỹ thuật viên sẽ được thông báo.
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                        <button type="submit" class="btn btn-danger">
                            <i class="fas fa-times me-2"></i>Từ Chối
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Request Revision Modal -->
    <div class="modal fade" id="revisionModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="fas fa-edit me-2"></i>Yêu Cầu Chỉnh Sửa</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <form action="reviewMaintenanceReport" method="post">
                    <div class="modal-body">
                        <input type="hidden" name="action" value="requestRevision">
                        <input type="hidden" name="scheduleId" id="revisionScheduleId">
                        
                        <div class="mb-3">
                            <label for="revisionComments" class="form-label">Yêu Cầu Chỉnh Sửa <span class="text-danger">*</span></label>
                            <textarea class="form-control" id="revisionComments" name="revisionComments" 
                                      rows="4" placeholder="Nhập yêu cầu chỉnh sửa cụ thể..." required></textarea>
                        </div>
                        
                        <div class="alert alert-info">
                            <i class="fas fa-info-circle me-2"></i>
                            Kỹ thuật viên sẽ nhận được thông báo và có thể chỉnh sửa báo cáo theo yêu cầu.
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                        <button type="submit" class="btn btn-warning">
                            <i class="fas fa-edit me-2"></i>Gửi Yêu Cầu
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.datatables.net/1.11.5/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.11.5/js/dataTables.bootstrap5.min.js"></script>
    <script>
        $(document).ready(function() {
            // Initialize DataTables
            $('#allReportsTable').DataTable({
                "pageLength": 10,
                "order": [[0, "desc"]],
                "language": {
                    "url": "//cdn.datatables.net/plug-ins/1.11.5/i18n/vi.json"
                }
            });
            
            // Event delegation for action buttons
            $(document).on('click', '.action-btn', function(e) {
                e.preventDefault();
                const action = $(this).data('action');
                const scheduleId = $(this).data('schedule-id');
                
                switch(action) {
                    case 'view':
                        viewReportDetails(scheduleId);
                        break;
                    case 'approve':
                        approveReport(scheduleId);
                        break;
                    case 'reject':
                        rejectReport(scheduleId);
                        break;
                    case 'revision':
                        requestRevision(scheduleId);
                        break;
                }
            });
        });
        
        function viewReportDetails(scheduleId) {
            fetch('reviewMaintenanceReport?action=getReportDetails&scheduleId=' + scheduleId)
            .then(response => response.json())
            .then(data => {
                if (data.error) {
                    showToast('Lỗi khi tải chi tiết báo cáo: ' + data.error, 'error');
                    return;
                }
                
                const schedule = data.schedule;
                const serviceRequest = data.serviceRequest;
                const assignments = data.assignments;
                
                let content = '<div class="report-details">' +
                    '<div class="report-section">' +
                        '<h6><i class="fas fa-calendar me-2"></i>Thông Tin Lịch Bảo Trì</h6>' +
                        '<div class="row">' +
                            '<div class="col-md-6">' +
                                '<p><strong>ID Lịch:</strong> #' + schedule.scheduleId + '</p>' +
                                '<p><strong>Loại Bảo Trì:</strong> <span class="badge bg-info">' + schedule.scheduleType + '</span></p>' +
                                '<p><strong>Ngày Bảo Trì:</strong> ' + schedule.scheduledDate + '</p>' +
                                '<p><strong>Trạng Thái:</strong> <span class="badge status-' + schedule.status.toLowerCase().replace(' ', '-') + '">' +
                                    (schedule.status == 'Completed' ? 'Hoàn Thành' : 
                                     schedule.status == 'Cancelled' ? 'Đã Hủy' : 
                                     schedule.status == 'Scheduled' ? 'Đã Lên Lịch' : 
                                     schedule.status == 'In Progress' ? 'Đang Thực Hiện' : 
                                     schedule.status == 'Pending Review' ? 'Chờ Duyệt' : 
                                     schedule.status) +
                                '</span></p>' +
                            '</div>' +
                            '<div class="col-md-6">' +
                                '<p><strong>KTV Phụ Trách:</strong> KTV ' + (data.technicianName ? data.technicianName + ' ' : '') + '(#' + schedule.assignedTo + ')' + '</p>' +
                                '<p><strong>Độ Ưu Tiên:</strong> ' +
                                    '<span class="priority-indicator priority-' + (schedule.priorityId == 1 ? 'low' : 
                                                                                    schedule.priorityId == 2 ? 'medium' : 
                                                                                    schedule.priorityId == 3 ? 'high' : 'critical') + '"></span>' +
                                    (schedule.priorityId == 1 ? 'Thấp' : 
                                     schedule.priorityId == 2 ? 'Trung Bình' : 
                                     schedule.priorityId == 3 ? 'Cao' : 'Khẩn Cấp') +
                                '</p>' +
                                '<p><strong>Quy Tắc Lặp:</strong> ' + (schedule.recurrenceRule || 'Không lặp lại') + '</p>' +
                            '</div>' +
                        '</div>' +
                    '</div>';

                // Contract information section (Technician must include Contract Name and ID)
                if (schedule.contractId) {
                    content += '<div class="report-section">' +
                        '<h6><i class="fas fa-file-contract me-2"></i>Thông Tin Hợp Đồng</h6>' +
                        '<div class="row">' +
                            '<div class="col-md-6">' +
                                '<p><strong>ID Hợp Đồng:</strong> #' + schedule.contractId + '</p>' +
                                '<p><strong>Tên/Chi Tiết Hợp Đồng:</strong> ' + (data.contract && data.contract.details ? data.contract.details : 'N/A') + '</p>' +
                                '<p><strong>Loại Hợp Đồng:</strong> ' + (data.contract && data.contract.contractType ? data.contract.contractType : 'N/A') + '</p>' +
                            '</div>' +
                            '<div class="col-md-6">' +
                                '<p><strong>Ngày Ký:</strong> ' + (data.contract && data.contract.contractDate ? data.contract.contractDate : 'N/A') + '</p>' +
                                '<p><strong>Trạng Thái:</strong> ' + (data.contract && data.contract.status ? data.contract.status : 'N/A') + '</p>' +
                                '<p><strong>Khách Hàng:</strong> ' + (data.contract && (data.contract.customerName || data.contract.customerId) ? (data.contract.customerName || ('#' + data.contract.customerId)) : 'N/A') + '</p>' +
                            '</div>' +
                        '</div>' +
                    '</div>';
                }
                
                if (serviceRequest) {
                    content += '<div class="report-section">' +
                            '<h6><i class="fas fa-clipboard-list me-2"></i>Thông Tin Yêu Cầu Dịch Vụ</h6>' +
                            '<div class="row">' +
                                '<div class="col-md-6">' +
                                    '<p><strong>ID Yêu Cầu:</strong> #' + serviceRequest.requestId + '</p>' +
                                    '<p><strong>Loại Dịch Vụ:</strong> ' + serviceRequest.requestType + '</p>' +
                                    '<p><strong>Mô Tả:</strong> ' + (serviceRequest.description || 'N/A') + '</p>' +
                                '</div>' +
                                '<div class="col-md-6">' +
                                    '<p><strong>Ngày Tạo:</strong> ' + serviceRequest.requestDate + '</p>' +
                                    '<p><strong>Trạng Thái:</strong> ' +
                                        (serviceRequest.status == 'Completed' ? 'Hoàn Thành' : 
                                         serviceRequest.status == 'Cancelled' ? 'Đã Hủy' : 
                                         serviceRequest.status == 'Pending' ? 'Chờ Xử Lý' : 
                                         serviceRequest.status == 'Approved' ? 'Đã Duyệt' : 
                                         serviceRequest.status == 'Rejected' ? 'Từ Chối' : 
                                         serviceRequest.status) +
                                    '</p>' +
                                '</div>' +
                            '</div>' +
                        '</div>';
                }
                
                if (assignments && assignments.length > 0) {
                    content += '<div class="report-section">' +
                            '<h6><i class="fas fa-tasks me-2"></i>Phân Công Công Việc</h6>' +
                            '<div class="table-responsive">' +
                                '<table class="table table-sm">' +
                                    '<thead>' +
                                        '<tr>' +
                                            '<th>ID</th>' +
                                            '<th>Người Phân Công</th>' +
                                            '<th>Ngày Phân Công</th>' +
                                            '<th>Thời Gian Ước Tính</th>' +
                                            '<th>Độ Ưu Tiên</th>' +
                                            '<th>Trạng Thái</th>' +
                                        '</tr>' +
                                    '</thead>' +
                                    '<tbody>';
                    
                    assignments.forEach(assignment => {
                        content += '<tr>' +
                                '<td>#' + assignment.assignmentId + '</td>' +
                                '<td>Manager #' + assignment.assignedBy + '</td>' +
                                '<td>' + assignment.assignmentDate + '</td>' +
                                '<td>' + (assignment.estimatedDuration || 'N/A') + '</td>' +
                                '<td>' + assignment.priorityLevel + '</td>' +
                                '<td>' + (assignment.acceptedByTechnician ? 'Đã Chấp Nhận' : 'Chờ Chấp Nhận') + '</td>' +
                            '</tr>';
                    });
                    
                    content += '</tbody>' +
                                '</table>' +
                            '</div>' +
                        '</div>';
                }
                
                content += '</div>';
                
                document.getElementById('reportDetailsContent').innerHTML = content;
                
                const modal = new bootstrap.Modal(document.getElementById('reportDetailsModal'));
                modal.show();
            })
            .catch(error => {
                console.error('Error fetching report details:', error);
                showToast('Lỗi khi tải chi tiết báo cáo!', 'error');
            });
        }
        
        function approveReport(scheduleId) {
            document.getElementById('approveScheduleId').value = scheduleId;
            const modal = new bootstrap.Modal(document.getElementById('approveReportModal'));
            modal.show();
        }
        
        function rejectReport(scheduleId) {
            document.getElementById('rejectScheduleId').value = scheduleId;
            const modal = new bootstrap.Modal(document.getElementById('rejectReportModal'));
            modal.show();
        }
        
        function requestRevision(scheduleId) {
            document.getElementById('revisionScheduleId').value = scheduleId;
            const modal = new bootstrap.Modal(document.getElementById('revisionModal'));
            modal.show();
        }
        
        function showToast(message, type) {
            const toast = document.createElement('div');
            toast.className = 'alert alert-' + (type == 'success' ? 'success' : 'danger') + ' position-fixed';
            toast.style.cssText = 'top: 20px; right: 20px; z-index: 9999; min-width: 300px;';
            toast.innerHTML = message +
                '<button type="button" class="btn-close" onclick="this.parentElement.remove()"></button>';
            document.body.appendChild(toast);
            
            setTimeout(() => {
                if (toast.parentElement) {
                    toast.remove();
                }
            }, 5000);
        }
    </script>
        </div> <!-- content-wrapper -->
    </div> <!-- main-content -->
</body>
</html>