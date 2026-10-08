# Little World Kitchen

An original, cozy portrait game built in **Godot 4.6.3** with GDScript. Merge fresh ingredients, cook little dishes, serve your neighbors, and give a café a new beginning. Designed for touch, with mouse support for development and a browser preview.

## Play

1. Tap a fruit basket, garden crate, or pantry on the board to create an ingredient. Each costs one energy.
2. Drag two matching ingredients together, or tap an ingredient and then its match. Merges reveal higher ingredients and clear adjacent dusty tiles.
3. Open the kitchen to turn ingredients into dishes. Seven appliances have short timers; finished food waits safely for collection.
4. Serve ready customer orders to earn coins, stars, and experience.
5. Use stars to renovate the café, choose a style, and unlock the next city.

The board has 63 cells (7 columns × 9 rows), three ingredient chains, seven concurrent orders, and ten storage slots. Recipes, travel, café renovation, daily gifts, save/resume, sound controls, and an in-game guide are included. New York, Bangkok, Tokyo, and Paris each have a story and café progress. Energy restores over time; there are no ads, purchases, accounts, or monetization SDKs.

This is a playable first version. Native store publishing, production balancing, localization, cloud saves, and device-fleet testing remain future work. The screenshots supplied for the brief were references for the genre; this project's branding, interface, and artwork are original.

## Run with Godot

Install the standard (non-.NET) **Godot 4.6.3** editor, import `project.godot`, and press **F5** to play. The renderer is GL Compatibility. There are no Godot plugins or external runtime packages.

On this cloud workspace:

```bash
cd /workspace/Merge-Cooking-game
tools/setup.sh
tools/godot.sh --headless --editor --path . --import
```

`setup.sh` uses the installed matching engine when available, otherwise downloads the pinned official Linux x86_64 engine. It verifies official SHA-512 hashes and installs Web, Linux, and Android templates into `/workspace/.local/share/godot/export_templates/4.6.3.stable`. Its archive cache lives under `/workspace/.cache`, with editor settings under `/workspace/.config`. Override `LWK_TOOLS_ROOT`, `LWK_DOWNLOAD_ROOT`, `XDG_DATA_HOME`, `XDG_CONFIG_HOME`, and `XDG_CACHE_HOME` to use other writable locations.

## Browser preview

```bash
tools/build.sh
python3 tools/serve.py --port 8000
```

Open **http://localhost:8000**. Web export uses a single-threaded WebAssembly engine and works with a normal static web host. The local server supplies WebAssembly MIME types and cross-origin headers. Deploy over HTTPS when accessing from a phone; `localhost` works for desktop development. The entire `build/web/` folder must be kept together.

For an additional Linux executable:

```bash
tools/build.sh --linux
./build/linux/little-world-kitchen.x86_64
```

For a development Android APK in this Linux cloud workspace:

```bash
tools/setup_android.sh
tools/build.sh --android
```

The APK is written to `build/android/little-world-kitchen.apk`. It is signed with a generated development key for sideloading. The SDK and private local development key are kept outside the repository. See [Android build notes](docs/ANDROID_BUILD_NOTES.md) for requirements and verification.

Exports and imported assets are generated under ignored `build/` and `.godot/` directories. No downloaded engine, templates, or dependency folders need to be committed.

## Validation

The automated suite passes **196 gameplay checks** and **20 scene checks**. See [validation](docs/VALIDATION.md) for commands, real-browser gameplay/save checks, and verified scope.

Browser checks are optional developer tooling, separate from the game's runtime:

```bash
npm_config_cache=/workspace/.cache/npm npm ci --prefix tools --ignore-scripts
node tools/browser_smoke.cjs
```

Start the preview server first. The script uses `/usr/bin/chromium` when available; otherwise install a Playwright Chromium browser with `cd tools && npx playwright install chromium`. Override `LWK_URL` or `CHROMIUM_PATH` as needed. Screenshots are written under `build/screenshots/`.

## Mobile builds and project structure

[Mobile export instructions](docs/MOBILE_EXPORT.md) cover Android and iOS requirements. A development Android APK has been exported and its signing, ZIP integrity, and 16 KB alignment verified. Physical Android device testing remains outstanding. iOS requires macOS and Xcode; no iOS app or store release has been built.

| Location | Purpose |
| --- | --- |
| `project.godot`, `main.tscn` | Portrait viewport, renderer, and main scene |
| `scripts/game_state.gd` | Board, recipes, orders, economy, travel, and persistence |
| `scripts/` | Runtime interface, interactions, and audio |
| `assets/` | Original art and licensed fonts |
| `tests/` | Headless gameplay validation |
| `tools/` | Setup, export, preview server, and browser checks |
| `docs/` | Mobile export, design notes, validation, and credits |

Save data stays on the device in Godot's `user://` storage. In a browser this uses local browser storage; clearing site data removes progress. See [credits](docs/CREDITS.md) for third-party licenses.
