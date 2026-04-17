SET NAMES utf8mb4;
SET time_zone = '+00:00';

CREATE TABLE IF NOT EXISTS test_workspaces (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  core_code VARCHAR(80) NOT NULL,
  agent_code VARCHAR(80) NOT NULL,
  workspace_code VARCHAR(120) NOT NULL,
  environment ENUM('test') NOT NULL DEFAULT 'test',
  status ENUM('active','inactive') NOT NULL DEFAULT 'active',
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_test_workspaces_unique (core_code, agent_code, workspace_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS test_contacts (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  core_code VARCHAR(80) NOT NULL,
  agent_code VARCHAR(80) NOT NULL,
  workspace_code VARCHAR(120) NOT NULL,
  uuid CHAR(36) NOT NULL,
  display_name VARCHAR(150) DEFAULT NULL,
  phone VARCHAR(30) DEFAULT NULL,
  email VARCHAR(190) DEFAULT NULL,
  contact_type ENUM('person','company','system') NOT NULL DEFAULT 'person',
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_test_contacts_scope_uuid (core_code, agent_code, workspace_code, uuid),
  KEY idx_test_contacts_phone (phone),
  KEY idx_test_contacts_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS test_conversations (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  core_code VARCHAR(80) NOT NULL,
  agent_code VARCHAR(80) NOT NULL,
  workspace_code VARCHAR(120) NOT NULL,
  contact_id BIGINT UNSIGNED DEFAULT NULL,
  uuid CHAR(36) NOT NULL,
  channel VARCHAR(60) DEFAULT NULL,
  external_chat_id VARCHAR(190) DEFAULT NULL,
  subject VARCHAR(190) DEFAULT NULL,
  status ENUM('open','pending','closed','archived') NOT NULL DEFAULT 'open',
  started_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  last_message_at TIMESTAMP NULL DEFAULT NULL,
  closed_at TIMESTAMP NULL DEFAULT NULL,
  metadata JSON DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_test_conversations_scope_uuid (core_code, agent_code, workspace_code, uuid),
  KEY idx_test_conversations_contact (contact_id),
  KEY idx_test_conversations_scope (core_code, agent_code, workspace_code),
  CONSTRAINT fk_test_conversations_contact FOREIGN KEY (contact_id) REFERENCES test_contacts(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS test_messages (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  core_code VARCHAR(80) NOT NULL,
  agent_code VARCHAR(80) NOT NULL,
  workspace_code VARCHAR(120) NOT NULL,
  conversation_id BIGINT UNSIGNED NOT NULL,
  uuid CHAR(36) NOT NULL,
  direction ENUM('inbound','outbound','internal') NOT NULL,
  sender_type ENUM('contact','agent','user','system') NOT NULL,
  sender_ref VARCHAR(120) DEFAULT NULL,
  content LONGTEXT NOT NULL,
  content_type ENUM('text','json','markdown','event') NOT NULL DEFAULT 'text',
  status ENUM('received','queued','sent','failed','processed') NOT NULL DEFAULT 'received',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  metadata JSON DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_test_messages_scope_uuid (core_code, agent_code, workspace_code, uuid),
  KEY idx_test_messages_conversation (conversation_id),
  KEY idx_test_messages_scope (core_code, agent_code, workspace_code),
  CONSTRAINT fk_test_messages_conversation FOREIGN KEY (conversation_id) REFERENCES test_conversations(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS test_tasks (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  core_code VARCHAR(80) NOT NULL,
  agent_code VARCHAR(80) NOT NULL,
  workspace_code VARCHAR(120) NOT NULL,
  uuid CHAR(36) NOT NULL,
  conversation_id BIGINT UNSIGNED DEFAULT NULL,
  task_type VARCHAR(100) NOT NULL,
  title VARCHAR(190) NOT NULL,
  payload JSON DEFAULT NULL,
  priority ENUM('low','normal','high','critical') NOT NULL DEFAULT 'normal',
  status ENUM('queued','running','blocked','done','failed','cancelled') NOT NULL DEFAULT 'queued',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_test_tasks_scope_uuid (core_code, agent_code, workspace_code, uuid),
  KEY idx_test_tasks_conversation (conversation_id),
  KEY idx_test_tasks_scope (core_code, agent_code, workspace_code),
  CONSTRAINT fk_test_tasks_conversation FOREIGN KEY (conversation_id) REFERENCES test_conversations(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS test_file_assets (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  core_code VARCHAR(80) NOT NULL,
  agent_code VARCHAR(80) NOT NULL,
  workspace_code VARCHAR(120) NOT NULL,
  uuid CHAR(36) NOT NULL,
  storage_provider VARCHAR(60) NOT NULL DEFAULT 'filesystem',
  storage_path VARCHAR(500) NOT NULL,
  original_name VARCHAR(255) DEFAULT NULL,
  mime_type VARCHAR(120) DEFAULT NULL,
  file_size_bytes BIGINT UNSIGNED DEFAULT NULL,
  checksum_sha256 CHAR(64) DEFAULT NULL,
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_test_file_assets_scope_uuid (core_code, agent_code, workspace_code, uuid),
  KEY idx_test_file_assets_scope (core_code, agent_code, workspace_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS test_audit_logs (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  core_code VARCHAR(80) NOT NULL,
  agent_code VARCHAR(80) NOT NULL,
  workspace_code VARCHAR(120) NOT NULL,
  actor_type ENUM('user','agent','system','contact') NOT NULL,
  actor_ref VARCHAR(120) DEFAULT NULL,
  target_type VARCHAR(80) NOT NULL,
  target_ref VARCHAR(120) DEFAULT NULL,
  action VARCHAR(120) NOT NULL,
  summary VARCHAR(255) DEFAULT NULL,
  details JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_test_audit_scope (core_code, agent_code, workspace_code),
  KEY idx_test_audit_action (action)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SHOW TABLES;
