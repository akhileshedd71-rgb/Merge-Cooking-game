# Android development build

The cloud environment can export a signed development APK with Godot 4.6.3's
official Android template. No Gradle build or native engine compilation is needed.

## Build

From the repository root on Linux x86_64:

```bash
tools/setup.sh
tools/setup_android.sh
tools/build.sh --android
```

The APK is written to `build/android/little-world-kitchen.apk`. The last command
also refreshes the Web build. To export only Android after setup:

```bash
XDG_CONFIG_HOME=/workspace/.config-android \
ANDROID_USER_HOME=/workspace/.android-user \
tools/godot.sh --headless --path "$PWD" \
  --export-debug Android build/android/little-world-kitchen.apk
```

`setup_android.sh` is repeatable and keeps installed tools outside the checkout:

- Android SDK: `/workspace/.android-sdk` (override `ANDROID_SDK_ROOT`).
- SDK user files: `/workspace/.android-user` (override `ANDROID_USER_HOME`).
- Android editor settings: `/workspace/.config-android/godot` (override
  `XDG_CONFIG_HOME`). These are separate from Web/Linux editor settings to prevent
  concurrent exports from replacing the Android tool paths.
- Development key: `/workspace/.local/share/godot/keystores/debug.keystore`.

Required host tools are `bash`, `curl`, `python3`, Java, and `keytool`. This build
was validated with OpenJDK 21's runtime and `keytool`; the precompiled template
workflow does not invoke `javac`. A full JDK is needed if switching to a custom
Gradle build later.

## SDK and artifact integrity

Command-line tools 19.0 are downloaded from Google's official
`https://dl.google.com/android/repository/commandlinetools-linux-13114758_latest.zip`.
The setup verifies the SHA-1 checksum published in Google's HTTPS
`repository2-1.xml`: `5fdcc763663eefb86a5b8879697aa6088b041e70`.
Google's `sdkmanager` then installs and verifies `build-tools;35.0.1`,
`platforms;android-35`, and `platform-tools`. Platform Tools was version 37.0.1 in
this environment. Running the setup accepts the requested SDK package licenses.
The script respects the session HTTP proxy and standard Java/system CA trust;
TLS and archive verification remain enabled.

The Godot template already contains compiled Android code targeting SDK 36.
Godot uses the installed Build Tools 35.0.1 for signing/alignment and reports its
documented fallback when no matching 36.x directory exists. This standard APK
export succeeded and passed signature validation. Publishing or adding native
plugins should use a full JDK and the exact SDK/Gradle versions required by the
chosen Godot version.

Android export requires
`rendering/textures/vram_compression/import_etc2_astc=true` in `project.godot`.
Without that setting Godot 4.6.3 rejects the Android configuration without a
helpful message, even when the SDK and keystore are correct.

## Verified artifact

- Application: **Little World Kitchen**, package `com.littleworldkitchen.game`.
- Version: `0.1.0`, version code `1`.
- Minimum Android SDK: 24 (Android 7.0); target SDK: 36 (Android 16).
- Native architectures: `arm64-v8a` and `x86_64`.
- Development signing: RSA 2048, standard Android debug certificate.
- APK Signature Schemes v2 and v3: verified.
- 16 KB ZIP alignment, every native library's 16 KB ELF load alignment, and ZIP
  CRC checks: passed.
- Bundled content check: branded app icon, compiled game scripts, all 64 room
  variants present.
- Validated APK size: 59,993,229 bytes.
- Validated APK SHA-256:
  `5e5ec56c6161eab74e2f96dd7448cb83d52f29959a96b312eeae61ea6fc5648b`.

Hashes change when the game is rebuilt; the value above identifies the artifact
created during this implementation.

Recheck any rebuilt APK with:

```bash
/workspace/.android-sdk/build-tools/35.0.1/apksigner verify --verbose \
  build/android/little-world-kitchen.apk
/workspace/.android-sdk/build-tools/35.0.1/zipalign -c -P 16 4 \
  build/android/little-world-kitchen.apk
/workspace/.android-sdk/build-tools/35.0.1/aapt dump badging \
  build/android/little-world-kitchen.apk
sha256sum build/android/little-world-kitchen.apk
```

On a development machine with an authorized connected device:

```bash
adb install -r build/android/little-world-kitchen.apk
adb shell am start -n com.littleworldkitchen.game/com.godot.game.GodotAppLauncher
```

The generated APK is for local testing. It is not store-signed or published.
No Android device or emulator was attached to this cloud environment, so native
touch input, lifecycle/save recovery, and performance still need a device test.
