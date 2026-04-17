SET NAMES utf8mb4;
SET time_zone = '+00:00';

CREATE TABLE IF NOT EXISTS doctor_baselines (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  doctor_id BIGINT UNSIGNED NOT NULL,
  baseline_date DATE NOT NULL,
  period_type ENUM('weekly','monthly') NOT NULL DEFAULT 'monthly',
  available_slots INT NOT NULL DEFAULT 0,
  booked_slots INT NOT NULL DEFAULT 0,
  occupancy_rate DECIMAL(5,2) NOT NULL DEFAULT 0,
  source_type ENUM('manual','imported','calculated') NOT NULL DEFAULT 'manual',
  notes TEXT DEFAULT NULL,
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_doctor_baselines_unique (doctor_id, baseline_date, period_type),
  KEY idx_doctor_baselines_doctor (doctor_id),
  CONSTRAINT fk_doctor_baselines_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS doctor_performance_metrics (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  doctor_id BIGINT UNSIGNED NOT NULL,
  metric_date DATE NOT NULL,
  period_type ENUM('daily','weekly','monthly') NOT NULL DEFAULT 'weekly',
  available_slots INT NOT NULL DEFAULT 0,
  booked_slots INT NOT NULL DEFAULT 0,
  occupancy_rate DECIMAL(5,2) NOT NULL DEFAULT 0,
  new_patients_count INT NOT NULL DEFAULT 0,
  followup_patients_count INT NOT NULL DEFAULT 0,
  cancelled_appointments_count INT NOT NULL DEFAULT 0,
  no_show_count INT NOT NULL DEFAULT 0,
  rescheduled_count INT NOT NULL DEFAULT 0,
  agent_assisted_appointments_count INT NOT NULL DEFAULT 0,
  agent_attributed_appointments_count INT NOT NULL DEFAULT 0,
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_doctor_performance_metrics_unique (doctor_id, metric_date, period_type),
  KEY idx_doctor_performance_metrics_doctor (doctor_id),
  CONSTRAINT fk_doctor_performance_metrics_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS doctor_goals (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  doctor_id BIGINT UNSIGNED NOT NULL,
  goal_code VARCHAR(100) NOT NULL,
  goal_type VARCHAR(80) NOT NULL,
  goal_name VARCHAR(190) NOT NULL,
  target_value DECIMAL(12,2) NOT NULL,
  current_value DECIMAL(12,2) DEFAULT NULL,
  unit VARCHAR(40) DEFAULT NULL,
  start_date DATE NOT NULL,
  target_date DATE DEFAULT NULL,
  status ENUM('draft','active','paused','achieved','cancelled') NOT NULL DEFAULT 'active',
  priority ENUM('low','normal','high','critical') NOT NULL DEFAULT 'normal',
  strategy_notes TEXT DEFAULT NULL,
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_doctor_goals_code (goal_code),
  KEY idx_doctor_goals_doctor (doctor_id),
  KEY idx_doctor_goals_status (status),
  CONSTRAINT fk_doctor_goals_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS doctor_goal_actions (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  doctor_goal_id BIGINT UNSIGNED NOT NULL,
  action_type VARCHAR(80) NOT NULL,
  action_title VARCHAR(190) NOT NULL,
  action_status ENUM('planned','in_progress','done','cancelled') NOT NULL DEFAULT 'planned',
  planned_at DATETIME DEFAULT NULL,
  executed_at DATETIME DEFAULT NULL,
  impact_value DECIMAL(12,2) DEFAULT NULL,
  notes TEXT DEFAULT NULL,
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_doctor_goal_actions_goal (doctor_goal_id),
  KEY idx_doctor_goal_actions_status (action_status),
  CONSTRAINT fk_doctor_goal_actions_goal FOREIGN KEY (doctor_goal_id) REFERENCES doctor_goals(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS appointment_attribution (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  appointment_id BIGINT UNSIGNED NOT NULL,
  doctor_id BIGINT UNSIGNED DEFAULT NULL,
  attribution_type ENUM('direct','assisted','influenced') NOT NULL DEFAULT 'direct',
  agent_code VARCHAR(80) DEFAULT NULL,
  attributed_value DECIMAL(12,2) DEFAULT NULL,
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_appointment_attribution_appointment (appointment_id),
  KEY idx_appointment_attribution_doctor (doctor_id),
  CONSTRAINT fk_appointment_attribution_appointment FOREIGN KEY (appointment_id) REFERENCES appointments(id) ON DELETE CASCADE,
  CONSTRAINT fk_appointment_attribution_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SHOW TABLES;
