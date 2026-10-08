/* Optional real-browser checks for the exported Godot canvas. */
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { chromium } = require('playwright');

const url = process.env.LWK_URL || 'http://127.0.0.1:8000';
const screenshots = path.resolve(__dirname, '../build/screenshots');
const executablePath = process.env.CHROMIUM_PATH ||
  (fs.existsSync('/usr/bin/chromium') ? '/usr/bin/chromium' : undefined);

async function main() {
  fs.mkdirSync(screenshots, { recursive: true });
  const browser = await chromium.launch({
    executablePath,
    headless: true,
    args: ['--no-sandbox', '--disable-dev-shm-usage', '--enable-unsafe-swiftshader', '--use-angle=swiftshader'],
  });
  const issues = [];
  const context = await browser.newContext({ viewport: { width: 540, height: 1080 }, deviceScaleFactor: 1, hasTouch: true });
  const page = await context.newPage();
  page.on('pageerror', error => issues.push(`JavaScript: ${error.message}`));
  page.on('console', message => {
    if (message.type() === 'error') issues.push(`Console: ${message.text()}`);
  });
  const snapshot = () => page.evaluate(() => window.__LWK_STATE);
  const expectState = async (predicate, description) => {
    await page.waitForFunction(predicate, null, { timeout: 15000 });
    assert.ok(await snapshot(), description);
  };
  const tap = async (x, y) => {
    await page.touchscreen.tap(x, y);
    await page.waitForTimeout(180);
  };
  const screenshot = name => page.screenshot({ path: path.join(screenshots, name), fullPage: true });
  try {
    const response = await page.goto(url, { waitUntil: 'domcontentloaded', timeout: 120000 });
    assert.equal(response.status(), 200, 'The web export should respond successfully');
    await page.locator('#canvas').waitFor({ state: 'visible', timeout: 120000 });
    await page.waitForFunction(() => {
      const canvas = document.querySelector('#canvas');
      const status = document.querySelector('#status');
      return canvas && canvas.width > 0 && canvas.height > 0 &&
        (!status || getComputedStyle(status).display === 'none' || getComputedStyle(status).visibility === 'hidden');
    }, null, { timeout: 120000 });
    await page.waitForTimeout(1500);
    await expectState(() => window.__LWK_STATE?.board?.length === 63, 'The game state should contain its full board');
    await screenshot('01-kitchen-portrait.png');
    const portrait = await page.locator('#canvas').boundingBox();
    assert.ok(portrait && portrait.width > 300 && portrait.height > 600, 'The portrait canvas should fill a phone viewport');

    const initial = await snapshot();
    await tap(72, 372); // Fruit generator: a real touch event.
    const generated = await snapshot();
    assert.equal(generated.energy, initial.energy - 1, 'A generator tap should consume exactly one energy');
    assert.equal(generated.board.filter(item => item === '').length, initial.board.filter(item => item === '').length - 1);
    await tap(270, 372);
    await tap(336, 372);
    await expectState(() => window.__LWK_STATE.merges === 1, 'Tap-to-merge should upgrade the cherries');
    assert.equal((await snapshot()).board[4], 'strawberry');

    // Mouse drag uses the same input route as dragging an item on desktop.
    await page.mouse.move(72, 438);
    await page.mouse.down();
    await page.mouse.move(138, 438, { steps: 12 });
    await page.waitForTimeout(150);
    await page.mouse.up();
    await expectState(() => window.__LWK_STATE.merges === 2, 'A drag should merge the strawberries');
    assert.equal((await snapshot()).board[8], 'banana');
    await screenshot('04-merged-board.png');

    await tap(95, 304); // Serve the first ready customer.
    await expectState(() => window.__LWK_STATE.total_orders === 1, 'Serving should record an order');
    assert.ok((await snapshot()).coins > initial.coins, 'Serving should pay coins');

    await tap(138, 438); // Deselect the banana left selected after dragging.
    await tap(204, 438); // Bread.
    await tap(451, 965); // Store.
    await expectState(() => window.__LWK_STATE.inventory.length === 1, 'Store should move an ingredient off the board');
    await tap(475, 965); // Bag.
    await expectState(() => window.__LWK_STATE.modal === 'storage', 'The storage tray should open');
    await screenshot('05-pantry.png');
    await tap(88, 483); // Return the first stored item.
    await expectState(() => window.__LWK_STATE.inventory.length === 0, 'An item should return from storage');
    await tap(480, 247); // Close.

    await tap(138, 438); // Banana.
    await tap(351, 965); // Cook selected ingredient.
    await expectState(() => window.__LWK_STATE.modal === 'ingredient', 'The matching recipe should open');
    await tap(270, 484); // Cook banana smoothie.
    await expectState(() => window.__LWK_STATE.jobs.length === 1 && window.__LWK_STATE.tab === 'Cook', 'Cooking should consume an ingredient and start its timer');
    assert.equal((await snapshot()).jobs[0].output, 'smoothie');
    await screenshot('06-cooking.png');

    await tap(270, 1040); // Bistro, while cooking continues.
    await expectState(() => window.__LWK_STATE.tab === 'Bistro', 'The bistro tab should open');
    await tap(452, 716); // Renovate floor.
    await expectState(() => window.__LWK_STATE.modal === 'renovate', 'Renovation should offer styles');
    await tap(303, 519); // Choose sage.
    await expectState(() => window.__LWK_STATE.renovations['0'].floor === 'sage', 'Stars should purchase the selected renovation');
    assert.equal((await snapshot()).stars, 1, 'A floor renovation should spend two stars after one order');
    await screenshot('07-bistro.png');

    await tap(165, 1040);
    await page.waitForFunction(() => window.__LWK_STATE.jobs[0].ready_at <= Date.now() / 1000 - 1, null, { timeout: 15000 });
    await page.waitForTimeout(1000); // Let the on-screen button switch from boost to collect.
    await tap(388, 490);
    await expectState(() => window.__LWK_STATE.jobs.length === 0 && window.__LWK_STATE.board.includes('smoothie'), 'A completed dish should be collected onto the board');
    await tap(60, 1040);
    await tap(261, 304); // The second customer requests the smoothie.
    await expectState(() => window.__LWK_STATE.total_orders === 2, 'The cooked dish should fulfill its customer order');

    await tap(450, 132);
    await expectState(() => window.__LWK_STATE.modal === 'gift', 'The daily gift should open');
    const beforeGift = await snapshot();
    await tap(270, 851);
    await expectState(() => window.__LWK_STATE.modal === '', 'Claiming the gift should close the sheet');
    assert.ok((await snapshot()).coins > beforeGift.coins, 'The daily gift should reward coins');
    await tap(375, 1040);
    await expectState(() => window.__LWK_STATE.tab === 'Travel', 'The travel tab should open');
    await screenshot('08-travel.png');
    await tap(480, 1040);
    await expectState(() => window.__LWK_STATE.tab === 'Book', 'The recipe notebook should open');
    await screenshot('09-notebook.png');

    const beforeReload = await snapshot();
    await page.waitForTimeout(1800); // Allow the browser-backed save filesystem to flush.
    await page.reload({ waitUntil: 'domcontentloaded' });
    await expectState(() => window.__LWK_STATE?.merges === 2, 'Saved merges should survive reloading');
    const restored = await snapshot();
    assert.equal(restored.coins, beforeReload.coins, 'Reload should preserve earned coins');
    assert.equal(restored.total_orders, 2, 'Reload should preserve completed orders');
    assert.equal(restored.renovations['0'].floor, 'sage', 'Reload should preserve renovation style');
    assert.deepEqual(restored.board, beforeReload.board, 'Reload should preserve the exact board');

    // A resize exercises the game's layout in a common narrow phone viewport.
    await page.setViewportSize({ width: 390, height: 844 });
    await page.waitForTimeout(600);
    await screenshot('02-kitchen-phone.png');
    const narrow = await page.locator('#canvas').boundingBox();
    assert.ok(narrow && narrow.width <= 391 && narrow.height <= 845, 'The canvas must stay within the mobile viewport');

    await page.setViewportSize({ width: 1440, height: 1080 });
    await page.waitForTimeout(600);
    await screenshot('03-kitchen-desktop.png');
    assert.deepEqual(issues, [], 'The game should start and resize without browser or Godot errors');
    console.log(`PASS: Web startup; touch spawning; tap and drag merges; serving; storage; timed cooking and collection; renovation; daily gift; all navigation tabs; save/reload; portrait/narrow/desktop rendering. Screenshots: ${screenshots}`);
  } finally {
    await context.close();
    await browser.close();
  }
}

main().catch(error => { console.error(error); process.exitCode = 1; });
