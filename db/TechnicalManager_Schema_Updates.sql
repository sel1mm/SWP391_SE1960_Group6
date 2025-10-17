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