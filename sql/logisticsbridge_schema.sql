SET NAMES utf8mb4;
SET time_zone = '+00:00';

CREATE TABLE IF NOT EXISTS warehouses (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  code VARCHAR(80) NOT NULL,
  name VARCHAR(190) NOT NULL,
  country_code VARCHAR(10) DEFAULT NULL,
  city VARCHAR(120) DEFAULT NULL,
  address_line1 VARCHAR(255) DEFAULT NULL,
  status ENUM('active','inactive') NOT NULL DEFAULT 'active',
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_warehouses_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS lockers (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  warehouse_id BIGINT UNSIGNED DEFAULT NULL,
  contact_id BIGINT UNSIGNED DEFAULT NULL,
  locker_code VARCHAR(80) NOT NULL,
  label VARCHAR(120) DEFAULT NULL,
  status ENUM('active','inactive','blocked') NOT NULL DEFAULT 'active',
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_lockers_code (locker_code),
  KEY idx_lockers_warehouse (warehouse_id),
  KEY idx_lockers_contact (contact_id),
  CONSTRAINT fk_lockers_warehouse FOREIGN KEY (warehouse_id) REFERENCES warehouses(id) ON DELETE SET NULL,
  CONSTRAINT fk_lockers_contact FOREIGN KEY (contact_id) REFERENCES contacts(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS shipments (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  uuid CHAR(36) NOT NULL,
  contact_id BIGINT UNSIGNED DEFAULT NULL,
  locker_id BIGINT UNSIGNED DEFAULT NULL,
  origin_warehouse_id BIGINT UNSIGNED DEFAULT NULL,
  destination_warehouse_id BIGINT UNSIGNED DEFAULT NULL,
  tracking_number VARCHAR(120) DEFAULT NULL,
  carrier_name VARCHAR(120) DEFAULT NULL,
  shipment_status ENUM('pre_alert','received','processing','in_transit','out_for_delivery','delivered','cancelled') NOT NULL DEFAULT 'pre_alert',
  weight_kg DECIMAL(10,3) DEFAULT NULL,
  declared_value DECIMAL(12,2) DEFAULT NULL,
  currency_code VARCHAR(10) DEFAULT 'USD',
  received_at DATETIME DEFAULT NULL,
  delivered_at DATETIME DEFAULT NULL,
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_shipments_uuid (uuid),
  KEY idx_shipments_contact (contact_id),
  KEY idx_shipments_locker (locker_id),
  KEY idx_shipments_tracking (tracking_number),
  KEY idx_shipments_status (shipment_status),
  CONSTRAINT fk_shipments_contact FOREIGN KEY (contact_id) REFERENCES contacts(id) ON DELETE SET NULL,
  CONSTRAINT fk_shipments_locker FOREIGN KEY (locker_id) REFERENCES lockers(id) ON DELETE SET NULL,
  CONSTRAINT fk_shipments_origin_warehouse FOREIGN KEY (origin_warehouse_id) REFERENCES warehouses(id) ON DELETE SET NULL,
  CONSTRAINT fk_shipments_destination_warehouse FOREIGN KEY (destination_warehouse_id) REFERENCES warehouses(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS tracking_events (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  shipment_id BIGINT UNSIGNED NOT NULL,
  event_code VARCHAR(80) DEFAULT NULL,
  event_label VARCHAR(190) NOT NULL,
  event_timestamp DATETIME NOT NULL,
  location_text VARCHAR(190) DEFAULT NULL,
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_tracking_events_shipment (shipment_id),
  KEY idx_tracking_events_timestamp (event_timestamp),
  CONSTRAINT fk_tracking_events_shipment FOREIGN KEY (shipment_id) REFERENCES shipments(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS delivery_routes (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  route_code VARCHAR(80) NOT NULL,
  route_date DATE NOT NULL,
  driver_name VARCHAR(190) DEFAULT NULL,
  vehicle_label VARCHAR(120) DEFAULT NULL,
  route_status ENUM('planned','in_progress','completed','cancelled') NOT NULL DEFAULT 'planned',
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_delivery_routes_code_date (route_code, route_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS delivery_attempts (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  shipment_id BIGINT UNSIGNED NOT NULL,
  delivery_route_id BIGINT UNSIGNED DEFAULT NULL,
  attempt_status ENUM('scheduled','successful','failed','rescheduled') NOT NULL DEFAULT 'scheduled',
  attempted_at DATETIME DEFAULT NULL,
  proof_file_asset_id BIGINT UNSIGNED DEFAULT NULL,
  notes TEXT DEFAULT NULL,
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_delivery_attempts_shipment (shipment_id),
  KEY idx_delivery_attempts_route (delivery_route_id),
  KEY idx_delivery_attempts_proof (proof_file_asset_id),
  CONSTRAINT fk_delivery_attempts_shipment FOREIGN KEY (shipment_id) REFERENCES shipments(id) ON DELETE CASCADE,
  CONSTRAINT fk_delivery_attempts_route FOREIGN KEY (delivery_route_id) REFERENCES delivery_routes(id) ON DELETE SET NULL,
  CONSTRAINT fk_delivery_attempts_proof FOREIGN KEY (proof_file_asset_id) REFERENCES file_assets(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS carrier_integrations (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  carrier_code VARCHAR(80) NOT NULL,
  carrier_name VARCHAR(190) NOT NULL,
  integration_type VARCHAR(80) DEFAULT NULL,
  status ENUM('active','inactive') NOT NULL DEFAULT 'active',
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_carrier_integrations_code (carrier_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SHOW TABLES;
