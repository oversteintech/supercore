import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Global look for every Super App product mark (except Garage, which keeps
/// its own assets). Change this once → all sibling icons restyle.
enum AfterProductIconStyle {
  /// Family interlocking gradient (red → purple → blue).
  classic,

  /// Bright metallic gold.
  premiumGold,

  /// Chrome silver.
  silver,

  /// Cool diamond / ice.
  diamond,

  /// Deep midnight navy.
  midnight,

  /// Emerald / health green.
  emerald,

  /// Warm coral / blossom.
  coral,

  /// Royal purple.
  royal,
}

extension AfterProductIconStyleAccess on AfterProductIconStyle {
  String get storageKey => name;

  String get label => switch (this) {
        AfterProductIconStyle.classic => 'Classic',
        AfterProductIconStyle.premiumGold => 'Gold',
        AfterProductIconStyle.silver => 'Silver',
        AfterProductIconStyle.diamond => 'Diamond',
        AfterProductIconStyle.midnight => 'Midnight',
        AfterProductIconStyle.emerald => 'Emerald',
        AfterProductIconStyle.coral => 'Coral',
        AfterProductIconStyle.royal => 'Royal',
      };

  static AfterProductIconStyle fromStorage(String? raw) {
    for (final v in AfterProductIconStyle.values) {
      if (v.name == raw) return v;
    }
    return AfterProductIconStyle.classic;
  }

  List<Color> get monogramGradient => switch (this) {
        AfterProductIconStyle.classic => const [
            Color(0xFFE11D48),
            Color(0xFF7C3AED),
            Color(0xFF2563EB),
          ],
        AfterProductIconStyle.premiumGold => const [
            Color(0xFFFFF1A8),
            Color(0xFFD4AF37),
            Color(0xFFB8860B),
          ],
        AfterProductIconStyle.silver => const [
            Color(0xFFFFFFFF),
            Color(0xFFC0C0C0),
            Color(0xFF6B7280),
          ],
        AfterProductIconStyle.diamond => const [
            Color(0xFFE0F2FE),
            Color(0xFF38BDF8),
            Color(0xFF0EA5E9),
          ],
        AfterProductIconStyle.midnight => const [
            Color(0xFF94A3B8),
            Color(0xFF334155),
            Color(0xFF0F172A),
          ],
        AfterProductIconStyle.emerald => const [
            Color(0xFF6EE7B7),
            Color(0xFF10B981),
            Color(0xFF047857),
          ],
        AfterProductIconStyle.coral => const [
            Color(0xFFFBCFE8),
            Color(0xFFEC4899),
            Color(0xFFBE185D),
          ],
        AfterProductIconStyle.royal => const [
            Color(0xFFE9D5FF),
            Color(0xFF8B5CF6),
            Color(0xFF4C1D95),
          ],
      };

  Color get tileBackground => switch (this) {
        AfterProductIconStyle.classic ||
        AfterProductIconStyle.midnight ||
        AfterProductIconStyle.royal ||
        AfterProductIconStyle.diamond =>
          const Color(0xFF0A0A0A),
        AfterProductIconStyle.premiumGold => const Color(0xFF1A1200),
        AfterProductIconStyle.silver => const Color(0xFF111827),
        AfterProductIconStyle.emerald => const Color(0xFF022C22),
        AfterProductIconStyle.coral => const Color(0xFF1F0A14),
      };
}

/// Canonical product identity for shared premium icons.
///
/// Garage is intentionally omitted — flagship keeps its own monogram assets.
enum AfterProductId {
  afterHub,
  health,
  finance,
  home,
  travel,
  pet,
  news,
  sports,
  games,
  family,
  documents,
  learning,
  hospital,
  airport,
  maritime,
  factory,
  logistics,
  construction,
  school,
  hotel,
  restaurant,
  retail,
  energy,
  municipality,
  farm,
  agriculture,
  police,
  fire,
  mining,
}

/// Spec for one Super App product mark.
@immutable
class AfterProductIconSpec {
  const AfterProductIconSpec({
    required this.id,
    required this.packageName,
    required this.displayName,
    required this.monogram,
    required this.glyph,
    required this.accent,
  });

  final AfterProductId id;
  final String packageName;
  final String displayName;

  /// 1–3 letter interlocking monogram (e.g. `S+`, `SF`, `AH`).
  final String monogram;

  /// Domain glyph shown under / beside the monogram.
  final IconData glyph;

  /// Product accent (login chrome / shell).
  final Color accent;
}

/// Single source of truth for sibling Super App icons.
abstract final class AfterProductIconCatalog {
  static const List<AfterProductIconSpec> all = [
    AfterProductIconSpec(
      id: AfterProductId.afterHub,
      packageName: 'after_hub',
      displayName: 'After Hub',
      monogram: 'AH',
      glyph: Icons.hub_rounded,
      accent: Color(0xFF6366F1),
    ),
    AfterProductIconSpec(
      id: AfterProductId.health,
      packageName: 'super_health',
      displayName: 'SuperHealth',
      monogram: 'S+',
      glyph: Icons.favorite_rounded,
      accent: Color(0xFF10B981),
    ),
    AfterProductIconSpec(
      id: AfterProductId.finance,
      packageName: 'super_finance',
      displayName: 'SuperFinance',
      monogram: 'SF',
      glyph: Icons.account_balance_wallet_rounded,
      accent: Color(0xFF0EA5E9),
    ),
    AfterProductIconSpec(
      id: AfterProductId.home,
      packageName: 'super_home',
      displayName: 'SuperHome',
      monogram: 'SH',
      glyph: Icons.home_rounded,
      accent: Color(0xFFF59E0B),
    ),
    AfterProductIconSpec(
      id: AfterProductId.travel,
      packageName: 'super_travel',
      displayName: 'SuperTravel',
      monogram: 'ST',
      glyph: Icons.flight_takeoff_rounded,
      accent: Color(0xFF06B6D4),
    ),
    AfterProductIconSpec(
      id: AfterProductId.pet,
      packageName: 'super_pet',
      displayName: 'SuperPet',
      monogram: 'SP',
      glyph: Icons.pets_rounded,
      accent: Color(0xFFD97706),
    ),
    AfterProductIconSpec(
      id: AfterProductId.news,
      packageName: 'super_news',
      displayName: 'SuperNews',
      monogram: 'SN',
      glyph: Icons.newspaper_rounded,
      accent: Color(0xFFEF4444),
    ),
    AfterProductIconSpec(
      id: AfterProductId.sports,
      packageName: 'super_sports',
      displayName: 'SuperSports',
      monogram: 'SS',
      glyph: Icons.sports_soccer_rounded,
      accent: Color(0xFF22C55E),
    ),
    AfterProductIconSpec(
      id: AfterProductId.games,
      packageName: 'super_games',
      displayName: 'SuperGames',
      monogram: 'SG',
      glyph: Icons.sports_esports_rounded,
      accent: Color(0xFFA855F7),
    ),
    AfterProductIconSpec(
      id: AfterProductId.family,
      packageName: 'super_family',
      displayName: 'SuperFamily',
      monogram: 'SF',
      glyph: Icons.family_restroom_rounded,
      accent: Color(0xFFEC4899),
    ),
    AfterProductIconSpec(
      id: AfterProductId.documents,
      packageName: 'super_documents',
      displayName: 'SuperDocuments',
      monogram: 'SD',
      glyph: Icons.description_rounded,
      accent: Color(0xFF64748B),
    ),
    AfterProductIconSpec(
      id: AfterProductId.learning,
      packageName: 'super_learning',
      displayName: 'SuperLearning',
      monogram: 'SL',
      glyph: Icons.school_rounded,
      accent: Color(0xFF3B82F6),
    ),
    AfterProductIconSpec(
      id: AfterProductId.hospital,
      packageName: 'super_hospital',
      displayName: 'SuperHospital',
      monogram: 'SH',
      glyph: Icons.local_hospital_rounded,
      accent: Color(0xFFDC2626),
    ),
    AfterProductIconSpec(
      id: AfterProductId.airport,
      packageName: 'super_airport',
      displayName: 'SuperAirport',
      monogram: 'SA',
      glyph: Icons.connecting_airports_rounded,
      accent: Color(0xFF0284C7),
    ),
    AfterProductIconSpec(
      id: AfterProductId.maritime,
      packageName: 'super_maritime',
      displayName: 'SuperMaritime',
      monogram: 'SM',
      glyph: Icons.sailing_rounded,
      accent: Color(0xFF0E7490),
    ),
    AfterProductIconSpec(
      id: AfterProductId.factory,
      packageName: 'super_factory',
      displayName: 'SuperFactory',
      monogram: 'SF',
      glyph: Icons.precision_manufacturing_rounded,
      accent: Color(0xFF78716C),
    ),
    AfterProductIconSpec(
      id: AfterProductId.logistics,
      packageName: 'super_logistics',
      displayName: 'SuperLogistics',
      monogram: 'SL',
      glyph: Icons.local_shipping_rounded,
      accent: Color(0xFFEA580C),
    ),
    AfterProductIconSpec(
      id: AfterProductId.construction,
      packageName: 'super_construction',
      displayName: 'SuperConstruction',
      monogram: 'SC',
      glyph: Icons.construction_rounded,
      accent: Color(0xFFF97316),
    ),
    AfterProductIconSpec(
      id: AfterProductId.school,
      packageName: 'super_school',
      displayName: 'SuperSchool',
      monogram: 'SS',
      glyph: Icons.account_balance_rounded,
      accent: Color(0xFF2563EB),
    ),
    AfterProductIconSpec(
      id: AfterProductId.hotel,
      packageName: 'super_hotel',
      displayName: 'SuperHotel',
      monogram: 'SH',
      glyph: Icons.hotel_rounded,
      accent: Color(0xFF7C3AED),
    ),
    AfterProductIconSpec(
      id: AfterProductId.restaurant,
      packageName: 'super_restaurant',
      displayName: 'SuperRestaurant',
      monogram: 'SR',
      glyph: Icons.restaurant_rounded,
      accent: Color(0xFFE11D48),
    ),
    AfterProductIconSpec(
      id: AfterProductId.retail,
      packageName: 'super_retail',
      displayName: 'SuperRetail',
      monogram: 'SR',
      glyph: Icons.storefront_rounded,
      accent: Color(0xFFDB2777),
    ),
    AfterProductIconSpec(
      id: AfterProductId.energy,
      packageName: 'super_energy',
      displayName: 'SuperEnergy',
      monogram: 'SE',
      glyph: Icons.bolt_rounded,
      accent: Color(0xFFEAB308),
    ),
    AfterProductIconSpec(
      id: AfterProductId.municipality,
      packageName: 'super_municipality',
      displayName: 'SuperMunicipality',
      monogram: 'SM',
      glyph: Icons.location_city_rounded,
      accent: Color(0xFF475569),
    ),
    AfterProductIconSpec(
      id: AfterProductId.farm,
      packageName: 'super_farm',
      displayName: 'SuperFarm',
      monogram: 'SF',
      glyph: Icons.agriculture_rounded,
      accent: Color(0xFF65A30D),
    ),
    AfterProductIconSpec(
      id: AfterProductId.agriculture,
      packageName: 'super_agriculture',
      displayName: 'SuperAgriculture',
      monogram: 'SA',
      glyph: Icons.eco_rounded,
      accent: Color(0xFF16A34A),
    ),
    AfterProductIconSpec(
      id: AfterProductId.police,
      packageName: 'super_police',
      displayName: 'SuperPolice',
      monogram: 'SP',
      glyph: Icons.local_police_rounded,
      accent: Color(0xFF1D4ED8),
    ),
    AfterProductIconSpec(
      id: AfterProductId.fire,
      packageName: 'super_fire',
      displayName: 'SuperFire',
      monogram: 'SF',
      glyph: Icons.local_fire_department_rounded,
      accent: Color(0xFFDC2626),
    ),
    AfterProductIconSpec(
      id: AfterProductId.mining,
      packageName: 'super_mining',
      displayName: 'SuperMining',
      monogram: 'SM',
      glyph: Icons.landscape_rounded,
      accent: Color(0xFF92400E),
    ),
  ];

  static AfterProductIconSpec? byPackage(String packageName) {
    final key = packageName.trim().toLowerCase();
    for (final s in all) {
      if (s.packageName == key) return s;
    }
    return null;
  }

  static AfterProductIconSpec? byAppName(String appName) {
    final normalized = appName.trim().toLowerCase().replaceAll(' ', '');
    for (final s in all) {
      if (s.displayName.toLowerCase().replaceAll(' ', '') == normalized) {
        return s;
      }
      if (normalized.contains(s.id.name)) return s;
    }
    // Fuzzy: SuperHealth → health
    for (final s in all) {
      final short = s.displayName
          .toLowerCase()
          .replaceFirst('super', '')
          .replaceAll(' ', '');
      if (normalized.endsWith(short) && short.isNotEmpty) return s;
    }
    if (normalized.contains('hub') || normalized == 'afterhub') {
      return byId(AfterProductId.afterHub);
    }
    return null;
  }

  static AfterProductIconSpec? byId(AfterProductId id) {
    for (final s in all) {
      if (s.id == id) return s;
    }
    return null;
  }
}

/// Premium product mark — monogram + domain glyph, styled from the hub.
class AfterProductIconMark extends StatelessWidget {
  const AfterProductIconMark({
    required this.spec,
    this.style = AfterProductIconStyle.classic,
    this.size = 96,
    this.showGlyph = true,
    this.showLabel = false,
    super.key,
  });

  final AfterProductIconSpec spec;
  final AfterProductIconStyle style;
  final double size;
  final bool showGlyph;
  final bool showLabel;

  /// Resolve from Family chrome app name (Garage returns null — keep local).
  factory AfterProductIconMark.forAppName(
    String appName, {
    AfterProductIconStyle style = AfterProductIconStyle.classic,
    double size = 96,
    Key? key,
  }) {
    final spec = AfterProductIconCatalog.byAppName(appName);
    if (spec == null) {
      return AfterProductIconMark(
        key: key,
        spec: const AfterProductIconSpec(
          id: AfterProductId.afterHub,
          packageName: 'after_hub',
          displayName: 'After',
          monogram: 'A',
          glyph: Icons.apps_rounded,
          accent: Color(0xFF6366F1),
        ),
        style: style,
        size: size,
      );
    }
    return AfterProductIconMark(
      key: key,
      spec: spec,
      style: style,
      size: size,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _AfterProductIconPainter(
              monogram: spec.monogram,
              glyph: showGlyph ? spec.glyph : null,
              style: style,
              accent: spec.accent,
            ),
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: 8),
          Text(
            spec.displayName,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ],
    );
  }
}

class _AfterProductIconPainter extends CustomPainter {
  _AfterProductIconPainter({
    required this.monogram,
    required this.style,
    required this.accent,
    this.glyph,
  });

  final String monogram;
  final IconData? glyph;
  final AfterProductIconStyle style;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(size.width * 0.22),
    );
    final bg = Paint()..color = style.tileBackground;
    canvas.drawRRect(r, bg);

    // Soft accent glow ring.
    final glow = Paint()
      ..shader = ui.Gradient.radial(
        size.center(Offset.zero),
        size.width * 0.55,
        [
          accent.withValues(alpha: 0.35),
          accent.withValues(alpha: 0.0),
        ],
      );
    canvas.drawRRect(r, glow);

    final colors = style.monogramGradient;
    final stops = List<double>.generate(
      colors.length,
      (i) => colors.length == 1 ? 0.0 : i / (colors.length - 1),
    );
    final gradient = Paint()
      ..shader = ui.Gradient.linear(
        Offset(size.width * 0.15, size.height * 0.2),
        Offset(size.width * 0.9, size.height * 0.9),
        colors,
        stops,
      );

    final text = TextPainter(
      text: TextSpan(
        text: monogram,
        style: TextStyle(
          fontSize: size.width * (monogram.length > 2 ? 0.34 : 0.42),
          fontWeight: FontWeight.w900,
          letterSpacing: monogram.length > 2 ? -1.5 : -0.5,
          foreground: gradient,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width * 0.9);

    final textOffset = Offset(
      (size.width - text.width) / 2,
      size.height * (glyph == null ? 0.28 : 0.18),
    );
    text.paint(canvas, textOffset);

    if (glyph != null) {
      final iconPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(glyph!.codePoint),
          style: TextStyle(
            fontSize: size.width * 0.2,
            fontFamily: glyph!.fontFamily,
            package: glyph!.fontPackage,
            color: accent.withValues(alpha: 0.95),
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      iconPainter.paint(
        canvas,
        Offset(
          (size.width - iconPainter.width) / 2,
          size.height * 0.68,
        ),
      );
    }

    // Premium shine sweep.
    final shine = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, size.height * 0.1),
        Offset(size.width, size.height * 0.35),
        [
          Colors.white.withValues(alpha: 0.18),
          Colors.white.withValues(alpha: 0.0),
        ],
        [0.0, 0.55],
      );
    canvas.save();
    canvas.clipRRect(r);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.45),
      shine,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _AfterProductIconPainter oldDelegate) {
    return oldDelegate.monogram != monogram ||
        oldDelegate.style != style ||
        oldDelegate.accent != accent ||
        oldDelegate.glyph != glyph;
  }
}

