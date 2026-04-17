const fs = require('fs');
const path = require('path');
const { chromium } = require('playwright');
const { createDb } = require('./lib/db');

const PROFILE_CODE = 'juan-pablo-medina-clinicweb';
const DEBUG_DIR = path.join(process.cwd(), 'debug_cleanup_split');

function ensureDebugDir() {
  if (!fs.existsSync(DEBUG_DIR)) fs.mkdirSync(DEBUG_DIR, { recursive: true });
}

function log(message, extra) {
  const line = `[${new Date().toISOString()}] ${message}${extra ? ` ${JSON.stringify(extra)}` : ''}`;
  console.log(line);
  fs.appendFileSync(path.join(DEBUG_DIR, 'run.log'), line + '\n');
}

async function resolveAccessProfile(db, profileCode) {
  const sql = `
    SELECT pap.id, pap.doctor_id, pap.login_identifier,
           pap.metadata AS access_metadata,
           pr.metadata AS platform_metadata,
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

async function login(page, profile) {
  const loginUrl = extractLoginUrl(profile);
  const password = resolvePassword(profile);
  log('login:start', { loginUrl, user: profile.login_identifier });
  await page.goto(loginUrl, { waitUntil: 'networkidle', timeout: 45000 });
  await page.fill('#txt_usuario', profile.login_identifier);
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
  } catch (_) {}
  await page.waitForLoadState('domcontentloaded').catch(() => {});
  await page.waitForTimeout(3000);
}

async function waitForAgendaReady(page) {
  const start = Date.now();
  while (Date.now() - start < 45000) {
    try {
      const state = await page.evaluate(() => ({
        hasScheduler: !!document.querySelector('.dhx_cal_container.custom_scheduler'),
        hasViewSelect: !!document.querySelector('#_ctl0_main__ctl1_cmb_ver'),
        hasDoctorName: !!Array.from(document.querySelectorAll('body *')).find(n => (n.textContent || '').includes('Juan Pablo Medina Velásquez')),
      }));
      log('agenda:state', state);
      if (state.hasScheduler && state.hasViewSelect && state.hasDoctorName) return;
    } catch (error) {
      if (!(error.message || '').includes('Execution context was destroyed')) throw error;
    }
    await page.waitForLoadState('domcontentloaded').catch(() => {});
    await page.waitForTimeout(2000);
  }
  throw new Error('Agenda not ready');
}

async function inspect(page, label) {
  const state = await page.evaluate(() => ({
    currentViewValue: document.querySelector('#_ctl0_main__ctl1_cmb_ver')?.value || null,
    activeDay: !!document.querySelector('.day_tab.active'),
    activeWeek: !!document.querySelector('.week_tab.active'),
    loadingVisible: !!Array.from(document.querySelectorAll('[class*="loading"], .loadingPanel')).find(el => {
      const s = window.getComputedStyle(el);
      return s && s.display !== 'none' && s.visibility !== 'hidden' && Number(s.opacity || '1') > 0;
    }),
    overlayVisible: !!Array.from(document.querySelectorAll('[class*="modal"], [class*="overlay"], [class*="popup"]')).find(el => {
      const s = window.getComputedStyle(el);
      return s && s.display !== 'none' && s.visibility !== 'hidden' && Number(s.opacity || '1') > 0;
    }),
  }));
  log(`inspect:${label}`, state);
}

async function onlyHideOverlays(page) {
  log('overlays_hide_only:start');
  await page.evaluate(() => {
    const suspects = Array.from(document.querySelectorAll('[class*="modal"], [class*="overlay"], [class*="popup"]'));
    for (const el of suspects) {
      const text = (el.innerText || '').toLowerCase();
      if (text.includes('imprimir') || text.includes('advertencia') || text.includes('enviar') || text.includes('soporte') || text.includes('error interno')) {
        el.style.display = 'none';
        el.style.visibility = 'hidden';
      }
    }
  });
  log('overlays_hide_only:end');
}

async function onlyHideLoaders(page) {
  log('loaders_only:start');
  await page.evaluate(() => {
    ['[class*="loading"]','.loadingPanel','.loading-overlay','.loading-container'].forEach(selector => {
      document.querySelectorAll(selector).forEach(el => {
        el.style.display = 'none';
        el.style.visibility = 'hidden';
      });
    });
  });
  log('loaders_only:end');
}

(async () => {
  ensureDebugDir();
  const db = await createDb();
  let browser;
  try {
    const profile = await resolveAccessProfile(db, PROFILE_CODE);
    if (!profile) throw new Error('Profile not found');

    browser = await chromium.launch({ headless: true });
    const page = await browser.newPage({ viewport: { width: 1600, height: 2400 } });

    await login(page, profile);
    await waitForAgendaReady(page);
    await inspect(page, 'agenda_ready');

    await onlyHideOverlays(page);
    await inspect(page, 'after_only_hide_overlays');

    await onlyHideLoaders(page);
    await inspect(page, 'after_only_hide_loaders');

    await browser.close();
    await db.close();
  } catch (error) {
    log('error', { message: error.message, stack: error.stack });
    try { if (browser) await browser.close(); } catch (_) {}
    try { await db.close(); } catch (_) {}
    process.exit(1);
  }
})();
