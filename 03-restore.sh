#!/usr/bin/env bash
# Puts back everything 02-debloat.sh removed (from state/removed.txt), or one package: ./03-restore.sh com.foo.bar
source "$(dirname "$0")/lib.sh"
if [[ -n "${1:-}" ]]; then pkgs=("$1"); else mapfile -t pkgs < <(sort -u "$STATE/removed.txt" 2>/dev/null); fi
for p in "${pkgs[@]}"; do
  A cmd package install-existing --user 0 "$p" 2>/dev/null | tr -d '\r'
  A pm enable --user 0 "$p" 2>/dev/null | tr -d '\r'
done
A settings put global window_animation_scale 1; A settings put global transition_animation_scale 1; A settings put global animator_duration_scale 1
echo "Restored ${#pkgs[@]} package(s)."
