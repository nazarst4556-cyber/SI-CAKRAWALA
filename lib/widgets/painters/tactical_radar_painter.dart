import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class TacticalRadarPainter extends CustomPainter {
  final double sweepAngle; // 0 to 2*PI

  TacticalRadarPainter({required this.sweepAngle});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 8;

    // Rings
    final ringPaint = Paint()
      ..color = const Color(0x3339FF14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 1; i <= 4; i++) {
      canvas.drawCircle(center, (radius / 4) * i, ringPaint);
    }

    // Crosshairs
    canvas.drawLine(Offset(center.dx - radius, center.dy), Offset(center.dx + radius, center.dy), ringPaint);
    canvas.drawLine(Offset(center.dx, center.dy - radius), Offset(center.dx, center.dy + radius), ringPaint);

    // Radar Sweep Wedge
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        startAngle: sweepAngle - 0.6,
        endAngle: sweepAngle,
        colors: const [
          Colors.transparent,
          Color(0x5939FF14),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, sweepPaint);

    // Sweep Line
    final lineEnd = Offset(center.dx + cos(sweepAngle) * radius, center.dy + sin(sweepAngle) * radius);
    final sweepLinePaint = Paint()
      ..color = AppColors.tniGreenNeon
      ..strokeWidth = 1.5;
    canvas.drawLine(center, lineEnd, sweepLinePaint);

    // Blips
    final blipPositions = [
      Offset(center.dx + radius * 0.45, center.dy - radius * 0.3),
      Offset(center.dx - radius * 0.6, center.dy + radius * 0.2),
      Offset(center.dx + radius * 0.7, center.dy + radius * 0.5),
    ];

    final blipColors = [AppColors.tniGreenNeon, AppColors.merahNeon, AppColors.warningAmber];

    for (int i = 0; i < blipPositions.length; i++) {
      canvas.drawCircle(blipPositions[i], 3.0, Paint()..color = blipColors[i]);
    }
  }

  @override
  bool shouldRepaint(covariant TacticalRadarPainter oldDelegate) => true;
}
