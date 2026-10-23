import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SatelliteOrbitPainter extends CustomPainter {
  final double progress;

  SatelliteOrbitPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final earthRadius = min(size.width, size.height) * 0.35;

    // Earth Sphere Radial Gradient
    final earthPaint = Paint()
      ..shader = RadialGradient(
        colors: const [
          Color(0xFF0F321E),
          Color(0xFF06180D),
          Color(0xFF020904),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: earthRadius));

    canvas.drawCircle(center, earthRadius, earthPaint);

    // Atmosphere Glow
    final glowPaint = Paint()
      ..color = const Color(0x4000E5FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, earthRadius + 3, glowPaint);

    // Polar Orbit Ellipse
    final orbitPaint = Paint()
      ..color = const Color(0x6600E5FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(0.7);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: earthRadius * 2.4, height: earthRadius * 1.0), orbitPaint);

    // Satellite Position
    final satAngle = progress * 2 * pi;
    final satX = (earthRadius * 1.2) * cos(satAngle);
    final satY = (earthRadius * 0.5) * sin(satAngle);
    canvas.drawCircle(Offset(satX, satY), 5.0, Paint()..color = AppColors.cyberCyan);
    canvas.restore();

    // Equatorial Orbit
    canvas.drawOval(
      Rect.fromCenter(center: center, width: earthRadius * 2.2, height: earthRadius * 0.6),
      Paint()..color = const Color(0x66D4AF37)..style = PaintingStyle.stroke..strokeWidth = 1.0,
    );
  }

  @override
  bool shouldRepaint(covariant SatelliteOrbitPainter oldDelegate) => true;
}
