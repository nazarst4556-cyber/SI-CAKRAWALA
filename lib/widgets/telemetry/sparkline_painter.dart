import 'package:flutter/material.dart';

/// A custom painter that renders a real-time sparkline chart with a gradient fill.
class SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;
  final Color fillColorTop;
  final double criticalThreshold; // 0.0–1.0
  final double animValue; // 0.0–1.0 for scan-line pulse

  SparklinePainter({
    required this.data,
    required this.lineColor,
    required this.fillColorTop,
    this.criticalThreshold = 0.90,
    this.animValue = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final double maxVal = data.reduce((a, b) => a > b ? a : b).clamp(1.0, double.infinity);
    final double minVal = data.reduce((a, b) => a < b ? a : b);

    // Build path points
    final List<Offset> points = [];
    for (int i = 0; i < data.length; i++) {
      final double x = i / (data.length - 1) * size.width;
      final double normalized = (data[i] - minVal) / (maxVal - minVal).clamp(1.0, double.infinity);
      final double y = size.height - normalized * size.height * 0.85 - 2;
      points.add(Offset(x, y));
    }

    // Gradient fill below the line
    final fillPath = Path()..moveTo(points.first.dx, size.height);
    for (final p in points) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [fillColorTop.withValues(alpha: 0.35), fillColorTop.withValues(alpha: 0.0)],
    );
    final fillPaint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    // Draw the line
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      // Smooth cubic bezier
      final prev = points[i - 1];
      final curr = points[i];
      final cp1 = Offset((prev.dx + curr.dx) / 2, prev.dy);
      final cp2 = Offset((prev.dx + curr.dx) / 2, curr.dy);
      linePath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, curr.dx, curr.dy);
    }

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2.5)
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(linePath, linePaint);

    // Solid line on top
    final solidLinePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(linePath, solidLinePaint);

    // Current value dot at last point
    final lastPt = points.last;
    final dotGlow = Paint()
      ..color = lineColor.withValues(alpha: 0.4)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6.0);
    canvas.drawCircle(lastPt, 6, dotGlow);

    final dotPaint = Paint()..color = lineColor;
    canvas.drawCircle(lastPt, 3, dotPaint);

    // Animated scan-line (vertical sweep)
    final scanX = animValue * size.width;
    final scanPaint = Paint()
      ..color = lineColor.withValues(alpha: 0.12)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(scanX, 0), Offset(scanX, size.height), scanPaint);

    // Critical threshold line
    final threshY = size.height - criticalThreshold * size.height * 0.85 - 2;
    final threshPaint = Paint()
      ..color = const Color(0xFFFF2A37).withValues(alpha: 0.45)
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round;

    // Dashed threshold
    double dashStart = 0;
    while (dashStart < size.width) {
      canvas.drawLine(
        Offset(dashStart, threshY),
        Offset((dashStart + 6).clamp(0, size.width), threshY),
        threshPaint,
      );
      dashStart += 10;
    }
  }

  @override
  bool shouldRepaint(SparklinePainter old) =>
      old.data != data || old.animValue != animValue || old.lineColor != lineColor;
}
