<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>CRM Dashboard - Quản Lý Hóa Đơn</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
        <style>
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }

            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                background: linear-gradient(135deg, #f5f7fa 0%, #e8ecf1 100%);
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
                box-shadow: 0 4px 10px rgba(255, 193, 7, 0.3);
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
                border: 1px solid rgba(255,255,255,0.3);
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
                background: linear-gradient(135deg, #dc3545, #c82333);
                color: white;
                border-color: #dc3545;
                transform: translateY(-2px);
                box-shadow: 0 4px 12px rgba(220, 53, 69, 0.3);
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
                box-shadow: 0 2px 10px rgba(0,0,0,0.08);
                display: flex;
                justify-content: space-between;
                align-items: center;
                backdrop-filter: blur(10px);
            }

            .page-title {
                font-size: 1.8rem;
                font-weight: 700;
                background: linear-gradient(135deg, #1e3c72, #2a5298);
                -webkit-background-clip: text;
                -webkit-text-fill-color: transparent;
                margin: 0;
                display: flex;
                align-items: center;
                gap: 12px;
            }

            .page-title i {
                background: linear-gradient(135deg, #ffc107, #ff9800);
                -webkit-background-clip: text;
                -webkit-text-fill-color: transparent;
            }

            .content-wrapper {
                padding: 30px;
            }

            .stats-card {
                border-radius: 15px;
                padding: 25px;
                margin-bottom: 20px;
                box-shadow: 0 4px 15px rgba(0,0,0,0.1);
                transition: all 0.3s;
                position: relative;
                overflow: hidden;
            }

            .stats-card::before {
                content: '';
                position: absolute;
                top: -50%;
                right: -50%;
                width: 200%;
                height: 200%;
                background: radial-gradient(circle, rgba(255,255,255,0.2) 0%, transparent 70%);
                animation: pulse 3s ease-in-out infinite;
            }

            @keyframes pulse {
                0%, 100% {
                    transform: scale(0.8);
                    opacity: 0.3;
                }
                50% {
                    transform: scale(1.2);
                    opacity: 0.5;
                }
            }

            .stats-card:hover {
                transform: translateY(-8px);
                box-shadow: 0 8px 25px rgba(0,0,0,0.2);
            }

            .stats-card i {
                font-size: 2.8rem;
                opacity: 0.9;
            }

            .stats-card h6 {
                font-size: 0.9rem;
                font-weight: 600;
                margin-bottom: 8px;
                opacity: 0.9;
            }

            .stats-card h2 {
                font-size: 2rem;
                font-weight: 700;
                margin: 0;
            }

            .table-container {
                background: white;
                border-radius: 15px;
                padding: 30px;
                box-shadow: 0 4px 20px rgba(0,0,0,0.08);
                margin-top: 20px;
            }

            .table {
                margin-bottom: 0;
            }

            .table thead th {
                border-bottom: 2px solid #dee2e6;
                font-weight: 600;
                color: #1e3c72;
                text-transform: uppercase;
                font-size: 0.85rem;
                letter-spacing: 0.5px;
                padding: 15px 10px;
            }

            .table tbody tr {
                transition: all 0.3s;
            }

            .table tbody tr:hover {
                background-color: rgba(30, 60, 114, 0.05);
                transform: scale(1.01);
            }

            .table tbody td {
                vertical-align: middle;
                padding: 15px 10px;
            }

            .badge-paid {
                background: linear-gradient(135deg, #198754, #157347);
                padding: 6px 12px;
                border-radius: 20px;
                font-size: 0.8rem;
            }

            .badge-pending {
                background: linear-gradient(135deg, #ffc107, #ffb300);
                color: #000;
                padding: 6px 12px;
                border-radius: 20px;
                font-size: 0.8rem;
            }

            .badge-overdue {
                background: linear-gradient(135deg, #dc3545, #c82333);
                padding: 6px 12px;
                border-radius: 20px;
                font-size: 0.8rem;
            }

            .search-filter-bar {
                background: white;
                padding: 25px;
                border-radius: 15px;
                margin-bottom: 20px;
                box-shadow: 0 4px 15px rgba(0,0,0,0.08);
            }

            .form-control {
                border-radius: 10px;
                border: 2px solid #e9ecef;
                padding: 12px 15px;
                transition: all 0.3s;
            }

            .form-control:focus {
                border-color: #ffc107;
                box-shadow: 0 0 0 0.2rem rgba(255, 193, 7, 0.25);
            }

            .btn {
                border-radius: 10px;
                padding: 10px 20px;
                font-weight: 600;
                transition: all 0.3s;
            }

            .btn-primary {
                background: linear-gradient(135deg, #1e3c72, #2a5298);
                border: none;
            }

            .btn-primary:hover {
                background: linear-gradient(135deg, #2a5298, #1e3c72);
                transform: translateY(-2px);
                box-shadow: 0 4px 12px rgba(30, 60, 114, 0.3);
            }

            .btn-secondary {
                background: linear-gradient(135deg, #6c757d, #5a6268);
                border: none;
            }

            .btn-secondary:hover {
                background: linear-gradient(135deg, #5a6268, #545b62);
                transform: translateY(-2px);
                box-shadow: 0 4px 12px rgba(108, 117, 125, 0.3);
            }

            .btn-info {
                background: linear-gradient(135deg, #0dcaf0, #0aa2c0);
                border: none;
            }

            .btn-info:hover {
                background: linear-gradient(135deg, #0aa2c0, #0987a0);
                transform: translateY(-2px);
                box-shadow: 0 4px 12px rgba(13, 202, 240, 0.3);
            }

            .btn-action {
                padding: 6px 12px;
                margin: 0 2px;
                font-size: 0.85rem;
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
                border-radius: 12px;
                padding: 15px 20px;
                box-shadow: 0 8px 20px rgba(0,0,0,0.15);
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
                position: relative;
            }

            .site-footer::before {
                content: '';
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                height: 1px;
                background: linear-gradient(90deg, transparent, rgba(255,193,7,0.5), transparent);
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
                margin-bottom: 40px;
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
                height: 3px;
                background: linear-gradient(90deg, #ffc107, transparent);
                border-radius: 2px;
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

            .footer-social {
                display: flex;
                gap: 15px;
            }

            .social-link {
                width: 40px;
                height: 40px;
                border-radius: 50%;
                background: rgba(255,255,255,0.1);
                display: flex;
                align-items: center;
                justify-content: center;
                color: white;
                text-decoration: none;
                transition: all 0.3s;
            }

            .social-link:hover {
                background: #ffc107;
                color: #1a202c;
                transform: translateY(-3px);
            }

            .scroll-to-top {
                position: fixed;
                bottom: 30px;
                right: 30px;
                width: 50px;
                height: 50px;
                background: linear-gradient(135deg, #ffc107, #ff9800);
                color: white;
                border-radius: 50%;
                display: none;
                align-items: center;
                justify-content: center;
                cursor: pointer;
                transition: all 0.3s;
                z-index: 998;
                box-shadow: 0 4px 15px rgba(255, 193, 7, 0.4);
            }

            .scroll-to-top:hover {
                background: linear-gradient(135deg, #ff9800, #ffc107);
                transform: translateY(-5px);
                box-shadow: 0 6px 20px rgba(255, 193, 7, 0.6);
            }

            .scroll-to-top.show {
                display: flex;
            }

            /* PARTS DETAIL STYLES */
            .border-left-primary {
                border-left: 4px solid #007bff !important;
            }

     /* ✅✅✅ PAGINATION STYLES - MÀU XANH DƯƠNG ✅✅✅ */
            .pagination .page-item .page-link {
                border-radius: 8px;
                border: 1px solid #dee2e6;
                color: #495057;
                padding: 8px 15px;
                font-weight: 500;
                transition: all 0.3s;
                margin: 0 2px;
                background: white;
            }

            .pagination .page-item.active .page-link {
                background: #007bff;
                border-color: #007bff;
                color: white;
            }

            .pagination .page-item:not(.disabled) .page-link:hover {
                background: #0056b3;
                border-color: #0056b3;
                color: white;
            }

            .pagination .page-item.disabled .page-link {
                background: #f8f9fa;
                border-color: #dee2e6;
                color: #6c757d;
                cursor: not-allowed;
            }

            .pagination {
                margin: 0;
            }

            .pagination .page-item {
                margin: 0 2px;
            }
            /* ✅✅✅ KẾT THÚC PAGINATION STYLES ✅✅✅ */

            @media (max-width: 576px) {
                .pagination .page-item:not(.active):not(:first-child):not(:last-child):not(:nth-child(2)):not(:nth-last-child(2)) {
                    display: none;
                }
            }

            .card-body .text-xs {
                font-size: 0.75rem;
            }

            .table-hover tbody tr:hover {
                background-color: rgba(0, 123, 255, 0.05);
            }

            .text-truncate {
                overflow: hidden;
                text-overflow: ellipsis;
                white-space: nowrap;
            }

            .badge {
                font-size: 0.75rem;
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
                animation: pulseBadge 2s infinite;
            }

            @keyframes pulseBadge {
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

            /* RESPONSIVE */
            @media (max-width: 1200px) {
                .footer-grid {
                    grid-template-columns: repeat(2, 1fr);
                    gap: 40px;
                }
            }

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

                .page-title {
                    font-size: 1.3rem;
                }

                .stats-card h2 {
                    font-size: 1.5rem;
                }

                .top-navbar {
                    flex-direction: column;
                    gap: 15px;
                    align-items: flex-start;
                }

                .chatbot-window {
                    width: calc(100vw - 30px);
                    right: 15px;
                }
            }
            
            
            /* XÓA HORIZONTAL SCROLLBAR */
            .table-responsive {
                overflow-x: hidden !important;
                -webkit-overflow-scrolling: touch;
            }

            /* Nếu muốn cho phép scroll dọc nhưng ẩn thanh scroll */
            .table-responsive::-webkit-scrollbar {
                display: none;
            }

            .table-responsive {
                -ms-overflow-style: none;  /* IE and Edge */
                scrollbar-width: none;  /* Firefox */
            }

            /* Đảm bảo table không bị overflow */
            .table-container {
                overflow: visible;
            }

            .table {
                width: 100%;
                margin-bottom: 0;
                table-layout: auto;
            }

            .table th,
            .table td {
                white-space: normal;
                word-wrap: break-word;
                vertical-align: middle;
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
                    <a href="${pageContext.request.contextPath}/equipment" class="menu-item">
                        <i class="fas fa-tools"></i>
                        <span>Thiết Bị</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/invoices" class="menu-item active">
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
                <h1 class="page-title">
                    <i class="fas fa-file-invoice-dollar"></i>
                    Quản Lý Hóa Đơn
                </h1>
                <div class="d-flex gap-2">
                    <button class="btn btn-secondary" onclick="refreshPage()">
                        <i class="fas fa-sync-alt"></i> Làm Mới
                    </button>
                </div>
            </div>

            <div id="toastContainer"></div>

            <div class="content-wrapper">
                <!-- THỐNG KÊ - 4 Ô -->
                <div class="row">
                    <div class="col-xl-3 col-lg-6 col-md-6 col-sm-6">
                        <div class="stats-card bg-primary text-white">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h6>Tổng Hóa Đơn</h6>
                                    <h2>${totalInvoices != null ? totalInvoices : 0}</h2>
                                </div>
                                <i class="fas fa-file-invoice"></i>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-lg-6 col-md-6 col-sm-6">
                        <div class="stats-card bg-success text-white">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h6>Đã Thanh Toán</h6>
                                    <h2>${paidCount != null ? paidCount : 0}</h2>
                                </div>
                                <i class="fas fa-check-circle"></i>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-lg-6 col-md-6 col-sm-6">
                        <div class="stats-card bg-warning text-dark">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h6>Chưa Thanh Toán</h6>
                                    <h2>${pendingCount != null ? pendingCount : 0}</h2>
                                </div>
                                <i class="fas fa-clock"></i>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-lg-6 col-md-6 col-sm-6">
                        <div class="stats-card" style="background: linear-gradient(135deg, #8b5cf6, #7c3aed); color: white;">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h6>Tổng Tiền</h6>
                                    <h2><fmt:formatNumber value="${(totalAmount != null ? totalAmount : 0) * 26000}" pattern="#,###" /> đ</h2>
                                </div>
                                <i class="fas fa-dollar-sign"></i>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- SEARCH BAR -->
                <div class="search-filter-bar">
                    <form action="${pageContext.request.contextPath}/invoices" method="get">
                        <input type="hidden" name="action" value="search"/>

                        <!-- Hàng 1: Search + Dropdowns -->
                        <div class="row g-3 mb-2">
                            <div class="col-md-3">
                                <label class="form-label fw-bold">Tìm kiếm</label>
                                <input type="text" class="form-control" name="keyword"
                                       placeholder="Mã hóa đơn, số tiền, mã hợp đồng..."
                                       value="${param.keyword}">
                            </div>

                            <div class="col-md-2">
                                <label class="form-label fw-bold">Trạng thái</label>
                                <select name="status" class="form-select">
                                    <option value="">Tất cả</option>
                                    <option value="Paid" ${param.status == 'Paid' ? 'selected' : ''}>Đã Thanh Toán</option>
                                    <option value="Pending" ${param.status == 'Pending' ? 'selected' : ''}>Chưa Thanh Toán</option>
                                    <option value="Overdue" ${param.status == 'Overdue' ? 'selected' : ''}>Quá Hạn</option>
                                </select>
                            </div>

                            <div class="col-md-3">
                                <label class="form-label fw-bold">Phương thức thanh toán</label>
                                <select name="paymentMethod" class="form-select">
                                    <option value="">Tất cả</option>
                                    <option value="Bank" ${param.paymentMethod == 'Bank' ? 'selected' : ''}>Chuyển Khoản Ngân Hàng</option>
                                    <option value="Cash" ${param.paymentMethod == 'Cash' ? 'selected' : ''}>Tiền Mặt</option>
                                    <option value="VNPAY" ${param.paymentMethod == 'VNPAY' ? 'selected' : ''}>VNPAY</option>
                                </select>
                            </div>

                            <div class="col-md-2">
                                <label class="form-label fw-bold">Sắp xếp</label>
                                <select name="sortBy" class="form-select">
                                    <option value="newest" ${param.sortBy == 'newest' ? 'selected' : ''}>Mới nhất</option>
                                    <option value="oldest" ${param.sortBy == 'oldest' ? 'selected' : ''}>Cũ nhất</option>
                                    <option value="amount_asc" ${param.sortBy == 'amount_asc' ? 'selected' : ''}>Số tiền tăng dần</option>
                                    <option value="amount_desc" ${param.sortBy == 'amount_desc' ? 'selected' : ''}>Số tiền giảm dần</option>
                                </select>
                            </div>
                        </div>

                        <!-- Hàng 2: Date range -->
                        <div class="row g-3 mb-2 align-items-end">
                            <div class="col-md-3">
                                <label class="form-label fw-bold">Từ ngày phát hành</label>
                                <input type="date" class="form-control" name="fromDate" value="${param.fromDate}">
                            </div>

                            <div class="col-md-3">
                                <label class="form-label fw-bold">Đến ngày phát hành</label>
                                <input type="date" class="form-control" name="toDate" value="${param.toDate}">
                            </div>

                            <div class="col-md-3">
                                <label class="form-label fw-bold">Từ ngày đến hạn</label>
                                <input type="date" class="form-control" name="fromDueDate" value="${param.fromDueDate}">
                            </div>

                            <div class="col-md-3">
                                <label class="form-label fw-bold">Đến ngày đến hạn</label>
                                <input type="date" class="form-control" name="toDueDate" value="${param.toDueDate}">
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
                                <a href="${pageContext.request.contextPath}/invoices" class="btn btn-outline-dark">
                                    <i class="fas fa-sync-alt me-1"></i> Làm mới
                                </a>
                            </div>
                        </div>
                    </form>
                </div>

                <!-- CHI TIẾT HÓA ĐƠN (nếu có) -->
                <c:if test="${viewMode == 'detail' && not empty selectedInvoice}">
                    <div class="table-container mb-4">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h4 class="mb-0">
                                <i class="fas fa-file-invoice-dollar text-primary me-2"></i>
                                Chi Tiết Hóa Đơn #INV${selectedInvoice.invoiceId}
                            </h4>
                            <div>
                                <button class="btn btn-outline-primary btn-sm me-2" onclick="printInvoice(${selectedInvoice.invoiceId})">
                                    <i class="fas fa-print"></i> In Hóa Đơn
                                </button>
                                <button class="btn btn-outline-success btn-sm me-2" onclick="exportInvoicePDF(${selectedInvoice.invoiceId})">
                                    <i class="fas fa-file-pdf"></i> Xuất PDF
                                </button>
                                <a href="${pageContext.request.contextPath}/invoices" class="btn btn-secondary btn-sm">
                                    <i class="fas fa-arrow-left"></i> Quay Lại
                                </a>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-6">
                                <div class="card border-0 shadow-sm">
                                    <div class="card-header bg-primary text-white">
                                        <h6 class="mb-0"><i class="fas fa-info-circle me-2"></i>Thông Tin Hóa Đơn</h6>
                                    </div>
                                    <div class="card-body">
                                        <table class="table table-borderless">
                                            <tr>
                                                <td><strong>Mã Hóa Đơn:</strong></td>
                                                <td>#INV${selectedInvoice.invoiceId}</td>
                                            </tr>
                                            <tr>
                                                <td><strong>Mã Hợp Đồng:</strong></td>
                                                <td><span class="badge bg-primary">${formattedContractId}</span></td>
                                            </tr>
                                            <tr>
                                                <td><strong>Ngày Phát Hành:</strong></td>
                                                <td><fmt:formatDate value="${selectedInvoice.issueDate}" pattern="dd/MM/yyyy"/></td>
                                            </tr>
                                            <tr>
                                                <td><strong>Hạn Thanh Toán:</strong></td>
                                                <td><fmt:formatDate value="${selectedInvoice.dueDate}" pattern="dd/MM/yyyy"/></td>
                                            </tr>
                                            <tr>
                                                <td><strong>Tổng Tiền:</strong></td>
                                                <td><strong class="text-success fs-5"><fmt:formatNumber value="${selectedInvoice.totalAmount * 26000}" pattern="#,###"/> đ</strong></td>
                                            </tr>
                                            <tr>
                                                <td><strong>Trạng Thái:</strong></td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${selectedInvoice.status == 'Paid'}">
                                                            <span class="badge badge-paid fs-6">
                                                                <i class="fas fa-check-circle"></i> Đã Thanh Toán
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${selectedInvoice.status == 'Pending'}">
                                                            <span class="badge badge-pending fs-6">
                                                                <i class="fas fa-clock"></i> Chưa Thanh Toán
                                                            </span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge badge-overdue fs-6">
                                                                <i class="fas fa-exclamation-triangle"></i> Quá Hạn
                                                            </span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </tr>
                                        </table>
                                    </div>
                                </div>
                            </div>

                            <div class="col-md-6">
                                <div class="card border-0 shadow-sm">
                                    <div class="card-header bg-success text-white">
                                        <h6 class="mb-0"><i class="fas fa-list me-2"></i>Chi Tiết Dịch Vụ</h6>
                                    </div>
                                    <div class="card-body">
                                        <c:choose>
                                            <c:when test="${not empty invoiceDetails}">
                                                <div class="table-responsive">
                                                    <table class="table table-sm">
                                                        <thead>
                                                            <tr>
                                                                <th>Mô Tả</th>
                                                                <th class="text-end">Số Tiền</th>
                                                            </tr>
                                                        </thead>
                                                        <tbody>
                                                            <c:forEach var="detail" items="${invoiceDetails}">
                                                                <tr>
                                                                    <td>${detail.description}</td>
                                                                    <td class="text-end">
                                                                        <fmt:formatNumber value="${detail.amount * 26000}" pattern="#,###"/> đ
                                                                    </td>
                                                                </tr>
                                                            </c:forEach>
                                                        </tbody>
                                                        <tfoot>
                                                            <tr class="table-active">
                                                                <th>Tổng Cộng:</th>
                                                                <th class="text-end">
                                                                    <fmt:formatNumber value="${selectedInvoice.totalAmount * 26000}" pattern="#,###"/> đ
                                                                </th>
                                                            </tr>
                                                        </tfoot>
                                                    </table>
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <p class="text-muted text-center">Không có chi tiết dịch vụ</p>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Chi tiết linh kiện sử dụng -->
                        <c:if test="${not empty repairPartDetails}">
                            <div class="row mt-4">
                                <div class="col-12">
                                    <div class="card border-0 shadow-sm">
                                        <div class="card-header bg-warning text-dark">
                                            <h6 class="mb-0"><i class="fas fa-cogs me-2"></i>Chi Tiết Linh Kiện Sử Dụng</h6>
                                        </div>
                                        <div class="card-body">
                                            <div class="table-responsive">
                                                <table class="table table-sm table-hover">
                                                    <thead class="table-light">
                                                        <tr>
                                                            <th><i class="fas fa-hashtag me-1"></i>Báo Cáo</th>
                                                            <th><i class="fas fa-cog me-1"></i>Tên Linh Kiện</th>
                                                            <th><i class="fas fa-tags me-1"></i>Danh Mục</th>
                                                            <th class="text-center"><i class="fas fa-sort-numeric-up me-1"></i>Số Lượng</th>
                                                            <th class="text-end"><i class="fas fa-dollar-sign me-1"></i>Đơn Giá</th>
                                                            <th class="text-end"><i class="fas fa-calculator me-1"></i>Thành Tiền</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <c:forEach var="part" items="${repairPartDetails}">
                                                            <tr>
                                                                <td>
                                                                    <small class="text-muted">#${part.reportId}</small><br>
                                                                    <span class="text-truncate" style="max-width: 150px; display: inline-block;" title="${part.reportDescription}">
                                                                        ${part.reportDescription}
                                                                    </span>
                                                                </td>
                                                                <td>
                                                                    <strong>${part.partName}</strong>
                                                                </td>
                                                                <td>
                                                                    <span class="badge bg-secondary">${part.category}</span>
                                                                </td>
                                                                <td class="text-center">
                                                                    <span class="badge bg-primary">${part.quantity}</span>
                                                                </td>
                                                                <td class="text-end">
                                                                    <fmt:formatNumber value="${part.price * 26000}" pattern="#,###"/> đ
                                                                </td>
                                                                <td class="text-end">
                                                                    <strong class="text-success">
                                                                        <fmt:formatNumber value="${part.totalPrice * 26000}" pattern="#,###"/> đ
                                                                    </strong>
                                                                </td>
                                                            </tr>
                                                        </c:forEach>
                                                    </tbody>
                                                    <tfoot class="table-active">
                                                        <tr>
                                                            <th colspan="5" class="text-end">Tổng Tiền Linh Kiện:</th>
                                                            <th class="text-end">
                                                                <strong class="text-success fs-5">
                                                                    <fmt:formatNumber value="${partsTotalAmount * 26000}" pattern="#,###"/> đ
                                                                </strong>
                                                            </th>
                                                        </tr>
                                                    </tfoot>
                                                </table>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </c:if>

                        <!-- Thống kê theo danh mục linh kiện -->
                        <c:if test="${not empty partsCategoryStats}">
                            <div class="row mt-4">
                                <div class="col-12">
                                    <div class="card border-0 shadow-sm">
                                        <div class="card-header bg-info text-white">
                                            <h6 class="mb-0"><i class="fas fa-chart-pie me-2"></i>Thống Kê Theo Danh Mục Linh Kiện</h6>
                                        </div>
                                        <div class="card-body">
                                            <div class="row">
                                                <c:forEach var="stat" items="${partsCategoryStats}">
                                                    <div class="col-md-4 mb-3">
                                                        <div class="card border-left-primary h-100">
                                                            <div class="card-body">
                                                                <div class="row no-gutters align-items-center">
                                                                    <div class="col mr-2">
                                                                        <div class="text-xs font-weight-bold text-primary text-uppercase mb-1">
                                                                            ${stat.category}
                                                                        </div>
                                                                        <div class="h5 mb-0 font-weight-bold text-gray-800">
                                                                            <fmt:formatNumber value="${stat.categoryTotal * 26000}" pattern="#,###"/> đ
                                                                        </div>
                                                                        <div class="text-muted small">
                                                                            ${stat.partCount} loại linh kiện • ${stat.totalQuantity} cái
                                                                        </div>
                                                                    </div>
                                                                    <div class="col-auto">
                                                                        <i class="fas fa-cogs fa-2x text-gray-300"></i>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </c:forEach>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </c:if>
                    </div>
                </c:if>

                <!-- TABLE -->
                <div class="table-container">
                    <div class="table-responsive">
                        <c:choose>
                            <c:when test="${not empty invoiceList}">
                                <table class="table table-hover">
                                    <thead class="table-light">
                                        <tr>
                                            <th><i class="fas fa-hashtag me-2"></i>Mã HĐ</th>
                                            <th><i class="fas fa-file-contract me-2"></i>Mã Hợp Đồng</th>
                                            <th><i class="fas fa-calendar-alt me-2"></i>Ngày Phát Hành</th>
                                            <th><i class="fas fa-calendar-check me-2"></i>Hạn Thanh Toán</th>
                                            <th><i class="fas fa-money-bill-wave me-2"></i>Tổng Tiền</th>
                                            <th><i class="fas fa-credit-card me-2"></i>Phương Thức</th>
                                            <th><i class="fas fa-info-circle me-2"></i>Trạng Thái</th>
                                            <!-- <th class="text-center"><i class="fas fa-cog me-2"></i>Thao Tác</th> -->
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="item" items="${invoiceList}" varStatus="status">
                                            <tr>
                                                <td><strong class="text-primary">#INV${item.invoice.invoiceId}</strong></td>
                                                <td><span class="badge bg-primary">${item.formattedContractId}</span></td>
                                                <td>
                                                    <i class="fas fa-calendar text-muted me-2"></i>
                                                    <c:choose>
                                                        <c:when test="${not empty item.invoice.issueDate}">
                                                            ${item.invoice.issueDate}
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="text-muted">Chưa có</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <i class="fas fa-calendar text-muted me-2"></i>
                                                    <c:choose>
                                                        <c:when test="${not empty item.invoice.dueDate}">
                                                            ${item.invoice.dueDate}
                                                            <c:if test="${item.invoice.status == 'Pending' || item.invoice.status == 'Overdue'}">
                                                                <small class="text-danger ms-1">
                                                                    <i class="fas fa-exclamation-triangle"></i> Kiểm tra hạn
                                                                </small>
                                                            </c:if>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="text-muted">Chưa có</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td><strong class="text-success"><fmt:formatNumber value="${item.invoice.totalAmount * 26000}" pattern="#,###"/> đ</strong></td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${not empty item.invoice.paymentMethod}">
                                                            <c:choose>
                                                                <c:when test="${item.invoice.paymentMethod == 'Bank'}">
                                                                    <span class="badge bg-info text-dark">
                                                                        <i class="fas fa-university"></i> Ngân Hàng
                                                                    </span>
                                                                </c:when>
                                                                <c:when test="${item.invoice.paymentMethod == 'Cash'}">
                                                                    <span class="badge bg-success">
                                                                        <i class="fas fa-money-bill"></i> Tiền Mặt
                                                                    </span>
                                                                </c:when>
                                                                <c:when test="${item.invoice.paymentMethod == 'VNPAY'}">
                                                                    <span class="badge bg-primary">
                                                                        <i class="fas fa-credit-card"></i> VNPAY
                                                                    </span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="badge bg-secondary">
                                                                        <i class="fas fa-question"></i> ${item.invoice.paymentMethod}
                                                                    </span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="text-muted">
                                                                <i class="fas fa-minus"></i> Chưa thanh toán
                                                            </span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${item.invoice.status == 'Paid'}">
                                                            <span class="badge badge-paid">
                                                                <i class="fas fa-check-circle"></i> Đã Thanh Toán
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${item.invoice.status == 'Pending'}">
                                                            <span class="badge badge-pending">
                                                                <i class="fas fa-clock"></i> Chưa Thanh Toán
                                                            </span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge badge-overdue">
                                                                <i class="fas fa-exclamation-triangle"></i> Quá Hạn
                                                            </span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>                                              
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </c:when>
                            <c:otherwise>
                                <div class="text-center py-5">
                                    <i class="fas fa-inbox fa-4x text-muted mb-3" style="opacity: 0.3;"></i>
                                    <h4 class="text-muted">Không tìm thấy hóa đơn</h4>
                                    <p class="text-muted">
                                        <c:choose>
                                            <c:when test="${searchMode}">
                                                Không tìm thấy hóa đơn phù hợp với từ khóa "<strong>${keyword}</strong>"
                                            </c:when>
                                            <c:otherwise>
                                                Hiện tại bạn chưa có hóa đơn nào trong hệ thống
                                            </c:otherwise>
                                        </c:choose>
                                    </p>
                                    <c:if test="${searchMode}">
                                        <a href="${pageContext.request.contextPath}/invoices" class="btn btn-primary mt-3">
                                            <i class="fas fa-arrow-left"></i> Quay lại danh sách
                                        </a>
                                    </c:if>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>




                <c:if test="${totalPages >= 1}">
                    <c:url var="baseUrl" value="invoices">
                        <c:param name="keyword" value="${param.keyword}" />
                        <c:param name="status" value="${param.status}" />
                        <c:param name="paymentMethod" value="${param.paymentMethod}" />
                        <c:param name="sortBy" value="${param.sortBy}" />
                        <c:param name="fromDate" value="${param.fromDate}" />
                        <c:param name="toDate" value="${param.toDate}" />
                        <c:param name="fromDueDate" value="${param.fromDueDate}" />
                        <c:param name="toDueDate" value="${param.toDueDate}" />
                    </c:url>

                    <nav aria-label="Page navigation" class="mt-4">
                        <ul class="pagination justify-content-center">
                            <li class="page-item ${currentPage <= 1 ? 'disabled' : ''}">
                                <a class="page-link" href="${baseUrl}&page=${currentPage - 1}">
                                    <i class="fas fa-chevron-left"></i> Trước
                                </a>
                            </li>

                            <c:forEach var="i" begin="1" end="${totalPages}">
                                <li class="page-item ${i == currentPage ? 'active' : ''}">
                                    <a class="page-link" href="${baseUrl}&page=${i}">${i}</a>
                                </li>
                            </c:forEach>

                            <li class="page-item ${currentPage >= totalPages ? 'disabled' : ''}">
                                <a class="page-link" href="${baseUrl}&page=${currentPage + 1}">
                                    Tiếp <i class="fas fa-chevron-right"></i>
                                </a>
                            </li>
                        </ul>
                    </nav>

                    <div class="text-center text-muted mb-3">
                        <small>
                            Trang <strong>${currentPage}</strong> / <strong>${totalPages}</strong> |
                            Hiển thị <strong>${fn:length(invoiceList)}</strong> hóa đơn
                        </small>
                    </div>
                </c:if>
                <!-- ✅✅✅ KẾT THÚC PAGINATION ✅✅✅ -->

            </div>
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
                            <li><a href="#">→ Quản lý hóa đơn</a></li>
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
                            <li><a href="#">→ Điều khoản dịch vụ</a></li>
                            <li><a href="#">→ Chính sách bảo mật</a></li>
                            <li><a href="#">→ Liên hệ</a></li>
                        </ul>
                    </div>
                </div>

                <div class="footer-bottom">
                    <div class="footer-copyright">
                        © 2025 CRM System. All rights reserved. Made with <i class="fas fa-heart text-danger"></i> in Vietnam
                    </div>
                    <div class="footer-social">
                        <a href="#" class="social-link" title="Facebook">
                            <i class="fab fa-facebook-f"></i>
                        </a>
                        <a href="#" class="social-link" title="Twitter">
                            <i class="fab fa-twitter"></i>
                        </a>
                        <a href="#" class="social-link" title="LinkedIn">
                            <i class="fab fa-linkedin-in"></i>
                        </a>
                        <a href="#" class="social-link" title="Instagram">
                            <i class="fab fa-instagram"></i>
                        </a>
                    </div>
                </div>
            </div>
        </footer>

        <!-- SCROLL TO TOP BUTTON -->
        <div class="scroll-to-top" id="scrollToTop">
            <i class="fas fa-arrow-up"></i>
        </div>

        <!-- CHATBOT WIDGET -->
        <div class="chatbot-container">
            <button class="chatbot-button" onclick="toggleChatbotWidget()">
                <i class="fas fa-comment-dots"></i>
                <span class="chatbot-badge">AI</span>
            </button>

            <div class="chatbot-window" id="chatbotWindowWidget">
                <div class="chatbot-header">
                    <h4>
                        <i class="fas fa-robot"></i>
                        Trợ lý AI
                    </h4>
                    <button class="chatbot-close" onclick="toggleChatbotWidget()">
                        <i class="fas fa-times"></i>
                    </button>
                </div>

                <!-- PHẦN RECOMMENDATIONS -->
                <div class="chatbot-recommendations" id="chatbotRecommendationsWidget">
                    <div class="recommendations-title">
                        <i class="fas fa-lightbulb"></i>
                        Câu hỏi thường gặp
                    </div>
                    <div class="recommendation-chips" id="recommendationChipsWidget">
                        <!-- Recommendations sẽ được thêm bằng JavaScript -->
                    </div>
                </div>

                <div class="chatbot-messages" id="chatMessagesWidget">
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
                    <input type="text" id="chatInputWidget" placeholder="Nhập câu hỏi của bạn..." onkeypress="handleKeyPressWidget(event)">
                    <button class="chatbot-send" id="sendBtnWidget" onclick="sendMessageWidget()">
                        <i class="fas fa-paper-plane"></i>
                    </button>
                </div>
            </div>
        </div>

        <!-- SCRIPTS -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <script>
                        // Toggle Sidebar
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

                        // Refresh Page
                        function refreshPage() {
                            location.reload();
                        }

                        // Toast Notification Function
                        function showToast(message, type = 'success') {
                            const container = document.getElementById('toastContainer');
                            const toast = document.createElement('div');
                            toast.className = 'toast-notification ' + type;

                            const icon = type === 'success' ? 'fa-check-circle' : 'fa-exclamation-circle';

                            toast.innerHTML =
                                    '<div class="toast-icon ' + type + '">' +
                                    '<i class="fas ' + icon + '"></i>' +
                                    '</div>' +
                                    '<div class="toast-content">' +
                                    '<strong>' + (type === 'success' ? 'Thành công!' : 'Lỗi!') + '</strong>' +
                                    '<p style="margin: 0; font-size: 0.9rem;">' + message + '</p>' +
                                    '</div>' +
                                    '<button class="toast-close" onclick="closeToast(this)">' +
                                    '<i class="fas fa-times"></i>' +
                                    '</button>';

                            container.appendChild(toast);

                            setTimeout(function () {
                                toast.classList.add('hiding');
                                setTimeout(function () {
                                    toast.remove();
                                }, 400);
                            }, 5000);
                        }

                        function closeToast(btn) {
                            const toast = btn.closest('.toast-notification');
                            toast.classList.add('hiding');
                            setTimeout(() => toast.remove(), 400);
                        }

                        // Scroll to Top
                        const scrollToTopBtn = document.getElementById('scrollToTop');

                        window.addEventListener('scroll', () => {
                            if (window.pageYOffset > 300) {
                                scrollToTopBtn.classList.add('show');
                            } else {
                                scrollToTopBtn.classList.remove('show');
                            }
                        });

                        scrollToTopBtn.addEventListener('click', () => {
                            window.scrollTo({
                                top: 0,
                                behavior: 'smooth'
                            });
                        });

                        // Check for URL parameters to show toast
                        window.addEventListener('DOMContentLoaded', () => {
                            const urlParams = new URLSearchParams(window.location.search);
                            const success = urlParams.get('success');
                            const error = urlParams.get('error');

                            if (success) {
                                showToast(decodeURIComponent(success), 'success');
                            }
                            if (error) {
                                showToast(decodeURIComponent(error), 'error');
                            }
                        });

                        // Mobile Sidebar Toggle
                        if (window.innerWidth <= 768) {
                            const sidebar = document.getElementById('sidebar');
                            document.addEventListener('click', (e) => {
                                if (!sidebar.contains(e.target) && sidebar.classList.contains('show')) {
                                    sidebar.classList.remove('show');
                                }
                            });
                        }

                        // Add animation to stats cards on page load
                        window.addEventListener('load', () => {
                            const statsCards = document.querySelectorAll('.stats-card');
                            statsCards.forEach((card, index) => {
                                setTimeout(() => {
                                    card.style.opacity = '0';
                                    card.style.transform = 'translateY(20px)';
                                    card.style.transition = 'all 0.5s ease';

                                    setTimeout(() => {
                                        card.style.opacity = '1';
                                        card.style.transform = 'translateY(0)';
                                    }, 50);
                                }, index * 100);
                            });
                        });

                        // Xuất hóa đơn PDF
                        function exportInvoicePDF(invoiceId) {
                            window.open('${pageContext.request.contextPath}/invoices?action=exportPDF&id=' + invoiceId, '_blank');
                        }

                        // In hóa đơn
                        function printInvoice(invoiceId) {
                            window.open('${pageContext.request.contextPath}/invoices?action=print&id=' + invoiceId, '_blank');
                        }

                        // Làm nổi bật hóa đơn quá hạn
                        document.addEventListener('DOMContentLoaded', function () {
                            const overdueRows = document.querySelectorAll('tr:has(.badge-overdue)');
                            overdueRows.forEach(row => {
                                row.style.backgroundColor = 'rgba(220, 53, 69, 0.05)';
                                row.style.borderLeft = '4px solid #dc3545';
                            });
                        });

                        // ========== CHATBOT FUNCTIONS ==========

                        // FAQ DATA
                        const FAQ_DATA_WIDGET = [
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
                                        "answer": "Để tạo yêu cầu, quý khách thực hiện theo các bước sau:\n\n1. Truy cập trang \"Yêu cầu dịch vụ\"\n2. Nhấn nút \"Tạo yêu cầu mới\" ở góc trên màn hình\n3. Chọn \"Hỗ trợ thiết bị\"\n4. Chọn thiết bị cần bảo hành từ danh sách\n5. Chọn mức độ ưu tiên cho yêu cầu\n6. Mô tả chi tiết vấn đề của thiết bị\n7. Kiểm tra lại thông tin và nhấn \"Gửi yêu cầu\""
                                    },
                                    {
                                        "question": "Thời gian xử lý yêu cầu mất bao lâu?",
                                        "answer": "Thời gian xử lý yêu cầu phụ thuộc vào:\n- Mức độ ưu tiên của yêu cầu\n- Tình trạng thiết bị\n- Khả năng sẵn có của phụ tùng\n\nThông thường:\n- Yêu cầu khẩn cấp: 24-48 giờ\n- Yêu cầu thường: 3-5 ngày làm việc"
                                    },
                                    {
                                        "question": "Các trạng thái của yêu cầu dịch vụ có ý nghĩa gì?",
                                        "answer": "Yêu cầu sẽ đi qua các trạng thái:\n\n1. Chờ xác nhận: Yêu cầu vừa được tạo\n2. Chờ xử lý: Đã được xác nhận, chờ phân công\n3. Đang xử lý: Kỹ thuật viên đang xử lý\n4. Hoàn thành: Đã sửa chữa xong\n5. Đã hủy: Yêu cầu bị hủy"
                                    }
                                ]
                            },
                            {
                                "category": "Hợp đồng",
                                "questions": [
                                    {
                                        "question": "Làm thế nào để xem thông tin hợp đồng?",
                                        "answer": "Để xem thông tin hợp đồng:\n\n1. Truy cập trang \"Hợp đồng\"\n2. Xem danh sách tất cả các hợp đồng\n3. Nhấn \"Danh sách thiết bị\" để xem chi tiết\n\nThông tin bao gồm:\n- Mã hợp đồng\n- Loại hợp đồng\n- Ngày hiệu lực\n- Trạng thái"
                                    },
                                    {
                                        "question": "Chính sách bảo hành như thế nào?",
                                        "answer": "Chính sách bảo hành:\n\n- Thời gian: Theo hợp đồng (12-36 tháng)\n- Phạm vi: Lỗi nhà sản xuất, hỏng hóc bình thường\n- Miễn phí phụ tùng và sửa chữa\n\nKhông bảo hành:\n- Sử dụng sai cách\n- Va đập, rơi vỡ\n- Can thiệp bởi bên thứ ba"
                                    }
                                ]
                            },
                            {
                                "category": "Hóa đơn & Thanh toán",
                                "questions": [
                                    {
                                        "question": "Làm thế nào để xem hóa đơn?",
                                        "answer": "Để xem hóa đơn:\n\n1. Truy cập trang \"Hóa đơn\"\n2. Xem danh sách hóa đơn\n\nThông tin gồm:\n- Mã hóa đơn\n- Số tiền\n- Ngày phát hành\n- Hạn thanh toán\n- Trạng thái"
                                    },
                                    {
                                        "question": "Làm thế nào để thanh toán hóa đơn?",
                                        "answer": "Các phương thức thanh toán:\n\n1. Thanh toán trực tuyến:\n- Chuyển khoản ngân hàng\n- Ví điện tử (Momo, ZaloPay)\n- Thẻ ATM/Tín dụng\n\n2. Thanh toán trực tiếp:\n- Tại văn phòng\n- Thu tiền tận nơi"
                                    }
                                ]
                            },
                            {
                                "category": "Thiết bị",
                                "questions": [
                                    {
                                        "question": "Làm thế nào để xem thông tin thiết bị?",
                                        "answer": "Để xem thiết bị:\n\n1. Truy cập trang \"Thiết bị\"\n2. Xem danh sách thiết bị\n3. Nhấn \"Chi tiết\" để xem thêm\n\nThông tin:\n- Tên thiết bị\n- Mã/Serial number\n- Hợp đồng liên quan\n- Trạng thái\n- Thời hạn bảo hành"
                                    }
                                ]
                            }
                        ];

                        // Initialize recommendations when page loads
                        document.addEventListener('DOMContentLoaded', function () {
                            showNewRecommendationsWidget();
                        });

                        function showNewRecommendationsWidget() {
                            const container = document.getElementById('recommendationChipsWidget');
                            if (!container)
                                return;

                            container.innerHTML = '';

                            // Get all questions
                            const allQuestions = FAQ_DATA_WIDGET.flatMap(category =>
                                category.questions.map(q => ({
                                        question: q.question,
                                        category: category.category
                                    }))
                            );

                            // Random 6 questions
                            const shuffled = [...allQuestions].sort(() => 0.5 - Math.random());
                            const selectedQuestions = shuffled.slice(0, 6);

                            // Group by category
                            const questionsByCategory = {};
                            selectedQuestions.forEach(item => {
                                if (!questionsByCategory[item.category]) {
                                    questionsByCategory[item.category] = [];
                                }
                                questionsByCategory[item.category].push(item.question);
                            });

                            // Render chips
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
                                    chip.onclick = () => sendRecommendedQuestionWidget(question);
                                    container.appendChild(chip);
                                });
                            });
                        }

                        function sendRecommendedQuestionWidget(question) {
                            const input = document.getElementById('chatInputWidget');
                            input.value = question;
                            sendMessageWidget();
                        }

                        function hideRecommendationsWidget() {
                            const recommendations = document.getElementById('chatbotRecommendationsWidget');
                            if (recommendations) {
                                recommendations.style.display = 'none';
                            }
                        }

                        function showRecommendationsWidget() {
                            const recommendations = document.getElementById('chatbotRecommendationsWidget');
                            if (recommendations) {
                                recommendations.style.display = 'block';
                                showNewRecommendationsWidget();
                            }
                        }

                        function toggleChatbotWidget() {
                            const chatWindow = document.getElementById('chatbotWindowWidget');
                            chatWindow.classList.toggle('active');

                            if (chatWindow.classList.contains('active')) {
                                showRecommendationsWidget();
                                setTimeout(() => {
                                    document.getElementById('chatInputWidget').focus();
                                }, 300);
                            }
                        }

                        function handleKeyPressWidget(event) {
                            if (event.key === 'Enter') {
                                sendMessageWidget();
                            }
                        }

                        function addMessageWidget(content, isUser = false) {
                            const messagesDiv = document.getElementById('chatMessagesWidget');
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
                                contentDiv.innerHTML = formatMessageWidget(content);
                                messageDiv.appendChild(avatar);
                                messageDiv.appendChild(contentDiv);
                            }

                            messagesDiv.appendChild(messageDiv);
                            messagesDiv.scrollTop = messagesDiv.scrollHeight;
                        }

                        function showTypingWidget() {
                            const messagesDiv = document.getElementById('chatMessagesWidget');
                            const typingDiv = document.createElement('div');
                            typingDiv.className = 'message bot';
                            typingDiv.id = 'typingIndicatorWidget';

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

                        function hideTypingWidget() {
                            const typing = document.getElementById('typingIndicatorWidget');
                            if (typing) {
                                typing.remove();
                            }
                        }

                        async function sendMessageWidget() {
                            const input = document.getElementById('chatInputWidget');
                            const sendBtn = document.getElementById('sendBtnWidget');
                            const question = input.value.trim();

                            if (!question)
                                return;

                            hideRecommendationsWidget();
                            addMessageWidget(question, true);
                            input.value = '';

                            input.disabled = true;
                            sendBtn.disabled = true;

                            showTypingWidget();

                            try {
                                const response = await fetch('${pageContext.request.contextPath}/askGemini', {
                                    method: 'POST',
                                    headers: {
                                        'Content-Type': 'application/json'
                                    },
                                    body: JSON.stringify({q: question})
                                });

                                const data = await response.json();
                                hideTypingWidget();

                                if (data.success && data.answer) {
                                    addMessageWidget(data.answer, false);
                                } else {
                                    addMessageWidget(data.error || 'Xin lỗi, có lỗi xảy ra. Vui lòng thử lại.', false);
                                }

                                setTimeout(() => {
                                    showRecommendationsWidget();
                                }, 500);

                            } catch (error) {
                                hideTypingWidget();
                                addMessageWidget('Xin lỗi, không thể kết nối đến server. Vui lòng thử lại sau.', false);
                                console.error('Error:', error);

                                setTimeout(() => {
                                    showRecommendationsWidget();
                                }, 500);
                            } finally {
                                input.disabled = false;
                                sendBtn.disabled = false;
                                input.focus();
                            }
                        }

                        function formatMessageWidget(text) {
                            if (!text)
                                return '';

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