🧰 Technician Module – Easy Integration Guide

This module adds Technician Task Management features to your existing CRM system.
It includes UI pages, servlet endpoints, and MySQL tables for handling tasks, contracts, and repair reports.

📌 What’s Inside

Pages

/technician/tasks → Task list page

/technician/task?id={id} → Task detail page

/technician/contracts → Equipment contract form

/technician/reports → Repair report form

APIs

GET /api/technician/tasks → Get assigned tasks (JSON)

POST /api/technician/tasks/{id}/status → Update task status

🧭 How to Add This Module

//Copy and run the SQL below in your MySQL database.
//Each table uses CREATE TABLE IF NOT EXISTS — so it won’t overwrite anything that already exists.


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