const fs = require('fs');
const path = require('path');
const { chromium } = require('playwright');
const { createDb } = require('./lib/db');

const PROFILE_CODE = 'juan-pablo-medina-clinicweb';
const SOURCE_PLATFORM = 'Clinic Web';
const SOURCE_LABEL = 'weekly_12w_history_runner';
const WEEKS_TO_CAPTURE = 12;
const DEBUG_DIR = path.join(process.cwd(), 'debug_juan_pablo_12w_history');

function ensureDebugDir() {
  if (!fs.existsSync(DEBUG_DIR)) fs.mkdirSync(DEBUG_DIR, { recursive: true });
}

function debugLog(message, extra) {
  const line = `[${new Date().toISOString()}] ${message}${extra ? ` ${JSON.stringify(extra)}` : ''}`;
  console.log(line);
  fs.appendFileSync(path.join(DEBUG_DIR, 'run.log'), line + '\n');
}

async function saveDebugArtifacts(page, prefix) {
  ensureDebugDir();
  const safe = prefix.replace(/[^a-zA-Z0-9_-]/g, '_');
  try {
    await page.screenshot({ path: path.join(DEBUG_DIR, `${safe}.png`), fullPage: true });
  } catch (_) {}
  try {
    fs.writeFileSync(path.join(DEBUG_DIR, `${safe}.html`), await page.content(), 'utf8');
  } catch (_) {}
}

async function resolveAccessProfile(db, profileCode) {
  const sql = `
    SELECT pap.id, pap.doctor_id, pap.login_identifier,
           pap.metadata AS access_metadata,
           pr.platform_name, pr.platform_code, pr.metadata AS platform_metadata,
           pas.secret_value, pas.is_encrypted
    FROM platform_access_profiles pap
    LEFT JOIN platform_registry pr ON pr.id = pap.platform_registry_id
    LEFT JOIN platform_access_secrets pas
      ON pas.access_profile_id = pap.id
     AND pas.secret_type = 'password'
     AND pas.status = 'active'
    WHERE pap.profile_code = ? AND pap.status = 'active'
    LIMIT 1
  `;
  return db.queryOne(sql, [profileCode]);
}

function parseMaybeJson(value) {
  if (!value) return {};
  if (typeof value === 'object') return value;
  try { return JSON.parse(value); } catch (_) { return {}; }
}

function extractLoginUrl(profile) {
  const accessMetadata = parseMaybeJson(profile.access_metadata);
  const platformMetadata = parseMaybeJson(profile.platform_metadata);
  return accessMetadata.login_url || platformMetadata.login_url || 'https://professional.cliniweb.com/inicio_sesion.aspx?ReturnUrl=%2f';
}

function resolvePassword(profile) {
  if (!profile.secret_value) throw new Error('No password secret found');
  if (profile.is_encrypted) throw new Error('Encrypted secret support not implemented');
  return profile.secret_value;
}

async function typeAndTriggerPassword(page, password) {
  await page.click('#txt_password');
  await page.fill('#txt_password', '');
  await page.type('#txt_password', password, { delay: 80 });
  await page.dispatchEvent('#txt_password', 'input');
  await page.dispatchEvent('#txt_password', 'change');
  await page.dispatchEvent('#txt_password', 'blur');
  await page.keyboard.press('Tab');
}

async function loginClinicWeb(page, profile) {
  const loginUrl = extractLoginUrl(profile);
  const password = resolvePassword(profile);

  debugLog('login:start', { loginUrl, user: profile.login_identifier });
  await page.goto(loginUrl, { waitUntil: 'networkidle', timeout: 45000 });
  await page.fill('#txt_usuario', profile.login_identifier, { timeout: 15000 });
  await page.evaluate(() => document.querySelector('#btn_siguiente')?.click());
  await page.waitForSelector('#txt_password', { state: 'visible', timeout: 30000 });
  await typeAndTriggerPassword(page, password);
  await page.waitForFunction(() => {
    const btn = document.querySelector('#btn_iniciar');
    return btn && !btn.disabled;
  }, { timeout: 30000 });

  const beforeUrl = page.url();
  await page.evaluate(() => document.querySelector('#btn_iniciar')?.click());
  try {
    await page.waitForURL(url => url.toString() !== beforeUrl, { timeout: 15000 });
    debugLog('login:navigation_detected', { url: page.url() });
  } catch (_) {
    debugLog('login:url_not_changed');
  }
  await page.waitForLoadState('domcontentloaded').catch(() => {});
  await page.waitForTimeout(3000);
  await waitForAgendaReady(page);
  await clearResidualUi(page);
  debugLog('login:done', { url: page.url() });
}

async function hidePossibleOverlays(page) {
  await page.evaluate(() => {
    const suspects = Array.from(document.querySelectorAll('[class*="modal"], [class*="overlay"], [class*="popup"]'));
    for (const el of suspects) {
      const text = (el.innerText || '').toLowerCase();
      if (text.includes('imprimir') || text.includes('advertencia') || text.includes('enviar') || text.includes('soporte') || text.includes('error interno')) {
        el.style.display = 'none';
        el.style.visibility = 'hidden';
        el.setAttribute('data-hidden-by-script', '1');
      }
    }
  }).catch(() => {});
}

async function waitForAgendaReady(page) {
  const start = Date.now();
  const timeoutMs = 45000;

  while (Date.now() - start < timeoutMs) {
    try {
      const state = await page.evaluate(() => ({
        url: location.href,
        hasScheduler: !!document.querySelector('.dhx_cal_container.custom_scheduler'),
        hasViewSelect: !!document.querySelector('#_ctl0_main__ctl1_cmb_ver'),
        hasDoctorName: !!Array.from(document.querySelectorAll('body *')).find(n => (n.textContent || '').includes('Juan Pablo Medina Velásquez')),
        loadingVisible: !!Array.from(document.querySelectorAll('[class*="loading"], .loadingPanel')).find(el => {
          const style = window.getComputedStyle(el);
          return style && style.display !== 'none' && style.visibility !== 'hidden' && Number(style.opacity || '1') > 0;
        }),
        overlayVisible: !!Array.from(document.querySelectorAll('[class*="modal"], [class*="overlay"], [class*="popup"]')).find(el => {
          const style = window.getComputedStyle(el);
          return style && style.display !== 'none' && style.visibility !== 'hidden' && Number(style.opacity || '1') > 0;
        }),
      }));

      debugLog('agenda_ready:state', state);

      if (state.hasScheduler && state.hasViewSelect && state.hasDoctorName) {
        return state;
      }
    } catch (error) {
      if ((error.message || '').includes('Execution context was destroyed')) {
        debugLog('agenda_ready:context_replaced');
      } else {
        throw error;
      }
    }

    await page.waitForLoadState('domcontentloaded').catch(() => {});
    await page.waitForTimeout(2000);
  }

  throw new Error('Agenda did not reach ready state within timeout');
}

async function clearResidualUi(page) {
  for (let i = 0; i < 3; i++) {
    await hidePossibleOverlays(page);
    await page.evaluate(() => {
      const selectors = ['[class*="loading"]', '.loadingPanel', '.loading-overlay', '.loading-container'];
      for (const selector of selectors) {
        document.querySelectorAll(selector).forEach(el => {
          el.style.display = 'none';
          el.style.visibility = 'hidden';
          el.setAttribute('data-hidden-by-script', '1');
        });
      }
    }).catch(() => {});
    await page.waitForTimeout(600);
  }

  const state = await page.evaluate(() => ({
    loadingVisible: !!Array.from(document.querySelectorAll('[class*="loading"], .loadingPanel')).find(el => {
      const style = window.getComputedStyle(el);
      return style && style.display !== 'none' && style.visibility !== 'hidden' && Number(style.opacity || '1') > 0;
    }),
    overlayVisible: !!Array.from(document.querySelectorAll('[class*="modal"], [class*="overlay"], [class*="popup"]')).find(el => {
      const style = window.getComputedStyle(el);
      return style && style.display !== 'none' && style.visibility !== 'hidden' && Number(style.opacity || '1') > 0;
    }),
  })).catch(() => ({ loadingVisible: null, overlayVisible: null }));

  debugLog('ui_cleared:state', state);
}

async function ensureWeekView(page) {
  debugLog('week_view:ensure:start');
  const isWeekActive = await page.locator('.week_tab.active').count().catch(() => 0);
  if (isWeekActive) {
    debugLog('week_view:already_active');
    return;
  }

  await page.evaluate(() => {
    const el = document.querySelector('#_ctl0_main__ctl1_cmb_ver');
    if (el) {
      el.value = '1';
      el.dispatchEvent(new Event('change', { bubbles: true }));
    }
  }).catch((error) => debugLog('week_view:method1_error', { message: error.message }));

  await page.waitForTimeout(2500);

  const state = await page.evaluate(() => ({
    currentViewValue: document.querySelector('#_ctl0_main__ctl1_cmb_ver')?.value || null,
    activeDay: !!document.querySelector('.day_tab.active'),
    activeWeek: !!document.querySelector('.week_tab.active'),
    schedulerClass: document.querySelector('.dhx_cal_container.custom_scheduler')?.className || null,
    dateLabel: document.querySelector('.dhx_cal_date.cal_date')?.textContent?.trim() || null,
    scaleBar: document.querySelector('.dhx_scale_bar')?.textContent?.trim() || null,
  })).catch(() => ({}));

  debugLog('week_view:state_after_method1', state);

  if (!state.activeWeek) {
    throw new Error('Week view did not activate with validated method');
  }

  debugLog('week_view:ensure:end', { activeAfter: 1 });
}

function parseTimeLabel(label) {
  const m = String(label).trim().match(/^(\d{1,2}):(\d{2})\s*(am|pm)$/i);
  if (!m) return null;
  let hour = Number(m[1]);
  const minute = Number(m[2]);
  const meridiem = m[3].toLowerCase();
  if (meridiem === 'pm' && hour !== 12) hour += 12;
  if (meridiem === 'am' && hour === 12) hour = 0;
  return hour * 60 + minute;
}

function toIsoDate(date) {
  const y = date.getFullYear();
  const m = String(date.getMonth() + 1).padStart(2, '0');
  const d = String(date.getDate()).padStart(2, '0');
  return `${y}-${m}-${d}`;
}

function parseSpanishDateLabel(label) {
  if (!label) return null;
  const months = {
    ene: 0, enero: 0, feb: 1, febrero: 1, mar: 2, marzo: 2, abr: 3, abril: 3,
    may: 4, mayo: 4, jun: 5, junio: 5, jul: 6, julio: 6, ago: 7, agosto: 7,
    sep: 8, sept: 8, septiembre: 8, oct: 9, octubre: 9, nov: 10, noviembre: 10,
    dic: 11, diciembre: 11,
  };

  const m = String(label).trim().match(/(\d{1,2})\s+([A-Za-zÁÉÍÓÚáéíóú]+)\s+(\d{4})/i);
  if (!m) return null;
  const day = Number(m[1]);
  const monthRaw = m[2].toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '');
  const year = Number(m[3]);
  const month = months[monthRaw];
  if (month === undefined) return null;
  return new Date(year, month, day);
}

function normalizeWeekStart(date) {
  const d = new Date(date);
  const day = d.getDay();
  const diff = day === 0 ? -6 : 1 - day;
  d.setDate(d.getDate() + diff);
  d.setHours(0, 0, 0, 0);
  return d;
}

async function readWeekMetrics(page) {
  return page.evaluate(() => {
    const container = document.querySelector('.dhx_cal_container.custom_scheduler');
    if (!container) throw new Error('Calendar container not found');

    const dateLabel = container.querySelector('.dhx_cal_date')?.textContent?.trim() || null;
    const headerLabel = container.querySelector('.dhx_scale_bar')?.textContent?.trim() || null;
    const events = Array.from(container.querySelectorAll('.dhx_cal_event')).map((event) => ({
      title: event.querySelector('.dhx_title')?.textContent?.trim() || '',
      body: event.querySelector('.dhx_body')?.textContent?.trim() || '',
      aria: event.getAttribute('aria-label') || '',
    }));

    return { dateLabel, headerLabel, events };
  });
}

function computeMetrics(raw) {
  const blocks = raw.events.map((event) => {
    const match = event.title.match(/^(\d{1,2}:\d{2}\s*[ap]m)\s*-\s*(\d{1,2}:\d{2}\s*[ap]m)$/i);
    if (!match) return null;
    const startMinutes = parseTimeLabel(match[1]);
    const endMinutes = parseTimeLabel(match[2]);
    if (startMinutes === null || endMinutes === null || endMinutes <= startMinutes) return null;
    return { ...event, startMinutes, endMinutes };
  }).filter(Boolean);

  const bookedBlocks = blocks.filter(e => {
    const body = (e.body || '').toLowerCase();
    const aria = (e.aria || '').toLowerCase();
    return body.includes('ocupado') || aria.includes('ocupado') || body.length > 0;
  });

  const uniqueTimeRanges = new Map();
  for (const block of bookedBlocks) {
    const key = `${block.startMinutes}-${block.endMinutes}`;
    if (!uniqueTimeRanges.has(key)) {
      uniqueTimeRanges.set(key, block.endMinutes - block.startMinutes);
    }
  }

  const bookedMinutes = Array.from(uniqueTimeRanges.values()).reduce((sum, minutes) => sum + minutes, 0);
  const earliestStart = uniqueTimeRanges.size ? Math.min(...Array.from(uniqueTimeRanges.keys()).map(k => Number(k.split('-')[0]))) : null;
  const latestEnd = uniqueTimeRanges.size ? Math.max(...Array.from(uniqueTimeRanges.keys()).map(k => Number(k.split('-')[1]))) : null;
  const availableMinutes = earliestStart !== null && latestEnd !== null ? Math.max(0, latestEnd - earliestStart) : 0;

  const availableSlots = Math.round(availableMinutes / 30);
  const bookedSlots = Math.round(bookedMinutes / 30);
  const namedAppointments = bookedBlocks.filter(e => !(e.body || '').toLowerCase().includes('ocupado')).length;
  const occupancyRate = availableSlots > 0 ? Number(((bookedSlots / availableSlots) * 100).toFixed(2)) : 0;

  const parsedDate = parseSpanishDateLabel(raw.dateLabel) || parseSpanishDateLabel(raw.headerLabel);
  const weekStart = normalizeWeekStart(parsedDate || new Date());

  return {
    snapshotDate: toIsoDate(weekStart),
    dateLabel: raw.dateLabel,
    headerLabel: raw.headerLabel,
    availableSlots,
    bookedSlots,
    cancelledSlots: 0,
    noShowCount: 0,
    occupancyRate,
    extractionConfidence: bookedBlocks.length ? 92 : 70,
    weekStatus: bookedBlocks.length ? 'valid_normal' : 'invalid',
    exclusionReason: bookedBlocks.length ? null : 'no_visible_events_in_week_view',
    namedAppointments,
    blocks: bookedBlocks,
    uniqueRangesCount: uniqueTimeRanges.size,
  };
}

async function goPreviousWeek(page, iteration) {
  const currentLabel = await page.locator('.dhx_cal_date.cal_date').first().textContent().catch(() => null);
  debugLog('nav:prev:start', { iteration, currentLabel: currentLabel?.trim() || null });

  await page.evaluate(() => {
    const btn = document.querySelector('.dhx_cal_prev_button.nav_prev_btn');
    if (!btn) throw new Error('Prev button not found');
    btn.click();
  }).catch((error) => {
    throw new Error(`Prev navigation failed: ${error.message}`);
  });

  try {
    await page.waitForFunction((prev) => {
      const label = document.querySelector('.dhx_cal_date.cal_date')?.textContent?.trim() || null;
      return label && label !== prev;
    }, currentLabel?.trim() || null, { timeout: 10000 });
  } catch (_) {
    debugLog('nav:prev:label_not_changed', { iteration, currentLabel: currentLabel?.trim() || null });
  }

  await page.waitForTimeout(1500);
  const afterState = await page.evaluate(() => ({
    dateLabel: document.querySelector('.dhx_cal_date.cal_date')?.textContent?.trim() || null,
    scaleBar: document.querySelector('.dhx_scale_bar')?.textContent?.trim() || null,
    activeWeek: !!document.querySelector('.week_tab.active'),
  })).catch(() => ({}));

  debugLog('nav:prev:end', { iteration, ...afterState });
}

async function createSyncSession(db, accessProfileId, doctorId) {
  const result = await db.execute(
    `INSERT INTO platform_sync_sessions (
      access_profile_id, doctor_id, sync_type, session_status, started_at, metadata
    ) VALUES (?, ?, 'baseline', 'running', NOW(), JSON_OBJECT('runner', ?, 'source', ?, 'weeks_to_capture', ?))`,
    [accessProfileId, doctorId, SOURCE_LABEL, SOURCE_PLATFORM, WEEKS_TO_CAPTURE]
  );
  return result.insertId;
}

async function completeSyncSession(db, id) {
  await db.execute(`UPDATE platform_sync_sessions SET session_status='completed', ended_at=NOW(), updated_at=CURRENT_TIMESTAMP WHERE id = ?`, [id]);
}

async function failSyncSession(db, id, message) {
  await db.execute(`UPDATE platform_sync_sessions SET session_status='failed', ended_at=NOW(), error_message=?, updated_at=CURRENT_TIMESTAMP WHERE id = ?`, [message, id]);
}

async function persistWeek(db, profile, metrics, iteration) {
  await db.execute(
    `INSERT INTO doctor_schedule_snapshots (
      doctor_id, access_profile_id, snapshot_date, period_type,
      available_slots, booked_slots, cancelled_slots, no_show_count,
      source_platform, metadata
    ) VALUES (?, ?, ?, 'weekly', ?, ?, ?, ?, ?,
      JSON_OBJECT(
        'sync_type', 'baseline',
        'week_status', ?,
        'exclusion_reason', ?,
        'extraction_confidence', ?,
        'runner', ?,
        'iteration', ?,
        'captured_date_label', ?,
        'captured_header_label', ?,
        'named_appointments', ?
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
      metrics.snapshotDate,
      metrics.availableSlots,
      metrics.bookedSlots,
      metrics.cancelledSlots,
      metrics.noShowCount,
      SOURCE_PLATFORM,
      metrics.weekStatus,
      metrics.exclusionReason,
      metrics.extractionConfidence,
      SOURCE_LABEL,
      iteration,
      metrics.dateLabel,
      metrics.headerLabel,
      metrics.namedAppointments,
    ]
  );

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
        'week_status', ?,
        'exclusion_reason', ?,
        'extraction_confidence', ?,
        'runner', ?,
        'iteration', ?
      )
    )
    ON DUPLICATE KEY UPDATE
      available_slots = VALUES(available_slots),
      booked_slots = VALUES(booked_slots),
      occupancy_rate = VALUES(occupancy_rate),
      cancelled_appointments_count = VALUES(cancelled_appointments_count),
      no_show_count = VALUES(no_show_count),
      metadata = VALUES(metadata)`,
    [
      profile.doctor_id,
      metrics.snapshotDate,
      metrics.availableSlots,
      metrics.bookedSlots,
      metrics.occupancyRate,
      metrics.cancelledSlots,
      metrics.noShowCount,
      SOURCE_PLATFORM,
      metrics.weekStatus,
      metrics.exclusionReason,
      metrics.extractionConfidence,
      SOURCE_LABEL,
      iteration,
    ]
  );
}

(async () => {
  ensureDebugDir();
  debugLog('runner:start', { profileCode: PROFILE_CODE, weeks: WEEKS_TO_CAPTURE });
  const db = await createDb();
  let syncSessionId = null;
  let browser = null;
  try {
    const profile = await resolveAccessProfile(db, PROFILE_CODE);
    if (!profile) throw new Error(`Access profile not found: ${PROFILE_CODE}`);
    debugLog('profile:resolved', { doctorId: profile.doctor_id, accessProfileId: profile.id, user: profile.login_identifier });

    syncSessionId = await createSyncSession(db, profile.id, profile.doctor_id);
    debugLog('sync_session:created', { syncSessionId });

    browser = await chromium.launch({ headless: true });
    const page = await browser.newPage({ viewport: { width: 1600, height: 2400 } });

    await loginClinicWeb(page, profile);
    await saveDebugArtifacts(page, 'post_login');
    await ensureWeekView(page);
    await hidePossibleOverlays(page);
    await page.waitForTimeout(1500);
    await saveDebugArtifacts(page, 'week_view_ready');

    const captured = [];
    const seenDates = new Set();

    for (let i = 0; i < WEEKS_TO_CAPTURE; i++) {
      const iteration = i + 1;
      debugLog('iteration:start', { iteration });
      await hidePossibleOverlays(page);
      const raw = await readWeekMetrics(page);
      debugLog('iteration:raw', { iteration, dateLabel: raw.dateLabel, headerLabel: raw.headerLabel, events: raw.events.length });
      const metrics = computeMetrics(raw);
      debugLog('iteration:metrics', {
        iteration,
        snapshotDate: metrics.snapshotDate,
        availableSlots: metrics.availableSlots,
        bookedSlots: metrics.bookedSlots,
        occupancyRate: metrics.occupancyRate,
        weekStatus: metrics.weekStatus,
        blocks: metrics.blocks.length,
        uniqueRangesCount: metrics.uniqueRangesCount,
      });
      await saveDebugArtifacts(page, `iteration_${String(iteration).padStart(2, '0')}_${metrics.snapshotDate}`);

      if (!seenDates.has(metrics.snapshotDate)) {
        await persistWeek(db, profile, metrics, iteration);
        seenDates.add(metrics.snapshotDate);
        captured.push(metrics);
        debugLog('iteration:persisted', { iteration, snapshotDate: metrics.snapshotDate });
      } else {
        debugLog('iteration:duplicate_skipped', { iteration, snapshotDate: metrics.snapshotDate });
      }

      if (i < WEEKS_TO_CAPTURE - 1) {
        await goPreviousWeek(page, iteration);
      }
    }

    await completeSyncSession(db, syncSessionId);
    debugLog('sync_session:completed', { syncSessionId, capturedWeeks: captured.length });
    console.log(JSON.stringify({ ok: true, syncSessionId, capturedWeeks: captured.length, weeks: captured }, null, 2));

    await browser.close();
    await db.close();
  } catch (error) {
    debugLog('runner:error', { message: error.message || String(error), stack: error.stack || null });
    if (syncSessionId) {
      try { await failSyncSession(db, syncSessionId, error.message || String(error)); } catch (_) {}
    }
    try { if (browser) await browser.close(); } catch (_) {}
    try { await db.close(); } catch (_) {}
    console.error(error);
    process.exit(1);
  }
})();
