<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .card-hover:hover {
            transform: translateY(-5px);
            transition: transform 0.3s ease;
        }
        .card-hover {
            transition: transform 0.3s ease;
        }
    </style>
</head>
<body>
    <div class="container-fluid">
        <div class="row">
            <!-- Sidebar -->
            <div class="col-md-2 bg-dark min-vh-100">
                <div class="p-3">
                    <h4 class="text-white">CRM System</h4>
                    <ul class="nav flex-column">
                        <li class="nav-item">
                            <a class="nav-link text-white" href="${pageContext.request.contextPath}/home.jsp">
                                <i class="fas fa-home"></i> Home
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link text-white active" href="${pageContext.request.contextPath}/admin.jsp">
                                <i class="fas fa-tachometer-alt"></i> Admin Dashboard
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link text-white" href="${pageContext.request.contextPath}/user/list">
                                <i class="fas fa-users"></i> Users
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link text-white" href="${pageContext.request.contextPath}/role/list">
                                <i class="fas fa-user-tag"></i> Roles
                            </a>
                        </li>
                    </ul>
                </div>
            </div>

            <!-- Main Content -->
            <div class="col-md-10">
                <div class="p-4">
                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <h2><i class="fas fa-tachometer-alt"></i> Admin Dashboard</h2>
                        <div class="text-muted">
                            <i class="fas fa-user-shield"></i> Administrator Panel
                        </div>
                    </div>

                    <!-- Welcome Message -->
                    <div class="alert alert-info">
                        <h5><i class="fas fa-info-circle"></i> Welcome to the Admin Dashboard</h5>
                        <p class="mb-0">Manage users, roles, and system settings from this central location.</p>
                    </div>

                    <!-- Management Cards -->
                    <div class="row">
                        <!-- User Management -->
                        <div class="col-md-6 mb-4">
                            <div class="card card-hover h-100">
                                <div class="card-body text-center">
                                    <i class="fas fa-users fa-3x text-primary mb-3"></i>
                                    <h4 class="card-title">User Management</h4>
                                    <p class="card-text">Create, edit, and manage user accounts. Assign roles and permissions to users.</p>
                                    <div class="d-grid gap-2">
                                        <a href="${pageContext.request.contextPath}/user/list" class="btn btn-primary">
                                            <i class="fas fa-users"></i> Manage Users
                                        </a>
                                        <a href="${pageContext.request.contextPath}/user/create" class="btn btn-outline-primary">
                                            <i class="fas fa-user-plus"></i> Add New User
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Role Management -->
                        <div class="col-md-6 mb-4">
                            <div class="card card-hover h-100">
                                <div class="card-body text-center">
                                    <i class="fas fa-user-tag fa-3x text-success mb-3"></i>
                                    <h4 class="card-title">Role Management</h4>
                                    <p class="card-text">Create and manage user roles. Define permissions and access levels for different user types.</p>
                                    <div class="d-grid gap-2">
                                        <a href="${pageContext.request.contextPath}/role/list" class="btn btn-success">
                                            <i class="fas fa-user-tag"></i> Manage Roles
                                        </a>
                                        <a href="${pageContext.request.contextPath}/role/create" class="btn btn-outline-success">
                                            <i class="fas fa-plus"></i> Add New Role
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Quick Stats -->
                    <div class="row">
                        <div class="col-md-12">
                            <div class="card">
                                <div class="card-header">
                                    <h5><i class="fas fa-chart-bar"></i> Quick Statistics</h5>
                                </div>
                                <div class="card-body">
                                    <div class="row text-center">
                                        <div class="col-md-3">
                                            <div class="p-3">
                                                <i class="fas fa-users fa-2x text-primary mb-2"></i>
                                                <h4 class="text-primary">Users</h4>
                                                <p class="text-muted">Total registered users</p>
                                            </div>
                                        </div>
                                        <div class="col-md-3">
                                            <div class="p-3">
                                                <i class="fas fa-user-tag fa-2x text-success mb-2"></i>
                                                <h4 class="text-success">Roles</h4>
                                                <p class="text-muted">Available user roles</p>
                                            </div>
                                        </div>
                                        <div class="col-md-3">
                                            <div class="p-3">
                                                <i class="fas fa-user-check fa-2x text-info mb-2"></i>
                                                <h4 class="text-info">Active</h4>
                                                <p class="text-muted">Active user accounts</p>
                                            </div>
                                        </div>
                                        <div class="col-md-3">
                                            <div class="p-3">
                                                <i class="fas fa-user-times fa-2x text-warning mb-2"></i>
                                                <h4 class="text-warning">Inactive</h4>
                                                <p class="text-muted">Inactive user accounts</p>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- System Information -->
                    <div class="row mt-4">
                        <div class="col-md-12">
                            <div class="card">
                                <div class="card-header">
                                    <h5><i class="fas fa-cog"></i> System Information</h5>
                                </div>
                                <div class="card-body">
                                    <div class="row">
                                        <div class="col-md-6">
                                            <h6>Features Available:</h6>
                                            <ul class="list-unstyled">
                                                <li><i class="fas fa-check text-success"></i> User CRUD Operations</li>
                                                <li><i class="fas fa-check text-success"></i> Role Management</li>
                                                <li><i class="fas fa-check text-success"></i> User-Role Assignment</li>
                                                <li><i class="fas fa-check text-success"></i> Password Management</li>
                                                <li><i class="fas fa-check text-success"></i> Account Status Control</li>
                                            </ul>
                                        </div>
                                        <div class="col-md-6">
                                            <h6>Security Features:</h6>
                                            <ul class="list-unstyled">
                                                <li><i class="fas fa-shield-alt text-primary"></i> Password Hashing</li>
                                                <li><i class="fas fa-lock text-primary"></i> Role-based Access</li>
                                                <li><i class="fas fa-user-shield text-primary"></i> Admin Controls</li>
                                                <li><i class="fas fa-key text-primary"></i> Secure Authentication</li>
                                            </ul>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
