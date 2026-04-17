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

  throw new Error('login_url not found in profile/platform metadata');
}

function resolvePasswordFromDb(profile) {
  if (!profile.secret_value) {
    throw new Error(`No active password secret found for profile`);
  }

  if (profile.is_encrypted) {
    throw new Error('Encrypted secret support is not implemented yet');
  }

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
  const profileCode = process.argv[2] || 'juan-pablo-medina-clinicweb';
  const db = await createDb();

  try {
    const profile = await resolveAccessProfile(db, profileCode);
    if (!profile) {
      throw new Error(`Access profile not found: ${profileCode}`);
    }

    const loginUrl = extractLoginUrl(profile);
    const password = resolvePasswordFromDb(profile);

    const browser = await chromium.launch({ headless: true });
    const page = await browser.newPage();

    await page.goto(loginUrl, { waitUntil: 'networkidle' });

    // Step 1: username screen
    await page.fill('#txt_usuario', profile.login_identifier);
    await page.evaluate(() => {
      const btn = document.querySelector('#btn_siguiente');
      if (btn) btn.click();
    });

    // Step 2: password screen
    await page.waitForSelector('#txt_password', { state: 'visible', timeout: 30000 });
    await typeAndTriggerPassword(page, password);

    await page.waitForFunction(() => {
      const btn = document.querySelector('#btn_iniciar');
      return btn && !btn.disabled;
    }, { timeout: 30000 });

    const beforeUrl = page.url();
    await page.evaluate(() => {
      const btn = document.querySelector('#btn_iniciar');
      if (btn) btn.click();
    });

    try {
      await page.waitForURL(url => url.toString() !== beforeUrl, { timeout: 15000 });
    } catch (_) {
      // If URL does not change, still wait for DOM/network to settle because login could be SPA-like or partial postback.
      await page.waitForTimeout(5000);
    }

    await page.waitForLoadState('domcontentloaded').catch(() => {});
    await page.waitForTimeout(3000);

    const outDir = process.cwd();
    let html = '';
    try {
      html = await page.content();
      fs.writeFileSync(path.join(outDir, 'clinicweb_post_login.html'), html, 'utf8');
      console.log('Saved: clinicweb_post_login.html');
    } catch (error) {
      console.log('Could not save HTML after login transition:', error.message);
    }

    await page.screenshot({ path: path.join(outDir, 'clinicweb_post_login.png'), fullPage: true });

    console.log('Profile:', profileCode);
    console.log('URL actual:', page.url());
    console.log('Título:', await page.title());
    console.log('Saved: clinicweb_post_login.png');

    await browser.close();
  } finally {
    await db.close();
  }
})().catch((err) => {
  console.error(err);
  process.exit(1);
});
