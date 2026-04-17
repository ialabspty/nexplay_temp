// Huli Practice adapter skeleton for Playwright
// This file is a starting point for real browser automation.

async function loginHuli(page, { loginUrl, loginIdentifier, password }) {
  await page.goto(loginUrl, { waitUntil: 'networkidle' });

  // TODO: adjust selectors to the real Huli Practice login page.
  await page.fill('input[type="email"], input[name="email"], input[name="username"]', loginIdentifier);
  await page.fill('input[type="password"], input[name="password"]', password);
  await page.click('button[type="submit"], button:has-text("Iniciar"), button:has-text("Login")');

  // TODO: replace with a real post-login assertion.
  await page.waitForLoadState('networkidle');
}

async function navigateToSchedule(page) {
  // TODO: adjust to real Huli navigation.
  // Example placeholders:
  // await page.click('a:has-text("Agenda")');
  // await page.waitForLoadState('networkidle');
}

async function ensureDoctorContext(page, doctorName) {
  // TODO: if the account can see multiple doctors, switch/select the correct one.
}

async function selectPeriod(page, { periodType = 'weekly', targetDate }) {
  // TODO: adjust to the actual period controls in Huli.
}

async function extractHuliSchedule(page, { periodType, targetDate }) {
  await navigateToSchedule(page);
  await selectPeriod(page, { periodType, targetDate });

  // TODO: replace these placeholders with real extraction logic.
  const availableSlots = 0;
  const bookedSlots = 0;
  const cancelledSlots = 0;
  const noShowCount = 0;

  return {
    availableSlots,
    bookedSlots,
    cancelledSlots,
    noShowCount,
  };
}

module.exports = {
  loginHuli,
  navigateToSchedule,
  ensureDoctorContext,
  selectPeriod,
  extractHuliSchedule,
};
