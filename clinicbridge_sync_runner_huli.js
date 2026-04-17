// ClinicBridge sync runner skeleton for Huli Practice
// Note: requires a browser automation runtime (e.g. Playwright) to execute real navigation.

async function resolveAccessProfile(db, profileCode) {
  const sql = `
    SELECT pap.id, pap.doctor_id, pap.login_identifier, pap.credential_ref,
           pr.platform_code, pr.platform_name, pr.connector_code
    FROM platform_access_profiles pap
    LEFT JOIN platform_registry pr ON pr.id = pap.platform_registry_id
    WHERE pap.profile_code = ? AND pap.status = 'active'
    LIMIT 1
  `;
  return db.queryOne(sql, [profileCode]);
}

async function createSyncSession(db, accessProfileId, doctorId, syncType) {
  const sql = `
    INSERT INTO platform_sync_sessions (
      access_profile_id, doctor_id, sync_type, session_status, started_at, metadata
    ) VALUES (?, ?, ?, 'running', NOW(), JSON_OBJECT('runner', 'huli'))
  `;
  const result = await db.execute(sql, [accessProfileId, doctorId, syncType]);
  return result.insertId;
}

async function closeSyncSessionCompleted(db, syncSessionId) {
  const sql = `
    UPDATE platform_sync_sessions
    SET session_status = 'completed', ended_at = NOW(), updated_at = CURRENT_TIMESTAMP
    WHERE id = ?
  `;
  await db.execute(sql, [syncSessionId]);
}

async function closeSyncSessionFailed(db, syncSessionId, errorMessage) {
  const sql = `
    UPDATE platform_sync_sessions
    SET session_status = 'failed', ended_at = NOW(), error_message = ?, updated_at = CURRENT_TIMESTAMP
    WHERE id = ?
  `;
  await db.execute(sql, [errorMessage, syncSessionId]);
}

function calculateOccupancy(availableSlots, bookedSlots) {
  if (!availableSlots || availableSlots <= 0) return 0;
  return Number(((bookedSlots / availableSlots) * 100).toFixed(2));
}

async function persistSnapshotAndMetrics(db, payload) {
  const {
    doctorId,
    accessProfileId,
    snapshotDate,
    periodType,
    availableSlots,
    bookedSlots,
    cancelledSlots,
    noShowCount,
    sourcePlatform,
    syncType,
    agentAssistedAppointmentsCount = 0,
    agentAttributedAppointmentsCount = 0,
    baselineNotes = 'Initial baseline sync',
  } = payload;

  const occupancyRate = calculateOccupancy(availableSlots, bookedSlots);

  await db.execute(
    `INSERT INTO doctor_schedule_snapshots (
      doctor_id, access_profile_id, snapshot_date, period_type,
      available_slots, booked_slots, cancelled_slots, no_show_count,
      source_platform, metadata
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, JSON_OBJECT('sync_type', ?))
    ON DUPLICATE KEY UPDATE
      available_slots = VALUES(available_slots),
      booked_slots = VALUES(booked_slots),
      cancelled_slots = VALUES(cancelled_slots),
      no_show_count = VALUES(no_show_count),
      source_platform = VALUES(source_platform),
      metadata = VALUES(metadata)`,
    [
      doctorId,
      accessProfileId,
      snapshotDate,
      periodType,
      availableSlots,
      bookedSlots,
      cancelledSlots,
      noShowCount,
      sourcePlatform,
      syncType,
    ]
  );

  await db.execute(
    `INSERT INTO doctor_performance_metrics (
      doctor_id, metric_date, period_type,
      available_slots, booked_slots, occupancy_rate,
      cancelled_appointments_count, no_show_count,
      agent_assisted_appointments_count, agent_attributed_appointments_count,
      metadata
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, JSON_OBJECT('source', ?))
    ON DUPLICATE KEY UPDATE
      available_slots = VALUES(available_slots),
      booked_slots = VALUES(booked_slots),
      occupancy_rate = VALUES(occupancy_rate),
      cancelled_appointments_count = VALUES(cancelled_appointments_count),
      no_show_count = VALUES(no_show_count),
      agent_assisted_appointments_count = VALUES(agent_assisted_appointments_count),
      agent_attributed_appointments_count = VALUES(agent_attributed_appointments_count),
      metadata = VALUES(metadata)`,
    [
      doctorId,
      snapshotDate,
      periodType,
      availableSlots,
      bookedSlots,
      occupancyRate,
      cancelledSlots,
      noShowCount,
      agentAssistedAppointmentsCount,
      agentAttributedAppointmentsCount,
      sourcePlatform,
    ]
  );

  await db.execute(
    `INSERT INTO doctor_baselines (
      doctor_id, baseline_date, period_type,
      available_slots, booked_slots, occupancy_rate,
      source_type, notes, metadata
    )
    SELECT ?, ?, ?, ?, ?, ?, 'calculated', ?, JSON_OBJECT('source', ?)
    WHERE NOT EXISTS (
      SELECT 1 FROM doctor_baselines
      WHERE doctor_id = ? AND baseline_date = ? AND period_type = ?
    )`,
    [
      doctorId,
      snapshotDate,
      periodType,
      availableSlots,
      bookedSlots,
      occupancyRate,
      baselineNotes,
      sourcePlatform,
      doctorId,
      snapshotDate,
      periodType,
    ]
  );

  await db.execute(
    `UPDATE doctor_goals
     SET current_value = ?,
         status = CASE WHEN target_value IS NOT NULL AND ? >= target_value THEN 'achieved' ELSE status END,
         updated_at = CURRENT_TIMESTAMP
     WHERE doctor_id = ?
       AND goal_type = 'occupancy_rate'
       AND status IN ('active', 'paused')`,
    [occupancyRate, occupancyRate, doctorId]
  );

  return { occupancyRate };
}

// Placeholder: implement with Playwright/Puppeteer or another browser runtime.
async function loginHuli(page, loginIdentifier, password) {
  throw new Error('loginHuli not implemented yet');
}

// Placeholder: implement UI extraction here.
async function extractHuliSchedule(page, { periodType, targetDate }) {
  throw new Error('extractHuliSchedule not implemented yet');
}

async function runHuliSync({ db, browser, profileCode, syncType = 'baseline', periodType = 'weekly', targetDate }) {
  const accessProfile = await resolveAccessProfile(db, profileCode);
  if (!accessProfile) throw new Error(`Access profile not found: ${profileCode}`);

  const syncSessionId = await createSyncSession(db, accessProfile.id, accessProfile.doctor_id, syncType);

  try {
    const page = await browser.newPage();

    // TODO: resolve secret from credential_ref securely.
    const password = null;

    await loginHuli(page, accessProfile.login_identifier, password);
    const metrics = await extractHuliSchedule(page, { periodType, targetDate });

    const snapshotDate = targetDate || new Date().toISOString().slice(0, 10);
    const persisted = await persistSnapshotAndMetrics(db, {
      doctorId: accessProfile.doctor_id,
      accessProfileId: accessProfile.id,
      snapshotDate,
      periodType,
      availableSlots: metrics.availableSlots,
      bookedSlots: metrics.bookedSlots,
      cancelledSlots: metrics.cancelledSlots || 0,
      noShowCount: metrics.noShowCount || 0,
      sourcePlatform: 'Huli Practice',
      syncType,
    });

    await closeSyncSessionCompleted(db, syncSessionId);
    return {
      syncSessionId,
      ...persisted,
      metrics,
    };
  } catch (error) {
    await closeSyncSessionFailed(db, syncSessionId, error.message || String(error));
    throw error;
  }
}

module.exports = {
  runHuliSync,
  resolveAccessProfile,
  createSyncSession,
  persistSnapshotAndMetrics,
  closeSyncSessionCompleted,
  closeSyncSessionFailed,
  calculateOccupancy,
};
