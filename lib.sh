#!/usr/bin/env bash
# Shared helpers. Sourced by every script. Do not run directly.
set -u
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE="$HERE/state"; mkdir -p "$STATE"

# --- find adb ---
find_adb() {
  if command -v adb >/dev/null 2>&1; then command -v adb; return; fi
  for p in "$HOME/Android/Sdk/platform-tools/adb" "$HOME/Library/Android/sdk/platform-tools/adb" \
           "$LOCALAPPDATA/Android/Sdk/platform-tools/adb.exe" /opt/homebrew/bin/adb /usr/lib/android-sdk/platform-tools/adb; do
    [[ -x "$p" ]] && { echo "$p"; return; }
  done
  echo "adb not found. Install Android platform-tools: https://developer.android.com/tools/releases/platform-tools" >&2
  echo "  Debian/Ubuntu: sudo apt install adb    macOS: brew install android-platform-tools" >&2
  exit 1
}
ADB="$(find_adb)"

# --- TV address: $TV_IP env, or state/tv.conf, or ./find-tv.sh ---
if [[ -z "${TV_IP:-}" && -f "$STATE/tv.conf" ]]; then TV_IP="$(cat "$STATE/tv.conf")"; fi
if [[ -z "${TV_IP:-}" ]]; then
  echo "TV address unknown. Run ./find-tv.sh, or: export TV_IP=192.168.x.x" >&2; exit 1
fi
D="$TV_IP:5555"
echo "$TV_IP" > "$STATE/tv.conf"

# --- connect and wait for on-screen authorisation ---
tv_connect() {
  "$ADB" connect "$D" >/dev/null 2>&1 || true
  for i in $(seq 1 24); do
    st="$("$ADB" -s "$D" get-state 2>/dev/null || true)"
    [[ "$st" == "device" ]] && return 0
    if "$ADB" devices | grep -q "$D.*unauthorized"; then
      [[ $i -eq 1 ]] && echo "Look at the TV: tick 'Always allow from this computer' and press OK on the USB debugging prompt..."
    elif [[ $i -eq 1 ]]; then
      echo "Cannot reach $D. On the TV: Settings > System > About > tap 'Android TV OS build' 7 times, then System > Developer options > Network debugging ON." >&2
    fi
    sleep 5; "$ADB" connect "$D" >/dev/null 2>&1 || true
  done
  echo "Could not connect/authorise to $D" >&2; exit 1
}
A() { "$ADB" -s "$D" shell "$@"; }
tv_connect
