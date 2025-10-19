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