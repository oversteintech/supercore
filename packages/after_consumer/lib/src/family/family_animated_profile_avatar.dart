import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'family_avatar_options.dart';

/// Lively profile avatar with orbiting gradient frame (Garage parity).
class FamilyAnimatedProfileAvatar extends StatefulWidget {
  const FamilyAnimatedProfileAvatar({
    required this.avatar,
    this.imageBytes,
    this.radius = 26,
    this.animate = true,
    this.showEditBadge = false,
    this.editBadgeColor,
    this.editBadgeIconColor,
    super.key,
  });

  final FamilyAvatarOption avatar;
  final Uint8List? imageBytes;
  final double radius;
  final bool animate;
  final bool showEditBadge;
  final Color? editBadgeColor;
  final Color? editBadgeIconColor;

  @override
  State<FamilyAnimatedProfileAvatar> createState() =>
      _FamilyAnimatedProfileAvatarState();
}

class _FamilyAnimatedProfileAvatarState
    extends State<FamilyAnimatedProfileAvatar> with TickerProviderStateMixin {
  late final AnimationController _orbit;
  late final AnimationController _pulse;
  late final AnimationController _float;

  bool get _hasPhoto =>
      widget.imageBytes != null && widget.imageBytes!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _orbit = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.avatar.orbitMs),
    );
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    );
    _float = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    // Tickers start in didChangeDependencies once TickerMode is available.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncTickers();
  }

  @override
  void didUpdateWidget(covariant FamilyAnimatedProfileAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.avatar.orbitMs != widget.avatar.orbitMs) {
      _orbit.duration = Duration(milliseconds: widget.avatar.orbitMs);
    }
    if (oldWidget.animate != widget.animate) {
      _syncTickers();
    } else if (oldWidget.avatar.orbitMs != widget.avatar.orbitMs &&
        _orbit.isAnimating) {
      _orbit.repeat();
    }
  }

  void _syncTickers() {
    final enabled = widget.animate && TickerMode.of(context);
    if (enabled) {
      if (!_orbit.isAnimating) _orbit.repeat();
      if (!_pulse.isAnimating) _pulse.repeat(reverse: true);
      if (!_float.isAnimating) _float.repeat(reverse: true);
    } else {
      _orbit.stop();
      _pulse.stop();
      _float.stop();
    }
  }

  @override
  void dispose() {
    _orbit.dispose();
    _pulse.dispose();
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.radius * 2;
    final borderPad = math.max(2, widget.radius * 0.08).toDouble();
    final iconSize = widget.radius * 0.92;
    final accent = widget.avatar.color;
    final gradient = widget.avatar.resolvedGradient;

    Widget core({
      required double pulse,
      required double floatY,
      required double iconTurn,
    }) {
      return SizedBox(
        width: size,
        height: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              colors: gradient,
              transform: GradientRotation(_orbit.value * 2 * math.pi),
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.22 + pulse * 0.32),
                blurRadius: 8 + pulse * 12,
                spreadRadius: 0.4 + pulse * 0.8,
              ),
              BoxShadow(
                color: gradient[1].withValues(alpha: 0.10 + pulse * 0.14),
                blurRadius: 18,
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(borderPad),
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent,
                gradient: _hasPhoto
                    ? null
                    : RadialGradient(
                        center: const Alignment(-0.35, -0.4),
                        radius: 1.05,
                        colors: [
                          Color.lerp(accent, Colors.white, 0.28)!,
                          accent,
                          Color.lerp(accent, Colors.black, 0.22)!,
                        ],
                        stops: const [0.0, 0.55, 1.0],
                      ),
                image: _hasPhoto
                    ? DecorationImage(
                        image: MemoryImage(widget.imageBytes!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _hasPhoto
                  ? const SizedBox.expand()
                  : Center(
                      child: Transform.translate(
                        offset: Offset(0, floatY),
                        child: Transform.rotate(
                          angle: iconTurn,
                          child: Icon(
                            widget.avatar.icon,
                            size: iconSize,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.28),
                                blurRadius: 6,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ),
      );
    }

    final avatar = !widget.animate
        ? core(pulse: 0.4, floatY: 0, iconTurn: 0)
        : AnimatedBuilder(
            animation: Listenable.merge([_orbit, _pulse, _float]),
            builder: (context, _) {
              final pulse = _pulse.value;
              final floatY = _hasPhoto
                  ? 0.0
                  : math.sin(_float.value * math.pi) * (widget.radius * 0.06);
              final iconTurn = _hasPhoto
                  ? 0.0
                  : math.sin(_orbit.value * math.pi * 2) * 0.08;
              return Transform.scale(
                scale: 1 + pulse * 0.035,
                child: core(
                  pulse: pulse,
                  floatY: floatY,
                  iconTurn: iconTurn,
                ),
              );
            },
          );

    if (!widget.showEditBadge) return avatar;

    final badgeBg =
        widget.editBadgeColor ?? Theme.of(context).colorScheme.primary;
    final badgeFg =
        widget.editBadgeIconColor ?? Theme.of(context).colorScheme.onPrimary;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        Positioned(
          right: -2,
          bottom: -2,
          child: Container(
            width: math.max(20, widget.radius * 0.72),
            height: math.max(20, widget.radius * 0.72),
            decoration: BoxDecoration(
              color: badgeBg,
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.surface,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: badgeBg.withValues(alpha: 0.35),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Icon(
              Icons.edit_rounded,
              size: math.max(10, widget.radius * 0.38),
              color: badgeFg,
            ),
          ),
        ),
      ],
    );
  }
}

/// Compact animated tile used in the avatar picker grid.
class FamilyAnimatedAvatarPickerTile extends StatefulWidget {
  const FamilyAnimatedAvatarPickerTile({
    required this.avatar,
    required this.selected,
    required this.onTap,
    this.enabled = true,
    super.key,
  });

  final FamilyAvatarOption avatar;
  final bool selected;
  final VoidCallback onTap;
  final bool enabled;

  @override
  State<FamilyAnimatedAvatarPickerTile> createState() =>
      _FamilyAnimatedAvatarPickerTileState();
}

class _FamilyAnimatedAvatarPickerTileState
    extends State<FamilyAnimatedAvatarPickerTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.avatar.orbitMs),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (TickerMode.of(context)) {
      if (!_controller.isAnimating) _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void didUpdateWidget(covariant FamilyAnimatedAvatarPickerTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.avatar.orbitMs != widget.avatar.orbitMs) {
      _controller.duration = Duration(milliseconds: widget.avatar.orbitMs);
      if (_controller.isAnimating) _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.avatar.color;

    return InkWell(
      onTap: widget.enabled ? widget.onTap : null,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final pulse = (math.sin(_controller.value * math.pi * 2) + 1) / 2;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 72,
            height: 72,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: SweepGradient(
                colors: widget.avatar.resolvedGradient,
                transform: GradientRotation(_controller.value * 2 * math.pi),
              ),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(
                    alpha: widget.selected
                        ? 0.28 + pulse * 0.28
                        : 0.10 + pulse * 0.12,
                  ),
                  blurRadius: widget.selected ? 12 + pulse * 8 : 6,
                  spreadRadius: widget.selected ? 0.8 : 0.2,
                ),
              ],
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: RadialGradient(
                  center: const Alignment(-0.3, -0.35),
                  radius: 1.1,
                  colors: [
                    Color.lerp(accent, Colors.white, 0.22)!,
                    accent,
                    Color.lerp(accent, Colors.black, 0.18)!,
                  ],
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Transform.translate(
                    offset: Offset(
                      0,
                      math.sin(_controller.value * math.pi * 2) * 1.6,
                    ),
                    child: Icon(
                      widget.avatar.icon,
                      color: Colors.white,
                      size: 30,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  if (widget.selected)
                    Positioned(
                      right: 5,
                      top: 5,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: accent.withValues(alpha: 0.4),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          size: 13,
                          color: accent,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
