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
        /* Tab Styles */
.nav-tabs {
    border-bottom: 2px solid #e9ecef;
}

.nav-tabs .nav-link {
    
    color: #999999 !important; 
    border: none;
    border-bottom: 3px solid transparent;
    padding: 12px 20px;
    font-weight: 500;
    transition: all 0.3s;
}

.nav-tabs .nav-link:hover {
    border-bottom-color: #667eea;
    background: rgba(102, 126, 234, 0.05);
    
}

.nav-tabs .nav-link.active {
    color: #667eea;
    background: rgba(102, 126, 234, 0.1);
    border-bottom-color: #667eea;
    font-weight: 600;
}

.nav-tabs .nav-link .badge {
    font-size: 0.75rem;
    padding: 2px 6px;
    
}
/* Pagination Styles - Improved */
.pagination {
    margin: 0;
    gap: 5px;
}

.pagination .page-item {
    margin: 0 3px;
}

.pagination .page-link {
    color: #495057;
    background-color: #fff;
    border: 2px solid #dee2e6;
    padding: 10px 16px;
    border-radius: 8px;
    font-weight: 500;
    transition: all 0.3s;
    min-width: 45px;
    text-align: center;
}

.pagination .page-link:hover {
    background: #667eea;
    border-color: #667eea;
    color: white;
    transform: translateY(-2px);
    box-shadow: 0 4px 8px rgba(102, 126, 234, 0.3);
}

.pagination .page-item.active .page-link {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    border-color: #667eea;
    color: white;
    font-weight: 700;
    box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
}

.pagination .page-item.disabled .page-link {
    opacity: 0.4;
    cursor: not-allowed;
    background-color: #f8f9fa;
    border-color: #dee2e6;
}

.pagination .page-item.disabled .page-link:hover {
    transform: none;
    box-shadow: none;
    background-color: #f8f9fa;
    border-color: #dee2e6;
    color: #6c757d;
}

/* Pagination info text */
.pagination-info {
    font-size: 0.95rem;
    color: #495057;
    font-weight: 500;
}

.pagination-info span {
    font-weight: 700;
    color: #667eea;
}
.technician-item-schedule {
    transition: all 0.3s ease;
    border-radius: 5px;
}

.technician-item-schedule:hover {
    background-color: rgba(102, 126, 234, 0.08) !important;
}

.form-check-input {
    cursor: pointer;
    width: 20px;
    height: 20px;
}

.form-check-input:checked {
    background-color: #667eea;
    border-color: #667eea;
}

.form-check-label {
    margin-left: 10px;
}
/* Request dropdown styles */
.request-item {
    transition: all 0.3s ease;
}

.request-item:hover {
    background-color: rgba(102, 126, 234, 0.08) !important;
    border-color: #667eea !important;
    transform: translateX(3px);
}

.request-item.hidden {
    display: none !important;
}

#requestSearchBox {
    border: 2px solid #e9ecef;
    border-radius: 8px;
    padding: 8px 12px;
    transition: all 0.3s;
}

#requestSearchBox:focus {
    border-color: #667eea;
    box-shadow: 0 0 0 0.2rem rgba(102, 126, 234, 0.25);
    outline: none;
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
                        <div class="stats-label">Từ hôm nay trở xuống</div>
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
    
    <!-- Dropdown Button -->
    <div class="dropdown w-100">
        <button class="btn btn-outline-secondary dropdown-toggle w-100 text-start d-flex justify-content-between align-items-center" 
                type="button" 
                id="requestDropdown" 
                data-bs-toggle="dropdown" 
                aria-expanded="false"
                style="height: 40px;">
            <span id="requestDropdownText">Chọn yêu cầu dịch vụ...</span>
        </button>
        
        <!-- Dropdown Menu with Search -->
        <div class="dropdown-menu w-100 p-3" 
             aria-labelledby="requestDropdown" 
             style="max-height: 400px; overflow-y: auto;"
             onclick="event.stopPropagation();">
            
            <!-- Search Box -->
            <div class="mb-3">
                <input type="text" 
                       class="form-control" 
                       id="requestSearchBox" 
                       placeholder="🔍 Tìm kiếm theo ID hoặc mô tả..."
                       onkeyup="filterRequests()"
                       onclick="event.stopPropagation()">
            </div>
            
            <!-- Clear Selection Button -->
            <div class="mb-3 pb-3 border-bottom">
                <button type="button" 
                        class="btn btn-sm btn-outline-secondary w-100" 
                        onclick="clearRequestSelection()">
                    <i class="fas fa-times me-1"></i>Xóa Lựa Chọn
                </button>
            </div>
            
            <!-- Request List -->
            <div id="requestListContainer">
                <c:forEach var="request" items="${approvedRequests}">
    <div class="request-item p-2 rounded mb-2" 
         style="border: 1px solid #e9ecef; cursor: pointer; transition: all 0.3s;"
         data-request-id="${request.requestId}"
         data-request-desc="${fn:toLowerCase(request.description)}"
         data-contract-id="${request.contractId}"
         onclick="selectRequest(${request.requestId}, '${fn:escapeXml(request.description)}', ${request.contractId != null ? request.contractId : 'null'})">
        <div class="d-flex justify-content-between align-items-start">
            <div>
                <strong>ID: ${request.requestId}</strong>
                <p class="mb-0 text-muted small">${request.description}</p>
            </div>
        </div>
    </div>
</c:forEach>
                
                <c:if test="${empty approvedRequests}">
                    <div class="text-center text-muted py-3" id="noRequestMessage">
                        <i class="fas fa-inbox fa-2x mb-2"></i>
                        <p class="mb-0">Không có yêu cầu nào</p>
                    </div>
                </c:if>
                
                <!-- No Results Message -->
                <div class="text-center text-muted py-3 d-none" id="noRequestResults">
                    <i class="fas fa-search fa-2x mb-2"></i>
                    <p class="mb-0">Không tìm thấy yêu cầu</p>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Hidden input to store selected value -->
    <input type="hidden" id="requestId" name="requestId" value="${prefilledRequestId}">
    
    <!-- Display selected request -->
    <div class="mt-2" id="selectedRequestDisplay" style="display: none;">
        <span class="badge bg-success">
            <i class="fas fa-check-circle me-1"></i>
            <span id="selectedRequestText"></span>
        </span>
    </div>
</div>
                                
                                <div class="mb-3">
                                    <label for="contractId" class="form-label">Hợp Đồng</label>
                                    <select class="form-select" id="contractId" name="contractId">
                                        <option value="">Chọn hợp đồng (tùy chọn)...</option>
                                        <c:forEach var="contract" items="${contractList}">
                                            <option value="${contract.contractId}"
                                                    ${prefilledContractId != null && prefilledContractId == contract.contractId ? 'selected' : ''}>
                                                #${contract.contractId} - ${contract.details}
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>
                                
                                
                                
                                <div class="mb-3">
    <label class="form-label">Kỹ Thuật Viên <span class="text-danger">*</span></label>
    
    <!-- Dropdown Button -->
    <div class="dropdown w-100">
        <button class="btn btn-outline-secondary dropdown-toggle w-100 text-start d-flex justify-content-between align-items-center" 
                type="button" 
                id="technicianDropdown" 
                data-bs-toggle="dropdown" 
                aria-expanded="false"
                style="height: 40px;">
            <span id="dropdownButtonText">Chọn kỹ thuật viên...</span>
        </button>
        
        <!-- Dropdown Menu with Checkboxes -->
        <div class="dropdown-menu w-100 p-3" 
             aria-labelledby="technicianDropdown" 
             style="max-height: 400px; overflow-y: auto;"
             onclick="event.stopPropagation();">
            
            <!-- Action Buttons -->
            <div class="d-flex gap-2 mb-3 pb-3 border-bottom">
                <button type="button" class="btn btn-sm btn-outline-primary flex-fill" onclick="selectAllTechniciansSchedule()">
                    <i class="fas fa-check-square me-1"></i>Chọn Tất Cả
                </button>
                <button type="button" class="btn btn-sm btn-outline-secondary flex-fill" onclick="deselectAllTechniciansSchedule()">
                    <i class="fas fa-square me-1"></i>Bỏ Chọn
                </button>
            </div>
            
            <!-- Technician List -->
            <c:forEach var="technician" items="${availableTechnicians}">
                <div class="form-check mb-2 p-2 technician-item-schedule rounded" 
                     style="border-left: 3px solid transparent; transition: all 0.3s;">
                    <input class="form-check-input technician-checkbox-schedule" 
                           type="checkbox" 
                           name="technicianIds" 
                           value="${technician.technicianId}"
                           id="tech_schedule_${technician.technicianId}"
                           data-capacity="${technician.availableCapacity}"
                           data-name="${technician.technicianName}"
                           onchange="updateSelectedCountSchedule()">
                    <label class="form-check-label w-100" for="tech_schedule_${technician.technicianId}" style="cursor: pointer;">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <strong>${technician.technicianName}</strong>
                                <small class="text-muted d-block">(ID: ${technician.technicianId})</small>
                            </div>
                            <div class="text-end">
                                <c:set var="maxPoints" value="${technician.maxConcurrentTasks}" />
                                <c:set var="currentPoints" value="${technician.currentActiveTasks}" />
                                <c:set var="availablePoints" value="${maxPoints - currentPoints}" />
                                <c:choose>
                                    <c:when test="${availablePoints >= 3}">
                                        <span class="badge bg-success">Sẵn sàng </span>
                                    </c:when>
                                    <c:when test="${availablePoints >= 1}">
                                        <span class="badge bg-warning text-dark">Gần đầy </span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge bg-danger">Quá tải </span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </label>
                </div>
            </c:forEach>
            
            <c:if test="${empty availableTechnicians}">
                <div class="text-center text-muted py-3">
                    <i class="fas fa-user-slash fa-2x mb-2"></i>
                    <p class="mb-0">Không có kỹ thuật viên khả dụng</p>
                </div>
            </c:if>
        </div>
    </div>
    
    <!-- Selected Count Badge -->
    <div class="mt-2">
        <span class="badge bg-info" id="selectedCountSchedule">Đã chọn: 0</span>
    </div>
    
    <small class="text-danger d-none" id="technicianErrorSchedule">Vui lòng chọn ít nhất một kỹ thuật viên</small>
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
                                    <label for="priorityId" class="form-label">Độ Ưu Tiên</label>
                                    <select class="form-select" id="priorityId" name="priorityId">
                                        <option value="1" ${prefilledPriorityId != null && prefilledPriorityId == 1 ? 'selected' : ''}>Thấp</option>
                                        <option value="2" ${prefilledPriorityId == null || prefilledPriorityId == 2 ? 'selected' : ''}>Trung Bình</option>
                                        <option value="3" ${prefilledPriorityId != null && prefilledPriorityId == 3 ? 'selected' : ''}>Cao</option>
                                        <option value="4" ${prefilledPriorityId != null && prefilledPriorityId == 4 ? 'selected' : ''}>Khẩn Cấp</option>
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

          <!-- Schedule List với Tabs và Pagination -->
<div class="row mt-4">
    <div class="col-12">
        <div class="card">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h5 class="mb-0"><i class="fas fa-list me-2"></i>Danh Sách Lịch Bảo Trì</h5>
            </div>
            
            <!-- Tabs Navigation -->
            <div class="card-body pb-0">
                <ul class="nav nav-tabs" id="scheduleStatusTabs" role="tablist">
                    <li class="nav-item" role="presentation">
                        <button class="nav-link active" id="all-tab" data-bs-toggle="tab" 
                                data-filter="all" type="button" role="tab">
                            <i class="fas fa-list me-1"></i>Tất Cả
                            <span class="badge bg-primary ms-1">${allSchedules.size()}</span>
                        </button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link" id="scheduled-tab" data-bs-toggle="tab" 
                                data-filter="Scheduled" type="button" role="tab">
                            <i class="fas fa-calendar-check me-1"></i>Đã Lên Lịch
                            <span class="badge bg-info ms-1 scheduled-count">0</span>
                        </button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link" id="inprogress-tab" data-bs-toggle="tab" 
                                data-filter="In Progress" type="button" role="tab">
                            <i class="fas fa-spinner me-1"></i>Đang Thực Hiện
                            <span class="badge bg-warning ms-1 inprogress-count">0</span>
                        </button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link" id="completed-tab" data-bs-toggle="tab" 
                                data-filter="Completed" type="button" role="tab">
                            <i class="fas fa-check-circle me-1"></i>Hoàn Thành
                            <span class="badge bg-success ms-1 completed-count">0</span>
                        </button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link" id="overdue-tab" data-bs-toggle="tab" 
                                data-filter="overdue" type="button" role="tab">
                            <i class="fas fa-exclamation-triangle me-1"></i>Quá Hạn
                            <span class="badge bg-danger ms-1 overdue-count">0</span>
                        </button>
                    </li>
                </ul>
            </div>

            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-hover" id="scheduleTable">
                        <thead class="table-light">
                            <tr>
                                <th>ID</th>
                                <th>Yêu Cầu</th>
                                
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
                                <tr data-schedule-id="${schedule.scheduleId}"
                                    data-status="${schedule.status}"
                                    data-date="${schedule.scheduledDate}">
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
        <c:when test="${not empty schedule.technicianName}">
            ${schedule.technicianName}
            <span class="text-muted small">(#${schedule.assignedTo})</span>
        </c:when>
        <c:otherwise>
            KTV #${schedule.assignedTo}
        </c:otherwise>
    </c:choose>
</td>
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
                                        <c:choose>
                                            <c:when test="${schedule.status == 'Scheduled'}">
                                                <span class="badge bg-primary">Đã Lên Lịch</span>
                                            </c:when>
                                            <c:when test="${schedule.status == 'In Progress'}">
                                                <span class="badge bg-warning">Đang Thực Hiện</span>
                                            </c:when>
                                            <c:when test="${schedule.status == 'Completed'}">
                                                <span class="badge bg-success">Hoàn Thành</span>
                                            </c:when>
                                            <c:when test="${schedule.status == 'Cancelled'}">
                                                <span class="badge bg-secondary">Hủy Bỏ</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-secondary">${schedule.status}</span>
                                            </c:otherwise>
                                        </c:choose>
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
                
                <!-- Pagination -->
                <div class="d-flex justify-content-between align-items-center mt-4 pt-3 border-top">
    <div class="pagination-info">
        Hiển thị <span id="showingFrom">1</span> - <span id="showingTo">8</span> 
        của <span id="totalRecords">0</span> bản ghi
    </div>
    <nav>
        <ul class="pagination mb-0" id="pagination">
                            <!-- Pagination buttons will be generated by JavaScript -->
                        </ul>
                    </nav>
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
                                <label for="editPriorityId" class="form-label">Độ Ưu Tiên</label>
                                <select class="form-select" id="editPriorityId" name="priorityId" disabled>
                                    <option value="1">Thấp</option>
                                    <option value="2">Trung Bình</option>
                                    <option value="3">Cao</option>
                                    <option value="4">Khẩn Cấp</option>
                                </select>
                            </div>
                        </div>
                        
                       <div class="mb-3">
                        <label for="editStatusDisplay" class="form-label">Trạng Thái</label>
                        <input type="text" class="form-control" id="editStatusDisplay" readonly 
                               style="background-color: #e9ecef; cursor: not-allowed;">
                        
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
            "title": "<c:out value='${schedule.scheduleType}' escapeXml='true'/> - KTV ID:<c:out value='${schedule.assignedTo}' escapeXml='true'/>",
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
let currentFilter = 'all';
let currentPage = 1;
const itemsPerPage = 8;
let filteredSchedules = [];

document.addEventListener('DOMContentLoaded', function() {
    initializeCalendar();
    setMinDateTime();
    initializeTabs();
    initializeScheduleFilter();
});

function initializeCalendar() {
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

function initializeTabs() {
    const tabButtons = document.querySelectorAll('#scheduleStatusTabs button[data-filter]');
    
    tabButtons.forEach(button => {
        button.addEventListener('click', function() {
            const filter = this.getAttribute('data-filter');
            currentFilter = filter;
            currentPage = 1;
            filterAndPaginateSchedules();
        });
    });
}

function initializeScheduleFilter() {
    updateTabCounts();
    filterAndPaginateSchedules();
}

function parseDate(dateStr) {
    if (!dateStr) return null;
    dateStr = dateStr.trim();
    
    let date = null;
    if (dateStr.includes(' ')) {
        date = new Date(dateStr.replace(' ', 'T'));
    } else if (dateStr.includes('T')) {
        date = new Date(dateStr);
    } else {
        date = new Date(dateStr + 'T00:00:00');
    }
    
    return isNaN(date.getTime()) ? null : date;
}

function updateTabCounts() {
    const table = document.getElementById('scheduleTable');
    const tbody = table.getElementsByTagName('tbody')[0];
    if (!tbody) return;
    
    const rows = tbody.getElementsByTagName('tr');
    const now = new Date();
    now.setHours(0, 0, 0, 0);
    
    let scheduledCount = 0;
    let inprogressCount = 0;
    let completedCount = 0;
    let overdueCount = 0;
    
    for (let row of rows) {
        const status = row.getAttribute('data-status');
        const dateStr = row.getAttribute('data-date');
        
        if (!dateStr) continue;
        
        const scheduledDate = parseDate(dateStr);
        if (!scheduledDate) continue;
        
        if (status === 'Scheduled') scheduledCount++;
        else if (status === 'In Progress') inprogressCount++;
        else if (status === 'Completed') completedCount++;
        
        if (scheduledDate < now && status !== 'Completed' && status !== 'Cancelled') {
            overdueCount++;
        }
    }
    
    document.querySelector('.scheduled-count').textContent = scheduledCount;
    document.querySelector('.inprogress-count').textContent = inprogressCount;
    document.querySelector('.completed-count').textContent = completedCount;
    document.querySelector('.overdue-count').textContent = overdueCount;
}

function filterAndPaginateSchedules() {
    const table = document.getElementById('scheduleTable');
    const tbody = table.getElementsByTagName('tbody')[0];
    
    if (!tbody) {
        console.error('Table tbody not found');
        return;
    }
    
    const rows = Array.from(tbody.getElementsByTagName('tr'));
    const now = new Date();
    now.setHours(0, 0, 0, 0);
    
    filteredSchedules = rows.filter(row => {
        const status = row.getAttribute('data-status');
        const dateStr = row.getAttribute('data-date');
        
        if (!dateStr) return false;
        
        const scheduledDate = parseDate(dateStr);
        if (!scheduledDate) return false;
        
        const isOverdue = scheduledDate < now && status !== 'Completed' && status !== 'Cancelled';
        
        if (currentFilter === 'all') {
            return true;
        } else if (currentFilter === 'overdue') {
            return isOverdue;
        } else {
            return status === currentFilter;
        }
    });
    
    rows.forEach(row => {
        row.style.display = 'none';
    });
    
    const totalItems = filteredSchedules.length;
    
    if (totalItems === 0) {
        document.getElementById('showingFrom').textContent = '0';
        document.getElementById('showingTo').textContent = '0';
        document.getElementById('totalRecords').textContent = '0';
        document.getElementById('pagination').innerHTML = '';
        return;
    }
    
    const totalPages = Math.ceil(totalItems / itemsPerPage);
    
    if (currentPage > totalPages) {
        currentPage = totalPages;
    }
    if (currentPage < 1) {
        currentPage = 1;
    }
    
    const startIndex = (currentPage - 1) * itemsPerPage;
    const endIndex = Math.min(startIndex + itemsPerPage, totalItems);
    
    for (let i = startIndex; i < endIndex; i++) {
        if (filteredSchedules[i]) {
            filteredSchedules[i].style.display = '';
        }
    }
    
    document.getElementById('showingFrom').textContent = startIndex + 1;
    document.getElementById('showingTo').textContent = endIndex;
    document.getElementById('totalRecords').textContent = totalItems;
    
    renderPagination(totalPages);
}

function renderPagination(totalPages) {
    const pagination = document.getElementById('pagination');
    pagination.innerHTML = '';
    
    if (totalPages <= 1) return;
    
    const prevLi = document.createElement('li');
    prevLi.className = 'page-item' + (currentPage === 1 ? ' disabled' : '');
    prevLi.innerHTML = '<a class="page-link" href="#" onclick="changePage(' + (currentPage - 1) + '); return false;"><i class="fas fa-chevron-left"></i></a>';
    pagination.appendChild(prevLi);
    
    const maxVisiblePages = 5;
    let startPage = Math.max(1, currentPage - Math.floor(maxVisiblePages / 2));
    let endPage = Math.min(totalPages, startPage + maxVisiblePages - 1);
    
    if (endPage - startPage < maxVisiblePages - 1) {
        startPage = Math.max(1, endPage - maxVisiblePages + 1);
    }
    
    if (startPage > 1) {
        const firstLi = document.createElement('li');
        firstLi.className = 'page-item';
        firstLi.innerHTML = '<a class="page-link" href="#" onclick="changePage(1); return false;">1</a>';
        pagination.appendChild(firstLi);
        
        if (startPage > 2) {
            const dotsLi = document.createElement('li');
            dotsLi.className = 'page-item disabled';
            dotsLi.innerHTML = '<span class="page-link">...</span>';
            pagination.appendChild(dotsLi);
        }
    }
    
    for (let i = startPage; i <= endPage; i++) {
        const pageLi = document.createElement('li');
        pageLi.className = 'page-item' + (i === currentPage ? ' active' : '');
        pageLi.innerHTML = '<a class="page-link" href="#" onclick="changePage(' + i + '); return false;">' + i + '</a>';
        pagination.appendChild(pageLi);
    }
    
    if (endPage < totalPages) {
        if (endPage < totalPages - 1) {
            const dotsLi = document.createElement('li');
            dotsLi.className = 'page-item disabled';
            dotsLi.innerHTML = '<span class="page-link">...</span>';
            pagination.appendChild(dotsLi);
        }
        
        const lastLi = document.createElement('li');
        lastLi.className = 'page-item';
        lastLi.innerHTML = '<a class="page-link" href="#" onclick="changePage(' + totalPages + '); return false;">' + totalPages + '</a>';
        pagination.appendChild(lastLi);
    }
    
    const nextLi = document.createElement('li');
    nextLi.className = 'page-item' + (currentPage === totalPages ? ' disabled' : '');
    nextLi.innerHTML = '<a class="page-link" href="#" onclick="changePage(' + (currentPage + 1) + '); return false;"><i class="fas fa-chevron-right"></i></a>';
    pagination.appendChild(nextLi);
}

function changePage(page) {
    const totalPages = Math.ceil(filteredSchedules.length / itemsPerPage) || 1;
    
    if (page < 1 || page > totalPages || page === currentPage) {
        return;
    }
    
    currentPage = page;
    filterAndPaginateSchedules();
    
    const tableCard = document.querySelector('.card:has(#scheduleTable)');
    if (tableCard) {
        tableCard.scrollIntoView({ 
            behavior: 'smooth', 
            block: 'start'
        });
    }
}

function editSchedule(scheduleId) {
    document.getElementById('editScheduleForm').reset();
    
    fetch('scheduleMaintenance?action=getScheduleDetails&scheduleId=' + scheduleId)
    .then(response => {
        if (!response.ok) throw new Error('Network response was not ok');
        return response.json();
    })
    .then(data => {
        if (data.error) {
            showToast('Lỗi: ' + data.error, 'error');
            return;
        }
        
        document.getElementById('editScheduleId').value = data.scheduleId;
        
        let scheduledDateStr = data.scheduledDate;
        if (typeof scheduledDateStr === 'string') {
            if (scheduledDateStr.length === 10) {
                scheduledDateStr = scheduledDateStr + 'T00:00';
            } else if (scheduledDateStr.includes('T')) {
                scheduledDateStr = scheduledDateStr.substring(0, 16);
            } else if (scheduledDateStr.includes(' ')) {
                scheduledDateStr = scheduledDateStr.replace(' ', 'T').substring(0, 16);
            }
        }
        document.getElementById('editScheduledDate').value = scheduledDateStr;
        
        document.getElementById('editScheduleType').value = data.scheduleType || 'Preventive';
        
        document.getElementById('editPriorityId').value = data.priorityId || '2';
        
        const statusMap = {
            'Scheduled': 'Đã Lên Lịch',
            'In Progress': 'Đang Thực Hiện',
            'Completed': 'Hoàn Thành',
            'Cancelled': 'Hủy Bỏ'
        };
        
        document.getElementById('editStatusDisplay').value = statusMap[data.status] || data.status;
        
        const modal = new bootstrap.Modal(document.getElementById('editScheduleModal'));
        modal.show();
    })
    .catch(error => {
        console.error('Error:', error);
        showToast('Lỗi khi tải thông tin!', 'error');
    });
}

function saveScheduleChanges() {
    const form = document.getElementById('editScheduleForm');
    const formData = new FormData(form);
    
    const scheduledDate = document.getElementById('editScheduledDate').value;
    const scheduleType = document.getElementById('editScheduleType').value;
    
    if (!scheduledDate || !scheduleType) {
        showToast('Vui lòng điền đầy đủ thông tin!', 'error');
        return;
    }
    
    fetch('scheduleMaintenance', {
        method: 'POST',
        body: new URLSearchParams(formData)
    })
    .then(response => {
        if (response.ok) {
            showToast('Cập nhật thành công!', 'success');
            const modal = bootstrap.Modal.getInstance(document.getElementById('editScheduleModal'));
            if (modal) modal.hide();
            setTimeout(() => location.reload(), 1000);
        } else {
            return response.text().then(text => {
                showToast('Lỗi: ' + text, 'error');
            });
        }
    })
    .catch(error => {
        console.error('Error:', error);
        showToast('Lỗi khi cập nhật!', 'error');
    });
}

function deleteSchedule(scheduleId) {
    if (!confirm('Bạn có chắc chắn muốn xóa?')) return;
    
    fetch('scheduleMaintenance', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'action=deleteSchedule&scheduleId=' + scheduleId
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            showToast('Xóa thành công!', 'success');
            location.reload();
        } else {
            showToast('Lỗi: ' + (data.error || 'Unknown'), 'error');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        showToast('Lỗi khi xóa!', 'error');
    });
}

document.addEventListener('click', function(e) {
    if (e.target.closest('.schedule-action-btn')) {
        const button = e.target.closest('.schedule-action-btn');
        const action = button.getAttribute('data-action');
        const scheduleId = button.getAttribute('data-schedule-id');
        
        if (action && scheduleId) {
            if (action === 'edit') editSchedule(scheduleId);
            else if (action === 'delete') deleteSchedule(scheduleId);
        }
    }
});

function showToast(message, type) {
    const toast = document.createElement('div');
    toast.className = 'alert alert-' + (type === 'success' ? 'success' : 'danger') + ' position-fixed';
    toast.style.cssText = 'top: 20px; right: 20px; z-index: 9999; min-width: 300px;';
    toast.innerHTML = message + '<button type="button" class="btn-close" onclick="this.parentElement.remove()"></button>';
    document.body.appendChild(toast);
    
    setTimeout(() => {
        if (toast.parentElement) toast.remove();
    }, 5000);
}

document.getElementById('scheduleForm').addEventListener('submit', function(e) {
    const technicianSelect = document.getElementById('assignedTo');
    const selectedOption = technicianSelect.options[technicianSelect.selectedIndex];
    
    if (selectedOption && selectedOption.textContent.includes('(Khả năng: 0/')) {
        e.preventDefault();
        alert('Kỹ thuật viên không còn khả năng nhận thêm công việc!');
        return false;
    }
});
// ===== HIGHLIGHT FORM KHI CÓ PRE-FILLED DATA =====
document.addEventListener('DOMContentLoaded', function() {
    const requestIdSelect = document.getElementById('requestId');
    const contractIdSelect = document.getElementById('contractId');
    const priorityIdSelect = document.getElementById('priorityId');
    
    // Kiểm tra nếu có giá trị được pre-fill
    const hasPrefilledData = requestIdSelect.value || 
                             contractIdSelect.value || 
                             (priorityIdSelect.value && priorityIdSelect.value !== '2');
    
    if (hasPrefilledData) {
        // Highlight các trường đã được điền sẵn
        if (requestIdSelect.value) {
            requestIdSelect.classList.add('border-success');
            requestIdSelect.style.borderWidth = '3px';
        }
        
        if (contractIdSelect.value) {
            contractIdSelect.classList.add('border-success');
            contractIdSelect.style.borderWidth = '3px';
        }
        
        if (priorityIdSelect.value && priorityIdSelect.value !== '2') {
            priorityIdSelect.classList.add('border-warning');
            priorityIdSelect.style.borderWidth = '3px';
        }
        
        // Scroll đến form và hiển thị thông báo
        const scheduleForm = document.getElementById('scheduleForm');
        setTimeout(function() {
            scheduleForm.scrollIntoView({ behavior: 'smooth', block: 'start' });
        }, 300);
        
        showToast('Thêm thông tin thành công', 'success');
    }
});
function updateSelectedCountSchedule() {
    const checkboxes = document.querySelectorAll('.technician-checkbox-schedule:checked');
    const count = checkboxes.length;
    document.getElementById('selectedCountSchedule').textContent = 'Đã chọn: ' + count;
    
    // Highlight selected items
    document.querySelectorAll('.technician-item-schedule').forEach(item => {
        const checkbox = item.querySelector('.technician-checkbox-schedule');
        if (checkbox.checked) {
            item.style.borderLeftColor = '#667eea';
            item.style.backgroundColor = 'rgba(102, 126, 234, 0.05)';
        } else {
            item.style.borderLeftColor = 'transparent';
            item.style.backgroundColor = 'transparent';
        }
    });
    
    // Hide error message when at least one is selected
    if (count > 0) {
        document.getElementById('technicianErrorSchedule').classList.add('d-none');
    }
}

function selectAllTechniciansSchedule() {
    const checkboxes = document.querySelectorAll('.technician-checkbox-schedule');
    checkboxes.forEach(cb => {
        if (parseInt(cb.dataset.capacity) > 0) {
            cb.checked = true;
        }
    });
    updateSelectedCountSchedule();
}

function deselectAllTechniciansSchedule() {
    const checkboxes = document.querySelectorAll('.technician-checkbox-schedule');
    checkboxes.forEach(cb => cb.checked = false);
    updateSelectedCountSchedule();
}
document.addEventListener('DOMContentLoaded', function() {
    // Initialize count
    if (typeof updateSelectedCountSchedule === 'function') {
        updateSelectedCountSchedule();
    }
    
    // Add validation to schedule form
    const scheduleForm = document.getElementById('scheduleForm');
    if (scheduleForm) {
        scheduleForm.addEventListener('submit', function(e) {
            const checkedBoxes = document.querySelectorAll('.technician-checkbox-schedule:checked');
            
            // Validate: At least one technician must be selected
            if (checkedBoxes.length === 0) {
                e.preventDefault();
                document.getElementById('technicianErrorSchedule').classList.remove('d-none');
                alert('⚠️ Vui lòng chọn ít nhất một kỹ thuật viên!');
                return false;
            }
            
            // Check capacity for each selected technician
            let hasOverloadedTech = false;
            let overloadedNames = [];
            
            checkedBoxes.forEach(cb => {
                if (parseInt(cb.dataset.capacity) <= 0) {
                    hasOverloadedTech = true;
                    overloadedNames.push(cb.dataset.name);
                }
            });
            
            if (hasOverloadedTech) {
                e.preventDefault();
                alert('⚠️ Các kỹ thuật viên sau đã quá tải:\n' + overloadedNames.join('\n') + 
                      '\n\nVui lòng bỏ chọn họ trước khi lập lịch!');
                return false;
            }
            
            // Validate other required fields
            const scheduledDate = document.getElementById('scheduledDate').value;
            const scheduleType = document.getElementById('scheduleType').value;
            
            if (!scheduledDate || !scheduleType) {
                e.preventDefault();
                alert('⚠️ Vui lòng điền đầy đủ thông tin bắt buộc!');
                return false;
            }
            
            // Confirm assignment
            const confirmMsg = `✅ Bạn có chắc muốn lập lịch bảo trì cho ${checkedBoxes.length} kỹ thuật viên?\n\n` +
                               Array.from(checkedBoxes).map(cb => '• ' + cb.dataset.name).join('\n');
            
            if (!confirm(confirmMsg)) {
                e.preventDefault();
                return false;
            }
        });
    }
});
// Thêm vào cuối phần <script>

function filterRequests() {
    const searchValue = document.getElementById('requestSearchBox').value.toLowerCase().trim();
    const requestItems = document.querySelectorAll('.request-item');
    let visibleCount = 0;
    
    requestItems.forEach(item => {
        const requestId = item.getAttribute('data-request-id');
        const requestDesc = item.getAttribute('data-request-desc');
        
        // Search by ID or Description (dùng includes để tìm bất kỳ ký tự nào)
        const matchesSearch = requestId.includes(searchValue) || 
                             requestDesc.includes(searchValue);
        
        if (matchesSearch) {
            item.classList.remove('hidden');
            visibleCount++;
        } else {
            item.classList.add('hidden');
        }
    });
    
    // Show/hide "no results" message
    const noResultsMsg = document.getElementById('noRequestResults');
    if (visibleCount === 0 && searchValue !== '') {
        noResultsMsg.classList.remove('d-none');
    } else {
        noResultsMsg.classList.add('d-none');
    }
}

function selectRequest(requestId, description, contractId) {
    // Set hidden input value
    document.getElementById('requestId').value = requestId;
    
    // Update button text
    const buttonText = 'ID: ' + requestId + ' - ' + description.substring(0, 50) + 
                      (description.length > 50 ? '...' : '');
    document.getElementById('requestDropdownText').textContent = buttonText;
    
    // Show selected badge
    document.getElementById('selectedRequestText').textContent = 'ID: ' + requestId;
    document.getElementById('selectedRequestDisplay').style.display = 'block';
    
    // ✅ TỰ ĐỘNG SET CONTRACT
    if (contractId && contractId !== 'null') {
        const contractSelect = document.getElementById('contractId');
        contractSelect.value = contractId;
        
        // Highlight contract field
        contractSelect.classList.add('border-success');
        contractSelect.style.borderWidth = '3px';
    } else {
        // Reset contract nếu không có
        const contractSelect = document.getElementById('contractId');
        contractSelect.value = '';
        contractSelect.classList.remove('border-success');
        contractSelect.style.borderWidth = '';
    }
    
    // Close dropdown
    const dropdown = bootstrap.Dropdown.getInstance(document.getElementById('requestDropdown'));
    if (dropdown) {
        dropdown.hide();
    }
    
    // Highlight the form field
    const dropdownButton = document.querySelector('#requestDropdown');
    dropdownButton.classList.add('border-success');
    dropdownButton.style.borderWidth = '3px';
}
function clearRequestSelection() {
    // Clear hidden input
    document.getElementById('requestId').value = '';
    
    // Reset button text
    document.getElementById('requestDropdownText').textContent = 'Chọn yêu cầu dịch vụ...';
    
    // Hide selected badge
    document.getElementById('selectedRequestDisplay').style.display = 'none';
    
    // Remove highlight
    const dropdownButton = document.querySelector('#requestDropdown');
    dropdownButton.classList.remove('border-success');
    dropdownButton.style.borderWidth = '';
    
    // ✅ CLEAR CONTRACT
    const contractSelect = document.getElementById('contractId');
    contractSelect.value = '';
    contractSelect.classList.remove('border-success');
    contractSelect.style.borderWidth = '';
    
    // Clear search box
    document.getElementById('requestSearchBox').value = '';
    filterRequests();
}

// Handle pre-filled value on page load
document.addEventListener('DOMContentLoaded', function() {
    const prefilledValue = document.getElementById('requestId').value;
    if (prefilledValue) {
        // Find and display the pre-filled request
        const requestItem = document.querySelector('.request-item[data-request-id="' + prefilledValue + '"]');
        if (requestItem) {
            const desc = requestItem.querySelector('.text-muted').textContent;
            selectRequest(prefilledValue, desc);
        }
    }
});
    </script>
        </div> <!-- content-wrapper -->
    </div> <!-- main-content -->
</body>
</html>