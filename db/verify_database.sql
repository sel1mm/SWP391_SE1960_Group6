-- Database Setup Script for Technician Module Deployment
-- Run this script to ensure the database is properly set up

-- Create database if it doesn't exist
CREATE DATABASE IF NOT EXISTS reviewiter2;
USE reviewiter2;

-- Verify the database exists
SELECT 'Database reviewiter2 is ready' as status;

-- Check if main tables exist
SELECT 
    CASE 
        WHEN COUNT(*) > 0 THEN 'Tables exist'
        ELSE 'Tables missing - run db_for_review_final.sql'
    END as table_status
FROM information_schema.tables 
WHERE table_schema = 'reviewiter2' 
AND table_name IN ('WorkTask', 'RepairReport', 'Contract', 'Equipment');

-- Show available tables
SHOW TABLES;
