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
INSERT IGNORE INTO Role (roleId, roleName) VALUES 
(1, 'Admin'),
(2, 'Customer'),
(3, 'Customer Service Staff'),
(4, 'Technical Manager'),
(5, 'Technician');

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

-- Assign Roles to Accounts (matching corrected role IDs)
INSERT IGNORE INTO AccountRole (accountId, roleId) VALUES 
(1, 1), -- admin -> Admin
(2, 4), -- techmanager1 -> Technical Manager
(3, 4), -- techmanager2 -> Technical Manager
(4, 2), -- customer1 -> Customer
(5, 2), -- customer2 -> Customer
(6, 2), -- customer3 -> Customer
(7, 2), -- customer4 -> Customer
(8, 5), -- technician1 -> Technician
(9, 5), -- technician2 -> Technician
(10, 5), -- technician3 -> Technician
(11, 5), -- technician4 -> Technician
(12, 3); -- css1 -> Customer Service Staff

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

INSERT IGNORE INTO ServiceRequest (requestId, contractId, equipmentId, createdBy, description, priorityLevel, requestDate, status, requestType) VALUES 

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
(5, NULL, 6, 8, 'Scheduled', 'Bảo trì định kỳ hàng tháng máy lạnh', '2025-01-15', '2025-01-15', 'Assigned'),
(6, NULL, 7, 9, 'Scheduled', 'Bảo trì định kỳ hàng quý máy bơm', '2025-01-20', '2025-01-20', 'Assigned'),

-- Completed tasks
(7, NULL, 10, 8, 'Scheduled', 'Bảo trì định kỳ tháng 11', '2024-11-15', '2024-11-15', 'Completed'),
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