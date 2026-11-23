#!/usr/bin/env bash
# Install or update LightCraft (mz) on a Mac (Apple Silicon) from the latest GitHub release.
#
#   curl -fsSL https://raw.githubusercontent.com/zneb076/lightcraft-custom/main/install/update-mac.sh | bash
#
# Add "-s -- --force" after "bash" to reinstall the same version. It quits LightCraft (mz) first if
# it's open, and opens it again afterwards. Downloads made this way aren't quarantined, and the
# script clears the flag anyway, so no "can't be opened" prompt or extra Terminal step is needed.
set -euo pipefail

REPO="zneb076/lightcraft-custom"
APP="${LIGHTCRAFT_MZ_APP:-/Applications/LightCraft (mz).app}"
FORCE=0
AUTO=0
for arg in "$@"; do
  case "$arg" in
    --force) FORCE=1 ;;
    --auto) AUTO=1 ;; # daily background run: never quits the app, tells you with a notification
  esac
done

say() { printf '%s==> %s\n' "$([ "$AUTO" = 1 ] && date '+%F %T ')" "$*"; }
notify() { [ "$AUTO" = 1 ] && osascript -e "display notification \"$1\" with title \"LightCraft (mz)\"" >/dev/null 2>&1 || true; }
die() { printf 'Error: %s\n' "$*" >&2; notify "Update failed: $*"; exit 1; }

[ "$(uname -s)" = "Darwin" ] || die "this script is for macOS."
[ "$(uname -m)" = "arm64" ] || die "these builds are for Apple Silicon Macs (M1 or newer) only."

say "Checking the latest LightCraft (mz) release"
if ! json=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest"); then
  # offline or GitHub down: in the daily run, just try again tomorrow
  [ "$AUTO" = 1 ] && { say "couldn't reach GitHub; will try next time"; exit 0; }
  die "couldn't reach GitHub."
fi
tag=$(printf '%s' "$json" | grep -o '"tag_name": *"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')
url=$(printf '%s' "$json" | grep -o '"browser_download_url": *"[^"]*macos-aarch64\.dmg"' | head -1 | sed 's/.*"\(https[^"]*\)"$/\1/')
[ -n "$tag" ] && [ -n "$url" ] || die "the latest release has no Mac download."
latest=${tag#v}; latest=${latest%-custom}

installed=""
if [ -f "$APP/Contents/Info.plist" ]; then
  installed=$(plutil -extract CFBundleShortVersionString raw "$APP/Contents/Info.plist" 2>/dev/null || true)
fi
if [ "$installed" = "$latest" ] && [ "$FORCE" = 0 ]; then
  say "LightCraft (mz) $installed is already the latest version."
  exit 0
fi
# the daily run doesn't install over an app you're using: it tells you and tries again next time
if [ "$AUTO" = 1 ] && pgrep -f "$APP/Contents/MacOS/" >/dev/null; then
  say "$latest is available but LightCraft (mz) is open; will install next time"
  seen="$HOME/Library/Application Support/LightCraft-mz/told-$latest"
  if [ ! -e "$seen" ]; then # say so once per version, not on every check
    mkdir -p "$(dirname "$seen")" && touch "$seen"
    notify "Version $latest is ready. It installs by itself once LightCraft (mz) is closed."
  fi
  exit 0
fi
say "Installing LightCraft (mz) $latest${installed:+ (replacing $installed)}"

tmp=$(mktemp -d)
mnt="$tmp/mnt"
cleanup() {
  hdiutil detach -quiet "$mnt" 2>/dev/null || true
  rm -rf "$tmp"
}
trap cleanup EXIT

say "Downloading $(basename "$url")"
curl -fL --progress-bar -o "$tmp/app.dmg" "$url" || die "download failed."

# Quit the patched app (only this copy, not the official LightCraft) before replacing it.
was_running=0
if pgrep -f "$APP/Contents/MacOS/" >/dev/null; then
  was_running=1
  say "Quitting LightCraft (mz)"
  osascript -e "tell application \"$APP\" to quit" >/dev/null 2>&1 || true
  for _ in $(seq 1 30); do
    pgrep -f "$APP/Contents/MacOS/" >/dev/null || break
    sleep 1
  done
  pgrep -f "$APP/Contents/MacOS/" >/dev/null && die "LightCraft (mz) is still open. Quit it and run this again."
fi

mkdir -p "$mnt"
hdiutil attach -quiet -nobrowse -readonly -mountpoint "$mnt" "$tmp/app.dmg" || die "couldn't open the downloaded .dmg."
src=$(find "$mnt" -maxdepth 1 -name '*.app' | head -1)
[ -n "$src" ] || die "no app inside the .dmg."

ditto "$src" "$APP.new"
rm -rf "$APP"
mv "$APP.new" "$APP"
xattr -dr com.apple.quarantine "$APP" 2>/dev/null || true
codesign --verify --deep "$APP" || die "the installed app failed its signature check."

say "Done: LightCraft (mz) $latest is in $(dirname "$APP")"
notify "Updated to version $latest."
if [ "$was_running" = 1 ]; then
  open "$APP"
fi
