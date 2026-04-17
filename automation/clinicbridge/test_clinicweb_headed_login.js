const { chromium } = require('playwright');
const { createDb } = require('./lib/db');

const PROFILE_CODE = 'juan-pablo-medina-clinicweb';

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
        title: document.title,
      }));

      console.log('Agenda readiness state:', state);

      if (state.hasScheduler && state.hasViewSelect && state.hasDoctorName) {
        return state;
      }
    } catch (error) {
      if ((error.message || '').includes('Execution context was destroyed')) {
        console.log('Agenda readiness state: context replaced by navigation, retrying...');
      } else {
        throw error;
      }
    }

    await page.waitForLoadState('domcontentloaded').catch(() => {});
    await page.waitForTimeout(2000);
  }

  throw new Error('Agenda did not reach ready state within timeout');
}

(async () => {
  const db = await createDb();
  try {
    const profile = await resolveAccessProfile(db, PROFILE_CODE);
    if (!profile) throw new Error('Profile not found');

    const browser = await chromium.launch({ headless: false, slowMo: 250 });
    const page = await browser.newPage({ viewport: { width: 1440, height: 1200 } });

    page.on('console', msg => console.log('[browser console]', msg.type(), msg.text()));
    page.on('pageerror', err => console.log('[pageerror]', err.message));
    page.on('requestfailed', req => console.log('[requestfailed]', req.url(), req.failure()?.errorText));

    const loginUrl = extractLoginUrl(profile);
    const password = resolvePassword(profile);

    console.log('Opening:', loginUrl);
    await page.goto(loginUrl, { waitUntil: 'domcontentloaded', timeout: 45000 });
    console.log('Loaded login page:', page.url());

    await page.fill('#txt_usuario', profile.login_identifier);
    await page.evaluate(() => document.querySelector('#btn_siguiente')?.click());
    console.log('Username step submitted');

    await page.waitForSelector('#txt_password', { state: 'visible', timeout: 30000 });
    console.log('Password field visible');

    await typeAndTriggerPassword(page, password);
    await page.waitForFunction(() => {
      const btn = document.querySelector('#btn_iniciar');
      return btn && !btn.disabled;
    }, { timeout: 30000 });
    console.log('Login button enabled');

    const beforeUrl = page.url();
    await page.evaluate(() => document.querySelector('#btn_iniciar')?.click());
    console.log('Login submitted');

    try {
      await page.waitForURL(url => url.toString() !== beforeUrl, { timeout: 15000 });
      console.log('Navigation detected after submit:', page.url());
    } catch (_) {
      console.log('No URL change detected, continuing with functional readiness checks');
    }

    await page.waitForLoadState('domcontentloaded').catch(() => {});
    await page.waitForTimeout(3000);

    const readyState = await waitForAgendaReady(page);
    console.log('Agenda ready:', readyState);
    console.log('Current URL after readiness:', page.url());
    console.log('Current title:', await page.title());

    await page.waitForTimeout(10000);
    await browser.close();
    await db.close();
  } catch (error) {
    try { await db.close(); } catch (_) {}
    console.error(error);
    process.exit(1);
  }
})();
