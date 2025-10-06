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

  <form id="changePasswordForm">
    <div id="currentPasswordContainer">
      <input type="password" name="currentPassword" placeholder="Enter your current password" class="form-control mb-2" required>
      <button type="submit" class="save-btn button">Submit</button>
    </div>

    <div id="newPasswordContainer" style="display:none;">
      <input type="password" name="newPassword" placeholder="Enter new password" class="form-control mb-2">
      <input type="password" name="renewPassword" placeholder="Re-enter new password" class="form-control mb-2">
      <button id="saveNewPassword" type="button" class="save-btn button2" >Save New Password</button>
    </div>
  </form>

  <div id="resultContainer" style="margin-top:10px;" class ="button2"></div>
</div>

<script>
document.getElementById("changePasswordForm").addEventListener("submit", function(e) {
  e.preventDefault();
  const currentPassword = document.querySelector('input[name="currentPassword"]').value;

  if (currentPassword === "123456") {
    document.getElementById("currentPasswordContainer").style.display = "none";
    document.getElementById("newPasswordContainer").style.display = "block";
    document.getElementById("resultContainer").innerHTML = "<span style='color:green'>Current password correct!</span>";
  } else {
    document.getElementById("resultContainer").innerHTML = "<span style='color:red'>Current password incorrect!</span>";
  }
});

document.getElementById("saveNewPassword").addEventListener("click", function() {
  const newPass = document.querySelector('input[name="newPassword"]').value;
  const renewPass = document.querySelector('input[name="renewPassword"]').value;

  if (newPass !== renewPass) {
    alert("New passwords do not match!");
    return;
  }

  document.getElementById("resultContainer").innerHTML = "<span style='color:green'>Password changed successfully!</span>";
  document.getElementById("newPasswordContainer").style.display = "none";
});
</script>

</body>
</html>