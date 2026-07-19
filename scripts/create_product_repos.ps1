# Creates missing AfterArtificial product repos under oversteintech and pushes
# initial scaffolds. Requires: gh auth login
#
# Usage:
#   pwsh scripts/create_product_repos.ps1
#   pwsh scripts/create_product_repos.ps1 -DryRun

param(
  [switch]$DryRun,
  [string]$Org = 'oversteintech',
  [string]$HanturaiRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path,
  [string]$Gh = "$env:LOCALAPPDATA\gh-cli\bin\gh.exe"
)

$ErrorActionPreference = 'Stop'
if (-not (Test-Path $Gh)) {
  $Gh = (Get-Command gh -ErrorAction SilentlyContinue)?.Source
}
if (-not $Gh) { throw 'gh CLI not found. Install GitHub CLI and run gh auth login.' }

& $Gh auth status | Out-Null

$catalog = Get-Content (Join-Path $PSScriptRoot '..\catalog\products.yaml') -Raw
# Parse product names/packages from yaml lines (simple, no YAML lib)
$products = @()
$current = $null
foreach ($line in ($catalog -split "`n")) {
  if ($line -match '^\s+- name:\s*(.+)$') {
    if ($null -ne $current) { $products += $current }
    $current = [ordered]@{ name = $Matches[1].Trim(); package = ''; productLine = ''; status = ''; siblingPath = '' }
  } elseif ($null -ne $current) {
    if ($line -match '^\s+package:\s*(.+)$') { $current.package = $Matches[1].Trim() }
    if ($line -match '^\s+productLine:\s*(.+)$') { $current.productLine = $Matches[1].Trim() }
    if ($line -match '^\s+status:\s*(.+)$') { $current.status = $Matches[1].Trim() }
    if ($line -match '^\s+siblingPath:\s*(.+)$') { $current.siblingPath = $Matches[1].Trim() }
  }
}
if ($null -ne $current) { $products += $current }

# Repos that already exist on origin org or should not be recreated as empty
$skipAlways = @('supercore', 'supergarage')

function Ensure-LocalScaffold($product) {
  $folder = ($product.siblingPath -replace '^\.\./', '')
  $path = Join-Path $HanturaiRoot $folder
  if (Test-Path $path) { return $path }

  New-Item -ItemType Directory -Force -Path $path | Out-Null
  $line = $product.productLine
  $readme = @"
# $($product.name)

**Product line:** $line  
**Package:** ``$($product.package)``  
**Status:** $($product.status)

Part of the [AfterArtificial AI Operating System](https://github.com/$Org/supercore).

- Consumer reference: **SuperGarage**
- Enterprise reference: **SuperHospital**
- Shared kernel: ``after_core`` + ``after_design_system``
- OS layer: ``$(if ($line -eq 'enterprise') { 'after_enterprise' } else { 'after_consumer' })``

## Generate from standard

See [supercore/docs/AFTER_OS_ARCHITECTURE.md](https://github.com/$Org/supercore/blob/main/docs/AFTER_OS_ARCHITECTURE.md)
and templates under ``templates/super_app_$line/``.

Do not invent a new architecture — assemble from After OS standards.
"@
  Set-Content -Path (Join-Path $path 'README.md') -Value $readme -Encoding UTF8
  $gitignore = @"
.dart_tool/
.packages
build/
.idea/
*.iml
.vscode/
coverage/
local_secrets.dart
"@
  Set-Content -Path (Join-Path $path '.gitignore') -Value $gitignore -Encoding UTF8
  return $path
}

foreach ($p in $products) {
  $repoName = ($p.siblingPath -replace '^\.\./', '')
  if ([string]::IsNullOrWhiteSpace($repoName)) { continue }
  if ($skipAlways -contains $repoName) {
    Write-Host "SKIP existing flagship/core: $repoName"
    continue
  }

  $local = Ensure-LocalScaffold $p
  Write-Host "LOCAL $local"

  $exists = $false
  try {
    & $Gh repo view "$Org/$repoName" --json name 2>$null | Out-Null
    if ($LASTEXITCODE -eq 0) { $exists = $true }
  } catch { $exists = $false }

  if ($DryRun) {
    Write-Host "DRYRUN would ensure repo $Org/$repoName (exists=$exists)"
    continue
  }

  if (-not $exists) {
    Write-Host "CREATE $Org/$repoName"
    & $Gh repo create "$Org/$repoName" --private --description "$($p.name) — AfterArtificial $($p.productLine) Super App" --confirm
  } else {
    Write-Host "EXISTS $Org/$repoName"
  }

  Push-Location $local
  try {
    if (-not (Test-Path '.git')) {
      git init -b main
      git add .
      git commit -m "Initial scaffold for $($p.name) ($($p.productLine) line)."
    }
    $remote = "https://github.com/$Org/$repoName.git"
    $hasOrigin = git remote 2>$null | Select-String -Pattern '^origin$' -Quiet
    if (-not $hasOrigin) {
      git remote add origin $remote
    } else {
      git remote set-url origin $remote
    }
    git push -u origin HEAD:main
    Write-Host "PUSHED $Org/$repoName"
  } finally {
    Pop-Location
  }
}

Write-Host 'Done.'
