<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<html>
    <head>
        <title>CRMS - Quên mật khẩu</title>
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
            }

            .login-container {
                background: rgba(255,255,255,0.95);
                border-radius: 20px;
                padding: 40px;
                box-shadow: 0 15px 35px rgba(0,0,0,0.1);
                width: 100%;
                max-width: 450px;
                backdrop-filter: blur(10px);
            }

            .login-header {
                text-align: center;
                margin-bottom: 40px;
            }

            .login-title {
                color: #2c3e50;
                font-weight: bold;
                font-size: 2rem;
                margin-bottom: 10px;
            }

            .login-title i {
                color: #3498db;
                margin-right: 15px;
            }

            .login-subtitle {
                color: #7f8c8d;
                font-size: 1rem;
            }

            .form-group {
                position: relative;
                margin-bottom: 25px;
            }

            .form-control-modern {
                border: 2px solid #ecf0f1;
                border-radius: 15px;
                padding: 15px 20px 15px 50px;
                font-size: 1rem;
                transition: all 0.3s ease;
                background: rgba(255,255,255,0.9);
            }

            .form-control-modern:focus {
                border-color: #3498db;
                box-shadow: 0 0 0 3px rgba(52,152,219,0.1);
                background: white;
            }

            .input-icon {
                position: absolute;
                left: 18px;
                top: 50%;
                transform: translateY(-50%);
                color: #7f8c8d;
                font-size: 1.1rem;
                z-index: 5;
            }

            .form-label-modern {
                color: #2c3e50;
                font-weight: 600;
                margin-bottom: 8px;
                font-size: 0.95rem;
            }

            .btn-login {
                background: linear-gradient(45deg, #3498db, #2980b9);
                border: none;
                border-radius: 15px;
                padding: 15px;
                color: white;
                font-weight: 600;
                font-size: 1.1rem;
                width: 100%;
                transition: all 0.3s ease;
                margin-bottom: 20px;
            }

            .btn-login:hover {
                background: linear-gradient(45deg, #2980b9, #21618c);
                transform: translateY(-2px);
                box-shadow: 0 8px 25px rgba(52,152,219,0.3);
                color: white;
            }

            .btn-login:disabled {
                background: #bdc3c7;
                cursor: not-allowed;
            }

            .alert-modern {
                border-radius: 15px;
                border: none;
                padding: 15px 20px;
                margin-bottom: 25px;
                box-shadow: 0 5px 15px rgba(231,76,60,0.1);
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

            .error-message {
                color: #e74c3c;
                font-size: 0.9rem;
                margin-top: 5px;
                display: none;
            }
        </style>
    </head>
    <body>
        <a href="home.jsp" class="brand-logo">
            <i class="fas fa-laptop"></i>CRMS
        </a>

        <div class="login-container">
            <div class="login-header">
                <h2 class="login-title"><i class="fas fa-key"></i> Quên mật khẩu</h2>
                <p class="login-subtitle">Nhập địa chỉ email đã đăng ký để nhận mã OTP.</p>
            </div>

            <c:if test="${not empty error}">
                <div class="alert alert-danger alert-modern">
                    <i class="fas fa-exclamation-triangle"></i> ${error}
                </div>
            </c:if>

            <form method="post" action="forgotPassword" id="forgotForm">
                <div class="form-group">
                    <label for="email" class="form-label-modern">
                        <i class="fas fa-envelope"></i> Email
                    </label>
                    <div class="position-relative">
                        <i class=""></i>
                        <input type="email" class="form-control form-control-modern" id="email" name="email"
                               placeholder="Nhập email đăng ký" required>
                        <div id="emailError" class="error-message">Email không hợp lệ. Vui lòng nhập đúng định dạng <br> Ví dụ: example@domain.com</div>
                    </div>
                </div>

                <button type="submit" id="sendBtn" class="btn btn-login" disabled>
                    <i class="fas fa-paper-plane"></i> Gửi mã OTP
                </button>
            </form>
        </div>

        <script>
            const emailInput = document.getElementById('email');
            const sendBtn = document.getElementById('sendBtn');
            const emailError = document.getElementById('emailError');
            const emailPattern = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;

            emailInput.addEventListener('input', function () {
                const email = emailInput.value.trim();

                if (emailPattern.test(email)) {
                    emailError.style.display = 'none';
                    sendBtn.disabled = false;
                } else {
                    emailError.style.display = email.length > 0 ? 'block' : 'none';
                    sendBtn.disabled = true;
                }
            });
        </script>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
