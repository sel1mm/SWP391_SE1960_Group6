<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@page import="model.Account"%>
<%@page import="java.util.List"%>
<%@page import="model.TechnicianWorkload"%>
<%@page import="model.ServiceRequest"%>
<%@page import="model.TechnicianSkill"%>
<%@page import="model.WorkAssignment"%>

<%
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
    <title>Phân Công Công Việc - Technical Manager</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
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
        
        .btn-success {
            transition: all 0.3s ease;
        }

        .btn-success:hover {
            transform: scale(1.1);
            box-shadow: 0 4px 12px rgba(40, 167, 69, 0.4);
        }

        .border-3 {
            border-width: 3px !important;
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
        
        .workload-indicator {
            display: inline-block;
            width: 100px;
            height: 8px;
            background-color: #e9ecef;
            border-radius: 4px;
            overflow: hidden;
        }
        
        .workload-bar {
            height: 100%;
            border-radius: 4px;
            transition: width 0.3s ease;
        }
        
        .workload-low { background-color: #28a745; }
        .workload-medium { background-color: #ffc107; }
        .workload-high { background-color: #dc3545; }
        
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

        /* Pagination Styles */
        .pagination {
            display: flex;
            justify-content: center;
            margin-top: 20px;
        }

        .pagination button {
            margin: 0 5px;
            padding: 8px 12px;
            border: 1px solid #667eea;
            background: white;
            color: #667eea;
            border-radius: 5px;
            cursor: pointer;
            transition: all 0.3s;
        }

        .pagination button:hover:not(:disabled) {
            background: #667eea;
            color: white;
        }

        .pagination button.active {
            background: #667eea;
            color: white;
        }

        .pagination button:disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }

        /* Filter Section */
        .filter-section {
            display: flex;
            gap: 10px;
            margin-bottom: 15px;
            align-items: center;
        }

        .filter-section select {
            flex: 1;
            max-width: 200px;
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
                    <i class="fas fa-check-circle me-2"></i>Duyệt Yêu Cầu
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link active" href="assignWork">
                    <i class="fas fa-user-plus me-2"></i>Phân Công Công Việc
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="scheduleMaintenance">
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
        <div class="container-fluid">
            <!-- Header -->
            <div class="row mb-4">
                <div class="col-12">
                    <h2><i class="fas fa-user-plus me-3"></i>Phân Công Công Việc</h2>
                    <p class="text-muted">Phân công công việc cho kỹ thuật viên</p>
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

            <!-- Assign Work Form -->
            <div class="row">
                <div class="col-lg-8">
                    <div class="card">
                        <div class="card-header">
                            <h5 class="mb-0"><i class="fas fa-plus-circle me-2"></i>Phân Công Công Việc Mới</h5>
                        </div>
                        <div class="card-body">
                            <form action="assignWork" method="post" id="assignWorkForm">
                                <input type="hidden" name="action" value="assignWork">
                                
                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label for="taskId" class="form-label">Yêu Cầu Dịch Vụ</label>
                                        <select class="form-select" id="taskId" name="taskId" required>
                                            <option value="">Chọn yêu cầu dịch vụ...</option>
                                            <c:forEach var="request" items="${pendingRequests}">
                                                <option value="${request.requestId}" 
                                                        ${preSelectedRequestId != null && preSelectedRequestId == request.requestId.toString() ? 'selected' : ''}>
                                                    #${request.requestId} - ${request.requestType} (${request.priorityLevel})
                                                </option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                    
                                    <div class="col-md-6 mb-3">
                                        <label for="technicianId" class="form-label">Kỹ Thuật Viên</label>
                                        <select class="form-select" id="technicianId" name="technicianId" required>
                                            <option value="">Chọn kỹ thuật viên...</option>
                                            <c:forEach var="technician" items="${availableTechnicians}">
                                                <option value="<c:out value='${technician.technicianId}' escapeXml='true'/>" 
                                                        data-capacity="<c:out value='${technician.availableCapacity}' escapeXml='true'/>"
                                                        data-completion-time="<c:out value='${technician.averageCompletionTime}' escapeXml='true'/>">
                                                    Kỹ thuật viên #<c:out value='${technician.technicianId}' escapeXml='true'/> 
                                                    (Khả năng: <c:out value='${technician.availableCapacity}' escapeXml='true'/>/<c:out value='${technician.maxConcurrentTasks}' escapeXml='true'/>)
                                                </option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                </div>
                                
                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label for="estimatedDuration" class="form-label">Thời Gian Ước Tính (giờ)</label>
                                        <input type="number" class="form-control" id="estimatedDuration" 
                                               name="estimatedDuration" step="0.5" min="0.5" required>
                                    </div>
                                    
                                    <div class="col-md-6 mb-3">
                                        <label for="priority" class="form-label">Độ Ưu Tiên</label>
                                        <select class="form-select" id="priority" name="priority" required>
                                           
                                            <option value="Normal" ${preSelectedPriority == 'Normal' || preSelectedPriority == null ? 'selected' : ''}>Trung Bình (1 point)</option>
                                            <option value="High" ${preSelectedPriority == 'High' ? 'selected' : ''}>Cao (2 points)</option>
                                            <option value="Urgent" ${preSelectedPriority == 'Urgent' ? 'selected' : ''}>Khẩn Cấp (3 points)</option>
                                        </select>
                                    </div>
                                </div>
                                
                                <div class="mb-3">
                                    <label for="requiredSkills" class="form-label">Kỹ Năng Yêu Cầu</label>
                                    <textarea class="form-control" id="requiredSkills" name="requiredSkills" 
                                              rows="3" placeholder="Mô tả kỹ năng cần thiết cho công việc này..."></textarea>
                                </div>
                                
                                <div class="d-grid gap-2 d-md-flex justify-content-md-end">
                                    <button type="reset" class="btn btn-secondary me-md-2">
                                        <i class="fas fa-undo me-2"></i>Đặt Lại
                                    </button>
                                    <button type="submit" class="btn btn-primary">
                                        <i class="fas fa-paper-plane me-2"></i>Phân Công
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
                
                <!-- Technician Workload Summary -->
                <div class="col-lg-4">
                    <div class="card">
                        <div class="card-header">
                            <h5 class="mb-0"><i class="fas fa-chart-bar me-2"></i>Tình Trạng Kỹ Thuật Viên</h5>
                        </div>
                        <div class="card-body">
                           <c:forEach var="technician" items="${availableTechnicians}">
    <%-- ✅ ĐÚNG: maxConcurrentTasks = 5, không nhân 3 nữa --%>
    <c:set var="maxPoints" value="${technician.maxConcurrentTasks}" />
    <c:set var="currentPoints" value="${technician.currentActiveTasks}" />
    <c:set var="availablePoints" value="${maxPoints - currentPoints}" />
    <c:set var="usagePercent" value="${(currentPoints * 100) / maxPoints}" />
    
    <div class="mb-3 p-3 border rounded">
        <div class="d-flex justify-content-between align-items-center mb-2">
            <strong>KTV #${technician.technicianId}</strong>
            <span class="badge <c:choose>
                <c:when test='${availablePoints >= 3}'>bg-success</c:when>
                <c:when test='${availablePoints >= 1}'>bg-warning text-dark</c:when>
                <c:otherwise>bg-danger</c:otherwise>
            </c:choose>">
                ${currentPoints}/${maxPoints} points
            </span>
        </div>
        <div class="workload-indicator mb-2">
            <div class="workload-bar <c:choose>
                <c:when test='${usagePercent <= 50}'>workload-low</c:when>
                <c:when test='${usagePercent <= 80}'>workload-medium</c:when>
                <c:otherwise>workload-high</c:otherwise>
            </c:choose>"
                 style="width: ${usagePercent}%"></div>
        </div>
        <small class="text-muted">
            <c:choose>
                <c:when test="${availablePoints >= 3}">
                    <span class="text-success">✓ Sẵn sàng nhận việc</span>
                </c:when>
                <c:when test="${availablePoints >= 1}">
                    <span class="text-warning">⚠ Gần đầy</span>
                </c:when>
                <c:otherwise>
                    <span class="text-danger">✗ Quá tải</span>
                </c:otherwise>
            </c:choose>
        </small>
    </div>
</c:forEach>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Assignment History -->
            <div class="row mt-4">
                <div class="col-12">
                    <div class="card">
                        <div class="card-header d-flex justify-content-between align-items-center">
                            <h5 class="mb-0"><i class="fas fa-history me-2"></i>Lịch Sử Phân Công</h5>
                            <div class="d-flex gap-2">
                                <button class="btn btn-outline-light btn-sm" onclick="refreshAssignmentHistory()">
                                    <i class="fas fa-sync-alt me-2"></i>Làm Mới
                                </button>
                            </div>
                        </div>
                        <div class="card-body">
                            <!-- Filter Section -->
                            <div class="filter-section">
                                <label>Lọc theo trạng thái:</label>
                                <select id="statusFilter" class="form-select">
                                    <option value="">Tất cả</option>
                                    <option value="Assigned">Đã Phân Công</option>
                                    <option value="In Progress">Đang Thực Hiện</option>
                                    <option value="Completed">Đã Hoàn Thành</option>
                                </select>
                            </div>

                            <div class="table-responsive">
                                <table class="table table-hover">
                                    <thead class="table-light">
                                        <tr>
                                            <th>ID</th>
                                            <th>Nhiệm Vụ</th>
                                            <th>Kỹ Thuật Viên</th>
                                            <th>Ngày Phân Công</th>
                                            <th>Thời Gian Ước Tính</th>
                                            <th>Độ Ưu Tiên</th>
                                            <th>Trạng Thái</th>
                                            <th>Hành Động</th>
                                        </tr>
                                    </thead>
                                    <tbody id="assignmentHistoryTable">
                                        <!-- Dynamic content will be loaded here -->
                                    </tbody>
                                </table>
                            </div>

                            <!-- Pagination -->
                            <div class="pagination" id="paginationControls">
                                <!-- Pagination buttons will be generated here -->
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        let currentPage = 1;
        const itemsPerPage = 10;
        let allAssignments = [];
        let filteredAssignments = [];

        document.getElementById('assignWorkForm').addEventListener('submit', function(e) {
            const technicianSelect = document.getElementById('technicianId');
            const selectedOption = technicianSelect.options[technicianSelect.selectedIndex];
            
            if (selectedOption && selectedOption.dataset.capacity <= 0) {
                e.preventDefault();
                alert('Kỹ thuật viên đã chọn không còn khả năng nhận thêm công việc!');
                return false;
            }
        });

        function getStatusClass(status) {
            switch(status) {
                case 'Completed': return 'bg-success';
                case 'Assigned': return 'bg-info';
                case 'In Progress': return 'bg-warning text-dark';
                default: return 'bg-secondary';
            }
        }

        function getStatusText(status) {
            switch(status) {
                case 'Completed': return 'Đã Hoàn Thành';
                case 'Assigned': return 'Đã Phân Công';
                case 'In Progress': return 'Đang Thực Hiện';
                default: return status;
            }
        }

        function refreshAssignmentHistory() {
            fetch('assignWork?action=getAssignmentHistory')
                .then(response => response.json())
                .then(data => {
                    allAssignments = data;
                    applyFilter();
                })
                .catch(error => {
                    console.error('Error refreshing assignment history:', error);
                });
        }

        function applyFilter() {
            const statusFilter = document.getElementById('statusFilter').value;
            
            if (statusFilter === '') {
                filteredAssignments = allAssignments;
            } else {
                filteredAssignments = allAssignments.filter(a => a.status === statusFilter);
            }
            
            currentPage = 1;
            renderTable();
            renderPagination();
        }

        function renderTable() {
            const tbody = document.getElementById('assignmentHistoryTable');
            tbody.innerHTML = '';
            
            const startIndex = (currentPage - 1) * itemsPerPage;
            const endIndex = startIndex + itemsPerPage;
            const pageAssignments = filteredAssignments.slice(startIndex, endIndex);
            
            pageAssignments.forEach(assignment => {
                const row = document.createElement('tr');
                row.innerHTML = 
                    '<td>#' + assignment.assignmentId + '</td>' +
                    '<td>#' + assignment.taskId + '</td>' +
                    '<td>KTV #' + assignment.assignedTo + '</td>' +
                    '<td>' + assignment.assignmentDate + '</td>' +
                    '<td>' + parseFloat(assignment.estimatedDuration).toFixed(2) + 'h</td>' +
                    '<td>' +
                        '<span class="badge ' + getPriorityClass(assignment.priority) + '">' +
                        assignment.priority +
                        '</span>' +
                    '</td>' +
                    '<td>' +
                        '<span class="badge ' + getStatusClass(assignment.status) + '">' +
                        getStatusText(assignment.status) +
                        '</span>' +
                    '</td>' +
                    '<td>' +
                        '<button class="btn btn-sm btn-outline-danger delete-assignment-btn" ' +
                                'data-assignment-id="' + assignment.assignmentId + '"' +
                                (assignment.status === 'Completed' ? ' disabled' : '') + '>' +
                            '<i class="fas fa-trash"></i>' +
                        '</button>' +
                    '</td>';
                tbody.appendChild(row);
            });
        }

        function renderPagination() {
            const totalPages = Math.ceil(filteredAssignments.length / itemsPerPage);
            const paginationControls = document.getElementById('paginationControls');
            paginationControls.innerHTML = '';
            
            if (totalPages <= 1) return;
            
            // Previous button
            const prevBtn = document.createElement('button');
            prevBtn.textContent = '« Trước';
            prevBtn.disabled = currentPage === 1;
            prevBtn.onclick = () => {
                if (currentPage > 1) {
                    currentPage--;
                    renderTable();
                    renderPagination();
                }
            };
            paginationControls.appendChild(prevBtn);
            
            // Page numbers
            for (let i = 1; i <= totalPages; i++) {
                const pageBtn = document.createElement('button');
                pageBtn.textContent = i;
                pageBtn.className = currentPage === i ? 'active' : '';
                pageBtn.onclick = () => {
                    currentPage = i;
                    renderTable();
                    renderPagination();
                };
                paginationControls.appendChild(pageBtn);
            }
            
            // Next button
            const nextBtn = document.createElement('button');
            nextBtn.textContent = 'Sau »';
            nextBtn.disabled = currentPage === totalPages;
            nextBtn.onclick = () => {
                if (currentPage < totalPages) {
                    currentPage++;
                    renderTable();
                    renderPagination();
                }
            };
            paginationControls.appendChild(nextBtn);
        }

       // Delete assignment

        function deleteAssignment(assignmentId) {

            if (confirm('Bạn có chắc chắn muốn xóa phân công này?')) {

                fetch('assignWork', {

                    method: 'POST',

                    headers: {

                        'Content-Type': 'application/x-www-form-urlencoded',

                    },

                    body: 'action=deleteAssignment&assignmentId=' + assignmentId

                })

                .then(response => response.json())

                .then(data => {

                    if (data.success) {

                        refreshAssignmentHistory();

                        showToast('Xóa phân công thành công!', 'success');

                        location.reload(); 

                    } else {

                        showToast('Lỗi khi xóa phân công: ' + (data.error || 'Unknown error'), 'error');

                    }

                })

                .catch(error => {

                    console.error('Error deleting assignment:', error);

                    showToast('Lỗi khi xóa phân công!', 'error');

                });

            }

        }

        // Event delegation for delete assignment buttons

        document.addEventListener('click', function(e) {

            if (e.target.closest('.delete-assignment-btn')) {

                const button = e.target.closest('.delete-assignment-btn');

                const assignmentId = button.getAttribute('data-assignment-id');

                if (assignmentId) {

                    deleteAssignment(assignmentId);

                }

            }

        });

        // Helper functions

        function getPriorityClass(priority) {

            switch(priority) {

                case 'Urgent': return 'bg-danger';

                case 'High': return 'bg-warning';

                case 'Normal': return 'bg-info';

                default: return 'bg-secondary';

            }

        }

        function showToast(message, type) {

            // Simple toast notification

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

        // Auto-refresh every 30 seconds

        setInterval(refreshAssignmentHistory, 30000);

        document.addEventListener('DOMContentLoaded', function() {

    refreshAssignmentHistory();

});

document.addEventListener('DOMContentLoaded', function() {

    const taskSelect = document.getElementById('taskId');

    const prioritySelect = document.getElementById('priority');

    

    // Check if fields were pre-filled

    if (taskSelect.value && '${preSelectedRequestId}' !== '') {

        // Add highlight animation

        taskSelect.classList.add('border-success', 'border-3');

        setTimeout(() => {

            taskSelect.classList.remove('border-success', 'border-3');

        }, 3000);

        

        // Show notification

        showToast('Yêu cầu dịch vụ đã được chọn sẵn!', 'success');

    }

    

    if (prioritySelect.value && '${preSelectedPriority}' !== '') {

        prioritySelect.classList.add('border-success', 'border-3');

        setTimeout(() => {

            prioritySelect.classList.remove('border-success', 'border-3');

        }, 3000);

    }

});

    </script>

</body>

</html>