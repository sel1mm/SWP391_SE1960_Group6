
<%-- 
    Document   : customer
    Created on : Oct 10, 2025, 12:30:40 AM
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
           
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
        
        <title>CRM System - Quản lý Khách hàng Chuyên nghiệp</title>
        <style>
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }
            
            body {
                font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
                background: #f8f9fc;
                color: #333;
                line-height: 1.6;
            }
            
            /* Navigation Bar */
            .navbar {
                
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                padding: 0;
                box-shadow: 0 4px 20px rgba(0,0,0,0.1);
                position: sticky;
                top: 0;
                z-index: 1000;
            }
            
            .nav-container {
                max-width: 1200px;
                margin: 0 auto;
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: 1rem 2rem;
            }
           
            
            .logo {
                color: white;
                font-size: 28px;
                font-weight: bold;
                display: flex;
                align-items: center;
                gap: 10px;
            }
            
            .nav-links {
                display: flex;
                gap: 30px;
                align-items: center;
            }
            
            .nav-links a {
                color: white;
                text-decoration: none;
                font-weight: 500;
                font-size: 15px;
                transition: all 0.3s;
                padding: 8px 16px;
                border-radius: 6px;
            }
            
            .nav-links a:hover {
                background: rgba(255,255,255,0.2);
            }
            
            .btn-login {
                background: transparent;
                color: white;
                padding: 8px 16px;
                border-radius: 6px;
                font-weight: 500;
            }

            /* Slide bar dọc */
              .sidebar .logo {
            font-size: 24px;
            font-weight: bold;
            text-align: center;
            margin-bottom: 40px;
        }

        .sidebar a {
            color: white;
            text-decoration: none;
            padding: 15px 20px;
            font-size: 16px;
            display: flex;
            align-items: center;
            gap: 10px;
            transition: background 0.3s;
        }
.sidebar{
    max-width: 250px;
    height : 610px ;
    margin-top: 77px ;
    position: fixed ;

}

        .sidebar a:hover {
            background: rgba(255,255,255,0.2);
        }

        .sidebar a i {
            min-width: 20px;
            text-align: center;
        }
              .footer {
                background: #2d3748;
                color: white;
                padding: 60px 20px 30px;
            }
            
            .footer-content {
                max-width: 1200px;
                margin: 0 auto;
                display: grid;
                grid-template-columns: repeat(3, 1fr);
                gap: 40px;
                margin-bottom: 40px;
            }
            
            .footer-section h3 {
                font-size: 18px;
                margin-bottom: 20px;
                font-weight: 600;
            }
            
            .footer-section ul {
                list-style: none;
            }
            
            .footer-section ul li {
                margin-bottom: 12px;
            }
            
            .footer-section a {
                color: #cbd5e0;
                text-decoration: none;
                transition: all 0.3s;
            }
            
            .footer-section a:hover {
                color: white;
                padding-left: 5px;
            }
            
            .footer-bottom {
                text-align: center;
                padding-top: 30px;
                border-top: 1px solid #4a5568;
                color: #cbd5e0;
            }
            .kpi-container {
              
      display: grid;
      grid-template-columns: 200px 200px 200px 200px ;
      grid-template-rows: 150px px ;
      gap: 15px;
      
      margin-top: 30px ;
      margin-left: 140px ;
    }

    .kpi-card {
      background: #fff;
      padding: 20px;
      border-radius: 12px;
      box-shadow: 0 2px 8px rgba(0,0,0,0.08);
      text-align: left;
    }

    .kpi-card h3 {
      font-size: 15px;
      color: #666;
      margin-bottom: 8px;
    }

    .kpi-card p {
      font-size: 22px;
      font-weight: bold;
      margin: 0;
      color: #2d4ef5;
    }
     .container {
  display: flex;
  margin-top: 60px; /* đẩy xuống dưới navbar */
}
.content {
  margin-left: 220px; /* chừa khoảng cho sidebar */
  padding: 20px;
  background: #f4f6f8;
  min-height: calc(100vh - 60px);
}       
.content h2{
    margin-left: 70px ;
    margin-top: -70px;
    color: #666 ;
}   
.status-container{
  
  display: flex ;
  justify-content: space-between;
  margin-top: 50px ;
}

/* .status-container-left{
  margin-left: 30px ;
  margin-top: 30px ;
      background: #fff;
      padding: 20px;
      border-radius: 12px;
      box-shadow: 0 2px 8px rgba(0,0,0,0.08);
      width: 400px ;
      height: 250px;
}  */
/* .status-container-right{
  margin-left: 30px ;
  margin-top: 30px ;
      background: #fff;
      padding: 20px;
      border-radius: 12px;
      box-shadow: 0 2px 8px rgba(0,0,0,0.08);
      width: 400px ;
      height: 250px;
}            */
.status-container p{
  
   font-size: 22px;
      font-weight: bold;
      margin: 0;
      color: #666 ; 

}
#inventoryChart {
  width: 200px !important;
  height: 200px !important;
}
#inventoryChart2 {
  width: 200px !important;
  height: 200px !important;
}
    .card {
      margin-top: 20px ;
      margin-left: 55px;
      background: white;
      padding: 20px 40px;
      border-radius: 15px;
      box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
      display: flex;
      align-items: center ;
      gap: 30px;
      width: 490px ;
    }

    .legend {
      display: flex;
      flex-direction: column;
      gap: 10px;
    }

    .legend-item {
      display: flex;
      align-items: center;
      gap: 8px;
      font-size: 14px;
    }

    .color-dot {
      width: 12px;
      height: 12px;
      border-radius: 50%;
      display: inline-block;
    }

    .label-value {
      font-weight: bold;
      font-size: 16px;
    }
    .list-container{
      padding-right: 20px ;
      margin-left: 55px;
      
      display: grid;
      grid-template-columns:  1fr 1fr ;
      margin-top: 40px;
     
  gap: 30px;
    }
    .right-list p {
      color: #666;
      font-weight: bold;
      font-size: 20px ;
    }
    .left-list p{
      color: #666;
      font-weight: bold;
      font-size: 20px ;
    }
    .status-container p{
      margin-left: 55px ;
    }
    .list-container p{
      
      margin-top: 20px ;
    }
   
    /* Áp dụng cho cả hai box */
.left-list, .right-list {
  
  background: #fff;
  padding: 20px;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
}
.right-list{
  margin-left: 20px;
  margin-right: -20px;
}

/* Đưa 2 p ra 2 bên */
.left-list p.title, 
.right-list p.title {
  float: left;
  font-weight: bold;
  font-size: 18px;
  color: #666;
}

.left-list p.more,
.right-list p.more {
  float: right;
  font-size: 14px;
  color: green;
  cursor: pointer;
}

/* Clear float để container bao lại nội dung */
.left-list::after,
.right-list::after {
  content: "";
  display: block;
  clear: both;
}
.list-container table{
   width: 100%;
  margin-top: 30px ;
 
  
}
.list-container p{
  margin-bottom: 10px ;
}
table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 15px;
  background-color: #fff;
}

th, td {
  border: 1px solid #ddd;
  padding: 10px 15px;
  text-align: left;
}

th {
  background-color: #007bff;
  color: white;
}

tr:nth-child(even) {
  background-color: #f9f9f9;
}

tr:hover {
  background-color: #e9f3ff;
}

        </style>
    </head>
    <body>
        <nav class="navbar">
<div class="nav-container">
                <div class="logo">CRM System</div>
                <div class="nav-links">
                    <a href="#"><i class="fas fa-envelope"></i> Tin nhắn</a>
        <a href="#"><i class="fas fa-bell"></i> Thông báo</a>
                   
                    <a href="#contact">Avatar</a>
                    <a href="login" class="btn-login">Xin chào ${sessionScope.username}</a>
                </div>
            </div>
        </nav>
        <<form action="storekeeper" method="POST">
            <div class="container">
            <div class="sidebar">
                <div class="sidebar navbar nav-container2">
         <a href="storekeeper"><i class="fas fa-user-cog"></i><span>Trang chủ</span></a>
        <a href="manageProfile"><i class="fas fa-tachometer-alt" ></i><span>Quản lý người dùng</span></a>
        <a href="#"><i class="fas fa-chart-line"></i><span>Thống kê</span></a>
        <a href="numberInventory"><i class="fas fa-boxes"></i><span>Số lượng tồn kho</span></a>
        <a href="numberPart"><i class="fas fa-list"></i><span>Danh sách hàng tồn kho</span></a>
        <a href="transactionHistory"><i class="fas fa-history"></i><span>Lịch sử giao dịch</span></a>
        <a href="partRequest"><i class="fas fa-tools"></i><span>Yêu cầu thiết bị</span></a>
        <a href="#"><i class="fas fa-file-invoice"></i><span>Danh sách hóa đơn</span></a>
        <a href="#"><i class="fas fa-wrench"></i><span>Báo cáo sửa chữa</span></a>
        <a href="partDetail"><i class="fas fa-truck-loading"></i><span>Chi tiết thiệt bị</span></a>
    </div>
            </div>
            <div class="content">
            <!--Một số KPI của storekeeper-->
           <section>
                 <h2>Inventory Management KPIs</h2>
            
            <div class="kpi-container">
    <div class="kpi-card">
      <h3>Trung bình  thời gian hoàn thành sửa chữa</h3>
      <p>1.2</p>
    </div>
    <div class="kpi-card">
      <h3>Tỉ lệ sử dụng vật dụng trên tổng tồn kho </h3>
      <p>$341,678</p>
    </div>
    <div class="kpi-card">
      <h3>Số lượng công việc trễ hạn</h3>
      <p>$412,343</p>
    </div>
    <div class="kpi-card">
      <h3>Tỉ lệ thiết bị được cấp đúng yêu cầu</h3>
      <p>95.5%</p>
    </div>
    <div class="kpi-card">
      <h3>Số báo cáo chờ xác nhận</h3>
      <p>16.5</p>
    </div>
    <div class="kpi-card">
      <h3>Tổng số lượng thiết bị trong kho </h3>
      <p>14.2</p>
    </div>
    <div class="kpi-card">
      <h3>% công việc xong đúng kế hoạch</h3>
      <p>94.5%</p>
    </div>
    <div class="kpi-card">
      <h3>Số lượng vật tư sắp hết</h3>
      <p>2.3%</p>
    </div>
  </div>
           </section>
<!--Thống kê-->
<section>
  <div class="status-container">
  
  <div >
    <p>Thiết bị</p>
     <div class="card">
    <canvas id="inventoryChart" width="100" height="100"></canvas>

    <div class="legend">
      <div class="legend-item"><span class="color-dot" style="background:#00b894;"></span> In Stock Items <span class="label-value">134</span></div>
      <div class="legend-item"><span class="color-dot" style="background:#6c5ce7;"></span> Out of Stock Items <span class="label-value">7</span></div>
      <div class="legend-item"><span class="color-dot" style="background:#fdcb6e;"></span> Low Stock Items <span class="label-value">3</span></div>
      <div class="legend-item"><span class="color-dot" style="background:#d63031;"></span> Dead Stock Items <span class="label-value">1</span></div>
    </div>
  </div>
  </div>
  
  <div >
    <p>Yêu cầu</p>
     <div class="card">
    <!-- Biểu đồ hình tròn -->
    <canvas id="inventoryChart2" width="100" height="100"></canvas>

    <!-- Phần legend -->
    <div class="legend">
      <div class="legend-item"><span class="color-dot" style="background:#f0ad4e;"></span> Pending Requests <span class="label-value">12</span></div>
      <div class="legend-item"><span class="color-dot" style="background:#0275d8;"></span> Approved Requests <span class="label-value">24</span></div>
      <div class="legend-item"><span class="color-dot" style="background:#d9534f;"></span> Rejected Requests <span class="label-value">5</span></div>
      <div class="legend-item"><span class="color-dot" style="background:#5cb85c;"></span> Completed Requests <span class="label-value">18</span></div>
    </div>
  </div>

  </div>
</div>
</section>
<section>
  <div class="list-container">
   <div class="left-list">
    <p class="title">Thiết bị được sử dụng nhiều</p>
    <p class="more">Xem thêm <i class="fa-solid fa-arrow-right" style="color: #007bff;"></i></p>
    <table border="1">
                <thead>
                    <tr>
                        <th>InventoryId</th>
                        <th>PartId</th>
                        <th>PartName</th>
                        <th>Quantity</th>
                        
                        
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                    </tr>
                </tbody>
            </table>
   </div>
   <div class="right-list">
    <p class="title">Thiết bị sắp hết </p>
    <p class="more">Xem thêm <i class="fa-solid fa-arrow-right" style="color: #007bff;"></i></p>
      <table border="1">
                <thead>
                    <tr>
                        <th>PartID</th>
                        <th>PartName</th>
                        <th>Description</th>
                        <th>Unit Price</th>
                        
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                    </tr>
                </tbody>
            </table>
   </div>
  </div>
</section>
  </div>
  
        </div>
        </form>

        <!-- Navigation -->
   
<script>
    const ctx = document.getElementById('inventoryChart').getContext('2d');
    new Chart(ctx, {  
      type: 'doughnut',
      data: {
        labels: ['In Stock', 'Out of Stock', 'Low Stock', 'Dead Stock'],
        datasets: [{
          data: [134, 7, 3, 1],
          backgroundColor: ['#00b894', '#6c5ce7', '#fdcb6e', '#d63031'],
          borderWidth: 0
        }]
      },
      options: {
        cutout: '70%',
        plugins: { legend: { display: false } }
      }
    });
     const ltx = document.getElementById('inventoryChart2').getContext('2d');
    new Chart(ltx, {
      type: 'doughnut',
      data: {
        labels: ['Pending', 'Approved', 'Rejected', 'Completed'],
        datasets: [{
          data: [12, 24, 5, 18], // <-- Thay số liệu thật ở đây
          backgroundColor: ['#f0ad4e', '#0275d8', '#d9534f', '#5cb85c'],
          borderWidth: 0
        }]
      },
      options: {
        cutout: '70%',
        plugins: { legend: { display: false } }
      }
    });
  </script>
  

    </body>
</html>
