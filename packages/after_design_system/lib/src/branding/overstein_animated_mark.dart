import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Vector OVERSTEIN OS mark with the overstein.com motion: ring segments draw
/// in, letters rise, then the ring spins without pause behind a breathing halo.
///
/// Geometry matches `OversteinMark.tsx` on overstein.com (120-unit box, ring
/// radius 54 so it clears the letters at every rotation angle).
class OversteinAnimatedMark extends StatefulWidget {
  const OversteinAnimatedMark({super.key, this.size = 150});

  /// Ring draw + letter rise window; spin and halo keep running afterwards.
  static const entranceDuration = Duration(milliseconds: 1500);

  final double size;

  @override
  State<OversteinAnimatedMark> createState() => _OversteinAnimatedMarkState();
}

class _OversteinAnimatedMarkState extends State<OversteinAnimatedMark>
    with TickerProviderStateMixin {
  static const _turn = Duration(seconds: 6);
  static const _breath = Duration(milliseconds: 3600);

  late final AnimationController _entrance;
  late final AnimationController _spin;
  late final AnimationController _halo;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: OversteinAnimatedMark.entranceDuration,
    )..forward();
    _spin = AnimationController(vsync: this, duration: _turn)..repeat();
    _halo = AnimationController(vsync: this, duration: _breath)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _entrance.dispose();
    _spin.dispose();
    _halo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.square(widget.size),
        painter: _MarkPainter(
          entrance: _entrance,
          spin: _spin,
          halo: _halo,
        ),
      ),
    );
  }
}

class _MarkPainter extends CustomPainter {
  _MarkPainter({
    required this.entrance,
    required this.spin,
    required this.halo,
  }) : super(repaint: Listenable.merge([entrance, spin, halo]));

  final Animation<double> entrance;
  final Animation<double> spin;
  final Animation<double> halo;

  static const _box = 120.0;
  static const _center = Offset(60, 60);
  static const _ringRadius = 54.0;
  static const _ringStroke = 4.0;
  static const _arcSweep = 46 * math.pi / 180;
  static const _arcStarts = [-140.0, -86.0, 40.0, 94.0];
  static const _ease = Cubic(0.16, 1, 0.3, 1);

  static final _entranceSeconds =
      OversteinAnimatedMark.entranceDuration.inMilliseconds / 1000;
  static const _arcDraw = 1.2;
  static const _arcStagger = 0.08;

  static final Path _letters = _buildLetters();

  static Path _buildLetters() {
    Path polygon(List<Offset> points) => Path()..addPolygon(points, true);
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(
        polygon(const [
          Offset(23.45, 39.6),
          Offset(52.35, 39.6),
          Offset(58.3, 45.55),
          Offset(58.3, 74.45),
          Offset(52.35, 80.4),
          Offset(23.45, 80.4),
          Offset(17.5, 74.45),
          Offset(17.5, 45.55),
        ]),
        Offset.zero,
      )
      ..addPath(
        polygon(const [
          Offset(26, 48.1),
          Offset(26, 71.9),
          Offset(49.8, 71.9),
          Offset(49.8, 48.1),
        ]),
        Offset.zero,
      )
      ..addPath(
        polygon(const [
          Offset(67.65, 39.6),
          Offset(102.5, 39.6),
          Offset(97.4, 48.1),
          Offset(70.2, 48.1),
          Offset(70.2, 55.75),
          Offset(96.55, 55.75),
          Offset(102.5, 61.7),
          Offset(102.5, 74.45),
          Offset(96.55, 80.4),
          Offset(61.7, 80.4),
          Offset(66.8, 71.9),
          Offset(94, 71.9),
          Offset(94, 64.25),
          Offset(67.65, 64.25),
          Offset(61.7, 58.3),
          Offset(61.7, 45.55),
        ]),
        Offset.zero,
      );
  }

  double _interval(double startSeconds, double endSeconds) {
    final t = entrance.value * _entranceSeconds;
    final raw = ((t - startSeconds) / (endSeconds - startSeconds)).clamp(0.0, 1.0);
    return _ease.transform(raw);
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / _box, size.height / _box);

    final breath = Curves.easeInOut.transform(halo.value);
    final haloScale = 0.92 + 0.14 * breath;
    final haloOpacity = 0.55 + 0.45 * breath;
    canvas.drawCircle(
      _center,
      58 * haloScale,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF2A7DB3).withValues(alpha: 0.32 * haloOpacity),
            const Color(0x002A7DB3),
          ],
        ).createShader(Rect.fromCircle(center: _center, radius: 58 * haloScale)),
    );

    final steel = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFF4F6F9), Color(0xFFA3ACB9), Color(0xFFE2E6EB)],
    ).createShader(const Rect.fromLTWH(0, 0, _box, _box));

    canvas.save();
    canvas.translate(_center.dx, _center.dy);
    canvas.rotate(spin.value * 2 * math.pi);
    canvas.translate(-_center.dx, -_center.dy);
    final ringPaint = Paint()
      ..shader = steel
      ..style = PaintingStyle.stroke
      ..strokeWidth = _ringStroke;
    final ringRect = Rect.fromCircle(center: _center, radius: _ringRadius);
    for (var i = 0; i < _arcStarts.length; i++) {
      final start = _arcStagger * i;
      final drawn = _interval(start, start + _arcDraw);
      if (drawn <= 0) continue;
      canvas.drawArc(
        ringRect,
        _arcStarts[i] * math.pi / 180,
        _arcSweep * drawn,
        false,
        ringPaint,
      );
    }
    canvas.restore();

    final rise = _interval(0.3, 1.2);
    if (rise > 0) {
      final scale = 0.94 + 0.06 * rise;
      canvas.save();
      canvas.translate(_center.dx, _center.dy + 6 * (1 - rise));
      canvas.scale(scale);
      canvas.translate(-_center.dx, -_center.dy);
      canvas.drawPath(
        _letters,
        Paint()
          ..shader = steel
          ..color = Color.fromRGBO(255, 255, 255, rise),
      );
      canvas.restore();
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_MarkPainter oldDelegate) =>
      oldDelegate.entrance != entrance ||
      oldDelegate.spin != spin ||
      oldDelegate.halo != halo;
}
