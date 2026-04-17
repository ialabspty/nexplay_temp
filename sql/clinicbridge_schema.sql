SET NAMES utf8mb4;
SET time_zone = '+00:00';

CREATE TABLE IF NOT EXISTS clinics (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  code VARCHAR(80) NOT NULL,
  name VARCHAR(190) NOT NULL,
  legal_name VARCHAR(190) DEFAULT NULL,
  status ENUM('active','inactive') NOT NULL DEFAULT 'active',
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_clinics_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS locations (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  clinic_id BIGINT UNSIGNED NOT NULL,
  code VARCHAR(80) NOT NULL,
  name VARCHAR(190) NOT NULL,
  address_line1 VARCHAR(255) DEFAULT NULL,
  city VARCHAR(120) DEFAULT NULL,
  country_code VARCHAR(10) DEFAULT NULL,
  phone VARCHAR(30) DEFAULT NULL,
  status ENUM('active','inactive') NOT NULL DEFAULT 'active',
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_locations_clinic_code (clinic_id, code),
  CONSTRAINT fk_locations_clinic FOREIGN KEY (clinic_id) REFERENCES clinics(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS specialties (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  code VARCHAR(80) NOT NULL,
  name VARCHAR(150) NOT NULL,
  status ENUM('active','inactive') NOT NULL DEFAULT 'active',
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_specialties_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS services (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  clinic_id BIGINT UNSIGNED DEFAULT NULL,
  specialty_id BIGINT UNSIGNED DEFAULT NULL,
  code VARCHAR(80) NOT NULL,
  name VARCHAR(190) NOT NULL,
  service_type ENUM('consultation','procedure','treatment','other') NOT NULL DEFAULT 'consultation',
  duration_minutes INT DEFAULT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_services_code (code),
  KEY idx_services_clinic (clinic_id),
  KEY idx_services_specialty (specialty_id),
  CONSTRAINT fk_services_clinic FOREIGN KEY (clinic_id) REFERENCES clinics(id) ON DELETE SET NULL,
  CONSTRAINT fk_services_specialty FOREIGN KEY (specialty_id) REFERENCES specialties(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS doctors (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  clinic_id BIGINT UNSIGNED DEFAULT NULL,
  primary_location_id BIGINT UNSIGNED DEFAULT NULL,
  full_name VARCHAR(190) NOT NULL,
  license_number VARCHAR(120) DEFAULT NULL,
  status ENUM('active','inactive') NOT NULL DEFAULT 'active',
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_doctors_clinic (clinic_id),
  KEY idx_doctors_location (primary_location_id),
  KEY idx_doctors_full_name (full_name),
  CONSTRAINT fk_doctors_clinic FOREIGN KEY (clinic_id) REFERENCES clinics(id) ON DELETE SET NULL,
  CONSTRAINT fk_doctors_location FOREIGN KEY (primary_location_id) REFERENCES locations(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS doctor_services (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  doctor_id BIGINT UNSIGNED NOT NULL,
  service_id BIGINT UNSIGNED NOT NULL,
  location_id BIGINT UNSIGNED DEFAULT NULL,
  status ENUM('active','inactive') NOT NULL DEFAULT 'active',
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_doctor_services_unique (doctor_id, service_id, location_id),
  KEY idx_doctor_services_service (service_id),
  CONSTRAINT fk_doctor_services_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE CASCADE,
  CONSTRAINT fk_doctor_services_service FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE,
  CONSTRAINT fk_doctor_services_location FOREIGN KEY (location_id) REFERENCES locations(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS doctor_platforms (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  doctor_id BIGINT UNSIGNED DEFAULT NULL,
  clinic_id BIGINT UNSIGNED DEFAULT NULL,
  location_id BIGINT UNSIGNED DEFAULT NULL,
  service_id BIGINT UNSIGNED DEFAULT NULL,
  module_type ENUM('appointments','medical_records','other') NOT NULL DEFAULT 'appointments',
  platform_name VARCHAR(150) NOT NULL,
  access_url VARCHAR(255) DEFAULT NULL,
  resolution_priority INT NOT NULL DEFAULT 100,
  status ENUM('active','inactive') NOT NULL DEFAULT 'active',
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_doctor_platforms_doctor (doctor_id),
  KEY idx_doctor_platforms_clinic (clinic_id),
  KEY idx_doctor_platforms_location (location_id),
  KEY idx_doctor_platforms_service (service_id),
  CONSTRAINT fk_doctor_platforms_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE SET NULL,
  CONSTRAINT fk_doctor_platforms_clinic FOREIGN KEY (clinic_id) REFERENCES clinics(id) ON DELETE SET NULL,
  CONSTRAINT fk_doctor_platforms_location FOREIGN KEY (location_id) REFERENCES locations(id) ON DELETE SET NULL,
  CONSTRAINT fk_doctor_platforms_service FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS patient_contacts (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  contact_id BIGINT UNSIGNED DEFAULT NULL,
  full_name VARCHAR(190) NOT NULL,
  phone VARCHAR(30) DEFAULT NULL,
  email VARCHAR(190) DEFAULT NULL,
  date_of_birth DATE DEFAULT NULL,
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_patient_contacts_contact (contact_id),
  KEY idx_patient_contacts_phone (phone),
  CONSTRAINT fk_patient_contacts_contact FOREIGN KEY (contact_id) REFERENCES contacts(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS appointments (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  patient_contact_id BIGINT UNSIGNED DEFAULT NULL,
  doctor_id BIGINT UNSIGNED DEFAULT NULL,
  location_id BIGINT UNSIGNED DEFAULT NULL,
  service_id BIGINT UNSIGNED DEFAULT NULL,
  conversation_id BIGINT UNSIGNED DEFAULT NULL,
  appointment_status ENUM('requested','scheduled','confirmed','completed','cancelled','no_show') NOT NULL DEFAULT 'requested',
  scheduled_start DATETIME DEFAULT NULL,
  scheduled_end DATETIME DEFAULT NULL,
  external_booking_ref VARCHAR(190) DEFAULT NULL,
  notes TEXT DEFAULT NULL,
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_appointments_patient (patient_contact_id),
  KEY idx_appointments_doctor (doctor_id),
  KEY idx_appointments_location (location_id),
  KEY idx_appointments_service (service_id),
  KEY idx_appointments_conversation (conversation_id),
  CONSTRAINT fk_appointments_patient FOREIGN KEY (patient_contact_id) REFERENCES patient_contacts(id) ON DELETE SET NULL,
  CONSTRAINT fk_appointments_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE SET NULL,
  CONSTRAINT fk_appointments_location FOREIGN KEY (location_id) REFERENCES locations(id) ON DELETE SET NULL,
  CONSTRAINT fk_appointments_service FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE SET NULL,
  CONSTRAINT fk_appointments_conversation FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS accepted_insurances (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  doctor_id BIGINT UNSIGNED DEFAULT NULL,
  clinic_id BIGINT UNSIGNED DEFAULT NULL,
  insurance_name VARCHAR(190) NOT NULL,
  status ENUM('active','inactive') NOT NULL DEFAULT 'active',
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_accepted_insurances_doctor (doctor_id),
  KEY idx_accepted_insurances_clinic (clinic_id),
  CONSTRAINT fk_accepted_insurances_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE SET NULL,
  CONSTRAINT fk_accepted_insurances_clinic FOREIGN KEY (clinic_id) REFERENCES clinics(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SHOW TABLES;
