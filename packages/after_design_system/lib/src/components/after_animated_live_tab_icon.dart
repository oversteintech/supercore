import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Live tab mark — sensors icon + always-on pulsing red “on-air” status.
///
/// Shared across every Super App bottom nav so Live reads as truly live
/// even when the tab is unselected.
class AfterAnimatedLiveTabIcon extends StatefulWidget {
  const AfterAnimatedLiveTabIcon({
    required this.selected,
    this.size = 24,
    super.key,
  });

  final bool selected;
  final double size;

  static const liveRed = Color(0xFFE53935);

  @override
  State<AfterAnimatedLiveTabIcon> createState() =>
      _AfterAnimatedLiveTabIconState();
}

class _AfterAnimatedLiveTabIconState extends State<AfterAnimatedLiveTabIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncTicker();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _syncTicker() {
    final enabled = TickerMode.of(context);
    if (enabled) {
      if (!_controller.isAnimating) _controller.repeat();
    } else if (_controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final iconTheme = IconTheme.of(context);
    final baseColor = iconTheme.color ?? scheme.onSurfaceVariant;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final breath = 0.96 + 0.04 * math.sin(t * math.pi * 2);
        final sweep = (math.sin(t * math.pi * 2) + 1) / 2;
        final blink = 0.55 + 0.45 * ((math.sin(t * math.pi * 4) + 1) / 2);
        final rippleA = t % 1.0;
        final rippleB = (t + 0.5) % 1.0;

        return SizedBox(
          width: widget.size + 4,
          height: widget.size + 4,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: breath,
                child: Icon(
                  widget.selected
                      ? Icons.sensors_rounded
                      : Icons.sensors_outlined,
                  size: widget.size,
                  color: Color.lerp(
                    baseColor,
                    AfterAnimatedLiveTabIcon.liveRed,
                    widget.selected ? 0.18 + sweep * 0.22 : sweep * 0.12,
                  ),
                ),
              ),
              Positioned(
                top: -2,
                right: -3,
                child: SizedBox(
                  width: 14,
                  height: 14,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      _AfterLiveRipple(
                        progress: rippleA,
                        color: AfterAnimatedLiveTabIcon.liveRed,
                      ),
                      _AfterLiveRipple(
                        progress: rippleB,
                        color: AfterAnimatedLiveTabIcon.liveRed,
                      ),
                      Opacity(
                        opacity: blink,
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: AfterAnimatedLiveTabIcon.liveRed,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: scheme.surface,
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AfterAnimatedLiveTabIcon.liveRed
                                    .withValues(alpha: 0.35 + blink * 0.35),
                                blurRadius: 3 + blink * 2,
                                spreadRadius: blink * 0.6,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AfterLiveRipple extends StatelessWidget {
  const _AfterLiveRipple({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final size = 6.0 + progress * 10.0;
    final opacity = (1.0 - progress).clamp(0.0, 1.0) * 0.55;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withValues(alpha: opacity),
          width: 1.2,
        ),
      ),
    );
  }
}
