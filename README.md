# LightCraft (mz)

A personal build of [LightCraft](https://github.com/storytold/lightcraft) (MIT / Apache-2.0) with a few changes, built automatically for macOS and Windows.

---

## 📌 คู่มือฉบับย่อ: มีอัปเดตแล้วต้องทำอะไร

> เปิดหน้านี้ได้จากในแอป: **LightCraft (mz) → About** แล้วกดลิงก์ "Custom build: what changed and how updates work"

### ปกติ: ไม่ต้องทำอะไรเลย

1. LightCraft ตัวทางการออกเวอร์ชันใหม่
2. **GitHub build ตัว (mz) ให้อัตโนมัติ** เช็กทุกวัน 08:00 แล้วไฟล์ใหม่จะขึ้นที่ [Releases](../../releases/latest)
3. **Mac ติดตั้งให้เองอัตโนมัติ** เช็กทุก 3 ชั่วโมงและตอนเปิดเครื่อง จะมีแจ้งเตือน "Updated to version …"
   - ถ้าแอปเปิดอยู่ จะไม่ปิดแอปให้ แต่จะขึ้นแจ้งเตือนว่ามีเวอร์ชันใหม่ และติดตั้งเองหลังจากปิดแอป
4. **Windows ต้องอัปเดตเอง** เปิด PowerShell แล้ววางคำสั่งนี้:
   ```powershell
   irm https://raw.githubusercontent.com/zneb076/lightcraft-custom/main/install/update-windows.ps1 | iex
   ```

### ต้องทำอะไรบางอย่างเฉพาะกรณีเหล่านี้

| เจออะไร | ทำอะไร |
|---|---|
| อีเมลจาก GitHub ว่า **"Build LightCraft (custom)" failed** และในหน้านั้นมีคำว่า *Patch no longer applies* หรือ *Rename no longer applies* | ตัวทางการแก้โค้ดตรงที่เราแก้ไว้ เลยต้องปรับ patch ใหม่ ให้เปิด Claude Code แล้วบอกว่า *"build ของ github.com/zneb076/lightcraft-custom fail เพราะ patch ใส่ไม่ได้ ช่วยแก้ให้หน่อย"* ระหว่างนี้ตัวเก่ายังใช้ได้ตามปกติ |
| อีเมลจาก GitHub ว่า **scheduled workflow will be disabled** (มาประมาณทุก 60 วัน ถ้า repo ไม่มีการเปลี่ยนแปลง) | กดปุ่มในอีเมลเพื่อเปิดต่อ หรือเข้า **Actions → Build LightCraft (custom)** แล้วกด **Enable workflow** ถ้าไม่ทำ จะไม่มี build ใหม่ |
| แจ้งเตือนบน Mac ว่า **"Update failed"** | ดูสาเหตุในไฟล์ `~/Library/Logs/lightcraft-mz-update.log` หรือรันคำสั่งอัปเดตเอง (ดูด้านล่าง) |
| อยากได้เวอร์ชันใหม่ทันที ไม่อยากรอ | ใน repo ไปที่ **Actions → Build LightCraft (custom) → Run workflow** รอประมาณ 20 นาที แล้วบน Mac รัน: `curl -fsSL https://raw.githubusercontent.com/zneb076/lightcraft-custom/main/install/update-mac.sh \| bash` |
| ซื้อ Mac ใหม่ หรือลงเครื่องใหม่ | รันคำสั่งนี้ครั้งเดียว จะติดตั้งแอปและเปิดอัปเดตอัตโนมัติให้: `curl -fsSL https://raw.githubusercontent.com/zneb076/lightcraft-custom/main/install/update-mac.sh \| bash && curl -fsSL https://raw.githubusercontent.com/zneb076/lightcraft-custom/main/install/auto-update-mac.sh \| bash` |
| อยากปิดการอัปเดตอัตโนมัติบน Mac | `curl -fsSL https://raw.githubusercontent.com/zneb076/lightcraft-custom/main/install/auto-update-mac.sh \| bash -s -- --off` |

### ข้อควรระวัง

- **อย่าอัปเดต LightCraft ตัวทางการก่อนตัว (mz)** ทั้งสองตัวใช้ catalog และ settings ชุดเดียวกัน ถ้าตัวทางการเวอร์ชันใหม่ไปอัปเกรด catalog ไปก่อน ตัว (mz) เวอร์ชันเก่าอาจเปิดไม่ได้ ง่ายที่สุดคือใช้แต่ตัว (mz)
- **อย่าเปิดทั้งสองตัวพร้อมกัน**
- บน Windows ตัว (mz) กับตัวทางการติดตั้งทับกัน ลงตัวไหนตัวนั้นจะแทนที่อีกตัว

---

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
