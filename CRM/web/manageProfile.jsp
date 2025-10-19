<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Profile - CRM System</title>
    
    <!-- Fonts & Icons -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', system-ui, -apple-system, sans-serif;
            background: #f5f7fa;
            min-height: 100vh;
            padding: 20px;
        }

        .profile-container {
            background: white;
            border-radius: 16px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
            max-width: 1100px;
            width: 100%;
            margin: 0 auto;
            overflow: hidden;
            animation: slideUp 0.6s ease-out;
        }

        @keyframes slideUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }


        /* Header Section */
        .profile-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 40px;
            color: white;
        }


        .header-content {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .header-left h1 {
            font-size: 32px;
            font-weight: 700;
            margin-bottom: 8px;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .header-left p {
            font-size: 15px;
            opacity: 0.9;
            font-weight: 400;
        }

        .header-right .badge {
            background: rgba(255, 255, 255, 0.2);
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 600;
            backdrop-filter: blur(10px);
        }

        /* Main Content */
        .profile-content {
            display: grid;
            grid-template-columns: 1fr 350px;
            gap: 0;
        }

        /* Left Side - Info */
        .info-section {
            padding: 40px;
            background: #fafbfc;
        }

        .info-grid {
            display: grid;
            gap: 24px;
        }

        .info-item {
            display: flex;
            align-items: flex-start;
            gap: 16px;
            padding: 18px;
            background: white;
            border-radius: 12px;
            border: 1px solid #e8ecf1;
            transition: all 0.3s ease;
        }

        .info-item:hover {
            border-color: #667eea;
            box-shadow: 0 4px 12px rgba(102, 126, 234, 0.15);
            transform: translateY(-2px);
        }

        .info-icon {
            width: 42px;
            height: 42px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 18px;
            flex-shrink: 0;
        }

        .info-details {
            flex: 1;
        }

        .info-label {
            font-size: 12px;
            color: #8492a6;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 4px;
        }

        .info-value {
            font-size: 15px;
            color: #2c3e50;
            font-weight: 500;
            word-break: break-word;
        }

        /* Right Side - Avatar & Actions */
        .avatar-section {
            padding: 40px 30px;
            background: white;
            border-left: 1px solid #e8ecf1;
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        .avatar-wrapper {
            position: relative;
            margin-bottom: 30px;
        }

        .avatar-preview {
            width: 160px;
            height: 160px;
            border-radius: 50%;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border: 5px solid white;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 64px;
            color: white;
            font-weight: 700;
            position: relative;
            overflow: hidden;
        }

        /* ✅ THÊM - CSS cho avatar image */
        .avatar-preview img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            border-radius: 50%;
        }

        .avatar-badge {
            position: absolute;
            bottom: 10px;
            right: 10px;
            width: 36px;
            height: 36px;
            background: #10b981;
            border: 4px solid white;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .avatar-badge i {
            color: white;
            font-size: 14px;
        }

        .user-name {
            font-size: 22px;
            font-weight: 700;
            color: #2c3e50;
            margin-bottom: 6px;
            text-align: center;
        }

        .user-role {
            font-size: 14px;
            color: #8492a6;
            margin-bottom: 30px;
            text-align: center;
        }

        /* Action Buttons */
        .action-buttons {
            width: 100%;
            display: flex;
            flex-direction: column;
            gap: 12px;
        }

        .btn-action {
            width: 100%;
            padding: 14px 20px;
            border: none;
            border-radius: 10px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            transition: all 0.3s ease;
            text-decoration: none;
            text-align: center;
        }

        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(102, 126, 234, 0.5);
        }

        .btn-secondary {
            background: white;
            color: #667eea;
            border: 2px solid #667eea;
        }

        .btn-secondary:hover {
            background: #667eea;
            color: white;
            transform: translateY(-2px);
        }

        .divider {
            width: 100%;
            height: 1px;
            background: #e8ecf1;
            margin: 20px 0;
        }

        .stats-grid {
            width: 100%;
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
            margin-top: 20px;
        }

        .stat-card {
            background: #f8f9fc;
            padding: 16px;
            border-radius: 10px;
            text-align: center;
        }

        .stat-value {
            font-size: 24px;
            font-weight: 700;
            color: #667eea;
            margin-bottom: 4px;
        }

        .stat-label {
            font-size: 12px;
            color: #8492a6;
            font-weight: 500;
        }

        /* Responsive */
        @media (max-width: 968px) {
            .profile-content {
                grid-template-columns: 1fr;
            }

            .avatar-section {
                border-left: none;
                border-top: 1px solid #e8ecf1;
            }

            .header-content {
                flex-direction: column;
                gap: 20px;
                text-align: center;
            }
        }

        @media (max-width: 640px) {
            .profile-header {
                padding: 30px 20px;
            }

            .info-section {
                padding: 30px 20px;
            }

            .header-left h1 {
                font-size: 24px;
            }

            .info-item {
                flex-direction: column;
                align-items: flex-start;
            }
        }
    </style>
</head>
<body>
    <div class="profile-container">
        <!-- Header -->
        <div class="profile-header">
            <div class="header-content">
                <div class="header-left">
                    <h1>
                        <i class="fas fa-user-circle"></i>
                        My Profile
                    </h1>
                    <p>Manage your account information and security settings</p>
                </div>
                <div class="header-right">
                    <span class="badge">
                        <i class="fas fa-shield-alt"></i> Account Protected
                    </span>
                </div>
            </div>
        </div>

        <!-- Main Content -->
        <form action="manageProfile" method="POST">
            <div class="profile-content">
                <!-- Left Side - Information -->
                <div class="info-section">
                    <div class="info-grid">
                        <div class="info-item">
                            <div class="info-icon">
                                <i class="fas fa-user"></i>
                            </div>
                            <div class="info-details">
                                <div class="info-label">Username</div>
                                <div class="info-value">
                                    <c:choose>
                                        <c:when test="${not empty account.data}">
                                            ${account.data.username}
                                        </c:when>
                                        <c:otherwise>
                                            N/A
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>

                        <div class="info-item">
                            <div class="info-icon">
                                <i class="fas fa-id-card"></i>
                            </div>
                            <div class="info-details">
                                <div class="info-label">Full Name</div>
                                <div class="info-value">
                                    <c:choose>
                                        <c:when test="${not empty account.data}">
                                            ${account.data.fullName}
                                        </c:when>
                                        <c:otherwise>
                                            N/A
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>

                        <div class="info-item">
                            <div class="info-icon">
                                <i class="fas fa-envelope"></i>
                            </div>
                            <div class="info-details">
                                <div class="info-label">Email Address</div>
                                <div class="info-value">
                                    <c:choose>
                                        <c:when test="${not empty account.data}">
                                            ${account.data.email}
                                        </c:when>
                                        <c:otherwise>
                                            N/A
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>

                        <div class="info-item">
                            <div class="info-icon">
                                <i class="fas fa-phone"></i>
                            </div>
                            <div class="info-details">
                                <div class="info-label">Phone Number</div>
                                <div class="info-value">
                                    <c:choose>
                                        <c:when test="${not empty account.data}">
                                            ${account.data.phone}
                                        </c:when>
                                        <c:otherwise>
                                            N/A
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>

                        <div class="info-item">
                            <div class="info-icon">
                                <i class="fas fa-map-marker-alt"></i>
                            </div>
                            <div class="info-details">
                                <div class="info-label">Address</div>
                                <div class="info-value">
                                    <c:choose>
                                        <c:when test="${not empty accountProfile}">
                                            ${accountProfile.address}
                                        </c:when>
                                        <c:otherwise>
                                            N/A
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>

                        <div class="info-item">
                            <div class="info-icon">
                                <i class="fas fa-id-badge"></i>
                            </div>
                            <div class="info-details">
                                <div class="info-label">National ID</div>
                                <div class="info-value">
                                    <c:choose>
                                        <c:when test="${not empty accountProfile}">
                                            ${accountProfile.nationalId}
                                        </c:when>
                                        <c:otherwise>
                                            N/A
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>


                        <div class="info-item">
                            <div class="info-icon">
                                <i class="fas fa-calendar"></i>
                            </div>
                            <div class="info-details">
                                <div class="info-label">Date of Birth</div>
                                <div class="info-value">
                                    <c:choose>
                                        <c:when test="${not empty accountProfile}">
                                            ${accountProfile.dateOfBirth}
                                        </c:when>
                                        <c:otherwise>
                                            N/A
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>


                <!-- Right Side - Avatar & Actions -->
                <div class="avatar-section">
                    <div class="avatar-wrapper">
                        <div class="avatar-preview">
                            <!-- ✅ SỬA - Hiển thị ảnh avatar hoặc chữ cái đầu -->
                            <c:choose>
                                <c:when test="${not empty accountProfile and not empty accountProfile.avatarUrl}">
                                    <img src="${accountProfile.avatarUrl}" alt="Avatar">
                                </c:when>
                                <c:otherwise>
                                    <c:choose>
                                        <c:when test="${not empty account.data and not empty account.data.fullName}">
                                            ${account.data.fullName.substring(0, 1).toUpperCase()}
                                        </c:when>
                                        <c:otherwise>
                                            ?
                                        </c:otherwise>
                                    </c:choose>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <div class="avatar-badge">
                            <i class="fas fa-check"></i>
                        </div>
                    </div>

                    <div class="user-name">
                        <c:choose>
                            <c:when test="${not empty account.data}">
                                ${account.data.fullName}
                            </c:when>
                            <c:otherwise>
                                User Name
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="user-role">
                        <i class="fas fa-briefcase"></i> Store Keeper
                    </div>

                    <div class="action-buttons">
                        <button type="button" class="btn-action btn-primary" 
                                onclick="window.location.href='changeInformation'">
                            <i class="fas fa-edit"></i>
                            Edit Information
                        </button>

                        <button type="button" class="btn-action btn-secondary" 
                                onclick="window.location.href='changePassword.jsp'">
                            <i class="fas fa-key"></i>
                            Change Password
                        </button>
                    </div>

                    <div class="divider"></div>

                    <div class="stats-grid">
                        <div class="stat-card">
                            <div class="stat-value">24</div>
                            <div class="stat-label">Active Days</div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-value">152</div>
                            <div class="stat-label">Tasks Done</div>
                        </div>
                    </div>
                </div>
            </div>
        </form>
    </div>
</body>
</html>