#!/usr/bin/env bash
# Turn on automatic updates of LightCraft (mz) on this Mac.
#
#   curl -fsSL https://raw.githubusercontent.com/zneb076/lightcraft-custom/main/install/auto-update-mac.sh | bash
#
# Every 3 hours (and when you log in) it checks GitHub for a newer LightCraft (mz) and installs it,
# showing a notification when it does. It never closes the app while you're using it: then it
# waits until the app is closed at the next check. Log: ~/Library/Logs/lightcraft-mz-update.log
#
# Turn it off:  ... | bash -s -- --off
set -euo pipefail

LABEL="com.zneb076.lightcraft-mz.update"
DIR="$HOME/Library/Application Support/LightCraft-mz"
SCRIPT="$DIR/update-mac.sh"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
LOG="$HOME/Library/Logs/lightcraft-mz-update.log"
SRC="https://raw.githubusercontent.com/zneb076/lightcraft-custom/main/install/update-mac.sh"

launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true

if [ "${1:-}" = "--off" ]; then
  rm -f "$PLIST" "$SCRIPT"
  echo "==> Automatic updates of LightCraft (mz) are off."
  exit 0
fi

# A local copy of the updater runs each time, so nothing new is downloaded and run on its own;
# run this command again to pick up a newer updater.
mkdir -p "$DIR" "$HOME/Library/LaunchAgents" "$HOME/Library/Logs"
curl -fsSL -o "$SCRIPT.new" "$SRC"
bash -n "$SCRIPT.new"
mv "$SCRIPT.new" "$SCRIPT"
chmod +x "$SCRIPT"

cat >"$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$LABEL</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>$SCRIPT</string>
    <string>--auto</string>
  </array>
  <key>StartInterval</key>
  <integer>10800</integer>
  <key>RunAtLoad</key>
  <true/>
  <key>StandardOutPath</key>
  <string>$LOG</string>
  <key>StandardErrorPath</key>
  <string>$LOG</string>
  <key>ProcessType</key>
  <string>Background</string>
</dict>
</plist>
EOF
plutil -lint "$PLIST" >/dev/null
launchctl bootstrap "gui/$(id -u)" "$PLIST"

echo "==> Automatic updates of LightCraft (mz) are on: every 3 hours and at login."
echo "    Log: $LOG"
echo "    Turn off: curl -fsSL https://raw.githubusercontent.com/zneb076/lightcraft-custom/main/install/auto-update-mac.sh | bash -s -- --off"
