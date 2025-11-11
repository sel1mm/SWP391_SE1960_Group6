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
    <title>Điều Khoản Dịch Vụ - Hệ Thống CRM</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.8;
            color: #2c3e50;
            background: linear-gradient(135deg, #f5f7fa 0%, #e8eef3 100%);
            padding: 40px 20px;
        }

        .container {
            max-width: 900px;
            margin: 0 auto;
            background: white;
            padding: 50px;
            border-radius: 20px;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.1);
        }

        .header {
            text-align: center;
            margin-bottom: 50px;
            padding-bottom: 30px;
            border-bottom: 3px solid #3498db;
        }

        .header h1 {
            font-size: 2.5em;
            color: #2c3e50;
            margin-bottom: 10px;
            font-weight: 700;
        }

        .header p {
            color: #7f8c8d;
            font-size: 1.1em;
        }

        .last-updated {
            background: #ecf0f1;
            padding: 15px;
            border-radius: 10px;
            text-align: center;
            margin-bottom: 40px;
            color: #34495e;
            font-size: 0.95em;
        }

        .section {
            margin-bottom: 40px;
        }

        .section-title {
            font-size: 1.4em;
            color: #2c3e50;
            margin-bottom: 20px;
            padding-left: 20px;
            border-left: 5px solid #3498db;
            font-weight: 600;
        }

        .section-content {
            padding-left: 25px;
        }

        .section-content h3 {
            color: #34495e;
            font-size: 1.1em;
            margin-top: 20px;
            margin-bottom: 12px;
            font-weight: 600;
        }

        .section-content p {
            margin-bottom: 15px;
            text-align: justify;
        }

        .section-content ul {
            list-style: none;
            padding-left: 0;
        }

        .section-content ul li {
            padding: 10px 0 10px 30px;
            position: relative;
        }

        .section-content ul li:before {
            content: "▸";
            color: #3498db;
            font-weight: bold;
            position: absolute;
            left: 0;
            font-size: 1.2em;
        }

        .highlight-box {
            background: #e8f4f8;
            border-left: 4px solid #3498db;
            padding: 20px;
            margin: 20px 0;
            border-radius: 8px;
        }

        .highlight-box strong {
            color: #2980b9;
        }

        .warning-box {
            background: #fff3cd;
            border-left: 4px solid #ffc107;
            padding: 20px;
            margin: 20px 0;
            border-radius: 8px;
        }

        .footer {
            margin-top: 60px;
            padding-top: 30px;
            border-top: 2px solid #ecf0f1;
            text-align: center;
            color: #7f8c8d;
            font-size: 0.9em;
        }

        .back-button {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 20px;
            background: white;
            color: #3498db;
            text-decoration: none;
            border-radius: 8px;
            font-weight: 600;
            font-size: 0.95em;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.08);
            transition: all 0.3s ease;
            margin-bottom: 20px;
        }

        .back-button:hover {
            background: #3498db;
            color: white;
            transform: translateX(-3px);
            box-shadow: 0 4px 15px rgba(52, 152, 219, 0.3);
        }

        .back-icon {
            font-size: 1.1em;
            transition: transform 0.3s ease;
        }

        .back-button:hover .back-icon {
            transform: translateX(-3px);
        }

        @media (max-width: 768px) {
            .container {
                padding: 30px 20px;
            }

            .header h1 {
                font-size: 1.8em;
            }

            .section-title {
                font-size: 1.2em;
            }

            .back-button {
                font-size: 0.9em;
                padding: 8px 16px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <a href="${pageContext.request.contextPath}/" class="back-button">
            <span class="back-icon">←</span>
            Về Homepage
        </a>

        <div class="header">
            <h1>ĐIỀU KHOẢN DỊCH VỤ</h1>
            <p>Hệ Thống Quản Lý Quan Hệ Khách Hàng (CRM)</p>
        </div>

        <div class="last-updated">
            Cập nhật lần cuối: <%= formattedDate %>
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

        <div class="footer">
            <p><strong>Bằng việc sử dụng hệ thống CRM, bạn đã đồng ý với toàn bộ các điều khoản dịch vụ nêu trên.</strong></p>
            <p style="margin-top: 20px;">Mọi thắc mắc xin vui lòng liên hệ bộ phận hỗ trợ khách hàng của chúng tôi.</p>
            <p style="margin-top: 10px; color: #95a5a6;">© <%= currentDate.getYear() %> Hệ Thống CRM. Bảo lưu mọi quyền.</p>
        </div>
    </div>
</body>
</html>