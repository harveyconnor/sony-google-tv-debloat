# Instructions for Claude Code

This repo debloats a Sony Bravia Google TV over Wi-Fi ADB. You run the scripts from the user's laptop. Read README.md first.

## Workflow

1. Confirm `adb` exists (`lib.sh` searches common SDK paths). If missing, help the user install platform-tools.
2. Ask the user to enable Network debugging on the TV (steps in README). You cannot do this remotely.
3. `./find-tv.sh` to locate the TV. If SSDP finds nothing, ask the user for the TV's IP (Settings > Network > Status) and `export TV_IP=...`.
4. `./01-recon.sh` and read `state/packages-3rdparty.txt`. Ask which preinstalled streaming apps the user never uses before removing any.
5. `./02-debloat.sh [extra packages]`. It reboots the TV. Wait ~90 s, then verify with `01-recon.sh` that the launcher is up and memory improved.
6. `./04-background.sh`, then offer `05-launcher-at4k.sh` and `06-screensaver.sh`. Both open a Play Store page on the TV and try to press Install; if the TV's Play Store needs the user to press it, say so.
7. After the launcher switch, the user must answer two on-screen prompts in AT4K (TV listings: Allow, accessibility notice: Yes).

## Rules

- Never `pm uninstall` without `--user 0`, and never touch anything outside the lists in `02-debloat.sh` without telling the user why.
- Do not remove streaming apps, AirPlay/HomeKit (`com.sony.dtv.airplayapp`, `com.sony.dtv.homekit`), Google TTS, Play Store, GMS, or Sony tuner/input packages.
- If the user owns a Bravia Cam, delete the camera lines from `SAFE` before running step 2.
- `cmd dreams start` does not exist on Android 12; to test the screensaver temporarily set `screen_off_timeout` to 15000 and restore it.
- `screensaver_activate_on_sleep` must be 1 or Sony firmware sleeps instead of showing the screensaver.
- Screenshots over ADB work: `adb -s IP:5555 exec-out screencap -p > shot.png`. Use them to see what the TV is showing.
- Everything is reversible with the undo commands in README. If something looks wrong after a step, run the undo rather than improvising.
