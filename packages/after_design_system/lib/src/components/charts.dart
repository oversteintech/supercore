import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../foundations/colors.dart';
import '../foundations/radius.dart';
import '../foundations/spacing.dart';
import '../foundations/theme.dart';

/// Lightweight chart primitives — token-aligned, no heavy chart dependency.
/// Super Apps MAY wrap `fl_chart` using [AfterColors.chartSeries] for complex plots.

class AfterSparkline extends StatelessWidget {
  const AfterSparkline({
    required this.values,
    super.key,
    this.height = 48,
    this.color,
    this.strokeWidth = 2,
    this.fill = true,
  });

  final List<double> values;
  final double height;
  final Color? color;
  final double strokeWidth;
  final bool fill;

  @override
  Widget build(BuildContext context) {
    final colors = context.afterColors;
    final line = color ?? colors.accent;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _SparklinePainter(
          values: values,
          color: line,
          strokeWidth: strokeWidth,
          fill: fill,
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.values,
    required this.color,
    required this.strokeWidth,
    required this.fill,
  });

  final List<double> values;
  final Color color;
  final double strokeWidth;
  final bool fill;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final minV = values.reduce(math.min);
    final maxV = values.reduce(math.max);
    final range = (maxV - minV).abs() < 1e-9 ? 1.0 : maxV - minV;

    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = i / (values.length - 1) * size.width;
      final y = size.height - ((values[i] - minV) / range) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    if (fill) {
      final fillPath = Path.from(path)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      canvas.drawPath(
        fillPath,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withValues(alpha: 0.28),
              color.withValues(alpha: 0.0),
            ],
          ).createShader(Offset.zero & size),
      );
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.values != values ||
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.fill != fill;
}

/// Simple horizontal / vertical bar chart.
class AfterBarChart extends StatelessWidget {
  const AfterBarChart({
    required this.values,
    super.key,
    this.labels,
    this.height = 140,
    this.horizontal = false,
  });

  final List<double> values;
  final List<String>? labels;
  final double height;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final colors = context.afterColors;
    final type = context.afterTypography;
    final maxV = values.isEmpty ? 1.0 : values.reduce(math.max).clamp(1e-9, double.infinity);

    return SizedBox(
      height: height,
      child: horizontal
          ? Column(
              children: [
                for (var i = 0; i < values.length; i++) ...[
                  if (i > 0) const SizedBox(height: AfterSpacing.sm),
                  Row(
                    children: [
                      SizedBox(
                        width: 56,
                        child: Text(
                          labels != null && i < labels!.length ? labels![i] : '${i + 1}',
                          style: type.labelSmall.copyWith(color: colors.muted),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: AfterRadius.xsAll,
                          child: LinearProgressIndicator(
                            value: values[i] / maxV,
                            minHeight: 10,
                            backgroundColor: colors.surfaceMuted,
                            color: AfterColors.chartSeries[i % AfterColors.chartSeries.length],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < values.length; i++) ...[
                  if (i > 0) const SizedBox(width: AfterSpacing.sm),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: FractionallySizedBox(
                              heightFactor: (values[i] / maxV).clamp(0.02, 1),
                              widthFactor: 1,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: AfterColors
                                      .chartSeries[i % AfterColors.chartSeries.length],
                                  borderRadius: AfterRadius.xsAll,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (labels != null && i < labels!.length) ...[
                          const SizedBox(height: 4),
                          Text(
                            labels![i],
                            style: type.labelSmall.copyWith(color: colors.muted),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

/// Donut / progress ring for single KPI.
class AfterProgressRing extends StatelessWidget {
  const AfterProgressRing({
    required this.value,
    super.key,
    this.size = 72,
    this.strokeWidth = 6,
    this.color,
    this.child,
  });

  /// 0..1
  final double value;
  final double size;
  final double strokeWidth;
  final Color? color;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final colors = context.afterColors;
    final ring = color ?? colors.accent;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _RingPainter(
              value: value.clamp(0, 1),
              color: ring,
              track: colors.border,
              strokeWidth: strokeWidth,
            ),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.value,
    required this.color,
    required this.track,
    required this.strokeWidth,
  });

  final double value;
  final Color color;
  final Color track;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final valuePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * value,
      false,
      valuePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.value != value ||
      oldDelegate.color != color ||
      oldDelegate.track != track ||
      oldDelegate.strokeWidth != strokeWidth;
}
