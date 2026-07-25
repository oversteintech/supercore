import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Compact refresh control that spins while [onPressed] runs.
///
/// Used beside Live / list titles across Super Apps (Garage-parity).
class AfterAnimatedRefreshIconButton extends StatefulWidget {
  const AfterAnimatedRefreshIconButton({
    required this.onPressed,
    this.tooltip,
    this.iconSize = 22,
    super.key,
  });

  final Future<void> Function() onPressed;
  final String? tooltip;
  final double iconSize;

  @override
  State<AfterAnimatedRefreshIconButton> createState() =>
      _AfterAnimatedRefreshIconButtonState();
}

class _AfterAnimatedRefreshIconButtonState
    extends State<AfterAnimatedRefreshIconButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  var _busy = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handlePress() async {
    if (_busy) return;
    setState(() => _busy = true);
    _controller.repeat();
    try {
      await widget.onPressed();
    } finally {
      if (mounted) {
        _controller
          ..stop()
          ..reset();
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: widget.tooltip,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      onPressed: _busy ? null : () => unawaited(_handlePress()),
      icon: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _controller.value * 2 * math.pi,
            child: child,
          );
        },
        child: Icon(Icons.refresh_rounded, size: widget.iconSize),
      ),
    );
  }
}
