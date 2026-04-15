import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// A widget that wraps [child] with subtle celestial doodles painted in the
/// background at very low opacity — purely decorative, zero interaction cost.
class CelestialBackground extends StatelessWidget {
  final Widget child;
  const CelestialBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(
          painter: _CelestialDoodlePainter(),
          child: const SizedBox.expand(),
        ),
        child,
      ],
    );
  }
}

class _CelestialDoodlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final primaryPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.09)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final accentPaint = Paint()
      ..color = const Color(0xFF8784B4).withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final dotPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.10)
      ..style = PaintingStyle.fill;

    final goldenPaint = Paint()
      ..color = const Color(0xFFE7AD5D).withValues(alpha: 0.09)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final w = size.width;
    final h = size.height;

    // ------------------------------------------------------------------
    // 1. Scattered tiny 6-point stars
    // ------------------------------------------------------------------
    final starPositions = [
      Offset(w * 0.08, h * 0.04),
      Offset(w * 0.85, h * 0.06),
      Offset(w * 0.92, h * 0.18),
      Offset(w * 0.05, h * 0.25),
      Offset(w * 0.55, h * 0.12),
      Offset(w * 0.72, h * 0.35),
      Offset(w * 0.15, h * 0.50),
      Offset(w * 0.88, h * 0.55),
      Offset(w * 0.40, h * 0.68),
      Offset(w * 0.10, h * 0.78),
      Offset(w * 0.65, h * 0.82),
      Offset(w * 0.30, h * 0.90),
      Offset(w * 0.80, h * 0.92),
      Offset(w * 0.50, h * 0.44),
      Offset(w * 0.95, h * 0.72),
    ];

    for (int i = 0; i < starPositions.length; i++) {
      final p = starPositions[i];
      final r = (i % 3 == 0) ? 7.0 : (i % 3 == 1) ? 5.0 : 9.0;
      _drawStar(canvas, p, r, i % 2 == 0 ? primaryPaint : goldenPaint);
    }

    // ------------------------------------------------------------------
    // 2. Crescent moons
    // ------------------------------------------------------------------
    _drawCrescent(canvas, Offset(w * 0.93, h * 0.10), 14, primaryPaint);
    _drawCrescent(canvas, Offset(w * 0.06, h * 0.62), 10, accentPaint);
    _drawCrescent(canvas, Offset(w * 0.78, h * 0.75), 12, primaryPaint);

    // ------------------------------------------------------------------
    // 3. Small sun bursts (circle with radiating lines)
    // ------------------------------------------------------------------
    _drawSunburst(canvas, Offset(w * 0.20, h * 0.08), 10, goldenPaint);
    _drawSunburst(canvas, Offset(w * 0.78, h * 0.20), 8, goldenPaint);
    _drawSunburst(canvas, Offset(w * 0.12, h * 0.88), 9, goldenPaint);
    _drawSunburst(canvas, Offset(w * 0.88, h * 0.88), 11, goldenPaint);

    // ------------------------------------------------------------------
    // 4. Orbital / dotted circles
    // ------------------------------------------------------------------
    _drawDashedCircle(canvas, Offset(w * 0.85, h * 0.30), 28, accentPaint);
    _drawDashedCircle(canvas, Offset(w * 0.18, h * 0.38), 22, primaryPaint);
    _drawDashedCircle(canvas, Offset(w * 0.60, h * 0.94), 26, accentPaint);

    // ------------------------------------------------------------------
    // 5. Tiny constellation-style dot clusters
    // ------------------------------------------------------------------
    final clusters = [
      [Offset(w * 0.30, h * 0.15), Offset(w * 0.34, h * 0.13), Offset(w * 0.37, h * 0.16)],
      [Offset(w * 0.60, h * 0.30), Offset(w * 0.63, h * 0.27), Offset(w * 0.66, h * 0.31), Offset(w * 0.64, h * 0.34)],
      [Offset(w * 0.20, h * 0.70), Offset(w * 0.23, h * 0.67), Offset(w * 0.26, h * 0.71)],
      [Offset(w * 0.70, h * 0.60), Offset(w * 0.74, h * 0.58), Offset(w * 0.77, h * 0.62), Offset(w * 0.73, h * 0.65)],
      [Offset(w * 0.45, h * 0.85), Offset(w * 0.48, h * 0.83), Offset(w * 0.50, h * 0.87)],
    ];

    for (final cluster in clusters) {
      _drawConstellation(canvas, cluster, dotPaint, primaryPaint);
    }

    // ------------------------------------------------------------------
    // 6. Diamond / rhombus ornaments (like the reference's corner diamonds)
    // ------------------------------------------------------------------
    _drawDiamond(canvas, Offset(w * 0.04, h * 0.04), 10, primaryPaint);
    _drawDiamond(canvas, Offset(w * 0.96, h * 0.04), 10, primaryPaint);
    _drawDiamond(canvas, Offset(w * 0.04, h * 0.96), 8, accentPaint);
    _drawDiamond(canvas, Offset(w * 0.96, h * 0.96), 8, accentPaint);

    // ------------------------------------------------------------------
    // 7. Cross / plus tick marks (celestial reference marks)
    // ------------------------------------------------------------------
    final tickPositions = [
      Offset(w * 0.45, h * 0.05),
      Offset(w * 0.50, h * 0.58),
      Offset(w * 0.35, h * 0.78),
      Offset(w * 0.82, h * 0.48),
    ];
    for (final p in tickPositions) {
      _drawCrossTick(canvas, p, 6, accentPaint);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    const points = 6;
    final innerRadius = radius * 0.45;
    for (int i = 0; i < points * 2; i++) {
      final angle = (math.pi / points) * i - math.pi / 2;
      final r = i.isEven ? radius : innerRadius;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawCrescent(Canvas canvas, Offset center, double radius, Paint paint) {
    final outerPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));
    final innerPath = Path()
      ..addOval(Rect.fromCircle(
          center: Offset(center.dx + radius * 0.45, center.dy),
          radius: radius * 0.78));
    final crescent = Path.combine(PathOperation.difference, outerPath, innerPath);
    canvas.drawPath(crescent, paint..style = PaintingStyle.fill);
    paint.style = PaintingStyle.stroke; // reset
  }

  void _drawSunburst(Canvas canvas, Offset center, double radius, Paint paint) {
    canvas.drawCircle(center, radius * 0.45, paint);
    const rays = 8;
    for (int i = 0; i < rays; i++) {
      final angle = (2 * math.pi / rays) * i;
      final inner = Offset(
        center.dx + (radius * 0.6) * math.cos(angle),
        center.dy + (radius * 0.6) * math.sin(angle),
      );
      final outer = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawLine(inner, outer, paint);
    }
  }

  void _drawDashedCircle(Canvas canvas, Offset center, double radius, Paint paint) {
    const dashes = 24;
    const gapFraction = 0.4;
    for (int i = 0; i < dashes; i++) {
      final startAngle = (2 * math.pi / dashes) * i;
      final sweepAngle = (2 * math.pi / dashes) * (1 - gapFraction);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  void _drawConstellation(Canvas canvas, List<Offset> points, Paint dotPaint, Paint linePaint) {
    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], linePaint);
    }
    for (final p in points) {
      canvas.drawCircle(p, 1.8, dotPaint);
    }
  }

  void _drawDiamond(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path()
      ..moveTo(center.dx, center.dy - size)
      ..lineTo(center.dx + size * 0.55, center.dy)
      ..lineTo(center.dx, center.dy + size)
      ..lineTo(center.dx - size * 0.55, center.dy)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawCrossTick(Canvas canvas, Offset center, double size, Paint paint) {
    canvas.drawLine(
      Offset(center.dx - size, center.dy),
      Offset(center.dx + size, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - size),
      Offset(center.dx, center.dy + size),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
