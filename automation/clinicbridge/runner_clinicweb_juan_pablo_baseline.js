const { chromium } = require('playwright');
const { createDb } = require('./lib/db');
const { resolveAccessProfile } = require('./lib/profile-resolver');
const clinicWeb = require('./connectors/clinicweb');

const PROFILE_CODE = 'juan-pablo-medina-clinicweb';
const SOURCE_PLATFORM = 'Clinic Web';
const SOURCE_LABEL = 'weekly_12w_baseline_runner';

function formatDateToMonday(date) {
  const d = new Date(date);
  const day = d.getDay();
  const diff = day === 0 ? -6 : 1 - day;
  d.setDate(d.getDate() + diff);
  const y = d.getFullYear();
  const m = String(d.getMonth() + 1).padStart(2, '0');
  const da = String(d.getDate()).padStart(2, '0');
  return `${y}-${m}-${da}`;
}

async function createSyncSession(db, accessProfileId, doctorId) {
  const sql = `
    INSERT INTO platform_sync_sessions (
      access_profile_id, doctor_id, sync_type, session_status, started_at, metadata
    ) VALUES (?, ?, 'baseline', 'running', NOW(), JSON_OBJECT('runner', ?, 'source', ?, 'profile_code', ?))
  `;
  const result = await db.execute(sql, [accessProfileId, doctorId, SOURCE_LABEL, SOURCE_PLATFORM, PROFILE_CODE]);
  return result.insertId;
}

async function completeSyncSession(db, syncSessionId) {
  await db.execute(
    `UPDATE platform_sync_sessions
     SET session_status = 'completed', ended_at = NOW(), updated_at = CURRENT_TIMESTAMP
     WHERE id = ?`,
    [syncSessionId]
  );
}

async function failSyncSession(db, syncSessionId, errorMessage) {
  await db.execute(
    `UPDATE platform_sync_sessions
     SET session_status = 'failed', ended_at = NOW(), error_message = ?, updated_at = CURRENT_TIMESTAMP
     WHERE id = ?`,
    [errorMessage, syncSessionId]
  );
}

async function persistWeeklySnapshot(db, profile, metrics) {
  const snapshotDate = formatDateToMonday(new Date());

  await db.execute(
    `INSERT INTO doctor_schedule_snapshots (
      doctor_id, access_profile_id, snapshot_date, period_type,
      available_slots, booked_slots, cancelled_slots, no_show_count,
      source_platform, metadata
    ) VALUES (?, ?, ?, 'weekly', ?, ?, ?, ?, ?,
      JSON_OBJECT(
        'sync_type', 'baseline',
        'extraction_confidence', ?,
        'doctor', 'Juan Pablo Medina Velásquez',
        'profile_code', ?,
        'captured_day_label', ?,
        'captured_date_label', ?
      )
    )
    ON DUPLICATE KEY UPDATE
      available_slots = VALUES(available_slots),
      booked_slots = VALUES(booked_slots),
      cancelled_slots = VALUES(cancelled_slots),
      no_show_count = VALUES(no_show_count),
      source_platform = VALUES(source_platform),
      metadata = VALUES(metadata)`,
    [
      profile.doctor_id,
      profile.id,
      snapshotDate,
      metrics.availableSlots,
      metrics.bookedSlots,
      metrics.cancelledSlots,
      metrics.noShowCount,
      SOURCE_PLATFORM,
      metrics.extractionConfidence || 0,
      PROFILE_CODE,
      metrics.dayLabel,
      metrics.dateLabel,
    ]
  );

  return snapshotDate;
}

async function upsertPerformanceMetric(db, profile, metrics, snapshotDate) {
  await db.execute(
    `INSERT INTO doctor_performance_metrics (
      doctor_id, metric_date, period_type,
      available_slots, booked_slots, occupancy_rate,
      cancelled_appointments_count, no_show_count,
      agent_assisted_appointments_count, agent_attributed_appointments_count,
      metadata
    ) VALUES (?, ?, 'weekly', ?, ?, ?, ?, ?, 0, 0,
      JSON_OBJECT(
        'source', ?,
        'extraction_confidence', ?,
        'runner', ?,
        'profile_code', ?
      )
    )
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
      profile.doctor_id,
      snapshotDate,
      metrics.availableSlots,
      metrics.bookedSlots,
      metrics.occupancyRate,
      metrics.cancelledSlots,
      metrics.noShowCount,
      SOURCE_PLATFORM,
      metrics.extractionConfidence || 0,
      SOURCE_LABEL,
      PROFILE_CODE,
    ]
  );
}

(async () => {
  const db = await createDb();
  let syncSessionId = null;
  let browser;

  try {
    const profile = await resolveAccessProfile(db, PROFILE_CODE);
    if (!profile) throw new Error(`Access profile not found: ${PROFILE_CODE}`);

    syncSessionId = await createSyncSession(db, profile.id, profile.doctor_id);

    browser = await chromium.launch({ headless: true });
    const page = await browser.newPage({ viewport: { width: 1440, height: 2200 } });

    await clinicWeb.login(page, profile);
    const metrics = await clinicWeb.extractMetrics(page);
    const snapshotDate = await persistWeeklySnapshot(db, profile, metrics);
    await upsertPerformanceMetric(db, profile, metrics, snapshotDate);
    await completeSyncSession(db, syncSessionId);

    console.log(JSON.stringify({ ok: true, syncSessionId, snapshotDate, metrics }, null, 2));
  } catch (error) {
    if (syncSessionId) {
      try {
        await failSyncSession(db, syncSessionId, error.message || String(error));
      } catch (_) {}
    }
    console.error(error);
    process.exitCode = 1;
  } finally {
    try {
      if (browser) await browser.close();
    } catch (_) {}
    try {
      await db.close();
    } catch (_) {}
  }
})();
