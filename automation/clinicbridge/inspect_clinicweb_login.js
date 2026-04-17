const fs = require('fs');
const path = require('path');
const { chromium } = require('playwright');
const dotenv = require('dotenv');

dotenv.config();

(async () => {
  const loginUrl = 'https://professional.cliniweb.com/inicio_sesion.aspx?ReturnUrl=%2f';
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();

  await page.goto(loginUrl, { waitUntil: 'networkidle' });

  const inputs = await page.$$eval('input', els =>
    els.map(el => ({
      tag: el.tagName,
      type: el.getAttribute('type'),
      id: el.getAttribute('id'),
      name: el.getAttribute('name'),
      value: el.getAttribute('value'),
      placeholder: el.getAttribute('placeholder'),
    }))
  );

  const buttons = await page.$$eval('button, input[type="submit"], input[type="button"]', els =>
    els.map(el => ({
      tag: el.tagName,
      type: el.getAttribute('type'),
      id: el.getAttribute('id'),
      name: el.getAttribute('name'),
      text: el.innerText || el.getAttribute('value') || null,
    }))
  );

  const html = await page.content();

  const outDir = process.cwd();
  fs.writeFileSync(path.join(outDir, 'clinicweb_login_elements.json'), JSON.stringify({ inputs, buttons }, null, 2));
  fs.writeFileSync(path.join(outDir, 'clinicweb_login.html'), html, 'utf8');
  await page.screenshot({ path: path.join(outDir, 'clinicweb_login.png'), fullPage: true });

  console.log('Saved: clinicweb_login_elements.json');
  console.log('Saved: clinicweb_login.html');
  console.log('Saved: clinicweb_login.png');

  await browser.close();
})().catch((err) => {
  console.error(err);
  process.exit(1);
});
