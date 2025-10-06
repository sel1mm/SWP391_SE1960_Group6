<%-- 
    Document   : changeInformation
    Created on : Oct 6, 2025, 4:24:54 PM
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>

<!--
Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Html.html to edit this template
-->
<html>
  <head>
    <title>TODO supply a title</title>
    <style>
        body {
    height: 100vh;               /* chiều cao toàn màn hình */
    margin: 0;                   /* xóa margin mặc định */
    
    display: flex;               /* bật flexbox */
    justify-content: center;     /* căn giữa ngang */
    align-items: center;         /* căn giữa dọc */
    background-image: url("images/industry.jpg");
    background-size: cover;       
    background-position: center;  
    background-repeat: no-repeat;
}
.my-container {
    background-color: rgba(255, 255, 255, 0.9); /* nền trắng hơi trong suốt */
    padding: 40px;                              /* khoảng cách bên trong */
    border-radius: 10px;                        /* bo góc */
    box-shadow: 0 4px 20px rgba(0,0,0,0.3);    /* đổ bóng nổi bật */
    min-width: 1000px;                           /* chiều rộng tối thiểu */
}
.divider-horizontal {
    height: 2px;                  /* độ dày đường phân cách */
    background-color: #ccc;        /* màu xám nhạt */
    margin: 20px 0;                /* khoảng cách trên/dưới */
    border-radius: 1px;            /* bo nhẹ nếu muốn */
}

/* Flexbox chia 2 phần ngang */
.row-content {
    display: flex;
    gap: 20px; /* khoảng cách giữa 2 phần */
}

/* Bên trái */
.left-side {
    flex: 1;
    padding-right: 20px;
    border-right: 2px solid #ccc; /* đường dọc phân cách */
}

/* Bên phải */
.right-side {
    flex: 1;
    padding-left: 20px;
}
.avatar-preview {
    
    width: 150px;
    height: 150px;
    border-radius: 50%; /* cắt tròn */
    overflow: hidden;
    border: 2px solid #ccc;
    background-color: #eee; /* nền mặc định */
    margin-left:130px ;
    margin-top: 20px ;
}
.avatar-dropzone {
    margin-top: 20px;
    border: 2px dashed #aaa;
    border-radius: 10px;
    height: 150px;
    display: flex;
    justify-content: center;
    align-items: center;
    text-align: center;
    color: #555;
    cursor: pointer;
    position: relative;
}
.header-right {
    text-align: right;   /* căn chữ sang phải */
    margin-bottom: 10px; /* khoảng cách với divider */
}
.right-side .change-avatar {
    margin-top: 0;       /* không cách trên */
    margin-bottom: 10px; /* cách divider */
    text-align: left;    /* căn chữ sang trái trong cột phải */
}
.header-row {
    display: flex;
    justify-content: space-between; /* chia trái - phải */
    align-items: flex-start;       /* căn đầu hàng */
    width: 100%;
    margin-bottom: 20px;
}

.header-left h3, .header-left p {
    margin: 0;
}

.header-right h4 {
    margin: 0;
    text-align: right; /* chữ căn sang phải */
}
.text{
    margin-left:100px ;
    margin-top: 20px ;
}
.save-btn {
  background-color: #F05D40; /* màu vàng */
  color: white; /* chữ trắng */
  border: none; 
  padding: 8px 16px;
  border-radius: 5px;
  cursor: pointer;
  font-weight: bold;
}

.save-btn:hover {
  background-color: #F05D40; /* vàng đậm khi hover */
}
.text2{
    margin-top: -10px ;
    margin-left : 120px ;
}
.avatar-button{
    margin-top: 20px ;
    margin-left: 128px ;
}
.button2 input{
    margin-left: 100px ;
}
td{
    padding-bottom: 10px ;
}
    </style>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link rel="stylesheet" href="CSS/newcss.css" />
    <link
      href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
      rel="stylesheet"
    />
  </head>
  <body>
    <form action="manageProfile" method="POST">
      <div class="my-container">
        <div class="header-left">
          <h3>My Profile</h3>
          <p>User management to protect account</p>
        </div>

        <div class="divider-horizontal"></div>

        <div class="row-content">
          <!-- Phần bên trái -->
          <div class="left-side">
            <table>
              <tr>
                <td class="ps-5  py-2">Email:</td>
                <td class="ps-2">
                 <input type = "text" placeholder="Enter your new email" class="form-control">
                </td>
              </tr>
              <tr>
                <td class="ps-5  py-2">Address:</td>
                <td class="ps-2">
                  <input type = "text" placeholder="Enter your address" class="form-control">

                </td>
              </tr>
              

              <tr>
                <td class="ps-5  py-2">NationalID:</td>

                <td class="ps-2">
                <input type = "text" placeholder="Enter your new nationalID" class="form-control">
                </td>
              </tr>

              <tr>
                <td class="ps-5  py-2">DateOfBirth:</td>

                <td class="ps-2">
                    <input type = "text" placeholder="Enter your new DoB" class="form-control">
                </td>
              </tr>

              <tr>
                
               
                 <td class="ps-2 py-2 button2 " colspan="2">
                  <input
                    type="submit"
                    value="Submit change"
                    class="save-btn"
                  />
                </td>
              
              </tr>
            </table>
          </div>

          <!-- Phần bên phải -->

          <div class="right-side">
            <div class="avatar-preview"></div>
            <div class="ps-2 py-2 avatar-button ">
                <td >
                  <input
                    type="submit"
                    value="Change avatar"
                    class="save-btn"
                  />
                </td>
            </div>
          </div>
        </div>
      </div>
    </form>
  </body>
</html>
