SET NAMES utf8mb4;
SET time_zone = '+00:00';

CREATE TABLE IF NOT EXISTS db_connection_profiles (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  profile_code VARCHAR(100) NOT NULL,
  core_code VARCHAR(80) NOT NULL,
  db_engine VARCHAR(40) NOT NULL DEFAULT 'mysql',
  host VARCHAR(255) NOT NULL,
  port INT NOT NULL DEFAULT 3306,
  database_name VARCHAR(190) NOT NULL,
  username VARCHAR(190) NOT NULL,
  secret_ref VARCHAR(255) DEFAULT NULL,
  encrypted_password TEXT DEFAULT NULL,
  ssl_mode VARCHAR(40) DEFAULT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  read_only TINYINT(1) NOT NULL DEFAULT 0,
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_db_connection_profiles_code (profile_code),
  KEY idx_db_connection_profiles_core (core_code),
  KEY idx_db_connection_profiles_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS db_connection_permissions (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  profile_id BIGINT UNSIGNED NOT NULL,
  agent_id BIGINT UNSIGNED DEFAULT NULL,
  permission_scope ENUM('read','write','admin') NOT NULL DEFAULT 'read',
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_db_connection_permissions_unique (profile_id, agent_id, permission_scope),
  KEY idx_db_connection_permissions_agent (agent_id),
  CONSTRAINT fk_db_connection_permissions_profile FOREIGN KEY (profile_id) REFERENCES db_connection_profiles(id) ON DELETE CASCADE,
  CONSTRAINT fk_db_connection_permissions_agent FOREIGN KEY (agent_id) REFERENCES agents(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS db_connection_audit (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  profile_id BIGINT UNSIGNED NOT NULL,
  agent_id BIGINT UNSIGNED DEFAULT NULL,
  action_type ENUM('connect','query','transaction','error','disconnect') NOT NULL,
  query_summary VARCHAR(255) DEFAULT NULL,
  status ENUM('ok','failed') NOT NULL DEFAULT 'ok',
  error_message TEXT DEFAULT NULL,
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_db_connection_audit_profile (profile_id),
  KEY idx_db_connection_audit_agent (agent_id),
  KEY idx_db_connection_audit_action (action_type),
  CONSTRAINT fk_db_connection_audit_profile FOREIGN KEY (profile_id) REFERENCES db_connection_profiles(id) ON DELETE CASCADE,
  CONSTRAINT fk_db_connection_audit_agent FOREIGN KEY (agent_id) REFERENCES agents(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SHOW TABLES;
