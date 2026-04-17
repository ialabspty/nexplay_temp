const fs = require('fs');
const path = require('path');
const { chromium } = require('playwright');
const { createDb } = require('./lib/db');

const DEBUG_DIR = path.join(process.cwd(), 'debug_switch_week_view');
const PROFILE_CODE = 'juan-pablo-medina-clinicweb';

function ensureDebugDir() {
  if (!fs.existsSync(DEBUG_DIR)) fs.mkdirSync(DEBUG_DIR, { recursive: true });
}

function log(message, extra) {
  const line = `[${new Date().toISOString()}] ${message}${extra ? ` ${JSON.stringify(extra)}` : ''}`;
  console.log(line);
  fs.appendFileSync(path.join(DEBUG_DIR, 'run.log'), line + '\n');
}

async function save(page, name) {
  const safe = name.replace(/[^a-zA-Z0-9_-]/g, '_');
  await page.screenshot({ path: path.join(DEBUG_DIR, `${safe}.png`), fullPage: true }).catch(() => {});
  fs.writeFileSync(path.join(DEBUG_DIR, `${safe}.html`), await page.content(), 'utf8');
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

async function closePossibleOverlays(page) {
  const selectors = ['button:has-text("Cerrar")','button:has-text("Listo")','a:has-text("Cerrar")','a:has-text("Listo")','.modal-close','.close'];
  for (const selector of selectors) {
    const count = await page.locator(selector).count().catch(() => 0);
    for (let i = 0; i < count; i++) {
      await page.locator(selector).nth(i).click({ timeout: 800 }).catch(() => {});
      await page.waitForTimeout(200);
    }
  }
  await page.evaluate(() => {
    const suspects = Array.from(document.querySelectorAll('[class*="modal"], [class*="overlay"], [class*="popup"]'));
    for (const el of suspects) {
      const text = (el.innerText || '').toLowerCase();
      if (text.includes('imprimir') || text.includes('advertencia') || text.includes('enviar') || text.includes('soporte')) {
        el.style.display = 'none';
      }
    }
  }).catch(() => {});
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
  await page.evaluate(() => document.querySelector('#btn_iniciar')?.click());
  await page.waitForLoadState('domcontentloaded').catch(() => {});
  await page.waitForTimeout(5000);
  log('login:done', { url: page.url() });
}

async function inspectState(page, label) {
  const state = await page.evaluate(() => {
    return {
      url: location.href,
      currentViewValue: document.querySelector('#_ctl0_main__ctl1_cmb_ver')?.value || null,
      activeDay: !!document.querySelector('.day_tab.active'),
      activeWeek: !!document.querySelector('.week_tab.active'),
      dateLabel: document.querySelector('.dhx_cal_date.cal_date')?.textContent?.trim() || null,
      scaleBar: document.querySelector('.dhx_scale_bar')?.textContent?.trim() || null,
      schedulerClass: document.querySelector('.dhx_cal_container.custom_scheduler')?.className || null,
    };
  });
  log(`state:${label}`, state);
  return state;
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
    await closePossibleOverlays(page);
    await save(page, 'post_login');
    await inspectState(page, 'post_login');

    log('switch:method1_select_change:start');
    await page.evaluate(() => {
      const el = document.querySelector('#_ctl0_main__ctl1_cmb_ver');
      if (!el) return;
      el.value = '1';
      el.dispatchEvent(new Event('change', { bubbles: true }));
    });
    await page.waitForTimeout(3000);
    await closePossibleOverlays(page);
    await save(page, 'after_method1');
    await inspectState(page, 'after_method1');

    log('switch:method2_click_week_tab:start');
    await page.locator('.week_tab').first().click({ timeout: 3000 }).catch(() => {});
    await page.waitForTimeout(3000);
    await closePossibleOverlays(page);
    await save(page, 'after_method2');
    await inspectState(page, 'after_method2');

    log('switch:method3_dom_click_week_tab:start');
    await page.evaluate(() => document.querySelector('.week_tab')?.click());
    await page.waitForTimeout(3000);
    await closePossibleOverlays(page);
    await save(page, 'after_method3');
    await inspectState(page, 'after_method3');

    await browser.close();
    await db.close();
  } catch (error) {
    log('error', { message: error.message, stack: error.stack });
    try { if (browser) await browser.close(); } catch (_) {}
    try { await db.close(); } catch (_) {}
    process.exit(1);
  }
})();
