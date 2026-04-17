SET NAMES utf8mb4;
SET time_zone = '+00:00';

INSERT INTO platform_access_secrets (
  access_profile_id,
  secret_type,
  secret_value,
  is_encrypted,
  encryption_version,
  status,
  metadata
)
SELECT pap.id,
       'password',
       'JuanyAle2011',
       0,
       NULL,
       'active',
       JSON_OBJECT('source', 'credential_update')
FROM platform_access_profiles pap
WHERE pap.profile_code = 'juan-pablo-medina-clinicweb'
ON DUPLICATE KEY UPDATE
  secret_value = VALUES(secret_value),
  is_encrypted = VALUES(is_encrypted),
  encryption_version = VALUES(encryption_version),
  status = VALUES(status),
  metadata = VALUES(metadata);

SHOW TABLES;
