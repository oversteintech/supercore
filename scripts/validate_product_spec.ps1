# Validate a product.spec.yaml against the AfterArtificial factory schema.
#
# Usage:
#   powershell -File scripts\validate_product_spec.ps1 -SpecPath factory\specs\examples\super_airport.product.spec.yaml
#
# Exits 0 when the spec parses and passes basic checks, 1 otherwise.

param(
  [Parameter(Mandatory)][string]$SpecPath
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot '_spec_parser.ps1')

if (-not (Test-Path $SpecPath)) {
  Write-Host "ERROR: spec not found: $SpecPath" -ForegroundColor Red
  exit 1
}

try {
  $spec = Read-ProductSpec -Path $SpecPath
} catch {
  Write-Host "ERROR: failed to parse YAML: $($_.Exception.Message)" -ForegroundColor Red
  exit 1
}

$result = Test-ProductSpec -Spec $spec
if ($result.ok) {
  $name = $spec.metadata.name
  $line = $spec.metadata.productLine
  $ref = $spec.spec.reference
  $features = @($spec.spec.features).Count
  $tabs = @($spec.spec.navigation.tabs).Count
  $widgets = @($spec.spec.dashboard.widgets).Count
  $skills = @($spec.spec.ai.skills).Count
  Write-Host "OK  $SpecPath" -ForegroundColor Green
  Write-Host "    name=$name line=$line reference=$ref"
  Write-Host "    features=$features tabs=$tabs dashboard_widgets=$widgets ai_skills=$skills"
  exit 0
} else {
  Write-Host "FAIL $SpecPath" -ForegroundColor Red
  foreach ($e in $result.errors) {
    Write-Host " - $e" -ForegroundColor Red
  }
  exit 1
}
