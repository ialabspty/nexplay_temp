const fs = require('fs');
const path = require('path');
const { chromium } = require('playwright');
const dotenv = require('dotenv');
const { createDb } = require('./lib/db');

dotenv.config();

async function resolveAccessProfile(db, profileCode) {
  const sql = `
    SELECT pap.id, pap.doctor_id, pap.login_identifier,
           pap.metadata AS access_metadata,
           pr.metadata AS platform_metadata
    FROM platform_access_profiles pap
    LEFT JOIN platform_registry pr ON pr.id = pap.platform_registry_id
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

(async () => {
  const db = await createDb();
  const profile = await resolveAccessProfile(db, 'juan-pablo-medina-clinicweb');
  const loginUrl = extractLoginUrl(profile);

  try {
    const browser = await chromium.launch({ headless: true });
    const page = await browser.newPage();

    await page.goto(loginUrl, { waitUntil: 'networkidle' });
    await page.fill('#txt_usuario', profile.login_identifier);

    await page.evaluate(() => {
      const btn = document.querySelector('#btn_iniciar');
      if (btn) btn.disabled = false;
    });

    await page.click('#btn_iniciar');
    await page.waitForTimeout(3000);

    const passwordVisible = await page.isVisible('#txt_password').catch(() => false);
    const html = await page.content();
    const outDir = process.cwd();
    fs.writeFileSync(path.join(outDir, 'clinicweb_force_step.html'), html, 'utf8');
    await page.screenshot({ path: path.join(outDir, 'clinicweb_force_step.png'), fullPage: true });

    console.log('URL actual:', page.url());
    console.log('Password visible:', passwordVisible);
    console.log('Saved: clinicweb_force_step.html');
    console.log('Saved: clinicweb_force_step.png');

    await browser.close();
  } finally {
    await db.close();
  }
})().catch((err) => {
  console.error(err);
  process.exit(1);
});
