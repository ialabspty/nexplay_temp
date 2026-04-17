-- ClinicBridge v2 - esquema SQL inicial
-- Base orientativa para multitenancy, canales, RBAC, plataformas y capa cognitiva

CREATE TABLE tenants (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  tenant_key VARCHAR(100) NOT NULL UNIQUE,
  brand_name VARCHAR(255) NOT NULL,
  business_name VARCHAR(255) NULL,
  vertical VARCHAR(100) NOT NULL DEFAULT 'clinic',
  status VARCHAR(50) NOT NULL DEFAULT 'draft',
  country_code VARCHAR(10) NULL,
  timezone VARCHAR(100) NULL,
  default_language VARCHAR(20) NOT NULL DEFAULT 'es',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE tenant_branding (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  tenant_id BIGINT NOT NULL,
  public_name VARCHAR(255) NOT NULL,
  legal_name VARCHAR(255) NULL,
  description TEXT NULL,
  logo_url TEXT NULL,
  primary_color VARCHAR(50) NULL,
  tone_profile VARCHAR(100) NULL,
  greeting_message TEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_tenant_branding_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id)
);

CREATE TABLE tenant_locations (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  tenant_id BIGINT NOT NULL,
  name VARCHAR(255) NOT NULL,
  address_line TEXT NULL,
  city VARCHAR(150) NULL,
  country VARCHAR(150) NULL,
  latitude DECIMAL(10,7) NULL,
  longitude DECIMAL(10,7) NULL,
  status VARCHAR(50) NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_tenant_locations_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id)
);

CREATE TABLE tenant_doctors (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  tenant_id BIGINT NOT NULL,
  location_id BIGINT NULL,
  full_name VARCHAR(255) NOT NULL,
  slug VARCHAR(255) NULL,
  specialty VARCHAR(255) NULL,
  status VARCHAR(50) NOT NULL DEFAULT 'active',
  accepts_new_patients TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_tenant_doctors_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id),
  CONSTRAINT fk_tenant_doctors_location FOREIGN KEY (location_id) REFERENCES tenant_locations(id)
);

CREATE TABLE tenant_services (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  tenant_id BIGINT NOT NULL,
  name VARCHAR(255) NOT NULL,
  category VARCHAR(100) NULL,
  status VARCHAR(50) NOT NULL DEFAULT 'active',
  public_enabled TINYINT(1) NOT NULL DEFAULT 1,
  price_mode VARCHAR(50) NOT NULL DEFAULT 'hidden',
  listed_price DECIMAL(12,2) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_tenant_services_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id)
);

CREATE TABLE tenant_doctor_services (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  tenant_id BIGINT NOT NULL,
  doctor_id BIGINT NOT NULL,
  service_id BIGINT NOT NULL,
  status VARCHAR(50) NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_tenant_doctor_service (tenant_id, doctor_id, service_id),
  CONSTRAINT fk_tenant_doctor_services_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id),
  CONSTRAINT fk_tenant_doctor_services_doctor FOREIGN KEY (doctor_id) REFERENCES tenant_doctors(id),
  CONSTRAINT fk_tenant_doctor_services_service FOREIGN KEY (service_id) REFERENCES tenant_services(id)
);

CREATE TABLE tenant_schedules (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  tenant_id BIGINT NOT NULL,
  doctor_id BIGINT NULL,
  location_id BIGINT NULL,
  weekday TINYINT NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  status VARCHAR(50) NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_tenant_schedules_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id),
  CONSTRAINT fk_tenant_schedules_doctor FOREIGN KEY (doctor_id) REFERENCES tenant_doctors(id),
  CONSTRAINT fk_tenant_schedules_location FOREIGN KEY (location_id) REFERENCES tenant_locations(id)
);

CREATE TABLE tenant_insurances (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  tenant_id BIGINT NOT NULL,
  doctor_id BIGINT NULL,
  insurance_name VARCHAR(255) NOT NULL,
  status VARCHAR(50) NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_tenant_insurances_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id),
  CONSTRAINT fk_tenant_insurances_doctor FOREIGN KEY (doctor_id) REFERENCES tenant_doctors(id)
);

CREATE TABLE tenant_policies (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  tenant_id BIGINT NOT NULL,
  policy_key VARCHAR(150) NOT NULL,
  policy_value_json JSON NOT NULL,
  status VARCHAR(50) NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_tenant_policy (tenant_id, policy_key),
  CONSTRAINT fk_tenant_policies_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id)
);

CREATE TABLE tenant_prompts (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  tenant_id BIGINT NOT NULL,
  prompt_type VARCHAR(100) NOT NULL,
  content MEDIUMTEXT NOT NULL,
  version VARCHAR(50) NULL,
  status VARCHAR(50) NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_tenant_prompts_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id)
);

CREATE TABLE tenant_feature_flags (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  tenant_id BIGINT NOT NULL,
  flag_key VARCHAR(150) NOT NULL,
  flag_value VARCHAR(255) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_tenant_flag (tenant_id, flag_key),
  CONSTRAINT fk_tenant_feature_flags_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id)
);

CREATE TABLE tenant_channels (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  tenant_id BIGINT NOT NULL,
  channel_type VARCHAR(50) NOT NULL,
  provider VARCHAR(100) NOT NULL,
  purpose VARCHAR(50) NOT NULL DEFAULT 'public',
  business_account_id VARCHAR(255) NULL,
  phone_number_id VARCHAR(255) NULL,
  display_phone_number VARCHAR(50) NULL,
  display_name VARCHAR(255) NULL,
  webhook_path VARCHAR(255) NULL,
  access_token_ref VARCHAR(255) NULL,
  verify_token_ref VARCHAR(255) NULL,
  status VARCHAR(50) NOT NULL DEFAULT 'draft',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_phone_number_id (phone_number_id),
  CONSTRAINT fk_tenant_channels_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id)
);

CREATE TABLE platform_users (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  full_name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NULL,
  phone_e164 VARCHAR(50) NULL,
  status VARCHAR(50) NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_platform_users_phone (phone_e164),
  UNIQUE KEY uq_platform_users_email (email)
);

CREATE TABLE roles (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  role_key VARCHAR(100) NOT NULL UNIQUE,
  description TEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE tenant_memberships (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  tenant_id BIGINT NOT NULL,
  user_id BIGINT NOT NULL,
  role_id BIGINT NOT NULL,
  status VARCHAR(50) NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_tenant_membership (tenant_id, user_id, role_id),
  CONSTRAINT fk_tenant_memberships_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id),
  CONSTRAINT fk_tenant_memberships_user FOREIGN KEY (user_id) REFERENCES platform_users(id),
  CONSTRAINT fk_tenant_memberships_role FOREIGN KEY (role_id) REFERENCES roles(id)
);

CREATE TABLE phone_authorizations (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  phone_e164 VARCHAR(50) NOT NULL,
  user_id BIGINT NULL,
  tenant_id BIGINT NULL,
  role_scope VARCHAR(50) NOT NULL,
  role_id BIGINT NOT NULL,
  status VARCHAR(50) NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_phone_authorization (phone_e164, role_id, tenant_id),
  CONSTRAINT fk_phone_authorizations_user FOREIGN KEY (user_id) REFERENCES platform_users(id),
  CONSTRAINT fk_phone_authorizations_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id),
  CONSTRAINT fk_phone_authorizations_role FOREIGN KEY (role_id) REFERENCES roles(id)
);

CREATE TABLE config_change_log (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  actor_user_id BIGINT NULL,
  actor_phone_e164 VARCHAR(50) NULL,
  tenant_id BIGINT NULL,
  entity_type VARCHAR(100) NOT NULL,
  entity_id VARCHAR(100) NOT NULL,
  action_type VARCHAR(100) NOT NULL,
  before_json JSON NULL,
  after_json JSON NULL,
  source_channel VARCHAR(50) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_config_change_log_user FOREIGN KEY (actor_user_id) REFERENCES platform_users(id),
  CONSTRAINT fk_config_change_log_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id)
);

CREATE TABLE platforms (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  platform_key VARCHAR(100) NOT NULL UNIQUE,
  display_name VARCHAR(255) NOT NULL,
  vendor_type VARCHAR(100) NULL,
  supports_crawling TINYINT(1) NOT NULL DEFAULT 1,
  supports_schedule TINYINT(1) NOT NULL DEFAULT 0,
  supports_emr TINYINT(1) NOT NULL DEFAULT 0,
  status VARCHAR(50) NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE platform_entrypoints (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  tenant_id BIGINT NOT NULL,
  platform_id BIGINT NOT NULL,
  scope_type VARCHAR(50) NOT NULL,
  scope_id BIGINT NOT NULL,
  login_url TEXT NOT NULL,
  base_url TEXT NULL,
  module_type VARCHAR(100) NOT NULL,
  status VARCHAR(50) NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_platform_entrypoints_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id),
  CONSTRAINT fk_platform_entrypoints_platform FOREIGN KEY (platform_id) REFERENCES platforms(id)
);

CREATE TABLE platform_access_profiles (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  tenant_id BIGINT NOT NULL,
  platform_id BIGINT NOT NULL,
  scope_type VARCHAR(50) NOT NULL,
  scope_id BIGINT NOT NULL,
  login_identifier VARCHAR(255) NOT NULL,
  credential_ref VARCHAR(255) NOT NULL,
  inheritance_mode VARCHAR(50) NOT NULL DEFAULT 'direct',
  status VARCHAR(50) NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_platform_access_profiles_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id),
  CONSTRAINT fk_platform_access_profiles_platform FOREIGN KEY (platform_id) REFERENCES platforms(id)
);

CREATE TABLE doctor_platform_assignments (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  tenant_id BIGINT NOT NULL,
  doctor_id BIGINT NOT NULL,
  platform_id BIGINT NOT NULL,
  origin VARCHAR(50) NOT NULL,
  location_scope BIGINT NULL,
  specialty_scope VARCHAR(255) NULL,
  service_scope BIGINT NULL,
  module_scope VARCHAR(100) NOT NULL,
  priority INT NOT NULL DEFAULT 100,
  status VARCHAR(50) NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_doctor_platform_assignments_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id),
  CONSTRAINT fk_doctor_platform_assignments_doctor FOREIGN KEY (doctor_id) REFERENCES tenant_doctors(id),
  CONSTRAINT fk_doctor_platform_assignments_platform FOREIGN KEY (platform_id) REFERENCES platforms(id),
  CONSTRAINT fk_doctor_platform_assignments_location FOREIGN KEY (location_scope) REFERENCES tenant_locations(id),
  CONSTRAINT fk_doctor_platform_assignments_service FOREIGN KEY (service_scope) REFERENCES tenant_services(id)
);

CREATE TABLE platform_access_secrets (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  tenant_id BIGINT NOT NULL,
  platform_id BIGINT NOT NULL,
  scope_type VARCHAR(50) NOT NULL,
  scope_id BIGINT NOT NULL,
  secret_ref VARCHAR(255) NOT NULL,
  auth_type VARCHAR(100) NOT NULL,
  rotation_status VARCHAR(50) NOT NULL DEFAULT 'active',
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_platform_access_secrets_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id),
  CONSTRAINT fk_platform_access_secrets_platform FOREIGN KEY (platform_id) REFERENCES platforms(id)
);

CREATE TABLE tenant_templates (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  template_key VARCHAR(100) NOT NULL UNIQUE,
  vertical VARCHAR(100) NOT NULL,
  base_branding_json JSON NULL,
  base_policies_json JSON NULL,
  base_prompt MEDIUMTEXT NULL,
  base_services_json JSON NULL,
  feature_flags_json JSON NULL,
  status VARCHAR(50) NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE tenant_cognitive_providers (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  tenant_id BIGINT NOT NULL,
  provider_key VARCHAR(100) NOT NULL,
  model_key VARCHAR(150) NOT NULL,
  purpose VARCHAR(100) NOT NULL,
  priority INT NOT NULL DEFAULT 100,
  status VARCHAR(50) NOT NULL DEFAULT 'active',
  temperature DECIMAL(4,2) NULL,
  max_tokens INT NULL,
  timeout_ms INT NULL,
  cost_tier VARCHAR(50) NULL,
  secret_ref VARCHAR(255) NULL,
  policy_profile VARCHAR(100) NULL,
  enabled TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_tenant_cognitive_providers_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id)
);

CREATE TABLE tenant_cognitive_policies (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  tenant_id BIGINT NOT NULL,
  policy_key VARCHAR(100) NOT NULL,
  allowed_domains_json JSON NULL,
  blocked_topics_json JSON NULL,
  requires_db_grounding TINYINT(1) NOT NULL DEFAULT 0,
  allow_free_generation TINYINT(1) NOT NULL DEFAULT 0,
  fallback_mode VARCHAR(50) NOT NULL DEFAULT 'hardcoded',
  citation_mode VARCHAR(50) NOT NULL DEFAULT 'none',
  hallucination_guard_level VARCHAR(50) NOT NULL DEFAULT 'high',
  status VARCHAR(50) NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_tenant_cognitive_policy (tenant_id, policy_key),
  CONSTRAINT fk_tenant_cognitive_policies_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id)
);

CREATE TABLE message_resolution_logs (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  tenant_id BIGINT NOT NULL,
  channel_id BIGINT NULL,
  inbound_message_id VARCHAR(255) NOT NULL,
  source_used VARCHAR(50) NOT NULL,
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
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_message_resolution_logs_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id),
  CONSTRAINT fk_message_resolution_logs_channel FOREIGN KEY (channel_id) REFERENCES tenant_channels(id)
);

-- Seeds mínimos sugeridos
INSERT INTO roles (role_key, description) VALUES
  ('platform_owner', 'Control total de la plataforma'),
  ('platform_admin', 'Administración global operativa'),
  ('clinic_supervisor', 'Responsable de configuración de una clínica'),
  ('clinic_operator', 'Operación acotada de clínica'),
  ('audit_readonly', 'Consulta sin permisos de cambio');

INSERT INTO platforms (platform_key, display_name, vendor_type, supports_crawling, supports_schedule, supports_emr) VALUES
  ('clinic-web', 'Clinic Web', 'clinicweb', 1, 1, 0),
  ('huli-practice', 'Huli Practice', 'huli', 1, 1, 1);
