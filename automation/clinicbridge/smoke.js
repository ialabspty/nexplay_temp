const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({ headless: false });
  const page = await browser.newPage();
  await page.goto('https://example.com', { waitUntil: 'domcontentloaded' });
  console.log('Title:', await page.title());
  await browser.close();
})().catch((err) => {
  console.error(err);
  process.exit(1);
});
