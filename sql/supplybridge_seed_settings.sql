SET NAMES utf8mb4;
SET time_zone = '+00:00';

INSERT INTO settings (scope_type, scope_ref, `key`, `value`, is_secret)
VALUES
  ('global', NULL, 'orders.require_delivery_address', JSON_OBJECT('value', true), 0),
  ('global', NULL, 'quotes.enabled', JSON_OBJECT('value', true), 0),
  ('global', NULL, 'purchase_requests.enabled', JSON_OBJECT('value', true), 0),
  ('global', NULL, 'deliveries.require_proof', JSON_OBJECT('value', false), 0),
  ('global', NULL, 'currency.default', JSON_OBJECT('value', 'USD'), 0),
  ('global', NULL, 'orders.default_status', JSON_OBJECT('value', 'draft'), 0)
ON DUPLICATE KEY UPDATE
  `value` = VALUES(`value`),
  is_secret = VALUES(is_secret);

SHOW TABLES;
