<#
.SYNOPSIS
  Wire Overstein sibling apps for Play release signing + optional AAB build.

.DESCRIPTION
  Copies SuperGarage upload keystore into each app (shared upload cert is OK
  with Play App Signing), writes android/key.properties, patches
  build.gradle.kts for release signing, normalizes underscore applicationIds,
  and bumps version to 1.0.0+1 when still 0.1.0+1.

  Does NOT commit secrets. key.properties / *.jks stay local/gitignored.
#>
param(
  [switch]$BuildAab,
  [switch]$SkipVersionBump,
  [string[]]$Apps = @(
    'superhealth',
    'superfinance',
    'superhome',
    'superfarm',
    'superhospital',
    'supersports',
    'supernews',
    'supertravel',
    'superpet',
    'superairport',
    'supermaritime',
    'superfactory',
    'afterhub'
  )
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$Hanturai = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$GarageRoot = Join-Path $Hanturai 'supergarage'
$SrcKeyProps = Join-Path $GarageRoot 'android\key.properties'
$SrcJks = Join-Path $GarageRoot 'android\keystore\supergarage-release.jks'

if (-not (Test-Path $SrcKeyProps)) { throw "Missing $SrcKeyProps" }
if (-not (Test-Path $SrcJks)) { throw "Missing $SrcJks" }

# Parse garage key.properties without printing secrets.
$garageProps = @{}
Get-Content $SrcKeyProps | ForEach-Object {
  if ($_ -match '^\s*#' -or $_ -notmatch '=') { return }
  $k, $v = $_.Split('=', 2)
  $garageProps[$k.Trim()] = $v
}
foreach ($need in @('storePassword', 'keyPassword', 'keyAlias')) {
  if (-not $garageProps.ContainsKey($need) -or [string]::IsNullOrWhiteSpace($garageProps[$need])) {
    throw "key.properties missing $need"
  }
}

$idFixes = @{
  'superairport'  = @{ ns = 'com.overstein.superairport';  id = 'com.overstein.superairport' }
  'supermaritime' = @{ ns = 'com.overstein.supermaritime'; id = 'com.overstein.supermaritime' }
  'superfactory'  = @{ ns = 'com.overstein.superfactory';  id = 'com.overstein.superfactory' }
}

function Write-KeyProperties {
  param([string]$AppAndroidDir, [string]$Alias)
  $ksDir = Join-Path $AppAndroidDir 'keystore'
  New-Item -ItemType Directory -Force -Path $ksDir | Out-Null
  $destJks = Join-Path $ksDir 'overstein-upload.jks'
  Copy-Item -Path $SrcJks -Destination $destJks -Force

  $propsPath = Join-Path $AppAndroidDir 'key.properties'
  $lines = @(
    "storePassword=$($garageProps['storePassword'])"
    "keyPassword=$($garageProps['keyPassword'])"
    "keyAlias=$($garageProps['keyAlias'])"
    'storeFile=../keystore/overstein-upload.jks'
  )
  $utf8NoBom = New-Object System.Text.UTF8Encoding $false
  [System.IO.File]::WriteAllLines($propsPath, $lines, $utf8NoBom)
}

function Ensure-Gitignore {
  param([string]$AppRoot)
  $gi = Join-Path $AppRoot '.gitignore'
  $lines = @(
    'android/key.properties'
    'android/keystore/*.jks'
    'android/keystore/CREDENTIALS.txt'
    'android/keystore/*-sa.json'
  )
  $existing = if (Test-Path $gi) { Get-Content $gi -Raw } else { '' }
  $append = @()
  foreach ($l in $lines) {
    if ($existing -notmatch [regex]::Escape($l)) { $append += $l }
  }
  if ($append.Count -gt 0) {
    Add-Content -Path $gi -Value ("`n# Play release secrets`n" + ($append -join "`n") + "`n")
  }
}

function Patch-BuildGradle {
  param([string]$GradlePath, [string]$AppName)

  $text = Get-Content $GradlePath -Raw

  if ($idFixes.ContainsKey($AppName)) {
    $fix = $idFixes[$AppName]
    $text = $text -replace 'namespace\s*=\s*"com\.overstein\.super_[^"]+"', "namespace = `"$($fix.ns)`""
    $text = $text -replace 'applicationId\s*=\s*"com\.overstein\.super_[^"]+"', "applicationId = `"$($fix.id)`""
  }

  if ($text -notmatch 'key\.properties') {
    $importBlock = @'
import java.util.Properties

'@
    if ($text -notmatch 'import java.util.Properties') {
      $text = $importBlock + $text
    }

    $signingBlock = @'

// Release signing from android/key.properties (not committed).
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseSigning = keystorePropertiesFile.exists()
if (hasReleaseSigning) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

'@
    $text = $text -replace '(plugins\s*\{[\s\S]*?\}\s*)', "`$1$signingBlock"

    $signingConfigs = @'

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                val storeFilePath = keystoreProperties.getProperty("storeFile")
                    ?: error("key.properties: storeFile is missing")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                    ?: error("key.properties: keyAlias is missing")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                    ?: error("key.properties: keyPassword is missing")
                storePassword = keystoreProperties.getProperty("storePassword")
                    ?: error("key.properties: storePassword is missing")
                storeFile = file(storeFilePath)
            }
        }
    }

'@
    if ($text -notmatch 'signingConfigs\s*\{') {
      $text = $text -replace '(defaultConfig\s*\{[\s\S]*?\}\s*)', "`$1$signingConfigs"
    }

    $releaseSigning = @'
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
'@
    $text = $text -replace 'signingConfig\s*=\s*signingConfigs\.getByName\("debug"\)', $releaseSigning
  }

  Set-Content -Path $GradlePath -Value $text -Encoding UTF8 -NoNewline
}

function Bump-Version {
  param([string]$Pubspec)
  if ($SkipVersionBump) { return }
  $raw = Get-Content $Pubspec -Raw
  if ($raw -match 'version:\s*0\.1\.0\+1') {
    $raw = $raw -replace 'version:\s*0\.1\.0\+1', 'version: 1.0.0+1'
    Set-Content -Path $Pubspec -Value $raw -Encoding UTF8 -NoNewline
    Write-Host "  version -> 1.0.0+1"
  }
}

$results = @()
foreach ($app in $Apps) {
  $root = Join-Path $Hanturai $app
  Write-Host ""
  Write-Host "=== $app ===" -ForegroundColor Cyan
  if (-not (Test-Path $root)) {
    Write-Host "  SKIP missing folder" -ForegroundColor Yellow
    $results += [pscustomobject]@{ App = $app; Status = 'missing' }
    continue
  }

  $android = Join-Path $root 'android'
  $gradle = Join-Path $android 'app\build.gradle.kts'
  $pubspec = Join-Path $root 'pubspec.yaml'
  if (-not (Test-Path $gradle)) {
    Write-Host "  SKIP no build.gradle.kts" -ForegroundColor Yellow
    $results += [pscustomobject]@{ App = $app; Status = 'no-gradle' }
    continue
  }

  Ensure-Gitignore -AppRoot $root
  Write-KeyProperties -AppAndroidDir $android -Alias 'supergarage'
  Patch-BuildGradle -GradlePath $gradle -AppName $app
  if (Test-Path $pubspec) { Bump-Version -Pubspec $pubspec }
  Write-Host "  signing wired"

  if ($BuildAab) {
    Push-Location $root
    try {
      Write-Host "  flutter pub get..."
      flutter pub get | Out-Host
      if ($LASTEXITCODE -ne 0) { throw "pub get failed ($LASTEXITCODE)" }

      $dist = Join-Path $root 'dist\aab'
      New-Item -ItemType Directory -Force -Path $dist | Out-Null
      $stamp = Get-Date -Format 'yyyy-MM-dd_HHmm'
      $outName = "$app-release-$stamp.aab"
      $outPath = Join-Path $dist $outName

      Write-Host "  flutter build appbundle --release..."
      flutter build appbundle --release
      if ($LASTEXITCODE -ne 0) { throw "appbundle failed ($LASTEXITCODE)" }

      $built = Join-Path $root 'build\app\outputs\bundle\release\app-release.aab'
      if (-not (Test-Path $built)) {
        # Some AGP layouts
        $alt = Get-ChildItem (Join-Path $root 'build\app\outputs\bundle') -Recurse -Filter '*.aab' -ErrorAction SilentlyContinue |
          Sort-Object LastWriteTime -Descending | Select-Object -First 1
        if ($null -eq $alt) { throw "AAB not found after build" }
        $built = $alt.FullName
      }
      Copy-Item $built $outPath -Force
      @(
        "artifact=$outName"
        "path=$outPath"
        "built_at=$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        "package=com.overstein.$($app -replace '^super','super' -replace '^after','after')"
      ) | Set-Content (Join-Path $dist 'LATEST.txt') -Encoding UTF8
      Write-Host "  AAB OK: $outPath" -ForegroundColor Green
      $results += [pscustomobject]@{ App = $app; Status = 'aab-ok'; Path = $outPath }
    }
    catch {
      Write-Host "  AAB FAIL: $_" -ForegroundColor Red
      $results += [pscustomobject]@{ App = $app; Status = "aab-fail: $_" }
    }
    finally {
      Pop-Location
    }
  }
  else {
    $results += [pscustomobject]@{ App = $app; Status = 'wired' }
  }
}

Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor Cyan
$results | Format-Table -AutoSize
$fail = @($results | Where-Object { $_.Status -like 'aab-fail*' -or $_.Status -eq 'missing' })
if ($fail.Count -gt 0) { exit 1 }
exit 0
