SET NAMES utf8mb4;
SET time_zone = '+00:00';

CREATE TABLE IF NOT EXISTS platform_access_profiles (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  doctor_platform_id BIGINT UNSIGNED DEFAULT NULL,
  doctor_id BIGINT UNSIGNED DEFAULT NULL,
  clinic_id BIGINT UNSIGNED DEFAULT NULL,
  profile_code VARCHAR(120) NOT NULL,
  platform_name VARCHAR(150) NOT NULL,
  login_identifier VARCHAR(190) DEFAULT NULL,
  credential_ref VARCHAR(255) DEFAULT NULL,
  login_mode VARCHAR(60) DEFAULT NULL,
  status ENUM('active','inactive','revoked') NOT NULL DEFAULT 'active',
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_platform_access_profiles_code (profile_code),
  KEY idx_platform_access_profiles_doctor (doctor_id),
  KEY idx_platform_access_profiles_platform (platform_name),
  CONSTRAINT fk_platform_access_profiles_doctor_platform FOREIGN KEY (doctor_platform_id) REFERENCES doctor_platforms(id) ON DELETE SET NULL,
  CONSTRAINT fk_platform_access_profiles_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE SET NULL,
  CONSTRAINT fk_platform_access_profiles_clinic FOREIGN KEY (clinic_id) REFERENCES clinics(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS platform_sync_sessions (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  access_profile_id BIGINT UNSIGNED NOT NULL,
  doctor_id BIGINT UNSIGNED DEFAULT NULL,
  sync_type ENUM('baseline','metrics_refresh','availability_refresh') NOT NULL DEFAULT 'baseline',
  session_status ENUM('created','running','completed','failed','expired') NOT NULL DEFAULT 'created',
  started_at DATETIME DEFAULT NULL,
  ended_at DATETIME DEFAULT NULL,
  error_message TEXT DEFAULT NULL,
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_platform_sync_sessions_access_profile (access_profile_id),
  KEY idx_platform_sync_sessions_doctor (doctor_id),
  KEY idx_platform_sync_sessions_status (session_status),
  CONSTRAINT fk_platform_sync_sessions_access_profile FOREIGN KEY (access_profile_id) REFERENCES platform_access_profiles(id) ON DELETE CASCADE,
  CONSTRAINT fk_platform_sync_sessions_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS doctor_schedule_snapshots (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  doctor_id BIGINT UNSIGNED NOT NULL,
  access_profile_id BIGINT UNSIGNED DEFAULT NULL,
  snapshot_date DATE NOT NULL,
  period_type ENUM('daily','weekly','monthly') NOT NULL DEFAULT 'weekly',
  available_slots INT NOT NULL DEFAULT 0,
  booked_slots INT NOT NULL DEFAULT 0,
  cancelled_slots INT NOT NULL DEFAULT 0,
  no_show_count INT NOT NULL DEFAULT 0,
  source_platform VARCHAR(150) DEFAULT NULL,
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_doctor_schedule_snapshots_unique (doctor_id, snapshot_date, period_type),
  KEY idx_doctor_schedule_snapshots_access_profile (access_profile_id),
  CONSTRAINT fk_doctor_schedule_snapshots_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE CASCADE,
  CONSTRAINT fk_doctor_schedule_snapshots_access_profile FOREIGN KEY (access_profile_id) REFERENCES platform_access_profiles(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO platform_access_profiles (
  doctor_platform_id, doctor_id, clinic_id, profile_code, platform_name, login_identifier, credential_ref, login_mode, status, metadata
)
SELECT dp.id,
       d.id,
       c.id,
       'juan-pablo-medina-clinicweb',
       'Clinic Web',
       'jpmedina@ufm.edu',
       'clinicbridge/dermacos/juan-pablo-medina/clinicweb',
       'email_password',
       'active',
       JSON_OBJECT('purpose', 'baseline-and-metrics')
FROM doctors d
JOIN clinics c ON c.id = d.clinic_id AND c.code = 'dermacos-panama'
LEFT JOIN doctor_platforms dp ON dp.doctor_id = d.id AND dp.platform_name = 'Clinic Web' AND dp.module_type = 'appointments'
WHERE d.full_name = 'Juan Pablo Medina'
ON DUPLICATE KEY UPDATE
  doctor_platform_id = VALUES(doctor_platform_id),
  doctor_id = VALUES(doctor_id),
  clinic_id = VALUES(clinic_id),
  platform_name = VALUES(platform_name),
  login_identifier = VALUES(login_identifier),
  credential_ref = VALUES(credential_ref),
  login_mode = VALUES(login_mode),
  status = VALUES(status),
  metadata = VALUES(metadata);

INSERT INTO platform_access_profiles (
  doctor_platform_id, doctor_id, clinic_id, profile_code, platform_name, login_identifier, credential_ref, login_mode, status, metadata
)
SELECT dp.id,
       d.id,
       c.id,
       'liseth-jones-huli',
       'Huli Practice',
       'alejandrajones@ufm.edu',
       'clinicbridge/dermacos/liseth-jones/huli',
       'email_password',
       'active',
       JSON_OBJECT('purpose', 'baseline-and-metrics')
FROM doctors d
JOIN clinics c ON c.id = d.clinic_id AND c.code = 'dermacos-panama'
LEFT JOIN doctor_platforms dp ON dp.doctor_id = d.id AND dp.platform_name = 'Huli Practice' AND dp.module_type = 'appointments'
WHERE d.full_name = 'Liseth Alejandra Jones Ulate'
ON DUPLICATE KEY UPDATE
  doctor_platform_id = VALUES(doctor_platform_id),
  doctor_id = VALUES(doctor_id),
  clinic_id = VALUES(clinic_id),
  platform_name = VALUES(platform_name),
  login_identifier = VALUES(login_identifier),
  credential_ref = VALUES(credential_ref),
  login_mode = VALUES(login_mode),
  status = VALUES(status),
  metadata = VALUES(metadata);

SHOW TABLES;
