<%-- 
    Document   : changePassword
    Created on : Oct 6, 2025, 8:55:55 AM
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
  <title>Change Password</title>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
  <style>
    body {
      height: 100vh;
      margin: 0;
      display: flex;
      justify-content: center;
      align-items: center;
      background-image: url("images/industry.jpg");
      background-size: cover;       
      background-position: center;  
      background-repeat: no-repeat;
    }
    td{
    padding-bottom: 10px ;
}
    .my-container {
      background-color: rgba(255, 255, 255, 0.9);
      padding: 40px;
      border-radius: 10px;
      box-shadow: 0 4px 20px rgba(0,0,0,0.3);
      min-width: 500px;
    }
    .divider-horizontal {
      height: 2px;
      background-color: #ccc;
      margin: 20px 0;
      border-radius: 1px;
    }
    .save-btn {
  background-color: #F05D40; /* màu vàng */
  color: white; /* chữ trắng */
  border: none; 
  padding: 5px 16px;
  border-radius: 5px;
  cursor: pointer;
  font-weight: bold;
}
.button{
  margin-top: 10px ;
 
}
.button2{
  margin-top: 10px ;
 
}
  </style>
</head>
<body>

<div class="my-container">
  <div class="header-left">
    <h3>Change Password</h3>
    <p>Change password for better security.</p>
  </div>

  <div class="divider-horizontal"></div> 

  <form id="changePasswordForm" action="changePassword" method="Post" target="_blank">
    <div id="currentPasswordContainer">
      <input type="password" name="currentPassword" placeholder="Enter your current password" class="form-control mb-2" required>
      <button type="submit" class="save-btn button">Submit</button>
    </div>

  <div id="newPasswordContainer" style="display:none;">
  <input type="password" id="newPassword" name="newPassword" 
         placeholder="Enter new password" 
         class="form-control mb-2"
         oninput="checkPasswordInput('newPassword', 'passwordError')" />

  <p id="passwordError" style="color:red; margin-bottom:10px;"></p>

  <input type="password" id="renewPassword" name="renewPassword" 
         placeholder="Re-enter new password" 
         class="form-control mb-2">

  <button id="saveNewPassword" type="button" class="save-btn button2">Save New Password</button>
</div>
  </form>

  <div id="resultContainer" style="margin-top:10px;" class ="button2"></div>
</div>


<script src="js/passwordValidation.js"></script>
<script>
document.addEventListener("DOMContentLoaded", function() {
    // Xử lý check current password
    const changePasswordForm = document.getElementById("changePasswordForm");
    const currentPasswordContainer = document.getElementById("currentPasswordContainer");
    const newPasswordContainer = document.getElementById("newPasswordContainer");
    const resultContainer = document.getElementById("resultContainer");
    const saveNewPasswordBtn = document.getElementById("saveNewPassword");

    changePasswordForm.addEventListener("submit", function(e) {
        e.preventDefault();

        const currentPassword = document.querySelector('input[name="currentPassword"]').value;

        fetch('changePassword', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'currentPassword=' + encodeURIComponent(currentPassword)
        })
        .then(response => response.text())
        .then(data => {
            if (data === "ok") {
                currentPasswordContainer.style.display = "none";
                newPasswordContainer.style.display = "block";
                resultContainer.innerHTML = "<span style='color:green'>Current password correct!</span>";
            } else {
                resultContainer.innerHTML = "<span style='color:red'>" + data + "</span>";
            }
        })
        .catch(error => {
            console.error('Error:', error);
            resultContainer.innerHTML = "<span style='color:red'>Error occurred!</span>";
        });
    });

    // Xử lý lưu password mới
saveNewPasswordBtn.addEventListener("click", function() {
    const newPass = document.querySelector('input[name="newPassword"]').value;
    const renewPass = document.querySelector('input[name="renewPassword"]').value;

    const errorMessage = validatePassword(newPass);
    if (errorMessage) {
        resultContainer.innerHTML = "<span style='color:red'>" + errorMessage + "</span>";
        return;
    }

    if (newPass !== renewPass) {
        resultContainer.innerHTML = "<span style='color:red'>New passwords do not match!</span>";
        return;
    }

    fetch('changePassword', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'newPassword=' + encodeURIComponent(newPass) + '&renewPassword=' + encodeURIComponent(renewPass)
    })
    .then(response => response.text())
    .then(data => {
        resultContainer.innerHTML = "<span style='color:green'>" + data + "</span>";
        newPasswordContainer.style.display = "none";
    })
    .catch(error => {
        console.error('Error:', error);
        resultContainer.innerHTML = "<span style='color:red'>Error occurred!</span>";
    });
});
});
</script>
</body>
</html>