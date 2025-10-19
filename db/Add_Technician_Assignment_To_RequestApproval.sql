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