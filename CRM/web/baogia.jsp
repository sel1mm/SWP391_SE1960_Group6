<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Báo Giá Dịch Vụ - CRM System</title>
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

            /* Hero Section */
            .hero {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                padding: 80px 20px;
                text-align: center;
            }

            .hero h1 {
                font-size: 48px;
                margin-bottom: 20px;
                font-weight: 700;
                animation: fadeInUp 0.8s ease-out;
            }

            .hero p {
                font-size: 20px;
                opacity: 0.95;
                max-width: 700px;
                margin: 0 auto;
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

            /* Services Section */
            .services-section {
                max-width: 1200px;
                margin: -50px auto 80px;
                padding: 0 20px;
                position: relative;
                z-index: 10;
            }

            .content-wrapper {
                background: white;
                padding: 40px;
                border-radius: 20px;
                box-shadow: 0 20px 60px rgba(0,0,0,0.15);
            }

            /* Back Button */
            .back-button {
                display:inline-flex;
                align-items:center;
                gap:8px;
                padding:12px 24px;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color:white;
                text-decoration:none;
                border-radius:12px;
                font-weight:600;
                margin-bottom:40px;
                transition: all 0.3s ease;
            }
            .back-button:hover {
                transform: translateY(-3px);
                box-shadow:0 8px 25px rgba(102,126,234,0.4);
            }
            .back-icon {
                font-size:1.1em;
                transition: transform 0.3s ease;
            }
            .back-button:hover .back-icon {
                transform: translateX(-3px);
            }

            .section-title {
                text-align: center;
                font-size: 36px;
                font-weight: 700;
                color: #2d3748;
                margin-bottom: 15px;
            }

            .section-subtitle {
                text-align: center;
                font-size: 18px;
                color: #666;
                margin-bottom: 50px;
                max-width: 700px;
                margin-left: auto;
                margin-right: auto;
            }

            .services-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
                gap: 25px;
            }

            .service-card {
                background: white;
                padding: 30px;
                border-radius: 15px;
                box-shadow: 0 5px 25px rgba(0,0,0,0.08);
                transition: all 0.3s;
                border-left: 4px solid #667eea;
            }

            .service-card:hover {
                transform: translateX(5px);
                box-shadow: 0 10px 35px rgba(102,126,234,0.2);
            }

            .service-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 15px;
            }

            .service-title {
                font-size: 20px;
                font-weight: 600;
                color: #2d3748;
            }

            .service-price {
                font-size: 22px;
                font-weight: 700;
                color: #667eea;
            }

            .service-description {
                font-size: 14px;
                color: #666;
                line-height: 1.7;
                margin-bottom: 15px;
            }

            .service-details {
                font-size: 13px;
                color: #999;
                padding-top: 15px;
                border-top: 1px solid #f0f0f0;
            }

            /* CTA Section */
            .cta-section {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                padding: 80px 20px;
                text-align: center;
                margin-top: 80px;
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
                max-width: 700px;
                margin-left: auto;
                margin-right: auto;
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

            /* Footer */
            footer {
                background:#1a202c;
                padding:80px 20px 40px;
                color:#cbd5e0;
                margin-top:100px;
            }
            .footer-grid {
                max-width:1200px;
                margin:0 auto;
                display:grid;
                grid-template-columns:repeat(auto-fit,minmax(250px,1fr));
                gap:60px;
            }
            .footer-title {
                font-size:18px;
                font-weight:700;
                margin-bottom:25px;
                color:#fff;
                display:flex;
                align-items:center;
                gap:10px;
            }
            .title-bar {
                width:4px;
                height:20px;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                border-radius:2px;
            }
            .footer-heading {
                font-size:16px;
                font-weight:700;
                margin-bottom:25px;
                color:#fff;
            }
            .footer-desc {
                font-size:14px;
                line-height:1.8;
                color:#cbd5e0;
                margin-bottom:20px;
            }
            .footer-version {
                font-size:13px;
                line-height:1.8;
                color:#a0aec0;
            }
            .footer-list {
                list-style:none;
                padding:0;
            }
            .footer-list li {
                margin-bottom:12px;
                font-size:14px;
            }
            .footer-list a, .footer-list span {
                color:#cbd5e0;
                text-decoration:none;
                transition:all 0.3s;
            }
            .footer-list a:hover, .footer-list span:hover {
                color:#fff;
                transform:translateX(4px);
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

                .services-grid {
                    grid-template-columns: 1fr;
                }

                .section-title {
                    font-size: 28px;
                }

                .footer-grid {
                    gap:40px;
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
                    <a href="home.jsp">Trang chủ</a>
                    <% 
                        model.Account acc = (model.Account) session.getAttribute("session_login");
                        if (acc == null) { 
                    %>
                    <a href="login" class="btn-login">Đăng nhập</a>
                    <% 
                        } else { 
                            String userRole = (String) session.getAttribute("session_role");
                            String dashboardLink = "#";
                            if ("admin".equalsIgnoreCase(userRole)) {
                                dashboardLink = "admin.jsp";
                            } else if ("Technical Manager".equalsIgnoreCase(userRole)) {
                                dashboardLink = "technicalManagerApproval";
                            } else if ("Customer Support Staff".equalsIgnoreCase(userRole)) {
                                dashboardLink = "dashboard.jsp";
                            } else if ("Storekeeper".equalsIgnoreCase(userRole)) {
                                dashboardLink = "storekeeper";
                            } else if ("Technician".equalsIgnoreCase(userRole)) {
                                dashboardLink = "technician/dashboard";
                            } else if ("customer".equalsIgnoreCase(userRole)) {
                                dashboardLink = "managerServiceRequest";
                            } else {
                                dashboardLink = "home.jsp";
                            }
                    %>
                    <a href="#" style="color: white; font-size: 15px; text-decoration: none;">
                        👋 Xin chào, <strong><%= acc.getUsername() %></strong>
                    </a>
                    <a href="<%= dashboardLink %>" class="btn-login" style="background: rgba(255,255,255,0.2); text-decoration: none;">
                        📊 Dashboard
                    </a>
                    <a href="logout" class="btn-login" style="background: rgba(255,255,255,0.2); text-decoration: none;">
                        Đăng xuất
                    </a>
                    <% 
                        } 
                    %>
                </div>
            </div>
        </nav>

        <!-- Hero Section -->
        <section class="hero">
            <h1>Báo Giá Dịch Vụ</h1>
            <p>Lựa chọn gói dịch vụ phù hợp với nhu cầu quản lý khách hàng và thiết bị của doanh nghiệp bạn</p>
        </section>

        <!-- Additional Services -->
        <section class="services-section">
            <div class="content-wrapper">
                <a href="home.jsp" class="back-button"><span class="back-icon">←</span>Về Trang chủ</a>
                
                <h2 class="section-title">Dịch Vụ Bổ Sung</h2>
                <p class="section-subtitle">Các dịch vụ chăm sóc khách hàng và bảo trì thiết bị chuyên nghiệp</p>

                <div class="services-grid">
                <div class="service-card">
                    <div class="service-header">
                        <h4 class="service-title">Hợp đồng Bảo trì Cơ bản</h4>
                        <span class="service-price">500.000₫</span>
                    </div>
                    <p class="service-description">
                        Kiểm tra định kỳ 6 tháng/lần, bảo dưỡng thiết bị cơ bản, hỗ trợ kỹ thuật qua điện thoại
                    </p>
                    <p class="service-details">⏱ Thời gian phản hồi: 24-48 giờ</p>
                </div>

                <div class="service-card">
                    <div class="service-header">
                        <h4 class="service-title">Hợp đồng Bảo trì Nâng cao</h4>
                        <span class="service-price">1.200.000₫</span>
                    </div>
                    <p class="service-description">
                        Kiểm tra định kỳ 3 tháng/lần, bảo dưỡng toàn diện, ưu tiên hỗ trợ kỹ thuật, thay thế linh kiện
                    </p>
                    <p class="service-details">⏱ Thời gian phản hồi: 8-12 giờ</p>
                </div>

                <div class="service-card">
                    <div class="service-header">
                        <h4 class="service-title">Bảo trì Premium</h4>
                        <span class="service-price">2.500.000₫</span>
                    </div>
                    <p class="service-description">
                        Kiểm tra hàng tháng, bảo dưỡng VIP, hỗ trợ 24/7, kỹ thuật viên tận nơi, thay thế thiết bị dự phòng
                    </p>
                    <p class="service-details">⏱ Thời gian phản hồi: 2-4 giờ</p>
                </div>

                <div class="service-card">
                    <div class="service-header">
                        <h4 class="service-title">Đào tạo Nhân viên</h4>
                        <span class="service-price">3.000.000₫</span>
                    </div>
                    <p class="service-description">
                        Khóa đào tạo 2 ngày về sử dụng hệ thống CRM, quản lý khách hàng hiệu quả, tài liệu hướng dẫn
                    </p>
                    <p class="service-details">📚 Tối đa 10 người/khóa</p>
                </div>

                <div class="service-card">
                    <div class="service-header">
                        <h4 class="service-title">Tích hợp Hệ thống</h4>
                        <span class="service-price">5.000.000₫</span>
                    </div>
                    <p class="service-description">
                        Tích hợp CRM với hệ thống ERP, kế toán, email marketing, hoặc các phần mềm khác của doanh nghiệp
                    </p>
                    <p class="service-details">🔧 Thời gian triển khai: 1-2 tuần</p>
                </div>

                <div class="service-card">
                    <div class="service-header">
                        <h4 class="service-title">Tùy chỉnh Giao diện</h4>
                        <span class="service-price">4.000.000₫</span>
                    </div>
                    <p class="service-description">
                        Thiết kế giao diện theo thương hiệu doanh nghiệp, tùy chỉnh báo cáo, biểu mẫu và dashboard
                    </p>
                    <p class="service-details">🎨 Thời gian hoàn thành: 1 tuần</p>
                </div>
            </div>
            </div>
        </section>

 
        <!-- Footer -->
        <footer style="background: linear-gradient(135deg, #1a202c 0%, #2d3748 100%); color: #e2e8f0; padding: 80px 20px 40px; margin-top: 100px; border-top: 1px solid #4a5568;">
            <div style="max-width: 1200px; margin: 0 auto;">
                <!-- Main Footer Content -->
                <div class="footer-grid">
                    <!-- About Section -->
                    <div>
                        <h3 class="footer-title">
                            <span class="title-bar"></span>
                            CRM System
                        </h3>
                        <p class="footer-desc">
                            Giải pháp quản lý khách hàng toàn diện, giúp doanh nghiệp tối ưu hóa quy trình và nâng cao chất lượng dịch vụ.
                        </p>
                        <p class="footer-version">
                            <strong>Version:</strong> 1.0.0<br>
                            <strong>Phiên bản:</strong> Enterprise Edition
                        </p>
                    </div>

                    <!-- Features -->
                    <div>
                        <h4 class="footer-heading">Tính năng chính</h4>
                        <ul class="footer-list">
                            <li>→ Quản lý khách hàng</li>
                            <li>→ Quản lý hợp đồng</li>
                            <li>→ Quản lý thiết bị</li>
                            <li>→ Báo cáo & Phân tích</li>
                            <li>→ Quản lý yêu cầu dịch vụ</li>
                        </ul>
                    </div>

                    <!-- Company Info -->
                    <div>
                        <h4 class="footer-heading">Thông tin công ty</h4>
                        <ul class="footer-list">
                            <li><a href="about.jsp">→ Về chúng tôi</a></li>
                            <li><a href="tos.jsp">→ Điều khoản sử dụng</a></li>
                            <li><a href="baohanh.jsp">→ Chính sách bảo hành</a></li>
                            <li><a href="baogia.jsp">→ Báo giá dịch vụ</a></li>

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