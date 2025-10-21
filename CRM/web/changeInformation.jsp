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
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
            position: relative;
        }

        /* Animated background */
        body::before {
            content: '';
            position: absolute;
            width: 100%;
            height: 100%;
            background-image: 
                radial-gradient(circle at 20% 30%, rgba(255,255,255,0.1) 0%, transparent 50%),
                radial-gradient(circle at 80% 70%, rgba(255,255,255,0.08) 0%, transparent 50%);
            animation: float 20s ease-in-out infinite;
        }

        @keyframes float {
            0%, 100% { transform: translateY(0px); }
            50% { transform: translateY(-20px); }
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

        /* Header */
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 30px 40px;
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
            0%, 100% { transform: scale(1); opacity: 0.3; }
            50% { transform: scale(1.1); opacity: 0.5; }
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

        /* Back Button */
        .btn-back {
            position: absolute;
            top: 30px;
            right: 40px;
            padding: 10px 20px;
            background: rgba(255, 255, 255, 0.2);
            color: white;
            border: 1px solid rgba(255, 255, 255, 0.3);
            border-radius: 8px;
            text-decoration: none;
            font-size: 14px;
            font-weight: 500;
            transition: all 0.3s ease;
            z-index: 3;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }

        .btn-back:hover {
            background: rgba(255, 255, 255, 0.3);
        }

        /* Content Grid */
        .content {
            display: grid;
            grid-template-columns: 1fr 280px;
            gap: 0;
        }

        /* Form Section */
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
            color: #667eea;
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
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
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
            padding: 12px 16px;
            border-radius: 10px;
            margin-bottom: 20px;
            font-size: 14px;
            font-weight: 500;
            display: none;
            animation: slideDown 0.3s ease;
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
            display: block;
        }

        .message-box.error {
            background: #fee2e2;
            color: #991b1b;
            border: 1px solid #fca5a5;
            display: block;
        }

        .btn-submit {
            width: 100%;
            padding: 14px 24px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
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
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
        }

        .btn-submit:hover:not(:disabled) {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(102, 126, 234, 0.5);
        }

        .btn-submit:active:not(:disabled) {
            transform: translateY(0);
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
            to { transform: rotate(360deg); }
        }

        /* Avatar Section */
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
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
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
            background: #667eea;
            border: 3px solid white;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .avatar-edit-icon:hover {
            background: #5568d3;
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
            color: #667eea;
            border: 2px solid #667eea;
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
            background: #667eea;
            color: white;
            transform: translateY(-2px);
        }

        .avatar-info {
            margin-top: 20px;
            text-align: center;
            color: #718096;
            font-size: 12px;
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

            .btn-back {
                position: static;
                margin-bottom: 15px;
            }

            .header-content {
                margin-top: 10px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- Header -->
        <div class="header">
            <a href="storekeeper" class="btn-back">
                <i class="fas fa-arrow-left"></i> Back to Dashboard
            </a>
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
                            <i class="fas fa-check-circle"></i> ${successMessage}
                        </div>
                    </c:if>
                    
                    <c:if test="${not empty errorMessage}">
                        <div class="message-box error">
                            <i class="fas fa-exclamation-circle"></i> ${errorMessage}
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
                               maxlength="20"
                               required>
                        <div class="error-message" id="fullNameError">Please enter your full name</div>
                    </div>

                    <div class="form-group">
                        <label class="form-label">
                            <i class="fas fa-envelope"></i>
                            Email Address
                            <span class="required">*</span>
                        </label>
                        <input type="email" 
                               name="email" 
                               id="email" 
                               class="form-input" 
                               placeholder="example@email.com"
                               value="${sessionScope.user.email}"
                               maxlength="20"
                               required>
                        <div class="error-message" id="emailError">Please enter a valid email address</div>
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
                        
                        <div class="error-message" id="phoneError">Phone number must be 10-11 digits</div>
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
                               maxlength=" 40"
                               required>
                        <div class="error-message" id="addressError">Please enter your address</div>
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
                        <div class="error-message" id="dobError">Please select your date of birth</div>
                    </div>

                    <button type="submit" class="btn-submit" id="submitBtn">
                        <div class="spinner"></div>
                        <i class="fas fa-save"></i>
                        <span>Save Changes</span>
                    </button>
                </div>

                <!-- Avatar Section -->
                <div class="avatar-section">
                    <div class="avatar-wrapper">
                        <div class="avatar-preview" onclick="document.getElementById('avatarUpload').click()">
                            <c:choose>
                                <c:when test="${not empty sessionScope.user.avatar}">
                                    <!-- Avatar URL đã có format: avatar/filename.jpg -->
                                    <img src="${pageContext.request.contextPath}/${sessionScope.user.avatar}" 
                                         alt="Avatar"
                                         onerror="this.onerror=null; this.parentElement.innerHTML='<i class=\'fas fa-user\'></i>';">
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
                    </div>
                </div>
            </div>
        </form>
    </div>

    <script>
        // Preview avatar
        function previewAvatar(event) {
            const file = event.target.files[0];
            if (file) {
                // Validate file size (2MB = 2 * 1024 * 1024 bytes)
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

                const reader = new FileReader();
                reader.onload = function(e) {
                    const avatarPreview = document.querySelector('.avatar-preview');
                    avatarPreview.innerHTML = '<img src="' + e.target.result + '" alt="Avatar Preview">';
                }
                reader.readAsDataURL(file);
            }
        }

        // Show message
        function showMessage(type, message) {
            const messageBox = document.getElementById('messageBox');
            messageBox.className = 'message-box ' + type;
            messageBox.innerHTML = '<i class="fas fa-' + (type === 'success' ? 'check' : 'exclamation') + '-circle"></i> ' + message;
            
            // Auto hide after 5 seconds
            setTimeout(function() {
                messageBox.style.display = 'none';
            }, 5000);
        }

        // Validate email format
        function validateEmail(email) {
            const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            return re.test(email);
        }

        // Validate phone number
        function validatePhone(phone) {
            return /^[0-9]{10,11}$/.test(phone);
        }

        // Validate national ID
        function validateNationalId(id) {
            return /^[0-9]{9,12}$/.test(id);
        }

        // Validate date of birth (must be at least 18 years old)
        function validateDOB(dob) {
            const birthDate = new Date(dob);
            const today = new Date();
            const age = today.getFullYear() - birthDate.getFullYear();
            const monthDiff = today.getMonth() - birthDate.getMonth();
            
            if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
                return age - 1 >= 18;
            }
            return age >= 18;
        }

        // Show field error
        function showFieldError(fieldId, show) {
            if (show === undefined) show = true;
            
            const field = document.getElementById(fieldId);
            const error = document.getElementById(fieldId + 'Error');
            
            if (show) {
                field.classList.add('error');
                error.classList.add('show');
            } else {
                field.classList.remove('error');
                error.classList.remove('show');
            }
        }

        // Form validation
        document.getElementById('changeInfoForm').addEventListener('submit', function(e) {
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

            // Validate phone (if provided)
            const phone = document.getElementById('phone').value.trim();
            if (phone && !validatePhone(phone)) {
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
            if (!dob || !validateDOB(dob)) {
                showFieldError('dob');
                document.getElementById('dobError').textContent = 'You must be at least 18 years old';
                isValid = false;
            } else {
                showFieldError('dob', false);
            }

            if (isValid) {
                // Show loading state
                submitBtn.classList.add('loading');
                submitBtn.disabled = true;
                
                // Submit form
                this.submit();
            } else {
                showMessage('error', 'Please correct the errors in the form!');
            }
        });

        // Real-time validation
        document.getElementById('email').addEventListener('blur', function() {
            if (this.value && !validateEmail(this.value)) {
                showFieldError('email');
            } else {
                showFieldError('email', false);
            }
        });

        document.getElementById('phone').addEventListener('blur', function() {
            if (this.value && !validatePhone(this.value)) {
                showFieldError('phone');
            } else {
                showFieldError('phone', false);
            }
        });

        document.getElementById('nationalId').addEventListener('blur', function() {
            if (this.value && !validateNationalId(this.value)) {
                showFieldError('nationalId');
            } else {
                showFieldError('nationalId', false);
            }
        });

        document.getElementById('dob').addEventListener('change', function() {
            if (this.value && !validateDOB(this.value)) {
                showFieldError('dob');
                document.getElementById('dobError').textContent = 'You must be at least 18 years old';
            } else {
                showFieldError('dob', false);
            }
        });

        // Set max date for DOB (18 years ago from today)
        const dobInput = document.getElementById('dob');
        const today = new Date();
        const maxDate = new Date(today.getFullYear() - 18, today.getMonth(), today.getDate());
        dobInput.max = maxDate.toISOString().split('T')[0];
        
        // Auto-hide server messages after 5 seconds
        window.addEventListener('DOMContentLoaded', function() {
            const serverMessages = document.querySelectorAll('.message-box.success, .message-box.error');
            serverMessages.forEach(function(msg) {
                if (msg.style.display !== 'none') {
                    setTimeout(function() {
                        msg.style.display = 'none';
                    }, 5000);
                }
            });
        });
    </script>
</body>
</html>