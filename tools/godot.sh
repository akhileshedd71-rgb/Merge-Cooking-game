#!/usr/bin/env bash
set -euo pipefail
export XDG_DATA_HOME="${XDG_DATA_HOME:-/workspace/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-/workspace/.cache}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-/workspace/.config}"
mkdir -p "${XDG_DATA_HOME}" "${XDG_CONFIG_HOME}" "${XDG_CACHE_HOME}/fontconfig"
LWK_GODOT_BIN="${GODOT_BIN:-${LWK_TOOLS_ROOT:-/workspace/.local}/bin/godot}"
if [[ ! -x "${LWK_GODOT_BIN}" ]]; then LWK_GODOT_BIN="$(command -v godot || true)"; fi
if [[ -z "${LWK_GODOT_BIN}" ]]; then printf 'Godot is missing. Run tools/setup.sh first.\n' >&2; exit 1; fi
exec "${LWK_GODOT_BIN}" "$@"
