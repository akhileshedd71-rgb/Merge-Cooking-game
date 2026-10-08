#!/usr/bin/env bash
set -euo pipefail
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_LINUX=false
BUILD_ANDROID=false
for option in "$@"; do
  case "$option" in
    --linux) BUILD_LINUX=true ;;
    --android) BUILD_ANDROID=true ;;
    *) printf 'Usage: tools/build.sh [--linux] [--android]\n' >&2; exit 2 ;;
  esac
done
cd "${PROJECT_ROOT}"
mkdir -p build/web build/linux
touch build/.gdignore
tools/godot.sh --headless --editor --path "${PROJECT_ROOT}" --import
tools/godot.sh --headless --path "${PROJECT_ROOT}" --export-release Web build/web/index.html
if [[ "${BUILD_LINUX}" == true ]]; then
  tools/godot.sh --headless --path "${PROJECT_ROOT}" --export-release "Linux" build/linux/little-world-kitchen.x86_64
fi
if [[ "${BUILD_ANDROID}" == true ]]; then
  mkdir -p build/android
  XDG_CONFIG_HOME="${LWK_ANDROID_CONFIG_HOME:-/workspace/.config-android}" \
    ANDROID_USER_HOME="${ANDROID_USER_HOME:-/workspace/.android-user}" \
    tools/godot.sh --headless --path "${PROJECT_ROOT}" --export-debug Android build/android/little-world-kitchen.apk
fi
printf 'Web build ready. Preview: python3 tools/serve.py\n'
