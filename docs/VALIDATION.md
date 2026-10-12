# Validation

## Reproduce

Use Godot 4.6.3 with the matching export templates:

```bash
tools/setup.sh
tools/setup_android.sh
tools/build.sh --linux --android
python3 tools/serve.py --port 8000
```

In a second terminal, run the browser checks:

```bash
npm_config_cache=/workspace/.cache/npm npm ci --prefix tools --ignore-scripts
node tools/browser_smoke.cjs
```

The browser script performs real touch and mouse input for spawning, tap/drag merges, customer fulfillment, storage, timed cooking and collection, renovation, daily rewards, and navigation. It reloads the page and checks the exact saved board, coins, orders, and renovation. It also checks browser/Godot errors and layouts at 540 × 1080, 390 × 844, and 1440 × 1080. Screenshots are saved to `build/screenshots/`. Chromium can be selected using `CHROMIUM_PATH`; the server URL defaults to `http://127.0.0.1:8000` and can be changed with `LWK_URL`.

The Android development export and its packaging verification are documented in [MOBILE_EXPORT.md](MOBILE_EXPORT.md). Physical-device checks and native iOS export require additional platform tooling and devices; they are not established by a successful browser test or package build.

## Automated game rules

The `tests/` directory contains headless state-model checks for spawning, merges, storage, timed cooking, order rewards, renovation, travel, and persistence. Scene checks instantiate the actual interface and exercise input, modal blocking, and navigation.

```bash
tools/godot.sh --headless --path . --script tests/test_game.gd
tools/godot.sh --headless --path . --script tests/test_ui.gd
tools/godot.sh --headless --path . --script tests/test_expansion.gd
```

- **423 game rule checks:** passed, zero failures.
- **20 scene/interface checks:** passed, zero failures.
- **1,160 expansion checks:** passed, including all five merge chains, recipe gates, two-ingredient consumption, all 20 levels’ order pools, tutorial resume/rewards, shop limits, and migration from a real version-1 save.
- **Godot Web and Linux release exports:** passed; the Linux executable also passed a headless startup check.
- **Chromium gameplay and save/reload smoke:** passed, including the complete six-step tutorial using real touch input, native drag, recipe filters, supplier/shop screens, storage expansion, levels/goals, eight illustrated destinations, and three viewport sizes.
- **Development Android APK:** exported, signed, ZIP CRC checked, and 16 KB alignment verified. ARM64 and x86_64; minimum API 24, target API 36. Not yet installed or played on a physical device.

These checks establish a functioning first playable loop. They do not establish store readiness, native iOS support, or physical-device performance.

The Linux cloud startup check uses writable application storage:

```bash
XDG_DATA_HOME=/workspace/.local/share XDG_CACHE_HOME=/workspace/.cache XDG_CONFIG_HOME=/workspace/.config \
  ./build/linux/little-world-kitchen.x86_64 --headless --quit-after 10 -- --fresh
```

Version 0.2.0 native packaging: Android version code 2, package `com.littleworldkitchen.game`; APK signature v2/v3, 16 KB ZIP alignment, and archive CRC checks passed. No physical Android device was attached.
