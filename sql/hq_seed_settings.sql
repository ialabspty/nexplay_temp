SET NAMES utf8mb4;
SET time_zone = '+00:00';

INSERT INTO settings (scope_type, scope_id, `key`, `value`, is_secret)
VALUES
  ('global', NULL, 'system.mode', JSON_OBJECT('value', 'hybrid'), 0),
  ('global', NULL, 'files.storage_provider', JSON_OBJECT('value', 'filesystem'), 0),
  ('global', NULL, 'db.architecture_version', JSON_OBJECT('value', 'v1'), 0),
  ('global', NULL, 'routing.default_strategy', JSON_OBJECT('value', 'domain-first'), 0),
  ('global', NULL, 'tasks.default_priority', JSON_OBJECT('value', 'normal'), 0),
  ('global', NULL, 'audit.enabled', JSON_OBJECT('value', true), 0),
  ('global', NULL, 'attachments.enabled', JSON_OBJECT('value', true), 0)
ON DUPLICATE KEY UPDATE
  `value` = VALUES(`value`),
  is_secret = VALUES(is_secret);

SHOW TABLES;
