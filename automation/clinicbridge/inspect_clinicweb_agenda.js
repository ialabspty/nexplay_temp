const fs = require('fs');
const path = require('path');
const { chromium } = require('playwright');
const dotenv = require('dotenv');
const { createDb } = require('./lib/db');

dotenv.config();

async function resolveAccessProfile(db, profileCode) {
  const sql = `
    SELECT pap.id, pap.doctor_id, pap.login_identifier, pap.credential_ref,
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

function extractLoginUrl(profile) {
  const accessMetadata = profile.access_metadata || {};
  const platformMetadata = profile.platform_metadata || {};

  if (typeof accessMetadata === 'string') {
    try {
      const parsed = JSON.parse(accessMetadata);
      if (parsed.login_url) return parsed.login_url;
    } catch (_) {}
  } else if (accessMetadata && accessMetadata.login_url) {
    return accessMetadata.login_url;
  }

  if (typeof platformMetadata === 'string') {
    try {
      const parsed = JSON.parse(platformMetadata);
      if (parsed.login_url) return parsed.login_url;
    } catch (_) {}
  } else if (platformMetadata && platformMetadata.login_url) {
    return platformMetadata.login_url;
  }

  throw new Error('login_url not found');
}

function resolvePasswordFromDb(profile) {
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

(async () => {
  const db = await createDb();
  const profile = await resolveAccessProfile(db, 'juan-pablo-medina-clinicweb');
  const loginUrl = extractLoginUrl(profile);
  const password = resolvePasswordFromDb(profile);

  try {
    const browser = await chromium.launch({ headless: true });
    const page = await browser.newPage();

    await page.goto(loginUrl, { waitUntil: 'networkidle' });
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
    } catch (_) {
      await page.waitForTimeout(5000);
    }

    await page.waitForLoadState('domcontentloaded').catch(() => {});
    await page.waitForTimeout(3000);

    const visibleTexts = await page.$$eval('body *', nodes =>
      nodes.map(n => (n.innerText || '').trim()).filter(Boolean).slice(0, 300)
    );

    const nodes = await page.$$eval('div, td, th, span, a', els =>
      els.slice(0, 800).map(el => ({
        tag: el.tagName,
        id: el.id || null,
        className: el.className || null,
        text: (el.innerText || '').trim().slice(0, 150),
      }))
    );

    const outDir = process.cwd();
    fs.writeFileSync(path.join(outDir, 'clinicweb_agenda_texts.json'), JSON.stringify(visibleTexts, null, 2));
    fs.writeFileSync(path.join(outDir, 'clinicweb_agenda_nodes.json'), JSON.stringify(nodes, null, 2));
    fs.writeFileSync(path.join(outDir, 'clinicweb_agenda.html'), await page.content(), 'utf8');
    await page.screenshot({ path: path.join(outDir, 'clinicweb_agenda.png'), fullPage: true });

    console.log('URL actual:', page.url());
    console.log('Saved: clinicweb_agenda_texts.json');
    console.log('Saved: clinicweb_agenda_nodes.json');
    console.log('Saved: clinicweb_agenda.html');
    console.log('Saved: clinicweb_agenda.png');

    await browser.close();
  } finally {
    await db.close();
  }
})().catch((err) => {
  console.error(err);
  process.exit(1);
});
