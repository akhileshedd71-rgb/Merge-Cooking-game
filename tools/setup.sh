#!/usr/bin/env bash
# Install the pinned engine and supported export templates without root access.
set -euo pipefail

GODOT_VERSION=4.6.3
GODOT_TAG="${GODOT_VERSION}-stable"
TOOLS_ROOT="${LWK_TOOLS_ROOT:-/workspace/.local}"
DOWNLOAD_ROOT="${LWK_DOWNLOAD_ROOT:-/workspace/.cache/godot-downloads}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-${TOOLS_ROOT}/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-/workspace/.cache}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-/workspace/.config}"
RELEASE_URL="https://github.com/godotengine/godot-builds/releases/download/${GODOT_TAG}"
mkdir -p "${TOOLS_ROOT}/bin" "${DOWNLOAD_ROOT}" "${XDG_CACHE_HOME}/fontconfig" "${XDG_DATA_HOME}/godot/export_templates" "${XDG_CONFIG_HOME}"

for required in curl unzip sha512sum python3; do
  command -v "${required}" >/dev/null || { printf 'Missing prerequisite: %s\n' "${required}" >&2; exit 1; }
done

# The expected hashes are the release's official SHA512-SUMS.txt entries.
ENGINE_HASH=a035258da32b77f966a5376f9fa29c30a6adde826a85ba918e1605bd1fc9823eba7d85f1dd5e748956bd2ba72827c0025ffa11bb82aec91128c407a2e723c99c
TEMPLATES_HASH=da606b61c10157844f8300172df374472665f95015495cb1a7cd132c40ede404faa96cc1016a4b9662db9909ddea69632c4948b2cd11163438dad4808881fb68

download_verified() {
  local name="$1" expected="$2" archive="${DOWNLOAD_ROOT}/$1"
  if [[ -f "${archive}" ]] && printf '%s  %s\n' "${expected}" "${archive}" | sha512sum --check --status; then
    printf 'Using verified archive: %s\n' "${name}"
  else
    curl --fail --location --retry 2 --show-error "${RELEASE_URL}/${name}" -o "${archive}.part"
    printf '%s  %s\n' "${expected}" "${archive}.part" | sha512sum --check --status
    mv "${archive}.part" "${archive}"
  fi
}

GODOT_BIN="${TOOLS_ROOT}/bin/godot"
if [[ ! -x "${GODOT_BIN}" ]]; then GODOT_BIN="$(command -v godot || true)"; fi
if [[ -z "${GODOT_BIN}" ]] || [[ "$("${GODOT_BIN}" --version 2>/dev/null)" != "${GODOT_VERSION}.stable."* ]]; then
  if [[ "$(uname -s)" != Linux || "$(uname -m)" != x86_64 ]]; then
    printf 'Install Godot %s for this platform from https://godotengine.org/download/\n' "${GODOT_VERSION}" >&2
    exit 1
  fi
  engine="Godot_v${GODOT_TAG}_linux.x86_64.zip"
  download_verified "${engine}" "${ENGINE_HASH}"
  unzip -oq "${DOWNLOAD_ROOT}/${engine}" -d "${TOOLS_ROOT}/bin"
  chmod +x "${TOOLS_ROOT}/bin/Godot_v${GODOT_TAG}_linux.x86_64"
  ln -sfn "Godot_v${GODOT_TAG}_linux.x86_64" "${TOOLS_ROOT}/bin/godot"
  GODOT_BIN="${TOOLS_ROOT}/bin/godot"
fi
printf 'Engine: %s (%s)\n' "${GODOT_BIN}" "$("${GODOT_BIN}" --version)"

templates="Godot_v${GODOT_TAG}_export_templates.tpz"
template_dir="${XDG_DATA_HOME}/godot/export_templates/${GODOT_VERSION}.stable"
download_verified "${templates}" "${TEMPLATES_HASH}"
mkdir -p "${template_dir}"
# These are the project targets. Keep other platforms out of the cloud snapshot.
unzip -ojq "${DOWNLOAD_ROOT}/${templates}" \
  templates/version.txt templates/web_debug.zip templates/web_release.zip \
  templates/web_nothreads_debug.zip templates/web_nothreads_release.zip \
  templates/linux_debug.x86_64 templates/linux_release.x86_64 \
  templates/android_debug.apk templates/android_release.apk \
  -d "${template_dir}"
printf 'Templates ready: %s\nSetup complete. Run tools/build.sh to import and export.\n' "${template_dir}"
