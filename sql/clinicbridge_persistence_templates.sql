-- ClinicBridge persistence templates
-- Adapt parameters before execution.

-- 1. Create sync session
INSERT INTO platform_sync_sessions (
  access_profile_id,
  doctor_id,
  sync_type,
  session_status,
  started_at,
  metadata
) VALUES (
  :access_profile_id,
  :doctor_id,
  :sync_type,
  'running',
  NOW(),
  JSON_OBJECT('source', :source_platform)
);

-- 2. Insert schedule snapshot
INSERT INTO doctor_schedule_snapshots (
  doctor_id,
  access_profile_id,
  snapshot_date,
  period_type,
  available_slots,
  booked_slots,
  cancelled_slots,
  no_show_count,
  source_platform,
  metadata
) VALUES (
  :doctor_id,
  :access_profile_id,
  :snapshot_date,
  :period_type,
  :available_slots,
  :booked_slots,
  :cancelled_slots,
  :no_show_count,
  :source_platform,
  JSON_OBJECT('sync_type', :sync_type)
)
ON DUPLICATE KEY UPDATE
  available_slots = VALUES(available_slots),
  booked_slots = VALUES(booked_slots),
  cancelled_slots = VALUES(cancelled_slots),
  no_show_count = VALUES(no_show_count),
  source_platform = VALUES(source_platform),
  metadata = VALUES(metadata);

-- 3. Upsert performance metric
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
) VALUES (
  :doctor_id,
  :metric_date,
  :period_type,
  :available_slots,
  :booked_slots,
  :occupancy_rate,
  :cancelled_slots,
  :no_show_count,
  :agent_assisted_appointments_count,
  :agent_attributed_appointments_count,
  JSON_OBJECT('source', :source_platform)
)
ON DUPLICATE KEY UPDATE
  available_slots = VALUES(available_slots),
  booked_slots = VALUES(booked_slots),
  occupancy_rate = VALUES(occupancy_rate),
  cancelled_appointments_count = VALUES(cancelled_appointments_count),
  no_show_count = VALUES(no_show_count),
  agent_assisted_appointments_count = VALUES(agent_assisted_appointments_count),
  agent_attributed_appointments_count = VALUES(agent_attributed_appointments_count),
  metadata = VALUES(metadata);

-- 4. Insert baseline if first time
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
  :doctor_id,
  :baseline_date,
  :period_type,
  :available_slots,
  :booked_slots,
  :occupancy_rate,
  'calculated',
  :baseline_notes,
  JSON_OBJECT('source', :source_platform)
WHERE NOT EXISTS (
  SELECT 1 FROM doctor_baselines
  WHERE doctor_id = :doctor_id
    AND baseline_date = :baseline_date
    AND period_type = :period_type
);

-- 5. Update active occupancy goal
UPDATE doctor_goals
SET current_value = :occupancy_rate,
    status = CASE
      WHEN target_value IS NOT NULL AND :occupancy_rate >= target_value THEN 'achieved'
      ELSE status
    END,
    updated_at = CURRENT_TIMESTAMP
WHERE doctor_id = :doctor_id
  AND goal_type = 'occupancy_rate'
  AND status IN ('active', 'paused');

-- 6. Close sync session as completed
UPDATE platform_sync_sessions
SET session_status = 'completed',
    ended_at = NOW(),
    updated_at = CURRENT_TIMESTAMP
WHERE id = :sync_session_id;

-- 7. Close sync session as failed
UPDATE platform_sync_sessions
SET session_status = 'failed',
    ended_at = NOW(),
    error_message = :error_message,
    updated_at = CURRENT_TIMESTAMP
WHERE id = :sync_session_id;
