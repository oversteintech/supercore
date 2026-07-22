# Adds productId: AfterProductId.xyz to sibling FamilyChromeConfig blocks.
# Does NOT touch SuperGarage.

$map = @{
  'afterhub'           = 'afterHub'
  'superhealth'        = 'health'
  'superfinance'       = 'finance'
  'superhome'          = 'home'
  'supertravel'        = 'travel'
  'superpet'           = 'pet'
  'supernews'          = 'news'
  'supersports'        = 'sports'
  'supergames'         = 'games'
  'superfamily'        = 'family'
  'superdocuments'     = 'documents'
  'superlearning'      = 'learning'
  'superhospital'      = 'hospital'
  'superairport'       = 'airport'
  'supermaritime'      = 'maritime'
  'superfactory'       = 'factory'
  'superlogistics'     = 'logistics'
  'superconstruction'  = 'construction'
  'superschool'        = 'school'
  'superhotel'         = 'hotel'
  'superrestaurant'    = 'restaurant'
  'superretail'        = 'retail'
  'superenergy'        = 'energy'
  'supermunicipality'  = 'municipality'
  'superfarm'          = 'farm'
  'superagriculture'   = 'agriculture'
  'superpolice'        = 'police'
  'superfire'          = 'fire'
  'supermining'        = 'mining'
}

$root = 'D:\Projects\HANTURAI'
foreach ($folder in $map.Keys) {
  $path = Join-Path $root "$folder\lib\app\family\family_stores.dart"
  if (-not (Test-Path $path)) {
    Write-Host "skip missing $path"
    continue
  }
  $text = Get-Content -Raw -Path $path
  if ($text -match 'productId:') {
    Write-Host "already wired $folder"
    continue
  }
  $id = $map[$folder]
  # Insert productId after accent line inside FamilyChromeConfig.
  $updated = [regex]::Replace(
    $text,
    '(const\s+\w+Chrome\s*=\s*FamilyChromeConfig\([\s\S]*?accent:\s*[^,\n]+,)',
    "`$1`r`n  productId: AfterProductId.$id,"
  )
  if ($updated -eq $text) {
    Write-Host "no match $folder"
    continue
  }
  # Ensure after_design_system import if needed for AfterProductId —
  # AfterProductId is exported via after_consumer -> after_design_system.
  # family_stores already imports after_consumer.
  Set-Content -Path $path -Value $updated -NoNewline
  Write-Host "wired $folder -> $id"
}
Write-Host 'done'
