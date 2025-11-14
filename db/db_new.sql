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
    contractId INT NULL,
    equipmentId INT NULL,
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


-- ====================================================================
-- 1. TECHNICIAN SKILLS AND SPECIALIZATIONS
-- ====================================================================
-- Purpose: Support UC-06 requirement to assign work based on technician skills
-- Allows tracking of what each technician is qualified to work on

CREATE TABLE TechnicianSkill (
    skillId INT AUTO_INCREMENT PRIMARY KEY,
    skillName VARCHAR(100) NOT NULL UNIQUE, -- e.g., 'Electrical', 'HVAC', 'Plumbing', 'IT Systems'
    description VARCHAR(255),
    category VARCHAR(50), -- e.g., 'Hardware', 'Software', 'Mechanical'
    createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    updatedAt DATETIME
);

CREATE TABLE TechnicianSkillAssignment (
    assignmentId INT AUTO_INCREMENT PRIMARY KEY,
    technicianId INT NOT NULL,
    skillId INT NOT NULL,
    proficiencyLevel VARCHAR(20) NOT NULL CHECK (proficiencyLevel IN ('Beginner', 'Intermediate', 'Advanced', 'Expert')),
    certificationDate DATE, -- when they were certified in this skill
    expiryDate DATE, -- for skills requiring periodic recertification
    isActive BIT NOT NULL DEFAULT 1, -- allows deactivating expired skills
    FOREIGN KEY (technicianId) REFERENCES Account(accountId),
    FOREIGN KEY (skillId) REFERENCES TechnicianSkill(skillId),
    UNIQUE (technicianId, skillId)
);

-- Index for faster technician skill lookups when assigning work
CREATE INDEX idx_technician_skill_active ON TechnicianSkillAssignment(technicianId, isActive);
CREATE INDEX idx_skill_proficiency ON TechnicianSkillAssignment(skillId, proficiencyLevel);

-- ====================================================================
-- 2. TECHNICIAN WORKLOAD TRACKING
-- ====================================================================
-- Purpose: Support UC-06 requirement to assign based on workload
-- Tracks current capacity and availability of technicians

CREATE TABLE TechnicianWorkload (
    workloadId INT AUTO_INCREMENT PRIMARY KEY,
    technicianId INT NOT NULL UNIQUE,
    maxConcurrentTasks INT NOT NULL DEFAULT 5, -- maximum tasks they can handle at once
    currentActiveTasks INT NOT NULL DEFAULT 0, -- current number of active tasks
    totalCompletedTasks INT NOT NULL DEFAULT 0, -- historical count
    averageCompletionTime DECIMAL(10,2), -- in hours, helps estimate availability
    lastAssignedDate DATETIME, -- when they last got a task
    lastUpdated DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (technicianId) REFERENCES Account(accountId)
);

-- Index for finding available technicians
CREATE INDEX idx_technician_availability ON TechnicianWorkload(currentActiveTasks, maxConcurrentTasks);

-- ====================================================================
-- 3. TECHNICIAN AVAILABILITY SCHEDULE
-- ====================================================================
-- Purpose: Track when technicians are available for work assignment
-- Supports UC-06 requirement for "available technicians"

CREATE TABLE TechnicianAvailability (
    availabilityId INT AUTO_INCREMENT PRIMARY KEY,
    technicianId INT NOT NULL,
    availableDate DATE NOT NULL,
    startTime TIME NOT NULL,
    endTime TIME NOT NULL,
    availabilityType VARCHAR(20) NOT NULL CHECK (availabilityType IN ('Available', 'OnLeave', 'Sick', 'Training', 'OffDuty')),
    reason VARCHAR(255), -- optional note for unavailability
    createdBy INT NOT NULL, -- who set this availability
    createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (technicianId) REFERENCES Account(accountId),
    FOREIGN KEY (createdBy) REFERENCES Account(accountId)
);

-- Index for checking availability on specific dates
CREATE INDEX idx_tech_date_availability ON TechnicianAvailability(technicianId, availableDate, availabilityType);

-- ====================================================================
-- 4. ENHANCED REQUEST APPROVAL
-- ====================================================================
-- Purpose: Extend existing RequestApproval table with manager notes
-- Supports UC-05 with additional context

-- Add columns to existing RequestApproval table
ALTER TABLE RequestApproval
ADD COLUMN reviewedAt DATETIME,
ADD COLUMN estimatedEffort DECIMAL(10,2), -- estimated hours needed
ADD COLUMN recommendedSkills VARCHAR(255), -- skills needed for this request
ADD COLUMN urgencyNotes VARCHAR(500); -- manager's assessment of urgency

-- Index for tracking approval history by manager
CREATE INDEX idx_approval_by_manager ON RequestApproval(approvedBy, approvalDate);

-- ====================================================================
-- 5. WORK ASSIGNMENT TRACKING
-- ====================================================================
-- Purpose: Track the assignment decision process
-- Supports UC-06 with audit trail and reasoning

CREATE TABLE WorkAssignment (
    assignmentId INT AUTO_INCREMENT PRIMARY KEY,
    taskId INT NOT NULL,
    assignedBy INT NOT NULL, -- Technical Manager who made the assignment
    assignedTo INT NOT NULL, -- Technician receiving the assignment
    assignmentDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    assignmentReason VARCHAR(500), -- why this technician was chosen
    estimatedDuration DECIMAL(10,2), -- estimated hours
    requiredSkills VARCHAR(255), -- skills needed for this task
    priority VARCHAR(20) NOT NULL CHECK (priority IN ('Low', 'Normal', 'High', 'Urgent')),
    acceptedByTechnician BIT DEFAULT 0, -- whether technician acknowledged
    acceptedAt DATETIME,
    FOREIGN KEY (taskId) REFERENCES WorkTask(taskId),
    FOREIGN KEY (assignedBy) REFERENCES Account(accountId),
    FOREIGN KEY (assignedTo) REFERENCES Account(accountId)
);

-- Index for tracking assignments by manager and technician
CREATE INDEX idx_assignment_by_manager ON WorkAssignment(assignedBy, assignmentDate);
CREATE INDEX idx_assignment_to_technician ON WorkAssignment(assignedTo, assignmentDate);

-- ====================================================================
-- 6. ENHANCED MAINTENANCE SCHEDULE
-- ====================================================================
-- Purpose: Add fields to support UC-07 features
-- Extends MaintenanceSchedule for better tracking

-- Add columns to existing MaintenanceSchedule table
ALTER TABLE MaintenanceSchedule
ADD COLUMN createdBy INT, -- Technical Manager who created the schedule
ADD COLUMN estimatedDuration DECIMAL(10,2), -- estimated hours for maintenance
ADD COLUMN actualDuration DECIMAL(10,2), -- actual time taken (filled after completion)
ADD COLUMN requiredSkills VARCHAR(255), -- skills needed
ADD COLUMN notes VARCHAR(500), -- manager's notes about the schedule
ADD COLUMN notificationSent BIT DEFAULT 0, -- whether technician was notified
ADD COLUMN notificationSentAt DATETIME;

-- Add foreign key for createdBy
ALTER TABLE MaintenanceSchedule
ADD FOREIGN KEY (createdBy) REFERENCES Account(accountId);

-- Index for finding schedules created by specific manager
CREATE INDEX idx_schedule_created_by ON MaintenanceSchedule(createdBy, scheduledDate);

-- ====================================================================
-- 7. REPORT REVIEW TRACKING
-- ====================================================================
-- Purpose: Support UC-08 for reviewing maintenance reports
-- Tracks manager review, feedback, and approval status

CREATE TABLE ReportReview (
    reviewId INT AUTO_INCREMENT PRIMARY KEY,
    reportId INT NOT NULL, -- links to RepairReport
    resultId INT, -- links to RepairResult (optional, as report may not have result yet)
    reviewedBy INT NOT NULL, -- Technical Manager
    reviewDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    reviewStatus VARCHAR(20) NOT NULL CHECK (reviewStatus IN ('Pending', 'Approved', 'RejectedNeedsRevision', 'Reviewed')),
    rating INT CHECK (rating >= 1 AND rating <= 5), -- quality rating 1-5
    feedback VARCHAR(1000), -- manager's detailed feedback
    actionRequired VARCHAR(500), -- any follow-up actions needed
    followUpRequired BIT DEFAULT 0, -- whether follow-up is needed
    followUpDate DATE, -- when to follow up
    technicalCompliance BIT, -- whether work met technical standards
    qualityScore DECIMAL(5,2), -- calculated quality score
    FOREIGN KEY (reportId) REFERENCES RepairReport(reportId),
    FOREIGN KEY (resultId) REFERENCES RepairResult(resultId),
    FOREIGN KEY (reviewedBy) REFERENCES Account(accountId),
    UNIQUE (reportId) -- one review per report
);

-- Index for finding reviews by manager
CREATE INDEX idx_review_by_manager ON ReportReview(reviewedBy, reviewDate);
CREATE INDEX idx_review_status ON ReportReview(reviewStatus);

-- ====================================================================
-- 8. TECHNICIAN PERFORMANCE METRICS
-- ====================================================================
-- Purpose: Track technician performance for better assignment decisions
-- Supports UC-06 by providing performance history

CREATE TABLE TechnicianPerformance (
    performanceId INT AUTO_INCREMENT PRIMARY KEY,
    technicianId INT NOT NULL,
    evaluationPeriod VARCHAR(20) NOT NULL, -- e.g., '2024-Q1', '2024-01'
    tasksCompleted INT NOT NULL DEFAULT 0,
    tasksOnTime INT NOT NULL DEFAULT 0,
    tasksLate INT NOT NULL DEFAULT 0,
    averageCompletionTime DECIMAL(10,2), -- in hours
    averageQualityScore DECIMAL(5,2), -- from report reviews
    customerSatisfactionScore DECIMAL(5,2), -- if available
    performanceScore DECIMAL(5,2), -- overall calculated score
    evaluatedBy INT NOT NULL, -- Technical Manager
    evaluatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    comments VARCHAR(500),
    FOREIGN KEY (technicianId) REFERENCES Account(accountId),
    FOREIGN KEY (evaluatedBy) REFERENCES Account(accountId),
    UNIQUE (technicianId, evaluationPeriod)
);

-- Index for performance tracking
CREATE INDEX idx_performance_tech ON TechnicianPerformance(technicianId, evaluationPeriod);
CREATE INDEX idx_performance_score ON TechnicianPerformance(performanceScore DESC);

-- ====================================================================
-- 9. MAINTENANCE SCHEDULE NOTIFICATIONS
-- ====================================================================
-- Purpose: Track notifications sent for scheduled maintenance
-- Supports UC-07 requirement to notify assigned technicians

CREATE TABLE ScheduleNotification (
    notificationId INT AUTO_INCREMENT PRIMARY KEY,
    scheduleId INT NOT NULL,
    recipientId INT NOT NULL, -- technician being notified
    notificationType VARCHAR(50) NOT NULL CHECK (notificationType IN ('Assignment', 'Reminder', 'Rescheduled', 'Cancelled', 'Urgent')),
    sentAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sentBy INT NOT NULL, -- Technical Manager
    deliveryMethod VARCHAR(20) NOT NULL CHECK (deliveryMethod IN ('Email', 'SMS', 'InApp', 'All')),
    deliveryStatus VARCHAR(20) NOT NULL CHECK (deliveryStatus IN ('Pending', 'Sent', 'Delivered', 'Failed')),
    readAt DATETIME, -- when technician read the notification
    FOREIGN KEY (scheduleId) REFERENCES MaintenanceSchedule(scheduleId),
    FOREIGN KEY (recipientId) REFERENCES Account(accountId),
    FOREIGN KEY (sentBy) REFERENCES Account(accountId)
);

-- Index for tracking notifications
CREATE INDEX idx_notification_schedule ON ScheduleNotification(scheduleId, sentAt);
CREATE INDEX idx_notification_recipient ON ScheduleNotification(recipientId, deliveryStatus);

-- ====================================================================
-- 10. EQUIPMENT SERVICE REQUIREMENTS
-- ====================================================================
-- Purpose: Link equipment types to required skills
-- Helps UC-06 by suggesting which technicians can service which equipment

CREATE TABLE EquipmentServiceRequirement (
    requirementId INT AUTO_INCREMENT PRIMARY KEY,
    equipmentId INT NOT NULL,
    skillId INT NOT NULL,
    minimumProficiency VARCHAR(20) NOT NULL CHECK (minimumProficiency IN ('Beginner', 'Intermediate', 'Advanced', 'Expert')),
    isMandatory BIT NOT NULL DEFAULT 1, -- whether this skill is required or just helpful
    FOREIGN KEY (equipmentId) REFERENCES Equipment(equipmentId),
    FOREIGN KEY (skillId) REFERENCES TechnicianSkill(skillId),
    UNIQUE (equipmentId, skillId)
);

-- Index for finding required skills for equipment
CREATE INDEX idx_equipment_skill_req ON EquipmentServiceRequirement(equipmentId, isMandatory);

-- ====================================================================
-- 11. MANAGER DASHBOARD VIEWS
-- ====================================================================
-- Purpose: Pre-computed views for Technical Manager dashboard
-- Optimizes UC-06 workflow for viewing available technicians

-- View: Available Technicians with Current Workload
CREATE VIEW vw_AvailableTechnicians AS
SELECT 
    a.accountId,
    a.fullName,
    a.email,
    a.phone,
    tw.currentActiveTasks,
    tw.maxConcurrentTasks,
    (tw.maxConcurrentTasks - tw.currentActiveTasks) AS availableCapacity,
    tw.averageCompletionTime,
    CASE 
        WHEN tw.currentActiveTasks >= tw.maxConcurrentTasks THEN 'Fully Booked'
        WHEN tw.currentActiveTasks >= (tw.maxConcurrentTasks * 0.8) THEN 'Nearly Full'
        ELSE 'Available'
    END AS availabilityStatus
FROM Account a
INNER JOIN AccountRole ar ON a.accountId = ar.accountId
INNER JOIN Role r ON ar.roleId = r.roleId
LEFT JOIN TechnicianWorkload tw ON a.accountId = tw.technicianId
WHERE r.roleName = 'Technician' 
  AND a.status = 'Active'
  AND (tw.currentActiveTasks IS NULL OR tw.currentActiveTasks < tw.maxConcurrentTasks);

-- View: Pending Service Requests for Approval
CREATE VIEW vw_PendingServiceRequests AS
SELECT 
    sr.requestId,
    sr.contractId,
    sr.equipmentId,
    sr.createdBy,
    sr.description,
    sr.priorityLevel,
    sr.requestDate,
    sr.status,
    sr.requestType,
    a.fullName AS customerName,
    a.email AS customerEmail,
    e.serialNumber AS equipmentSerialNumber,
    e.model AS equipmentModel,
    c.contractType,
    DATEDIFF(CURRENT_DATE, sr.requestDate) AS daysPending
FROM ServiceRequest sr
INNER JOIN Account a ON sr.createdBy = a.accountId
INNER JOIN Equipment e ON sr.equipmentId = e.equipmentId
INNER JOIN Contract c ON sr.contractId = c.contractId
WHERE sr.status = 'Pending'
ORDER BY sr.priorityLevel DESC, sr.requestDate ASC;

-- View: Technician Skills Summary
CREATE VIEW vw_TechnicianSkillsSummary AS
SELECT 
    a.accountId AS technicianId,
    a.fullName AS technicianName,
    ts.skillId,
    ts.skillName,
    ts.category,
    tsa.proficiencyLevel,
    tsa.isActive,
    tsa.expiryDate
FROM Account a
INNER JOIN AccountRole ar ON a.accountId = ar.accountId
INNER JOIN Role r ON ar.roleId = r.roleId
INNER JOIN TechnicianSkillAssignment tsa ON a.accountId = tsa.technicianId
INNER JOIN TechnicianSkill ts ON tsa.skillId = ts.skillId
WHERE r.roleName = 'Technician' 
  AND a.status = 'Active'
  AND tsa.isActive = 1;

-- View: Maintenance Reports Pending Review
CREATE VIEW vw_PendingMaintenanceReports AS
SELECT 
    rr.reportId,
    rr.requestId,
    rr.technicianId,
    rr.details,
    rr.diagnosis,
    rr.estimatedCost,
    rr.quotationStatus,
    rr.repairDate,
    a.fullName AS technicianName,
    sr.description AS requestDescription,
    sr.priorityLevel,
    COALESCE(rev.reviewStatus, 'Pending') AS reviewStatus
FROM RepairReport rr
INNER JOIN Account a ON rr.technicianId = a.accountId
INNER JOIN ServiceRequest sr ON rr.requestId = sr.requestId
LEFT JOIN ReportReview rev ON rr.reportId = rev.reportId
WHERE COALESCE(rev.reviewStatus, 'Pending') = 'Pending'
ORDER BY sr.priorityLevel DESC, rr.repairDate ASC;

-- ====================================================================
-- 12. TRIGGER FOR AUTOMATIC WORKLOAD UPDATES
-- ====================================================================
-- Purpose: Automatically update technician workload when tasks are assigned/completed
-- Maintains accurate workload data for UC-06

-- ====================================================================
-- XÓA TRIGGER CŨ
-- ====================================================================
DROP TRIGGER IF EXISTS trg_UpdateWorkloadOnTaskAssign;
DROP TRIGGER IF EXISTS trg_UpdateWorkloadOnTaskComplete;
DROP TRIGGER IF EXISTS trg_UpdateScheduleStatusOnTaskComplete;
	DELIMITER //

	CREATE TRIGGER trg_UpdateWorkloadOnTaskAssign
	AFTER INSERT ON WorkTask
	FOR EACH ROW
	BEGIN
		DECLARE workload_points INT DEFAULT 1;
		DECLARE task_priority VARCHAR(20);
		
		-- Lấy priority từ WorkAssignment (nếu có)
		SELECT wa.priority INTO task_priority
		FROM WorkAssignment wa
		WHERE wa.taskId = NEW.taskId
		LIMIT 1;
		
		-- Tính workload points dựa trên priority
		IF task_priority = 'Urgent' THEN
			SET workload_points = 3;
		ELSEIF task_priority = 'High' THEN
			SET workload_points = 2;
		ELSE
			SET workload_points = 1;  -- Normal, Low
		END IF;
		
		-- Cập nhật workload
		INSERT INTO TechnicianWorkload (technicianId, currentActiveTasks, maxConcurrentTasks, lastAssignedDate, lastUpdated)
		VALUES (NEW.technicianId, workload_points, 5, NOW(), NOW())
		ON DUPLICATE KEY UPDATE 
			currentActiveTasks = currentActiveTasks + workload_points,
			lastAssignedDate = NOW(),
			lastUpdated = NOW();
	END//

	-- ✅ Tạo lại trigger GIẢM workload theo priority

CREATE TRIGGER trg_UpdateWorkloadOnTaskComplete
AFTER UPDATE ON WorkTask
FOR EACH ROW
BEGIN
    DECLARE workload_points INT DEFAULT 1;
    DECLARE task_priority VARCHAR(20);
    DECLARE schedule_priority_id INT DEFAULT NULL;
    
    -- Chỉ chạy khi status chuyển sang Completed
    IF NEW.status = 'Completed' AND OLD.status != 'Completed' THEN
        
        -- ✅ BƯỚC 1: Thử lấy priority từ WorkAssignment (cho task từ /assignWork)
        SELECT wa.priority INTO task_priority
        FROM WorkAssignment wa
        WHERE wa.taskId = NEW.taskId
        LIMIT 1;
        
        -- ✅ BƯỚC 2: Nếu không có WorkAssignment, lấy từ MaintenanceSchedule (cho task từ /scheduleMaintenance)
        IF task_priority IS NULL AND NEW.scheduleId IS NOT NULL THEN
            SELECT ms.priorityId INTO schedule_priority_id
            FROM MaintenanceSchedule ms
            WHERE ms.scheduleId = NEW.scheduleId
            LIMIT 1;
            
            -- Convert priorityId sang priority string
            IF schedule_priority_id = 4 THEN
                SET task_priority = 'Urgent';
            ELSEIF schedule_priority_id = 3 THEN
                SET task_priority = 'High';
            ELSEIF schedule_priority_id = 2 THEN
                SET task_priority = 'Normal';
            ELSE
                SET task_priority = 'Normal';
            END IF;
        END IF;
        
        -- ✅ BƯỚC 3: Tính workload points dựa trên priority
        IF task_priority = 'Urgent' THEN
            SET workload_points = 3;
        ELSEIF task_priority = 'High' THEN
            SET workload_points = 2;
        ELSE
            SET workload_points = 1;  -- Normal, Low
        END IF;
        
        -- ✅ BƯỚC 4: Giảm workload và tăng completed count
        UPDATE TechnicianWorkload
        SET currentActiveTasks = GREATEST(0, currentActiveTasks - workload_points),
            totalCompletedTasks = totalCompletedTasks + 1,
            lastUpdated = NOW()
        WHERE technicianId = NEW.technicianId;
        
    END IF;
END//

DELIMITER ;

-- ====================================================================
-- VERIFY: Kiểm tra trigger đã được tạo
-- ====================================================================
SHOW TRIGGERS WHERE `Trigger` = 'trg_UpdateWorkloadOnTaskComplete';
	-- Đồng bộ status của bảng maintenanceschedule với bảng work task
	DELIMITER //

	CREATE TRIGGER trg_UpdateScheduleStatusOnTaskComplete
	AFTER UPDATE ON WorkTask
	FOR EACH ROW
	BEGIN
		-- Khi WorkTask completed, update MaintenanceSchedule tương ứng
		IF NEW.status = 'Completed' AND OLD.status != 'Completed' AND NEW.scheduleId IS NOT NULL THEN
			UPDATE MaintenanceSchedule
			SET status = 'Completed'
			WHERE scheduleId = NEW.scheduleId;
		END IF;
		
		-- Khi WorkTask in progress, update MaintenanceSchedule
		IF NEW.status = 'In Progress' AND OLD.status != 'In Progress' AND NEW.scheduleId IS NOT NULL THEN
			UPDATE MaintenanceSchedule
			SET status = 'In Progress'
			WHERE scheduleId = NEW.scheduleId;
		END IF;
	END//

	DELIMITER ;
-- ====================================================================
-- 13. STORED PROCEDURES FOR TECHNICAL MANAGER OPERATIONS
-- ====================================================================
-- Purpose: Encapsulate complex business logic for manager operations

DELIMITER //

-- Procedure: Get Recommended Technicians for a Service Request
CREATE PROCEDURE sp_GetRecommendedTechnicians(
    IN p_requestId INT,
    IN p_requiredSkillId INT
)
BEGIN
    SELECT 
        a.accountId,
        a.fullName,
        a.email,
        tw.currentActiveTasks,
        tw.maxConcurrentTasks,
        (tw.maxConcurrentTasks - tw.currentActiveTasks) AS availableCapacity,
        tsa.proficiencyLevel,
        tp.performanceScore,
        tp.averageQualityScore,
        CASE 
            WHEN tsa.proficiencyLevel = 'Expert' THEN 4
            WHEN tsa.proficiencyLevel = 'Advanced' THEN 3
            WHEN tsa.proficiencyLevel = 'Intermediate' THEN 2
            ELSE 1
        END AS skillWeight,
        (COALESCE(tp.performanceScore, 3.0) * 0.4 + 
         (tw.maxConcurrentTasks - tw.currentActiveTasks) * 0.3 +
         CASE 
            WHEN tsa.proficiencyLevel = 'Expert' THEN 4
            WHEN tsa.proficiencyLevel = 'Advanced' THEN 3
            WHEN tsa.proficiencyLevel = 'Intermediate' THEN 2
            ELSE 1
         END * 0.3) AS recommendationScore
    FROM Account a
    INNER JOIN AccountRole ar ON a.accountId = ar.accountId
    INNER JOIN Role r ON ar.roleId = r.roleId
    INNER JOIN TechnicianWorkload tw ON a.accountId = tw.technicianId
    INNER JOIN TechnicianSkillAssignment tsa ON a.accountId = tsa.technicianId
    LEFT JOIN TechnicianPerformance tp ON a.accountId = tp.technicianId
        AND tp.evaluationPeriod = DATE_FORMAT(CURRENT_DATE, '%Y-Q%q')
    WHERE r.roleName = 'Technician'
        AND a.status = 'Active'
        AND tsa.skillId = p_requiredSkillId
        AND tsa.isActive = 1
        AND tw.currentActiveTasks < tw.maxConcurrentTasks
    ORDER BY recommendationScore DESC
    LIMIT 10;
END//

-- Procedure: Approve Service Request and Create Work Task
CREATE PROCEDURE sp_ApproveAndAssignRequest(
    IN p_requestId INT,
    IN p_managerId INT,
    IN p_technicianId INT,
    IN p_estimatedHours DECIMAL(10,2),
    IN p_note VARCHAR(255)
)
BEGIN
    DECLARE v_approvalId INT;
    DECLARE v_taskId INT;
    
    -- Start transaction
    START TRANSACTION;
    
    -- Update service request status
    UPDATE ServiceRequest 
    SET status = 'Approved' 
    WHERE requestId = p_requestId;
    
    -- Create approval record
    INSERT INTO RequestApproval (requestId, approvedBy, approvalDate, decision, note, estimatedEffort)
    VALUES (p_requestId, p_managerId, NOW(), 'Approved', p_note, p_estimatedHours);
    
    SET v_approvalId = LAST_INSERT_ID();
    
    -- Create work task
    INSERT INTO WorkTask (requestId, technicianId, taskType, startDate, status)
    VALUES (p_requestId, p_technicianId, 'Request', CURRENT_DATE, 'Assigned');
    
    SET v_taskId = LAST_INSERT_ID();
    
    -- Create work assignment record
    INSERT INTO WorkAssignment (taskId, assignedBy, assignedTo, assignmentDate, estimatedDuration)
    VALUES (v_taskId, p_managerId, p_technicianId, NOW(), p_estimatedHours);
    
    -- Commit transaction
    COMMIT;
    
    -- Return the created IDs
    SELECT v_approvalId AS approvalId, v_taskId AS taskId;
END//

DELIMITER ;

-- ====================================================================
-- 14. INITIAL DATA FOR TECHNICAL MANAGER ROLE
-- ====================================================================
-- Purpose: Ensure Technical Manager role exists and set up default data

-- Insert Technical Manager role if it doesn't exist
INSERT INTO Role (roleName)
VALUES ('Technical Manager')
ON DUPLICATE KEY UPDATE roleName = 'Technical Manager';

-- Insert some default technician skills
INSERT INTO TechnicianSkill (skillName, description, category) VALUES
('Electrical Systems', 'Installation and repair of electrical systems', 'Electrical'),
('HVAC Systems', 'Heating, ventilation, and air conditioning systems', 'Mechanical'),
('Plumbing', 'Water supply and drainage systems', 'Plumbing'),
('IT Infrastructure', 'Computer networks and IT equipment', 'Technology'),
('Mechanical Repair', 'General mechanical equipment repair', 'Mechanical'),
('Safety Systems', 'Fire safety and security systems', 'Safety'),
('Building Automation', 'BMS and automation systems', 'Technology'),
('Welding', 'Metal fabrication and welding', 'Mechanical')
ON DUPLICATE KEY UPDATE skillName = VALUES(skillName);

-- ====================================================================
-- 15. INDEXES FOR PERFORMANCE OPTIMIZATION
-- ====================================================================
-- Purpose: Optimize queries used by Technical Manager operations

-- Index for finding work tasks by technician and status
CREATE INDEX idx_worktask_tech_status ON WorkTask(technicianId, status);

-- Index for finding service requests by status and date
CREATE INDEX idx_servicerequest_status_date ON ServiceRequest(status, requestDate);

-- Index for finding maintenance schedules by technician and date
CREATE INDEX idx_maintenance_tech_date ON MaintenanceSchedule(assignedTo, scheduledDate, status);

-- Index for finding repair reports by technician and date
CREATE INDEX idx_repairreport_tech_date ON RepairReport(technicianId, repairDate);

-- ====================================================================
-- VERIFICATION QUERIES
-- ====================================================================
-- Purpose: Verify that all modifications were applied successfully

-- Check all new tables were created
SELECT 'Tables Created' AS Check_Type, 
       COUNT(*) AS Count_Result
FROM information_schema.tables 
WHERE table_schema = DATABASE() 
  AND table_name IN (
    'TechnicianSkill', 'TechnicianSkillAssignment', 'TechnicianWorkload',
    'TechnicianAvailability', 'WorkAssignment', 'ReportReview',
    'TechnicianPerformance', 'ScheduleNotification', 'EquipmentServiceRequirement'
);

-- Check views were created
SELECT 'Views Created' AS Check_Type,
       COUNT(*) AS Count_Result
FROM information_schema.views
WHERE table_schema = DATABASE()
  AND table_name IN (
    'vw_AvailableTechnicians', 'vw_PendingServiceRequests',
    'vw_TechnicianSkillsSummary', 'vw_PendingMaintenanceReports'
);

-- Check triggers were created
-- SELECT 'Triggers Created' AS Check_Type,
--       COUNT(*) AS Count_Result
-- FROM information_schema.triggers
-- WHERE trigger_schema = DATABASE()
--  AND trigger_name IN (
--    'trg_UpdateWorkloadOnTaskAssign', 'trg_UpdateWorkloadOnTaskComplete'
-- );

-- Check stored procedures were created
SELECT 'Procedures Created' AS Check_Type,
       COUNT(*) AS Count_Result
FROM information_schema.routines
WHERE routine_schema = DATABASE()
  AND routine_type = 'PROCEDURE'
  AND routine_name IN (
    'sp_GetRecommendedTechnicians', 'sp_ApproveAndAssignRequest'
);

-- ====================================================================
-- END OF SCRIPT
-- ====================================================================
-- All database modifications for Technical Manager functionality
-- have been completed. The schema now fully supports:
-- - UC-05: Approve/Reject Service Request
-- - UC-06: Assign Work to Technician (with skills, workload, availability)
-- - UC-07: Schedule Maintenance (with notifications)
-- - UC-08: Review Maintenance Report (with feedback tracking)
-- ====================================================================

-- ====================================================================
-- DATABASE UPDATE: Add Technician Assignment to RequestApproval Table
-- ====================================================================
-- Purpose: Allow Technical Manager to assign technicians during approval process
-- Date: Current
-- Author: System Update

-- Add assignedTechnicianId column to RequestApproval table
ALTER TABLE RequestApproval 
ADD COLUMN assignedTechnicianId INT NULL COMMENT 'Technician assigned to handle the approved request';

-- Add foreign key constraint to ensure assigned technician exists and is valid
ALTER TABLE RequestApproval 
ADD CONSTRAINT FK_RequestApproval_AssignedTechnician 
FOREIGN KEY (assignedTechnicianId) REFERENCES Account(accountId);

-- Add index for better query performance
CREATE INDEX IDX_RequestApproval_AssignedTechnician ON RequestApproval(assignedTechnicianId);

-- Update existing approved requests to have NULL assignedTechnicianId (optional)
-- This allows existing data to remain valid while new approvals can include technician assignment

-- Verification query to check the update
SELECT 
    COLUMN_NAME, 
    DATA_TYPE, 
    IS_NULLABLE, 
    COLUMN_DEFAULT,
    COLUMN_COMMENT
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() 
  AND TABLE_NAME = 'RequestApproval' 
  AND COLUMN_NAME = 'assignedTechnicianId';

-- Success message
SELECT 'RequestApproval table has been successfully updated with technician assignment capability!' as Status;

-- ====================================================================
-- DATABASE UPDATE SCRIPT FOR SERVICEREQUEST AND REQUESTAPPROVAL TABLES
-- ====================================================================
-- This script updates the existing ServiceRequest and RequestApproval tables
-- to match the new specifications with ENUM types and improved field definitions.
--
-- IMPORTANT: Backup your database before running this script!
-- ====================================================================

-- ====================================================================
-- 1. UPDATE SERVICEREQUEST TABLE
-- ====================================================================

-- Step 1: Modify requestDate from DATE to DATETIME with DEFAULT CURRENT_TIMESTAMP
ALTER TABLE ServiceRequest 
MODIFY COLUMN requestDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP;

-- Step 2: Modify status from VARCHAR to ENUM
ALTER TABLE ServiceRequest 
MODIFY COLUMN status ENUM('Pending','Awaiting Approval','Approved','Rejected','Completed','Cancelled') 
NOT NULL DEFAULT 'Pending';

-- Step 3: Modify requestType from VARCHAR to ENUM
ALTER TABLE ServiceRequest 
MODIFY COLUMN requestType ENUM('Service','Warranty','InformationUpdate') 
NOT NULL DEFAULT 'Service';

-- ====================================================================
-- 2. UPDATE REQUESTAPPROVAL TABLE
-- ====================================================================

-- Step 1: Drop the UNIQUE constraint on requestId
-- First, find the constraint name (it might be auto-generated)
-- We'll use a more generic approach that works regardless of constraint name
-- ALTER TABLE RequestApproval DROP INDEX requestId;

-- Step 2: Modify approvedBy to be nullable
ALTER TABLE RequestApproval 
MODIFY COLUMN approvedBy INT NULL;

-- Step 3: Modify approvalDate from DATE NOT NULL to DATETIME NULL
ALTER TABLE RequestApproval 
MODIFY COLUMN approvalDate DATETIME NULL;

-- Step 4: Modify decision from VARCHAR to ENUM with DEFAULT 'Pending'
ALTER TABLE RequestApproval 
MODIFY COLUMN decision ENUM('Pending','Approved','Rejected') DEFAULT 'Pending';

-- ====================================================================
-- 3. DATA MIGRATION (OPTIONAL)
-- ====================================================================
-- If you have existing data, you might want to update it to match new ENUM values

-- Update any existing status values that don't match the new ENUM
-- (Uncomment and modify as needed based on your existing data)

-- UPDATE ServiceRequest 
-- SET status = 'Pending' 
-- WHERE status NOT IN ('Pending','Awaiting Approval','Approved','Rejected','Completed','Cancelled');

-- UPDATE ServiceRequest 
-- SET requestType = 'Service' 
-- WHERE requestType NOT IN ('Service','Warranty','InformationUpdate');

-- Update any existing decision values that don't match the new ENUM
-- UPDATE RequestApproval 
-- SET decision = 'Pending' 
-- WHERE decision NOT IN ('Pending','Approved','Rejected');

-- ====================================================================
-- 4. VERIFICATION QUERIES
-- ====================================================================
-- Run these queries to verify the changes were applied correctly

-- Verify ServiceRequest table structure
-- DESCRIBE ServiceRequest;

-- Verify RequestApproval table structure  
-- DESCRIBE RequestApproval;

-- Check for any data that might not fit the new constraints
-- SELECT status, COUNT(*) FROM ServiceRequest GROUP BY status;
-- SELECT requestType, COUNT(*) FROM ServiceRequest GROUP BY requestType;
-- SELECT decision, COUNT(*) FROM RequestApproval GROUP BY decision;

-- ====================================================================
-- NOTES:
-- ====================================================================
-- 1. The UNIQUE constraint on RequestApproval.requestId has been removed
--    This allows multiple approval records for the same request if needed
-- 2. approvedBy is now nullable to support 'Pending' state
-- 3. approvalDate is now nullable to support records without approval date
-- 4. All ENUM fields have appropriate DEFAULT values
-- 5. requestDate now uses DATETIME for more precise timestamps
-- ====================================================================

-- ====================================================================
-- TECHNICAL MANAGER TEST DATA SCRIPT
-- ====================================================================
-- This script creates comprehensive test data for testing the Technical Manager
-- Approval functionality at http://localhost:8080/CRM/technicalManagerApproval
--
-- Features tested:
-- - Service Request Approval/Rejection
-- - Work Assignment to Technicians
-- - Maintenance Scheduling
-- - Priority Management
-- - Equipment and Contract Management
-- ====================================================================

-- Clear existing test data (optional - uncomment if needed)
-- DELETE FROM RequestApproval WHERE approvalId > 0;
-- DELETE FROM ServiceRequest WHERE requestId > 0;
-- DELETE FROM ContractEquipment WHERE contractEquipmentId > 0;
-- DELETE FROM Contract WHERE contractId > 0;
-- DELETE FROM Equipment WHERE equipmentId > 0;
-- DELETE FROM AccountRole WHERE accountId > 0;
-- DELETE FROM Account WHERE accountId > 0;
-- DELETE FROM Role WHERE roleId > 0;

-- ====================================================================
-- 1. ROLES AND ACCOUNTS
-- ====================================================================

-- Insert Roles (matching AccountRoleService.java implementation)

-- BINHPQ: bo insert ignore vao role vi DB da co 6 roles theo id 1-6

-- INSERT IGNORE INTO Role (roleId, roleName) VALUES 
-- (1, 'Admin'),
-- (2, 'Customer'),
-- (3, 'Customer Service Staff'),
-- (4, 'Technical Manager'),
-- (5, 'Technician');

-- Insert Test Accounts
INSERT IGNORE INTO Account (accountId, username, passwordHash, fullName, email, phone, status, createdAt) VALUES 
-- Admin
(1, 'admin', '$2a$12$jfOF05tnCZRuUQO7SducFulvctczEiSaNFHTne87YSZ3sV14Ortke', 'System Administrator', 'admin@crm.com', '0901000001', 'Active', '2024-01-01 08:00:00'),

-- Technical Managers
(2, 'techmanager1', '$2a$12$jfOF05tnCZRuUQO7SducFulvctczEiSaNFHTne87YSZ3sV14Ortke', 'Nguyễn Văn Quản', 'techmanager1@crm.com', '0901000002', 'Active', '2024-01-01 08:00:00'),
(3, 'techmanager2', '$2a$12$jfOF05tnCZRuUQO7SducFulvctczEiSaNFHTne87YSZ3sV14Ortke', 'Trần Thị Hương', 'techmanager2@crm.com', '0901000003', 'Active', '2024-01-01 08:00:00'),

-- Customers
(4, 'customer1', '$2a$12$jfOF05tnCZRuUQO7SducFulvctczEiSaNFHTne87YSZ3sV14Ortke', 'Lê Văn Khách', 'customer1@gmail.com', '0901000004', 'Active', '2024-01-01 08:00:00'),
(5, 'customer2', '$2a$12$jfOF05tnCZRuUQO7SducFulvctczEiSaNFHTne87YSZ3sV14Ortke', 'Phạm Thị Lan', 'customer2@gmail.com', '0901000005', 'Active', '2024-01-01 08:00:00'),
(6, 'customer3', '$2a$12$jfOF05tnCZRuUQO7SducFulvctczEiSaNFHTne87YSZ3sV14Ortke', 'Hoàng Văn Minh', 'customer3@gmail.com', '0901000006', 'Active', '2024-01-01 08:00:00'),
(7, 'customer4', '$2a$12$jfOF05tnCZRuUQO7SducFulvctczEiSaNFHTne87YSZ3sV14Ortke', 'Vũ Thị Hoa', 'customer4@gmail.com', '0901000007', 'Active', '2024-01-01 08:00:00'),

-- Technicians
(8, 'technician1', '$2a$12$jfOF05tnCZRuUQO7SducFulvctczEiSaNFHTne87YSZ3sV14Ortke', 'Nguyễn Văn Sửa', 'technician1@crm.com', '0901000008', 'Active', '2024-01-01 08:00:00'),
(9, 'technician2', '$2a$12$jfOF05tnCZRuUQO7SducFulvctczEiSaNFHTne87YSZ3sV14Ortke', 'Trần Văn Chữa', 'technician2@crm.com', '0901000009', 'Active', '2024-01-01 08:00:00'),
(10, 'technician3', '$2a$12$jfOF05tnCZRuUQO7SducFulvctczEiSaNFHTne87YSZ3sV14Ortke', 'Lê Thị Bảo', 'technician3@crm.com', '0901000010', 'Active', '2024-01-01 08:00:00'),
(11, 'technician4', '$2a$12$jfOF05tnCZRuUQO7SducFulvctczEiSaNFHTne87YSZ3sV14Ortke', 'Phạm Văn Trì', 'technician4@crm.com', '0901000011', 'Active', '2024-01-01 08:00:00'),

-- Customer Service Staff
(12, 'css1', '$2a$12$jfOF05tnCZRuUQO7SducFulvctczEiSaNFHTne87YSZ3sV14Ortke', 'Nguyễn Thị Hỗ Trợ', 'css1@crm.com', '0901000012', 'Active', '2024-01-01 08:00:00');

-- Assign Roles to Accounts (canonical IDs)
INSERT IGNORE INTO AccountRole (accountId, roleId) VALUES 
(1, 1),  -- Admin
(2, 4),  -- Technical Manager
(3, 4),  -- Technical Manager
(4, 2),  -- Customer
(5, 2),  -- Customer
(6, 2),  -- Customer
(7, 2),  -- Customer
(8, 6),  -- Technician
(9, 6),  -- Technician
(10, 6), -- Technician
(11, 6), -- Technician
(12, 3); -- Customer Support Staff

-- ====================================================================
-- 2. PRIORITY LEVELS
-- ====================================================================

INSERT IGNORE INTO Priority (priorityId, priorityName, priorityLevel, description) VALUES 
(1, 'Low', 1, 'Không khẩn cấp, có thể xử lý trong vòng 1 tuần'),
(2, 'Normal', 2, 'Mức độ bình thường, xử lý trong 2-3 ngày'),
(3, 'High', 3, 'Ưu tiên cao, cần xử lý trong 24 giờ'),
(4, 'Urgent', 4, 'Khẩn cấp, cần xử lý ngay lập tức');

-- ====================================================================
-- 3. EQUIPMENT AND CONTRACTS
-- ====================================================================

-- Equipment
INSERT IGNORE INTO Equipment (equipmentId, serialNumber, model, description, installDate, lastUpdatedBy, lastUpdatedDate) VALUES 
-- Air Conditioners
(1, 'AC001-2024', 'Daikin FTKC25UAVMV', 'Máy lạnh 1HP - Phòng khách', '2024-01-15', 1, '2024-01-15'),
(2, 'AC002-2024', 'Panasonic CU-N9VKH-8', 'Máy lạnh 1.5HP - Phòng ngủ chính', '2024-02-01', 1, '2024-02-01'),
(3, 'AC003-2024', 'Mitsubishi MSY-JP25VF', 'Máy lạnh 1HP - Phòng làm việc', '2024-02-15', 1, '2024-02-15'),
(4, 'AC004-2024', 'LG V10ENW', 'Máy lạnh 1.5HP - Phòng khách lớn', '2024-03-01', 1, '2024-03-01'),

-- Water Pumps
(5, 'PUMP001-2024', 'Grundfos CM3-4', 'Máy bơm nước sinh hoạt', '2024-01-20', 1, '2024-01-20'),
(6, 'PUMP002-2024', 'Pentax CM32-160A', 'Máy bơm nước công nghiệp', '2024-02-10', 1, '2024-02-10'),

-- Electrical Systems
(7, 'ELEC001-2024', 'Schneider Electric Panel', 'Tủ điện chính', '2024-01-10', 1, '2024-01-10'),
(8, 'ELEC002-2024', 'ABB Motor Drive', 'Biến tần điều khiển motor', '2024-02-20', 1, '2024-02-20'),

-- HVAC Systems
(9, 'HVAC001-2024', 'Carrier AquaEdge 19XR', 'Hệ thống điều hòa trung tâm', '2024-03-15', 1, '2024-03-15'),
(10, 'HVAC002-2024', 'Trane RTAC', 'Máy lạnh công nghiệp', '2024-03-20', 1, '2024-03-20');

-- Contracts
INSERT IGNORE INTO Contract (contractId, customerId, contractDate, contractType, status, details) VALUES 
(1, 4, '2024-01-01', 'Bảo trì', 'Active', 'Hợp đồng bảo trì thiết bị điều hòa - Lê Văn Khách'),
(2, 5, '2024-02-01', 'Bảo hành', 'Active', 'Hợp đồng bảo hành máy bơm - Phạm Thị Lan'),
(3, 6, '2024-02-15', 'Bảo trì', 'Active', 'Hợp đồng bảo trì hệ thống điện - Hoàng Văn Minh'),
(4, 7, '2024-03-01', 'Bảo hành', 'Active', 'Hợp đồng bảo hành HVAC - Vũ Thị Hoa'),
(5, 4, '2024-03-10', 'Bảo trì', 'Active', 'Hợp đồng bảo trì mở rộng - Lê Văn Khách');

-- Contract Equipment Relationships
INSERT IGNORE INTO ContractEquipment (contractEquipmentId, contractId, equipmentId, startDate, endDate, quantity, price) VALUES 
-- Contract 1 - Customer 4 (Lê Văn Khách)
(1, 1, 1, '2024-01-01', '2025-12-31', 1, 5000000),
(2, 1, 2, '2024-02-01', '2025-12-31', 1, 6000000),

-- Contract 2 - Customer 5 (Phạm Thị Lan)
(3, 2, 5, '2024-02-01', '2026-02-01', 1, 8000000),
(4, 2, 6, '2024-02-10', '2026-02-10', 1, 12000000),

-- Contract 3 - Customer 6 (Hoàng Văn Minh)
(5, 3, 7, '2024-02-15', '2026-02-15', 1, 15000000),
(6, 3, 8, '2024-02-20', '2026-02-20', 1, 10000000),

-- Contract 4 - Customer 7 (Vũ Thị Hoa)
(7, 4, 9, '2024-03-01', '2026-03-01', 1, 25000000),
(8, 4, 10, '2024-03-20', '2026-03-20', 1, 30000000),

-- Contract 5 - Customer 4 (Lê Văn Khách) - Extended
(9, 5, 3, '2024-03-10', '2025-12-12', 1, 5500000),
(10, 5, 4, '2024-03-10', '2025-12-12', 1, 6500000);

-- ====================================================================
-- 4. SERVICE REQUESTS FOR TESTING APPROVAL WORKFLOW
-- ====================================================================

INSERT IGNORE INTO ServiceRequest (requestId, contractId, equipmentId, createdBy, description, priorityLevel, requestDate, status, requestType) VALUES 

-- PENDING REQUESTS (for approval testing)
(1, 1, 1, 4, 'Máy lạnh không mát, tiếng ồn lớn khi hoạt động', 'Urgent', '2024-12-01', 'Awaiting Approval', 'Service'),
(2, 1, 2, 4, 'Máy lạnh chảy nước, có mùi khó chịu', 'High', '2024-12-02', 'Awaiting Approval', 'Service'),
(3, 2, 5, 5, 'Máy bơm không hoạt động, có tiếng kêu lạ', 'Normal', '2024-12-03', 'Awaiting Approval', 'Warranty'),
(4, 3, 7, 6, 'Tủ điện bị nóng, cầu dao tự ngắt', 'Urgent', '2024-12-04', 'Awaiting Approval', 'Service'),
(5, 2, 6, 5, 'Máy bơm công nghiệp giảm áp suất', 'High', '2024-12-05', 'Awaiting Approval', 'Warranty'),
(6, 4, 9, 7, 'Hệ thống HVAC không đạt nhiệt độ', 'Normal', '2024-12-06','Awaiting Approval', 'Warranty'),
(7, 3, 8, 6, 'Biến tần báo lỗi E001', 'High', '2024-12-07', 'Awaiting Approval', 'Service'),
(8, 5, 3, 4, 'Máy lạnh phòng làm việc không khởi động', 'Normal', '2024-12-08', 'Awaiting Approval', 'Service'),
(9, 4, 10, 7, 'Máy lạnh công nghiệp rò gas', 'Urgent', '2024-12-09', 'Awaiting Approval', 'Warranty'),
(10, 5, 4, 4, 'Máy lạnh phòng khách có mùi cháy', 'Urgent', '2024-12-10', 'Awaiting Approval', 'Service'),

-- APPROVED REQUESTS (for history testing)
(11, 1, 1, 4, 'Bảo trì định kỳ máy lạnh phòng khách', 'Normal', '2024-11-25', 'Approved', 'Service'),
(12, 2, 5, 5, 'Thay thế bộ lọc máy bơm', 'Normal', '2024-11-26', 'Approved', 'Warranty'),
(13, 3, 7, 6, 'Kiểm tra hệ thống điện định kỳ', 'Normal', '2024-11-27', 'Approved', 'Service'),
(14, 4, 9, 7, 'Bảo trì HVAC theo lịch', 'Normal', '2024-11-28', 'Approved', 'Warranty'),
(15, 1, 2, 4, 'Vệ sinh máy lạnh phòng ngủ', 'Low', '2024-11-29', 'Approved', 'Service'),

-- REJECTED REQUESTS (for history testing)
(16, 2, 6, 5, 'Yêu cầu thay thế toàn bộ máy bơm', 'High', '2024-11-20', 'Rejected', 'Warranty'),
(17, 3, 8, 6, 'Nâng cấp biến tần lên model mới', 'Normal', '2024-11-21', 'Rejected', 'Service'),
(18, 4, 10, 7, 'Thay thế máy lạnh công nghiệp', 'Low', '2024-11-22', 'Rejected', 'Warranty'),

-- TODAY'S REQUESTS (for dashboard statistics)
(19, 1, 1, 4, 'Kiểm tra máy lạnh sau sửa chữa', 'Normal', CURDATE(), 'Awaiting Approval', 'Service'),
(20, 2, 5, 5, 'Máy bơm có tiếng động lạ', 'High', CURDATE(), 'Awaiting Approval', 'Warranty'),
(21, 3, 7, 6, 'Tủ điện báo cảnh báo', 'Urgent', CURDATE(), 'Awaiting Approval', 'Service'),
(22, 5, 4, 4, 'Máy lạnh không tự động tắt', 'Normal', CURDATE(), 'Awaiting Approval', 'Service');

-- ====================================================================
-- 5. REQUEST APPROVALS (for approved/rejected requests)
-- ====================================================================

INSERT IGNORE INTO RequestApproval (approvalId, requestId, approvedBy, approvalDate, decision, note) VALUES 
-- Approved requests
(1, 11, 2, '2024-11-26', 'Approved', 'Đã kiểm tra lịch bảo trì, phê duyệt thực hiện'),
(2, 12, 2, '2024-11-27', 'Approved', 'Bộ lọc cần thay theo đúng chu kỳ, phê duyệt'),
(3, 13, 3, '2024-11-28', 'Approved', 'Kiểm tra định kỳ cần thiết, giao cho technician có kinh nghiệm'),
(4, 14, 2, '2024-11-29', 'Approved', 'Bảo trì HVAC theo đúng lịch trình, phê duyệt'),
(5, 15, 3, '2024-11-30', 'Approved', 'Vệ sinh định kỳ, ưu tiên thấp nhưng cần thực hiện'),
(6, 22, 2, CURDATE(), 'Approved', 'Yêu cầu hôm nay, đã kiểm tra và phê duyệt'),

-- Rejected requests
(7, 16, 2, '2024-11-21', 'Rejected', 'Máy bơm vẫn trong thời gian bảo hành, không cần thay thế toàn bộ'),
(8, 17, 3, '2024-11-22', 'Rejected', 'Biến tần hiện tại hoạt động tốt, không cần nâng cấp'),
(9, 18, 2, '2024-11-23', 'Rejected', 'Chi phí thay thế quá cao, đề xuất sửa chữa thay vì thay mới');

-- ====================================================================
-- 6. MAINTENANCE SCHEDULES (for scheduling testing)
-- ====================================================================

INSERT IGNORE INTO MaintenanceSchedule (scheduleId, requestId, contractId, equipmentId, assignedTo, scheduledDate, scheduleType, recurrenceRule, status, priorityId) VALUES 
-- Scheduled from approved requests
(1, 11, 1, 1, 8, '2024-12-15', 'Request', NULL, 'Scheduled', 2),
(2, 12, 2, 5, 9, '2024-12-16', 'Request', NULL, 'Scheduled', 2),
(3, 13, 3, 7, 10, '2024-12-17', 'Request', NULL, 'Scheduled', 2),
(4, 14, 4, 9, 11, '2024-12-18', 'Request', NULL, 'Scheduled', 2),
(5, 15, 1, 2, 8, '2024-12-19', 'Request', NULL, 'Scheduled', 1),

-- Periodic maintenance schedules
(6, NULL, 1, 1, 8, '2025-01-15', 'Periodic', 'MONTHLY', 'Scheduled', 2),
(7, NULL, 2, 5, 9, '2025-01-20', 'Periodic', 'QUARTERLY', 'Scheduled', 2),
(8, NULL, 3, 7, 10, '2025-02-15', 'Periodic', 'MONTHLY', 'Scheduled', 2),
(9, NULL, 4, 9, 11, '2025-03-01', 'Periodic', 'QUARTERLY', 'Scheduled', 2),

-- Completed schedules
(10, NULL, 1, 2, 8, '2024-11-15', 'Periodic', 'MONTHLY', 'Completed', 2),
(11, NULL, 2, 6, 9, '2024-11-20', 'Periodic', 'QUARTERLY', 'Completed', 2);

-- ====================================================================
-- 7. WORK TASKS (for assignment testing)
-- ====================================================================

INSERT IGNORE INTO WorkTask (taskId, requestId, scheduleId, technicianId, taskType, taskDetails, startDate, endDate, status) VALUES 
-- Tasks from approved requests
(1, 11, 1, 8, 'Request', 'Bảo trì định kỳ máy lạnh: vệ sinh, kiểm tra gas, thay filter', '2024-12-15', '2024-12-15', 'Assigned'),
(2, 12, 2, 9, 'Request', 'Thay thế bộ lọc máy bơm và kiểm tra hệ thống', '2024-12-16', '2024-12-16', 'Assigned'),
(3, 13, 3, 10, 'Request', 'Kiểm tra toàn bộ hệ thống điện, đo điện trở cách điện', '2024-12-17', '2024-12-17', 'Assigned'),
(4, 14, 4, 11, 'Request', 'Bảo trì HVAC: vệ sinh dàn lạnh, kiểm tra hệ thống điều khiển', '2024-12-18', '2024-12-18', 'Assigned'),

-- Scheduled maintenance tasks
(6, NULL, 7, 9, 'Scheduled', 'Bảo trì định kỳ hàng quý máy bơm', '2025-01-20', '2025-01-20', 'Assigned'),

-- Completed tasks
(8, NULL, 11, 9, 'Scheduled', 'Bảo trì quý 4/2024', '2024-11-20', '2024-11-20', 'Completed');

-- ====================================================================
-- 8. REPAIR RESULTS (for completed tasks)
-- ====================================================================

INSERT IGNORE INTO RepairResult (resultId, taskId, details, completionDate, technicianId, status) VALUES 
(1, 7, 'Đã hoàn thành bảo trì định kỳ. Vệ sinh dàn lạnh, thay filter, kiểm tra gas. Máy hoạt động bình thường.', '2024-11-15', 8, 'Completed'),
(2, 8, 'Bảo trì máy bơm hoàn tất. Thay dầu, kiểm tra áp suất, vệ sinh bộ lọc. Không phát hiện vấn đề.', '2024-11-20', 9, 'Completed');

-- ====================================================================
-- 9. ACCOUNT PROFILES (optional - for complete user information)
-- ====================================================================

INSERT IGNORE INTO AccountProfile (profileId, accountId, address, dateOfBirth, nationalId, verified, extraData) VALUES 
(1, 1, 'Tòa nhà CRM, Quận 1, TP.HCM', '1980-01-01', '001080000001', 1, 'System Administrator'),
(2, 2, '123 Nguyễn Văn Cừ, Quận 5, TP.HCM', '1985-05-15', '001085051501', 1, 'Technical Manager - Senior'),
(3, 3, '456 Lê Văn Sỹ, Quận 3, TP.HCM', '1987-08-20', '001087082001', 1, 'Technical Manager - Junior'),
(4, 4, '789 Trần Hưng Đạo, Quận 1, TP.HCM', '1990-03-10', '001090031001', 1, 'VIP Customer'),
(5, 5, '321 Điện Biên Phủ, Quận Bình Thạnh, TP.HCM', '1988-12-25', '001088122501', 1, 'Regular Customer'),
(6, 6, '654 Võ Văn Tần, Quận 3, TP.HCM', '1992-07-18', '001092071801', 1, 'Corporate Customer'),
(7, 7, '987 Nguyễn Thị Minh Khai, Quận 1, TP.HCM', '1989-11-05', '001089110501', 1, 'Premium Customer'),
(8, 8, '147 Lý Thường Kiệt, Quận 10, TP.HCM', '1991-04-22', '001091042201', 1, 'HVAC Specialist'),
(9, 9, '258 Nguyễn Đình Chiểu, Quận 3, TP.HCM', '1993-09-14', '001093091401', 1, 'Electrical Specialist'),
(10, 10, '369 Pasteur, Quận 1, TP.HCM', '1990-06-30', '001090063001', 1, 'Mechanical Specialist'),
(11, 11, '741 Cách Mạng Tháng 8, Quận 10, TP.HCM', '1994-02-28', '001094022801', 1, 'General Technician'),
(12, 12, '852 Hai Bà Trưng, Quận 1, TP.HCM', '1986-10-12', '001086101201', 1, 'Customer Service Lead');

-- ====================================================================
-- VERIFICATION QUERIES
-- ====================================================================
-- Use these queries to verify the test data was inserted correctly:

/*
-- Check pending requests for approval
SELECT sr.requestId, sr.description, sr.priorityLevel, sr.requestDate, 
       c.fullName as customerName, e.model as equipmentModel
FROM ServiceRequest sr
JOIN Account c ON sr.createdBy = c.accountId
JOIN Equipment e ON sr.equipmentId = e.equipmentId
WHERE sr.status = 'Pending'
ORDER BY sr.requestDate DESC;

-- Check approved requests
SELECT sr.requestId, sr.description, ra.decision, ra.approvalDate, ra.note,
       tm.fullName as approvedBy
FROM ServiceRequest sr
JOIN RequestApproval ra ON sr.requestId = ra.requestId
JOIN Account tm ON ra.approvedBy = tm.accountId
WHERE ra.decision = 'Approved'
ORDER BY ra.approvalDate DESC;

-- Check maintenance schedules
SELECT ms.scheduleId, ms.scheduledDate, ms.scheduleType, ms.status,
       t.fullName as technicianName, e.model as equipmentModel
FROM MaintenanceSchedule ms
JOIN Account t ON ms.assignedTo = t.accountId
JOIN Equipment e ON ms.equipmentId = e.equipmentId
ORDER BY ms.scheduledDate;

-- Check statistics for dashboard
SELECT 
    (SELECT COUNT(*) FROM ServiceRequest WHERE status = 'Pending') as pendingRequests,
    (SELECT COUNT(*) FROM ServiceRequest WHERE status = 'Pending' AND priorityLevel = 'Urgent') as urgentRequests,
    (SELECT COUNT(*) FROM ServiceRequest WHERE DATE(requestDate) = CURDATE()) as todayRequests,
    (SELECT COUNT(*) FROM RequestApproval WHERE DATE(approvalDate) = CURDATE() AND decision = 'Approved') as approvedToday;
*/

-- ====================================================================
-- SCRIPT COMPLETION
-- ====================================================================
SELECT 'Technical Manager test data has been successfully inserted!' as Status,
       (SELECT COUNT(*) FROM ServiceRequest WHERE status = 'Pending') as PendingRequests,
       (SELECT COUNT(*) FROM RequestApproval) as TotalApprovals,
       (SELECT COUNT(*) FROM MaintenanceSchedule) as ScheduledMaintenance,
       (SELECT COUNT(*) FROM Account WHERE accountId IN (SELECT accountId FROM AccountRole WHERE roleId = 4)) as TechnicalManagers;

-- ====================================================================
-- ADDITIONAL SEED: CONTRACTS (10 more) + CONTRACT-EQUIPMENT LINKS
-- ====================================================================

-- Contracts 6..15 (customers 4..7 already exist)
INSERT IGNORE INTO Contract (contractId, customerId, contractDate, contractType, status, details) VALUES 
(6, 5, '2024-03-20', 'Bảo trì',    'Active',    'Gia hạn bảo trì bơm nước - Phạm Thị Lan'),
(7, 6, '2024-03-25', 'Bảo hành',   'Active',    'Bảo hành biến tần - Hoàng Văn Minh'),
(8, 7, '2024-04-01', 'Bảo trì',    'Active',    'Bảo trì HVAC trung tâm - Vũ Thị Hoa'),
(9, 4, '2024-04-05', 'Bảo hành',   'Active',    'Bảo hành máy lạnh gia đình - Lê Văn Khách'),
(10, 5,'2024-04-10', 'Bảo trì',    'Active',    'Bảo trì mở rộng cho hệ thống điện'),
(11, 6,'2024-04-15', 'Bảo trì',    'Active', 'Hoàn tất bảo trì quý I'),
(12, 7,'2024-04-20', 'Bảo hành',   'Active',    'Bảo hành thiết bị HVAC công nghiệp'),
(13, 4,'2024-05-01', 'Bảo trì',    'Active',    'Bảo trì định kỳ nửa năm'),
(14, 5,'2024-05-15', 'Bảo trì',    'Active',    'Bảo trì bổ sung phòng làm việc'),
(15, 6,'2024-06-01', 'Bảo hành',   'Active',    'Bảo hành mở rộng cho tủ điện');

-- ContractEquipment for contracts 6..15 (equipment 1..10 exist)
INSERT IGNORE INTO ContractEquipment (contractEquipmentId, contractId, equipmentId, startDate, endDate, quantity, price) VALUES 
(11, 6,  5, '2024-03-20', '2026-03-20', 1, 8000000),
(12, 6,  6, '2024-03-20', '2026-03-20', 1, 12000000),
(13, 7,  8, '2024-03-25', '2026-03-25', 1, 9500000),
(14, 7,  7, '2024-03-25', '2026-03-25', 1, 7500000),
(15, 8,  9, '2024-04-01', '2026-04-01', 1, 26000000),
(16, 8, 10, '2024-04-01', '2026-04-01', 1, 30000000),
(17, 9,  1, '2024-04-05', '2026-04-05', 1, 5200000),
(18, 9,  2, '2024-04-05', '2026-04-05', 1, 6100000),
(19,10,  7, '2024-04-10', '2026-04-10', 1, 15500000),
(20,10,  3, '2024-04-10', '2026-04-10', 1, 7000000),
(21,11,  2, '2024-04-15', '2026-04-15', 1, 6000000),
(22,11,  5, '2024-04-15', '2026-04-15', 1, 8200000),
(23,12,  9, '2024-04-20', '2026-04-20', 1, 25000000),
(24,13,  4, '2024-05-01', '2026-05-01', 1, 6600000),
(25,14,  3, '2024-05-15', '2026-05-15', 1, 5600000),
(26,15,  7, '2024-06-01', '2026-06-01', 1, 15000000);

-- ====================================================================
-- ADDITIONAL SEED: REPAIR REPORTS (12 more, IDs 9301..9312)
-- Link to existing ServiceRequest ids (1..15, 22) and technicians (8..11)
-- ====================================================================

INSERT IGNORE INTO RepairReport
    (reportId, requestId, technicianId, details, diagnosis, estimatedCost, quotationStatus, repairDate, invoiceDetailId)
VALUES
-- Pending reports for current Pending requests (no repairDate yet)
(9301, 1,  8,  'Khảo sát sơ bộ, chờ phê duyệt.',            'Cần vệ sinh và kiểm tra gas.',                  0.00,  'Pending',  NULL, NULL),
(9302, 2,  8,  'Kiểm tra rò nước và mùi.',                  'Nghi bẩn dàn lạnh, cần vệ sinh.',               0.00,  'Pending',  NULL, NULL),
(9303, 3,  9,  'Chẩn đoán tiếng kêu máy bơm.',              'Ổ bi mòn, đề xuất thay.',                       0.00,  'Pending',  NULL, NULL),
(9304, 4, 10,  'Đo nhiệt độ dàn lạnh, kiểm tra gas.',       'Có thể thiếu gas, cần bổ sung.',               0.00,  'Pending',  NULL, NULL),
(9305, 5, 11,  'Kiểm tra lọc gió, khử mùi.',                'Lọc bẩn, cần thay mới.',                        0.00,  'Pending',  NULL, NULL),
(9306, 7, 10,  'Đọc log biến tần, kiểm tra cảnh báo.',      'Quá tải ngắn hạn, theo dõi thêm.',             0.00,  'Pending',  NULL, NULL),
(9307, 9, 11,  'Kiểm tra rò gas hệ thống công nghiệp.',     'Áp suất thấp, cần dò rò và nạp gas.',          0.00,  'Pending',  NULL, NULL),
(9308, 10, 8,  'Kiểm tra mùi cháy, an toàn điện.',          'Tiếp xúc lỏng, cần siết lại đầu nối.',         0.00,  'Pending',  NULL, NULL),
-- Approved requests with completed repairs (provide repairDate and cost)
(9309, 11, 8,  'Bảo trì định kỳ: vệ sinh, kiểm tra gas.',   'Bụi bẩn, thiếu bảo dưỡng định kỳ.',            350000.00, 'Approved', '2024-11-26', NULL),
(9310, 12, 9,  'Thay bộ lọc máy bơm, test áp vận hành.',    'Bộ lọc cũ bẩn gây cản trở lưu lượng.',         420000.00, 'Approved', '2024-11-27', NULL),
(9311, 13,10,  'Siết cos, đo nhiệt, kiểm tra dây dẫn.',     'Tiếp xúc lỏng gây nhiệt cục bộ.',              300000.00, 'Approved', '2024-11-28', NULL),
(9312, 22,8,   'Xử lý nhanh yêu cầu trong ngày.',           'Vệ sinh dàn lạnh và hiệu chỉnh.',             280000.00, 'Approved', CURDATE(),    NULL);

INSERT INTO Account (
    accountId, username, passwordHash, fullName, email, phone, status
) VALUES (
    13,
    'storekeeper1',
    '$2a$12$2RKO9JRG8wKWZKF1cCA.nu28b0wiQKApNKjwuKP.A7mcmcA4Hf.by',
    'Trần Bảo Lâm',
    'lamtranbao1234@gmail.com',
    '1234567891',
    'Active'
);
INSERT INTO AccountProfile (
    profileId, 
    accountId, 
    address, 
    dateOfBirth, 
    avatarUrl, 
    nationalId, 
    verified, 
    extraData
) VALUES (
    13, 
    13, 
    'Hà Nội, Việt Nam', 
    '2000-05-20', 
    'https://example.com/avatar2.png', 
    '012345678912', 
    1, 
    'Khách VIP'
);


UPDATE AccountProfile 
SET address = 'Hà Đông', 
    dateOfBirth = '2005-1-18', 
    avatarUrl = 'https://example.com/avatar2.png', 
    nationalId = '012345678912', 
    verified = 1, 
    extraData = 'UpdateFirst' 
WHERE accountId = 13;


 INSERT INTO AccountRole(AccountId,roleId)
 VALUES(13,5);



INSERT INTO Part VALUES (1, 'Engine Oil Filter', 'High performance oil filter for car engines', 120.50, 2, '2025-10-10');
INSERT INTO Part VALUES (2, 'Air Filter', 'Ensures clean airflow to the engine', 90.00, 2, '2025-10-10');
INSERT INTO Part VALUES (3, 'Brake Pad Set', 'Front brake pad set for compact cars', 450.75, 2, '2025-10-10');
INSERT INTO Part VALUES (4, 'Spark Plug', 'Copper spark plug for gasoline engines', 65.20, 2, '2025-10-10');
INSERT INTO Part VALUES (5, 'Timing Belt', 'Durable rubber belt for engine timing system', 800.00, 2, '2025-10-10');
INSERT INTO Part VALUES (6, 'Battery 12V', 'Maintenance-free 12V car battery', 1500.00, 2, '2025-10-10');
INSERT INTO Part VALUES (7, 'Fuel Pump', 'Electric fuel pump suitable for most sedans', 980.00, 2, '2025-10-10');
INSERT INTO Part VALUES (8, 'Radiator Hose', 'Flexible coolant hose for engine radiator', 180.00, 2, '2025-10-10');
INSERT INTO Part VALUES (9, 'Alternator', 'Generates electricity for car battery and systems', 2150.50, 2, '2025-10-10');
INSERT INTO Part VALUES (10, 'Shock Absorber', 'Rear shock absorber for SUV models', 1250.00, 2, '2025-10-10');
INSERT INTO Part VALUES (11, 'Wiper Blade', 'Durable rubber wiper for clear windshield view', 95.50, 2, '2025-10-10');
INSERT INTO Part VALUES (12, 'Radiator', 'Aluminum radiator for efficient engine cooling', 1750.00, 2, '2025-10-10');
INSERT INTO Part VALUES (13, 'Clutch Plate', 'High-friction clutch plate for manual transmission', 1320.00, 2, '2025-10-10');
INSERT INTO Part VALUES (14, 'Headlight Bulb', 'LED headlight bulb, 6000K white light', 220.00, 2, '2025-10-10');
INSERT INTO Part VALUES (15, 'Tail Light Assembly', 'Rear light assembly for modern cars', 880.50, 2, '2025-10-10');
INSERT INTO Part VALUES (16, 'Engine Mount', 'Rubber mount for reducing engine vibration', 560.00, 2, '2025-10-10');
INSERT INTO Part VALUES (17, 'Drive Belt', 'Multi-ribbed serpentine belt', 330.00, 2, '2025-10-10');
INSERT INTO Part VALUES (18, 'Oxygen Sensor', 'Monitors exhaust gas and optimizes fuel ratio', 710.00, 2, '2025-10-10');
INSERT INTO Part VALUES (19, 'Transmission Fluid', 'High-quality ATF for automatic transmissions', 320.50, 2, '2025-10-10');
INSERT INTO Part VALUES (20, 'Coolant Reservoir', 'Plastic coolant overflow tank for engine system', 275.00, 2, '2025-10-10');
INSERT INTO Part VALUES (21, 'Wheel Bearing', 'High precision wheel bearing for smooth rotation', 450.00, 2, '2025-10-10');
INSERT INTO Part VALUES (22, 'Brake Disc', 'Ventilated front brake disc for sedan', 950.00, 2, '2025-10-10');
INSERT INTO Part VALUES (23, 'Radiator Fan', 'Electric cooling fan for engine radiator', 620.00, 2, '2025-10-10');
INSERT INTO Part VALUES (24, 'AC Compressor', 'Air conditioning compressor unit for car cooling system', 2150.00, 2, '2025-10-10');
INSERT INTO Part VALUES (25, 'Fuel Injector', 'Precision fuel injector for better combustion', 740.00, 2, '2025-10-10');
INSERT INTO Part VALUES (26, 'Throttle Body', 'Controls air intake for efficient engine performance', 890.00, 2, '2025-10-10');
INSERT INTO Part VALUES (27, 'Power Steering Pump', 'Hydraulic pump for smooth steering control', 1300.00, 2, '2025-10-10');
INSERT INTO Part VALUES (28, 'Engine Gasket Set', 'Complete gasket kit for engine sealing', 480.00, 2, '2025-10-10');
INSERT INTO Part VALUES (29, 'Ignition Coil', 'High voltage coil for efficient spark generation', 520.00, 2, '2025-10-10');
INSERT INTO Part VALUES (30, 'Water Pump', 'Circulates coolant through the engine', 600.00, 2, '2025-10-10');
INSERT INTO Part VALUES (31, 'Thermostat', 'Controls engine temperature by regulating coolant flow', 180.00, 2, '2025-10-10');
INSERT INTO Part VALUES (32, 'Fuel Tank Cap', 'Sealed cap to prevent fuel evaporation', 85.00, 2, '2025-10-10');
INSERT INTO Part VALUES (33, 'Crankshaft Sensor', 'Monitors engine speed and crank position', 310.00, 2, '2025-10-10');
INSERT INTO Part VALUES (34, 'Camshaft Sensor', 'Measures camshaft position for precise timing', 290.00, 2, '2025-10-10');
INSERT INTO Part VALUES (35, 'Engine Control Module', 'Central computer controlling engine functions', 3250.00, 2, '2025-10-10');
INSERT INTO Part VALUES (36, 'ABS Sensor', 'Wheel speed sensor for anti-lock braking system', 360.00, 2, '2025-10-10');
INSERT INTO Part VALUES (37, 'Brake Caliper', 'Hydraulic component that squeezes brake pads', 1100.00, 2, '2025-10-10');
INSERT INTO Part VALUES (38, 'Fuel Filter', 'Removes impurities from fuel before combustion', 120.00, 2, '2025-10-10');
INSERT INTO Part VALUES (39, 'Cabin Air Filter', 'Purifies air entering the passenger compartment', 130.00, 2, '2025-10-10');
INSERT INTO Part VALUES (40, 'Rearview Mirror', 'Adjustable mirror for rear visibility', 240.00, 2, '2025-10-10');
INSERT INTO Part VALUES (41, 'Side Mirror', 'Left-side mirror assembly for driver visibility', 320.00, 2, '2025-10-10');
INSERT INTO Part VALUES (42, 'Door Handle', 'Exterior handle for car doors', 180.00, 2, '2025-10-10');
INSERT INTO Part VALUES (43, 'Window Regulator', 'Mechanism for raising and lowering car windows', 640.00, 2, '2025-10-10');
INSERT INTO Part VALUES (44, 'Windshield Washer Pump', 'Pumps washer fluid to windshield', 150.00, 2, '2025-10-10');
INSERT INTO Part VALUES (45, 'Radiator Cap', 'Maintains pressure in the cooling system', 95.00, 2, '2025-10-10');
INSERT INTO Part VALUES (46, 'Fuel Pressure Regulator', 'Maintains proper fuel pressure to injectors', 310.00, 2, '2025-10-10');
INSERT INTO Part VALUES (47, 'Exhaust Pipe', 'Metal pipe to direct exhaust gases from engine', 870.00, 2, '2025-10-10');
INSERT INTO Part VALUES (48, 'Muffler', 'Reduces exhaust noise from engine', 650.00, 2, '2025-10-10');
INSERT INTO Part VALUES (49, 'Catalytic Converter', 'Reduces harmful emissions from exhaust gases', 1850.00, 2, '2025-10-10');
INSERT INTO Part VALUES (50, 'Door Lock Actuator', 'Motor for locking and unlocking doors', 420.00, 2, '2025-10-10');
INSERT INTO Part VALUES (51, 'Engine Valve', 'Controls intake and exhaust gas flow', 210.00, 2, '2025-10-10');
INSERT INTO Part VALUES (52, 'Cylinder Head', 'Covers the top of the cylinders in the engine block', 4100.00, 2, '2025-10-10');
INSERT INTO Part VALUES (53, 'Oil Pan', 'Reservoir for engine oil storage', 770.00, 2, '2025-10-10');
INSERT INTO Part VALUES (54, 'Timing Chain', 'Synchronizes rotation of engine crankshaft and camshaft', 950.00, 2, '2025-10-10');
INSERT INTO Part VALUES (55, 'Valve Cover', 'Covers and seals engine valves', 440.00, 2, '2025-10-10');
INSERT INTO Part VALUES (56, 'Crankshaft', 'Converts linear motion to rotational motion in engine', 5100.00, 2, '2025-10-10');
INSERT INTO Part VALUES (57, 'Piston Ring Set', 'Seals combustion chamber and controls oil consumption', 380.00, 2, '2025-10-10');
INSERT INTO Part VALUES (58, 'Connecting Rod', 'Links piston to crankshaft in the engine', 850.00, 2, '2025-10-10');
INSERT INTO Part VALUES (59, 'Camshaft', 'Controls opening and closing of engine valves', 1800.00, 2, '2025-10-10');
INSERT INTO Part VALUES (60, 'Turbocharger', 'Increases engine power by forcing air into cylinders', 5500.00, 2, '2025-10-10');
INSERT INTO Part VALUES (61, 'Intercooler', 'Cools compressed air from turbocharger', 1450.00, 2, '2025-10-10');
INSERT INTO Part VALUES (62, 'Flywheel', 'Stores rotational energy to smooth engine operation', 2100.00, 2, '2025-10-10');
INSERT INTO Part VALUES (63, 'Clutch Cable', 'Transfers clutch pedal force to clutch system', 250.00, 2, '2025-10-10');
INSERT INTO Part VALUES (64, 'Gearbox Mount', 'Supports gearbox and absorbs vibration', 560.00, 2, '2025-10-10');
INSERT INTO Part VALUES (65, 'Transmission Mount', 'Reduces vibration between engine and transmission', 590.00, 2, '2025-10-10');
INSERT INTO Part VALUES (66, 'Driveshaft', 'Transfers torque from transmission to differential', 2700.00, 2, '2025-10-10');
INSERT INTO Part VALUES (67, 'Axle Shaft', 'Transfers power from differential to wheels', 1950.00, 2, '2025-10-10');
INSERT INTO Part VALUES (68, 'Differential Assembly', 'Distributes torque between drive wheels', 4850.00, 2, '2025-10-10');
INSERT INTO Part VALUES (69, 'Steering Rack', 'Converts steering wheel motion to wheel movement', 2800.00, 2, '2025-10-10');
INSERT INTO Part VALUES (70, 'Ball Joint', 'Connects steering knuckle to control arm', 390.00, 2, '2025-10-10');
INSERT INTO Part VALUES (71, 'Control Arm', 'Connects suspension to the vehicle frame', 1150.00, 2, '2025-10-10');
INSERT INTO Part VALUES (72, 'Stabilizer Bar', 'Reduces body roll during cornering', 670.00, 2, '2025-10-10');
INSERT INTO Part VALUES (73, 'Coil Spring', 'Supports vehicle weight and absorbs shock', 550.00, 2, '2025-10-10');
INSERT INTO Part VALUES (74, 'Leaf Spring', 'Suspension component for trucks and vans', 1250.00, 2, '2025-10-10');
INSERT INTO Part VALUES (75, 'Hub Assembly', 'Wheel hub assembly with bearing', 1450.00, 2, '2025-10-10');
INSERT INTO Part VALUES (76, 'Brake Master Cylinder', 'Supplies hydraulic pressure to brake system', 920.00, 2, '2025-10-10');
INSERT INTO Part VALUES (77, 'Clutch Master Cylinder', 'Hydraulic cylinder for clutch operation', 850.00, 2, '2025-10-10');
INSERT INTO Part VALUES (78, 'Brake Booster', 'Assists braking by amplifying pedal force', 1300.00, 2, '2025-10-10');
INSERT INTO Part VALUES (79, 'Air Conditioning Condenser', 'Dissipates heat from compressed refrigerant', 1650.00, 2, '2025-10-10');
INSERT INTO Part VALUES (80, 'Heater Core', 'Provides heat to cabin from engine coolant', 880.00, 2, '2025-10-10');
INSERT INTO Part VALUES (81, 'Seat Belt', 'Safety belt for driver and passengers', 350.00, 2, '2025-10-10');
INSERT INTO Part VALUES (82, 'Airbag Sensor', 'Triggers airbag deployment during collision', 1250.00, 2, '2025-10-10');
INSERT INTO Part VALUES (83, 'Speedometer Cable', 'Connects transmission to speedometer gauge', 280.00, 2, '2025-10-10');
INSERT INTO Part VALUES (84, 'Head Gasket', 'Seals cylinder head and engine block', 420.00, 2, '2025-10-10');
INSERT INTO Part VALUES (85, 'Brake Hose', 'Carries brake fluid to wheel cylinder', 260.00, 2, '2025-10-10');
INSERT INTO Part VALUES (86, 'Clutch Disc', 'Transfers power between engine and transmission', 980.00, 2, '2025-10-10');
INSERT INTO Part VALUES (87, 'Starter Motor', 'Cranks engine for starting', 2200.00, 2, '2025-10-10');
INSERT INTO Part VALUES (88, 'Alternator Belt', 'Belt for alternator and power steering system', 340.00, 2, '2025-10-10');
INSERT INTO Part VALUES (89, 'Windshield', 'Front glass panel for vehicle cabin', 3100.00, 2, '2025-10-10');
INSERT INTO Part VALUES (90, 'Rear Glass', 'Rear windshield for cars', 2450.00, 2, '2025-10-10');
INSERT INTO Part VALUES (91, 'Door Seal', 'Rubber weatherstrip to prevent water leaks', 180.00, 2, '2025-10-10');
INSERT INTO Part VALUES (92, 'Bonnet Hinge', 'Metal hinge connecting hood to frame', 320.00, 2, '2025-10-10');
INSERT INTO Part VALUES (93, 'Hood Latch', 'Locks hood securely in place', 230.00, 2, '2025-10-10');
INSERT INTO Part VALUES (94, 'Tailgate Strut', 'Gas strut for lifting tailgate', 450.00, 2, '2025-10-10');
INSERT INTO Part VALUES (95, 'License Plate Light', 'Small light to illuminate license plate', 95.00, 2, '2025-10-10');
INSERT INTO Part VALUES (96, 'Fog Light', 'Low-mounted light for fog visibility', 310.00, 2, '2025-10-10');
INSERT INTO Part VALUES (97, 'Horn Assembly', 'Electric horn for vehicle alert sound', 270.00, 2, '2025-10-10');
INSERT INTO Part VALUES (98, 'Battery Cable', 'Connects battery terminals to starter and alternator', 190.00, 2, '2025-10-10');
INSERT INTO Part VALUES (99, 'Fuse Box', 'Houses electrical fuses for protection', 650.00, 2, '2025-10-10');
INSERT INTO Part VALUES (100, 'ECU Connector', 'Electrical connector for vehicle ECU', 210.00, 2, '2025-10-10');



INSERT INTO PartDetail VALUES (1, 1, 'ENG-OIL-001', 'Available', 'Warehouse A1', 2, '2025-10-10');
INSERT INTO PartDetail VALUES (2, 1, 'ENG-OIL-002', 'InUse', 'Garage 3', 2, '2025-10-10');

INSERT INTO PartDetail VALUES (3, 2, 'AIR-FLT-001', 'Available', 'Warehouse A2', 2, '2025-10-10');
INSERT INTO PartDetail VALUES (4, 2, 'AIR-FLT-002', 'Available', 'Warehouse A2', 2, '2025-10-10');

INSERT INTO PartDetail VALUES (5, 3, 'BRK-PAD-001', 'InUse', 'Repair Bay 1', 2, '2025-10-10');
INSERT INTO PartDetail VALUES (6, 3, 'BRK-PAD-002', 'Faulty', 'Returned Zone', 2, '2025-10-10');

INSERT INTO PartDetail VALUES (7, 4, 'SPK-PLG-001', 'Available', 'Warehouse B1', 2, '2025-10-10');
INSERT INTO PartDetail VALUES (8, 4, 'SPK-PLG-002', 'Available', 'Warehouse B1', 2, '2025-10-10');

INSERT INTO PartDetail VALUES (9, 5, 'TMG-BLT-001', 'InUse', 'Garage 1', 2, '2025-10-10');
INSERT INTO PartDetail VALUES (10, 5, 'TMG-BLT-002', 'Available', 'Warehouse C1', 2, '2025-10-10');

INSERT INTO PartDetail VALUES (11, 6, 'BAT-12V-001', 'Available', 'Battery Rack A', 2, '2025-10-10');
INSERT INTO PartDetail VALUES (12, 6, 'BAT-12V-002', 'Retired', 'Recycling Area', 2, '2025-10-10');

INSERT INTO PartDetail VALUES (13, 7, 'FUEL-PMP-001', 'Available', 'Warehouse D1', 2, '2025-10-10');
INSERT INTO PartDetail VALUES (14, 7, 'FUEL-PMP-002', 'InUse', 'Test Car 2', 2, '2025-10-10');

INSERT INTO PartDetail VALUES (15, 8, 'RAD-HOSE-001', 'Available', 'Warehouse D2', 2, '2025-10-10');
INSERT INTO PartDetail VALUES (16, 8, 'RAD-HOSE-002', 'Faulty', 'Return Desk', 2, '2025-10-10');

INSERT INTO PartDetail VALUES (17, 9, 'ALT-001', 'Available', 'Warehouse E1', 2, '2025-10-10');
INSERT INTO PartDetail VALUES (18, 9, 'ALT-002', 'InUse', 'Truck Bay 2', 2, '2025-10-10');

INSERT INTO PartDetail VALUES (19, 10, 'SHK-ABS-001', 'Available', 'Warehouse E2', 2, '2025-10-10');
INSERT INTO PartDetail VALUES (20, 10, 'SHK-ABS-002', 'Faulty', 'Repair Section', 2, '2025-10-10');

INSERT INTO PartDetail VALUES (21, 11, 'WPR-BLD-001', 'Available', 'Warehouse F1', 2, '2025-10-10');
INSERT INTO PartDetail VALUES (22, 11, 'WPR-BLD-002', 'Available', 'Warehouse F1', 2, '2025-10-10');

INSERT INTO PartDetail VALUES (23, 12, 'RAD-001', 'InUse', 'Garage 4', 2, '2025-10-10');
INSERT INTO PartDetail VALUES (24, 12, 'RAD-002', 'Available', 'Warehouse F2', 2, '2025-10-10');

INSERT INTO PartDetail VALUES (25, 13, 'CLT-PLT-001', 'Available', 'Warehouse G1', 2, '2025-10-10');
INSERT INTO PartDetail VALUES (26, 13, 'CLT-PLT-002', 'Faulty', 'Return Zone', 2, '2025-10-10');

INSERT INTO PartDetail VALUES (27, 14, 'HDL-BLB-001', 'Available', 'Warehouse G2', 2, '2025-10-10');
INSERT INTO PartDetail VALUES (28, 14, 'HDL-BLB-002', 'InUse', 'Car Assembly Line', 2, '2025-10-10');

INSERT INTO PartDetail VALUES (29, 15, 'TLG-ASSY-001', 'Available', 'Warehouse H1', 2, '2025-10-10');
INSERT INTO PartDetail VALUES (30, 15, 'TLG-ASSY-002', 'Available', 'Warehouse H1', 2, '2025-10-10');

INSERT INTO PartDetail VALUES (31, 16, 'ENG-MNT-001', 'InUse', 'Garage 2', 2, '2025-10-10');
INSERT INTO PartDetail VALUES (32, 16, 'ENG-MNT-002', 'Available', 'Warehouse I1', 2, '2025-10-10');

INSERT INTO PartDetail VALUES (33, 17, 'DRV-BLT-001', 'Available', 'Warehouse I2', 2, '2025-10-10');
INSERT INTO PartDetail VALUES (34, 17, 'DRV-BLT-002', 'Retired', 'Old Storage', 2, '2025-10-10');

INSERT INTO PartDetail VALUES (35, 18, 'OXY-SEN-001', 'InUse', 'Engine Test Room', 2, '2025-10-10');
INSERT INTO PartDetail VALUES (36, 18, 'OXY-SEN-002', 'Available', 'Warehouse J1', 2, '2025-10-10');

INSERT INTO PartDetail VALUES (37, 19, 'TRN-FLD-001', 'Available', 'Warehouse J2', 2, '2025-10-10');
INSERT INTO PartDetail VALUES (38, 19, 'TRN-FLD-002', 'Available', 'Warehouse J2', 2, '2025-10-10');

INSERT INTO PartDetail VALUES (39, 20, 'COL-RES-001', 'Available', 'Warehouse K1', 2, '2025-10-10');
INSERT INTO PartDetail VALUES (40, 20, 'COL-RES-002', 'Faulty', 'Returned Zone', 2, '2025-10-10');

INSERT INTO Inventory (inventoryId, partId, quantity, lastUpdatedBy, lastUpdatedDate)
VALUES
(1, 1, 120, 2, NOW()),  -- Engine Oil Filter
(2, 2, 80, 2, NOW()),   -- Air Filter
(3, 3, 200, 2, NOW()),  -- Brake Pad Set
(4, 4, 150, 2, NOW()),  -- Spark Plug
(5, 5, 60, 2, NOW()),   -- Timing Belt
(6, 6, 40, 2, NOW()),   -- Battery 12V
(7, 7, 90, 2, NOW()),   -- Fuel Pump
(8, 8, 130, 2, NOW()),  -- Radiator Hose
(9, 9, 35, 2, NOW()),   -- Alternator
(10, 10, 55, 2, NOW()); -- Shock Absorber




INSERT INTO Inventory (inventoryId, partId, quantity, lastUpdatedBy, lastUpdatedDate)
VALUES

(11, 11, 50, 1, CURRENT_DATE),
(12, 12, 60, 1, CURRENT_DATE),
(13, 13, 70, 1, CURRENT_DATE),
(14, 14, 80, 1, CURRENT_DATE),
(15, 15, 90, 1, CURRENT_DATE),
(16, 16, 100, 1, CURRENT_DATE),
(17, 17, 55, 1, CURRENT_DATE),
(18, 18, 65, 1, CURRENT_DATE),
(19, 19, 75, 1, CURRENT_DATE),
(20, 20, 85, 1, CURRENT_DATE),
(21, 21, 50, 1, CURRENT_DATE),
(22, 22, 60, 1, CURRENT_DATE),
(23, 23, 70, 1, CURRENT_DATE),
(24, 24, 80, 1, CURRENT_DATE),
(25, 25, 90, 1, CURRENT_DATE),
(26, 26, 100, 1, CURRENT_DATE),
(27, 27, 55, 1, CURRENT_DATE),
(28, 28, 65, 1, CURRENT_DATE),
(29, 29, 75, 1, CURRENT_DATE),
(30, 30, 85, 1, CURRENT_DATE),
(31, 31, 50, 1, CURRENT_DATE),
(32, 32, 60, 1, CURRENT_DATE),
(33, 33, 70, 1, CURRENT_DATE),
(34, 34, 80, 1, CURRENT_DATE),
(35, 35, 90, 1, CURRENT_DATE),
(36, 36, 100, 1, CURRENT_DATE),
(37, 37, 55, 1, CURRENT_DATE),
(38, 38, 65, 1, CURRENT_DATE),
(39, 39, 75, 1, CURRENT_DATE),
(40, 40, 85, 1, CURRENT_DATE),
(41, 41, 50, 1, CURRENT_DATE),
(42, 42, 60, 1, CURRENT_DATE),
(43, 43, 70, 1, CURRENT_DATE),
(44, 44, 80, 1, CURRENT_DATE),
(45, 45, 90, 1, CURRENT_DATE),
(46, 46, 100, 1, CURRENT_DATE),
(47, 47, 55, 1, CURRENT_DATE),
(48, 48, 65, 1, CURRENT_DATE),
(49, 49, 75, 1, CURRENT_DATE),
(50, 50, 85, 1, CURRENT_DATE),
(51, 51, 50, 1, CURRENT_DATE),
(52, 52, 60, 1, CURRENT_DATE),
(53, 53, 70, 1, CURRENT_DATE),
(54, 54, 80, 1, CURRENT_DATE),
(55, 55, 90, 1, CURRENT_DATE),
(56, 56, 100, 1, CURRENT_DATE),
(57, 57, 55, 1, CURRENT_DATE),
(58, 58, 65, 1, CURRENT_DATE),
(59, 59, 75, 1, CURRENT_DATE),
(60, 60, 85, 1, CURRENT_DATE),
(61, 61, 50, 1, CURRENT_DATE),
(62, 62, 60, 1, CURRENT_DATE),
(63, 63, 70, 1, CURRENT_DATE),
(64, 64, 80, 1, CURRENT_DATE),
(65, 65, 90, 1, CURRENT_DATE),
(66, 66, 100, 1, CURRENT_DATE),
(67, 67, 55, 1, CURRENT_DATE),
(68, 68, 65, 1, CURRENT_DATE),
(69, 69, 75, 1, CURRENT_DATE),
(70, 70, 85, 1, CURRENT_DATE),
(71, 71, 50, 1, CURRENT_DATE),
(72, 72, 60, 1, CURRENT_DATE),
(73, 73, 70, 1, CURRENT_DATE),
(74, 74, 80, 1, CURRENT_DATE),
(75, 75, 90, 1, CURRENT_DATE),
(76, 76, 100, 1, CURRENT_DATE),
(77, 77, 55, 1, CURRENT_DATE),
(78, 78, 65, 1, CURRENT_DATE),
(79, 79, 75, 1, CURRENT_DATE),
(80, 80, 85, 1, CURRENT_DATE),
(81, 81, 50, 1, CURRENT_DATE),
(82, 82, 60, 1, CURRENT_DATE),
(83, 83, 70, 1, CURRENT_DATE),
(84, 84, 80, 1, CURRENT_DATE),
(85, 85, 90, 1, CURRENT_DATE),
(86, 86, 100, 1, CURRENT_DATE),
(87, 87, 55, 1, CURRENT_DATE),
(88, 88, 65, 1, CURRENT_DATE),
(89, 89, 75, 1, CURRENT_DATE),
(90, 90, 85, 1, CURRENT_DATE),
(91, 91, 50, 1, CURRENT_DATE),
(92, 92, 60, 1, CURRENT_DATE),
(93, 93, 70, 1, CURRENT_DATE),
(94, 94, 80, 1, CURRENT_DATE),
(95, 95, 90, 1, CURRENT_DATE),
(96, 96, 100, 1, CURRENT_DATE),
(97, 97, 55, 1, CURRENT_DATE),
(98, 98, 65, 1, CURRENT_DATE),
(99, 99, 75, 1, CURRENT_DATE),
(100, 100, 85, 1, CURRENT_DATE);


INSERT INTO PartDetail (partId, serialNumber, status, location, lastUpdatedBy, lastUpdatedDate) VALUES
(1,'SN001','Available','Kho A',1,CURDATE()),
(2,'SN002','InUse','Kho B',1,CURDATE()),
(3,'SN003','Faulty','Kho C',1,CURDATE()),
(4,'SN004','Retired','Kho D',1,CURDATE()),
(5,'SN005','Available','Kho A',1,CURDATE()),
(6,'SN006','InUse','Kho B',1,CURDATE()),
(7,'SN007','Faulty','Kho C',1,CURDATE()),
(8,'SN008','Retired','Kho D',1,CURDATE()),
(9,'SN009','Available','Kho A',1,CURDATE()),
(10,'SN010','InUse','Kho B',1,CURDATE()),
(11,'SN011','Faulty','Kho C',1,CURDATE()),
(12,'SN012','Retired','Kho D',1,CURDATE()),
(13,'SN013','Available','Kho A',1,CURDATE()),
(14,'SN014','InUse','Kho B',1,CURDATE()),
(15,'SN015','Faulty','Kho C',1,CURDATE()),
(16,'SN016','Retired','Kho D',1,CURDATE()),
(17,'SN017','Available','Kho A',1,CURDATE()),
(18,'SN018','InUse','Kho B',1,CURDATE()),
(19,'SN019','Faulty','Kho C',1,CURDATE()),
(20,'SN020','Retired','Kho D',1,CURDATE()),
(21,'SN021','Available','Kho A',1,CURDATE()),
(22,'SN022','InUse','Kho B',1,CURDATE()),
(23,'SN023','Faulty','Kho C',1,CURDATE()),
(24,'SN024','Retired','Kho D',1,CURDATE()),
(25,'SN025','Available','Kho A',1,CURDATE()),
(26,'SN026','InUse','Kho B',1,CURDATE()),
(27,'SN027','Faulty','Kho C',1,CURDATE()),
(28,'SN028','Retired','Kho D',1,CURDATE()),
(29,'SN029','Available','Kho A',1,CURDATE()),
(30,'SN030','InUse','Kho B',1,CURDATE()),
(31,'SN031','Faulty','Kho C',1,CURDATE()),
(32,'SN032','Retired','Kho D',1,CURDATE()),
(33,'SN033','Available','Kho A',1,CURDATE()),
(34,'SN034','InUse','Kho B',1,CURDATE()),
(35,'SN035','Faulty','Kho C',1,CURDATE()),
(36,'SN036','Retired','Kho D',1,CURDATE()),
(37,'SN037','Available','Kho A',1,CURDATE()),
(38,'SN038','InUse','Kho B',1,CURDATE()),
(39,'SN039','Faulty','Kho C',1,CURDATE()),
(40,'SN040','Retired','Kho D',1,CURDATE()),
(41,'SN041','Available','Kho A',1,CURDATE()),
(42,'SN042','InUse','Kho B',1,CURDATE()),
(43,'SN043','Faulty','Kho C',1,CURDATE()),
(44,'SN044','Retired','Kho D',1,CURDATE()),
(45,'SN045','Available','Kho A',1,CURDATE()),
(46,'SN046','InUse','Kho B',1,CURDATE()),
(47,'SN047','Faulty','Kho C',1,CURDATE()),
(48,'SN048','Retired','Kho D',1,CURDATE()),
(49,'SN049','Available','Kho A',1,CURDATE()),
(50,'SN050','InUse','Kho B',1,CURDATE()),
(51,'SN051','Faulty','Kho C',1,CURDATE()),
(52,'SN052','Retired','Kho D',1,CURDATE()),
(53,'SN053','Available','Kho A',1,CURDATE()),
(54,'SN054','InUse','Kho B',1,CURDATE()),
(55,'SN055','Faulty','Kho C',1,CURDATE()),
(56,'SN056','Retired','Kho D',1,CURDATE()),
(57,'SN057','Available','Kho A',1,CURDATE()),
(58,'SN058','InUse','Kho B',1,CURDATE()),
(59,'SN059','Faulty','Kho C',1,CURDATE()),
(60,'SN060','Retired','Kho D',1,CURDATE()),
(61,'SN061','Available','Kho A',1,CURDATE()),
(62,'SN062','InUse','Kho B',1,CURDATE()),
(63,'SN063','Faulty','Kho C',1,CURDATE()),
(64,'SN064','Retired','Kho D',1,CURDATE()),
(65,'SN065','Available','Kho A',1,CURDATE()),
(66,'SN066','InUse','Kho B',1,CURDATE()),
(67,'SN067','Faulty','Kho C',1,CURDATE()),
(68,'SN068','Retired','Kho D',1,CURDATE()),
(69,'SN069','Available','Kho A',1,CURDATE()),
(70,'SN070','InUse','Kho B',1,CURDATE()),
(71,'SN071','Faulty','Kho C',1,CURDATE()),
(72,'SN072','Retired','Kho D',1,CURDATE()),
(73,'SN073','Available','Kho A',1,CURDATE()),
(74,'SN074','InUse','Kho B',1,CURDATE()),
(75,'SN075','Faulty','Kho C',1,CURDATE()),
(76,'SN076','Retired','Kho D',1,CURDATE()),
(77,'SN077','Available','Kho A',1,CURDATE()),
(78,'SN078','InUse','Kho B',1,CURDATE()),
(79,'SN079','Faulty','Kho C',1,CURDATE()),
(80,'SN080','Retired','Kho D',1,CURDATE()),
(81,'SN081','Available','Kho A',1,CURDATE()),
(82,'SN082','InUse','Kho B',1,CURDATE()),
(83,'SN083','Faulty','Kho C',1,CURDATE()),
(84,'SN084','Retired','Kho D',1,CURDATE()),
(85,'SN085','Available','Kho A',1,CURDATE()),
(86,'SN086','InUse','Kho B',1,CURDATE()),
(87,'SN087','Faulty','Kho C',1,CURDATE()),
(88,'SN088','Retired','Kho D',1,CURDATE()),
(89,'SN089','Available','Kho A',1,CURDATE()),
(90,'SN090','InUse','Kho B',1,CURDATE()),
(91,'SN091','Faulty','Kho C',1,CURDATE()),
(92,'SN092','Retired','Kho D',1,CURDATE()),
(93,'SN093','Available','Kho A',1,CURDATE()),
(94,'SN094','InUse','Kho B',1,CURDATE()),
(95,'SN095','Faulty','Kho C',1,CURDATE()),
(96,'SN096','Retired','Kho D',1,CURDATE()),
(97,'SN097','Available','Kho A',1,CURDATE()),
(98,'SN098','InUse','Kho B',1,CURDATE()),
(99,'SN099','Faulty','Kho C',1,CURDATE()),
(100,'SN100','Retired','Kho D',1,CURDATE());


INSERT INTO PartDetail ( partId, serialNumber, status, location, lastUpdatedBy, lastUpdatedDate) VALUES
( 2, 'Air Filter #001', 'Available', 'Warehouse A', 1, '2025-10-15'),
( 2, 'Air Filter #002', 'Available', 'Warehouse A', 1, '2025-10-15'),
( 2, 'Air Filter #003', 'InUse', 'Garage 1', 2, '2025-10-14'),
( 2, 'Air Filter #004', 'Faulty', 'Repair Zone', 3, '2025-10-13'),
( 2, 'Air Filter #005', 'Available', 'Warehouse B', 1, '2025-10-15'),
( 2, 'Air Filter #006', 'Available', 'Warehouse A', 1, '2025-10-15'),
( 2, 'Air Filter #007', 'Retired', 'Storage Room', 2, '2025-10-10'),
( 2, 'Air Filter #008', 'Available', 'Warehouse C', 1, '2025-10-15'),
( 2, 'Air Filter #009', 'InUse', 'Garage 2', 2, '2025-10-14'),
( 2, 'Air Filter #010', 'Available', 'Warehouse B', 1, '2025-10-15');

INSERT INTO PartDetail ( partId, serialNumber, status, location, lastUpdatedBy, lastUpdatedDate) VALUES
( 3, 'Brake Pad Set #001', 'Available', 'Warehouse A', 1, '2025-10-15'),
( 3, 'Brake Pad Set #002', 'Available', 'Warehouse A', 1, '2025-10-15'),
( 3, 'Brake Pad Set #003', 'InUse', 'Garage 1', 2, '2025-10-14'),
( 3, 'Brake Pad Set #004', 'Faulty', 'Repair Zone', 3, '2025-10-13'),
( 3, 'Brake Pad Set #005', 'Available', 'Warehouse B', 1, '2025-10-15'),
( 3, 'Brake Pad Set #006', 'Available', 'Warehouse A', 1, '2025-10-15'),
( 3, 'Brake Pad Set #007', 'Available', 'Warehouse C', 1, '2025-10-15'),
( 3, 'Brake Pad Set #008', 'Retired', 'Storage Room', 2, '2025-10-12'),
( 3, 'Brake Pad Set #009', 'Available', 'Warehouse B', 1, '2025-10-15'),
( 3, 'Brake Pad Set #010', 'InUse', 'Garage 2', 2, '2025-10-14'),
( 3, 'Brake Pad Set #011', 'Available', 'Warehouse A', 1, '2025-10-15'),
( 3, 'Brake Pad Set #012', 'Available', 'Warehouse C', 1, '2025-10-15'),
( 3, 'Brake Pad Set #013', 'Faulty', 'Repair Zone', 3, '2025-10-13'),
( 3, 'Brake Pad Set #014', 'Available', 'Warehouse A', 1, '2025-10-15'),
( 3, 'Brake Pad Set #015', 'Available', 'Warehouse B', 1, '2025-10-15');

alter table MaintenanceSchedule modify scheduledDate datetime not null;

-- TECHNICIAN MODULE DEMO SEED (Technician accountId = 8)
-- Creates 10 requests from real customers (4..7), approved by manager (2),
-- scheduled and tasked for technician 8 with logical dates.
-- Id ranges: 201..210 to avoid collision.

START TRANSACTION;

-- 1) Service Requests (initially Pending)
INSERT IGNORE INTO ServiceRequest
(requestId, contractId, equipmentId, createdBy, description, priorityLevel, requestDate, status, requestType)
VALUES
-- Past (to be completed)
(201, 1, 1, 4, 'Bảo trì máy lạnh phòng khách: vệ sinh và kiểm tra gas.', 'High',    DATE_SUB(CURDATE(), INTERVAL 30 DAY), 'Awaiting Approval', 'Service'),
(202, 2, 5, 5, 'Máy bơm nước kêu to khi chạy, kiểm tra ổ bi.',           'Normal',  DATE_SUB(CURDATE(), INTERVAL 27 DAY), 'Awaiting Approval', 'Warranty'),
(203, 3, 7, 6, 'Tủ điện báo nhiệt cao, kiểm tra kết nối.',               'High',    DATE_SUB(CURDATE(), INTERVAL 22 DAY), 'Awaiting Approval', 'Service'),
(204, 4, 9, 7, 'HVAC không đạt nhiệt độ cài đặt, kiểm tra gas.',         'Urgent',  DATE_SUB(CURDATE(), INTERVAL 18 DAY), 'Awaiting Approval', 'Service'),
(205, 5, 4, 4, 'Máy lạnh phòng ngủ mùi lạ, kiểm tra lọc.',               'Normal',  DATE_SUB(CURDATE(), INTERVAL 14 DAY), 'Awaiting Approval', 'Service'),
(206, 2, 6, 5, 'Máy bơm rò nước, kiểm tra phớt.',                        'High',    DATE_SUB(CURDATE(), INTERVAL 11 DAY), 'Awaiting Approval', 'Warranty'),
-- Today/nearby (active work)
(207, 3, 8, 6, 'Kiểm tra cảnh báo biến tần.',                             'Normal',  DATE_SUB(CURDATE(), INTERVAL 1 DAY), 'Awaiting Approval', 'Service'),
-- Future (scheduled)
(208, 1, 2, 4, 'Bảo trì định kỳ máy lạnh phòng ngủ.',                     'Low',     CURDATE(),                               'Awaiting Approval', 'Service'),
(209, 4, 10, 7, 'Kiểm tra HVAC định kỳ quý.',                             'Normal',  CURDATE(),                               'Awaiting Approval', 'Service'),
(210, 5, 3, 4, 'Bảo trì mở rộng, vệ sinh và đo áp suất.',                 'High',    CURDATE(),                               'Awaiting Approval', 'Service');

-- 2) Approvals by Technical Manager (accountId=2), assigning technician 8
INSERT IGNORE INTO RequestApproval
(approvalId, requestId, approvedBy, approvalDate, decision, note, estimatedEffort, assignedTechnicianId)
VALUES
(201, 201, 2, DATE_SUB(CURDATE(), INTERVAL 29 DAY), 'Approved', 'Xử lý trong ngày.', 2.0, 8),
(202, 202, 2, DATE_SUB(CURDATE(), INTERVAL 26 DAY), 'Approved', 'Chẩn đoán tiếng ồn.', 2.0, 8),
(203, 203, 2, DATE_SUB(CURDATE(), INTERVAL 21 DAY), 'Approved', 'Kiểm tra nhiệt và siết lại.', 2.5, 8),
(204, 204, 2, DATE_SUB(CURDATE(), INTERVAL 17 DAY), 'Approved', 'Ưu tiên cao.', 3.0, 8),
(205, 205, 2, DATE_SUB(CURDATE(), INTERVAL 13 DAY), 'Approved', 'Vệ sinh lọc và test mùi.', 1.5, 8),
(206, 206, 2, DATE_SUB(CURDATE(), INTERVAL 10 DAY), 'Approved', 'Kiểm tra phớt và rò rỉ.', 2.0, 8),
(207, 207, 2, DATE_SUB(CURDATE(), INTERVAL 0 DAY),  'Approved', 'Xử lý cảnh báo.', 1.5, 8),
(208, 208, 2, DATE_ADD(CURDATE(), INTERVAL 0 DAY),  'Approved', 'Lịch định kỳ.', 2.0, 8),
(209, 209, 2, DATE_ADD(CURDATE(), INTERVAL 0 DAY),  'Approved', 'Lịch quý.', 2.5, 8),
(210, 210, 2, DATE_ADD(CURDATE(), INTERVAL 0 DAY),  'Approved', 'Bảo trì mở rộng.', 3.0, 8);

-- Reflect approval in ServiceRequest
UPDATE ServiceRequest SET status = 'Approved' WHERE requestId BETWEEN 201 AND 210;

-- 3) Maintenance Schedules for technician 8
-- Past -> Completed, Today -> In progress/Assigned, Future -> Scheduled
INSERT IGNORE INTO MaintenanceSchedule
(scheduleId, requestId, contractId, equipmentId, assignedTo, scheduledDate, scheduleType, recurrenceRule, status, priorityId, createdBy, estimatedDuration)
VALUES
-- Past completed (spread out)
(201, 201, 1, 1, 8, DATE_SUB(CURDATE(), INTERVAL 28 DAY), 'Request', NULL, 'Completed', 3, 2, 2.0),
(202, 202, 2, 5, 8, DATE_SUB(CURDATE(), INTERVAL 25 DAY), 'Request', NULL, 'Completed', 2, 2, 2.0),
(203, 203, 3, 7, 8, DATE_SUB(CURDATE(), INTERVAL 20 DAY), 'Request', NULL, 'Completed', 3, 2, 2.5),
(204, 204, 4, 9, 8, DATE_SUB(CURDATE(), INTERVAL 16 DAY), 'Request', NULL, 'Completed', 4, 2, 3.0),
(205, 205, 5, 4, 8, DATE_SUB(CURDATE(), INTERVAL 12 DAY), 'Request', NULL, 'Completed', 2, 2, 1.5),
(206, 206, 2, 6, 8, DATE_SUB(CURDATE(), INTERVAL 9 DAY),  'Request', NULL, 'Completed', 3, 2, 2.0),
-- Today/near-term
(207, 207, 3, 8, 8, CURDATE(),                           'Request', NULL, 'Scheduled', 2, 2, 1.5),
-- Future scheduled
(208, 208, 1, 2, 8, DATE_ADD(CURDATE(), INTERVAL 3 DAY),  'Request', NULL, 'Scheduled', 1, 2, 2.0),
(209, 209, 4, 10,8, DATE_ADD(CURDATE(), INTERVAL 7 DAY),  'Request', NULL, 'Scheduled', 2, 2, 2.5),
(210, 210, 5, 3, 8, DATE_ADD(CURDATE(), INTERVAL 14 DAY), 'Request', NULL, 'Scheduled', 3, 2, 3.0);

-- 4) Work Tasks for technician 8
INSERT IGNORE INTO WorkTask
(taskId, requestId, scheduleId, technicianId, taskType, taskDetails, startDate, endDate, status)
VALUES
-- Past completed (endDate same day)
(201, 201, 201, 8, 'Request', 'Vệ sinh dàn lạnh, bổ sung gas nếu cần.', DATE_SUB(CURDATE(), INTERVAL 28 DAY), DATE_SUB(CURDATE(), INTERVAL 28 DAY), 'Completed'),
(202, 202, 202, 8, 'Request', 'Kiểm tra ổ bi, cân chỉnh, test tiếng ồn.', DATE_SUB(CURDATE(), INTERVAL 25 DAY), DATE_SUB(CURDATE(), INTERVAL 25 DAY), 'Completed'),
(203, 203, 203, 8, 'Request', 'Siết lại đầu nối, kiểm tra nhiệt độ tủ điện.', DATE_SUB(CURDATE(), INTERVAL 20 DAY), DATE_SUB(CURDATE(), INTERVAL 20 DAY), 'Completed'),
(204, 204, 204, 8, 'Request', 'Kiểm tra rò rỉ gas, hiệu chỉnh hệ thống.', DATE_SUB(CURDATE(), INTERVAL 16 DAY), DATE_SUB(CURDATE(), INTERVAL 16 DAY), 'Completed'),
(205, 205, 205, 8, 'Request', 'Vệ sinh lọc gió, khử mùi, test vận hành.', DATE_SUB(CURDATE(), INTERVAL 12 DAY), DATE_SUB(CURDATE(), INTERVAL 12 DAY), 'Completed'),
(206, 206, 206, 8, 'Request', 'Thay phớt bơm, test rò rỉ sau thay.', DATE_SUB(CURDATE(), INTERVAL 9 DAY), DATE_SUB(CURDATE(), INTERVAL 9 DAY), 'Completed'),
-- Today / near-term (active)
(207, 207, 207, 8, 'Request', 'Xử lý cảnh báo biến tần, kiểm tra nhật ký lỗi.', CURDATE(), NULL, 'Assigned'),
-- Future (scheduled)
(208, 208, 208, 8, 'Request', 'Bảo trì định kỳ máy lạnh phòng ngủ.', NULL, NULL, 'Assigned'),
(209, 209, 209, 8, 'Request', 'Bảo trì định kỳ hệ thống HVAC.', NULL, NULL, 'Assigned'),
(210, 210, 210, 8, 'Request', 'Bảo trì mở rộng, kiểm tra tổng thể.', NULL, NULL, 'Assigned');

-- 5) Repair Results for completed tasks (show history quality)
INSERT IGNORE INTO RepairResult
(resultId, taskId, details, completionDate, technicianId, status)
VALUES
(201, 201, 'Vệ sinh và kiểm tra gas hoàn tất, hoạt động bình thường.', DATE_SUB(CURDATE(), INTERVAL 28 DAY), 8, 'Completed'),
(202, 202, 'Ổ bi đã được xử lý, tiếng ồn giảm, test đạt.', DATE_SUB(CURDATE(), INTERVAL 25 DAY), 8, 'Completed'),
(203, 203, 'Nhiệt độ tủ điện ổn định sau khi siết lại.', DATE_SUB(CURDATE(), INTERVAL 20 DAY), 8, 'Completed'),
(204, 204, 'Không phát hiện rò rỉ, hiệu chỉnh cấu hình HVAC.', DATE_SUB(CURDATE(), INTERVAL 16 DAY), 8, 'Completed'),
(205, 205, 'Đã khử mùi và vệ sinh lọc, cảm giác mùi hết.', DATE_SUB(CURDATE(), INTERVAL 12 DAY), 8, 'Completed'),
(206, 206, 'Thay phớt thành công, không còn rò nước.', DATE_SUB(CURDATE(), INTERVAL 9 DAY), 8, 'Completed');

COMMIT;

-- Optional quick checks (read-only)
-- SELECT wt.taskId, wt.status, sr.createdBy AS customerId, ms.contractId, ms.equipmentId
-- FROM WorkTask wt
-- JOIN MaintenanceSchedule ms ON wt.scheduleId = ms.scheduleId
-- JOIN ServiceRequest sr ON wt.requestId = sr.requestId
-- WHERE wt.technicianId = 8 AND wt.taskId BETWEEN 201 AND 210
-- ORDER BY wt.taskId;


-- TECHNICIAN REPAIR REPORTS SEED (Technician 8) – safe to append to db_new.sql
-- Uses existing ServiceRequest ids: 201..210
-- reportId range: 9201..9210 to avoid collisions

START TRANSACTION;

INSERT IGNORE INTO RepairReport
(reportId, requestId, technicianId, details, diagnosis, estimatedCost, quotationStatus, repairDate, invoiceDetailId)
VALUES
-- Past completed jobs (match earlier scheduled/completed timeline)
(9201, 201, 8,
 'Vệ sinh dàn lạnh, kiểm tra áp suất gas, siết lại đầu nối.',
 'Bụi bẩn và thiếu bảo dưỡng định kỳ làm giảm hiệu suất.',
 450000.00, 'Approved', DATE_SUB(CURDATE(), INTERVAL 28 DAY), NULL),

(9202, 202, 8,
 'Kiểm tra tiếng ồn máy bơm, cân chỉnh và bôi trơn ổ bi.',
 'Mòn ổ bi dẫn đến rung và tiếng ồn cao.',
 520000.00, 'Approved', DATE_SUB(CURDATE(), INTERVAL 25 DAY), NULL),

(9203, 203, 8,
 'Kiểm tra tủ điện, siết lại đầu cos, đo nhiệt các điểm tiếp xúc.',
 'Tiếp xúc lỏng làm tăng nhiệt cục bộ.',
 380000.00, 'Approved', DATE_SUB(CURDATE(), INTERVAL 20 DAY), NULL),

(9204, 204, 8,
 'Kiểm tra rò rỉ và hiệu chỉnh cấu hình HVAC, test vận hành.',
 'Cài đặt điều khiển chưa tối ưu, không phát hiện rò rỉ.',
 650000.00, 'Approved', DATE_SUB(CURDATE(), INTERVAL 16 DAY), NULL),

(9205, 205, 8,
 'Vệ sinh lọc gió, khử mùi, kiểm tra cảm biến nhiệt.',
 'Lọc bẩn gây mùi, cảm biến hoạt động bình thường.',
 300000.00, 'Approved', DATE_SUB(CURDATE(), INTERVAL 12 DAY), NULL),

(9206, 206, 8,
 'Thay phớt bơm, kiểm tra rò sau thay, test áp vận hành.',
 'Phớt cũ chai cứng gây rò nước.',
 570000.00, 'Approved', DATE_SUB(CURDATE(), INTERVAL 9 DAY), NULL),

-- Today / near-term (work ongoing) – keep repairDate NULL
(9207, 207, 8,
 'Kiểm tra cảnh báo biến tần, đọc nhật ký lỗi, kiểm tra tải.',
 'Cảnh báo do quá tải ngắn hạn, cần theo dõi thêm.',
 0.00, 'Pending', NULL, NULL),

-- Future scheduled – planning report placeholders (optional drafts)
(9208, 208, 8,
 'Bảo trì định kỳ máy lạnh phòng ngủ: vệ sinh, kiểm tra gas.',
 'Dự kiến vệ sinh và hiệu chỉnh nhẹ.',
 0.00, 'Pending', NULL, NULL),

(9209, 209, 8,
 'Bảo trì định kỳ hệ thống HVAC: kiểm tra trao đổi nhiệt, cảm biến.',
 'Dự kiến hiệu chỉnh thông số điều khiển.',
 0.00, 'Pending', NULL, NULL),

(9210, 210, 8,
 'Bảo trì mở rộng: kiểm tra tổng thể, đo áp suất, vệ sinh hệ thống.',
 'Dự kiến thay lọc và tối ưu cấu hình.',
 0.00, 'Pending', NULL, NULL);

COMMIT;

-- Optional quick check:
-- SELECT rr.reportId, rr.requestId, rr.technicianId, rr.quotationStatus, rr.repairDate
-- FROM RepairReport rr
-- WHERE rr.reportId BETWEEN 9201 AND 9210
-- ORDER BY rr.reportId;

START TRANSACTION;

UPDATE RepairReport rr
LEFT JOIN WorkTask wt 
  ON wt.requestId = rr.requestId AND wt.technicianId = rr.technicianId
LEFT JOIN MaintenanceSchedule ms 
  ON ms.requestId = rr.requestId AND ms.assignedTo = rr.technicianId
LEFT JOIN ServiceRequest sr 
  ON sr.requestId = rr.requestId
SET rr.repairDate = COALESCE(
    wt.endDate,
    wt.startDate,
    ms.scheduledDate,
    DATE(sr.requestDate),
    CURDATE()
)
WHERE rr.reportId IN (9308, 9302, 9301, 9210, 9209, 9208, 9207)
  AND rr.repairDate IS NULL;

COMMIT;

START TRANSACTION;

-- 1) For tasks 208..210: set startDate from MaintenanceSchedule.scheduledDate if missing
UPDATE WorkTask wt
JOIN MaintenanceSchedule ms ON ms.scheduleId = wt.scheduleId
SET wt.startDate = ms.scheduledDate
WHERE wt.taskId IN (208,209,210)
  AND wt.startDate IS NULL;

-- 2) For task 207: if startDate is missing (safety), set it from schedule or request date or today
UPDATE WorkTask wt
LEFT JOIN MaintenanceSchedule ms ON ms.scheduleId = wt.scheduleId
LEFT JOIN ServiceRequest sr ON sr.requestId = wt.requestId
SET wt.startDate = COALESCE(wt.startDate, ms.scheduledDate, DATE(sr.requestDate), CURDATE())
WHERE wt.taskId = 207
  AND wt.startDate IS NULL;

-- 3) For any Assigned tasks among 207..210: ensure endDate stays NULL (clean future/active tasks)
UPDATE WorkTask
SET endDate = NULL
WHERE taskId IN (207,208,209,210)
  AND status = 'Assigned';

-- LamTB
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS PartDetailStatusHistory;
DROP TABLE IF EXISTS PartDetail;
DROP TABLE IF EXISTS Part;
DROP TABLE IF EXISTS Equipment;
DROP TABLE IF EXISTS Category;
SET FOREIGN_KEY_CHECKS = 1;

-- Bảng Category với phân loại rõ ràng
CREATE TABLE Category (
    categoryId INT AUTO_INCREMENT PRIMARY KEY,
    categoryName VARCHAR(50) NOT NULL UNIQUE,
    type VARCHAR(20) NOT NULL CHECK (type IN ('Equipment', 'Part')),
    INDEX idx_category_type (type)
);

-- Bảng Part - Linh kiện/phụ tùng (không thể hoạt động độc lập)
CREATE TABLE Part (
    partId INT AUTO_INCREMENT PRIMARY KEY,
    partName VARCHAR(100) NOT NULL,
    description VARCHAR(255),
    unitPrice DECIMAL(12,2),
    categoryId INT NULL,
    lastUpdatedBy INT NOT NULL,
    lastUpdatedDate DATE NOT NULL,
    FOREIGN KEY (categoryId) REFERENCES Category(categoryId),
    FOREIGN KEY (lastUpdatedBy) REFERENCES Account(accountId)
);

-- Bảng PartDetail - Chi tiết từng linh kiện cụ thể
CREATE TABLE PartDetail (
    partDetailId INT AUTO_INCREMENT PRIMARY KEY,
    partId INT NOT NULL,
    serialNumber VARCHAR(100) UNIQUE NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('Available','InUse','Faulty','Retired')),
    location VARCHAR(255),
    categoryId INT NULL,
    lastUpdatedBy INT NOT NULL,
    lastUpdatedDate DATE NOT NULL,
    FOREIGN KEY (partId) REFERENCES Part(partId),
    FOREIGN KEY (categoryId) REFERENCES Category(categoryId),
    FOREIGN KEY (lastUpdatedBy) REFERENCES Account(accountId)
);

-- Bảng lịch sử thay đổi trạng thái PartDetail
CREATE TABLE PartDetailStatusHistory (
    historyId INT AUTO_INCREMENT PRIMARY KEY,
    partDetailId INT NOT NULL,
    oldStatus VARCHAR(20),
    newStatus VARCHAR(20) NOT NULL,
    changedBy INT NOT NULL,
    changedDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    notes VARCHAR(255),
    categoryId INT NULL,
    FOREIGN KEY (partDetailId) REFERENCES PartDetail(partDetailId) ON DELETE CASCADE,
    FOREIGN KEY (categoryId) REFERENCES Category(categoryId),
    FOREIGN KEY (changedBy) REFERENCES Account(accountId)
);

-- Bảng Equipment - Thiết bị hoàn chỉnh (có thể hoạt động độc lập)
CREATE TABLE Equipment (
    equipmentId INT AUTO_INCREMENT PRIMARY KEY,
    serialNumber VARCHAR(100) UNIQUE NOT NULL,
    model VARCHAR(100),
    description VARCHAR(255),
    installDate DATE,
    categoryId INT NULL,
    lastUpdatedBy INT NOT NULL,
    lastUpdatedDate DATE NOT NULL,
    FOREIGN KEY (categoryId) REFERENCES Category(categoryId),
    FOREIGN KEY (lastUpdatedBy) REFERENCES Account(accountId)
);

-- ========================================
-- TRIGGERS để kiểm tra categoryId type
-- ========================================

DELIMITER //

-- Trigger kiểm tra Part categoryId phải là type='Part'
CREATE TRIGGER trg_part_category_check_insert
BEFORE INSERT ON Part
FOR EACH ROW
BEGIN
    DECLARE cat_type VARCHAR(20);
    
    IF NEW.categoryId IS NOT NULL THEN
        SELECT type INTO cat_type FROM Category WHERE categoryId = NEW.categoryId;
        
        IF cat_type != 'Part' THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Part categoryId must be of type Part';
        END IF;
    END IF;
END//

CREATE TRIGGER trg_part_category_check_update
BEFORE UPDATE ON Part
FOR EACH ROW
BEGIN
    DECLARE cat_type VARCHAR(20);
    
    IF NEW.categoryId IS NOT NULL THEN
        SELECT type INTO cat_type FROM Category WHERE categoryId = NEW.categoryId;
        
        IF cat_type != 'Part' THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Part categoryId must be of type Part';
        END IF;
    END IF;
END//

-- Trigger kiểm tra PartDetail categoryId phải là type='Part'
CREATE TRIGGER trg_partdetail_category_check_insert
BEFORE INSERT ON PartDetail
FOR EACH ROW
BEGIN
    DECLARE cat_type VARCHAR(20);
    
    IF NEW.categoryId IS NOT NULL THEN
        SELECT type INTO cat_type FROM Category WHERE categoryId = NEW.categoryId;
        
        IF cat_type != 'Part' THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'PartDetail categoryId must be of type Part';
        END IF;
    END IF;
END//

CREATE TRIGGER trg_partdetail_category_check_update
BEFORE UPDATE ON PartDetail
FOR EACH ROW
BEGIN
    DECLARE cat_type VARCHAR(20);
    
    IF NEW.categoryId IS NOT NULL THEN
        SELECT type INTO cat_type FROM Category WHERE categoryId = NEW.categoryId;
        
        IF cat_type != 'Part' THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'PartDetail categoryId must be of type Part';
        END IF;
    END IF;
END//

-- Trigger kiểm tra PartDetailStatusHistory categoryId phải là type='Part'
CREATE TRIGGER trg_history_category_check_insert
BEFORE INSERT ON PartDetailStatusHistory
FOR EACH ROW
BEGIN
    DECLARE cat_type VARCHAR(20);
    
    IF NEW.categoryId IS NOT NULL THEN
        SELECT type INTO cat_type FROM Category WHERE categoryId = NEW.categoryId;
        
        IF cat_type != 'Part' THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'PartDetailStatusHistory categoryId must be of type Part';
        END IF;
    END IF;
END//

CREATE TRIGGER trg_history_category_check_update
BEFORE UPDATE ON PartDetailStatusHistory
FOR EACH ROW
BEGIN
    DECLARE cat_type VARCHAR(20);
    
    IF NEW.categoryId IS NOT NULL THEN
        SELECT type INTO cat_type FROM Category WHERE categoryId = NEW.categoryId;
        
        IF cat_type != 'Part' THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'PartDetailStatusHistory categoryId must be of type Part';
        END IF;
    END IF;
END//

-- Trigger kiểm tra Equipment categoryId phải là type='Equipment'
CREATE TRIGGER trg_equipment_category_check_insert
BEFORE INSERT ON Equipment
FOR EACH ROW
BEGIN
    DECLARE cat_type VARCHAR(20);
    
    IF NEW.categoryId IS NOT NULL THEN
        SELECT type INTO cat_type FROM Category WHERE categoryId = NEW.categoryId;
        
        IF cat_type != 'Equipment' THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Equipment categoryId must be of type Equipment';
        END IF;
    END IF;
END//

CREATE TRIGGER trg_equipment_category_check_update
BEFORE UPDATE ON Equipment
FOR EACH ROW
BEGIN
    DECLARE cat_type VARCHAR(20);
    
    IF NEW.categoryId IS NOT NULL THEN
        SELECT type INTO cat_type FROM Category WHERE categoryId = NEW.categoryId;
        
        IF cat_type != 'Equipment' THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Equipment categoryId must be of type Equipment';
        END IF;
    END IF;
END//

DELIMITER ;

-- ========================================
-- DỮ LIỆU MẪU
-- ========================================

-- Categories cho Part (linh kiện/phụ tùng)
INSERT INTO Category VALUES (1, 'HVAC Components', 'Part');
INSERT INTO Category VALUES (2, 'Pump Components', 'Part');
INSERT INTO Category VALUES (3, 'Electrical Components', 'Part');
INSERT INTO Category VALUES (4, 'Elevator Components', 'Part');
INSERT INTO Category VALUES (5, 'Cooling Components', 'Part');

-- Categories cho Equipment (thiết bị hoàn chỉnh)
INSERT INTO Category VALUES (6, 'HVAC System', 'Equipment');
INSERT INTO Category VALUES (7, 'Industrial Pump', 'Equipment');
INSERT INTO Category VALUES (8, 'Power System', 'Equipment');
INSERT INTO Category VALUES (9, 'Lighting System', 'Equipment');
INSERT INTO Category VALUES (10, 'Control System', 'Equipment');
INSERT INTO Category VALUES (11, 'Elevator System', 'Equipment');
INSERT INTO Category VALUES (12, 'Fire Protection System', 'Equipment');
INSERT INTO Category VALUES (13, 'Air Conditioning Unit', 'Equipment');

-- Part: Các linh kiện/phụ tùng cho thiết bị tòa nhà
INSERT INTO Part (partId, partName, description, unitPrice, categoryId, lastUpdatedBy, lastUpdatedDate) VALUES
-- HVAC Components (Category 1)
(1, 'Air Filter HEPA', 'High efficiency air filter for HVAC system', 850.00, 1, 2, '2025-10-10'),
(2, 'Compressor Motor', '3HP compressor motor for AC unit', 4500.00, 1, 2, '2025-10-10'),
(3, 'Evaporator Coil', 'Copper evaporator coil for cooling', 3200.00, 1, 2, '2025-10-10'),
(4, 'Condenser Fan Blade', 'Metal fan blade for condenser unit', 680.00, 1, 2, '2025-10-10'),
(5, 'Thermostat Controller', 'Digital thermostat for temperature control', 1250.00, 1, 2, '2025-10-10'),

-- Pump Components (Category 2)
(6, 'Pump Impeller', 'Stainless steel impeller for water pump', 2100.00, 2, 2, '2025-10-10'),
(7, 'Mechanical Seal', 'High-pressure mechanical seal for pump', 890.00, 2, 2, '2025-10-10'),
(8, 'Pump Motor Bearing', 'Heavy duty bearing for pump motor', 560.00, 2, 2, '2025-10-10'),
(9, 'Pressure Gauge', 'Digital pressure gauge 0-10 bar', 450.00, 2, 2, '2025-10-10'),
(10, 'Check Valve', 'Non-return valve for water system', 720.00, 2, 2, '2025-10-10'),

-- Electrical Components (Category 3)
(11, 'Circuit Breaker 3P', 'Three-phase circuit breaker 100A', 1850.00, 3, 2, '2025-10-10'),
(12, 'Contactor 50A', 'Magnetic contactor for motor control', 980.00, 3, 2, '2025-10-10'),
(13, 'Power Cable 3x16mm', 'Three-core power cable per meter', 145.00, 3, 2, '2025-10-10'),
(14, 'LED Panel Light', 'LED panel 600x600mm 40W', 520.00, 3, 2, '2025-10-10'),
(15, 'Emergency Light Battery', 'Backup battery for emergency lighting', 780.00, 3, 2, '2025-10-10'),

-- Elevator Components (Category 4)
(16, 'Elevator Door Motor', 'AC motor for automatic door system', 5600.00, 4, 2, '2025-10-10'),
(17, 'Steel Wire Rope', 'High tensile steel rope for elevator', 3200.00, 4, 2, '2025-10-10'),
(18, 'Limit Switch', 'Safety limit switch for elevator', 890.00, 4, 2, '2025-10-10'),
(19, 'Elevator Control Board', 'Main control PCB for elevator system', 7500.00, 4, 2, '2025-10-10'),
(20, 'Guide Rail Roller', 'Polyurethane roller for guide rail', 650.00, 4, 2, '2025-10-10'),

-- Cooling Components (Category 5)
(21, 'Cooling Tower Fill', 'PVC cooling tower fill material', 1200.00, 5, 2, '2025-10-10'),
(22, 'Water Spray Nozzle', 'Brass spray nozzle for cooling tower', 280.00, 5, 2, '2025-10-10'),
(23, 'Refrigerant R410A', 'Refrigerant gas cylinder 13.6kg', 2800.00, 5, 2, '2025-10-10'),
(24, 'Expansion Valve', 'Thermostatic expansion valve', 1450.00, 5, 2, '2025-10-10'),
(25, 'Fan Motor 380V', 'Three-phase fan motor 1.5KW', 3200.00, 5, 2, '2025-10-10');

-- PartDetail: Chi tiết linh kiện
INSERT INTO PartDetail VALUES (1, 1, 'HEPA-FLT-001', 'Available', 'Main Warehouse', 1, 2, '2025-10-10');
INSERT INTO PartDetail VALUES (2, 1, 'HEPA-FLT-002', 'InUse', 'Floor 10 HVAC Room', 1, 2, '2025-10-10');
INSERT INTO PartDetail VALUES (3, 2, 'COMP-MTR-001', 'Available', 'Main Warehouse', 1, 2, '2025-10-10');
INSERT INTO PartDetail VALUES (4, 2, 'COMP-MTR-002', 'InUse', 'Rooftop AC Unit 2', NULL, 2, '2025-10-10');
INSERT INTO PartDetail VALUES (5, 3, 'EVAP-COIL-001', 'Available', 'Main Warehouse', 1, 2, '2025-10-10');
INSERT INTO PartDetail VALUES (6, 3, 'EVAP-COIL-002', 'Faulty', 'Maintenance Workshop', 1, 2, '2025-10-10');
INSERT INTO PartDetail VALUES (7, 4, 'FAN-BLD-001', 'Available', 'Main Warehouse', 1, 2, '2025-10-10');
INSERT INTO PartDetail VALUES (8, 4, 'FAN-BLD-002', 'InUse', 'Basement Chiller Room', NULL, 2, '2025-10-10');
INSERT INTO PartDetail VALUES (9, 5, 'THERMO-001', 'Available', 'Main Warehouse', 1, 2, '2025-10-10');
INSERT INTO PartDetail VALUES (10, 5, 'THERMO-002', 'InUse', 'Floor 5 Control Room', 1, 2, '2025-10-10');

-- Pump Components
INSERT INTO PartDetail VALUES (11, 6, 'IMPEL-001', 'Available', 'Main Warehouse', 2, 2, '2025-10-10');
INSERT INTO PartDetail VALUES (12, 6, 'IMPEL-002', 'InUse', 'Basement Water Pump Room', 2, 2, '2025-10-10');
INSERT INTO PartDetail VALUES (13, 7, 'MECH-SEAL-001', 'Available', 'Main Warehouse', 2, 2, '2025-10-10');
INSERT INTO PartDetail VALUES (14, 7, 'MECH-SEAL-002', 'Retired', 'Disposal Area', NULL, 2, '2025-10-10');
INSERT INTO PartDetail VALUES (15, 8, 'BEARING-001', 'Available', 'Main Warehouse', 2, 2, '2025-10-10');
INSERT INTO PartDetail VALUES (16, 8, 'BEARING-002', 'InUse', 'Floor 2 Pump Station', 2, 2, '2025-10-10');
INSERT INTO PartDetail VALUES (17, 9, 'GAUGE-001', 'Available', 'Main Warehouse', 2, 2, '2025-10-10');
INSERT INTO PartDetail VALUES (18, 9, 'GAUGE-002', 'Faulty', 'Maintenance Workshop', NULL, 2, '2025-10-10');
INSERT INTO PartDetail VALUES (19, 10, 'VALVE-001', 'Available', 'Main Warehouse', 2, 2, '2025-10-10');
INSERT INTO PartDetail VALUES (20, 10, 'VALVE-002', 'InUse', 'Main Water Line Floor B1', 2, 2, '2025-10-10');

-- Electrical Components
INSERT INTO PartDetail VALUES (21, 11, 'CB-3P-001', 'Available', 'Main Warehouse', 3, 2, '2025-10-10');
INSERT INTO PartDetail VALUES (22, 11, 'CB-3P-002', 'InUse', 'Main Electrical Panel Floor 1', 3, 2, '2025-10-10');
INSERT INTO PartDetail VALUES (23, 12, 'CONT-001', 'Available', 'Main Warehouse', 3, 2, '2025-10-10');
INSERT INTO PartDetail VALUES (24, 12, 'CONT-002', 'InUse', 'Pump Control Cabinet B1', NULL, 2, '2025-10-10');
INSERT INTO PartDetail VALUES (25, 13, 'PWR-CBL-001', 'Available', 'Main Warehouse', 3, 2, '2025-10-10');
INSERT INTO PartDetail VALUES (26, 13, 'PWR-CBL-002', 'Available', 'Main Warehouse', 3, 2, '2025-10-10');
INSERT INTO PartDetail VALUES (27, 14, 'LED-PNL-001', 'Available', 'Main Warehouse', 3, 2, '2025-10-10');
INSERT INTO PartDetail VALUES (28, 14, 'LED-PNL-002', 'InUse', 'Floor 8 Office Area', NULL, 2, '2025-10-10');
INSERT INTO PartDetail VALUES (29, 15, 'EMER-BAT-001', 'Available', 'Main Warehouse', 3, 2, '2025-10-10');
INSERT INTO PartDetail VALUES (30, 15, 'EMER-BAT-002', 'InUse', 'Emergency Exit Floor 3', 3, 2, '2025-10-10');

-- Elevator Components
INSERT INTO PartDetail VALUES (31, 16, 'ELEV-MTR-001', 'Available', 'Main Warehouse', 4, 2, '2025-10-10');
INSERT INTO PartDetail VALUES (32, 16, 'ELEV-MTR-002', 'InUse', 'Elevator A Machine Room', 4, 2, '2025-10-10');
INSERT INTO PartDetail VALUES (33, 17, 'WIRE-ROPE-001', 'Available', 'Main Warehouse', 4, 2, '2025-10-10');
INSERT INTO PartDetail VALUES (34, 17, 'WIRE-ROPE-002', 'InUse', 'Elevator B Shaft', NULL, 2, '2025-10-10');
INSERT INTO PartDetail VALUES (35, 18, 'LMT-SW-001', 'Available', 'Main Warehouse', 4, 2, '2025-10-10');
INSERT INTO PartDetail VALUES (36, 18, 'LMT-SW-002', 'InUse', 'Elevator C Top Floor', 4, 2, '2025-10-10');
INSERT INTO PartDetail VALUES (37, 19, 'ELEV-PCB-001', 'Available', 'Main Warehouse', NULL, 2, '2025-10-10');
INSERT INTO PartDetail VALUES (38, 19, 'ELEV-PCB-002', 'InUse', 'Elevator A Control Room', 4, 2, '2025-10-10');
INSERT INTO PartDetail VALUES (39, 20, 'GUIDE-ROLL-001', 'Available', 'Main Warehouse', 4, 2, '2025-10-10');
INSERT INTO PartDetail VALUES (40, 20, 'GUIDE-ROLL-002', 'InUse', 'Elevator B Guide Rail', 4, 2, '2025-10-10');

-- Cooling Components
INSERT INTO PartDetail VALUES (41, 21, 'COOL-FILL-001', 'Available', 'Main Warehouse', 5, 2, '2025-10-10');
INSERT INTO PartDetail VALUES (42, 21, 'COOL-FILL-002', 'InUse', 'Rooftop Cooling Tower 1', 5, 2, '2025-10-10');
INSERT INTO PartDetail VALUES (43, 22, 'SPRAY-NOZ-001', 'Available', 'Main Warehouse', 5, 2, '2025-10-10');
INSERT INTO PartDetail VALUES (44, 22, 'SPRAY-NOZ-002', 'InUse', 'Rooftop Cooling Tower 2', NULL, 2, '2025-10-10');
INSERT INTO PartDetail VALUES (45, 23, 'REFRIG-001', 'Available', 'Main Warehouse', 5, 2, '2025-10-10');
INSERT INTO PartDetail VALUES (46, 23, 'REFRIG-002', 'Available', 'Main Warehouse', 5, 2, '2025-10-10');
INSERT INTO PartDetail VALUES (47, 24, 'EXP-VLV-001', 'Available', 'Main Warehouse', 5, 2, '2025-10-10');
INSERT INTO PartDetail VALUES (48, 24, 'EXP-VLV-002', 'InUse', 'AC Unit Floor 12', 5, 2, '2025-10-10');
INSERT INTO PartDetail VALUES (49, 25, 'FAN-MTR-001', 'Available', 'Main Warehouse', 5, 2, '2025-10-10');
INSERT INTO PartDetail VALUES (50, 25, 'FAN-MTR-002', 'InUse', 'Chiller Room Basement', 5, 2, '2025-10-10');

-- Equipment: Thiết bị hoàn chỉnh cho tòa nhà
INSERT INTO Equipment (equipmentId, serialNumber, model, description, installDate, categoryId, lastUpdatedBy, lastUpdatedDate) VALUES
-- Air Conditioning Systems (Category 13)
(1, 'AC-001-2024', 'Daikin VRV IV', 'Máy lạnh trung tâm - Tầng 1-5', '2024-01-15', 13, 2, '2024-01-15'),
(2, 'AC-002-2024', 'Daikin VRV IV', 'Máy lạnh trung tâm - Tầng 1-5', '2024-01-15', 13, 2, '2024-01-15'),
(3, 'AC-003-2024', 'Daikin VRV IV', 'Máy lạnh trung tâm - Tầng 1-5', '2024-01-15', 13, 2, '2024-01-15'),
(4, 'AC-004-2024', 'Daikin VRV IV', 'Máy lạnh trung tâm - Tầng 1-5', '2024-01-15', 13, 2, '2024-01-15'),
(5, 'AC-005-2024', 'Daikin VRV IV', 'Máy lạnh trung tâm - Tầng 1-5', '2024-01-15', 13, 2, '2024-01-15'),

(6, 'AC-006-2024', 'Mitsubishi City Multi', 'Máy lạnh trung tâm - Tầng 6-10', '2024-02-01', 13, 2, '2024-02-01'),
(7, 'AC-007-2024', 'Mitsubishi City Multi', 'Máy lạnh trung tâm - Tầng 6-10', '2024-02-01', 13, 2, '2024-02-01'),
(8, 'AC-008-2024', 'Mitsubishi City Multi', 'Máy lạnh trung tâm - Tầng 6-10', '2024-02-01', 13, 2, '2024-02-01'),
(9, 'AC-009-2024', 'Mitsubishi City Multi', 'Máy lạnh trung tâm - Tầng 6-10', '2024-02-01', 13, 2, '2024-02-01'),
(10, 'AC-010-2024', 'Mitsubishi City Multi', 'Máy lạnh trung tâm - Tầng 6-10', '2024-02-01', 13, 2, '2024-02-01'),

(11, 'AC-011-2024', 'LG Multi V5', 'Máy lạnh VRV - Tầng hầm', '2024-02-15', 13, 2, '2024-02-15'),
(12, 'AC-012-2024', 'LG Multi V5', 'Máy lạnh VRV - Tầng hầm', '2024-02-15', 13, 2, '2024-02-15'),
(13, 'AC-013-2024', 'LG Multi V5', 'Máy lạnh VRV - Tầng hầm', '2024-02-15', 13, 2, '2024-02-15'),
(14, 'AC-014-2024', 'LG Multi V5', 'Máy lạnh VRV - Tầng hầm', '2024-02-15', 13, 2, '2024-02-15'),
(15, 'AC-015-2024', 'LG Multi V5', 'Máy lạnh VRV - Tầng hầm', '2024-02-15', 13, 2, '2024-02-15'),

(16, 'AC-016-2024', 'Panasonic ECOi', 'Máy lạnh trung tâm - Văn phòng chính', '2024-03-01', 13, 2, '2024-03-01'),
(17, 'AC-017-2024', 'Panasonic ECOi', 'Máy lạnh trung tâm - Văn phòng chính', '2024-03-01', 13, 2, '2024-03-01'),
(18, 'AC-018-2024', 'Panasonic ECOi', 'Máy lạnh trung tâm - Văn phòng chính', '2024-03-01', 13, 2, '2024-03-01'),
(19, 'AC-019-2024', 'Panasonic ECOi', 'Máy lạnh trung tâm - Văn phòng chính', '2024-03-01', 13, 2, '2024-03-01'),
(20, 'AC-020-2024', 'Panasonic ECOi', 'Máy lạnh trung tâm - Văn phòng chính', '2024-03-01', 13, 2, '2024-03-01'),

-- Water Pumps (Category 7)
(21, 'PUMP-021-2024', 'Grundfos CR32-4', 'Máy bơm nước sinh hoạt tầng 1-10', '2024-01-20', 7, 2, '2024-01-20'),
(22, 'PUMP-022-2024', 'Grundfos CR32-4', 'Máy bơm nước sinh hoạt tầng 1-10', '2024-01-20', 7, 2, '2024-01-20'),
(23, 'PUMP-023-2024', 'Grundfos CR32-4', 'Máy bơm nước sinh hoạt tầng 1-10', '2024-01-20', 7, 2, '2024-01-20'),
(24, 'PUMP-024-2024', 'Grundfos CR32-4', 'Máy bơm nước sinh hoạt tầng 1-10', '2024-01-20', 7, 2, '2024-01-20'),
(25, 'PUMP-025-2024', 'Grundfos CR32-4', 'Máy bơm nước sinh hoạt tầng 1-10', '2024-01-20', 7, 2, '2024-01-20'),

(26, 'PUMP-026-2024', 'Pentax CM50-200A', 'Máy bơm cấp nước tòa nhà', '2024-02-10', 7, 2, '2024-02-10'),
(27, 'PUMP-027-2024', 'Pentax CM50-200A', 'Máy bơm cấp nước tòa nhà', '2024-02-10', 7, 2, '2024-02-10'),
(28, 'PUMP-028-2024', 'Pentax CM50-200A', 'Máy bơm cấp nước tòa nhà', '2024-02-10', 7, 2, '2024-02-10'),
(29, 'PUMP-029-2024', 'Pentax CM50-200A', 'Máy bơm cấp nước tòa nhà', '2024-02-10', 7, 2, '2024-02-10'),
(30, 'PUMP-030-2024', 'Pentax CM50-200A', 'Máy bơm cấp nước tòa nhà', '2024-02-10', 7, 2, '2024-02-10'),

(31, 'PUMP-031-2024', 'Ebara 3M 32-160', 'Máy bơm chữa cháy', '2024-03-05', 7, 2, '2024-03-05'),
(32, 'PUMP-032-2024', 'Ebara 3M 32-160', 'Máy bơm chữa cháy', '2024-03-05', 7, 2, '2024-03-05'),
(33, 'PUMP-033-2024', 'Ebara 3M 32-160', 'Máy bơm chữa cháy', '2024-03-05', 7, 2, '2024-03-05'),
(34, 'PUMP-034-2024', 'Ebara 3M 32-160', 'Máy bơm chữa cháy', '2024-03-05', 7, 2, '2024-03-05'),
(35, 'PUMP-035-2024', 'Ebara 3M 32-160', 'Máy bơm chữa cháy', '2024-03-05', 7, 2, '2024-03-05'),

-- Power Systems (Category 8)
(36, 'ELEC-036-2024', 'Schneider Prisma Plus', 'Tủ điện tổng tòa nhà', '2024-01-10', 8, 2, '2024-01-10'),
(37, 'ELEC-037-2024', 'Schneider Prisma Plus', 'Tủ điện tổng tòa nhà', '2024-01-10', 8, 2, '2024-01-10'),
(38, 'ELEC-038-2024', 'Schneider Prisma Plus', 'Tủ điện tổng tòa nhà', '2024-01-10', 8, 2, '2024-01-10'),
(39, 'ELEC-039-2024', 'Schneider Prisma Plus', 'Tủ điện tổng tòa nhà', '2024-01-10', 8, 2, '2024-01-10'),
(40, 'ELEC-040-2024', 'Schneider Prisma Plus', 'Tủ điện tổng tòa nhà', '2024-01-10', 8, 2, '2024-01-10'),

(41, 'ELEC-041-2024', 'ABB ACH580', 'Biến tần điều khiển bơm nước', '2024-03-20', 8, 2, '2024-03-20'),
(42, 'ELEC-042-2024', 'ABB ACH580', 'Biến tần điều khiển bơm nước', '2024-03-20', 8, 2, '2024-03-20'),
(43, 'ELEC-043-2024', 'ABB ACH580', 'Biến tần điều khiển bơm nước', '2024-03-20', 8, 2, '2024-03-20'),
(44, 'ELEC-044-2024', 'ABB ACH580', 'Biến tần điều khiển bơm nước', '2024-03-20', 8, 2, '2024-03-20'),
(45, 'ELEC-045-2024', 'ABB ACH580', 'Biến tần điều khiển bơm nước', '2024-03-20', 8, 2, '2024-03-20'),

(46, 'ELEC-046-2024', 'APC Symmetra 20KVA', 'Bộ lưu điện tòa nhà', '2024-02-15', 8, 2, '2024-02-15'),
(47, 'ELEC-047-2024', 'APC Symmetra 20KVA', 'Bộ lưu điện tòa nhà', '2024-02-15', 8, 2, '2024-02-15'),
(48, 'ELEC-048-2024', 'APC Symmetra 20KVA', 'Bộ lưu điện tòa nhà', '2024-02-15', 8, 2, '2024-02-15'),
(49, 'ELEC-049-2024', 'APC Symmetra 20KVA', 'Bộ lưu điện tòa nhà', '2024-02-15', 8, 2, '2024-02-15'),
(50, 'ELEC-050-2024', 'APC Symmetra 20KVA', 'Bộ lưu điện tòa nhà', '2024-02-15', 8, 2, '2024-02-15'),

(51, 'ELEC-051-2024', 'Cummins C150D5', 'Máy phát điện dự phòng 150KVA', '2024-01-25', 8, 2, '2024-01-25'),
(52, 'ELEC-052-2024', 'Cummins C150D5', 'Máy phát điện dự phòng 150KVA', '2024-01-25', 8, 2, '2024-01-25'),
(53, 'ELEC-053-2024', 'Cummins C150D5', 'Máy phát điện dự phòng 150KVA', '2024-01-25', 8, 2, '2024-01-25'),
(54, 'ELEC-054-2024', 'Cummins C150D5', 'Máy phát điện dự phòng 150KVA', '2024-01-25', 8, 2, '2024-01-25'),
(55, 'ELEC-055-2024', 'Cummins C150D5', 'Máy phát điện dự phòng 150KVA', '2024-01-25', 8, 2, '2024-01-25'),

-- HVAC Systems (Category 6)
(56, 'HVAC-056-2024', 'Carrier 30XA', 'Hệ thống điều hòa trung tâm chiller', '2024-03-15', 6, 2, '2024-03-15'),
(57, 'HVAC-057-2024', 'Carrier 30XA', 'Hệ thống điều hòa trung tâm chiller', '2024-03-15', 6, 2, '2024-03-15'),
(58, 'HVAC-058-2024', 'Carrier 30XA', 'Hệ thống điều hòa trung tâm chiller', '2024-03-15', 6, 2, '2024-03-15'),
(59, 'HVAC-059-2024', 'Carrier 30XA', 'Hệ thống điều hòa trung tâm chiller', '2024-03-15', 6, 2, '2024-03-15'),
(60, 'HVAC-060-2024', 'Carrier 30XA', 'Hệ thống điều hòa trung tâm chiller', '2024-03-15', 6, 2, '2024-03-15'),

(61, 'HVAC-061-2024', 'Trane RTAC 375', 'Máy lạnh công suất lớn', '2024-03-20', 6, 2, '2024-03-20'),
(62, 'HVAC-062-2024', 'Trane RTAC 375', 'Máy lạnh công suất lớn', '2024-03-20', 6, 2, '2024-03-20'),
(63, 'HVAC-063-2024', 'Trane RTAC 375', 'Máy lạnh công suất lớn', '2024-03-20', 6, 2, '2024-03-20'),
(64, 'HVAC-064-2024', 'Trane RTAC 375', 'Máy lạnh công suất lớn', '2024-03-20', 6, 2, '2024-03-20'),
(65, 'HVAC-065-2024', 'Trane RTAC 375', 'Máy lạnh công suất lớn', '2024-03-20', 6, 2, '2024-03-20'),

(66, 'HVAC-066-2024', 'York Air Handler', 'Dàn xử lý không khí tầng 5', '2024-04-10', 6, 2, '2024-04-10'),
(67, 'HVAC-067-2024', 'York Air Handler', 'Dàn xử lý không khí tầng 5', '2024-04-10', 6, 2, '2024-04-10'),
(68, 'HVAC-068-2024', 'York Air Handler', 'Dàn xử lý không khí tầng 5', '2024-04-10', 6, 2, '2024-04-10'),
(69, 'HVAC-069-2024', 'York Air Handler', 'Dàn xử lý không khí tầng 5', '2024-04-10', 6, 2, '2024-04-10'),
(70, 'HVAC-070-2024', 'York Air Handler', 'Dàn xử lý không khí tầng 5', '2024-04-10', 6, 2, '2024-04-10'),

-- Elevator Systems (Category 11)
(71, 'ELEV-071-2024', 'Otis Gen2', 'Thang máy hành khách - Khối A', '2024-04-15', 11, 2, '2024-04-15'),
(72, 'ELEV-072-2024', 'Otis Gen2', 'Thang máy hành khách - Khối A', '2024-04-15', 11, 2, '2024-04-15'),
(73, 'ELEV-073-2024', 'Otis Gen2', 'Thang máy hành khách - Khối A', '2024-04-15', 11, 2, '2024-04-15'),
(74, 'ELEV-074-2024', 'Otis Gen2', 'Thang máy hành khách - Khối A', '2024-04-15', 11, 2, '2024-04-15'),
(75, 'ELEV-075-2024', 'Otis Gen2', 'Thang máy hành khách - Khối A', '2024-04-15', 11, 2, '2024-04-15'),

-- Elevator Systems (Category 11) tiếp tục
(76, 'ELEV-076-2024', 'Mitsubishi NEXIEZ-MRL', 'Thang máy hành khách - Khối B', '2024-05-10', 11, 2, '2024-05-10'),
(77, 'ELEV-077-2024', 'Mitsubishi NEXIEZ-MRL', 'Thang máy hành khách - Khối B', '2024-05-10', 11, 2, '2024-05-10'),
(78, 'ELEV-078-2024', 'Mitsubishi NEXIEZ-MRL', 'Thang máy hành khách - Khối B', '2024-05-10', 11, 2, '2024-05-10'),
(79, 'ELEV-079-2024', 'Mitsubishi NEXIEZ-MRL', 'Thang máy hành khách - Khối B', '2024-05-10', 11, 2, '2024-05-10'),
(80, 'ELEV-080-2024', 'Mitsubishi NEXIEZ-MRL', 'Thang máy hành khách - Khối B', '2024-05-10', 11, 2, '2024-05-10'),

(81, 'ELEV-081-2024', 'KONE MonoSpace 500', 'Thang máy chở hàng', '2024-05-20', 11, 2, '2024-05-20'),
(82, 'ELEV-082-2024', 'KONE MonoSpace 500', 'Thang máy chở hàng', '2024-05-20', 11, 2, '2024-05-20'),
(83, 'ELEV-083-2024', 'KONE MonoSpace 500', 'Thang máy chở hàng', '2024-05-20', 11, 2, '2024-05-20'),
(84, 'ELEV-084-2024', 'KONE MonoSpace 500', 'Thang máy chở hàng', '2024-05-20', 11, 2, '2024-05-20'),
(85, 'ELEV-085-2024', 'KONE MonoSpace 500', 'Thang máy chở hàng', '2024-05-20', 11, 2, '2024-05-20'),

-- Fire Protection Systems (Category 12)
(86, 'FIRE-086-2024', 'Hochiki Fire Panel', 'Tủ trung tâm báo cháy', '2024-06-01', 12, 2, '2024-06-01'),
(87, 'FIRE-087-2024', 'Hochiki Fire Panel', 'Tủ trung tâm báo cháy', '2024-06-01', 12, 2, '2024-06-01'),
(88, 'FIRE-088-2024', 'Hochiki Fire Panel', 'Tủ trung tâm báo cháy', '2024-06-01', 12, 2, '2024-06-01'),
(89, 'FIRE-089-2024', 'Hochiki Fire Panel', 'Tủ trung tâm báo cháy', '2024-06-01', 12, 2, '2024-06-01'),
(90, 'FIRE-090-2024', 'Hochiki Fire Panel', 'Tủ trung tâm báo cháy', '2024-06-01', 12, 2, '2024-06-01'),

(91, 'FIRE-091-2024', 'Viking Sprinkler System', 'Hệ thống sprinkler phòng cháy', '2024-06-15', 12, 2, '2024-06-15'),
(92, 'FIRE-092-2024', 'Viking Sprinkler System', 'Hệ thống sprinkler phòng cháy', '2024-06-15', 12, 2, '2024-06-15'),
(93, 'FIRE-093-2024', 'Viking Sprinkler System', 'Hệ thống sprinkler phòng cháy', '2024-06-15', 12, 2, '2024-06-15'),
(94, 'FIRE-094-2024', 'Viking Sprinkler System', 'Hệ thống sprinkler phòng cháy', '2024-06-15', 12, 2, '2024-06-15'),
(95, 'FIRE-095-2024', 'Viking Sprinkler System', 'Hệ thống sprinkler phòng cháy', '2024-06-15', 12, 2, '2024-06-15'),

-- Control Systems (Category 10)
(96, 'BMS-096-2024', 'Siemens Desigo CC', 'Hệ thống quản lý tòa nhà BMS', '2024-07-01', 10, 2, '2024-07-01'),
(97, 'BMS-097-2024', 'Siemens Desigo CC', 'Hệ thống quản lý tòa nhà BMS', '2024-07-01', 10, 2, '2024-07-01'),
(98, 'BMS-098-2024', 'Siemens Desigo CC', 'Hệ thống quản lý tòa nhà BMS', '2024-07-01', 10, 2, '2024-07-01'),
(99, 'BMS-099-2024', 'Siemens Desigo CC', 'Hệ thống quản lý tòa nhà BMS', '2024-07-01', 10, 2, '2024-07-01'),
(100, 'BMS-100-2024', 'Siemens Desigo CC', 'Hệ thống quản lý tòa nhà BMS', '2024-07-01', 10, 2, '2024-07-01'),

(101, 'BMS-101-2024', 'Honeywell Pro-Watch', 'Hệ thống kiểm soát ra vào', '2024-07-15', 10, 2, '2024-07-15'),
(102, 'BMS-102-2024', 'Honeywell Pro-Watch', 'Hệ thống kiểm soát ra vào', '2024-07-15', 10, 2, '2024-07-15'),
(103, 'BMS-103-2024', 'Honeywell Pro-Watch', 'Hệ thống kiểm soát ra vào', '2024-07-15', 10, 2, '2024-07-15'),
(104, 'BMS-104-2024', 'Honeywell Pro-Watch', 'Hệ thống kiểm soát ra vào', '2024-07-15', 10, 2, '2024-07-15'),
(105, 'BMS-105-2024', 'Honeywell Pro-Watch', 'Hệ thống kiểm soát ra vào', '2024-07-15', 10, 2, '2024-07-15'),

-- Cooling Systems (Category 6)
(106, 'COOL-106-2024', 'BAC Cooling Tower', 'Tháp giải nhiệt 500 RT', '2024-08-01', 6, 2, '2024-08-01'),
(107, 'COOL-107-2024', 'BAC Cooling Tower', 'Tháp giải nhiệt 500 RT', '2024-08-01', 6, 2, '2024-08-01'),
(108, 'COOL-108-2024', 'BAC Cooling Tower', 'Tháp giải nhiệt 500 RT', '2024-08-01', 6, 2, '2024-08-01'),
(109, 'COOL-109-2024', 'BAC Cooling Tower', 'Tháp giải nhiệt 500 RT', '2024-08-01', 6, 2, '2024-08-01'),
(110, 'COOL-110-2024', 'BAC Cooling Tower', 'Tháp giải nhiệt 500 RT', '2024-08-01', 6, 2, '2024-08-01'),

(111, 'COOL-111-2024', 'York YCIV Chiller', 'Máy làm lạnh nước 400 RT', '2024-08-15', 6, 2, '2024-08-15'),
(112, 'COOL-112-2024', 'York YCIV Chiller', 'Máy làm lạnh nước 400 RT', '2024-08-15', 6, 2, '2024-08-15'),
(113, 'COOL-113-2024', 'York YCIV Chiller', 'Máy làm lạnh nước 400 RT', '2024-08-15', 6, 2, '2024-08-15'),
(114, 'COOL-114-2024', 'York YCIV Chiller', 'Máy làm lạnh nước 400 RT', '2024-08-15', 6, 2, '2024-08-15'),
(115, 'COOL-115-2024', 'York YCIV Chiller', 'Máy làm lạnh nước 400 RT', '2024-08-15', 6, 2, '2024-08-15'),

-- Lighting Systems (Category 9)
(116, 'LIGHT-116-2024', 'Philips SmartBright', 'Hệ thống chiếu sáng thông minh', '2024-09-01', 9, 2, '2024-09-01'),
(117, 'LIGHT-117-2024', 'Philips SmartBright', 'Hệ thống chiếu sáng thông minh', '2024-09-01', 9, 2, '2024-09-01'),
(118, 'LIGHT-118-2024', 'Philips SmartBright', 'Hệ thống chiếu sáng thông minh', '2024-09-01', 9, 2, '2024-09-01'),
(119, 'LIGHT-119-2024', 'Philips SmartBright', 'Hệ thống chiếu sáng thông minh', '2024-09-01', 9, 2, '2024-09-01'),
(120, 'LIGHT-120-2024', 'Philips SmartBright', 'Hệ thống chiếu sáng thông minh', '2024-09-01', 9, 2, '2024-09-01'),

(121, 'LIGHT-121-2024', 'Osram LED System', 'Hệ thống đèn LED tòa nhà', '2024-09-15', 9, 2, '2024-09-15'),
(122, 'LIGHT-122-2024', 'Osram LED System', 'Hệ thống đèn LED tòa nhà', '2024-09-15', 9, 2, '2024-09-15'),
(123, 'LIGHT-123-2024', 'Osram LED System', 'Hệ thống đèn LED tòa nhà', '2024-09-15', 9, 2, '2024-09-15'),
(124, 'LIGHT-124-2024', 'Osram LED System', 'Hệ thống đèn LED tòa nhà', '2024-09-15', 9, 2, '2024-09-15'),
(125, 'LIGHT-125-2024', 'Osram LED System', 'Hệ thống đèn LED tòa nhà', '2024-09-15', 9, 2, '2024-09-15');


COMMIT;


START TRANSACTION;

CREATE TABLE IF NOT EXISTS ContractEquipment_backup AS 
SELECT * FROM ContractEquipment 
WHERE contractId IN (1, 5, 9, 13) AND equipmentId IN (1,2,3,4);

CREATE TABLE IF NOT EXISTS Equipment_backup AS 
SELECT * FROM Equipment WHERE equipmentId IN (1,2,3,4);




-- Xóa equipment 1 trong contract 9 (giữ lại contract 1)
DELETE FROM ContractEquipment 
WHERE equipmentId = 1 AND contractId = 9;

-- Xóa equipment 2 trong contract 9 (giữ lại contract 1)
DELETE FROM ContractEquipment 
WHERE equipmentId = 2 AND contractId = 9;

-- Xóa equipment 4 trong contract 13 (giữ lại contract 5)
DELETE FROM ContractEquipment 
WHERE equipmentId = 4 AND contractId = 13;

--- Xoa trung lap customer2
SET SQL_SAFE_UPDATES = 0;

START TRANSACTION;

-- Backup dữ liệu trước khi xóa cho Customer2
CREATE TABLE IF NOT EXISTS ContractEquipment_customer2_backup AS 
SELECT * FROM ContractEquipment 
WHERE contractId IN (2, 6, 10, 14) AND equipmentId IN (3, 5, 6);

CREATE TABLE IF NOT EXISTS Equipment_customer2_backup AS 
SELECT * FROM Equipment WHERE equipmentId IN (3, 5, 6);

-- CUSTOMER 2 (Phạm Thị Lan - customerId = 5)
-- Xóa equipment 3 trong contract 14 (giữ lại contract 10)
DELETE FROM ContractEquipment 
WHERE equipmentId = 3 AND contractId = 14;

-- Xóa equipment 5 trong contract 6 (giữ lại contract 2)
DELETE FROM ContractEquipment 
WHERE equipmentId = 5 AND contractId = 6;

-- Xóa equipment 6 trong contract 6 (giữ lại contract 2)
DELETE FROM ContractEquipment 
WHERE equipmentId = 6 AND contractId = 6;

-- Kiểm tra lại kết quả sau khi xóa
SELECT 
    c.customerId,
    a.fullName as customerName,
    e.equipmentId,
    e.serialNumber,
    e.model,
    c.contractId,
    COUNT(*) OVER (PARTITION BY c.customerId, e.serialNumber) as duplicate_count
FROM Equipment e
JOIN ContractEquipment ce ON e.equipmentId = ce.equipmentId
JOIN Contract c ON ce.contractId = c.contractId
JOIN Account a ON c.customerId = a.accountId
WHERE c.customerId = 5
ORDER BY e.serialNumber, e.equipmentId;

-- Nếu kết quả OK, commit
COMMIT;
-- Nếu có vấn đề: ROLLBACK;

SET SQL_SAFE_UPDATES = 1;

---- 


--- xoa trung lap customer3 


SET SQL_SAFE_UPDATES = 0;

START TRANSACTION;

-- Backup dữ liệu trước khi xóa cho Customer3
CREATE TABLE IF NOT EXISTS ContractEquipment_customer3_backup AS 
SELECT * FROM ContractEquipment 
WHERE contractId IN (3, 7, 11, 15) AND equipmentId IN (2, 5, 7, 8);

CREATE TABLE IF NOT EXISTS Equipment_customer3_backup AS 
SELECT * FROM Equipment WHERE equipmentId IN (2, 5, 7, 8);

-- CUSTOMER 3 (Hoàng Văn Minh - customerId = 6)
-- Xóa equipment 7 trong contract 7 (giữ lại contract 3)
DELETE FROM ContractEquipment 
WHERE equipmentId = 7 AND contractId = 7;

-- Xóa equipment 7 trong contract 15 (giữ lại contract 3)
DELETE FROM ContractEquipment 
WHERE equipmentId = 7 AND contractId = 15;

-- Xóa equipment 8 trong contract 7 (giữ lại contract 3)
DELETE FROM ContractEquipment 
WHERE equipmentId = 8 AND contractId = 7;

-- Kiểm tra lại kết quả sau khi xóa
SELECT 
    c.customerId,
    a.fullName as customerName,
    e.equipmentId,
    e.serialNumber,
    e.model,
    c.contractId,
    COUNT(*) OVER (PARTITION BY c.customerId, e.serialNumber) as duplicate_count
FROM Equipment e
JOIN ContractEquipment ce ON e.equipmentId = ce.equipmentId
JOIN Contract c ON ce.contractId = c.contractId
JOIN Account a ON c.customerId = a.accountId
WHERE c.customerId = 6
ORDER BY e.serialNumber, e.equipmentId;

-- Nếu kết quả OK, commit
COMMIT;
-- Nếu có vấn đề: ROLLBACK;

SET SQL_SAFE_UPDATES = 1;

--- Xoa trung lap customer4


SET SQL_SAFE_UPDATES = 0;

START TRANSACTION;

-- Backup dữ liệu trước khi xóa cho Customer4
CREATE TABLE IF NOT EXISTS ContractEquipment_customer4_backup AS 
SELECT * FROM ContractEquipment 
WHERE contractId IN (4, 8, 12) AND equipmentId IN (9, 10);

CREATE TABLE IF NOT EXISTS Equipment_customer4_backup AS 
SELECT * FROM Equipment WHERE equipmentId IN (9, 10);

-- CUSTOMER 4 (Vũ Thị Hoa - customerId = 7)
-- Xóa equipment 9 trong contract 8 (giữ lại contract 4)
DELETE FROM ContractEquipment 
WHERE equipmentId = 9 AND contractId = 8;

-- Xóa equipment 9 trong contract 12 (giữ lại contract 4)
DELETE FROM ContractEquipment 
WHERE equipmentId = 9 AND contractId = 12;

-- Xóa equipment 10 trong contract 8 (giữ lại contract 4)
DELETE FROM ContractEquipment 
WHERE equipmentId = 10 AND contractId = 8;

-- Kiểm tra lại kết quả sau khi xóa
SELECT 
    c.customerId,
    a.fullName as customerName,
    e.equipmentId,
    e.serialNumber,
    e.model,
    c.contractId,
    COUNT(*) OVER (PARTITION BY c.customerId, e.serialNumber) as duplicate_count
FROM Equipment e
JOIN ContractEquipment ce ON e.equipmentId = ce.equipmentId
JOIN Contract c ON ce.contractId = c.contractId
JOIN Account a ON c.customerId = a.accountId
WHERE c.customerId = 7
ORDER BY e.serialNumber, e.equipmentId;

-- Nếu kết quả OK, commit
COMMIT;
-- Nếu có vấn đề: ROLLBACK;

SET SQL_SAFE_UPDATES = 1;

-- 

-- Bật event scheduler nếu chưa bật
SET GLOBAL event_scheduler = ON;

DELIMITER $$

CREATE EVENT update_contract_status_daily
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    -- Cập nhật "Completed" nếu tất cả thiết bị trong hợp đồng đã hết hạn
    UPDATE Contract c
    SET c.status = 'Completed'
    WHERE c.status = 'Active'
      AND NOT EXISTS (
          SELECT 1
          FROM ContractEquipment ce
          WHERE ce.contractId = c.contractId
            AND (ce.endDate IS NULL OR ce.endDate >= CURDATE())
      );

    -- (Tùy chọn) Cập nhật "Cancelled" hoặc "Expired" nếu có quy tắc riêng
    -- Ví dụ: nếu hợp đồng đã hết hạn hơn 30 ngày
     UPDATE Contract c
     SET c.status = 'Cancelled'
     WHERE c.status = 'Completed'
	 AND EXISTS (
          SELECT 1
          FROM ContractEquipment ce
          WHERE ce.contractId = c.contractId
           AND ce.endDate < DATE_SUB(CURDATE(), INTERVAL 30 DAY)
      );
END $$

DELIMITER ;

SET SQL_SAFE_UPDATES = 0;

DELETE c
FROM Contract c
LEFT JOIN ContractEquipment ce ON c.contractId = ce.contractId
WHERE ce.contractId IS NULL;

SET SQL_SAFE_UPDATES = 1;

CREATE TABLE ContractAppendix (
    appendixId INT AUTO_INCREMENT PRIMARY KEY,
    contractId INT NOT NULL,
    appendixType ENUM('AddEquipment', 'RepairPart', 'ExtendTerm', 'Other') NOT NULL,
    appendixName VARCHAR(255),
    description TEXT,
    effectiveDate DATE DEFAULT (CURRENT_DATE),
    totalAmount DECIMAL(18,2) DEFAULT 0,
    status ENUM('Draft','Approved','Archived') DEFAULT 'Approved',
    fileAttachment VARCHAR(255),
    createdBy INT,
    createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    warrantyCovered TINYINT(1) DEFAULT 0,
    warrantyReportId INT NULL,
    FOREIGN KEY (contractId) REFERENCES Contract(contractId),
    FOREIGN KEY (warrantyReportId) REFERENCES RepairReport(reportId)
);


CREATE TABLE ContractAppendixEquipment (
    appendixEquipId INT AUTO_INCREMENT PRIMARY KEY,
    appendixId INT NOT NULL,
    equipmentId INT NOT NULL,
    unitPrice DECIMAL(18,2),
    note TEXT,
    FOREIGN KEY (appendixId) REFERENCES ContractAppendix(appendixId),
    FOREIGN KEY (equipmentId) REFERENCES Equipment(equipmentId)
);


CREATE TABLE ContractAppendixPart (
    appendixPartId INT AUTO_INCREMENT PRIMARY KEY,
    appendixId INT NOT NULL,
    equipmentId INT NOT NULL,
    partId INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    unitPrice DECIMAL(18,2),
    totalPrice DECIMAL(18,2) GENERATED ALWAYS AS (quantity * unitPrice) STORED,
    repairReportId INT,
    paymentStatus ENUM('Unpaid','Paid') DEFAULT 'Paid',
    approvedByCustomer BOOLEAN DEFAULT TRUE,
    approvalDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    note TEXT,
    FOREIGN KEY (appendixId) REFERENCES ContractAppendix(appendixId),
    FOREIGN KEY (equipmentId) REFERENCES Equipment(equipmentId),
    FOREIGN KEY (partId) REFERENCES Part(partId),
    FOREIGN KEY (repairReportId) REFERENCES RepairReport(reportId)
);


CREATE TABLE RepairReportDetail (
    detailId INT AUTO_INCREMENT PRIMARY KEY,
    reportId INT NOT NULL,
    partId INT NOT NULL,
    quantity INT NOT NULL,
    unitPrice DECIMAL(12,2),
    FOREIGN KEY (reportId) REFERENCES RepairReport(reportId),
    FOREIGN KEY (partId) REFERENCES Part(partId)
);

ALTER TABLE RepairReportDetail
ADD COLUMN partDetailId INT NULL,
ADD FOREIGN KEY (partDetailId) REFERENCES PartDetail(partDetailId);

DELIMITER $$

CREATE TRIGGER trg_add_parts_to_contract_appendix
AFTER UPDATE ON RepairReport
FOR EACH ROW
BEGIN
    DECLARE v_contractId INT;
    DECLARE v_equipmentId INT;
    DECLARE v_appendixId INT;
    DECLARE v_total DECIMAL(18,2);
    DECLARE v_equipmentModel VARCHAR(255);
    DECLARE v_equipmentSerial VARCHAR(255);
    DECLARE v_requestType VARCHAR(20);
    DECLARE v_isWarranty TINYINT(1) DEFAULT 0;

    -- Chỉ thực hiện khi báo giá đã được duyệt và thanh toán (Approved)
    IF NEW.quotationStatus = 'Approved' AND OLD.quotationStatus <> 'Approved' THEN

        -- Lấy thông tin hợp đồng, thiết bị và loại yêu cầu từ ServiceRequest
        SELECT contractId, equipmentId, requestType
        INTO v_contractId, v_equipmentId, v_requestType
        FROM ServiceRequest
        WHERE requestId = NEW.requestId;

        IF v_requestType = 'Warranty' THEN
            SET v_isWarranty = 1;
        END IF;

        -- Lấy thông tin thiết bị (model và serial)
        SELECT model, serialNumber
        INTO v_equipmentModel, v_equipmentSerial
        FROM Equipment
        WHERE equipmentId = v_equipmentId;

        -- Tính tổng giá trị part trong báo giá
        SELECT SUM(quantity * unitPrice)
        INTO v_total
        FROM RepairReportDetail
        WHERE reportId = NEW.reportId;

        -- ✅ Tạo phụ lục hợp đồng (loại RepairPart) cho đúng thiết bị
        INSERT INTO ContractAppendix (
            contractId,
            appendixType,
            appendixName,
            description,
            effectiveDate,
            totalAmount,
            status,
            warrantyCovered,
            warrantyReportId
        )
        VALUES (
            v_contractId,
            'RepairPart',
            IF(v_isWarranty = 1,
               CONCAT('Phụ lục linh kiện bảo hành cho thiết bị [', v_equipmentModel, ' - ', v_equipmentSerial, ']'),
               CONCAT('Phụ lục thay thế linh kiện cho thiết bị [', v_equipmentModel, ' - ', v_equipmentSerial, ']')),
            IF(v_isWarranty = 1,
               'Tự động tạo khi khách hàng đồng ý bảo trì bảo hành (miễn phí)',
               'Tự động tạo khi khách hàng đồng ý và thanh toán báo giá sửa chữa'),
            CURDATE(),
            IF(v_isWarranty = 1, 0, IFNULL(v_total, 0)),
            'Approved',
            v_isWarranty,
            NEW.reportId
        );

        SET v_appendixId = LAST_INSERT_ID();

        -- Ghi danh sách part vào phụ lục hợp đồng
        INSERT INTO ContractAppendixPart (
            appendixId,
            equipmentId,
            partId,
            quantity,
            unitPrice,
            repairReportId,
            paymentStatus,
            approvedByCustomer,
            approvalDate,
            note
        )
        SELECT
            v_appendixId,
            v_equipmentId,
            d.partId,
            d.quantity,
            d.unitPrice,
            NEW.reportId,
            'Paid',  -- Đánh dấu đã chi trả (bởi khách hoặc bảo hành)
            TRUE,
            NOW(),
            IF(v_isWarranty = 1,
               CONCAT('Linh kiện bảo hành (miễn phí) - tự động từ báo cáo #', NEW.reportId),
               'Tự động ghi nhận từ báo giá đã duyệt & thanh toán')
        FROM RepairReportDetail d
        WHERE d.reportId = NEW.reportId;
    END IF;
END$$

DELIMITER ;

ALTER TABLE Contract 
ADD COLUMN createdDate DATETIME DEFAULT NULL AFTER details;

-- ============================================================
-- Schedule-origin RepairReport support (idempotent)
-- Adds RepairReport.scheduleId and RepairReport.origin
-- ============================================================
DELIMITER //
DROP PROCEDURE IF EXISTS sp_add_schedule_origin_to_repairreport//
CREATE PROCEDURE sp_add_schedule_origin_to_repairreport()
BEGIN
    -- Add scheduleId if missing
    IF NOT EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = 'RepairReport'
          AND COLUMN_NAME = 'scheduleId'
    ) THEN
        ALTER TABLE RepairReport
            ADD COLUMN scheduleId INT NULL AFTER requestId;
    END IF;

    -- Add origin if missing
    IF NOT EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = 'RepairReport'
          AND COLUMN_NAME = 'origin'
    ) THEN
        ALTER TABLE RepairReport
            ADD COLUMN origin ENUM('ServiceRequest','Schedule') DEFAULT 'ServiceRequest' AFTER diagnosis;
    END IF;

    -- Add FK for scheduleId if not exists
    IF NOT EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = 'RepairReport'
          AND CONSTRAINT_NAME = 'FK_RepairReport_MaintenanceSchedule'
    ) THEN
        ALTER TABLE RepairReport
            ADD CONSTRAINT FK_RepairReport_MaintenanceSchedule
            FOREIGN KEY (scheduleId) REFERENCES MaintenanceSchedule(scheduleId);
    END IF;
END//
CALL sp_add_schedule_origin_to_repairreport()//
DROP PROCEDURE IF EXISTS sp_add_schedule_origin_to_repairreport//
DELIMITER ;


-- Ensure warranty tracking columns exist for ContractAppendix (idempotent for single-run deploy)
DELIMITER //
DROP PROCEDURE IF EXISTS sp_add_warranty_columns//
CREATE PROCEDURE sp_add_warranty_columns()
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = 'ContractAppendix'
          AND COLUMN_NAME = 'warrantyCovered'
    ) THEN
        ALTER TABLE ContractAppendix
            ADD COLUMN warrantyCovered TINYINT(1) DEFAULT 0;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = 'ContractAppendix'
          AND COLUMN_NAME = 'warrantyReportId'
    ) THEN
        ALTER TABLE ContractAppendix
            ADD COLUMN warrantyReportId INT NULL;
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = 'ContractAppendix'
          AND CONSTRAINT_NAME = 'fk_contractappendix_warrantyreport'
    ) THEN
        ALTER TABLE ContractAppendix
            ADD CONSTRAINT fk_contractappendix_warrantyreport
            FOREIGN KEY (warrantyReportId) REFERENCES RepairReport(reportId);
    END IF;
END//
CALL sp_add_warranty_columns()//
DROP PROCEDURE IF EXISTS sp_add_warranty_columns//
DELIMITER ;


ALTER TABLE InvoiceDetail 
ADD COLUMN repairReportDetailId INT NULL AFTER invoiceId,
ADD COLUMN quantity INT NULL AFTER repairReportDetailId,
ADD COLUMN unitPrice DECIMAL(12,2) NULL AFTER quantity,
ADD COLUMN totalPrice DECIMAL(12,2) NULL AFTER unitPrice,
ADD COLUMN paymentStatus VARCHAR(20) DEFAULT 'Pending' AFTER totalPrice,
ADD COLUMN paymentDate DATE NULL AFTER paymentStatus;


ALTER TABLE InvoiceDetail
ADD CONSTRAINT FK_InvoiceDetail_RepairReportDetail
FOREIGN KEY (repairReportDetailId) REFERENCES RepairReportDetail(detailId);
DESCRIBE InvoiceDetail;



-------------------------------------

ALTER TABLE Invoice 
ADD COLUMN paymentMethod VARCHAR(50) NULL 
COMMENT 'Payment method: VNPay, Cash, Bank Transfer';

-- Verify Invoice table
DESC Invoice;

-- ============================================
-- 2. Thêm cột reportId vào bảng Payment (nếu chưa có)
-- ============================================

-- Kiểm tra xem cột reportId đã tồn tại chưa
SELECT COUNT(*) as column_exists
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE()
AND TABLE_NAME = 'Payment' 
AND COLUMN_NAME = 'reportId';

-- Nếu kết quả = 0, chạy lệnh sau:
ALTER TABLE Payment 
ADD COLUMN reportId INT NULL 
COMMENT 'Link to RepairReport';

-- Thêm Foreign Key constraint
ALTER TABLE Payment
ADD CONSTRAINT FK_Payment_RepairReport 
FOREIGN KEY (reportId) REFERENCES RepairReport(reportId)
ON DELETE SET NULL;

-- Thêm index
CREATE INDEX IX_Payment_ReportId ON Payment(reportId);

-- Verify Payment table
DESC Payment;

-- ============================================
-- 3. Kiểm tra kết quả
-- ============================================

-- Xem structure của Invoice
SHOW COLUMNS FROM Invoice LIKE 'paymentMethod';

-- Xem structure của Payment
SHOW COLUMNS FROM Payment LIKE 'reportId';

-- Xem Foreign Keys
SELECT 
    CONSTRAINT_NAME,
    TABLE_NAME,
    COLUMN_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = DATABASE()
AND TABLE_NAME = 'Payment'
AND CONSTRAINT_NAME LIKE 'FK_%';

-- ============================================
-- 4. Test Insert (Optional)
-- ============================================

-- Xóa test data (nếu cần)
-- DELETE FROM Invoice WHERE invoiceId = LAST_INSERT_ID();

-- ============================================
-- 5. Rollback (nếu có lỗi)
-- ============================================
/*
-- Xóa cột paymentMethod
ALTER TABLE Invoice DROP COLUMN paymentMethod;

-- Xóa Foreign Key và cột reportId
ALTER TABLE Payment DROP FOREIGN KEY FK_Payment_RepairReport;
DROP INDEX IX_Payment_ReportId ON Payment;
ALTER TABLE Payment DROP COLUMN reportId;
*/

ALTER TABLE MaintenanceSchedule 
ADD COLUMN customerId INT NULL,
ADD FOREIGN KEY (customerId) REFERENCES Account(accountId);

ALTER TABLE ContractAppendixEquipment
ADD COLUMN startDate DATE,
ADD COLUMN endDate DATE;

DELIMITER $$

CREATE TRIGGER trg_ContractAppendixEquipment_before_insert
BEFORE INSERT ON ContractAppendixEquipment
FOR EACH ROW
BEGIN
    DECLARE v_start DATE;

    -- Lấy effectiveDate từ bảng ContractAppendix
    SELECT effectiveDate INTO v_start
    FROM ContractAppendix
    WHERE appendixId = NEW.appendixId;

    -- Gán giá trị startDate và endDate
    SET NEW.startDate = v_start;
    SET NEW.endDate = DATE_ADD(v_start, INTERVAL 3 YEAR);
END$$

DELIMITER ;

SET SQL_SAFE_UPDATES = 0;
UPDATE Part
SET lastUpdatedBy = 13;
SET SQL_SAFE_UPDATES = 1;
Select * From PartDetail ;
INSERT INTO PartDetail (partDetailId, partId, serialNumber, status, location, categoryId, lastUpdatedBy, lastUpdatedDate)
VALUES
(52, 1, 'ABC-123-4567', 'Available', 'Main Warehouse', 1, 13, '2025-11-12'),
(53, 2, 'DEF-456-7890', 'Available', 'Floor 10 HVAC Room', 2, 13, '2025-11-12'),
(54, 3, 'GHI-789-0123', 'Available', 'Rooftop Unit 02', 3, 13, '2025-11-12'),
(55, 4, 'JKL-234-5678', 'Available', 'Main Warehouse', 4, 13, '2025-11-12'),
(56, 5, 'MNO-567-8901', 'Available', 'Floor 10 HVAC Room', 5, 13, '2025-11-12'),
(57, 6, 'PQR-890-1234', 'Available', 'Storage Room A', 1, 13, '2025-11-12'),
(58, 7, 'STU-123-4567', 'Available', 'Main Warehouse', 2, 13, '2025-11-12'),
(59, 8, 'VWX-456-7890', 'Available', 'Rooftop Unit 03', 3, 13, '2025-11-12'),
(60, 9, 'YZA-789-0123', 'Available', 'Floor 10 HVAC Room', 4, 13, '2025-11-12'),
(61, 10, 'BCD-234-5678', 'Available', 'Main Warehouse', 5, 13, '2025-11-12'),
(62, 11, 'EFG-567-8901', 'Available', 'Storage Room B', 1, 13, '2025-11-12'),
(63, 12, 'HIJ-890-1234', 'Available', 'Rooftop Unit 01', 2, 13, '2025-11-12'),
(64, 13, 'KLM-123-4567', 'Available', 'Main Warehouse', 3, 13, '2025-11-12'),
(65, 14, 'NOP-456-7890', 'Available', 'Floor 10 HVAC Room', 4, 13, '2025-11-12'),
(66, 15, 'QRS-789-0123', 'Available', 'Storage Room A', 5, 13, '2025-11-12'),
(67, 16, 'TUV-234-5678', 'Available', 'Main Warehouse', 1, 13, '2025-11-12'),
(68, 17, 'WXY-567-8901', 'Available', 'Rooftop Unit 02', 2, 13, '2025-11-12'),
(69, 18, 'ZAB-890-1234', 'Available', 'Floor 10 HVAC Room', 3, 13, '2025-11-12'),
(70, 19, 'CDE-123-4567', 'Available', 'Main Warehouse', 4, 13, '2025-11-12'),
(71, 20, 'FGH-456-7890', 'Available', 'Storage Room C', 5, 13, '2025-11-12'),
(72, 21, 'IJK-789-0123', 'Available', 'Rooftop Unit 03', 1, 13, '2025-11-12'),
(73, 22, 'LMN-234-5678', 'Available', 'Main Warehouse', 2, 13, '2025-11-12'),
(74, 23, 'OPQ-567-8901', 'Available', 'Floor 10 HVAC Room', 3, 13, '2025-11-12'),
(75, 24, 'RST-890-1234', 'Available', 'Storage Room A', 4, 13, '2025-11-12'),
(76, 25, 'UVW-123-4567', 'Available', 'Main Warehouse', 5, 13, '2025-11-12'),
(77, 1, 'XYZ-456-7890', 'Available', 'Rooftop Unit 01', 1, 13, '2025-11-12'),
(78, 2, 'ABC-789-0123', 'Available', 'Floor 10 HVAC Room', 2, 13, '2025-11-12'),
(79, 3, 'DEF-234-5678', 'Available', 'Main Warehouse', 3, 13, '2025-11-12'),
(80, 4, 'GHI-567-8901', 'Available', 'Storage Room B', 4, 13, '2025-11-12'),
(81, 5, 'JKL-890-1234', 'Available', 'Rooftop Unit 02', 5, 13, '2025-11-12'),
(82, 6, 'MNO-123-4567', 'Available', 'Main Warehouse', 1, 13, '2025-11-12'),
(83, 7, 'PQR-456-7890', 'Available', 'Floor 10 HVAC Room', 2, 13, '2025-11-12'),
(84, 8, 'STU-789-0123', 'Available', 'Storage Room C', 3, 13, '2025-11-12'),
(85, 9, 'VWX-234-5678', 'Available', 'Main Warehouse', 4, 13, '2025-11-12'),
(86, 10, 'YZA-567-8901', 'Available', 'Rooftop Unit 03', 5, 13, '2025-11-12'),
(87, 11, 'BCD-890-1234', 'Available', 'Floor 10 HVAC Room', 1, 13, '2025-11-12'),
(88, 12, 'EFG-123-4567', 'Available', 'Main Warehouse', 2, 13, '2025-11-12'),
(89, 13, 'HIJ-456-7890', 'Available', 'Storage Room A', 3, 13, '2025-11-12'),
(90, 14, 'KLM-789-0123', 'Available', 'Rooftop Unit 01', 4, 13, '2025-11-12'),
(91, 15, 'NOP-234-5678', 'Available', 'Main Warehouse', 5, 13, '2025-11-12'),
(92, 16, 'QRS-567-8901', 'Available', 'Floor 10 HVAC Room', 1, 13, '2025-11-12'),
(93, 17, 'TUV-890-1234', 'Available', 'Storage Room B', 2, 13, '2025-11-12'),
(94, 18, 'WXY-123-4567', 'Available', 'Main Warehouse', 3, 13, '2025-11-12'),
(95, 19, 'ZAB-456-7890', 'Available', 'Rooftop Unit 02', 4, 13, '2025-11-12'),
(96, 20, 'CDE-789-0123', 'Available', 'Floor 10 HVAC Room', 5, 13, '2025-11-12'),
(97, 21, 'FGH-234-5678', 'Available', 'Main Warehouse', 1, 13, '2025-11-12'),
(98, 22, 'IJK-567-8901', 'Available', 'Storage Room C', 2, 13, '2025-11-12'),
(99, 23, 'LMN-890-1234', 'Available', 'Rooftop Unit 03', 3, 13, '2025-11-12'),
(100, 24, 'OPQ-123-4567', 'Available', 'Main Warehouse', 4, 13, '2025-11-12'),
(101, 25, 'RST-456-7890', 'Available', 'Floor 10 HVAC Room', 5, 13, '2025-11-12'),
(102, 1, 'UVW-789-0123', 'Available', 'Storage Room A', 1, 13, '2025-11-12'),
(103, 2, 'XYZ-234-5678', 'Available', 'Main Warehouse', 2, 13, '2025-11-12'),
(104, 3, 'ABC-567-8901', 'Available', 'Rooftop Unit 01', 3, 13, '2025-11-12'),
(105, 4, 'DEF-890-1234', 'Available', 'Floor 10 HVAC Room', 4, 13, '2025-11-12'),
(106, 5, 'GHI-123-4567', 'Available', 'Main Warehouse', 5, 13, '2025-11-12'),
(107, 6, 'JKL-456-7890', 'Available', 'Storage Room B', 1, 13, '2025-11-12'),
(108, 7, 'MNO-789-0123', 'Available', 'Rooftop Unit 02', 2, 13, '2025-11-12'),
(109, 8, 'PQR-234-5678', 'Available', 'Main Warehouse', 3, 13, '2025-11-12'),
(110, 9, 'STU-567-8901', 'Available', 'Floor 10 HVAC Room', 4, 13, '2025-11-12'),
(111, 10, 'VWX-890-1234', 'Available', 'Storage Room C', 5, 13, '2025-11-12'),
(112, 11, 'YZA-123-4567', 'Available', 'Main Warehouse', 1, 13, '2025-11-12'),
(113, 12, 'BCD-456-7890', 'Available', 'Rooftop Unit 03', 2, 13, '2025-11-12'),
(114, 13, 'EFG-789-0123', 'Available', 'Floor 10 HVAC Room', 3, 13, '2025-11-12'),
(115, 14, 'HIJ-234-5678', 'Available', 'Main Warehouse', 4, 13, '2025-11-12'),
(116, 15, 'KLM-567-8901', 'Available', 'Storage Room A', 5, 13, '2025-11-12'),
(117, 16, 'NOP-890-1234', 'Available', 'Rooftop Unit 01', 1, 13, '2025-11-12'),
(118, 17, 'QRS-123-4567', 'Available', 'Main Warehouse', 2, 13, '2025-11-12'),
(119, 18, 'TUV-456-7890', 'Available', 'Floor 10 HVAC Room', 3, 13, '2025-11-12'),
(120, 19, 'WXY-789-0123', 'Available', 'Storage Room B', 4, 13, '2025-11-12'),
(121, 20, 'ZAB-234-5678', 'Available', 'Main Warehouse', 5, 13, '2025-11-12'),
(122, 21, 'CDE-567-8901', 'Available', 'Rooftop Unit 02', 1, 13, '2025-11-12'),
(123, 22, 'FGH-890-1234', 'Available', 'Floor 10 HVAC Room', 2, 13, '2025-11-12'),
(124, 23, 'IJK-123-4567', 'Available', 'Main Warehouse', 3, 13, '2025-11-12'),
(125, 24, 'LMN-456-7890', 'Available', 'Storage Room C', 4, 13, '2025-11-12'),
(126, 25, 'OPQ-789-0123', 'Available', 'Rooftop Unit 03', 5, 13, '2025-11-12'),
(127, 1, 'RST-234-5678', 'Available', 'Main Warehouse', 1, 13, '2025-11-12'),
(128, 2, 'UVW-567-8901', 'Available', 'Floor 10 HVAC Room', 2, 13, '2025-11-12'),
(129, 3, 'XYZ-890-1234', 'Available', 'Storage Room A', 3, 13, '2025-11-12'),
(130, 4, 'ABC-123-4568', 'Available', 'Main Warehouse', 4, 13, '2025-11-12'),
(131, 5, 'DEF-456-7891', 'Available', 'Rooftop Unit 01', 5, 13, '2025-11-12'),
(132, 6, 'GHI-789-0124', 'Available', 'Floor 10 HVAC Room', 1, 13, '2025-11-12'),
(133, 7, 'JKL-234-5679', 'Available', 'Main Warehouse', 2, 13, '2025-11-12'),
(134, 8, 'MNO-567-8902', 'Available', 'Storage Room B', 3, 13, '2025-11-12'),
(135, 9, 'PQR-890-1235', 'Available', 'Rooftop Unit 02', 4, 13, '2025-11-12'),
(136, 10, 'STU-123-4568', 'Available', 'Main Warehouse', 5, 13, '2025-11-12'),
(137, 11, 'VWX-456-7891', 'Available', 'Floor 10 HVAC Room', 1, 13, '2025-11-12'),
(138, 12, 'YZA-789-0124', 'Available', 'Storage Room C', 2, 13, '2025-11-12'),
(139, 13, 'BCD-234-5679', 'Available', 'Main Warehouse', 3, 13, '2025-11-12'),
(140, 14, 'EFG-567-8902', 'Available', 'Rooftop Unit 03', 4, 13, '2025-11-12'),
(141, 15, 'HIJ-890-1235', 'Available', 'Floor 10 HVAC Room', 5, 13, '2025-11-12'),
(142, 16, 'KLM-123-4568', 'Available', 'Main Warehouse', 1, 13, '2025-11-12'),
(143, 17, 'NOP-456-7891', 'Available', 'Storage Room A', 2, 13, '2025-11-12'),
(144, 18, 'QRS-789-0124', 'Available', 'Rooftop Unit 01', 3, 13, '2025-11-12'),
(145, 19, 'TUV-234-5679', 'Available', 'Main Warehouse', 4, 13, '2025-11-12'),
(146, 20, 'WXY-567-8902', 'Available', 'Floor 10 HVAC Room', 5, 13, '2025-11-12'),
(147, 21, 'ZAB-890-1235', 'Available', 'Storage Room B', 1, 13, '2025-11-12'),
(148, 22, 'CDE-123-4568', 'Available', 'Main Warehouse', 2, 13, '2025-11-12'),
(149, 23, 'FGH-456-7891', 'Available', 'Rooftop Unit 02', 3, 13, '2025-11-12'),
(150, 24, 'IJK-789-0124', 'Available', 'Floor 10 HVAC Room', 4, 13, '2025-11-12'),
(151, 25, 'LMN-234-5679', 'Available', 'Main Warehouse', 5, 13, '2025-11-12');


ALTER TABLE RepairReport
ADD COLUMN inspectionResult ENUM('Eligible', 'NotEligible') DEFAULT 'Eligible';


ALTER TABLE Contract
ADD COLUMN fileAttachment VARCHAR(255);

DELETE FROM ContractEquipment 
WHERE equipmentId = 3 AND contractId = 10;

DELETE FROM ContractEquipment 
WHERE equipmentId = 2 AND contractId = 11;

DELETE FROM ContractEquipment 
WHERE equipmentId = 5 AND contractId = 11;

DELETE FROM Contract where contractId = 11;

DELETE FROM ContractEquipment 
WHERE equipmentId = 7 AND contractId = 3;

