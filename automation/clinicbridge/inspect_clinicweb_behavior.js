const fs = require('fs');
const path = require('path');
const { chromium } = require('playwright');

(async () => {
  const loginUrl = 'https://professional.cliniweb.com/inicio_sesion.aspx?ReturnUrl=%2f';
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();

  await page.goto(loginUrl, { waitUntil: 'networkidle' });

  const details = await page.evaluate(() => {
    const user = document.querySelector('#txt_usuario');
    const pass = document.querySelector('#txt_password');
    const btn = document.querySelector('#btn_iniciar');

    function attrs(el) {
      if (!el) return null;
      const out = {};
      for (const attr of el.attributes) {
        out[attr.name] = attr.value;
      }
      return out;
    }

    return {
      user: attrs(user),
      pass: attrs(pass),
      button: attrs(btn),
    };
  });

  const outDir = process.cwd();
  fs.writeFileSync(path.join(outDir, 'clinicweb_behavior_details.json'), JSON.stringify(details, null, 2));
  console.log('Saved: clinicweb_behavior_details.json');

  await browser.close();
})().catch((err) => {
  console.error(err);
  process.exit(1);
});
