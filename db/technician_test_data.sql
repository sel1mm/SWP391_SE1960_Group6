-- =============================================
-- TECHNICIAN MODULE TEST DATA
-- Comprehensive seed data for testing all technician features
-- Randomized data to avoid conflicts with existing data
-- =============================================

SET FOREIGN_KEY_CHECKS = 0;

-- =============================================
-- 1. Additional Test Accounts (Customers & Technicians)
-- =============================================

-- Additional Customers (accountId 6-15)
INSERT INTO Account (accountId, username, passwordHash, fullName, email, phone, status, createdAt) VALUES
(6, 'customer2', '$2a$12$rmfB.fZeS1UQVq/JiejzE.QYVzwp5HyJOnPJ3JaLRmsnYzF80IUuq', 'Nguyễn Văn Minh', 'customer2@gmail.com', '0902000001', 'Active', NOW()),
(7, 'customer3', '$2a$12$rmfB.fZeS1UQVq/JiejzE.QYVzwp5HyJOnPJ3JaLRmsnYzF80IUuq', 'Trần Thị Hương', 'customer3@gmail.com', '0902000002', 'Active', NOW()),
(8, 'customer4', '$2a$12$rmfB.fZeS1UQVq/JiejzE.QYVzwp5HyJOnPJ3JaLRmsnYzF80IUuq', 'Lê Văn Đức', 'customer4@gmail.com', '0902000003', 'Active', NOW()),
(9, 'customer5', '$2a$12$rmfB.fZeS1UQVq/JiejzE.QYVzwp5HyJOnPJ3JaLRmsnYzF80IUuq', 'Phạm Thị Mai', 'customer5@gmail.com', '0902000004', 'Active', NOW()),
(10, 'customer6', '$2a$12$rmfB.fZeS1UQVq/JiejzE.QYVzwp5HyJOnPJ3JaLRmsnYzF80IUuq', 'Hoàng Văn Nam', 'customer6@gmail.com', '0902000005', 'Active', NOW()),
(11, 'customer7', '$2a$12$rmfB.fZeS1UQVq/JiejzE.QYVzwp5HyJOnPJ3JaLRmsnYzF80IUuq', 'Vũ Thị Lan', 'customer7@gmail.com', '0902000006', 'Active', NOW()),
(12, 'customer8', '$2a$12$rmfB.fZeS1UQVq/JiejzE.QYVzwp5HyJOnPJ3JaLRmsnYzF80IUuq', 'Đặng Văn Hùng', 'customer8@gmail.com', '0902000007', 'Active', NOW()),
(13, 'customer9', '$2a$12$rmfB.fZeS1UQVq/JiejzE.QYVzwp5HyJOnPJ3JaLRmsnYzF80IUuq', 'Bùi Thị Thu', 'customer9@gmail.com', '0902000008', 'Active', NOW()),
(14, 'customer10', '$2a$12$rmfB.fZeS1UQVq/JiejzE.QYVzwp5HyJOnPJ3JaLRmsnYzF80IUuq', 'Ngô Văn Tài', 'customer10@gmail.com', '0902000009', 'Active', NOW()),
(15, 'customer11', '$2a$12$rmfB.fZeS1UQVq/JiejzE.QYVzwp5HyJOnPJ3JaLRmsnYzF80IUuq', 'Đinh Thị Hoa', 'customer11@gmail.com', '0902000010', 'Active', NOW());

-- Additional Technicians (accountId 16-20)
INSERT INTO Account (accountId, username, passwordHash, fullName, email, phone, status, createdAt) VALUES
(16, 'technician3', '$2a$12$rmfB.fZeS1UQVq/JiejzE.QYVzwp5HyJOnPJ3JaLRmsnYzF80IUuq', 'Võ Văn Cường', 'technician3@crm.com', '0903000001', 'Active', NOW()),
(17, 'technician4', '$2a$12$rmfB.fZeS1UQVq/JiejzE.QYVzwp5HyJOnPJ3JaLRmsnYzF80IUuq', 'Nguyễn Thị Linh', 'technician4@crm.com', '0903000002', 'Active', NOW()),
(18, 'technician5', '$2a$12$rmfB.fZeS1UQVq/JiejzE.QYVzwp5HyJOnPJ3JaLRmsnYzF80IUuq', 'Trần Văn Bình', 'technician5@crm.com', '0903000003', 'Active', NOW()),
(19, 'technician6', '$2a$12$rmfB.fZeS1UQVq/JiejzE.QYVzwp5HyJOnPJ3JaLRmsnYzF80IUuq', 'Lê Thị Hạnh', 'technician6@crm.com', '0903000004', 'Active', NOW()),
(20, 'technician7', '$2a$12$rmfB.fZeS1UQVq/JiejzE.QYVzwp5HyJOnPJ3JaLRmsnYzF80IUuq', 'Phạm Văn Thành', 'technician7@crm.com', '0903000005', 'Active', NOW());

-- Assign roles to new accounts
INSERT INTO AccountRole (accountId, roleId) VALUES
-- Customers (roleId = 2)
(6,2), (7,2), (8,2), (9,2), (10,2), (11,2), (12,2), (13,2), (14,2), (15,2),
-- Technicians (roleId = 6)
(16,6), (17,6), (18,6), (19,6), (20,6);

-- =============================================
-- 2. Additional Equipment Data
-- =============================================

INSERT INTO Equipment (equipmentId, serialNumber, model, description, installDate, lastUpdatedBy, lastUpdatedDate) VALUES
(2, 'HVAC002', 'Carrier 30HXC036', 'Chiller trung tâm 36kW', '2024-11-15', 1, '2024-11-15'),
(3, 'HVAC003', 'Mitsubishi Electric PUMY-P112VKM', 'Máy lạnh VRV 11.2kW', '2024-12-01', 1, '2024-12-01'),
(4, 'HVAC004', 'Daikin FTKC35UAVMV', 'Máy lạnh trung tâm 35kW', '2024-10-20', 1, '2024-10-20'),
(5, 'HVAC005', 'York YCIV0155', 'Chiller nước 155kW', '2024-09-10', 1, '2024-09-10'),
(6, 'HVAC006', 'Trane RTWD150', 'Chiller không khí 150kW', '2024-08-25', 1, '2024-08-25'),
(7, 'HVAC007', 'LG Multi V5 S120', 'Hệ thống VRV 120kW', '2024-07-30', 1, '2024-07-30'),
(8, 'HVAC008', 'Samsung DVM S ECO', 'Máy lạnh VRV 80kW', '2024-06-15', 1, '2024-06-15'),
(9, 'HVAC009', 'Fujitsu Airstage VRF', 'Hệ thống VRF 100kW', '2024-05-20', 1, '2024-05-20'),
(10, 'HVAC010', 'Hitachi SET-FREE', 'Máy lạnh VRV 90kW', '2024-04-10', 1, '2024-04-10'),
(11, 'HVAC011', 'Gree VRF', 'Hệ thống VRF 110kW', '2024-03-05', 1, '2024-03-05'),
(12, 'HVAC012', 'Midea VRF', 'Máy lạnh VRV 75kW', '2024-02-15', 1, '2024-02-15'),
(13, 'HVAC013', 'Haier VRF', 'Hệ thống VRF 85kW', '2024-01-20', 1, '2024-01-20'),
(14, 'HVAC014', 'Panasonic VRF', 'Máy lạnh VRV 95kW', '2023-12-10', 1, '2023-12-10'),
(15, 'HVAC015', 'Sharp VRF', 'Hệ thống VRF 105kW', '2023-11-25', 1, '2023-11-25');

-- =============================================
-- 3. Additional Contracts Data
-- =============================================

INSERT INTO Contract (contractId, customerId, contractDate, contractType, status, details) VALUES
(2, 6, '2024-11-01', 'Equipment Lease', 'Active', 'Hợp đồng thuê máy lạnh trung tâm Carrier'),
(3, 7, '2024-12-01', 'Maintenance Agreement', 'Active', 'Hợp đồng bảo trì hệ thống VRV Mitsubishi'),
(4, 8, '2024-10-15', 'Equipment Purchase', 'Active', 'Hợp đồng mua máy lạnh Daikin'),
(5, 9, '2024-09-20', 'Service Contract', 'Active', 'Hợp đồng dịch vụ chiller York'),
(6, 10, '2024-08-30', 'Equipment Lease', 'Active', 'Hợp đồng thuê chiller Trane'),
(7, 11, '2024-07-25', 'Maintenance Agreement', 'Active', 'Hợp đồng bảo trì hệ thống LG Multi V5'),
(8, 12, '2024-06-20', 'Equipment Purchase', 'Active', 'Hợp đồng mua máy lạnh Samsung DVM'),
(9, 13, '2024-05-15', 'Service Contract', 'Active', 'Hợp đồng dịch vụ Fujitsu Airstage'),
(10, 14, '2024-04-10', 'Equipment Lease', 'Active', 'Hợp đồng thuê Hitachi SET-FREE'),
(11, 15, '2024-03-05', 'Maintenance Agreement', 'Active', 'Hợp đồng bảo trì hệ thống Gree VRF'),
(12, 6, '2024-02-20', 'Equipment Purchase', 'Active', 'Hợp đồng mua máy lạnh Midea VRF'),
(13, 7, '2024-01-15', 'Service Contract', 'Active', 'Hợp đồng dịch vụ Haier VRF'),
(14, 8, '2023-12-20', 'Equipment Lease', 'Active', 'Hợp đồng thuê Panasonic VRF'),
(15, 9, '2023-11-25', 'Maintenance Agreement', 'Active', 'Hợp đồng bảo trì hệ thống Sharp VRF');

-- =============================================
-- 4. Contract Equipment Relationships
-- =============================================

INSERT INTO ContractEquipment (contractEquipmentId, contractId, equipmentId, startDate, endDate, quantity, price) VALUES
(2, 2, 2, '2024-11-01', '2025-10-31', 1, 8000000),
(3, 3, 3, '2024-12-01', '2025-11-30', 1, 12000000),
(4, 4, 4, '2024-10-15', '2025-10-14', 1, 9500000),
(5, 5, 5, '2024-09-20', '2025-09-19', 1, 15000000),
(6, 6, 6, '2024-08-30', '2025-08-29', 1, 18000000),
(7, 7, 7, '2024-07-25', '2025-07-24', 1, 20000000),
(8, 8, 8, '2024-06-20', '2025-06-19', 1, 16000000),
(9, 9, 9, '2024-05-15', '2025-05-14', 1, 14000000),
(10, 10, 10, '2024-04-10', '2025-04-09', 1, 13000000),
(11, 11, 11, '2024-03-05', '2025-03-04', 1, 17000000),
(12, 12, 12, '2024-02-20', '2025-02-19', 1, 11000000),
(13, 13, 13, '2024-01-15', '2025-01-14', 1, 12500000),
(14, 14, 14, '2023-12-20', '2024-12-19', 1, 13500000),
(15, 15, 15, '2023-11-25', '2024-11-24', 1, 14500000);

-- =============================================
-- 5. Service Requests Data
-- =============================================

INSERT INTO ServiceRequest (requestId, contractId, equipmentId, createdBy, description, priorityLevel, requestDate, status, requestType) VALUES
(2, 2, 2, 6, 'Máy lạnh Carrier không hoạt động', 'High', '2025-01-15', 'Approved', 'Service'),
(3, 3, 3, 7, 'Hệ thống VRV Mitsubishi có tiếng ồn', 'Normal', '2025-01-20', 'Approved', 'Service'),
(4, 4, 4, 8, 'Máy lạnh Daikin không mát', 'Urgent', '2025-01-25', 'Approved', 'Service'),
(5, 5, 5, 9, 'Chiller York báo lỗi áp suất', 'High', '2025-02-01', 'Approved', 'Service'),
(6, 6, 6, 10, 'Chiller Trane rò rỉ nước', 'Normal', '2025-02-05', 'Approved', 'Service'),
(7, 7, 7, 11, 'Hệ thống LG Multi V5 không khởi động', 'Urgent', '2025-02-10', 'Approved', 'Service'),
(8, 8, 8, 12, 'Máy lạnh Samsung DVM báo lỗi sensor', 'High', '2025-02-15', 'Approved', 'Service'),
(9, 9, 9, 13, 'Fujitsu Airstage không làm lạnh', 'Normal', '2025-02-20', 'Approved', 'Service'),
(10, 10, 10, 14, 'Hitachi SET-FREE có mùi lạ', 'High', '2025-02-25', 'Approved', 'Service'),
(11, 11, 11, 15, 'Gree VRF tiêu thụ điện cao', 'Normal', '2025-03-01', 'Approved', 'Service'),
(12, 12, 12, 6, 'Midea VRF không điều khiển được', 'Urgent', '2025-03-05', 'Approved', 'Service'),
(13, 13, 13, 7, 'Haier VRF báo lỗi compressor', 'High', '2025-03-10', 'Approved', 'Service'),
(14, 14, 14, 8, 'Panasonic VRF không đạt nhiệt độ', 'Normal', '2025-03-15', 'Approved', 'Service'),
(15, 15, 15, 9, 'Sharp VRF có tiếng kêu lạ', 'High', '2025-03-20', 'Approved', 'Service');

-- =============================================
-- 6. Maintenance Schedules Data
-- =============================================

INSERT INTO MaintenanceSchedule (scheduleId, requestId, contractId, equipmentId, assignedTo, scheduledDate, scheduleType, status, priorityId) VALUES
(2, 2, 2, 2, 16, '2025-01-18', 'Request', 'Scheduled', 3),
(3, 3, 3, 3, 17, '2025-01-23', 'Request', 'Scheduled', 2),
(4, 4, 4, 4, 18, '2025-01-28', 'Request', 'Scheduled', 4),
(5, 5, 5, 5, 19, '2025-02-03', 'Request', 'Scheduled', 3),
(6, 6, 6, 6, 20, '2025-02-08', 'Request', 'Scheduled', 2),
(7, 7, 7, 7, 3, '2025-02-13', 'Request', 'Scheduled', 4),
(8, 8, 8, 8, 4, '2025-02-18', 'Request', 'Scheduled', 3),
(9, 9, 9, 9, 16, '2025-02-23', 'Request', 'Scheduled', 2),
(10, 10, 10, 10, 17, '2025-02-28', 'Request', 'Scheduled', 3),
(11, 11, 11, 11, 18, '2025-03-03', 'Request', 'Scheduled', 2),
(12, 12, 12, 12, 19, '2025-03-08', 'Request', 'Scheduled', 4),
(13, 13, 13, 13, 20, '2025-03-13', 'Request', 'Scheduled', 3),
(14, 14, 14, 14, 3, '2025-03-18', 'Request', 'Scheduled', 2),
(15, 15, 15, 15, 4, '2025-03-23', 'Request', 'Scheduled', 3);

-- =============================================
-- 7. Work Tasks Data (Various Statuses)
-- =============================================

INSERT INTO WorkTask (taskId, requestId, scheduleId, technicianId, taskType, taskDetails, startDate, endDate, status) VALUES
-- Completed tasks
(2, 2, 2, 16, 'Request', 'Kiểm tra và sửa chữa máy lạnh Carrier', '2025-01-18', '2025-01-18', 'Completed'),
(3, 3, 3, 17, 'Request', 'Khắc phục tiếng ồn hệ thống VRV Mitsubishi', '2025-01-23', '2025-01-23', 'Completed'),
(4, 4, 4, 18, 'Request', 'Bảo trì máy lạnh Daikin', '2025-01-28', '2025-01-28', 'Completed'),

-- In Progress tasks
(5, 5, 5, 19, 'Request', 'Sửa chữa chiller York', '2025-02-03', NULL, 'In Progress'),
(6, 6, 6, 20, 'Request', 'Khắc phục rò rỉ chiller Trane', '2025-02-08', NULL, 'In Progress'),

-- Pending tasks
(7, 7, 7, 3, 'Request', 'Kiểm tra hệ thống LG Multi V5', '2025-02-13', NULL, 'Pending'),
(8, 8, 8, 4, 'Request', 'Sửa chữa sensor máy lạnh Samsung', '2025-02-18', NULL, 'Pending'),
(9, 9, 9, 16, 'Request', 'Bảo trì Fujitsu Airstage', '2025-02-23', NULL, 'Pending'),

-- On Hold tasks
(10, 10, 10, 17, 'Request', 'Kiểm tra mùi lạ Hitachi SET-FREE', '2025-02-28', NULL, 'On Hold'),
(11, 11, 11, 18, 'Request', 'Tối ưu tiêu thụ điện Gree VRF', '2025-03-03', NULL, 'On Hold'),

-- Assigned tasks
(12, 12, 12, 19, 'Request', 'Sửa chữa điều khiển Midea VRF', '2025-03-08', NULL, 'Assigned'),
(13, 13, 13, 20, 'Request', 'Thay thế compressor Haier VRF', '2025-03-13', NULL, 'Assigned'),
(14, 14, 14, 3, 'Request', 'Kiểm tra nhiệt độ Panasonic VRF', '2025-03-18', NULL, 'Assigned'),
(15, 15, 15, 4, 'Request', 'Khắc phục tiếng kêu Sharp VRF', '2025-03-23', NULL, 'Assigned');

-- =============================================
-- 8. Repair Reports Data (Various Statuses)
-- =============================================

INSERT INTO RepairReport (reportId, requestId, technicianId, details, diagnosis, estimatedCost, quotationStatus, repairDate) VALUES
-- Completed reports
(2, 2, 16, 'Thay thế board điều khiển và kiểm tra hệ thống', 'Board điều khiển bị hỏng do sét đánh', 2500000, 'Approved', '2025-01-18'),
(3, 3, 17, 'Vệ sinh dàn lạnh và cân chỉnh van tiết lưu', 'Van tiết lưu bị nghẹt, dàn lạnh bẩn', 1800000, 'Approved', '2025-01-23'),
(4, 4, 18, 'Thay gas và kiểm tra hệ thống làm lạnh', 'Thiếu gas R410A, hệ thống hoạt động bình thường', 2200000, 'Approved', '2025-01-28'),

-- Pending reports
(5, 5, 19, 'Kiểm tra áp suất và thay thế sensor', 'Sensor áp suất bị lỗi, cần thay thế', 3200000, 'Pending', '2025-02-05'),
(6, 6, 20, 'Sửa chữa đường ống và kiểm tra hệ thống', 'Đường ống bị rò rỉ tại mối nối', 2800000, 'Pending', '2025-02-10'),
(7, 7, 3, 'Thay thế inverter và kiểm tra điện', 'Inverter bị hỏng do điện áp không ổn định', 4500000, 'Pending', '2025-02-15'),
(8, 8, 4, 'Sửa chữa sensor nhiệt độ và hiệu chỉnh', 'Sensor nhiệt độ bị lỗi, cần hiệu chỉnh', 1900000, 'Pending', '2025-02-20'),
(9, 9, 16, 'Kiểm tra hệ thống làm lạnh và thay gas', 'Thiếu gas, hệ thống cần bảo trì định kỳ', 2100000, 'Pending', '2025-02-25'),

-- General reports (no requestId)
(10, 0, 17, 'Bảo trì định kỳ hệ thống HVAC', 'Kiểm tra tổng thể hệ thống, thay thế bộ lọc', 1500000, 'Pending', '2025-03-01'),
(11, 0, 18, 'Sửa chữa hệ thống điều hòa không khí', 'Hệ thống không hoạt động, cần kiểm tra điện', 3800000, 'Pending', '2025-03-05'),
(12, 0, 19, 'Thay thế máy nén và bảo trì hệ thống', 'Máy nén bị hỏng, cần thay thế hoàn toàn', 8500000, 'Pending', '2025-03-10');

-- =============================================
-- 9. Repair Results Data
-- =============================================

INSERT INTO RepairResult (resultId, taskId, details, completionDate, technicianId, status) VALUES
(2, 2, 'Hoàn thành tốt, máy lạnh hoạt động bình thường', '2025-01-19', 16, 'Completed'),
(3, 3, 'Khắc phục thành công tiếng ồn, hệ thống ổn định', '2025-01-24', 17, 'Completed'),
(4, 4, 'Bảo trì hoàn tất, máy lạnh làm lạnh tốt', '2025-01-29', 18, 'Completed');

-- =============================================
-- 10. Additional Test Contracts for Contract Creation Testing
-- =============================================

INSERT INTO Contract (contractId, customerId, contractDate, contractType, status, details) VALUES
(16, 10, '2025-01-10', 'Equipment Lease', 'Active', 'Hợp đồng thuê máy lạnh mới'),
(17, 11, '2025-01-15', 'Maintenance Agreement', 'Active', 'Hợp đồng bảo trì hệ thống HVAC'),
(18, 12, '2025-01-20', 'Service Contract', 'Completed', 'Hợp đồng dịch vụ sửa chữa đã hoàn thành'),
(19, 13, '2025-01-25', 'Equipment Purchase', 'Active', 'Hợp đồng mua thiết bị mới'),
(20, 14, '2025-01-30', 'Equipment Lease', 'Cancelled', 'Hợp đồng thuê chiller đã hủy');

-- =============================================
-- 11. Additional Equipment for Contract Testing
-- =============================================

INSERT INTO Equipment (equipmentId, serialNumber, model, description, installDate, lastUpdatedBy, lastUpdatedDate) VALUES
(16, 'HVAC016', 'Daikin FTKC50UAVMV', 'Máy lạnh trung tâm 50kW', '2025-01-05', 1, '2025-01-05'),
(17, 'HVAC017', 'Carrier 30HXC048', 'Chiller trung tâm 48kW', '2025-01-10', 1, '2025-01-10'),
(18, 'HVAC018', 'Mitsubishi Electric PUMY-P140VKM', 'Máy lạnh VRV 14kW', '2025-01-15', 1, '2025-01-15'),
(19, 'HVAC019', 'York YCIV0200', 'Chiller nước 200kW', '2025-01-20', 1, '2025-01-20'),
(20, 'HVAC020', 'Trane RTWD200', 'Chiller không khí 200kW', '2025-01-25', 1, '2025-01-25');

-- =============================================
-- 12. Contract Equipment for New Contracts
-- =============================================

INSERT INTO ContractEquipment (contractEquipmentId, contractId, equipmentId, startDate, endDate, quantity, price) VALUES
(16, 16, 16, '2025-01-10', '2026-01-09', 1, 12000000),
(17, 17, 17, '2025-01-15', '2026-01-14', 1, 15000000),
(18, 18, 18, '2025-01-20', '2026-01-19', 1, 18000000),
(19, 19, 19, '2025-01-25', '2026-01-24', 1, 25000000),
(20, 20, 20, '2025-01-30', '2026-01-29', 1, 22000000);

SET FOREIGN_KEY_CHECKS = 1;

-- =============================================
-- ✅ TEST DATA SUMMARY
-- =============================================

SELECT '✅ Technician Module Test Data Created Successfully' AS status;

-- Show summary of created data
SELECT 'Accounts' AS table_name, COUNT(*) AS count FROM Account WHERE accountId > 5;
SELECT 'Contracts' AS table_name, COUNT(*) AS count FROM Contract WHERE contractId > 1;
SELECT 'Equipment' AS table_name, COUNT(*) AS count FROM Equipment WHERE equipmentId > 1;
SELECT 'ServiceRequests' AS table_name, COUNT(*) AS count FROM ServiceRequest WHERE requestId > 1;
SELECT 'WorkTasks' AS table_name, COUNT(*) AS count FROM WorkTask WHERE taskId > 1;
SELECT 'RepairReports' AS table_name, COUNT(*) AS count FROM RepairReport WHERE reportId > 1;

-- Show technician accounts for testing
SELECT accountId, username, fullName, email FROM Account WHERE accountId IN (3,4,16,17,18,19,20);

-- Show customer accounts for contract creation testing
SELECT accountId, username, fullName, email FROM Account WHERE accountId BETWEEN 6 AND 15;

-- Show work tasks by status for testing
SELECT status, COUNT(*) AS count FROM WorkTask GROUP BY status;

-- Show repair reports by status for testing
SELECT quotationStatus, COUNT(*) AS count FROM RepairReport GROUP BY quotationStatus;
