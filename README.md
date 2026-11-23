# LightCraft (mz)

A personal build of [LightCraft](https://github.com/storytold/lightcraft) (MIT / Apache-2.0) with a few changes, built automatically for macOS and Windows.

## Changes

1. **A single click on the photo no longer zooms.** It only focuses the photo. Double-click, `Z` or Space still toggle the zoom.
2. **← / → always change the photo**, even right after adjusting a slider on the right panel (they used to end up resizing the panel). ↑ / ↓ still nudge the selected slider.
3. The app is called **LightCraft (mz)** (window title, menu, About, Dock, Start menu), so it's easy to tell apart from the official build. It uses the same catalog and settings as the official app.

The code changes are in [`patches/`](patches/); the renaming is in [`scripts/rename.sh`](scripts/rename.sh).

## How the automatic builds work

[`.github/workflows/build.yml`](.github/workflows/build.yml) runs every day at 08:00 (Thailand time):

1. It checks the latest LightCraft release.
2. If it hasn't built that version yet, it downloads the source, applies `patches/`, renames the app, and builds:
   - macOS Apple Silicon `.dmg`
   - Windows x64 `.msi` (installer) and `-portable.zip`
3. It publishes them under [Releases](../../releases) as `<version>-custom`.

To build now: **Actions → Build LightCraft (custom) → Run workflow** (tick *force* to rebuild a version already built).

If LightCraft changes the code a patch edits, the build fails with "Patch no longer applies" and GitHub emails you. The patch then needs updating; the previous release stays available.

## Installing

These builds aren't signed by Apple or Microsoft, so the first launch needs one extra step.

**Mac:** open the `.dmg`, drag **LightCraft (mz)** to Applications, then run this once in Terminal:

```bash
xattr -dr com.apple.quarantine "/Applications/LightCraft (mz).app"
```

(or: try to open it, then **System Settings → Privacy & Security → Open Anyway**).

**Windows:** run the `.msi`. If SmartScreen says "Windows protected your PC", click **More info → Run anyway**. The installer replaces an installed official LightCraft (they share an install), and the official installer replaces this one.

## Updating with one command

**Mac** (Terminal):

```bash
curl -fsSL https://raw.githubusercontent.com/zneb076/lightcraft-custom/main/install/update-mac.sh | bash
```

It installs the latest LightCraft (mz) if it's newer than the one you have (or installs it the first time), quits and reopens the app if it's open, and needs no `xattr` step. Run it again any time; it does nothing when you're up to date.

**Windows** (PowerShell):

```powershell
irm https://raw.githubusercontent.com/zneb076/lightcraft-custom/main/install/update-windows.ps1 | iex
```

Windows asks for administrator permission while it installs.

### Automatic updates on Mac

```bash
curl -fsSL https://raw.githubusercontent.com/zneb076/lightcraft-custom/main/install/auto-update-mac.sh | bash
```

Checks every 3 hours (and at login) and installs a new LightCraft (mz) by itself, with a notification. If the app is open it waits until it's closed; it never quits the app on you. Log: `~/Library/Logs/lightcraft-mz-update.log`. Turn it off with the same command plus `-s -- --off`.
