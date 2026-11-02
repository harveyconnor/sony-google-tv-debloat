#!/usr/bin/env bash
# Removes ad-tracking, promo, HbbTV, hotel-mode, camera, demo and help packages for the main user.
# Nothing is deleted from the system partition: 03-restore.sh puts everything back.
# Usage: ./02-debloat.sh [extra.package.names ...]   (e.g. preinstalled streaming apps you never use)
source "$(dirname "$0")/lib.sh"
SAFE=(
  # viewing-tracking / analytics / ad tech
  tv.samba.ssm tv.samba.ssm.ui com.qterics.da.product com.sony.dtv.da.service com.sonyericsson.idd.agent
  com.sony.dtv.sonybugreportsys com.google.android.feedback com.google.android.partnersetup
  # Sony promo / recommendation rows
  com.sony.dtv.sonyselect com.sony.dtv.sonyselectshelf com.sony.dtv.sonyshelf com.sony.dtv.promos
  com.sony.dtv.promotionmanager com.sony.dtv.sonytab com.sony.dtv.recapp com.sony.dtv.livingfit
  # Google ambient screensaver (always resident) + games
  com.google.android.apps.tv.dreamx com.google.android.backdrop com.google.android.play.games
  # HbbTV / interactive broadcast ad engine
  com.sony.dtv.hbbtv com.sony.dtv.hbbtvplayer com.sony.dtv.interactivetvplatform com.sony.dtv.interactivetvutil
  com.sony.dtv.interactivetvutil.output com.vewd.core.integration.dia com.vewd.core.service
  # hotel / business mode
  com.sony.dtv.b2b.adminpassword com.sony.dtv.b2b.deviceadminsettings com.sony.dtv.b2b.frameworkextension
  com.sony.dtv.b2b.hotelmode com.sony.dtv.b2b.importexport com.sony.dtv.b2b.ipcontrolsettings
  com.sony.dtv.b2b.noderuntimeextension.bpk com.sony.dtv.b2b.noderuntimeextension.node_20_11_1
  com.sony.dtv.b2b.noderuntime.normal com.sony.dtv.b2b.noderuntime.privilege com.sony.dtv.b2b.prosettings
  com.sony.dtv.b2b.rs232csupport com.sony.dtv.b2b.webappruntimedrm com.sony.dtv.b2b.softap com.sony.dtv.b2b.vendorprotocol
  # Bravia Cam services (only matters if you own the camera accessory: see README)
  com.sony.dtv.sensingcamera.fwupdate com.sony.dtv.sensingcamera.settings com.sony.dtv.sensingfusionservice
  com.sony.dtv.gestureapp com.sony.dtv.distancealert
  # retail demo
  com.sony.dtv.demosupport com.sony.dtv.demosystemsupport com.sony.dtv.multiscreendemo com.sony.dtv.demomode
  # help / support
  com.sony.dtv.customersupport com.sony.dtv.customersupport.provider.res com.sony.dtv.helpguidecontents
  com.sony.dtv.smarthelp com.sony.dtv.imanual
  # Sony cloud IoT (Alexa power-on), misc
  com.sony.dtv.seeds.iot com.sony.dtv.seeds.iot.remotestart com.sony.dtv.osat.music com.sony.dtv.ecodashboard
  com.android.printspooler com.google.android.syncadapters.calendar
)
LIST=("${SAFE[@]}" "$@")
installed="$(A pm list packages | sed 's/package://' | tr -d '\r')"
done_list=(); skipped=()
for p in "${LIST[@]}"; do
  grep -qx "$p" <<<"$installed" || continue
  out="$(A pm uninstall -k --user 0 "$p" 2>&1 | tr -d '\r')"
  if [[ "$out" == *Success* ]]; then done_list+=("$p")
  else out2="$(A pm disable-user --user 0 "$p" 2>&1 | tr -d '\r')"
       [[ "$out2" == *disabled* ]] && done_list+=("$p") || skipped+=("$p: $out"); fi
done
printf '%s\n' "${done_list[@]}" >> "$STATE/removed.txt"
echo "Removed/disabled (${#done_list[@]}):"; printf '  %s\n' "${done_list[@]}"
[[ ${#skipped[@]} -gt 0 ]] && { echo "Could not remove:"; printf '  %s\n' "${skipped[@]}"; }
A settings put secure screensaver_enabled 0        # Google ambient screensaver is gone; 06-screensaver.sh adds a better one
A settings put global window_animation_scale 0.5
A settings put global transition_animation_scale 0.5
A settings put global animator_duration_scale 0.5
A pm trim-caches 128G >/dev/null 2>&1
A pm clear com.android.statementservice >/dev/null 2>&1   # avoids a harmless first-boot crash of the app-link verifier
echo "Animations 0.5x, caches trimmed. Rebooting TV..."; "$ADB" -s "$D" reboot
