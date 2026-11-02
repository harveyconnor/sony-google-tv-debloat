#!/usr/bin/env bash
# Stops streaming apps auto-launching into the background at boot (they still open normally when you pick them).
# Usage: ./04-background.sh           -> block every user-installed app + the usual preinstalled streamers
#        ./04-background.sh allow     -> undo
source "$(dirname "$0")/lib.sh"
MODE="${1:-ignore}"
mapfile -t APPS < <(A pm list packages -3 | sed 's/package://' | tr -d '\r')
APPS+=(com.netflix.ninja com.amazon.amazonvideo.livingroom com.apple.atve.sony.appletv com.disney.disneyplus
       com.spotify.tv.android com.google.android.youtube.tvmusic com.google.android.youtube.tvkids com.uei.quicksetsdk.sony)
for p in $(printf '%s\n' "${APPS[@]}" | sort -u); do
  case "$p" in com.overdevs.at4k|com.neilturner.aerialviews) continue;; esac   # launcher + screensaver must run in background
  A cmd appops set "$p" RUN_ANY_IN_BACKGROUND "$MODE" >/dev/null 2>&1
  A cmd appops set "$p" RUN_IN_BACKGROUND "$MODE" >/dev/null 2>&1
  [[ "$MODE" == ignore ]] && A am force-stop "$p" >/dev/null 2>&1
  echo "$p -> $MODE"
done
