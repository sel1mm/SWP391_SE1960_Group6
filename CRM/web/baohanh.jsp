<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    LocalDate currentDate = LocalDate.now();
    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("'Tháng' MM 'năm' yyyy");
    String formattedDate = currentDate.format(formatter);
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Chính sách bảo hành - CRM System</title>
        <style>
            * {
                margin:0;
                padding:0;
                box-sizing:border-box;
            }
            body {
                font-family: 'Inter', sans-serif;
                background:#f8f9fc;
                color:#333;
                line-height:1.6;
            }

            /* Navbar */
            .navbar {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                padding:0;
                box-shadow:0 4px 20px rgba(0,0,0,0.1);
                position:sticky;
                top:0;
                z-index:1000;
            }
            .nav-container {
                max-width:1200px;
                margin:0 auto;
                display:flex;
                justify-content:space-between;
                align-items:center;
                padding:1rem 2rem;
            }
            .logo {
                color:white;
                font-size:28px;
                font-weight:bold;
            }
            .nav-links {
                display:flex;
                gap:30px;
                align-items:center;
            }
            .nav-links a {
                color:white;
                text-decoration:none;
                font-weight:500;
                font-size:15px;
                padding:8px 16px;
                border-radius:6px;
                transition:all 0.3s;
            }
            .nav-links a:hover {
                background: rgba(255,255,255,0.2);
            }
            .btn-login {
                background: transparent;
                color:white;
            }

            /* Hero */
            .hero {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color:white;
                padding:80px 20px;
                text-align:center;
                position:relative;
                overflow:hidden;
            }
            .hero h1 {
                font-size:42px;
                margin-bottom:15px;
                font-weight:700;
                animation:fadeInUp 0.8s ease-out;
            }
            .hero p {
                font-size:18px;
                opacity:0.95;
                animation:fadeInUp 0.8s ease-out 0.2s both;
            }
            @keyframes fadeInUp {
                from {
                    opacity:0;
                    transform:translateY(30px);
                }
                to {
                    opacity:1;
                    transform:translateY(0);
                }
            }

            /* Content */
            .content-wrapper {
                max-width:1200px;
                margin:-40px auto 80px;
                padding:0 20px;
                position:relative;
                z-index:10;
            }
            .content-card {
                background:white;
                padding:40px 30px;
                border-radius:20px;
                box-shadow:0 20px 60px rgba(0,0,0,0.15);
            }
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
                margin-bottom:20px;
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

            h2.section-title {
                font-size:1.5em;
                color:#2c3748;
                margin-bottom:20px;
                padding-left:20px;
                border-left:5px solid #667eea;
                font-weight:700;
            }
            .section-content {
                padding-left:25px;
                color:#555;
                line-height:1.8;
                font-size:16px;
            }
            .last-updated {
                margin-bottom:20px;
                font-size:14px;
                color:#718096;
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
            .footer-bottom {
                text-align:center;
                margin-top:60px;
                font-size:13px;
                color:#a0aec0;
                border-top:1px solid rgba(255,255,255,0.1);
                padding-top:20px;
            }

            @media(max-width:768px){
                .hero h1 {
                    font-size:32px;
                }
                .content-card {
                    padding:30px 20px;
                }
                footer {
                    padding:60px 20px 30px;
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

        <!-- Hero -->
        <section class="hero">
            <h1>Chính sách bảo hành</h1>
            <p>CRM System - Chính sách bảo hành dịch vụ và sản phẩm</p>
        </section>

        <!-- Content -->
        <div class="content-wrapper">
            <div class="content-card">
                <a href="home.jsp" class="back-button"><span class="back-icon">←</span>Về Trang chủ</a>
                <div class="last-updated">📅 Cập nhật lần cuối: <%= formattedDate %></div>

                <div class="section">
                    <h2 class="section-title">Điều kiện bảo hành</h2>
                    <div class="section-content">
                        <p>CRM System cam kết bảo hành sản phẩm và dịch vụ trong thời gian quy định từ ngày mua. Các thiết bị hoặc phần mềm sẽ được kiểm tra lỗi kỹ thuật và sửa chữa miễn phí nếu lỗi do nhà sản xuất.</p>
                    </div>
                </div>

                <div class="section">
                    <h2 class="section-title">Thời gian và quy trình</h2>
                    <div class="section-content">
                        <p>- Thời gian bảo hành: từ 6 tháng đến 24 tháng tùy sản phẩm.</p>
                        <p>- Quy trình yêu cầu bảo hành: khách hàng liên hệ bộ phận hỗ trợ, cung cấp thông tin sản phẩm và hóa đơn mua hàng, sau đó nhận hướng dẫn gửi sản phẩm hoặc được hỗ trợ trực tuyến.</p>
                    </div>
                </div>

                <div class="section">
                    <h2 class="section-title">Trách nhiệm của khách hàng</h2>
                    <div class="section-content">
                        <p>- Sử dụng sản phẩm đúng hướng dẫn của nhà sản xuất.</p>
                        <p>- Không tự ý sửa chữa gây hỏng hóc sản phẩm.</p>
                        <p>- Cung cấp thông tin chính xác khi yêu cầu bảo hành.</p>
                    </div>
                </div>

                <div class="section">
                    <h2 class="section-title">Các trường hợp từ chối bảo hành</h2>
                    <div class="section-content">
                        <p>- Hư hỏng do tác động vật lý, thiên tai, cháy nổ hoặc sử dụng sai hướng dẫn.</p>
                        <p>- Sản phẩm hết thời gian bảo hành hoặc không còn hóa đơn hợp lệ.</p>
                    </div>
                </div>
            </div>
        </div>

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
                            <li><a href="baohanh.jsp">Chính sách bảo hành</a></li>
                            <li><a href="baogia.jsp">Báo giá dịch vụ</a></li>

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
