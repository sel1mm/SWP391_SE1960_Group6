<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@page import="model.Account"%>
<%@page import="java.util.List"%>
<%@page import="model.MaintenanceSchedule"%>
<%@page import="model.ServiceRequest"%>
<%@page import="model.TechnicianWorkload"%>
<%@page import="model.Equipment"%>
<%@page import="model.Contract"%>

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
    <title>Lập Lịch Bảo Trì - Technical Manager</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/fullcalendar@5.11.3/main.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #f8f9fa;
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            margin: 0;
            padding: 0;
        }

        /* Sidebar Styles */
      /* SIDEBAR STYLES */
            .sidebar {
                position: fixed;
                top: 0;
                left: 0;
                height: 100vh;
                width: 260px;
                background: linear-gradient(180deg, #1a1a2e 0%, #16213e 100%);
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
        
        .calendar-container {
            background: white;
            border-radius: 15px;
            padding: 20px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }
        
        .fc-event {
            border-radius: 5px;
            border: none;
            padding: 2px 5px;
        }
        
        .fc-event-scheduled { background-color: #007bff; }
        .fc-event-in-progress { background-color: #ffc107; }
        .fc-event-completed { background-color: #28a745; }
        .fc-event-overdue { background-color: #dc3545; }
        
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
        .priority-critical { background-color: #dc3545; }
        
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
                <a class="nav-link" href="dashboard.jsp">
                    <i class="fas fa-tachometer-alt me-2"></i>Dashboard
                </a>
            </li>
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
                <a class="nav-link active" href="scheduleMaintenance">
                    <i class="fas fa-calendar-alt me-2"></i>Lập Lịch Bảo Trì
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="reviewMaintenanceReport">
                    <i class="fas fa-file-alt me-2"></i>Xem Báo Cáo Bảo Trì
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="manageProfile.jsp">
                    <i class="fas fa-cog me-2"></i>Cài Đặt
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
                    <h2><i class="fas fa-calendar-alt me-3"></i>Lập Lịch Bảo Trì</h2>
                    <p class="text-muted">Quản lý và lập lịch bảo trì thiết bị</p>
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
                <div class="col-md-3">
                    <div class="stats-card">
                        <div class="stats-number">${allSchedules.size()}</div>
                        <div class="stats-label">Tổng Lịch Bảo Trì</div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="stats-card">
                        <div class="stats-number">${upcomingSchedules.size()}</div>
                        <div class="stats-label">Sắp Tới (7 ngày)</div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="stats-card">
                        <div class="stats-number">${overdueSchedules.size()}</div>
                        <div class="stats-label">Quá Hạn</div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="stats-card">
                        <div class="stats-number">${availableTechnicians.size()}</div>
                        <div class="stats-label">KTV Có Sẵn</div>
                    </div>
                </div>
            </div>

            <!-- Create Schedule Form -->
            <div class="row">
                <div class="col-lg-4">
                    <div class="card">
                        <div class="card-header">
                            <h5 class="mb-0"><i class="fas fa-plus-circle me-2"></i>Tạo Lịch Bảo Trì Mới</h5>
                        </div>
                        <div class="card-body">
                            <form action="scheduleMaintenance" method="post" id="scheduleForm">
                                <input type="hidden" name="action" value="createSchedule">
                                
                                <div class="mb-3">
                                    <label for="requestId" class="form-label">Yêu Cầu Dịch Vụ</label>
                                    <select class="form-select" id="requestId" name="requestId">
                                        <option value="">Chọn yêu cầu dịch vụ (tùy chọn)...</option>
                                        <c:forEach var="request" items="${approvedRequests}">
                                            <option value="${request.requestId}">
                                                #${request.requestId} - ${request.requestType}
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>
                                
                                <div class="mb-3">
                                    <label for="contractId" class="form-label">Hợp Đồng</label>
                                    <select class="form-select" id="contractId" name="contractId">
                                        <option value="">Chọn hợp đồng (tùy chọn)...</option>
                                        <c:forEach var="contract" items="${contractList}">
                                            <option value="${contract.contractId}">
                                                #${contract.contractId} - ${contract.details}
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>
                                
                                <div class="mb-3">
                                    <label for="equipmentId" class="form-label">Thiết Bị</label>
                                    <select class="form-select" id="equipmentId" name="equipmentId">
                                        <option value="">Chọn thiết bị (tùy chọn)...</option>
                                        <c:forEach var="equipment" items="${equipmentList}">
                                            <option value="${equipment.equipmentId}">
                                                ${equipment.serialNumber} - ${equipment.model} - ${equipment.description}
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>
                                
                                <div class="mb-3">
                                    <label for="assignedTo" class="form-label">Kỹ Thuật Viên <span class="text-danger">*</span></label>
                                    <select class="form-select" id="assignedTo" name="assignedTo" required>
                                        <option value="">Chọn kỹ thuật viên...</option>
                                        <c:forEach var="technician" items="${availableTechnicians}">
                                            <option value="${technician.technicianId}">
                                                KTV #${technician.technicianId} 
                                                (Khả năng: ${technician.availableCapacity}/${technician.maxConcurrentTasks})
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>
                                
                                <div class="mb-3">
                                    <label for="scheduledDate" class="form-label">Ngày Giờ Bảo Trì <span class="text-danger">*</span></label>
                                    <input type="datetime-local" class="form-control" id="scheduledDate" 
                                           name="scheduledDate" required>
                                </div>
                                
                                <div class="mb-3">
                                    <label for="scheduleType" class="form-label">Loại Bảo Trì <span class="text-danger">*</span></label>
                                    <select class="form-select" id="scheduleType" name="scheduleType" required>
                                        <option value="">Chọn loại bảo trì...</option>
                                        <option value="Preventive">Bảo Trì Định Kỳ</option>
                                        <option value="Corrective">Bảo Trì Sửa Chữa</option>
                                        <option value="Emergency">Bảo Trì Khẩn Cấp</option>
                                        <option value="Inspection">Kiểm Tra</option>
                                    </select>
                                </div>
                                
                                <div class="mb-3">
                                    <label for="recurrenceRule" class="form-label">Quy Tắc Lặp Lại</label>
                                    <select class="form-select" id="recurrenceRule" name="recurrenceRule">
                                        <option value="">Không lặp lại</option>
                                        <option value="WEEKLY">Hàng tuần</option>
                                        <option value="MONTHLY">Hàng tháng</option>
                                        <option value="QUARTERLY">Hàng quý</option>
                                        <option value="YEARLY">Hàng năm</option>
                                    </select>
                                </div>
                                
                                <div class="mb-3">
                                    <label for="priorityId" class="form-label">Độ Ưu Tiên</label>
                                    <select class="form-select" id="priorityId" name="priorityId">
                                        <option value="1">Thấp</option>
                                        <option value="2" selected>Trung Bình</option>
                                        <option value="3">Cao</option>
                                        <option value="4">Khẩn Cấp</option>
                                    </select>
                                </div>
                                
                                <div class="d-grid">
                                    <button type="submit" class="btn btn-primary">
                                        <i class="fas fa-calendar-plus me-2"></i>Tạo Lịch Bảo Trì
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
                
                <!-- Calendar View -->
                <div class="col-lg-8">
                    <div class="calendar-container">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h5><i class="fas fa-calendar me-2"></i>Lịch Bảo Trì</h5>
                           
                        </div>
                        <div id="calendar"></div>
                    </div>
                </div>
            </div>

            <!-- Schedule List -->
            <div class="row mt-4">
                <div class="col-12">
                    <div class="card">
                        <div class="card-header d-flex justify-content-between align-items-center">
                            <h5 class="mb-0"><i class="fas fa-list me-2"></i>Danh Sách Lịch Bảo Trì</h5>
                            <div class="btn-group">
                                <button class="btn btn-outline-light btn-sm" onclick="filterSchedules('all')">Tất Cả</button>
                                <button class="btn btn-outline-light btn-sm" onclick="filterSchedules('upcoming')">Sắp Tới</button>
                                <button class="btn btn-outline-light btn-sm" onclick="filterSchedules('overdue')">Quá Hạn</button>
                            </div>
                        </div>
                        <div class="card-body">
                            <div class="table-responsive">
                                <table class="table table-hover" id="scheduleTable">
                                    <thead class="table-light">
                                        <tr>
                                            <th>ID</th>
                                            <th>Yêu Cầu</th>
                                            <th>Thiết Bị</th>
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
                                            <tr data-schedule-id="${schedule.scheduleId}">
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
                                                        <c:when test="${schedule.equipmentId != null}">
                                                            #${schedule.equipmentId}
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="text-muted">N/A</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>KTV #${schedule.assignedTo}</td>
                                                <td>${schedule.scheduledDate}</td>
                                                <td>
                                                    <span class="badge bg-info">${schedule.scheduleType}</span>
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
                                                    <select class="form-select form-select-sm" 
                                                            onchange="updateScheduleStatus(${schedule.scheduleId}, this.value)">
                                                        <option value="Scheduled" ${schedule.status == 'Scheduled' ? 'selected' : ''}>Đã Lên Lịch</option>
                                                        <option value="In Progress" ${schedule.status == 'In Progress' ? 'selected' : ''}>Đang Thực Hiện</option>
                                                        <option value="Completed" ${schedule.status == 'Completed' ? 'selected' : ''}>Hoàn Thành</option>
                                                        <option value="Cancelled" ${schedule.status == 'Cancelled' ? 'selected' : ''}>Hủy Bỏ</option>
                                                    </select>
                                                </td>
                                                <td>
                                                    <div class="btn-group btn-group-sm">
                                                        <button class="btn btn-outline-primary schedule-action-btn" 
                                                                data-action="edit"
                                                                data-schedule-id="<c:out value='${schedule.scheduleId}' escapeXml='true'/>"
                                                                title="Chỉnh sửa">
                                                            <i class="fas fa-edit"></i>
                                                        </button>
                                                        <button class="btn btn-outline-danger schedule-action-btn" 
                                                                data-action="delete"
                                                                data-schedule-id="<c:out value='${schedule.scheduleId}' escapeXml='true'/>"
                                                                title="Xóa"
                                                                <c:if test='${schedule.status == "Completed" || schedule.status == "In Progress"}'>disabled</c:if>>
                                                            <i class="fas fa-trash"></i>
                                                        </button>
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
            </div>
        </div>
    </div>

    <!-- Edit Schedule Modal -->
    <div class="modal fade" id="editScheduleModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="fas fa-edit me-2"></i>Chỉnh Sửa Lịch Bảo Trì</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <form id="editScheduleForm">
                        <input type="hidden" name="action" value="updateSchedule">
                        <input type="hidden" name="scheduleId" id="editScheduleId">
                        
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="editScheduledDate" class="form-label">Ngày Giờ Bảo Trì</label>
                                <input type="datetime-local" class="form-control" id="editScheduledDate" 
                                       name="scheduledDate" required>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="editScheduleType" class="form-label">Loại Bảo Trì</label>
                                <select class="form-select" id="editScheduleType" name="scheduleType" required>
                                    <option value="Preventive">Bảo Trì Định Kỳ</option>
                                    <option value="Corrective">Bảo Trì Sửa Chữa</option>
                                    <option value="Emergency">Bảo Trì Khẩn Cấp</option>
                                    <option value="Inspection">Kiểm Tra</option>
                                </select>
                            </div>
                        </div>
                        
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="editRecurrenceRule" class="form-label">Quy Tắc Lặp Lại</label>
                                <select class="form-select" id="editRecurrenceRule" name="recurrenceRule">
                                    <option value="">Không lặp lại</option>
                                    <option value="WEEKLY">Hàng tuần</option>
                                    <option value="MONTHLY">Hàng tháng</option>
                                    <option value="QUARTERLY">Hàng quý</option>
                                    <option value="YEARLY">Hàng năm</option>
                                </select>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="editPriorityId" class="form-label">Độ Ưu Tiên</label>
                                <select class="form-select" id="editPriorityId" name="priorityId">
                                    <option value="1">Thấp</option>
                                    <option value="2">Trung Bình</option>
                                    <option value="3">Cao</option>
                                    <option value="4">Khẩn Cấp</option>
                                </select>
                            </div>
                        </div>
                        
                        <div class="mb-3">
                            <label for="editStatus" class="form-label">Trạng Thái</label>
                            <select class="form-select" id="editStatus" name="status">
                                <option value="Scheduled">Đã Lên Lịch</option>
                                <option value="In Progress">Đang Thực Hiện</option>
                                <option value="Completed">Hoàn Thành</option>
                                <option value="Cancelled">Hủy Bỏ</option>
                            </select>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                    <button type="button" class="btn btn-primary" onclick="saveScheduleChanges()">
                        <i class="fas fa-save me-2"></i>Lưu Thay Đổi
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- JSON Data Island for Schedule Events -->
    <script type="application/json" id="scheduleData">
    [
        <c:forEach var="schedule" items="${allSchedules}" varStatus="status">
        {
            "id": "<c:out value='${schedule.scheduleId}' escapeXml='true'/>",
            "title": "<c:out value='${schedule.scheduleType}' escapeXml='true'/> - KTV #<c:out value='${schedule.assignedTo}' escapeXml='true'/>",
            "start": "<c:out value='${schedule.scheduledDate}' escapeXml='true'/>",
            "className": "fc-event-<c:out value='${fn:toLowerCase(fn:replace(schedule.status, " ", "-"))}' escapeXml='true'/>",
            "extendedProps": {
                "scheduleId": <c:out value='${schedule.scheduleId}' default='0'/>,
                "status": "<c:out value='${schedule.status}' escapeXml='true'/>",
                "priority": <c:out value='${schedule.priorityId}' default='1'/>
            }
        }<c:if test="${!status.last}">,</c:if>
        </c:forEach>
    ]
    </script>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/fullcalendar@5.11.3/main.min.js"></script>
    <script>
        let calendar;
        
        document.addEventListener('DOMContentLoaded', function() {
            initializeCalendar();
            setMinDateTime();
        });
        
        function initializeCalendar() {
            // Parse schedule data from JSON data island
            const scheduleDataElement = document.getElementById('scheduleData');
            let scheduleEvents = [];
            
            try {
                scheduleEvents = JSON.parse(scheduleDataElement.textContent);
            } catch (e) {
                console.error('Error parsing schedule data:', e);
                scheduleEvents = [];
            }
            
            const calendarEl = document.getElementById('calendar');
            calendar = new FullCalendar.Calendar(calendarEl, {
                initialView: 'dayGridMonth',
                headerToolbar: {
                    left: 'prev,next today',
                    center: 'title',
                    right: 'dayGridMonth,timeGridWeek,timeGridDay'
                },
                events: scheduleEvents,
                eventClick: function(info) {
                    editSchedule(info.event.extendedProps.scheduleId);
                },
                height: 'auto'
            });
            calendar.render();
        }
        
        function changeCalendarView(view) {
            calendar.changeView(view);
        }
        
        function setMinDateTime() {
            const now = new Date();
            const year = now.getFullYear();
            const month = String(now.getMonth() + 1).padStart(2, '0');
            const day = String(now.getDate()).padStart(2, '0');
            const hours = String(now.getHours()).padStart(2, '0');
            const minutes = String(now.getMinutes()).padStart(2, '0');
            
            const minDateTime = year + '-' + month + '-' + day + 'T' + hours + ':' + minutes;
            document.getElementById('scheduledDate').min = minDateTime;
        }
        
        function filterSchedules(filter) {
            const table = document.getElementById('scheduleTable');
            const rows = table.getElementsByTagName('tbody')[0].getElementsByTagName('tr');
            
            for (let row of rows) {
                const statusCell = row.cells[7].querySelector('select');
                const status = statusCell.value;
                const scheduledDate = new Date(row.cells[4].textContent);
                const now = new Date();
                
                let show = true;
                
                if (filter === 'upcoming') {
                    const weekFromNow = new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000);
                    show = scheduledDate >= now && scheduledDate <= weekFromNow && status !== 'Completed';
                } else if (filter === 'overdue') {
                    show = scheduledDate < now && status !== 'Completed';
                }
                
                row.style.display = show ? '' : 'none';
            }
        }
        
        function updateScheduleStatus(scheduleId, newStatus) {
            fetch('scheduleMaintenance', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: 'action=updateStatus&scheduleId=' + scheduleId + '&status=' + encodeURIComponent(newStatus)
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    showToast('Cập nhật trạng thái thành công!', 'success');
                    // Update calendar
                    const event = calendar.getEventById(scheduleId);
                    if (event) {
                        event.setProp('className', 'fc-event-' + newStatus.toLowerCase().replace(" ", "-"));
                    }
                } else {
                    showToast('Lỗi khi cập nhật trạng thái: ' + (data.error || 'Unknown error'), 'error');
                }
            })
            .catch(error => {
                console.error('Error updating status:', error);
                showToast('Lỗi khi cập nhật trạng thái!', 'error');
            });
        }
        
        function editSchedule(scheduleId) {
            fetch('scheduleMaintenance?action=getScheduleDetails&scheduleId=' + scheduleId)
            .then(response => response.json())
            .then(data => {
                if (data.error) {
                    showToast('Lỗi khi tải thông tin lịch bảo trì: ' + data.error, 'error');
                    return;
                }
                
                // Populate edit form
                document.getElementById('editScheduleId').value = data.scheduleId;
                
                // Format date for datetime-local input
                const scheduledDate = new Date(data.scheduledDate);
                const formattedDate = scheduledDate.toISOString().slice(0, 16);
                document.getElementById('editScheduledDate').value = formattedDate;
                
                document.getElementById('editScheduleType').value = data.scheduleType;
                document.getElementById('editRecurrenceRule').value = data.recurrenceRule || '';
                document.getElementById('editPriorityId').value = data.priorityId;
                document.getElementById('editStatus').value = data.status;
                
                // Show modal
                const modal = new bootstrap.Modal(document.getElementById('editScheduleModal'));
                modal.show();
            })
            .catch(error => {
                console.error('Error fetching schedule details:', error);
                showToast('Lỗi khi tải thông tin lịch bảo trì!', 'error');
            });
        }
        
        function saveScheduleChanges() {
            const form = document.getElementById('editScheduleForm');
            const formData = new FormData(form);
            
            fetch('scheduleMaintenance', {
                method: 'POST',
                body: formData
            })
            .then(response => {
                if (response.ok) {
                    showToast('Cập nhật lịch bảo trì thành công!', 'success');
                    setTimeout(() => {
                        location.reload();
                    }, 1500);
                } else {
                    showToast('Lỗi khi cập nhật lịch bảo trì!', 'error');
                }
            })
            .catch(error => {
                console.error('Error updating schedule:', error);
                showToast('Lỗi khi cập nhật lịch bảo trì!', 'error');
            });
            
            // Hide modal
            const modal = bootstrap.Modal.getInstance(document.getElementById('editScheduleModal'));
            modal.hide();
        }
        
        function deleteSchedule(scheduleId) {
            if (confirm('Bạn có chắc chắn muốn xóa lịch bảo trì này?')) {
                fetch('scheduleMaintenance', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: 'action=deleteSchedule&scheduleId=' + scheduleId
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        showToast('Xóa lịch bảo trì thành công!', 'success');
                        // Remove from table
                        const row = document.querySelector('tr[data-schedule-id="' + scheduleId + '"]');
                        if (row) {
                            row.remove();
                        }
                        // Remove from calendar
                        const event = calendar.getEventById(scheduleId);
                        if (event) {
                            event.remove();
                        }
                    } else {
                        showToast('Lỗi khi xóa lịch bảo trì: ' + (data.error || 'Unknown error'), 'error');
                    }
                })
                .catch(error => {
                    console.error('Error deleting schedule:', error);
                    showToast('Lỗi khi xóa lịch bảo trì!', 'error');
                });
            }
        }
        
        // Event delegation for schedule action buttons
        document.addEventListener('click', function(e) {
            if (e.target.closest('.schedule-action-btn')) {
                const button = e.target.closest('.schedule-action-btn');
                const action = button.getAttribute('data-action');
                const scheduleId = button.getAttribute('data-schedule-id');
                
                if (action && scheduleId) {
                    if (action === 'edit') {
                        editSchedule(scheduleId);
                    } else if (action === 'delete') {
                        deleteSchedule(scheduleId);
                    }
                }
            }
        });
        
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
        
        // Form validation
        document.getElementById('scheduleForm').addEventListener('submit', function(e) {
            const technicianSelect = document.getElementById('assignedTo');
            const selectedOption = technicianSelect.options[technicianSelect.selectedIndex];
            
            if (selectedOption && selectedOption.textContent.includes('(Khả năng: 0/')) {
                e.preventDefault();
                alert('Kỹ thuật viên đã chọn không còn khả năng nhận thêm công việc!');
                return false;
            }
        });
    </script>
        </div> <!-- content-wrapper -->
    </div> <!-- main-content -->
</body>
</html>