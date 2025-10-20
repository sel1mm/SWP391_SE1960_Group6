-- =============================================
-- TECHNICIAN DEMO SEED DATA - UNIQUE VERSION
-- =============================================
-- This script adds comprehensive seed data for technician features demo
-- Uses unique IDs that don't conflict with existing data
-- Add this to the end of db_for_review.sql

-- =============================================
-- 1. ADDITIONAL CUSTOMERS FOR CONTRACT MANAGEMENT
-- =============================================

-- Add more customers for contract creation demo (starting from accountId 20)
INSERT INTO Account (accountId, username, passwordHash, fullName, email, phone, status, createdAt) VALUES 
(20, 'demo_customer_1', '$2a$12$rmfB.fZeS1UQVq/JiejzE.QYVzwp5HyJOnPJ3JaLRmsnYzF80IUuq', 'Nguyễn Văn Demo', 'demo.customer1@email.com', '0902000001', 'Active', NOW()),
(21, 'demo_customer_2', '$2a$12$rmfB.fZeS1UQVq/JiejzE.QYVzwp5HyJOnPJ3JaLRmsnYzF80IUuq', 'Trần Thị Demo', 'demo.customer2@email.com', '0902000002', 'Active', NOW()),
(22, 'demo_customer_3', '$2a$12$rmfB.fZeS1UQVq/JiejzE.QYVzwp5HyJOnPJ3JaLRmsnYzF80IUuq', 'Lê Văn Demo', 'demo.customer3@email.com', '0902000003', 'Active', NOW()),
(23, 'demo_customer_4', '$2a$12$rmfB.fZeS1UQVq/JiejzE.QYVzwp5HyJOnPJ3JaLRmsnYzF80IUuq', 'Phạm Thị Demo', 'demo.customer4@email.com', '0902000004', 'Active', NOW()),
(24, 'demo_customer_5', '$2a$12$rmfB.fZeS1UQVq/JiejzE.QYVzwp5HyJOnPJ3JaLRmsnYzF80IUuq', 'Hoàng Văn Demo', 'demo.customer5@email.com', '0902000005', 'Active', NOW());

-- Assign Customer role to these accounts
INSERT INTO AccountRole (accountId, roleId) VALUES 
(20, 2), (21, 2), (22, 2), (23, 2), (24, 2);

-- =============================================
-- 2. ADDITIONAL EQUIPMENT FOR CONTRACTS
-- =============================================

-- Add more equipment for contract management (starting from equipmentId 20)
INSERT INTO Equipment (equipmentId, serialNumber, model, description, installDate, lastUpdatedBy, lastUpdatedDate) VALUES 
(20, 'DEMO-EQ-001', 'Industrial Pump Model Demo A', 'High-pressure industrial water pump for demo', '2024-06-15', 1, CURDATE()),
(21, 'DEMO-EQ-002', 'Conveyor Belt System Demo B', 'Automated conveyor belt for manufacturing demo', '2024-07-20', 1, CURDATE()),
(22, 'DEMO-EQ-003', 'HVAC Unit Demo C', 'Commercial heating and cooling system demo', '2024-08-10', 1, CURDATE()),
(23, 'DEMO-EQ-004', 'Generator Model Demo D', 'Backup power generator 50kW demo', '2024-09-05', 1, CURDATE()),
(24, 'DEMO-EQ-005', 'Compressor Unit Demo E', 'Industrial air compressor system demo', '2024-10-12', 1, CURDATE());

-- =============================================
-- 3. CONTRACTS FOR TECHNICIAN MANAGEMENT
-- =============================================

-- Add contracts for technician to manage (starting from contractId 20)
INSERT INTO Contract (contractId, customerId, contractDate, contractType, status, details) VALUES 
(20, 20, '2024-06-15', 'Bảo trì', 'Active', 'Hợp đồng bảo trì thiết bị công nghiệp - Nguyễn Văn Demo'),
(21, 21, '2024-07-20', 'Bảo hành', 'Active', 'Hợp đồng bảo hành hệ thống sản xuất - Trần Thị Demo'),
(22, 22, '2024-08-10', 'Lắp đặt', 'Active', 'Hợp đồng lắp đặt hệ thống HVAC - Lê Văn Demo'),
(23, 23, '2024-09-05', 'Bảo trì', 'Completed', 'Hợp đồng bảo trì máy phát điện - Phạm Thị Demo'),
(24, 24, '2024-10-12', 'Sửa chữa', 'Active', 'Hợp đồng sửa chữa máy nén khí - Hoàng Văn Demo'),
(25, 20, '2024-11-01', 'Bảo hành', 'Cancelled', 'Hợp đồng bảo hành mở rộng bị hủy'),
(26, 21, '2024-11-15', 'Bảo trì', 'Active', 'Hợp đồng bảo trì hàng tháng'),
(27, 22, '2024-12-01', 'Lắp đặt', 'Active', 'Hợp đồng lắp đặt thiết bị mới');

-- Link equipment to contracts (starting from contractEquipmentId 20)
INSERT INTO ContractEquipment (contractEquipmentId, contractId, equipmentId, startDate, endDate, quantity, price) VALUES 
(20, 20, 20, '2024-06-15', '2025-06-15', 1, 5000000.00),
(21, 21, 21, '2024-07-20', '2026-07-20', 1, 8000000.00),
(22, 22, 22, '2024-08-10', '2025-08-10', 1, 12000000.00),
(23, 23, 23, '2024-09-05', '2024-12-05', 1, 3000000.00),
(24, 24, 24, '2024-10-12', '2025-01-12', 1, 4500000.00),
(25, 26, 20, '2024-11-15', '2025-02-15', 1, 2000000.00),
(26, 27, 21, '2024-12-01', '2025-06-01', 1, 6000000.00);

-- =============================================
-- 4. SERVICE REQUESTS FOR TECHNICIAN TASKS
-- =============================================

-- Add service requests that will become technician tasks (starting from requestId 20)
INSERT INTO ServiceRequest (requestId, contractId, equipmentId, createdBy, description, priorityLevel, requestDate, status, requestType) VALUES 
(20, 20, 20, 20, 'Máy bơm công nghiệp có tiếng ồn bất thường', 'High', NOW(), 'Approved', 'Service'),
(21, 21, 21, 21, 'Hệ thống băng tải cần điều chỉnh tốc độ', 'Normal', NOW(), 'Approved', 'Service'),
(22, 22, 22, 22, 'Hệ thống HVAC không làm mát đúng nhiệt độ', 'Urgent', NOW(), 'Approved', 'Service'),
(23, 23, 23, 23, 'Kiểm tra bảo trì máy phát điện', 'Normal', NOW(), 'Approved', 'Service'),
(24, 24, 24, 24, 'Máy nén khí có vấn đề về áp suất', 'High', NOW(), 'Approved', 'Service'),
(25, 26, 20, 20, 'Kiểm tra định kỳ máy bơm hàng tháng', 'Normal', NOW(), 'Approved', 'Service'),
(26, 27, 21, 21, 'Thay thế băng tải mới', 'High', NOW(), 'Approved', 'Service'),
(27, 20, 20, 20, 'Sửa chữa khẩn cấp máy bơm', 'Urgent', NOW(), 'Approved', 'Service');

-- =============================================
-- 5. WORK TASKS FOR TECHNICIAN ASSIGNMENT
-- =============================================

-- Add work tasks assigned to technician (accountId = 2, which is the technician account)
-- Starting from taskId 20
INSERT INTO WorkTask (taskId, requestId, scheduleId, technicianId, taskType, taskDetails, startDate, endDate, status) VALUES 
(20, 20, NULL, 2, 'Request', 'Kiểm tra máy bơm công nghiệp và thực hiện bảo trì', '2024-12-20', '2024-12-22', 'Assigned'),
(21, 21, NULL, 2, 'Request', 'Điều chỉnh tốc độ băng tải và kiểm tra căn chỉnh', '2024-12-21', '2024-12-23', 'Assigned'),
(22, 22, NULL, 2, 'Request', 'Chẩn đoán vấn đề làm mát HVAC và sửa chữa', '2024-12-22', '2024-12-24', 'In Progress'),
(23, 23, NULL, 2, 'Request', 'Thực hiện kiểm tra bảo trì máy phát điện', '2024-12-23', '2024-12-25', 'Assigned'),
(24, 24, NULL, 2, 'Request', 'Sửa chữa vấn đề áp suất máy nén khí', '2024-12-24', '2024-12-26', 'Assigned'),
(25, 25, NULL, 2, 'Request', 'Kiểm tra định kỳ máy bơm hàng tháng', '2024-12-25', '2024-12-27', 'Assigned'),
(26, 26, NULL, 2, 'Request', 'Thay thế băng tải mới và kiểm tra hoạt động', '2024-12-26', '2024-12-28', 'Assigned'),
(27, 27, NULL, 2, 'Request', 'Sửa chữa khẩn cấp máy bơm', '2024-12-27', '2024-12-29', 'Assigned'),
-- Add some completed tasks for work history
(28, 20, NULL, 2, 'Request', 'Bảo trì máy bơm trước đó đã hoàn thành', '2024-11-15', '2024-11-17', 'Completed'),
(29, 21, NULL, 2, 'Request', 'Sửa chữa băng tải trước đó đã hoàn thành', '2024-11-20', '2024-11-22', 'Completed'),
(30, 22, NULL, 2, 'Request', 'Sửa chữa HVAC trước đó đã hoàn thành', '2024-11-25', '2024-11-27', 'Completed');

-- =============================================
-- 6. REPAIR REPORTS FOR TECHNICIAN REPORTS
-- =============================================

-- Add repair reports for technician to view and create (starting from reportId 20)
INSERT INTO RepairReport (reportId, requestId, technicianId, details, diagnosis, estimatedCost, quotationStatus, repairDate, invoiceDetailId) VALUES 
(20, 20, 2, 'Kiểm tra máy bơm hoàn tất. Phát hiện mòn ổ trục gây tiếng ồn.', 'Mòn ổ trục do thiếu bôi trơn. Cần thay thế ổ trục.', 500000.00, 'Pending', '2024-12-20', NULL),
(21, 21, 2, 'Điều chỉnh băng tải hoàn tất. Bộ điều khiển tốc độ đã được hiệu chỉnh.', 'Vấn đề hiệu chỉnh bộ điều khiển tốc độ. Đã điều chỉnh độ căng băng tải.', 200000.00, 'Approved', '2024-12-21', NULL),
(22, 22, 2, 'Chẩn đoán hệ thống HVAC hoàn tất. Phát hiện rò rỉ gas lạnh.', 'Rò rỉ gas lạnh trong dàn ngưng. Cần sửa chữa rò rỉ và nạp lại gas.', 800000.00, 'Pending', '2024-12-22', NULL),
(23, 23, 2, 'Kiểm tra bảo trì máy phát điện hoàn tất thành công.', 'Bảo trì định kỳ đã thực hiện. Tất cả hệ thống hoạt động bình thường.', 150000.00, 'Approved', '2024-12-23', NULL),
(24, 24, 2, 'Vấn đề áp suất máy nén khí đã được giải quyết.', 'Thay thế van áp suất hoàn tất. Áp suất hệ thống đã được khôi phục.', 350000.00, 'Pending', '2024-12-24', NULL),
-- Add some completed reports for history
(25, 28, 2, 'Bảo trì máy bơm trước đó hoàn tất thành công.', 'Thay thế ổ trục hoàn tất. Máy bơm hoạt động bình thường.', 450000.00, 'Approved', '2024-11-17', NULL),
(26, 29, 2, 'Sửa chữa băng tải trước đó hoàn tất.', 'Thay thế băng tải và căn chỉnh hoàn tất.', 600000.00, 'Approved', '2024-11-22', NULL),
(27, 30, 2, 'Sửa chữa HVAC trước đó hoàn tất.', 'Sửa chữa rò rỉ gas và nạp lại hệ thống.', 750000.00, 'Approved', '2024-11-27', NULL);

-- =============================================
-- 7. MAINTENANCE SCHEDULES FOR SCHEDULED TASKS
-- =============================================

-- Add maintenance schedules for periodic tasks (starting from scheduleId 20)
INSERT INTO MaintenanceSchedule (scheduleId, requestId, contractId, equipmentId, assignedTo, scheduledDate, scheduleType, recurrenceRule, status, priorityId) VALUES 
(20, NULL, 20, 20, 2, '2024-12-30', 'Periodic', 'MONTHLY', 'Scheduled', 2),
(21, NULL, 21, 21, 2, '2025-01-15', 'Periodic', 'MONTHLY', 'Scheduled', 2),
(22, NULL, 22, 22, 2, '2025-01-20', 'Periodic', 'MONTHLY', 'Scheduled', 2),
(23, NULL, 23, 23, 2, '2025-01-25', 'Periodic', 'MONTHLY', 'Scheduled', 2),
(24, NULL, 24, 24, 2, '2025-01-30', 'Periodic', 'MONTHLY', 'Scheduled', 2);

-- =============================================
-- 8. REQUEST APPROVALS FOR WORKFLOW
-- =============================================

-- Add request approvals for the service requests (starting from approvalId 20)
INSERT INTO RequestApproval (approvalId, requestId, approvedBy, approvalDate, decision, note) VALUES 
(20, 20, 1, NOW(), 'Approved', 'Phê duyệt phân công cho kỹ thuật viên'),
(21, 21, 1, NOW(), 'Approved', 'Phê duyệt phân công cho kỹ thuật viên'),
(22, 22, 1, NOW(), 'Approved', 'Phê duyệt phân công khẩn cấp cho kỹ thuật viên'),
(23, 23, 1, NOW(), 'Approved', 'Phê duyệt phân công cho kỹ thuật viên'),
(24, 24, 1, NOW(), 'Approved', 'Phê duyệt phân công cho kỹ thuật viên'),
(25, 25, 1, NOW(), 'Approved', 'Phê duyệt phân công cho kỹ thuật viên'),
(26, 26, 1, NOW(), 'Approved', 'Phê duyệt phân công cho kỹ thuật viên'),
(27, 27, 1, NOW(), 'Approved', 'Phê duyệt phân công khẩn cấp cho kỹ thuật viên');

-- =============================================
-- 9. INVOICE DETAILS FOR REPAIR REPORTS
-- =============================================

-- Add invoice details for repair reports (starting from invoiceId 20)
INSERT INTO Invoice (invoiceId, contractId, issueDate, dueDate, totalAmount, status) VALUES 
(20, 20, '2024-12-20', '2025-01-20', 500000.00, 'Pending'),
(21, 21, '2024-12-21', '2025-01-21', 200000.00, 'Paid'),
(22, 22, '2024-12-22', '2025-01-22', 800000.00, 'Pending'),
(23, 23, '2024-12-23', '2025-01-23', 150000.00, 'Paid'),
(24, 24, '2024-12-24', '2025-01-24', 350000.00, 'Pending');

INSERT INTO InvoiceDetail (invoiceDetailId, invoiceId, description, amount) VALUES 
(20, 20, 'Thay thế ổ trục máy bơm', 500000.00),
(21, 21, 'Điều chỉnh băng tải', 200000.00),
(22, 22, 'Sửa chữa rò rỉ gas HVAC', 800000.00),
(23, 23, 'Bảo trì máy phát điện', 150000.00),
(24, 24, 'Thay thế van áp suất máy nén', 350000.00);

-- Update repair reports with invoice detail IDs
UPDATE RepairReport SET invoiceDetailId = 20 WHERE reportId = 20;
UPDATE RepairReport SET invoiceDetailId = 21 WHERE reportId = 21;
UPDATE RepairReport SET invoiceDetailId = 22 WHERE reportId = 22;
UPDATE RepairReport SET invoiceDetailId = 23 WHERE reportId = 23;
UPDATE RepairReport SET invoiceDetailId = 24 WHERE reportId = 24;

-- =============================================
-- 10. NOTIFICATIONS FOR TECHNICIAN
-- =============================================

-- Add notifications for technician (starting from notificationId 20)
INSERT INTO Notification (notificationId, accountId, notificationType, contractEquipmentId, message, createdAt, status) VALUES 
(20, 2, 'Warranty', 20, 'Thiết bị hợp đồng sắp đến hạn bảo trì', NOW(), 'Unread'),
(21, 2, 'System', NULL, 'Nhiệm vụ mới được phân công: Bảo trì máy bơm', NOW(), 'Unread'),
(22, 2, 'Warranty', 21, 'Băng tải bảo hành hết hạn trong 30 ngày', NOW(), 'Unread'),
(23, 2, 'System', NULL, 'Hạn chót nhiệm vụ sắp đến: Sửa chữa HVAC', NOW(), 'Unread'),
(24, 2, 'Other', 22, 'Nhận được phản hồi khách hàng về sửa chữa gần đây', NOW(), 'Unread');

-- =============================================
-- 11. SUPPORT TICKETS FOR TECHNICIAN CONTEXT
-- =============================================

-- Add support tickets related to technician work (starting from ticketId 20)
INSERT INTO SupportTicket (ticketId, customerId, supportStaffId, contractId, equipmentId, description, response, createdDate, closedDate) VALUES 
(20, 20, 1, 20, 20, 'Khách hàng báo cáo vấn đề tiếng ồn máy bơm', 'Kỹ thuật viên được phân công điều tra', '2024-12-19', NULL),
(21, 21, 1, 21, 21, 'Vấn đề tốc độ băng tải', 'Kỹ thuật viên được phân công điều chỉnh', '2024-12-20', '2024-12-21'),
(22, 22, 1, 22, 22, 'Hệ thống HVAC không làm mát', 'Phân công khẩn cấp cho kỹ thuật viên', '2024-12-21', NULL),
(23, 23, 1, 23, 23, 'Yêu cầu bảo trì máy phát điện', 'Kỹ thuật viên được phân công bảo trì', '2024-12-22', '2024-12-23'),
(24, 24, 1, 24, 24, 'Vấn đề áp suất máy nén', 'Kỹ thuật viên được phân công sửa chữa', '2024-12-23', NULL);

-- =============================================
-- DEMO DATA SUMMARY
-- =============================================
-- This seed data provides:
-- 1. 5 additional customers (accountId 20-24) for contract management
-- 2. 5 additional equipment items (equipmentId 20-24)
-- 3. 8 contracts (contractId 20-27) with various statuses
-- 4. 8 service requests (requestId 20-27) approved for technician assignment
-- 5. 11 work tasks (taskId 20-30) - 8 assigned + 3 completed for history
-- 6. 8 repair reports (reportId 20-27) - 5 pending + 3 completed for history
-- 7. 5 maintenance schedules (scheduleId 20-24) for periodic tasks
-- 8. 8 request approvals (approvalId 20-27) for workflow
-- 9. Invoice details for repair reports
-- 10. 5 notifications (notificationId 20-24) for technician dashboard
-- 11. 5 support tickets (ticketId 20-24) for context

-- All data is designed to work with technician account (accountId = 2)
-- and provides comprehensive demo scenarios for all technician features.
-- Uses Vietnamese descriptions to match existing data style.
