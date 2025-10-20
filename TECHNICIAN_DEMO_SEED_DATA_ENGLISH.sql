-- =============================================
-- TECHNICIAN DEMO SEED DATA - UNIQUE ENGLISH VERSION
-- =============================================
-- This script adds comprehensive seed data for technician features demo
-- Uses unique IDs that don't conflict with existing data
-- All descriptions in English to avoid encoding issues
-- Add this to the end of db_for_review.sql

-- =============================================
-- 1. ADDITIONAL CUSTOMERS FOR CONTRACT MANAGEMENT
-- =============================================

-- Add more customers for contract creation demo (starting from accountId 20)
INSERT INTO Account (accountId, username, passwordHash, fullName, email, phone, status, createdAt) VALUES 
(20, 'demo_customer_1', '$2a$12$rmfB.fZeS1UQVq/JiejzE.QYVzwp5HyJOnPJ3JaLRmsnYzF80IUuq', 'John Demo Smith', 'demo.customer1@email.com', '0902000001', 'Active', NOW()),
(21, 'demo_customer_2', '$2a$12$rmfB.fZeS1UQVq/JiejzE.QYVzwp5HyJOnPJ3JaLRmsnYzF80IUuq', 'Sarah Demo Johnson', 'demo.customer2@email.com', '0902000002', 'Active', NOW()),
(22, 'demo_customer_3', '$2a$12$rmfB.fZeS1UQVq/JiejzE.QYVzwp5HyJOnPJ3JaLRmsnYzF80IUuq', 'Mike Demo Wilson', 'demo.customer3@email.com', '0902000003', 'Active', NOW()),
(23, 'demo_customer_4', '$2a$12$rmfB.fZeS1UQVq/JiejzE.QYVzwp5HyJOnPJ3JaLRmsnYzF80IUuq', 'Lisa Demo Brown', 'demo.customer4@email.com', '0902000004', 'Active', NOW()),
(24, 'demo_customer_5', '$2a$12$rmfB.fZeS1UQVq/JiejzE.QYVzwp5HyJOnPJ3JaLRmsnYzF80IUuq', 'David Demo Lee', 'demo.customer5@email.com', '0902000005', 'Active', NOW());

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
(20, 20, '2024-06-15', 'Maintenance', 'Active', 'Annual maintenance contract for industrial equipment - John Demo Smith'),
(21, 21, '2024-07-20', 'Warranty', 'Active', 'Extended warranty service contract - Sarah Demo Johnson'),
(22, 22, '2024-08-10', 'Installation', 'Active', 'Equipment installation and setup contract - Mike Demo Wilson'),
(23, 23, '2024-09-05', 'Maintenance', 'Completed', 'Quarterly maintenance service contract - Lisa Demo Brown'),
(24, 24, '2024-10-12', 'Repair', 'Active', 'Emergency repair service contract - David Demo Lee'),
(25, 20, '2024-11-01', 'Warranty', 'Cancelled', 'Cancelled warranty extension contract'),
(26, 21, '2024-11-15', 'Maintenance', 'Active', 'Monthly maintenance contract'),
(27, 22, '2024-12-01', 'Installation', 'Active', 'New equipment installation contract');

-- Link equipment to contracts (starting from contractEquipmentId 20)
INSERT INTO ContractEquipment (contractEquipmentId, contractId, equipmentId, startDate, endDate, quantity, price) VALUES 
(20, 20, 20, '2024-06-15', '2025-06-15', 1, 5000.00),
(21, 21, 21, '2024-07-20', '2026-07-20', 1, 8000.00),
(22, 22, 22, '2024-08-10', '2025-08-10', 1, 12000.00),
(23, 23, 23, '2024-09-05', '2024-12-05', 1, 3000.00),
(24, 24, 24, '2024-10-12', '2025-01-12', 1, 4500.00),
(25, 26, 20, '2024-11-15', '2025-02-15', 1, 2000.00),
(26, 27, 21, '2024-12-01', '2025-06-01', 1, 6000.00);

-- =============================================
-- 4. SERVICE REQUESTS FOR TECHNICIAN TASKS
-- =============================================

-- Add service requests that will become technician tasks (starting from requestId 20)
INSERT INTO ServiceRequest (requestId, contractId, equipmentId, createdBy, description, priorityLevel, requestDate, status, requestType) VALUES 
(20, 20, 20, 20, 'Industrial pump making unusual noise - maintenance required', 'High', NOW(), 'Approved', 'Service'),
(21, 21, 21, 21, 'Conveyor belt needs speed adjustment - operational issues', 'Normal', NOW(), 'Approved', 'Service'),
(22, 22, 22, 22, 'HVAC system not cooling properly - urgent repair needed', 'Urgent', NOW(), 'Approved', 'Service'),
(23, 23, 23, 23, 'Generator maintenance check required', 'Normal', NOW(), 'Approved', 'Service'),
(24, 24, 24, 24, 'Compressor pressure issues - repair needed', 'High', NOW(), 'Approved', 'Service'),
(25, 26, 20, 20, 'Monthly pump inspection and service', 'Normal', NOW(), 'Approved', 'Service'),
(26, 27, 21, 21, 'Conveyor belt replacement required', 'High', NOW(), 'Approved', 'Service'),
(27, 20, 20, 20, 'Emergency pump repair - urgent service', 'Urgent', NOW(), 'Approved', 'Service');

-- =============================================
-- 5. WORK TASKS FOR TECHNICIAN ASSIGNMENT
-- =============================================

-- Add work tasks assigned to technician (accountId = 2, which is the technician account)
-- Starting from taskId 20
INSERT INTO WorkTask (taskId, requestId, scheduleId, technicianId, taskType, taskDetails, startDate, endDate, status) VALUES 
(20, 20, NULL, 2, 'Request', 'Inspect industrial pump for unusual noise and perform maintenance', '2024-12-20', '2024-12-22', 'Assigned'),
(21, 21, NULL, 2, 'Request', 'Adjust conveyor belt speed and check alignment', '2024-12-21', '2024-12-23', 'Assigned'),
(22, 22, NULL, 2, 'Request', 'Diagnose HVAC cooling issues and repair', '2024-12-22', '2024-12-24', 'In Progress'),
(23, 23, NULL, 2, 'Request', 'Perform generator maintenance check', '2024-12-23', '2024-12-25', 'Assigned'),
(24, 24, NULL, 2, 'Request', 'Fix compressor pressure issues', '2024-12-24', '2024-12-26', 'Assigned'),
(25, 25, NULL, 2, 'Request', 'Monthly pump inspection and service', '2024-12-25', '2024-12-27', 'Assigned'),
(26, 26, NULL, 2, 'Request', 'Replace conveyor belt and test operation', '2024-12-26', '2024-12-28', 'Assigned'),
(27, 27, NULL, 2, 'Request', 'Emergency pump repair - urgent', '2024-12-27', '2024-12-29', 'Assigned'),
-- Add some completed tasks for work history
(28, 20, NULL, 2, 'Request', 'Previous pump maintenance completed successfully', '2024-11-15', '2024-11-17', 'Completed'),
(29, 21, NULL, 2, 'Request', 'Previous conveyor belt repair completed', '2024-11-20', '2024-11-22', 'Completed'),
(30, 22, NULL, 2, 'Request', 'Previous HVAC repair completed', '2024-11-25', '2024-11-27', 'Completed');

-- =============================================
-- 6. REPAIR REPORTS FOR TECHNICIAN REPORTS
-- =============================================

-- Add repair reports for technician to view and create (starting from reportId 20)
INSERT INTO RepairReport (reportId, requestId, technicianId, details, diagnosis, estimatedCost, quotationStatus, repairDate, invoiceDetailId) VALUES 
(20, 20, 2, 'Pump inspection completed. Found bearing wear causing noise.', 'Bearing wear due to lack of lubrication. Requires bearing replacement.', 500.00, 'Pending', '2024-12-20', NULL),
(21, 21, 2, 'Conveyor belt adjusted. Speed controller calibrated.', 'Speed controller calibration issue. Belt tension adjusted.', 200.00, 'Approved', '2024-12-21', NULL),
(22, 22, 2, 'HVAC system diagnosed. Refrigerant leak found.', 'Refrigerant leak in condenser unit. Requires leak repair and refrigerant recharge.', 800.00, 'Pending', '2024-12-22', NULL),
(23, 23, 2, 'Generator maintenance completed successfully.', 'Routine maintenance performed. All systems functioning normally.', 150.00, 'Approved', '2024-12-23', NULL),
(24, 24, 2, 'Compressor pressure issues resolved.', 'Pressure valve replacement completed. System pressure restored.', 350.00, 'Pending', '2024-12-24', NULL),
-- Add some completed reports for history
(25, 28, 2, 'Previous pump maintenance completed successfully.', 'Bearing replacement completed. Pump operating normally.', 450.00, 'Approved', '2024-11-17', NULL),
(26, 29, 2, 'Previous conveyor belt repair completed.', 'Belt replacement and alignment completed.', 600.00, 'Approved', '2024-11-22', NULL),
(27, 30, 2, 'Previous HVAC repair completed.', 'Refrigerant leak repaired and system recharged.', 750.00, 'Approved', '2024-11-27', NULL);

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
(20, 20, 1, NOW(), 'Approved', 'Approved for technician assignment'),
(21, 21, 1, NOW(), 'Approved', 'Approved for technician assignment'),
(22, 22, 1, NOW(), 'Approved', 'Approved for urgent technician assignment'),
(23, 23, 1, NOW(), 'Approved', 'Approved for technician assignment'),
(24, 24, 1, NOW(), 'Approved', 'Approved for technician assignment'),
(25, 25, 1, NOW(), 'Approved', 'Approved for technician assignment'),
(26, 26, 1, NOW(), 'Approved', 'Approved for technician assignment'),
(27, 27, 1, NOW(), 'Approved', 'Approved for urgent technician assignment');

-- =============================================
-- 9. INVOICE DETAILS FOR REPAIR REPORTS
-- =============================================

-- Add invoice details for repair reports (starting from invoiceId 20)
INSERT INTO Invoice (invoiceId, contractId, issueDate, dueDate, totalAmount, status) VALUES 
(20, 20, '2024-12-20', '2025-01-20', 500.00, 'Pending'),
(21, 21, '2024-12-21', '2025-01-21', 200.00, 'Paid'),
(22, 22, '2024-12-22', '2025-01-22', 800.00, 'Pending'),
(23, 23, '2024-12-23', '2025-01-23', 150.00, 'Paid'),
(24, 24, '2024-12-24', '2025-01-24', 350.00, 'Pending');

INSERT INTO InvoiceDetail (invoiceDetailId, invoiceId, description, amount) VALUES 
(20, 20, 'Pump bearing replacement', 500.00),
(21, 21, 'Conveyor belt adjustment', 200.00),
(22, 22, 'HVAC refrigerant repair', 800.00),
(23, 23, 'Generator maintenance', 150.00),
(24, 24, 'Compressor pressure valve replacement', 350.00);

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
(20, 2, 'Warranty', 20, 'Contract equipment maintenance due soon', NOW(), 'Unread'),
(21, 2, 'System', NULL, 'New task assigned: Pump maintenance', NOW(), 'Unread'),
(22, 2, 'Warranty', 21, 'Conveyor belt warranty expires in 30 days', NOW(), 'Unread'),
(23, 2, 'System', NULL, 'Task deadline approaching: HVAC repair', NOW(), 'Unread'),
(24, 2, 'Other', 22, 'Customer feedback received for recent repair', NOW(), 'Unread');

-- =============================================
-- 11. SUPPORT TICKETS FOR TECHNICIAN CONTEXT
-- =============================================

-- Add support tickets related to technician work (starting from ticketId 20)
INSERT INTO SupportTicket (ticketId, customerId, supportStaffId, contractId, equipmentId, description, response, createdDate, closedDate) VALUES 
(20, 20, 1, 20, 20, 'Customer reported pump noise issue', 'Technician assigned to investigate', '2024-12-19', NULL),
(21, 21, 1, 21, 21, 'Conveyor belt speed problem', 'Technician assigned for adjustment', '2024-12-20', '2024-12-21'),
(22, 22, 1, 22, 22, 'HVAC cooling not working', 'Urgent technician assignment', '2024-12-21', NULL),
(23, 23, 1, 23, 23, 'Generator maintenance request', 'Technician assigned for maintenance', '2024-12-22', '2024-12-23'),
(24, 24, 1, 24, 24, 'Compressor pressure issues', 'Technician assigned for repair', '2024-12-23', NULL);

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
-- All descriptions in English to avoid encoding issues.
