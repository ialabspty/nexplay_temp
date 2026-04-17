-- Phase 2 seeds and bootstrap data
-- Note: apply per core as needed.

-- HQ reference seeds
-- Suggested manual application in hq:
-- INSERT INTO settings (scope_type, scope_id, `key`, `value`, is_secret)
-- VALUES
-- ('global', NULL, 'system.mode', JSON_OBJECT('value','hybrid'), 0),
-- ('global', NULL, 'files.storage_provider', JSON_OBJECT('value','filesystem'), 0),
-- ('global', NULL, 'db.architecture_version', JSON_OBJECT('value','v1'), 0)
-- ON DUPLICATE KEY UPDATE `value` = VALUES(`value`), is_secret = VALUES(is_secret);

-- EduBridge seed ideas
-- platforms: Huli Practice / Clinic Web are clinic-related, not EduBridge
-- For EduBridge, seed platforms per actual school systems when confirmed.

-- ClinicBridge seed ideas
-- specialties: dermatology
-- services: consulta inicial, consulta de seguimiento, biopsia, crioterapia, etc.

-- ServiceBridge seed ideas
-- service_types according to Servialpa catalog

-- RetailBridge seed ideas
-- tenants like jardines-panama
-- categories for jardinería, conveniencia, ferretería

-- SupplyBridge seed ideas
-- default supplier placeholders only after confirming vendors

-- BusinessOpsBridge seed ideas
-- default settings, movement categories, summary cadence
