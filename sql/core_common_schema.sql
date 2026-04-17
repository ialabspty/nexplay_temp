SET NAMES utf8mb4;
SET time_zone = '+00:00';

CREATE TABLE IF NOT EXISTS contacts (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  uuid CHAR(36) NOT NULL,
  display_name VARCHAR(150) DEFAULT NULL,
  phone VARCHAR(30) DEFAULT NULL,
  email VARCHAR(190) DEFAULT NULL,
  contact_type ENUM('person','company','system') NOT NULL DEFAULT 'person',
  source_channel VARCHAR(60) DEFAULT NULL,
  external_ref VARCHAR(190) DEFAULT NULL,
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_contacts_uuid (uuid),
  KEY idx_contacts_phone (phone),
  KEY idx_contacts_email (email),
  KEY idx_contacts_external_ref (external_ref)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS conversations (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  uuid CHAR(36) NOT NULL,
  contact_id BIGINT UNSIGNED DEFAULT NULL,
  channel VARCHAR(60) DEFAULT NULL,
  external_chat_id VARCHAR(190) DEFAULT NULL,
  subject VARCHAR(190) DEFAULT NULL,
  status ENUM('open','pending','closed','archived') NOT NULL DEFAULT 'open',
  started_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  last_message_at TIMESTAMP NULL DEFAULT NULL,
  closed_at TIMESTAMP NULL DEFAULT NULL,
  metadata JSON DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_conversations_uuid (uuid),
  KEY idx_conversations_contact (contact_id),
  KEY idx_conversations_status (status),
  KEY idx_conversations_external_chat_id (external_chat_id),
  CONSTRAINT fk_conversations_contact FOREIGN KEY (contact_id) REFERENCES contacts(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS messages (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  conversation_id BIGINT UNSIGNED NOT NULL,
  uuid CHAR(36) NOT NULL,
  direction ENUM('inbound','outbound','internal') NOT NULL,
  sender_type ENUM('contact','agent','user','system') NOT NULL,
  sender_ref VARCHAR(120) DEFAULT NULL,
  content LONGTEXT NOT NULL,
  content_type ENUM('text','json','markdown','event') NOT NULL DEFAULT 'text',
  provider_message_id VARCHAR(190) DEFAULT NULL,
  status ENUM('received','queued','sent','failed','processed') NOT NULL DEFAULT 'received',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  metadata JSON DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_messages_uuid (uuid),
  KEY idx_messages_conversation (conversation_id),
  KEY idx_messages_provider_message_id (provider_message_id),
  KEY idx_messages_status (status),
  KEY idx_messages_created_at (created_at),
  CONSTRAINT fk_messages_conversation FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS attachments (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  message_id BIGINT UNSIGNED DEFAULT NULL,
  attachment_type VARCHAR(60) NOT NULL,
  file_name VARCHAR(255) DEFAULT NULL,
  mime_type VARCHAR(120) DEFAULT NULL,
  storage_path VARCHAR(500) NOT NULL,
  file_size_bytes BIGINT UNSIGNED DEFAULT NULL,
  checksum_sha256 CHAR(64) DEFAULT NULL,
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_attachments_message (message_id),
  KEY idx_attachments_storage_path (storage_path(191)),
  CONSTRAINT fk_attachments_message FOREIGN KEY (message_id) REFERENCES messages(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS task_queue (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  uuid CHAR(36) NOT NULL,
  conversation_id BIGINT UNSIGNED DEFAULT NULL,
  task_type VARCHAR(100) NOT NULL,
  title VARCHAR(190) NOT NULL,
  payload JSON DEFAULT NULL,
  priority ENUM('low','normal','high','critical') NOT NULL DEFAULT 'normal',
  status ENUM('queued','running','blocked','done','failed','cancelled') NOT NULL DEFAULT 'queued',
  scheduled_for TIMESTAMP NULL DEFAULT NULL,
  started_at TIMESTAMP NULL DEFAULT NULL,
  completed_at TIMESTAMP NULL DEFAULT NULL,
  error_message TEXT DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_task_queue_uuid (uuid),
  KEY idx_task_queue_conversation (conversation_id),
  KEY idx_task_queue_status (status),
  KEY idx_task_queue_priority (priority),
  KEY idx_task_queue_scheduled_for (scheduled_for),
  CONSTRAINT fk_task_queue_conversation FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS audit_logs (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  actor_type ENUM('user','agent','system','contact') NOT NULL,
  actor_ref VARCHAR(120) DEFAULT NULL,
  target_type VARCHAR(80) NOT NULL,
  target_ref VARCHAR(120) DEFAULT NULL,
  action VARCHAR(120) NOT NULL,
  summary VARCHAR(255) DEFAULT NULL,
  details JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_audit_logs_actor (actor_type, actor_ref),
  KEY idx_audit_logs_target (target_type, target_ref),
  KEY idx_audit_logs_action (action),
  KEY idx_audit_logs_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS settings (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  scope_type ENUM('global','workspace','agent','user','tenant') NOT NULL DEFAULT 'global',
  scope_ref VARCHAR(120) DEFAULT NULL,
  `key` VARCHAR(150) NOT NULL,
  `value` JSON DEFAULT NULL,
  is_secret TINYINT(1) NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_settings_scope_key (scope_type, scope_ref, `key`),
  KEY idx_settings_key (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS file_assets (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  uuid CHAR(36) NOT NULL,
  storage_provider VARCHAR(60) NOT NULL DEFAULT 'filesystem',
  storage_path VARCHAR(500) NOT NULL,
  original_name VARCHAR(255) DEFAULT NULL,
  mime_type VARCHAR(120) DEFAULT NULL,
  extension VARCHAR(20) DEFAULT NULL,
  file_size_bytes BIGINT UNSIGNED DEFAULT NULL,
  checksum_sha256 CHAR(64) DEFAULT NULL,
  visibility ENUM('private','internal','public') NOT NULL DEFAULT 'private',
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_file_assets_uuid (uuid),
  KEY idx_file_assets_storage_path (storage_path(191)),
  KEY idx_file_assets_checksum (checksum_sha256)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS file_links (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  file_asset_id BIGINT UNSIGNED NOT NULL,
  entity_type VARCHAR(80) NOT NULL,
  entity_id BIGINT UNSIGNED DEFAULT NULL,
  entity_ref VARCHAR(120) DEFAULT NULL,
  role VARCHAR(60) DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_file_links_asset (file_asset_id),
  KEY idx_file_links_entity (entity_type, entity_id),
  KEY idx_file_links_entity_ref (entity_type, entity_ref),
  CONSTRAINT fk_file_links_asset FOREIGN KEY (file_asset_id) REFERENCES file_assets(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
