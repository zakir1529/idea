# ZYRO Lightweight Desktop App Builder
$ErrorActionPreference = "Stop"
$root = $PSScriptRoot

$nodeDir = "C:\Users\Jc\codex testing\.tools\node-v22.14.0-win-x64"
if (Test-Path $nodeDir) {
    $env:PATH = "$nodeDir;$env:PATH"
}

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "   ZYRO Retail POS - Lightweight Desktop Builder   " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

$resourcesDir = Join-Path $root "resources"
$distLightweight = Join-Path $root "dist-lightweight"
$appOutputDir = Join-Path $distLightweight "ZYRO-Retail-POS"

# 1. Clean previous staging / output
if (Test-Path $resourcesDir) { Remove-Item -Recurse -Force $resourcesDir }
if (Test-Path $distLightweight) { Remove-Item -Recurse -Force $distLightweight }
New-Item -ItemType Directory -Path $resourcesDir -Force | Out-Null
New-Item -ItemType Directory -Path $appOutputDir -Force | Out-Null

Write-Host "`n[1/4] Staging web assets into resources/..." -ForegroundColor Yellow
$itemsToCopy = @(
    "index.html",
    "css",
    "js",
    "components",
    "assets",
    "favicon.ico",
    "ZYRO.ico",
    "normalized_products.json",
    "normalized_variants.json",
    "default_store_data.json",
    "DB.txt"
)

foreach ($item in $itemsToCopy) {
    $src = Join-Path $root $item
    if (Test-Path $src) {
        Copy-Item -Path $src -Destination $resourcesDir -Recurse -Force
    }
}

# 2. Run Neutralino build with embedded resources
Write-Host "`n[2/4] Compiling lightweight desktop executable..." -ForegroundColor Yellow
npx.cmd --yes @neutralinojs/neu build --release --embed-resources

# 3. Collect Windows binary
Write-Host "`n[3/4] Packaging standalone Windows executable..." -ForegroundColor Yellow
$neuDistDir = Join-Path $root "dist\ZYRO"
$builtExe = Join-Path $neuDistDir "ZYRO-win_x64.exe"

if (-not (Test-Path $builtExe)) {
    # Check if named differently
    $builtExe = (Get-ChildItem -Path (Join-Path $root "dist") -Filter "*win_x64.exe" -Recurse | Select-Object -First 1).FullName
}

if ($builtExe -and (Test-Path $builtExe)) {
    $destExe = Join-Path $appOutputDir "ZYRO.exe"
    Copy-Item $builtExe $destExe -Force
    # Also maintain portable ZYRO.exe in root folder
    try {
        Copy-Item $builtExe (Join-Path $root "ZYRO.exe") -Force -ErrorAction Stop
    } catch {
        Write-Host "Notice: D:\ZyroInventory\ZYRO.exe is currently running. Staged new build in dist-lightweight\ZYRO-Retail-POS\ZYRO.exe" -ForegroundColor Yellow
    }
    
    # Also copy icon and readme for convenience
    if (Test-Path (Join-Path $root "ZYRO.ico")) {
        Copy-Item (Join-Path $root "ZYRO.ico") $appOutputDir -Force
    }
    
    $readmeContent = @"
ZYRO Retail POS - Desktop Edition
=================================

To run ZYRO:
Double-click 'ZYRO.exe'.

No installation, Node.js, or browser setup required!
Powered by lightweight native WebView2.
"@
    Set-Content -Path (Join-Path $appOutputDir "README.txt") -Value $readmeContent -Encoding UTF8

    # 4. Create ZIP archive
    Write-Host "`n[4/4] Creating shareable ZIP package..." -ForegroundColor Yellow
    $zipPath = Join-Path $distLightweight "ZYRO-Retail-POS-Windows.zip"
    Compress-Archive -Path "$appOutputDir\*" -DestinationPath $zipPath -Force

    # Clean temporary staging
    if (Test-Path $resourcesDir) { Remove-Item -Recurse -Force $resourcesDir }
    if (Test-Path (Join-Path $root "dist")) { Remove-Item -Recurse -Force (Join-Path $root "dist") }

    $exeSize = [math]::Round((Get-Item $destExe).Length / 1MB, 2)
    $zipSize = [math]::Round((Get-Item $zipPath).Length / 1MB, 2)

    Write-Host "`nSUCCESS! Build Completed Successfully:" -ForegroundColor Green
    Write-Host " - Standalone Executable: $destExe ($exeSize MB)" -ForegroundColor Cyan
    Write-Host " - Shareable ZIP File:    $zipPath ($zipSize MB)" -ForegroundColor Cyan
    Write-Host "==================================================" -ForegroundColor Green
} else {
    Write-Error "Build failed: could not locate compiled Windows executable in dist/."
}
