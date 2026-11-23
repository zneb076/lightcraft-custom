# Install or update LightCraft (mz) on Windows (x64) from the latest GitHub release.
#
#   irm https://raw.githubusercontent.com/zneb076/lightcraft-custom/main/install/update-windows.ps1 | iex
#
# Run it in PowerShell. Windows asks for administrator permission while installing. To reinstall
# the same version, run:  $env:LIGHTCRAFT_MZ_FORCE = 1  first.
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$Repo = 'zneb076/lightcraft-custom'

function Say($m) { Write-Host "==> $m" }

if ($env:PROCESSOR_ARCHITECTURE -ne 'AMD64') {
  throw 'These builds are for 64-bit Intel/AMD Windows (x64) only.'
}

Say 'Checking the latest LightCraft (mz) release'
$rel = Invoke-RestMethod "https://api.github.com/repos/$Repo/releases/latest" -Headers @{ 'User-Agent' = 'lightcraft-mz-updater' }
$asset = $rel.assets | Where-Object { $_.name -like '*windows-x64.msi' } | Select-Object -First 1
if (-not $asset) { throw 'The latest release has no Windows installer.' }
$latest = $rel.tag_name -replace '^v', '' -replace '-custom$', ''

# The version installed now (Apps & features entry), if any
$installed = $null
foreach ($root in 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall', 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall', 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall') {
  $hit = Get-ChildItem $root -ErrorAction SilentlyContinue | Get-ItemProperty -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName -eq 'LightCraft (mz)' } | Select-Object -First 1
  if ($hit) { $installed = $hit.DisplayVersion; break }
}
if ($installed -and $installed.StartsWith($latest) -and -not $env:LIGHTCRAFT_MZ_FORCE) {
  Say "LightCraft (mz) $installed is already the latest version."
  return
}
Say "Installing LightCraft (mz) $latest$(if ($installed) { " (replacing $installed)" })"

$msi = Join-Path $env:TEMP $asset.name
Say "Downloading $($asset.name)"
Invoke-WebRequest $asset.browser_download_url -OutFile $msi -Headers @{ 'User-Agent' = 'lightcraft-mz-updater' }
Unblock-File $msi

$running = Get-Process lightcraft -ErrorAction SilentlyContinue
if ($running) {
  Say 'Closing LightCraft'
  $running | ForEach-Object { [void]$_.CloseMainWindow() }
  $running | Wait-Process -Timeout 30 -ErrorAction SilentlyContinue
  if (Get-Process lightcraft -ErrorAction SilentlyContinue) { throw 'LightCraft is still open. Close it and run this again.' }
}

$p = Start-Process msiexec.exe -ArgumentList @('/i', "`"$msi`"", '/passive', '/norestart') -Verb RunAs -Wait -PassThru
Remove-Item $msi -ErrorAction SilentlyContinue
if ($p.ExitCode -notin 0, 3010) { throw "The installer failed (code $($p.ExitCode))." }
Say "Done: LightCraft (mz) $latest is installed. Find it in the Start menu."
