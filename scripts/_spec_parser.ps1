# Shared minimal YAML parser for AfterArtificial product.spec.yaml files.
# Tuned to the shape declared in factory/schema/product.spec.schema.json.
#
# Public API:
#   Read-ProductSpec  -Path <file>          → ordered-hashtable (spec)
#   Get-ProductSpec   -Name <SuperName>     → hashtable synthesized from name
#   Test-ProductSpec  -Spec <hashtable>     → returns @{ ok, errors[] }
#
# Deliberately NOT a general-purpose YAML parser. Supports:
#   * mappings, nested mappings
#   * lists via `- key: value` block syntax
#   * scalars (strings, ints, bools) with optional `"..."` quotes
#   * flow lists like `[en, tr]` (strings only)
#   * indented `subtitleKey: ...` continuation entries under list items
#   * empty list values (`permissions: []`)
#   * comments (`# ...`) and blank lines

$ErrorActionPreference = 'Stop'

# Parser state — script-scoped so recursive helpers can share it.
$script:SpecLines = @()
$script:SpecPos = 0

function ConvertTo-SpecScalar {
  param([string]$Raw)
  if ($null -eq $Raw) { return $null }
  $t = $Raw.Trim()
  if ($t -eq '' -or $t -eq '~' -or $t -eq 'null') { return $null }
  if ($t -match '^\[(.*)\]$') {
    $inner = $Matches[1].Trim()
    if ($inner -eq '') { return @() }
    $items = @()
    foreach ($seg in $inner.Split(',')) {
      $items += (ConvertTo-SpecScalar $seg)
    }
    return , $items
  }
  if ($t -match '^"(.*)"$' -or $t -match "^'(.*)'$") {
    return $Matches[1]
  }
  if ($t -eq 'true') { return $true }
  if ($t -eq 'false') { return $false }
  if ($t -match '^-?\d+$') { return [int]$t }
  return $t
}

function Get-SpecIndent {
  param([string]$Line)
  $count = 0
  foreach ($ch in $Line.ToCharArray()) {
    if ($ch -eq ' ') { $count++ } else { break }
  }
  return $count
}

function Read-SpecBlock {
  param([int]$MinIndent)
  $node = [ordered]@{}
  while ($script:SpecPos -lt $script:SpecLines.Count) {
    $line = $script:SpecLines[$script:SpecPos]
    $indent = Get-SpecIndent $line
    if ($indent -lt $MinIndent) { return $node }
    $content = $line.Substring($indent)
    if ($content.StartsWith('- ')) { return $node }

    $script:SpecPos++

    if ($content -match '^([A-Za-z0-9_]+):\s*$') {
      $key = $Matches[1]
      if ($script:SpecPos -ge $script:SpecLines.Count) {
        $node[$key] = $null
        continue
      }
      $nextLine = $script:SpecLines[$script:SpecPos]
      $nextIndent = Get-SpecIndent $nextLine
      if ($nextIndent -le $indent) {
        $node[$key] = $null
        continue
      }
      $nextContent = $nextLine.Substring($nextIndent)
      if ($nextContent.StartsWith('- ')) {
        $node[$key] = Read-SpecList -MinIndent $nextIndent
      } else {
        $node[$key] = Read-SpecBlock -MinIndent $nextIndent
      }
    } elseif ($content -match '^([A-Za-z0-9_]+):\s*(.+)$') {
      $key = $Matches[1]
      $val = $Matches[2]
      $node[$key] = ConvertTo-SpecScalar $val
    } else {
      throw "Unrecognized line: $line"
    }
  }
  return $node
}

function Read-SpecList {
  param([int]$MinIndent)
  $list = @()
  while ($script:SpecPos -lt $script:SpecLines.Count) {
    $line = $script:SpecLines[$script:SpecPos]
    $indent = Get-SpecIndent $line
    if ($indent -lt $MinIndent) { return , $list }
    $content = $line.Substring($indent)
    if (-not $content.StartsWith('- ')) { return , $list }
    $script:SpecPos++
    $rest = $content.Substring(2)

    if ($rest -match '^([A-Za-z0-9_]+):\s*(.*)$') {
      $item = [ordered]@{}
      $firstKey = $Matches[1]
      $firstVal = $Matches[2]
      if ($firstVal.Trim() -ne '') {
        $item[$firstKey] = ConvertTo-SpecScalar $firstVal
      } else {
        if ($script:SpecPos -lt $script:SpecLines.Count) {
          $peek = $script:SpecLines[$script:SpecPos]
          $peekIndent = Get-SpecIndent $peek
          if ($peekIndent -gt ($indent + 2)) {
            $peekContent = $peek.Substring($peekIndent)
            if ($peekContent.StartsWith('- ')) {
              $item[$firstKey] = Read-SpecList -MinIndent $peekIndent
            } else {
              $item[$firstKey] = Read-SpecBlock -MinIndent $peekIndent
            }
          } else {
            $item[$firstKey] = $null
          }
        } else {
          $item[$firstKey] = $null
        }
      }

      $childIndent = $indent + 2
      while ($script:SpecPos -lt $script:SpecLines.Count) {
        $peek = $script:SpecLines[$script:SpecPos]
        $peekIndent = Get-SpecIndent $peek
        if ($peekIndent -lt $childIndent) { break }
        $peekContent = $peek.Substring($peekIndent)
        if ($peekContent.StartsWith('- ')) { break }
        if ($peekIndent -eq $childIndent -and $peekContent -match '^([A-Za-z0-9_]+):\s*(.*)$') {
          $script:SpecPos++
          $k = $Matches[1]
          $v = $Matches[2]
          if ($v.Trim() -eq '') {
            if ($script:SpecPos -lt $script:SpecLines.Count) {
              $peek2 = $script:SpecLines[$script:SpecPos]
              $peek2Indent = Get-SpecIndent $peek2
              if ($peek2Indent -gt $childIndent) {
                $peek2Content = $peek2.Substring($peek2Indent)
                if ($peek2Content.StartsWith('- ')) {
                  $item[$k] = Read-SpecList -MinIndent $peek2Indent
                } else {
                  $item[$k] = Read-SpecBlock -MinIndent $peek2Indent
                }
              } else {
                $item[$k] = $null
              }
            } else {
              $item[$k] = $null
            }
          } else {
            $item[$k] = ConvertTo-SpecScalar $v
          }
        } else {
          break
        }
      }
      $list += , $item
    } else {
      $list += , (ConvertTo-SpecScalar $rest)
    }
  }
  return , $list
}

function Read-ProductSpec {
  param([Parameter(Mandatory)][string]$Path)

  if (-not (Test-Path $Path)) {
    throw "product.spec not found: $Path"
  }
  $raw = Get-Content -Raw -Path $Path
  $lines = @()
  foreach ($line in ($raw -split "`r?`n")) {
    if ($line -match '^\s*#') { continue }
    $noComment = $line -replace '\s+#.*$', ''
    if ($noComment.Trim() -eq '') { continue }
    $lines += $noComment.TrimEnd()
  }

  $script:SpecLines = $lines
  $script:SpecPos = 0

  return (Read-SpecBlock -MinIndent 0)
}

function Get-ProductSpec {
  param(
    [Parameter(Mandatory)][string]$Name,
    [string]$Reference = 'SuperHospital'
  )
  $line = if ($Reference -eq 'SuperGarage') { 'consumer' } else { 'enterprise' }
  $package = ((($Name -creplace '([A-Z])', '_$1').ToLowerInvariant()).TrimStart('_'))
  $bundleSuffix = ($Name.ToLowerInvariant())
  $mono = ($Name -creplace '[^A-Z]', '')
  if ($mono.Length -gt 3) { $mono = $mono.Substring(0, 3) }
  if ($mono.Length -lt 2) { $mono = $Name.Substring(0, 2).ToUpperInvariant() }

  $spec = [ordered]@{
    apiVersion = 'after.ai/v1'
    kind       = 'SuperApp'
    metadata   = [ordered]@{
      name        = $Name
      package     = $package
      bundle      = "com.overstein.$bundleSuffix"
      productLine = $line
    }
    spec       = [ordered]@{
      domain     = "$Name domain"
      reference  = $Reference
      features   = @(
        [ordered]@{ id = 'core'; titleKey = 'features.core'; subtitleKey = 'features.core_sub' }
      )
      navigation = [ordered]@{
        tabs = @(
          [ordered]@{ id = 'home'; labelKey = 'nav.home'; icon = 'home_outlined' },
          [ordered]@{ id = 'core'; labelKey = 'nav.core'; icon = 'apps_outlined'; feature = 'core' },
          [ordered]@{ id = 'assistant'; labelKey = 'nav.assistant'; icon = 'auto_awesome_outlined'; module = 'assistant' },
          [ordered]@{ id = 'more'; labelKey = 'nav.more'; icon = 'more_horiz_outlined'; module = 'more' }
        )
      }
      permissions = @()
      dashboard   = [ordered]@{ widgets = @() }
      ai          = [ordered]@{ skills = @() }
      branding    = [ordered]@{ accent = '#22D3EE'; monogram = $mono }
      locales     = @(
        'en','zh','hi','es','fr','ar','bn','pt','ru','ur',
        'id','de','ja','sw','mr','te','tr','ta','vi','ko'
      )
    }
  }
  return $spec
}

function Test-ProductSpec {
  param([Parameter(Mandatory)]$Spec)
  $errors = @()

  if ($Spec.apiVersion -ne 'after.ai/v1') {
    $errors += "apiVersion must equal 'after.ai/v1' (got '$($Spec.apiVersion)')"
  }
  if ($Spec.kind -ne 'SuperApp') {
    $errors += "kind must equal 'SuperApp' (got '$($Spec.kind)')"
  }

  $meta = $Spec.metadata
  if (-not $meta) {
    $errors += 'metadata block missing'
  } else {
    foreach ($k in 'name', 'package', 'bundle', 'productLine') {
      if ([string]::IsNullOrWhiteSpace([string]$meta[$k])) {
        $errors += "metadata.$k is required"
      }
    }
    if ($meta.productLine -and $meta.productLine -notin @('consumer', 'enterprise')) {
      $errors += "metadata.productLine must be 'consumer' or 'enterprise'"
    }
    if ($meta.name -and $meta.name -notmatch '^[A-Z][A-Za-z0-9]*$') {
      $errors += 'metadata.name must be PascalCase'
    }
    if ($meta.package -and $meta.package -notmatch '^[a-z][a-z0-9_]*$') {
      $errors += 'metadata.package must be snake_case'
    }
    if ($meta.bundle -and $meta.bundle -notmatch '^com\.overstein\.[a-z0-9]+$') {
      $errors += 'metadata.bundle must match com.overstein.<lowercase>'
    }
  }

  $s = $Spec.spec
  if (-not $s) {
    $errors += 'spec block missing'
    return @{ ok = $false; errors = $errors }
  }
  if ([string]::IsNullOrWhiteSpace([string]$s.domain)) {
    $errors += 'spec.domain is required'
  }
  if ($s.reference -and $s.reference -notin @('SuperGarage', 'SuperHospital')) {
    $errors += "spec.reference must be 'SuperGarage' or 'SuperHospital'"
  }
  $featureCount = @($s.features).Count
  if ($featureCount -lt 1) {
    $errors += 'spec.features must contain at least one entry'
  }
  $tabCount = 0
  if ($s.navigation -and $s.navigation.tabs) {
    $tabCount = @($s.navigation.tabs).Count
  }
  if ($tabCount -lt 2) {
    $errors += 'spec.navigation.tabs must contain at least 2 tabs'
  }
  if ($tabCount -gt 6) {
    $errors += 'spec.navigation.tabs must contain at most 6 tabs'
  }

  return @{ ok = ($errors.Count -eq 0); errors = $errors }
}
