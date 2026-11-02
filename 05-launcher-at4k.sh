#!/usr/bin/env bash
# Installs AT4K Launcher from the Play Store and makes it the home screen. Undo: ./05-launcher-at4k.sh undo
source "$(dirname "$0")/lib.sh"
PKG=com.overdevs.at4k
if [[ "${1:-}" == undo ]]; then
  A pm enable --user 0 com.google.android.apps.tv.launcherx; A pm enable --user 0 com.sony.dtv.launcherxcustomizer
  A pm enable --user 0 com.google.android.tungsten.setupwraith
  A cmd package set-home-activity com.google.android.apps.tv.launcherx/.home.HomeActivity
  A input keyevent KEYCODE_HOME; echo "Google TV home restored. (AT4K is still installed; remove it from Settings > Apps if you like.)"; exit 0
fi
A input keyevent KEYCODE_WAKEUP
if ! A pm list packages | grep -q "$PKG"; then
  A am start -a android.intent.action.VIEW -d "market://details?id=$PKG" >/dev/null 2>&1
  echo "Play Store page opened on the TV. Press Install on the remote (or wait, I will try to press it)..."
  sleep 6; A input keyevent KEYCODE_DPAD_CENTER
  for i in $(seq 1 36); do sleep 5; A pm list packages | grep -q "$PKG" && break; done
  A pm list packages | grep -q "$PKG" || { echo "AT4K did not install. Install it from the Play Store on the TV, then re-run."; exit 1; }
  echo "AT4K installed."
fi
A cmd package set-home-activity "$PKG/.MainActivity"
A pm disable-user --user 0 com.google.android.apps.tv.launcherx
A pm disable-user --user 0 com.sony.dtv.launcherxcustomizer
A pm disable-user --user 0 com.google.android.tungsten.setupwraith    # otherwise it silently re-enables Google TV home
A input keyevent KEYCODE_HOME
echo "AT4K is now the home screen. On the TV answer its two first-run prompts (TV listings: Allow; accessibility notice: Yes)."
echo "Wallpaper: AT4K settings (sliders icon, top right) > Theme Mode > Subreddit Wallpaper > e.g. r/LandscapePhotography"
