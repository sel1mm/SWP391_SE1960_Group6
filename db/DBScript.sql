
-- 1. Role & Account
--  Role
CREATE TABLE Role (
    roleId INT AUTO_INCREMENT PRIMARY KEY,
    roleName VARCHAR(50) NOT NULL UNIQUE -- Admin, Technician, Customer, CSS...
);

-- Account (dùng cho đăng nhập + thông tin cơ bản)
CREATE TABLE Account (
    accountId INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    passwordHash VARCHAR(255) NOT NULL,
    fullName VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20) UNIQUE,
    status VARCHAR(20) NOT NULL DEFAULT 'Active' 
        CHECK (status IN ('Active','Inactive')),
    createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    updatedAt DATETIME
);

-- AccountRole (1 account có thể có nhiều role)
CREATE TABLE AccountRole (
    accountId INT NOT NULL,
    roleId INT NOT NULL,
    PRIMARY KEY (accountId, roleId),
    FOREIGN KEY (accountId) REFERENCES Account(accountId),
    FOREIGN KEY (roleId) REFERENCES Role(roleId)
);

-- AccountProfile (profile chia làm 2 nhóm: user-editable và admin-only)
CREATE TABLE AccountProfile (
    profileId INT AUTO_INCREMENT PRIMARY KEY,
    accountId INT UNIQUE NOT NULL,

    -- Thông tin KH tự đổi được
    address VARCHAR(255),
    dateOfBirth DATE,
    avatarUrl VARCHAR(255),

    -- Thông tin nhạy cảm: chỉ admin/CSS có quyền đổi
    nationalId VARCHAR(50) UNIQUE,  -- CCCD/CMND
    verified BIT NOT NULL DEFAULT 0, -- 0: chưa xác thực, 1: đã xác thực

    extraData VARCHAR(255),
    FOREIGN KEY (accountId) REFERENCES Account(accountId)
);


-- 2. Contract & Equipment
-- Hợp đồng
CREATE TABLE Contract (
    contractId INT AUTO_INCREMENT PRIMARY KEY,
    customerId INT NOT NULL,
    contractDate DATE NOT NULL,                -- ngày ký hợp đồng
    contractType VARCHAR(50) NOT NULL,         -- Bảo hành / Bảo trì / Mua bán
    status VARCHAR(50) NOT NULL CHECK (status IN ('Active','Completed','Cancelled')),
    details VARCHAR(255),
    FOREIGN KEY (customerId) REFERENCES Account(accountId)
);

-- Thiết bị (không phụ thuộc trực tiếp vào hợp đồng)
CREATE TABLE Equipment (
    equipmentId INT AUTO_INCREMENT PRIMARY KEY,
    serialNumber VARCHAR(100) UNIQUE NOT NULL,
    model VARCHAR(100),
    description VARCHAR(255),
    installDate DATE,
    lastUpdatedBy INT NOT NULL,
    lastUpdatedDate DATE NOT NULL,
    FOREIGN KEY (lastUpdatedBy) REFERENCES Account(accountId)
);

-- Liên kết Hợp đồng - Thiết bị (nhiều-nhiều, quản lý thời hạn theo từng thiết bị)
CREATE TABLE ContractEquipment (
    contractEquipmentId INT AUTO_INCREMENT PRIMARY KEY,
    contractId INT NOT NULL,
    equipmentId INT NOT NULL,
    startDate DATE NOT NULL,          -- thời gian bắt đầu (bảo hành/bảo trì/thuê)
    endDate DATE,                     -- thời gian kết thúc cho thiết bị
    quantity INT NOT NULL DEFAULT 1 CHECK (quantity > 0),
    price DECIMAL(12,2),              -- giá áp cho thiết bị trong hợp đồng (nếu có)
    FOREIGN KEY (contractId) REFERENCES Contract(contractId),
    FOREIGN KEY (equipmentId) REFERENCES Equipment(equipmentId),
    UNIQUE (contractId, equipmentId)  -- 1 thiết bị chỉ xuất hiện 1 lần trong 1 hợp đồng
);

-- 3. Service Request & Work Flow
CREATE TABLE ServiceRequest (
    requestId INT AUTO_INCREMENT PRIMARY KEY,
    contractId INT NOT NULL,
    equipmentId INT NOT NULL,
    createdBy INT NOT NULL, -- Account (Customer)
    description VARCHAR(255),
    priorityLevel VARCHAR(20) NOT NULL DEFAULT 'Normal', -- Normal / High / Urgent
    requestDate DATE NOT NULL,
    status VARCHAR(50) NOT NULL, -- Pending / Approved / Rejected
    FOREIGN KEY (contractId) REFERENCES Contract(contractId),
    FOREIGN KEY (equipmentId) REFERENCES Equipment(equipmentId),
    FOREIGN KEY (createdBy) REFERENCES Account(accountId)
);

ALTER TABLE ServiceRequest
ADD requestType VARCHAR(20) NOT NULL DEFAULT 'Service'; -- Service / Warranty

CREATE TABLE RequestApproval (
    approvalId INT AUTO_INCREMENT PRIMARY KEY,
    requestId INT NOT NULL UNIQUE,
    approvedBy INT NOT NULL, -- Account (Technical Manager)
    approvalDate DATE NOT NULL,
    decision VARCHAR(20) NOT NULL, -- Approved / Rejected
    note VARCHAR(255),
    FOREIGN KEY (requestId) REFERENCES ServiceRequest(requestId),
    FOREIGN KEY (approvedBy) REFERENCES Account(accountId)
);

CREATE TABLE Priority (
    priorityId INT AUTO_INCREMENT PRIMARY KEY,
    priorityName VARCHAR(50) NOT NULL,   -- Normal / High / Urgent
    priorityLevel INT NOT NULL,          -- 1=Thấp, 2=Trung bình, 3=Cao...
    description VARCHAR(255)
);

CREATE TABLE MaintenanceSchedule (
    scheduleId INT AUTO_INCREMENT PRIMARY KEY,
    requestId INT, -- có thể NULL nếu là bảo trì định kỳ
    contractId INT, -- dùng cho lịch định kỳ
    equipmentId INT, -- dùng cho lịch định kỳ
    assignedTo INT NOT NULL, -- Technician
    scheduledDate DATE NOT NULL,
    scheduleType VARCHAR(20) NOT NULL, -- Request / Periodic
    recurrenceRule VARCHAR(100), -- ví dụ: MONTHLY, YEARLY (chỉ áp dụng cho Periodic)
    status VARCHAR(50) NOT NULL, -- Scheduled / Completed / Missed
    priorityId INT NOT NULL, -- liên kết sang bảng Priority
    FOREIGN KEY (requestId) REFERENCES ServiceRequest(requestId),
    FOREIGN KEY (contractId) REFERENCES Contract(contractId),
    FOREIGN KEY (equipmentId) REFERENCES Equipment(equipmentId),
    FOREIGN KEY (assignedTo) REFERENCES Account(accountId),
    FOREIGN KEY (priorityId) REFERENCES Priority(priorityId)
);



CREATE TABLE WorkTask (
    taskId INT AUTO_INCREMENT PRIMARY KEY,
    requestId INT,            -- liên kết nếu phát sinh từ ServiceRequest
    scheduleId INT,           -- liên kết nếu phát sinh từ MaintenanceSchedule
    technicianId INT NOT NULL, -- ai được giao
    taskType VARCHAR(50) NOT NULL, -- Request / Scheduled
    taskDetails VARCHAR(255),
    startDate DATE,
    endDate DATE,
    status VARCHAR(50) NOT NULL, -- Assigned / In Progress / Completed / Failed
    FOREIGN KEY (requestId) REFERENCES ServiceRequest(requestId),
    FOREIGN KEY (scheduleId) REFERENCES MaintenanceSchedule(scheduleId),
    FOREIGN KEY (technicianId) REFERENCES Account(accountId)
);

CREATE TABLE RepairResult (
    resultId INT AUTO_INCREMENT PRIMARY KEY,
    taskId INT NOT NULL,
    details VARCHAR(255),
    completionDate DATE,
    technicianId INT NOT NULL,
    status VARCHAR(50) NOT NULL, -- Completed / Failed / Pending verification
    FOREIGN KEY (taskId) REFERENCES WorkTask(taskId),
    FOREIGN KEY (technicianId) REFERENCES Account(accountId)
);

-- 4. Inventory
CREATE TABLE Part (
    partId INT AUTO_INCREMENT PRIMARY KEY,
    partName VARCHAR(100) NOT NULL,
    description VARCHAR(255),
    unitPrice DECIMAL(12,2),
    lastUpdatedBy INT NOT NULL,
    lastUpdatedDate DATE NOT NULL,
    FOREIGN KEY (lastUpdatedBy) REFERENCES Account(accountId)
);

-- Bảng chi tiết part (serial number)
CREATE TABLE PartDetail (
    partDetailId INT AUTO_INCREMENT PRIMARY KEY,
    partId INT NOT NULL,
    serialNumber VARCHAR(100) UNIQUE NOT NULL, -- mỗi serial number duy nhất
    status VARCHAR(20) NOT NULL CHECK (status IN ('Available','InUse','Faulty','Retired')),
    location VARCHAR(255), -- vị trí vật lý nếu cần
    lastUpdatedBy INT NOT NULL,
    lastUpdatedDate DATE NOT NULL,
    FOREIGN KEY (partId) REFERENCES Part(partId),
    FOREIGN KEY (lastUpdatedBy) REFERENCES Account(accountId)
);

-- Mỗi Part chỉ có 1 dòng tổng tồn kho
CREATE TABLE Inventory (
    inventoryId INT AUTO_INCREMENT PRIMARY KEY,
    partId INT NOT NULL UNIQUE, -- 1 part = 1 dòng tồn kho tổng
    quantity INT NOT NULL CHECK (quantity >= 0),
    lastUpdatedBy INT NOT NULL,
    lastUpdatedDate DATE NOT NULL,
    FOREIGN KEY (partId) REFERENCES Part(partId),
    FOREIGN KEY (lastUpdatedBy) REFERENCES Account(accountId)
);

-- Lịch sử nhập xuất
CREATE TABLE StockTransaction (
    transactionId INT AUTO_INCREMENT PRIMARY KEY,
    partId INT NOT NULL,
    transactionType VARCHAR(20) NOT NULL CHECK (transactionType IN ('Import','Export')), 
    quantity INT NOT NULL CHECK (quantity > 0),
    transactionDate DATE NOT NULL,
    performedBy INT NOT NULL,
    FOREIGN KEY (partId) REFERENCES Part(partId),
    FOREIGN KEY (performedBy) REFERENCES Account(accountId)
);

-- Yêu cầu cấp phát part cho task
CREATE TABLE PartsRequest (
    partsRequestId INT AUTO_INCREMENT PRIMARY KEY,
    taskId INT NOT NULL, -- tham chiếu WorkTask
    requestDate DATE NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('Pending','Approved','Rejected','Completed')), 
    handledBy INT,
    handledDate DATE,
    FOREIGN KEY (taskId) REFERENCES WorkTask(taskId),
    FOREIGN KEY (handledBy) REFERENCES Account(accountId)
);

-- Chi tiết yêu cầu từng loại part
CREATE TABLE PartsRequestDetail (
    requestDetailId INT AUTO_INCREMENT PRIMARY KEY,
    partsRequestId INT NOT NULL,
    partId INT NOT NULL,
    quantityRequested INT NOT NULL CHECK (quantityRequested > 0),
    quantityIssued INT CHECK (quantityIssued >= 0),
    FOREIGN KEY (partsRequestId) REFERENCES PartsRequest(partsRequestId),
    FOREIGN KEY (partId) REFERENCES Part(partId)
);


CREATE TABLE Invoice (
    invoiceId INT AUTO_INCREMENT PRIMARY KEY,
    contractId INT NOT NULL,
    issueDate DATE NOT NULL,
    dueDate DATE,
    totalAmount DECIMAL(12,2) NOT NULL,
    status VARCHAR(50) NOT NULL,
    FOREIGN KEY (contractId) REFERENCES Contract(contractId)
);

CREATE TABLE InvoiceDetail (
    invoiceDetailId INT AUTO_INCREMENT PRIMARY KEY,
    invoiceId INT NOT NULL,
    description VARCHAR(255),
    amount DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (invoiceId) REFERENCES Invoice(invoiceId)
);

CREATE TABLE RepairReport (
    reportId INT AUTO_INCREMENT PRIMARY KEY,
    requestId INT NOT NULL,
    technicianId INT,
    details VARCHAR(255),
    diagnosis VARCHAR(255),
    estimatedCost DECIMAL(12,2),
    quotationStatus VARCHAR(50) DEFAULT 'Pending', -- Pending / Approved / Rejected
    repairDate DATE,
    invoiceDetailId INT, -- Liên kết chi phí thực tế sang InvoiceDetail
    FOREIGN KEY (requestId) REFERENCES ServiceRequest(requestId),
    FOREIGN KEY (technicianId) REFERENCES Account(accountId),
    FOREIGN KEY (invoiceDetailId) REFERENCES InvoiceDetail(invoiceDetailId)
);


-- 5. Payment & Finance
CREATE TABLE Payment (
    paymentId INT AUTO_INCREMENT PRIMARY KEY,
    invoiceId INT UNIQUE,  -- mỗi hóa đơn chỉ có 1 payment
    amount DECIMAL(12,2) NOT NULL,
    paymentDate DATE,
    status VARCHAR(50) NOT NULL, -- Pending / Completed / Failed
    FOREIGN KEY (invoiceId) REFERENCES Invoice(invoiceId)
);


CREATE TABLE PaymentTransaction (
    transactionId INT AUTO_INCREMENT PRIMARY KEY,
    paymentId INT NOT NULL,
    accountId INT NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    method VARCHAR(50) NOT NULL, -- Cash, Bank, VNPAY
    transactionDate DATE NOT NULL,
    status VARCHAR(50) NOT NULL,
    FOREIGN KEY (paymentId) REFERENCES Payment(paymentId),
    FOREIGN KEY (accountId) REFERENCES Account(accountId)
);

CREATE TABLE VnpayTransaction (
    vnpayId INT AUTO_INCREMENT PRIMARY KEY,
    transactionId INT NOT NULL,
    vnpayRef VARCHAR(100) NOT NULL,
    responseCode VARCHAR(10),
    FOREIGN KEY (transactionId) REFERENCES PaymentTransaction(transactionId)
);

-- 6. Support & Communication
CREATE TABLE SupportTicket (
    ticketId INT AUTO_INCREMENT PRIMARY KEY,
    customerId INT NOT NULL,
    supportStaffId INT NOT NULL,
    contractId INT,
    equipmentId INT,
    description VARCHAR(255),
    response VARCHAR(255),
    createdDate DATE NOT NULL,
    closedDate DATE,
    FOREIGN KEY (customerId) REFERENCES Account(accountId),
    FOREIGN KEY (supportStaffId) REFERENCES Account(accountId),
    FOREIGN KEY (contractId) REFERENCES Contract(contractId),
    FOREIGN KEY (equipmentId) REFERENCES Equipment(equipmentId)
);

CREATE TABLE Notification (
    notificationId INT AUTO_INCREMENT PRIMARY KEY,
    accountId INT NOT NULL, -- ai nhận thông báo
    notificationType VARCHAR(50) NOT NULL CHECK (notificationType IN ('Warranty','Inventory','System','Other')),
    contractEquipmentId INT, -- optional: liên kết đến thiết bị trong hợp đồng
    message VARCHAR(255) NOT NULL,
createdAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL CHECK (status IN ('Unread','Read','Sent')),
    FOREIGN KEY (accountId) REFERENCES Account(accountId),
    FOREIGN KEY (contractEquipmentId) REFERENCES ContractEquipment(contractEquipmentId)
);

-- 1. Thêm role Admin (nếu chưa có)
INSERT INTO Role (roleId, roleName)
VALUES (1, 'Admin')
ON DUPLICATE KEY UPDATE roleName='Admin';

-- 2. Thêm role Customer
INSERT INTO Role (roleId, roleName)
VALUES (2, 'Customer')
ON DUPLICATE KEY UPDATE roleName='Customer';

-- 3. Thêm role Customer Support Staff
INSERT INTO Role (roleId, roleName)
VALUES (3, 'Customer Support Staff')
ON DUPLICATE KEY UPDATE roleName='Customer Support Staff';

-- 4. Thêm role Technical Manager
INSERT INTO Role (roleId, roleName)
VALUES (4, 'Technical Manager')
ON DUPLICATE KEY UPDATE roleName='Technical Manager';

-- 5. Thêm role Storekeeper
INSERT INTO Role (roleId, roleName)
VALUES (5, 'Storekeeper')
ON DUPLICATE KEY UPDATE roleName='Storekeeper';

-- 6. Thêm role Technician
INSERT INTO Role (roleId, roleName)
VALUES (6, 'Technician')
ON DUPLICATE KEY UPDATE roleName='Technician';

-- 2. Thêm tài khoản admin
INSERT INTO Account (username, passwordHash, fullName, email, phone, status, createdAt)
VALUES (
    'admin', 
    '$2a$12$rmfB.fZeS1UQVq/JiejzE.QYVzwp5HyJOnPJ3JaLRmsnYzF80IUuq', -- hash của "123456"
    'System Administrator', 
    'leanhvuvlhg@gmail.com', 
    '0123456789', 
    'Active', 
    NOW()
);

-- 3. Gán role Admin cho account vừa tạo
INSERT INTO AccountRole (accountId, roleId)
VALUES (LAST_INSERT_ID(), 1);

-- 4. Thêm tài khoản technician test
INSERT INTO Account (username, passwordHash, fullName, email, phone, status, createdAt)
VALUES (
    'technician', 
    '$2a$12$rmfB.fZeS1UQVq/JiejzE.QYVzwp5HyJOnPJ3JaLRmsnYzF80IUuq', -- hash của "123456"
    'Test Technician', 
    'technician@test.com', 
    '0987654321', 
    'Active', 
    NOW()
);

-- 5. Gán role Technician cho account vừa tạo
INSERT INTO AccountRole (accountId, roleId)
VALUES (LAST_INSERT_ID(), 6);




