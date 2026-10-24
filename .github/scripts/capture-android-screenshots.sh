#!/usr/bin/env bash
# Installs a debug APK on the running emulator, launches it and saves a
# screenshot of what is on screen after startup.
#
# usage: capture-android-screenshots.sh <apk> <package> <out-dir>
#
# This captures the screen the app opens on; it does not navigate. Deeper
# screens need UI automation (an instrumented test that saves screenshots).
set -euo pipefail

APK=$1
PKG=$2
OUT=$3
mkdir -p "$OUT"

adb install -r "$APK"
adb shell pm clear "$PKG" || true
# Granted here only so the notification prompt does not cover the screenshot.
adb shell pm grant "$PKG" android.permission.POST_NOTIFICATIONS || true

adb shell monkey -p "$PKG" -c android.intent.category.LAUNCHER 1

# Wait up to 30 s for the app window to take focus, then let it settle.
for _ in $(seq 1 30); do
  if adb shell dumpsys window | grep -m1 mCurrentFocus | grep -q "$PKG"; then
    break
  fi
  sleep 1
done
# This app shows the Flutter splash for a while on a cold emulator (the first run
# captured only the splash after 6 s), so give it longer before the screenshot.
sleep 25

adb exec-out screencap -p > "$OUT/launch.png"
ls -l "$OUT"
