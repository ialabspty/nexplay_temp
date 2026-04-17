SET NAMES utf8mb4;
SET time_zone = '+00:00';

INSERT INTO tenants (code, name, brand_name, status, metadata)
VALUES (
  'jardines-panama',
  'Jardines Panamá',
  'Jardines Panamá',
  'active',
  JSON_OBJECT(
    'description', 'Productos de jardinería, ferretería, conveniencia y delivery',
    'public_context', 'jardines-panama-public',
    'ops_context', 'jardines-panama-ops'
  )
)
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  brand_name = VALUES(brand_name),
  status = VALUES(status),
  metadata = VALUES(metadata);

INSERT INTO catalog_categories (tenant_id, code, name, parent_category_id, sort_order, is_active, metadata)
SELECT t.id, seed.code, seed.name, NULL, seed.sort_order, 1, JSON_OBJECT()
FROM tenants t
JOIN (
  SELECT 'jardineria' AS code, 'Jardinería' AS name, 10 AS sort_order
  UNION ALL SELECT 'conveniencia', 'Conveniencia', 20
  UNION ALL SELECT 'ferreteria', 'Ferretería', 30
) AS seed
WHERE t.code = 'jardines-panama'
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  parent_category_id = VALUES(parent_category_id),
  sort_order = VALUES(sort_order),
  is_active = VALUES(is_active),
  metadata = VALUES(metadata);

INSERT INTO delivery_zones (tenant_id, zone_code, zone_name, delivery_fee, is_active, metadata)
SELECT t.id, seed.zone_code, seed.zone_name, seed.delivery_fee, 1, JSON_OBJECT('placeholder', true)
FROM tenants t
JOIN (
  SELECT 'default-panama-city' AS zone_code, 'Ciudad de Panamá (por definir)' AS zone_name, 0.00 AS delivery_fee
) AS seed
WHERE t.code = 'jardines-panama'
ON DUPLICATE KEY UPDATE
  zone_name = VALUES(zone_name),
  delivery_fee = VALUES(delivery_fee),
  is_active = VALUES(is_active),
  metadata = VALUES(metadata);

INSERT INTO price_lists (tenant_id, name, currency_code, is_default, is_active, metadata)
SELECT t.id, 'Lista base', 'USD', 1, 1, JSON_OBJECT()
FROM tenants t
WHERE t.code = 'jardines-panama'
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  currency_code = VALUES(currency_code),
  is_default = VALUES(is_default),
  is_active = VALUES(is_active),
  metadata = VALUES(metadata);

SHOW TABLES;
