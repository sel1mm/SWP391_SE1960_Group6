<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
    <head>
        <title>CRMS - Register</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
        <style>
            body {
                background: #ffffff;
                min-height: 100vh;
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                display: flex;
                align-items: center;
                justify-content: center;
                padding: 20px;
                overflow: hidden;
            }

            .register-container {
                background: rgba(255,255,255,0.95);
                border-radius: 20px;
                padding: 30px;
                box-shadow: 0 15px 35px rgba(0,0,0,0.1);
                width: 100%;
                max-width: 450px;
                backdrop-filter: blur(10px);
                max-height: 90vh;
                overflow-y: auto;
                scrollbar-width: thin;
            }

            .register-header {
                text-align: center;
                margin-bottom: 30px;
            }

            .register-title {
                color: #2c3e50;
                font-weight: bold;
                font-size: 2rem;
                margin-bottom: 10px;
            }

            .register-title i {
                color: #27ae60;
                margin-right: 15px;
            }

            .register-subtitle {
                color: #7f8c8d;
                font-size: 1rem;
            }

            .form-group {
                margin-bottom: 15px;
            }

            .form-control-modern {
                border: 2px solid #ecf0f1;
                border-radius: 12px;
                padding: 10px 15px;
                font-size: 0.95rem;
                background: rgba(255,255,255,0.9);
            }

            .form-control-modern:focus {
                border-color: #27ae60;
                box-shadow: 0 0 0 3px rgba(39,174,96,0.1);
                background: white;
            }

            .form-label-modern {
                color: #2c3e50;
                font-weight: 600;
                margin-bottom: 6px;
                font-size: 0.95rem;
                display: flex;
                align-items: center;
            }

            .required-star {
                color: red;
                margin-left: 4px;
            }

            .btn-register {
                background: linear-gradient(45deg, #27ae60, #2ecc71);
                border: none;
                border-radius: 15px;
                padding: 12px;
                color: white;
                font-weight: 600;
                font-size: 1rem;
                width: 100%;
                transition: all 0.3s ease;
                margin-bottom: 20px;
            }

            .btn-register:hover {
                background: linear-gradient(45deg, #229954, #27ae60);
                box-shadow: 0 8px 25px rgba(39,174,96,0.3);
                color: white;
            }

            .btn-login-link {
                background: linear-gradient(45deg, #3498db, #2980b9);
                border: none;
                border-radius: 15px;
                padding: 12px;
                color: white;
                font-weight: 500;
                width: 100%;
                transition: all 0.3s ease;
            }

            .btn-login-link:hover {
                background: linear-gradient(45deg, #2980b9, #21618c);
                box-shadow: 0 8px 25px rgba(52,152,219,0.3);
            }

            .divider {
                text-align: center;
                margin: 15px 0;
                color: #7f8c8d;
                position: relative;
            }

            .divider::before {
                content: '';
                position: absolute;
                top: 50%;
                left: 0;
                right: 0;
                height: 1px;
                background: linear-gradient(90deg, transparent, #bdc3c7, transparent);
            }

            .divider span {
                background: rgba(255,255,255,0.95);
                padding: 0 15px;
                font-size: 0.9rem;
            }

            .error-message {
                color: red;
                font-size: 0.85rem;
                display: none;
                margin-top: 5px;
            }

            .brand-logo {
                position: absolute;
                top: 20px;
                left: 20px;
                color: black;
                text-decoration: none;
                font-weight: bold;
                font-size: 1.2rem;
                transition: all 0.3s ease;
            }

            .brand-logo:hover {
                color: #f39c12;
                text-decoration: none;
            }

            .brand-logo i {
                margin-right: 8px;
            }
        </style>
    </head>
    <body>
        <a href="home" class="brand-logo">
            <i class="fas fa-laptop"></i>CRMS
        </a>

        <div class="register-container">
            <div class="register-header">
                <h2 class="register-title">
                    <i class="fas fa-user-plus"></i>Đăng ký
                </h2>
                <p class="register-subtitle">Tạo tài khoản mới để bắt đầu với CRMS.</p>
            </div>

            <c:if test="${not empty error}">
                <div class="alert alert-danger">
                    <i class="fas fa-exclamation-triangle"></i> ${error}
                </div>
            </c:if>

            <form id="registerForm" action="register" method="POST" onsubmit="return validateForm()">
                <div class="form-group">
                    <label for="fullName" class="form-label-modern">Họ và tên <span class="required-star">*</span></label>
                    <input type="text" id="fullName" name="fullName" class="form-control form-control-modern"
                           placeholder="Nhập họ và tên đầy đủ" required maxlength="100"
                           pattern="^[A-Za-zÀ-ỹ\s]{2,50}$"
                           title="Họ và tên chỉ được chứa chữ cái và khoảng trắng, độ dài 2-50 ký tự">
                    <div id="fullNameError" class="error-message">Họ và tên không hợp lệ</div>
                </div>

                <div class="form-group">
                    <label for="email" class="form-label-modern">Email <span class="required-star">*</span></label>
                    <input type="email" id="email" name="email" class="form-control form-control-modern"
                           required pattern="[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$" maxlength="100"
                           placeholder="example@domain.com"
                           title="Email không đúng định dạng">
                    <div id="emailError" class="error-message">Email phải có định dạng: example@domain.com</div>
                </div>

                <div class="form-group">
                    <label class="form-label-modern">Số điện thoại <span class="required-star">*</span></label>
                    <input type="tel" id="phoneNumber" name="phoneNumber" class="form-control form-control-modern"
                           placeholder="Nhập số điện thoại" required maxlength="10"
                           pattern="(03|05|07|08|09)[0-9]{8}"
                           title="Số điện thoại phải bắt đầu bằng 03, 05, 07, 08 hoặc 09 và có đúng 10 chữ số">
                    <div id="phoneError" class="error-message">Số điện thoại không hợp lệ</div>
                </div>

                <div class="form-group">
                    <label for="username" class="form-label-modern">Tên đăng nhập <span class="required-star">*</span></label>
                    <input type="text" id="username" name="username" class="form-control form-control-modern"
                           required minlength="1" maxlength="20"
                           pattern="^[A-Za-z0-9]+$"
                           placeholder="Tên đăng nhập"
                           title="Tên đăng nhập chỉ được chứa chữ cái và số (tối đa 20 ký tự)">
                    <div id="usernameError" class="error-message">Tên đăng nhập chỉ được chứa chữ cái và số (tối đa 20 ký tự)</div>
                </div>

                <div class="form-group">
                    <label for="password" class="form-label-modern">Mật khẩu <span class="required-star">*</span></label>
                    <input type="password" id="password" name="password"
                           class="form-control form-control-modern"
                           placeholder="Nhập mật khẩu"
                           required minlength="6" maxlength="30"
                           pattern="^(?=.*[A-Za-z0-9])[A-Za-z0-9!@#$%^&*()_+=-]{6,30}$"
                           title="Mật khẩu không được có khoảng trắng.">
                </div>

                <div class="form-group">
                    <label for="confirm-password" class="form-label-modern">Nhập lại mật khẩu <span class="required-star">*</span></label>
                    <input type="password" id="confirm-password" name="confirm-password"
                           class="form-control form-control-modern"
                           placeholder="Xác nhận lại mật khẩu"
                           required minlength="6" maxlength="30">
                    <div id="passwordError" class="error-message">Mật khẩu không khớp</div>
                </div>

                <div class="form-group form-check mt-3 mb-4">
                    <input type="checkbox" class="form-check-input" id="termsCheckbox" required>
                    <label class="form-check-label" for="termsCheckbox">
                        Việc đăng ký tài khoản đồng nghĩa với việc bạn đã đọc và đồng ý với 
                        <a href="#" target="_blank">Điều khoản & Dịch vụ</a> của chúng tôi.
                    </label>
                </div>

                <button type="submit" class="btn btn-register" id="submitBtn" disabled>
                    <i class="fas fa-user-plus"></i> Tạo tài khoản
                </button>

                <div class="divider"><span>Đã có tài khoản?</span></div>
                <a href="login.jsp" class="btn btn-login-link">
                    <i class="fas fa-sign-in-alt"></i> Đăng nhập ngay
                </a>
            </form>
        </div>

        <script>
            const form = document.getElementById('registerForm');
            const fullNameInput = document.getElementById('fullName');
            const emailInput = document.getElementById('email');
            const usernameInput = document.getElementById('username');
            const passwordInput = document.getElementById('password');
            const confirmPasswordInput = document.getElementById('confirm-password');
            const phoneInput = document.getElementById('phoneNumber');

            const fullNameError = document.getElementById('fullNameError');
            const phoneError = document.getElementById('phoneError');
            const emailError = document.getElementById('emailError');
            const usernameError = document.getElementById('usernameError');
            const passwordError = document.getElementById('passwordError');
            const submitBtn = document.getElementById('submitBtn');

            const fullNamePattern = /^[A-Za-zÀ-ỹ\s]{2,50}$/;
            const emailPattern = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
            const usernamePattern = /^[a-zA-Z0-9]+$/;
            const phonePattern = /^(03|05|07|08|09)[0-9]{8}$/;

            fullNameInput.addEventListener('blur', validateFullName);
            emailInput.addEventListener('blur', validateEmail);
            usernameInput.addEventListener('blur', validateUsername);
            confirmPasswordInput.addEventListener('blur', validatePasswordMatch);
            phoneInput.addEventListener('blur', validatePhoneNumber);
            passwordInput.addEventListener('blur', validatePasswordMatch);

            fullNameInput.addEventListener('input', hideError(fullNameError));
            emailInput.addEventListener('input', hideError(emailError));
            usernameInput.addEventListener('input', hideError(usernameError));
            phoneInput.addEventListener('input', hideError(phoneError));
            passwordInput.addEventListener('input', hideError(passwordError));
            confirmPasswordInput.addEventListener('input', hideError(passwordError));

            function hideError(errorElement) {
                return function () {
                    errorElement.style.display = 'none';
                };
            }

            function validateFullName() {
                if (!fullNamePattern.test(fullNameInput.value.trim())) {
                    fullNameError.style.display = 'block';
                    return false;
                }
                return true;
            }

            function validatePhoneNumber() {
                if (!phonePattern.test(phoneInput.value.trim())) {
                    phoneError.style.display = 'block';
                    return false;
                }
                return true;
            }

            function validateEmail() {
                if (!emailPattern.test(emailInput.value.trim())) {
                    emailError.style.display = 'block';
                    return false;
                }
                return true;
            }

            function validateUsername() {
                if (!usernamePattern.test(usernameInput.value.trim())) {
                    usernameError.style.display = 'block';
                    return false;
                }
                return true;
            }

            function validatePasswordMatch() {
                if (passwordInput.value !== confirmPasswordInput.value) {
                    passwordError.style.display = 'block';
                    return false;
                }
                return true;
            }

            form.addEventListener('submit', function (e) {
                const isValid = validateFullName() &&
                        validatePhoneNumber() &&
                        validateEmail() &&
                        validateUsername() &&
                        validatePasswordMatch();
                if (!isValid) {
                    e.preventDefault();
                }
            });

            const termsCheckbox = document.getElementById('termsCheckbox');
            termsCheckbox.addEventListener('change', function () {
                submitBtn.disabled = !this.checked;
            });
        </script>

    </body>
</html>
