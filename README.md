# Sony Google TV debloat

Scripts to make a Sony Bravia Google TV fast and ad-free, run from a laptop over Wi-Fi.
No root, nothing is deleted from the system partition, and every step has an undo.

Built and tested on a Sony Bravia XR-75X90J (Android TV 12, MediaTek "BRAVIA 4K VH2"). Other Sony Google TVs
share most package names. The scripts skip anything that is not installed, so they are safe to run on other models.

What it did on the test TV:

| | Before | After |
|---|---|---|
| Free memory | 920 MB | 1.4 GB |
| Free storage | 597 MB | 1.1 GB |
| Enabled packages | 251 | 200 |

## What gets removed

- **Viewing trackers:** Samba TV automatic content recognition, Qterics device analytics, Sony telemetry.
- **Promo rows:** Sony Select, Sony promos, Sony tab, recommendations, Google Play Games.
- **HbbTV / broadcast interactive ads** (Vewd engine). Only matters if you use red-button services on antenna TV.
- **Hotel / business mode** packages, retail demo mode, help guides.
- **Bravia Cam services.** Skip these if you own the camera accessory (edit `02-debloat.sh`).
- **Google ambient screensaver** (permanently resident). Replaced by Aerial Views in step 6.
- Also: UI animations halved, caches trimmed, streaming apps stopped from auto-launching into the background at boot.

Streaming apps are **not** removed unless you pass them explicitly to step 2.

## Requirements

- `adb` (Android platform-tools). Debian/Ubuntu `sudo apt install adb`, macOS `brew install android-platform-tools`,
  Windows: download platform-tools and run these scripts from Git Bash or WSL.
- `python3` (only for `find-tv.sh`).
- Laptop and TV on the same Wi-Fi.

## Enable debugging on the TV (one time, with the remote)

1. Settings > System > About > scroll to **Android TV OS build** and press OK on it 7 times.
2. Settings > System > **Developer options** > **Network debugging** ON (and USB debugging if asked).
3. The first time a script connects, the TV shows "Allow USB debugging?". Tick **Always allow** and press OK.

## Run

```bash
./find-tv.sh            # finds the TV on the LAN and saves its IP to state/tv.conf (or: export TV_IP=192.168.1.50)
./01-recon.sh           # read-only: model, memory, storage, package lists into state/
./02-debloat.sh         # remove bloat, tweak animations, reboot  (add package names to also remove streaming apps)
./04-background.sh      # stop streaming apps auto-starting in the background
./05-launcher-at4k.sh   # install AT4K Launcher (free, Apple TV-style) and make it the home screen
./06-screensaver.sh     # install Aerial Views and make it the screensaver after 10 min idle
```

Example with unused streaming apps removed too:

```bash
./02-debloat.sh com.tubitv au.com.stan.and com.google.android.youtube.tvkids
```

Find package names of apps you want gone in `state/packages-3rdparty.txt` after step 1.

## Undo

```bash
./03-restore.sh                 # re-enable everything step 2 removed
./03-restore.sh com.foo.bar     # just one package
./04-background.sh allow        # let apps run in the background again
./05-launcher-at4k.sh undo      # back to Google TV home
./06-screensaver.sh off         # screensaver off
```

A factory reset also reverts everything.

## Notes

- AT4K's free tier gives Light, Dark, gradient, or a rotating "Subreddit Wallpaper" (try r/LandscapePhotography).
  Custom image and video wallpapers are a paid upgrade.
- Aerial Views streams 4K video. Open the app on the TV to cache clips locally if your connection is metered.
- A load average of about 40 on these MediaTek TVs is a kernel audio-thread quirk, not real CPU load.
- Test your remote's dedicated streaming buttons after the launcher switch. They worked on the test TV.
- Network debugging stays on so you can re-run the scripts later. Only computers you approve on-screen can connect.
  Turn it off in Developer options if you prefer.
