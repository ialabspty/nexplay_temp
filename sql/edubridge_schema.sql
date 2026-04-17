SET NAMES utf8mb4;
SET time_zone = '+00:00';

CREATE TABLE IF NOT EXISTS platforms (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  code VARCHAR(80) NOT NULL,
  name VARCHAR(150) NOT NULL,
  provider_type VARCHAR(80) DEFAULT NULL,
  base_url VARCHAR(255) DEFAULT NULL,
  status ENUM('active','inactive','draft') NOT NULL DEFAULT 'active',
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_platforms_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS schools (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  code VARCHAR(100) NOT NULL,
  name VARCHAR(190) NOT NULL,
  country_code VARCHAR(10) DEFAULT NULL,
  status ENUM('active','inactive','prospect') NOT NULL DEFAULT 'active',
  notes TEXT DEFAULT NULL,
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_schools_code (code),
  KEY idx_schools_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS school_aliases (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  school_id BIGINT UNSIGNED NOT NULL,
  alias_name VARCHAR(190) NOT NULL,
  normalized_alias VARCHAR(190) DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_school_aliases_school_alias (school_id, alias_name),
  KEY idx_school_aliases_normalized (normalized_alias),
  CONSTRAINT fk_school_aliases_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS school_platforms (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  school_id BIGINT UNSIGNED NOT NULL,
  platform_id BIGINT UNSIGNED NOT NULL,
  access_url VARCHAR(255) DEFAULT NULL,
  is_primary TINYINT(1) NOT NULL DEFAULT 0,
  status ENUM('active','inactive') NOT NULL DEFAULT 'active',
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_school_platforms_unique (school_id, platform_id, access_url),
  KEY idx_school_platforms_platform (platform_id),
  CONSTRAINT fk_school_platforms_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
  CONSTRAINT fk_school_platforms_platform FOREIGN KEY (platform_id) REFERENCES platforms(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS guardians (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  contact_id BIGINT UNSIGNED DEFAULT NULL,
  full_name VARCHAR(190) NOT NULL,
  email VARCHAR(190) DEFAULT NULL,
  phone VARCHAR(30) DEFAULT NULL,
  status ENUM('active','inactive') NOT NULL DEFAULT 'active',
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_guardians_contact (contact_id),
  KEY idx_guardians_email (email),
  KEY idx_guardians_phone (phone),
  CONSTRAINT fk_guardians_contact FOREIGN KEY (contact_id) REFERENCES contacts(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS students (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  school_id BIGINT UNSIGNED DEFAULT NULL,
  full_name VARCHAR(190) NOT NULL,
  preferred_name VARCHAR(120) DEFAULT NULL,
  student_code VARCHAR(120) DEFAULT NULL,
  enrollment_status ENUM('active','inactive','pending') NOT NULL DEFAULT 'active',
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_students_school (school_id),
  KEY idx_students_full_name (full_name),
  KEY idx_students_student_code (student_code),
  CONSTRAINT fk_students_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS guardian_students (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  guardian_id BIGINT UNSIGNED NOT NULL,
  student_id BIGINT UNSIGNED NOT NULL,
  relationship_label VARCHAR(100) DEFAULT NULL,
  is_primary TINYINT(1) NOT NULL DEFAULT 0,
  status ENUM('active','inactive') NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_guardian_students_unique (guardian_id, student_id),
  KEY idx_guardian_students_student (student_id),
  CONSTRAINT fk_guardian_students_guardian FOREIGN KEY (guardian_id) REFERENCES guardians(id) ON DELETE CASCADE,
  CONSTRAINT fk_guardian_students_student FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS subscriptions (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  student_id BIGINT UNSIGNED NOT NULL,
  plan_code VARCHAR(80) NOT NULL DEFAULT 'student-monthly',
  billing_cycle ENUM('monthly') NOT NULL DEFAULT 'monthly',
  price_amount DECIMAL(10,2) NOT NULL,
  currency_code VARCHAR(10) NOT NULL DEFAULT 'USD',
  anchor_day TINYINT UNSIGNED DEFAULT NULL,
  status ENUM('active','inactive','cancelled','past_due','trial') NOT NULL DEFAULT 'active',
  started_at DATETIME NOT NULL,
  current_period_start DATETIME DEFAULT NULL,
  current_period_end DATETIME DEFAULT NULL,
  cancelled_at DATETIME DEFAULT NULL,
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_subscriptions_student (student_id),
  KEY idx_subscriptions_status (status),
  CONSTRAINT fk_subscriptions_student FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS student_access_profiles (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  student_id BIGINT UNSIGNED NOT NULL,
  school_platform_id BIGINT UNSIGNED DEFAULT NULL,
  guardian_id BIGINT UNSIGNED DEFAULT NULL,
  access_username VARCHAR(190) DEFAULT NULL,
  credential_ref VARCHAR(190) DEFAULT NULL,
  status ENUM('active','inactive','revoked') NOT NULL DEFAULT 'active',
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_student_access_profiles_student (student_id),
  KEY idx_student_access_profiles_school_platform (school_platform_id),
  KEY idx_student_access_profiles_guardian (guardian_id),
  CONSTRAINT fk_student_access_profiles_student FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
  CONSTRAINT fk_student_access_profiles_school_platform FOREIGN KEY (school_platform_id) REFERENCES school_platforms(id) ON DELETE SET NULL,
  CONSTRAINT fk_student_access_profiles_guardian FOREIGN KEY (guardian_id) REFERENCES guardians(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS crawler_sessions (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  school_platform_id BIGINT UNSIGNED DEFAULT NULL,
  student_id BIGINT UNSIGNED DEFAULT NULL,
  guardian_id BIGINT UNSIGNED DEFAULT NULL,
  session_status ENUM('created','running','completed','failed','expired') NOT NULL DEFAULT 'created',
  started_at DATETIME DEFAULT NULL,
  ended_at DATETIME DEFAULT NULL,
  error_message TEXT DEFAULT NULL,
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_crawler_sessions_school_platform (school_platform_id),
  KEY idx_crawler_sessions_student (student_id),
  KEY idx_crawler_sessions_guardian (guardian_id),
  CONSTRAINT fk_crawler_sessions_school_platform FOREIGN KEY (school_platform_id) REFERENCES school_platforms(id) ON DELETE SET NULL,
  CONSTRAINT fk_crawler_sessions_student FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE SET NULL,
  CONSTRAINT fk_crawler_sessions_guardian FOREIGN KEY (guardian_id) REFERENCES guardians(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS school_documents (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  school_id BIGINT UNSIGNED NOT NULL,
  file_asset_id BIGINT UNSIGNED DEFAULT NULL,
  document_type VARCHAR(80) NOT NULL,
  title VARCHAR(190) NOT NULL,
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_school_documents_school (school_id),
  KEY idx_school_documents_asset (file_asset_id),
  CONSTRAINT fk_school_documents_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
  CONSTRAINT fk_school_documents_asset FOREIGN KEY (file_asset_id) REFERENCES file_assets(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS student_summaries (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  student_id BIGINT UNSIGNED NOT NULL,
  summary_type VARCHAR(80) NOT NULL,
  summary_date DATE DEFAULT NULL,
  content LONGTEXT NOT NULL,
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_student_summaries_student (student_id),
  KEY idx_student_summaries_type (summary_type),
  CONSTRAINT fk_student_summaries_student FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SHOW TABLES;
