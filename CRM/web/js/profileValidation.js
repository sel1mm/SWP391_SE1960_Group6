// js/profileValidation.js

// Lấy các input cần validate
const emailInput = document.getElementById("email");
const addressInput = document.querySelector('input[placeholder="Enter your address"]');
const nationalIDInput = document.getElementById("nationalID");
const dobInput = document.querySelector('input[placeholder="Enter your new DoB"]');
const message = document.getElementById("message");

// Hàm hiển thị thông báo
function showMessage(text, color = "red") {
  message.textContent = text;
  message.style.color = color;
}

// Hàm kiểm tra email hợp lệ
function isValidEmail(email) {
  const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return re.test(email);
}

// Hàm kiểm tra địa chỉ (tối thiểu 5 ký tự)
function isValidAddress(address) {
  return address.length >= 5;
}

// Hàm kiểm tra nationalID chỉ gồm 12 chữ số
function isValidNationalID(id) {
  return /^\d{12}$/.test(id);
}

// Hàm kiểm tra định dạng ngày sinh (dd/mm/yyyy hoặc yyyy-mm-dd)
function isValidDate(dob) {
  const re = /^(\d{2}\/\d{2}\/\d{4})$|^(\d{4}-\d{2}-\d{2})$/;
  return re.test(dob);
}

// Hàm validate tổng thể
function validateProfileForm() {
  const email = emailInput.value.trim();
  const address = addressInput.value.trim();
  const nationalID = nationalIDInput.value.trim();
  const dob = dobInput.value.trim();

  if (!email) {
    showMessage("Email cannot be empty!");
    return false;
  }
  if (!isValidEmail(email)) {
    showMessage("Invalid email format!");
    return false;
  }

  if (!address) {
    showMessage("Address cannot be empty!");
    return false;
  }
  if (!isValidAddress(address)) {
    showMessage("Address must be at least 5 characters long!");
    return false;
  }

  if (!nationalID) {
    showMessage("National ID cannot be empty!");
    return false;
  }
  if (!isValidNationalID(nationalID)) {
    showMessage("National ID must contain exactly 12 digits!");
    return false;
  }

  if (!dob) {
    showMessage("Date of Birth cannot be empty!");
    return false;
  }
  if (!isValidDate(dob)) {
    showMessage("Use dd/mm/yyyy or yyyy-mm-dd");
    return false;
  }

  showMessage("All inputs look good!", "green");
  return true;
}

// Theo dõi người dùng nhập để hiện lỗi tức thì
[emailInput, addressInput, nationalIDInput, dobInput].forEach((input) => {
  input.addEventListener("input", validateProfileForm);
});
