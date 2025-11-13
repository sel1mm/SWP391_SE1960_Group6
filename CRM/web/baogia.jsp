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

            /* Pricing Section */
            .pricing-section {
                max-width: 1200px;
                margin: -50px auto 80px;
                padding: 0 20px;
                position: relative;
                z-index: 10;
            }

            .pricing-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
                gap: 30px;
                margin-bottom: 60px;
            }

            .pricing-card {
                background: white;
                border-radius: 20px;
                padding: 40px;
                box-shadow: 0 20px 60px rgba(0,0,0,0.15);
                transition: all 0.3s;
                position: relative;
                overflow: hidden;
            }

            .pricing-card:hover {
                transform: translateY(-10px);
                box-shadow: 0 25px 70px rgba(102,126,234,0.3);
            }

            .pricing-card.featured {
                border: 3px solid #667eea;
                transform: scale(1.05);
            }

            .pricing-card.featured::before {
                content: 'PHỔ BIẾN NHẤT';
                position: absolute;
                top: 20px;
                right: -35px;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                padding: 5px 40px;
                transform: rotate(45deg);
                font-size: 12px;
                font-weight: 700;
                letter-spacing: 1px;
            }

            .pricing-header {
                text-align: center;
                margin-bottom: 30px;
            }

            .pricing-icon {
                font-size: 50px;
                margin-bottom: 15px;
            }

            .pricing-title {
                font-size: 28px;
                font-weight: 700;
                color: #2d3748;
                margin-bottom: 10px;
            }

            .pricing-subtitle {
                font-size: 14px;
                color: #666;
                margin-bottom: 20px;
            }

            .pricing-price {
                font-size: 48px;
                font-weight: 700;
                color: #667eea;
                margin-bottom: 5px;
            }

            .pricing-price span {
                font-size: 18px;
                color: #666;
                font-weight: 400;
            }

            .pricing-period {
                font-size: 14px;
                color: #999;
                margin-bottom: 30px;
            }

            .pricing-features {
                list-style: none;
                margin-bottom: 30px;
            }

            .pricing-features li {
                padding: 12px 0;
                font-size: 15px;
                color: #555;
                border-bottom: 1px solid #f0f0f0;
                display: flex;
                align-items: center;
                gap: 10px;
            }

            .pricing-features li:last-child {
                border-bottom: none;
            }

            .feature-icon {
                color: #667eea;
                font-weight: 700;
            }

            .feature-disabled {
                color: #ccc !important;
            }

            .pricing-button {
                width: 100%;
                padding: 16px;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                border: none;
                border-radius: 12px;
                font-size: 16px;
                font-weight: 600;
                cursor: pointer;
                transition: all 0.3s;
            }

            .pricing-button:hover {
                transform: translateY(-3px);
                box-shadow: 0 10px 30px rgba(102,126,234,0.4);
            }

            .pricing-button.outline {
                background: transparent;
                border: 2px solid #667eea;
                color: #667eea;
            }

            .pricing-button.outline:hover {
                background: #667eea;
                color: white;
            }

            /* Services Section */
            .services-section {
                max-width: 1200px;
                margin: 0 auto 80px;
                padding: 0 20px;
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

            /* Comparison Table */
            .comparison-section {
                max-width: 1200px;
                margin: 0 auto 80px;
                padding: 0 20px;
            }

            .comparison-table {
                background: white;
                border-radius: 20px;
                box-shadow: 0 20px 60px rgba(0,0,0,0.15);
                overflow: hidden;
            }

            .comparison-table table {
                width: 100%;
                border-collapse: collapse;
            }

            .comparison-table th {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                padding: 20px;
                font-weight: 600;
                font-size: 16px;
                text-align: left;
            }

            .comparison-table td {
                padding: 18px 20px;
                border-bottom: 1px solid #f0f0f0;
                font-size: 14px;
            }

            .comparison-table tr:hover {
                background: #f8f9fc;
            }

            .check-icon {
                color: #667eea;
                font-weight: 700;
                font-size: 18px;
            }

            .cross-icon {
                color: #ccc;
                font-weight: 700;
                font-size: 18px;
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
                background: linear-gradient(135deg, #1a202c 0%, #2d3748 100%);
                color: #e2e8f0;
                padding: 60px 20px 30px;
                border-top: 1px solid #4a5568;
            }

            .footer-content {
                max-width: 1200px;
                margin: 0 auto;
                text-align: center;
            }

            .footer-content p {
                font-size: 13px;
                color: #a0aec0;
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

                .pricing-grid {
                    grid-template-columns: 1fr;
                }

                .pricing-card.featured {
                    transform: scale(1);
                }

                .services-grid {
                    grid-template-columns: 1fr;
                }

                .comparison-table {
                    overflow-x: auto;
                }

                .section-title {
                    font-size: 28px;
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
                    <a href="pricing.jsp">Báo giá</a>
                    <a href="login">Đăng nhập</a>
                </div>
            </div>
        </nav>

        <!-- Hero Section -->
        <section class="hero">
            <h1>Báo Giá Dịch Vụ</h1>
            <p>Lựa chọn gói dịch vụ phù hợp với nhu cầu quản lý khách hàng và thiết bị của doanh nghiệp bạn</p>
        </section>

        <!-- Pricing Cards -->
        <section class="pricing-section">
            <div class="pricing-grid">
                <!-- Basic Plan -->
                <div class="pricing-card">
                    <div class="pricing-header">
                        <div class="pricing-icon">🌱</div>
                        <h3 class="pricing-title">Gói Cơ Bản</h3>
                        <p class="pricing-subtitle">Dành cho doanh nghiệp nhỏ</p>
                        <div class="pricing-price">2.900.000₫<span>/tháng</span></div>
                        <p class="pricing-period">Thanh toán hàng tháng</p>
                    </div>
                    <ul class="pricing-features">
                        <li><span class="feature-icon">✓</span> Quản lý tối đa 100 khách hàng</li>
                        <li><span class="feature-icon">✓</span> 3 tài khoản người dùng</li>
                        <li><span class="feature-icon">✓</span> Quản lý hợp đồng cơ bản</li>
                        <li><span class="feature-icon">✓</span> Báo cáo cơ bản</li>
                        <li><span class="feature-icon">✓</span> Hỗ trợ email</li>
                        <li><span class="feature-icon feature-disabled">✗</span> Quản lý thiết bị nâng cao</li>
                        <li><span class="feature-icon feature-disabled">✗</span> API tích hợp</li>
                    </ul>
                    <button class="pricing-button outline">Chọn gói này</button>
                </div>

                <!-- Professional Plan -->
                <div class="pricing-card featured">
                    <div class="pricing-header">
                        <div class="pricing-icon">🚀</div>
                        <h3 class="pricing-title">Gói Chuyên Nghiệp</h3>
                        <p class="pricing-subtitle">Dành cho doanh nghiệp vừa</p>
                        <div class="pricing-price">5.900.000₫<span>/tháng</span></div>
                        <p class="pricing-period">Thanh toán hàng tháng</p>
                    </div>
                    <ul class="pricing-features">
                        <li><span class="feature-icon">✓</span> Quản lý không giới hạn khách hàng</li>
                        <li><span class="feature-icon">✓</span> 10 tài khoản người dùng</li>
                        <li><span class="feature-icon">✓</span> Quản lý hợp đồng & thiết bị</li>
                        <li><span class="feature-icon">✓</span> Báo cáo nâng cao</li>
                        <li><span class="feature-icon">✓</span> Hỗ trợ 24/7</li>
                        <li><span class="feature-icon">✓</span> Quản lý bảo trì định kỳ</li>
                        <li><span class="feature-icon">✓</span> API tích hợp cơ bản</li>
                    </ul>
                    <button class="pricing-button">Chọn gói này</button>
                </div>

                <!-- Enterprise Plan -->
                <div class="pricing-card">
                    <div class="pricing-header">
                        <div class="pricing-icon">👑</div>
                        <h3 class="pricing-title">Gói Doanh Nghiệp</h3>
                        <p class="pricing-subtitle">Giải pháp toàn diện</p>
                        <div class="pricing-price">Liên hệ</div>
                        <p class="pricing-period">Tùy chỉnh theo nhu cầu</p>
                    </div>
                    <ul class="pricing-features">
                        <li><span class="feature-icon">✓</span> Không giới hạn mọi tính năng</li>
                        <li><span class="feature-icon">✓</span> Không giới hạn người dùng</li>
                        <li><span class="feature-icon">✓</span> Tùy chỉnh theo yêu cầu</li>
                        <li><span class="feature-icon">✓</span> Phân tích dữ liệu AI</li>
                        <li><span class="feature-icon">✓</span> Hỗ trợ ưu tiên 24/7</li>
                        <li><span class="feature-icon">✓</span> API không giới hạn</li>
                        <li><span class="feature-icon">✓</span> Đào tạo & Tư vấn</li>
                    </ul>
                    <button class="pricing-button">Liên hệ tư vấn</button>
                </div>
            </div>
        </section>

        <!-- Additional Services -->
        <section class="services-section">
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
        </section>

        <!-- Comparison Table -->
        <section class="comparison-section">
            <h2 class="section-title">So Sánh Chi Tiết Các Gói</h2>
            <p class="section-subtitle">Xem chi tiết tính năng của từng gói dịch vụ</p>
            
            <div class="comparison-table">
                <table>
                    <thead>
                        <tr>
                            <th>Tính năng</th>
                            <th>Gói Cơ Bản</th>
                            <th>Gói Chuyên Nghiệp</th>
                            <th>Gói Doanh Nghiệp</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td><strong>Số lượng khách hàng</strong></td>
                            <td>Tối đa 100</td>
                            <td>Không giới hạn</td>
                            <td>Không giới hạn</td>
                        </tr>
                        <tr>
                            <td><strong>Tài khoản người dùng</strong></td>
                            <td>3 tài khoản</td>
                            <td>10 tài khoản</td>
                            <td>Không giới hạn</td>
                        </tr>
                        <tr>
                            <td><strong>Quản lý hợp đồng</strong></td>
                            <td><span class="check-icon">✓</span></td>
                            <td><span class="check-icon">✓</span></td>
                            <td><span class="check-icon">✓</span></td>
                        </tr>
                        <tr>
                            <td><strong>Quản lý thiết bị</strong></td>
                            <td><span class="cross-icon">✗</span></td>
                            <td><span class="check-icon">✓</span></td>
                            <td><span class="check-icon">✓</span></td>
                        </tr>
                        <tr>
                            <td><strong>Quản lý bảo trì</strong></td>
                            <td><span class="cross-icon">✗</span></td>
                            <td><span class="check-icon">✓</span></td>
                            <td><span class="check-icon">✓</span></td>
                        </tr>
                        <tr>
                            <td><strong>Báo cáo & Thống kê</strong></td>
                            <td>Cơ bản</td>
                            <td>Nâng cao</td>
                            <td>Phân tích AI</td>
                        </tr>
                        <tr>
                            <td><strong>API tích hợp</strong></td>
                            <td><span class="cross-icon">✗</span></td>
                            <td>Cơ bản</td>
                            <td>Không giới hạn</td>
                        </tr>
                        <tr>
                            <td><strong>Hỗ trợ khách hàng</strong></td>
                            <td>Email</td>
                            <td>24/7</td>
                            <td>Ưu tiên 24/7</td>
                        </tr>
                        <tr>
                            <td><strong>Đào tạo</strong></td>
                            <td><span class="cross-icon">✗</span></td>
                            <td>Video hướng dẫn</td>
                            <td>Tận nơi</td>
                        </tr>
                        <tr>
                            <td><strong>Tùy chỉnh hệ thống</strong></td>
                            <td><span class="cross-icon">✗</span></td>
                            <td><span class="cross-icon">✗</span></td>
                            <td><span class="check-icon">✓</span></td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </section>

        <!-- CTA Section -->
        <section class="cta-section">
            <div class="cta-content">
                <h2>Bạn cần tư vấn thêm?</h2>
                <p>Đội ngũ chuyên gia của chúng tôi sẵn sàng hỗ trợ bạn lựa chọn gói dịch vụ phù hợp nhất</p>
                <div class="cta-buttons">
                    <a href="#" class="btn btn-white">Liên hệ ngay</a>
                    <a href="#" class="btn btn-outline">Đặt lịch tư vấn</a>
                </div>
            </div>
        </section>

        <!-- Footer -->
        <footer>
            <div class="footer-content">
                <p>&copy; 2025 CRM System. All rights reserved. | Phát triển bởi <strong>Group 6</strong></p>
            </div>
        </footer>
    </body>
</html>