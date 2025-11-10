<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <title>CRM System - Quản lý Kho</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f5f5f5;
            color: #333;
            line-height: 1.6;
            min-height: 100vh;
        }

        /* Sidebar - Full Height */
        .sidebar {
            width: 220px;
            height: 100vh;
            position: fixed;
            top: 0;
            left: 0;
            background: #000000;
            display: flex;
            flex-direction: column;
            box-shadow: 2px 0 4px rgba(0,0,0,0.1);
            z-index: 1001;
        }

        .sidebar-logo {
            color: white;
            font-size: 24px;
            font-weight: 600;
            padding: 1rem 1.25rem;
            border-bottom: 1px solid rgba(255,255,255,0.1);
            display: flex;
            align-items: center;
            gap: 10px;
            height: 65px;
        }

        .sidebar-menu {
            flex: 1;
            overflow-y: auto;
            padding-top: 10px;
        }

        .sidebar a {
            color: white;
            text-decoration: none;
            padding: 12px 20px;
            font-size: 14px;
            display: flex;
            align-items: center;
            gap: 12px;
            transition: all 0.2s;
            border-left: 3px solid transparent;
        }

        .sidebar a:hover, .sidebar a.active {
            background: rgba(255,255,255,0.08);
            border-left: 3px solid white;
        }

        .sidebar a i {
            min-width: 18px;
            text-align: center;
            font-size: 16px;
        }

        .sidebar .logout-btn {
            margin-top: auto;
            background: rgba(255, 255, 255, 0.05);
            border-top: 1px solid rgba(255,255,255,0.1);
            text-align: center;
            font-weight: 500;
        }

        /* Top Navbar - Right Side Only */
        .navbar {
            background: #f5f5f5;
            padding: 1rem 2rem;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            position: fixed;
            top: 0;
            left: 220px;
            right: 0;
            z-index: 1000;
            height: 65px;
            display: flex;
            justify-content: flex-end;
            align-items: center;
            border-bottom: 1px solid #e0e0e0;
        }

        .user-info {
            color: #2c5f6f;
            font-weight: 600;
            font-size: 14px;
            padding: 8px 20px;
            background: #d4f1f4;
            border-radius: 6px;
            border: 1px solid #b8e6e9;
        }

        /* Main Content */
        .container {
            margin-left: 220px;
            margin-top: 65px;
            min-height: calc(100vh - 65px);
        }

        .content {
            padding: 30px 40px;
            background: #f5f5f5;
        }

        .content h2 {
            margin: 0 0 30px 0;
            color: #333;
            font-size: 28px;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .content h2::before {
            content: '⚙️';
            font-size: 32px;
        }

        /* KPI Cards */
        .kpi-container {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
            margin-bottom: 40px;
        }

        .kpi-card {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            border: 1px solid #e0e0e0;
            transition: all 0.3s;
        }

        .kpi-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.15);
        }

        .kpi-card h3 {
            font-size: 13px;
            color: #666;
            margin-bottom: 12px;
            font-weight: 500;
        }

        .kpi-card p {
            font-size: 26px;
            font-weight: 600;
            margin: 0;
            color: #333;
        }

        /* Chart Container */
        .chart-container {
            background: white;
            padding: 24px;
            border-radius: 8px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            border: 1px solid #e0e0e0;
            margin-bottom: 40px;
        }

        .chart-container > p {
            font-size: 18px;
            font-weight: 600;
            margin: 0 0 20px 0;
            color: #333;
        }

        .card {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 30px;
        }

        #inventoryChart {
            width: 180px !important;
            height: 180px !important;
        }

        .legend {
            display: flex;
            flex-direction: column;
            gap: 10px;
        }

        .legend-item {
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 13px;
            color: #666;
        }

        .color-dot {
            width: 12px;
            height: 12px;
            border-radius: 50%;
        }

        .label-value {
            font-weight: 600;
            font-size: 15px;
            color: #333;
            margin-left: auto;
        }

        /* List Container */
        .list-container {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 30px;
            margin-top: 30px;
        }

        .left-list, .right-list {
            background: white;
            padding: 24px;
            border-radius: 8px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            border: 1px solid #e0e0e0;
        }

        .left-list::after, .right-list::after {
            content: "";
            display: block;
            clear: both;
        }

        .title {
            float: left;
            font-weight: 600;
            font-size: 16px;
            color: #333;
            margin-bottom: 20px;
        }

        .more {
            float: right;
            font-size: 13px;
            color: #666;
            cursor: pointer;
            transition: color 0.3s;
            font-weight: 400;
        }

        .more:hover {
            color: #333;
        }

        /* Table Styles */
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
            background-color: white;
        }

        th, td {
            border: 1px solid #e0e0e0;
            padding: 10px 12px;
            text-align: left;
            font-size: 13px;
        }

        th {
            background-color: #f8f9fa;
            color: #333;
            font-weight: 600;
            border-bottom: 2px solid #dee2e6;
        }

        tr:nth-child(even) {
            background-color: #fafafa;
        }

        tr:hover {
            background-color: #f0f0f0;
        }

        td {
            color: #666;
        }

        .empty-row {
            text-align: center;
            color: #999;
            font-style: italic;
        }

        /* ========== FLOATING CHATBOT STYLES ========== */
        
        /* Chat Button */
        .chat-button {
            position: fixed;
            bottom: 30px;
            right: 30px;
            width: 60px;
            height: 60px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            box-shadow: 0 4px 20px rgba(102, 126, 234, 0.4);
            transition: all 0.3s ease;
            z-index: 1002;
            border: none;
        }

        .chat-button:hover {
            transform: scale(1.1);
            box-shadow: 0 6px 30px rgba(102, 126, 234, 0.6);
        }

        .chat-button.active {
            background: #ff6b6b;
        }

        .chat-button i {
            font-size: 26px;
            color: white;
        }

        /* Chat Widget */
        .chat-widget {
            position: fixed;
            bottom: 100px;
            right: 30px;
            width: 400px;
            height: 600px;
            background: white;
            border-radius: 20px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.3);
            display: none;
            flex-direction: column;
            overflow: hidden;
            z-index: 1001;
            animation: slideUp 0.3s ease-out;
        }

        .chat-widget.active {
            display: flex;
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

        .chat-widget-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            text-align: center;
            font-size: 18px;
            font-weight: bold;
        }

        .chat-widget-messages {
            flex: 1;
            padding: 20px;
            overflow-y: auto;
            background: #f5f5f5;
        }

        .chat-widget-message {
            margin-bottom: 15px;
            animation: fadeIn 0.3s;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .chat-widget-message.user {
            text-align: right;
        }

        .chat-widget-message-content {
            display: inline-block;
            padding: 12px 18px;
            border-radius: 18px;
            max-width: 80%;
            word-wrap: break-word;
            line-height: 1.4;
        }

        .chat-widget-message.user .chat-widget-message-content {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }

        .chat-widget-message.ai .chat-widget-message-content {
            background: white;
            color: #333;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }

        .chat-widget-message.error .chat-widget-message-content {
            background: #ff6b6b;
            color: white;
        }

        .typing-indicator {
            display: none;
            padding: 10px;
            text-align: left;
        }

        .typing-indicator.show {
            display: block;
        }

        .typing-dot {
            display: inline-block;
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: #999;
            margin: 0 2px;
            animation: typing 1.4s infinite;
        }

        .typing-dot:nth-child(2) { animation-delay: 0.2s; }
        .typing-dot:nth-child(3) { animation-delay: 0.4s; }

        @keyframes typing {
            0%, 60%, 100% { transform: translateY(0); }
            30% { transform: translateY(-10px); }
        }

        .chat-widget-input-area {
            padding: 20px;
            background: white;
            border-top: 1px solid #e0e0e0;
        }

        .chat-widget-input-wrapper {
            display: flex;
            gap: 10px;
        }

        #chatMessageInput {
            flex: 1;
            padding: 12px 18px;
            border: 2px solid #e0e0e0;
            border-radius: 25px;
            font-size: 14px;
            outline: none;
            transition: border-color 0.3s;
        }

        #chatMessageInput:focus {
            border-color: #667eea;
        }

        #chatSendButton {
            padding: 12px 25px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 25px;
            cursor: pointer;
            font-weight: bold;
            transition: transform 0.2s;
        }

        #chatSendButton:hover:not(:disabled) {
            transform: scale(1.05);
        }

        #chatSendButton:disabled {
            opacity: 0.6;
            cursor: not-allowed;
        }

        .chat-widget-messages::-webkit-scrollbar {
            width: 6px;
        }

        .chat-widget-messages::-webkit-scrollbar-track {
            background: #f1f1f1;
        }

        .chat-widget-messages::-webkit-scrollbar-thumb {
            background: #888;
            border-radius: 3px;
        }

        .chat-widget-messages::-webkit-scrollbar-thumb:hover {
            background: #555;
        }

        /* Table in chat */
        .chat-widget-message table {
            border-collapse: collapse;
            width: 100%;
            max-width: 420px;
            font-size: 13px;
            margin-top: 10px;
        }

        .chat-widget-message table th {
            padding: 6px 8px;
            border-bottom: 1px solid #eee;
            text-align: left;
            font-weight: 600;
            background: transparent;
        }

        .chat-widget-message table td {
            padding: 6px 8px;
            border-bottom: 1px solid #f1f1f1;
        }
    </style>
</head>
<body>
    <!-- Sidebar Full Height -->
    <div class="sidebar">
        <div class="sidebar-logo">CRM System</div>
        <div class="sidebar-menu">
            <a href="statistic" class="active"><i class="fas fa-home"></i><span>Trang chủ</span></a>
            <a href="manageProfile"><i class="fas fa-user-circle"></i><span>Hồ Sơ</span></a>
            <a href="storekeeper"><i class="fas fa-chart-line"></i><span>Thống kê</span></a>
            <a href="numberPart"><i class="fas fa-list"></i><span>Danh sách linh kiện</span></a>
            <a href="numberEquipment"><i class="fas fa-list"></i><span>Danh sách thiết bị</span></a>
            <a href="PartDetailHistoryServlet"><i class="fas fa-history"></i><span>Lịch sử giao dịch</span></a>
            <a href="partDetail"><i class="fas fa-truck-loading"></i><span>Chi tiết linh kiện</span></a>
            <a href="category"><i class="fas fa-tags"></i><span>Quản lý danh mục</span></a>
        </div>
        <a href="logout" class="logout-btn">
            <i class="fas fa-sign-out-alt"></i><span>Đăng xuất</span>
        </a>
    </div>

    <!-- Top Navbar (Right Side Only) -->
    <nav class="navbar">
        <div class="user-info">
            Xin chào ${sessionScope.username}
        </div>
    </nav>

    <!-- Main Content -->
    <div class="container">
        <div class="content">
            <!-- KPI Section -->
            <section>
                <h2>Chỉ số quản lý kho</h2>
                
                <div class="kpi-container">
                    <div class="kpi-card">
                        <h3>Tổng số loại thiết bị trong kho</h3>
                        <p>${totalEquipmentTypes}</p>
                    </div>
                    <div class="kpi-card">
                        <h3>Tổng số loại linh kiện trong kho</h3>
                        <p>${totalPartTypes}</p>
                    </div>
                    <div class="kpi-card">
                        <h3>Tổng số loại linh kiện sắp hết</h3>
                        <p>${lowStockCount}</p>
                    </div>
                    <div class="kpi-card">
                        <h3>Tổng số linh kiện sẵn sàng trong kho</h3>
                        <p>${availableCount}</p>
                    </div>
                    <div class="kpi-card">
                        <h3>Tổng số linh kiện bị hỏng trong kho</h3>
                        <p>${faultyCount}</p>
                    </div>
                    <div class="kpi-card">
                        <h3>Tổng số linh kiện đang được sử dụng</h3>
                        <p>${inUseCount}</p>
                    </div>
                    <div class="kpi-card">
                        <h3>% Tổng số linh kiện sẵn sàng</h3>
                        <p>${availablePercent}%</p>
                    </div>
                    <div class="kpi-card">
                        <h3>% Số lượng linh kiện ngừng dùng</h3>
                        <p>${retiredPercent}%</p>
                    </div>
                </div>
            </section>
            
            <!-- Chart Section -->
            <section>
                <div class="chart-container">
                    <p>Tình trạng linh kiện</p>
                    <div class="card">
                        <canvas id="inventoryChart"></canvas>
                        <div class="legend">
                            <div class="legend-item">
                                <span class="color-dot" style="background:#00b894;"></span> 
                                Linh kiện có sẵn
                                <span class="label-value">${chartInStock}</span>
                            </div>
                            <div class="legend-item">
                                <span class="color-dot" style="background:#6c5ce7;"></span> 
                                Linh kiện hết hàng
                                <span class="label-value">${chartOutOfStock}</span>
                            </div>
                            <div class="legend-item">
                                <span class="color-dot" style="background:#fdcb6e;"></span> 
                                Linh kiện sắp hết
                                <span class="label-value">${chartLowStock}</span>
                            </div>
                            <div class="legend-item">
                                <span class="color-dot" style="background:#d63031;"></span> 
                                Linh kiện ngừng dùng
                                <span class="label-value">${chartDeadStock}</span>
                            </div>
                        </div>
                    </div>
                </div>
            </section>
            
            <!-- Tables Section -->
            <section>
                <div class="list-container">
                    <div class="left-list">
                        <p class="title">Linh kiện sắp hết</p>
                        <a href="numberPart" class="more">Xem thêm <i class="fa-solid fa-arrow-right"></i></a>
                        <table border="1">
                            <thead>
                                <tr>
                                    <th>Part ID</th>
                                    <th>Tên linh kiện</th>
                                    <th>Danh mục</th>
                                    <th>Số lượng</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${not empty lowStockParts}">
                                        <c:forEach var="part" items="${lowStockParts}">
                                            <tr>
                                                <td>${part.partId}</td>
                                                <td>${part.partName}</td>
                                                <td>${part.categoryName != null ? part.categoryName : 'N/A'}</td>
                                                <td>${part.quantity}</td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="4" class="empty-row">Không có linh kiện sắp hết</td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>
                    
                    <div class="right-list">
                        <p class="title">Những linh kiện được sử dụng nhiều</p>
                        <a href="numberPart" class="more">Xem thêm <i class="fa-solid fa-arrow-right"></i></a>
                        <table border="1">
                            <thead>
                                <tr>
                                    <th>Part ID</th>
                                    <th>Tên linh kiện</th>
                                    <th>Danh mục</th>
                                    <th>Đang dùng</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${not empty mostUsedParts}">
                                        <c:forEach var="part" items="${mostUsedParts}">
                                            <tr>
                                                <td>${part.partId}</td>
                                                <td>${part.partName}</td>
                                                <td>${part.categoryName != null ? part.categoryName : 'N/A'}</td>
                                                <td>${part.quantity}</td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="4" class="empty-row">Không có dữ liệu</td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>
                </div>
            </section>
        </div>
    </div>

    <!-- Floating Chat Button -->
    <button class="chat-button" id="chatButton">
        <i class="fas fa-robot"></i>
    </button>

    <!-- Chat Widget -->
    <div class="chat-widget" id="chatWidget">
        <div class="chat-widget-header">
            🤖 ChatGPT Assistant
        </div>
        
        <div class="chat-widget-messages" id="chatWidgetMessages">
            <div class="chat-widget-message ai">
                <div class="chat-widget-message-content">
                    Xin chào! Tôi là trợ lý AI. Tôi có thể giúp gì cho bạn?
                </div>
            </div>
        </div>

        <div class="typing-indicator" id="chatTypingIndicator">
            <span class="typing-dot"></span>
            <span class="typing-dot"></span>
            <span class="typing-dot"></span>
        </div>
        
        <div class="chat-widget-input-area">
            <div class="chat-widget-input-wrapper">
                <input 
                    type="text" 
                    id="chatMessageInput" 
                    placeholder="Nhập tin nhắn của bạn..."
                    autocomplete="off"
                >
                <button id="chatSendButton">Gửi</button>
            </div>
        </div>
    </div>

    <script>
        // Chart: Equipment Status
        const ctx = document.getElementById('inventoryChart').getContext('2d');
        new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: ['Có sẵn', 'Hết hàng', 'Sắp hết', 'Ngừng dùng'],
                datasets: [{
                    data: [
                        ${chartInStock}, 
                        ${chartOutOfStock}, 
                        ${chartLowStock}, 
                        ${chartDeadStock}
                    ],
                    backgroundColor: ['#00b894', '#6c5ce7', '#fdcb6e', '#d63031'],
                    borderWidth: 0
                }]
            },
            options: {
                cutout: '70%',
                plugins: { legend: { display: false } }
            }
        });

        // ========== CHATBOT FUNCTIONALITY ==========
        const chatButton = document.getElementById('chatButton');
        const chatWidget = document.getElementById('chatWidget');
        const chatMessageInput = document.getElementById('chatMessageInput');
        const chatSendButton = document.getElementById('chatSendButton');
        const chatWidgetMessages = document.getElementById('chatWidgetMessages');
        const chatTypingIndicator = document.getElementById('chatTypingIndicator');

        // Toggle chat widget
        chatButton.addEventListener('click', function() {
            chatWidget.classList.toggle('active');
            chatButton.classList.toggle('active');
            
            if (chatWidget.classList.contains('active')) {
                chatMessageInput.focus();
                chatButton.innerHTML = '<i class="fas fa-times"></i>';
            } else {
                chatButton.innerHTML = '<i class="fas fa-robot"></i>';
            }
        });

        // Send message on Enter
        chatMessageInput.addEventListener('keypress', function(e) {
            if (e.key === 'Enter' && !chatSendButton.disabled) {
                sendChatMessage();
            }
        });

        // Send message on button click
        chatSendButton.addEventListener('click', sendChatMessage);

        function sendChatMessage() {
            const message = chatMessageInput.value.trim();
            
            if (!message) {
                return;
            }

            // Display user message
            addChatMessage('user', message);
            
            // Clear input
            chatMessageInput.value = '';
            
            // Disable input
            chatSendButton.disabled = true;
            chatMessageInput.disabled = true;
            
            // Show typing indicator
            chatTypingIndicator.classList.add('show');
            scrollChatToBottom();

            // Send request to servlet
            fetch('AskGeminiServlet', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: 'q=' + encodeURIComponent(message)
            })
            .then(response => response.json())
            .then(data => {
                chatTypingIndicator.classList.remove('show');

                // If server returns error
                if (data.error) {
                    addChatMessage('error', data.error);
                    return;
                }

                // 1) Display natural language answer
                if (data.ai_answer) {
                    addChatMessage('ai', data.ai_answer);
                } else if (data.generated_sql && (!data.result || !data.result.rows || data.result.rows.length === 0)) {
                    addChatMessage('ai', 'SQL được sinh: ' + data.generated_sql);
                }

                // 2) Display table results
                if (data.result && Array.isArray(data.result.columns)) {
                    addChatTableResult(data.result);
                }

                // 3) Show generated SQL (for debug)
                if (data.generated_sql) {
                    addChatMessage('ai', '🔎 Generated SQL: ' + data.generated_sql);
                }
            })
            .catch(error => {
                chatTypingIndicator.classList.remove('show');
                addChatMessage('error', 'Không thể kết nối đến server');
                console.error('Error:', error);
            })
            .finally(() => {
                chatSendButton.disabled = false;
                chatMessageInput.disabled = false;
                chatMessageInput.focus();
            });
        }

        function addChatTableResult(result) {
            const cols = result.columns || [];
            const rows = result.rows || [];

            const messageDiv = document.createElement('div');
            messageDiv.className = 'chat-widget-message ai';

            const contentDiv = document.createElement('div');
            contentDiv.className = 'chat-widget-message-content';

            // Create table
            const table = document.createElement('table');
            table.style.borderCollapse = 'collapse';
            table.style.width = '100%';
            table.style.maxWidth = '420px';
            table.style.fontSize = '13px';

            // Style for th/td
            const thStyle = "padding:6px 8px;border-bottom:1px solid #eee;text-align:left;font-weight:600;";
            const tdStyle = "padding:6px 8px;border-bottom:1px solid #f1f1f1;";

            // Header
            const thead = document.createElement('thead');
            const trh = document.createElement('tr');
            cols.forEach(col => {
                const th = document.createElement('th');
                th.textContent = col;
                th.setAttribute('style', thStyle);
                trh.appendChild(th);
            });
            thead.appendChild(trh);
            table.appendChild(thead);

            // Body
            const tbody = document.createElement('tbody');
            rows.forEach(rowObj => {
                const tr = document.createElement('tr');
                cols.forEach(col => {
                    const td = document.createElement('td');
                    const val = rowObj[col];
                    td.textContent = (val === null || typeof val === 'undefined') ? 'NULL' : String(val);
                    td.setAttribute('style', tdStyle);
                    tr.appendChild(td);
                });
                tbody.appendChild(tr);
            });
            table.appendChild(tbody);

            // If no rows
            if (rows.length === 0) {
                const empty = document.createElement('div');
                empty.textContent = 'Không có dữ liệu.';
                contentDiv.appendChild(empty);
            } else {
                contentDiv.appendChild(table);
            }

            messageDiv.appendChild(contentDiv);
            chatWidgetMessages.appendChild(messageDiv);
            scrollChatToBottom();
        }

        function addChatMessage(type, content) {
            const messageDiv = document.createElement('div');
            messageDiv.className = 'chat-widget-message ' + type;
            
            const contentDiv = document.createElement('div');
            contentDiv.className = 'chat-widget-message-content';
            contentDiv.textContent = content;
            
            messageDiv.appendChild(contentDiv);
            chatWidgetMessages.appendChild(messageDiv);
            
            scrollChatToBottom();
        }

        function scrollChatToBottom() {
            chatWidgetMessages.scrollTop = chatWidgetMessages.scrollHeight;
        }
         </script>
</body>
</html>