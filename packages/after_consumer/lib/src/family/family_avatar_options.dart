import 'package:flutter/material.dart';

/// Preset avatar option — Garage-parity animated identity chip.
class FamilyAvatarOption {
  const FamilyAvatarOption(
    this.id,
    this.icon,
    this.color, {
    this.gradientColors,
    this.orbitMs = 2800,
  });

  final String id;
  final IconData icon;
  final Color color;

  /// Rotating frame palette — falls back to [color]-derived tones.
  final List<Color>? gradientColors;

  /// Orbit speed for this avatar's animated frame.
  final int orbitMs;

  List<Color> get resolvedGradient {
    if (gradientColors != null && gradientColors!.length >= 3) {
      return gradientColors!;
    }
    return [
      color,
      Color.lerp(color, Colors.white, 0.55)!,
      Colors.white,
      Color.lerp(color, Colors.black, 0.15)!,
      color,
    ];
  }
}

/// Shared Super App avatar set (same UX as SuperGarage).
const familyAvatarOptions = <FamilyAvatarOption>[
  FamilyAvatarOption(
    'avatar_1',
    Icons.person_rounded,
    Color(0xFF0284C7),
    gradientColors: [
      Color(0xFF0369A1),
      Color(0xFF38BDF8),
      Colors.white,
      Color(0xFF7DD3FC),
      Color(0xFF0EA5E9),
      Color(0xFF0369A1),
    ],
    orbitMs: 2600,
  ),
  FamilyAvatarOption(
    'avatar_2',
    Icons.face_rounded,
    Color(0xFF7C3AED),
    gradientColors: [
      Color(0xFF5B21B6),
      Color(0xFFA78BFA),
      Colors.white,
      Color(0xFFC4B5FD),
      Color(0xFF8B5CF6),
      Color(0xFF5B21B6),
    ],
    orbitMs: 2400,
  ),
  FamilyAvatarOption(
    'avatar_3',
    Icons.emoji_emotions_rounded,
    Color(0xFFE10600),
    gradientColors: [
      Color(0xFFB91C1C),
      Color(0xFFF87171),
      Colors.white,
      Color(0xFFFBBF24),
      Color(0xFFEF4444),
      Color(0xFFB91C1C),
    ],
    orbitMs: 2000,
  ),
  FamilyAvatarOption(
    'avatar_4',
    Icons.auto_awesome_rounded,
    Color(0xFF0F766E),
    gradientColors: [
      Color(0xFF115E59),
      Color(0xFF2DD4BF),
      Colors.white,
      Color(0xFF5EEAD4),
      Color(0xFF14B8A6),
      Color(0xFF115E59),
    ],
    orbitMs: 3000,
  ),
  FamilyAvatarOption(
    'avatar_5',
    Icons.bolt_rounded,
    Color(0xFF059669),
    gradientColors: [
      Color(0xFF047857),
      Color(0xFF34D399),
      Colors.white,
      Color(0xFF6EE7B7),
      Color(0xFF10B981),
      Color(0xFF047857),
    ],
    orbitMs: 2200,
  ),
  FamilyAvatarOption(
    'avatar_6',
    Icons.favorite_rounded,
    Color(0xFFEA580C),
    gradientColors: [
      Color(0xFFC2410C),
      Color(0xFFFB923C),
      Colors.white,
      Color(0xFFFDBA74),
      Color(0xFFF97316),
      Color(0xFFC2410C),
    ],
    orbitMs: 1800,
  ),
  FamilyAvatarOption(
    'avatar_7',
    Icons.star_rounded,
    Color(0xFF475569),
    gradientColors: [
      Color(0xFF334155),
      Color(0xFF94A3B8),
      Colors.white,
      Color(0xFFCBD5E1),
      Color(0xFF64748B),
      Color(0xFF334155),
    ],
    orbitMs: 2700,
  ),
  FamilyAvatarOption(
    'avatar_8',
    Icons.workspace_premium_rounded,
    Color(0xFFD97706),
    gradientColors: [
      Color(0xFFB45309),
      Color(0xFFFBBF24),
      Colors.white,
      Color(0xFFFDE68A),
      Color(0xFFF59E0B),
      Color(0xFFB45309),
    ],
    orbitMs: 3200,
  ),
];

FamilyAvatarOption familyAvatarForId(
  String id, {
  List<FamilyAvatarOption>? options,
}) {
  final list = options ?? familyAvatarOptions;
  return list.firstWhere(
    (avatar) => avatar.id == id,
    orElse: () => list.first,
  );
}
