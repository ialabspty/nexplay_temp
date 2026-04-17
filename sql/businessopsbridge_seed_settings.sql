SET NAMES utf8mb4;
SET time_zone = '+00:00';

INSERT INTO settings (scope_type, scope_ref, `key`, `value`, is_secret)
VALUES
  ('global', NULL, 'summaries.daily.enabled', JSON_OBJECT('value', true), 0),
  ('global', NULL, 'summaries.daily.default_time', JSON_OBJECT('value', '20:00'), 0),
  ('global', NULL, 'inventory.track_movements', JSON_OBJECT('value', true), 0),
  ('global', NULL, 'cashflow.track_movements', JSON_OBJECT('value', true), 0),
  ('global', NULL, 'tasks.default_priority', JSON_OBJECT('value', 'normal'), 0),
  ('global', NULL, 'currency.default', JSON_OBJECT('value', 'USD'), 0)
ON DUPLICATE KEY UPDATE
  `value` = VALUES(`value`),
  is_secret = VALUES(is_secret);

SHOW TABLES;
