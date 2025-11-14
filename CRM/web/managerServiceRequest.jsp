<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>CRM Dashboard - Manager Service Request</title>
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

            .menu-section-title {
                padding: 8px 20px;
                color: rgba(255,255,255,0.5);
                font-size: 0.75rem;
                font-weight: 600;
                text-transform: uppercase;
                letter-spacing: 1px;
                transition: all 0.3s;
            }

            .sidebar.collapsed .menu-section-title {
                opacity: 0;
                height: 0;
                padding: 0;
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

            .menu-item .badge {
                margin-left: auto;
                font-size: 0.7rem;
            }

            .sidebar.collapsed .menu-item .badge {
                display: none;
            }

            /* SIDEBAR FOOTER */
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

            /* TOGGLE BUTTON */
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

            /* ✅ NEW TABLE STYLES - EXPANDABLE ROWS */
            .table-container {
                background: white;
                border-radius: 10px;
                padding: 0;
                box-shadow: 0 2px 8px rgba(0,0,0,0.1);
                overflow: hidden;
            }

            .expandable-table {
                width: 100%;
            }

            .table-header {
                background: #2c3e50;
                color: white;
                display: grid;
                grid-template-columns: 80px 150px 2fr 120px 140px 100px;
                gap: 15px;
                padding: 15px 20px;
                font-weight: 600;
                font-size: 0.9rem;
            }

            .request-row {
                border-bottom: 1px solid #ecf0f1;
                transition: all 0.3s;
            }

            .request-row:hover {
                background: #f8f9fa;
            }

            .request-header {
                display: grid;
                grid-template-columns: 80px 150px 2fr 120px 140px 100px;
                gap: 15px;
                padding: 18px 20px;
                align-items: center;
                cursor: pointer;
            }

            .request-id {
                display: flex;
                align-items: center;
                gap: 8px;
                font-weight: 600;
                color: #2c3e50;
                font-size: 0.9rem;
            }

            .chevron-icon {
                width: 14px;
                height: 14px;
                transition: transform 0.3s;
                opacity: 0;
            }

            .request-row.has-quotation .chevron-icon {
                opacity: 1;
            }

            .chevron-icon.expanded {
                transform: rotate(90deg);
            }

            .request-equipment {
                color: #2c3e50;
                font-weight: 500;
                font-size: 0.9rem;
            }

            .request-description {
                color: #7f8c8d;
                font-size: 0.85rem;
            }

            .request-date {
                color: #34495e;
                font-size: 0.85rem;
            }

            /* STATUS BADGES */
            .badge {
                padding: 6px 12px;
                border-radius: 20px;
                font-size: 0.75rem;
                font-weight: 600;
                display: inline-flex;
                align-items: center;
                gap: 5px;
            }

            .badge-pending {
                background-color: #ffc107;
                color: #000;
            }
            .badge-awaiting {
                background-color: #ff9800;
                color: #fff;
            }
            .badge-inprogress {
                background-color: #0dcaf0;
            }
            .badge-completed {
                background-color: #198754;
            }
            .badge-cancelled {
                background-color: #dc3545;
            }

            /* ✅ QUOTATION DETAILS - EXPANDABLE SECTION */
            .quotation-details {
                background: #f8f9fa;
                padding: 25px;
                border-top: 1px solid #ecf0f1;
                display: none;
            }

            .quotation-details.show {
                display: block;
            }

            .quotation-header-text {
                display: flex;
                align-items: center;
                gap: 10px;
                color: #3498db;
                font-weight: 600;
                margin-bottom: 20px;
                font-size: 0.95rem;
            }

            .quotation-header-text::before {
                content: '';
                width: 12px;
                height: 12px;
                background: #3498db;
                border-radius: 50%;
            }

            .quotation-table {
                background: white;
                border-radius: 8px;
                overflow: hidden;
            }

            .quotation-table-header {
                background: #2c3e50;
                color: white;
                display: grid;
                grid-template-columns: 180px 2fr 180px 140px 140px;
                gap: 15px;
                padding: 15px 20px;
                font-weight: 600;
                font-size: 0.9rem;
            }

            .technician-row {
                border-bottom: 1px solid #ecf0f1;
                transition: all 0.3s;
            }

            .technician-header {
                display: grid;
                grid-template-columns: 180px 2fr 180px 140px 140px;
                gap: 15px;
                padding: 18px 20px;
                align-items: center;
                cursor: pointer;
            }

            .technician-header:hover {
                background: #f8f9fa;
            }

            .technician-name {
                display: flex;
                align-items: center;
                gap: 10px;
                font-weight: 600;
                color: #2c3e50;
            }

            .technician-work {
                color: #34495e;
            }

            .tech-parts-count {
                font-size: 0.8rem;
                color: #95a5a6;
                margin-top: 3px;
            }

            .technician-cost {
                color: #e74c3c;
                font-weight: 700;
            }

            /* PARTS TABLE */
            .parts-section {
                background: #f8f9fa;
                padding: 20px;
                display: none;
            }

            .parts-section.show {
                display: block;
            }

            .parts-date {
                font-size: 0.85rem;
                color: #7f8c8d;
                margin-bottom: 15px;
            }

            .parts-table {
                background: white;
                border-radius: 8px;
                overflow: hidden;
                border: 1px solid #ecf0f1;
            }

            .parts-table-header {
                background: #ecf0f1;
                display: grid;
                grid-template-columns: 2fr 180px 100px 140px 140px;
                gap: 15px;
                padding: 12px 20px;
                font-weight: 600;
                font-size: 0.85rem;
                color: #2c3e50;
            }

            .parts-table-row {
                display: grid;
                grid-template-columns: 2fr 180px 100px 140px 140px;
                gap: 15px;
                padding: 15px 20px;
                border-bottom: 1px solid #ecf0f1;
                font-size: 0.9rem;
            }

            .parts-table-row:hover {
                background: #f8f9fa;
            }

            .parts-table-row:last-child {
                border-bottom: none;
            }

            .parts-serial {
                color: #7f8c8d;
                font-family: 'Courier New', monospace;
            }

            .parts-quantity {
                text-align: center;
            }

            .parts-price, .parts-total {
                text-align: right;
            }

            .parts-total {
                color: #e74c3c;
                font-weight: 600;
            }

            .parts-table-footer {
                background: #ecf0f1;
                display: grid;
                grid-template-columns: 2fr 180px 100px 140px 140px 180px;
                gap: 15px;
                padding: 12px 20px;
                font-weight: 700;
            }

            .parts-table-footer .total-label {
                grid-column: 1 / 6;
                text-align: right;
                color: #2c3e50;
            }

            .parts-table-footer .total-value {
                text-align: right;
                color: #e74c3c;
            }

            /* ACTION BUTTONS */
            .action-buttons {
                display: flex;
                gap: 8px;
                align-items: center;
                justify-content: center;
            }

            .btn-action {
                padding: 6px 12px;
                border: none;
                border-radius: 6px;
                font-size: 0.8rem;
                font-weight: 600;
                cursor: pointer;
                transition: all 0.3s;
                display: inline-flex;
                align-items: center;
                gap: 5px;
            }

            .btn-paid {
                background: #27ae60;
                color: white;
                cursor: default;
            }

            .btn-pay {
                background: #27ae60;
                color: white;
            }

            .btn-pay:hover {
                background: #229954;
            }

            .btn-cancel {
                background: #e74c3c;
                color: white;
            }

            .btn-cancel:hover {
                background: #c0392b;
            }

            .paid-status {
                color: #27ae60;
                font-size: 0.85rem;
                display: flex;
                align-items: center;
                gap: 5px;
            }

            /* ✅ TECHNICIAN PAYMENT SECTION */
            .technician-payment-section {
                margin-top: 20px;
                padding: 20px;
                background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
                border-radius: 12px;
                border: 2px solid #dee2e6;
                display: flex;
                justify-content: space-between;
                align-items: center;
                gap: 20px;
            }

            .payment-summary {
                flex: 1;
            }

            .payment-summary-text {
                font-size: 0.9rem;
                color: #6c757d;
                margin-bottom: 8px;
                font-weight: 500;
            }

            .payment-total-amount {
                font-size: 1.5rem;
                font-weight: 700;
                color: #2c3e50;
            }

            .btn-pay-all {
                padding: 12px 30px;
                background: linear-gradient(135deg, #27ae60 0%, #229954 100%);
                color: white;
                border: none;
                border-radius: 8px;
                font-size: 1rem;
                font-weight: 600;
                cursor: pointer;
                transition: all 0.3s;
                display: inline-flex;
                align-items: center;
                gap: 10px;
                box-shadow: 0 4px 6px rgba(39, 174, 96, 0.3);
            }

            .btn-pay-all:hover {
                transform: translateY(-2px);
                box-shadow: 0 6px 12px rgba(39, 174, 96, 0.4);
                background: linear-gradient(135deg, #229954 0%, #1e8449 100%);
            }

            .btn-pay-all:active {
                transform: translateY(0);
            }

            .all-paid-badge {
                padding: 12px 30px;
                background: linear-gradient(135deg, #d4edda 0%, #c3e6cb 100%);
                color: #155724;
                border: 2px solid #c3e6cb;
                border-radius: 8px;
                font-size: 1rem;
                font-weight: 600;
                display: inline-flex;
                align-items: center;
                gap: 10px;
            }

            .all-paid-badge i {
                font-size: 1.2rem;
            }

            .payment-actions {
                display: flex;
                gap: 12px;
                align-items: center;
            }

            .btn-reject-quotation {
                padding: 12px 30px;
                background: linear-gradient(135deg, #e74c3c 0%, #c0392b 100%);
                color: white;
                border: none;
                border-radius: 8px;
                font-size: 1rem;
                font-weight: 600;
                cursor: pointer;
                transition: all 0.3s;
                display: inline-flex;
                align-items: center;
                gap: 10px;
                box-shadow: 0 4px 6px rgba(231, 76, 60, 0.3);
            }

            .btn-reject-quotation:hover {
                transform: translateY(-2px);
                box-shadow: 0 6px 12px rgba(231, 76, 60, 0.4);
                background: linear-gradient(135deg, #c0392b 0%, #a93226 100%);
            }

            .btn-reject-quotation:active {
                transform: translateY(0);
            }

            /* SUMMARY */
            .quotation-summary {
                margin-top: 20px;
                padding: 20px;
                background: white;
                border-radius: 8px;
                display: flex;
                justify-content: space-between;
                align-items: center;
            }

            .summary-count {
                display: flex;
                align-items: center;
                gap: 10px;
                color: #2c3e50;
                font-weight: 600;
            }

            .summary-count::before {
                content: '';
                width: 12px;
                height: 12px;
                background: #3498db;
                border-radius: 50%;
            }

            .summary-total {
                color: #e74c3c;
                font-weight: 700;
                font-size: 1.1rem;
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
            .btn-purple {
                background: #8b5cf6;
                color: white;
                border: none;
            }

            .btn-purple:hover {
                background: #7c3aed;
                color: white;
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

            .toast-notification.info {
                border-left: 4px solid #0dcaf0;
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

            .toast-icon.info {
                color: #0dcaf0;
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

            /* CSS cho description display */
            .description-display {
                white-space: pre-wrap !important;
                word-wrap: break-word !important;
                word-break: break-word !important;
                overflow-wrap: anywhere !important;
                max-height: 300px;
                overflow-y: auto;
                overflow-x: hidden;
                line-height: 1.6;
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            }

            .description-display::-webkit-scrollbar {
                width: 8px;
            }

            .description-display::-webkit-scrollbar-thumb {
                background: rgba(0,0,0,0.2);
                border-radius: 4px;
            }

            .description-display::-webkit-scrollbar-thumb:hover {
                background: rgba(0,0,0,0.3);
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

            .footer-version {
                color: rgba(255, 255, 255, 0.6);
                font-size: 0.9rem;
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

            .footer-contact-item {
                display: flex;
                align-items: flex-start;
                gap: 12px;
                margin-bottom: 15px;
                color: rgba(255, 255, 255, 0.8);
                font-size: 0.9rem;
            }

            .footer-contact-item i {
                font-size: 1rem;
                color: #ffc107;
                margin-top: 3px;
            }

            .footer-stats {
                list-style: none;
                padding: 0;
                margin: 0;
            }

            .footer-stats li {
                margin-bottom: 12px;
                display: flex;
                align-items: center;
                gap: 10px;
                color: rgba(255, 255, 255, 0.8);
                font-size: 0.9rem;
            }

            .footer-stats i {
                color: #ffc107;
                font-size: 1rem;
            }

            .footer-certifications {
                display: flex;
                gap: 10px;
                margin-top: 20px;
                flex-wrap: wrap;
            }

            .cert-badge {
                background: rgba(255, 255, 255, 0.1);
                padding: 6px 12px;
                border-radius: 6px;
                display: flex;
                align-items: center;
                gap: 6px;
                font-size: 0.8rem;
                transition: all 0.3s;
            }

            .cert-badge:hover {
                background: rgba(255, 255, 255, 0.2);
                transform: translateY(-2px);
            }

            .cert-badge i {
                color: #ffc107;
            }

            .footer-divider {
                height: 1px;
                background: linear-gradient(to right, transparent, rgba(255,255,255,0.2), transparent);
                margin-bottom: 40px;
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

            .footer-bottom-links {
                display: flex;
                gap: 25px;
            }

            .footer-bottom-links a {
                color: rgba(255, 255, 255, 0.7);
                text-decoration: none;
                font-size: 0.9rem;
                transition: all 0.3s;
            }

            .footer-bottom-links a:hover {
                color: #ffc107;
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

            /* BUTTON STYLES FOR QUOTATION ACTIONS */
            .btn-approve-quotation {
                padding: 12px 30px;
                background: linear-gradient(135deg, #27ae60 0%, #229954 100%);
                color: white;
                border: none;
                border-radius: 8px;
                font-size: 1rem;
                font-weight: 600;
                cursor: pointer;
                transition: all 0.3s;
                display: inline-flex;
                align-items: center;
                gap: 10px;
                box-shadow: 0 4px 6px rgba(39, 174, 96, 0.3);
            }

            .btn-approve-quotation:hover {
                transform: translateY(-2px);
                box-shadow: 0 6px 12px rgba(39, 174, 96, 0.4);
                background: linear-gradient(135deg, #229954 0%, #1e8449 100%);
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

                .footer-bottom-links {
                    flex-direction: column;
                    gap: 10px;
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
                    <i></i>
                    <span>CRM System</span>
                </a>
            </div>

            <div class="sidebar-menu">
                <div class="menu-section">
                    <a href="${pageContext.request.contextPath}/dashbroadCustomer.jsp" class="menu-item">
                        <i class="fas fa-home"></i>
                        <span>Dashboard</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/managerServiceRequest" class="menu-item active">
                        <i class="fas fa-clipboard-list"></i>
                        <span>Yêu Cầu Dịch Vụ</span>
                        <span class="badge bg-warning">${pendingCount}</span>
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
            </div>

            <div class="sidebar-footer">
                <div class="user-info">
                    <div class="user-avatar">
                        <c:choose>
                            <c:when test="${not empty sessionScope.session_login.fullName}">
                                ${sessionScope.session_login.fullName.substring(0,1).toUpperCase()}
                            </c:when>
                            <c:when test="${not empty sessionScope.session_login.username}">
                                ${sessionScope.session_login.username.substring(0,1).toUpperCase()}
                            </c:when>
                            <c:otherwise>
                                U
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="user-details">
                        <div class="user-name">
                            <c:choose>
                                <c:when test="${not empty sessionScope.session_login.fullName}">
                                    ${sessionScope.session_login.fullName}
                                </c:when>
                                <c:when test="${not empty sessionScope.session_login.username}">
                                    ${sessionScope.session_login.username}
                                </c:when>
                                <c:otherwise>
                                    User
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <div class="user-role">
                            <c:choose>
                                <c:when test="${not empty sessionScope.session_role}">
                                    ${sessionScope.session_role}
                                </c:when>
                                <c:otherwise>
                                    Manager
                                </c:otherwise>
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
                <h1 class="page-title"><i class="fas fa-clipboard-list"></i> Yêu Cầu Dịch Vụ</h1>
                <div class="d-flex gap-2">
                    <button class="btn btn-secondary" onclick="refreshPage()">
                        <i class="fas fa-sync"></i> Làm Mới
                    </button>
                    <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#createModal">
                        <i class="fas fa-plus"></i> Tạo Yêu Cầu Mới
                    </button>
                </div>
            </div>

            <div id="toastContainer"></div>

            <div class="content-wrapper">
                <%
                    String errorMsg = (String) session.getAttribute("error");
                    String successMsg = (String) session.getAttribute("success");
                    String infoMsg = (String) session.getAttribute("info");
                %>

                <% if (errorMsg != null || successMsg != null || infoMsg != null) { %>
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

                    <% if (infoMsg != null) { 
                            session.removeAttribute("info");
                    %>
                        setTimeout(function () {
                            showToast('<%= infoMsg.replace("'", "\\'").replace("\"", "\\\"") %>', 'info');
                        }, 100);
                    <% } %>
                    });
                </script>
                <% } %>

                <!-- THỐNG KÊ - 6 Ô THEO DISPLAY STATUS -->
                <div class="row">
                    <div class="col-xl-2 col-lg-4 col-md-6 col-sm-6 mb-3">
                        <div class="stats-card bg-primary text-white">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h6>Tổng Yêu Cầu</h6>
                                    <h2>${totalRequests}</h2>
                                </div>
                                <i class="fas fa-clipboard-list"></i>
                            </div>
                        </div>
                    </div>

                    <div class="col-xl-2 col-lg-4 col-md-6 col-sm-6 mb-3">
                        <div class="stats-card bg-warning text-dark">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h6>Chờ Xác Nhận</h6>
                                    <h2>
                                        <c:set var="countChoXacNhan" value="0" />
                                        <c:forEach var="req" items="${allRequests}">
                                            <c:if test="${req.getDisplayStatus() == 'Chờ Xác Nhận'}">
                                                <c:set var="countChoXacNhan" value="${countChoXacNhan + 1}" />
                                            </c:if>
                                        </c:forEach>
                                        ${countChoXacNhan}
                                    </h2>
                                </div>
                                <i class="fas fa-question-circle"></i>
                            </div>
                        </div>
                    </div>

                    <div class="col-xl-2 col-lg-4 col-md-6 col-sm-6 mb-3">
                        <div class="stats-card" style="background: #ff9800; color: white;">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h6>Chờ Xử Lý</h6>
                                    <h2>
                                        <c:set var="countChoXuLy" value="0" />
                                        <c:forEach var="req" items="${allRequests}">
                                            <c:if test="${req.getDisplayStatus() == 'Chờ Xử Lý'}">
                                                <c:set var="countChoXuLy" value="${countChoXuLy + 1}" />
                                            </c:if>
                                        </c:forEach>
                                        ${countChoXuLy}
                                    </h2>
                                </div>
                                <i class="fas fa-hourglass-half"></i>
                            </div>
                        </div>
                    </div>

                    <div class="col-xl-2 col-lg-4 col-md-6 col-sm-6 mb-3">
                        <div class="stats-card bg-info text-white">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h6>Đang Xử Lý</h6>
                                    <h2>
                                        <c:set var="countDangXuLy" value="0" />
                                        <c:forEach var="req" items="${allRequests}">
                                            <c:if test="${req.getDisplayStatus() == 'Đang Xử Lý'}">
                                                <c:set var="countDangXuLy" value="${countDangXuLy + 1}" />
                                            </c:if>
                                        </c:forEach>
                                        ${countDangXuLy}
                                    </h2>
                                </div>
                                <i class="fas fa-spinner"></i>
                            </div>
                        </div>
                    </div>

                    <div class="col-xl-2 col-lg-4 col-md-6 col-sm-6 mb-3">
                        <div class="stats-card bg-success text-white">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h6>Hoàn Thành</h6>
                                    <h2>
                                        <c:set var="countHoanThanh" value="0" />
                                        <c:forEach var="req" items="${allRequests}">
                                            <c:if test="${req.getDisplayStatus() == 'Hoàn Thành'}">
                                                <c:set var="countHoanThanh" value="${countHoanThanh + 1}" />
                                            </c:if>
                                        </c:forEach>
                                        ${countHoanThanh}
                                    </h2>
                                </div>
                                <i class="fas fa-check-circle"></i>
                            </div>
                        </div>
                    </div>

                    <div class="col-xl-2 col-lg-4 col-md-6 col-sm-6 mb-3">
                        <div class="stats-card bg-danger text-white">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h6>Đã Hủy</h6>
                                    <h2>
                                        <c:set var="countDaHuy" value="0" />
                                        <c:forEach var="req" items="${allRequests}">
                                            <c:if test="${req.getDisplayStatus() == 'Đã Hủy'}">
                                                <c:set var="countDaHuy" value="${countDaHuy + 1}" />
                                            </c:if>
                                        </c:forEach>
                                        ${countDaHuy}
                                    </h2>
                                </div>
                                <i class="fas fa-times-circle"></i>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- SEARCH BAR -->
                <div class="search-filter-bar">
                    <form action="${pageContext.request.contextPath}/managerServiceRequest" method="get">
                        <input type="hidden" name="action" value="search"/>

                        <div class="row g-3 mb-2">
                            <div class="col-md-3">
                                <label class="form-label fw-bold">Tìm kiếm</label>
                                <input type="text" class="form-control" name="keyword"
                                       placeholder="Mô tả, ID yêu cầu, mã hợp đồng..."
                                       value="${param.keyword}">
                            </div>

                            <div class="col-md-2">
                                <label class="form-label fw-bold">Trạng Thái</label>
                                <select name="status" class="form-select">
                                    <option value="">Tất cả</option>
                                    <option value="Pending" ${param.status == 'Pending' ? 'selected' : ''}>Chờ Xác Nhận</option>
                                    <option value="AwaitingApproval" ${param.status == 'AwaitingApproval' ? 'selected' : ''}>Chờ Xử Lý</option>
                                    <option value="Approved" ${param.status == 'Approved' ? 'selected' : ''}>Đang Xử Lý</option>
                                    <option value="Completed" ${param.status == 'Completed' ? 'selected' : ''}>Hoàn Thành</option>
                                    <option value="Cancelled" ${param.status == 'Cancelled' ? 'selected' : ''}>Đã Hủy</option>
                                    <option value="Rejected" ${param.status == 'Rejected' ? 'selected' : ''}>Bị Từ Chối</option>
                                </select>
                            </div>

                            <div class="col-md-3">
                                <label class="form-label fw-bold">Loại Yêu Cầu</label>
                                <select name="requestType" class="form-select">
                                    <option value="">Tất cả</option>
                                    <option value="Service" ${param.requestType == 'Service' ? 'selected' : ''}>Dịch Vụ</option>
                                    <option value="Warranty" ${param.requestType == 'Warranty' ? 'selected' : ''}>Bảo Hành</option>
                                    <option value="InformationUpdate" ${param.requestType == 'InformationUpdate' ? 'selected' : ''}>Cập Nhật Thông Tin</option>
                                </select>
                            </div>

                            <div class="col-md-4">
                                <label class="form-label fw-bold">Sắp xếp</label>
                                <select name="sortBy" class="form-select">
                                    <option value="newest" ${param.sortBy == 'newest' ? 'selected' : ''}>Mới nhất</option>
                                    <option value="oldest" ${param.sortBy == 'oldest' ? 'selected' : ''}>Cũ nhất</option>
                                    <option value="priority_high" ${param.sortBy == 'priority_high' ? 'selected' : ''}>Ưu tiên cao</option>
                                    <option value="priority_low" ${param.sortBy == 'priority_low' ? 'selected' : ''}>Ưu tiên thấp</option>
                                </select>
                            </div>
                        </div>

                        <div class="row g-3 mb-2 align-items-end">
                            <div class="col-md-3">
                                <label class="form-label fw-bold">Từ ngày tạo</label>
                                <input type="date" class="form-control" name="fromDate" value="${param.fromDate}">
                            </div>

                            <div class="col-md-3">
                                <label class="form-label fw-bold">Đến ngày tạo</label>
                                <input type="date" class="form-control" name="toDate" value="${param.toDate}">
                            </div>

                            <div class="col-md-3">
                                <label class="form-label fw-bold">Mức độ ưu tiên</label>
                                <select name="priorityLevel" class="form-select">
                                    <option value="">Tất cả</option>
                                    <option value="Normal" ${param.priorityLevel == 'Normal' ? 'selected' : ''}>Bình Thường</option>
                                    <option value="High" ${param.priorityLevel == 'High' ? 'selected' : ''}>Cao</option>
                                    <option value="Urgent" ${param.priorityLevel == 'Urgent' ? 'selected' : ''}>Khẩn Cấp</option>
                                </select>
                            </div>
                        </div>

                        <div class="row g-3">
                            <div class="col-md-3 d-grid">
                                <button type="submit" class="btn btn-dark">
                                    <i class="fas fa-search me-1"></i> Tìm kiếm
                                </button>
                            </div>
                            <div class="col-md-3 d-grid">
                                <a href="${pageContext.request.contextPath}/managerServiceRequest" class="btn btn-outline-dark">
                                    <i class="fas fa-sync-alt me-1"></i> Làm mới
                                </a>
                            </div>
                        </div>
                    </form>
                </div>

                <!-- ✅ EXPANDABLE TABLE -->
                <div class="table-container">
                    <div class="expandable-table">
                        <!-- Table Header -->
                        <div class="table-header">
                            <div>Hợp Đồng</div>
                            <div>Thiết Bị</div>
                            <div>Mô Tả</div>
                            <div>Ngày Tạo</div>
                            <div>Trạng Thái</div>
                            <div>Thao Tác</div>
                        </div>

                        <!-- Request Rows -->
                        <c:forEach var="req" items="${requests}">
                            <%-- Determine if this request has quotation and should show dropdown --%>
                            <c:set var="displayStatus" value="${req.getDisplayStatus()}" />
                            <%-- 
                                hasQuotation = true nếu:
                                - displayStatus là "Đang Xử Lý" 
                                - status là 'Approved' HOẶC (status là 'Completed' VÀ paymentStatus != 'Completed')
                            --%>
                            <c:set var="hasQuotation" value="${displayStatus == 'Đang Xử Lý'}" />

                            <div class="request-row ${hasQuotation ? 'has-quotation' : ''}" data-request-id="${req.requestId}">
                                <!-- Request Header (clickable only if has quotation) -->
                                <div class="request-header" ${hasQuotation ? 'onclick="toggleRequestDetails(' += req.requestId += ')"' : ''}>
                                    <div class="request-id">
                                        <c:if test="${hasQuotation}">
                                            <svg class="chevron-icon" id="chevron-${req.requestId}" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path>
                                            </svg>
                                        </c:if>
                                        ${req.contractId}
                                    </div>
                                    <div class="request-equipment">
                                        <c:choose>
                                            <c:when test="${not empty req.equipmentName}">
                                                ${req.equipmentName}
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted">-</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                    <div class="request-description">
                                        <c:choose>
                                            <c:when test="${req.description.length() > 60}">
                                                ${req.description.substring(0, 60)}...
                                            </c:when>
                                            <c:otherwise>
                                                ${req.description}
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                    <div class="request-date">
                                        <fmt:formatDate value="${req.requestDate}" pattern="dd/MM/yyyy"/>
                                    </div>
                                    <div>
                                        <c:choose>
                                            <c:when test="${displayStatus == 'Chờ Xác Nhận'}">
                                                <span class="badge badge-pending"><i class="fas fa-question-circle"></i> Chờ Xác Nhận</span>
                                            </c:when>
                                            <c:when test="${displayStatus == 'Chờ Xử Lý'}">
                                                <span class="badge badge-awaiting"><i class="fas fa-hourglass-half"></i> Chờ Xử Lý</span>
                                            </c:when>
                                            <c:when test="${displayStatus == 'Đang Xử Lý'}">
                                                <span class="badge badge-inprogress"><i class="fas fa-spinner"></i> Đang Xử Lý</span>
                                            </c:when>
                                            <c:when test="${displayStatus == 'Hoàn Thành'}">
                                                <span class="badge badge-completed"><i class="fas fa-check-circle"></i> Hoàn Thành</span>
                                            </c:when>
                                            <c:when test="${displayStatus == 'Đã Hủy'}">
                                                <span class="badge badge-cancelled"><i class="fas fa-times-circle"></i> Đã Hủy</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-secondary">${displayStatus}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                    <div>
                                        <button class="btn btn-sm btn-info btn-action" onclick="event.stopPropagation(); viewRequestDetail(${req.requestId}, '${displayStatus}')">
                                            <i class="fas fa-eye"></i> Chi Tiết
                                        </button>
                                    </div>
                                </div>

                                <!-- ✅ Quotation Details (only for requests with quotation) -->
                                <c:if test="${hasQuotation}">
                                    <div class="quotation-details" id="details-${req.requestId}">
                                        <div class="quotation-header-text">
                                            Danh sách báo giá (Repair Reports)
                                        </div>

                                        <!-- This will be populated via AJAX when expanded -->
                                        <div id="quotation-content-${req.requestId}">
                                            <div class="text-center py-4">
                                                <i class="fas fa-spinner fa-spin fa-2x text-primary"></i>
                                                <p class="mt-2 text-muted">Đang tải dữ liệu báo giá...</p>
                                            </div>
                                        </div>
                                    </div>
                                </c:if>
                            </div>
                        </c:forEach>

                        <c:if test="${empty requests}">
                            <div style="padding: 40px; text-align: center; color: #7f8c8d;">
                                <i class="fas fa-inbox fa-3x mb-3"></i>
                                <p>Bạn chưa có yêu cầu dịch vụ nào</p>
                                <button class="btn btn-primary mt-2" data-bs-toggle="modal" data-bs-target="#createModal">
                                    <i class="fas fa-plus"></i> Tạo Yêu Cầu Đầu Tiên
                                </button>
                            </div>
                        </c:if>
                    </div>

                    <!-- PHÂN TRANG -->
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
                                | Hiển thị <strong>${fn:length(requests)}</strong> yêu cầu
                            </small>
                        </div>
                    </c:if>
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
                            <p class="footer-version">
                                <strong>Version:</strong> 1.0.0<br>
                                <strong>Phiên bản:</strong> Enterprise Edition
                            </p>
                        </div>

                        <div class="footer-section">
                            <h5>Tính năng chính</h5>
                            <ul class="footer-links">
                                <li><a href="#">→ Quản lý khách hàng</a></li>
                                <li><a href="#">→ Quản lý hợp đồng</a></li>
                                <li><a href="#">→ Quản lý thiết bị</a></li>
                                <li><a href="#">→ Báo cáo & Phân tích</a></li>
                                <li><a href="#">→ Quản lý yêu cầu dịch vụ</a></li>
                            </ul>
                        </div>

                        <div class="footer-section">
                            <h5>Hỗ trợ & Trợ giúp</h5>
                            <ul class="footer-links">
                                <li><a href="#">→ Trung tâm trợ giúp</a></li>
                                <li><a href="#">→ Hướng dẫn sử dụng</a></li>
                                <li><a href="#">→ Liên hệ hỗ trợ</a></li>
                                <li><a href="#">→ Câu hỏi thường gặp</a></li>
                                <li><a href="#">→ Yêu cầu tính năng</a></li>
                            </ul>
                        </div>

                        <div class="footer-section">
                            <h5>Thông tin công ty</h5>
                            <ul class="footer-links">
                                <li><a href="#">→ Về chúng tôi</a></li>
                                <li><a href="#">→ Điều khoản sử dụng</a></li>
                                <li><a href="#">→ Chính sách bảo mật</a></li>
                                <li><a href="#">→ Bảo mật dữ liệu</a></li>
                                <li><a href="#">→ Liên hệ</a></li>
                            </ul>
                        </div>
                    </div>                                  
                    <div class="footer-bottom">
                        <p class="footer-copyright">
                            &copy; 2025 CRM System. All rights reserved. | Phát triển bởi <strong>Group 6</strong>
                        </p>
                        <div class="footer-bottom-links">
                            <a href="#">Chính sách bảo mật</a>
                            <a href="#">Điều khoản dịch vụ</a>
                            <a href="#">Cài đặt Cookie</a>
                        </div>
                    </div>
                </div>
            </footer>

            <div class="scroll-to-top" id="scrollToTop" onclick="scrollToTop()">
                <i class="fas fa-arrow-up"></i>
            </div>
        </div>

        <!-- ========== MODAL TẠO YÊU CẦU MỚI ========== -->
        <div class="modal fade" id="createModal" tabindex="-1">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <form action="${pageContext.request.contextPath}/managerServiceRequest" method="post" id="createForm" onsubmit="return validateCreateForm(event)">
                        <input type="hidden" name="action" value="CreateServiceRequest">
                        <div class="modal-header bg-primary text-white">
                            <h5 class="modal-title">
                                <i class="fas fa-plus-circle"></i> Tạo Yêu Cầu Hỗ Trợ Mới
                            </h5>
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                        </div>
                        <div class="modal-body">
                            <!-- Loại Hỗ Trợ -->
                            <div class="mb-3">
                                <label class="form-label">
                                    <i class="fas fa-question-circle"></i> Loại Hỗ Trợ 
                                    <span class="text-danger">*</span>
                                </label>
                                <select class="form-select" name="supportType" id="supportType" required onchange="toggleFields()">
                                    <option value="">-- Chọn loại hỗ trợ --</option>
                                    <option value="equipment">🔧 Hỗ Trợ Thiết Bị</option>
                                </select>
                            </div>

                            <!-- ✅ THÊM MỚI: Loại Yêu Cầu (Request Type) -->
                            <div class="mb-3" id="requestTypeField" style="display:none;">
                                <label class="form-label">
                                    <i class="fas fa-tags"></i> Loại Yêu Cầu 
                                    <span class="text-danger">*</span>
                                </label>
                                <select class="form-select" name="requestType" id="requestType">
                                    <option value="Service">🔧 Service (Dịch vụ sửa chữa)</option>
                                    <option value="Warranty">🛡️ Warranty (Bảo hành)</option>
                                </select>
                                <small class="form-text text-muted">
                                    <i class="fas fa-info-circle"></i> Service: Dịch vụ sửa chữa thông thường | Warranty: Sửa chữa theo bảo hành hợp đồng
                                </small>
                            </div>

                            <!-- ✅ DROPDOWN THIẾT BỊ -->
                            <div class="mb-3" id="equipmentSelectField" style="display:none;">
                                <label class="form-label">
                                    <i class="fas fa-tools"></i> Chọn Thiết Bị 
                                    <span class="text-danger">*</span>
                                </label>

                                <!-- Button trigger dropdown -->
                                <button class="btn btn-outline-secondary w-100 text-start d-flex justify-content-between align-items-center" 
                                        type="button" 
                                        id="equipmentDropdownBtn"
                                        onclick="toggleEquipmentDropdown()">
                                    <span id="equipmentDropdownLabel">
                                        <i class="fas fa-list"></i> Chọn thiết bị cần hỗ trợ
                                    </span>
                                    <i class="fas fa-chevron-down" id="equipmentDropdownIcon"></i>
                                </button>

                                <!-- Dropdown menu -->
                                <div class="border rounded mt-2 p-3 bg-light" 
                                     id="equipmentDropdownMenu" 
                                     style="display: none; max-height: 300px; overflow-y: auto;">

                                    <c:choose>
                                        <c:when test="${not empty sessionScope.customerEquipmentList}">
                                            <c:forEach var="equipment" items="${sessionScope.customerEquipmentList}" varStatus="status">
                                                <div class="form-check mb-2">
                                                    <input class="form-check-input equipment-checkbox" 
                                                           type="checkbox" 
                                                           name="equipmentIds" 
                                                           value="${equipment.equipmentId}"
                                                           id="equipment_${status.index}"
                                                           data-model="${equipment.model}"
                                                           data-serial="${equipment.serialNumber}"
                                                           data-contract="${equipment.contractId}"
                                                           onchange="updateSelectedEquipment()">
                                                    <label class="form-check-label w-100" for="equipment_${status.index}">
                                                        <strong><c:out value="${equipment.model}"/></strong><br>
                                                        <small class="text-muted">
                                                            Serial: <c:out value="${equipment.serialNumber}"/> | 
                                                            <c:choose>
                                                                <c:when test="${equipment.contractId != null && equipment.contractId > 0}">
                                                                    Hợp đồng: HD<c:out value="${String.format('%03d', equipment.contractId)}"/>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="text-warning">Không có hợp đồng</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </small>
                                                    </label>
                                                </div>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="text-center text-muted py-3">
                                                <i class="fas fa-inbox fa-2x mb-2"></i>
                                                <p>Bạn chưa có thiết bị nào</p>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>

                                <!-- Hiển thị thiết bị đã chọn -->
                                <div id="selectedEquipmentDisplay" class="mt-2"></div>

                                <small class="form-text text-muted">
                                    <i class="fas fa-info-circle"></i> Bạn có thể chọn nhiều thiết bị cùng lúc
                                </small>
                            </div>

                            <!-- Mức Độ Ưu Tiên -->
                            <div class="mb-3" id="priorityField" style="display:none;">
                                <label class="form-label">
                                    <i class="fas fa-exclamation-circle"></i> Mức Độ Ưu Tiên 
                                    <span class="text-danger">*</span>
                                </label>
                                <select class="form-select" name="priorityLevel" id="priorityLevel">
                                    <option value="Normal">⚪ Bình Thường</option>
                                    <option value="High">🟡 Cao</option>
                                    <option value="Urgent">🔴 Khẩn Cấp</option>
                                </select>
                            </div>

                            <!-- Mô Tả -->
                            <div class="mb-3" id="descriptionField" style="display:none;">
                                <label class="form-label">
                                    <i class="fas fa-comment-dots"></i> Mô Tả Vấn Đề 
                                    <span class="text-danger">*</span>
                                </label>
                                <textarea class="form-control" name="description" id="description" rows="5" 
                                          placeholder="Mô tả chi tiết vấn đề bạn đang gặp phải..."
                                          maxlength="1000"
                                          oninput="updateCharCount()"></textarea>
                                <div class="d-flex justify-content-between align-items-center mt-1">
                                    <small class="form-text text-muted">
                                        <i class="fas fa-info-circle"></i> Tối thiểu 10 ký tự, tối đa 1000 ký tự
                                    </small>
                                    <span id="charCount" class="text-muted" style="font-size: 0.875rem;">0/1000</span>
                                </div>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                                <i class="fas fa-times"></i> Hủy
                            </button>
                            <button type="submit" class="btn btn-primary">
                                <i class="fas fa-paper-plane"></i> Gửi Yêu Cầu
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <!-- MODAL CHI TIẾT: CHỜ XÁC NHẬN -->
        <div class="modal fade" id="viewModalPending" tabindex="-1">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header bg-warning text-dark">
                        <h5 class="modal-title">
                            <i class="fas fa-question-circle"></i> Chi Tiết Yêu Cầu - Chờ Xác Nhận
                        </h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <strong><i class="fas fa-hashtag"></i> Mã Yêu Cầu:</strong>
                                <p class="fw-normal" id="pendingRequestId"></p>
                            </div>
                            <div class="col-md-6">
                                <strong><i class="fas fa-calendar"></i> Ngày Tạo:</strong>
                                <p class="fw-normal" id="pendingRequestDate"></p>
                            </div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <strong><i class="fas fa-file-contract"></i> Mã Hợp Đồng:</strong>
                                <p class="fw-normal" id="pendingContractId"></p>
                            </div>
                            <div class="col-md-6">
                                <strong><i class="fas fa-tools"></i> Thiết Bị:</strong>
                                <p class="fw-normal" id="pendingEquipmentName"></p>
                            </div>
                        </div>
                        <div class="row mb-3">                      
                            <div class="col-md-6">
                                <strong><i class="fas fa-exclamation-circle"></i> Mức Độ Ưu Tiên:</strong>
                                <span class="badge" id="pendingPriority"></span>
                            </div>
                            <div class="col-md-6">
                                <strong><i class="fas fa-tag"></i> Loại Yêu Cầu:</strong>
                                <span class="badge" id="pendingRequestType"></span>
                            </div>
                        </div>
                        <div class="mb-3">
                            <strong><i class="fas fa-comment-dots"></i> Mô Tả Vấn Đề:</strong>
                            <div class="border rounded p-3 bg-light description-display" id="pendingDescription"></div>
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

        <!-- MODAL CHI TIẾT: CHỜ XỬ LÝ -->
        <div class="modal fade" id="viewModalAwaiting" tabindex="-1">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header" style="background: #ff9800; color: white;">
                        <h5 class="modal-title">
                            <i class="fas fa-hourglass-half"></i> Chi Tiết Yêu Cầu - Chờ Xử Lý
                        </h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <strong><i class="fas fa-hashtag"></i> Mã Yêu Cầu:</strong>
                                <p class="fw-normal" id="awaitingRequestId"></p>
                            </div>
                            <div class="col-md-6">
                                <strong><i class="fas fa-calendar"></i> Ngày Tạo:</strong>
                                <p class="fw-normal" id="awaitingRequestDate"></p>
                            </div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <strong><i class="fas fa-file-contract"></i> Mã Hợp Đồng:</strong>
                                <p class="fw-normal" id="awaitingContractId"></p>
                            </div>
                            <div class="col-md-6">
                                <strong><i class="fas fa-tools"></i> Thiết Bị:</strong>
                                <p class="fw-normal" id="awaitingEquipmentName"></p>
                            </div>
                        </div>
                        <div class="row mb-3">                            
                            <div class="col-md-6">
                                <strong><i class="fas fa-exclamation-circle"></i> Mức Độ Ưu Tiên:</strong>
                                <span class="badge" id="awaitingPriority"></span>
                            </div>
                            <div class="col-md-6">
                                <strong><i class="fas fa-user-cog"></i> Người Xử Lý:</strong>
                                <p class="fw-normal text-primary" id="awaitingTechnicianName">
                                    <i class="fas fa-spinner fa-spin"></i> Đang tải...
                                </p>
                            </div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <strong><i class="fas fa-tag"></i> Loại Yêu Cầu:</strong>
                                <span class="badge" id="awaitingRequestType"></span>
                            </div>
                        </div>
                        <div class="mb-3">
                            <strong><i class="fas fa-comment-dots"></i> Mô Tả Vấn Đề:</strong>
                            <div class="border rounded p-3 bg-light description-display" id="awaitingDescription"></div>
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

        <!-- MODAL CHI TIẾT: ĐANG XỬ LÝ -->
        <div class="modal fade" id="viewModalInProgress" tabindex="-1">
            <div class="modal-dialog modal-xl">
                <div class="modal-content">
                    <div class="modal-header bg-info text-white">
                        <h5 class="modal-title">
                            <i class="fas fa-spinner fa-spin"></i> Chi Tiết Yêu Cầu - Đang Xử Lý
                        </h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body" style="background: #f8f9fa;">
                        <!-- ✅ SECTION 1: Thông Tin Yêu Cầu -->
                        <div class="card mb-3 shadow-sm">
                            <div class="card-header bg-white border-bottom">
                                <h6 class="mb-0 text-primary">
                                    <i class="fas fa-info-circle"></i> Thông Tin Yêu Cầu
                                </h6>
                            </div>
                            <div class="card-body">
                                <div class="row g-3 mb-3">
                                    <div class="col-md-3">
                                        <div class="detail-item">
                                            <small class="text-muted d-block mb-1">
                                                <i class="fas fa-hashtag"></i> Mã Yêu Cầu
                                            </small>
                                            <strong class="text-primary" id="inProgressRequestId">-</strong>
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <div class="detail-item">
                                            <small class="text-muted d-block mb-1">
                                                <i class="fas fa-calendar"></i> Ngày Tạo
                                            </small>
                                            <strong id="inProgressRequestDate">-</strong>
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <div class="detail-item">
                                            <small class="text-muted d-block mb-1">
                                                <i class="fas fa-file-contract"></i> Mã Hợp Đồng
                                            </small>
                                            <strong id="inProgressContractId">-</strong>
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <div class="detail-item">
                                            <small class="text-muted d-block mb-1">
                                                <i class="fas fa-exclamation-circle"></i> Mức Độ Ưu Tiên
                                            </small>
                                            <span class="badge" id="inProgressPriority">-</span>
                                        </div>
                                    </div>
                                </div>
                                <div class="row g-3 mb-3">
                                    <div class="col-md-6">
                                        <div class="detail-item">
                                            <small class="text-muted d-block mb-1">
                                                <i class="fas fa-tools"></i> Thiết Bị
                                            </small>
                                            <strong id="inProgressEquipmentName">-</strong>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="detail-item">
                                            <small class="text-muted d-block mb-1">
                                                <i class="fas fa-tag"></i> Loại Yêu Cầu
                                            </small>
                                            <span class="badge" id="inProgressRequestType">-</span>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-12">
                                        <small class="text-muted d-block mb-2">
                                            <i class="fas fa-comment-dots"></i> Mô Tả Vấn Đề
                                        </small>
                                        <div class="border rounded p-3 bg-light description-display" id="inProgressDescription">-</div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- ✅ SECTION 2: Danh Sách Người Sửa Chữa -->
                        <div class="card shadow-sm">
                            <div class="card-header bg-white border-bottom">
                                <h6 class="mb-0 text-success">
                                    <i class="fas fa-users-cog"></i> Danh Sách Người Sửa Chữa
                                </h6>
                            </div>
                            <div class="card-body p-0">
                                <!-- Container for technicians list -->
                                <div id="inProgressTechniciansList">
                                    <div class="text-center py-4">
                                        <i class="fas fa-spinner fa-spin fa-2x text-muted"></i>
                                        <p class="text-muted mt-2">Đang tải thông tin...</p>
                                    </div>
                                </div>
                            </div>
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

        <style>
            /* ✅ STYLES FOR DETAIL MODAL */
            .detail-item {
                padding: 8px 0;
            }

            .detail-item small {
                font-size: 0.8rem;
                font-weight: 600;
            }

            .detail-item strong {
                font-size: 1rem;
                color: #2c3e50;
            }

            /* Technician Card Styles */
            .technician-card {
                border: 1px solid #e0e0e0;
                border-radius: 10px;
                padding: 20px;
                margin-bottom: 15px;
                background: white;
                transition: all 0.3s;
            }

            .technician-card:hover {
                box-shadow: 0 4px 12px rgba(0,0,0,0.1);
                transform: translateY(-2px);
            }

            .technician-card:last-child {
                margin-bottom: 0;
            }

            .technician-header-row {
                display: flex;
                align-items: center;
                gap: 15px;
                margin-bottom: 15px;
                padding-bottom: 15px;
                border-bottom: 2px solid #f0f0f0;
            }

            .technician-avatar {
                width: 60px;
                height: 60px;
                border-radius: 50%;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                display: flex;
                align-items: center;
                justify-content: center;
                color: white;
                font-weight: 700;
                font-size: 1.5rem;
                flex-shrink: 0;
            }

            .technician-info {
                flex: 1;
            }

            .technician-name {
                font-size: 1.1rem;
                font-weight: 700;
                color: #2c3e50;
                margin-bottom: 5px;
            }

            .technician-work-desc {
                color: #7f8c8d;
                font-size: 0.9rem;
                margin-bottom: 5px;
            }

            .technician-meta {
                display: flex;
                gap: 15px;
                flex-wrap: wrap;
            }

            .meta-item {
                display: flex;
                align-items: center;
                gap: 5px;
                font-size: 0.85rem;
                color: #95a5a6;
            }

            .meta-item i {
                color: #3498db;
            }

            .technician-cost-badge {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                padding: 8px 15px;
                border-radius: 20px;
                font-weight: 700;
                font-size: 1rem;
                white-space: nowrap;
            }

            /* Parts List in Technician Card */
            .parts-list-header {
                background: #f8f9fa;
                padding: 12px 15px;
                border-radius: 8px 8px 0 0;
                display: flex;
                align-items: center;
                gap: 10px;
                font-weight: 600;
                color: #2c3e50;
                margin-bottom: 10px;
            }

            .part-item {
                display: grid;
                grid-template-columns: 2fr 1fr 80px 120px 120px;
                gap: 15px;
                padding: 12px 15px;
                border: 1px solid #e0e0e0;
                border-radius: 8px;
                margin-bottom: 10px;
                align-items: center;
                background: white;
                transition: all 0.2s;
            }

            .part-item:hover {
                background: #f8f9fa;
                border-color: #3498db;
            }

            .part-name {
                font-weight: 600;
                color: #2c3e50;
            }

            .part-serial {
                font-family: 'Courier New', monospace;
                color: #7f8c8d;
                font-size: 0.85rem;
            }

            .part-quantity {
                text-align: center;
                font-weight: 600;
            }

            .part-price {
                text-align: right;
                color: #e74c3c;
                font-weight: 600;
            }

            .part-actions {
                display: flex;
                gap: 5px;
                justify-content: flex-end;
            }

            .no-parts-message {
                text-align: center;
                padding: 30px;
                color: #95a5a6;
            }

            .no-parts-message i {
                font-size: 3rem;
                margin-bottom: 10px;
                opacity: 0.5;
            }
        </style>

        <!-- MODAL CHI TIẾT: HOÀN THÀNH -->
        <div class="modal fade" id="viewModalCompleted" tabindex="-1">
            <div class="modal-dialog modal-xl">
                <div class="modal-content">
                    <div class="modal-header bg-success text-white">
                        <h5 class="modal-title">
                            <i class="fas fa-check-circle"></i> Chi Tiết Yêu Cầu - Hoàn Thành
                        </h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body" style="background: #f8f9fa;">
                        <!-- SECTION 1: Thông Tin Yêu Cầu -->
                        <div class="card mb-3 shadow-sm">
                            <div class="card-header bg-white border-bottom">
                                <h6 class="mb-0 text-success">
                                    <i class="fas fa-info-circle"></i> Thông Tin Yêu Cầu
                                </h6>
                            </div>
                            <div class="card-body">
                                <div class="row g-3 mb-3">
                                    <div class="col-md-3">
                                        <div class="detail-item">
                                            <small class="text-muted d-block mb-1">
                                                <i class="fas fa-hashtag"></i> Mã Yêu Cầu
                                            </small>
                                            <strong class="text-success" id="completedRequestId">-</strong>
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <div class="detail-item">
                                            <small class="text-muted d-block mb-1"></small>
                                            <i class="fas fa-calendar"></i> Ngày Tạo
                                            </small>
                                            <strong id="completedRequestDate">-</strong>
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <div class="detail-item">
                                            <small class="text-muted d-block mb-1">
                                                <i class="fas fa-file-contract"></i> Mã Hợp Đồng
                                            </small>
                                            <strong id="completedContractId">-</strong>
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <div class="detail-item">
                                            <small class="text-muted d-block mb-1">
                                                <i class="fas fa-tools"></i> Thiết Bị
                                            </small>
                                            <strong id="completedEquipmentName">-</strong>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-12">
                                        <small class="text-muted d-block mb-2">
                                            <i class="fas fa-comment-dots"></i> Mô Tả Vấn Đề
                                        </small>
                                        <div class="border rounded p-3 bg-light description-display" id="completedDescription">-</div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- SECTION 2: Thông Tin Kỹ Thuật Viên & Báo Giá -->
                        <div class="card shadow-sm">
                            <div class="card-header bg-white border-bottom">
                                <h6 class="mb-0 text-success">
                                    <i class="fas fa-users-cog"></i> Kỹ Thuật Viên & Báo Giá Sửa Chữa
                                </h6>
                            </div>
                            <div class="card-body p-0">
                                <!-- Container for completed technicians list -->
                                <div id="completedTechniciansList">
                                    <div class="text-center py-4">
                                        <i class="fas fa-spinner fa-spin fa-2x text-muted"></i>
                                        <p class="text-muted mt-2">Đang tải thông tin...</p>
                                    </div>
                                </div>
                            </div>
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
                        // ========== TOGGLE REQUEST DETAILS (EXPAND/COLLAPSE) ==========
                        function toggleRequestDetails(requestId) {
                            const details = document.getElementById('details-' + requestId);
                            const chevron = document.getElementById('chevron-' + requestId);
                            const content = document.getElementById('quotation-content-' + requestId);

                            if (details.classList.contains('show')) {
                                details.classList.remove('show');
                                chevron.classList.remove('expanded');
                            } else {
                                details.classList.add('show');
                                chevron.classList.add('expanded');

                                // Load quotation data via AJAX if not already loaded
                                if (content && content.querySelector('.fa-spinner')) {
                                    loadQuotationDetails(requestId);
                                }
                            }
                        }
                        /**
                         * ✅ ĐỒNG Ý BÁO GIÁ CỦA KỸ THUẬT VIÊN CỤ THỂ
                         * Customer đồng ý với báo giá của 1 kỹ thuật viên
                         */
                        function approveQuotation(requestId, reportId, technicianName) {
                            console.log('🟢 approveQuotation called:', {requestId, reportId, technicianName});

                            Swal.fire({
                                title: 'Xác nhận đồng ý?',
                                html: `Bạn có chắc muốn đồng ý báo giá của <strong>${technicianName}</strong>?<br><br>` +
                                        `<small class="text-muted">Báo giá sẽ được đánh dấu là "Đã duyệt".</small>`,
                                icon: 'question',
                                showCancelButton: true,
                                confirmButtonColor: '#28a745',
                                cancelButtonColor: '#6c757d',
                                confirmButtonText: '<i class="fas fa-check-circle"></i> Đồng ý',
                                cancelButtonText: '<i class="fas fa-times"></i> Hủy'
                            }).then((result) => {
                                if (result.isConfirmed) {
                                    // Hiển thị loading
                                    Swal.fire({
                                        title: 'Đang xử lý...',
                                        html: 'Vui lòng đợi trong giây lát',
                                        allowOutsideClick: false,
                                        didOpen: () => {
                                            Swal.showLoading();
                                        }
                                    });

                                    // Gọi AJAX
                                    const formData = new URLSearchParams();
                                    formData.append('action', 'approveQuotation');
                                    formData.append('requestId', requestId);
                                    formData.append('reportId', reportId);

                                    console.log('📤 Sending request:', formData.toString());

                                    fetch('${pageContext.request.contextPath}/managerServiceRequest', {
                                        method: 'POST',
                                        headers: {
                                            'Content-Type': 'application/x-www-form-urlencoded'
                                        },
                                        body: formData.toString()
                                    })
                                            .then(response => {
                                                console.log('📥 Response status:', response.status);
                                                if (!response.ok) {
                                                    throw new Error('Server trả về lỗi: ' + response.status);
                                                }
                                                return response.text();
                                            })
                                            .then(text => {
                                                console.log('📥 Response text:', text);
                                                if (!text || text.trim() === '') {
                                                    throw new Error('Server trả về response rỗng');
                                                }
                                                return JSON.parse(text);
                                            })
                                            .then(data => {
                                                console.log('✅ Parsed data:', data);
                                                Swal.close();

                                                if (data.success) {
                                                    Swal.fire({
                                                        icon: 'success',
                                                        title: 'Thành công!',
                                                        text: data.message || 'Đã đồng ý báo giá thành công!',
                                                        confirmButtonText: 'OK'
                                                    }).then(() => {
                                                        location.reload();
                                                    });
                                                } else {
                                                    Swal.fire({
                                                        icon: 'error',
                                                        title: 'Lỗi!',
                                                        text: data.message || 'Không thể đồng ý báo giá!'
                                                    });
                                                }
                                            })
                                            .catch(error => {
                                                console.error('❌ Error:', error);
                                                Swal.close();
                                                Swal.fire({
                                                    icon: 'error',
                                                    title: 'Lỗi!',
                                                    html: `Có lỗi xảy ra:<br><br>` +
                                                            `<small class="text-danger">${error.message}</small>`
                                                });
                                            });
                                }
                            });
                        }

                        // ========== LOAD QUOTATION DETAILS VIA AJAX ==========
                        function loadQuotationDetails(requestId) {
                            const content = document.getElementById('quotation-content-' + requestId);

                            fetch('${pageContext.request.contextPath}/managerServiceRequest?action=getQuotationDetails&requestId=' + requestId)
                                    .then(response => response.json())
                                    .then(data => {
                                        if (data.success && data.quotations && data.quotations.length > 0) {
                                            const requestType = data.requestType || 'Service';
                                            const isWarranty = requestType === 'Warranty';

                                            console.log('📋 Request Type:', requestType, '| Is Warranty:', isWarranty);

                                            let html = '<div class="quotation-table">';
                                            html += '<div class="quotation-table-header">';
                                            html += '<div>Technician</div>';
                                            html += '<div>Công việc mô tả</div>';
                                            html += '<div>Estimated Cost</div>';
                                            html += '<div>Status</div>';
                                            html += '<div style="text-align: center;">Số linh kiện</div>';
                                            html += '</div>';

                                            let totalCost = 0;
                                            let totalParts = 0;

                                            console.log('📋 Total quotations:', data.quotations.length);

                                            data.quotations.forEach((quotation, index) => {
                                                const cost = (parseFloat(quotation.estimatedCost) || 0) * 26000;
                                                totalCost += cost;
                                                const partsCount = quotation.parts ? quotation.parts.length : 0;
                                                totalParts += partsCount;

                                                console.log(`🔧 Technician ${index + 1}:`, quotation.technicianName, '| Parts:', partsCount);

                                                // ✅ KIỂM TRA TRẠNG THÁI PARTS
                                                let allPartsPaid = true;
                                                let hasUnpaidParts = false;
                                                let isServiceOnlyQuotation = false; // ✅ THÊM FLAG MỚI

                                                if (quotation.parts && quotation.parts.length > 0) {
                                                    // CÓ LINH KIỆN - kiểm tra trạng thái thanh toán
                                                    quotation.parts.forEach(part => {
                                                        if (part.paymentStatus !== 'Completed' && part.paymentStatus !== 'Cancelled') {
                                                            allPartsPaid = false;
                                                            hasUnpaidParts = true;
                                                        }
                                                    });
                                                } else {
                                                    // ✅ KHÔNG CÓ LINH KIỆN - là dịch vụ thuần (vệ sinh, bảo trì...)
                                                    // Coi như cần thanh toán nếu chưa có invoice hoặc invoice chưa completed
                                                    isServiceOnlyQuotation = true;
                                                    allPartsPaid = (quotation.invoiceStatus === 'Completed');
                                                    hasUnpaidParts = (quotation.invoiceStatus !== 'Completed' && quotation.invoiceStatus !== 'Cancelled');
                                                }

                                                html += '<div class="technician-row">';
                                                html += '<div class="technician-header" onclick="toggleTechnician(\'tech-' + requestId + '-' + index + '\')">';
                                                html += '<div class="technician-name">';
                                                html += '<svg class="chevron-icon" id="chevron-tech-' + requestId + '-' + index + '" fill="none" stroke="currentColor" viewBox="0 0 24 24" style="width: 14px; height: 14px;">';
                                                html += '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path>';
                                                html += '</svg>';
                                                html += quotation.technicianName || 'N/A';
                                                html += '</div>';
                                                html += '<div class="technician-work">' + (quotation.workDescription || 'N/A') + '</div>';
                                                html += '<div class="technician-cost">' + cost.toLocaleString('vi-VN') + ' đ</div>';

                                                // ✅ HIỂN THỊ TRẠNG THÁI
                                                html += '<div>';
                                                const qStatus = quotation.quotationStatus || quotation.status;

                                                if (qStatus === 'Rejected' || quotation.invoiceStatus === 'Cancelled') {
                                                    html += '<span class="badge badge-cancelled"><i class="fas fa-times-circle"></i> Từ chối</span>';
                                                } else if (qStatus === 'Approved' || quotation.invoiceStatus === 'Completed' || (allPartsPaid && quotation.parts && quotation.parts.length > 0)) {
                                                    html += '<span class="badge badge-completed"><i class="fas fa-check-circle"></i> ' + (isWarranty ? 'Đã duyệt' : 'Đã thanh toán') + '</span>';
                                                } else if (qStatus === 'Pending') {
                                                    html += '<span class="badge badge-pending"><i class="fas fa-clock"></i> Chờ xác nhận</span>';
                                                } else {
                                                    html += '<span class="badge badge-' + getStatusClass(qStatus) + '">' + getStatusText(qStatus) + '</span>';
                                                }
                                                html += '</div>';

                                                html += '<div style="text-align: center; font-weight: 600;">' + partsCount + ' linh kiện</div>';
                                                html += '</div>';

                                                // ✅ CHI TIẾT LINH KIỆN VÀ THANH TOÁN
                                                    html += '<div class="parts-section" id="parts-tech-' + requestId + '-' + index + '">';

                                                    if (quotation.parts && quotation.parts.length > 0) {
                                                        // ✅ CÓ LINH KIỆN - Hiển thị bảng parts
                                                        html += '<div class="parts-date"><strong>Ngày tạo:</strong> ' + (quotation.repairDate || 'N/A') + '</div>';
                                                        html += '<div class="parts-table">';

                                                        // TABLE HEADER
                                                        if (isWarranty) {
                                                            html += '<div class="parts-table-header" style="grid-template-columns: 2fr 180px 100px;">';
                                                            html += '<div>Tên Linh Kiện</div>';
                                                            html += '<div>Serial Number</div>';
                                                            html += '<div>Số Lượng</div>';
                                                            html += '</div>';
                                                        } else {
                                                            html += '<div class="parts-table-header">';
                                                            html += '<div>Tên Linh Kiện</div>';
                                                            html += '<div>Serial Number</div>';
                                                            html += '<div>Số Lượng</div>';
                                                            html += '<div>Đơn Giá</div>';
                                                            html += '<div>Thành Tiền</div>';
                                                            html += '</div>';
                                                        }

                                                        let partsTotalCost = 0;

                                                        // DANH SÁCH LINH KIỆN
                                                        quotation.parts.forEach((part, partIndex) => {
                                                            const partTotal = (parseFloat(part.unitPrice) || 0) * 26000 * (parseInt(part.quantity) || 0);
                                                            partsTotalCost += partTotal;

                                                            if (isWarranty) {
                                                                html += '<div class="parts-table-row" style="grid-template-columns: 2fr 180px 100px;">';
                                                                html += '<div>' + (part.partName || 'N/A') + '</div>';
                                                                html += '<div class="parts-serial">' + (part.serialNumber || 'N/A') + '</div>';
                                                                html += '<div class="parts-quantity">' + (part.quantity || 0) + '</div>';
                                                                html += '</div>';
                                                            } else {
                                                                html += '<div class="parts-table-row">';
                                                                html += '<div>' + (part.partName || 'N/A') + '</div>';
                                                                html += '<div class="parts-serial">' + (part.serialNumber || 'N/A') + '</div>';
                                                                html += '<div class="parts-quantity">' + (part.quantity || 0) + '</div>';
                                                                html += '<div class="parts-price">' + ((parseFloat(part.unitPrice) || 0) * 26000).toLocaleString('vi-VN') + ' đ</div>';
                                                                html += '<div class="parts-total">' + partTotal.toLocaleString('vi-VN') + ' đ</div>';
                                                                html += '</div>';
                                                            }
                                                        });

                                                        // FOOTER - Chỉ cho Service
                                                        if (!isWarranty) {
                                                            html += '<div class="parts-table-footer">';
                                                            html += '<div class="total-label">Tổng cộng:</div>';
                                                            html += '<div class="total-value">' + partsTotalCost.toLocaleString('vi-VN') + ' đ</div>';
                                                            html += '</div>';
                                                        }
                                                        html += '</div>'; // Close parts-table

                                                    } else {
                                                        // ✅ KHÔNG CÓ LINH KIỆN - Service only (vệ sinh, bảo trì...)
                                                        html += '<div class="alert alert-info" style="margin: 20px;">';
                                                        html += '<i class="fas fa-info-circle"></i> ';
                                                        html += '<strong>Dịch vụ không yêu cầu thay thế linh kiện</strong><br>';
                                                        html += '<small class="text-muted">Đây là dịch vụ vệ sinh, bảo trì hoặc kiểm tra không cần thay thế phụ tùng.</small>';
                                                        html += '</div>';
                                                    }

                                                    // ✅ ========== ACTION BUTTONS - DI CHUYỂN RA NGOÀI ========== 
                                                    
                                                    const isRejected = qStatus === 'Rejected' || quotation.invoiceStatus === 'Cancelled';
                                                    const isCompleted = quotation.invoiceStatus === 'Completed' || allPartsPaid;
                                                    const isApproved = qStatus === 'Approved';
                                                    const isPending = qStatus === 'Pending';

                                                    console.log('🔍 Payment Button Check:', {
                                                        requestId,
                                                        reportId: quotation.reportId,
                                                        techName: quotation.technicianName,
                                                        qStatus,
                                                        isWarranty,
                                                        hasUnpaidParts,
                                                        isServiceOnlyQuotation,
                                                        isRejected,
                                                        isCompleted,
                                                        isPending,
                                                        isApproved
                                                    });

                                                    // CHỈ HIỂN THỊ NÚT KHI: Chưa reject, chưa completed
                                                    if (!isRejected && !isCompleted) {
                                                        html += '<div class="technician-payment-section">';
                                                        html += '<div class="payment-summary">';

                                                        if (isWarranty) {
                                                            // WARRANTY: Hiển thị số lượng linh kiện
                                                            const partsCount = quotation.parts ? quotation.parts.length : 0;
                                                            html += '<div class="payment-summary-text">Tổng số linh kiện cần thay thế</div>';
                                                            html += '<div class="payment-total-amount">' + partsCount + ' linh kiện</div>';
                                                        } else {
                                                            // SERVICE: Hiển thị tổng tiền
                                                            html += '<div class="payment-summary-text">' + 
                                                                    (isServiceOnlyQuotation ? 'Tổng chi phí dịch vụ' : 'Tổng chi phí linh kiện của kỹ thuật viên') + 
                                                                    '</div>';
                                                            html += '<div class="payment-total-amount">' + cost.toLocaleString('vi-VN') + ' đ</div>';
                                                        }

                                                        html += '</div>';
                                                        html += '<div class="payment-actions">';

                                                        // ========== LOGIC NÚT THEO TRẠNG THÁI ==========
                                                        if (isWarranty) {
                                                            // WARRANTY - CHỈ HIỂN THỊ NÚT Ở TRẠNG THÁI PENDING
                                                            if (isPending) {
                                                                html += '<button class="btn-approve-quotation" onclick="event.stopPropagation(); approveQuotation(' + requestId + ', ' + quotation.reportId + ', \'' + (quotation.technicianName || 'Kỹ thuật viên') + '\')">';
                                                                html += '<i class="fas fa-check-circle"></i> Đồng ý báo giá';
                                                                html += '</button>';

                                                                html += '<button class="btn-reject-quotation" onclick="event.stopPropagation(); rejectQuotation(' + requestId + ', ' + quotation.reportId + ', \'' + (quotation.technicianName || 'Kỹ thuật viên') + '\')">';
                                                                html += '<i class="fas fa-times-circle"></i> Từ chối báo giá';
                                                                html += '</button>';
                                                            }
                                                        } else {
                                                            // ✅ SERVICE - HIỂN THỊ NÚT CHO CẢ PARTS VÀ SERVICE-ONLY
                                                            // Điều kiện: isPending VÀ (có parts chưa thanh toán HOẶC là service-only chưa completed)
                                                            if (isPending && (hasUnpaidParts || isServiceOnlyQuotation)) {
                                                                html += '<button class="btn-pay-all" onclick="event.stopPropagation(); payForTechnician(' + requestId + ', ' + quotation.reportId + ', \'' + (quotation.technicianName || 'Kỹ thuật viên') + '\')">';
                                                                html += '<i class="fas fa-credit-card"></i> Thanh toán';
                                                                html += '</button>';

                                                                html += '<button class="btn-reject-quotation" onclick="event.stopPropagation(); rejectQuotation(' + requestId + ', ' + quotation.reportId + ', \'' + (quotation.technicianName || 'Kỹ thuật viên') + '\')">';
                                                                html += '<i class="fas fa-times-circle"></i> Từ chối báo giá';
                                                                html += '</button>';
                                                            }
                                                        }

                                                        html += '</div>'; // Close payment-actions
                                                        html += '</div>'; // Close technician-payment-section

                                                    } else if (isCompleted) {
                                                        // ✅ HIỂN THỊ BADGE "HOÀN THÀNH"
                                                        html += '<div class="alert alert-success" style="margin: 15px; text-align: center;">';
                                                        html += '<i class="fas fa-check-circle"></i> ';
                                                        html += isWarranty ? 'Đã hoàn tất thay thế linh kiện' : 'Đã thanh toán đầy đủ';
                                                        html += '</div>';
                                                    } else if (isRejected) {
                                                        // ✅ HIỂN THỊ BADGE "ĐÃ TỪ CHỐI"
                                                        html += '<div class="alert alert-danger" style="margin: 15px; text-align: center;">';
                                                        html += '<i class="fas fa-times-circle"></i> Báo giá đã bị từ chối';
                                                        html += '</div>';
                                                    }

                                                    html += '</div>'; // Close parts-section
                                                    html += '</div>'; // Close technician-row
                                            });

                                            html += '</div>'; // Close quotation-table

                                            // SUMMARY
                                            html += '<div class="quotation-summary">';
                                            html += '<div class="summary-count">Tổng số kỹ thuật viên: ' + data.quotations.length + ' | Tổng số linh kiện: ' + totalParts + '</div>';
                                            if (!isWarranty) {
                                                html += '<div class="summary-total">Tổng chi phí ước tính: ' + totalCost.toLocaleString('vi-VN') + ' đ</div>';
                                            }
                                            html += '</div>';

                                            content.innerHTML = html;
                                        } else {
                                            content.innerHTML = '<div class="alert alert-info" style="margin: 20px;"><i class="fas fa-info-circle"></i> ' + (data.message || 'Chưa có báo giá nào') + '</div>';
                                        }
                                    })
                                    .catch(error => {
                                        console.error('Error loading quotation:', error);
                                        content.innerHTML = '<div class="alert alert-danger" style="margin: 20px;"><i class="fas fa-exclamation-triangle"></i> Không thể tải dữ liệu báo giá</div>';
                                    });
                        }

                        // ✅ HÀM MỚI: ĐỒNG Ý THAY THẾ TẤT CẢ LINH KIỆN BẢO HÀNH
                        function approveWarrantyForTechnician(requestId, reportId, technicianName) {
                            Swal.fire({
                                title: 'Xác nhận đồng ý?',
                                html: '<p>Bạn có chắc chắn muốn đồng ý thay thế <strong>tất cả linh kiện</strong> của kỹ thuật viên:<br><strong>' + technicianName + '</strong>?</p>' +
                                        '<small class="text-muted">Đây là dịch vụ bảo hành, không cần thanh toán.</small>',
                                icon: 'question',
                                showCancelButton: true,
                                confirmButtonText: '<i class="fas fa-check-circle"></i> Xác nhận đồng ý',
                                cancelButtonText: '<i class="fas fa-times"></i> Hủy',
                                confirmButtonColor: '#27ae60',
                                cancelButtonColor: '#95a5a6',
                                reverseButtons: true
                            }).then((result) => {
                                if (result.isConfirmed) {
                                    // Hiển thị loading
                                    Swal.fire({
                                        title: 'Đang xử lý...',
                                        html: 'Vui lòng đợi trong giây lát',
                                        allowOutsideClick: false,
                                        didOpen: () => {
                                            Swal.showLoading();
                                        }
                                    });

                                    // TODO: Gọi API để approve tất cả parts của technician này
                                    // Tạm thời redirect đến trang xử lý
                                    const url = '${pageContext.request.contextPath}/managerServiceRequest?action=approveAllWarrantyParts&requestId=' + requestId + '&reportId=' + reportId;

                                    fetch(url, {
                                        method: 'POST'
                                    })
                                            .then(response => response.json())
                                            .then(data => {
                                                Swal.close();
                                                if (data.success) {
                                                    Swal.fire({
                                                        icon: 'success',
                                                        title: 'Thành công!',
                                                        text: data.message || 'Đã đồng ý thay thế linh kiện!',
                                                        confirmButtonText: 'OK'
                                                    }).then(() => {
                                                        location.reload();
                                                    });
                                                } else {
                                                    Swal.fire({
                                                        icon: 'error',
                                                        title: 'Lỗi!',
                                                        text: data.message || 'Không thể xử lý yêu cầu!'
                                                    });
                                                }
                                            })
                                            .catch(error => {
                                                Swal.close();
                                                Swal.fire({
                                                    icon: 'error',
                                                    title: 'Lỗi!',
                                                    text: 'Có lỗi xảy ra: ' + error.message
                                                });
                                            });
                                }
                            });
                        }

                        // ========== TOGGLE TECHNICIAN PARTS ==========
                        function toggleTechnician(id) {
                            const parts = document.getElementById('parts-' + id);
                            const chevron = document.getElementById('chevron-' + id);

                            // ✅ THÊM NULL CHECK
                            if (!parts || !chevron) {
                                console.warn('Elements not found for id:', id);
                                return;
                            }

                            if (parts.classList.contains('show')) {
                                parts.classList.remove('show');
                                chevron.style.transform = 'rotate(0deg)';
                            } else {
                                parts.classList.add('show');
                                chevron.style.transform = 'rotate(90deg)';
                            }
                        }

                        // ========== HELPER FUNCTIONS ==========
                        function getStatusClass(status) {
                            const statusMap = {
                                'Pending': 'pending',
                                'AwaitingApproval': 'awaiting',
                                'Approved': 'inprogress',
                                'Completed': 'completed',
                                'Cancelled': 'cancelled',
                                'Rejected': 'cancelled'
                            };
                            return statusMap[status] || 'secondary';
                        }

                        function getStatusText(status) {
                            const textMap = {
                                'Pending': 'Chờ xác nhận',
                                'AwaitingApproval': 'Chờ xử lý',
                                'Approved': 'Đang xử lý',
                                'Completed': 'Hoàn thành',
                                'Cancelled': 'Đã hủy',
                                'Rejected': 'Từ chối'
                            };
                            return textMap[status] || status;
                        }

                        // ========== PAYMENT & CANCEL FUNCTIONS FOR INDIVIDUAL PARTS ==========

                        /**
                         * ✅ Thanh toán cho 1 linh kiện cụ thể - Chuyển sang trang thanh toán
                         * @param requestId - ID của service request
                         * @param reportId - ID của repair report (technician's quotation)
                         * @param partDetailId - ID của part detail (linh kiện cụ thể)
                         * @param partName - Tên linh kiện (để hiển thị)
                         */
                        function payForPart(requestId, reportId, partDetailId, partName) {
                            // Chuyển sang trang thanh toán với thông tin linh kiện
                            const url = '${pageContext.request.contextPath}/payment?requestId=' + requestId +
                                    '&reportId=' + reportId +
                                    '&partDetailId=' + partDetailId +
                                    '&partName=' + encodeURIComponent(partName);

                            window.location.href = url;
                        }

                        /**
                         * ✅ Hủy 1 linh kiện cụ thể - CHỈ HỦY LINH KIỆN ĐÓ
                         * @param requestId - ID của service request
                         * @param reportId - ID của repair report
                         * @param partDetailId - ID của part detail
                         * @param partName - Tên linh kiện
                         */
                        function cancelPart(requestId, reportId, partDetailId, partName) {
                            Swal.fire({
                                title: 'Xác nhận hủy linh kiện',
                                html: '<p>Bạn có chắc chắn muốn hủy linh kiện:<br><strong>' + partName + '</strong>?</p>',
                                icon: 'warning',
                                showCancelButton: true,
                                confirmButtonText: '<i class="fas fa-trash"></i> Xác nhận hủy',
                                cancelButtonText: '<i class="fas fa-times"></i> Giữ lại',
                                confirmButtonColor: '#e74c3c',
                                cancelButtonColor: '#95a5a6',
                                reverseButtons: true
                            }).then((result) => {
                                if (result.isConfirmed) {
                                    // Hiển thị loading
                                    Swal.fire({
                                        title: 'Đang xử lý...',
                                        text: 'Vui lòng đợi',
                                        allowOutsideClick: false,
                                        didOpen: () => {
                                            Swal.showLoading();
                                        }
                                    });

                                    // Gửi request hủy linh kiện
                                    const formData = new FormData();
                                    formData.append('action', 'cancelPart');
                                    formData.append('requestId', requestId);
                                    formData.append('reportId', reportId);
                                    formData.append('partDetailId', partDetailId);

                                    fetch('${pageContext.request.contextPath}/managerServiceRequest', {
                                        method: 'POST',
                                        body: formData
                                    })
                                            .then(response => {
                                                console.log('Response status:', response.status);
                                                console.log('Response headers:', response.headers);
                                                return response.text(); // Đọc text trước để debug
                                            })
                                            .then(text => {
                                                console.log('Response text:', text);
                                                try {
                                                    return JSON.parse(text);
                                                } catch (e) {
                                                    console.error('JSON parse error:', e);
                                                    console.error('Response was:', text);
                                                    throw new Error('Invalid JSON response: ' + text.substring(0, 100));
                                                }
                                            })
                                            .then(data => {
                                                Swal.close();

                                                if (data.success) {
                                                    Swal.fire({
                                                        icon: 'success',
                                                        title: 'Đã hủy linh kiện!',
                                                        text: data.message || 'Linh kiện đã được hủy thành công',
                                                        timer: 2000,
                                                        showConfirmButton: false
                                                    }).then(() => {
                                                        // Reload dropdown để cập nhật trạng thái
                                                        loadQuotationDetails(requestId);
                                                    });
                                                } else {
                                                    Swal.fire({
                                                        icon: 'error',
                                                        title: 'Lỗi!',
                                                        text: data.message || 'Không thể hủy linh kiện'
                                                    });
                                                }
                                            })
                                            .catch(error => {
                                                Swal.close();
                                                console.error('Error:', error);
                                                Swal.fire({
                                                    icon: 'error',
                                                    title: 'Lỗi!',
                                                    text: 'Có lỗi xảy ra khi hủy: ' + error.message
                                                });
                                            });
                                }
                            });
                        }

                        /**
                         * ✅ THANH TOÁN TỔNG CHO KỸ THUẬT VIÊN
                         * Thanh toán tất cả linh kiện của 1 kỹ thuật viên
                         * @param requestId - ID của service request
                         * @param reportId - ID của repair report (technician's quotation)
                         * @param technicianName - Tên kỹ thuật viên
                         */
                        function payForTechnician(requestId, reportId, technicianName) {
    Swal.fire({
        title: 'Xác nhận thanh toán',
        html: '<p>Bạn có chắc chắn muốn thanh toán <strong>tất cả linh kiện</strong> của kỹ thuật viên:<br><strong>' + technicianName + '</strong>?</p>',
        icon: 'question',
        showCancelButton: true,
        confirmButtonText: '<i class="fas fa-credit-card"></i> Xác nhận thanh toán',
        cancelButtonText: '<i class="fas fa-times"></i> Hủy',
        confirmButtonColor: '#27ae60',
        cancelButtonColor: '#95a5a6',
        reverseButtons: true
    }).then((result) => {
        if (result.isConfirmed) {
            // ✅ GỌI SERVLET ĐỂ CẬP NHẬT quotationStatus TRƯỚC
            fetch('${pageContext.request.contextPath}/managerServiceRequest', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: 'action=payForTechnician&requestId=' + requestId + '&reportId=' + reportId
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    // ✅ SAU ĐÓ MỚI CHUYỂN SANG TRANG THANH TOÁN
                    window.location.href = '${pageContext.request.contextPath}/payment?requestId=' + requestId + '&reportId=' + reportId;
                } else {
                    Swal.fire({
                        icon: 'error',
                        title: 'Lỗi!',
                        text: data.message || 'Không thể xử lý yêu cầu!'
                    });
                }
            })
            .catch(error => {
                Swal.fire({
                    icon: 'error',
                    title: 'Lỗi!',
                    text: 'Có lỗi xảy ra: ' + error.message
                });
            });
        }
    });
}



                        // ========== OLD PAYMENT FUNCTIONS (Keep for backward compatibility) ==========
                        function makePayment(requestId, reportId) {
                            Swal.fire({
                                title: 'Xác nhận thanh toán',
                                text: 'Bạn có chắc chắn muốn thanh toán báo giá này?',
                                icon: 'question',
                                showCancelButton: true,
                                confirmButtonText: 'Xác nhận',
                                cancelButtonText: 'Hủy',
                                confirmButtonColor: '#27ae60',
                                cancelButtonColor: '#95a5a6'
                            }).then((result) => {
                                if (result.isConfirmed) {
                                    window.location.href = '${pageContext.request.contextPath}/managerServiceRequest?action=makePayment&requestId=' + requestId + '&reportId=' + reportId;
                                }
                            });
                        }

                        function cancelQuotation(requestId, reportId) {
                            Swal.fire({
                                title: 'Xác nhận hủy',
                                text: 'Bạn có chắc chắn muốn hủy báo giá này?',
                                icon: 'warning',
                                showCancelButton: true,
                                confirmButtonText: 'Xác nhận hủy',
                                cancelButtonText: 'Giữ lại',
                                confirmButtonColor: '#e74c3c',
                                cancelButtonColor: '#95a5a6'
                            }).then((result) => {
                                if (result.isConfirmed) {
                                    Swal.fire({
                                        icon: 'info',
                                        title: 'Đã hủy!',
                                        text: 'Báo giá đã được hủy',
                                        timer: 2000,
                                        showConfirmButton: false
                                    });
                                }
                            });
                        }

                        /**
                         * ✅ TỪ CHỐI BÁO GIÁ CỦA KỸ THUẬT VIÊN
                         * @param requestId - ID của service request
                         * @param reportId - ID của repair report
                         * @param technicianName - Tên kỹ thuật viên
                         */
                        function rejectQuotation(requestId, reportId, technicianName) {
                            Swal.fire({
                                title: 'Xác nhận từ chối?',
                                html: `Bạn có chắc muốn từ chối báo giá của <strong>${technicianName}</strong>?<br><br>` +
                                        `<small class="text-muted">Báo giá sẽ bị đánh dấu là "Đã từ chối".</small>`,
                                icon: 'warning',
                                showCancelButton: true,
                                confirmButtonColor: '#e74c3c',
                                cancelButtonColor: '#6c757d',
                                confirmButtonText: '<i class="fas fa-times-circle"></i> Từ chối',
                                cancelButtonText: '<i class="fas fa-arrow-left"></i> Quay lại'
                            }).then((result) => {
                                if (result.isConfirmed) {
                                    // Hiển thị loading
                                    Swal.fire({
                                        title: 'Đang xử lý...',
                                        html: 'Vui lòng đợi trong giây lát',
                                        allowOutsideClick: false,
                                        didOpen: () => {
                                            Swal.showLoading();
                                        }
                                    });

                                    // Gọi AJAX
                                    const formData = new URLSearchParams();
                                    formData.append('action', 'rejectQuotation');
                                    formData.append('requestId', requestId);
                                    formData.append('reportId', reportId);

                                    fetch('${pageContext.request.contextPath}/managerServiceRequest', {
                                        method: 'POST',
                                        headers: {
                                            'Content-Type': 'application/x-www-form-urlencoded'
                                        },
                                        body: formData.toString()
                                    })
                                            .then(response => response.json())
                                            .then(data => {
                                                Swal.close();

                                                if (data.success) {
                                                    Swal.fire({
                                                        icon: 'success',
                                                        title: 'Đã từ chối!',
                                                        text: data.message || 'Báo giá đã được từ chối thành công!',
                                                        confirmButtonText: 'OK'
                                                    }).then(() => {
                                                        location.reload();
                                                    });
                                                } else {
                                                    Swal.fire({
                                                        icon: 'error',
                                                        title: 'Lỗi!',
                                                        text: data.message || 'Không thể từ chối báo giá!'
                                                    });
                                                }
                                            })
                                            .catch(error => {
                                                Swal.close();
                                                Swal.fire({
                                                    icon: 'error',
                                                    title: 'Lỗi!',
                                                    text: 'Có lỗi xảy ra: ' + error.message
                                                });
                                            });
                                }
                            });
                        }

                        // ========== OTHER UTILITY FUNCTIONS FROM ORIGINAL CODE ==========
                        function refreshPage() {
                            window.location.href = "${pageContext.request.contextPath}/managerServiceRequest";
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

                        function scrollToTop() {
                            window.scrollTo({
                                top: 0,
                                behavior: 'smooth'
                            });
                        }

                        function goToPage(pageNumber) {
                            const urlParams = new URLSearchParams(window.location.search);
                            urlParams.set('page', pageNumber);
                            if (!urlParams.has('action')) {
                                urlParams.set('action', 'search');
                            }
                            window.location.href = '${pageContext.request.contextPath}/managerServiceRequest?' + urlParams.toString();
                        }

                        // View request detail function (from original)
                        function viewRequestDetail(requestId, displayStatus) {
                            console.log('🔍 Opening detail modal for request:', requestId, 'Status:', displayStatus);

                            // Hiển thị loading
                            Swal.fire({
                                title: 'Đang tải...',
                                html: 'Vui lòng đợi trong giây lát',
                                allowOutsideClick: false,
                                didOpen: () => {
                                    Swal.showLoading();
                                }
                            });

                            // Gọi AJAX để lấy dữ liệu
                            fetch('${pageContext.request.contextPath}/managerServiceRequest?action=viewDetail&requestId=' + requestId)
                                    .then(response => response.json())
                                    .then(data => {
                                        Swal.close(); // Đóng loading

                                        if (!data.success) {
                                            Swal.fire({
                                                icon: 'error',
                                                title: 'Lỗi!',
                                                text: data.message || 'Không thể tải thông tin yêu cầu'
                                            });
                                            return;
                                        }

                                        console.log('✅ Received data:', data);

                                        // Hiển thị modal tùy theo trạng thái
                                        if (displayStatus === 'Chờ Xác Nhận') {
                                            showPendingModal(data);
                                        } else if (displayStatus === 'Chờ Xử Lý') {
                                            showAwaitingModal(data);
                                        } else if (displayStatus === 'Đang Xử Lý') {
                                            showInProgressModal(data);
                                        } else if (displayStatus === 'Hoàn Thành') {
                                            showCompletedModal(data);
                                        } else {
                                            // Fallback: dùng modal Pending
                                            showPendingModal(data);
                                        }
                                    })
                                    .catch(error => {
                                        Swal.close();
                                        console.error('❌ Error:', error);
                                        Swal.fire({
                                            icon: 'error',
                                            title: 'Lỗi!',
                                            text: 'Có lỗi xảy ra khi tải dữ liệu: ' + error.message
                                        });
                                    });
                        }

                        // ========== MODAL 1: CHỜ XÁC NHẬN ==========
                        function showPendingModal(data) {
                            document.getElementById('pendingRequestId').textContent = '#' + data.requestId;
                            document.getElementById('pendingRequestDate').textContent = data.requestDate;
                            document.getElementById('pendingContractId').textContent = data.contractId || 'N/A';
                            document.getElementById('pendingEquipmentName').textContent = data.equipmentName || 'N/A';
                            document.getElementById('pendingDescription').textContent = data.description;

                            // Priority badge
                            const priorityBadge = document.getElementById('pendingPriority');
                            const priorityMap = {
                                'Normal': {className: 'bg-secondary', text: 'Bình Thường'},
                                'High': {className: 'bg-warning text-dark', text: 'Cao'},
                                'Urgent': {className: 'bg-danger', text: 'Khẩn Cấp'}
                            };
                            const priority = priorityMap[data.priorityLevel] || {className: 'bg-dark', text: data.priorityLevel};
                            priorityBadge.className = 'badge ' + priority.className;
                            priorityBadge.textContent = priority.text;

                            // Request Type badge
                            const typeBadge = document.getElementById('pendingRequestType');
                            if (data.requestType === 'Service' || data.requestType === 'Warranty') {
                                typeBadge.className = 'badge bg-primary';
                                typeBadge.textContent = '🔧 Hỗ Trợ Thiết Bị';
                            } else if (data.requestType === 'InformationUpdate') {
                                typeBadge.className = 'badge bg-info';
                                typeBadge.textContent = '👤 Hỗ Trợ Tài Khoản';
                            } else {
                                typeBadge.className = 'badge bg-secondary';
                                typeBadge.textContent = data.requestType || 'N/A';
                            }

                            // Mở modal
                            new bootstrap.Modal(document.getElementById('viewModalPending')).show();
                        }

                        // ========== MODAL 2: CHỜ XỬ LÝ ==========
                        function showAwaitingModal(data) {
                            document.getElementById('awaitingRequestId').textContent = '#' + data.requestId;
                            document.getElementById('awaitingRequestDate').textContent = data.requestDate;
                            document.getElementById('awaitingContractId').textContent = data.contractId || 'N/A';
                            document.getElementById('awaitingEquipmentName').textContent = data.equipmentName || 'N/A';
                            document.getElementById('awaitingDescription').textContent = data.description;

                            // Priority badge
                            const priorityBadge = document.getElementById('awaitingPriority');
                            const priorityMap = {
                                'Normal': {className: 'bg-secondary', text: 'Bình Thường'},
                                'High': {className: 'bg-warning text-dark', text: 'Cao'},
                                'Urgent': {className: 'bg-danger', text: 'Khẩn Cấp'}
                            };
                            const priority = priorityMap[data.priorityLevel] || {className: 'bg-dark', text: data.priorityLevel};
                            priorityBadge.className = 'badge ' + priority.className;
                            priorityBadge.textContent = priority.text;

                            // Request Type badge
                            const typeBadge = document.getElementById('awaitingRequestType');
                            if (data.requestType === 'Service' || data.requestType === 'Warranty') {
                                typeBadge.className = 'badge bg-primary';
                                typeBadge.textContent = '🔧 Hỗ Trợ Thiết Bị';
                            } else if (data.requestType === 'InformationUpdate') {
                                typeBadge.className = 'badge bg-info';
                                typeBadge.textContent = '👤 Hỗ Trợ Tài Khoản';
                            } else {
                                typeBadge.className = 'badge bg-secondary';
                                typeBadge.textContent = data.requestType || 'N/A';
                            }

                            // Tên người xử lý
                            const technicianNameEl = document.getElementById('awaitingTechnicianName');
                            if (data.assignedTechnicianName) {
                                technicianNameEl.innerHTML = '<i class="fas fa-user-check"></i> ' + data.assignedTechnicianName;
                                technicianNameEl.className = 'fw-normal text-primary';
                            } else {
                                technicianNameEl.innerHTML = '<i class="fas fa-question-circle"></i> Chưa phân công';
                                technicianNameEl.className = 'fw-normal text-muted';
                            }

                            // Mở modal
                            new bootstrap.Modal(document.getElementById('viewModalAwaiting')).show();
                        }

                        // ========== MODAL 3: ĐANG XỬ LÝ ==========
                        function showInProgressModal(data) {
                            console.log('📋 Showing In Progress Modal with full details');
                            console.log('📦 Data:', data);

                            // Thông tin yêu cầu cơ bản
                            document.getElementById('inProgressRequestId').textContent = '#' + data.requestId;
                            document.getElementById('inProgressRequestDate').textContent = data.requestDate;
                            document.getElementById('inProgressContractId').textContent = data.contractId || 'N/A';
                            document.getElementById('inProgressEquipmentName').textContent = data.equipmentName || 'N/A';
                            document.getElementById('inProgressDescription').textContent = data.description;

                            // Priority badge
                            const priorityBadge = document.getElementById('inProgressPriority');
                            const priorityMap = {
                                'Normal': {className: 'bg-secondary', text: 'Bình Thường'},
                                'High': {className: 'bg-warning text-dark', text: 'Cao'},
                                'Urgent': {className: 'bg-danger', text: 'Khẩn Cấp'}
                            };
                            const priority = priorityMap[data.priorityLevel] || {className: 'bg-dark', text: data.priorityLevel};
                            priorityBadge.className = 'badge ' + priority.className;
                            priorityBadge.textContent = priority.text;

                            // Request Type badge
                            const typeBadge = document.getElementById('inProgressRequestType');
                            if (data.requestType === 'Service' || data.requestType === 'Warranty') {
                                typeBadge.className = 'badge bg-primary';
                                typeBadge.textContent = '🔧 Hỗ Trợ Thiết Bị';
                            } else if (data.requestType === 'InformationUpdate') {
                                typeBadge.className = 'badge bg-info';
                                typeBadge.textContent = '👤 Hỗ Trợ Tài Khoản';
                            } else {
                                typeBadge.className = 'badge bg-secondary';
                                typeBadge.textContent = data.requestType || 'N/A';
                            }

                            // Load danh sách technicians và parts
                            loadTechniciansForModal(data.requestId);

                            // Mở modal
                            new bootstrap.Modal(document.getElementById('viewModalInProgress')).show();
                        }

                        // ✅ Load danh sách technicians với parts cho modal chi tiết
                        function loadTechniciansForModal(requestId) {
                            const container = document.getElementById('inProgressTechniciansList');

                            console.log('🔍 Loading technicians for request:', requestId);

                            fetch('${pageContext.request.contextPath}/managerServiceRequest?action=getQuotationDetails&requestId=' + requestId)
                                    .then(response => {
                                        console.log('📡 Response status:', response.status);
                                        return response.json();
                                    })
                                    .then(data => {
                                        console.log('📦 Received data:', data);

                                        if (data.success && data.quotations && data.quotations.length > 0) {
                                            console.log('✅ Found', data.quotations.length, 'quotations');
                                            let html = '<div style="padding: 20px;">';

                                            data.quotations.forEach((quotation, index) => {
                                                const techInitial = quotation.technicianName ? quotation.technicianName.charAt(0).toUpperCase() : 'T';
                                                const cost = (parseFloat(quotation.estimatedCost) || 0) * 26000;
                                                const partsCount = quotation.parts ? quotation.parts.length : 0;

                                                html += '<div class="technician-card">';

                                                // Header với avatar và info
                                                html += '<div class="technician-header-row">';
                                                html += '<div class="technician-avatar">' + techInitial + '</div>';
                                                html += '<div class="technician-info">';
                                                html += '<div class="technician-name">' + (quotation.technicianName || 'N/A') + '</div>';
                                                html += '<div class="technician-work-desc">' + (quotation.workDescription || 'Không có mô tả') + '</div>';
                                                html += '<div class="technician-meta">';
                                                html += '<div class="meta-item">';
                                                html += '<i class="fas fa-calendar-check"></i>';
                                                html += '<span>Ngày sửa: ' + (quotation.repairDate || 'Chưa xác định') + '</span>';
                                                html += '</div>';
                                                html += '<div class="meta-item">';
                                                html += '<i class="fas fa-cogs"></i>';
                                                html += '<span>' + partsCount + ' linh kiện</span>';
                                                html += '</div>';
                                                html += '</div>';
                                                html += '</div>';
                                                html += '<div class="technician-cost-badge">';
                                                html += cost.toLocaleString('vi-VN') + ' đ';
                                                html += '</div>';
                                                html += '</div>';

                                                // Danh sách linh kiện
                                                if (quotation.parts && quotation.parts.length > 0) {
                                                    html += '<div class="parts-list-header">';
                                                    html += '<i class="fas fa-tools"></i>';
                                                    html += '<span>Danh Sách Linh Kiện Cần Thay Thế</span>';
                                                    html += '</div>';

                                                    quotation.parts.forEach(part => {
                                                        const unitPrice = (parseFloat(part.unitPrice) || 0) * 26000;
                                                        const quantity = parseInt(part.quantity) || 0;
                                                        const totalPrice = unitPrice * quantity;

                                                        html += '<div class="part-item">';
                                                        html += '<div>';
                                                        html += '<div class="part-name">' + (part.partName || 'N/A') + '</div>';
                                                        html += '<div class="part-serial">' + (part.serialNumber || 'N/A') + '</div>';
                                                        html += '</div>';
                                                        html += '<div class="part-quantity">x' + quantity + '</div>';
                                                        html += '<div class="text-muted" style="text-align: right; font-size: 0.85rem;">' + unitPrice.toLocaleString('vi-VN') + ' đ</div>';
                                                        html += '<div class="part-price">' + totalPrice.toLocaleString('vi-VN') + ' đ</div>';

                                                        // Status hoặc action buttons
                                                        html += '<div class="part-actions">';
                                                        if (part.paymentStatus === 'Completed') {
                                                            html += '<span class="badge badge-completed" style="font-size: 0.7rem;">';
                                                            html += '<i class="fas fa-check-circle"></i> Đã thanh toán';
                                                            html += '</span>';
                                                        } else if (part.paymentStatus === 'Cancelled') {
                                                            html += '<span class="badge badge-cancelled" style="font-size: 0.7rem;">';
                                                            html += '<i class="fas fa-times-circle"></i> Đã hủy';
                                                            html += '</span>';
                                                        }
                                                        html += '</div>';

                                                    });
                                                } else {
                                                    html += '<div class="no-parts-message">';
                                                    html += '<i class="fas fa-box-open"></i>';
                                                    html += '<p>Không có linh kiện nào cần thay thế</p>';
                                                    html += '</div>';
                                                }

                                                html += '</div>'; // Close technician-card
                                            });

                                            html += '</div>';
                                            container.innerHTML = html;
                                        } else {
                                            console.warn('⚠️ No quotations found or data.success = false');
                                            console.log('Data:', data);
                                            container.innerHTML = '<div class="text-center py-4"><i class="fas fa-info-circle fa-2x text-muted mb-2"></i><p class="text-muted">Chưa có thông tin người sửa chữa</p><small class="text-muted">RequestId: ' + requestId + '</small></div>';
                                        }
                                    })
                                    .catch(error => {
                                        console.error('❌ Error loading technicians:', error);
                                        container.innerHTML = '<div class="text-center py-4 text-danger"><i class="fas fa-exclamation-triangle fa-2x mb-2"></i><p>Không thể tải thông tin</p><small>' + error.message + '</small></div>';
                                    });
                        }

                        // ========== MODAL 4: HOÀN THÀNH ==========
                        function showCompletedModal(data) {
                            console.log('✅ Showing Completed Modal with full details');
                            console.log('📦 Data:', data);

                            // Thông tin yêu cầu cơ bản
                            document.getElementById('completedRequestId').textContent = '#' + data.requestId;
                            document.getElementById('completedRequestDate').textContent = data.requestDate;
                            document.getElementById('completedContractId').textContent = data.contractId || 'N/A';
                            document.getElementById('completedEquipmentName').textContent = data.equipmentName || 'N/A';
                            document.getElementById('completedDescription').textContent = data.description;

                            // Load danh sách technicians và parts cho yêu cầu hoàn thành
                            loadCompletedTechnicians(data.requestId);

                            // Mở modal
                            new bootstrap.Modal(document.getElementById('viewModalCompleted')).show();
                        }

                        // ✅ Load danh sách technicians với parts cho modal hoàn thành
                        function loadCompletedTechnicians(requestId) {
                            const container = document.getElementById('completedTechniciansList');

                            console.log('🔍 Loading completed technicians for request:', requestId);

                            fetch('${pageContext.request.contextPath}/managerServiceRequest?action=getQuotationDetails&requestId=' + requestId)
                                    .then(response => {
                                        console.log('📡 Response status:', response.status);
                                        return response.json();
                                    })
                                    .then(data => {
                                        console.log('📦 Received data:', data);

                                        if (data.success && data.quotations && data.quotations.length > 0) {
                                            console.log('✅ Found', data.quotations.length, 'quotations');
                                            let html = '<div style="padding: 20px;">';
                                            let totalCost = 0;

                                            data.quotations.forEach((quotation, index) => {
                                                const techInitial = quotation.technicianName ? quotation.technicianName.charAt(0).toUpperCase() : 'T';
                                                const cost = (parseFloat(quotation.estimatedCost) || 0) * 26000;
                                                totalCost += cost;
                                                const partsCount = quotation.parts ? quotation.parts.length : 0;

                                                html += '<div class="technician-card">';

                                                // Header với avatar và info
                                                html += '<div class="technician-header-row">';
                                                html += '<div class="technician-avatar">' + techInitial + '</div>';
                                                html += '<div class="technician-info">';
                                                html += '<div class="technician-name">' + (quotation.technicianName || 'N/A') + '</div>';
                                                html += '<div class="technician-work-desc">' + (quotation.workDescription || 'Không có mô tả') + '</div>';
                                                html += '<div class="technician-meta">';
                                                html += '<div class="meta-item">';
                                                html += '<i class="fas fa-calendar-check"></i>';
                                                html += '<span>Ngày sửa: ' + (quotation.repairDate || 'Chưa xác định') + '</span>';
                                                html += '</div>';
                                                html += '<div class="meta-item">';
                                                html += '<i class="fas fa-cogs"></i>';
                                                html += '<span>' + partsCount + ' linh kiện</span>';
                                                html += '</div>';
                                                html += '</div>';
                                                html += '</div>';
                                                html += '<div class="technician-cost-badge">';
                                                html += cost.toLocaleString('vi-VN') + ' đ';
                                                html += '</div>';
                                                html += '</div>';

                                                // Danh sách linh kiện
                                                if (quotation.parts && quotation.parts.length > 0) {
                                                    html += '<div class="parts-list-header">';
                                                    html += '<i class="fas fa-tools"></i>';
                                                    html += '<span>Danh Sách Linh Kiện Đã Thay Thế</span>';
                                                    html += '</div>';

                                                    let partsTotalCost = 0;

                                                    quotation.parts.forEach(part => {
                                                        const unitPrice = (parseFloat(part.unitPrice) || 0) * 26000;
                                                        const quantity = parseInt(part.quantity) || 0;
                                                        const totalPrice = unitPrice * quantity;
                                                        partsTotalCost += totalPrice;

                                                        html += '<div class="part-item">';
                                                        html += '<div>';
                                                        html += '<div class="part-name">' + (part.partName || 'N/A') + '</div>';
                                                        html += '<div class="part-serial">' + (part.serialNumber || 'N/A') + '</div>';
                                                        html += '</div>';
                                                        html += '<div class="part-quantity">x' + quantity + '</div>';
                                                        html += '<div class="text-muted" style="text-align: right; font-size: 0.85rem;">' + unitPrice.toLocaleString('vi-VN') + ' đ</div>';
                                                        html += '<div class="part-price">' + totalPrice.toLocaleString('vi-VN') + ' đ</div>';

                                                        // Hiển thị trạng thái thanh toán

                                                        html += '</div>';
                                                        html += '</div>';
                                                    });

                                                    // Tổng chi phí linh kiện của kỹ thuật viên
                                                    html += '<div class="mt-3 p-3 bg-light border rounded">';
                                                    html += '<div class="d-flex justify-content-between align-items-center">';
                                                    html += '<strong class="text-success"><i class="fas fa-calculator"></i> Tổng chi phí linh kiện:</strong>';
                                                    html += '<strong class="text-success" style="font-size: 1.2rem;">' + partsTotalCost.toLocaleString('vi-VN') + ' đ</strong>';
                                                    html += '</div>';
                                                    html += '</div>';
                                                } else {
                                                    html += '<div class="no-parts-message">';
                                                    html += '<i class="fas fa-box-open"></i>';
                                                    html += '<p>Không có linh kiện nào được thay thế</p>';
                                                    html += '</div>';
                                                }

                                                html += '</div>'; // Close technician-card
                                            });

                                            // Tổng kết toàn bộ
                                            html += '<div class="card mt-3 border-success">';
                                            html += '<div class="card-body bg-light">';
                                            html += '<div class="row">';
                                            html += '<div class="col-md-6">';
                                            html += '<h6 class="text-success mb-2"><i class="fas fa-users-cog"></i> Tổng Kết</h6>';
                                            html += '<p class="mb-1"><strong>Số kỹ thuật viên:</strong> ' + data.quotations.length + '</p>';
                                            html += '<p class="mb-0"><strong>Trạng thái:</strong> <span class="badge badge-completed">Hoàn thành</span></p>';
                                            html += '</div>';
                                            html += '<div class="col-md-6 text-end">';
                                            html += '<h6 class="text-success mb-2"><i class="fas fa-money-bill-wave"></i> Tổng Chi Phí</h6>';
                                            html += '<h3 class="text-success mb-0">' + totalCost.toLocaleString('vi-VN') + ' đ</h3>';
                                            html += '</div>';
                                            html += '</div>';
                                            html += '</div>';
                                            html += '</div>';

                                            html += '</div>';
                                            container.innerHTML = html;
                                        } else {
                                            console.warn('⚠️ No quotations found or data.success = false');
                                            console.log('Data:', data);
                                            container.innerHTML = '<div class="text-center py-4"><i class="fas fa-info-circle fa-2x text-muted mb-2"></i><p class="text-muted">Chưa có thông tin kỹ thuật viên</p></div>';
                                        }
                                    })
                                    .catch(error => {
                                        console.error('❌ Error loading technicians:', error);
                                        container.innerHTML = '<div class="text-center py-4 text-danger"><i class="fas fa-exclamation-triangle fa-2x mb-2"></i><p>Không thể tải thông tin</p><small>' + error.message + '</small></div>';
                                    });
                        }

                        // Scroll to top button
                        window.addEventListener('scroll', function () {
                            const scrollBtn = document.getElementById('scrollToTop');
                            if (window.pageYOffset > 300) {
                                scrollBtn.classList.add('show');
                            } else {
                                scrollBtn.classList.remove('show');
                            }
                        });

                        // Toast notifications (from original)
                        function showToast(message, type) {
                            const container = document.getElementById('toastContainer');
                            let iconClass = 'fa-check-circle';
                            if (type === 'error')
                                iconClass = 'fa-exclamation-circle';
                            if (type === 'info')
                                iconClass = 'fa-info-circle';

                            const toastDiv = document.createElement('div');
                            toastDiv.className = 'toast-notification ' + type;

                            const iconDiv = document.createElement('div');
                            iconDiv.className = 'toast-icon ' + type;
                            iconDiv.innerHTML = '<i class="fas ' + iconClass + '"></i>';

                            const contentDiv = document.createElement('div');
                            contentDiv.className = 'toast-content';
                            contentDiv.textContent = message;

                            const closeBtn = document.createElement('button');
                            closeBtn.className = 'toast-close';
                            closeBtn.type = 'button';
                            closeBtn.innerHTML = '<i class="fas fa-times"></i>';
                            closeBtn.onclick = hideToast;

                            toastDiv.appendChild(iconDiv);
                            toastDiv.appendChild(contentDiv);
                            toastDiv.appendChild(closeBtn);

                            container.innerHTML = '';
                            container.appendChild(toastDiv);

                            setTimeout(hideToast, 5000);
                        }

                        function hideToast() {
                            const container = document.getElementById('toastContainer');
                            const toast = container.querySelector('.toast-notification');
                            if (toast) {
                                toast.classList.add('hiding');
                                setTimeout(function () {
                                    container.innerHTML = '';
                                }, 400);
                            }
                        }

                        // ========== CREATE FORM FUNCTIONS ==========
                        function toggleFields() {
                            const supportType = document.getElementById('supportType').value;
                            const equipmentSelectField = document.getElementById('equipmentSelectField');
                            const requestTypeField = document.getElementById('requestTypeField');
                            const priorityField = document.getElementById('priorityField');
                            const descriptionField = document.getElementById('descriptionField');
                            const priorityInput = document.getElementById('priorityLevel');
                            const descriptionInput = document.getElementById('description');
                            const requestTypeInput = document.getElementById('requestType');

                            if (supportType === 'equipment') {
                                equipmentSelectField.style.display = 'block';
                                requestTypeField.style.display = 'block';
                                priorityField.style.display = 'block';
                                descriptionField.style.display = 'block';
                                priorityInput.setAttribute('required', 'required');
                                descriptionInput.setAttribute('required', 'required');
                                requestTypeInput.setAttribute('required', 'required');
                                updateCharCount();
                            } else {
                                equipmentSelectField.style.display = 'none';
                                requestTypeField.style.display = 'none';
                                priorityField.style.display = 'none';
                                descriptionField.style.display = 'none';
                                priorityInput.removeAttribute('required');
                                descriptionInput.removeAttribute('required');
                                requestTypeInput.removeAttribute('required');
                            }
                        }

                        function toggleEquipmentDropdown() {
                            const menu = document.getElementById('equipmentDropdownMenu');
                            const icon = document.getElementById('equipmentDropdownIcon');

                            if (menu.style.display === 'none' || menu.style.display === '') {
                                menu.style.display = 'block';
                                icon.classList.remove('fa-chevron-down');
                                icon.classList.add('fa-chevron-up');
                            } else {
                                menu.style.display = 'none';
                                icon.classList.remove('fa-chevron-up');
                                icon.classList.add('fa-chevron-down');
                            }
                        }

                        function updateSelectedEquipment() {
                            const checkboxes = document.querySelectorAll('.equipment-checkbox:checked');
                            const display = document.getElementById('selectedEquipmentDisplay');
                            const label = document.getElementById('equipmentDropdownLabel');

                            if (checkboxes.length === 0) {
                                display.innerHTML = '';
                                label.innerHTML = '<i class="fas fa-list"></i> Chọn thiết bị cần hỗ trợ';
                                return;
                            }

                            // Update label
                            label.innerHTML = '<i class="fas fa-check-circle text-success"></i> Đã chọn ' + checkboxes.length + ' thiết bị';

                            // Update display
                            let html = '<div class="alert alert-info mb-0 mt-2"><strong>Đã chọn ' + checkboxes.length + ' thiết bị:</strong><ul class="mb-0 mt-2">';
                            checkboxes.forEach(function (cb) {
                                const model = cb.dataset.model;
                                const serial = cb.dataset.serial;
                                html += '<li><strong>' + model + '</strong> (SN: ' + serial + ')</li>';
                            });
                            html += '</ul></div>';
                            display.innerHTML = html;
                        }

                        function updateCharCount() {
                            const textarea = document.getElementById('description');
                            const charCount = document.getElementById('charCount');
                            if (!textarea || !charCount)
                                return;

                            const currentLength = textarea.value.length;
                            charCount.textContent = currentLength + '/1000';

                            if (currentLength > 900) {
                                charCount.className = 'text-danger';
                            } else if (currentLength > 700) {
                                charCount.className = 'text-warning';
                            } else {
                                charCount.className = 'text-muted';
                            }
                        }

                        function validateCreateForm(event) {
                            const supportType = document.getElementById('supportType').value;
                            const description = document.getElementById('description').value.trim();

                            if (!supportType) {
                                event.preventDefault();
                                showToast('Vui lòng chọn loại hỗ trợ!', 'error');
                                return false;
                            }

                            if (description.length < 10) {
                                event.preventDefault();
                                showToast('Mô tả phải có ít nhất 10 ký tự!', 'error');
                                document.getElementById('description').focus();
                                return false;
                            }

                            if (description.length > 1000) {
                                event.preventDefault();
                                showToast('Mô tả không được vượt quá 1000 ký tự!', 'error');
                                document.getElementById('description').focus();
                                return false;
                            }

                            // Chỉ kiểm tra thiết bị cho loại hỗ trợ thiết bị
                            const selectedEquipment = document.querySelectorAll('.equipment-checkbox:checked');
                            if (selectedEquipment.length === 0) {
                                event.preventDefault();
                                showToast('Vui lòng chọn ít nhất một thiết bị!', 'error');
                                return false;
                            }

                            return true;
                        }

                        // ========== EVENT LISTENERS ==========
                        document.addEventListener('DOMContentLoaded', function () {
                            console.log('🔍 DOM Loaded');

                            // Event cho textarea
                            const descriptionTextarea = document.getElementById('description');
                            if (descriptionTextarea) {
                                descriptionTextarea.addEventListener('input', updateCharCount);
                            }

                            // Reset form khi đóng modal TẠO MỚI
                            const createModal = document.getElementById('createModal');
                            if (createModal) {
                                createModal.addEventListener('hidden.bs.modal', function () {
                                    document.getElementById('createForm').reset();
                                    toggleFields();

                                    // Reset dropdown
                                    const menu = document.getElementById('equipmentDropdownMenu');
                                    if (menu) {
                                        menu.style.display = 'none';
                                    }

                                    const icon = document.getElementById('equipmentDropdownIcon');
                                    if (icon) {
                                        icon.classList.remove('fa-chevron-up');
                                        icon.classList.add('fa-chevron-down');
                                    }

                                    // Uncheck all checkboxes
                                    document.querySelectorAll('.equipment-checkbox').forEach(cb => cb.checked = false);
                                    updateSelectedEquipment();
                                });

                                createModal.addEventListener('shown.bs.modal', function () {
                                    updateCharCount();
                                });
                            }

                            // Đóng dropdown khi click bên ngoài
                            document.addEventListener('click', function (event) {
                                const dropdown = document.getElementById('equipmentDropdownMenu');
                                const button = document.getElementById('equipmentDropdownBtn');

                                if (dropdown && button) {
                                    if (!button.contains(event.target) && !dropdown.contains(event.target)) {
                                        dropdown.style.display = 'none';
                                        const icon = document.getElementById('equipmentDropdownIcon');
                                        if (icon) {
                                            icon.classList.remove('fa-chevron-up');
                                            icon.classList.add('fa-chevron-down');
                                        }
                                    }
                                }
                            });
                        });

                        // ========== FUNCTION TỪ CHỐI BÁO GIÁ ==========
                        function rejectQuotation(requestId, reportId, technicianName) {
                            console.log('🔴 rejectQuotation called:', {requestId, reportId, technicianName});

                            Swal.fire({
                                title: 'Xác nhận từ chối?',
                                html: `Bạn có chắc muốn từ chối báo giá của <strong>${technicianName}</strong>?<br><br>` +
                                        `<small class="text-muted">Báo giá sẽ được đánh dấu là "Từ chối" và không thể hoàn tác.</small>`,
                                icon: 'warning',
                                showCancelButton: true,
                                confirmButtonColor: '#d33',
                                cancelButtonColor: '#6c757d',
                                confirmButtonText: '<i class="fas fa-times-circle"></i> Từ chối',
                                cancelButtonText: '<i class="fas fa-arrow-left"></i> Hủy'
                            }).then((result) => {
                                if (result.isConfirmed) {
                                    // Hiển thị loading
                                    Swal.fire({
                                        title: 'Đang xử lý...',
                                        html: 'Vui lòng đợi trong giây lát',
                                        allowOutsideClick: false,
                                        didOpen: () => {
                                            Swal.showLoading();
                                        }
                                    });

                                    // Gọi AJAX
                                    const formData = new URLSearchParams();
                                    formData.append('action', 'rejectQuotation');
                                    formData.append('requestId', requestId);
                                    formData.append('reportId', reportId);

                                    console.log('📤 Sending request:', formData.toString());

                                    fetch('${pageContext.request.contextPath}/managerServiceRequest', {
                                        method: 'POST',
                                        headers: {
                                            'Content-Type': 'application/x-www-form-urlencoded'
                                        },
                                        body: formData.toString()
                                    })
                                            .then(response => {
                                                console.log('📥 Response status:', response.status);
                                                if (!response.ok) {
                                                    throw new Error('Server trả về lỗi: ' + response.status);
                                                }
                                                return response.text();
                                            })
                                            .then(text => {
                                                console.log('📥 Response text:', text);
                                                if (!text || text.trim() === '') {
                                                    throw new Error('Server trả về response rỗng. Vui lòng kiểm tra server log.');
                                                }
                                                return JSON.parse(text);
                                            })
                                            .then(data => {
                                                console.log('✅ Parsed data:', data);
                                                Swal.close();

                                                if (data.success) {
                                                    Swal.fire({
                                                        icon: 'success',
                                                        title: 'Thành công!',
                                                        text: data.message || 'Đã từ chối báo giá thành công!',
                                                        confirmButtonText: 'OK'
                                                    }).then(() => {
                                                        location.reload();
                                                    });
                                                } else {
                                                    Swal.fire({
                                                        icon: 'error',
                                                        title: 'Lỗi!',
                                                        text: data.message || 'Không thể từ chối báo giá!'
                                                    });
                                                }
                                            })
                                            .catch(error => {
                                                console.error('❌ Error:', error);
                                                Swal.close();
                                                Swal.fire({
                                                    icon: 'error',
                                                    title: 'Lỗi!',
                                                    html: `Có lỗi xảy ra khi từ chối báo giá:<br><br>` +
                                                            `<small class="text-danger">${error.message}</small><br><br>` +
                                                            `<small class="text-muted">Vui lòng kiểm tra console log và server log để biết thêm chi tiết.</small>`
                                                });
                                            });
                                }
                            });
                        }
                        // ========== FAQ DATA ========== 
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