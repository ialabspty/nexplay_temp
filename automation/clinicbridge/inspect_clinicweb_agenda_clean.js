const fs = require('fs');
const path = require('path');
const { chromium } = require('playwright');
const { createDb } = require('./lib/db');

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
  const selectors = [
    'button:has-text("Cerrar")',
    'button:has-text("Listo")',
    'button:has-text("Cancelar")',
    'a:has-text("Cerrar")',
    'a:has-text("Listo")',
    '.modal-close',
    '.close',
    '.swal2-confirm',
    '.swal2-cancel',
  ];

  for (const selector of selectors) {
    const matches = await page.locator(selector).count().catch(() => 0);
    for (let i = 0; i < matches; i++) {
      try {
        await page.locator(selector).nth(i).click({ timeout: 1500 });
        await page.waitForTimeout(500);
      } catch (_) {}
    }
  }

  // Last resort: hide obvious overlay containers
  await page.evaluate(() => {
    const suspects = Array.from(document.querySelectorAll('[class*="modal"], [class*="overlay"], [class*="popup"]'));
    for (const el of suspects) {
      const text = (el.innerText || '').toLowerCase();
      if (text.includes('imprimir') || text.includes('advertencia') || text.includes('enviar') || text.includes('soporte')) {
        el.style.display = 'none';
        el.setAttribute('data-hidden-by-script', '1');
      }
    }
  });
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
    await page.evaluate(() => document.querySelector('#btn_siguiente')?.click());
    await page.waitForSelector('#txt_password', { state: 'visible', timeout: 30000 });
    await typeAndTriggerPassword(page, profile.secret_value);
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

    await closePossibleOverlays(page);
    await page.waitForTimeout(2000);

    const visibleTexts = await page.$$eval('body *', nodes =>
      nodes.map(n => (n.innerText || '').trim()).filter(Boolean).slice(0, 300)
    );

    const nodes = await page.$$eval('div, td, th, span, a', els =>
      els.slice(0, 1000).map(el => ({
        tag: el.tagName,
        id: el.id || null,
        className: el.className || null,
        text: (el.innerText || '').trim().slice(0, 150),
      }))
    );

    const outDir = process.cwd();
    fs.writeFileSync(path.join(outDir, 'clinicweb_agenda_clean_texts.json'), JSON.stringify(visibleTexts, null, 2));
    fs.writeFileSync(path.join(outDir, 'clinicweb_agenda_clean_nodes.json'), JSON.stringify(nodes, null, 2));
    fs.writeFileSync(path.join(outDir, 'clinicweb_agenda_clean.html'), await page.content(), 'utf8');
    await page.screenshot({ path: path.join(outDir, 'clinicweb_agenda_clean.png'), fullPage: true });

    console.log('URL actual:', page.url());
    console.log('Saved: clinicweb_agenda_clean_texts.json');
    console.log('Saved: clinicweb_agenda_clean_nodes.json');
    console.log('Saved: clinicweb_agenda_clean.html');
    console.log('Saved: clinicweb_agenda_clean.png');

    await browser.close();
  } finally {
    await db.close();
  }
})().catch((err) => {
  console.error(err);
  process.exit(1);
});
