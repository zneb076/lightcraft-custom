#!/usr/bin/env bash
# Shows the app as "LightCraft (mz)" so the patched build is easy to tell apart from the official one.
# Only names people see are changed (window title, menu, About, Dock/Finder, Start menu, installer).
# The bundle identifier, settings folder and catalog location stay the same, so this build opens
# the same photos, catalog and settings as the official LightCraft.
#
# Run from the LightCraft checkout root. Every edit must match, or the build stops, so a change
# upstream can't silently leave the old name in place.
set -euo pipefail
NAME="${APP_SUFFIX_NAME:-LightCraft (mz)}"
export NAME

# edit FILE PERL-SUBSTITUTION: apply it and fail if it changed nothing
edit() {
  local file="$1" expr="$2" before
  before=$(cksum <"$file")
  perl -0pi -e "$expr" "$file"
  if [ "$(cksum <"$file")" = "$before" ]; then
    echo "::error title=Rename no longer applies::$file: nothing matched $expr" >&2
    exit 1
  fi
  echo "renamed in $file"
}

# --- in the app ----------------------------------------------------------------------------
edit apps/lightcraft/src/main.rs           's/with_title\("LightCraft"\)/with_title("$ENV{NAME}")/'
edit apps/lightcraft/src/native_menu.rs    's/Submenu::new\("LightCraft", true\)/Submenu::new("$ENV{NAME}", true)/'
edit crates/ui-egui/src/dialogs.rs         's/RichText::new\("LightCraft"\)\.font/RichText::new("$ENV{NAME}").font/'
# About also links to this repo's README (what's changed, how updates work), so it's easy to find later
edit crates/ui-egui/src/dialogs.rs         's/(ui\.label\(egui::RichText::new\("\Q$ENV{NAME}\E"\)[^\n]*\n)/$1            ui.hyperlink_to("Custom build: what changed and how updates work", "https:\/\/github.com\/zneb076\/lightcraft-custom#readme");\n/'

# --- macOS: Dock / menu bar name, the .app name in the DMG, the DMG volume name -------------------
edit packaging/macos/Info.plist.in 's|(<key>CFBundleDisplayName</key>\s*<string>)LightCraft(</string>)|$1$ENV{NAME}$2|'
edit packaging/macos/Info.plist.in 's|(<key>CFBundleName</key>\s*<string>)LightCraft(</string>)|$1$ENV{NAME}$2|'
edit packaging/macos/package.sh    's|/LightCraft\.app"|/$ENV{NAME}.app"|g'
edit packaging/macos/package.sh    's|-volname "LightCraft"|-volname "$ENV{NAME}"|'

# --- Windows: installer title, Start menu shortcut, Apps & features entry --------------------------
edit packaging/windows/lightcraft.wxs 's|<Package Name="LightCraft"|<Package Name="$ENV{NAME}"|'
edit packaging/windows/lightcraft.wxs 's|(<Shortcut Id="StartMenuShortcut" Directory="ProgramMenuFolder" Name=")LightCraft"|$1$ENV{NAME}"|'
edit packaging/windows/lightcraft.wxs 's|Value="Launch LightCraft"|Value="Launch $ENV{NAME}"|'
