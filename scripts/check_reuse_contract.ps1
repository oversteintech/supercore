# Enforces PLATFORM_DOCTRINE.md / factory/reuse_contract.yaml against a product repo.
# Warns on discouraged platform forks; fails on missing required thin-product files.
#
# Usage:
#   powershell -File scripts\check_reuse_contract.ps1 -AppRoot ..\superairport

param(
  [Parameter(Mandatory = $true)][string]$AppRoot,
  [switch]$Strict
)

$ErrorActionPreference = 'Stop'
$root = if ([IO.Path]::IsPathRooted($AppRoot)) { $AppRoot } else {
  Join-Path (Get-Location) $AppRoot
}
$contractPath = Join-Path $PSScriptRoot '..\factory\reuse_contract.yaml'
if (-not (Test-Path $root)) { throw "AppRoot not found: $root" }
if (-not (Test-Path $contractPath)) { throw "Contract missing: $contractPath" }

Write-Host "Reuse contract check: $root"
Write-Host "Doctrine: docs/PLATFORM_DOCTRINE.md (target ≥ 90% platform reuse)"
Write-Host ''

$errors = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]

$required = @(
  'product.spec.yaml',
  'pubspec.yaml',
  'lib\main.dart',
  'lib\app\platform\manifest.dart',
  'lib\features\feature_catalog.dart'
)
# feature_catalog may be named differently in transitional clones
$altCatalog = Get-ChildItem -Path (Join-Path $root 'lib') -Recurse -Filter '*feature*.dart' -ErrorAction SilentlyContinue |
  Where-Object { $_.Name -match 'feature_catalog|feature\.dart' } |
  Select-Object -First 1

foreach ($rel in $required) {
  $p = Join-Path $root $rel
  if (-not (Test-Path $p)) {
    if ($rel -eq 'lib\features\feature_catalog.dart' -and $altCatalog) {
      Write-Host "  [OK-ALT] feature catalog via $($altCatalog.FullName.Replace($root, '.'))"
      continue
    }
    if ($rel -eq 'product.spec.yaml' -and -not $Strict) {
      $warnings.Add("Missing $rel (generate from factory/specs)")
      continue
    }
    $errors.Add("Missing required file: $rel")
  } else {
    Write-Host "  [OK] $rel"
  }
}

$pub = Get-Content (Join-Path $root 'pubspec.yaml') -Raw
foreach ($dep in @('after_core', 'after_design_system')) {
  if ($pub -notmatch [regex]::Escape($dep)) {
    $errors.Add("pubspec.yaml must depend on $dep")
  }
}
if ($pub -notmatch 'after_enterprise' -and $pub -notmatch 'after_consumer') {
  $errors.Add('pubspec.yaml must depend on after_enterprise or after_consumer')
}

$discouraged = @(
  'lib\features\shell\main_shell.dart',
  'lib\features\auth\auth_gate.dart',
  'lib\features\tasks\tasks_screen.dart',
  'lib\features\calendar\calendar_screen.dart',
  'lib\features\documents\documents_screen.dart'
)
foreach ($rel in $discouraged) {
  if (Test-Path (Join-Path $root $rel)) {
    $warnings.Add("Discouraged platform fork still present: $rel — migrate to AfterEnterpriseMainShell / AuthGate (PLATFORM_DOCTRINE)")
  }
}

# Rough LOC split: vertical features vs everything else under lib/
$lib = Join-Path $root 'lib'
if (Test-Path $lib) {
  $allDart = Get-ChildItem $lib -Recurse -Filter *.dart
  $featureDart = $allDart | Where-Object {
    $_.FullName -match '\\features\\' -and
    $_.FullName -notmatch '\\features\\(shell|auth|tasks|calendar|documents|more|ai|overstein|common|dashboard)\\'
  }
  $totalLines = 0
  $featureLines = 0
  foreach ($f in $allDart) {
    $n = (Get-Content $f.FullName | Measure-Object -Line).Lines
    $totalLines += $n
  }
  foreach ($f in $featureDart) {
    $n = (Get-Content $f.FullName | Measure-Object -Line).Lines
    $featureLines += $n
  }
  if ($totalLines -gt 0) {
    $pct = [math]::Round(100.0 * $featureLines / $totalLines, 1)
    Write-Host ""
    Write-Host "  Vertical feature LOC share (heuristic): $pct% of lib/ ($featureLines / $totalLines)"
    Write-Host "  Platform doctrine: product-owned surface should stay near the 10% band;"
    Write-Host "  most of lib/ should shrink as apps mount AfterEnterpriseProductApp."
    if ($pct -lt 5 -and $totalLines -gt 2000) {
      $warnings.Add("lib/ is large but little vertical LOC — likely duplicated shell; migrate to platform host")
    }
  }
}

Write-Host ''
foreach ($w in $warnings) { Write-Host "  [WARN] $w" -ForegroundColor Yellow }
foreach ($e in $errors) { Write-Host "  [FAIL] $e" -ForegroundColor Red }

if ($errors.Count -gt 0) {
  Write-Host ''
  Write-Host 'Reuse contract FAILED' -ForegroundColor Red
  exit 1
}
if ($Strict -and $warnings.Count -gt 0) {
  Write-Host ''
  Write-Host 'Reuse contract FAILED (strict warnings)' -ForegroundColor Red
  exit 1
}
Write-Host ''
Write-Host 'Reuse contract OK (see warnings for transitional forks)' -ForegroundColor Green
exit 0
