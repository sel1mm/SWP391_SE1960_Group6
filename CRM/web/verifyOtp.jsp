<%@ page contentType="text/html;charset=UTF-8" %> 
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<html>
    <head>
        <title>CRMS - Xác minh OTP</title>
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
                position: relative;
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

            .btn-submit {
                background: linear-gradient(45deg, #3498db, #2980b9);
                border: none;
                border-radius: 15px;
                padding: 15px;
                color: white;
                font-weight: 600;
                font-size: 1.1rem;
                width: 100%;
                transition: all 0.3s ease;
                margin-top: 10px;
            }

            .btn-submit:disabled {
                opacity: 0.5;
                cursor: not-allowed;
            }

            .btn-resend {
                background: #ecf0f1;
                border: none;
                border-radius: 15px;
                padding: 12px;
                color: #2c3e50;
                font-weight: 600;
                font-size: 1rem;
                width: 100%;
                margin-top: 15px;
                transition: all 0.3s ease;
            }

            .btn-resend:hover:not(:disabled) {
                background: #d0d7de;
                transform: translateY(-2px);
            }

            .btn-resend:disabled {
                opacity: 0.6;
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

            #otpError {
                color: red;
                font-size: 0.9rem;
                margin-top: 5px;
                display: none;
            }
        </style>
    </head>
    <body>
        <a href="home" class="brand-logo">
            <i class="fas fa-laptop"></i>CRMS
        </a>

        <div class="login-container">
            <div class="login-header">
                <h2 class="login-title"><i class="fas fa-key"></i> Xác minh OTP</h2>
                <p class="login-subtitle">Nhập mã OTP đã được gửi đến email của bạn.</p>
            </div>

            <c:if test="${not empty error}">
                <div class="alert alert-danger alert-modern">
                    <i class="fas fa-exclamation-triangle"></i> ${error}
                </div>
            </c:if>

            <form method="post" action="verifyOtp">
                <div class="form-group">
                    <label for="otp" class="form-label-modern">
                        <i></i> Mã OTP
                    </label>
                    <div class="position-relative">
                        <i></i>
                        <input type="text" class="form-control form-control-modern" id="otp" name="otp"
                               placeholder="Nhập mã OTP gồm 6 chữ số" maxlength="6" required>
                        <div id="otpError">Mã OTP phải gồm 6 chữ số.</div>
                    </div>
                </div>

                <button type="submit" class="btn btn-submit" id="submitBtn" disabled>
                    <i class="fas fa-check-circle"></i> Xác nhận OTP
                </button>
            </form>

            <form method="post" action="resendOtp" id="resendForm">
                <button type="submit" class="btn btn-resend" id="resendBtn" disabled>
                    <i class="fas fa-paper-plane"></i> Gửi lại OTP (<span id="countdown">60</span>s)
                </button>
            </form>
        </div>

        <script>
            const otpInput = document.getElementById('otp');
            const submitBtn = document.getElementById('submitBtn');
            const otpError = document.getElementById('otpError');
            const otpPattern = /^[0-9]{6}$/;

            otpInput.addEventListener('input', function () {
                if (otpPattern.test(otpInput.value.trim())) {
                    submitBtn.disabled = false;
                    otpError.style.display = 'none';
                } else {
                    submitBtn.disabled = true;
                    otpError.style.display = otpInput.value.length > 0 ? 'block' : 'none';
                }
            });

            let countdown = 60;
            const countdownSpan = document.getElementById('countdown');
            const resendBtn = document.getElementById('resendBtn');

            function startCountdown() {
                resendBtn.disabled = true;
                const timer = setInterval(() => {
                    countdown--;
                    countdownSpan.textContent = countdown;
                    if (countdown <= 0) {
                        clearInterval(timer);
                        resendBtn.disabled = false;
                        resendBtn.textContent = "Gửi lại OTP";
                    }
                }, 1000);
            }

            window.onload = startCountdown;
            document.getElementById('resendForm').addEventListener('submit', function (e) {
                startCountdown();
            });
        </script>
    </body>
</html>
