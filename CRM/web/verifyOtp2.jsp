<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Verify Email - OTP</title>
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
            0%, 100% { transform: translateY(0px); }
            50% { transform: translateY(-20px); }
        }

        .otp-container {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            width: 100%;
            max-width: 450px;
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

        .otp-header {
            background: linear-gradient(135deg, #212529 0%, #343a40 100%);
            padding: 35px 40px;
            color: white;
            text-align: center;
            position: relative;
            overflow: hidden;
        }

        .otp-header::before {
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

        .otp-header-content {
            position: relative;
            z-index: 2;
        }

        .otp-header i {
            font-size: 48px;
            margin-bottom: 15px;
            display: block;
        }

        .otp-header h2 {
            font-size: 24px;
            font-weight: 700;
            margin-bottom: 10px;
        }

        .otp-header p {
            font-size: 14px;
            opacity: 0.9;
            line-height: 1.5;
        }

        .otp-header strong {
            color: #fff;
            font-weight: 600;
        }

        .otp-body {
            padding: 40px;
            background: #fafbfc;
        }

        .message {
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

        .message.error {
            background: #fee2e2;
            color: #991b1b;
            border: 1px solid #fca5a5;
            display: flex;
        }

        .message.success {
            background: #d1fae5;
            color: #065f46;
            border: 1px solid #6ee7b7;
            display: flex;
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
            margin-bottom: 12px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .form-label i {
            color: #212529;
            font-size: 16px;
        }

        .otp-input {
            width: 100%;
            padding: 16px 20px;
            border: 2px solid #e2e8f0;
            border-radius: 10px;
            font-size: 24px;
            text-align: center;
            letter-spacing: 8px;
            font-weight: 600;
            font-family: 'Courier New', monospace;
            transition: all 0.3s ease;
            background: white;
        }

        .otp-input:focus {
            outline: none;
            border-color: #212529;
            box-shadow: 0 0 0 3px rgba(33, 37, 41, 0.1);
        }

        .otp-input::placeholder {
            font-size: 14px;
            letter-spacing: normal;
            font-family: 'Inter', sans-serif;
        }

        .otp-info {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 12px;
            color: #718096;
            margin-top: 8px;
        }

        .otp-info i {
            color: #212529;
        }

        .btn-verify {
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
            margin-bottom: 15px;
        }

        .btn-verify:hover:not(:disabled) {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(33, 37, 41, 0.5);
        }

        .btn-verify:disabled {
            opacity: 0.6;
            cursor: not-allowed;
        }

        .btn-verify .spinner {
            width: 16px;
            height: 16px;
            border: 2px solid rgba(255, 255, 255, 0.3);
            border-top-color: white;
            border-radius: 50%;
            animation: spin 0.6s linear infinite;
            display: none;
        }

        .btn-verify.loading .spinner {
            display: block;
        }

        @keyframes spin {
            to { transform: rotate(360deg); }
        }

        .resend-section {
            text-align: center;
            padding-top: 15px;
            border-top: 1px solid #e2e8f0;
        }

        .resend-text {
            font-size: 13px;
            color: #718096;
            margin-bottom: 10px;
        }

        .btn-resend {
            background: white;
            color: #212529;
            border: 2px solid #212529;
            padding: 10px 20px;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        .btn-resend:hover:not(:disabled) {
            background: #212529;
            color: white;
            transform: translateY(-2px);
        }

        .btn-resend:disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }

        .timer {
            display: inline-block;
            font-weight: 600;
            color: #212529;
        }

        .back-link {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            color: #718096;
            text-decoration: none;
            font-size: 14px;
            margin-top: 15px;
            transition: color 0.3s ease;
        }

        .back-link:hover {
            color: #212529;
        }

        @media (max-width: 640px) {
            .otp-container {
                margin: 20px;
            }

            .otp-header {
                padding: 25px 20px;
            }

            .otp-body {
                padding: 30px 20px;
            }

            .otp-header h2 {
                font-size: 20px;
            }

            .otp-input {
                font-size: 20px;
                letter-spacing: 6px;
            }
        }
    </style>
</head>
<body>
    <div class="otp-container">
        <div class="otp-header">
            <div class="otp-header-content">
                <i class="fas fa-shield-alt"></i>
                <h2>Verify Your Email</h2>
                <p>We've sent a 6-digit verification code to<br>
                <strong>${sessionScope.pendingNewEmail}</strong></p>
            </div>
        </div>

        <div class="otp-body">
            <!-- Display messages -->
            <c:if test="${not empty error}">
                <div class="message error">
                    <i class="fas fa-exclamation-circle"></i>
                    <span>${error}</span>
                </div>
            </c:if>

            <c:if test="${not empty success}">
                <div class="message success">
                    <i class="fas fa-check-circle"></i>
                    <span>${success}</span>
                </div>
            </c:if>

            <!-- OTP Form -->
            <form id="otpForm" action="verifyOtp" method="post">
                <div class="form-group">
                    <label class="form-label">
                        <i class="fas fa-key"></i>
                        Verification Code
                    </label>
                    <input type="text" 
                           name="otpInput" 
                           id="otpInput"
                           class="otp-input" 
                           maxlength="6"
                           placeholder="000000" 
                           pattern="[0-9]{6}"
                           autocomplete="off"
                           required>
                    <div class="otp-info">
                        <i class="fas fa-clock"></i>
                        <span>Code expires in <span id="countdown" class="timer">5:00</span></span>
                    </div>
                </div>

                <button type="submit" class="btn-verify" id="verifyBtn">
                    <div class="spinner"></div>
                    <i class="fas fa-check"></i>
                    <span>Verify Code</span>
                </button>
            </form>

            <!-- Resend Section -->
            <div class="resend-section">
                <p class="resend-text">Didn't receive the code?</p>
                <form action="resendOtp" method="post" style="display: inline;">
                    <button type="submit" class="btn-resend" id="resendBtn">
                        <i class="fas fa-redo"></i>
                        <span>Resend OTP</span>
                    </button>
                </form>
                <br>
                <a href="changeInformation" class="back-link">
                    <i class="fas fa-arrow-left"></i>
                    Back to Change Information
                </a>
            </div>
        </div>
    </div>

    <script>
        // Countdown timer (5 minutes)
        let timeLeft = 5 * 60; // 5 minutes in seconds
        const countdownElement = document.getElementById('countdown');
        const resendBtn = document.getElementById('resendBtn');

        function updateCountdown() {
            const minutes = Math.floor(timeLeft / 60);
            const seconds = timeLeft % 60;
            countdownElement.textContent = minutes + ':' + (seconds < 10 ? '0' : '') + seconds;

            if (timeLeft <= 0) {
                countdownElement.textContent = '0:00';
                countdownElement.style.color = '#e53e3e';
                resendBtn.disabled = false;
                showMessage('error', 'OTP has expired. Please request a new one.');
                return;
            }

            if (timeLeft <= 60) {
                countdownElement.style.color = '#e53e3e';
            }

            timeLeft--;
            setTimeout(updateCountdown, 1000);
        }

        // Start countdown
        updateCountdown();

        // Auto-focus on OTP input
        document.getElementById('otpInput').focus();

        // Only allow numbers
        document.getElementById('otpInput').addEventListener('input', function(e) {
            this.value = this.value.replace(/[^0-9]/g, '');
        });

        // Form submission
        document.getElementById('otpForm').addEventListener('submit', function(e) {
            const otpInput = document.getElementById('otpInput').value;
            const verifyBtn = document.getElementById('verifyBtn');

            if (otpInput.length !== 6) {
                e.preventDefault();
                showMessage('error', 'Please enter a valid 6-digit code.');
                return;
            }

            verifyBtn.classList.add('loading');
            verifyBtn.disabled = true;
        });

        // Show message function
        function showMessage(type, message) {
            const existingMessages = document.querySelectorAll('.message');
            existingMessages.forEach(msg => msg.remove());

            const messageDiv = document.createElement('div');
            messageDiv.className = 'message ' + type;
            messageDiv.innerHTML = '<i class="fas fa-' + (type === 'success' ? 'check' : 'exclamation') + '-circle"></i><span>' + message + '</span>';
            
            const otpBody = document.querySelector('.otp-body');
            otpBody.insertBefore(messageDiv, otpBody.firstChild);

            setTimeout(function() {
                messageDiv.style.display = 'none';
            }, 5000);
        }

        // Auto-hide server messages
        window.addEventListener('DOMContentLoaded', function() {
            const serverMessages = document.querySelectorAll('.message.success, .message.error');
            serverMessages.forEach(function(msg) {
                setTimeout(function() {
                    msg.style.display = 'none';
                }, 5000);
            });
        });

        // Disable resend button initially
        resendBtn.disabled = true;
        setTimeout(function() {
            resendBtn.disabled = false;
        }, 30000); // Enable after 30 seconds
    </script>
</body>
</html>