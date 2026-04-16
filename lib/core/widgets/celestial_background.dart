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
      ..color = AppColors.primary.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final accentPaint = Paint()
      ..color = const Color(0xFF8784B4).withValues(alpha: 0.09)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final dotPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.11)
      ..style = PaintingStyle.fill;

    final goldenPaint = Paint()
      ..color = const Color(0xFFE7AD5D).withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final rosePaint = Paint()
      ..color = const Color(0xFFDEA080).withValues(alpha: 0.09)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final w = size.width;
    final h = size.height;

    // We divide the page into a 6-column × 12-row virtual grid.
    // Each cell is ~(w/6) × (h/12). Elements are placed at deterministic
    // offsets within each cell so coverage is even top-to-bottom, left-to-right.

    // ── Helper: cell centre with small nudge ──────────────────────────────────
    Offset cell(int col, int row, {double dx = 0.5, double dy = 0.5}) {
      return Offset(
        w * (col + dx) / 6.0,
        h * (row + dy) / 12.0,
      );
    }

    // ── 1. Stars ─────────────────────────────────────────────────────────────
    // 30 stars: 5 per row across 6 vertical bands (rows 0-11 every 2.4 rows)
    const starCells = [
      [0, 0], [1, 1], [2, 0], [3, 1], [4, 0], [5, 1],  // row-band 0-1
      [0, 2], [1, 3], [2, 2], [3, 3], [4, 2], [5, 3],  // row-band 2-3
      [0, 4], [1, 5], [2, 4], [3, 5], [4, 4], [5, 5],  // row-band 4-5
      [0, 6], [1, 7], [2, 6], [3, 7], [4, 6], [5, 7],  // row-band 6-7
      [0, 8], [1, 9], [2, 8], [3, 9], [4, 8], [5, 9],  // row-band 8-9
      [0,10], [1,11], [2,10], [3,11], [4,10], [5,11],  // row-band 10-11
    ];

    const starDx = [0.2, 0.8, 0.5, 0.15, 0.85, 0.4,
                    0.7, 0.3, 0.9, 0.1, 0.6, 0.25,
                    0.45, 0.75, 0.15, 0.8, 0.35, 0.65,
                    0.1, 0.55, 0.9, 0.2, 0.7, 0.4,
                    0.85, 0.3, 0.6, 0.05, 0.75, 0.5,
                    0.3, 0.7, 0.2, 0.8, 0.45, 0.6];

    const starDy = [0.3, 0.7, 0.5, 0.2, 0.8, 0.4,
                    0.6, 0.3, 0.7, 0.5, 0.2, 0.8,
                    0.4, 0.7, 0.3, 0.6, 0.8, 0.2,
                    0.5, 0.3, 0.7, 0.8, 0.2, 0.6,
                    0.3, 0.7, 0.4, 0.6, 0.2, 0.8,
                    0.6, 0.2, 0.8, 0.4, 0.7, 0.3];

    const starSizes = [7.0, 5.0, 9.0, 6.0, 8.0, 5.0,
                       7.0, 6.0, 8.0, 5.0, 9.0, 6.0,
                       5.0, 8.0, 7.0, 6.0, 9.0, 5.0,
                       8.0, 6.0, 5.0, 7.0, 9.0, 6.0,
                       5.0, 8.0, 6.0, 9.0, 7.0, 5.0,
                       6.0, 8.0, 5.0, 9.0, 7.0, 6.0];

    for (int i = 0; i < starCells.length; i++) {
      final c = starCells[i];
      final pos = cell(c[0], c[1], dx: starDx[i], dy: starDy[i]);
      _drawStar(canvas, pos, starSizes[i], i % 2 == 0 ? primaryPaint : goldenPaint);
    }

    // ── 2. Crescent moons ─────────────────────────────────────────────────────
    // 12 crescents, 1 per column per 2 vertical bands
    final crescents = [
      (cell(0, 0,  dx: 0.7, dy: 0.6), 11.0, primaryPaint),
      (cell(1, 2,  dx: 0.3, dy: 0.3), 10.0, accentPaint),
      (cell(2, 4,  dx: 0.8, dy: 0.5), 13.0, primaryPaint),
      (cell(3, 6,  dx: 0.2, dy: 0.7), 10.0, rosePaint),
      (cell(4, 8,  dx: 0.7, dy: 0.4), 12.0, accentPaint),
      (cell(5, 10, dx: 0.3, dy: 0.6), 11.0, primaryPaint),
      (cell(0, 5,  dx: 0.5, dy: 0.2), 10.0, accentPaint),
      (cell(1, 7,  dx: 0.8, dy: 0.8), 12.0, primaryPaint),
      (cell(2, 9,  dx: 0.2, dy: 0.3), 10.0, rosePaint),
      (cell(3, 1,  dx: 0.7, dy: 0.7), 11.0, goldenPaint),
      (cell(4, 3,  dx: 0.3, dy: 0.4), 10.0, primaryPaint),
      (cell(5, 5,  dx: 0.8, dy: 0.3), 13.0, accentPaint),
    ];
    for (final c in crescents) {
      _drawCrescent(canvas, c.$1, c.$2, c.$3);
    }

    // ── 3. Sunbursts ─────────────────────────────────────────────────────────
    // 12 sunbursts
    final sunbursts = [
      (cell(0, 1,  dx: 0.3, dy: 0.8), 10.0),
      (cell(1, 3,  dx: 0.7, dy: 0.2), 8.0),
      (cell(2, 5,  dx: 0.2, dy: 0.7), 11.0),
      (cell(3, 7,  dx: 0.8, dy: 0.3), 9.0),
      (cell(4, 9,  dx: 0.3, dy: 0.6), 10.0),
      (cell(5, 11, dx: 0.7, dy: 0.2), 8.0),
      (cell(0, 6,  dx: 0.8, dy: 0.5), 9.0),
      (cell(1, 8,  dx: 0.2, dy: 0.8), 11.0),
      (cell(2, 10, dx: 0.7, dy: 0.4), 8.0),
      (cell(3, 0,  dx: 0.5, dy: 0.8), 10.0),
      (cell(4, 2,  dx: 0.8, dy: 0.5), 9.0),
      (cell(5, 4,  dx: 0.2, dy: 0.3), 11.0),
    ];
    for (int i = 0; i < sunbursts.length; i++) {
      final s = sunbursts[i];
      _drawSunburst(canvas, s.$1, s.$2, i % 2 == 0 ? goldenPaint : rosePaint);
    }

    // ── 4. Dashed orbital circles ─────────────────────────────────────────────
    // 10 dashed circles spread across the full height
    final dashCircles = [
      (cell(0, 2,  dx: 0.6, dy: 0.5), 20.0, accentPaint),
      (cell(1, 5,  dx: 0.4, dy: 0.5), 24.0, primaryPaint),
      (cell(2, 8,  dx: 0.7, dy: 0.5), 18.0, accentPaint),
      (cell(3, 11, dx: 0.3, dy: 0.4), 22.0, rosePaint),
      (cell(4, 1,  dx: 0.5, dy: 0.7), 26.0, primaryPaint),
      (cell(5, 4,  dx: 0.6, dy: 0.4), 20.0, accentPaint),
      (cell(0, 7,  dx: 0.4, dy: 0.6), 28.0, primaryPaint),
      (cell(2, 3,  dx: 0.3, dy: 0.8), 22.0, goldenPaint),
      (cell(4, 6,  dx: 0.7, dy: 0.3), 18.0, rosePaint),
      (cell(5, 9,  dx: 0.4, dy: 0.7), 24.0, accentPaint),
    ];
    for (final c in dashCircles) {
      _drawDashedCircle(canvas, c.$1, c.$2, c.$3);
    }

    // ── 5. Constellation dot clusters ────────────────────────────────────────
    // 10 clusters spread across all vertical bands
    final clusterAnchors = [
      cell(0, 0,  dx: 0.4, dy: 0.9),
      cell(1, 2,  dx: 0.6, dy: 0.4),
      cell(2, 4,  dx: 0.3, dy: 0.6),
      cell(3, 6,  dx: 0.7, dy: 0.3),
      cell(4, 8,  dx: 0.2, dy: 0.7),
      cell(5, 10, dx: 0.5, dy: 0.5),
      cell(0, 9,  dx: 0.7, dy: 0.3),
      cell(2, 7,  dx: 0.5, dy: 0.8),
      cell(4, 5,  dx: 0.3, dy: 0.2),
      cell(3, 3,  dx: 0.6, dy: 0.7),
    ];

    for (int i = 0; i < clusterAnchors.length; i++) {
      final a = clusterAnchors[i];
      final pts = i % 2 == 0
          ? [a, a + const Offset(14, -8), a + const Offset(26, -4), a + const Offset(20, 10)]
          : [a, a + const Offset(12, 6), a + const Offset(22, -2)];
      _drawConstellation(canvas, pts, dotPaint, i % 2 == 0 ? primaryPaint : accentPaint);
    }

    // ── 6. Diamond ornaments ─────────────────────────────────────────────────
    // 16 diamonds: 4 corners + 12 spread across all rows
    final diamonds = [
      // Corners
      (cell(0, 0, dx: 0.1, dy: 0.1), 10.0, primaryPaint),
      (cell(5, 0, dx: 0.9, dy: 0.1), 10.0, primaryPaint),
      (cell(0, 11, dx: 0.1, dy: 0.9), 8.0, accentPaint),
      (cell(5, 11, dx: 0.9, dy: 0.9), 8.0, accentPaint),
      // Mid spread
      (cell(1, 1,  dx: 0.5, dy: 0.5), 7.0, rosePaint),
      (cell(2, 3,  dx: 0.5, dy: 0.5), 8.0, primaryPaint),
      (cell(3, 5,  dx: 0.5, dy: 0.5), 7.0, accentPaint),
      (cell(4, 7,  dx: 0.5, dy: 0.5), 9.0, goldenPaint),
      (cell(5, 9,  dx: 0.5, dy: 0.5), 7.0, primaryPaint),
      (cell(0, 4,  dx: 0.5, dy: 0.5), 8.0, rosePaint),
      (cell(1, 6,  dx: 0.5, dy: 0.5), 7.0, accentPaint),
      (cell(2, 8,  dx: 0.5, dy: 0.5), 9.0, primaryPaint),
      (cell(3, 10, dx: 0.5, dy: 0.5), 7.0, goldenPaint),
      (cell(4, 11, dx: 0.5, dy: 0.3), 8.0, accentPaint),
      (cell(1, 10, dx: 0.7, dy: 0.6), 7.0, rosePaint),
      (cell(5, 2,  dx: 0.3, dy: 0.7), 8.0, primaryPaint),
    ];
    for (final d in diamonds) {
      _drawDiamond(canvas, d.$1, d.$2, d.$3);
    }

    // ── 7. Cross tick marks ──────────────────────────────────────────────────
    // 16 ticks — 2 per 3 columns per vertical sweep
    final ticks = [
      cell(0, 1,  dx: 0.8, dy: 0.4),
      cell(1, 2,  dx: 0.2, dy: 0.8),
      cell(2, 3,  dx: 0.6, dy: 0.2),
      cell(3, 4,  dx: 0.4, dy: 0.8),
      cell(4, 5,  dx: 0.2, dy: 0.3),
      cell(5, 6,  dx: 0.7, dy: 0.7),
      cell(0, 7,  dx: 0.6, dy: 0.2),
      cell(1, 8,  dx: 0.3, dy: 0.6),
      cell(2, 9,  dx: 0.8, dy: 0.4),
      cell(3, 10, dx: 0.2, dy: 0.7),
      cell(4, 11, dx: 0.6, dy: 0.3),
      cell(5, 0,  dx: 0.4, dy: 0.7),
      cell(0, 3,  dx: 0.7, dy: 0.6),
      cell(2, 6,  dx: 0.3, dy: 0.4),
      cell(4, 0,  dx: 0.5, dy: 0.8),
      cell(3, 2,  dx: 0.8, dy: 0.3),
    ];
    for (int i = 0; i < ticks.length; i++) {
      _drawCrossTick(canvas, ticks[i], 5.5, i % 2 == 0 ? accentPaint : primaryPaint);
    }

    // ── 8. Small dot fills (extra texture) ───────────────────────────────────
    // 20 tiny filled circles spread uniformly
    const dotPositions = [
      [0.12, 0.05], [0.38, 0.09], [0.62, 0.03], [0.87, 0.07],
      [0.25, 0.17], [0.50, 0.22], [0.75, 0.15], [0.05, 0.28],
      [0.42, 0.33], [0.68, 0.38], [0.93, 0.42], [0.18, 0.47],
      [0.55, 0.52], [0.80, 0.57], [0.08, 0.63], [0.35, 0.68],
      [0.60, 0.73], [0.88, 0.78], [0.22, 0.84], [0.50, 0.88],
      [0.72, 0.93], [0.14, 0.96], [0.45, 0.99], [0.90, 0.95],
    ];
    for (int i = 0; i < dotPositions.length; i++) {
      final dp = dotPositions[i];
      canvas.drawCircle(
        Offset(w * dp[0], h * dp[1]),
        i % 3 == 0 ? 2.5 : 1.8,
        dotPaint,
      );
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
    paint.style = PaintingStyle.stroke;
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
