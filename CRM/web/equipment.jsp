<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>CRM Dashboard - Quản Lý Thiết Bị</title>
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

            .sidebar-menu::-webkit-scrollbar {
                width: 6px;
            }

            .sidebar-menu::-webkit-scrollbar-thumb {
                background: rgba(255,255,255,0.2);
                border-radius: 10px;
            }

            .menu-section {
                margin-bottom: 20px;
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
                transition: all 0.3s;
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
                transition: all 0.3s;
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

            .user-details {
                flex: 1;
                transition: all 0.3s;
            }

            .user-name {
                font-size: 0.9rem;
                font-weight: 600;
                margin-bottom: 2px;
            }

            .user-role {
                font-size: 0.75rem;
                color: rgba(255,255,255,0.6);
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
                border-color: white;
            }

            .sidebar.collapsed .btn-logout span {
                display: none;
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
                box-shadow: 0 2px 8px rgba(0,0,0,0.15);
            }

            .sidebar-toggle:hover {
                transform: scale(1.1);
                background: #1e3c72;
                color: white;
            }

            /* MAIN CONTENT */
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
                display: flex;
                justify-content: space-between;
                align-items: center;
            }

            .page-title {
                font-size: 1.5rem;
                font-weight: 700;
                color: #1e3c72;
                margin: 0;
            }

            .content-wrapper {
                padding: 30px;
            }

            .stats-card {
                border-radius: 10px;
                padding: 20px;
                margin-bottom: 20px;
                box-shadow: 0 2px 4px rgba(0,0,0,0.1);
                transition: all 0.3s;
            }

            .stats-card:hover {
                transform: translateY(-5px);
                box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            }

            .stats-card i {
                font-size: 2.5rem;
                opacity: 0.8;
            }

            .table-container {
                background: white;
                border-radius: 10px;
                padding: 25px;
                box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            }

            .badge-active {
                background-color: #198754;
            }

            .badge-repair {
                background-color: #ffc107;
                color: #000;
            }

            .badge-maintenance {
                background-color: #8b5cf6;
            }

            .search-filter-bar {
                background: white;
                padding: 20px;
                border-radius: 10px;
                margin-bottom: 20px;
                box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            }

            .btn-action {
                padding: 5px 10px;
                margin: 0 2px;
            }

            /* TOAST NOTIFICATION */
            #toastContainer {
                position: fixed;
                top: 80px;
                right: 20px;
                z-index: 99999;
                width: 350px;
                max-width: 90vw;
            }

            .toast-notification {
                background: white;
                border-radius: 10px;
                padding: 15px 20px;
                box-shadow: 0 4px 12px rgba(0,0,0,0.15);
                display: flex;
                align-items: center;
                gap: 15px;
                margin-bottom: 10px;
                animation: slideInRight 0.4s ease-out;
            }

            @keyframes slideInRight {
                from {
                    transform: translateX(400px);
                    opacity: 0;
                }
                to {
                    transform: translateX(0);
                    opacity: 1;
                }
            }

            .toast-notification.hiding {
                animation: slideOutRight 0.4s ease-out forwards;
            }

            @keyframes slideOutRight {
                from {
                    transform: translateX(0);
                    opacity: 1;
                }
                to {
                    transform: translateX(400px);
                    opacity: 0;
                }
            }

            .toast-notification.success {
                border-left: 4px solid #198754;
            }

            .toast-notification.error {
                border-left: 4px solid #dc3545;
            }

            .toast-icon {
                font-size: 24px;
                flex-shrink: 0;
            }

            .toast-icon.success {
                color: #198754;
            }

            .toast-icon.error {
                color: #dc3545;
            }

            .toast-content {
                flex: 1;
            }

            .toast-close {
                background: none;
                border: none;
                cursor: pointer;
                color: #999;
                padding: 0;
                font-size: 18px;
                transition: color 0.2s;
            }

            .toast-close:hover {
                color: #333;
            }

            /* FOOTER STYLES */
            .site-footer {
                background: linear-gradient(135deg, #1a202c 0%, #2d3748 100%);
                color: rgba(255, 255, 255, 0.9);
                padding: 50px 0 20px;
                margin-top: 50px;
            }

            .footer-content {
                max-width: 1400px;
                margin: 0 auto;
                padding: 0 30px;
            }

            .footer-grid {
                display: grid;
                grid-template-columns: repeat(4, 1fr);
                gap: 50px;
                margin-bottom: 60px;
            }

            .footer-section h5 {
                color: #fff;
                font-size: 1.1rem;
                font-weight: 600;
                margin-bottom: 20px;
                position: relative;
                padding-bottom: 10px;
            }

            .footer-section h5:after {
                content: '';
                position: absolute;
                left: 0;
                bottom: 0;
                width: 50px;
                height: 2px;
                background: #ffc107;
            }

            .footer-about {
                color: rgba(255, 255, 255, 0.8);
                line-height: 1.8;
                margin-bottom: 15px;
                font-size: 14px;
            }

            .footer-links {
                list-style: none;
                padding: 0;
                margin: 0;
            }

            .footer-links li {
                margin-bottom: 12px;
            }

            .footer-links a {
                color: rgba(255, 255, 255, 0.8);
                text-decoration: none;
                display: flex;
                align-items: center;
                gap: 8px;
                transition: all 0.3s;
                font-size: 0.95rem;
            }

            .footer-links a:hover {
                color: #ffc107;
                transform: translateX(5px);
            }

            .footer-bottom {
                border-top: 1px solid rgba(255, 255, 255, 0.1);
                padding-top: 25px;
                display: flex;
                justify-content: space-between;
                align-items: center;
                flex-wrap: wrap;
                gap: 15px;
            }

            .footer-copyright {
                color: rgba(255, 255, 255, 0.7);
                font-size: 0.9rem;
            }

            .scroll-to-top {
                position: fixed;
                bottom: 30px;
                right: 30px;
                width: 45px;
                height: 45px;
                background: #ffc107;
                color: #1e3c72;
                border-radius: 50%;
                display: none;
                align-items: center;
                justify-content: center;
                cursor: pointer;
                transition: all 0.3s;
                z-index: 999;
                box-shadow: 0 4px 12px rgba(255, 193, 7, 0.3);
            }

            .scroll-to-top:hover {
                background: #ffb300;
                transform: translateY(-5px);
            }

            .scroll-to-top.show {
                display: flex;
            }

            /* ✅ REPAIR INFO SECTION */
            .repair-info-section {
                background: #fff3cd;
                border: 1px solid #ffc107;
                border-radius: 8px;
                padding: 20px;
                margin-top: 20px;
            }

            .repair-info-section h6 {
                color: #856404;
                font-weight: 600;
                margin-bottom: 15px;
                display: flex;
                align-items: center;
                gap: 8px;
            }

            .info-item {
                display: flex;
                margin-bottom: 12px;
                padding: 8px;
                background: white;
                border-radius: 4px;
            }

            .info-item strong {
                min-width: 150px;
                color: #495057;
            }

            .info-item span {
                color: #212529;
            }

            /* RESPONSIVE */
            @media (max-width: 768px) {
                .sidebar {
                    transform: translateX(-100%);
                }

                .sidebar.show {
                    transform: translateX(0);
                }

                .main-content {
                    margin-left: 0;
                }

                .sidebar.collapsed ~ .main-content {
                    margin-left: 0;
                }

                .footer-grid {
                    grid-template-columns: 1fr;
                    gap: 30px;
                }

                .footer-bottom {
                    flex-direction: column;
                    text-align: center;
                }
            }
            /* ========== CHATBOT STYLES ========== */
            .chatbot-container {
                position: fixed;
                bottom: 30px;
                right: 30px;
                z-index: 99999;
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
                0%, 100% {
                    transform: scale(1);
                }
                50% {
                    transform: scale(1.1);
                }
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

            /* ========== CHATBOT RECOMMENDATIONS ========== */
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
                from {
                    opacity: 0;
                    transform: translateY(10px);
                }
                to {
                    opacity: 1;
                    transform: translateY(0);
                }
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
                white-space: pre-line;
                word-wrap: break-word;
                overflow-wrap: break-word;
            }

            .message.user .message-content {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                border-bottom-right-radius: 4px;
            }

            .message.bot .message-content strong {
                color: #1e3c72;
                font-weight: 600;
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

            .typing-dot:nth-child(2) {
                animation-delay: 0.2s;
            }
            .typing-dot:nth-child(3) {
                animation-delay: 0.4s;
            }

            @keyframes typing {
                0%, 60%, 100% {
                    transform: translateY(0);
                }
                30% {
                    transform: translateY(-10px);
                }
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
            #maintenanceHistoryModal .table {
                font-size: 0.9rem;
            }

            #maintenanceHistoryModal .table td {
                vertical-align: middle;
            }

            #maintenanceHistoryModal .badge {
                font-size: 0.8rem;
                padding: 0.35em 0.65em;
            }

            #historyTableBody tr:hover {
                background-color: #f8f9fa;
            }
            /* ✅ FORCE TEXT COLOR CHO MAINTENANCE HISTORY TABLE */
            #maintenanceHistoryModal table,
            #maintenanceHistoryModal table * {
                color: #000 !important;
            }

            #maintenanceHistoryModal tbody tr {
                background-color: #ffffff !important;
            }

            #maintenanceHistoryModal tbody td {
                background-color: #ffffff !important;
                color: #000000 !important;
                padding: 12px 8px !important;
            }

            #maintenanceHistoryModal tbody td strong,
            #maintenanceHistoryModal tbody td span:not(.badge) {
                color: #000000 !important;
            }

            /* ✅ CHỈ BADGE MỚI CÓ MÀU RIÊNG */
            #maintenanceHistoryModal .badge {
                color: inherit !important;
            }
              /* CHATBOT RECOMMENDATIONS - Moved to bottom */
        .chatbot-recommendations {
            padding: 12px 15px;
            background: #f8f9fa;
            border-top: 1px solid #e0e0e0;
            max-height: 140px;
            overflow-y: auto;
            transition: all 0.3s ease;
        }

        .chatbot-recommendations.hidden {
            max-height: 0;
            padding: 0;
            border: none;
            overflow: hidden;
        }

        .recommendations-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 8px;
        }

        .recommendations-title {
            font-size: 0.75rem;
            color: #667eea;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 5px;
        }

        .recommendations-toggle {
            background: none;
            border: none;
            color: #667eea;
            cursor: pointer;
            font-size: 0.7rem;
            padding: 2px 8px;
            border-radius: 10px;
            transition: all 0.2s;
        }

        .recommendations-toggle:hover {
            background: rgba(102, 126, 234, 0.1);
        }

        .recommendation-chips {
            display: flex;
            flex-wrap: wrap;
            gap: 6px;
        }

        .recommendation-chip {
            background: white;
            border: 1px solid #e0e0e0;
            border-radius: 15px;
            padding: 5px 10px;
            font-size: 0.7rem;
            color: #333;
            cursor: pointer;
            transition: all 0.3s;
            white-space: nowrap;
            max-width: 100%;
            overflow: hidden;
            text-overflow: ellipsis;
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
        }

        .recommendation-chip:hover {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-color: #667eea;
            transform: translateY(-2px);
            box-shadow: 0 3px 8px rgba(102, 126, 234, 0.3);
        }

        .recommendation-category {
            width: 100%;
            font-size: 0.65rem;
            color: #888;
            margin-top: 6px;
            margin-bottom: 3px;
            font-weight: 500;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .chatbot-recommendations::-webkit-scrollbar {
            width: 4px;
        }

        .chatbot-recommendations::-webkit-scrollbar-thumb {
            background: #ddd;
            border-radius: 10px;
        }

        .chatbot-input {
            padding: 15px;
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
                    <span>CRM System</span>
                </a>
            </div>

            <div class="sidebar-menu">
                <div class="menu-section">
                    <a href="${pageContext.request.contextPath}/dashbroadCustomer.jsp" class="menu-item">
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
                    <a href="${pageContext.request.contextPath}/equipment" class="menu-item active">
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
            </div>

            <div class="sidebar-footer">
                <div class="user-info">
                    <div class="user-avatar">
                        <c:choose>
                            <c:when test="${not empty sessionScope.session_login.fullName}">
                                ${sessionScope.session_login.fullName.substring(0,1).toUpperCase()}
                            </c:when>
                            <c:otherwise>U</c:otherwise>
                        </c:choose>
                    </div>
                    <div class="user-details">
                        <div class="user-name">
                            <c:choose>
                                <c:when test="${not empty sessionScope.session_login.fullName}">
                                    ${sessionScope.session_login.fullName}
                                </c:when>
                                <c:otherwise>User</c:otherwise>
                            </c:choose>
                        </div>
                        <div class="user-role">
                            <c:choose>
                                <c:when test="${not empty sessionScope.session_role}">
                                    ${sessionScope.session_role}
                                </c:when>
                                <c:otherwise>Customer</c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
                <a href="${pageContext.request.contextPath}/logout" class="btn-logout" style="text-decoration: none;">
                    <i class="fas fa-sign-out-alt"></i>
                    <span>Đăng Xuất</span>
                </a>
            </div>
        </div>

        <!-- MAIN CONTENT -->
        <div class="main-content">
            <div class="top-navbar">
                <h1 class="page-title"><i class="fas fa-tools"></i> Quản Lý Thiết Bị</h1>
                <div class="d-flex gap-2">
                    <button class="btn btn-secondary" onclick="refreshPage()">
                        <i class="fas fa-sync"></i> Làm Mới
                    </button>
                </div>
            </div>

            <div id="toastContainer"></div>

            <div class="content-wrapper">
                <%
                    String errorMsg = (String) session.getAttribute("error");
                    String successMsg = (String) session.getAttribute("success");
                %>

                <% if (errorMsg != null || successMsg != null) { %>
                <script>
                    window.addEventListener('load', function () {
                    <% if (errorMsg != null) { 
                            session.removeAttribute("error");
                    %>
                        setTimeout(function () {
                            showToast('<%= errorMsg.replace("'", "\\'").replace("\"", "\\\"") %>', 'error');
                        }, 100);
                    <% } %>

                    <% if (successMsg != null) { 
                            session.removeAttribute("success");
                    %>
                        setTimeout(function () {
                            showToast('<%= successMsg.replace("'", "\\'").replace("\"", "\\\"") %>', 'success');
                        }, 100);
                    <% } %>
                    });
                </script>
                <% } %>

                <!-- THỐNG KÊ - 4 Ô -->
                <div class="row">
                    <div class="col-xl-3 col-lg-6 col-md-6 col-sm-6">
                        <div class="stats-card bg-primary text-white">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h6>Tổng Thiết Bị</h6>
                                    <h2>${totalEquipment != null ? totalEquipment : 0}</h2>
                                </div>
                                <i class="fas fa-clipboard-list"></i>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-lg-6 col-md-6 col-sm-6">
                        <div class="stats-card bg-success text-white">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h6>Đang Hoạt Động</h6>
                                    <h2>${activeCount != null ? activeCount : 0}</h2>
                                </div>
                                <i class="fas fa-check-circle"></i>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-lg-6 col-md-6 col-sm-6">
                        <div class="stats-card bg-warning text-dark">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h6>Đang Sửa Chữa</h6>
                                    <h2>${repairCount != null ? repairCount : 0}</h2>
                                </div>
                                <i class="fas fa-wrench"></i>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-lg-6 col-md-6 col-sm-6">
                        <div class="stats-card" style="background-color: #8b5cf6; color: white;">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h6>Đang Bảo Trì</h6>
                                    <h2>${maintenanceCount != null ? maintenanceCount : 0}</h2>
                                </div>
                                <i class="fas fa-cog"></i>
                            </div>
                        </div>
                    </div>
                </div>



                <!-- SEARCH BAR -->
                <div class="search-filter-bar">
                    <form action="${pageContext.request.contextPath}/equipment" method="get">
                        <input type="hidden" name="action" value="search"/>

                        <!-- Hàng 1: Search + Dropdowns -->
                        <div class="row g-3 mb-2">
                            <div class="col-md-3">
                                <label class="form-label fw-bold">Tìm kiếm</label>
                                <input type="text" class="form-control" name="keyword"
                                       placeholder="Tên thiết bị, serial number, mã hợp đồng..."
                                       value="${param.keyword}">
                            </div>

                            <div class="col-md-2">
                                <label class="form-label fw-bold">Trạng thái</label>
                                <select name="status" class="form-select">
                                    <option value="">Tất cả</option>
                                    <option value="Active" ${param.status == 'Active' ? 'selected' : ''}>Đang Hoạt Động</option>
                                    <option value="Repair" ${param.status == 'Repair' ? 'selected' : ''}>Đang Sửa Chữa</option>
                                </select>
                            </div>

                            <div class="col-md-3">
                                <label class="form-label fw-bold">Loại</label>
                                <select name="sourceType" class="form-select">
                                    <option value="">Tất cả</option>
                                    <option value="Hợp Đồng" ${param.sourceType == 'Hợp Đồng' ? 'selected' : ''}>Hợp Đồng</option>
                                    <option value="Phụ Lục" ${param.sourceType == 'Phụ Lục' ? 'selected' : ''}>Phụ Lục</option>
                                </select>
                            </div>

                            <div class="col-md-4">
                                <label class="form-label fw-bold">Sắp xếp</label>
                                <select name="sortBy" class="form-select">
                                    <option value="newest" ${param.sortBy == 'newest' ? 'selected' : ''}>Mới nhất</option>
                                    <option value="oldest" ${param.sortBy == 'oldest' ? 'selected' : ''}>Cũ nhất</option>
                                    <option value="name_asc" ${param.sortBy == 'name_asc' ? 'selected' : ''}>Tên A-Z</option>
                                    <option value="name_desc" ${param.sortBy == 'name_desc' ? 'selected' : ''}>Tên Z-A</option>
                                </select>
                            </div>
                        </div>

                        <!-- Hàng 2: Date range -->
                        <div class="row g-3 mb-2 align-items-end">
                            <div class="col-md-3">
                                <label class="form-label fw-bold">Từ ngày lắp đặt</label>
                                <input type="date" class="form-control" name="fromDate" value="${param.fromDate}">
                            </div>

                            <div class="col-md-3">
                                <label class="form-label fw-bold">Đến ngày lắp đặt</label>
                                <input type="date" class="form-control" name="toDate" value="${param.toDate}">
                            </div>
                        </div>

                        <!-- Hàng 3: Buttons -->
                        <div class="row g-3">
                            <div class="col-md-3 d-grid">
                                <button type="submit" class="btn btn-dark">
                                    <i class="fas fa-search me-1"></i> Tìm kiếm
                                </button>
                            </div>
                            <div class="col-md-3 d-grid">
                                <a href="${pageContext.request.contextPath}/equipment" class="btn btn-outline-dark">
                                    <i class="fas fa-sync-alt me-1"></i> Làm mới
                                </a>
                            </div>
                        </div>
                    </form>
                </div>


                <!-- TABLE -->
                <div class="table-container">
                    <div class="table-responsive">
                        <c:choose>
                            <c:when test="${not empty equipmentList}">
                                <table class="table table-hover">
                                    <thead class="table-light">
                                        <tr>
                                            <th>STT</th>
                                            <th>Tên Thiết Bị</th>
                                            <th>Serial Number</th>
                                            <th>Loại</th>
                                            <th>Mã Hợp Đồng</th>
                                            <th>Ngày Bắt Đầu</th>
                                            <th>Ngày Kết Thúc</th>
                                            <th>Trạng Thái</th>
                                            <th>Thao Tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="item" items="${equipmentList}" varStatus="status">
                                            <tr>
                                                <td><strong>${status.index + 1}</strong></td>
                                                <td><strong>${item.equipment.model}</strong></td>
                                                <td>${item.equipment.serialNumber}</td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${item.sourceType == 'Hợp Đồng'}">
                                                            <span class="badge bg-success">
                                                                <i class="fas fa-file-contract"></i> Hợp Đồng
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${item.sourceType == 'Phụ Lục'}">
                                                            <span class="badge bg-info">
                                                                <i class="fas fa-file-plus"></i> Phụ Lục
                                                            </span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge bg-secondary">
                                                                <i class="fas fa-question"></i> Không xác định
                                                            </span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td><span class="badge bg-primary">${item.contractId}</span></td>

                                                <!-- ✅ NGÀY BẮT ĐẦU -->
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${not empty item.startDate}">
                                                            <i class="fas fa-calendar-plus text-success me-1"></i>
                                                            ${item.startDate}
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="text-muted">
                                                                <i class="fas fa-minus"></i> Chưa có
                                                            </span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>

                                                <!-- ✅ NGÀY KẾT THÚC -->
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${not empty item.endDate}">
                                                            <i class="fas fa-calendar-times text-danger me-1"></i>
                                                            ${item.endDate}
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="text-muted">
                                                                <i class="fas fa-minus"></i> Chưa có
                                                            </span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>

                                                <!-- ✅ TRẠNG THÁI DỰA TRÊN NGÀY -->
                                                <td>
                                                    <c:choose>
                                                        <%-- Logic: Nếu có endDate và ngày hiện tại < endDate thì Active, ngược lại Expired --%>
                                                        <c:when test="${not empty item.endDate}">
                                                            <jsp:useBean id="now" class="java.util.Date"/>
                                                            <fmt:parseDate value="${item.endDate}" pattern="yyyy-MM-dd" var="parsedEndDate"/>

                                                            <c:choose>
                                                                <c:when test="${now.time < parsedEndDate.time}">
                                                                    <span class="badge bg-success">
                                                                        <i class="fas fa-check-circle"></i> Đang Hoạt Động
                                                                    </span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="badge bg-danger">
                                                                        <i class="fas fa-times-circle"></i> Hết Hạn
                                                                    </span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <%-- Nếu không có endDate, sử dụng status từ servlet --%>
                                                            <c:choose>
                                                                <c:when test="${item.status == 'Active'}">
                                                                    <span class="badge bg-success">
                                                                        <i class="fas fa-check-circle"></i> Đang Hoạt Động
                                                                    </span>
                                                                </c:when>
                                                                <c:when test="${item.status == 'Repair'}">
                                                                    <span class="badge badge-repair">
                                                                        <i class="fas fa-wrench"></i> Đang Sửa
                                                                    </span>
                                                                </c:when>
                                                                <c:when test="${item.status == 'Maintenance'}">
                                                                    <span class="badge badge-maintenance">
                                                                        <i class="fas fa-cog"></i> Bảo Trì
                                                                    </span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="badge bg-warning text-dark">
                                                                        <i class="fas fa-question-circle"></i> Pending
                                                                    </span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>

                                                <td>
                                                    <button class="btn btn-sm btn-info btn-action"
                                                            data-id="${item.equipment.equipmentId}"
                                                            data-model="${item.equipment.model}"
                                                            data-serial="${item.equipment.serialNumber}"
                                                            data-contract="${item.contractId}"
                                                            data-description="${item.equipment.description}"
                                                            data-install-date="${item.equipment.installDate}"
                                                            data-last-update="${item.equipment.lastUpdatedDate}"
                                                            data-status="${item.status}"
                                                            data-technician-name="${item.technicianName}"
                                                            data-repair-date="${item.repairDate}"
                                                            data-diagnosis="${item.diagnosis}"
                                                            data-repair-details="${item.repairDetails}"
                                                            data-estimated-cost="${item.estimatedCost}"
                                                            data-quotation-status="${item.quotationStatus}"
                                                            data-start-date="${item.startDate}"
                                                            data-end-date="${item.endDate}"
                                                            onclick="viewEquipmentDetail(this)">
                                                        <i class="fas fa-eye"></i> Chi Tiết
                                                    </button>

                                                    <button class="btn btn-sm btn-primary btn-action"
                                                            data-id="${item.equipment.equipmentId}"
                                                            data-model="${item.equipment.model}"
                                                            onclick="viewMaintenanceHistory(this)">
                                                        <i class="fas fa-history"></i> Lịch Sử Bảo Trì
                                                    </button>

                                                    <c:if test="${item.status == 'Active'}">
                                                        <button class="btn btn-sm btn-warning btn-action"
                                                                data-id="${item.equipment.equipmentId}"
                                                                data-contract="${item.contractId}"
                                                                data-serial="${item.equipment.serialNumber}"
                                                                data-model="${item.equipment.model}"
                                                                onclick="createRequest(this)">
                                                            <i class="fas fa-plus-circle"></i> Tạo Đơn
                                                        </button>
                                                    </c:if>

                                                    <c:if test="${item.status != 'Active'}">
                                                        <button disabled 
                                                                title="Thiết bị đang ${item.status == 'Repair' ? 'sửa chữa' : 'bảo trì'}">
                                                        </button>
                                                    </c:if>                                               
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </c:when>
                            <c:otherwise>
                                <div class="text-center py-5">
                                    <i class="fas fa-box-open fa-3x text-muted mb-3"></i>
                                    <h4 class="text-muted">Không tìm thấy thiết bị</h4>
                                    <p class="text-muted">
                                        <c:choose>
                                            <c:when test="${searchMode}">
                                                Không tìm thấy thiết bị phù hợp với từ khóa "<strong>${keyword}</strong>"
                                            </c:when>
                                            <c:otherwise>
                                                Hiện tại bạn chưa có thiết bị nào trong hệ thống
                                            </c:otherwise>
                                        </c:choose>
                                    </p>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <!-- PHÂN TRANG - GIỮ NGUYÊN -->
                    <c:if test="${totalPages > 1}">
                        <nav aria-label="Page navigation" class="mt-4">
                            <ul class="pagination justify-content-center">
                                <li class="page-item ${currentPage <= 1 ? 'disabled' : ''}">
                                    <c:if test="${currentPage > 1}">
                                        <a class="page-link" href="javascript:void(0)" onclick="goToPage(${currentPage - 1})">
                                            <i class="fas fa-chevron-left"></i> Trước
                                        </a>
                                    </c:if>
                                    <c:if test="${currentPage <= 1}">
                                        <span class="page-link">
                                            <i class="fas fa-chevron-left"></i> Trước
                                        </span>
                                    </c:if>
                                </li>

                                <c:forEach var="i" begin="1" end="${totalPages}">
                                    <li class="page-item ${i == currentPage ? 'active' : ''}">
                                        <c:if test="${i != currentPage}">
                                            <a class="page-link" href="javascript:void(0)" onclick="goToPage(${i})">
                                                ${i}
                                            </a>
                                        </c:if>
                                        <c:if test="${i == currentPage}">
                                            <span class="page-link">${i}</span>
                                        </c:if>
                                    </li>
                                </c:forEach>

                                <li class="page-item ${currentPage >= totalPages ? 'disabled' : ''}">
                                    <c:if test="${currentPage < totalPages}">
                                        <a class="page-link" href="javascript:void(0)" onclick="goToPage(${currentPage + 1})">
                                            Tiếp <i class="fas fa-chevron-right"></i>
                                        </a>
                                    </c:if>
                                    <c:if test="${currentPage >= totalPages}">
                                        <span class="page-link">
                                            Tiếp <i class="fas fa-chevron-right"></i>
                                        </span>
                                    </c:if>
                                </li>
                            </ul>
                        </nav>

                        <div class="text-center text-muted mb-3">
                            <small>
                                Trang <strong>${currentPage}</strong> của <strong>${totalPages}</strong> 
                                | Hiển thị <strong>${fn:length(equipmentList)}</strong> thiết bị
                            </small>
                        </div>
                    </c:if>
                </div>

                <!-- FOOTER -->
                <footer class="site-footer">
                    <div class="footer-content">
                        <div class="footer-grid">
                            <div class="footer-section">
                                <h5>CRM System</h5>
                                <p class="footer-about">
                                    Giải pháp quản lý khách hàng toàn diện, giúp doanh nghiệp tối ưu hóa quy trình và nâng cao chất lượng dịch vụ.
                                </p>
                            </div>

                            <div class="footer-section">
                                <h5>Tính năng chính</h5>
                                <ul class="footer-links">
                                    <li><a href="#">→ Quản lý khách hàng</a></li>
                                    <li><a href="#">→ Quản lý hợp đồng</a></li>
                                    <li><a href="#">→ Quản lý thiết bị</a></li>
                                    <li><a href="#">→ Báo cáo & Phân tích</a></li>
                                </ul>
                            </div>

                            <div class="footer-section">
                                <h5>Hỗ trợ</h5>
                                <ul class="footer-links">
                                    <li><a href="#">→ Trung tâm trợ giúp</a></li>
                                    <li><a href="#">→ Hướng dẫn sử dụng</a></li>
                                    <li><a href="#">→ Liên hệ hỗ trợ</a></li>
                                    <li><a href="#">→ Câu hỏi thường gặp</a></li>
                                </ul>
                            </div>

                            <div class="footer-section">
                                <h5>Thông tin</h5>
                                <ul class="footer-links">
                                    <li><a href="#">→ Về chúng tôi</a></li>
                                    <li><a href="#">→ Điều khoản sử dụng</a></li>
                                    <li><a href="#">→ Chính sách bảo mật</a></li>
                                    <li><a href="#">→ Liên hệ</a></li>
                                </ul>
                            </div>
                        </div>

                        <div class="footer-bottom">
                            <p class="footer-copyright">
                                &copy; 2025 CRM System. All rights reserved. | Phát triển bởi <strong>Group 6</strong>
                            </p>
                        </div>
                    </div>
                </footer>

                <!-- Scroll to Top Button -->
                <div class="scroll-to-top" id="scrollToTop" onclick="scrollToTop()">
                    <i class="fas fa-arrow-up"></i>
                </div>
            </div>

            <!-- ✅ MODAL VIEW EQUIPMENT - CẬP NHẬT HIỂN THỊ THÔNG TIN SỬA CHỮA -->
            <div class="modal fade" id="viewModal" tabindex="-1">
                <div class="modal-dialog modal-xl">
                    <div class="modal-content">
                        <div class="modal-header bg-info text-white">
                            <h5 class="modal-title">
                                <i class="fas fa-info-circle"></i> Chi Tiết Thiết Bị
                            </h5>
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                        </div>
                        <div class="modal-body">
                            <!-- THÔNG TIN CƠ BẢN -->
                            <div class="card mb-3">
                                <div class="card-header bg-light">
                                    <h6 class="mb-0"><i class="fas fa-tools"></i> Thông Tin Thiết Bị</h6>
                                </div>
                                <div class="card-body">
                                    <div class="row mb-3">
                                        <div class="col-md-6">
                                            <strong>Tên Thiết Bị:</strong>
                                            <p class="fw-normal" id="viewEquipmentName"></p>
                                        </div>
                                        <div class="col-md-6">
                                            <strong>Serial Number:</strong>
                                            <p class="fw-normal" id="viewSerialNumber"></p>
                                        </div>
                                    </div>

                                    <div class="row mb-3">
                                        <div class="col-md-6">
                                            <strong>Mã Hợp Đồng:</strong>
                                            <p class="fw-normal" id="viewContractId"></p>
                                        </div>
                                        <div class="col-md-6">
                                            <strong>Ngày Lắp Đặt:</strong>
                                            <p class="fw-normal" id="viewInstallDate"></p>
                                        </div>
                                    </div>

                                    <div class="row mb-3">
                                        <div class="col-md-6">
                                            <strong>Cập Nhật Lần Cuối:</strong>
                                            <p class="fw-normal" id="viewLastUpdate"></p>
                                        </div>
                                        <div class="col-md-6">
                                            <strong>Trạng Thái:</strong>
                                            <span class="badge" id="viewStatus"></span>
                                        </div>
                                    </div>

                                    <div class="mb-3">
                                        <strong>Mô Tả:</strong>
                                        <div class="border rounded p-3 bg-light" id="viewDescription"></div>
                                    </div>
                                </div>
                            </div>

                            <!-- ✅ THÔNG TIN SỬA CHỮA (CHỈ HIỂN THỊ KHI STATUS = REPAIR) -->
                            <div id="repairInfoSection" style="display: none;">
                                <div class="card border-warning">
                                    <div class="card-header bg-warning text-dark">
                                        <h6 class="mb-0">
                                            <i class="fas fa-wrench"></i> Thông Tin Sửa Chữa
                                        </h6>
                                    </div>
                                    <div class="card-body">
                                        <div class="row mb-3">
                                            <div class="col-md-6">
                                                <strong><i class="fas fa-user-cog"></i> Kỹ Thuật Viên:</strong>
                                                <p class="text-primary fw-bold" id="viewTechnicianName">Đang tải...</p>
                                            </div>
                                            <div class="col-md-6">
                                                <strong><i class="fas fa-calendar-check"></i> Ngày Bắt Đầu Sửa:</strong>
                                                <p id="viewRepairDate">N/A</p>
                                            </div>
                                        </div>                                  
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                                <i class="fas fa-times"></i> Đóng
                            </button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- MODAL CREATE SERVICE REQUEST for Equipment -->
            <div class="modal fade" id="createRequestModal" tabindex="-1">
                <div class="modal-dialog modal-lg">
                    <div class="modal-content">
                        <div class="modal-header bg-warning text-dark">
                            <h5 class="modal-title">
                                <i class="fas fa-plus-circle"></i> Tạo Đơn Hỗ Trợ Thiết Bị
                            </h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                        </div>
                        <form action="${pageContext.request.contextPath}/managerServiceRequest" method="post" id="createRequestForm" onsubmit="return validateEquipmentRequestForm(event)">
                            <input type="hidden" name="action" value="CreateServiceRequest">
                            <input type="hidden" name="supportType" value="equipment">
                            <input type="hidden" name="equipmentIds" id="requestEquipmentId">
                            <input type="hidden" name="contractId" id="requestContractIdValue">

                            <div class="modal-body">
                                <!-- ✅ THÊM MỚI: Loại Yêu Cầu (Request Type) -->
                                <div class="mb-3">
                                    <label class="form-label">
                                        <i class="fas fa-tags"></i> Loại Yêu Cầu 
                                        <span class="text-danger">*</span>
                                    </label>
                                    <select class="form-select" name="requestType" id="equipmentRequestType" required>
                                        <option value="Service">🔧 Service (Dịch vụ sửa chữa)</option>
                                        <option value="Warranty">🛡️ Warranty (Bảo hành)</option>
                                    </select>
                                    <small class="form-text text-muted">
                                        <i class="fas fa-info-circle"></i> Service: Dịch vụ sửa chữa thông thường | Warranty: Sửa chữa theo bảo hành hợp đồng
                                    </small>
                                </div>

                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label">
                                            <i class="fas fa-tools"></i> Tên Thiết Bị
                                            <span class="text-danger">*</span>
                                        </label>
                                        <input type="text" class="form-control" 
                                               id="requestEquipmentName" readonly>
                                    </div>

                                    <div class="col-md-6 mb-3">
                                        <label class="form-label">
                                            <i class="fas fa-file-contract"></i> Mã Hợp Đồng
                                            <span class="text-danger">*</span>
                                        </label>
                                        <input type="text" class="form-control" 
                                               id="requestContractId" readonly>
                                    </div>
                                </div>

                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label">
                                            <i class="fas fa-barcode"></i> Serial Number
                                        </label>
                                        <input type="text" class="form-control" 
                                               id="requestSerialNumber" readonly>
                                    </div>

                                    <div class="col-md-6 mb-3">
                                        <label class="form-label">
                                            <i class="fas fa-exclamation-circle"></i> Mức Độ Ưu Tiên 
                                            <span class="text-danger">*</span>
                                        </label>
                                        <select class="form-select" name="priorityLevel" id="equipmentPriorityLevel" required>
                                            <option value="">-- Chọn mức độ --</option>
                                            <option value="Normal">⚪ Bình Thường</option>
                                            <option value="High">🟡 Cao</option>
                                            <option value="Urgent">🔴 Khẩn Cấp</option>
                                        </select>
                                    </div>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label">
                                        <i class="fas fa-comment-dots"></i> Mô Tả Vấn Đề 
                                        <span class="text-danger">*</span>
                                    </label>
                                    <textarea class="form-control" name="description" id="equipmentRequestDescription" rows="5" 
                                              placeholder="Mô tả chi tiết vấn đề bạn đang gặp phải với thiết bị..."
                                              minlength="10" maxlength="1000" required
                                              oninput="updateEquipmentCharCount()"></textarea>
                                    <div class="d-flex justify-content-between align-items-center mt-1">
                                        <small class="form-text text-muted">
                                            <i class="fas fa-info-circle"></i> Tối thiểu 10 ký tự, tối đa 1000 ký tự
                                        </small>
                                        <span id="equipmentCharCount" class="text-muted" style="font-size: 0.875rem;">0/1000</span>
                                    </div>
                                </div>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                                    <i class="fas fa-times"></i> Hủy
                                </button>
                                <button type="submit" class="btn btn-warning">
                                    <i class="fas fa-paper-plane"></i> Gửi Yêu Cầu
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>



            <!-- ✅ MODAL LỊCH SỬ BẢO TRÌ - ĐÃ SỬA -->
            <div class="modal fade" id="maintenanceHistoryModal" tabindex="-1">
                <div class="modal-dialog modal-xl">
                    <div class="modal-content">
                        <div class="modal-header bg-primary text-white">
                            <h5 class="modal-title">
                                <i class="fas fa-history"></i> Lịch Sử Bảo Trì - <span id="historyEquipmentName"></span>
                            </h5>
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                        </div>

                        <!-- ✅ THÊM STYLE CHO MODAL BODY -->
                        <div class="modal-body" style="min-height: 400px; max-height: 70vh; overflow-y: auto; padding: 20px;">

                            <!-- Loading spinner -->
                            <div id="historyLoading" class="text-center py-5" style="display: none;">
                                <div class="spinner-border text-primary" role="status" style="width: 3rem; height: 3rem;">
                                    <span class="visually-hidden">Loading...</span>
                                </div>
                                <p class="mt-3 text-muted fw-bold">Đang tải lịch sử bảo trì...</p>
                            </div>

                            <!-- Empty state -->
                            <div id="historyEmpty" class="text-center py-5" style="display: none;">
                                <i class="fas fa-inbox fa-3x text-muted mb-3"></i>
                                <h5 class="text-muted">Chưa có lịch sử bảo trì</h5>
                                <p class="text-muted">Thiết bị này chưa được bảo trì lần nào</p>
                            </div>

                            <!-- History table -->
                            <div id="historyContent" style="display: none;">
                                <div class="table-responsive">
                                    <table class="table table-hover table-bordered mb-0">
                                        <thead class="table-light" style="position: sticky; top: 0; z-index: 10; background-color: #f8f9fa;">
                                            <tr>
                                                <th width="5%" class="text-center">STT</th>
                                                <th width="15%">Kỹ Thuật Viên</th>
                                                <th width="15%">Ngày Giờ Bảo Trì</th>
                                                <th width="12%">Loại Bảo Trì</th>                                           
                                                <th width="12%">Loại Task</th>
                                                <th width="10%">Trạng Thái</th>
                                                <!-- <th width="19%">Chi Tiết</th> -->
                                            </tr>
                                        </thead>
                                        <tbody id="historyTableBody" style="background-color: #ffffff;">
                                            <!-- Data will be inserted here by JavaScript -->
                                        </tbody>
                                    </table>
                                </div>

                                <!-- Pagination for history -->
                                <nav aria-label="History pagination" id="historyPagination" class="mt-3" style="display: none;">
                                    <ul class="pagination justify-content-center mb-0" id="historyPaginationList">
                                        <!-- Pagination will be inserted here by JavaScript -->
                                    </ul>
                                </nav>
                            </div>
                        </div>

                        <div class="modal-footer bg-light">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                                <i class="fas fa-times"></i> Đóng
                            </button>
                        </div>
                    </div>
                </div>
            </div>

            <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
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

        container.innerHTML = '';

        const allQuestions = FAQ_DATA.flatMap(category => 
            category.questions.map(q => ({
                question: q.question,
                category: category.category
            }))
        );

        const shuffled = [...allQuestions].sort(() => 0.5 - Math.random());
        const selectedQuestions = shuffled.slice(0, 6);

        const questionsByCategory = {};
        selectedQuestions.forEach(item => {
            if (!questionsByCategory[item.category]) {
                questionsByCategory[item.category] = [];
            }
            questionsByCategory[item.category].push(item.question);
        });

        Object.entries(questionsByCategory).forEach(([category, questions]) => {
            const categoryDiv = document.createElement('div');
            categoryDiv.className = 'recommendation-category';
            categoryDiv.textContent = category;
            container.appendChild(categoryDiv);

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

    function toggleRecommendations() {
        showNewRecommendations();
    }

    function hideRecommendations() {
        const recommendations = document.getElementById('chatbotRecommendations');
        if (recommendations) {
            recommendations.classList.add('hidden');
        }
    }

    function showRecommendations() {
        const recommendations = document.getElementById('chatbotRecommendations');
        if (recommendations) {
            recommendations.classList.remove('hidden');
            showNewRecommendations();
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
            contentDiv.textContent = content;
            messageDiv.appendChild(contentDiv);
            messageDiv.appendChild(avatar);
        } else {
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
        
        hideRecommendations();
        
        addMessage(question, true);
        input.value = '';
        
        input.disabled = true;
        sendBtn.disabled = true;
        
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
            
            setTimeout(() => {
                showRecommendations();
            }, 500);
            
        } catch (error) {
            hideTyping();
            addMessage('Xin lỗi, không thể kết nối đến server. Vui lòng thử lại sau.', false);
            console.error('Error:', error);
            
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
        
        let formatted = text.replace(/\n/g, '<br>');
        formatted = formatted.replace(/(\d+\.)\s/g, '<br>$1 ');
        formatted = formatted.replace(/^- /gm, '<br>• ');
        formatted = formatted.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>');
        formatted = formatted.replace(/([A-Z][^.!?]*:\s*)/g, '<strong>$1</strong>');
        
        return formatted;
    }
</script>

    </body>
</html>
