SET NAMES utf8mb4;
SET time_zone = '+00:00';

INSERT INTO db_connection_profiles (
  profile_code, core_code, db_engine, host, port, database_name, username, secret_ref, encrypted_password, ssl_mode, is_active, read_only, metadata
)
VALUES
  ('hq-primary', 'hq', 'mysql', 'p3plzcpnl508943.prod.phx3.secureserver.net', 3306, 'hq', 'openclaw_admin', 'godaddy/mysql/hq-primary', NULL, NULL, 1, 0, JSON_OBJECT()),
  ('logisticsbridge-primary', 'LogisticsBridge', 'mysql', 'p3plzcpnl508943.prod.phx3.secureserver.net', 3306, 'LogisticsBridge', 'openclaw_admin', 'godaddy/mysql/logisticsbridge-primary', NULL, NULL, 1, 0, JSON_OBJECT()),
  ('servicebridge-primary', 'ServiceBridge', 'mysql', 'p3plzcpnl508943.prod.phx3.secureserver.net', 3306, 'ServiceBridge', 'openclaw_admin', 'godaddy/mysql/servicebridge-primary', NULL, NULL, 1, 0, JSON_OBJECT()),
  ('edubridge-primary', 'EduBridge', 'mysql', 'p3plzcpnl508943.prod.phx3.secureserver.net', 3306, 'EduBridge', 'openclaw_admin', 'godaddy/mysql/edubridge-primary', NULL, NULL, 1, 0, JSON_OBJECT()),
  ('supplybridge-primary', 'SupplyBridge', 'mysql', 'p3plzcpnl508943.prod.phx3.secureserver.net', 3306, 'SupplyBridge', 'openclaw_admin', 'godaddy/mysql/supplybridge-primary', NULL, NULL, 1, 0, JSON_OBJECT()),
  ('businessopsbridge-primary', 'BusinessOpsBridge', 'mysql', 'p3plzcpnl508943.prod.phx3.secureserver.net', 3306, 'BusinessOpsBridge', 'openclaw_admin', 'godaddy/mysql/businessopsbridge-primary', NULL, NULL, 1, 0, JSON_OBJECT()),
  ('retailbridge-primary', 'RetailBridge', 'mysql', 'p3plzcpnl508943.prod.phx3.secureserver.net', 3306, 'RetailBridge', 'openclaw_admin', 'godaddy/mysql/retailbridge-primary', NULL, NULL, 1, 0, JSON_OBJECT()),
  ('clinicbridge-primary', 'ClinicBridge', 'mysql', 'p3plzcpnl508943.prod.phx3.secureserver.net', 3306, 'ClinicBridge', 'openclaw_admin', 'godaddy/mysql/clinicbridge-primary', NULL, NULL, 1, 0, JSON_OBJECT()),
  ('openclaw-test-primary', 'openclaw_test', 'mysql', 'p3plzcpnl508943.prod.phx3.secureserver.net', 3306, 'openclaw_test', 'openclaw_admin', 'godaddy/mysql/openclaw-test-primary', NULL, NULL, 1, 0, JSON_OBJECT())
ON DUPLICATE KEY UPDATE
  core_code = VALUES(core_code),
  db_engine = VALUES(db_engine),
  host = VALUES(host),
  port = VALUES(port),
  database_name = VALUES(database_name),
  username = VALUES(username),
  secret_ref = VALUES(secret_ref),
  encrypted_password = VALUES(encrypted_password),
  ssl_mode = VALUES(ssl_mode),
  is_active = VALUES(is_active),
  read_only = VALUES(read_only),
  metadata = VALUES(metadata);

INSERT IGNORE INTO db_connection_permissions (profile_id, agent_id, permission_scope, is_active, metadata)
SELECT p.id, a.id, 'admin', 1, JSON_OBJECT()
FROM db_connection_profiles p
JOIN agents a ON a.code = 'hq-internal';

INSERT IGNORE INTO db_connection_permissions (profile_id, agent_id, permission_scope, is_active, metadata)
SELECT p.id, a.id, 'read', 1, JSON_OBJECT()
FROM db_connection_profiles p
JOIN agents a ON a.code = 'hq-internal';

INSERT IGNORE INTO db_connection_permissions (profile_id, agent_id, permission_scope, is_active, metadata)
SELECT p.id, a.id, 'write', 1, JSON_OBJECT()
FROM db_connection_profiles p
JOIN agents a ON a.code = 'hq-internal';

INSERT IGNORE INTO db_connection_permissions (profile_id, agent_id, permission_scope, is_active, metadata)
SELECT p.id, a.id, 'read', 1, JSON_OBJECT()
FROM db_connection_profiles p
JOIN agents a ON (
  (p.core_code = 'LogisticsBridge' AND a.code = 'kargaspty') OR
  (p.core_code = 'ServiceBridge' AND a.code = 'servialpa') OR
  (p.core_code = 'EduBridge' AND a.code = 'edubridge') OR
  (p.core_code = 'SupplyBridge' AND a.code = 'telollevo') OR
  (p.core_code = 'BusinessOpsBridge' AND a.code = 'tunegocioaldia') OR
  (p.core_code = 'RetailBridge' AND a.code = 'jardines-panama') OR
  (p.core_code = 'ClinicBridge' AND a.code = 'dermacos')
);

INSERT IGNORE INTO db_connection_permissions (profile_id, agent_id, permission_scope, is_active, metadata)
SELECT p.id, a.id, 'write', 1, JSON_OBJECT()
FROM db_connection_profiles p
JOIN agents a ON (
  (p.core_code = 'LogisticsBridge' AND a.code = 'kargaspty') OR
  (p.core_code = 'ServiceBridge' AND a.code = 'servialpa') OR
  (p.core_code = 'EduBridge' AND a.code = 'edubridge') OR
  (p.core_code = 'SupplyBridge' AND a.code = 'telollevo') OR
  (p.core_code = 'BusinessOpsBridge' AND a.code = 'tunegocioaldia') OR
  (p.core_code = 'RetailBridge' AND a.code = 'jardines-panama') OR
  (p.core_code = 'ClinicBridge' AND a.code = 'dermacos')
);

SHOW TABLES;
