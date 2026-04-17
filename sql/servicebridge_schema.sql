SET NAMES utf8mb4;
SET time_zone = '+00:00';

CREATE TABLE IF NOT EXISTS service_types (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  code VARCHAR(80) NOT NULL,
  name VARCHAR(190) NOT NULL,
  description TEXT DEFAULT NULL,
  status ENUM('active','inactive') NOT NULL DEFAULT 'active',
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_service_types_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS service_cases (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  uuid CHAR(36) NOT NULL,
  conversation_id BIGINT UNSIGNED DEFAULT NULL,
  contact_id BIGINT UNSIGNED DEFAULT NULL,
  service_type_id BIGINT UNSIGNED DEFAULT NULL,
  case_status ENUM('new','in_review','pending_documents','in_progress','resolved','cancelled') NOT NULL DEFAULT 'new',
  priority ENUM('low','normal','high','critical') NOT NULL DEFAULT 'normal',
  subject VARCHAR(190) NOT NULL,
  description TEXT DEFAULT NULL,
  opened_at DATETIME DEFAULT NULL,
  resolved_at DATETIME DEFAULT NULL,
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_service_cases_uuid (uuid),
  KEY idx_service_cases_conversation (conversation_id),
  KEY idx_service_cases_contact (contact_id),
  KEY idx_service_cases_type (service_type_id),
  KEY idx_service_cases_status (case_status),
  CONSTRAINT fk_service_cases_conversation FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE SET NULL,
  CONSTRAINT fk_service_cases_contact FOREIGN KEY (contact_id) REFERENCES contacts(id) ON DELETE SET NULL,
  CONSTRAINT fk_service_cases_type FOREIGN KEY (service_type_id) REFERENCES service_types(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS requirements (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  service_type_id BIGINT UNSIGNED DEFAULT NULL,
  code VARCHAR(80) NOT NULL,
  title VARCHAR(190) NOT NULL,
  description TEXT DEFAULT NULL,
  is_required TINYINT(1) NOT NULL DEFAULT 1,
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_requirements_code (code),
  KEY idx_requirements_service_type (service_type_id),
  CONSTRAINT fk_requirements_service_type FOREIGN KEY (service_type_id) REFERENCES service_types(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS case_documents (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  service_case_id BIGINT UNSIGNED NOT NULL,
  requirement_id BIGINT UNSIGNED DEFAULT NULL,
  file_asset_id BIGINT UNSIGNED DEFAULT NULL,
  document_status ENUM('pending','received','validated','rejected') NOT NULL DEFAULT 'pending',
  notes TEXT DEFAULT NULL,
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_case_documents_case (service_case_id),
  KEY idx_case_documents_requirement (requirement_id),
  KEY idx_case_documents_asset (file_asset_id),
  CONSTRAINT fk_case_documents_case FOREIGN KEY (service_case_id) REFERENCES service_cases(id) ON DELETE CASCADE,
  CONSTRAINT fk_case_documents_requirement FOREIGN KEY (requirement_id) REFERENCES requirements(id) ON DELETE SET NULL,
  CONSTRAINT fk_case_documents_asset FOREIGN KEY (file_asset_id) REFERENCES file_assets(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS case_status_history (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  service_case_id BIGINT UNSIGNED NOT NULL,
  previous_status VARCHAR(60) DEFAULT NULL,
  new_status VARCHAR(60) NOT NULL,
  changed_by VARCHAR(120) DEFAULT NULL,
  change_reason VARCHAR(255) DEFAULT NULL,
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_case_status_history_case (service_case_id),
  CONSTRAINT fk_case_status_history_case FOREIGN KEY (service_case_id) REFERENCES service_cases(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS appointments (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  service_case_id BIGINT UNSIGNED DEFAULT NULL,
  contact_id BIGINT UNSIGNED DEFAULT NULL,
  appointment_type VARCHAR(80) NOT NULL,
  appointment_status ENUM('requested','scheduled','completed','cancelled','no_show') NOT NULL DEFAULT 'requested',
  scheduled_start DATETIME DEFAULT NULL,
  scheduled_end DATETIME DEFAULT NULL,
  location_text VARCHAR(255) DEFAULT NULL,
  notes TEXT DEFAULT NULL,
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_appointments_case (service_case_id),
  KEY idx_appointments_contact (contact_id),
  CONSTRAINT fk_service_appointments_case FOREIGN KEY (service_case_id) REFERENCES service_cases(id) ON DELETE SET NULL,
  CONSTRAINT fk_service_appointments_contact FOREIGN KEY (contact_id) REFERENCES contacts(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS assigned_operators (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  service_case_id BIGINT UNSIGNED NOT NULL,
  operator_name VARCHAR(190) NOT NULL,
  operator_role VARCHAR(120) DEFAULT NULL,
  assigned_at DATETIME NOT NULL,
  unassigned_at DATETIME DEFAULT NULL,
  status ENUM('active','inactive') NOT NULL DEFAULT 'active',
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_assigned_operators_case (service_case_id),
  CONSTRAINT fk_assigned_operators_case FOREIGN KEY (service_case_id) REFERENCES service_cases(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SHOW TABLES;
