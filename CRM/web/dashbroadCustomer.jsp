<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - CRM System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f8f9fa;
            overflow-x: hidden;
        }

        /* SIDEBAR STYLES */
        .sidebar {
            position: fixed;
            top: 0;
            left: 0;
            height: 100vh;
            width: 260px;
            background: #000000;
            padding: 0;
            transition: all 0.3s ease;
            z-index: 1000;
            box-shadow: 4px 0 10px rgba(0,0,0,0.1);
            display: flex;
            flex-direction: column;
        }

        .sidebar.collapsed {
            width: 70px;
        }

        .sidebar-header {
            padding: 25px 20px;
            background: rgba(0,0,0,0.2);
            border-bottom: 1px solid rgba(255,255,255,0.1);
        }

        .sidebar-brand {
            display: flex;
            align-items: center;
            gap: 12px;
            color: white;
            text-decoration: none;
            font-size: 1.4rem;
            font-weight: 700;
            transition: all 0.3s;
        }

        .sidebar-brand i {
            font-size: 2rem;
            color: #ffc107;
        }

        .sidebar.collapsed .sidebar-brand span {
            display: none;
        }

        .sidebar-menu {
            flex: 1;
            padding: 20px 0;
            overflow-y: auto;
            overflow-x: hidden;
        }

        .menu-item {
            display: flex;
            align-items: center;
            padding: 14px 20px;
            color: rgba(255,255,255,0.8);
            text-decoration: none;
            transition: all 0.3s;
            position: relative;
            margin: 2px 10px;
            border-radius: 8px;
        }

        .menu-item:hover {
            background: rgba(255,255,255,0.1);
            color: white;
            transform: translateX(5px);
        }

        .menu-item.active {
            background: rgba(255,255,255,0.15);
            color: white;
            border-left: 4px solid #ffc107;
        }

        .menu-item i {
            font-size: 1.2rem;
            width: 30px;
            text-align: center;
        }

        .menu-item span {
            margin-left: 12px;
            font-size: 0.95rem;
        }

        .sidebar.collapsed .menu-item span {
            display: none;
        }

        .sidebar-footer {
            padding: 20px;
            border-top: 1px solid rgba(255,255,255,0.1);
            background: rgba(0,0,0,0.2);
        }

        .user-info {
            display: flex;
            align-items: center;
            gap: 12px;
            color: white;
            margin-bottom: 15px;
            padding: 10px;
            background: rgba(255,255,255,0.1);
            border-radius: 8px;
        }

        .user-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: linear-gradient(135deg, #ffc107, #ff9800);
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            font-size: 1.1rem;
            color: white;
        }

        .sidebar.collapsed .user-details {
            display: none;
        }

        .btn-logout {
            width: 100%;
            padding: 12px;
            background: transparent;
            color: white;
            border: 1px solid white;
            border-radius: 8px;
            font-weight: 600;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            transition: all 0.3s;
            cursor: pointer;
            text-decoration: none;
        }

        .btn-logout:hover {
            background: white;
            color: #1a1a2e;
        }

        .sidebar-toggle {
            position: absolute;
            top: 25px;
            right: -15px;
            width: 30px;
            height: 30px;
            background: white;
            border: 2px solid #1e3c72;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            color: #1e3c72;
            transition: all 0.3s;
        }

        .main-content {
            margin-left: 260px;
            transition: all 0.3s ease;
            min-height: 100vh;
        }

        .sidebar.collapsed ~ .main-content {
            margin-left: 70px;
        }

        .top-navbar {
            background: white;
            padding: 20px 30px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        .page-title {
            font-size: 1.5rem;
            font-weight: 700;
            color: #1e3c72;
        }

        .content-wrapper {
            padding: 30px;
        }

        .dashboard-cards {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-top: 20px;
        }

        .dashboard-card {
            background: white;
            border-radius: 10px;
            padding: 30px;
            text-align: center;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            transition: all 0.3s;
            cursor: pointer;
            text-decoration: none;
            color: inherit;
        }

        .dashboard-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 4px 16px rgba(0,0,0,0.15);
        }

        /* CHATBOT STYLES */
        .chatbot-container {
            position: fixed;
            bottom: 30px;
            right: 30px;
            z-index: 999;
        }

        .chatbot-button {
            width: 60px;
            height: 60px;
            border-radius: 50%;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border: none;
            box-shadow: 0 4px 20px rgba(102, 126, 234, 0.5);
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s;
            position: relative;
        }

        .chatbot-button:hover {
            transform: scale(1.1);
            box-shadow: 0 6px 25px rgba(102, 126, 234, 0.6);
        }

        .chatbot-button i {
            color: white;
            font-size: 24px;
        }

        .chatbot-badge {
            position: absolute;
            top: -5px;
            right: -5px;
            width: 20px;
            height: 20px;
            background: #ff4757;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 10px;
            color: white;
            font-weight: bold;
            animation: pulse 2s infinite;
        }

        @keyframes pulse {
            0%, 100% { transform: scale(1); }
            50% { transform: scale(1.1); }
        }

        .chatbot-window {
            position: fixed;
            bottom: 100px;
            right: 30px;
            width: 420px;
            height: 650px;
            background: white;
            border-radius: 20px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            display: none;
            flex-direction: column;
            overflow: hidden;
            animation: slideUp 0.3s ease-out;
        }

        @keyframes slideUp {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .chatbot-window.active {
            display: flex;
        }

        .chatbot-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .chatbot-header h4 {
            margin: 0;
            font-size: 1.1rem;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .chatbot-close {
            background: rgba(255,255,255,0.2);
            border: none;
            width: 30px;
            height: 30px;
            border-radius: 50%;
            cursor: pointer;
            color: white;
            transition: all 0.3s;
        }

        .chatbot-close:hover {
            background: rgba(255,255,255,0.3);
        }

        /* CHATBOT RECOMMENDATIONS */
        .chatbot-recommendations {
            padding: 15px 20px;
            background: white;
            border-bottom: 1px solid #eee;
            max-height: 150px;
            overflow-y: auto;
        }

        .recommendations-title {
            font-size: 0.8rem;
            color: #667eea;
            font-weight: 600;
            margin-bottom: 10px;
            display: flex;
            align-items: center;
            gap: 5px;
        }

        .recommendation-chips {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
        }

        .recommendation-chip {
            background: #f8f9fa;
            border: 1px solid #e0e0e0;
            border-radius: 20px;
            padding: 6px 12px;
            font-size: 0.75rem;
            color: #333;
            cursor: pointer;
            transition: all 0.3s;
            white-space: nowrap;
            max-width: 100%;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .recommendation-chip:hover {
            background: #667eea;
            color: white;
            border-color: #667eea;
            transform: translateY(-2px);
        }

        .recommendation-category {
            width: 100%;
            font-size: 0.7rem;
            color: #888;
            margin-top: 5px;
            margin-bottom: 3px;
            font-weight: 500;
        }

        /* Scrollbar for recommendations */
        .chatbot-recommendations::-webkit-scrollbar {
            width: 4px;
        }

        .chatbot-recommendations::-webkit-scrollbar-thumb {
            background: #ddd;
            border-radius: 10px;
        }

        .chatbot-messages {
            flex: 1;
            padding: 20px;
            overflow-y: auto;
            background: #f8f9fa;
        }

        .chatbot-messages::-webkit-scrollbar {
            width: 6px;
        }

        .chatbot-messages::-webkit-scrollbar-thumb {
            background: #ddd;
            border-radius: 10px;
        }

        .message {
            margin-bottom: 15px;
            display: flex;
            gap: 10px;
            animation: fadeIn 0.3s;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .message.bot {
            justify-content: flex-start;
        }

        .message.user {
            justify-content: flex-end;
        }

        .message-avatar {
            width: 35px;
            height: 35px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 18px;
            flex-shrink: 0;
        }

        .message.bot .message-avatar {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }

        .message.user .message-avatar {
            background: #ffc107;
            color: white;
        }

        .message-content {
            max-width: 70%;
            padding: 12px 16px;
            border-radius: 18px;
            line-height: 1.5;
            font-size: 0.9rem;
        }

        .message.bot .message-content {
            background: white;
            color: #333;
            border-bottom-left-radius: 4px;
        }

        .message.user .message-content {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-bottom-right-radius: 4px;
        }

        .typing-indicator {
            display: flex;
            gap: 4px;
            padding: 12px 16px;
            background: white;
            border-radius: 18px;
            width: fit-content;
        }

        .typing-dot {
            width: 8px;
            height: 8px;
            background: #667eea;
            border-radius: 50%;
            animation: typing 1.4s infinite;
        }

        .typing-dot:nth-child(2) { animation-delay: 0.2s; }
        .typing-dot:nth-child(3) { animation-delay: 0.4s; }

        @keyframes typing {
            0%, 60%, 100% { transform: translateY(0); }
            30% { transform: translateY(-10px); }
        }

        .chatbot-input {
            padding: 20px;
            background: white;
            border-top: 1px solid #eee;
            display: flex;
            gap: 10px;
        }

        .chatbot-input input {
            flex: 1;
            border: 1px solid #ddd;
            border-radius: 25px;
            padding: 12px 20px;
            font-size: 0.9rem;
            outline: none;
            transition: all 0.3s;
        }

        .chatbot-input input:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }

        .chatbot-send {
            width: 45px;
            height: 45px;
            border-radius: 50%;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border: none;
            color: white;
            cursor: pointer;
            transition: all 0.3s;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .chatbot-send:hover:not(:disabled) {
            transform: scale(1.1);
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
        }

        .chatbot-send:disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }

        @media (max-width: 768px) {
            .chatbot-window {
                width: calc(100vw - 30px);
                right: 15px;
            }
        }
        .message.bot .message-content {
    background: white;
    color: #333;
    border-bottom-left-radius: 4px;
    white-space: pre-line; /* QUAN TRỌNG: giữ nguyên xuống dòng */
    word-wrap: break-word;
    overflow-wrap: break-word;
    line-height: 1.5;
}

.message.bot .message-content strong {
    color: #1e3c72;
    font-weight: 600;
}

.message.bot .message-content br {
    display: block;
    content: "";
    margin-bottom: 8px;
}

/* Đảm bảo danh sách hiển thị đẹp */
.message.bot .message-content ul,
.message.bot .message-content ol {
    margin: 8px 0;
    padding-left: 20px;
}

.message.bot .message-content li {
    margin-bottom: 4px;
    line-height: 1.4;
}
    </style>
</head>
<body>
    <!-- SIDEBAR -->
    <div class="sidebar" id="sidebar">
        <div class="sidebar-toggle" onclick="toggleSidebar()">
            <i class="fas fa-chevron-left" id="toggleIcon"></i>
        </div>

        <div class="sidebar-header">
            <a href="#" class="sidebar-brand">
                <i class="fas fa-cogs"></i>
                <span>CRM System</span>
            </a>
        </div>

        <div class="sidebar-menu">
            <a href="${pageContext.request.contextPath}/dashboard" class="menu-item active">
                <i class="fas fa-home"></i>
                <span>Dashboard</span>
            </a>
            <a href="${pageContext.request.contextPath}/managerServiceRequest" class="menu-item">
                <i class="fas fa-clipboard-list"></i>
                <span>Yêu Cầu Dịch Vụ</span>
            </a>
            <a href="${pageContext.request.contextPath}/viewcontracts" class="menu-item">
                <i class="fas fa-file-contract"></i>
                <span>Hợp Đồng</span>
            </a>
            <a href="${pageContext.request.contextPath}/equipment" class="menu-item">
                <i class="fas fa-tools"></i>
                <span>Thiết Bị</span>
            </a>
            <a href="${pageContext.request.contextPath}/invoices" class="menu-item">
                <i class="fas fa-file-invoice-dollar"></i>
                <span>Hóa Đơn</span>
            </a>
            <a href="${pageContext.request.contextPath}/manageProfile" class="menu-item">
                <i class="fas fa-user-circle"></i>
                <span>Hồ Sơ</span>
            </a>
        </div>

        <div class="sidebar-footer">
            <div class="user-info">
                <div class="user-avatar">
                    ${sessionScope.session_login.fullName != null ? sessionScope.session_login.fullName.substring(0,1).toUpperCase() : 'U'}
                </div>
                <div class="user-details">
                    <div class="user-name">${sessionScope.session_login.username}</div>
                    <div class="user-role">Manager</div>
                </div>
            </div>
            <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
                <i class="fas fa-sign-out-alt"></i>
                <span>Đăng Xuất</span>
            </a>
        </div>
    </div>

    <!-- MAIN CONTENT -->
    <div class="main-content">
        <div class="top-navbar">
            <h1 class="page-title"><i class="fas fa-tachometer-alt"></i> Bảng Điều Khiển</h1>
        </div>

        <div class="content-wrapper">
            <div class="dashboard-cards">
                <a href="${pageContext.request.contextPath}/managerServiceRequest" class="dashboard-card">
                    <div style="font-size: 3rem; color: #667eea; margin-bottom: 20px;">
                        <i class="fas fa-clipboard-list"></i>
                    </div>
                    <div style="font-size: 1.25rem; font-weight: 600; margin-bottom: 10px;">Yêu cầu</div>
                    <div style="color: #666;">Quản lý yêu cầu dịch vụ</div>
                </a>

                <a href="${pageContext.request.contextPath}/viewcontracts" class="dashboard-card">
                    <div style="font-size: 3rem; color: #667eea; margin-bottom: 20px;">
                        <i class="fas fa-file-contract"></i>
                    </div>
                    <div style="font-size: 1.25rem; font-weight: 600; margin-bottom: 10px;">Hợp đồng</div>
                    <div style="color: #666;">Quản lý hợp đồng khách hàng</div>
                </a>

                <a href="${pageContext.request.contextPath}/equipment" class="dashboard-card">
                    <div style="font-size: 3rem; color: #667eea; margin-bottom: 20px;">
                        <i class="fas fa-tools"></i>
                    </div>
                    <div style="font-size: 1.25rem; font-weight: 600; margin-bottom: 10px;">Thiết bị</div>
                    <div style="color: #666;">Quản lý thiết bị</div>
                </a>

                <a href="${pageContext.request.contextPath}/invoices" class="dashboard-card">
                    <div style="font-size: 3rem; color: #667eea; margin-bottom: 20px;">
                        <i class="fas fa-receipt"></i>
                    </div>
                    <div style="font-size: 1.25rem; font-weight: 600; margin-bottom: 10px;">Hóa Đơn</div>
                    <div style="color: #666;">Quản lý hóa đơn</div>
                </a>
            </div>
        </div>
    </div>

    <!-- CHATBOT -->
    <div class="chatbot-container">
        <button class="chatbot-button" onclick="toggleChatbot()">
            <i class="fas fa-comment-dots"></i>
            <span class="chatbot-badge">AI</span>
        </button>

        <div class="chatbot-window" id="chatbotWindow">
            <div class="chatbot-header">
                <h4>
                    <i class="fas fa-robot"></i>
                    Trợ lý AI
                </h4>
                <button class="chatbot-close" onclick="toggleChatbot()">
                    <i class="fas fa-times"></i>
                </button>
            </div>

            <!-- PHẦN RECOMMENDATIONS -->
            <div class="chatbot-recommendations" id="chatbotRecommendations">
                <div class="recommendations-title">
                    <i class="fas fa-lightbulb"></i>
                    Câu hỏi thường gặp
                </div>
                <div class="recommendation-chips" id="recommendationChips">
                    <!-- Recommendations sẽ được thêm bằng JavaScript -->
                </div>
            </div>

            <div class="chatbot-messages" id="chatMessages">
                <div class="message bot">
                    <div class="message-avatar">
                        <i class="fas fa-robot"></i>
                    </div>
                    <div class="message-content">
                        Xin chào! Tôi là trợ lý AI của hệ thống. Tôi có thể giúp bạn trả lời các câu hỏi về dịch vụ, hợp đồng, thiết bị và hóa đơn. Bạn cần hỗ trợ gì?
                    </div>
                </div>
            </div>

            <div class="chatbot-input">
                <input type="text" id="chatInput" placeholder="Nhập câu hỏi của bạn..." onkeypress="handleKeyPress(event)">
                <button class="chatbot-send" id="sendBtn" onclick="sendMessage()">
                    <i class="fas fa-paper-plane"></i>
                </button>
            </div>
        </div>
    </div>

<script>
    // FAQ Data
    const FAQ_DATA = [
        {
            "category": "Giới thiệu chung",
            "questions": [
                {
                    "question": "Hệ thống của bạn cung cấp dịch vụ gì?",
                    "answer": "Hệ thống của chúng tôi cung cấp dịch vụ bảo hành và bảo trì thiết bị cho khách hàng. Khi quý khách mua thiết bị, chúng tôi sẽ tạo hợp đồng và lưu thông tin vào hệ thống. Khi thiết bị cần sửa chữa, quý khách chỉ cần tạo yêu cầu trực tuyến, chúng tôi sẽ xử lý và thực hiện sửa chữa theo quy trình chuyên nghiệp."
                },
                {
                    "question": "Làm thế nào để liên hệ bộ phận hỗ trợ khách hàng?",
                    "answer": "Quý khách có thể liên hệ với bộ phận hỗ trợ khách hàng qua:\n- Hotline: [Số điện thoại]\n- Email: [Địa chỉ email]\n- Chat trực tuyến trên website\n- Hoặc tạo yêu cầu hỗ trợ trực tiếp trên hệ thống"
                }
            ]
        },
        {
            "category": "Yêu cầu dịch vụ",
            "questions": [
                {
                    "question": "Làm thế nào để tạo yêu cầu bảo hành/bảo trì?",
                    "answer": "Để tạo yêu cầu, quý khách thực hiện theo các bước sau:\n\n1. Truy cập trang \"Yêu cầu dịch vụ\"\n2. Nhấn nút \"Tạo yêu cầu mới\" ở góc trên màn hình\n3. Chọn \"Hỗ trợ thiết bị\"\n4. Chọn thiết bị cần bảo hành từ danh sách (chỉ hiển thị thiết bị trong hợp đồng và chưa đang bảo hành)\n5. Chọn mức độ ưu tiên cho yêu cầu\n6. Mô tả chi tiết vấn đề của thiết bị\n7. Kiểm tra lại thông tin và nhấn \"Gửi yêu cầu\"\n\nSau khi gửi yêu cầu, chúng tôi sẽ xử lý và gửi báo giá. Khi quý khách thanh toán, chúng tôi sẽ tiến hành sửa chữa ngay."
                },
                {
                    "question": "Thời gian xử lý yêu cầu mất bao lâu?",
                    "answer": "Thời gian tạo yêu cầu trên hệ thống rất nhanh (chỉ vài phút). Tuy nhiên, thời gian xử lý yêu cầu phụ thuộc vào:\n\n- Mức độ ưu tiên của yêu cầu\n- Tình trạng và mức độ hỏng hóc của thiết bị\n- Khả năng sẵn có của phụ tùng thay thế\n\nThông thường:\n- Yêu cầu khẩn cấp: 24-48 giờ\n- Yêu cầu thường: 3-5 ngày làm việc\n- Yêu cầu không khẩn: 5-7 ngày làm việc"
                },
                {
                    "question": "Các trạng thái của yêu cầu dịch vụ có ý nghĩa gì?",
                    "answer": "Yêu cầu của quý khách sẽ đi qua các trạng thái sau:\n\n1. **Chờ xác nhận**: Yêu cầu vừa được tạo và đang chờ bộ phận hỗ trợ khách hàng xác nhận\n\n2. **Chờ xử lý**: Bộ phận hỗ trợ đã chuyển yêu cầu cho trưởng bộ phận kỹ thuật để phân công\n\n3. **Đang xử lý**: Trưởng bộ phận kỹ thuật đã giao việc cho kỹ thuật viên. Quý khách sẽ nhận được báo giá chi tiết. Quý khách có thể chấp nhận hoặc từ chối từng hạng mục trong báo giá\n\n4. **Đang sửa chữa**: Kỹ thuật viên đang thực hiện sửa chữa các hạng mục đã được thanh toán\n\n5. **Hoàn thành**: Thiết bị đã được sửa chữa xong và sẵn sàng giao lại cho quý khách\n\n6. **Đã hủy**: Yêu cầu đã bị hủy bởi quý khách hoặc hệ thống"
                },
                {
                    "question": "Tôi có thể hủy yêu cầu đã tạo không?",
                    "answer": "Có, quý khách có thể hủy yêu cầu khi:\n- Yêu cầu đang ở trạng thái \"Chờ xác nhận\" hoặc \"Chờ xử lý\"\n- Chưa thanh toán báo giá\n\nĐể hủy yêu cầu:\n1. Vào trang \"Yêu cầu dịch vụ\"\n2. Chọn yêu cầu cần hủy\n3. Nhấn nút \"Hủy yêu cầu\"\n4. Xác nhận hủy\n\nLưu ý: Sau khi đã thanh toán và kỹ thuật viên bắt đầu sửa chữa, quý khách không thể hủy yêu cầu."
                }
            ]
        },
        {
            "category": "Hợp đồng",
            "questions": [
                {
                    "question": "Làm thế nào để xem thông tin hợp đồng?",
                    "answer": "Để xem thông tin hợp đồng:\n\n1. Truy cập trang \"Hợp đồng\"\n2. Xem danh sách tất cả các hợp đồng của quý khách\n3. Nhấn vào nút \"Danh sách thiết bị\" để xem chi tiết các thiết bị trong từng hợp đồng\n\nTại đây, quý khách có thể xem:\n- Mã hợp đồng\n- Loại hợp đồng (mua bán, bảo hành, bảo trì)\n- Ngày bắt đầu và ngày kết thúc\n- Trạng thái hợp đồng\n- Danh sách thiết bị được bảo hành/bảo trì"
                },
                {
                    "question": "Làm thế nào để tạo hợp đồng mới?",
                    "answer": "Để tạo hợp đồng mới, quý khách vui lòng liên hệ trực tiếp với bộ phận hỗ trợ khách hàng qua:\n\n- Hotline: [Số điện thoại]\n- Email: [Địa chỉ email]\n- Đến trực tiếp văn phòng\n\nCác loại hợp đồng chúng tôi cung cấp:\n- Hợp đồng mua bán thiết bị\n- Hợp đồng bảo hành\n- Hợp đồng bảo trì định kỳ\n\nNhân viên hỗ trợ sẽ tư vấn và hướng dẫn quý khách hoàn tất thủ tục ký kết hợp đồng."
                },
                {
                    "question": "Chính sách bảo hành như thế nào?",
                    "answer": "Chính sách bảo hành của chúng tôi bao gồm:\n\n**Thời gian bảo hành:**\n- Theo thỏa thuận trong hợp đồng (thường từ 12-36 tháng)\n\n**Phạm vi bảo hành:**\n- Lỗi do nhà sản xuất\n- Hỏng hóc trong quá trình sử dụng bình thường\n- Bảo hành miễn phí phụ tùng và chi phí sửa chữa\n\n**Không bảo hành:**\n- Hư hỏng do sử dụng sai cách\n- Thiết bị bị va đập, rơi vỡ\n- Can thiệp sửa chữa bởi bên thứ ba\n- Thiết bị hết hạn bảo hành\n\nVui lòng tham khảo chi tiết trong hợp đồng của quý khách."
                }
            ]
        },
        {
            "category": "Hóa đơn & Thanh toán",
            "questions": [
                {
                    "question": "Làm thế nào để xem hóa đơn?",
                    "answer": "Để xem hóa đơn:\n\n1. Truy cập trang \"Hóa đơn\"\n2. Xem danh sách tất cả các hóa đơn\n\nThông tin hiển thị bao gồm:\n- Mã hóa đơn\n- Số tiền cần thanh toán\n- Ngày phát hành hóa đơn\n- Hạn thanh toán\n- Trạng thái (Chờ thanh toán, Đã thanh toán, Quá hạn)\n- Chi tiết các hạng mục trong hóa đơn"
                },
                {
                    "question": "Làm thế nào để thanh toán hóa đơn?",
                    "answer": "Quý khách có thể thanh toán hóa đơn qua các phương thức sau:\n\n**1. Thanh toán trực tuyến:**\n- Chuyển khoản ngân hàng\n- Ví điện tử (Momo, ZaloPay, VNPay)\n- Thẻ ATM/Thẻ tín dụng\n\n**2. Thanh toán trực tiếp:**\n- Tại văn phòng công ty\n- Thu tiền tận nơi (với một số trường hợp)\n\n**Cách thanh toán:**\n1. Vào trang \"Hóa đơn\"\n2. Chọn hóa đơn cần thanh toán\n3. Nhấn \"Thanh toán\"\n4. Chọn phương thức thanh toán\n5. Làm theo hướng dẫn\n\nSau khi thanh toán thành công, hệ thống sẽ cập nhật trạng thái hóa đơn và gửi biên lai qua email."
                },
                {
                    "question": "Điều gì xảy ra nếu tôi không thanh toán đúng hạn?",
                    "answer": "Nếu hóa đơn không được thanh toán đúng hạn:\n\n- Yêu cầu sửa chữa sẽ bị tạm dừng\n- Hóa đơn chuyển sang trạng thái \"Quá hạn\"\n- Có thể phát sinh phí phạt chậm thanh toán (theo hợp đồng)\n- Ảnh hưởng đến các yêu cầu dịch vụ tiếp theo\n\nVui lòng liên hệ bộ phận hỗ trợ nếu quý khách gặp khó khăn trong việc thanh toán để được tư vấn và hỗ trợ."
                }
            ]
        },
        {
            "category": "Thiết bị",
            "questions": [
                {
                    "question": "Làm thế nào để xem thông tin thiết bị?",
                    "answer": "Để xem thông tin thiết bị:\n\n1. Truy cập trang \"Thiết bị\"\n2. Xem danh sách tất cả thiết bị từ các hợp đồng của quý khách\n3. Nhấn vào \"Chi tiết\" để xem thông tin chi tiết\n\n**Thông tin hiển thị:**\n- Tên thiết bị\n- Mã thiết bị / Serial number\n- Hợp đồng liên quan\n- Trạng thái thiết bị (Đang hoạt động, Đang bảo hành, Đã hỏng)\n- Ngày mua / Ngày kích hoạt bảo hành\n- Thời hạn bảo hành còn lại\n\n**Nếu thiết bị đang được sửa chữa:**\n- Ngày bắt đầu sửa chữa\n- Kỹ thuật viên phụ trách\n- Dự kiến hoàn thành\n- Vấn đề đang được xử lý"
                },
                {
                    "question": "Tại sao một số thiết bị không hiển thị khi tạo yêu cầu?",
                    "answer": "Thiết bị sẽ không hiển thị trong danh sách tạo yêu cầu khi:\n\n- Thiết bị đang trong quá trình bảo hành/sửa chữa\n- Thiết bị không thuộc hợp đồng còn hiệu lực\n- Thiết bị đã hết hạn bảo hành và chưa gia hạn\n- Hợp đồng liên quan đã hết hạn hoặc bị hủy\n\nNếu quý khách cần sửa chữa thiết bị không có trong danh sách, vui lòng liên hệ bộ phận hỗ trợ để được tư vấn về việc gia hạn hợp đồng hoặc tạo hợp đồng mới."
                }
            ]
        },
        {
            "category": "Tài khoản & Bảo mật",
            "questions": [
                {
                    "question": "Làm thế nào để thay đổi thông tin cá nhân?",
                    "answer": "Để thay đổi thông tin cá nhân:\n\n1. Truy cập trang \"Hồ sơ\"\n2. Xem thông tin hiện tại của quý khách\n3. Nhấn nút \"Chỉnh sửa thông tin\"\n4. Cập nhật các thông tin cần thay đổi\n5. Nhấn \"Lưu thay đổi\"\n\n**Thông tin có thể chỉnh sửa:**\n- Họ và tên\n- Số điện thoại\n- Địa chỉ\n- Số CMND/CCCD\n- Ngày sinh\n\n**Lưu ý về email:**\n- Để thay đổi email, hệ thống sẽ gửi mã OTP đến email mới\n- Quý khách cần xác thực mã OTP để hoàn tất thay đổi\n- Việc này đảm bảo email mới thuộc quyền sở hữu của quý khách"
                },
                {
                    "question": "Làm thế nào để đổi mật khẩu?",
                    "answer": "Để đổi mật khẩu:\n\n1. Truy cập trang \"Hồ sơ\"\n2. Nhấn nút \"Đổi mật khẩu\"\n3. Nhập mật khẩu cũ\n4. Nhập mật khẩu mới (tối thiểu 8 ký tự, bao gồm chữ hoa, chữ thường, số)\n5. Xác nhận mật khẩu mới\n6. Nhấn \"Cập nhật\"\n\n**Lưu ý bảo mật:**\n- Không chia sẻ mật khẩu với người khác\n- Thay đổi mật khẩu định kỳ (3-6 tháng)\n- Sử dụng mật khẩu mạnh và khác biệt với các tài khoản khác\n- Nếu quên mật khẩu, sử dụng chức năng \"Quên mật khẩu\" ở trang đăng nhập"
                },
                {
                    "question": "Tôi quên mật khẩu, phải làm sao?",
                    "answer": "Nếu quên mật khẩu:\n\n1. Tại trang đăng nhập, nhấn \"Quên mật khẩu?\"\n2. Nhập email đã đăng ký\n3. Hệ thống sẽ gửi mã OTP đến email\n4. Nhập mã OTP để xác thực\n5. Tạo mật khẩu mới\n6. Đăng nhập lại với mật khẩu mới\n\nNếu không nhận được email:\n- Kiểm tra hộp thư spam/junk\n- Đợi 1-2 phút và thử lại\n- Liên hệ bộ phận hỗ trợ nếu vẫn không nhận được"
                }
            ]
        }
    ];

    // Initialize when page loads
    document.addEventListener('DOMContentLoaded', function() {
        showNewRecommendations();
    });

    function showNewRecommendations() {
        const container = document.getElementById('recommendationChips');
        if (!container) return;

        // Clear existing content
        container.innerHTML = '';

        // Get all questions from all categories
        const allQuestions = FAQ_DATA.flatMap(category => 
            category.questions.map(q => ({
                question: q.question,
                category: category.category
            }))
        );

        // Shuffle and take 6 questions (random mỗi lần)
        const shuffled = [...allQuestions].sort(() => 0.5 - Math.random());
        const selectedQuestions = shuffled.slice(0, 6);

        // Group by category for better organization
        const questionsByCategory = {};
        selectedQuestions.forEach(item => {
            if (!questionsByCategory[item.category]) {
                questionsByCategory[item.category] = [];
            }
            questionsByCategory[item.category].push(item.question);
        });

        // Render chips by category
        Object.entries(questionsByCategory).forEach(([category, questions]) => {
            // Add category label
            const categoryDiv = document.createElement('div');
            categoryDiv.className = 'recommendation-category';
            categoryDiv.textContent = category;
            container.appendChild(categoryDiv);

            // Add question chips
            questions.forEach(question => {
                const chip = document.createElement('div');
                chip.className = 'recommendation-chip';
                chip.textContent = question;
                chip.title = question;
                chip.onclick = () => sendRecommendedQuestion(question);
                container.appendChild(chip);
            });
        });
    }

    function sendRecommendedQuestion(question) {
        const input = document.getElementById('chatInput');
        input.value = question;
        sendMessage();
    }

    function hideRecommendations() {
        const recommendations = document.getElementById('chatbotRecommendations');
        if (recommendations) {
            recommendations.style.display = 'none';
        }
    }

    function showRecommendations() {
        const recommendations = document.getElementById('chatbotRecommendations');
        if (recommendations) {
            recommendations.style.display = 'block';
            // Hiển thị recommendations mới mỗi lần mở chat
            showNewRecommendations();
        }
    }

    function toggleSidebar() {
        const sidebar = document.getElementById('sidebar');
        const toggleIcon = document.getElementById('toggleIcon');
        sidebar.classList.toggle('collapsed');

        if (sidebar.classList.contains('collapsed')) {
            toggleIcon.classList.remove('fa-chevron-left');
            toggleIcon.classList.add('fa-chevron-right');
        } else {
            toggleIcon.classList.remove('fa-chevron-right');
            toggleIcon.classList.add('fa-chevron-left');
        }
    }

    function toggleChatbot() {
        const chatWindow = document.getElementById('chatbotWindow');
        chatWindow.classList.toggle('active');
        
        if (chatWindow.classList.contains('active')) {
            showRecommendations();
            setTimeout(() => {
                document.getElementById('chatInput').focus();
            }, 300);
        }
    }

    function handleKeyPress(event) {
        if (event.key === 'Enter') {
            sendMessage();
        }
    }

  function addMessage(content, isUser = false) {
    const messagesDiv = document.getElementById('chatMessages');
    const messageDiv = document.createElement('div');
    messageDiv.className = `message ${isUser ? 'user' : 'bot'}`;
    
    const avatar = document.createElement('div');
    avatar.className = 'message-avatar';
    avatar.innerHTML = isUser ? '<i class="fas fa-user"></i>' : '<i class="fas fa-robot"></i>';
    
    const contentDiv = document.createElement('div');
    contentDiv.className = 'message-content';
    
    if (isUser) {
        // Tin nhắn user - chỉ text bình thường
        contentDiv.textContent = content;
        messageDiv.appendChild(contentDiv);
        messageDiv.appendChild(avatar);
    } else {
        // Tin nhắn bot - có format HTML
        contentDiv.innerHTML = formatMessage(content);
        messageDiv.appendChild(avatar);
        messageDiv.appendChild(contentDiv);
    }
    
    messagesDiv.appendChild(messageDiv);
    messagesDiv.scrollTop = messagesDiv.scrollHeight;
}

    function showTyping() {
        const messagesDiv = document.getElementById('chatMessages');
        const typingDiv = document.createElement('div');
        typingDiv.className = 'message bot';
        typingDiv.id = 'typingIndicator';
        
        const avatar = document.createElement('div');
        avatar.className = 'message-avatar';
        avatar.innerHTML = '<i class="fas fa-robot"></i>';
        
        const typing = document.createElement('div');
        typing.className = 'typing-indicator';
        typing.innerHTML = '<div class="typing-dot"></div><div class="typing-dot"></div><div class="typing-dot"></div>';
        
        typingDiv.appendChild(avatar);
        typingDiv.appendChild(typing);
        messagesDiv.appendChild(typingDiv);
        messagesDiv.scrollTop = messagesDiv.scrollHeight;
    }

    function hideTyping() {
        const typing = document.getElementById('typingIndicator');
        if (typing) {
            typing.remove();
        }
    }

    async function sendMessage() {
        const input = document.getElementById('chatInput');
        const sendBtn = document.getElementById('sendBtn');
        const question = input.value.trim();
        
        if (!question) return;
        
        // Ẩn recommendations khi gửi tin nhắn
        hideRecommendations();
        
        // Thêm tin nhắn của user
        addMessage(question, true);
        input.value = '';
        
        // Disable input
        input.disabled = true;
        sendBtn.disabled = true;
        
        // Show typing
        showTyping();
        
        try {
            const response = await fetch('${pageContext.request.contextPath}/askGemini', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ q: question })
            });
            
            const data = await response.json();
            hideTyping();
            
            if (data.success && data.answer) {
                addMessage(data.answer, false);
            } else {
                addMessage(data.error || 'Xin lỗi, có lỗi xảy ra. Vui lòng thử lại.', false);
            }
            
            // QUAN TRỌNG: Hiển thị recommendations mới SAU KHI trả lời xong
            setTimeout(() => {
                showRecommendations();
            }, 500);
            
        } catch (error) {
            hideTyping();
            addMessage('Xin lỗi, không thể kết nối đến server. Vui lòng thử lại sau.', false);
            console.error('Error:', error);
            
            // Vẫn hiển thị recommendations mới dù có lỗi
            setTimeout(() => {
                showRecommendations();
            }, 500);
        } finally {
            input.disabled = false;
            sendBtn.disabled = false;
            input.focus();
        }
    }
    function formatMessage(text) {
    if (!text) return '';
    
    // 1. Thay thế xuống dòng bằng <br>
    let formatted = text.replace(/\n/g, '<br>');
    
    // 2. Format danh sách có số thứ tự
    formatted = formatted.replace(/(\d+\.)\s/g, '<br>$1 ');
    
    // 3. Format danh sách có dấu gạch đầu dòng
    formatted = formatted.replace(/^- /gm, '<br>• ');
    
    // 4. Format chữ in đậm
    formatted = formatted.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>');
    
    // 5. Format tiêu đề
    formatted = formatted.replace(/([A-Z][^.!?]*:\s*)/g, '<strong>$1</strong>');
    
    return formatted;
}
</script>
</body>
</html>