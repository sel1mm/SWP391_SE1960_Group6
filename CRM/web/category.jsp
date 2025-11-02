<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <title>CRM System - Category Management</title>

    <style>
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: 'Inter', 'Segoe UI', sans-serif;
    background: #f5f7fa;
    color: #333;
    line-height: 1.6;
}

/* NAVBAR */
.navbar {
    background: #000000;
    padding: 1rem 0;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    position: sticky;
    top: 0;
    z-index: 1000;
}

.nav-container {
    max-width: 100%;
    padding: 0 2rem;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.logo {
    color: white;
    font-size: 24px;
    font-weight: 600;
}

.nav-links {
    display: flex;
    gap: 30px;
    align-items: center;
}

.nav-links a {
    color: white;
    text-decoration: none;
    font-weight: 400;
    font-size: 14px;
    transition: all 0.3s ease;
    padding: 8px 16px;
    border-radius: 4px;
}

.nav-links a:hover {
    background: rgba(255,255,255,0.1);
}

/* SIDEBAR */
.sidebar {
    width: 220px;
    min-height: calc(100vh - 65px);
    position: fixed;
    top: 65px;
    left: 0;
    background: #000000;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    box-shadow: 2px 0 4px rgba(0,0,0,0.1);
}

.sidebar a {
    color: white;
    text-decoration: none;
    padding: 12px 20px;
    font-size: 14px;
    display: flex;
    align-items: center;
    gap: 12px;
    transition: all 0.2s ease;
    font-weight: 400;
    border-left: 3px solid transparent;
}

.sidebar a:hover, .sidebar a.active {
    background: rgba(255,255,255,0.08);
    border-left: 3px solid white;
}

/* CONTENT */
.content {
    margin-left: 220px;
    padding: 40px;
    min-height: calc(100vh - 65px);
}

.page-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 30px;
}

.page-header h2 {
    color: #1a202c;
    font-size: 32px;
    font-weight: 700;
    display: flex;
    align-items: center;
    gap: 12px;
}

.btn-add-new {
    background: #3b82f6;
    color: white;
    border: none;
    padding: 12px 24px;
    border-radius: 8px;
    cursor: pointer;
    font-weight: 600;
    font-size: 14px;
    transition: all 0.2s;
    display: inline-flex;
    align-items: center;
    gap: 8px;
}

.btn-add-new:hover {
    background: #2563eb;
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(59,130,246,0.4);
}

/* FILTER SECTION */
.filter-section {
    background: white;
    padding: 20px;
    border-radius: 12px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.1);
    margin-bottom: 24px;
}

.filter-group {
    display: flex;
    gap: 12px;
    align-items: center;
}

.filter-group label {
    font-weight: 600;
    color: #4b5563;
    font-size: 14px;
}

.filter-select {
    padding: 10px 16px;
    border: 2px solid #e5e7eb;
    border-radius: 8px;
    font-size: 14px;
    outline: none;
    background: white;
    transition: all 0.2s;
    cursor: pointer;
    min-width: 200px;
}

.filter-select:focus {
    border-color: #3b82f6;
    box-shadow: 0 0 0 3px rgba(59,130,246,0.1);
}

/* MESSAGES */
.message {
    padding: 16px 20px;
    border-radius: 8px;
    margin-bottom: 20px;
    display: flex;
    align-items: center;
    gap: 12px;
    font-weight: 500;
    animation: slideDown 0.3s ease;
}

@keyframes slideDown {
    from {
        opacity: 0;
        transform: translateY(-10px);
    }
    to {
        opacity: 1;
        transform: translateY(0);
    }
}

.message.success {
    background: #d1fae5;
    color: #065f46;
    border: 1px solid #6ee7b7;
}

.message.error {
    background: #fee2e2;
    color: #991b1b;
    border: 1px solid #fca5a5;
}

/* TABLE */
.table-container {
    background: white;
    border-radius: 12px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.1);
    overflow: hidden;
}

.category-table {
    width: 100%;
    border-collapse: collapse;
}

.category-table thead {
    background: #f9fafb;
    border-bottom: 2px solid #e5e7eb;
}

.category-table thead th {
    padding: 16px 20px;
    text-align: left;
    font-weight: 600;
    font-size: 13px;
    color: #374151;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

.category-table tbody td {
    padding: 16px 20px;
    border-bottom: 1px solid #f3f4f6;
    font-size: 14px;
    color: #6b7280;
}

.category-table tbody tr {
    transition: all 0.2s;
}

.category-table tbody tr:hover {
    background: #f9fafb;
}

.category-table tbody tr:last-child td {
    border-bottom: none;
}

/* TYPE BADGE */
.type-badge {
    display: inline-block;
    padding: 6px 14px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

.type-badge.part {
    background: #dbeafe;
    color: #1e40af;
}

.type-badge.product {
    background: #fce7f3;
    color: #9f1239;
}

/* ACTION BUTTONS */
.action-buttons {
    display: flex;
    gap: 8px;
}

.btn-icon {
    width: 36px;
    height: 36px;
    border: 2px solid;
    background: white;
    border-radius: 8px;
    cursor: pointer;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    transition: all 0.2s;
    font-size: 14px;
}

.btn-edit {
    border-color: #3b82f6;
    color: #3b82f6;
}

.btn-edit:hover {
    background: #3b82f6;
    color: white;
    transform: translateY(-2px);
    box-shadow: 0 4px 8px rgba(59,130,246,0.3);
}

.btn-delete {
    border-color: #ef4444;
    color: #ef4444;
}

.btn-delete:hover {
    background: #ef4444;
    color: white;
    transform: translateY(-2px);
    box-shadow: 0 4px 8px rgba(239,68,68,0.3);
}

/* MODAL */
.modal-overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0,0,0,0.5);
    backdrop-filter: blur(4px);
    display: none;
    justify-content: center;
    align-items: center;
    z-index: 2000;
    animation: fadeIn 0.3s ease;
}

.modal-overlay.show {
    display: flex;
}

@keyframes fadeIn {
    from { opacity: 0; }
    to { opacity: 1; }
}

.modal-container {
    background: white;
    border-radius: 16px;
    width: 500px;
    max-width: 95%;
    box-shadow: 0 20px 50px rgba(0,0,0,0.3);
    animation: slideUp 0.3s ease;
}

@keyframes slideUp {
    from {
        transform: translateY(50px);
        opacity: 0;
    }
    to {
        transform: translateY(0);
        opacity: 1;
    }
}

.modal-header {
    padding: 24px 28px;
    border-bottom: 1px solid #e5e7eb;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.modal-header h3 {
    font-size: 20px;
    font-weight: 700;
    color: #1a202c;
    display: flex;
    align-items: center;
    gap: 10px;
}

.modal-close {
    background: #f3f4f6;
    border: none;
    width: 32px;
    height: 32px;
    border-radius: 8px;
    cursor: pointer;
    font-size: 18px;
    color: #6b7280;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: all 0.2s;
}

.modal-close:hover {
    background: #e5e7eb;
    color: #1f2937;
    transform: rotate(90deg);
}

.modal-body {
    padding: 28px;
}

.form-group {
    margin-bottom: 20px;
}

.form-group label {
    display: block;
    font-weight: 600;
    color: #374151;
    margin-bottom: 8px;
    font-size: 14px;
}

.form-group label .required {
    color: #ef4444;
}

.form-group input,
.form-group select {
    width: 100%;
    padding: 12px 16px;
    border: 2px solid #e5e7eb;
    border-radius: 8px;
    font-size: 14px;
    outline: none;
    transition: all 0.2s;
}

.form-group input:focus,
.form-group select:focus {
    border-color: #3b82f6;
    box-shadow: 0 0 0 3px rgba(59,130,246,0.1);
}

.form-message {
    font-size: 13px;
    margin-top: 12px;
    text-align: center;
    min-height: 20px;
    font-weight: 500;
}

.modal-footer {
    padding: 20px 28px;
    background: #f9fafb;
    border-top: 1px solid #e5e7eb;
    border-radius: 0 0 16px 16px;
    display: flex;
    justify-content: flex-end;
    gap: 12px;
}

.btn-modal {
    padding: 10px 24px;
    border-radius: 8px;
    border: none;
    font-weight: 600;
    font-size: 14px;
    cursor: pointer;
    transition: all 0.2s;
}

.btn-save {
    background: #3b82f6;
    color: white;
}

.btn-save:hover {
    background: #2563eb;
    transform: translateY(-1px);
    box-shadow: 0 4px 12px rgba(59,130,246,0.4);
}

.btn-cancel {
    background: #e5e7eb;
    color: #374151;
}

.btn-cancel:hover {
    background: #d1d5db;
}

/* NO DATA */
.no-data {
    text-align: center;
    padding: 60px 20px;
    color: #9ca3af;
}

.no-data i {
    font-size: 64px;
    margin-bottom: 16px;
    display: block;
    opacity: 0.5;
}

.no-data p {
    font-size: 16px;
    font-weight: 500;
}

/* RESPONSIVE */
@media (max-width: 900px) {
    .content {
        margin-left: 0;
        padding: 20px;
    }
    .sidebar {
        display: none;
    }
    .page-header {
        flex-direction: column;
        align-items: flex-start;
        gap: 16px;
    }
}
    </style>
</head>

<body>
    <!-- Navbar -->
    <nav class="navbar">
        <div class="nav-container">
            <div class="logo">CRM System</div>
            <div class="nav-links">
                <a href="#"><i class="fas fa-envelope"></i> Tin nhắn</a>
                <a href="#"><i class="fas fa-bell"></i> Thông báo</a>
                <a href="login">Xin chào ${sessionScope.session_login.fullName}</a>
            </div>
        </div>
    </nav>

    <!-- Sidebar -->
    <div class="sidebar">
        <div>
            <a href="storekeeper"><i class="fas fa-user-cog"></i><span>Trang chủ</span></a>
            <a href="manageProfile"><i class="fas fa-user-circle"></i><span>Hồ Sơ</span></a>
            <a href="#"><i class="fas fa-chart-line"></i><span>Thống kê</span></a>
            <a href="numberPart"><i class="fas fa-list"></i><span>Danh sách linh kiện</span></a>
            <a href="numberEquipment"><i class="fas fa-list"></i><span>Danh sách thiết bị </span></a>
            <a href="PartDetailHistoryServlet"><i class="fas fa-history"></i><span>Lịch sử giao dịch</span></a>
            <a href="partDetail"><i class="fas fa-truck-loading"></i><span>Chi tiết linh kiện</span></a>
            <a href="category" class="active"><i class="fas fa-tags"></i><span>Quản lý danh mục</span></a>
        </div>
        <a href="logout" style="background: rgba(255, 255, 255, 0.05); border-top: 1px solid rgba(255,255,255,0.1); text-align: center; font-weight: 500;">
            <i class="fas fa-sign-out-alt"></i><span>Đăng xuất</span>
        </a>
    </div>

    <!-- Content -->
    <div class="content">
        <div class="page-header">
            <h2><i class="fas fa-tags"></i> Quản lý danh mục</h2>
            <button class="btn-add-new" onclick="openModal('add')">
                <i class="fas fa-plus"></i> Add New Category
            </button>
        </div>

        <!-- Messages -->
        <c:if test="${not empty successMessage}">
            <div class="message success">
                <i class="fas fa-check-circle"></i> ${successMessage}
            </div>
        </c:if>
        <c:if test="${not empty errorMessage}">
            <div class="message error">
                <i class="fas fa-exclamation-circle"></i> ${errorMessage}
            </div>
        </c:if>

        <!-- Filter Section -->
        <div class="filter-section">
            <form action="category" method="GET" class="filter-group">
                <label><i class="fas fa-filter"></i> Filter by Type:</label>
                <select name="typeFilter" class="filter-select" onchange="this.form.submit()">
                    <option value="">All Categories</option>
                    <option value="Part" ${param.typeFilter == 'Part' ? 'selected' : ''}>Part</option>
                    <option value="Product" ${param.typeFilter == 'Product' ? 'selected' : ''}>Product</option>
                </select>
            </form>
        </div>

        <!-- Table -->
        <div class="table-container">
            <table class="category-table">
                <thead>
                    <tr>
                        <th style="width: 10%;">ID</th>
                        <th style="width: 40%;">Category Name</th>
                        <th style="width: 25%;">Type</th>
                        <th style="width: 25%;">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${not empty categoryList}">
                            <c:forEach items="${categoryList}" var="cat">
                                <tr>
                                    <td>${cat.categoryId}</td>
                                    <td><strong>${cat.categoryName}</strong></td>
                                    <td>
                                        <span class="type-badge ${cat.type.toLowerCase()}">
                                            ${cat.type}
                                        </span>
                                    </td>
                                    <td>
                                        <div class="action-buttons">
                                            <button class="btn-icon btn-edit" 
                                                    data-id="${cat.categoryId}"
                                                    data-name="${cat.categoryName}"
                                                    data-type="${cat.type}"
                                                    title="Edit">
                                                <i class="fas fa-edit"></i>
                                            </button>
                                            <button class="btn-icon btn-delete" 
                                                    data-id="${cat.categoryId}"
                                                    data-name="${cat.categoryName}"
                                                    title="Delete">
                                                <i class="fas fa-trash"></i>
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="4">
                                    <div class="no-data">
                                        <i class="fas fa-inbox"></i>
                                        <p>No categories found</p>
                                    </div>
                                </td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Modal Form -->
    <div class="modal-overlay" id="categoryModal">
        <div class="modal-container">
            <div class="modal-header">
                <h3 id="modalTitle"><i class="fas fa-plus-circle"></i> Add New Category</h3>
                <button class="modal-close" onclick="closeModal()">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            <form action="category" method="POST" id="categoryForm" onsubmit="return validateForm()">
                <input type="hidden" name="action" id="formAction" value="add">
                <input type="hidden" name="categoryId" id="categoryId">
                
                <div class="modal-body">
                    <div class="form-group">
                        <label>Category Name <span class="required">*</span></label>
                        <input type="text" name="categoryName" id="categoryName" 
                               required minlength="3" maxlength="50"
                               placeholder="Enter category name">
                    </div>

                    <div class="form-group">
                        <label>Type <span class="required">*</span></label>
                        <select name="type" id="categoryType" required>
                            <option value="">-- Select Type --</option>
                            <option value="Part">Part</option>
                            <option value="Product">Product</option>
                        </select>
                    </div>

                    <div class="form-message" id="formMessage"></div>
                </div>

                <div class="modal-footer">
                    <button type="button" class="btn-modal btn-cancel" onclick="closeModal()">
                        <i class="fas fa-times"></i> Cancel
                    </button>
                    <button type="submit" class="btn-modal btn-save">
                        <i class="fas fa-save"></i> Save
                    </button>
                </div>
            </form>
        </div>
    </div>

    <script>
        // ========== MODAL FUNCTIONS ==========
        function openModal(mode, categoryId = '', categoryName = '', type = '') {
            const modal = document.getElementById('categoryModal');
            const modalTitle = document.getElementById('modalTitle');
            const formAction = document.getElementById('formAction');
            const formMessage = document.getElementById('formMessage');
            
            formMessage.textContent = '';
            formMessage.style.color = '#ef4444';
            
            if (mode === 'add') {
                modalTitle.innerHTML = '<i class="fas fa-plus-circle"></i> Add New Category';
                formAction.value = 'add';
                document.getElementById('categoryId').value = '';
                document.getElementById('categoryName').value = '';
                document.getElementById('categoryType').value = '';
            } else {
                modalTitle.innerHTML = '<i class="fas fa-edit"></i> Edit Category';
                formAction.value = 'edit';
                document.getElementById('categoryId').value = categoryId;
                document.getElementById('categoryName').value = categoryName;
                document.getElementById('categoryType').value = type;
            }
            
            modal.classList.add('show');
            document.body.style.overflow = 'hidden';
        }

        function closeModal() {
            const modal = document.getElementById('categoryModal');
            modal.classList.remove('show');
            document.body.style.overflow = 'auto';
            document.getElementById('formMessage').textContent = '';
        }

        function validateForm() {
            const categoryName = document.getElementById('categoryName').value.trim();
            const type = document.getElementById('categoryType').value;
            const formMessage = document.getElementById('formMessage');
            
            formMessage.textContent = '';
            
            if (categoryName.length < 3) {
                formMessage.textContent = '❌ Category name must be at least 3 characters!';
                return false;
            }
            
            if (categoryName.length > 50) {
                formMessage.textContent = '❌ Category name cannot exceed 50 characters!';
                return false;
            }
            
            if (!type) {
                formMessage.textContent = '❌ Please select a type!';
                return false;
            }
            
            return true;
        }

        function deleteCategory(categoryId, categoryName) {
            if (confirm('Are you sure you want to delete "' + categoryName + '"?\n\nNote: This will fail if there are Parts/Products using this category.')) {
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = 'category';

                const actionInput = document.createElement('input');
                actionInput.type = 'hidden';
                actionInput.name = 'action';
                actionInput.value = 'delete';

                const idInput = document.createElement('input');
                idInput.type = 'hidden';
                idInput.name = 'categoryId';
                idInput.value = categoryId;

                form.appendChild(actionInput);
                form.appendChild(idInput);
                document.body.appendChild(form);
                form.submit();
            }
        }

        // ========== EVENT LISTENERS ==========
        document.addEventListener('DOMContentLoaded', function() {
            // Edit button click
            document.querySelectorAll('.btn-edit').forEach(function(button) {
                button.addEventListener('click', function() {
                    const id = this.getAttribute('data-id');
                    const name = this.getAttribute('data-name');
                    const type = this.getAttribute('data-type');
                    openModal('edit', id, name, type);
                });
            });

            // Delete button click
            document.querySelectorAll('.btn-delete').forEach(function(button) {
                button.addEventListener('click', function() {
                    const id = this.getAttribute('data-id');
                    const name = this.getAttribute('data-name');
                    deleteCategory(id, name);
                });
            });

            // Close modal when clicking outside
            const modal = document.getElementById('categoryModal');
            if (modal) {
                modal.addEventListener('click', function(e) {
                    if (e.target === this) {
                        closeModal();
                    }
                });
            }

            // Real-time validation for category name
            const categoryNameInput = document.getElementById('categoryName');
            if (categoryNameInput) {
                categoryNameInput.addEventListener('input', function() {
                    const length = this.value.length;
                    const formMessage = document.getElementById('formMessage');
                    
                    if (length === 0) {
                        formMessage.textContent = '';
                    } else if (length < 3) {
                        formMessage.textContent = `⚠️ Need ${3 - length} more character(s)`;
                        formMessage.style.color = '#f59e0b';
                    } else if (length > 50) {
                        formMessage.textContent = `❌ Exceeded by ${length - 50} character(s)`;
                        formMessage.style.color = '#ef4444';
                    } else {
                        formMessage.textContent = `✓ ${length}/50 characters`;
                        formMessage.style.color = '#10b981';
                    }
                });
            }

            // Auto-hide messages after 5 seconds
            const messages = document.querySelectorAll('.message');
            messages.forEach(function(msg) {
                setTimeout(function() {
                    msg.style.opacity = '0';
                    msg.style.transform = 'translateY(-20px)';
                    setTimeout(function() {
                        msg.style.display = 'none';
                    }, 300);
                }, 5000);
            });

            // Close modal with ESC key
            document.addEventListener('keydown', function(e) {
                if (e.key === 'Escape') {
                    closeModal();
                }
            });
        });
    </script>

    <%
        session.removeAttribute("successMessage");
        session.removeAttribute("errorMessage");
    %>
</body>
</html>