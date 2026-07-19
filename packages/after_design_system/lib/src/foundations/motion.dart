import 'package:flutter/widgets.dart';

/// Motion tokens — presence and hierarchy, not noise.
abstract final class AfterMotion {
  // Durations
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration normal = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 420);
  static const Duration emphasis = Duration(milliseconds: 560);

  // Curves — Apple-like ease, Linear-like snap
  static const Curve standard = Curves.easeInOutCubic;
  static const Curve entrance = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
  static const Curve emphasized = Curves.easeOutBack;
  static const Curve linear = Curves.linear;

  /// Page / tab cross-fade.
  static const Duration pageTransition = normal;

  /// Bottom sheet / dialog.
  static const Duration modalTransition = slow;

  /// Micro-interactions (press, toggle).
  static const Duration micro = fast;

  /// Skeleton shimmer period.
  static const Duration shimmer = Duration(milliseconds: 1400);

  /// Stagger delay between list items.
  static const Duration stagger = Duration(milliseconds: 40);
}

/// Standard fade+slide entrance for list / card content.
class AfterFadeSlide extends StatelessWidget {
  const AfterFadeSlide({
    required this.child,
    this.duration = AfterMotion.normal,
    this.curve = AfterMotion.entrance,
    this.offset = const Offset(0, 0.04),
    this.delay = Duration.zero,
    super.key,
  });

  final Widget child;
  final Duration duration;
  final Curve curve;
  final Offset offset;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final total = duration + delay;
    final start = total.inMilliseconds == 0
        ? 0.0
        : delay.inMilliseconds / total.inMilliseconds;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: total,
      curve: Interval(start, 1, curve: curve),
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(
              offset.dx * 24 * (1 - value),
              offset.dy * 24 * (1 - value),
            ),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
