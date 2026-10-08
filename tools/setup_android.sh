#!/usr/bin/env bash
# Install the official Android SDK and configure Godot for development APKs.
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export XDG_DATA_HOME="${XDG_DATA_HOME:-/workspace/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-/workspace/.cache}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-/workspace/.config-android}"
export ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-/workspace/.android-sdk}"
export ANDROID_USER_HOME="${ANDROID_USER_HOME:-/workspace/.android-user}"
for command in curl python3 java keytool; do
  command -v "${command}" >/dev/null || { printf 'Missing required tool: %s\n' "${command}" >&2; exit 1; }
done
if [[ -z "${JAVA_HOME:-}" ]]; then
  export JAVA_HOME="$(dirname "$(dirname "$(readlink -f "$(command -v java)")")")"
fi
mkdir -p "${ANDROID_SDK_ROOT}/cmdline-tools" "${ANDROID_USER_HOME}" "${XDG_CACHE_HOME}/android-sdk" "${XDG_CONFIG_HOME}/godot" "${XDG_DATA_HOME}/godot/keystores"

ANDROID_CLI="${ANDROID_SDK_ROOT}/cmdline-tools/19.0/bin/sdkmanager"
if [[ ! -x "${ANDROID_CLI}" ]]; then
  ANDROID_ARCHIVE="${XDG_CACHE_HOME}/android-sdk/commandlinetools-linux-13114758_latest.zip"
  curl --fail --location --show-error --silent \
    https://dl.google.com/android/repository/commandlinetools-linux-13114758_latest.zip \
    --output "${ANDROID_ARCHIVE}"
  python3 - "${ANDROID_ARCHIVE}" "${ANDROID_SDK_ROOT}" <<'PY'
import hashlib
from pathlib import Path
import sys
import tempfile
import zipfile

archive, sdk = map(Path, sys.argv[1:])
# Published by Google's HTTPS repository2-1.xml for commandline-tools 19.0.
expected_sha1 = "5fdcc763663eefb86a5b8879697aa6088b041e70"
if hashlib.sha1(archive.read_bytes()).hexdigest() != expected_sha1:
    raise SystemExit("Android command-line tools checksum verification failed")
with tempfile.TemporaryDirectory(dir=sdk / "cmdline-tools") as stage:
    with zipfile.ZipFile(archive) as package:
        package.extractall(stage)
    Path(stage, "cmdline-tools").rename(sdk / "cmdline-tools/19.0")
for executable in (sdk / "cmdline-tools/19.0/bin").iterdir():
    executable.chmod(0o755)
print("Official Android command-line tools archive checksum verified.")
PY
fi

# sdkmanager verifies the Google repository packages. Respect inherited proxy
# routing and JVM/system CA trust; never use --no_https or disable TLS checks.
python3 - "${ANDROID_CLI}" <<'PY'
import os
import subprocess
import sys
import urllib.parse

sdk = os.environ["ANDROID_SDK_ROOT"]
command = [sys.argv[1], "--sdk_root=" + sdk,
           "platform-tools", "build-tools;35.0.1", "platforms;android-35"]
proxy = urllib.parse.urlparse(os.environ.get("HTTPS_PROXY", os.environ.get("https_proxy", "")))
if proxy.hostname:
    command += ["--proxy=http", "--proxy_host=" + proxy.hostname,
                "--proxy_port=" + str(proxy.port or 80)]
# Running this setup accepts the licenses of the requested Android SDK packages.
subprocess.run(command, input="y\n" * 100, text=True, check=True)
PY

ANDROID_DEBUG_KEY="${XDG_DATA_HOME}/godot/keystores/debug.keystore"
if [[ ! -f "${ANDROID_DEBUG_KEY}" ]]; then
  keytool -genkeypair -noprompt -keystore "${ANDROID_DEBUG_KEY}" \
    -alias androiddebugkey -storepass android -keypass android \
    -keyalg RSA -keysize 2048 -validity 10000 \
    -dname 'CN=Android Debug,O=Android,C=US'
fi

python3 - <<'PY'
import json
import os
from pathlib import Path
import re

settings = Path(os.environ["XDG_CONFIG_HOME"]) / "godot/editor_settings-4.6.tres"
text = settings.read_text() if settings.exists() else '[gd_resource type="EditorSettings" format=3]\n\n[resource]\n'
values = {
    "export/android/java_sdk_path": os.environ["JAVA_HOME"],
    "export/android/android_sdk_path": os.environ["ANDROID_SDK_ROOT"],
    "export/android/debug_keystore": str(Path(os.environ["XDG_DATA_HOME"]) / "godot/keystores/debug.keystore"),
}
for key, value in values.items():
    line = key + " = " + json.dumps(value)
    pattern = r"^" + re.escape(key) + r" = .*?$"
    text = re.sub(pattern, lambda _: line, text, flags=re.M) if re.search(pattern, text, re.M) else text.rstrip() + "\n" + line + "\n"
settings.write_text(text)
print("Godot Android SDK, Java, and development keystore configured.")
PY

mkdir -p "${PROJECT_ROOT}/build/android"
printf 'Android SDK ready. Export a development APK with:\n  XDG_CONFIG_HOME="%s" ANDROID_USER_HOME="%s" tools/godot.sh --headless --path "%s" --export-debug Android build/android/little-world-kitchen.apk\n' "${XDG_CONFIG_HOME}" "${ANDROID_USER_HOME}" "${PROJECT_ROOT}"
