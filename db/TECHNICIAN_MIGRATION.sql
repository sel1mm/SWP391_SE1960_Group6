-- Technician module migration (idempotent). Run this on database `swp`.
-- This script ONLY adds new tables used by the Technician module and will not alter existing ones.

-- 1) Tasks assigned to technicians
CREATE TABLE IF NOT EXISTS tasks (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  status VARCHAR(50) NOT NULL,
  priority VARCHAR(50),
  due_date DATE,
  assigned_date DATE,
  assigned_technician_id BIGINT,
  equipment_needed TEXT,
  INDEX idx_tasks_assigned_technician (assigned_technician_id),
  INDEX idx_tasks_status (status),
  INDEX idx_tasks_due_date (due_date)
);

-- 2) Technician equipment contracts (separate from existing Contract table)
CREATE TABLE IF NOT EXISTS contracts (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  equipment_name VARCHAR(255) NOT NULL,
  quantity INT NOT NULL,
  unit_price DECIMAL(15,2) NULL,
  description TEXT,
  date DATE,
  technician_id BIGINT,
  task_id BIGINT,
  INDEX idx_contracts_task (task_id),
  INDEX idx_contracts_technician (technician_id)
);

-- 3) Repair reports submitted by technicians for tasks
CREATE TABLE IF NOT EXISTS repair_reports (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  task_id BIGINT NOT NULL,
  summary VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  file_path VARCHAR(500),
  created_date DATETIME DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_reports_task (task_id)
);

-- 4) Simple activity log for task status/comments
CREATE TABLE IF NOT EXISTS task_activity (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  task_id BIGINT NOT NULL,
  technician_id BIGINT,
  activity TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_activity_task (task_id)
);

-- Notes:
-- - Foreign keys are omitted to avoid conflicts with existing schema naming; you can add them later
--   if desired, referencing your Account/WorkTask tables.
-- - These tables are pluralized and independent of existing tables like `Contract` and `WorkTask`.
-- - If you prefer to integrate with existing `WorkTask`, adjust DAL queries accordingly.


