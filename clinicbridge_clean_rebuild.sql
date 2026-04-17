-- ClinicBridge clean rebuild
-- Reconstrucción completa desde cero del modelo de datos para ClinicBridge v2
-- Incluye: multitenancy, white-label, channels, RBAC, plataformas, crawling,
-- capa cognitiva configurable y medición de baseline/impacto/ROI.

DROP DATABASE IF EXISTS ClinicBridge;
CREATE DATABASE ClinicBridge CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ClinicBridge;

-- =========================
-- 1. TENANTS Y BRANDING
-- =========================

CREATE TABLE tenants (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tenant_key VARCHAR(100) NOT NULL UNIQUE,
  vertical VARCHAR(100) NOT NULL DEFAULT 'clinic',
  brand_name VARCHAR(190) NOT NULL,
  legal_name VARCHAR(190) NULL,
  status ENUM('draft','active','inactive') NOT NULL DEFAULT 'draft',
  country_code VARCHAR(10) NULL,
  timezone VARCHAR(100) NULL,
  default_language VARCHAR(20) NOT NULL DEFAULT 'es',
  metadata LONGTEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tenant_branding (
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

CREATE TABLE tenant_feature_flags (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  flag_key VARCHAR(150) NOT NULL,
  flag_value VARCHAR(255) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_tenant_flag (tenant_id, flag_key),
  CONSTRAINT fk_tenant_feature_flags_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tenant_prompts (
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

CREATE TABLE tenant_templates (
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

-- =========================
-- 2. CLÍNICAS, SEDES, MÉDICOS Y SERVICIOS
-- =========================

CREATE TABLE clinics (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  code VARCHAR(80) NOT NULL UNIQUE,
  name VARCHAR(190) NOT NULL,
  legal_name VARCHAR(190) NULL,
  status ENUM('active','inactive') NOT NULL DEFAULT 'active',
  default_language VARCHAR(20) NOT NULL DEFAULT 'es',
  timezone VARCHAR(100) NULL,
  metadata LONGTEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_clinics_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE locations (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  clinic_id BIGINT UNSIGNED NOT NULL,
  code VARCHAR(80) NULL,
  name VARCHAR(190) NOT NULL,
  address_line1 VARCHAR(255) NULL,
  city VARCHAR(120) NULL,
  country_code VARCHAR(10) NULL,
  phone VARCHAR(30) NULL,
  latitude DECIMAL(10,7) NULL,
  longitude DECIMAL(10,7) NULL,
  status ENUM('active','inactive') NOT NULL DEFAULT 'active',
  metadata LONGTEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_locations_clinic FOREIGN KEY (clinic_id) REFERENCES clinics(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE specialties (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  code VARCHAR(80) NOT NULL UNIQUE,
  name VARCHAR(150) NOT NULL,
  status ENUM('active','inactive') NOT NULL DEFAULT 'active',
  metadata LONGTEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE services (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  clinic_id BIGINT UNSIGNED NOT NULL,
  specialty_id BIGINT UNSIGNED NULL,
  code VARCHAR(80) NULL,
  name VARCHAR(190) NOT NULL,
  service_type ENUM('consultation','procedure','treatment','other') NOT NULL DEFAULT 'other',
  duration_minutes INT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  public_enabled TINYINT(1) NOT NULL DEFAULT 1,
  price_mode ENUM('hidden','listed','custom') NOT NULL DEFAULT 'hidden',
  listed_price DECIMAL(12,2) NULL,
  metadata LONGTEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_services_clinic FOREIGN KEY (clinic_id) REFERENCES clinics(id),
  CONSTRAINT fk_services_specialty FOREIGN KEY (specialty_id) REFERENCES specialties(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE doctors (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  clinic_id BIGINT UNSIGNED NOT NULL,
  primary_location_id BIGINT UNSIGNED NULL,
  full_name VARCHAR(190) NOT NULL,
  license_number VARCHAR(120) NULL,
  specialty_id BIGINT UNSIGNED NULL,
  status ENUM('active','inactive') NOT NULL DEFAULT 'active',
  accepts_new_patients TINYINT(1) NOT NULL DEFAULT 1,
  metadata LONGTEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_doctors_clinic FOREIGN KEY (clinic_id) REFERENCES clinics(id),
  CONSTRAINT fk_doctors_location FOREIGN KEY (primary_location_id) REFERENCES locations(id),
  CONSTRAINT fk_doctors_specialty FOREIGN KEY (specialty_id) REFERENCES specialties(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE doctor_services (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  doctor_id BIGINT UNSIGNED NOT NULL,
  service_id BIGINT UNSIGNED NOT NULL,
  location_id BIGINT UNSIGNED NULL,
  status ENUM('active','inactive') NOT NULL DEFAULT 'active',
  metadata LONGTEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_doctor_service_location (doctor_id, service_id, location_id),
  CONSTRAINT fk_doctor_services_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(id),
  CONSTRAINT fk_doctor_services_service FOREIGN KEY (service_id) REFERENCES services(id),
  CONSTRAINT fk_doctor_services_location FOREIGN KEY (location_id) REFERENCES locations(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE doctor_schedules (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  doctor_id BIGINT UNSIGNED NOT NULL,
  location_id BIGINT UNSIGNED NULL,
  weekday TINYINT NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  status ENUM('active','inactive') NOT NULL DEFAULT 'active',
  metadata LONGTEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_doctor_schedules_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(id),
  CONSTRAINT fk_doctor_schedules_location FOREIGN KEY (location_id) REFERENCES locations(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE accepted_insurances (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  doctor_id BIGINT UNSIGNED NULL,
  clinic_id BIGINT UNSIGNED NOT NULL,
  insurance_name VARCHAR(190) NOT NULL,
  status ENUM('active','inactive') NOT NULL DEFAULT 'active',
  metadata LONGTEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_accepted_insurances_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(id),
  CONSTRAINT fk_accepted_insurances_clinic FOREIGN KEY (clinic_id) REFERENCES clinics(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================
-- 3. CANALES Y COMUNICACIÓN
-- =========================

CREATE TABLE tenant_channels (
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
  CONSTRAINT fk_tenant_channels_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id),
  CONSTRAINT fk_tenant_channels_clinic FOREIGN KEY (clinic_id) REFERENCES clinics(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE contacts (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  uuid CHAR(36) NOT NULL,
  display_name VARCHAR(150) NULL,
  phone VARCHAR(30) NULL,
  email VARCHAR(190) NULL,
  contact_type ENUM('person','company','system') NOT NULL DEFAULT 'person',
  source_channel VARCHAR(60) NULL,
  external_ref VARCHAR(190) NULL,
  metadata LONGTEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_contacts_uuid (uuid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE patient_contacts (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  contact_id BIGINT UNSIGNED NOT NULL,
  clinic_id BIGINT UNSIGNED NULL,
  full_name VARCHAR(190) NOT NULL,
  phone VARCHAR(30) NULL,
  email VARCHAR(190) NULL,
  date_of_birth DATE NULL,
  metadata LONGTEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_patient_contacts_contact FOREIGN KEY (contact_id) REFERENCES contacts(id),
  CONSTRAINT fk_patient_contacts_clinic FOREIGN KEY (clinic_id) REFERENCES clinics(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE conversations (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  uuid CHAR(36) NOT NULL,
  tenant_id BIGINT UNSIGNED NULL,
  clinic_id BIGINT UNSIGNED NULL,
  contact_id BIGINT UNSIGNED NOT NULL,
  channel VARCHAR(60) NOT NULL,
  external_chat_id VARCHAR(190) NULL,
  subject VARCHAR(190) NULL,
  status ENUM('open','pending','closed','archived') NOT NULL DEFAULT 'open',
  started_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  last_message_at TIMESTAMP NULL,
  closed_at TIMESTAMP NULL,
  metadata LONGTEXT NULL,
  UNIQUE KEY uq_conversations_uuid (uuid),
  CONSTRAINT fk_conversations_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id),
  CONSTRAINT fk_conversations_clinic FOREIGN KEY (clinic_id) REFERENCES clinics(id),
  CONSTRAINT fk_conversations_contact FOREIGN KEY (contact_id) REFERENCES contacts(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE messages (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  conversation_id BIGINT UNSIGNED NOT NULL,
  uuid CHAR(36) NOT NULL,
  direction ENUM('inbound','outbound','internal') NOT NULL,
  sender_type ENUM('contact','agent','user','system') NOT NULL,
  sender_ref VARCHAR(120) NULL,
  content LONGTEXT NULL,
  content_type ENUM('text','json','markdown','event') NOT NULL DEFAULT 'text',
  provider_message_id VARCHAR(190) NULL,
  status ENUM('received','queued','sent','failed','processed') NOT NULL DEFAULT 'received',
  metadata LONGTEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_messages_uuid (uuid),
  CONSTRAINT fk_messages_conversation FOREIGN KEY (conversation_id) REFERENCES conversations(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE attachments (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  message_id BIGINT UNSIGNED NOT NULL,
  attachment_type VARCHAR(60) NOT NULL,
  file_name VARCHAR(255) NULL,
  mime_type VARCHAR(120) NULL,
  storage_path VARCHAR(500) NULL,
  file_size_bytes BIGINT UNSIGNED NULL,
  checksum_sha256 CHAR(64) NULL,
  metadata LONGTEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_attachments_message FOREIGN KEY (message_id) REFERENCES messages(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE file_assets (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  uuid CHAR(36) NOT NULL,
  storage_provider VARCHAR(60) NOT NULL,
  storage_path VARCHAR(500) NOT NULL,
  original_name VARCHAR(255) NULL,
  mime_type VARCHAR(120) NULL,
  extension VARCHAR(20) NULL,
  file_size_bytes BIGINT UNSIGNED NULL,
  checksum_sha256 CHAR(64) NULL,
  visibility ENUM('private','internal','public') NOT NULL DEFAULT 'private',
  metadata LONGTEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_file_assets_uuid (uuid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE file_links (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  file_asset_id BIGINT UNSIGNED NOT NULL,
  entity_type VARCHAR(80) NOT NULL,
  entity_id BIGINT UNSIGNED NOT NULL,
  entity_ref VARCHAR(120) NULL,
  role VARCHAR(60) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_file_links_asset FOREIGN KEY (file_asset_id) REFERENCES file_assets(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE task_queue (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  uuid CHAR(36) NOT NULL,
  tenant_id BIGINT UNSIGNED NULL,
  clinic_id BIGINT UNSIGNED NULL,
  conversation_id BIGINT UNSIGNED NULL,
  task_type VARCHAR(100) NOT NULL,
  title VARCHAR(190) NULL,
  payload LONGTEXT NULL,
  priority ENUM('low','normal','high','critical') NOT NULL DEFAULT 'normal',
  status ENUM('queued','running','blocked','done','failed','cancelled') NOT NULL DEFAULT 'queued',
  scheduled_for TIMESTAMP NULL,
  started_at TIMESTAMP NULL,
  completed_at TIMESTAMP NULL,
  error_message TEXT NULL,
  metadata LONGTEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_task_queue_uuid (uuid),
  CONSTRAINT fk_task_queue_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id),
  CONSTRAINT fk_task_queue_clinic FOREIGN KEY (clinic_id) REFERENCES clinics(id),
  CONSTRAINT fk_task_queue_conversation FOREIGN KEY (conversation_id) REFERENCES conversations(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================
-- 4. CITAS Y ATRIBUCIÓN
-- =========================

CREATE TABLE appointments (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  patient_contact_id BIGINT UNSIGNED NOT NULL,
  doctor_id BIGINT UNSIGNED NOT NULL,
  location_id BIGINT UNSIGNED NULL,
  service_id BIGINT UNSIGNED NULL,
  conversation_id BIGINT UNSIGNED NULL,
  appointment_status ENUM('requested','scheduled','confirmed','completed','cancelled','no_show') NOT NULL DEFAULT 'requested',
  scheduled_start DATETIME NULL,
  scheduled_end DATETIME NULL,
  external_booking_ref VARCHAR(190) NULL,
  notes TEXT NULL,
  metadata LONGTEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_appointments_patient FOREIGN KEY (patient_contact_id) REFERENCES patient_contacts(id),
  CONSTRAINT fk_appointments_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(id),
  CONSTRAINT fk_appointments_location FOREIGN KEY (location_id) REFERENCES locations(id),
  CONSTRAINT fk_appointments_service FOREIGN KEY (service_id) REFERENCES services(id),
  CONSTRAINT fk_appointments_conversation FOREIGN KEY (conversation_id) REFERENCES conversations(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE appointment_attribution (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  appointment_id BIGINT UNSIGNED NOT NULL,
  doctor_id BIGINT UNSIGNED NOT NULL,
  attribution_type ENUM('direct','assisted','influenced') NOT NULL,
  agent_code VARCHAR(80) NULL,
  attributed_value DECIMAL(12,2) NULL,
  metadata LONGTEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_appointment_attribution_appointment FOREIGN KEY (appointment_id) REFERENCES appointments(id),
  CONSTRAINT fk_appointment_attribution_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================
-- 5. RBAC Y ADMINISTRACIÓN
-- =========================

CREATE TABLE platform_users (
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

CREATE TABLE roles (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  role_key VARCHAR(100) NOT NULL UNIQUE,
  description TEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tenant_memberships (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  clinic_id BIGINT UNSIGNED NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  role_id BIGINT UNSIGNED NOT NULL,
  status ENUM('active','inactive') NOT NULL DEFAULT 'active',
  metadata LONGTEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_tenant_membership (tenant_id, user_id, role_id, clinic_id),
  CONSTRAINT fk_tenant_memberships_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id),
  CONSTRAINT fk_tenant_memberships_clinic FOREIGN KEY (clinic_id) REFERENCES clinics(id),
  CONSTRAINT fk_tenant_memberships_user FOREIGN KEY (user_id) REFERENCES platform_users(id),
  CONSTRAINT fk_tenant_memberships_role FOREIGN KEY (role_id) REFERENCES roles(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE phone_authorizations (
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

CREATE TABLE audit_logs (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NULL,
  clinic_id BIGINT UNSIGNED NULL,
  actor_type ENUM('user','agent','system','contact') NOT NULL,
  actor_ref VARCHAR(120) NULL,
  target_type VARCHAR(80) NOT NULL,
  target_ref VARCHAR(120) NOT NULL,
  action VARCHAR(120) NOT NULL,
  summary VARCHAR(255) NULL,
  details LONGTEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_audit_logs_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id),
  CONSTRAINT fk_audit_logs_clinic FOREIGN KEY (clinic_id) REFERENCES clinics(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE config_change_log (
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
  CONSTRAINT fk_config_change_log_user FOREIGN KEY (actor_user_id) REFERENCES platform_users(id),
  CONSTRAINT fk_config_change_log_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id),
  CONSTRAINT fk_config_change_log_clinic FOREIGN KEY (clinic_id) REFERENCES clinics(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================
-- 6. PLATAFORMAS, CRAWLING Y RESOLUCIÓN
-- =========================

CREATE TABLE platform_registry (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  platform_code VARCHAR(100) NOT NULL UNIQUE,
  platform_name VARCHAR(150) NOT NULL,
  platform_type ENUM('appointments','medical_records','mixed','other') NOT NULL DEFAULT 'other',
  connector_code VARCHAR(120) NULL,
  vendor_name VARCHAR(150) NULL,
  status ENUM('active','inactive','draft') NOT NULL DEFAULT 'active',
  capabilities LONGTEXT NULL,
  metadata LONGTEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE doctor_platforms (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  doctor_id BIGINT UNSIGNED NOT NULL,
  clinic_id BIGINT UNSIGNED NOT NULL,
  location_id BIGINT UNSIGNED NULL,
  service_id BIGINT UNSIGNED NULL,
  specialty_id BIGINT UNSIGNED NULL,
  platform_registry_id BIGINT UNSIGNED NULL,
  module_type ENUM('appointments','medical_records','other') NOT NULL DEFAULT 'appointments',
  platform_name VARCHAR(150) NOT NULL,
  access_url VARCHAR(255) NULL,
  origin_scope ENUM('doctor','location','clinic') NOT NULL DEFAULT 'doctor',
  resolution_priority INT NOT NULL DEFAULT 100,
  status ENUM('active','inactive') NOT NULL DEFAULT 'active',
  metadata LONGTEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_doctor_platforms_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(id),
  CONSTRAINT fk_doctor_platforms_clinic FOREIGN KEY (clinic_id) REFERENCES clinics(id),
  CONSTRAINT fk_doctor_platforms_location FOREIGN KEY (location_id) REFERENCES locations(id),
  CONSTRAINT fk_doctor_platforms_service FOREIGN KEY (service_id) REFERENCES services(id),
  CONSTRAINT fk_doctor_platforms_specialty FOREIGN KEY (specialty_id) REFERENCES specialties(id),
  CONSTRAINT fk_doctor_platforms_platform_registry FOREIGN KEY (platform_registry_id) REFERENCES platform_registry(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE platform_access_profiles (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  doctor_platform_id BIGINT UNSIGNED NOT NULL,
  doctor_id BIGINT UNSIGNED NULL,
  clinic_id BIGINT UNSIGNED NULL,
  location_id BIGINT UNSIGNED NULL,
  platform_registry_id BIGINT UNSIGNED NULL,
  scope_type ENUM('doctor','location','clinic') NOT NULL DEFAULT 'doctor',
  scope_id BIGINT UNSIGNED NULL,
  profile_code VARCHAR(120) NULL,
  platform_name VARCHAR(150) NOT NULL,
  login_identifier VARCHAR(190) NOT NULL,
  credential_ref VARCHAR(255) NULL,
  login_mode VARCHAR(60) NULL,
  status ENUM('active','inactive','revoked') NOT NULL DEFAULT 'active',
  metadata LONGTEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_platform_access_profiles_doctor_platform FOREIGN KEY (doctor_platform_id) REFERENCES doctor_platforms(id),
  CONSTRAINT fk_platform_access_profiles_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(id),
  CONSTRAINT fk_platform_access_profiles_clinic FOREIGN KEY (clinic_id) REFERENCES clinics(id),
  CONSTRAINT fk_platform_access_profiles_location FOREIGN KEY (location_id) REFERENCES locations(id),
  CONSTRAINT fk_platform_access_profiles_registry FOREIGN KEY (platform_registry_id) REFERENCES platform_registry(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE platform_access_secrets (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  access_profile_id BIGINT UNSIGNED NOT NULL,
  secret_type ENUM('password','token','api_key','other') NOT NULL,
  secret_value TEXT NOT NULL,
  is_encrypted TINYINT(1) NOT NULL DEFAULT 0,
  encryption_version VARCHAR(40) NULL,
  status ENUM('active','inactive','revoked') NOT NULL DEFAULT 'active',
  metadata LONGTEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_platform_access_secrets_profile FOREIGN KEY (access_profile_id) REFERENCES platform_access_profiles(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE platform_sync_sessions (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  access_profile_id BIGINT UNSIGNED NOT NULL,
  doctor_id BIGINT UNSIGNED NULL,
  sync_type ENUM('baseline','metrics_refresh','availability_refresh') NOT NULL,
  session_status ENUM('created','running','completed','failed','expired') NOT NULL DEFAULT 'created',
  started_at DATETIME NULL,
  ended_at DATETIME NULL,
  error_message TEXT NULL,
  metadata LONGTEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_platform_sync_sessions_profile FOREIGN KEY (access_profile_id) REFERENCES platform_access_profiles(id),
  CONSTRAINT fk_platform_sync_sessions_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================
-- 7. BASELINE, IMPACTO, MÉTRICAS Y ROI
-- =========================

CREATE TABLE doctor_baselines (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  doctor_id BIGINT UNSIGNED NOT NULL,
  baseline_date DATE NOT NULL,
  period_type ENUM('weekly','monthly') NOT NULL,
  available_slots INT NULL,
  booked_slots INT NULL,
  occupancy_rate DECIMAL(5,2) NULL,
  source_type ENUM('manual','imported','calculated') NOT NULL DEFAULT 'manual',
  notes TEXT NULL,
  metadata LONGTEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_doctor_baselines_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE doctor_performance_metrics (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  doctor_id BIGINT UNSIGNED NOT NULL,
  metric_date DATE NOT NULL,
  period_type ENUM('daily','weekly','monthly') NOT NULL,
  available_slots INT NULL,
  booked_slots INT NULL,
  occupancy_rate DECIMAL(5,2) NULL,
  new_patients_count INT NULL,
  followup_patients_count INT NULL,
  cancelled_appointments_count INT NULL,
  no_show_count INT NULL,
  rescheduled_count INT NULL,
  agent_assisted_appointments_count INT NULL,
  agent_attributed_appointments_count INT NULL,
  metadata LONGTEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_doctor_performance_metrics_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE doctor_schedule_snapshots (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  doctor_id BIGINT UNSIGNED NOT NULL,
  access_profile_id BIGINT UNSIGNED NULL,
  snapshot_date DATE NOT NULL,
  period_type ENUM('daily','weekly','monthly') NOT NULL,
  available_slots INT NULL,
  booked_slots INT NULL,
  cancelled_slots INT NULL,
  no_show_count INT NULL,
  source_platform VARCHAR(150) NULL,
  metadata LONGTEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_doctor_schedule_snapshots_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(id),
  CONSTRAINT fk_doctor_schedule_snapshots_profile FOREIGN KEY (access_profile_id) REFERENCES platform_access_profiles(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE doctor_goals (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  doctor_id BIGINT UNSIGNED NOT NULL,
  goal_code VARCHAR(100) NULL,
  goal_type VARCHAR(80) NOT NULL,
  goal_name VARCHAR(190) NOT NULL,
  target_value DECIMAL(12,2) NULL,
  current_value DECIMAL(12,2) NULL,
  unit VARCHAR(40) NULL,
  start_date DATE NULL,
  target_date DATE NULL,
  status ENUM('draft','active','paused','achieved','cancelled') NOT NULL DEFAULT 'draft',
  priority ENUM('low','normal','high','critical') NOT NULL DEFAULT 'normal',
  strategy_notes TEXT NULL,
  metadata LONGTEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_doctor_goals_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE doctor_goal_actions (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  doctor_goal_id BIGINT UNSIGNED NOT NULL,
  action_type VARCHAR(80) NOT NULL,
  action_title VARCHAR(190) NOT NULL,
  action_status ENUM('planned','in_progress','done','cancelled') NOT NULL DEFAULT 'planned',
  planned_at DATETIME NULL,
  executed_at DATETIME NULL,
  impact_value DECIMAL(12,2) NULL,
  notes TEXT NULL,
  metadata LONGTEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_doctor_goal_actions_goal FOREIGN KEY (doctor_goal_id) REFERENCES doctor_goals(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================
-- 8. CAPA COGNITIVA
-- =========================

CREATE TABLE tenant_cognitive_providers (
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
  CONSTRAINT fk_tenant_cognitive_providers_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id),
  CONSTRAINT fk_tenant_cognitive_providers_clinic FOREIGN KEY (clinic_id) REFERENCES clinics(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tenant_cognitive_policies (
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
  UNIQUE KEY uq_tenant_cognitive_policy (tenant_id, clinic_id, policy_key),
  CONSTRAINT fk_tenant_cognitive_policies_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id),
  CONSTRAINT fk_tenant_cognitive_policies_clinic FOREIGN KEY (clinic_id) REFERENCES clinics(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE message_resolution_logs (
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
  CONSTRAINT fk_message_resolution_logs_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id),
  CONSTRAINT fk_message_resolution_logs_clinic FOREIGN KEY (clinic_id) REFERENCES clinics(id),
  CONSTRAINT fk_message_resolution_logs_channel FOREIGN KEY (channel_id) REFERENCES tenant_channels(id),
  CONSTRAINT fk_message_resolution_logs_conversation FOREIGN KEY (conversation_id) REFERENCES conversations(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================
-- 9. SETTINGS GENERALES
-- =========================

CREATE TABLE settings (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  scope_type ENUM('global','tenant','clinic','user') NOT NULL,
  scope_ref VARCHAR(120) NOT NULL,
  `key` VARCHAR(150) NOT NULL,
  `value` LONGTEXT NULL,
  is_secret TINYINT(1) NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_settings_scope_key (scope_type, scope_ref, `key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================
-- 10. SEEDS MÍNIMOS
-- =========================

INSERT INTO roles (role_key, description) VALUES
  ('platform_owner', 'Control total de la plataforma'),
  ('platform_admin', 'Administración global operativa'),
  ('clinic_supervisor', 'Responsable de configuración de una clínica'),
  ('clinic_operator', 'Operación acotada de clínica'),
  ('audit_readonly', 'Consulta sin permisos de cambio');

INSERT INTO platform_registry (platform_code, platform_name, platform_type, connector_code, vendor_name, status) VALUES
  ('clinic-web', 'Clinic Web', 'appointments', 'clinicweb', 'Clinic Web', 'active'),
  ('huli-practice', 'Huli Practice', 'mixed', 'huli', 'Huli', 'active');
