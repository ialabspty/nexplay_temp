SET NAMES utf8mb4;
SET time_zone = '+00:00';

INSERT INTO settings (scope_type, scope_ref, `key`, `value`, is_secret)
VALUES
  ('global', NULL, 'shipments.track_events_enabled', JSON_OBJECT('value', true), 0),
  ('global', NULL, 'deliveries.require_proof', JSON_OBJECT('value', false), 0),
  ('global', NULL, 'lockers.enabled', JSON_OBJECT('value', true), 0),
  ('global', NULL, 'currency.default', JSON_OBJECT('value', 'USD'), 0),
  ('global', NULL, 'shipments.default_status', JSON_OBJECT('value', 'pre_alert'), 0)
ON DUPLICATE KEY UPDATE
  `value` = VALUES(`value`),
  is_secret = VALUES(is_secret);

SHOW TABLES;
