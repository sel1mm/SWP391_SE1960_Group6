-- =============================================
-- TECHNICIAN TEST SEED DATA
-- Complete seed data for testing all technician functionalities
-- Compatible with SWP_FULL_FIXED database schema
-- =============================================

SET FOREIGN_KEY_CHECKS = 0;

-- =============================================
-- 1. ACCOUNTS & ROLES
-- =============================================

-- Technical Manager (roleId = 4)
INSERT IGNORE INTO Account (accountId, username, passwordHash, fullName, email, phone, status, createdAt) VALUES 
(100, 'tech_manager_1', '$2a$12$rmfB.fZeS1UQVq/JiejzE.QYVzwp5HyJOnPJ3JaLRmsnYzF80IUuq', 'Technical Manager One', 'tech.manager1@company.com', '0901000100', 'Active', NOW());

INSERT IGNORE INTO AccountRole (accountId, roleId) VALUES (100, 4);

-- Technicians (roleId = 6)
INSERT IGNORE INTO Account (accountId, username, passwordHash, fullName, email, phone, status, createdAt) VALUES 
(101, 'technician_1', '$2a$12$rmfB.fZeS1UQVq/JiejzE.QYVzwp5HyJOnPJ3JaLRmsnYzF80IUuq', 'Nguyen Van Technician', 'tech1@company.com', '0901000101', 'Active', NOW()),
(102, 'technician_2', '$2a$12$rmfB.fZeS1UQVq/JiejzE.QYVzwp5HyJOnPJ3JaLRmsnYzF80IUuq', 'Tran Thi Repair', 'tech2@company.com', '0901000102', 'Active', NOW()),
(103, 'technician_3', '$2a$12$rmfB.fZeS1UQVq/JiejzE.QYVzwp5HyJOnPJ3JaLRmsnYzF80IUuq', 'Le Van Maintenance', 'tech3@company.com', '0901000103', 'Active', NOW()),
(104, 'technician_4', '$2a$12$rmfB.fZeS1UQVq/JiejzE.QYVzwp5HyJOnPJ3JaLRmsnYzF80IUuq', 'Pham Thi Service', 'tech4@company.com', '0901000104', 'Active', NOW());

INSERT IGNORE INTO AccountRole (accountId, roleId) VALUES 
(101, 6), (102, 6), (103, 6), (104, 6);

-- Customers (roleId = 2)
INSERT IGNORE INTO Account (accountId, username, passwordHash, fullName, email, phone, status, createdAt) VALUES 
(201, 'customer_1', '$2a$12$rmfB.fZeS1UQVq/JiejzE.QYVzwp5HyJOnPJ3JaLRmsnYzF80IUuq', 'ABC Manufacturing Co.', 'contact@abcmanufacturing.com', '0901000201', 'Active', NOW()),
(202, 'customer_2', '$2a$12$rmfB.fZeS1UQVq/JiejzE.QYVzwp5HyJOnPJ3JaLRmsnYzF80IUuq', 'XYZ Industrial Ltd.', 'service@xyzindustrial.com', '0901000202', 'Active', NOW()),
(203, 'customer_3', '$2a$12$rmfB.fZeS1UQVq/JiejzE.QYVzwp5HyJOnPJ3JaLRmsnYzF80IUuq', 'DEF Production Inc.', 'support@defproduction.com', '0901000203', 'Active', NOW());

INSERT IGNORE INTO AccountRole (accountId, roleId) VALUES 
(201, 2), (202, 2), (203, 2);

-- =============================================
-- 2. EQUIPMENT
-- =============================================

INSERT IGNORE INTO Equipment (equipmentId, serialNumber, model, description, installDate, lastUpdatedBy, lastUpdatedDate) VALUES 
(301, 'EQ-ABC-001', 'Industrial Pump Model IP-100', 'High-pressure industrial water pump for manufacturing', '2024-01-15', 100, CURDATE()),
(302, 'EQ-ABC-002', 'Conveyor Belt CB-200', 'Automated conveyor belt system for production line', '2024-02-01', 100, CURDATE()),
(303, 'EQ-XYZ-001', 'HVAC Unit HVAC-300', 'Commercial heating and cooling system', '2024-03-10', 100, CURDATE()),
(304, 'EQ-XYZ-002', 'Generator GEN-400', 'Backup power generator 100kW', '2024-04-05', 100, CURDATE()),
(305, 'EQ-DEF-001', 'Compressor COMP-500', 'Industrial air compressor system', '2024-05-12', 100, CURDATE()),
(306, 'EQ-DEF-002', 'Motor Control MC-600', 'Variable frequency drive motor controller', '2024-06-20', 100, CURDATE());

-- =============================================
-- 3. CONTRACTS & CONTRACT EQUIPMENT
-- =============================================

INSERT IGNORE INTO Contract (contractId, customerId, contractDate, contractType, status, details) VALUES 
(401, 201, '2024-01-01', 'Maintenance', 'Active', 'Annual maintenance contract for ABC Manufacturing equipment'),
(402, 202, '2024-02-01', 'Warranty', 'Active', 'Extended warranty service contract for XYZ Industrial'),
(403, 203, '2024-03-01', 'Installation', 'Active', 'Equipment installation and setup contract for DEF Production'),
(404, 201, '2024-04-01', 'Repair', 'Completed', 'Emergency repair service contract - completed'),
(405, 202, '2024-05-01', 'Maintenance', 'Active', 'Monthly maintenance contract for XYZ Industrial');

INSERT IGNORE INTO ContractEquipment (contractEquipmentId, contractId, equipmentId, startDate, endDate, quantity, price) VALUES 
(501, 401, 301, '2024-01-01', '2025-01-01', 1, 5000.00),
(502, 401, 302, '2024-02-01', '2025-02-01', 1, 8000.00),
(503, 402, 303, '2024-03-01', '2026-03-01', 1, 12000.00),
(504, 402, 304, '2024-04-01', '2026-04-01', 1, 15000.00),
(505, 403, 305, '2024-05-01', '2025-05-01', 1, 10000.00),
(506, 403, 306, '2024-06-01', '2025-06-01', 1, 7000.00),
(507, 404, 301, '2024-04-01', '2024-07-01', 1, 3000.00),
(508, 405, 303, '2024-05-01', '2024-08-01', 1, 2000.00);

-- =============================================
-- 4. SERVICE REQUESTS
-- =============================================

INSERT IGNORE INTO ServiceRequest (requestId, contractId, equipmentId, createdBy, description, priorityLevel, requestDate, status, requestType) VALUES 
(601, 401, 301, 201, 'Industrial pump making unusual noise - maintenance required', 'High', '2024-12-15', 'Approved', 'Service'),
(602, 401, 302, 201, 'Conveyor belt needs speed adjustment - operational issues', 'Normal', '2024-12-16', 'Approved', 'Service'),
(603, 402, 303, 202, 'HVAC system not cooling properly - urgent repair needed', 'Urgent', '2024-12-17', 'Approved', 'Service'),
(604, 402, 304, 202, 'Generator maintenance check required', 'Normal', '2024-12-18', 'Approved', 'Service'),
(605, 403, 305, 203, 'Compressor pressure issues - repair needed', 'High', '2024-12-19', 'Approved', 'Service'),
(606, 403, 306, 203, 'Motor controller showing error codes', 'High', '2024-12-20', 'Approved', 'Service'),
(607, 405, 303, 202, 'Monthly HVAC maintenance scheduled', 'Normal', '2024-12-21', 'Approved', 'Service'),
(608, 401, 301, 201, 'Emergency pump repair - urgent service', 'Urgent', '2024-12-22', 'Approved', 'Service'),
(609, 402, 304, 202, 'Generator inspection request', 'Normal', '2024-12-23', 'Pending', 'Service'),
(610, 403, 305, 203, 'Compressor routine maintenance', 'Low', '2024-12-24', 'Pending', 'Service');

-- =============================================
-- 5. REQUEST APPROVALS
-- =============================================

INSERT IGNORE INTO RequestApproval (approvalId, requestId, approvedBy, approvalDate, decision, note) VALUES 
(701, 601, 100, '2024-12-15 09:00:00', 'Approved', 'Approved for technician assignment - high priority'),
(702, 602, 100, '2024-12-16 10:00:00', 'Approved', 'Approved for technician assignment'),
(703, 603, 100, '2024-12-17 08:00:00', 'Approved', 'Approved for urgent technician assignment'),
(704, 604, 100, '2024-12-18 11:00:00', 'Approved', 'Approved for technician assignment'),
(705, 605, 100, '2024-12-19 09:30:00', 'Approved', 'Approved for technician assignment'),
(706, 606, 100, '2024-12-20 10:30:00', 'Approved', 'Approved for technician assignment'),
(707, 607, 100, '2024-12-21 08:30:00', 'Approved', 'Approved for technician assignment'),
(708, 608, 100, '2024-12-22 07:00:00', 'Approved', 'Approved for urgent technician assignment');

-- =============================================
-- 6. MAINTENANCE SCHEDULES
-- =============================================

INSERT IGNORE INTO MaintenanceSchedule (scheduleId, requestId, contractId, equipmentId, assignedTo, scheduledDate, scheduleType, recurrenceRule, status, priorityId) VALUES 
(801, 601, NULL, 301, 101, '2024-12-25', 'Request', NULL, 'Scheduled', 2),
(802, 602, NULL, 302, 102, '2024-12-26', 'Request', NULL, 'Scheduled', 2),
(803, 603, NULL, 303, 103, '2024-12-27', 'Request', NULL, 'Scheduled', 3),
(804, 604, NULL, 304, 104, '2024-12-28', 'Request', NULL, 'Scheduled', 2),
(805, 605, NULL, 305, 101, '2024-12-29', 'Request', NULL, 'Scheduled', 2),
(806, 606, NULL, 306, 102, '2024-12-30', 'Request', NULL, 'Scheduled', 2),
(807, 607, NULL, 303, 103, '2024-12-31', 'Request', NULL, 'Scheduled', 2),
(808, 608, NULL, 301, 104, '2025-01-01', 'Request', NULL, 'Scheduled', 3),
-- Periodic maintenance schedules
(809, NULL, 401, 301, 101, '2025-01-15', 'Periodic', 'MONTHLY', 'Scheduled', 2),
(810, NULL, 402, 303, 103, '2025-01-20', 'Periodic', 'MONTHLY', 'Scheduled', 2),
(811, NULL, 403, 305, 101, '2025-01-25', 'Periodic', 'MONTHLY', 'Scheduled', 2),
(812, NULL, 405, 303, 103, '2025-01-30', 'Periodic', 'MONTHLY', 'Scheduled', 2);

-- =============================================
-- 7. WORK TASKS
-- =============================================

INSERT IGNORE INTO WorkTask (taskId, requestId, scheduleId, technicianId, taskType, taskDetails, startDate, endDate, status) VALUES 
(901, 601, 801, 101, 'Request', 'Inspect industrial pump for unusual noise and perform maintenance', '2024-12-25', '2024-12-27', 'Assigned'),
(902, 602, 802, 102, 'Request', 'Adjust conveyor belt speed and check alignment', '2024-12-26', '2024-12-28', 'Assigned'),
(903, 603, 803, 103, 'Request', 'Diagnose HVAC cooling issues and repair', '2024-12-27', '2024-12-29', 'In Progress'),
(904, 604, 804, 104, 'Request', 'Perform generator maintenance check', '2024-12-28', '2024-12-30', 'Assigned'),
(905, 605, 805, 101, 'Request', 'Fix compressor pressure issues', '2024-12-29', '2024-12-31', 'Assigned'),
(906, 606, 806, 102, 'Request', 'Troubleshoot motor controller error codes', '2024-12-30', '2025-01-01', 'Assigned'),
(907, 607, 807, 103, 'Request', 'Monthly HVAC maintenance service', '2024-12-31', '2025-01-02', 'Assigned'),
(908, 608, 808, 104, 'Request', 'Emergency pump repair - urgent', '2025-01-01', '2025-01-03', 'Assigned'),
-- Completed tasks for history
(909, NULL, 809, 101, 'Scheduled', 'Previous pump maintenance completed', '2024-11-15', '2024-11-17', 'Completed'),
(910, NULL, 810, 103, 'Scheduled', 'Previous HVAC maintenance completed', '2024-11-20', '2024-11-22', 'Completed'),
(911, NULL, 811, 101, 'Scheduled', 'Previous compressor service completed', '2024-11-25', '2024-11-27', 'Completed');

-- =============================================
-- 8. WORK ASSIGNMENTS
-- =============================================

INSERT IGNORE INTO WorkAssignment (assignmentId, taskId, assignedBy, assignedTo, assignmentDate, assignmentReason, estimatedDuration, requiredSkills, priority, acceptedByTechnician, acceptedAt) VALUES 
(1001, 901, 100, 101, '2024-12-15 09:00:00', 'Technician has experience with industrial pumps', 8.0, 'Mechanical, Electrical', 'High', 1, '2024-12-15 10:00:00'),
(1002, 902, 100, 102, '2024-12-16 10:00:00', 'Technician specialized in conveyor systems', 6.0, 'Mechanical', 'Normal', 1, '2024-12-16 11:00:00'),
(1003, 903, 100, 103, '2024-12-17 08:00:00', 'Technician has HVAC certification', 12.0, 'HVAC, Refrigeration', 'Urgent', 1, '2024-12-17 09:00:00'),
(1004, 904, 100, 104, '2024-12-18 11:00:00', 'Technician experienced with generators', 4.0, 'Electrical, Mechanical', 'Normal', 0, NULL),
(1005, 905, 100, 101, '2024-12-19 09:30:00', 'Technician available and skilled in compressors', 6.0, 'Mechanical, Pneumatic', 'High', 1, '2024-12-19 10:30:00'),
(1006, 906, 100, 102, '2024-12-20 10:30:00', 'Technician has motor control expertise', 8.0, 'Electrical, Automation', 'High', 0, NULL),
(1007, 907, 100, 103, '2024-12-21 08:30:00', 'Technician familiar with this HVAC system', 4.0, 'HVAC', 'Normal', 1, '2024-12-21 09:30:00'),
(1008, 908, 100, 104, '2024-12-22 07:00:00', 'Emergency assignment - technician available', 10.0, 'Mechanical, Emergency Repair', 'Urgent', 1, '2024-12-22 08:00:00');

-- =============================================
-- 9. REPAIR RESULTS
-- =============================================

INSERT IGNORE INTO RepairResult (resultId, taskId, details, completionDate, technicianId, status) VALUES 
(1101, 909, 'Pump maintenance completed successfully. Bearing replacement performed. Pump operating normally.', '2024-11-17', 101, 'Completed'),
(1102, 910, 'HVAC maintenance completed. Filter replacement and system cleaning performed. All systems functioning properly.', '2024-11-22', 103, 'Completed'),
(1103, 911, 'Compressor service completed. Oil change and pressure check performed. System pressure restored to normal.', '2024-11-27', 101, 'Completed');

-- =============================================
-- 10. REPAIR REPORTS
-- =============================================

INSERT IGNORE INTO RepairReport (reportId, requestId, technicianId, details, diagnosis, estimatedCost, quotationStatus, repairDate, invoiceDetailId) VALUES 
(1201, 601, 101, 'Pump inspection completed. Found bearing wear causing noise.', 'Bearing wear due to lack of lubrication. Requires bearing replacement.', 500.00, 'Pending', '2024-12-25', NULL),
(1202, 602, 102, 'Conveyor belt adjusted. Speed controller calibrated.', 'Speed controller calibration issue. Belt tension adjusted.', 200.00, 'Approved', '2024-12-26', NULL),
(1203, 603, 103, 'HVAC system diagnosed. Refrigerant leak found.', 'Refrigerant leak in condenser unit. Requires leak repair and refrigerant recharge.', 800.00, 'Pending', '2024-12-27', NULL),
(1204, 604, 104, 'Generator maintenance completed successfully.', 'Routine maintenance performed. All systems functioning normally.', 150.00, 'Approved', '2024-12-28', NULL),
(1205, 605, 101, 'Compressor pressure issues resolved.', 'Pressure valve replacement completed. System pressure restored.', 350.00, 'Pending', '2024-12-29', NULL),
-- Completed reports for history
(1206, 909, 101, 'Previous pump maintenance completed successfully.', 'Bearing replacement completed. Pump operating normally.', 450.00, 'Approved', '2024-11-17', NULL),
(1207, 910, 103, 'Previous HVAC maintenance completed.', 'Filter replacement and system cleaning completed.', 300.00, 'Approved', '2024-11-22', NULL),
(1208, 911, 101, 'Previous compressor service completed.', 'Oil change and pressure check completed.', 250.00, 'Approved', '2024-11-27', NULL);

-- =============================================
-- 11. PARTS & INVENTORY
-- =============================================

INSERT IGNORE INTO Part (partId, partName, description, unitPrice, lastUpdatedBy, lastUpdatedDate) VALUES 
(1301, 'Pump Bearing Set', 'High-quality bearing set for industrial pumps', 150.00, 100, CURDATE()),
(1302, 'Conveyor Belt', 'Heavy-duty conveyor belt 2m width', 300.00, 100, CURDATE()),
(1303, 'HVAC Filter Set', 'Complete filter set for HVAC systems', 80.00, 100, CURDATE()),
(1304, 'Generator Oil', 'High-grade generator lubricating oil', 50.00, 100, CURDATE()),
(1305, 'Compressor Valve', 'Pressure relief valve for compressors', 120.00, 100, CURDATE()),
(1306, 'Motor Controller Board', 'Control board for motor controllers', 400.00, 100, CURDATE());

INSERT IGNORE INTO Inventory (inventoryId, partId, quantity, lastUpdatedBy, lastUpdatedDate) VALUES 
(1401, 1301, 10, 100, CURDATE()),
(1402, 1302, 5, 100, CURDATE()),
(1403, 1303, 20, 100, CURDATE()),
(1404, 1304, 15, 100, CURDATE()),
(1405, 1305, 8, 100, CURDATE()),
(1406, 1306, 3, 100, CURDATE());

INSERT IGNORE INTO PartDetail (partDetailId, partId, serialNumber, status, location, lastUpdatedBy, lastUpdatedDate) VALUES 
(1501, 1301, 'PB-001', 'Available', 'Warehouse A', 100, CURDATE()),
(1502, 1301, 'PB-002', 'Available', 'Warehouse A', 100, CURDATE()),
(1503, 1302, 'CB-001', 'Available', 'Warehouse B', 100, CURDATE()),
(1504, 1303, 'HF-001', 'Available', 'Warehouse C', 100, CURDATE()),
(1505, 1304, 'GO-001', 'Available', 'Warehouse A', 100, CURDATE()),
(1506, 1305, 'CV-001', 'Available', 'Warehouse B', 100, CURDATE()),
(1507, 1306, 'MCB-001', 'Available', 'Warehouse C', 100, CURDATE());

-- =============================================
-- 12. PARTS REQUESTS
-- =============================================

INSERT IGNORE INTO PartsRequest (partsRequestId, taskId, requestDate, status, handledBy, handledDate) VALUES 
(1601, 901, '2024-12-25', 'Approved', 100, '2024-12-25'),
(1602, 903, '2024-12-27', 'Pending', NULL, NULL),
(1603, 905, '2024-12-29', 'Completed', 100, '2024-12-29'),
(1604, 909, '2024-11-15', 'Completed', 100, '2024-11-15');

INSERT IGNORE INTO PartsRequestDetail (requestDetailId, partsRequestId, partId, quantityRequested, quantityIssued) VALUES 
(1701, 1601, 1301, 1, 1),
(1702, 1602, 1303, 2, 0),
(1703, 1603, 1305, 1, 1),
(1704, 1604, 1301, 1, 1);

-- =============================================
-- 13. INVOICES & PAYMENTS
-- =============================================

INSERT IGNORE INTO Invoice (invoiceId, contractId, issueDate, dueDate, totalAmount, status) VALUES 
(1801, 401, '2024-12-25', '2025-01-25', 500.00, 'Pending'),
(1802, 401, '2024-12-26', '2025-01-26', 200.00, 'Paid'),
(1803, 402, '2024-12-27', '2025-01-27', 800.00, 'Pending'),
(1804, 402, '2024-12-28', '2025-01-28', 150.00, 'Paid'),
(1805, 403, '2024-12-29', '2025-01-29', 350.00, 'Pending');

INSERT IGNORE INTO InvoiceDetail (invoiceDetailId, invoiceId, description, amount) VALUES 
(1901, 1801, 'Pump bearing replacement', 500.00),
(1902, 1802, 'Conveyor belt adjustment', 200.00),
(1903, 1803, 'HVAC refrigerant repair', 800.00),
(1904, 1804, 'Generator maintenance', 150.00),
(1905, 1805, 'Compressor pressure valve replacement', 350.00);

-- Update repair reports with invoice detail IDs
UPDATE RepairReport SET invoiceDetailId = 1901 WHERE reportId = 1201;
UPDATE RepairReport SET invoiceDetailId = 1902 WHERE reportId = 1202;
UPDATE RepairReport SET invoiceDetailId = 1903 WHERE reportId = 1203;
UPDATE RepairReport SET invoiceDetailId = 1904 WHERE reportId = 1204;
UPDATE RepairReport SET invoiceDetailId = 1905 WHERE reportId = 1205;

INSERT IGNORE INTO Payment (paymentId, invoiceId, amount, paymentDate, status) VALUES 
(2001, 1802, 200.00, '2024-12-26', 'Completed'),
(2002, 1804, 150.00, '2024-12-28', 'Completed');

INSERT IGNORE INTO PaymentTransaction (transactionId, paymentId, accountId, amount, method, transactionDate, status) VALUES 
(2101, 2001, 201, 200.00, 'Bank Transfer', '2024-12-26', 'Completed'),
(2102, 2002, 202, 150.00, 'Cash', '2024-12-28', 'Completed');

-- =============================================
-- 14. NOTIFICATIONS
-- =============================================

INSERT IGNORE INTO Notification (notificationId, accountId, notificationType, contractEquipmentId, message, createdAt, status) VALUES 
(2201, 101, 'Warranty', 501, 'Contract equipment maintenance due soon', NOW(), 'Unread'),
(2202, 101, 'System', NULL, 'New task assigned: Pump maintenance', NOW(), 'Unread'),
(2203, 102, 'Warranty', 502, 'Conveyor belt warranty expires in 30 days', NOW(), 'Unread'),
(2204, 103, 'System', NULL, 'Task deadline approaching: HVAC repair', NOW(), 'Unread'),
(2205, 104, 'Other', 504, 'Customer feedback received for recent repair', NOW(), 'Unread'),
(2206, 101, 'System', NULL, 'Parts request approved for task #901', NOW(), 'Unread'),
(2207, 103, 'System', NULL, 'Parts request pending for task #903', NOW(), 'Unread');

-- =============================================
-- 15. SUPPORT TICKETS
-- =============================================

INSERT IGNORE INTO SupportTicket (ticketId, customerId, supportStaffId, contractId, equipmentId, description, response, createdDate, closedDate) VALUES 
(2301, 201, 100, 401, 301, 'Customer reported pump noise issue', 'Technician assigned to investigate', '2024-12-19', NULL),
(2302, 202, 100, 402, 303, 'HVAC cooling not working', 'Urgent technician assignment', '2024-12-21', NULL),
(2303, 203, 100, 403, 305, 'Compressor pressure issues', 'Technician assigned for repair', '2024-12-23', NULL);

-- =============================================
-- 16. TECHNICIAN WORKLOAD & AVAILABILITY
-- =============================================

INSERT IGNORE INTO TechnicianWorkload (workloadId, technicianId, currentActiveTasks, maxConcurrentTasks, workloadPercentage, lastUpdated) VALUES 
(2401, 101, 3, 5, 60.0, NOW()),
(2402, 102, 2, 4, 50.0, NOW()),
(2403, 103, 3, 5, 60.0, NOW()),
(2404, 104, 2, 4, 50.0, NOW());

INSERT IGNORE INTO TechnicianAvailability (availabilityId, technicianId, availableDate, startTime, endTime, isAvailable, reason) VALUES 
(2501, 101, '2024-12-25', '08:00:00', '17:00:00', 1, 'Available for pump maintenance'),
(2502, 102, '2024-12-26', '08:00:00', '17:00:00', 1, 'Available for conveyor work'),
(2503, 103, '2024-12-27', '08:00:00', '17:00:00', 1, 'Available for HVAC repair'),
(2504, 104, '2024-12-28', '08:00:00', '17:00:00', 1, 'Available for generator work'),
(2505, 101, '2024-12-29', '08:00:00', '17:00:00', 1, 'Available for compressor work'),
(2506, 102, '2024-12-30', '08:00:00', '17:00:00', 1, 'Available for motor controller work'),
(2507, 103, '2024-12-31', '08:00:00', '17:00:00', 1, 'Available for HVAC maintenance'),
(2508, 104, '2025-01-01', '08:00:00', '17:00:00', 1, 'Available for emergency repair');

-- =============================================
-- 17. TECHNICIAN SKILLS
-- =============================================

INSERT IGNORE INTO TechnicianSkill (skillId, skillName, description, category) VALUES 
(2601, 'Mechanical Systems', 'Installation and repair of mechanical systems', 'Mechanical'),
(2602, 'Electrical Systems', 'Installation and repair of electrical systems', 'Electrical'),
(2603, 'HVAC Systems', 'Heating, ventilation, and air conditioning systems', 'HVAC'),
(2604, 'Pneumatic Systems', 'Air compressor and pneumatic equipment', 'Pneumatic'),
(2605, 'Conveyor Systems', 'Conveyor belt and material handling systems', 'Mechanical'),
(2606, 'Generator Systems', 'Power generation and backup systems', 'Electrical');

INSERT IGNORE INTO TechnicianSkillAssignment (assignmentId, technicianId, skillId, proficiencyLevel, certificationDate, expiryDate) VALUES 
(2701, 101, 2601, 'Expert', '2023-01-15', '2025-01-15'),
(2702, 101, 2602, 'Advanced', '2023-02-20', '2025-02-20'),
(2703, 101, 2604, 'Expert', '2023-03-10', '2025-03-10'),
(2704, 102, 2601, 'Advanced', '2023-04-05', '2025-04-05'),
(2705, 102, 2605, 'Expert', '2023-05-12', '2025-05-12'),
(2706, 103, 2603, 'Expert', '2023-06-20', '2025-06-20'),
(2707, 103, 2602, 'Advanced', '2023-07-15', '2025-07-15'),
(2708, 104, 2602, 'Expert', '2023-08-10', '2025-08-10'),
(2709, 104, 2606, 'Expert', '2023-09-05', '2025-09-05');

SET FOREIGN_KEY_CHECKS = 1;

-- =============================================
-- SEED DATA SUMMARY
-- =============================================
-- This seed data provides comprehensive test data for all technician functionalities:
-- 
-- ACCOUNTS & ROLES:
-- - 1 Technical Manager (accountId: 100, roleId: 4)
-- - 4 Technicians (accountId: 101-104, roleId: 6)
-- - 3 Customers (accountId: 201-203, roleId: 2)
--
-- EQUIPMENT & CONTRACTS:
-- - 6 Equipment items (equipmentId: 301-306)
-- - 5 Contracts (contractId: 401-405) with various statuses
-- - 8 Contract-Equipment relationships
--
-- SERVICE REQUESTS & WORKFLOW:
-- - 10 Service Requests (requestId: 601-610) with different priorities
-- - 8 Request Approvals (approvalId: 701-708)
-- - 12 Maintenance Schedules (scheduleId: 801-812)
-- - 11 Work Tasks (taskId: 901-911) with different statuses
-- - 8 Work Assignments (assignmentId: 1001-1008)
--
-- REPAIR REPORTS & RESULTS:
-- - 3 Repair Results (resultId: 1101-1103) for completed tasks
-- - 8 Repair Reports (reportId: 1201-1208) with quotation statuses
--
-- INVENTORY & PARTS:
-- - 6 Parts (partId: 1301-1306) with inventory counts
-- - 7 Part Details with serial numbers
-- - 4 Parts Requests (partsRequestId: 1601-1604) with different statuses
--
-- BILLING & PAYMENTS:
-- - 5 Invoices (invoiceId: 1801-1805) with different statuses
-- - 5 Invoice Details linked to repair reports
-- - 2 Payments (paymentId: 2001-2002) completed
-- - 2 Payment Transactions
--
-- NOTIFICATIONS & SUPPORT:
-- - 7 Notifications (notificationId: 2201-2207) for technicians
-- - 3 Support Tickets (ticketId: 2301-2303) for context
--
-- TECHNICIAN MANAGEMENT:
-- - 4 Technician Workload records
-- - 8 Technician Availability records
-- - 6 Technician Skills
-- - 9 Technician Skill Assignments
--
-- All data is designed to test complete technician workflows:
-- - Task assignment and acceptance
-- - Work progress tracking
-- - Repair report creation and quotation
-- - Parts request and inventory management
-- - Invoice generation and payment tracking
-- - Notification and communication systems
-- - Skill-based task assignment
-- - Workload and availability management
