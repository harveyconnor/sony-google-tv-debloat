#!/usr/bin/env bash
# Shows what is installed and what is hogging the TV. Safe: changes nothing.
source "$(dirname "$0")/lib.sh"
echo "== device ==";  A getprop ro.product.model; A getprop ro.build.version.release; A getprop ro.build.version.security_patch
echo "== memory =="; A cat /proc/meminfo | head -3
echo "== storage =="; A df -h /data | tail -1
echo "== top RAM =="; A dumpsys meminfo 2>/dev/null | sed -n '/Total PSS by process/,/Total PSS by OOM/p' | sed -n '2,16p'
A pm list packages -e | sed 's/package://' | tr -d '\r' | sort > "$STATE/packages-enabled.txt"
A pm list packages -d | sed 's/package://' | tr -d '\r' | sort > "$STATE/packages-disabled.txt"
A pm list packages -3 | sed 's/package://' | tr -d '\r' | sort > "$STATE/packages-3rdparty.txt"
echo "== user-installed apps =="; cat "$STATE/packages-3rdparty.txt"
echo; echo "$(wc -l < "$STATE/packages-enabled.txt") packages enabled. Lists saved in state/."
