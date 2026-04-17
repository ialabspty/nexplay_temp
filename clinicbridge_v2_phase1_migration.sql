-- ClinicBridge v2 - Fase 1 no destructiva
-- Objetivo: agregar base de multitenancy, channels, RBAC, auditoría de configuración
-- y capa cognitiva sin romper la estructura clínica actual.

START TRANSACTION;

CREATE TABLE IF NOT EXISTS tenants (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tenant_key VARCHAR(100) NOT NULL UNIQUE,
  vertical VARCHAR(100) NOT NULL DEFAULT 'clinic',
  status ENUM('draft','active','inactive') NOT NULL DEFAULT 'draft',
  country_code VARCHAR(10) NULL,
  timezone VARCHAR(100) NULL,
  default_language VARCHAR(20) NOT NULL DEFAULT 'es',
  metadata LONGTEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS tenant_branding (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  public_name VARCHAR(190) NOT NULL,
  legal_name VARCHAR(190) NULL,
  description TEXT NULL,
  logo_url VARCHAR(500) NULL,
  primary_color VARCHAR(50) NULL,
  tone_profile VARCHAR(100) NULL,
  greeting_message TEXT NULL,
  metadata LONGTEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_tenant_branding_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS tenant_feature_flags (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  flag_key VARCHAR(150) NOT NULL,
  flag_value VARCHAR(255) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_tenant_flag (tenant_id, flag_key),
  CONSTRAINT fk_tenant_feature_flags_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS tenant_prompts (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  prompt_type VARCHAR(100) NOT NULL,
  content MEDIUMTEXT NOT NULL,
  version VARCHAR(50) NULL,
  status ENUM('active','inactive','draft') NOT NULL DEFAULT 'active',
  metadata LONGTEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_tenant_prompts_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS tenant_templates (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  template_key VARCHAR(100) NOT NULL UNIQUE,
  vertical VARCHAR(100) NOT NULL,
  base_branding_json LONGTEXT NULL,
  base_policies_json LONGTEXT NULL,
  base_prompt MEDIUMTEXT NULL,
  base_services_json LONGTEXT NULL,
  feature_flags_json LONGTEXT NULL,
  status ENUM('active','inactive') NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS tenant_channels (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  clinic_id BIGINT UNSIGNED NULL,
  channel_type VARCHAR(50) NOT NULL,
  provider VARCHAR(100) NOT NULL,
  purpose ENUM('public','clinic_ops','platform_admin') NOT NULL DEFAULT 'public',
  business_account_id VARCHAR(255) NULL,
  phone_number_id VARCHAR(255) NULL,
  display_phone_number VARCHAR(50) NULL,
  display_name VARCHAR(190) NULL,
  webhook_path VARCHAR(255) NULL,
  access_token_ref VARCHAR(255) NULL,
  verify_token_ref VARCHAR(255) NULL,
  status ENUM('draft','active','inactive') NOT NULL DEFAULT 'draft',
  metadata LONGTEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_tenant_channels_phone_number_id (phone_number_id),
  KEY idx_tenant_channels_tenant (tenant_id),
  KEY idx_tenant_channels_clinic (clinic_id),
  CONSTRAINT fk_tenant_channels_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id),
  CONSTRAINT fk_tenant_channels_clinic FOREIGN KEY (clinic_id) REFERENCES clinics(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS platform_users (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  full_name VARCHAR(190) NOT NULL,
  email VARCHAR(190) NULL,
  phone_e164 VARCHAR(30) NULL,
  status ENUM('active','inactive') NOT NULL DEFAULT 'active',
  metadata LONGTEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_platform_users_email (email),
  UNIQUE KEY uq_platform_users_phone (phone_e164)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS roles (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  role_key VARCHAR(100) NOT NULL UNIQUE,
  description TEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS tenant_memberships (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  clinic_id BIGINT UNSIGNED NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  role_id BIGINT UNSIGNED NOT NULL,
  status ENUM('active','inactive') NOT NULL DEFAULT 'active',
  metadata LONGTEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_tenant_membership (tenant_id, user_id, role_id),
  KEY idx_tenant_memberships_clinic (clinic_id),
  CONSTRAINT fk_tenant_memberships_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id),
  CONSTRAINT fk_tenant_memberships_clinic FOREIGN KEY (clinic_id) REFERENCES clinics(id),
  CONSTRAINT fk_tenant_memberships_user FOREIGN KEY (user_id) REFERENCES platform_users(id),
  CONSTRAINT fk_tenant_memberships_role FOREIGN KEY (role_id) REFERENCES roles(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS phone_authorizations (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  phone_e164 VARCHAR(30) NOT NULL,
  user_id BIGINT UNSIGNED NULL,
  tenant_id BIGINT UNSIGNED NULL,
  clinic_id BIGINT UNSIGNED NULL,
  role_scope ENUM('platform','tenant','clinic') NOT NULL,
  role_id BIGINT UNSIGNED NOT NULL,
  status ENUM('active','inactive') NOT NULL DEFAULT 'active',
  metadata LONGTEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_phone_authorization (phone_e164, role_id, tenant_id, clinic_id),
  CONSTRAINT fk_phone_authorizations_user FOREIGN KEY (user_id) REFERENCES platform_users(id),
  CONSTRAINT fk_phone_authorizations_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id),
  CONSTRAINT fk_phone_authorizations_clinic FOREIGN KEY (clinic_id) REFERENCES clinics(id),
  CONSTRAINT fk_phone_authorizations_role FOREIGN KEY (role_id) REFERENCES roles(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS config_change_log (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  actor_user_id BIGINT UNSIGNED NULL,
  actor_phone_e164 VARCHAR(30) NULL,
  tenant_id BIGINT UNSIGNED NULL,
  clinic_id BIGINT UNSIGNED NULL,
  entity_type VARCHAR(100) NOT NULL,
  entity_id VARCHAR(100) NOT NULL,
  action_type VARCHAR(100) NOT NULL,
  before_json LONGTEXT NULL,
  after_json LONGTEXT NULL,
  source_channel VARCHAR(60) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_config_change_log_tenant (tenant_id),
  KEY idx_config_change_log_clinic (clinic_id),
  CONSTRAINT fk_config_change_log_user FOREIGN KEY (actor_user_id) REFERENCES platform_users(id),
  CONSTRAINT fk_config_change_log_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id),
  CONSTRAINT fk_config_change_log_clinic FOREIGN KEY (clinic_id) REFERENCES clinics(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS tenant_cognitive_providers (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  clinic_id BIGINT UNSIGNED NULL,
  provider_key VARCHAR(100) NOT NULL,
  model_key VARCHAR(150) NOT NULL,
  purpose VARCHAR(100) NOT NULL,
  priority INT NOT NULL DEFAULT 100,
  status ENUM('active','inactive') NOT NULL DEFAULT 'active',
  temperature DECIMAL(4,2) NULL,
  max_tokens INT NULL,
  timeout_ms INT NULL,
  cost_tier VARCHAR(50) NULL,
  secret_ref VARCHAR(255) NULL,
  policy_profile VARCHAR(100) NULL,
  enabled TINYINT(1) NOT NULL DEFAULT 1,
  metadata LONGTEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_tenant_cognitive_providers_tenant (tenant_id),
  KEY idx_tenant_cognitive_providers_clinic (clinic_id),
  CONSTRAINT fk_tenant_cognitive_providers_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id),
  CONSTRAINT fk_tenant_cognitive_providers_clinic FOREIGN KEY (clinic_id) REFERENCES clinics(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS tenant_cognitive_policies (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  clinic_id BIGINT UNSIGNED NULL,
  policy_key VARCHAR(100) NOT NULL,
  allowed_domains_json LONGTEXT NULL,
  blocked_topics_json LONGTEXT NULL,
  requires_db_grounding TINYINT(1) NOT NULL DEFAULT 0,
  allow_free_generation TINYINT(1) NOT NULL DEFAULT 0,
  fallback_mode VARCHAR(50) NOT NULL DEFAULT 'hardcoded',
  citation_mode VARCHAR(50) NOT NULL DEFAULT 'none',
  hallucination_guard_level VARCHAR(50) NOT NULL DEFAULT 'high',
  status ENUM('active','inactive') NOT NULL DEFAULT 'active',
  metadata LONGTEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_tenant_cognitive_policy (tenant_id, policy_key),
  KEY idx_tenant_cognitive_policies_clinic (clinic_id),
  CONSTRAINT fk_tenant_cognitive_policies_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id),
  CONSTRAINT fk_tenant_cognitive_policies_clinic FOREIGN KEY (clinic_id) REFERENCES clinics(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS message_resolution_logs (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  clinic_id BIGINT UNSIGNED NULL,
  channel_id BIGINT UNSIGNED NULL,
  conversation_id BIGINT UNSIGNED NULL,
  inbound_message_id VARCHAR(255) NOT NULL,
  source_used ENUM('hardcoded','db','cognitive','hybrid') NOT NULL,
  provider_key VARCHAR(100) NULL,
  model_key VARCHAR(150) NULL,
  purpose VARCHAR(100) NULL,
  adapter_used VARCHAR(100) NULL,
  token_usage_in INT NULL,
  token_usage_out INT NULL,
  cost_estimate DECIMAL(12,6) NULL,
  fallback_triggered TINYINT(1) NOT NULL DEFAULT 0,
  response_latency_ms INT NULL,
  success TINYINT(1) NOT NULL DEFAULT 1,
  error_message TEXT NULL,
  metadata LONGTEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_message_resolution_logs_tenant (tenant_id),
  KEY idx_message_resolution_logs_clinic (clinic_id),
  KEY idx_message_resolution_logs_channel (channel_id),
  KEY idx_message_resolution_logs_conversation (conversation_id),
  CONSTRAINT fk_message_resolution_logs_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id),
  CONSTRAINT fk_message_resolution_logs_clinic FOREIGN KEY (clinic_id) REFERENCES clinics(id),
  CONSTRAINT fk_message_resolution_logs_channel FOREIGN KEY (channel_id) REFERENCES tenant_channels(id),
  CONSTRAINT fk_message_resolution_logs_conversation FOREIGN KEY (conversation_id) REFERENCES conversations(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Extensión mínima no destructiva sobre clínicas
ALTER TABLE clinics
  ADD COLUMN IF NOT EXISTS tenant_id BIGINT UNSIGNED NULL AFTER id,
  ADD COLUMN IF NOT EXISTS default_language VARCHAR(20) NULL AFTER status,
  ADD COLUMN IF NOT EXISTS timezone VARCHAR(100) NULL AFTER default_language;

ALTER TABLE clinics
  ADD CONSTRAINT fk_clinics_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id);

-- Extensión mínima de locations
ALTER TABLE locations
  ADD COLUMN IF NOT EXISTS latitude DECIMAL(10,7) NULL AFTER country_code,
  ADD COLUMN IF NOT EXISTS longitude DECIMAL(10,7) NULL AFTER latitude;

-- Extensión mínima de services
ALTER TABLE services
  ADD COLUMN IF NOT EXISTS public_enabled TINYINT(1) NOT NULL DEFAULT 1 AFTER is_active,
  ADD COLUMN IF NOT EXISTS price_mode VARCHAR(50) NULL AFTER public_enabled,
  ADD COLUMN IF NOT EXISTS listed_price DECIMAL(12,2) NULL AFTER price_mode;

-- Extensión mínima de doctor_platforms
ALTER TABLE doctor_platforms
  ADD COLUMN IF NOT EXISTS platform_registry_id BIGINT UNSIGNED NULL AFTER service_id,
  ADD COLUMN IF NOT EXISTS origin_scope ENUM('doctor','location','clinic') NULL AFTER access_url;

ALTER TABLE doctor_platforms
  ADD CONSTRAINT fk_doctor_platforms_platform_registry FOREIGN KEY (platform_registry_id) REFERENCES platform_registry(id);

-- Extensión mínima de platform_access_profiles
ALTER TABLE platform_access_profiles
  ADD COLUMN IF NOT EXISTS location_id BIGINT UNSIGNED NULL AFTER clinic_id,
  ADD COLUMN IF NOT EXISTS scope_type VARCHAR(50) NULL AFTER location_id,
  ADD COLUMN IF NOT EXISTS scope_id BIGINT UNSIGNED NULL AFTER scope_type;

ALTER TABLE platform_access_profiles
  ADD CONSTRAINT fk_platform_access_profiles_location FOREIGN KEY (location_id) REFERENCES locations(id);

-- Seeds base de roles
INSERT IGNORE INTO roles (role_key, description) VALUES
  ('platform_owner', 'Control total de la plataforma'),
  ('platform_admin', 'Administración global operativa'),
  ('clinic_supervisor', 'Responsable de configuración de una clínica'),
  ('clinic_operator', 'Operación acotada de clínica'),
  ('audit_readonly', 'Consulta sin permisos de cambio');

COMMIT;
