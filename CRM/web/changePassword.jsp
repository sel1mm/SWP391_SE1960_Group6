<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Change Password - CRM System</title>

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
            max-width: 520px;
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
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
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

        .content {
            padding: 40px;
        }

        .step-indicator {
            display: flex;
            justify-content: center;
            gap: 12px;
            margin-bottom: 30px;
        }

        .step {
            width: 40px;
            height: 4px;
            background: #e2e8f0;
            border-radius: 2px;
            transition: all 0.3s ease;
        }

        .step.active {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }

        .form-group {
            margin-bottom: 24px;
            position: relative;
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
        }

        .password-input-wrapper {
            position: relative;
        }

        .form-input {
            width: 100%;
            padding: 14px 50px 14px 16px;
            border: 2px solid #e2e8f0;
            border-radius: 10px;
            font-size: 15px;
            font-family: 'Inter', sans-serif;
            transition: all 0.3s ease;
            background: white;
        }

        .form-input:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }

        .toggle-password {
            position: absolute;
            right: 16px;
            top: 50%;
            transform: translateY(-50%);
            cursor: pointer;
            color: #a0aec0;
            transition: color 0.3s ease;
        }

        .toggle-password:hover {
            color: #667eea;
        }

        .password-strength {
            margin-top: 8px;
            height: 4px;
            background: #e2e8f0;
            border-radius: 2px;
            overflow: hidden;
            display: none;
        }

        .password-strength-bar {
            height: 100%;
            width: 0%;
            transition: all 0.3s ease;
        }

        .strength-weak { background: #ef4444; width: 33%; }
        .strength-medium { background: #f59e0b; width: 66%; }
        .strength-strong { background: #10b981; width: 100%; }

        .password-requirements {
            margin-top: 12px;
            padding: 12px;
            background: #f7fafc;
            border-radius: 8px;
            font-size: 12px;
            display: none;
        }

        .password-requirements.show {
            display: block;
        }

        .requirement {
            display: flex;
            align-items: center;
            gap: 8px;
            color: #718096;
            margin-bottom: 6px;
        }

        .requirement:last-child {
            margin-bottom: 0;
        }

        .requirement.met {
            color: #10b981;
        }

        .requirement i {
            font-size: 10px;
        }

        .message-box {
            padding: 14px 16px;
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
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .message-box.error {
            background: #fee2e2;
            color: #991b1b;
            border: 1px solid #fca5a5;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .btn {
            width: 100%;
            padding: 14px 24px;
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
        }

        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
        }

        .btn-primary:hover:not(:disabled) {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(102, 126, 234, 0.5);
        }

        .btn-primary:disabled {
            opacity: 0.6;
            cursor: not-allowed;
            transform: none;
        }

        .form-section {
            display: none;
        }

        .form-section.active {
            display: block;
            animation: fadeIn 0.4s ease;
        }

        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateX(20px);
            }
            to {
                opacity: 1;
                transform: translateX(0);
            }
        }

        @media (max-width: 640px) {
            .content {
                padding: 30px 20px;
            }

            .header {
                padding: 25px 20px;
            }

            .header h1 {
                font-size: 24px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="header-content">
                <h1>
                    <i class="fas fa-lock"></i>
                    Change Password
                </h1>
                <p>Secure your account with a strong password</p>
            </div>
        </div>

        <div class="content">
            <div class="step-indicator">
                <div class="step active" id="step1"></div>
                <div class="step" id="step2"></div>
            </div>

            <div id="messageBox" class="message-box"></div>


            <form id="changePasswordForm" action="changePassword" method="POST">
                <!-- Keep hidden field OUTSIDE of sections so it's always sent -->
                <input type="hidden" name="hiddenCurrentPassword" id="hiddenCurrentPassword">

                <!-- Step 1: Current Password -->
                <div id="currentPasswordSection" class="form-section active">
                    <div class="form-group">
                        <label class="form-label">
                            <i class="fas fa-key"></i>
                            Current Password
                        </label>
                        <div class="password-input-wrapper">
                            <input type="password" 
                                   id="currentPassword"
                                   class="form-input" 
                                   placeholder="Enter your current password"
                                   required>
                            <i class="fas fa-eye toggle-password" onclick="togglePassword('currentPassword')"></i>
                        </div>
                    </div>

                    <button type="button" class="btn btn-primary" onclick="moveToStep2(event)">
                        <i class="fas fa-arrow-right"></i>
                        Continue to New Password
                    </button>
                </div>

                <!-- Step 2: New Password -->
                <div id="newPasswordSection" class="form-section">
                    <div class="form-group">
                        <label class="form-label">
                            <i class="fas fa-lock"></i>
                            New Password
                        </label>
                        <div class="password-input-wrapper">
                            <input type="password" 
                                   name="newPassword" 
                                   id="newPassword"
                                   class="form-input" 
                                   placeholder="Enter new password"
                                   oninput="checkPasswordStrength()"
                                   required>
                            <i class="fas fa-eye toggle-password" onclick="togglePassword('newPassword')"></i>
                        </div>
                        <div class="password-strength" id="strengthContainer">
                            <div class="password-strength-bar" id="strengthBar"></div>
                        </div>
                        <div class="password-requirements" id="requirements">
                            <div class="requirement" id="req-length">
                                <i class="fas fa-circle"></i>
                                <span>At least 8 characters</span>
                            </div>
                            <div class="requirement" id="req-uppercase">
                                <i class="fas fa-circle"></i>
                                <span>One uppercase letter</span>
                            </div>
                            <div class="requirement" id="req-lowercase">
                                <i class="fas fa-circle"></i>
                                <span>One lowercase letter</span>
                            </div>
                            <div class="requirement" id="req-number">
                                <i class="fas fa-circle"></i>
                                <span>One number</span>
                            </div>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label">
                            <i class="fas fa-check-circle"></i>
                            Confirm New Password
                        </label>
                        <div class="password-input-wrapper">
                            <input type="password" 
                                   name="renewPassword" 
                                   id="renewPassword"
                                   class="form-input" 
                                   placeholder="Re-enter new password"
                                   required>
                            <i class="fas fa-eye toggle-password" onclick="togglePassword('renewPassword')"></i>
                        </div>
                    </div>

                    <button type="submit" class="btn btn-primary" id="savePasswordBtn">
                        <i class="fas fa-save"></i>
                        Save New Password
                    </button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function togglePassword(inputId) {
            const input = document.getElementById(inputId);
            const icon = input.nextElementSibling;


            if (input.type === 'password') {
                input.type = 'text';
                icon.classList.remove('fa-eye');
                icon.classList.add('fa-eye-slash');
            } else {
                input.type = 'password';
                icon.classList.remove('fa-eye-slash');
                icon.classList.add('fa-eye');
            }
        }


        function moveToStep2(event) {
            if (event) event.preventDefault();
            
            const currentPassword = document.getElementById('currentPassword').value;
            const continueBtn = document.querySelector('#currentPasswordSection .btn-primary');

            if (!currentPassword) {
                showMessage('Please enter your current password', 'error');
                return;
            }

            continueBtn.disabled = true;
            const originalHTML = continueBtn.innerHTML;
            continueBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Verifying...';

            // Use URLSearchParams for proper form encoding
            const params = new URLSearchParams();
            params.append('currentPassword', currentPassword);
            params.append('action', 'verify');

            fetch('changePassword', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: params.toString()
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    document.getElementById('hiddenCurrentPassword').value = currentPassword;
                    document.getElementById('step2').classList.add('active');
                    document.getElementById('currentPasswordSection').classList.remove('active');
                    document.getElementById('newPasswordSection').classList.add('active');
                    showMessage('Password verified successfully', 'success');
                } else {
                    showMessage(data.message || 'Current password is incorrect', 'error');
                }

                continueBtn.disabled = false;
                continueBtn.innerHTML = originalHTML;
            })
            .catch(error => {
                console.error('Error:', error);
                showMessage('An error occurred. Please try again.', 'error');
                continueBtn.disabled = false;
                continueBtn.innerHTML = originalHTML;
            });
        }

        function checkPasswordStrength() {
            const password = document.getElementById('newPassword').value;
            const strengthBar = document.getElementById('strengthBar');
            const strengthContainer = document.getElementById('strengthContainer');
            const requirements = document.getElementById('requirements');

            if (password.length > 0) {
                strengthContainer.style.display = 'block';
                requirements.classList.add('show');
            } else {
                strengthContainer.style.display = 'none';
                requirements.classList.remove('show');
                return;
            }

            const hasLength = password.length >= 8;
            const hasUppercase = /[A-Z]/.test(password);
            const hasLowercase = /[a-z]/.test(password);
            const hasNumber = /[0-9]/.test(password);

            updateRequirement('req-length', hasLength);
            updateRequirement('req-uppercase', hasUppercase);
            updateRequirement('req-lowercase', hasLowercase);
            updateRequirement('req-number', hasNumber);

            let strength = 0;
            if (hasLength) strength++;
            if (hasUppercase) strength++;
            if (hasLowercase) strength++;
            if (hasNumber) strength++;

            strengthBar.className = 'password-strength-bar';
            if (strength <= 2) {
                strengthBar.classList.add('strength-weak');
            } else if (strength === 3) {
                strengthBar.classList.add('strength-medium');
            } else {
                strengthBar.classList.add('strength-strong');
            }
        }

        function updateRequirement(id, met) {
            const element = document.getElementById(id);
            if (met) {
                element.classList.add('met');
                element.querySelector('i').className = 'fas fa-check-circle';
            } else {
                element.classList.remove('met');
                element.querySelector('i').className = 'fas fa-circle';
            }
        }

        function showMessage(message, type) {
            const messageBox = document.getElementById('messageBox');
            messageBox.className = 'message-box ' + type;
            messageBox.style.display = 'flex';

            const icon = type === 'success' ? 'fa-check-circle' : 'fa-exclamation-circle';
            messageBox.innerHTML = '<i class="fas ' + icon + '"></i><span>' + message + '</span>';

            setTimeout(function() {
                messageBox.style.display = 'none';
            }, 5000);
        }

        function validatePassword(password) {
            const hasLength = password.length >= 8;
            const hasUppercase = /[A-Z]/.test(password);
            const hasLowercase = /[a-z]/.test(password);
            const hasNumber = /[0-9]/.test(password);

            return hasLength && hasUppercase && hasLowercase && hasNumber;
        }

        document.getElementById('changePasswordForm').addEventListener('submit', function(e) {
            e.preventDefault();

            const currentPassword = document.getElementById('hiddenCurrentPassword').value;
            const newPassword = document.getElementById('newPassword').value;
            const renewPassword = document.getElementById('renewPassword').value;

            console.log('=== DEBUG BEFORE SUBMIT ===');
            console.log('hiddenCurrentPassword value:', currentPassword);
            console.log('newPassword value:', newPassword);
            console.log('renewPassword value:', renewPassword);

            if (!currentPassword) {
                showMessage('Please verify your current password first', 'error');
                return;
            }

            if (!newPassword || !renewPassword) {
                showMessage('Please fill in all password fields', 'error');
                return;
            }

            if (!validatePassword(newPassword)) {
                showMessage('Password does not meet requirements', 'error');
                return;
            }

            if (newPassword !== renewPassword) {
                showMessage('Passwords do not match', 'error');
                return;
            }

            if (newPassword === currentPassword) {
                showMessage('New password must be different from current password', 'error');
                return;
            }

            const saveBtn = document.getElementById('savePasswordBtn');
            saveBtn.disabled = true;
            saveBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Saving...';

            // Use URLSearchParams instead of FormData to send as application/x-www-form-urlencoded
            const params = new URLSearchParams();
            params.append('hiddenCurrentPassword', currentPassword);
            params.append('newPassword', newPassword);
            params.append('renewPassword', renewPassword);

            console.log('=== Sending via AJAX ===');
            console.log('Params:', params.toString());

            fetch('changePassword', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: params.toString()
            })
            .then(response => {
                console.log('Response status:', response.status);
                console.log('Response type:', response.headers.get('content-type'));
                
                // Check if response is redirect
                if (response.redirected) {
                    window.location.href = response.url;
                    return;
                }
                
                // Check if HTML response (error page)
                const contentType = response.headers.get('content-type');
                if (contentType && contentType.includes('text/html')) {
                    return response.text();
                }
                
                return response.json();
            })
            .then(data => {
                if (typeof data === 'string') {
                    // It's HTML - show the error page
                    document.open();
                    document.write(data);
                    document.close();
                } else if (data && data.success) {
                    // Success - redirect
                    window.location.href = 'manageProfile';
                } else if (data && data.message) {
                    showMessage(data.message, 'error');
                    saveBtn.disabled = false;
                    saveBtn.innerHTML = '<i class="fas fa-save"></i> Save New Password';
                }
            })
            .catch(error => {
                console.error('Error:', error);
                showMessage('An error occurred. Please try again.', 'error');
                saveBtn.disabled = false;
                saveBtn.innerHTML = '<i class="fas fa-save"></i> Save New Password';
            });
        });

        document.querySelectorAll('.form-input').forEach(function(input) {
            input.addEventListener('input', function() {
                const messageBox = document.getElementById('messageBox');
                if (messageBox.classList.contains('error')) {
                    messageBox.style.display = 'none';
                }
            });
        });

        window.addEventListener('DOMContentLoaded', function() {
            <c:if test="${not empty errorMessage}">
                showMessage('${errorMessage}', 'error');
                <c:if test="${not empty param.newPassword}">
                    document.getElementById('step2').classList.add('active');
                    document.getElementById('currentPasswordSection').classList.remove('active');
                    document.getElementById('newPasswordSection').classList.add('active');
                </c:if>
            </c:if>

            <c:if test="${not empty sessionScope.successMessage}">
                showMessage('${sessionScope.successMessage}', 'success');
                <c:remove var="successMessage" scope="session"/>
            </c:if>
        });
    </script>

</body>
</html>