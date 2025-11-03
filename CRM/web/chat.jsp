<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ChatGPT - AI Assistant</title>
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
            width: 450px;
            height: 600px;
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
            padding: 20px;
            text-align: center;
            font-size: 20px;
            font-weight: bold;
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
            max-width: 80%;
            word-wrap: break-word;
            line-height: 1.4;
        }

        .message.user .message-content {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }

        .message.ai .message-content {
            background: white;
            color: #333;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
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
    </style>
</head>
<body>
    <div class="chat-container">
        <div class="chat-header">
            🤖 ChatGPT Assistant
        </div>
        
        <div class="chat-messages" id="chatMessages">
            <div class="message ai">
                <div class="message-content">
                    Xin chào! Tôi là trợ lý AI. Tôi có thể giúp gì cho bạn?
                </div>
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
                    placeholder="Nhập tin nhắn của bạn..."
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

        // Gửi tin nhắn khi nhấn Enter
        messageInput.addEventListener('keypress', function(e) {
            if (e.key === 'Enter' && !sendButton.disabled) {
                sendMessage();
            }
        });

        // Gửi tin nhắn khi click nút
        sendButton.addEventListener('click', sendMessage);

        function sendMessage() {
            const message = messageInput.value.trim();
            
            if (!message) {
                return;
            }

            // Hiển thị tin nhắn người dùng
            addMessage('user', message);
            
            // Clear input
            messageInput.value = '';
            
            // Disable input
            sendButton.disabled = true;
            messageInput.disabled = true;
            
            // Hiển thị typing indicator
            typingIndicator.classList.add('show');
            scrollToBottom();

            // Gửi request đến servlet
     // Gửi request đến servlet (phiên bản pipeline 1.3)
fetch('AskGeminiServlet', {
    method: 'POST',
    headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: 'q=' + encodeURIComponent(message)
})
.then(response => {
    // response là JSON (200) hoặc có error message (200 với error field)
    return response.json();
})
.then(data => {
    typingIndicator.classList.remove('show');

    // Nếu server trả lỗi
    if (data.error) {
        addMessage('error', data.error);
        return;
    }

    // 1) Hiển thị câu trả lời dạng natural language (nếu có)
    if (data.ai_answer) {
        addMessage('ai', data.ai_answer);
    } else if (data.generated_sql && (!data.result || !data.result.rows || data.result.rows.length === 0)) {
        // nếu không có ai_answer nhưng có SQL thì show SQL
        addMessage('ai', 'SQL được sinh: ' + data.generated_sql);
    }

    // 2) Hiển thị bảng kết quả (nếu có)
    if (data.result && Array.isArray(data.result.columns)) {
        addTableResult(data.result);
    }

    // 3) (Tùy chọn) show generated_sql bên dưới (để debug)
    if (data.generated_sql) {
        addMessage('ai', '🔎 Generated SQL: ' + data.generated_sql);
    }
})
.catch(error => {
    typingIndicator.classList.remove('show');
    addMessage('error', 'Không thể kết nối đến server');
    console.error('Error:', error);
})
.finally(() => {
    sendButton.disabled = false;
    messageInput.disabled = false;
    messageInput.focus();
});
        }
function addTableResult(result) {
    // result: { columns: [...], rows: [ {col1:val, col2:val}, ... ] }
    const cols = result.columns || [];
    const rows = result.rows || [];

    const messageDiv = document.createElement('div');
    messageDiv.className = 'message ai';

    const contentDiv = document.createElement('div');
    contentDiv.className = 'message-content';

    // tạo table
    const table = document.createElement('table');
    table.style.borderCollapse = 'collapse';
    table.style.width = '100%';
    table.style.maxWidth = '420px';
    table.style.fontSize = '13px';

    // style th/td
    const thStyle = "padding:6px 8px;border-bottom:1px solid #eee;text-align:left;font-weight:600;";
    const tdStyle = "padding:6px 8px;border-bottom:1px solid #f1f1f1;";

    // header
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

    // body
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

    // nếu không có row nào
    if (rows.length === 0) {
        const empty = document.createElement('div');
        empty.textContent = 'Không có dữ liệu.';
        contentDiv.appendChild(empty);
    } else {
        contentDiv.appendChild(table);
    }

    messageDiv.appendChild(contentDiv);
    chatMessages.appendChild(messageDiv);
    scrollToBottom();
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

        function scrollToBottom() {
            chatMessages.scrollTop = chatMessages.scrollHeight;
        }

        // Focus vào input khi load trang
        window.addEventListener('load', function() {
            messageInput.focus();
        });
    </script>
</body>
</html>