<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi Tiết Hợp Đồng HD-2025-001 - CRM System</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #e3f2fd 0%, #f3e5f5 100%);
            min-height: 100vh;
            padding: 20px;
        }

        .container {
            max-width: 1400px;
            margin: 0 auto;
        }

        /* Back Button */
        .back-button {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 20px;
            background: white;
            border: 2px solid #2196f3;
            color: #2196f3;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            margin-bottom: 20px;
            transition: all 0.3s;
        }

        .back-button:hover {
            background: #2196f3;
            color: white;
        }

        /* Header Card */
        .contract-header-card {
            background: white;
            border-radius: 15px;
            padding: 30px;
            margin-bottom: 25px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
            border-left: 6px solid #4caf50;
        }

        .header-top {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 25px;
        }

        .header-left h1 {
            font-size: 32px;
            color: #333;
            margin-bottom: 10px;
        }

        .header-badges {
            display: flex;
            gap: 10px;
            margin-bottom: 10px;
        }

        .badge {
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 5px;
        }

        .badge-active { background: #c8e6c9; color: #2e7d32; }
        .badge-premium { background: #e1bee7; color: #6a1b9a; }

        .contract-type {
            font-size: 18px;
            color: #666;
            margin-bottom: 5px;
        }

        .contract-desc {
            color: #999;
            font-size: 14px;
        }

        .header-right {
            text-align: right;
        }

        .contract-value-large {
            font-size: 36px;
            font-weight: bold;
            color: #4caf50;
            margin-bottom: 5px;
        }

        .contract-dates {
            color: #666;
            font-size: 14px;
            margin-bottom: 3px;
        }

        .progress-container {
            margin-top: 20px;
        }

        .progress-info {
            display: flex;
            justify-content: space-between;
            margin-bottom: 8px;
            font-size: 14px;
        }

        .progress-bar-bg {
            width: 100%;
            height: 14px;
            background: #e0e0e0;
            border-radius: 10px;
            overflow: hidden;
        }

        .progress-bar-fill {
            height: 100%;
            background: linear-gradient(90deg, #4caf50 0%, #8bc34a 100%);
            transition: width 0.5s;
            border-radius: 10px;
        }

        /* Quick Actions */
        .quick-actions {
            display: flex;
            gap: 15px;
            margin-bottom: 25px;
        }

        .action-btn {
            flex: 1;
            padding: 15px;
            border: none;
            border-radius: 12px;
            font-size: 15px;
            font-weight: 600;
            color: white;
            cursor: pointer;
            transition: all 0.3s;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }

        .action-btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.3);
        }

        .btn-blue { background: linear-gradient(135deg, #2196f3 0%, #1976d2 100%); }
        .btn-green { background: linear-gradient(135deg, #4caf50 0%, #388e3c 100%); }
        .btn-purple { background: linear-gradient(135deg, #9c27b0 0%, #7b1fa2 100%); }
        .btn-orange { background: linear-gradient(135deg, #ff9800 0%, #f57c00 100%); }

        /* Tabs */
        .tabs {
            display: flex;
            gap: 5px;
            background: white;
            padding: 5px;
            border-radius: 12px;
            margin-bottom: 25px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.08);
        }

        .tab {
            flex: 1;
            padding: 12px 20px;
            border: none;
            background: transparent;
            color: #666;
            font-weight: 600;
            cursor: pointer;
            border-radius: 8px;
            transition: all 0.3s;
        }

        .tab:hover {
            background: #f5f5f5;
        }

        .tab.active {
            background: linear-gradient(135deg, #2196f3 0%, #1976d2 100%);
            color: white;
        }

        /* Tab Content */
        .tab-content {
            display: none;
        }

        .tab-content.active {
            display: block;
        }

        /* Two Column Layout */
        .two-column {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 25px;
            margin-bottom: 25px;
        }

        /* Card */
        .card {
            background: white;
            border-radius: 12px;
            padding: 25px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.08);
        }

        .card-title {
            font-size: 18px;
            font-weight: 700;
            color: #333;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
            padding-bottom: 15px;
            border-bottom: 2px solid #f0f0f0;
        }

        .info-row {
            display: flex;
            justify-content: space-between;
            padding: 12px 0;
            border-bottom: 1px solid #f5f5f5;
        }

        .info-row:last-child {
            border-bottom: none;
        }

        .info-label {
            color: #666;
            font-size: 14px;
        }

        .info-value {
            font-weight: 600;
            color: #333;
            font-size: 14px;
            text-align: right;
        }

        /* Devices Table */
        .devices-table {
            width: 100%;
            border-collapse: collapse;
        }

        .devices-table thead {
            background: #f8f9fa;
        }

        .devices-table th {
            padding: 12px;
            text-align: left;
            font-size: 13px;
            font-weight: 600;
            color: #666;
            border-bottom: 2px solid #e0e0e0;
        }

        .devices-table td {
            padding: 12px;
            font-size: 14px;
            border-bottom: 1px solid #f5f5f5;
        }

        .devices-table tbody tr:hover {
            background: #f8f9fa;
        }

        .device-status {
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
        }

        .status-good { background: #c8e6c9; color: #2e7d32; }
        .status-warning { background: #ffe0b2; color: #ef6c00; }
        .status-error { background: #ffcdd2; color: #c62828; }

        /* Service History Timeline */
        .timeline {
            position: relative;
            padding-left: 40px;
        }

        .timeline-item {
            position: relative;
            padding-bottom: 30px;
        }

        .timeline-item:last-child {
            padding-bottom: 0;
        }

        .timeline-item::before {
            content: '';
            position: absolute;
            left: -32px;
            top: 0;
            width: 16px;
            height: 16px;
            border-radius: 50%;
            border: 3px solid #2196f3;
            background: white;
        }

        .timeline-item::after {
            content: '';
            position: absolute;
            left: -25px;
            top: 16px;
            width: 2px;
            height: calc(100% - 16px);
            background: #e0e0e0;
        }

        .timeline-item:last-child::after {
            display: none;
        }

        .timeline-item.completed::before {
            background: #4caf50;
            border-color: #4caf50;
        }

        .timeline-item.scheduled::before {
            background: #ff9800;
            border-color: #ff9800;
        }

        .timeline-date {
            font-size: 12px;
            color: #999;
            margin-bottom: 5px;
        }

        .timeline-title {
            font-weight: 600;
            color: #333;
            margin-bottom: 5px;
        }

        .timeline-desc {
            font-size: 14px;
            color: #666;
            margin-bottom: 5px;
        }

        .timeline-tech {
            font-size: 13px;
            color: #2196f3;
        }

        /* Payment History */
        .payment-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 15px;
            border: 2px solid #e0e0e0;
            border-radius: 10px;
            margin-bottom: 12px;
            transition: all 0.3s;
        }

        .payment-item:hover {
            border-color: #2196f3;
            background: #f8f9fa;
        }

        .payment-left {
            flex: 1;
        }

        .payment-date {
            font-size: 12px;
            color: #999;
            margin-bottom: 5px;
        }

        .payment-method {
            font-weight: 600;
            color: #333;
            margin-bottom: 3px;
        }

        .payment-invoice {
            font-size: 13px;
            color: #666;
        }

        .payment-amount {
            font-size: 20px;
            font-weight: bold;
            color: #4caf50;
        }

        /* Documents */
        .document-item {
            display: flex;
            align-items: center;
            gap: 15px;
            padding: 15px;
            border: 2px solid #e0e0e0;
            border-radius: 10px;
            margin-bottom: 12px;
            transition: all 0.3s;
            cursor: pointer;
        }

        .document-item:hover {
            border-color: #2196f3;
            background: #f8f9fa;
        }

        .doc-icon {
            width: 50px;
            height: 50px;
            background: linear-gradient(135deg, #2196f3 0%, #1976d2 100%);
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            color: white;
        }

        .doc-info {
            flex: 1;
        }

        .doc-name {
            font-weight: 600;
            color: #333;
            margin-bottom: 5px;
        }

        .doc-meta {
            font-size: 13px;
            color: #999;
        }

        .doc-download {
            padding: 8px 16px;
            background: #2196f3;
            color: white;
            border: none;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
        }

        /* Terms & Benefits */
        .terms-section {
            padding: 20px;
            background: #f8f9fa;
            border-radius: 10px;
            margin-bottom: 15px;
        }

        .terms-title {
            font-weight: 600;
            color: #333;
            margin-bottom: 15px;
            font-size: 16px;
        }

        .benefit-item {
            display: flex;
            align-items: flex-start;
            gap: 10px;
            margin-bottom: 12px;
            font-size: 14px;
            color: #666;
        }

        .benefit-check {
            color: #4caf50;
            font-weight: bold;
            font-size: 16px;
        }

        /* Contact Support */
        .support-card {
            background: linear-gradient(135deg, #ff9800 0%, #f57c00 100%);
            color: white;
            padding: 25px;
            border-radius: 12px;
            margin-top: 25px;
        }

        .support-title {
            font-size: 20px;
            font-weight: 700;
            margin-bottom: 10px;
        }

        .support-desc {
            margin-bottom: 15px;
            opacity: 0.9;
        }

        .support-contacts {
            display: flex;
            gap: 20px;
            flex-wrap: wrap;
        }

        .support-contact-item {
            display: flex;
            align-items: center;
            gap: 8px;
            font-weight: 600;
        }

        @media (max-width: 768px) {
            .two-column {
                grid-template-columns: 1fr;
            }

            .quick-actions {
                flex-direction: column;
            }

            .tabs {
                flex-direction: column;
            }
        }
    </style>
</head>
<body>
<%
    // Giả lập dữ liệu (thực tế lấy từ database theo contractId)
    request.setAttribute("contractId", "HD-2025-001");
    request.setAttribute("contractType", "Bảo trì định kỳ");
    request.setAttribute("contractDesc", "Bảo trì và kiểm tra định kỳ hệ thống HVAC");
    request.setAttribute("contractValue", "450.000.000");
    request.setAttribute("startDate", "01/01/2025");
    request.setAttribute("endDate", "31/12/2025");
    request.setAttribute("signDate", "28/12/2024");
    request.setAttribute("status", "active");
    request.setAttribute("statusText", "Đang hiệu lực");
    request.setAttribute("supportLevel", "Premium");
    request.setAttribute("progress", 85);
    
    // Thông tin 2 bên
    request.setAttribute("companyName", "Công ty TNHH Dịch Vụ Kỹ Thuật XYZ");
    request.setAttribute("companyAddress", "456 Nguyễn Văn Linh, Q.7, TP.HCM");
    request.setAttribute("companyPhone", "028-3838-9999");
    request.setAttribute("companyEmail", "contact@xyz.com.vn");
    request.setAttribute("companyRep", "Giám đốc: Trần Văn B");
    
    request.setAttribute("customerName", "Công ty TNHH ABC");
    request.setAttribute("customerAddress", "123 Đường Lê Lợi, Q.1, TP.HCM");
    request.setAttribute("customerPhone", "0901234567");
    request.setAttribute("customerEmail", "nguyenvana@abc.com");
    request.setAttribute("customerRep", "Đại diện: Nguyễn Văn A");
%>

<div class="container">
    <!-- Back Button -->
    <button class="back-button" onclick="history.back()">
        ← Quay lại danh sách hợp đồng
    </button>

    <!-- Header Card -->
    <div class="contract-header-card">
        <div class="header-top">
            <div class="header-left">
                <h1>${contractId}</h1>
                <div class="header-badges">
                    <span class="badge badge-active">✓ ${statusText}</span>
                    <span class="badge badge-premium">👑 ${supportLevel}</span>
                </div>
                <div class="contract-type">${contractType}</div>
                <div class="contract-desc">${contractDesc}</div>
            </div>
            <div class="header-right">
                <div style="font-size: 14px; color: #666; margin-bottom: 5px;">Giá trị hợp đồng</div>
                <div class="contract-value-large">${contractValue} ₫</div>
                <div class="contract-dates">📅 ${startDate} → ${endDate}</div>
                <div style="font-size: 12px; color: #999; margin-top: 5px;">Ký ngày: ${signDate}</div>
            </div>
        </div>

        <div class="progress-container">
            <div class="progress-info">
                <span style="font-weight: 600; color: #333;">Tiến độ thực hiện hợp đồng</span>
                <span style="font-weight: bold; color: #4caf50;">${progress}%</span>
            </div>
            <div class="progress-bar-bg">
                <div class="progress-bar-fill" style="width: ${progress}%;"></div>
            </div>
        </div>
    </div>

    <!-- Quick Actions -->
    <div class="quick-actions">
        <button class="action-btn btn-blue" onclick="downloadContract()">
            📥 Tải Hợp Đồng PDF
        </button>
        <button class="action-btn btn-green" onclick="requestSupport()">
            💬 Yêu Cầu Hỗ Trợ
        </button>
        <button class="action-btn btn-purple" onclick="bookService()">
            📅 Đặt Lịch Dịch Vụ
        </button>
        <button class="action-btn btn-orange" onclick="renewContract()">
            🔄 Gia Hạn Hợp Đồng
        </button>
    </div>

    <!-- Tabs -->
    <div class="tabs">
        <button class="tab active" onclick="showTab('overview')">📋 Tổng Quan</button>
        <button class="tab" onclick="showTab('devices')">🔧 Thiết Bị</button>
        <button class="tab" onclick="showTab('history')">📜 Lịch Sử Dịch Vụ</button>
        <button class="tab" onclick="showTab('payment')">💰 Thanh Toán</button>
        <button class="tab" onclick="showTab('documents')">📁 Tài Liệu</button>
        <button class="tab" onclick="showTab('terms')">📄 Điều Khoản</button>
    </div>

    <!-- Tab 1: Overview -->
    <div id="overview" class="tab-content active">
        <div class="two-column">
            <!-- Thông tin Bên A -->
            <div class="card">
                <div class="card-title">🏢 Bên A - Nhà Cung Cấp Dịch Vụ</div>
                <div class="info-row">
                    <span class="info-label">Công ty:</span>
                    <span class="info-value">${companyName}</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Địa chỉ:</span>
                    <span class="info-value">${companyAddress}</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Điện thoại:</span>
                    <span class="info-value">${companyPhone}</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Email:</span>
                    <span class="info-value">${companyEmail}</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Đại diện:</span>
                    <span class="info-value">${companyRep}</span>
                </div>
            </div>

            <!-- Thông tin Bên B -->
            <div class="card">
                <div class="card-title">👤 Bên B - Khách Hàng</div>
                <div class="info-row">
                    <span class="info-label">Công ty:</span>
                    <span class="info-value">${customerName}</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Địa chỉ:</span>
                    <span class="info-value">${customerAddress}</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Điện thoại:</span>
                    <span class="info-value">${customerPhone}</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Email:</span>
                    <span class="info-value">${customerEmail}</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Đại diện:</span>
                    <span class="info-value">${customerRep}</span>
                </div>
            </div>
        </div>

        <div class="two-column">
            <!-- Thông tin hợp đồng -->
            <div class="card">
                <div class="card-title">📋 Thông Tin Hợp Đồng</div>
                <div class="info-row">
                    <span class="info-label">Mã hợp đồng:</span>
                    <span class="info-value">${contractId}</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Loại hợp đồng:</span>
                    <span class="info-value">${contractType}</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Gói dịch vụ:</span>
                    <span class="info-value">${supportLevel}</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Ngày ký:</span>
                    <span class="info-value">${signDate}</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Ngày hiệu lực:</span>
                    <span class="info-value">${startDate}</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Ngày hết hạn:</span>
                    <span class="info-value">${endDate}</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Thời hạn:</span>
                    <span class="info-value">12 tháng</span>
                </div>
            </div>

            <!-- Thống kê -->
            <div class="card">
                <div class="card-title">📊 Thống Kê Thực Hiện</div>
                <div class="info-row">
                    <span class="info-label">Thiết bị quản lý:</span>
                    <span class="info-value">15 thiết bị</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Dịch vụ đã thực hiện:</span>
                    <span class="info-value">45 lần</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Dịch vụ sắp tới:</span>
                    <span class="info-value">05/11/2025</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Dịch vụ còn lại:</span>
                    <span class="info-value">7 lần</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Thời gian phản hồi TB:</span>
                    <span class="info-value">1.5 giờ</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Đánh giá dịch vụ:</span>
                    <span class="info-value">⭐⭐⭐⭐⭐ 4.8/5</span>
                </div>
            </div>
        </div>
    </div>

    <!-- Tab 2: Devices -->
    <div id="devices" class="tab-content">
        <div class="card">
            <div class="card-title">🔧 Danh Sách Thiết Bị Trong Hợp Đồng</div>
            <table class="devices-table">
                <thead>
                    <tr>
                        <th>Mã TB</th>
                        <th>Tên Thiết Bị</th>
                        <th>Model</th>
                        <th>Vị Trí</th>
                        <th>Tình Trạng</th>
                        <th>Lần Bảo Trì Cuối</th>
                        <th>Lần Bảo Trì Tiếp</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td><strong>TB-001</strong></td>
                        <td>Máy lạnh trung tâm</td>
                        <td>Trane RTAC-350</td>
                        <td>Tầng 1 - Lobby</td>
                        <td><span class="device-status status-good">✓ Tốt</span></td>
                        <td>25/10/2025</td>
                        <td>25/11/2025</td>
                    </tr>
                    <tr>
                        <td><strong>TB-002</strong></td>
                        <td>Chiller</td>
                        <td>Carrier AquaEdge 19XR</td>
                        <td>Tầng hầm B2</td>
                        <td><span class="device-status status-good">✓ Tốt</span></td>
                        <td>20/10/2025</td>
                        <td>20/11/2025</td>
                    </tr>
                    <tr>
                        <td><strong>TB-003</strong></td>
                        <td>AHU (Air Handling Unit)</td>
                        <td>Daikin AHU-500</td>
                        <td>Tầng 2 - Văn phòng</td>
                        <td><span class="device-status status-warning">⚠ Cần kiểm tra</span></td>
                        <td>18/10/2025</td>
                        <td>05/11/2025</td>
                    </tr>
                    <tr>
                        <td><strong>TB-004</strong></td>
                        <td>FCU (Fan Coil Unit)</td>
                        <td>Midea FCU-300</td>
                        <td>Tầng 3 - Phòng họp</td>
                        <td><span class="device-status status-good">✓ Tốt</span></td>
                        <td>22/10/2025</td>
                        <td>22/11/2025</td>
                    </tr>
                    <tr>
                        <td><strong>TB-005</strong></td>
                        <td>VRV System</td>
                        <td>Daikin VRV IV</td>
                        <td>Tầng 4 - Khu vực A</td>
                        <td><span class="device-status status-good">✓ Tốt</span></td>
                        <td>15/10/2025</td>
                        <td>15/11/2025</td>
                    </tr>
                    <tr>
                        <td><strong>TB-006</strong></td>
                        <td>Hệ thống ống gió</td>
                        <td>Custom Ductwork</td>
                        <td>Toàn bộ tòa nhà</td>
                        <td><span class="device-status status-good">✓ Tốt</span></td>
                        <td>10/10/2025</td>
                        <td>10/12/2025</td>
                    </tr>
                </tbody>
            </table>
            <p style="margin-top: 20px; color: #666; font-size: 14px;">
                <strong>Ghi chú:</strong> Hiển thị 6/15 thiết bị. 
                <a href="#" style="color: #2196f3;">Xem tất cả thiết bị →</a>
            </p>
        </div>
    </div>

    <!-- Tab 3: Service History -->
    <div id="history" class="tab-content">
        <div class="card">
            <div class="card-title">📜 Lịch Sử Dịch Vụ & Timeline</div>
            <div class="timeline">
                <div class="timeline-item scheduled">
                    <div class="timeline-date">📅 05/11/2025 (Sắp tới)</div>
                    <div class="timeline-title">Bảo trì định kỳ tháng 11</div>
                    <div class="timeline-desc">Kiểm tra và vệ sinh toàn bộ hệ thống HVAC</div>
                    <div class="timeline-tech">👷 Kỹ thuật viên: Chờ phân công</div>
                </div>

                <div class="timeline-item completed">
                    <div class="timeline-date">✓ 25/10/2025 (Hoàn thành)</div>
                    <div class="timeline-title">Bảo trì định kỳ tháng 10</div>
                    <div class="timeline-desc">Kiểm tra hệ thống làm lạnh, thay thế filter, kiểm tra gas</div>
                    <div class="timeline-tech">👷 Kỹ thuật viên: Trần Văn C • Thời gian: 4 giờ</div>
                </div>

                <div class="timeline-item completed">
                    <div class="timeline-date">✓ 20/10/2025 (Hoàn thành)</div>
                    <div class="timeline-title">Sửa chữa khẩn cấp TB-003</div>
                    <div class="timeline-desc">Xử lý sự cố rò rỉ nước tại AHU tầng 2</div>
                    <div class="timeline-tech">👷 Kỹ thuật viên: Nguyễn Văn D • Thời gian: 2 giờ</div>
                </div>

                <div class="timeline-item completed">
                    <div class="timeline-date">✓ 25/09/2025 (Hoàn thành)</div>
                    <div class="timeline-title">Bảo trì định kỳ tháng 9</div>
                    <div class="timeline-desc">Vệ sinh dàn nóng, kiểm tra áp suất hệ thống</div>
                    <div class="timeline-tech">👷 Kỹ thuật viên: Trần Văn C • Thời gian: 5 giờ</div>
                </div>

                <div class="timeline-item completed">
                    <div class="timeline-date">✓ 25/08/2025 (Hoàn thành)</div>
                    <div class="timeline-title">Bảo trì định kỳ tháng 8</div>
                    <div class="timeline-desc">Kiểm tra toàn diện, thay thế linh kiện hư hỏng</div>
                    <div class="timeline-tech">👷 Kỹ thuật viên: Phạm Văn E • Thời gian: 6 giờ</div>
                </div>

                <div class="timeline-item completed">
                    <div class="timeline-date">✓ 25/07/2025 (Hoàn thành)</div>
                    <div class="timeline-title">Bảo trì định kỳ tháng 7</div>
                    <div class="timeline-desc">Kiểm tra hệ thống điều khiển, cập nhật firmware</div>
                    <div class="timeline-tech">👷 Kỹ thuật viên: Trần Văn C • Thời gian: 3 giờ</div>
                </div>
            </div>
            <p style="margin-top: 20px; color: #666; font-size: 14px;">
                <strong>Ghi chú:</strong> Hiển thị 6 hoạt động gần nhất. 
                <a href="#" style="color: #2196f3;">Xem toàn bộ lịch sử →</a>
            </p>
        </div>
    </div>

    <!-- Tab 4: Payment History -->
    <div id="payment" class="tab-content">
        <div class="card">
            <div class="card-title">💰 Lịch Sử Thanh Toán</div>
            
            <div class="payment-item">
                <div class="payment-left">
                    <div class="payment-date">📅 28/12/2024</div>
                    <div class="payment-method">💳 Chuyển khoản ngân hàng</div>
                    <div class="payment-invoice">Hóa đơn: <strong>INV-2024-1234</strong></div>
                </div>
                <div class="payment-amount">450.000.000 ₫</div>
            </div>

            <div style="padding: 20px; background: #e8f5e9; border-radius: 10px; margin-top: 20px;">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px;">
                    <span style="font-weight: 600; color: #333;">Tổng đã thanh toán:</span>
                    <span style="font-size: 24px; font-weight: bold; color: #4caf50;">450.000.000 ₫</span>
                </div>
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px;">
                    <span style="font-weight: 600; color: #333;">Tổng giá trị hợp đồng:</span>
                    <span style="font-size: 20px; font-weight: bold; color: #333;">450.000.000 ₫</span>
                </div>
                <div style="display: flex; justify-content: space-between; align-items: center;">
                    <span style="font-weight: 600; color: #333;">Còn lại:</span>
                    <span style="font-size: 20px; font-weight: bold; color: #4caf50;">0 ₫</span>
                </div>
                <div style="margin-top: 15px; padding-top: 15px; border-top: 2px solid #c8e6c9;">
                    <div style="color: #2e7d32; font-weight: 600; display: flex; align-items: center; gap: 8px;">
                        ✓ Đã thanh toán đầy đủ
                    </div>
                </div>
            </div>

            <div style="margin-top: 20px; padding: 15px; background: #f8f9fa; border-radius: 10px;">
                <h4 style="margin-bottom: 10px; color: #333;">📄 Thông tin thanh toán:</h4>
                <div style="font-size: 14px; color: #666; line-height: 1.8;">
                    <div><strong>Ngân hàng:</strong> Vietcombank</div>
                    <div><strong>Số tài khoản:</strong> 1234567890</div>
                    <div><strong>Chủ tài khoản:</strong> Công ty TNHH Dịch Vụ Kỹ Thuật XYZ</div>
                    <div><strong>Chi nhánh:</strong> TP. Hồ Chí Minh</div>
                </div>
            </div>
        </div>
    </div>

    <!-- Tab 5: Documents -->
    <div id="documents" class="tab-content">
        <div class="card">
            <div class="card-title">📁 Tài Liệu & File Đính Kèm</div>
            
            <div class="document-item" onclick="viewDocument('contract')">
                <div class="doc-icon">📄</div>
                <div class="doc-info">
                    <div class="doc-name">Hợp đồng gốc đã ký - HD-2025-001.pdf</div>
                    <div class="doc-meta">PDF • 2.3 MB • Tải lên: 28/12/2024</div>
                </div>
                <button class="doc-download">📥 Tải xuống</button>
            </div>

            <div class="document-item" onclick="viewDocument('appendix')">
                <div class="doc-icon">📋</div>
                <div class="doc-info">
                    <div class="doc-name">Phụ lục thiết bị và phạm vi bảo trì.pdf</div>
                    <div class="doc-meta">PDF • 1.8 MB • Tải lên: 28/12/2024</div>
                </div>
                <button class="doc-download">📥 Tải xuống</button>
            </div>

            <div class="document-item" onclick="viewDocument('report-10')">
                <div class="doc-icon">📊</div>
                <div class="doc-info">
                    <div class="doc-name">Báo cáo bảo trì tháng 10/2025.pdf</div>
                    <div class="doc-meta">PDF • 856 KB • Tải lên: 25/10/2025</div>
                </div>
                <button class="doc-download">📥 Tải xuống</button>
            </div>

            <div class="document-item" onclick="viewDocument('report-09')">
                <div class="doc-icon">📊</div>
                <div class="doc-info">
                    <div class="doc-name">Báo cáo bảo trì tháng 09/2025.pdf</div>
                    <div class="doc-meta">PDF • 792 KB • Tải lên: 25/09/2025</div>
                </div>
                <button class="doc-download">📥 Tải xuống</button>
            </div>

            <div class="document-item" onclick="viewDocument('invoice')">
                <div class="doc-icon">🧾</div>
                <div class="doc-info">
                    <div class="doc-name">Hóa đơn thanh toán - INV-2024-1234.pdf</div>
                    <div class="doc-meta">PDF • 345 KB • Tải lên: 28/12/2024</div>
                </div>
                <button class="doc-download">📥 Tải xuống</button>
            </div>

            <div class="document-item" onclick="viewDocument('warranty')">
                <div class="doc-icon">🛡️</div>
                <div class="doc-info">
                    <div class="doc-name">Chứng nhận bảo hành thiết bị.pdf</div>
                    <div class="doc-meta">PDF • 1.2 MB • Tải lên: 28/12/2024</div>
                </div>
                <button class="doc-download">📥 Tải xuống</button>
            </div>

            <div class="document-item" onclick="viewDocument('manual')">
                <div class="doc-icon">📖</div>
                <div class="doc-info">
                    <div class="doc-name">Hướng dẫn sử dụng và bảo quản thiết bị.pdf</div>
                    <div class="doc-meta">PDF • 4.5 MB • Tải lên: 28/12/2024</div>
                </div>
                <button class="doc-download">📥 Tải xuống</button>
            </div>

            <div class="document-item" onclick="viewDocument('checklist')">
                <div class="doc-icon">✅</div>
                <div class="doc-info">
                    <div class="doc-name">Checklist bảo trì định kỳ.xlsx</div>
                    <div class="doc-meta">Excel • 234 KB • Tải lên: 28/12/2024</div>
                </div>
                <button class="doc-download">📥 Tải xuống</button>
            </div>
        </div>
    </div>

    <!-- Tab 6: Terms & Benefits -->
    <div id="terms" class="tab-content">
        <div class="card">
            <div class="card-title">📄 Điều Khoản & Quyền Lợi</div>
            
            <div class="terms-section">
                <div class="terms-title">🛡️ Quyền Lợi Của Khách Hàng (Gói Premium)</div>
                <div class="benefit-item">
                    <span class="benefit-check">✓</span>
                    <span><strong>Bảo trì định kỳ:</strong> 12 lần/năm (mỗi tháng 1 lần) bao gồm kiểm tra, vệ sinh, và điều chỉnh toàn bộ hệ thống HVAC</span>
                </div>
                <div class="benefit-item">
                    <span class="benefit-check">✓</span>
                    <span><strong>Hỗ trợ khẩn cấp 24/7:</strong> Phản hồi trong vòng 2 giờ, xử lý sự cố trong vòng 4 giờ</span>
                </div>
                <div class="benefit-item">
                    <span class="benefit-check">✓</span>
                    <span><strong>Báo cáo chi tiết:</strong> Báo cáo tình trạng thiết bị và kế hoạch bảo trì hàng tháng</span>
                </div>
                <div class="benefit-item">
                    <span class="benefit-check">✓</span>
                    <span><strong>Ưu tiên cao:</strong> Được ưu tiên xử lý trước các khách hàng khác</span>
                </div>
                <div class="benefit-item">
                    <span class="benefit-check">✓</span>
                    <span><strong>Miễn phí vật tư:</strong> Miễn phí thay thế các vật tư tiêu hao (filter, dầu bôi trơn, phớt...)</span>
                </div>
                <div class="benefit-item">
                    <span class="benefit-check">✓</span>
                    <span><strong>Giảm giá linh kiện:</strong> Giảm 20% chi phí linh kiện thay thế ngoài hợp đồng</span>
                </div>
                <div class="benefit-item">
                    <span class="benefit-check">✓</span>
                    <span><strong>Tư vấn miễn phí:</strong> Tư vấn về tiết kiệm năng lượng và nâng cấp hệ thống</span>
                </div>
                <div class="benefit-item">
                    <span class="benefit-check">✓</span>
                    <span><strong>Gia hạn ưu đãi:</strong> Giảm 10% khi gia hạn hợp đồng</span>
                </div>
            </div>

            <div class="terms-section">
                <div class="terms-title">📋 Trách Nhiệm Của Nhà Cung Cấp</div>
                <div class="benefit-item">
                    <span class="benefit-check">•</span>
                    <span>Thực hiện đúng lịch bảo trì định kỳ đã cam kết</span>
                </div>
                <div class="benefit-item">
                    <span class="benefit-check">•</span>
                    <span>Đảm bảo chất lượng dịch vụ và thiết bị thay thế</span>
                </div>
                <div class="benefit-item">
                    <span class="benefit-check">•</span>
                    <span>Cử kỹ thuật viên có chứng chỉ hành nghề</span>
                </div>
                <div class="benefit-item">
                    <span class="benefit-check">•</span>
                    <span>Bảo mật thông tin khách hàng</span>
                </div>
                <div class="benefit-item">
                    <span class="benefit-check">•</span>
                    <span>Bồi thường thiệt hại do lỗi của nhà cung cấp gây ra</span>
                </div>
            </div>

            <div class="terms-section">
                <div class="terms-title">📋 Trách Nhiệm Của Khách Hàng</div>
                <div class="benefit-item">
                    <span class="benefit-check">•</span>
                    <span>Thanh toán đầy đủ và đúng hạn theo hợp đồng</span>
                </div>
                <div class="benefit-item">
                    <span class="benefit-check">•</span>
                    <span>Tạo điều kiện cho kỹ thuật viên làm việc</span>
                </div>
                <div class="benefit-item">
                    <span class="benefit-check">•</span>
                    <span>Thông báo kịp thời khi phát hiện sự cố</span>
                </div>
                <div class="benefit-item">
                    <span class="benefit-check">•</span>
                    <span>Không tự ý sửa chữa hoặc thay đổi hệ thống</span>
                </div>
                <div class="benefit-item">
                    <span class="benefit-check">•</span>
                    <span>Tuân thủ hướng dẫn sử dụng và bảo quản thiết bị</span>
                </div>
            </div>

            <div class="terms-section">
                <div class="terms-title">⚠️ Điều Khoản Quan Trọng</div>
                <div class="benefit-item">
                    <span class="benefit-check">•</span>
                    <span><strong>Phạm vi bảo trì:</strong> Chỉ áp dụng cho 15 thiết bị được liệt kê trong phụ lục</span>
                </div>
                <div class="benefit-item">
                    <span class="benefit-check">•</span>
                    <span><strong>Ngoài phạm vi:</strong> Sự cố do thiên tai, hỏa hoạn, sử dụng sai mục đích không được bảo hành</span>
                </div>
                <div class="benefit-item">
                    <span class="benefit-check">•</span>
                    <span><strong>Thanh lý hợp đồng:</strong> Thông báo trước 30 ngày nếu muốn hủy hợp đồng</span>
                </div>
                <div class="benefit-item">
                    <span class="benefit-check">•</span>
                    <span><strong>Tranh chấp:</strong> Giải quyết thông qua thương lượng, hòa giải hoặc tòa án</span>
                </div>
                <div class="benefit-item">
                    <span class="benefit-check">•</span>
                    <span><strong>Điều khoản thay đổi:</strong> Mọi thay đổi phải được 2 bên ký phụ lục bổ sung</span>
                </div>
            </div>
        </div>
    </div>

    <!-- Support Card -->
    <div class="support-card">
        <div class="support-title">💬 Cần Hỗ Trợ?</div>
        <div class="support-desc">Chúng tôi luôn sẵn sàng hỗ trợ bạn 24/7. Hãy liên hệ với chúng tôi qua các kênh sau:</div>
        <div class="support-contacts">
            <div class="support-contact-item">
                📞 Hotline: 1900-xxxx
            </div>
            <div class="support-contact-item">
                ✉️ Email: support@xyz.com.vn
            </div>
            <div class="support-contact-item">
                💬 Chat: Online 24/7
            </div>
            <div class="support-contact-item">
                🚨 Khẩn cấp: 0909-xxx-xxx
            </div>
        </div>
    </div>

</div>

<script>
    function showTab(tabName) {
        // Hide all tab contents
        const tabContents = document.querySelectorAll('.tab-content');
        tabContents.forEach(content => {
            content.classList.remove('active');
        });

        // Remove active class from all tabs
        const tabs = document.querySelectorAll('.tab');
        tabs.forEach(tab => {
            tab.classList.remove('active');
        });

        // Show selected tab content
        document.getElementById(tabName).classList.add('active');

        // Add active class to clicked tab
        event.target.classList.add('active');
    }

    function downloadContract() {
        alert('Đang tải hợp đồng HD-2025-001.pdf...');
        // window.location.href = 'download.jsp?type=contract&id=HD-2025-001';
    }

    function requestSupport() {
        alert('Chuyển đến trang yêu cầu hỗ trợ...');
        // window.location.href = 'supportRequest.jsp?contractId=HD-2025-001';
    }

    function bookService() {
        alert('Chuyển đến trang đặt lịch dịch vụ...');
        // window.location.href = 'bookService.jsp?contractId=HD-2025-001';
    }

    function renewContract() {
        alert('Chuyển đến trang gia hạn hợp đồng...');
        // window.location.href = 'renewContract.jsp?contractId=HD-2025-001';
    }

    function viewDocument(docType) {
        alert('Mở tài liệu: ' + docType);
        // window.open('viewDocument.jsp?type=' + docType, '_blank');
    }
</script>

</body>
</html>