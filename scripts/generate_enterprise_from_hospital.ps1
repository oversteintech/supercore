# !!! TRANSITIONAL / DISCOURAGED !!!
# Cloning SuperHospital duplicates shell code and VIOLATES the ≥90% platform
# reuse doctrine (docs/PLATFORM_DOCTRINE.md).
#
# Prefer:  scripts\generate_product.ps1 -SpecPath factory\specs\examples\...
#          then mount AfterEnterpriseAuthGate + AfterEnterpriseMainShell
#          with EnterpriseProductRuntime from product.spec.yaml.
#
# This script remains only as a bridge for existing scaffolds. Do not expand it.
# Do not use it for new product lines.
#
# Usage (legacy):
#   powershell -File scripts\generate_enterprise_from_hospital.ps1 -Vertical Airport
#

param(
  [Parameter(Mandatory = $true)]
  [ValidateSet('Airport', 'Maritime', 'Factory', 'Hospital')]
  [string]$Vertical,
  [string]$HanturaiRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path,
  [switch]$SkipFlutterCreate,
  # ADR-008: required escape hatch — script hard-fails without it.
  [switch]$IKnowThisViolatesDoctrine
)

$ErrorActionPreference = 'Stop'

if (-not $IKnowThisViolatesDoctrine) {
  Write-Error @"
FATAL (ADR-008): generate_enterprise_from_hospital.ps1 is disabled.

Cloning SuperHospital violates PLATFORM_DOCTRINE (≥90% reuse).

Use instead:
  powershell -File scripts\generate_product.ps1 -SpecPath factory\specs\examples\...

If you intentionally need this transitional bridge, re-run with:
  -IKnowThisViolatesDoctrine
"@
  exit 1
}

$configs = @{
  Hospital = @{
    Name = 'SuperHospital'; Folder = 'superhospital'; Package = 'super_hospital'
    Bundle = 'com.overstein.superhospital'; Monogram = 'SH'; Accent = '#F43F5E'
    Domain = 'Hospital operations'; OrgName = 'General Hospital'; OrgSlug = 'general-hospital'
    OrgId = 'org_general_hospital'; AiLabel = 'Hospital AI'
    SeedIcon = 'local_hospital_outlined'
    SpecRel = 'factory\specs\examples\super_hospital.product.spec.yaml'
    WorkflowSrc = 'examples\workflows\hospital_catalog.json'
    PluginSrc = 'examples\plugins\superhospital_plugins.json'
    DashboardSrc = 'examples\dashboard\superhospital_home.json'
    Features = @(
      @{ Id='patients'; Title='Patients'; Sub='Demographics, MRN, admission status'; Perm='patients:read'; Icon='people_outline' }
      @{ Id='appointments'; Title='Appointments'; Sub='Booking and clinician calendars'; Perm='appointments:read'; Icon='event_available_outlined' }
      @{ Id='wards'; Title='Wards'; Sub='Bed occupancy grid'; Perm='wards:read'; Icon='bed_outlined' }
      @{ Id='staff'; Title='Staff'; Sub='Clinicians and on-call roster'; Perm='staff:read'; Icon='medical_services_outlined' }
      @{ Id='clinicalNotes'; Title='Clinical Notes'; Sub='Patient timeline entries'; Perm='notes:read'; Icon='note_alt_outlined' }
      @{ Id='pharmacy'; Title='Pharmacy'; Sub='Stock and dispense records'; Perm='pharmacy:read'; Icon='local_pharmacy_outlined' }
      @{ Id='labOrders'; Title='Lab Orders'; Sub='Order, collect, resulted workflow'; Perm='lab:read'; Icon='science_outlined' }
      @{ Id='billing'; Title='Billing'; Sub='Line items, payer, claims'; Perm='billing:read'; Icon='receipt_long_outlined' }
      @{ Id='compliance'; Title='Compliance'; Sub='HIPAA / GDPR audit exports'; Perm='compliance:read'; Icon='verified_user_outlined' }
      @{ Id='hospitalAi'; Title='Hospital AI'; Sub='Triage helper and discharge summariser'; Perm=$null; Icon='auto_awesome_outlined' }
    )
  }
  Airport = @{
    Name = 'SuperAirport'; Folder = 'superairport'; Package = 'super_airport'
    Bundle = 'com.overstein.superairport'; Monogram = 'SA'; Accent = '#0EA5E9'
    Domain = 'Airport / aviation operations'; OrgName = 'Metro International Airport'; OrgSlug = 'metro-airport'
    OrgId = 'org_metro_airport'; AiLabel = 'Airport AI'
    SeedIcon = 'flight_takeoff_outlined'
    SpecRel = 'factory\specs\examples\super_airport.product.spec.yaml'
    WorkflowSrc = 'examples\workflows\airport_catalog.json'
    PluginSrc = 'examples\plugins\supergarage_plugins.json'
    DashboardSrc = 'examples\dashboard\supergarage_home.json'
    Features = @(
      @{ Id='flights'; Title='Flights'; Sub='Departures, arrivals, delays'; Perm='airport.flights.read'; Icon='flight_takeoff_outlined' }
      @{ Id='gates'; Title='Gates'; Sub='Gate assignment and turnaround'; Perm='airport.gates.read'; Icon='airline_seat_recline_normal_outlined' }
      @{ Id='runways'; Title='Runways & Slots'; Sub='Slot capacity and runway status'; Perm='airport.runways.read'; Icon='flight_outlined' }
      @{ Id='baggage'; Title='Baggage'; Sub='Belt and transfer tracking'; Perm='airport.baggage.read'; Icon='luggage_outlined' }
      @{ Id='security'; Title='Security Screening'; Sub='Checkpoint queues and alerts'; Perm='airport.security.read'; Icon='security_outlined' }
      @{ Id='boarding'; Title='Check-In & Boarding'; Sub='Desk and boarding status'; Perm='airport.boarding.read'; Icon='airplane_ticket_outlined' }
      @{ Id='groundOps'; Title='Ground Ops'; Sub='Turnaround crews and equipment'; Perm='airport.ground_ops.read'; Icon='engineering_outlined' }
      @{ Id='crew'; Title='Crew Rotations'; Sub='Crew assignment and briefing'; Perm='airport.crew.read'; Icon='groups_outlined' }
      @{ Id='cargo'; Title='Cargo'; Sub='Air cargo handling'; Perm='airport.cargo.read'; Icon='inventory_2_outlined' }
      @{ Id='airportAi'; Title='Airport AI'; Sub='Delay briefs and gate insights'; Perm=$null; Icon='auto_awesome_outlined' }
    )
  }
  Maritime = @{
    Name = 'SuperMaritime'; Folder = 'supermaritime'; Package = 'super_maritime'
    Bundle = 'com.overstein.supermaritime'; Monogram = 'SM'; Accent = '#0284C7'
    Domain = 'Port and vessel operations'; OrgName = 'Harbor Port Authority'; OrgSlug = 'harbor-port'
    OrgId = 'org_harbor_port'; AiLabel = 'Maritime AI'
    SeedIcon = 'directions_boat_outlined'
    SpecRel = 'factory\specs\examples\super_maritime.product.spec.yaml'
    WorkflowSrc = 'examples\workflows\maritime_catalog.json'
    PluginSrc = 'examples\plugins\superhospital_plugins.json'
    DashboardSrc = 'examples\dashboard\superhospital_home.json'
    Features = @(
      @{ Id='vessels'; Title='Vessels'; Sub='Fleet registry and AIS status'; Perm='maritime.vessels.read'; Icon='directions_boat_outlined' }
      @{ Id='berths'; Title='Berths & Anchorage'; Sub='Berth allocation board'; Perm='maritime.berths.read'; Icon='place_outlined' }
      @{ Id='portCalls'; Title='Port Calls'; Sub='Inbound and outbound calls'; Perm='maritime.port_calls.read'; Icon='map_outlined' }
      @{ Id='cargo'; Title='Cargo Manifests'; Sub='Manifests and hazardous goods'; Perm='maritime.cargo.read'; Icon='inventory_2_outlined' }
      @{ Id='pilots'; Title='Pilots'; Sub='Pilotage roster and jobs'; Perm='maritime.pilots.read'; Icon='explore_outlined' }
      @{ Id='tugs'; Title='Tugs'; Sub='Tug assist scheduling'; Perm='maritime.tugs.read'; Icon='directions_boat_outlined' }
      @{ Id='bunkering'; Title='Bunkering'; Sub='Fuel and bunker ops'; Perm='maritime.bunkering.read'; Icon='local_gas_station_outlined' }
      @{ Id='customs'; Title='Customs & Clearance'; Sub='Clearance workflows'; Perm='maritime.customs.read'; Icon='gavel_outlined' }
      @{ Id='crewChange'; Title='Crew Change'; Sub='Crew change logistics'; Perm='maritime.crew.read'; Icon='groups_outlined' }
      @{ Id='maritimeAi'; Title='Maritime AI'; Sub='Arrival briefs and berth plans'; Perm=$null; Icon='auto_awesome_outlined' }
    )
  }
  Factory = @{
    Name = 'SuperFactory'; Folder = 'superfactory'; Package = 'super_factory'
    Bundle = 'com.overstein.superfactory'; Monogram = 'SF'; Accent = '#F59E0B'
    Domain = 'Factory floor and manufacturing operations'; OrgName = 'North Plant'; OrgSlug = 'north-plant'
    OrgId = 'org_north_plant'; AiLabel = 'Factory AI'
    SeedIcon = 'precision_manufacturing_outlined'
    SpecRel = 'factory\specs\examples\super_factory.product.spec.yaml'
    WorkflowSrc = 'examples\workflows\factory_catalog.json'
    PluginSrc = 'examples\plugins\supergarage_plugins.json'
    DashboardSrc = 'examples\dashboard\supergarage_home.json'
    Features = @(
      @{ Id='lines'; Title='Production Lines'; Sub='Line status and throughput'; Perm='factory.lines.read'; Icon='view_week_outlined' }
      @{ Id='workOrders'; Title='Work Orders'; Sub='Open and in-progress orders'; Perm='factory.work_orders.read'; Icon='assignment_outlined' }
      @{ Id='machines'; Title='Machines'; Sub='Asset health and telemetry'; Perm='factory.machines.read'; Icon='precision_manufacturing_outlined' }
      @{ Id='maintenance'; Title='Maintenance'; Sub='PM and repair jobs'; Perm='factory.maintenance.read'; Icon='build_outlined' }
      @{ Id='downtime'; Title='Downtime & Andon'; Sub='Stops and andon alerts'; Perm='factory.downtime.read'; Icon='report_problem_outlined' }
      @{ Id='oee'; Title='OEE'; Sub='Availability, performance, quality'; Perm='factory.oee.read'; Icon='speed_outlined' }
      @{ Id='quality'; Title='Quality Control'; Sub='Inspections and scrap'; Perm='factory.quality.read'; Icon='verified_outlined' }
      @{ Id='shifts'; Title='Shifts'; Sub='Shift roster and handover'; Perm='factory.shifts.read'; Icon='schedule_outlined' }
      @{ Id='inventory'; Title='Inventory'; Sub='WIP and finished goods'; Perm='factory.inventory.read'; Icon='warehouse_outlined' }
      @{ Id='factoryAi'; Title='Factory AI'; Sub='OEE briefs and maintenance tips'; Perm=$null; Icon='auto_awesome_outlined' }
    )
  }
}

$cfg = $configs[$Vertical]
$src = Join-Path $HanturaiRoot 'superhospital'
$dst = Join-Path $HanturaiRoot $cfg.Folder
$supercore = Join-Path $HanturaiRoot 'supercore'
$prefix = ($cfg.Package -split '_')[1]  # hospital | airport | maritime | factory
$PrefixPascal = (Get-Culture).TextInfo.ToTitleCase($prefix)  # Hospital | Airport...
$NameNoSuper = $cfg.Name -replace '^Super', ''

Write-Host "==> Generating $($cfg.Name) from SuperHospital reference"
Write-Host "    target = $dst"

if (-not (Test-Path $src)) { throw "SuperHospital source missing: $src" }
New-Item -ItemType Directory -Force -Path $dst | Out-Null

# Preserve PRODUCT.md / existing git
$preserve = @('docs\PRODUCT.md', '.git')
foreach ($p in $preserve) {
  $full = Join-Path $dst $p
  if (Test-Path $full) { Write-Host "  [KEEP] $p" }
}

# Wipe generated trees (keep docs + .git)
foreach ($wipe in @('lib', 'test', '.github')) {
  $path = Join-Path $dst $wipe
  if (Test-Path $path) { Remove-Item -Recurse -Force $path }
}

# Copy shell from SuperHospital
foreach ($copy in @('lib', 'test', '.github', 'analysis_options.yaml', '.gitignore')) {
  $from = Join-Path $src $copy
  $to = Join-Path $dst $copy
  if (-not (Test-Path $from)) { continue }
  if (Test-Path $from -PathType Container) {
    Copy-Item -Recurse -Force $from $to
  } else {
    Copy-Item -Force $from $to
  }
  Write-Host "  [COPY] $copy"
}

# Remove hospital-only industry feature folders (OS tabs stay)
$removeDirs = @(
  'patients', 'appointments', 'wards', 'staff', 'clinical_notes',
  'pharmacy', 'lab_orders', 'billing', 'compliance'
)
foreach ($d in $removeDirs) {
  $p = Join-Path $dst "lib\features\$d"
  if (Test-Path $p) { Remove-Item -Recurse -Force $p }
}

# Rename hospital-specific files
$renames = @(
  @{ From = "lib\domain\entities\hospital_feature.dart"; To = "lib\domain\entities\${prefix}_feature.dart" }
  @{ From = "lib\app\navigation\hospital_feature_icons.dart"; To = "lib\app\navigation\${prefix}_feature_icons.dart" }
  @{ From = "lib\data\repositories\seeded_hospital_repository.dart"; To = "lib\data\repositories\seeded_${prefix}_repository.dart" }
  @{ From = "lib\features\ai\hospital_ai_screen.dart"; To = "lib\features\ai\${prefix}_ai_screen.dart" }
)
foreach ($r in $renames) {
  $from = Join-Path $dst $r.From
  $to = Join-Path $dst $r.To
  if (Test-Path $from) {
    $parent = Split-Path $to -Parent
    New-Item -ItemType Directory -Force -Path $parent | Out-Null
    Move-Item -Force $from $to
    Write-Host "  [RENAME] $($r.From) -> $($r.To)"
  }
}

function Replace-InTree {
  param([string]$Root, [System.Collections.IDictionary]$Map)
  Get-ChildItem -Path $Root -Recurse -File | Where-Object {
    $_.Extension -in '.dart', '.yaml', '.yml', '.md', '.json'
  } | ForEach-Object {
    $text = [IO.File]::ReadAllText($_.FullName)
    $orig = $text
    foreach ($k in $Map.Keys) {
      $text = $text.Replace($k, [string]$Map[$k])
    }
    if ($text -ne $orig) {
      [IO.File]::WriteAllText($_.FullName, $text)
    }
  }
}

# Ordered replacements (longer / more specific first)
$map = [System.Collections.Specialized.OrderedDictionary]::new([System.StringComparer]::Ordinal)
$map.Add('super_hospital', $cfg.Package)
$map.Add('SuperHospital', $cfg.Name)
$map.Add('superHospital', 'super' + $NameNoSuper)
$map.Add('superhospital', $cfg.Folder)
$map.Add('com.overstein.superhospital', $cfg.Bundle)
$map.Add('HospitalFeatureId', "${PrefixPascal}FeatureId")
$map.Add('HospitalFeatureCatalog', "${PrefixPascal}FeatureCatalog")
$map.Add('HospitalFeature', "${PrefixPascal}Feature")
$map.Add('hospitalFeatureIconFor', "${prefix}FeatureIconFor")
$map.Add('hospital_feature', "${prefix}_feature")
$map.Add('HospitalAiScreen', "${PrefixPascal}AiScreen")
$map.Add('hospital_ai_screen', "${prefix}_ai_screen")
$map.Add('buildSeededHospitalRepository', "buildSeeded${PrefixPascal}Repository")
$map.Add('seeded_hospital_repository', "seeded_${prefix}_repository")
$map.Add('createSuperHospitalOverrides', "createSuper${NameNoSuper}Overrides")
$map.Add('superHospitalManifest', "super${NameNoSuper}Manifest")
$map.Add('superHospitalPlatformManifestProvider', "super${NameNoSuper}PlatformManifestProvider")
$map.Add('General Hospital', $cfg.OrgName)
$map.Add('general-hospital', $cfg.OrgSlug)
$map.Add('org_general_hospital', $cfg.OrgId)
$map.Add('Hospital AI', $cfg.AiLabel)
$map.Add('local_hospital_outlined', $cfg.SeedIcon)

Replace-InTree -Root $dst -Map $map

# Rewrite vertical feature entity
$enumLines = ($cfg.Features | ForEach-Object { "  $($_.Id)," }) -join "`n"
$catalogLines = foreach ($f in $cfg.Features) {
  $perm = if ($f.Perm) { "`n      requiredPermission: '$($f.Perm)'," } else { '' }
  @"
    ${PrefixPascal}Feature(
      id: ${PrefixPascal}FeatureId.$($f.Id),
      titleKey: 'features.$($f.Id -creplace '([A-Z])','_$1').ToLower() -replace '^_','' -replace '__','_',
      subtitleKey: 'features.$($f.Id)_sub',$perm
    ),
"@
}

# Fix title keys properly
$catalogEntries = New-Object System.Collections.Generic.List[string]
$iconCases = New-Object System.Collections.Generic.List[string]
$enStrings = New-Object System.Collections.Generic.List[string]
$trStrings = New-Object System.Collections.Generic.List[string]
$snake = {
  param($s)
  ($s -creplace '([a-z0-9])([A-Z])', '$1_$2').ToLowerInvariant()
}

foreach ($f in $cfg.Features) {
  $key = & $snake $f.Id
  $permLine = if ($f.Perm) { "      requiredPermission: '$($f.Perm)',`n" } else { '' }
  $catalogEntries.Add(@"
    ${PrefixPascal}Feature(
      id: ${PrefixPascal}FeatureId.$($f.Id),
      titleKey: 'features.$key',
      subtitleKey: 'features.${key}_sub',
$permLine    ),
"@)
  $iconCases.Add("    case ${PrefixPascal}FeatureId.$($f.Id):`n      return Icons.$($f.Icon);")
  $enStrings.Add("  'features.$key': '$($f.Title)',")
  $enStrings.Add("  'features.${key}_sub': '$($f.Sub)',")
  $trStrings.Add("  'features.$key': '$($f.Title)',")
  $trStrings.Add("  'features.${key}_sub': '$($f.Sub)',")
}

$featureDart = @"
/// $NameNoSuper-specific vertical features. Kept pure (no Flutter imports).
///
/// Presentation-layer icon + navigation mapping lives in
/// ``lib/app/navigation/${prefix}_feature_icons.dart``.
enum ${PrefixPascal}FeatureId {
$enumLines
}

class ${PrefixPascal}Feature {
  const ${PrefixPascal}Feature({
    required this.id,
    required this.titleKey,
    required this.subtitleKey,
    this.requiredPermission,
  });

  final ${PrefixPascal}FeatureId id;
  final String titleKey;
  final String subtitleKey;
  final String? requiredPermission;
}

abstract final class ${PrefixPascal}FeatureCatalog {
  static const List<${PrefixPascal}Feature> all = [
$($catalogEntries -join "`n")
  ];

  static ${PrefixPascal}Feature byId(${PrefixPascal}FeatureId id) =>
      all.firstWhere((feature) => feature.id == id);
}
"@
[IO.File]::WriteAllText((Join-Path $dst "lib\domain\entities\${prefix}_feature.dart"), $featureDart)

$iconsDart = @"
import 'package:flutter/material.dart';

import '../../domain/entities/${prefix}_feature.dart';

/// Presentation-layer mapping from feature IDs to Material icons.
IconData ${prefix}FeatureIconFor(${PrefixPascal}FeatureId id) {
  switch (id) {
$($iconCases -join "`n")
  }
}
"@
[IO.File]::WriteAllText((Join-Path $dst "lib\app\navigation\${prefix}_feature_icons.dart"), $iconsDart)

# Placeholder industry screens -- one folder per feature (except *Ai)
foreach ($f in $cfg.Features) {
  if ($f.Id -match 'Ai$') { continue }
  $key = & $snake $f.Id
  $dir = Join-Path $dst "lib\features\$key"
  New-Item -ItemType Directory -Force -Path $dir | Out-Null
  $pascal = ($f.Id.Substring(0,1).ToUpper() + $f.Id.Substring(1))
  $screen = @"
import 'package:flutter/material.dart';

import '../common/feature_placeholder.dart';

class ${pascal}Screen extends StatelessWidget {
  const ${pascal}Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholder(
      title: '$($f.Title)',
      subtitle: '$($f.Sub)',
      icon: Icons.$($f.Icon),
    );
  }
}
"@
  [IO.File]::WriteAllText((Join-Path $dir "${key}_screen.dart"), $screen)
}

# Rewrite string catalog (keep nav + app keys)
$stringsPath = Join-Path $dst 'lib\app\l10n\string_catalog.dart'
$strings = @"
/// Minimal in-memory string catalog for the $($cfg.Name) skeleton.
class StringCatalog {
  StringCatalog._(this._tables);

  factory StringCatalog.forTest(Map<String, Map<String, String>> tables) {
    return StringCatalog._(tables);
  }

  final Map<String, Map<String, String>> _tables;
  String locale = 'en';

  static StringCatalog seed() {
    return StringCatalog._({
      'en': _en,
      'tr': _tr,
    });
  }

  String t(String key, {Map<String, String> args = const {}}) {
    final table = _tables[locale] ?? _tables['en'] ?? const <String, String>{};
    final fallback = _tables['en'] ?? const <String, String>{};
    var value = table[key] ?? fallback[key] ?? key;
    for (final entry in args.entries) {
      value = value.replaceAll('{`${entry.key}}', entry.value);
    }
    return value;
  }

  void setLocale(String code) {
    if (_tables.containsKey(code)) {
      locale = code;
    }
  }
}

const Map<String, String> _en = {
  'app.title': '$($cfg.Name)',
  'app.offline_banner': "You're offline. Actions will sync when back online.",
  'nav.home': 'Home',
  'nav.tasks': 'Tasks',
  'nav.calendar': 'Calendar',
  'nav.documents': 'Documents',
  'nav.ai': 'AI',
  'nav.more': 'More',
$($enStrings -join "`n")
};

const Map<String, String> _tr = {
  'app.title': '$($cfg.Name)',
  'app.offline_banner': 'Çevrimdışısınız. İşlemler tekrar bağlanınca senkronize olacak.',
  'nav.home': 'Ana Sayfa',
  'nav.tasks': 'Görevler',
  'nav.calendar': 'Takvim',
  'nav.documents': 'Belgeler',
  'nav.ai': 'YZ',
  'nav.more': 'Daha Fazla',
$($trStrings -join "`n")
};
"@
[IO.File]::WriteAllText($stringsPath, $strings)

# Seed repository -- domain org + roles + one workflow from catalog if possible
$seedPath = Join-Path $dst "lib\data\repositories\seeded_${prefix}_repository.dart"
$seed = @"
import 'package:after_enterprise/after_enterprise.dart';

/// Builds a [MockEnterpriseRepository] preloaded with $($cfg.Name) demo data.
MockEnterpriseRepository buildSeeded${PrefixPascal}Repository() {
  final org = InMemoryOrganizationRepository(seed: const [
    Organization(
      id: '$($cfg.OrgId)',
      name: '$($cfg.OrgName)',
      slug: '$($cfg.OrgSlug)',
    ),
  ]);

  final rbac = InMemoryRbacRepository(seed: const [
    Role(
      id: 'role_admin',
      name: 'Administrator',
      permissions: {'*'},
      organizationId: '$($cfg.OrgId)',
      isSystem: true,
    ),
    Role(
      id: 'role_operator',
      name: 'Operator',
      permissions: {
        'tasks:read',
        'calendar:read',
        'documents:read',
      },
      organizationId: '$($cfg.OrgId)',
    ),
  ]);

  final workflows = InMemoryWorkflowRepository();
  final tasks = InMemoryTaskRepository(seed: [
    EnterpriseTask(
      id: 'task_shift_brief',
      organizationId: '$($cfg.OrgId)',
      title: 'Shift brief -- $($cfg.Name)',
      description: 'Review open work items for the current shift.',
      priority: TaskPriority.high,
      status: TaskStatus.inProgress,
      createdAt: DateTime.now().toUtc(),
    ),
  ]);

  return MockEnterpriseRepository(
    organizations: org,
    rbac: rbac,
    workflows: workflows,
    tasks: tasks,
  );
}
"@
[IO.File]::WriteAllText($seedPath, $seed)

# Fix dashboard imports / grid class names after replace
$dash = Join-Path $dst 'lib\features\dashboard\dashboard_screen.dart'
if (Test-Path $dash) {
  $dt = [IO.File]::ReadAllText($dash)
  $dt = $dt.Replace('_HospitalFeatureGrid', "_${PrefixPascal}FeatureGrid")
  $dt = $dt.Replace('_HospitalFeatureCard', "_${PrefixPascal}FeatureCard")
  # ensure icon import path
  $dt = $dt -replace "import '../../app/navigation/\w+_feature_icons.dart';", "import '../../app/navigation/${prefix}_feature_icons.dart';"
  $dt = $dt -replace "import '../../domain/entities/\w+_feature.dart';", "import '../../domain/entities/${prefix}_feature.dart';"
  [IO.File]::WriteAllText($dash, $dt)
}

# pubspec
$pubspec = @"
name: $($cfg.Package)
description: >
  $($cfg.Name) -- AfterArtificial enterprise Super App for
  $($cfg.Domain). Powered by After Framework. Built by Overstein Labs.
  Generated from SuperHospital by the AI Product Factory.
publish_to: "none"
version: 0.1.0+1

environment:
  sdk: ^3.12.2

dependencies:
  after_core:
    path: ../supercore/packages/after_core
  after_design_system:
    path: ../supercore/packages/after_design_system
  after_enterprise:
    path: ../supercore/packages/after_enterprise
  cupertino_icons: ^1.0.8
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  flutter_riverpod: ^3.3.2
  intl: ^0.20.2
  riverpod: any
  shared_preferences: ^2.5.5

dev_dependencies:
  very_good_analysis: ^10.3.0
  flutter_test:
    sdk: flutter

flutter:
  uses-material-design: true
  assets:
    - assets/dashboard/
    - assets/workflows/
    - assets/plugins/
"@
[IO.File]::WriteAllText((Join-Path $dst 'pubspec.yaml'), $pubspec)

# Assets from examples
foreach ($pair in @(
  @{ Src = $cfg.DashboardSrc; Dest = 'assets\dashboard\home.json' },
  @{ Src = $cfg.WorkflowSrc; Dest = 'assets\workflows\catalog.json' },
  @{ Src = $cfg.PluginSrc; Dest = 'assets\plugins\catalog.json' }
)) {
  $from = Join-Path $supercore $pair.Src
  $to = Join-Path $dst $pair.Dest
  New-Item -ItemType Directory -Force -Path (Split-Path $to -Parent) | Out-Null
  if (Test-Path $from) {
    Copy-Item -Force $from $to
    Write-Host "  [ASSET] $($pair.Dest)"
  }
}

# product.spec copy
$specFrom = Join-Path $supercore $cfg.SpecRel
$specTo = Join-Path $dst 'product.spec.yaml'
if (Test-Path $specFrom) {
  Copy-Item -Force $specFrom $specTo
  Write-Host "  [SPEC] product.spec.yaml"
}

# README
$readme = @"
# $($cfg.Name)

**Enterprise Super App** for $($cfg.Domain).

Generated from the **SuperHospital** reference by the AfterArtificial
AI Product Factory. Shares shell, auth, RBAC, workflow, tasks, calendar,
documents, AI tab, and More -- only the industry domain changes.

| Item | Value |
|------|-------|
| Package | ``$($cfg.Package)`` |
| Bundle | ``$($cfg.Bundle)`` |
| Product line | ``AfterProductLine.enterprise`` |
| Reference | SuperHospital |
| Monogram | $($cfg.Monogram) |

## Regenerate

``````powershell
cd ..\supercore
powershell -File scripts\generate_enterprise_from_hospital.ps1 -Vertical $Vertical
``````

Built by **Overstein Labs**. Powered by **After Framework**.
"@
[IO.File]::WriteAllText((Join-Path $dst 'README.md'), $readme)

# Fix test imports that may still reference hospital paths
$testRoot = Join-Path $dst 'test'
if (Test-Path $testRoot) {
  Replace-InTree -Root $testRoot -Map $map
}

# Hospital vertical: keep existing feature screens -- we deleted them only for siblings
if ($Vertical -eq 'Hospital') {
  Write-Host "  [NOTE] Hospital polish path -- re-copy feature dirs from backup skipped; Hospital source is self."
}

Write-Host ''
Write-Host 'Next: flutter create . ; flutter pub get ; flutter test'
if (-not $SkipFlutterCreate) {
  Push-Location $dst
  try {
    if (-not (Test-Path (Join-Path $dst 'android'))) {
      Write-Host '  Running flutter create .'
      flutter create . --project-name $($cfg.Package) --org com.overstein --platforms=android,ios
    }
    flutter pub get
    flutter test
  } finally {
    Pop-Location
  }
}

Write-Host "==> Done: $($cfg.Name)"
