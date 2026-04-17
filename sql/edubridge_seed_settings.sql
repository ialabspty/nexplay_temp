SET NAMES utf8mb4;
SET time_zone = '+00:00';

INSERT INTO settings (scope_type, scope_ref, `key`, `value`, is_secret)
VALUES
  ('global', NULL, 'core.mode', JSON_OBJECT('value', 'crawler'), 0),
  ('global', NULL, 'authorization.require_active_subscription', JSON_OBJECT('value', true), 0),
  ('global', NULL, 'multi_student.enabled', JSON_OBJECT('value', true), 0),
  ('global', NULL, 'school_resolution.mode', JSON_OBJECT('value', 'alias-normalized-confirmed'), 0),
  ('global', NULL, 'billing.student_monthly_usd', JSON_OBJECT('value', 14.99), 0),
  ('global', NULL, 'billing.additional_guardian_monthly_usd', JSON_OBJECT('value', 4.99), 0),
  ('global', NULL, 'billing.additional_student_monthly_usd', JSON_OBJECT('value', 14.99), 0),
  ('global', NULL, 'post_subscription.send_initial_summary', JSON_OBJECT('value', true), 0),
  ('global', NULL, 'post_subscription.delivery_channels', JSON_OBJECT('value', JSON_ARRAY('chat', 'email')), 0),
  ('global', NULL, 'service.block_non_subscribed_students', JSON_OBJECT('value', true), 0)
ON DUPLICATE KEY UPDATE
  `value` = VALUES(`value`),
  is_secret = VALUES(is_secret);

SHOW TABLES;
