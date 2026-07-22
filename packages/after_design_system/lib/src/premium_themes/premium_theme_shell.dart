import 'package:flutter/material.dart';

/// Shared app shell for every premium / animated theme.
///
/// Rules (all themes must follow):
/// - [child] is the app content — never wrapped in [AnimatedBuilder] or [Theme].
/// - Animated layers live only in [background] / [foregroundOverlays], isolated
///   behind [RepaintBoundary] + [IgnorePointer] so they never trigger full-tree
///   rebuilds or block touches.
/// - Stack slots are fixed (bg / overlays / content) so [child] (the Navigator)
///   never changes index when overlay count changes — that path asserts
///   `_elements.contains(element)` during route push/pop.
class PremiumThemeAppShell extends StatelessWidget {
  const PremiumThemeAppShell({
    required this.backgroundColor,
    required this.background,
    required this.child,
    this.foregroundOverlays = const [],
    super.key,
  });

  final Color backgroundColor;
  final Widget background;
  final List<Widget> foregroundOverlays;
  final Widget child;

  static const _bgKey = ValueKey<String>('premium-theme-bg');
  static const _fgKey = ValueKey<String>('premium-theme-fg');
  static const _contentKey = ValueKey<String>('premium-theme-content');

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: backgroundColor),
        Positioned.fill(
          key: _bgKey,
          child: RepaintBoundary(
            child: IgnorePointer(child: background),
          ),
        ),
        Positioned.fill(
          key: _fgKey,
          child: RepaintBoundary(
            child: IgnorePointer(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  for (final overlay in foregroundOverlays)
                    Positioned.fill(child: overlay),
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          key: _contentKey,
          child: child,
        ),
      ],
    );
  }
}
