<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Trợ lý AI - Hỗ trợ khách hàng</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .chat-container {
            width: 500px;
            height: 700px;
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }

        .chat-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 25px;
            text-align: center;
        }

        .chat-header h1 {
            font-size: 22px;
            font-weight: bold;
            margin-bottom: 5px;
        }

        .chat-header p {
            font-size: 13px;
            opacity: 0.9;
        }

        .chat-messages {
            flex: 1;
            padding: 20px;
            overflow-y: auto;
            background: #f5f5f5;
        }

        .message {
            margin-bottom: 15px;
            animation: fadeIn 0.3s;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .message.user {
            text-align: right;
        }

        .message-content {
            display: inline-block;
            padding: 12px 18px;
            border-radius: 18px;
            max-width: 85%;
            word-wrap: break-word;
            line-height: 1.5;
        }

        .message.user .message-content {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            text-align: left;
        }

        .message.ai .message-content {
            background: white;
            color: #333;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            text-align: left;
        }

        .message.ai .message-content ul,
        .message.ai .message-content ol {
            margin-left: 20px;
            margin-top: 8px;
        }

        .message.ai .message-content li {
            margin-bottom: 5px;
        }

        .message.ai .message-content strong {
            color: #667eea;
        }

        .message.error .message-content {
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

        .chat-input-area {
            padding: 20px;
            background: white;
            border-top: 1px solid #e0e0e0;
        }

        .input-wrapper {
            display: flex;
            gap: 10px;
        }

        #messageInput {
            flex: 1;
            padding: 12px 18px;
            border: 2px solid #e0e0e0;
            border-radius: 25px;
            font-size: 14px;
            outline: none;
            transition: border-color 0.3s;
        }

        #messageInput:focus {
            border-color: #667eea;
        }

        #sendButton {
            padding: 12px 25px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 25px;
            cursor: pointer;
            font-weight: bold;
            transition: transform 0.2s;
        }

        #sendButton:hover:not(:disabled) {
            transform: scale(1.05);
        }

        #sendButton:disabled {
            opacity: 0.6;
            cursor: not-allowed;
        }

        .chat-messages::-webkit-scrollbar {
            width: 6px;
        }

        .chat-messages::-webkit-scrollbar-track {
            background: #f1f1f1;
        }

        .chat-messages::-webkit-scrollbar-thumb {
            background: #888;
            border-radius: 3px;
        }

        .chat-messages::-webkit-scrollbar-thumb:hover {
            background: #555;
        }

        .quick-questions {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            margin-top: 10px;
        }

        .quick-question-btn {
            background: #f0f0f0;
            border: 1px solid #ddd;
            padding: 8px 12px;
            border-radius: 15px;
            font-size: 12px;
            cursor: pointer;
            transition: all 0.2s;
        }

        .quick-question-btn:hover {
            background: #667eea;
            color: white;
            border-color: #667eea;
        }
    </style>
</head>
<body>
    <div class="chat-container">
        <div class="chat-header">
            <h1>🤖 Trợ lý AI</h1>
            <p>Hỗ trợ khách hàng - Hệ thống bảo trì thiết bị</p>
        </div>
        
        <div class="chat-messages" id="chatMessages">
            <div class="message ai">
                <div class="message-content">
                    <strong>Xin chào!</strong> Tôi là trợ lý AI hỗ trợ khách hàng.<br><br>
                    Tôi có thể giúp bạn về:
                    <ul>
                        <li>Hướng dẫn sử dụng dịch vụ</li>
                        <li>Quy trình tạo yêu cầu bảo hành</li>
                        <li>Thông tin về hợp đồng và hóa đơn</li>
                        <li>Chính sách và quy định</li>
                    </ul>
                </div>
            </div>
            <div class="quick-questions">
                <button class="quick-question-btn" onclick="sendQuickQuestion('Làm thế nào để tạo yêu cầu bảo hành?')">📝 Tạo yêu cầu</button>
                <button class="quick-question-btn" onclick="sendQuickQuestion('Cách xem hóa đơn?')">💰 Xem hóa đơn</button>
                <button class="quick-question-btn" onclick="sendQuickQuestion('Chính sách bảo hành?')">🛡️ Bảo hành</button>
                <button class="quick-question-btn" onclick="sendQuickQuestion('Thời gian xử lý yêu cầu?')">⏱️ Thời gian</button>
            </div>
        </div>

        <div class="typing-indicator" id="typingIndicator">
            <span class="typing-dot"></span>
            <span class="typing-dot"></span>
            <span class="typing-dot"></span>
        </div>
        
        <div class="chat-input-area">
            <div class="input-wrapper">
                <input 
                    type="text" 
                    id="messageInput" 
                    placeholder="Nhập câu hỏi của bạn..."
                    autocomplete="off"
                >
                <button id="sendButton">Gửi</button>
            </div>
        </div>
    </div>

    <script>
        const messageInput = document.getElementById('messageInput');
        const sendButton = document.getElementById('sendButton');
        const chatMessages = document.getElementById('chatMessages');
        const typingIndicator = document.getElementById('typingIndicator');

        messageInput.addEventListener('keypress', function(e) {
            if (e.key === 'Enter' && !sendButton.disabled) {
                sendMessage();
            }
        });

        sendButton.addEventListener('click', sendMessage);

        function sendQuickQuestion(question) {
            messageInput.value = question;
            sendMessage();
        }

        function sendMessage() {
            const message = messageInput.value.trim();
            
            if (!message) {
                return;
            }

            addMessage('user', message);
            messageInput.value = '';
            sendButton.disabled = true;
            messageInput.disabled = true;
            typingIndicator.classList.add('show');
            scrollToBottom();

            fetch('AskGeminiServlet', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: 'q=' + encodeURIComponent(message)
            })
            .then(response => response.json())
            .then(data => {
                typingIndicator.classList.remove('show');

                if (data.error) {
                    addMessage('error', data.error);
                    return;
                }

                if (data.answer) {
                    addMessageHTML('ai', formatAnswer(data.answer));
                }
            })
            .catch(error => {
                typingIndicator.classList.remove('show');
                addMessage('error', 'Không thể kết nối đến server. Vui lòng thử lại.');
                console.error('Error:', error);
            })
            .finally(() => {
                sendButton.disabled = false;
                messageInput.disabled = false;
                messageInput.focus();
            });
        }

        function formatAnswer(text) {
            text = text.replace(/\n/g, '<br>');
            text = text.replace(/\*\*([^*]+)\*\*/g, '<strong>$1</strong>');
            text = text.replace(/^- (.+)$/gm, '<li>$1</li>');
            
            if (text.includes('<li>')) {
                text = text.replace(/(<li>.*<\/li>)/s, '<ul>$1</ul>');
            }
            
            return text;
        }

        function addMessage(type, content) {
            const messageDiv = document.createElement('div');
            messageDiv.className = 'message ' + type;
            
            const contentDiv = document.createElement('div');
            contentDiv.className = 'message-content';
            contentDiv.textContent = content;
            
            messageDiv.appendChild(contentDiv);
            chatMessages.appendChild(messageDiv);
            
            scrollToBottom();
        }

        function addMessageHTML(type, htmlContent) {
            const messageDiv = document.createElement('div');
            messageDiv.className = 'message ' + type;
            
            const contentDiv = document.createElement('div');
            contentDiv.className = 'message-content';
            contentDiv.innerHTML = htmlContent;
            
            messageDiv.appendChild(contentDiv);
            chatMessages.appendChild(messageDiv);
            
            scrollToBottom();
        }

        function scrollToBottom() {
            chatMessages.scrollTop = chatMessages.scrollHeight;
        }

        window.addEventListener('load', function() {
            messageInput.focus();
        });
    </script>
</body>
</html>