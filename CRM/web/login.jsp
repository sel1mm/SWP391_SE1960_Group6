<%@page contentType="text/html;charset=UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page import="jakarta.servlet.http.Cookie" %>
<%
    String usernameCookieSaved = "";
    String passwordCookieSaved = "";
    Cookie[] cookieListFromBrowser = request.getCookies();

    if (cookieListFromBrowser != null) {
        for (Cookie cookie : cookieListFromBrowser) {
            if (cookie.getName().equals("COOKIE_USERNAME")) {
                usernameCookieSaved = cookie.getValue();
            }
            if (cookie.getName().equals("COOKIE_PASSWORD")) {
                passwordCookieSaved = cookie.getValue();
            }
        }
    }
%>
<html>
    <head>
        <title>CRM</title>
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

            .btn-register {
                background: linear-gradient(45deg, #95a5a6, #7f8c8d);
                border: none;
                border-radius: 15px;
                padding: 12px;
                color: white;
                font-weight: 500;
                width: 100%;
                transition: all 0.3s ease;
            }

            .btn-register:hover {
                background: linear-gradient(45deg, #7f8c8d, #707b7c);
                transform: translateY(-2px);
                box-shadow: 0 8px 25px rgba(149,165,166,0.3);
                color: white;
            }

            .btn-google {
                background: #db4437;
                border: none;
                border-radius: 15px;
                padding: 12px;
                color: white;
                font-weight: 600;
                width: 100%;
                transition: all 0.3s ease;
            }

            .btn-google:hover {
                background: #c23321;
                transform: translateY(-2px);
                box-shadow: 0 8px 25px rgba(219, 68, 55, 0.3);
                color: white;
            }

            .divider {
                text-align: center;
                margin: 20px 0;
                position: relative;
            }

            .divider::before,
            .divider::after {
                content: "";
                position: absolute;
                top: 50%;
                width: 40%;
                height: 1px;
                background: #ccc;
            }

            .divider::before {
                left: 0;
            }

            .divider::after {
                right: 0;
            }

            .divider span {
                background: #fff;
                padding: 0 10px;
                font-weight: 600;
                color: #7f8c8d;
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

            .form-label-modern.required::after {
                content: " *";
                color: red;
                font-weight: bold;
            }
        </style>
    </head>
    <body>
        <a href="home" class="brand-logo">
            <i class="fas fa-laptop"></i>CRMS
        </a>

        <div class="login-container">
            <div class="login-header">
                <h2 class="login-title"><i class="fas fa-sign-in-alt"></i>Đăng nhập</h2>
                <p class="login-subtitle">Chào mừng trở lại! Vui lòng đăng nhập vào tài khoản của bạn.</p>
            </div>

            <c:if test="${not empty error}">
                <div class="alert alert-danger alert-modern">
                    <i class="fas fa-exclamation-triangle"></i> ${error}
                </div>
            </c:if>

            <form action="login" method="post">
                <div class="form-group">
                    <label for="username" class="form-label-modern required">
                        <i class="fas fa-user"></i> Tên đăng nhập
                    </label>
                    <div class="position-relative">
                        <i class="fas fa-user input-icon"></i>
                        <input type="text"
                               class="form-control form-control-modern"
                               id="username"
                               name="username"
                               placeholder="Nhập tên đăng nhập"
                               value="<%=usernameCookieSaved%>"
                               required
                               maxlength="20"
                               pattern="[A-Za-z0-9]+"
                               title="Tên đăng nhập chỉ chứa chữ cái (A–Z, a–z) và số (0–9), độ dài tối đa 20 ký tự.">
                    </div>
                </div>

                <div class="form-group">
                    <label for="password" class="form-label-modern required">
                        <i class="fas fa-lock"></i> Mật khẩu
                    </label>
                    <div class="position-relative">
                        <i class="fas fa-lock input-icon"></i>
                        <input type="password"
                               class="form-control form-control-modern"
                               id="password"
                               name="password"
                               placeholder="Nhập mật khẩu"
                               value="<%=passwordCookieSaved%>"
                               required
                               minlength="6"
                               maxlength="30"
                               pattern="^(?=.*[A-Za-z0-9])[A-Za-z0-9!@#$%^&*()_+=-]{6,30}$"
                               title="Mật khẩu không được có khoảng trắng.">
                    </div>
                </div>

                <div class="text-end" style="margin-top: -10px; font-size: 0.95rem;">
                    <a href="forgotPassword.jsp" class="text-decoration-none" style="color: #000000;">
                        Quên mật khẩu?
                    </a>
                </div>

                <div class="form-check mb-3">
                    <input type="checkbox" class="form-check-input" id="remember" name="remember">
                    <label class="form-check-label" for="remember">Ghi nhớ đăng nhập</label>
                </div>

                <button type="submit" class="btn btn-login">
                    <i class="fas fa-sign-in-alt"></i> Đăng nhập
                </button>

                <a href="register" class="btn btn-register">
                    <i class="fas fa-user-plus"></i> Tạo tài khoản mới
                </a>

                <div class="divider"><span>Hoặc</span></div>

                <a href="https://accounts.google.com/o/oauth2/auth?scope=email%20profile%20openid&redirect_uri=http://localhost:8080/CRM/login-google&response_type=code&client_id=314156413691-aghmg62mq9rdhki4ue9vhc92l50ipvvn.apps.googleusercontent.com&approval_prompt=force"
                   class="btn btn-google w-100">
                    <i class="fab fa-google me-2"></i> Đăng nhập bằng Google
                </a>
            </form>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
