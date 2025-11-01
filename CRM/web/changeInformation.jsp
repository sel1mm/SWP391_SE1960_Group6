<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Change Information - CRM System</title>

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
                background: linear-gradient(135deg, #1a1d23 0%, #2d3748 50%, #1a1d23 100%);
                min-height: 100vh;
                display: flex;
                flex-direction: column;
                justify-content: center;
                align-items: center;
                padding: 20px;
                position: relative;
            }

            body::before {
                content: '';
                position: absolute;
                width: 100%;
                height: 100%;
                background-image:
                    radial-gradient(circle at 20% 30%, rgba(33, 37, 41, 0.3) 0%, transparent 50%),
                    radial-gradient(circle at 80% 70%, rgba(33, 37, 41, 0.2) 0%, transparent 50%);
                animation: float 20s ease-in-out infinite;
            }

            @keyframes float {
                0%, 100% {
                    transform: translateY(0px);
                }
                50% {
                    transform: translateY(-20px);
                }
            }

            .dashboard-nav {
                max-width: 900px;
                width: 100%;
                margin-bottom: 20px;
                display: flex;
                position: relative;
                z-index: 2;
            }

            .btn-dashboard {
                display: inline-flex;
                align-items: center;
                gap: 10px;
                padding: 12px 24px;
                background: rgba(255, 255, 255, 0.95);
                color: #212529;
                border: 2px solid rgba(255, 255, 255, 0.3);
                border-radius: 10px;
                font-size: 14px;
                font-weight: 600;
                text-decoration: none;
                transition: all 0.3s ease;
                box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
                backdrop-filter: blur(10px);
            }

            .btn-dashboard:hover {
                background: white;
                transform: translateX(-3px);
                box-shadow: 0 6px 20px rgba(0, 0, 0, 0.3);
            }

            .container {
                background: white;
                border-radius: 20px;
                box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
                max-width: 900px;
                width: 100%;
                position: relative;
                z-index: 1;
                animation: slideUp 0.6s ease-out;
                overflow: hidden;
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

            .header {
                background: linear-gradient(135deg, #212529 0%, #343a40 100%);
                padding: 35px 40px;
                color: white;
                position: relative;
                overflow: hidden;
            }

            .header::before {
                content: '';
                position: absolute;
                top: -50%;
                right: -10%;
                width: 200px;
                height: 200px;
                background: rgba(255, 255, 255, 0.1);
                border-radius: 50%;
                animation: pulse 3s ease-in-out infinite;
            }

            @keyframes pulse {
                0%, 100% {
                    transform: scale(1);
                    opacity: 0.3;
                }
                50% {
                    transform: scale(1.1);
                    opacity: 0.5;
                }
            }

            .header-content {
                position: relative;
                z-index: 2;
            }

            .header h1 {
                font-size: 28px;
                font-weight: 700;
                margin-bottom: 8px;
                display: flex;
                align-items: center;
                gap: 12px;
            }

            .header p {
                font-size: 14px;
                opacity: 0.9;
            }

            .content {
                display: grid;
                grid-template-columns: 1fr 280px;
                gap: 0;
            }

            .form-section {
                padding: 40px;
                background: #fafbfc;
            }

            .form-group {
                margin-bottom: 24px;
            }

            .form-label {
                display: flex;
                align-items: center;
                gap: 8px;
                font-size: 13px;
                font-weight: 600;
                color: #4a5568;
                margin-bottom: 8px;
                text-transform: uppercase;
                letter-spacing: 0.5px;
            }

            .form-label i {
                color: #212529;
                font-size: 16px;
            }

            .form-label .required {
                color: #e53e3e;
                margin-left: 2px;
            }

            .form-input {
                width: 100%;
                padding: 12px 16px;
                border: 2px solid #e2e8f0;
                border-radius: 10px;
                font-size: 14px;
                font-family: 'Inter', sans-serif;
                transition: all 0.3s ease;
                background: white;
            }

            .form-input:focus {
                outline: none;
                border-color: #212529;
                box-shadow: 0 0 0 3px rgba(33, 37, 41, 0.1);
            }

            .form-input::placeholder {
                color: #a0aec0;
            }

            .form-input.error {
                border-color: #fc8181;
            }

            .error-message {
                color: #e53e3e;
                font-size: 12px;
                margin-top: 4px;
                display: none;
            }

            .error-message.show {
                display: block;
            }

            .message-box {
                padding: 14px 16px;
                border-radius: 10px;
                margin-bottom: 20px;
                font-size: 14px;
                font-weight: 500;
                display: none;
                animation: slideDown 0.3s ease;
                align-items: center;
                gap: 10px;
            }

            @keyframes slideDown {
                from {
                    opacity: 0;
                    transform: translateY(-10px);
                }
                to {
                    opacity: 1;
                    transform: translateY(0);
                }
            }

            .message-box.success {
                background: #d1fae5;
                color: #065f46;
                border: 1px solid #6ee7b7;
                display: flex;
            }

            .message-box.error {
                background: #fee2e2;
                color: #991b1b;
                border: 1px solid #fca5a5;
                display: flex;
            }

            .btn-submit {
                width: 100%;
                padding: 14px 24px;
                background: linear-gradient(135deg, #212529 0%, #343a40 100%);
                color: white;
                border: none;
                border-radius: 10px;
                font-size: 15px;
                font-weight: 600;
                cursor: pointer;
                transition: all 0.3s ease;
                display: flex;
                align-items: center;
                justify-content: center;
                gap: 10px;
                box-shadow: 0 4px 15px rgba(33, 37, 41, 0.4);
            }

            .btn-submit:hover:not(:disabled) {
                transform: translateY(-2px);
                box-shadow: 0 6px 20px rgba(33, 37, 41, 0.5);
            }

            .btn-submit:disabled {
                opacity: 0.6;
                cursor: not-allowed;
            }

            .btn-submit .spinner {
                width: 16px;
                height: 16px;
                border: 2px solid rgba(255, 255, 255, 0.3);
                border-top-color: white;
                border-radius: 50%;
                animation: spin 0.6s linear infinite;
                display: none;
            }

            .btn-submit.loading .spinner {
                display: block;
            }

            @keyframes spin {
                to {
                    transform: rotate(360deg);
                }
            }

            .avatar-section {
                padding: 40px 30px;
                background: white;
                border-left: 1px solid #e2e8f0;
                display: flex;
                flex-direction: column;
                align-items: center;
            }

            .avatar-wrapper {
                position: relative;
                margin-bottom: 30px;
            }

            .avatar-preview {
                width: 140px;
                height: 140px;
                border-radius: 50%;
                background: linear-gradient(135deg, #212529 0%, #343a40 100%);
                border: 4px solid white;
                box-shadow: 0 10px 25px rgba(0, 0, 0, 0.15);
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 48px;
                color: white;
                font-weight: 700;
                overflow: hidden;
                cursor: pointer;
                transition: all 0.3s ease;
            }

            .avatar-preview img {
                width: 100%;
                height: 100%;
                object-fit: cover;
            }

            .avatar-preview:hover {
                transform: scale(1.05);
                box-shadow: 0 12px 30px rgba(0, 0, 0, 0.2);
            }

            .avatar-edit-icon {
                position: absolute;
                bottom: 5px;
                right: 5px;
                width: 36px;
                height: 36px;
                background: #212529;
                border: 3px solid white;
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                cursor: pointer;
                transition: all 0.3s ease;
            }

            .avatar-edit-icon:hover {
                background: #343a40;
                transform: scale(1.1);
            }

            .avatar-edit-icon i {
                color: white;
                font-size: 14px;
            }

            .avatar-upload {
                display: none;
            }

            .btn-change-avatar {
                width: 100%;
                padding: 12px 20px;
                background: white;
                color: #212529;
                border: 2px solid #212529;
                border-radius: 10px;
                font-size: 14px;
                font-weight: 600;
                cursor: pointer;
                transition: all 0.3s ease;
                display: flex;
                align-items: center;
                justify-content: center;
                gap: 8px;
            }

            .btn-change-avatar:hover {
                background: #212529;
                color: white;
                transform: translateY(-2px);
            }

            .avatar-info {
                margin-top: 20px;
                text-align: center;
                color: #718096;
                font-size: 12px;
            }

            .btn-change-email {
                padding: 12px 20px;
                background: linear-gradient(135deg, #212529 0%, #343a40 100%);
                color: white;
                border: none;
                border-radius: 10px;
                font-size: 14px;
                font-weight: 600;
                cursor: pointer;
                white-space: nowrap;
                transition: all 0.3s ease;
            }

            .btn-change-email:hover {
                transform: translateY(-2px);
                box-shadow: 0 6px 20px rgba(33, 37, 41, 0.4);
            }

            /* Modal Styles */
            .modal {
                display: none;
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                background: rgba(0, 0, 0, 0.6);
                justify-content: center;
                align-items: center;
                z-index: 9999;
                animation: fadeIn 0.3s ease;
            }

            @keyframes fadeIn {
                from {
                    opacity: 0;
                }
                to {
                    opacity: 1;
                }
            }

            .modal-content {
                background: white;
                border-radius: 20px;
                width: 90%;
                max-width: 500px;
                box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
                animation: modalSlideUp 0.3s ease;
            }

            @keyframes modalSlideUp {
                from {
                    opacity: 0;
                    transform: translateY(30px);
                }
                to {
                    opacity: 1;
                    transform: translateY(0);
                }
            }

            .modal-header {
                background: linear-gradient(135deg, #212529 0%, #343a40 100%);
                color: white;
                padding: 25px 30px;
                border-radius: 20px 20px 0 0;
                display: flex;
                justify-content: space-between;
                align-items: center;
            }

            .modal-header h3 {
                margin: 0;
                font-size: 20px;
                font-weight: 600;
                display: flex;
                align-items: center;
                gap: 10px;
            }

            .modal-close {
                background: rgba(255, 255, 255, 0.2);
                border: none;
                color: white;
                width: 32px;
                height: 32px;
                border-radius: 50%;
                cursor: pointer;
                display: flex;
                align-items: center;
                justify-content: center;
                transition: all 0.3s ease;
            }

            .modal-close:hover {
                background: rgba(255, 255, 255, 0.3);
                transform: rotate(90deg);
            }

            .modal-body {
                padding: 30px;
            }

            .current-email-display {
                background: #f8f9fa;
                padding: 15px;
                border-radius: 10px;
                margin-bottom: 25px;
                border-left: 4px solid #212529;
                display: flex;
                align-items: center;
                gap: 8px;
            }

            .current-email-display label {
                font-weight: 600;
                color: #4a5568;
                font-size: 13px;
                white-space: nowrap;
            }

            .current-email-display p {
                margin: 0;
                color: #212529;
                font-weight: 500;
                font-size: 15px;
            }

            .btn-modal-submit {
                width: 100%;
                padding: 14px 24px;
                background: linear-gradient(135deg, #212529 0%, #343a40 100%);
                color: white;
                border: none;
                border-radius: 10px;
                font-size: 15px;
                font-weight: 600;
                cursor: pointer;
                transition: all 0.3s ease;
                display: flex;
                align-items: center;
                justify-content: center;
                gap: 10px;
                margin-top: 10px;
            }

            .btn-modal-submit:hover {
                transform: translateY(-2px);
                box-shadow: 0 6px 20px rgba(33, 37, 41, 0.4);
            }

            .btn-modal-submit:disabled {
                opacity: 0.6;
                cursor: not-allowed;
            }

            /* Responsive */
            @media (max-width: 768px) {
                .content {
                    grid-template-columns: 1fr;
                }

                .avatar-section {
                    border-left: none;
                    border-top: 1px solid #e2e8f0;
                }

                .form-section {
                    padding: 30px 20px;
                }

                .header {
                    padding: 25px 20px;
                }

                .dashboard-nav {
                    margin-bottom: 15px;
                }

                .btn-dashboard {
                    padding: 10px 18px;
                    font-size: 13px;
                }
            }
        </style>
    </head>
    <body>
        <!-- Xác định dashboard URL dựa trên role -->
        <c:choose>
            <c:when test="${sessionScope.session_role == 'admin'}">
                <c:set var="dashboardUrl" value="admin" />
            </c:when>
            <c:when test="${sessionScope.session_role == 'Technical Manager'}">
                <c:set var="dashboardUrl" value="technicalManagerApproval" />
            </c:when>
            <c:when test="${sessionScope.session_role == 'Customer Support Staff'}">
                <c:set var="dashboardUrl" value="dashboard.jsp" />
            </c:when>
            <c:when test="${sessionScope.session_role == 'Storekeeper'}">
                <c:set var="dashboardUrl" value="storekeeper" />
            </c:when>
            <c:when test="${sessionScope.session_role == 'Technician'}">
                <c:set var="dashboardUrl" value="technician/dashboard" />
            </c:when>
            <c:when test="${sessionScope.session_role == 'customer'}">
                <c:set var="dashboardUrl" value="managerServiceRequest" />
            </c:when>
            <c:otherwise>
                <c:set var="dashboardUrl" value="home.jsp" />
            </c:otherwise>
        </c:choose>

        <!-- Back to Dashboard Button -->
        <div class="dashboard-nav">
            <a href="${dashboardUrl}" class="btn-dashboard">
                <i class="fas fa-arrow-left"></i>
                Back to Dashboard
            </a>
        </div>

        <div class="container">
            <!-- Header -->
            <div class="header">
                <div class="header-content">
                    <h1>
                        <i class="fas fa-user-edit"></i>
                        Change Information
                    </h1>
                    <p>Update your personal information and profile details</p>
                </div>
            </div>

            <form action="changeInformation" method="POST" id="changeInfoForm" enctype="multipart/form-data">
                <div class="content">
                    <!-- Form Section -->
                    <div class="form-section">
                        <!-- Display messages from server -->
                        <c:if test="${not empty successMessage}">
                            <div class="message-box success">
                                <i class="fas fa-check-circle"></i>
                                <span>${successMessage}</span>
                            </div>
                        </c:if>

                        <c:if test="${not empty errorMessage}">
                            <div class="message-box error">
                                <i class="fas fa-exclamation-circle"></i>
                                <span>${errorMessage}</span>
                            </div>
                        </c:if>

                        <div id="messageBox" class="message-box"></div>

                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-user"></i>
                                Full Name
                                <span class="required">*</span>
                            </label>
                            <input type="text" 
                                   name="fullName" 
                                   id="fullName" 
                                   class="form-input" 
                                   placeholder="Enter your full name"
                                   value="${sessionScope.user.fullName}"
                                   maxlength="50"
                                   required>
                            <div class="error-message" id="fullNameError">Please enter your full name (at least 2 characters)</div>
                        </div>

                        <!-- Email with Change Button -->
                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-envelope"></i>
                                Email Address
                                <span class="required">*</span>
                            </label>

                            <div style="display: flex; gap: 10px; align-items: center;">
                                <input type="email" 
                                       name="email" 
                                       id="email" 
                                       class="form-input" 
                                       style="flex: 1;"
                                       placeholder="example@email.com"
                                       value="${sessionScope.user.email}"
                                       readonly
                                       required>

                                <button type="button" 
                                        class="btn-change-email" 
                                        onclick="openChangeEmailModal()">
                                    <i class="fas fa-paper-plane"></i> Change Email
                                </button>
                            </div>
                            <div style="margin-top: 8px; font-size: 12px; color: #718096;">
                                <i class="fas fa-info-circle"></i> Click "Change Email" to update your email address
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-phone"></i>
                                Phone Number
                            </label>
                            <input type="tel" 
                                   name="phone" 
                                   id="phone" 
                                   class="form-input" 
                                   placeholder="0123456789"
                                   value="${sessionScope.user.phone}"
                                   pattern="[0-9]{10,11}">
                            <div class="error-message" id="phoneError">Phone number must be 10-11 digits </div>
                        </div>

                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-map-marker-alt"></i>
                                Address
                                <span class="required">*</span>
                            </label>
                            <input type="text" 
                                   name="address" 
                                   id="address" 
                                   class="form-input" 
                                   placeholder="123 Main Street, City"
                                   value="${sessionScope.user.address}"
                                   maxlength="200"
                                   required>
                            <div class="error-message" id="addressError">Please enter your address (at least 5 characters)</div>
                        </div>

                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-id-card"></i>
                                National ID
                                <span class="required">*</span>
                            </label>
                            <input type="text" 
                                   name="nationalId" 
                                   id="nationalId" 
                                   class="form-input" 
                                   placeholder="123456789012"
                                   value="${sessionScope.user.nationalId}"
                                   pattern="[0-9]{9,12}"
                                   required>
                            <div class="error-message" id="nationalIdError">National ID must be 9-12 digits</div>
                        </div>

                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-calendar"></i>
                                Date of Birth
                                <span class="required">*</span>
                            </label>
                            <input type="date" 
                                   name="dob" 
                                   id="dob" 
                                   class="form-input"
                                   value="${sessionScope.user.dob}"
                                   required>
                            <div class="error-message" id="dobError">You must be at least 18 years old</div>
                        </div>

                        <button type="submit" class="btn-submit" id="submitBtn">
                            <div class="spinner"></div>
                            <i class="fas fa-save"></i>
                            <span>Save Changes</span>
                        </button>
                    </div>
                    <!-- Avatar Section - FIXED -->
                    <div class="avatar-section">
                        <div class="avatar-wrapper">
                            <div class="avatar-preview" onclick="document.getElementById('avatarUpload').click()">
                                <c:choose>
                                    <c:when test="${not empty sessionScope.user.avatar}">
                                        <!-- ✅ FIXED: Sử dụng servlet mapping /avatar/ -->
                                        <img src="${pageContext.request.contextPath}/avatar/${sessionScope.user.avatar}" 
                                             alt="Avatar"
                                             id="currentAvatar"
                                             onerror="console.error('Failed to load avatar:', this.src); this.onerror=null; this.parentElement.innerHTML='<i class=\'fas fa-user\'></i>';">
                                    </c:when>
                                    <c:otherwise>
                                        <i class="fas fa-user"></i>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <div class="avatar-edit-icon" onclick="document.getElementById('avatarUpload').click()">
                                <i class="fas fa-camera"></i>
                            </div>
                        </div>

                        <input type="file" 
                               id="avatarUpload" 
                               name="avatar"
                               class="avatar-upload" 
                               accept="image/jpeg,image/png,image/gif"
                               onchange="previewAvatar(event)">

                        <button type="button" class="btn-change-avatar" onclick="document.getElementById('avatarUpload').click()">
                            <i class="fas fa-upload"></i>
                            Upload Photo
                        </button>

                        <div class="avatar-info">
                            <p>Allowed: JPG, PNG, GIF</p>
                            <p>Max size: 2MB</p>
                            <c:if test="${not empty sessionScope.user.avatar}">
                                <p style="margin-top: 10px; font-size: 11px; color: #a0aec0;">
                                    Current: ${sessionScope.user.avatar}
                                </p>
                            </c:if>
                        </div>
                    </div>         

                </div>
            </form>
        </div>

        <!-- Change Email Modal -->
        <div id="changeEmailModal" class="modal">
            <div class="modal-content">
                <div class="modal-header">
                    <h3><i class="fas fa-envelope"></i> Change Email Address</h3>
                    <button type="button" class="modal-close" onclick="closeChangeEmailModal()">
                        <i class="fas fa-times"></i>
                    </button>
                </div>

                <div class="modal-body">
                    <div class="current-email-display">
                        <label><i class="fas fa-envelope-open"></i> Current Email:</label>
                        <p>${sessionScope.user.email}</p>
                    </div>

                    <form id="changeEmailForm" onsubmit="handleChangeEmail(event)">
                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-at"></i> New Email Address
                                <span class="required">*</span>
                            </label>
                            <input type="email" 
                                   id="newEmail" 
                                   name="newEmail"
                                   class="form-input" 
                                   placeholder="Enter new email address"
                                   required>
                            <div class="error-message" id="newEmailError">Please enter a valid email</div>
                        </div>

                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-check-double"></i> Confirm New Email
                                <span class="required">*</span>
                            </label>
                            <input type="email" 
                                   id="confirmNewEmail" 
                                   name="confirmNewEmail"
                                   class="form-input" 
                                   placeholder="Re-enter new email address"
                                   required>
                            <div class="error-message" id="confirmNewEmailError">Emails do not match</div>
                        </div>

                        <button type="submit" class="btn-modal-submit" id="sendOtpBtn">
                            <i class="fas fa-paper-plane"></i> Send OTP
                        </button>
                    </form>
                </div>
            </div>
        </div>

        <script>
    // ==================== Avatar Functions - FIXED ====================
    function previewAvatar(event) {
        const file = event.target.files[0];
        if (!file) {
            console.log('ℹ️ No file selected');
            return;
        }

        console.log('📁 Selected file:', file.name, 'Size:', file.size, 'Type:', file.type);

        // Validate file size
        if (file.size > 2 * 1024 * 1024) {
            showMessage('error', 'File size must be less than 2MB!');
            event.target.value = '';
            return;
        }

        // Validate file type
        const validTypes = ['image/jpeg', 'image/png', 'image/gif'];
        if (!validTypes.includes(file.type)) {
            showMessage('error', 'Only JPG, PNG, and GIF files are allowed!');
            event.target.value = '';
            return;
        }

        // Preview image
        const reader = new FileReader();
        reader.onload = function (e) {
            const avatarPreview = document.querySelector('.avatar-preview');
            avatarPreview.innerHTML = '<img src="' + e.target.result + '" alt="Avatar Preview" id="currentAvatar">';
            console.log('✅ Avatar preview updated');
        };
        reader.onerror = function (error) {
            console.error('❌ FileReader error:', error);
            showMessage('error', 'Failed to read file');
        };
        reader.readAsDataURL(file);
    }

    // ==================== Message Functions ====================
    function showMessage(type, message) {
        const messageBox = document.getElementById('messageBox');
        messageBox.className = 'message-box ' + type;
        messageBox.style.display = 'flex';
        messageBox.innerHTML = '<i class="fas fa-' + (type === 'success' ? 'check' : 'exclamation') + '-circle"></i><span>' + message + '</span>';

        setTimeout(function () {
            messageBox.style.display = 'none';
        }, 5000);
    }

    // ==================== Validation Functions ====================
    function validateEmail(email) {
        return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
    }

    function validatePhone(phone) {
        if (!phone || phone.trim() === '')
            return false;
        return /^[0-9]{10,11}$/.test(phone);
    }

    function validateNationalId(id) {
        return /^[0-9]{9,12}$/.test(id);
    }

    function validateDOB(dob) {
        if (!dob)
            return false;
        const birthDate = new Date(dob);
        const today = new Date();
        const age = today.getFullYear() - birthDate.getFullYear();
        const monthDiff = today.getMonth() - birthDate.getMonth();

        if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
            return age - 1 >= 18;
        }
        return age >= 18;
    }

    function showFieldError(fieldId, show) {
        if (show === undefined)
            show = true;

        const field = document.getElementById(fieldId);
        const error = document.getElementById(fieldId + 'Error');

        if (field && error) {
            if (show) {
                field.classList.add('error');
                error.classList.add('show');
            } else {
                field.classList.remove('error');
                error.classList.remove('show');
            }
        }
    }

    // ==================== Main Form Submission ====================
    document.getElementById('changeInfoForm').addEventListener('submit', function (e) {
        e.preventDefault();

        let isValid = true;
        const submitBtn = document.getElementById('submitBtn');

        // Validate full name
        const fullName = document.getElementById('fullName').value.trim();
        if (fullName.length < 2) {
            showFieldError('fullName');
            isValid = false;
        } else {
            showFieldError('fullName', false);
        }

        // Validate email
        const email = document.getElementById('email').value.trim();
        if (!validateEmail(email)) {
            showFieldError('email');
            isValid = false;
        } else {
            showFieldError('email', false);
        }

        // Validate phone
        const phone = document.getElementById('phone').value.trim();
        if (!validatePhone(phone)) {
            showFieldError('phone');
            isValid = false;
        } else {
            showFieldError('phone', false);
        }

        // Validate address
        const address = document.getElementById('address').value.trim();
        if (address.length < 5) {
            showFieldError('address');
            isValid = false;
        } else {
            showFieldError('address', false);
        }

        // Validate national ID
        const nationalId = document.getElementById('nationalId').value.trim();
        if (!validateNationalId(nationalId)) {
            showFieldError('nationalId');
            isValid = false;
        } else {
            showFieldError('nationalId', false);
        }

        // Validate date of birth
        const dob = document.getElementById('dob').value;
        if (!validateDOB(dob)) {
            showFieldError('dob');
            isValid = false;
        } else {
            showFieldError('dob', false);
        }

        if (isValid) {
            submitBtn.classList.add('loading');
            submitBtn.disabled = true;
            console.log('✅ Form validation passed, submitting...');
            this.submit();
        } else {
            showMessage('error', 'Please correct the errors in the form!');
        }
    });

    // ==================== Real-time Validation ====================
    document.getElementById('email').addEventListener('blur', function () {
        if (this.value && !validateEmail(this.value)) {
            showFieldError('email');
        } else {
            showFieldError('email', false);
        }
    });

    document.getElementById('phone').addEventListener('blur', function () {
        if (!validatePhone(this.value)) {
            showFieldError('phone');
        } else {
            showFieldError('phone', false);
        }
    });

    document.getElementById('nationalId').addEventListener('blur', function () {
        if (this.value && !validateNationalId(this.value)) {
            showFieldError('nationalId');
        } else {
            showFieldError('nationalId', false);
        }
    });

    document.getElementById('dob').addEventListener('change', function () {
        if (!validateDOB(this.value)) {
            showFieldError('dob');
        } else {
            showFieldError('dob', false);
        }
    });

    // ==================== Modal Functions ====================
    function openChangeEmailModal() {
        console.log('Opening modal...');
        const modal = document.getElementById('changeEmailModal');
        if (modal) {
            modal.style.display = 'flex';
            document.body.style.overflow = 'hidden';

            // Clear form
            document.getElementById('newEmail').value = '';
            document.getElementById('confirmNewEmail').value = '';

            // Clear errors
            document.getElementById('newEmailError').classList.remove('show');
            document.getElementById('confirmNewEmailError').classList.remove('show');
            document.getElementById('newEmail').classList.remove('error');
            document.getElementById('confirmNewEmail').classList.remove('error');

            console.log('Modal opened successfully');
        } else {
            console.error('Modal element not found!');
        }
    }

    function closeChangeEmailModal() {
        const modal = document.getElementById('changeEmailModal');
        if (modal) {
            modal.style.display = 'none';
            document.body.style.overflow = 'auto';
        }
    }

    // Close modal when clicking outside
    window.onclick = function (event) {
        const modal = document.getElementById('changeEmailModal');
        if (event.target === modal) {
            closeChangeEmailModal();
        }
    };

    // ==================== Change Email Handler ====================
    function handleChangeEmail(event) {
        event.preventDefault();

        const newEmail = document.getElementById('newEmail').value.trim();
        const confirmNewEmail = document.getElementById('confirmNewEmail').value.trim();
        const currentEmail = '${sessionScope.user.email}';

        let isValid = true;

        // Validate new email format
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(newEmail)) {
            document.getElementById('newEmailError').textContent = 'Please enter a valid email';
            document.getElementById('newEmailError').classList.add('show');
            document.getElementById('newEmail').classList.add('error');
            isValid = false;
        } else {
            document.getElementById('newEmailError').classList.remove('show');
            document.getElementById('newEmail').classList.remove('error');
        }

        // Validate email match
        if (newEmail !== confirmNewEmail) {
            document.getElementById('confirmNewEmailError').textContent = 'Emails do not match';
            document.getElementById('confirmNewEmailError').classList.add('show');
            document.getElementById('confirmNewEmail').classList.add('error');
            isValid = false;
        } else {
            document.getElementById('confirmNewEmailError').classList.remove('show');
            document.getElementById('confirmNewEmail').classList.remove('error');
        }

        // Validate new email different from current
        if (newEmail.toLowerCase() === currentEmail.toLowerCase()) {
            document.getElementById('newEmailError').textContent = 'New email must be different from current email';
            document.getElementById('newEmailError').classList.add('show');
            document.getElementById('newEmail').classList.add('error');
            isValid = false;
        }

        if (isValid) {
            const submitBtn = document.getElementById('sendOtpBtn');
            submitBtn.disabled = true;
            submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Sending...';

            const formData = new FormData();
            formData.append('newEmail', newEmail);
            formData.append('confirmEmail', confirmNewEmail);

            fetch('changeEmail', {
                method: 'POST',
                body: formData
            })
                    .then(response => {
                        if (response.redirected) {
                            window.location.href = response.url;
                        } else {
                            return response.text();
                        }
                    })
                    .then(html => {
                        if (html) {
                            const parser = new DOMParser();
                            const doc = parser.parseFromString(html, 'text/html');
                            const errorElement = doc.querySelector('.alert-danger');

                            if (errorElement) {
                                showMessage('error', errorElement.textContent.trim());
                                submitBtn.disabled = false;
                                submitBtn.innerHTML = '<i class="fas fa-paper-plane"></i> Send OTP';
                            }
                        }
                    })
                    .catch(error => {
                        console.error('Error:', error);
                        showMessage('error', 'An error occurred. Please try again.');
                        submitBtn.disabled = false;
                        submitBtn.innerHTML = '<i class="fas fa-paper-plane"></i> Send OTP';
                    });
        }
    }

    // ==================== Modal Real-time Validation ====================
    document.getElementById('newEmail').addEventListener('blur', function () {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (this.value && !emailRegex.test(this.value)) {
            document.getElementById('newEmailError').classList.add('show');
            this.classList.add('error');
        } else {
            document.getElementById('newEmailError').classList.remove('show');
            this.classList.remove('error');
        }
    });

    document.getElementById('confirmNewEmail').addEventListener('blur', function () {
        const newEmail = document.getElementById('newEmail').value;
        if (this.value && this.value !== newEmail) {
            document.getElementById('confirmNewEmailError').classList.add('show');
            this.classList.add('error');
        } else {
            document.getElementById('confirmNewEmailError').classList.remove('show');
            this.classList.remove('error');
        }
    });

    // ==================== Initialize ====================
    // Set max date for DOB (18 years ago)
    const dobInput = document.getElementById('dob');
    const today = new Date();
    const maxDate = new Date(today.getFullYear() - 18, today.getMonth(), today.getDate());
    dobInput.max = maxDate.toISOString().split('T')[0];

    // Auto-hide server messages after 5 seconds
    window.addEventListener('DOMContentLoaded', function () {
        console.log('🚀 Page loaded, initializing...');
        
        const serverMessages = document.querySelectorAll('.message-box.success, .message-box.error');
        serverMessages.forEach(function (msg) {
            if (msg.style.display !== 'none') {
                setTimeout(function () {
                    msg.style.display = 'none';
                }, 5000);
            }
        });

        // ✅ Debug avatar loading
        const avatarImg = document.getElementById('currentAvatar');
        if (avatarImg) {
            console.log('✅ Avatar element found');
            console.log('   - Source URL:', avatarImg.src);
            
            // Listen for load event
            avatarImg.addEventListener('load', function() {
                console.log('✅ Avatar loaded successfully');
            });
            
            // Listen for error event
            avatarImg.addEventListener('error', function() {
                console.error('❌ Failed to load avatar from:', this.src);
            });
        } else {
            console.log('ℹ️ No avatar image found (user may not have avatar)');
        }

        // Debug upload directory
        console.log('📁 Upload configuration:');
        console.log('   - Expected URL pattern: /yourapp/avatar/avatar_XXX_timestamp.jpg');
        console.log('   - AvatarServlet should serve from: D:/Every thing relate to Lam/.../avatar/');
    });
</script>
        <%
            // Xóa message sau khi đã hiển thị
            session.removeAttribute("successMessage");
            session.removeAttribute("errorMessage");
        %>
    </body>
</html>