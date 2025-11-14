<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    // Lấy ngày tháng hiện tại
    LocalDate currentDate = LocalDate.now();
    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("'Tháng' MM 'năm' yyyy");
    String formattedDate = currentDate.format(formatter);
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Điều Khoản Dịch Vụ - CRM System</title>
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

        /* Navigation Bar - Giống Home */
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

        /* Hero Section - Shorter version */
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

        /* Content Container */
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

        .last-updated {
            background: linear-gradient(135deg, #e8f4f8 0%, #f0e8f8 100%);
            padding: 15px 25px;
            border-radius: 12px;
            text-align: center;
            margin-bottom: 40px;
            color: #667eea;
            font-size: 0.95em;
            font-weight: 600;
            border: 2px solid rgba(102, 126, 234, 0.2);
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

        .section-content h3 {
            color: #34495e;
            font-size: 1.15em;
            margin-top: 20px;
            margin-bottom: 12px;
            font-weight: 600;
        }

        .section-content p {
            margin-bottom: 15px;
            text-align: justify;
            color: #555;
        }

        .section-content ul {
            list-style: none;
            padding-left: 0;
        }

        .section-content ul li {
            padding: 10px 0 10px 30px;
            position: relative;
            color: #555;
        }

        .section-content ul li:before {
            content: "▸";
            color: #667eea;
            font-weight: bold;
            position: absolute;
            left: 0;
            font-size: 1.2em;
        }

        .highlight-box {
            background: linear-gradient(135deg, #e8f4f8 0%, #f0e8f8 100%);
            border-left: 4px solid #667eea;
            padding: 20px 25px;
            margin: 20px 0;
            border-radius: 12px;
        }

        .highlight-box strong {
            color: #667eea;
        }

        .warning-box {
            background: linear-gradient(135deg, #fff3cd 0%, #ffe8cd 100%);
            border-left: 4px solid #ffc107;
            padding: 20px 25px;
            margin: 20px 0;
            border-radius: 12px;
        }

        .warning-box strong {
            color: #d68910;
        }

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
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
            transition: all 0.3s ease;
            margin-bottom: 30px;
        }

        .back-button:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 25px rgba(102, 126, 234, 0.4);
        }

        .back-icon {
            font-size: 1.1em;
            transition: transform 0.3s ease;
        }

        .back-button:hover .back-icon {
            transform: translateX(-3px);
        }

        /* Footer - Giống hệt Home.jsp */
        footer {
            background: linear-gradient(135deg, #1a202c 0%, #2d3748 100%);
            color: #e2e8f0;
            padding: 80px 20px 40px;
            border-top: 1px solid #4a5568;
        }

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

            .content-card {
                padding: 30px 20px;
            }

            .section-title {
                font-size: 1.2em;
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
                <a href="index.jsp#features">Tính năng</a>
                <a href="index.jsp#contact">Liên hệ</a>

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
            <h1>Điều Khoản Dịch Vụ</h1>
            <p>Hệ Thống Quản Lý Quan Hệ Khách Hàng (CRM)</p>
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
                <h2 class="section-title">1. Định Nghĩa và Phạm Vi Áp Dụng</h2>
                <div class="section-content">
                    <h3>1.1. Định nghĩa các thuật ngữ</h3>
                    <ul>
                        <li><strong>Hợp đồng:</strong> Văn bản thỏa thuận giữa các bên được lưu trữ trong hệ thống CRM</li>
                        <li><strong>Phụ lục hợp đồng:</strong> Văn bản bổ sung hoặc sửa đổi nội dung hợp đồng chính</li>
                        <li><strong>Yêu cầu dịch vụ:</strong> Các yêu cầu chăm sóc và hỗ trợ khách hàng được tạo trong hệ thống</li>
                        <li><strong>Khách hàng:</strong> Đối tượng được quản lý thông tin trong hệ thống CRM</li>
                        <li><strong>Người dùng hệ thống:</strong> Cá nhân hoặc tổ chức sử dụng hệ thống CRM</li>
                    </ul>

                    <h3>1.2. Phạm vi áp dụng hệ thống</h3>
                    <p>Hệ thống CRM được áp dụng cho các chức năng:</p>
                    <ul>
                        <li>Tạo và quản lý hợp đồng điện tử</li>
                        <li>Quản lý thông tin khách hàng</li>
                        <li>Tạo và quản lý yêu cầu chăm sóc khách hàng</li>
                        <li>Quản lý phụ lục hợp đồng</li>
                        <li>Theo dõi và lưu trữ lịch sử làm việc với khách hàng</li>
                    </ul>
                </div>
            </div>

            <div class="section">
                <h2 class="section-title">2. Quyền và Nghĩa Vụ của Bên Cung Cấp Dịch Vụ</h2>
                <div class="section-content">
                    <h3>2.1. Quyền và cam kết cung cấp</h3>
                    <ul>
                        <li>Cung cấp nền tảng CRM với đầy đủ tính năng như mô tả</li>
                        <li>Bảo đảm thời gian hoạt động (uptime) trên 99%</li>
                        <li>Bảo đảm an toàn và bảo mật dữ liệu theo Nghị định 13/2023 về bảo vệ dữ liệu cá nhân</li>
                        <li>Cung cấp hỗ trợ kỹ thuật trong khung giờ quy định</li>
                        <li>Bảo mật tuyệt đối thông tin khách hàng, không tiết lộ cho bên thứ ba</li>
                    </ul>

                    <div class="highlight-box">
                        <strong>Lưu ý:</strong> Bên cung cấp không chịu trách nhiệm cho các thiệt hại phát sinh do người dùng tự nhập sai dữ liệu hoặc vận hành không đúng quy trình.
                    </div>
                </div>
            </div>

            <div class="section">
                <h2 class="section-title">3. Quyền và Nghĩa Vụ của Người Dùng</h2>
                <div class="section-content">
                    <h3>3.1. Trách nhiệm về dữ liệu</h3>
                    <p>Người dùng chịu trách nhiệm hoàn toàn về tính chính xác của:</p>
                    <ul>
                        <li>Dữ liệu thông tin khách hàng</li>
                        <li>Nội dung và thông tin trong hợp đồng</li>
                        <li>Thông tin trong các phụ lục hợp đồng</li>
                    </ul>

                    <h3>3.2. Nghĩa vụ tuân thủ</h3>
                    <ul>
                        <li>Sử dụng hệ thống đúng mục đích, không lạm dụng dữ liệu cá nhân của khách hàng</li>
                        <li>Tuân thủ Luật Bảo vệ quyền lợi người tiêu dùng 2023</li>
                        <li>Không được sao chép, reverse-engineer hoặc can thiệp trái phép vào hệ thống</li>
                    </ul>
                </div>
            </div>

            <div class="section">
                <h2 class="section-title">4. Điều Khoản Về Hợp Đồng Trong Hệ Thống</h2>
                <div class="section-content">
                    <h3>4.1. Hình thức hợp đồng</h3>
                    <p>Hợp đồng có thể được tạo dưới các dạng:</p>
                    <ul>
                        <li>Hợp đồng điện tử với chữ ký điện tử</li>
                        <li>Hợp đồng giấy được scan và upload vào hệ thống</li>
                        <li>Hợp đồng từ mẫu có sẵn do hệ thống cung cấp</li>
                    </ul>

                    <h3>4.2. Điều kiện có giá trị pháp lý</h3>
                    <p>Hợp đồng chỉ có giá trị khi:</p>
                    <ul>
                        <li>Có xác nhận đầy đủ từ các bên liên quan</li>
                        <li>Được ký điện tử (nếu hệ thống có tích hợp chức năng này)</li>
                        <li>Hoặc được ký tay và upload bản scan có chất lượng rõ ràng</li>
                    </ul>

                    <h3>4.3. Quy định chỉnh sửa</h3>
                    <div class="warning-box">
                        <strong>Quan trọng:</strong> Mọi thay đổi trên hợp đồng phải được ghi lại đầy đủ trong lịch sử thay đổi. Không được chỉnh sửa nội dung hợp đồng đã ký trừ khi tạo phụ lục hợp đồng mới.
                    </div>
                </div>
            </div>

            <div class="section">
                <h2 class="section-title">5. Điều Khoản Về Phụ Lục Hợp Đồng</h2>
                <div class="section-content">
                    <h3>5.1. Giá trị pháp lý</h3>
                    <p>Phụ lục hợp đồng có giá trị tương đương hợp đồng chính khi:</p>
                    <ul>
                        <li>Nội dung không trái với quy định pháp luật</li>
                        <li>Được ký kết bởi đầy đủ hai bên</li>
                    </ul>

                    <h3>5.2. Mục đích sử dụng phụ lục</h3>
                    <p>Phụ lục hợp đồng được sử dụng để:</p>
                    <ul>
                        <li>Thay đổi giá trị và điều khoản thanh toán</li>
                        <li>Gia hạn thời gian thực hiện hợp đồng</li>
                        <li>Bổ sung các dịch vụ mới</li>
                        <li>Cập nhật thông tin khách hàng</li>
                        <li>Điều chỉnh các điều khoản ràng buộc khác</li>
                    </ul>

                    <div class="highlight-box">
                        Mỗi phụ lục phải có mã định danh riêng và được liên kết rõ ràng đến hợp đồng gốc.
                    </div>
                </div>
            </div>

            <div class="section">
                <h2 class="section-title">6. Quản Lý Yêu Cầu Chăm Sóc Khách Hàng</h2>
                <div class="section-content">
                    <h3>6.1. Quyền tạo yêu cầu</h3>
                    <p>Người dùng hệ thống có quyền tạo và quản lý các yêu cầu chăm sóc khách hàng bao gồm:</p>
                    <ul>
                        <li>Nội dung chi tiết vấn đề cần xử lý</li>
                        <li>Thời gian tiếp nhận yêu cầu</li>
                        <li>Người chịu trách nhiệm xử lý</li>
                        <li>Thời hạn hoàn thành</li>
                    </ul>

                    <h3>6.2. Lưu trữ lịch sử</h3>
                    <p>Toàn bộ lịch sử chăm sóc khách hàng được lưu trữ tự động, phục vụ cho việc kiểm tra và giám sát chất lượng dịch vụ.</p>

                    <div class="warning-box">
                        Hệ thống CRM không chịu trách nhiệm nếu nhân viên bỏ sót yêu cầu hoặc xử lý chậm trễ so với cam kết.
                    </div>
                </div>
            </div>

            <div class="section">
                <h2 class="section-title">7. Bảo Vệ Dữ Liệu Cá Nhân</h2>
                <div class="section-content">
                    <h3>7.1. Tuân thủ pháp luật</h3>
                    <p>Hệ thống tuân thủ nghiêm ngặt:</p>
                    <ul>
                        <li>Nghị định 13/2023 về bảo vệ dữ liệu cá nhân</li>
                        <li>Luật An toàn thông tin mạng</li>
                        <li>Luật An ninh mạng</li>
                    </ul>

                    <h3>7.2. Thu thập và sử dụng dữ liệu</h3>
                    <div class="highlight-box">
                        <strong>Nguyên tắc:</strong> Mọi dữ liệu cá nhân của khách hàng chỉ được thu thập và nhập vào hệ thống khi có sự đồng ý rõ ràng từ chủ thể dữ liệu.
                    </div>

                    <h3>7.3. Quyền của khách hàng</h3>
                    <p>Khách hàng có đầy đủ các quyền:</p>
                    <ul>
                        <li>Yêu cầu xem, kiểm tra dữ liệu cá nhân của mình</li>
                        <li>Yêu cầu chỉnh sửa thông tin không chính xác</li>
                        <li>Yêu cầu xóa dữ liệu cá nhân</li>
                        <li>Rút lại sự đồng ý cho phép xử lý dữ liệu bất kỳ lúc nào</li>
                    </ul>

                    <h3>7.4. Trách nhiệm bảo vệ</h3>
                    <p>Doanh nghiệp sử dụng hệ thống có trách nhiệm:</p>
                    <ul>
                        <li>Mã hóa dữ liệu nhạy cảm</li>
                        <li>Hạn chế quyền truy cập theo phân quyền</li>
                        <li>Thông báo kịp thời khi có sự cố rò rỉ dữ liệu</li>
                    </ul>
                </div>
            </div>

            <div class="section">
                <h2 class="section-title">8. Lưu Trữ và Sao Lưu Dữ Liệu</h2>
                <div class="section-content">
                    <h3>8.1. Thời gian lưu trữ</h3>
                    <p>Dữ liệu hợp đồng, phụ lục và thông tin khách hàng được lưu trữ tối thiểu theo quy định pháp luật hiện hành về lưu trữ tài liệu kế toán và hợp đồng thương mại.</p>

                    <h3>8.2. Cơ chế sao lưu</h3>
                    <ul>
                        <li>Sao lưu tự động theo chu kỳ: hàng ngày, hàng tuần, hàng tháng</li>
                        <li>Cung cấp cơ chế phục hồi dữ liệu (disaster recovery)</li>
                        <li>Lưu trữ bản sao lưu tại nhiều vị trí khác nhau</li>
                    </ul>
                </div>
            </div>

            <div class="section">
                <h2 class="section-title">9. Bảo Mật Hệ Thống</h2>
                <div class="section-content">
                    <h3>9.1. Biện pháp bảo mật kỹ thuật</h3>
                    <ul>
                        <li>Mã hóa truyền tải dữ liệu qua giao thức TLS/HTTPS</li>
                        <li>Chứng chỉ SSL/TLS chuẩn doanh nghiệp</li>
                        <li>Cơ chế phát hiện và cảnh báo truy cập bất thường</li>
                        <li>Xác thực đa yếu tố (2FA) cho tài khoản quan trọng</li>
                    </ul>

                    <h3>9.2. Phân quyền theo vai trò</h3>
                    <p>Hệ thống phân quyền chi tiết theo các vai trò:</p>
                    <ul>
                        <li><strong>Admin:</strong> Toàn quyền quản trị hệ thống</li>
                        <li><strong>Sales:</strong> Quản lý khách hàng và hợp đồng</li>
                        <li><strong>CSKH:</strong> Xử lý yêu cầu chăm sóc khách hàng</li>
                        <li><strong>Điều phối:</strong> Theo dõi và phân công công việc</li>
                        <li><strong>Kế toán:</strong> Truy cập thông tin tài chính và thanh toán</li>
                    </ul>
                </div>
            </div>

            <div class="section">
                <h2 class="section-title">10. Trách Nhiệm Pháp Lý</h2>
                <div class="section-content">
                    <h3>10.1. Giới hạn trách nhiệm của nhà cung cấp</h3>
                    <p>Bên cung cấp dịch vụ không chịu trách nhiệm cho các thiệt hại phát sinh từ:</p>
                    <ul>
                        <li>Lỗi vận hành từ phía người dùng</li>
                        <li>Nhập sai hoặc thiếu dữ liệu</li>
                        <li>Sử dụng hệ thống trái mục đích hoặc vi phạm pháp luật</li>
                        <li>Sự cố bất khả kháng như thiên tai, mất điện, đứt cáp mạng</li>
                    </ul>

                    <h3>10.2. Trách nhiệm của doanh nghiệp</h3>
                    <p>Doanh nghiệp sử dụng hệ thống chịu trách nhiệm đầy đủ về:</p>
                    <ul>
                        <li>Nội dung các hợp đồng được lưu trữ trong hệ thống</li>
                        <li>Nghĩa vụ thuế phát sinh từ các giao dịch</li>
                        <li>Nghĩa vụ pháp lý đối với khách hàng</li>
                        <li>Tuân thủ chuẩn mực kế toán và thương mại Việt Nam</li>
                    </ul>
                </div>
            </div>

            <div class="section">
                <h2 class="section-title">11. Điều Khoản Thanh Toán</h2>
                <div class="section-content">
                    <h3>11.1. Hình thức thanh toán</h3>
                    <p>Phí sử dụng hệ thống CRM được tính theo:</p>
                    <ul>
                        <li>Gói đăng ký theo tháng</li>
                        <li>Gói đăng ký theo năm (có ưu đãi)</li>
                        <li>Gói theo số lượng người dùng (user)</li>
                    </ul>

                    <h3>11.2. Chính sách hoàn tiền</h3>
                    <p>Không hoàn tiền cho các trường hợp hủy dịch vụ giữa kỳ (có thể thay đổi tùy theo gói dịch vụ cụ thể).</p>

                    <h3>11.3. Xử lý chậm thanh toán</h3>
                    <div class="warning-box">
                        Trong trường hợp chậm thanh toán quá hạn, hệ thống có quyền tạm khóa tài khoản cho đến khi hoàn tất nghĩa vụ thanh toán.
                    </div>
                </div>
            </div>

            <div class="section">
                <h2 class="section-title">12. Chấm Dứt Dịch Vụ</h2>
                <div class="section-content">
                    <h3>12.1. Điều kiện chấm dứt</h3>
                    <p>Một bên có quyền chấm dứt hợp đồng trong các trường hợp:</p>
                    <ul>
                        <li>Vi phạm nghiêm trọng các điều khoản bảo mật</li>
                        <li>Sử dụng hệ thống cho mục đích phi pháp</li>
                        <li>Không thực hiện nghĩa vụ thanh toán sau thời hạn nhắc nhở</li>
                    </ul>

                    <h3>12.2. Quyền lợi khi kết thúc</h3>
                    <div class="highlight-box">
                        <strong>Cam kết:</strong> Trước khi khóa tài khoản, hệ thống sẽ cho phép khách hàng export toàn bộ dữ liệu của mình ở định dạng phù hợp.
                    </div>
                </div>
            </div>

            <div class="section">
                <h2 class="section-title">13. Giải Quyết Tranh Chấp</h2>
                <div class="section-content">
                    <h3>13.1. Phương thức giải quyết</h3>
                    <p>Khi phát sinh tranh chấp, các bên cam kết:</p>
                    <ul>
                        <li>Ưu tiên giải quyết thông qua thương lượng, hòa giải</li>
                        <li>Nếu không đạt được thỏa thuận, tranh chấp sẽ được giải quyết tại Trung tâm Trọng tài Quốc tế Việt Nam (VIAC)</li>
                        <li>Hoặc giải quyết tại Tòa án có thẩm quyền theo pháp luật Việt Nam</li>
                    </ul>

                    <h3>13.2. Luật áp dụng</h3>
                    <p>Điều khoản dịch vụ này được điều chỉnh bởi:</p>
                    <ul>
                        <li>Bộ luật Dân sự Việt Nam</li>
                        <li>Luật Thương mại</li>
                        <li>Luật Giao dịch điện tử</li>
                        <li>Luật Bảo vệ dữ liệu cá nhân và các văn bản hướng dẫn</li>
                    </ul>
                </div>
            </div>

            <div style="margin-top: 60px; padding-top: 30px; border-top: 2px solid #ecf0f1; text-align: center;">
                <p style="font-size: 16px; font-weight: 600; color: #667eea; margin-bottom: 15px;">
                    <strong>Bằng việc sử dụng hệ thống CRM, bạn đã đồng ý với toàn bộ các điều khoản dịch vụ nêu trên.</strong>
                </p>
                <p style="color: #7f8c8d;">Mọi thắc mắc xin vui lòng liên hệ bộ phận hỗ trợ khách hàng của chúng tôi.</p>
            </div>
        </div>
    </div>

    <!-- Footer - Giống hệt Home.jsp -->
    <footer>
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
                        <li style="margin-bottom: 12px;"><a href="index.jsp#features" style="color: #cbd5e0; text-decoration: none; font-size: 14px; transition: all 0.3s; display: inline-block;">→ Quản lý khách hàng</a></li>
                        <li style="margin-bottom: 12px;"><a href="index.jsp#features" style="color: #cbd5e0; text-decoration: none; font-size: 14px; transition: all 0.3s; display: inline-block;">→ Quản lý hợp đồng</a></li>
                        <li style="margin-bottom: 12px;"><a href="index.jsp#features" style="color: #cbd5e0; text-decoration: none; font-size: 14px; transition: all 0.3s; display: inline-block;">→ Quản lý thiết bị</a></li>
                        <li style="margin-bottom: 12px;"><a href="index.jsp#features" style="color: #cbd5e0; text-decoration: none; font-size: 14px; transition: all 0.3s; display: inline-block;">→ Báo cáo & Phân tích</a></li>
                        <li style="margin-bottom: 12px;"><a href="index.jsp#features" style="color: #cbd5e0; text-decoration: none; font-size: 14px; transition: all 0.3s; display: inline-block;">→ Quản lý yêu cầu dịch vụ</a></li>
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
                        <li style="margin-bottom: 12px;"><a href="about.jsp" style="color: #cbd5e0; text-decoration: none; font-size: 14px; transition: all 0.3s; display: inline-block;">→ Về chúng tôi</a></li>
                        <li style="margin-bottom: 12px;"><a href="tos.jsp" style="color: #cbd5e0; text-decoration: none; font-size: 14px; transition: all 0.3s; display: inline-block;">→ Điều khoản sử dụng</a></li>
                        <li style="margin-bottom: 12px;"><a href="baohanh.jsp" style="color: #cbd5e0; text-decoration: none; font-size: 14px; transition: all 0.3s; display: inline-block;">→ Chính sách bảo hành</a></li>
                        <li style="margin-bottom: 12px;"><a href="baogia.jsp" style="color: #cbd5e0; text-decoration: none; font-size: 14px; transition: all 0.3s; display: inline-block;">→ Báo giá dịch vụ</a></li>
                        
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
                    <a href="tos.jsp" style="color: #cbd5e0; text-decoration: none; transition: color 0.3s;">Điều khoản dịch vụ</a>
                    <span style="color: #4a5568;">|</span>
                    <a href="#" style="color: #cbd5e0; text-decoration: none; transition: color 0.3s;">Cài đặt Cookie</a>
                </div>
            </div>
        </div>
    </footer>
</body>
</html>
