SET NAMES utf8mb4;
SET time_zone = '+00:00';

CREATE TABLE IF NOT EXISTS platform_access_secrets (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  access_profile_id BIGINT UNSIGNED NOT NULL,
  secret_type ENUM('password','token','api_key','other') NOT NULL DEFAULT 'password',
  secret_value TEXT NOT NULL,
  is_encrypted TINYINT(1) NOT NULL DEFAULT 0,
  encryption_version VARCHAR(40) DEFAULT NULL,
  status ENUM('active','inactive','revoked') NOT NULL DEFAULT 'active',
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_platform_access_secrets_profile_type (access_profile_id, secret_type),
  KEY idx_platform_access_secrets_status (status),
  CONSTRAINT fk_platform_access_secrets_profile FOREIGN KEY (access_profile_id) REFERENCES platform_access_profiles(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SHOW TABLES;
