SET NAMES utf8mb4;
SET time_zone = '+00:00';

CREATE TABLE IF NOT EXISTS platform_registry (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  platform_code VARCHAR(100) NOT NULL,
  platform_name VARCHAR(150) NOT NULL,
  platform_type ENUM('appointments','medical_records','mixed','other') NOT NULL DEFAULT 'appointments',
  connector_code VARCHAR(120) DEFAULT NULL,
  vendor_name VARCHAR(150) DEFAULT NULL,
  status ENUM('active','inactive','draft') NOT NULL DEFAULT 'active',
  capabilities JSON DEFAULT NULL,
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_platform_registry_code (platform_code),
  UNIQUE KEY uq_platform_registry_name (platform_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE platform_access_profiles
  ADD COLUMN IF NOT EXISTS platform_registry_id BIGINT UNSIGNED DEFAULT NULL AFTER clinic_id,
  ADD KEY idx_platform_access_profiles_platform_registry (platform_registry_id),
  ADD CONSTRAINT fk_platform_access_profiles_platform_registry FOREIGN KEY (platform_registry_id) REFERENCES platform_registry(id) ON DELETE SET NULL;

INSERT INTO platform_registry (
  platform_code, platform_name, platform_type, connector_code, vendor_name, status, capabilities, metadata
)
VALUES
  (
    'clinic-web',
    'Clinic Web',
    'appointments',
    'clinicbridge-clinic-web-v1',
    'Clinic Web',
    'active',
    JSON_OBJECT(
      'supports_baseline', true,
      'supports_metrics_refresh', true,
      'supports_schedule_snapshot', true
    ),
    JSON_OBJECT()
  ),
  (
    'huli-practice',
    'Huli Practice',
    'mixed',
    'clinicbridge-huli-practice-v1',
    'Huli Practice',
    'active',
    JSON_OBJECT(
      'supports_baseline', true,
      'supports_metrics_refresh', true,
      'supports_schedule_snapshot', true
    ),
    JSON_OBJECT()
  )
ON DUPLICATE KEY UPDATE
  platform_name = VALUES(platform_name),
  platform_type = VALUES(platform_type),
  connector_code = VALUES(connector_code),
  vendor_name = VALUES(vendor_name),
  status = VALUES(status),
  capabilities = VALUES(capabilities),
  metadata = VALUES(metadata);

UPDATE platform_access_profiles pap
JOIN platform_registry pr ON (
  (pap.platform_name = 'Clinic Web' AND pr.platform_code = 'clinic-web') OR
  (pap.platform_name = 'Huli Practice' AND pr.platform_code = 'huli-practice')
)
SET pap.platform_registry_id = pr.id
WHERE pap.platform_registry_id IS NULL;

SHOW TABLES;
