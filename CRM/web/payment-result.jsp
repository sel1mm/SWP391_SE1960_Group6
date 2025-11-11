<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Kết Quả Thanh Toán - CRM System</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
        <style>
            body {
                background: linear-gradient(135deg, #667eea, #764ba2);
                min-height: 100vh;
                display: flex;
                justify-content: center;
                align-items: center;
                font-family: 'Segoe UI', sans-serif;
            }
            .result-card {
                background: white;
                border-radius: 20px;
                box-shadow: 0 10px 25px rgba(0, 0, 0, 0.15);
                max-width: 600px;
                width: 100%;
                padding: 40px 30px;
                text-align: center;
                animation: fadeInUp 0.5s ease;
            }
            @keyframes fadeInUp {
                from {
                    transform: translateY(40px);
                    opacity: 0;
                }
                to {
                    transform: translateY(0);
                    opacity: 1;
                }
            }
            .icon-success {
                color: #28a745;
                font-size: 64px;
                margin-bottom: 15px;
            }
            .icon-fail {
                color: #dc3545;
                font-size: 64px;
                margin-bottom: 15px;
            }
            .transaction-info {
                text-align: left;
                margin-top: 25px;
            }
            .transaction-info .info-item {
                display: flex;
                justify-content: space-between;
                margin-bottom: 8px;
                font-size: 15px;
            }
            .btn-home {
                background: linear-gradient(135deg, #667eea, #764ba2);
                color: white;
                border: none;
                border-radius: 10px;
                padding: 10px 20px;
                margin-top: 25px;
                font-weight: 500;
                transition: all 0.3s ease;
            }
            .btn-home:hover {
                background: linear-gradient(135deg, #5a67d8, #6b46c1);
                transform: translateY(-2px);
            }
        </style>
    </head>
    <body>
        <div class="result-card">
            <c:choose>
                <c:when test="${success}">
                    <i class="fa-solid fa-circle-check icon-success"></i>
                    <h3 class="text-success mb-3">Thanh toán thành công!</h3>
                    <p>Cảm ơn bạn đã sử dụng dịch vụ của chúng tôi.</p>

                    <div class="transaction-info mt-4">
                        <div class="info-item"><span><b>Mã giao dịch:</b></span> <span>${transactionNo}</span></div>
                        <div class="info-item"><span><b>Ngân hàng:</b></span> <span>${bankCode}</span></div>
                        <div class="info-item">
                            <span><b>Số tiền:</b></span>
                            <span><fmt:formatNumber value="${amount}" type="currency" currencySymbol="₫"/></span>
                        </div>
                        <div class="info-item">
                            <span><b>Thời gian:</b></span>
                            <span><fmt:formatDate value="<%= new java.util.Date() %>" pattern="dd/MM/yyyy HH:mm:ss"/></span>
                        </div>
                    </div>

                    <a href="${pageContext.request.contextPath}/invoices" class="btn btn-home mt-4">
                        <i class="fa-solid fa-house"></i> Quay lại trang chính
                    </a>
                </c:when>

                <c:otherwise>
                    <i class="fa-solid fa-circle-xmark icon-fail"></i>
                    <h3 class="text-danger mb-3">Thanh toán thất bại!</h3>
                    <p>${error}</p>

                    <div class="transaction-info mt-4">
                        <div class="info-item"><span><b>Mã phản hồi:</b></span> <span>${responseCode}</span></div>
                        <div class="info-item"><span><b>Mô tả lỗi:</b></span> <span>${error}</span></div>
                    </div>

                    <a href="${pageContext.request.contextPath}/payment.jsp" class="btn btn-home mt-4">
                        <i class="fa-solid fa-arrow-left"></i> Thử lại thanh toán
                    </a>
                </c:otherwise>
            </c:choose>
        </div>
    </body>
</html>