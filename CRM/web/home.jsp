<%-- 
    Document   : index
    Created on : Oct 3, 2025, 8:38:16 PM
    Author     : doand
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>CRM System - Quản lý Khách hàng Chuyên nghiệp</title>
        <style>
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }
            
            body {
                font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
                background: #f8f9fc;
                color: #333;
                line-height: 1.6;
            }
            
            /* Navigation Bar */
            .navbar {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                padding: 0;
                box-shadow: 0 4px 20px rgba(0,0,0,0.1);
                position: sticky;
                top: 0;
                z-index: 1000;
            }
            
            .nav-container {
                max-width: 1200px;
                margin: 0 auto;
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: 1rem 2rem;
            }
            
            .logo {
                color: white;
                font-size: 28px;
                font-weight: bold;
                display: flex;
                align-items: center;
                gap: 10px;
            }
            
            .nav-links {
                display: flex;
                gap: 30px;
                align-items: center;
            }
            
            .nav-links a {
                color: white;
                text-decoration: none;
                font-weight: 500;
                font-size: 15px;
                transition: all 0.3s;
                padding: 8px 16px;
                border-radius: 6px;
            }
            
            .nav-links a:hover {
                background: rgba(255,255,255,0.2);
            }
            
            .btn-login {
                background: transparent;
                color: white;
                padding: 8px 16px;
                border-radius: 6px;
                font-weight: 500;
            }
            
            /* Hero Section */
            .hero {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                padding: 80px 20px;
                position: relative;
                overflow: hidden;
            }
            
            .hero::before {
                content: '';
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                bottom: 0;
                background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1440 320"><path fill="rgba(255,255,255,0.1)" d="M0,96L48,112C96,128,192,160,288,160C384,160,480,128,576,122.7C672,117,768,139,864,138.7C960,139,1056,117,1152,106.7C1248,96,1344,96,1392,96L1440,96L1440,320L1392,320C1344,320,1248,320,1152,320C1056,320,960,320,864,320C768,320,672,320,576,320C480,320,384,320,288,320C192,320,96,320,48,320L0,320Z"></path></svg>') no-repeat bottom;
                background-size: cover;
            }
            
            .hero-content {
                max-width: 1200px;
                margin: 0 auto;
                text-align: center;
                position: relative;
                z-index: 1;
            }
            
            .hero h1 {
                font-size: 52px;
                margin-bottom: 20px;
                font-weight: 700;
                line-height: 1.2;
                animation: fadeInUp 0.8s ease-out;
            }
            
            .hero p {
                font-size: 20px;
                margin-bottom: 40px;
                opacity: 0.95;
                max-width: 700px;
                margin-left: auto;
                margin-right: auto;
                animation: fadeInUp 0.8s ease-out 0.2s both;
            }
            
            @keyframes fadeInUp {
                from {
                    opacity: 0;
                    transform: translateY(30px);
                }
                to {
                    opacity: 1;
                    transform: translateY(0);
                }
            }
            
            /* Form Section */
            .form-container {
                max-width: 1200px;
                margin: -50px auto 60px;
                padding: 0 20px;
                position: relative;
                z-index: 10;
            }
            
            .form-card {
                background: white;
                padding: 50px;
                border-radius: 20px;
                box-shadow: 0 20px 60px rgba(0,0,0,0.15);
                text-align: center;
                animation: fadeInUp 0.8s ease-out 0.4s both;
            }
            
            .form-card h2 {
                color: #667eea;
                font-size: 32px;
                margin-bottom: 15px;
                font-weight: 700;
            }
            
            .form-group {
                display: flex;
                gap: 15px;
                justify-content: center;
                align-items: center;
                flex-wrap: wrap;
            }
            
            .form-group input[type="text"] {
                width: 350px;
                padding: 16px 24px;
                font-size: 16px;
                border: 2px solid #e2e8f0;
                border-radius: 12px;
                transition: all 0.3s;
                outline: none;
            }
            
            .form-group input[type="text"]:focus {
                border-color: #667eea;
                box-shadow: 0 0 0 4px rgba(102,126,234,0.1);
            }
            
            .form-group input[type="submit"] {
                padding: 16px 40px;
                font-size: 16px;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                border: none;
                border-radius: 12px;
                cursor: pointer;
                font-weight: 600;
                transition: all 0.3s;
            }
            
            .form-group input[type="submit"]:hover {
                transform: translateY(-3px);
                box-shadow: 0 10px 30px rgba(102,126,234,0.4);
            }
            
            /* Stats Section */
            .stats {
                max-width: 1200px;
                margin: 0 auto 80px;
                padding: 0 20px;
                display: grid;
                grid-template-columns: repeat(3, 1fr);
                gap: 30px;
            }
            
            .stat-card {
                background: white;
                padding: 35px;
                border-radius: 15px;
                text-align: center;
                box-shadow: 0 5px 25px rgba(0,0,0,0.08);
                transition: all 0.3s;
            }
            
            .stat-card:hover {
                transform: translateY(-10px);
                box-shadow: 0 15px 40px rgba(0,0,0,0.15);
            }
            
            .stat-number {
                font-size: 42px;
                font-weight: 700;
                color: #667eea;
                margin-bottom: 10px;
            }
            
            .stat-label {
                color: #666;
                font-size: 16px;
                font-weight: 500;
            }
            
            /* Features Section */
            .features-section {
                background: white;
                padding: 80px 20px;
            }
            
            .section-header {
                text-align: center;
                max-width: 700px;
                margin: 0 auto 60px;
            }
            
            .section-header h2 {
                font-size: 42px;
                color: #2d3748;
                margin-bottom: 15px;
                font-weight: 700;
            }
            
            .section-header p {
                font-size: 18px;
                color: #666;
            }
            
            .features {
                max-width: 1200px;
                margin: 0 auto;
                display: grid;
                grid-template-columns: repeat(3, 1fr);
                gap: 35px;
            }
            
            .feature-card {
                background: #f8f9fc;
                padding: 40px 30px;
                border-radius: 15px;
                text-align: center;
                transition: all 0.3s;
                border: 2px solid transparent;
            }
            
            .feature-card:hover {
                transform: translateY(-10px);
                border-color: #667eea;
                background: white;
                box-shadow: 0 15px 40px rgba(102,126,234,0.15);
            }
            
            .feature-icon {
                font-size: 60px;
                margin-bottom: 20px;
                display: inline-block;
                transition: all 0.3s;
            }
            
            .feature-card:hover .feature-icon {
                transform: scale(1.1);
            }
            
            .feature-card h3 {
                color: #2d3748;
                font-size: 22px;
                margin-bottom: 12px;
                font-weight: 600;
            }
            
            .feature-card p {
                color: #666;
                line-height: 1.7;
                font-size: 15px;
            }
            
            /* CTA Section */
            .cta-section {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                padding: 80px 20px;
                text-align: center;
            }
            
            .cta-content {
                max-width: 800px;
                margin: 0 auto;
            }
            
            .cta-content h2 {
                font-size: 40px;
                margin-bottom: 20px;
                font-weight: 700;
            }
            
            .cta-content p {
                font-size: 18px;
                margin-bottom: 35px;
                opacity: 0.95;
            }
            
            .cta-buttons {
                display: flex;
                gap: 20px;
                justify-content: center;
                flex-wrap: wrap;
            }
            
            .btn {
                padding: 16px 40px;
                border-radius: 12px;
                text-decoration: none;
                font-weight: 600;
                font-size: 16px;
                transition: all 0.3s;
                display: inline-block;
            }
            
            .btn-white {
                background: white;
                color: #667eea;
            }
            
            .btn-white:hover {
                transform: translateY(-3px);
                box-shadow: 0 10px 30px rgba(255,255,255,0.3);
            }
            
            .btn-outline {
                background: transparent;
                color: white;
                border: 2px solid white;
            }
            
            .btn-outline:hover {
                background: white;
                color: #667eea;
            }
            
            /* Footer hover effects */
            footer a:hover {
                color: white !important;
                padding-left: 5px;
            }
            
            /* Responsive */
            @media (max-width: 768px) {
                .nav-links {
                    display: none;
                }
                
                .hero h1 {
                    font-size: 32px;
                }
                
                .hero p {
                    font-size: 16px;
                }
                
                .form-card {
                    padding: 30px 20px;
                }
                
                .form-group input[type="text"] {
                    width: 100%;
                }
                
                .stats {
                    grid-template-columns: 1fr;
                }
                
                .features {
                    grid-template-columns: 1fr;
                }
                
                footer > div > div:first-child,
                footer > div > div:nth-child(3) {
                    grid-template-columns: 1fr !important;
                }
            }
        </style>
    </head>
    <body>
        <!-- Navigation -->
        <nav class="navbar">
            <div class="nav-container">
                <div class="logo">CRM System</div>
                <div class="nav-links">
                    <a href="index.jsp">Trang chủ</a>
                    <a href="#features">Tính năng</a>
                    <a href="#contact">Liên hệ</a>
                    <a href="login" class="btn-login">Đăng nhập</a>
                </div>
            </div>
        </nav>
        
        <!-- Hero Section -->
        <section class="hero">
            <div class="hero-content">
                <h1>Quản lý Khách hàng và Thiết bị</h1>
                <p>Giải pháp toàn diện cho việc chăm sóc khách hàng, quản lý hợp đồng và theo dõi thiết bị, giúp doanh nghiệp tối ưu hóa quy trình và nâng cao chất lượng dịch vụ</p>
            </div>
        </section>
        
        <!-- Form Section -->
        <div class="form-container">
            <div class="form-card">
                <h2>Bắt đầu trải nghiệm ngay hôm nay</h2>
            </div>
        </div>
        
        <!-- Features Section -->
        <section class="features-section" id="features">
            <div class="section-header">
                <h2>Tính năng vượt trội</h2>
                <p>Tất cả những gì bạn cần để quản lý và phát triển mối quan hệ khách hàng</p>
            </div>
            <div class="features">
                <div class="feature-card">
                    <div class="feature-icon">👥</div>
                    <h3>Quản lý Khách hàng</h3>
                    <p>Tập trung toàn bộ thông tin khách hàng, lịch sử giao dịch và tương tác tại một nơi</p>
                </div>
                
                <div class="feature-card">
                    <div class="feature-icon">📊</div>
                    <h3>Báo cáo Thống kê</h3>
                    <p>Phân tích dữ liệu chi tiết với biểu đồ trực quan, hỗ trợ ra quyết định chính xác</p>
                </div>
                
                <div class="feature-card">
                    <div class="feature-icon">📝</div>
                    <h3>Quản lý Hợp đồng</h3>
                    <p>Theo dõi và quản lý hợp đồng, gia hạn tự động với khả năng cá nhân hóa cao</p>
                </div>
                
                <div class="feature-card">
                    <div class="feature-icon">📅</div>
                    <h3>Quản lý Lịch hẹn</h3>
                    <p>Lên lịch cuộc họp, nhắc nhở tự động và đồng bộ với Google Calendar</p>
                </div>
                
                <div class="feature-card">
                    <div class="feature-icon">💬</div>
                    <h3>Hỗ trợ Khách hàng</h3>
                    <p>Quản lý ticket, live chat và tích hợp đa kênh để hỗ trợ nhanh chóng</p>
                </div>
                
                <div class="feature-card">
                    <div class="feature-icon">🔒</div>
                    <h3>Bảo mật cao</h3>
                    <p>Mã hóa dữ liệu, xác thực 2 lớp và tuân thủ tiêu chuẩn bảo mật quốc tế</p>
                </div>
            </div>
        </section>
        
        <!-- Footer -->
        <footer style="background: linear-gradient(135deg, #1a202c 0%, #2d3748 100%); color: #e2e8f0; padding: 80px 20px 40px; margin-top: 100px; border-top: 1px solid #4a5568;">
            <div style="max-width: 1200px; margin: 0 auto;">
                <!-- Main Footer Content -->
                <div style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 50px; margin-bottom: 60px;">
                    <!-- About Section -->
                    <div>
                        <h3 style="font-size: 18px; font-weight: 700; margin-bottom: 25px; color: white; display: flex; align-items: center; gap: 10px;">
                            <span style="width: 4px; height: 20px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);"></span>
                            CRM System
                        </h3>
                        <p style="font-size: 14px; line-height: 1.8; color: #cbd5e0; margin-bottom: 20px;">
                            Giải pháp quản lý khách hàng toàn diện, giúp doanh nghiệp tối ưu hóa quy trình và nâng cao chất lượng dịch vụ.
                        </p>
                        <p style="font-size: 13px; color: #a0aec0;">
                            <strong>Version:</strong> 1.0.0<br>
                            <strong>Phiên bản:</strong> Enterprise Edition
                        </p>
                    </div>

                    <!-- Products & Features -->
                    <div>
                        <h4 style="font-size: 16px; font-weight: 700; margin-bottom: 25px; color: white;">Tính năng chính</h4>
                        <ul style="list-style: none; padding: 0;">
                            <li style="margin-bottom: 12px;"><a href="#" style="color: #cbd5e0; text-decoration: none; font-size: 14px; transition: all 0.3s; display: inline-block;">→ Quản lý khách hàng</a></li>
                            <li style="margin-bottom: 12px;"><a href="#" style="color: #cbd5e0; text-decoration: none; font-size: 14px; transition: all 0.3s; display: inline-block;">→ Quản lý hợp đồng</a></li>
                            <li style="margin-bottom: 12px;"><a href="#" style="color: #cbd5e0; text-decoration: none; font-size: 14px; transition: all 0.3s; display: inline-block;">→ Quản lý thiết bị</a></li>
                            <li style="margin-bottom: 12px;"><a href="#" style="color: #cbd5e0; text-decoration: none; font-size: 14px; transition: all 0.3s; display: inline-block;">→ Báo cáo & Phân tích</a></li>
                            <li style="margin-bottom: 12px;"><a href="#" style="color: #cbd5e0; text-decoration: none; font-size: 14px; transition: all 0.3s; display: inline-block;">→ Quản lý yêu cầu dịch vụ</a></li>
                        </ul>
                    </div>

                    <!-- Support & Help -->
                    <div>
                        <h4 style="font-size: 16px; font-weight: 700; margin-bottom: 25px; color: white;">Hỗ trợ & Trợ giúp</h4>
                        <ul style="list-style: none; padding: 0;">
                            <li style="margin-bottom: 12px;"><a href="#" style="color: #cbd5e0; text-decoration: none; font-size: 14px; transition: all 0.3s; display: inline-block;">→ Trung tâm trợ giúp</a></li>
                            <li style="margin-bottom: 12px;"><a href="#" style="color: #cbd5e0; text-decoration: none; font-size: 14px; transition: all 0.3s; display: inline-block;">→ Hướng dẫn sử dụng</a></li>
                            <li style="margin-bottom: 12px;"><a href="#" style="color: #cbd5e0; text-decoration: none; font-size: 14px; transition: all 0.3s; display: inline-block;">→ Liên hệ hỗ trợ</a></li>
                            <li style="margin-bottom: 12px;"><a href="#" style="color: #cbd5e0; text-decoration: none; font-size: 14px; transition: all 0.3s; display: inline-block;">→ Câu hỏi thường gặp</a></li>
                            <li style="margin-bottom: 12px;"><a href="#" style="color: #cbd5e0; text-decoration: none; font-size: 14px; transition: all 0.3s; display: inline-block;">→ Yêu cầu tính năng</a></li>
                        </ul>
                    </div>

                    <!-- Company Info -->
                    <div>
                        <h4 style="font-size: 16px; font-weight: 700; margin-bottom: 25px; color: white;">Thông tin công ty</h4>
                        <ul style="list-style: none; padding: 0;">
                            <li style="margin-bottom: 12px;"><a href="#" style="color: #cbd5e0; text-decoration: none; font-size: 14px; transition: all 0.3s; display: inline-block;">→ Về chúng tôi</a></li>
                            <li style="margin-bottom: 12px;"><a href="#" style="color: #cbd5e0; text-decoration: none; font-size: 14px; transition: all 0.3s; display: inline-block;">→ Điều khoản sử dụng</a></li>
                            <li style="margin-bottom: 12px;"><a href="#" style="color: #cbd5e0; text-decoration: none; font-size: 14px; transition: all 0.3s; display: inline-block;">→ Chính sách bảo mật</a></li>
                            <li style="margin-bottom: 12px;"><a href="#" style="color: #cbd5e0; text-decoration: none; font-size: 14px; transition: all 0.3s; display: inline-block;">→ Bảo mật dữ liệu</a></li>
                            <li style="margin-bottom: 12px;"><a href="#" style="color: #cbd5e0; text-decoration: none; font-size: 14px; transition: all 0.3s; display: inline-block;">→ Liên hệ</a></li>
                        </ul>
                    </div>
                </div>

                <!-- Divider -->
                <div style="height: 1px; background: linear-gradient(to right, transparent, #4a5568, transparent); margin-bottom: 40px;"></div>

                <!-- Bottom Info -->
                <div style="display: grid; grid-template-columns: 2fr 1fr 1fr; gap: 40px; align-items: start; margin-bottom: 30px;">
                    <!-- Contact Info -->
                    <div>
                        <h4 style="font-size: 14px; font-weight: 700; margin-bottom: 15px; color: white; text-transform: uppercase; letter-spacing: 0.5px;">Liên hệ</h4>
                        <div style="font-size: 13px; line-height: 2; color: #cbd5e0;">
                            <p style="margin: 0;">📧 Email: <strong>support@crmsystem.com</strong></p>
                            <p style="margin: 0;">📞 Hotline: <strong>(+84) 123 456 7890</strong></p>
                            <p style="margin: 0;">🏢 Địa chỉ: <strong>Ho Chi Minh City, Vietnam</strong></p>
                            <p style="margin: 0;">⏰ Hỗ trợ: <strong>24/7</strong></p>
                        </div>
                    </div>

                    <!-- Stats -->
                    <div>
                        <h4 style="font-size: 14px; font-weight: 700; margin-bottom: 15px; color: white; text-transform: uppercase; letter-spacing: 0.5px;">Thống kê</h4>
                        <div style="font-size: 13px; line-height: 2; color: #cbd5e0;">
                            <p style="margin: 0;">👥 Người dùng: <strong>5,000+</strong></p>
                            <p style="margin: 0;">🏢 Công ty: <strong>1,200+</strong></p>
                            <p style="margin: 0;">📊 Dữ liệu: <strong>500K+</strong></p>
                            <p style="margin: 0;">⭐ Đánh giá: <strong>4.9/5.0</strong></p>
                        </div>
                    </div>

                    <!-- Certification -->
                    <div>
                        <h4 style="font-size: 14px; font-weight: 700; margin-bottom: 15px; color: white; text-transform: uppercase; letter-spacing: 0.5px;">Chứng chỉ</h4>
                        <div style="font-size: 12px; line-height: 1.8; color: #cbd5e0;">
                            <p style="margin: 0; display: inline-block; background: rgba(102,126,234,0.1); padding: 4px 8px; border-radius: 4px; margin-right: 6px; margin-bottom: 6px;">🔒 ISO 27001</p><br>
                            <p style="margin: 0; display: inline-block; background: rgba(102,126,234,0.1); padding: 4px 8px; border-radius: 4px; margin-right: 6px; margin-bottom: 6px;">✓ GDPR</p><br>
                            <p style="margin: 0; display: inline-block; background: rgba(102,126,234,0.1); padding: 4px 8px; border-radius: 4px;">🛡️ SOC 2</p>
                        </div>
                    </div>
                </div>

                <!-- Footer Bottom -->
                <div style="border-top: 1px solid #4a5568; padding-top: 30px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 20px;">
                    <p style="font-size: 13px; color: #a0aec0; margin: 0;">
                        &copy; 2025 CRM System. All rights reserved. | Phát triển bởi <strong>Group 6</strong>
                    </p>
                    <div style="display: flex; gap: 20px; font-size: 13px;">
                        <a href="#" style="color: #cbd5e0; text-decoration: none; transition: color 0.3s;">Chính sách bảo mật</a>
                        <span style="color: #4a5568;">|</span>
                        <a href="#" style="color: #cbd5e0; text-decoration: none; transition: color 0.3s;">Điều khoản dịch vụ</a>
                        <span style="color: #4a5568;">|</span>
                        <a href="#" style="color: #cbd5e0; text-decoration: none; transition: color 0.3s;">Cài đặt Cookie</a>
                    </div>
                </div>
            </div>
        </footer>
    </body>
</html>