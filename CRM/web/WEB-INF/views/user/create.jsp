<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Tạo Người Dùng</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    </head>
    <body>
        <div class="container-fluid">
            <div class="row">
                <!-- Sidebar -->
                <div class="col-md-2 min-vh-100 d-flex flex-column justify-content-between" style="background-color: #000000;">
                    <!-- Phần trên của sidebar -->
                    <div class="p-3">
                        <h4 class="text-white">Hệ Thống CRM</h4>
                        <ul class="nav flex-column">
                            <li class="nav-item">
                                <a class="nav-link text-white" href="${pageContext.request.contextPath}/home.jsp">
                                    <i class="fas fa-home"></i> Trang Chủ
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link text-white active" href="${pageContext.request.contextPath}/admin.jsp">
                                    <i class="fas fa-tachometer-alt"></i> Bảng Điều Khiển
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link text-white" href="${pageContext.request.contextPath}/user/list">
                                    <i class="fas fa-users"></i> Người Dùng
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link text-white" href="${pageContext.request.contextPath}/role/list">
                                    <i class="fas fa-user-tag"></i> Vai Trò
                                </a>
                            </li>
                        </ul>
                    </div>

                    <!-- Nút Logout ở dưới cùng -->
                    <div class="p-3 border-top border-secondary">
                        <a href="${pageContext.request.contextPath}/logout"
                           class="btn btn-outline-light w-100 d-flex align-items-center justify-content-center gap-2">
                            <i class="fas fa-sign-out-alt"></i> Đăng Xuất
                        </a>
                    </div>
                </div>

                <!-- Main Content -->
                <div class="col-md-10">
                    <div class="p-4">
                        <div class="d-flex justify-content-between align-items-center mb-4">
                            <h2><i class="fas fa-user-plus"></i> Tạo Người Dùng Mới</h2>
                            <a href="${pageContext.request.contextPath}/user/list" class="btn btn-secondary">
                                <i class="fas fa-arrow-left"></i> Quay Lại Danh Sách
                            </a>
                        </div>

                        <!-- Error Message -->
                        <c:if test="${not empty error}">
                            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                ${error}
                                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                            </div>
                        </c:if>

                        <!-- Create User Form -->
                        <div class="card">
                            <div class="card-body">
                                <form action="${pageContext.request.contextPath}/user/create" method="POST" id="createUserForm">
                                    <div class="row">
                                        <div class="col-md-6">
                                            <div class="mb-3">
                                                <label for="username" class="form-label">Tên Đăng Nhập <span class="text-danger">*</span></label>
                                                <input type="text" class="form-control" id="username" name="username" 
                                                       value="${user.username}" required>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="mb-3">
                                                <label for="fullName" class="form-label">Họ Và Tên</label>
                                                <input type="text" class="form-control" id="fullName" name="fullName" 
                                                       value="${user.fullName}">
                                            </div>
                                        </div>
                                    </div>

                                    <div class="row">
                                        <div class="col-md-6">
                                            <div class="mb-3">
                                                <label for="email" class="form-label">Email <span class="text-danger">*</span></label>
                                                <input type="email" class="form-control" id="email" name="email" 
                                                       value="${user.email}" required>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="mb-3">
                                                <label for="phone" class="form-label">Số Điện Thoại</label>
                                                <input type="tel" class="form-control" id="phone" name="phone" 
                                                       value="${user.phone}">
                                            </div>
                                        </div>
                                    </div>

                                    <div class="row">
                                        <div class="col-md-6">
                                            <div class="mb-3">
                                                <label for="password" class="form-label">Mật Khẩu <span class="text-danger">*</span></label>
                                                <div class="input-group">
                                                    <input type="password" class="form-control" id="password" name="password" required>
                                                    <button class="btn btn-outline-secondary" type="button" onclick="togglePasswordVisibility('password', 'togglePassword')">
                                                        <i class="fas fa-eye" id="togglePassword"></i>
                                                    </button>
                                                </div>
                                                <!-- Password Strength Indicator -->
                                                <div class="mt-2">
                                                    <div class="progress" style="height: 5px;">
                                                        <div id="passwordStrength" class="progress-bar" role="progressbar" style="width: 0%"></div>
                                                    </div>
                                                    <span id="strengthText" class="small"></span>
                                                </div>
                                                <div id="passwordFeedback" class="mt-1"></div>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="mb-3">
                                                <label for="confirmPassword" class="form-label">Xác Nhận Mật Khẩu <span class="text-danger">*</span></label>
                                                <div class="input-group">
                                                    <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" required>
                                                    <button class="btn btn-outline-secondary" type="button" onclick="togglePasswordVisibility('confirmPassword', 'toggleConfirmPassword')">
                                                        <i class="fas fa-eye" id="toggleConfirmPassword"></i>
                                                    </button>
                                                </div>
                                                <div id="matchIcon" class="mt-2"></div>
                                                <small class="text-muted">Nhập lại mật khẩu để xác nhận</small>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="row">
                                        <div class="col-md-6">
                                            <div class="mb-3">
                                                <label for="status" class="form-label">Trạng Thái</label>
                                                <select class="form-select" id="status" name="status">
                                                    <option value="Active" ${user.status == 'Active' ? 'selected' : ''}>Hoạt Động</option>
                                                    <option value="Inactive" ${user.status == 'Inactive' ? 'selected' : ''}>Không Hoạt Động</option>
                                                </select>
                                                <small class="form-text text-muted">
                                                    <i class="fas fa-info-circle"></i> 
                                                    <strong>Hoạt Động:</strong> Yêu cầu xác minh OTP qua email. 
                                                    <strong>Không Hoạt Động:</strong> Lưu trực tiếp, tài khoản không thể đăng nhập.
                                                </small>
                                            </div>
                                        </div>
                                    </div>

                                    <c:if test="${not empty roles}">
                                        <div class="mb-3">
                                            <label class="form-label">Vai Trò</label>
                                            <div class="row">
                                                <c:forEach var="role" items="${roles}">
                                                    <div class="col-md-4">
                                                        <div class="form-check">
                                                            <input class="form-check-input" type="checkbox" 
                                                                   name="roleIds" value="${role.roleId}" 
                                                                   id="role_${role.roleId}">
                                                            <label class="form-check-label" for="role_${role.roleId}">
                                                                ${role.roleName}
                                                            </label>
                                                        </div>
                                                    </div>
                                                </c:forEach>
                                            </div>
                                        </div>
                                    </c:if>

                                    <div class="d-flex justify-content-end gap-2">
                                        <a href="${pageContext.request.contextPath}/user/list" class="btn btn-secondary">
                                            <i class="fas fa-times"></i> Hủy
                                        </a>
                                        <button type="submit" class="btn btn-primary">
                                            <i class="fas fa-save"></i> Tạo Người Dùng
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
        <script>
                                                        // Password strength validation
                                                        function checkPasswordStrength(password) {
                                                            let strength = 0;
                                                            let feedback = [];

                                                            // 1️⃣ Độ dài hợp lệ
                                                            if (password.length >= 6 && password.length <= 30) {
                                                                strength += 25;
                                                            } else {
                                                                feedback.push("Mật khẩu phải từ 6–30 ký tự");
                                                            }

                                                            const hasLetter = /[A-Za-z]/.test(password);
                                                            const hasDigit = /\d/.test(password);
                                                            const hasSpecial = /[!@#$%^&*()_+=-]/.test(password);

                                                            // 2️⃣ Không được toàn bộ là ký tự đặc biệt
                                                            if (!hasLetter && !hasDigit && hasSpecial) {
                                                                feedback.push("Mật khẩu không được chứa toàn bộ ký tự đặc biệt");
                                                            } else {
                                                                strength += 25;
                                                            }

                                                            // 3️⃣ Có chữ → tăng strength
                                                            if (hasLetter) {
                                                                strength += 25;
                                                            } else {
                                                                feedback.push("Nên có ít nhất một chữ cái để tăng bảo mật");
                                                            }

                                                            // 4️⃣ Có số → tăng strength
                                                            if (hasDigit) {
                                                                strength += 25;
                                                            } else {
                                                                feedback.push("Nên có ít nhất một số để tăng mức độ mạnh");
                                                            }

                                                            // (Ký tự đặc biệt KHÔNG bắt buộc, nhưng giúp tăng strength)
                                                            if (hasSpecial) {
                                                                // bonus nhỏ nếu muốn → tùy bạn
                                                            }

                                                            return {strength, feedback};
                                                        }


                                                        // Update password strength indicator
                                                        function updatePasswordStrength() {
                                                            const password = document.getElementById('password').value;
                                                            const strengthBar = document.getElementById('passwordStrength');
                                                            const strengthText = document.getElementById('strengthText');
                                                            const feedbackDiv = document.getElementById('passwordFeedback');

                                                            if (!password) {
                                                                strengthBar.style.width = '0%';
                                                                strengthText.textContent = '';
                                                                feedbackDiv.innerHTML = '';
                                                                return;
                                                            }

                                                            const {strength, feedback} = checkPasswordStrength(password);

                                                            strengthBar.style.width = strength + '%';

                                                            // Update color and text based on strength
                                                            strengthBar.classList.remove('bg-danger', 'bg-warning', 'bg-info', 'bg-success');
                                                            if (strength < 50) {
                                                                strengthBar.classList.add('bg-danger');
                                                                strengthText.textContent = 'Yếu';
                                                                strengthText.className = 'small text-danger';
                                                            } else if (strength < 75) {
                                                                strengthBar.classList.add('bg-warning');
                                                                strengthText.textContent = 'Trung bình';
                                                                strengthText.className = 'small text-warning';
                                                            } else if (strength < 100) {
                                                                strengthBar.classList.add('bg-info');
                                                                strengthText.textContent = 'Khá';
                                                                strengthText.className = 'small text-info';
                                                            } else {
                                                                strengthBar.classList.add('bg-success');
                                                                strengthText.textContent = 'Mạnh';
                                                                strengthText.className = 'small text-success';
                                                            }

                                                            // Show feedback
                                                            if (feedback.length > 0) {
                                                                feedbackDiv.innerHTML = '<small class="text-muted">Cần: ' + feedback.join(', ') + '</small>';
                                                            } else {
                                                                feedbackDiv.innerHTML = '<small class="text-success"><i class="fas fa-check"></i> Mật khẩu mạnh</small>';
                                                            }
                                                        }

                                                        // Password confirmation validation
                                                        function validatePasswordMatch() {
                                                            const password = document.getElementById('password').value;
                                                            const confirmPasswordInput = document.getElementById('confirmPassword');
                                                            const confirmPassword = confirmPasswordInput.value;
                                                            const matchIcon = document.getElementById('matchIcon');

                                                            if (!confirmPassword) {
                                                                matchIcon.innerHTML = '';
                                                                return;
                                                            }

                                                            if (password === confirmPassword) {
                                                                confirmPasswordInput.setCustomValidity('');
                                                                matchIcon.innerHTML = '<small class="text-success"><i class="fas fa-check-circle"></i> Mật khẩu khớp</small>';
                                                            } else {
                                                                confirmPasswordInput.setCustomValidity('Mật khẩu không khớp');
                                                                matchIcon.innerHTML = '<small class="text-danger"><i class="fas fa-times-circle"></i> Mật khẩu không khớp</small>';
                                                            }
                                                        }

                                                        // Toggle password visibility
                                                        function togglePasswordVisibility(inputId, iconId) {
                                                            const input = document.getElementById(inputId);
                                                            const icon = document.getElementById(iconId);

                                                            if (input.type === 'password') {
                                                                input.type = 'text';
                                                                icon.classList.remove('fa-eye');
                                                                icon.classList.add('fa-eye-slash');
                                                            } else {
                                                                input.type = 'password';
                                                                icon.classList.remove('fa-eye-slash');
                                                                icon.classList.add('fa-eye');
                                                            }
                                                        }

                                                        // Initialize when DOM is ready
                                                        document.addEventListener('DOMContentLoaded', function () {
                                                            const password = document.getElementById('password');
                                                            const confirmPassword = document.getElementById('confirmPassword');

                                                            // Add event listeners for password fields
                                                            if (password) {
                                                                password.addEventListener('input', function () {
                                                                    updatePasswordStrength();
                                                                    validatePasswordMatch();
                                                                });
                                                            }

                                                            if (confirmPassword) {
                                                                confirmPassword.addEventListener('input', validatePasswordMatch);
                                                            }

                                                            // Form submission validation
                                                            document.getElementById('createUserForm').addEventListener('submit', function (e) {
                                                                const passwordValue = document.getElementById('password').value;
                                                                const confirmPasswordValue = document.getElementById('confirmPassword').value;

                                                                if (passwordValue !== confirmPasswordValue) {
                                                                    e.preventDefault();
                                                                    alert('Mật khẩu xác nhận không khớp!');
                                                                    return false;
                                                                }

                                                                if (passwordValue.length < 6) {
                                                                    e.preventDefault();
                                                                    alert('Mật khẩu phải có ít nhất 6 ký tự!');
                                                                    return false;
                                                                }

                                                                const {strength} = checkPasswordStrength(passwordValue);
                                                                if (strength < 50) {
                                                                    if (!confirm('Mật khẩu của bạn khá yếu. Bạn có chắc chắn muốn tiếp tục?')) {
                                                                        e.preventDefault();
                                                                        return false;
                                                                    }
                                                                }
                                                            });
                                                        });
        </script>
    </body>
</html>