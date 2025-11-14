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
        <title>About Us - CRM System</title>
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

            /* Navbar */
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
                padding: 60px 20px 80px;
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
                font-size: 42px;
                margin-bottom: 15px;
                font-weight: 700;
                line-height: 1.2;
                animation: fadeInUp 0.8s ease-out;
            }
            .hero p {
                font-size: 18px;
                opacity: 0.95;
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

            /* Content Wrapper */
            .content-wrapper {
                max-width: 1200px;
                margin: -40px auto 80px;
                padding: 0 20px;
                position: relative;
                z-index: 10;
            }
            .content-card {
                background: white;
                padding: 60px;
                border-radius: 20px;
                box-shadow: 0 20px 60px rgba(0,0,0,0.15);
                animation: fadeInUp 0.8s ease-out 0.4s both;
            }
            .section {
                margin-bottom: 45px;
            }
            .section-title {
                font-size: 1.5em;
                color: #2c3748;
                margin-bottom: 20px;
                padding-left: 20px;
                border-left: 5px solid #667eea;
                font-weight: 700;
            }
            .section-content {
                padding-left: 25px;
            }

            /* ================== TEAM MEMBER CSS ================== */
            .team-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
                gap: 30px;
                margin-top: 40px;
            }
            .team-member {
                background: #f8f9fc;
                border-radius: 15px;
                text-align: center;
                padding: 30px 20px;
                transition: all 0.3s;
                border: 2px solid transparent;
            }
            .team-member:hover {
                transform: translateY(-8px);
                border-color: #667eea;
                background: white;
                box-shadow: 0 10px 30px rgba(102,126,234,0.15);
            }
            .team-member img {
                width: 150px;
                height: 150px;
                border-radius: 50%;
                object-fit: cover;
                margin-bottom: 15px;
                border: 2px solid #e0e0e0;
                box-shadow: 0 2px 5px rgba(0,0,0,0.15);
                transition: transform 0.2s ease, box-shadow 0.2s ease;
            }
            .team-member img:hover {
                transform: scale(1.05);
                box-shadow: 0 4px 10px rgba(0,0,0,0.2);
            }
            .team-member h4 {
                font-size: 18px;
                color: #2d3748;
                margin-bottom: 8px;
                font-weight: 600;
            }
            .team-member p {
                color: #666;
                font-size: 14px;
            }
            @media (max-width: 768px) {
                .team-grid {
                    grid-template-columns: 1fr;
                    gap: 20px;
                }
                .team-member img {
                    width: 120px;
                    height: 120px;
                }
            }

            /* Back button */
            .back-button {
                display: inline-flex;
                align-items: center;
                gap: 8px;
                padding: 12px 24px;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                text-decoration: none;
                border-radius: 12px;
                font-weight: 600;
                font-size: 0.95em;
                box-shadow: 0 4px 15px rgba(102,126,234,0.3);
                transition: all 0.3s ease;
                margin-bottom: 30px;
            }
            .back-button:hover {
                transform: translateY(-3px);
                box-shadow: 0 8px 25px rgba(102,126,234,0.4);
            }
            .back-icon {
                font-size: 1.1em;
                transition: transform 0.3s ease;
            }
            .back-button:hover .back-icon {
                transform: translateX(-3px);
            }

            /* Footer */
            footer {
                background: #1a202c;
                padding: 80px 20px 40px;
                color: #cbd5e0;
                margin-top: 100px;
            }
            .footer-grid {
                max-width: 1200px;
                margin: 0 auto;
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
                gap: 60px;
            }
            .footer-title {
                font-size: 18px;
                font-weight: 700;
                margin-bottom: 25px;
                color: #fff;
                display: flex;
                align-items: center;
                gap: 10px;
            }
            .title-bar {
                width: 4px;
                height: 20px;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                border-radius: 2px;
            }
            .footer-heading {
                font-size: 16px;
                font-weight: 700;
                margin-bottom: 25px;
                color: #fff;
            }
            .footer-desc {
                font-size: 14px;
                line-height: 1.8;
                color: #cbd5e0;
                margin-bottom: 20px;
            }
            .footer-version {
                font-size: 13px;
                color: #a0aec0;
            }
            .footer-list {
                list-style: none;
                padding: 0;
                margin: 0;
            }
            .footer-list li {
                margin-bottom: 12px;
                font-size: 14px;
                transition: all 0.3s;
            }
            .footer-list a, .footer-list span {
                color: #cbd5e0;
                text-decoration: none;
                display: inline-block;
                transition: all 0.3s;
            }
            .footer-list a:hover, .footer-list span:hover {
                color: #fff;
                transform: translateX(4px);
            }
            .footer-bottom {
                text-align: center;
                margin-top: 60px;
                font-size: 13px;
                color: #a0aec0;
                border-top: 1px solid rgba(255, 255, 255, 0.1);
                padding-top: 20px;
            }
            /* ================== TEAM MEMBER CSS (CẢI TIẾN) ================== */
            .team-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
                gap: 30px;
                margin-top: 40px;
            }

            .team-member {
                background: #ffffff;
                border-radius: 20px;
                text-align: center;
                padding: 25px 15px;
                transition: all 0.4s ease;
                border: 1px solid #e0e0e0;
                box-shadow: 0 4px 12px rgba(0,0,0,0.05);
            }

            .team-member:hover {
                transform: translateY(-10px);
                border-color: #667eea;
                box-shadow: 0 15px 35px rgba(102,126,234,0.2);
                background: #f8f9ff;
            }

            .team-member img {
                width: 140px;
                height: 140px;
                border-radius: 50%;
                object-fit: cover;
                margin-bottom: 15px;
                border: 3px solid #e0e0e0;
                box-shadow: 0 3px 8px rgba(0,0,0,0.1);
                transition: transform 0.3s ease, box-shadow 0.3s ease, border-color 0.3s ease;
            }

            /* Hover avatar */
            .team-member img:hover {
                transform: scale(1.08);
                box-shadow: 0 6px 15px rgba(102,126,234,0.3);
                border-color: #667eea;
            }

            /* Name & Role */
            .team-member h4 {
                font-size: 18px;
                color: #2d3748;
                margin-bottom: 6px;
                font-weight: 600;
            }
            .team-member p {
                color: #718096;
                font-size: 14px;
                margin-bottom: 0;
            }

            /* Mobile */
            @media (max-width: 768px) {
                .team-grid {
                    grid-template-columns: 1fr;
                    gap: 20px;
                }
                .team-member img {
                    width: 120px;
                    height: 120px;
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
            <div class="hero-content">
                <h1>About Us</h1>
                <p>Đội ngũ phát triển CRM System</p>
            </div>
        </section>

        <!-- Content Section -->
        <div class="content-wrapper">
            <div class="content-card">
                <a href="home.jsp" class="back-button">
                    <span class="back-icon">←</span>
                    Về Trang chủ
                </a>

                <div class="last-updated">
                    📅 Cập nhật lần cuối: <%= formattedDate %>
                </div>

                <div class="section">
                    <h2 class="section-title">Tầm nhìn & Sứ mệnh</h2>
                    <div class="section-content">
                        <p><strong>Tầm nhìn:</strong> Trở thành giải pháp CRM hàng đầu tại Việt Nam, giúp doanh nghiệp tối ưu hóa quản lý khách hàng và nâng cao hiệu quả kinh doanh.</p>
                        <p><strong>Sứ mệnh:</strong> Cung cấp hệ thống CRM thông minh, dễ sử dụng, hỗ trợ doanh nghiệp xây dựng mối quan hệ khách hàng bền vững và nâng cao chất lượng dịch vụ.</p>
                    </div>
                </div>

                <div class="section">
                    <h2 class="section-title">Đội ngũ phát triển</h2>
                    <div class="section-content">
                        <div class="team-grid">
                            <div class="team-member">
                                <img src="https://tse2.mm.bing.net/th/id/OIP.x4FIT_6vXJzLBmpIBNT9qAAAAA?cb=ucfimg2ucfimg=1&w=225&h=225&rs=1&pid=ImgDetMain&o=7&rm=3" alt="Member X">

                                <h4>Doan Dinh Giap</h4>
                                <p>Fullstack Developer</p>
                            </div>
                            <div class="team-member">
                                <img src="https://scontent.fhan20-1.fna.fbcdn.net/v/t39.30808-1/494196726_711819304605422_7343151851657339219_n.jpg?stp=dst-jpg_s200x200_tt6&_nc_cat=103&cb2=99be929b-bd9a46d7&ccb=1-7&_nc_sid=e99d92&_nc_ohc=rZj9dMr_MFUQ7kNvwGw9r7f&_nc_oc=Adl2rMagbpZ58hMxSo5xi6dJH-Jje8StMc7hf6lNcT83SLFV8F-5n_ZLyNXuNkk64aSSRxpNVUzOoUDH7WL9EcsJ&_nc_zt=24&_nc_ht=scontent.fhan20-1.fna&_nc_gid=Xi5gi8lTw3Umsp5LzdUANQ&oh=00_AfjqrMNdh_bUozwqvetYTeeWcevien5uYD5gEI-RsEp1_g&oe=691BD30F" alt="Member X">

                                <h4>Le Anh Vu</h4>
                                <p>Fullstack Developer</p>
                            </div>
                            <div class="team-member">
                                <img src="https://sf-static.upanhlaylink.com/img/image_2025111468fe8db3474ae500c0cfbdc5afd2be8e.jpg" alt="Member X">

                                <h4>Nguyen Hai Bach</h4>
                                <p>Fullstack Developer</p>
                            </div>
                        </div>
                        <div class="team-grid" style="margin-top: 50px;">
                            <div class="team-member">
                                <img src="https://scontent.fhan2-3.fna.fbcdn.net/v/t39.30808-6/481290867_1672572963648920_5946532814955947331_n.jpg?_nc_cat=111&cb2=99be929b-bd9a46d7&ccb=1-7&_nc_sid=a5f93a&_nc_ohc=dShoP7NRJDMQ7kNvwEWnoiT&_nc_oc=Adn5jcdn0BAgiOVISRNHOnDU4yvZHIKIoGlMcQXG2LwYfeHCX161wp7M95FP62JK2WsOkI6m_r90reXaDoMUmRYi&_nc_zt=23&_nc_ht=scontent.fhan2-3.fna&_nc_gid=Np6ZKS4A9SUgQKQktAS3sg&oh=00_Afh7s1tFQbqXz9EtS0NnkVHL1034QcbOwEXWDa2ZOSgbJA&oe=691BCD27" alt="Member X">

                                <h4>Pham Quoc Binh</h4>
                                <p>Fullstack Developer</p>
                            </div>
                            <div class="team-member">
                                <img src="https://scontent.fhan20-1.fna.fbcdn.net/v/t39.30808-6/482201770_628898369742777_2807123171304223555_n.jpg?_nc_cat=102&cb2=99be929b-bd9a46d7&ccb=1-7&_nc_sid=a5f93a&_nc_ohc=77zEQqNV8HMQ7kNvwG4RGWx&_nc_oc=Adm6uchEyFAmfReF0k55imDgOz_XSGDaOpyQxIaHHYdMFrfyAODoGVhn__WwoGqOVHtghfVKlPiQtRir0ipdXqOn&_nc_zt=23&_nc_ht=scontent.fhan20-1.fna&_nc_gid=IoudbxgHJP_iqeKwkBi3Vw&oh=00_AfiKA_mqVVj-b4NTFpbi13ii4zem1o7qU4fFDdti66tW_A&oe=691BCBA8" alt="Member X">

                                <h4>Tran Bao Lam</h4>
                                <p>Fullstack Developer</p>
                            </div>
                            <div class="team-member">
                                <img src="https://tse3.mm.bing.net/th/id/OIP.AjWni_SG6OK4HruyGYqLTQAAAA?cb=ucfimg2ucfimg=1&rs=1&pid=ImgDetMain&o=7&rm=3" alt="Member X">

                                <h4>Nguyen Khanh Hung</h4>
                                <p>Fullstack Developer</p>
                            </div>
                        </div>
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
                             <li><a href="baohanh.jsp">→ Điều khoản sử dụng</a></li>
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
