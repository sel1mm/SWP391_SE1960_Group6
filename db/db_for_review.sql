-- =============================================
-- SWP_FULL_FIXED.sql
-- Safe-to-run version (no foreign key / duplicate errors)
-- =============================================

SET FOREIGN_KEY_CHECKS = 0;

-- SWP FULL UNEDITED MERGE

-- BEGIN DBScript.sql

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





-- END DBScript.sql

-- BEGIN Database_Update_Script.sql
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
ALTER TABLE RequestApproval DROP INDEX requestId;

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
-- END Database_Update_Script.sql

-- BEGIN Add_Technician_Assignment_To_RequestApproval.sql
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
-- END Add_Technician_Assignment_To_RequestApproval.sql

-- BEGIN TechnicalManager_Schema_Updates.sql
-- ====================================================================
-- DATABASE SCHEMA MODIFICATIONS FOR TECHNICAL MANAGER FUNCTIONALITY
-- ====================================================================
-- This script contains all necessary database changes to support
-- Technical Manager features as specified in the requirements document.
--
-- Technical Manager Use Cases:
-- UC-05: Approve/Reject Service Request
-- UC-06: Assign Work to Technician  
-- UC-07: Schedule Maintenance
-- UC-08: Review Maintenance Report
-- ====================================================================

-- Technician module tables (idempotent)
CREATE TABLE IF NOT EXISTS tasks (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  status VARCHAR(50) NOT NULL,
  priority VARCHAR(50),
  due_date DATE,
  assigned_date DATE,
  assigned_technician_id BIGINT,
  equipment_needed TEXT
);

CREATE TABLE IF NOT EXISTS contracts (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  equipment_name VARCHAR(255) NOT NULL,
  quantity INT NOT NULL,
  unit_price DECIMAL(15,2) NULL,
  description TEXT,
  date DATE,
  technician_id BIGINT,
  task_id BIGINT
);

CREATE TABLE IF NOT EXISTS repair_reports (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  task_id BIGINT NOT NULL,
  summary VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  file_path VARCHAR(500),
  created_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS task_activity (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  task_id BIGINT NOT NULL,
  technician_id BIGINT,
  activity TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

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

DELIMITER //

CREATE TRIGGER trg_UpdateWorkloadOnTaskAssign
AFTER INSERT ON WorkTask
FOR EACH ROW
BEGIN
    -- Increment active task count when new task is assigned
    INSERT INTO TechnicianWorkload (technicianId, currentActiveTasks, maxConcurrentTasks, lastAssignedDate, lastUpdated)
    VALUES (NEW.technicianId, 1, 5, NOW(), NOW())
    ON DUPLICATE KEY UPDATE 
        currentActiveTasks = currentActiveTasks + 1,
        lastAssignedDate = NOW(),
        lastUpdated = NOW();
END//

CREATE TRIGGER trg_UpdateWorkloadOnTaskComplete
AFTER UPDATE ON WorkTask
FOR EACH ROW
BEGIN
    -- Decrement active task count and increment completed count when task is completed
    IF NEW.status = 'Completed' AND OLD.status != 'Completed' THEN
        UPDATE TechnicianWorkload
        SET currentActiveTasks = GREATEST(0, currentActiveTasks - 1),
            totalCompletedTasks = totalCompletedTasks + 1,
            lastUpdated = NOW()
        WHERE technicianId = NEW.technicianId;
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
SELECT 'Triggers Created' AS Check_Type,
       COUNT(*) AS Count_Result
FROM information_schema.triggers
WHERE trigger_schema = DATABASE()
  AND trigger_name IN (
    'trg_UpdateWorkloadOnTaskAssign', 'trg_UpdateWorkloadOnTaskComplete'
);

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
-- END TechnicalManager_Schema_Updates.sql

-- BEGIN TECHNICIAN_MIGRATION.sql
-- Technician module migration (idempotent). Run this on database `swp`.
-- This script ONLY adds new tables used by the Technician module and will not alter existing ones.

-- 1) Tasks assigned to technicians
CREATE TABLE IF NOT EXISTS tasks (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  status VARCHAR(50) NOT NULL,
  priority VARCHAR(50),
  due_date DATE,
  assigned_date DATE,
  assigned_technician_id BIGINT,
  equipment_needed TEXT,
  INDEX idx_tasks_assigned_technician (assigned_technician_id),
  INDEX idx_tasks_status (status),
  INDEX idx_tasks_due_date (due_date)
);

-- 2) Technician equipment contracts (separate from existing Contract table)
CREATE TABLE IF NOT EXISTS contracts (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  equipment_name VARCHAR(255) NOT NULL,
  quantity INT NOT NULL,
  unit_price DECIMAL(15,2) NULL,
  description TEXT,
  date DATE,
  technician_id BIGINT,
  task_id BIGINT,
  INDEX idx_contracts_task (task_id),
  INDEX idx_contracts_technician (technician_id)
);

-- 3) Repair reports submitted by technicians for tasks
CREATE TABLE IF NOT EXISTS repair_reports (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  task_id BIGINT NOT NULL,
  summary VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  file_path VARCHAR(500),
  created_date DATETIME DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_reports_task (task_id)
);

-- 4) Simple activity log for task status/comments
CREATE TABLE IF NOT EXISTS task_activity (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  task_id BIGINT NOT NULL,
  technician_id BIGINT,
  activity TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_activity_task (task_id)
);

-- Notes:
-- - Foreign keys are omitted to avoid conflicts with existing schema naming; you can add them later
--   if desired, referencing your Account/WorkTask tables.
-- - These tables are pluralized and independent of existing tables like `Contract` and `WorkTask`.
-- - If you prefer to integrate with existing `WorkTask`, adjust DAL queries accordingly.



-- END TECHNICIAN_MIGRATION.sql

-- BEGIN Technical_Manager_Test_Data.sql
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
-- 
-- 
-- 
-- 
-- 
-- 
-- 
-- 

-- Insert Test Accounts
INSERT INTO Account (accountId, username, passwordHash, fullName, email, phone, status, createdAt) VALUES 

-- Technical Managers
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

-- Assign Roles to Accounts (matching corrected role IDs)
INSERT INTO AccountRole (accountId, roleId) VALUES 
(3, 4), -- techmanager2 -> Technical Manager
(4, 2), -- customer1 -> Customer
(5, 2), -- customer2 -> Customer
(6, 2), -- customer3 -> Customer
(7, 2), -- customer4 -> Customer
(8, 6), -- technician1 -> Technician
(9, 6), -- technician2 -> Technician
(10, 6), -- technician3 -> Technician
(11, 6), -- technician4 -> Technician
(12, 3); -- css1 -> Customer Service Staff

-- ====================================================================
-- 2. PRIORITY LEVELS
-- ====================================================================

INSERT INTO Priority (priorityId, priorityName, priorityLevel, description) VALUES 
(1, 'Low', 1, 'Không khẩn cấp, có thể xử lý trong vòng 1 tuần'),
(2, 'Normal', 2, 'Mức độ bình thường, xử lý trong 2-3 ngày'),
(3, 'High', 3, 'Ưu tiên cao, cần xử lý trong 24 giờ'),
(4, 'Urgent', 4, 'Khẩn cấp, cần xử lý ngay lập tức');

-- ====================================================================
-- 3. EQUIPMENT AND CONTRACTS
-- ====================================================================

-- Equipment
INSERT INTO Equipment (equipmentId, serialNumber, model, description, installDate, lastUpdatedBy, lastUpdatedDate) VALUES 
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
INSERT INTO Contract (contractId, customerId, contractDate, contractType, status, details) VALUES 
(1, 4, '2024-01-01', 'Bảo trì', 'Active', 'Hợp đồng bảo trì thiết bị điều hòa - Lê Văn Khách'),
(2, 5, '2024-02-01', 'Bảo hành', 'Active', 'Hợp đồng bảo hành máy bơm - Phạm Thị Lan'),
(3, 6, '2024-02-15', 'Bảo trì', 'Active', 'Hợp đồng bảo trì hệ thống điện - Hoàng Văn Minh'),
(4, 7, '2024-03-01', 'Bảo hành', 'Active', 'Hợp đồng bảo hành HVAC - Vũ Thị Hoa'),
(5, 4, '2024-03-10', 'Bảo trì', 'Active', 'Hợp đồng bảo trì mở rộng - Lê Văn Khách');

-- Contract Equipment Relationships
INSERT INTO ContractEquipment (contractEquipmentId, contractId, equipmentId, startDate, endDate, quantity, price) VALUES 
-- Contract 1 - Customer 4 (Lê Văn Khách)
(1, 1, 1, '2024-01-01', '2024-12-31', 1, 5000000),
(2, 1, 2, '2024-02-01', '2024-12-31', 1, 6000000),

-- Contract 2 - Customer 5 (Phạm Thị Lan)
(3, 2, 5, '2024-02-01', '2025-02-01', 1, 8000000),
(4, 2, 6, '2024-02-10', '2025-02-10', 1, 12000000),

-- Contract 3 - Customer 6 (Hoàng Văn Minh)
(5, 3, 7, '2024-02-15', '2025-02-15', 1, 15000000),
(6, 3, 8, '2024-02-20', '2025-02-20', 1, 10000000),

-- Contract 4 - Customer 7 (Vũ Thị Hoa)
(7, 4, 9, '2024-03-01', '2025-03-01', 1, 25000000),
(8, 4, 10, '2024-03-20', '2025-03-20', 1, 30000000),

-- Contract 5 - Customer 4 (Lê Văn Khách) - Extended
(9, 5, 3, '2024-03-10', '2025-03-10', 1, 5500000),
(10, 5, 4, '2024-03-10', '2025-03-10', 1, 6500000);

-- ====================================================================
-- 4. SERVICE REQUESTS FOR TESTING APPROVAL WORKFLOW
-- ====================================================================

INSERT INTO ServiceRequest (requestId, contractId, equipmentId, createdBy, description, priorityLevel, requestDate, status, requestType) VALUES 

-- PENDING REQUESTS (for approval testing)
(1, 1, 1, 4, 'Máy lạnh không mát, tiếng ồn lớn khi hoạt động', 'Urgent', '2024-12-01', 'Pending', 'Service'),
(2, 1, 2, 4, 'Máy lạnh chảy nước, có mùi khó chịu', 'High', '2024-12-02', 'Pending', 'Service'),
(3, 2, 5, 5, 'Máy bơm không hoạt động, có tiếng kêu lạ', 'Normal', '2024-12-03', 'Pending', 'Warranty'),
(4, 3, 7, 6, 'Tủ điện bị nóng, cầu dao tự ngắt', 'Urgent', '2024-12-04', 'Pending', 'Service'),
(5, 2, 6, 5, 'Máy bơm công nghiệp giảm áp suất', 'High', '2024-12-05', 'Pending', 'Warranty'),
(6, 4, 9, 7, 'Hệ thống HVAC không đạt nhiệt độ', 'Normal', '2024-12-06', 'Pending', 'Warranty'),
(7, 3, 8, 6, 'Biến tần báo lỗi E001', 'High', '2024-12-07', 'Pending', 'Service'),
(8, 5, 3, 4, 'Máy lạnh phòng làm việc không khởi động', 'Normal', '2024-12-08', 'Pending', 'Service'),
(9, 4, 10, 7, 'Máy lạnh công nghiệp rò gas', 'Urgent', '2024-12-09', 'Pending', 'Warranty'),
(10, 5, 4, 4, 'Máy lạnh phòng khách có mùi cháy', 'Urgent', '2024-12-10', 'Pending', 'Service'),

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
(19, 1, 1, 4, 'Kiểm tra máy lạnh sau sửa chữa', 'Normal', CURDATE(), 'Pending', 'Service'),
(20, 2, 5, 5, 'Máy bơm có tiếng động lạ', 'High', CURDATE(), 'Pending', 'Warranty'),
(21, 3, 7, 6, 'Tủ điện báo cảnh báo', 'Urgent', CURDATE(), 'Pending', 'Service'),
(22, 5, 4, 4, 'Máy lạnh không tự động tắt', 'Normal', CURDATE(), 'Approved', 'Service');

-- ====================================================================
-- 5. REQUEST APPROVALS (for approved/rejected requests)
-- ====================================================================

INSERT INTO RequestApproval (approvalId, requestId, approvedBy, approvalDate, decision, note) VALUES 
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

INSERT INTO MaintenanceSchedule (scheduleId, requestId, contractId, equipmentId, assignedTo, scheduledDate, scheduleType, recurrenceRule, status, priorityId) VALUES 
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

INSERT INTO WorkTask (taskId, requestId, scheduleId, technicianId, taskType, taskDetails, startDate, endDate, status) VALUES 
-- Tasks from approved requests
(1, 11, 1, 8, 'Request', 'Bảo trì định kỳ máy lạnh: vệ sinh, kiểm tra gas, thay filter', '2024-12-15', '2024-12-15', 'Assigned'),
(2, 12, 2, 9, 'Request', 'Thay thế bộ lọc máy bơm và kiểm tra hệ thống', '2024-12-16', '2024-12-16', 'Assigned'),
(3, 13, 3, 10, 'Request', 'Kiểm tra toàn bộ hệ thống điện, đo điện trở cách điện', '2024-12-17', '2024-12-17', 'Assigned'),
(4, 14, 4, 11, 'Request', 'Bảo trì HVAC: vệ sinh dàn lạnh, kiểm tra hệ thống điều khiển', '2024-12-18', '2024-12-18', 'Assigned'),

-- Scheduled maintenance tasks
(5, NULL, 6, 8, 'Scheduled', 'Bảo trì định kỳ hàng tháng máy lạnh', '2025-01-15', '2025-01-15', 'Assigned'),
(6, NULL, 7, 9, 'Scheduled', 'Bảo trì định kỳ hàng quý máy bơm', '2025-01-20', '2025-01-20', 'Assigned'),

-- Completed tasks
(7, NULL, 10, 8, 'Scheduled', 'Bảo trì định kỳ tháng 11', '2024-11-15', '2024-11-15', 'Completed'),
(8, NULL, 11, 9, 'Scheduled', 'Bảo trì quý 4/2024', '2024-11-20', '2024-11-20', 'Completed');

-- ====================================================================
-- 8. REPAIR RESULTS (for completed tasks)
-- ====================================================================

INSERT INTO RepairResult (resultId, taskId, details, completionDate, technicianId, status) VALUES 
(1, 7, 'Đã hoàn thành bảo trì định kỳ. Vệ sinh dàn lạnh, thay filter, kiểm tra gas. Máy hoạt động bình thường.', '2024-11-15', 8, 'Completed'),
(2, 8, 'Bảo trì máy bơm hoàn tất. Thay dầu, kiểm tra áp suất, vệ sinh bộ lọc. Không phát hiện vấn đề.', '2024-11-20', 9, 'Completed');

-- ====================================================================
-- 9. ACCOUNT PROFILES (optional - for complete user information)
-- ====================================================================

INSERT INTO AccountProfile (profileId, accountId, address, dateOfBirth, nationalId, verified, extraData) VALUES 
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
-- END Technical_Manager_Test_Data.sql


INSERT INTO Account (
    accountId, username, passwordHash, fullName, email, phone, status
) VALUES (
    13,
    'storekeeper1',
    '$2a$12$/EBvaV2Yx3HLbxL642jaEuYKh3KY7PYf7pZ8KOze.B7ZDX16Ky0Ba',
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

