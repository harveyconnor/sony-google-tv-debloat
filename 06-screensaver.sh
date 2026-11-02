#!/usr/bin/env bash
# Installs Aerial Views (free, open source Apple TV-style aerials) and makes it the screensaver after 10 min idle.
# Usage: ./06-screensaver.sh [minutes]     ./06-screensaver.sh off
source "$(dirname "$0")/lib.sh"
PKG=com.neilturner.aerialviews
if [[ "${1:-}" == off ]]; then A settings put secure screensaver_enabled 0; echo "Screensaver off."; exit 0; fi
MIN="${1:-10}"
A input keyevent KEYCODE_WAKEUP
if ! A pm list packages | grep -q "$PKG"; then
  A am start -a android.intent.action.VIEW -d "market://details?id=$PKG" >/dev/null 2>&1
  echo "Play Store page opened on the TV. Press Install on the remote (or wait, I will try to press it)..."
  sleep 6; A input keyevent KEYCODE_DPAD_CENTER
  for i in $(seq 1 36); do sleep 5; A pm list packages | grep -q "$PKG" && break; done
  A pm list packages | grep -q "$PKG" || { echo "Aerial Views did not install. Install it from the Play Store on the TV, then re-run."; exit 1; }
  echo "Aerial Views installed."
fi
A settings put secure screensaver_components "$PKG/.ui.screensaver.DreamActivity"
A settings put secure screensaver_enabled 1
A settings put secure screensaver_activate_on_sleep 1      # without this Sony firmware sleeps instead of showing the screensaver
A settings put system screen_off_timeout $((MIN*60000))
A cmd appops set "$PKG" RUN_ANY_IN_BACKGROUND allow >/dev/null 2>&1
A input keyevent KEYCODE_HOME
echo "Aerial Views is the screensaver, starting after $MIN min idle. Open the Aerial Views app on the TV to pick video sources or cache them locally."
