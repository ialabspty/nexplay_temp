SET NAMES utf8mb4;
SET time_zone = '+00:00';

DROP TABLE IF EXISTS __approval_probe;

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

CREATE TABLE IF NOT EXISTS routing_rules (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  rule_code VARCHAR(100) NOT NULL,
  name VARCHAR(150) NOT NULL,
  source_channel VARCHAR(60) DEFAULT NULL,
  match_type ENUM('keyword','regex','sender','domain','manual') NOT NULL DEFAULT 'keyword',
  match_value VARCHAR(255) NOT NULL,
  target_agent_id BIGINT UNSIGNED DEFAULT NULL,
  priority INT NOT NULL DEFAULT 100,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_routing_rules_code (rule_code),
  KEY idx_routing_rules_target_agent (target_agent_id),
  KEY idx_routing_rules_priority (priority),
  KEY idx_routing_rules_active (is_active),
  CONSTRAINT fk_routing_rules_target_agent FOREIGN KEY (target_agent_id) REFERENCES agents(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS agent_registry (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  agent_id BIGINT UNSIGNED NOT NULL,
  workspace_id BIGINT UNSIGNED DEFAULT NULL,
  runtime VARCHAR(60) DEFAULT NULL,
  session_key VARCHAR(190) DEFAULT NULL,
  status ENUM('active','inactive','paused','error') NOT NULL DEFAULT 'active',
  capabilities JSON DEFAULT NULL,
  last_seen_at TIMESTAMP NULL DEFAULT NULL,
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_agent_registry_agent_workspace (agent_id, workspace_id),
  KEY idx_agent_registry_session_key (session_key),
  KEY idx_agent_registry_status (status),
  CONSTRAINT fk_agent_registry_agent FOREIGN KEY (agent_id) REFERENCES agents(id) ON DELETE CASCADE,
  CONSTRAINT fk_agent_registry_workspace FOREIGN KEY (workspace_id) REFERENCES workspaces(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS handoff_events (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  conversation_id BIGINT UNSIGNED DEFAULT NULL,
  from_agent_id BIGINT UNSIGNED DEFAULT NULL,
  to_agent_id BIGINT UNSIGNED DEFAULT NULL,
  handoff_reason VARCHAR(190) DEFAULT NULL,
  status ENUM('requested','accepted','rejected','completed','cancelled') NOT NULL DEFAULT 'requested',
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  completed_at TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (id),
  KEY idx_handoff_events_conversation (conversation_id),
  KEY idx_handoff_events_from_agent (from_agent_id),
  KEY idx_handoff_events_to_agent (to_agent_id),
  KEY idx_handoff_events_status (status),
  CONSTRAINT fk_handoff_events_conversation FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE SET NULL,
  CONSTRAINT fk_handoff_events_from_agent FOREIGN KEY (from_agent_id) REFERENCES agents(id) ON DELETE SET NULL,
  CONSTRAINT fk_handoff_events_to_agent FOREIGN KEY (to_agent_id) REFERENCES agents(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS global_metrics (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  metric_date DATE NOT NULL,
  metric_scope VARCHAR(80) NOT NULL DEFAULT 'global',
  scope_ref VARCHAR(120) DEFAULT NULL,
  metric_name VARCHAR(120) NOT NULL,
  metric_value DECIMAL(18,4) NOT NULL DEFAULT 0,
  unit VARCHAR(30) DEFAULT NULL,
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_global_metrics_unique (metric_date, metric_scope, scope_ref, metric_name),
  KEY idx_global_metrics_scope (metric_scope, scope_ref),
  KEY idx_global_metrics_name (metric_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SHOW TABLES;
