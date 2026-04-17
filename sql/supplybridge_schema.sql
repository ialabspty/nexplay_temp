SET NAMES utf8mb4;
SET time_zone = '+00:00';

CREATE TABLE IF NOT EXISTS suppliers (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  code VARCHAR(80) NOT NULL,
  name VARCHAR(190) NOT NULL,
  supplier_type ENUM('store','merchant','distributor','individual','other') NOT NULL DEFAULT 'store',
  phone VARCHAR(30) DEFAULT NULL,
  email VARCHAR(190) DEFAULT NULL,
  status ENUM('active','inactive') NOT NULL DEFAULT 'active',
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_suppliers_code (code),
  KEY idx_suppliers_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS delivery_addresses (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  contact_id BIGINT UNSIGNED DEFAULT NULL,
  label VARCHAR(120) DEFAULT NULL,
  recipient_name VARCHAR(190) DEFAULT NULL,
  phone VARCHAR(30) DEFAULT NULL,
  country_code VARCHAR(10) DEFAULT NULL,
  city VARCHAR(120) DEFAULT NULL,
  district VARCHAR(120) DEFAULT NULL,
  address_line1 VARCHAR(255) NOT NULL,
  address_line2 VARCHAR(255) DEFAULT NULL,
  reference_text VARCHAR(255) DEFAULT NULL,
  latitude DECIMAL(10,7) DEFAULT NULL,
  longitude DECIMAL(10,7) DEFAULT NULL,
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_delivery_addresses_contact (contact_id),
  CONSTRAINT fk_delivery_addresses_contact FOREIGN KEY (contact_id) REFERENCES contacts(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS orders (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  uuid CHAR(36) NOT NULL,
  conversation_id BIGINT UNSIGNED DEFAULT NULL,
  contact_id BIGINT UNSIGNED DEFAULT NULL,
  delivery_address_id BIGINT UNSIGNED DEFAULT NULL,
  order_source VARCHAR(80) DEFAULT NULL,
  order_status ENUM('draft','quoted','confirmed','purchased','in_transit','delivered','cancelled') NOT NULL DEFAULT 'draft',
  currency_code VARCHAR(10) NOT NULL DEFAULT 'USD',
  subtotal_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
  delivery_fee_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
  service_fee_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
  total_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
  notes TEXT DEFAULT NULL,
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_orders_uuid (uuid),
  KEY idx_orders_conversation (conversation_id),
  KEY idx_orders_contact (contact_id),
  KEY idx_orders_delivery_address (delivery_address_id),
  KEY idx_orders_status (order_status),
  CONSTRAINT fk_orders_conversation FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE SET NULL,
  CONSTRAINT fk_orders_contact FOREIGN KEY (contact_id) REFERENCES contacts(id) ON DELETE SET NULL,
  CONSTRAINT fk_orders_delivery_address FOREIGN KEY (delivery_address_id) REFERENCES delivery_addresses(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS order_items (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  order_id BIGINT UNSIGNED NOT NULL,
  supplier_id BIGINT UNSIGNED DEFAULT NULL,
  item_name VARCHAR(190) NOT NULL,
  quantity DECIMAL(12,3) NOT NULL DEFAULT 1,
  unit_label VARCHAR(30) DEFAULT NULL,
  unit_price DECIMAL(12,2) NOT NULL DEFAULT 0,
  line_total DECIMAL(12,2) NOT NULL DEFAULT 0,
  status ENUM('requested','quoted','confirmed','purchased','unavailable','cancelled') NOT NULL DEFAULT 'requested',
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_order_items_order (order_id),
  KEY idx_order_items_supplier (supplier_id),
  CONSTRAINT fk_order_items_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  CONSTRAINT fk_order_items_supplier FOREIGN KEY (supplier_id) REFERENCES suppliers(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS supplier_quotes (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  order_id BIGINT UNSIGNED NOT NULL,
  supplier_id BIGINT UNSIGNED NOT NULL,
  quote_status ENUM('draft','submitted','accepted','rejected','expired') NOT NULL DEFAULT 'draft',
  quote_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
  currency_code VARCHAR(10) NOT NULL DEFAULT 'USD',
  valid_until DATETIME DEFAULT NULL,
  notes TEXT DEFAULT NULL,
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_supplier_quotes_order (order_id),
  KEY idx_supplier_quotes_supplier (supplier_id),
  CONSTRAINT fk_supplier_quotes_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  CONSTRAINT fk_supplier_quotes_supplier FOREIGN KEY (supplier_id) REFERENCES suppliers(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS purchase_requests (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  order_id BIGINT UNSIGNED NOT NULL,
  supplier_id BIGINT UNSIGNED DEFAULT NULL,
  requested_by VARCHAR(120) DEFAULT NULL,
  request_status ENUM('pending','approved','rejected','completed','cancelled') NOT NULL DEFAULT 'pending',
  approved_at DATETIME DEFAULT NULL,
  completed_at DATETIME DEFAULT NULL,
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_purchase_requests_order (order_id),
  KEY idx_purchase_requests_supplier (supplier_id),
  CONSTRAINT fk_purchase_requests_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  CONSTRAINT fk_purchase_requests_supplier FOREIGN KEY (supplier_id) REFERENCES suppliers(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS deliveries (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  order_id BIGINT UNSIGNED NOT NULL,
  delivery_address_id BIGINT UNSIGNED DEFAULT NULL,
  delivery_status ENUM('pending','assigned','picked_up','in_transit','delivered','failed','cancelled') NOT NULL DEFAULT 'pending',
  driver_name VARCHAR(190) DEFAULT NULL,
  driver_phone VARCHAR(30) DEFAULT NULL,
  picked_up_at DATETIME DEFAULT NULL,
  delivered_at DATETIME DEFAULT NULL,
  proof_file_asset_id BIGINT UNSIGNED DEFAULT NULL,
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_deliveries_order (order_id),
  KEY idx_deliveries_address (delivery_address_id),
  KEY idx_deliveries_proof_asset (proof_file_asset_id),
  CONSTRAINT fk_deliveries_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  CONSTRAINT fk_deliveries_address FOREIGN KEY (delivery_address_id) REFERENCES delivery_addresses(id) ON DELETE SET NULL,
  CONSTRAINT fk_deliveries_proof_asset FOREIGN KEY (proof_file_asset_id) REFERENCES file_assets(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS settlements (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  order_id BIGINT UNSIGNED DEFAULT NULL,
  settlement_type ENUM('customer_charge','supplier_payment','delivery_payment','refund','adjustment') NOT NULL,
  amount DECIMAL(12,2) NOT NULL,
  currency_code VARCHAR(10) NOT NULL DEFAULT 'USD',
  settlement_status ENUM('pending','completed','failed','cancelled') NOT NULL DEFAULT 'pending',
  settled_at DATETIME DEFAULT NULL,
  reference_code VARCHAR(120) DEFAULT NULL,
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_settlements_order (order_id),
  KEY idx_settlements_status (settlement_status),
  CONSTRAINT fk_settlements_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SHOW TABLES;
