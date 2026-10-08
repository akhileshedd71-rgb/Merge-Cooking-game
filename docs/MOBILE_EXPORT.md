# Mobile export

The game uses a 540 × 1080 portrait design space, stretch-aware controls, and touch/mouse input. The single-threaded Web export is the fastest way to try the game on a phone. A native app uses the same Godot project and state model.

## Android

An `Android` export preset is included for ARM64 phones and x86_64 emulators. It uses the Godot APK template and does not require a custom Gradle build. The package ID `com.littleworldkitchen.game` is a placeholder that should be changed to an identifier you control before publishing. The built development APK supports Android 7.0/API 24 and newer and declares target API 36.

### Build in this cloud workspace

```bash
tools/setup.sh
tools/setup_android.sh
tools/build.sh --android
```

`setup_android.sh` installs official checksum-verified command-line tools, uses the SDK manager to install Platform-Tools, Build-Tools 35.0.1, and Android Platform 35, and creates a local development keystore outside the repository. Its machine settings use `/workspace/.config-android` to avoid interference with desktop editor settings. Running the setup accepts the requested Android SDK package licenses.

The result is `build/android/little-world-kitchen.apk`, signed for development/sideloading. The export, APK signature verification, archive integrity, and 16 KB ZIP alignment checks passed; installation and play on a physical device have not been tested. See [the build notes](ANDROID_BUILD_NOTES.md) for exact local configuration.

### Configure another development machine

1. Install Godot 4.6.3 standard editor and matching export templates (`tools/setup.sh` installs the Android templates in this cloud environment).
2. Install OpenJDK 17 (recommended by Godot; higher JDK versions are supported).
3. Install the official Android SDK. [Godot 4.6's Android export guide](https://docs.godotengine.org/en/4.6/tutorials/export/exporting_for_android.html) lists the following full toolchain (this project's non-Gradle APK export needs only the first three packages):

   ```bash
   sdkmanager --sdk_root=/path/to/android-sdk \
     "platform-tools" "build-tools;35.0.1" "platforms;android-35" \
     "cmdline-tools;latest" "cmake;3.10.2.4988404" "ndk;28.1.13356709"
   ```

4. In **Editor → Editor Settings → Export → Android**, set **Java SDK Path** and **Android SDK Path**. These are machine settings, not source-controlled project settings.
5. Connect an Android device with USB debugging or start an emulator. Export a debug APK using **Project → Export → Android**, or:

   ```bash
   mkdir -p build/android
   godot --headless --path . --export-debug Android build/android/little-world-kitchen.apk
   adb install -r build/android/little-world-kitchen.apk
   ```

Godot must have a configured debug keystore for debug export. Keep keystores and their passwords outside the repository. Before Play Store submission, configure a release key securely, switch to an AAB/Gradle export, set an owned package ID and version, provide store graphics and adaptive icons, and test on physical devices.

The preset's **Runnable** flag is disabled to avoid background ADB device discovery during cloud exports. Enable it in your local editor if you want Godot's one-click device deployment; command-line APK export and `adb install` work regardless of that flag.

The app currently needs no network permission. There is no billing, advertising, analytics, backend, or user login. Do not enable permissions solely for future features.

## iOS

iOS export requires a Mac with Xcode, matching Godot 4.6.3 iOS templates, an Apple developer team, a bundle identifier, and signing/provisioning configuration. Add an iOS preset in Godot on that machine and complete the export in Xcode. No iOS preset with invented team identifiers or signing credentials is included.

## Device checks before release

- Confirm portrait layouts and readable text on short screens, narrow phones, and tablets.
- Play through drag, tap-to-merge, storage, cooking, orders, renovation, and travel.
- Close and reopen the app; verify saved progress and elapsed cooking/energy timers.
- Check the safe area around notches, system gestures, keyboard interaction, and back navigation.
- Measure frame rate, memory, startup time, and battery use on a lower-end Android device.
- Test interruption by calls, app switching, mute/volume controls, and offline launch.

Cloud browser validation is useful evidence, but it does not replace native device validation.
