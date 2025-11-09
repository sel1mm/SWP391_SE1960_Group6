<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thanh Toán - CRM System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 30px 20px;
        }
        .payment-container {
            max-width: 1400px;
            margin: 0 auto;
            background: white;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        .payment-header {
            background: white;
            padding: 30px 40px;
            border-bottom: 1px solid #e0e0e0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .contract-id-section { display: flex; align-items: center; gap: 15px; }
        .contract-id-icon {
            width: 48px; height: 48px;
            background: #f0f4ff;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #667eea;
            font-size: 1.5rem;
        }
        .contract-id-info h6 {
            color: #6c757d;
            font-size: 0.85rem;
            font-weight: 500;
            margin: 0 0 5px;
        }
        .contract-id-info h3 {
            color: #212529;
            font-size: 1.5rem;
            font-weight: 700;
            margin: 0;
        }
        .contract-dates { display: flex; gap: 30px; }
        .date-item { display: flex; align-items: center; gap: 10px; }
        .date-icon {
            width: 36px; height: 36px;
            background: #f8f9fa;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #495057;
            font-size: 1rem;
        }
        .date-info { display: flex; flex-direction: column; }
        .date-label { color: #6c757d; font-size: 0.85rem; margin-bottom: 3px; }
        .date-value { color: #212529; font-weight: 600; font-size: 0.95rem; }
        .payment-content {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 0;
        }
        .payment-left { padding: 40px; border-right: 1px solid #e0e0e0; }
        .payment-right { padding: 40px; background: #f8f9fa; }
        .info-card {
            background: white;
            border-radius: 12px;
            padding: 25px;
            margin-bottom: 30px;
            border: 1px solid #e9ecef;
        }
        .info-card-title {
            display: flex;
            align-items: center;
            gap: 12px;
            font-size: 1.1rem;
            font-weight: 600;
            color: #212529;
            margin-bottom: 20px;
        }
        .info-card-icon {
            width: 36px; height: 36px;
            background: #f0f4ff;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #667eea;
            font-size: 1.1rem;
        }
        .info-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 12px 0;
            border-bottom: 1px solid #f0f0f0;
        }
        .info-item:last-child { border-bottom: none; }
        .info-label { color: #6c757d; font-weight: 500; font-size: 0.95rem; }
        .info-value { color: #212529; font-weight: 600; font-size: 0.95rem; }
        .equipment-list { display: flex; flex-direction: column; gap: 20px; }
        .equipment-item {
            background: #f8f9fa;
            border: 1px solid #e9ecef;
            border-radius: 12px;
            padding: 20px;
            transition: all 0.3s;
        }
        .equipment-item:hover {
            border-color: #667eea;
            box-shadow: 0 2px 8px rgba(102, 126, 234, 0.1);
        }
        .equipment-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
        }
        .equipment-name { font-size: 1.15rem; font-weight: 700; color: #212529; }
        .equipment-price { font-size: 1.2rem; font-weight: 700; color: #667eea; }
        .equipment-details {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 15px;
            margin-top: 15px;
        }
        .equipment-detail-item { display: flex; flex-direction: column; gap: 5px; }
        .equipment-detail-label { font-size: 0.85rem; color: #6c757d; font-weight: 500; }
        .equipment-detail-value { font-size: 0.95rem; color: #212529; font-weight: 600; }
        .payment-methods { display: flex; flex-direction: column; gap: 15px; }
        .payment-method-item {
            display: flex;
            align-items: center;
            gap: 15px;
            padding: 18px;
            border: 2px solid #e9ecef;
            border-radius: 12px;
            cursor: pointer;
            transition: all 0.3s;
            background: white;
        }
        .payment-method-item:hover { border-color: #667eea; background: #f8f9ff; }
        .payment-method-item.selected { border-color: #667eea; background: #f0f4ff; }
        .payment-method-icon {
            width: 50px; height: 50px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: #f5f5f5;
            border-radius: 10px;
            font-size: 1.5rem;
            color: #495057;
            flex-shrink: 0;
        }
        .payment-method-item.selected .payment-method-icon { background: #667eea; color: white; }
        .payment-method-info { flex: 1; }
        .payment-method-name { font-weight: 600; color: #212529; margin-bottom: 5px; font-size: 1rem; }
        .payment-method-desc { color: #6c757d; font-size: 0.9rem; }
        .payment-method-check {
            width: 24px; height: 24px;
            border-radius: 50%;
            border: 2px solid #667eea;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            background: #667eea;
            flex-shrink: 0;
        }
        .payment-method-item:not(.selected) .payment-method-check { display: none; }
        .summary-card {
            background: white;
            border-radius: 12px;
            padding: 25px;
            margin-bottom: 20px;
            border: 1px solid #e9ecef;
        }
        .total-payment-box {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 12px;
            padding: 25px;
            margin: 20px 0;
            color: white;
            text-align: center;
        }
        .total-payment-label { font-size: 0.95rem; opacity: 0.95; margin-bottom: 10px; }
        .total-payment-amount { font-size: 2.2rem; font-weight: 700; margin: 10px 0; }
        .maintenance-services {
            background: #f8f9fa;
            border-radius: 12px;
            padding: 20px;
            margin: 20px 0;
        }
        .maintenance-services h6 {
            color: #212529;
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            gap: 10px;
            font-weight: 600;
        }
        .service-list { list-style: none; padding: 0; }
        .service-list li {
            padding: 8px 0;
            display: flex;
            align-items: center;
            gap: 10px;
            color: #495057;
            font-size: 0.9rem;
        }
        .service-list li i { color: #667eea; font-size: 0.85rem; }
        .btn-confirm-payment {
            width: 100%;
            padding: 18px;
            color: white;
            border: none;
            border-radius: 12px;
            font-size: 1.1rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            transition: all 0.3s;
            margin-top: 20px;
            cursor: pointer;
        }
        .btn-vnpay-payment { background: #2196f3; }
        .btn-vnpay-payment:hover {
            background: #1976d2;
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(33, 150, 243, 0.3);
        }
        .btn-cash-payment { background: #28a745; }
        .btn-cash-payment:hover {
            background: #218838;
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(40, 167, 69, 0.3);
        }
        .security-message {
            text-align: center;
            color: #6c757d;
            font-size: 0.85rem;
            margin-top: 15px;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }
        .security-message i { color: #667eea; }
        @media (max-width: 1200px) {
            .payment-content { grid-template-columns: 1fr; }
            .payment-left { border-right: none; border-bottom: 1px solid #e0e0e0; }
        }
    </style>
</head>
<body>
    <c:set var="finalRequestId" value="${param.requestId != null ? param.requestId : (serviceRequest != null && serviceRequest.requestId != null ? serviceRequest.requestId : 0)}" />
    
    <div id="payment-data" 
         data-payment-amount="${repairReport != null && repairReport.estimatedCost != null ? repairReport.estimatedCost : 0}"
         data-request-id="${finalRequestId}"
         data-context-path="${pageContext.request.contextPath}"
         style="display: none;">
    </div>
    
    <div class="payment-container">
        <!-- Header -->
        <div class="payment-header">
            <div class="contract-id-section">
                <div class="contract-id-icon">
                    <i class="fas fa-file-contract"></i>
                </div>
                <div class="contract-id-info">
                    <h6>Mã hợp đồng</h6>
                    <h3>HD-CRM-2025-<fmt:formatNumber value="${contract.contractId}" pattern="000000" /></h3>
                </div>
            </div>
            <div class="contract-dates">
                <div class="date-item">
                    <div class="date-icon"><i class="fas fa-calendar-alt"></i></div>
                    <div class="date-info">
                        <div class="date-label">Ngày bắt đầu</div>
                        <div class="date-value">
                            <c:if test="${contract.contractDate != null}">${contract.contractDate}</c:if>
                        </div>
                    </div>
                </div>
                <div class="date-item">
                    <div class="date-icon"><i class="fas fa-calendar-check"></i></div>
                    <div class="date-info">
                        <div class="date-label">Ngày kết thúc</div>
                        <div class="date-value">
                            <c:choose>
                                <c:when test="${not empty contractEquipmentList and not empty contractEquipmentList[0].endDate}">
                                    ${contractEquipmentList[0].endDate}
                                </c:when>
                                <c:otherwise>
                                    <c:if test="${contract.contractDate != null}">${contract.contractDate}</c:if>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Content -->
        <div class="payment-content">
            <!-- Left Column -->
            <div class="payment-left">
                <!-- Customer Information -->
                <div class="info-card">
                    <div class="info-card-title">
                        <div class="info-card-icon"><i class="fas fa-user"></i></div>
                        <span>Thông tin khách hàng</span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Họ và tên:</span>
                        <span class="info-value">${serviceRequest.customerName}</span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Số điện thoại:</span>
                        <span class="info-value">${serviceRequest.customerPhone}</span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Email:</span>
                        <span class="info-value">${serviceRequest.customerEmail}</span>
                    </div>
                </div>

                <!-- ✅ CHỈ HIỂN THỊ NẾU CÓ REPAIR REPORT -->
                <c:if test="${repairReport != null}">
                    <div class="info-card">
                        <div class="info-card-title">
                            <div class="info-card-icon"><i class="fas fa-wrench"></i></div>
                            <span>Thông tin sửa chữa</span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">Mô tả:</span>
                            <span class="info-value">${repairReport.details}</span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">Chi phí ước tính:</span>
                            <span class="info-value">
                                <fmt:formatNumber value="${repairReport.estimatedCost}" type="number" maxFractionDigits="0" /> ₫
                            </span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">Trạng thái báo giá:</span>
                            <span class="info-value">${repairReport.quotationStatus}</span>
                        </div>
                    </div>
                </c:if>

                <!-- Payment Methods -->
                <div class="info-card">
                    <div class="info-card-title">
                        <div class="info-card-icon"><i class="fas fa-credit-card"></i></div>
                        <span>Phương thức thanh toán</span>
                    </div>
                    <div class="payment-methods">
                        <div class="payment-method-item selected" onclick="selectPaymentMethod('VNPay', this)">
                            <div class="payment-method-icon"><i class="fas fa-wallet"></i></div>
                            <div class="payment-method-info">
                                <div class="payment-method-name">VNPay</div>
                                <div class="payment-method-desc">Thanh toán qua ví điện tử VNPay</div>
                            </div>
                            <div class="payment-method-check"><i class="fas fa-check"></i></div>
                        </div>
                        <div class="payment-method-item" onclick="selectPaymentMethod('Cash', this)">
                            <div class="payment-method-icon"><i class="fas fa-money-bill-wave"></i></div>
                            <div class="payment-method-info">
                                <div class="payment-method-name">Tiền mặt</div>
                                <div class="payment-method-desc">Thanh toán trực tiếp bằng tiền mặt</div>
                            </div>
                            <div class="payment-method-check"><i class="fas fa-check"></i></div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Right Column -->
            <div class="payment-right">
                <!-- Contract Summary -->
                <div class="summary-card">
                    <div class="info-card-title">
                        <div class="info-card-icon"><i class="fas fa-file-contract"></i></div>
                        <span>Tổng quan hợp đồng</span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Mã HĐ:</span>
                        <span class="info-value">HD-CRM-2025-<fmt:formatNumber value="${contract.contractId}" pattern="000000" /></span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Từ:</span>
                        <span class="info-value">
                            <c:if test="${contract.contractDate != null}">${contract.contractDate}</c:if>
                        </span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Đến:</span>
                        <span class="info-value">
                            <c:choose>
                                <c:when test="${not empty contractEquipmentList and not empty contractEquipmentList[0].endDate}">
                                    ${contractEquipmentList[0].endDate}
                                </c:when>
                                <c:otherwise>
                                    <c:if test="${contract.contractDate != null}">${contract.contractDate}</c:if>
                                </c:otherwise>
                            </c:choose>
                        </span>
                    </div>
                </div>

                <!-- Total Payment -->
                <div class="total-payment-box">
                    <div class="total-payment-label">Tổng thanh toán:</div>
                    <div class="total-payment-amount">
                        <c:choose>
                            <c:when test="${repairReport != null && repairReport.estimatedCost != null}">
                                <fmt:formatNumber value="${repairReport.estimatedCost}" type="number" maxFractionDigits="0" /> ₫
                            </c:when>
                            <c:otherwise>0 ₫</c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <!-- Maintenance Services -->
                <div class="maintenance-services">
                    <h6><i class="fas fa-cog"></i> Dịch vụ bảo trì bao gồm:</h6>
                    <ul class="service-list">
                        <li><i class="fas fa-check-circle"></i> Kiểm tra định kỳ 6 tháng/lần</li>
                        <li><i class="fas fa-check-circle"></i> Hỗ trợ kỹ thuật 24/7</li>
                        <li><i class="fas fa-check-circle"></i> Thay thế linh kiện miễn phí</li>
                        <li><i class="fas fa-check-circle"></i> Ưu tiên xử lý sự cố</li>
                    </ul>
                </div>

                <!-- Payment Buttons -->
                <button type="button" class="btn-confirm-payment btn-cash-payment" onclick="confirmCashPayment()">
                    <i class="fas fa-money-bill-wave"></i>
                    <span>Xác nhận thanh toán tiền mặt</span>
                </button>
                
                <button type="button" class="btn-confirm-payment btn-vnpay-payment" onclick="confirmVNPayPayment()">
                    <i class="fas fa-credit-card"></i>
                    <span>Thanh toán qua VNPay</span>
                </button>

                <div class="security-message">
                    <i class="fas fa-shield-alt"></i>
                    Giao dịch được bảo mật và mã hóa an toàn
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <c:if test="${not empty sessionScope.error}">
        <script>
            Swal.fire({
                icon: 'error',
                title: 'Lỗi!',
                text: '<c:out value="${sessionScope.error}" escapeXml="true" />',
                confirmButtonText: 'OK'
            });
        </script>
        <% session.removeAttribute("error"); %>
    </c:if>
    
    <script>
        let selectedPaymentMethod = 'VNPay';
        let paymentAmount = 0;
        let requestId = 0;
        let contextPath = '/CRM';

        (function init() {
            const paymentDataEl = document.getElementById('payment-data');
            if (!paymentDataEl) {
                console.error('❌ ERROR: payment-data not found!');
                return;
            }
            paymentAmount = parseFloat(paymentDataEl.getAttribute('data-payment-amount')) || 0;
            requestId = parseInt(paymentDataEl.getAttribute('data-request-id'));
            contextPath = paymentDataEl.getAttribute('data-context-path') || '/CRM';
            
            console.log('✅ Payment initialized:', { paymentAmount, requestId, contextPath });
        })();

        function selectPaymentMethod(method, element) {
            selectedPaymentMethod = method;
            document.querySelectorAll('.payment-method-item').forEach(item => {
                item.classList.remove('selected');
                const checkIcon = item.querySelector('.payment-method-check i');
                if (checkIcon) checkIcon.remove();
            });
            if (element) {
                element.classList.add('selected');
                const checkDiv = element.querySelector('.payment-method-check');
                if (checkDiv) {
                    const icon = document.createElement('i');
                    icon.className = 'fas fa-check';
                    checkDiv.appendChild(icon);
                }
            }
        }

        function confirmCashPayment() {
            const finalRequestId = requestId;
            if (!finalRequestId || finalRequestId <= 0) {
                Swal.fire({ icon: 'error', title: 'Lỗi!', text: 'Không thể xác định mã yêu cầu!' });
                return;
            }
            
            Swal.fire({
                title: 'Xác nhận thanh toán tiền mặt?',
                html: '<strong>Số tiền:</strong> ' + paymentAmount.toLocaleString('vi-VN') + ' VNĐ',
                icon: 'question',
                showCancelButton: true,
                confirmButtonColor: '#28a745',
                confirmButtonText: '✅ Xác nhận',
                cancelButtonText: 'Hủy'
            }).then((result) => {
                if (result.isConfirmed) {
                    Swal.fire({ title: 'Đang xử lý...', allowOutsideClick: false, didOpen: () => { Swal.showLoading(); } });
                    
                    const params = new URLSearchParams();
                    params.append('requestId', finalRequestId);
                    params.append('paymentMethod', 'Cash');

                    fetch(contextPath + '/payment', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                        body: params.toString()
                    })
                    .then(response => response.json())
                    .then(data => {
                        if (data.success) {
                            Swal.fire({
                                icon: 'success',
                                title: 'Thành công!',
                                text: data.message || 'Thanh toán thành công!',
                                timer: 3000
                            }).then(() => {
                                window.location.href = data.redirectUrl || (contextPath + '/managerServiceRequest');
                            });
                        } else {
                            Swal.fire({ icon: 'error', title: 'Lỗi!', text: data.error });
                        }
                    })
                    .catch(error => {
                        Swal.fire({ icon: 'error', title: 'Lỗi!', text: 'Không thể kết nối: ' + error.message });
                    });
                }
            });
        }
        
        function confirmVNPayPayment() {
            const finalRequestId = requestId;
            if (!finalRequestId || finalRequestId <= 0) {
                Swal.fire({ icon: 'error', title: 'Lỗi!', text: 'Không thể xác định mã yêu cầu!' });
                return;
            }
            
            Swal.fire({
                title: 'Xác nhận thanh toán?',
                text: 'Số tiền: ' + paymentAmount.toLocaleString('vi-VN') + ' VNĐ',
                icon: 'question',
                showCancelButton: true,
                confirmButtonColor: '#2196f3',
                confirmButtonText: '✅ Xác nhận',
                cancelButtonText: 'Hủy'
            }).then((result) => {
                if (result.isConfirmed) {
                    const params = new URLSearchParams();
                    params.append('requestId', finalRequestId);
                    params.append('paymentMethod', 'VNPay');

                    fetch(contextPath + '/payment', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                        body: params.toString()
                    })
                    .then(response => response.json())
                    .then(data => {
                        if (data.success && data.redirectUrl) {
                            window.location.href = data.redirectUrl;
                        } else {
                            Swal.fire({ icon: 'error', title: 'Lỗi!', text: data.error || 'Có lỗi xảy ra!' });
                        }
                    })
                    .catch(error => {
                        Swal.fire({ icon: 'error', title: 'Lỗi!', text: error.message });
                    });
                }
            });
        }
    </script>
</body>
</html>