SET NAMES utf8mb4;
SET time_zone = '+00:00';

-- ClinicBridge
-- Juan Pablo Medina / Clinic Web
-- Baseline semanal de ocupación, ventana histórica de 12 semanas
-- Uso:
-- 1. Ajustar @doctor_id y @access_profile_id si hace falta.
-- 2. Ejecutar los INSERT/UPSERT semanales conforme se capturen semanas reales.
-- 3. Ejecutar la sección de recálculo para consolidar baseline.

-- ============================================================
-- A. Resolver contexto real de Juan Pablo
-- ============================================================

SET @doctor_full_name := 'Juan Pablo Medina';
SET @profile_code := 'juan-pablo-medina-clinicweb';

SET @doctor_id := (
  SELECT d.id
  FROM doctors d
  WHERE d.full_name = @doctor_full_name
  LIMIT 1
);

SET @access_profile_id := (
  SELECT pap.id
  FROM platform_access_profiles pap
  WHERE pap.profile_code = @profile_code
    AND pap.status = 'active'
  LIMIT 1
);

SELECT @doctor_id AS doctor_id, @access_profile_id AS access_profile_id;

-- ============================================================
-- B. Template de registro semanal en snapshots
-- Repetir una vez por cada semana capturada
-- ============================================================
-- Parámetros esperados por semana:
-- @snapshot_date          -> fecha de referencia de la semana (recomendado: lunes)
-- @available_slots        -> slots ofertados de la semana
-- @booked_slots           -> slots ocupados de la semana
-- @cancelled_slots        -> canceladas visibles
-- @no_show_count          -> no-shows visibles
-- @week_status            -> valid_normal | valid_atypical | invalid
-- @exclusion_reason       -> null o motivo
-- @extraction_confidence  -> 0 a 100
-- @sync_type              -> baseline

-- Ejemplo de carga semanal:
-- SET @snapshot_date := '2026-04-06';
-- SET @available_slots := 18;
-- SET @booked_slots := 18;
-- SET @cancelled_slots := 0;
-- SET @no_show_count := 0;
-- SET @week_status := 'valid_normal';
-- SET @exclusion_reason := NULL;
-- SET @extraction_confidence := 95.00;
-- SET @sync_type := 'baseline';

-- INSERT INTO doctor_schedule_snapshots (
--   doctor_id,
--   access_profile_id,
--   snapshot_date,
--   period_type,
--   available_slots,
--   booked_slots,
--   cancelled_slots,
--   no_show_count,
--   source_platform,
--   metadata
-- ) VALUES (
--   @doctor_id,
--   @access_profile_id,
--   @snapshot_date,
--   'weekly',
--   @available_slots,
--   @booked_slots,
--   @cancelled_slots,
--   @no_show_count,
--   'Clinic Web',
--   JSON_OBJECT(
--     'sync_type', @sync_type,
--     'week_status', @week_status,
--     'exclusion_reason', @exclusion_reason,
--     'extraction_confidence', @extraction_confidence,
--     'window_weeks', 12,
--     'doctor', @doctor_full_name,
--     'profile_code', @profile_code
--   )
-- )
-- ON DUPLICATE KEY UPDATE
--   available_slots = VALUES(available_slots),
--   booked_slots = VALUES(booked_slots),
--   cancelled_slots = VALUES(cancelled_slots),
--   no_show_count = VALUES(no_show_count),
--   source_platform = VALUES(source_platform),
--   metadata = VALUES(metadata);

-- ============================================================
-- C. Sincronizar snapshots semanales a performance metrics
-- ============================================================

INSERT INTO doctor_performance_metrics (
  doctor_id,
  metric_date,
  period_type,
  available_slots,
  booked_slots,
  occupancy_rate,
  cancelled_appointments_count,
  no_show_count,
  agent_assisted_appointments_count,
  agent_attributed_appointments_count,
  metadata
)
SELECT
  dss.doctor_id,
  dss.snapshot_date AS metric_date,
  'weekly' AS period_type,
  dss.available_slots,
  dss.booked_slots,
  ROUND(
    CASE
      WHEN dss.available_slots > 0 THEN (dss.booked_slots / dss.available_slots) * 100
      ELSE 0
    END,
  2) AS occupancy_rate,
  dss.cancelled_slots,
  dss.no_show_count,
  0 AS agent_assisted_appointments_count,
  0 AS agent_attributed_appointments_count,
  JSON_OBJECT(
    'source', 'Clinic Web',
    'week_status', COALESCE(JSON_UNQUOTE(JSON_EXTRACT(dss.metadata, '$.week_status')), 'valid_normal'),
    'exclusion_reason', JSON_UNQUOTE(JSON_EXTRACT(dss.metadata, '$.exclusion_reason')),
    'extraction_confidence', JSON_EXTRACT(dss.metadata, '$.extraction_confidence'),
    'window_weeks', 12,
    'method', 'weekly_snapshot_sync'
  ) AS metadata
FROM doctor_schedule_snapshots dss
WHERE dss.doctor_id = @doctor_id
  AND dss.period_type = 'weekly'
  AND dss.snapshot_date >= DATE_SUB(CURDATE(), INTERVAL 12 WEEK)
ON DUPLICATE KEY UPDATE
  available_slots = VALUES(available_slots),
  booked_slots = VALUES(booked_slots),
  occupancy_rate = VALUES(occupancy_rate),
  cancelled_appointments_count = VALUES(cancelled_appointments_count),
  no_show_count = VALUES(no_show_count),
  agent_assisted_appointments_count = VALUES(agent_assisted_appointments_count),
  agent_attributed_appointments_count = VALUES(agent_attributed_appointments_count),
  metadata = VALUES(metadata);

-- ============================================================
-- D. Dataset base de semanas válidas para baseline central
-- ============================================================

DROP TEMPORARY TABLE IF EXISTS tmp_jpm_12w_valid_weeks;
CREATE TEMPORARY TABLE tmp_jpm_12w_valid_weeks AS
SELECT
  dss.doctor_id,
  dss.snapshot_date,
  dss.available_slots,
  dss.booked_slots,
  dss.cancelled_slots,
  dss.no_show_count,
  ROUND(
    CASE
      WHEN dss.available_slots > 0 THEN (dss.booked_slots / dss.available_slots) * 100
      ELSE 0
    END,
  2) AS occupancy_rate,
  COALESCE(JSON_UNQUOTE(JSON_EXTRACT(dss.metadata, '$.week_status')), 'valid_normal') AS week_status,
  JSON_UNQUOTE(JSON_EXTRACT(dss.metadata, '$.exclusion_reason')) AS exclusion_reason,
  CAST(JSON_UNQUOTE(JSON_EXTRACT(dss.metadata, '$.extraction_confidence')) AS DECIMAL(5,2)) AS extraction_confidence
FROM doctor_schedule_snapshots dss
WHERE dss.doctor_id = @doctor_id
  AND dss.period_type = 'weekly'
  AND dss.snapshot_date >= DATE_SUB(CURDATE(), INTERVAL 12 WEEK)
  AND COALESCE(JSON_UNQUOTE(JSON_EXTRACT(dss.metadata, '$.week_status')), 'valid_normal') = 'valid_normal';

SELECT *
FROM tmp_jpm_12w_valid_weeks
ORDER BY snapshot_date DESC;

-- ============================================================
-- E. Resumen estadístico de 12 semanas válidas
-- ============================================================

DROP TEMPORARY TABLE IF EXISTS tmp_jpm_12w_summary;
CREATE TEMPORARY TABLE tmp_jpm_12w_summary AS
SELECT
  doctor_id,
  COUNT(*) AS valid_weeks_count,
  ROUND(AVG(available_slots), 2) AS available_slots_avg,
  ROUND(AVG(booked_slots), 2) AS booked_slots_avg,
  ROUND(AVG(occupancy_rate), 2) AS occupancy_avg,
  ROUND(MIN(occupancy_rate), 2) AS occupancy_min,
  ROUND(MAX(occupancy_rate), 2) AS occupancy_max,
  ROUND(STDDEV_SAMP(occupancy_rate), 2) AS occupancy_stddev
FROM tmp_jpm_12w_valid_weeks
GROUP BY doctor_id;

SELECT * FROM tmp_jpm_12w_summary;

-- ============================================================
-- F. Mediana de ocupación, baseline central
-- ============================================================

DROP TEMPORARY TABLE IF EXISTS tmp_jpm_12w_median;
CREATE TEMPORARY TABLE tmp_jpm_12w_median AS
WITH ordered AS (
  SELECT
    doctor_id,
    occupancy_rate,
    ROW_NUMBER() OVER (
      PARTITION BY doctor_id
      ORDER BY occupancy_rate
    ) AS rn,
    COUNT(*) OVER (PARTITION BY doctor_id) AS cnt
  FROM tmp_jpm_12w_valid_weeks
)
SELECT
  doctor_id,
  ROUND(AVG(occupancy_rate), 2) AS occupancy_median
FROM ordered
WHERE rn IN (FLOOR((cnt + 1) / 2), FLOOR((cnt + 2) / 2))
GROUP BY doctor_id;

SELECT * FROM tmp_jpm_12w_median;

-- ============================================================
-- G. Conteo de semanas atípicas e inválidas
-- ============================================================

DROP TEMPORARY TABLE IF EXISTS tmp_jpm_12w_status_counts;
CREATE TEMPORARY TABLE tmp_jpm_12w_status_counts AS
SELECT
  dss.doctor_id,
  SUM(CASE WHEN COALESCE(JSON_UNQUOTE(JSON_EXTRACT(dss.metadata, '$.week_status')), 'valid_normal') = 'valid_atypical' THEN 1 ELSE 0 END) AS atypical_weeks_count,
  SUM(CASE WHEN COALESCE(JSON_UNQUOTE(JSON_EXTRACT(dss.metadata, '$.week_status')), 'valid_normal') = 'invalid' THEN 1 ELSE 0 END) AS invalid_weeks_count
FROM doctor_schedule_snapshots dss
WHERE dss.doctor_id = @doctor_id
  AND dss.period_type = 'weekly'
  AND dss.snapshot_date >= DATE_SUB(CURDATE(), INTERVAL 12 WEEK)
GROUP BY dss.doctor_id;

SELECT * FROM tmp_jpm_12w_status_counts;

-- ============================================================
-- H. Persistir baseline consolidado en doctor_baselines
-- ============================================================

INSERT INTO doctor_baselines (
  doctor_id,
  baseline_date,
  period_type,
  available_slots,
  booked_slots,
  occupancy_rate,
  source_type,
  notes,
  metadata
)
SELECT
  s.doctor_id,
  CURDATE() AS baseline_date,
  'weekly' AS period_type,
  CAST(s.available_slots_avg AS UNSIGNED) AS available_slots,
  CAST(s.booked_slots_avg AS UNSIGNED) AS booked_slots,
  m.occupancy_median AS occupancy_rate,
  'calculated' AS source_type,
  'Baseline semanal 12 semanas, Juan Pablo, Clinic Web' AS notes,
  JSON_OBJECT(
    'source', 'Clinic Web',
    'doctor', @doctor_full_name,
    'profile_code', @profile_code,
    'window_weeks', 12,
    'valid_weeks_count', s.valid_weeks_count,
    'atypical_weeks_count', COALESCE(c.atypical_weeks_count, 0),
    'invalid_weeks_count', COALESCE(c.invalid_weeks_count, 0),
    'baseline_status', CASE WHEN s.valid_weeks_count >= 8 THEN 'credible' ELSE 'provisional' END,
    'occupancy_avg', s.occupancy_avg,
    'occupancy_stddev', s.occupancy_stddev,
    'occupancy_min', s.occupancy_min,
    'occupancy_max', s.occupancy_max,
    'occupancy_median', m.occupancy_median,
    'method', 'weekly_12w_median'
  ) AS metadata
FROM tmp_jpm_12w_summary s
JOIN tmp_jpm_12w_median m ON m.doctor_id = s.doctor_id
LEFT JOIN tmp_jpm_12w_status_counts c ON c.doctor_id = s.doctor_id
ON DUPLICATE KEY UPDATE
  available_slots = VALUES(available_slots),
  booked_slots = VALUES(booked_slots),
  occupancy_rate = VALUES(occupancy_rate),
  source_type = VALUES(source_type),
  notes = VALUES(notes),
  metadata = VALUES(metadata);

-- ============================================================
-- I. Actualizar goal activo de ocupación, si existe
-- ============================================================

UPDATE doctor_goals dg
JOIN tmp_jpm_12w_median m ON m.doctor_id = dg.doctor_id
SET dg.current_value = m.occupancy_median,
    dg.status = CASE
      WHEN dg.target_value IS NOT NULL AND m.occupancy_median >= dg.target_value THEN 'achieved'
      ELSE dg.status
    END,
    dg.updated_at = CURRENT_TIMESTAMP
WHERE dg.doctor_id = @doctor_id
  AND dg.goal_type = 'occupancy_rate'
  AND dg.status IN ('active', 'paused');

-- ============================================================
-- J. Reporte final listo para revisión
-- ============================================================

SELECT
  db.doctor_id,
  d.full_name,
  db.baseline_date,
  db.period_type,
  db.available_slots,
  db.booked_slots,
  db.occupancy_rate AS baseline_occupancy_median,
  JSON_UNQUOTE(JSON_EXTRACT(db.metadata, '$.baseline_status')) AS baseline_status,
  JSON_EXTRACT(db.metadata, '$.valid_weeks_count') AS valid_weeks_count,
  JSON_EXTRACT(db.metadata, '$.atypical_weeks_count') AS atypical_weeks_count,
  JSON_EXTRACT(db.metadata, '$.invalid_weeks_count') AS invalid_weeks_count,
  JSON_EXTRACT(db.metadata, '$.occupancy_avg') AS occupancy_avg,
  JSON_EXTRACT(db.metadata, '$.occupancy_stddev') AS occupancy_stddev,
  JSON_EXTRACT(db.metadata, '$.occupancy_min') AS occupancy_min,
  JSON_EXTRACT(db.metadata, '$.occupancy_max') AS occupancy_max,
  JSON_EXTRACT(db.metadata, '$.occupancy_median') AS occupancy_median
FROM doctor_baselines db
JOIN doctors d ON d.id = db.doctor_id
WHERE db.doctor_id = @doctor_id
  AND db.period_type = 'weekly'
ORDER BY db.baseline_date DESC
LIMIT 5;
