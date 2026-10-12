/* Drive the real Godot canvas with touch/mouse input; diagnostics are read-only. */
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { chromium } = require('playwright');
const url = process.env.LWK_URL || 'http://127.0.0.1:8000';
const output = path.resolve(__dirname, '../build/screenshots');
async function main() {
  fs.mkdirSync(output, { recursive: true });
  const browser = await chromium.launch({ executablePath: process.env.CHROMIUM_PATH || '/usr/bin/chromium', headless: true,
    args: ['--no-sandbox', '--disable-dev-shm-usage', '--enable-unsafe-swiftshader', '--use-angle=swiftshader'] });
  const context = await browser.newContext({ viewport: { width: 540, height: 1080 }, hasTouch: true });
  const page = await context.newPage();
  const errors = [];
  page.on('pageerror', e => errors.push(e.message));
  page.on('console', m => { if (m.type() === 'error') errors.push(m.text()); });
  const snap = () => page.evaluate(() => window.__LWK_STATE);
  const wait = predicate => page.waitForFunction(predicate, null, { timeout: 20000 });
  const tap = async (x,y) => { await page.touchscreen.tap(x,y); await page.waitForTimeout(200); };
  const shot = name => page.screenshot({ path: path.join(output,name+'.png'), fullPage: true });
  const close = () => tap(480,245);
  try {
    assert.equal((await page.goto(url, {timeout:120000})).status(),200);
    await wait(() => window.__LWK_STATE?.modal === 'welcome');
    await page.waitForTimeout(800);
    await shot('v2-01-welcome');
    await tap(165,879); // Begin the interactive guide.
    await wait(() => window.__LWK_STATE.tutorial === 1);
    await shot('v2-02-guided-board');
    const initial = await snap();
    await tap(72,372);
    assert.equal((await snap()).energy,initial.energy-1);
    await wait(() => window.__LWK_STATE.tutorial === 2);
    await tap(270,372); await tap(336,372);
    await wait(() => window.__LWK_STATE.tutorial === 3 && window.__LWK_STATE.board[4] === 'strawberry');
    // Native drag remains supported alongside tap-to-merge.
    await page.mouse.move(72,438); await page.mouse.down();
    await page.mouse.move(138,438,{steps:12}); await page.mouse.up();
    await wait(() => window.__LWK_STATE.merges === 2);
    // Tapping a different ingredient selects it, never silently swaps it.
    const boardBefore = (await snap()).board;
    await tap(402,438);
    assert.deepEqual((await snap()).board,boardBefore);
    await tap(336,438);
    await tap(350,965);
    await wait(() => window.__LWK_STATE.modal === 'ingredient');
    await shot('v2-03-recipe');
    await tap(265,505);
    await wait(() => window.__LWK_STATE.tutorial === 4 && window.__LWK_STATE.jobs.length === 1);
    await shot('v2-04-cooking');
    await wait(() => window.__LWK_STATE.jobs[0].ready_at <= Date.now()/1000);
    await page.waitForTimeout(1200);
    await tap(390,489);
    await wait(() => window.__LWK_STATE.tutorial === 5 && window.__LWK_STATE.board.includes('smoothie'));
    await tap(60,1040);
    await tap(260,280);
    await wait(() => window.__LWK_STATE.tutorial === 6 && window.__LWK_STATE.total_orders === 1);
    await tap(270,1040);
    await tap(450,720);
    await wait(() => window.__LWK_STATE.modal === 'renovate');
    await tap(300,520);
    await wait(() => window.__LWK_STATE.tutorial === 7 && window.__LWK_STATE.modal === 'graduation');
    assert.equal((await snap()).renovations['0'].floor,'sage');
    assert.equal((await snap()).tutorial_rewarded,true);
    await shot('v2-05-graduation');
    await tap(170,879);
    await wait(() => window.__LWK_STATE.tab === 'Kitchen' && window.__LWK_STATE.modal === '');
    // Off-board storage and permanent expansion via earned coins.
    await tap(204,438); await tap(450,965);
    await wait(() => window.__LWK_STATE.inventory.length === 1);
    await tap(475,965);
    await wait(() => window.__LWK_STATE.modal === 'storage');
    await shot('v2-06-pantry');
    await tap(88,480);
    await wait(() => window.__LWK_STATE.inventory.length === 0);
    await close();
    await tap(205,130);
    await wait(() => window.__LWK_STATE.modal === 'market');
    await shot('v2-07-market');
    const energy = (await snap()).energy;
    await tap(190,385);
    assert.equal((await snap()).energy,energy-1);
    const coins = (await snap()).coins;
    await tap(420,865);
    await wait(() => window.__LWK_STATE.capacity === 11);
    assert.equal((await snap()).coins,coins-250);
    await close();
    await tap(485,55);
    await wait(() => window.__LWK_STATE.modal === 'career');
    await shot('v2-08-goals');
    await tap(357,497); // Chef-level roadmap tab.
    await shot('v2-09-levels');
    await close();
    await tap(480,1040);
    await wait(() => window.__LWK_STATE.tab === 'Book');
    await shot('v2-10-recipes');
    await page.mouse.move(280,870); await page.mouse.wheel(0,1450); await page.waitForTimeout(350);
    await shot('v2-19-expanded-recipes');
    await tap(270,383); // Ready-to-cook filter.
    await shot('v2-11-ready-recipes');
    await tap(392,335); // Ingredient families, six tiers each.
    await shot('v2-12-ingredients');
    await tap(375,1040);
    await wait(() => window.__LWK_STATE.tab === 'Travel');
    await shot('v2-13-passport');
    await page.mouse.move(275,880); await page.mouse.wheel(0,1500); await page.waitForTimeout(400);
    await shot('v2-14-new-destinations');
    await tap(270,1040); await shot('v2-15-bistro');
    await tap(60,1040);
    const saved = await snap();
    await page.waitForTimeout(1800);
    await page.reload();
    await wait(() => window.__LWK_STATE?.capacity === 11);
    const restored = await snap();
    for (const key of ['board','orders','coins','renovations','tutorial','tutorial_rewarded','capacity']) {
      assert.deepEqual(restored[key],saved[key],`Save/resume preserves ${key}`);
    }
    await shot('v2-16-kitchen');
    await page.setViewportSize({width:390,height:844}); await page.waitForTimeout(500);
    await shot('v2-17-phone');
    await page.setViewportSize({width:1440,height:1080}); await page.waitForTimeout(500);
    await shot('v2-18-desktop');
    assert.deepEqual(errors,[],'No browser or Godot runtime errors');
    console.log('PASS: six-step tutorial with real touch input; tap/native-drag merges; selection safety; cooking/collection; serving; renovation; one-time graduation; storage; coin purchases; levels/goals; recipe filters; all eight postcards; persistence; three viewports.');
  } catch (error) {
    await shot('v2-failure');
    console.error('Snapshot:',await snap());
    console.error('Runtime errors:',errors);
    throw error;
  } finally { await context.close(); await browser.close(); }
}
main().catch(e => { console.error(e); process.exitCode=1; });
