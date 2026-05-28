#!/usr/bin/env bash
# From WSL: copies setup-wsl-port-forward.ps1 into Windows %TEMP% and re-launches it
# elevated (UAC). Elevated shells often fail to execute scripts directly from \\\\wsl$\\ UNC paths.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="${SCRIPT_DIR}/setup-wsl-port-forward.ps1"

if [ ! -f "$SRC" ]; then
	echo "Missing: $SRC" >&2
	exit 1
fi

if ! command -v powershell.exe >/dev/null 2>&1; then
	echo "powershell.exe not found — run this from WSL on Windows." >&2
	exit 1
fi

WIN_TEMP="$(powershell.exe -NoProfile -Command 'Write-Host $env:TEMP' | tr -d '\r')"
if [ -z "$WIN_TEMP" ]; then
	echo "Could not resolve Windows TEMP." >&2
	exit 1
fi

LINUX_TEMP="$(wslpath -u "$WIN_TEMP")"
DST="${LINUX_TEMP}/homedx-setup-wsl-port-forward.ps1"

cp -f "$SRC" "$DST"

DST_WIN="$(wslpath -w "$DST")"
echo "Copied script to Windows: $DST_WIN"
echo "Approve the UAC prompt on Windows."
ps_cmd="Start-Process -FilePath powershell.exe -Verb RunAs -Wait -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-File','${DST_WIN}'"
powershell.exe -NoProfile -Command "$ps_cmd"
