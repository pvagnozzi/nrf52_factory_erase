<#
.SYNOPSIS
    📦 Build and package nRF52 Factory Erase firmware into release ZIPs.

.DESCRIPTION
    Calls build.ps1 to compile the firmware, then packages each environment's
    artifacts (.elf, .uf2, -ota.zip) into a single ZIP under release\.

.PARAMETER Environment
    s140_nrf52_611_softdevice   S140 v6.1.1 — RAK, LilyGo, Heltec Node T114
    s140_nrf52_730_softdevice   S140 v7.3.0 — Seeed, ms24sf1, ME25LS01
    all                         Build both environments (default)

.PARAMETER Clean
    Remove .pio\build\<env> before building.

.PARAMETER Verbose
    Pass -v to pio run for detailed compiler output.

.EXAMPLE
    .\scripts\windows\release.ps1
    .\scripts\windows\release.ps1 -Environment s140_nrf52_611_softdevice
    .\scripts\windows\release.ps1 -Clean
#>
[CmdletBinding()]
param(
    [ValidateSet('s140_nrf52_611_softdevice', 's140_nrf52_730_softdevice', 'all')]
    [string]$Environment = 'all',
    [switch]$Clean
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ProjectRoot   = (Get-Item "$PSScriptRoot\..\..").FullName
$ScriptsPython = Join-Path $ProjectRoot 'scripts\python'

Set-Location $ProjectRoot

# ── Colours ───────────────────────────────────────────────────────────────────
$ESC = [char]27
function Write-Header  { Write-Host "`n${ESC}[1;34m════════════════════════════════════════════${ESC}[0m`n${ESC}[1;34m  📦  nRF52 Factory Erase — Package         ${ESC}[0m`n${ESC}[1;34m════════════════════════════════════════════${ESC}[0m" }
function Write-Step    { param($t) Write-Host "`n${ESC}[0;36m▸  $t${ESC}[0m" }
function Write-Ok      { param($t) Write-Host "${ESC}[0;32m✔  $t${ESC}[0m" }
function Write-Err     { param($t) Write-Host "${ESC}[0;31m✖  $t${ESC}[0m" }
function Write-Info    { param($t) Write-Host "${ESC}[0;34mℹ  $t${ESC}[0m" }
function Write-Sep     { Write-Host "${ESC}[2m────────────────────────────────────────────${ESC}[0m" }

$AllEnvs = @('s140_nrf52_611_softdevice', 's140_nrf52_730_softdevice')
$Envs    = if ($Environment -eq 'all') { $AllEnvs } else { @($Environment) }

# ── Step 1: Build ─────────────────────────────────────────────────────────────
Write-Step "Building firmware…"
$buildArgs = @('-Environment', $Environment)
if ($Clean)                                          { $buildArgs += '-Clean' }
if ($VerbosePreference -ne 'SilentlyContinue')       { $buildArgs += '-Verbose' }

& "$PSScriptRoot\build.ps1" @buildArgs
if ($LASTEXITCODE -ne 0) { Write-Err 'Build failed.'; exit 1 }

# ── Resolve version ───────────────────────────────────────────────────────────
if (-not $env:APP_VERSION) {
    $env:APP_VERSION = python "$ScriptsPython\buildinfo.py" long 2>$null
    if (-not $env:APP_VERSION) {
        $props = Get-Content version.properties
        $major = ($props | Select-String 'major').ToString().Split('=')[1].Trim()
        $minor = ($props | Select-String 'minor').ToString().Split('=')[1].Trim()
        $build = ($props | Select-String 'build').ToString().Split('=')[1].Trim()
        $sha   = git rev-parse --short HEAD 2>$null
        $env:APP_VERSION = "$major.$minor.$build.$sha"
    }
}

$BuildDir   = Join-Path $ProjectRoot 'build'
$ReleaseDir = Join-Path $ProjectRoot 'release'
New-Item -ItemType Directory -Force $ReleaseDir | Out-Null

Write-Header
Write-Info "Version  : $($env:APP_VERSION)"
Write-Info "Build    : $BuildDir"
Write-Info "Release  : $ReleaseDir"
Write-Sep

$Passed = @(); $Failed = @()

# ── Step 2: Package ───────────────────────────────────────────────────────────
foreach ($Env in $Envs) {
    Write-Step "Packaging $Env…"
    $Base = "nrf52_factory_erase-${Env}-$($env:APP_VERSION)"
    $Zip  = Join-Path $ReleaseDir "$Base.zip"

    $Candidates = @(
        (Join-Path $BuildDir "$Base.elf"),
        (Join-Path $BuildDir "$Base.uf2"),
        (Join-Path $BuildDir "$Base-ota.zip")
    )
    $Files = $Candidates | Where-Object { Test-Path $_ }

    if ($Files.Count -eq 0) {
        Write-Err "No artifacts found for $Env in $BuildDir"
        $Failed += $Env
        continue
    }

    if (Test-Path $Zip) { Remove-Item -Force $Zip }
    Compress-Archive -Path $Files -DestinationPath $Zip

    $Passed += $Env
    Write-Ok "$Base.zip  ($($Files.Count) files)"
    Write-Sep
}

# ── Summary ───────────────────────────────────────────────────────────────────
Write-Host "`n${ESC}[1m── Summary ─────────────────────────────────────${ESC}[0m"
foreach ($e in $Passed) { Write-Host "  ${ESC}[0;32m✔ PASS${ESC}[0m  $e" }
foreach ($e in $Failed) { Write-Host "  ${ESC}[0;31m✖ FAIL${ESC}[0m  $e" }
Write-Host ""

Get-ChildItem $ReleaseDir -Filter *.zip |
    Sort-Object Name |
    Format-Table @{L='File';E={$_.Name}}, @{L='Size';E={"$([math]::Round($_.Length/1KB, 1)) KB"}} -AutoSize

if ($Failed.Count -gt 0) { Write-Err "$($Failed.Count) package(s) failed."; exit 1 }
Write-Ok "Release complete → $ReleaseDir"
