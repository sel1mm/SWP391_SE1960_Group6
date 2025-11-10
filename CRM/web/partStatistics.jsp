<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <title>CRM System - Trang chủ quản lý</title>
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

        /* Sidebar */
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

        /* Top Navbar */
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
            padding: 40px;
            background: #f5f5f5;
        }

        /* Header Section */
        .header-section {
            margin-bottom: 30px;
        }

        .header-section h1 {
            font-size: 28px;
            color: #1a1a2e;
            margin-bottom: 10px;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .header-section h1::before {
            content: '🏠';
            font-size: 32px;
        }

        .header-section p {
            color: #666;
            font-size: 15px;
            margin-left: 44px;
        }

        /* Navigation Cards Grid */
        .nav-cards-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 25px;
            margin-top: 30px;
        }

        .nav-card {
            background: white;
            padding: 30px 25px;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
            border: 1px solid #e8e8e8;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
            color: inherit;
            display: flex;
            flex-direction: column;
            align-items: center;
            text-align: center;
            position: relative;
            overflow: hidden;
        }

        .nav-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
            transform: scaleX(0);
            transition: transform 0.3s ease;
        }

        .nav-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 20px rgba(0,0,0,0.12);
            border-color: #667eea;
        }

        .nav-card:hover::before {
            transform: scaleX(1);
        }

        .nav-card-icon {
            width: 70px;
            height: 70px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 20px;
            transition: all 0.3s ease;
        }

        .nav-card:hover .nav-card-icon {
            transform: scale(1.1) rotate(5deg);
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
        }

        .nav-card-icon i {
            font-size: 32px;
            color: white;
        }

        .nav-card-title {
            font-size: 18px;
            font-weight: 600;
            color: #1a1a2e;
            margin-bottom: 10px;
        }

        .nav-card-description {
            font-size: 13px;
            color: #666;
            line-height: 1.5;
        }

        /* Specific card colors */
        .nav-card:nth-child(1) .nav-card-icon {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }

        .nav-card:nth-child(2) .nav-card-icon {
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
        }

        .nav-card:nth-child(3) .nav-card-icon {
            background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
        }

        .nav-card:nth-child(4) .nav-card-icon {
            background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);
        }

        .nav-card:nth-child(5) .nav-card-icon {
            background: linear-gradient(135deg, #fa709a 0%, #fee140 100%);
        }

        .nav-card:nth-child(6) .nav-card-icon {
            background: linear-gradient(135deg, #30cfd0 0%, #330867 100%);
        }

        .nav-card:nth-child(7) .nav-card-icon {
            background: linear-gradient(135deg, #a8edea 0%, #fed6e3 100%);
        }

        .nav-card:nth-child(8) .nav-card-icon {
            background: linear-gradient(135deg, #ff9a9e 0%, #fecfef 100%);
        }

        /* Modal Styles */
        .modal-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0, 0, 0, 0.6);
            z-index: 2000;
            animation: fadeIn 0.3s ease;
        }

        .modal-overlay.show {
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .modal-content {
            background: white;
            border-radius: 16px;
            padding: 0;
            max-width: 450px;
            width: 90%;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            animation: slideIn 0.3s ease;
            overflow: hidden;
        }

        .modal-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 25px 30px;
            position: relative;
        }

        .modal-header-icon {
            width: 60px;
            height: 60px;
            background: rgba(255, 255, 255, 0.2);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 15px;
        }

        .modal-header-icon i {
            font-size: 28px;
            color: white;
        }

        .modal-title {
            font-size: 22px;
            font-weight: 600;
            color: white;
            text-align: center;
            margin: 0;
        }

        .modal-body {
            padding: 30px;
            text-align: center;
        }

        .modal-message {
            font-size: 16px;
            color: #555;
            line-height: 1.6;
            margin-bottom: 25px;
        }

        .modal-footer {
            padding: 0 30px 30px;
            display: flex;
            justify-content: center;
        }

        .modal-close-btn {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            padding: 12px 40px;
            border-radius: 8px;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
        }

        .modal-close-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
        }

        .modal-close-btn:active {
            transform: translateY(0);
        }

        @keyframes fadeIn {
            from {
                opacity: 0;
            }
            to {
                opacity: 1;
            }
        }

        @keyframes slideIn {
            from {
                transform: translateY(-50px);
                opacity: 0;
            }
            to {
                transform: translateY(0);
                opacity: 1;
            }
        }

        /* Responsive */
        @media (max-width: 768px) {
            .sidebar {
                width: 60px;
            }

            .sidebar-logo {
                font-size: 0;
                justify-content: center;
            }

            .sidebar a span {
                display: none;
            }

            .navbar, .container {
                margin-left: 60px;
            }

            .nav-cards-grid {
                grid-template-columns: 1fr;
            }

            .modal-content {
                width: 95%;
                margin: 20px;
            }
        }
    </style>
</head>
<body>
    <!-- Sidebar -->
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

    <!-- Top Navbar -->
    <nav class="navbar">
        <div class="user-info">
            Xin chào ${sessionScope.username}
        </div>
    </nav>

    <!-- Main Content -->
    <div class="container">
        <div class="content">
            <!-- Header Section -->
            <div class="header-section">
                <h1>Trang chủ quản lý</h1>
                <p>Chào mừng bạn đến với hệ thống quản lý CRMS. Hãy chọn một chức năng từ thanh bên trái để bắt đầu.</p>
            </div>

            <!-- Navigation Cards -->
            <div class="nav-cards-grid">
                <!-- Card 1: Hồ sơ -->
                <a href="manageProfile" class="nav-card">
                    <div class="nav-card-icon">
                        <i class="fas fa-user-circle"></i>
                    </div>
                    <div class="nav-card-title">Hồ Sơ</div>
                    <div class="nav-card-description">Quản lý thông tin cá nhân và tài khoản của bạn.</div>
                </a>

                <!-- Card 2: Thống kê -->
                <a href="storekeeper" class="nav-card">
                    <div class="nav-card-icon">
                        <i class="fas fa-chart-line"></i>
                    </div>
                    <div class="nav-card-title">Thống kê</div>
                    <div class="nav-card-description">Xem báo cáo và phân tích dữ liệu kho.</div>
                </a>

                <!-- Card 3: Danh sách linh kiện -->
                <a href="numberPart" class="nav-card">
                    <div class="nav-card-icon">
                        <i class="fas fa-list"></i>
                    </div>
                    <div class="nav-card-title">Danh sách linh kiện</div>
                    <div class="nav-card-description">Quản lý danh sách tất cả linh kiện trong kho.</div>
                </a>

                <!-- Card 4: Danh sách thiết bị -->
                <a href="numberEquipment" class="nav-card">
                    <div class="nav-card-icon">
                        <i class="fas fa-cogs"></i>
                    </div>
                    <div class="nav-card-title">Danh sách thiết bị</div>
                    <div class="nav-card-description">Quản lý thiết bị và theo dõi tình trạng.</div>
                </a>

                <!-- Card 5: Lịch sử giao dịch -->
                <a href="PartDetailHistoryServlet" class="nav-card">
                    <div class="nav-card-icon">
                        <i class="fas fa-history"></i>
                    </div>
                    <div class="nav-card-title">Lịch sử giao dịch</div>
                    <div class="nav-card-description">Xem lịch sử nhập xuất và thay đổi.</div>
                </a>

                <!-- Card 6: Chi tiết linh kiện -->
                <a href="partDetail" class="nav-card">
                    <div class="nav-card-icon">
                        <i class="fas fa-truck-loading"></i>
                    </div>
                    <div class="nav-card-title">Chi tiết linh kiện</div>
                    <div class="nav-card-description">Quản lý chi tiết từng linh kiện cụ thể.</div>
                </a>

                <!-- Card 7: Quản lý danh mục -->
                <a href="category" class="nav-card">
                    <div class="nav-card-icon">
                        <i class="fas fa-tags"></i>
                    </div>
                    <div class="nav-card-title">Quản lý danh mục</div>
                    <div class="nav-card-description">Tạo và chỉnh sửa danh mục sản phẩm.</div>
                </a>

                <!-- Card 8: Placeholder cho chức năng khác -->
                <a href="#" class="nav-card" id="comingSoonCard">
                    <div class="nav-card-icon">
                        <i class="fas fa-ellipsis-h"></i>
                    </div>
                    <div class="nav-card-title">Chức năng khác</div>
                    <div class="nav-card-description">Các tính năng bổ sung đang được phát triển.</div>
                </a>
            </div>
        </div>
    </div>

    <!-- Modal -->
    <div class="modal-overlay" id="modalOverlay">
        <div class="modal-content">
            <div class="modal-header">
                <div class="modal-header-icon">
                    <i class="fas fa-info-circle"></i>
                </div>
                <h2 class="modal-title">Thông báo</h2>
            </div>
            <div class="modal-body">
                <p class="modal-message">Chức năng đang được phát triển!</p>
            </div>
            <div class="modal-footer">
                <button class="modal-close-btn" onclick="closeModal()">
                    <i class="fas fa-check"></i> Đã hiểu
                </button>
            </div>
        </div>
    </div>

    <script>
        // Modal functions
        function openModal() {
            document.getElementById('modalOverlay').classList.add('show');
        }

        function closeModal() {
            document.getElementById('modalOverlay').classList.remove('show');
        }

        // Close modal when clicking outside
        document.getElementById('modalOverlay').addEventListener('click', function(e) {
            if (e.target === this) {
                closeModal();
            }
        });

        // Close modal with ESC key
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                closeModal();
            }
        });

        // Coming soon card click handler
        document.getElementById('comingSoonCard').addEventListener('click', function(e) {
            e.preventDefault();
            openModal();
        });

        // Auto-hide alerts after 5 seconds
        document.addEventListener('DOMContentLoaded', function() {
            const alerts = document.querySelectorAll('.alert');
            alerts.forEach(alert => {
                setTimeout(() => {
                    alert.style.transition = 'opacity 0.3s ease';
                    alert.style.opacity = '0';
                    setTimeout(() => alert.remove(), 300);
                }, 5000);
            });

            // Active menu highlight
            const currentPath = window.location.pathname;
            const menuLinks = document.querySelectorAll('.sidebar a');
            menuLinks.forEach(link => {
                if (link.getAttribute('href') && currentPath.includes(link.getAttribute('href'))) {
                    link.classList.add('active');
                } else if (link.classList.contains('active') && !link.getAttribute('href').includes('storekeeper')) {
                    link.classList.remove('active');
                }
            });
        });
    </script>
</body>
</html>