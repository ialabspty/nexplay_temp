SET NAMES utf8mb4;
SET time_zone = '+00:00';

CREATE TABLE IF NOT EXISTS users (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  uuid CHAR(36) NOT NULL,
  full_name VARCHAR(150) NOT NULL,
  email VARCHAR(190) DEFAULT NULL,
  phone VARCHAR(30) DEFAULT NULL,
  status ENUM('active','inactive','blocked') NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_users_uuid (uuid),
  UNIQUE KEY uq_users_email (email),
  KEY idx_users_phone (phone),
  KEY idx_users_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS roles (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  code VARCHAR(80) NOT NULL,
  name VARCHAR(120) NOT NULL,
  description TEXT DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_roles_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS user_roles (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  role_id BIGINT UNSIGNED NOT NULL,
  assigned_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_user_roles_user_role (user_id, role_id),
  CONSTRAINT fk_user_roles_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_user_roles_role FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS agents (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  code VARCHAR(80) NOT NULL,
  name VARCHAR(120) NOT NULL,
  domain_type ENUM('internal','public','ops','system') NOT NULL DEFAULT 'public',
  status ENUM('active','inactive','draft') NOT NULL DEFAULT 'active',
  description TEXT DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_agents_code (code),
  KEY idx_agents_domain_type (domain_type),
  KEY idx_agents_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS workspaces (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  code VARCHAR(80) NOT NULL,
  name VARCHAR(120) NOT NULL,
  environment ENUM('test','prod','dev','stage') NOT NULL DEFAULT 'test',
  status ENUM('active','inactive') NOT NULL DEFAULT 'active',
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_workspaces_code (code),
  KEY idx_workspaces_environment (environment),
  KEY idx_workspaces_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS channel_accounts (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  workspace_id BIGINT UNSIGNED DEFAULT NULL,
  provider VARCHAR(60) NOT NULL,
  account_id VARCHAR(120) NOT NULL,
  label VARCHAR(150) DEFAULT NULL,
  status ENUM('active','inactive') NOT NULL DEFAULT 'active',
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_channel_accounts_provider_account (provider, account_id),
  KEY idx_channel_accounts_workspace (workspace_id),
  CONSTRAINT fk_channel_accounts_workspace FOREIGN KEY (workspace_id) REFERENCES workspaces(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
  workspace_id BIGINT UNSIGNED DEFAULT NULL,
  agent_id BIGINT UNSIGNED DEFAULT NULL,
  channel_account_id BIGINT UNSIGNED DEFAULT NULL,
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
  KEY idx_conversations_workspace (workspace_id),
  KEY idx_conversations_agent (agent_id),
  KEY idx_conversations_contact (contact_id),
  KEY idx_conversations_channel_account (channel_account_id),
  KEY idx_conversations_status (status),
  KEY idx_conversations_external_chat_id (external_chat_id),
  CONSTRAINT fk_conversations_workspace FOREIGN KEY (workspace_id) REFERENCES workspaces(id) ON DELETE SET NULL,
  CONSTRAINT fk_conversations_agent FOREIGN KEY (agent_id) REFERENCES agents(id) ON DELETE SET NULL,
  CONSTRAINT fk_conversations_channel_account FOREIGN KEY (channel_account_id) REFERENCES channel_accounts(id) ON DELETE SET NULL,
  CONSTRAINT fk_conversations_contact FOREIGN KEY (contact_id) REFERENCES contacts(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS messages (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  conversation_id BIGINT UNSIGNED NOT NULL,
  uuid CHAR(36) NOT NULL,
  direction ENUM('inbound','outbound','internal') NOT NULL,
  sender_type ENUM('contact','agent','user','system') NOT NULL,
  sender_id BIGINT UNSIGNED DEFAULT NULL,
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

CREATE TABLE IF NOT EXISTS task_queue (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  uuid CHAR(36) NOT NULL,
  agent_id BIGINT UNSIGNED DEFAULT NULL,
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
  KEY idx_task_queue_agent (agent_id),
  KEY idx_task_queue_conversation (conversation_id),
  KEY idx_task_queue_status (status),
  KEY idx_task_queue_priority (priority),
  KEY idx_task_queue_scheduled_for (scheduled_for),
  CONSTRAINT fk_task_queue_agent FOREIGN KEY (agent_id) REFERENCES agents(id) ON DELETE SET NULL,
  CONSTRAINT fk_task_queue_conversation FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS system_events (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  workspace_id BIGINT UNSIGNED DEFAULT NULL,
  agent_id BIGINT UNSIGNED DEFAULT NULL,
  event_type VARCHAR(100) NOT NULL,
  severity ENUM('info','warning','error','critical') NOT NULL DEFAULT 'info',
  title VARCHAR(190) NOT NULL,
  body TEXT DEFAULT NULL,
  event_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  metadata JSON DEFAULT NULL,
  PRIMARY KEY (id),
  KEY idx_system_events_workspace (workspace_id),
  KEY idx_system_events_agent (agent_id),
  KEY idx_system_events_event_type (event_type),
  KEY idx_system_events_severity (severity),
  KEY idx_system_events_event_at (event_at),
  CONSTRAINT fk_system_events_workspace FOREIGN KEY (workspace_id) REFERENCES workspaces(id) ON DELETE SET NULL,
  CONSTRAINT fk_system_events_agent FOREIGN KEY (agent_id) REFERENCES agents(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS audit_logs (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  actor_type ENUM('user','agent','system','contact') NOT NULL,
  actor_id BIGINT UNSIGNED DEFAULT NULL,
  target_type VARCHAR(80) NOT NULL,
  target_id VARCHAR(120) DEFAULT NULL,
  action VARCHAR(120) NOT NULL,
  summary VARCHAR(255) DEFAULT NULL,
  details JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_audit_logs_actor (actor_type, actor_id),
  KEY idx_audit_logs_target (target_type, target_id),
  KEY idx_audit_logs_action (action),
  KEY idx_audit_logs_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS settings (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  scope_type ENUM('global','workspace','agent','user') NOT NULL DEFAULT 'global',
  scope_id BIGINT UNSIGNED DEFAULT NULL,
  `key` VARCHAR(150) NOT NULL,
  `value` JSON DEFAULT NULL,
  is_secret TINYINT(1) NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_settings_scope_key (scope_type, scope_id, `key`),
  KEY idx_settings_key (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO roles (code, name, description)
VALUES
  ('super_admin', 'Super Admin', 'Acceso total administrativo'),
  ('operator', 'Operator', 'Operador interno'),
  ('viewer', 'Viewer', 'Solo lectura')
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  description = VALUES(description);

INSERT INTO agents (code, name, domain_type, status, description)
VALUES
  ('hq-internal', 'HQ Internal', 'internal', 'active', 'Centro de mando general'),
  ('kargaspty', 'KargasPTY', 'public', 'active', 'Logística y casillero'),
  ('servialpa', 'Servialpa', 'public', 'active', 'Trámites y seguimiento'),
  ('edubridge', 'EduBridge', 'public', 'active', 'Soporte escolar y plataforma educativa'),
  ('telollevo', 'TeLoLLevo', 'public', 'active', 'Compras, sourcing y delivery'),
  ('tunegocioaldia', 'Tu negocio al día', 'public', 'active', 'Gestión operativa del negocio'),
  ('jardines-panama', 'Jardines Panamá', 'public', 'active', 'Jardinería, ferretería, conveniencia y delivery'),
  ('dermacos', 'DermaCos', 'public', 'active', 'Clínica de dermatología')
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  domain_type = VALUES(domain_type),
  status = VALUES(status),
  description = VALUES(description);

INSERT INTO workspaces (code, name, environment, status, metadata)
VALUES
  ('hq-test', 'HQ Test', 'test', 'active', JSON_OBJECT('db', 'hq_test'))
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  environment = VALUES(environment),
  status = VALUES(status),
  metadata = VALUES(metadata);
