-- =============================================
-- TECHNICIAN DEMO SEED DATA
-- =============================================
-- This script adds comprehensive seed data for technician features demo
-- Add this to the end of db_for_review.sql

-- =============================================
-- 1. ADDITIONAL CUSTOMERS FOR CONTRACT MANAGEMENT
-- =============================================

-- Add more customers for contract creation demo
INSERT INTO Account (accountId, username, passwordHash, fullName, email, phone, status, createdAt) VALUES 
(101, 'customer1', '$2a$12$rmfB.fZeS1UQVq/JiejzE.QYVzwp5HyJOnPJ3JaLRmsnYzF80IUuq', 'John Smith', 'john.smith@email.com', '0123456789', 'Active', NOW()),
(102, 'customer2', '$2a$12$rmfB.fZeS1UQVq/JiejzE.QYVzwp5HyJOnPJ3JaLRmsnYzF80IUuq', 'Sarah Johnson', 'sarah.johnson@email.com', '0123456790', 'Active', NOW()),
(103, 'customer3', '$2a$12$rmfB.fZeS1UQVq/JiejzE.QYVzwp5HyJOnPJ3JaLRmsnYzF80IUuq', 'Mike Wilson', 'mike.wilson@email.com', '0123456791', 'Active', NOW()),
(104, 'customer4', '$2a$12$rmfB.fZeS1UQVq/JiejzE.QYVzwp5HyJOnPJ3JaLRmsnYzF80IUuq', 'Lisa Brown', 'lisa.brown@email.com', '0123456792', 'Active', NOW()),
(105, 'customer5', '$2a$12$rmfB.fZeS1UQVq/JiejzE.QYVzwp5HyJOnPJ3JaLRmsnYzF80IUuq', 'David Lee', 'david.lee@email.com', '0123456793', 'Active', NOW());

-- Assign Customer role to these accounts
INSERT INTO AccountRole (accountId, roleId) VALUES 
(101, 2), (102, 2), (103, 2), (104, 2), (105, 2);

-- =============================================
-- 2. ADDITIONAL EQUIPMENT FOR CONTRACTS
-- =============================================

-- Add more equipment for contract management
INSERT INTO Equipment (equipmentId, serialNumber, model, description, installDate, lastUpdatedBy, lastUpdatedDate) VALUES 
(101, 'EQ-001', 'Industrial Pump Model A', 'High-pressure industrial water pump', '2024-01-15', 1, CURDATE()),
(102, 'EQ-002', 'Conveyor Belt System B', 'Automated conveyor belt for manufacturing', '2024-02-20', 1, CURDATE()),
(103, 'EQ-003', 'HVAC Unit C', 'Commercial heating and cooling system', '2024-03-10', 1, CURDATE()),
(104, 'EQ-004', 'Generator Model D', 'Backup power generator 50kW', '2024-04-05', 1, CURDATE()),
(105, 'EQ-005', 'Compressor Unit E', 'Industrial air compressor system', '2024-05-12', 1, CURDATE());

-- =============================================
-- 3. CONTRACTS FOR TECHNICIAN MANAGEMENT
-- =============================================

-- Add contracts for technician to manage
INSERT INTO Contract (contractId, customerId, contractDate, contractType, status, details) VALUES 
(101, 101, '2024-01-15', 'Maintenance', 'Active', 'Annual maintenance contract for industrial equipment'),
(102, 102, '2024-02-20', 'Warranty', 'Active', 'Extended warranty service contract'),
(103, 103, '2024-03-10', 'Installation', 'Active', 'Equipment installation and setup contract'),
(104, 104, '2024-04-05', 'Maintenance', 'Completed', 'Quarterly maintenance service contract'),
(105, 105, '2024-05-12', 'Repair', 'Active', 'Emergency repair service contract'),
(106, 101, '2024-06-01', 'Warranty', 'Cancelled', 'Cancelled warranty extension contract'),
(107, 102, '2024-07-15', 'Maintenance', 'Active', 'Monthly maintenance contract'),
(108, 103, '2024-08-20', 'Installation', 'Active', 'New equipment installation contract');

-- Link equipment to contracts
INSERT INTO ContractEquipment (contractEquipmentId, contractId, equipmentId, startDate, endDate, quantity, price) VALUES 
(101, 101, 101, '2024-01-15', '2025-01-15', 1, 5000.00),
(102, 102, 102, '2024-02-20', '2026-02-20', 1, 8000.00),
(103, 103, 103, '2024-03-10', '2025-03-10', 1, 12000.00),
(104, 104, 104, '2024-04-05', '2024-07-05', 1, 3000.00),
(105, 105, 105, '2024-05-12', '2024-08-12', 1, 4500.00),
(106, 107, 101, '2024-07-15', '2024-10-15', 1, 2000.00),
(107, 108, 102, '2024-08-20', '2025-02-20', 1, 6000.00);

-- =============================================
-- 4. SERVICE REQUESTS FOR TECHNICIAN TASKS
-- =============================================

-- Add service requests that will become technician tasks
INSERT INTO ServiceRequest (requestId, contractId, equipmentId, createdBy, description, priorityLevel, requestDate, status, requestType) VALUES 
(101, 101, 101, 101, 'Pump maintenance required - unusual noise detected', 'High', NOW(), 'Approved', 'Service'),
(102, 102, 102, 102, 'Conveyor belt needs adjustment - speed issues', 'Normal', NOW(), 'Approved', 'Service'),
(103, 103, 103, 103, 'HVAC system not cooling properly', 'Urgent', NOW(), 'Approved', 'Service'),
(104, 104, 104, 104, 'Generator maintenance check', 'Normal', NOW(), 'Approved', 'Service'),
(105, 105, 105, 105, 'Compressor pressure issues', 'High', NOW(), 'Approved', 'Service'),
(106, 107, 101, 101, 'Monthly pump inspection', 'Normal', NOW(), 'Approved', 'Service'),
(107, 108, 102, 102, 'Conveyor belt replacement', 'High', NOW(), 'Approved', 'Service'),
(108, 101, 101, 101, 'Emergency pump repair', 'Urgent', NOW(), 'Approved', 'Service');

-- =============================================
-- 5. WORK TASKS FOR TECHNICIAN ASSIGNMENT
-- =============================================

-- Add work tasks assigned to technician (accountId = 2, which is the technician account)
INSERT INTO WorkTask (taskId, requestId, scheduleId, technicianId, taskType, taskDetails, startDate, endDate, status) VALUES 
(101, 101, NULL, 2, 'Request', 'Inspect pump for unusual noise and perform maintenance', '2024-12-20', '2024-12-22', 'Assigned'),
(102, 102, NULL, 2, 'Request', 'Adjust conveyor belt speed and check alignment', '2024-12-21', '2024-12-23', 'Assigned'),
(103, 103, NULL, 2, 'Request', 'Diagnose HVAC cooling issues and repair', '2024-12-22', '2024-12-24', 'In Progress'),
(104, 104, NULL, 2, 'Request', 'Perform generator maintenance check', '2024-12-23', '2024-12-25', 'Assigned'),
(105, 105, NULL, 2, 'Request', 'Fix compressor pressure issues', '2024-12-24', '2024-12-26', 'Assigned'),
(106, 106, NULL, 2, 'Request', 'Monthly pump inspection and service', '2024-12-25', '2024-12-27', 'Assigned'),
(107, 107, NULL, 2, 'Request', 'Replace conveyor belt and test operation', '2024-12-26', '2024-12-28', 'Assigned'),
(108, 108, NULL, 2, 'Request', 'Emergency pump repair - urgent', '2024-12-27', '2024-12-29', 'Assigned'),
-- Add some completed tasks for work history
(109, 101, NULL, 2, 'Request', 'Previous pump maintenance completed', '2024-11-15', '2024-11-17', 'Completed'),
(110, 102, NULL, 2, 'Request', 'Previous conveyor belt repair completed', '2024-11-20', '2024-11-22', 'Completed'),
(111, 103, NULL, 2, 'Request', 'Previous HVAC repair completed', '2024-11-25', '2024-11-27', 'Completed');

-- =============================================
-- 6. REPAIR REPORTS FOR TECHNICIAN REPORTS
-- =============================================

-- Add repair reports for technician to view and create
INSERT INTO RepairReport (reportId, requestId, technicianId, details, diagnosis, estimatedCost, quotationStatus, repairDate, invoiceDetailId) VALUES 
(101, 101, 2, 'Pump inspection completed. Found bearing wear causing noise.', 'Bearing wear due to lack of lubrication. Requires bearing replacement.', 500.00, 'Pending', '2024-12-20', NULL),
(102, 102, 2, 'Conveyor belt adjusted. Speed controller calibrated.', 'Speed controller calibration issue. Belt tension adjusted.', 200.00, 'Approved', '2024-12-21', NULL),
(103, 103, 2, 'HVAC system diagnosed. Refrigerant leak found.', 'Refrigerant leak in condenser unit. Requires leak repair and refrigerant recharge.', 800.00, 'Pending', '2024-12-22', NULL),
(104, 104, 2, 'Generator maintenance completed successfully.', 'Routine maintenance performed. All systems functioning normally.', 150.00, 'Approved', '2024-12-23', NULL),
(105, 105, 2, 'Compressor pressure issues resolved.', 'Pressure valve replacement completed. System pressure restored.', 350.00, 'Pending', '2024-12-24', NULL),
-- Add some completed reports for history
(106, 109, 2, 'Previous pump maintenance completed successfully.', 'Bearing replacement completed. Pump operating normally.', 450.00, 'Approved', '2024-11-17', NULL),
(107, 110, 2, 'Previous conveyor belt repair completed.', 'Belt replacement and alignment completed.', 600.00, 'Approved', '2024-11-22', NULL),
(108, 111, 2, 'Previous HVAC repair completed.', 'Refrigerant leak repaired and system recharged.', 750.00, 'Approved', '2024-11-27', NULL);

-- =============================================
-- 7. MAINTENANCE SCHEDULES FOR SCHEDULED TASKS
-- =============================================

-- Add maintenance schedules for periodic tasks
INSERT INTO MaintenanceSchedule (scheduleId, requestId, contractId, equipmentId, assignedTo, scheduledDate, scheduleType, recurrenceRule, status, priorityId) VALUES 
(101, NULL, 101, 101, 2, '2024-12-30', 'Periodic', 'MONTHLY', 'Scheduled', 1),
(102, NULL, 102, 102, 2, '2025-01-15', 'Periodic', 'MONTHLY', 'Scheduled', 1),
(103, NULL, 103, 103, 2, '2025-01-20', 'Periodic', 'MONTHLY', 'Scheduled', 1),
(104, NULL, 104, 104, 2, '2025-01-25', 'Periodic', 'MONTHLY', 'Scheduled', 1),
(105, NULL, 105, 105, 2, '2025-01-30', 'Periodic', 'MONTHLY', 'Scheduled', 1);

-- =============================================
-- 8. REQUEST APPROVALS FOR WORKFLOW
-- =============================================

-- Add request approvals for the service requests
INSERT INTO RequestApproval (approvalId, requestId, approvedBy, approvalDate, decision, note) VALUES 
(101, 101, 1, NOW(), 'Approved', 'Approved for technician assignment'),
(102, 102, 1, NOW(), 'Approved', 'Approved for technician assignment'),
(103, 103, 1, NOW(), 'Approved', 'Approved for urgent technician assignment'),
(104, 104, 1, NOW(), 'Approved', 'Approved for technician assignment'),
(105, 105, 1, NOW(), 'Approved', 'Approved for technician assignment'),
(106, 106, 1, NOW(), 'Approved', 'Approved for technician assignment'),
(107, 107, 1, NOW(), 'Approved', 'Approved for technician assignment'),
(108, 108, 1, NOW(), 'Approved', 'Approved for urgent technician assignment');

-- =============================================
-- 9. PRIORITY DATA FOR TASKS
-- =============================================

-- Ensure priority data exists
INSERT INTO Priority (priorityId, priorityName, priorityLevel, description) VALUES 
(1, 'Normal', 1, 'Standard priority level'),
(2, 'High', 2, 'High priority level'),
(3, 'Urgent', 3, 'Urgent priority level')
ON DUPLICATE KEY UPDATE priorityName=VALUES(priorityName);

-- =============================================
-- 10. INVOICE DETAILS FOR REPAIR REPORTS
-- =============================================

-- Add invoice details for repair reports
INSERT INTO Invoice (invoiceId, contractId, issueDate, dueDate, totalAmount, status) VALUES 
(101, 101, '2024-12-20', '2025-01-20', 500.00, 'Pending'),
(102, 102, '2024-12-21', '2025-01-21', 200.00, 'Paid'),
(103, 103, '2024-12-22', '2025-01-22', 800.00, 'Pending'),
(104, 104, '2024-12-23', '2025-01-23', 150.00, 'Paid'),
(105, 105, '2024-12-24', '2025-01-24', 350.00, 'Pending');

INSERT INTO InvoiceDetail (invoiceDetailId, invoiceId, description, amount) VALUES 
(101, 101, 'Pump bearing replacement', 500.00),
(102, 102, 'Conveyor belt adjustment', 200.00),
(103, 103, 'HVAC refrigerant repair', 800.00),
(104, 104, 'Generator maintenance', 150.00),
(105, 105, 'Compressor pressure valve replacement', 350.00);

-- Update repair reports with invoice detail IDs
UPDATE RepairReport SET invoiceDetailId = 101 WHERE reportId = 101;
UPDATE RepairReport SET invoiceDetailId = 102 WHERE reportId = 102;
UPDATE RepairReport SET invoiceDetailId = 103 WHERE reportId = 103;
UPDATE RepairReport SET invoiceDetailId = 104 WHERE reportId = 104;
UPDATE RepairReport SET invoiceDetailId = 105 WHERE reportId = 105;

-- =============================================
-- 11. NOTIFICATIONS FOR TECHNICIAN
-- =============================================

-- Add notifications for technician
INSERT INTO Notification (notificationId, accountId, notificationType, contractEquipmentId, message, createdAt, status) VALUES 
(101, 2, 'Warranty', 101, 'Contract equipment maintenance due soon', NOW(), 'Unread'),
(102, 2, 'System', NULL, 'New task assigned: Pump maintenance', NOW(), 'Unread'),
(103, 2, 'Warranty', 102, 'Conveyor belt warranty expires in 30 days', NOW(), 'Unread'),
(104, 2, 'System', NULL, 'Task deadline approaching: HVAC repair', NOW(), 'Unread'),
(105, 2, 'Other', 103, 'Customer feedback received for recent repair', NOW(), 'Unread');

-- =============================================
-- 12. SUPPORT TICKETS FOR TECHNICIAN CONTEXT
-- =============================================

-- Add support tickets related to technician work
INSERT INTO SupportTicket (ticketId, customerId, supportStaffId, contractId, equipmentId, description, response, createdDate, closedDate) VALUES 
(101, 101, 1, 101, 101, 'Customer reported pump noise issue', 'Technician assigned to investigate', '2024-12-19', NULL),
(102, 102, 1, 102, 102, 'Conveyor belt speed problem', 'Technician assigned for adjustment', '2024-12-20', '2024-12-21'),
(103, 103, 1, 103, 103, 'HVAC cooling not working', 'Urgent technician assignment', '2024-12-21', NULL),
(104, 104, 1, 104, 104, 'Generator maintenance request', 'Technician assigned for maintenance', '2024-12-22', '2024-12-23'),
(105, 105, 1, 105, 105, 'Compressor pressure issues', 'Technician assigned for repair', '2024-12-23', NULL);

-- =============================================
-- DEMO DATA SUMMARY
-- =============================================
-- This seed data provides:
-- 1. 5 additional customers for contract management
-- 2. 5 additional equipment items
-- 3. 8 contracts with various statuses (Active, Completed, Cancelled)
-- 4. 8 service requests approved for technician assignment
-- 5. 11 work tasks (8 assigned, 3 completed for history)
-- 6. 8 repair reports (5 pending, 3 completed for history)
-- 7. 5 maintenance schedules for periodic tasks
-- 8. 8 request approvals for workflow
-- 9. Priority data for task management
-- 10. Invoice details for repair reports
-- 11. 5 notifications for technician dashboard
-- 12. 5 support tickets for context

-- All data is designed to work with technician account (accountId = 2)
-- and provides comprehensive demo scenarios for all technician features.
