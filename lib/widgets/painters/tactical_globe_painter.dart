import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class StarParticle {
  final double x; // 0.0 to 1.0
  final double y; // 0.0 to 1.0
  final double size;
  final double phase;

  const StarParticle(this.x, this.y, this.size, this.phase);
}

class TacticalGlobePainter extends CustomPainter {
  final double orbitProgress;
  final double globeRotation;
  final bool showFootprintCone;
  final bool showOrbits;

  static final List<StarParticle> _stars = _generateStars();

  static List<StarParticle> _generateStars() {
    final rand = Random(42); // deterministic seed for stable starfield
    return List.generate(85, (_) {
      return StarParticle(
        rand.nextDouble(),
        rand.nextDouble(),
        0.8 + rand.nextDouble() * 2.2,
        rand.nextDouble() * 2 * pi,
      );
    });
  }

  TacticalGlobePainter({
    required this.orbitProgress,
    required this.globeRotation,
    this.showFootprintCone = true,
    this.showOrbits = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final earthRadius = min(size.width, size.height) * 0.32;

    // 1. STARFIELD BACKGROUND PARTICLES
    _drawStarfield(canvas, size);

    // 2. ATMOSPHERIC SCATTERING RIM GLOW (Outer atmosphere)
    _drawAtmosphereGlow(canvas, center, earthRadius);

    // 3. 3D EARTH GLOBE BODY & SPHERICAL SHADING
    _drawEarthBody(canvas, center, earthRadius);

    // 4. HOLOGRAPHIC ROTATING GRATICULE GRID (Latitudes & Longitudes)
    _drawGraticuleGrid(canvas, center, earthRadius);

    // 5. HOLOGRAPHIC CONTINENTAL LANDMASSES (Rotating with globe)
    _drawContinents(canvas, center, earthRadius);

    // 6. MULTI-LAYERED INCLINED ORBITAL PATHS
    if (showOrbits) {
      _drawOrbitalPaths(canvas, center, earthRadius);
    }

    // 7. ANIMATED SATELLITE MARKERS & SCAN FOOTPRINTS
    _drawSatellites(canvas, center, earthRadius);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 1. STARFIELD
  // ───────────────────────────────────────────────────────────────────────────
  void _drawStarfield(Canvas canvas, Size size) {
    for (final star in _stars) {
      final pos = Offset(star.x * size.width, star.y * size.height);
      final twinkle = 0.3 + 0.7 * (0.5 + 0.5 * sin(star.phase + orbitProgress * 4 * pi));

      final starPaint = Paint()
        ..color = Color.lerp(
          const Color(0xFF80D8FF),
          Colors.white,
          twinkle,
        )!.withValues(alpha: twinkle.clamp(0.15, 0.9))
        ..style = PaintingStyle.fill;

      canvas.drawCircle(pos, star.size * (0.8 + 0.2 * twinkle), starPaint);
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 2. ATMOSPHERE GLOW
  // ───────────────────────────────────────────────────────────────────────────
  void _drawAtmosphereGlow(Canvas canvas, Offset center, double radius) {
    // Outer Deep Rayleigh Scattering Glow
    final outerGlowPaint = Paint()
      ..color = const Color(0xFF00C6FF).withValues(alpha: 0.28)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);
    canvas.drawCircle(center, radius + 14, outerGlowPaint);

    // Secondary Ionosphere Cyan Rim Glow
    final ionoGlowPaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(center, radius + 5, ionoGlowPaint);

    // Crisp Atmospheric Limb Ring
    final limbPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..shader = SweepGradient(
        colors: const [
          Color(0xFF00E5FF),
          Color(0xFF0072FF),
          Color(0x3300C6FF),
          Color(0xFF00E5FF),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius + 1));
    canvas.drawCircle(center, radius + 1, limbPaint);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 3. EARTH BODY & 3D SPHERICAL SHADING
  // ───────────────────────────────────────────────────────────────────────────
  void _drawEarthBody(Canvas canvas, Offset center, double radius) {
    // Base 3D Sphere with Sunlit directional highlight from Top-Left
    final sphereRect = Rect.fromCircle(center: center, radius: radius);
    final earthPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.4, -0.4),
        radius: 0.95,
        colors: const [
          Color(0xFF0F3057), // Sunlit ocean deep navy
          Color(0xFF0A2240),
          Color(0xFF041224),
          Color(0xFF020712), // Deep-space shadow side
        ],
        stops: const [0.0, 0.35, 0.70, 1.0],
      ).createShader(sphereRect);

    canvas.drawCircle(center, radius, earthPaint);

    // Clip subsequent Earth grid & continents inside the globe disc
    canvas.save();
    final clipPath = Path()..addOval(sphereRect);
    canvas.clipPath(clipPath);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 4. HOLOGRAPHIC ROTATING GRATICULE GRID
  // ───────────────────────────────────────────────────────────────────────────
  void _drawGraticuleGrid(Canvas canvas, Offset center, double radius) {
    final gridPaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;

    final equatorPaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Latitudes (Parallel horizontal lines of varying scale)
    for (double lat = -60; lat <= 60; lat += 20) {
      final rad = lat * pi / 180;
      final yOffset = radius * sin(rad);
      final rAtLat = radius * cos(rad);

      final rect = Rect.fromCenter(
        center: Offset(center.dx, center.dy + yOffset),
        width: rAtLat * 2,
        height: rAtLat * 0.45,
      );

      canvas.drawOval(rect, lat == 0 ? equatorPaint : gridPaint);
    }

    // Longitudes (Meridians that rotate with globeRotation)
    for (int i = 0; i < 8; i++) {
      final baseAngle = (i * pi / 4) + (globeRotation * 2 * pi);
      final normAngle = baseAngle % (2 * pi);

      // Only draw meridians on the visible front hemisphere (-pi/2 to pi/2)
      final cosVal = cos(normAngle);
      final isFront = sin(normAngle) >= 0;

      final meridianPaint = Paint()
        ..color = const Color(0xFF00E5FF).withValues(alpha: isFront ? 0.22 : 0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isFront ? 1.0 : 0.6;

      final rect = Rect.fromCenter(
        center: center,
        width: (radius * 2 * cosVal.abs()).clamp(1.0, radius * 2),
        height: radius * 2,
      );

      canvas.drawOval(rect, meridianPaint);
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 5. HOLOGRAPHIC CONTINENTS
  // ───────────────────────────────────────────────────────────────────────────
  void _drawContinents(Canvas canvas, Offset center, double radius) {
    final continentPaint = Paint()
      ..color = const Color(0xFF2D6A4F).withValues(alpha: 0.40)
      ..style = PaintingStyle.fill;

    final continentStroke = Paint()
      ..color = const Color(0xFF52B788).withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Indonesian Archipelago & Eurasia landmass stylized blobs
    final rotOffset = (globeRotation * 2 * pi);

    final landmasses = [
      // (relative longitude angle, latitude Y, width, height)
      (0.2, -0.05, 0.45, 0.22), // Nusantara Archipelago (Sumatera/Jawa/Kal/Sul/Papua)
      (0.35, -0.40, 0.35, 0.25), // Australia
      (0.15, 0.35, 0.60, 0.35),  // East Asia
      (0.85, 0.30, 0.50, 0.30),  // Europe / Mid-East
      (0.70, -0.05, 0.40, 0.40), // Africa
    ];

    for (final land in landmasses) {
      final angle = land.$1 * 2 * pi + rotOffset;
      final xOffset = radius * sin(angle);
      final isFront = cos(angle) > -0.2;

      if (!isFront) continue; // culled on back side

      final pos = Offset(
        center.dx + xOffset,
        center.dy + land.$2 * radius,
      );

      final rect = Rect.fromCenter(
        center: pos,
        width: land.$3 * radius,
        height: land.$4 * radius,
      );

      canvas.drawOval(rect, continentPaint);
      canvas.drawOval(rect, continentStroke);
    }

    // Restore Earth sphere clip
    canvas.restore();
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 6. MULTI-LAYERED ORBITAL PATHS
  // ───────────────────────────────────────────────────────────────────────────
  void _drawOrbitalPaths(Canvas canvas, Offset center, double radius) {
    // Orbit 1: LEO Polar Sun-Synchronous (CAKRAWALA-3A) — Gold/Cyan Active Tracking
    _drawInclinedOrbit(
      canvas, center,
      semiMajor: radius * 1.48,
      semiMinor: radius * 0.68,
      inclination: -1.18, // ~68 degrees inclination
      color: AppColors.merahVibrant,
      strokeWidth: 1.4,
      isDashed: true,
    );

    // Orbit 2: Tactical Reconnaissance Orbit (LAPAN-A3 / Natuna Sector)
    _drawInclinedOrbit(
      canvas, center,
      semiMajor: radius * 1.35,
      semiMinor: radius * 0.55,
      inclination: 0.55, // ~31 degrees
      color: AppColors.cyberCyan,
      strokeWidth: 1.2,
      isDashed: false,
    );

    // Orbit 3: MEO Navigation Orbit (SAT-TNI 01)
    _drawInclinedOrbit(
      canvas, center,
      semiMajor: radius * 1.70,
      semiMinor: radius * 0.82,
      inclination: 0.95, // ~55 degrees
      color: AppColors.tniGreenNeon,
      strokeWidth: 1.0,
      isDashed: true,
    );

    // Orbit 4: GEO Geostationary Ring (PALAPA-N1)
    _drawInclinedOrbit(
      canvas, center,
      semiMajor: radius * 2.05,
      semiMinor: radius * 0.42,
      inclination: -0.12, // near-equatorial
      color: AppColors.goldInsignia,
      strokeWidth: 1.0,
      isDashed: true,
    );
  }

  void _drawInclinedOrbit(
    Canvas canvas,
    Offset center, {
    required double semiMajor,
    required double semiMinor,
    required double inclination,
    required Color color,
    required double strokeWidth,
    required bool isDashed,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(inclination);

    final orbitRect = Rect.fromCenter(
      center: Offset.zero,
      width: semiMajor * 2,
      height: semiMinor * 2,
    );

    final orbitPaint = Paint()
      ..color = color.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawOval(orbitRect, orbitPaint);

    // Subtle glow line
    final orbitGlow = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 2.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawOval(orbitRect, orbitGlow);

    canvas.restore();
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 7. SATELLITES & TARGET LOCK SCAN BEAM
  // ───────────────────────────────────────────────────────────────────────────
  void _drawSatellites(Canvas canvas, Offset center, double radius) {
    // Sat 1: CAKRAWALA-3A (Primary Satellite on Inclined Orbit 1)
    final sat1Angle = orbitProgress * 2 * pi;
    final sat1Major = radius * 1.48;
    final sat1Minor = radius * 0.68;
    final sat1Inc = -1.18;

    final sat1Pos = _calculateOrbitPoint(center, sat1Major, sat1Minor, sat1Inc, sat1Angle);
    final sat1IsFront = sin(sat1Angle) >= -0.2;

    if (sat1IsFront) {
      if (showFootprintCone) {
        _drawScanCone(canvas, sat1Pos, center, radius);
      }
      _drawSatelliteVehicle(
        canvas,
        sat1Pos,
        label: 'CAKRAWALA-3A [LEO-520]',
        color: AppColors.merahVibrant,
        isLocked: true,
        progress: orbitProgress,
      );
    }

    // Sat 2: LAPAN-A3 (SAR Reconnaissance on Orbit 2)
    final sat2Angle = (orbitProgress * 1.6 + 0.8) * 2 * pi;
    final sat2Pos = _calculateOrbitPoint(center, radius * 1.35, radius * 0.55, 0.55, sat2Angle);
    final sat2IsFront = sin(sat2Angle) >= -0.3;

    if (sat2IsFront) {
      _drawSatelliteVehicle(
        canvas,
        sat2Pos,
        label: 'LAPAN-A3 [SAR]',
        color: AppColors.cyberCyan,
        isLocked: false,
        progress: orbitProgress,
      );
    }

    // Sat 3: SAT-TNI 01 (MEO Navigation on Orbit 3)
    final sat3Angle = (orbitProgress * 0.9 + 2.2) * 2 * pi;
    final sat3Pos = _calculateOrbitPoint(center, radius * 1.70, radius * 0.82, 0.95, sat3Angle);
    final sat3IsFront = sin(sat3Angle) >= -0.3;

    if (sat3IsFront) {
      _drawSatelliteVehicle(
        canvas,
        sat3Pos,
        label: 'SAT-TNI 01 [MEO]',
        color: AppColors.tniGreenNeon,
        isLocked: false,
        progress: orbitProgress,
      );
    }

    // Sat 4: PALAPA-N1 (GEO Comms on Orbit 4)
    final sat4Angle = (orbitProgress * 0.4 + 3.8) * 2 * pi;
    final sat4Pos = _calculateOrbitPoint(center, radius * 2.05, radius * 0.42, -0.12, sat4Angle);
    final sat4IsFront = sin(sat4Angle) >= -0.3;

    if (sat4IsFront) {
      _drawSatelliteVehicle(
        canvas,
        sat4Pos,
        label: 'PALAPA-N1 [GEO]',
        color: AppColors.goldInsignia,
        isLocked: false,
        progress: orbitProgress,
      );
    }
  }

  Offset _calculateOrbitPoint(
    Offset center,
    double semiMajor,
    double semiMinor,
    double inclination,
    double angle,
  ) {
    final x0 = semiMajor * cos(angle);
    final y0 = semiMinor * sin(angle);

    final xRot = x0 * cos(inclination) - y0 * sin(inclination);
    final yRot = x0 * sin(inclination) + y0 * cos(inclination);

    return Offset(center.dx + xRot, center.dy + yRot);
  }

  void _drawScanCone(Canvas canvas, Offset satPos, Offset center, double earthRadius) {
    // Vector pointing from satellite toward Earth center
    final dir = center - satPos;
    final dist = dir.distance;
    final norm = dir / dist;

    // Contact point on Earth surface
    final contact = satPos + norm * (dist - earthRadius * 0.7);

    final conePath = Path()
      ..moveTo(satPos.dx, satPos.dy)
      ..lineTo(contact.dx - 28, contact.dy)
      ..lineTo(contact.dx + 28, contact.dy)
      ..close();

    final conePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.merahVibrant.withValues(alpha: 0.35),
          AppColors.merahVibrant.withValues(alpha: 0.04),
        ],
      ).createShader(Rect.fromPoints(satPos, contact));

    canvas.drawPath(conePath, conePaint);

    // Target scanning footprint ring on Earth surface
    final scanRingPaint = Paint()
      ..color = AppColors.merahVibrant.withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawOval(
      Rect.fromCenter(center: contact, width: 56, height: 20),
      scanRingPaint,
    );
  }

  void _drawSatelliteVehicle(
    Canvas canvas,
    Offset pos, {
    required String label,
    required Color color,
    required bool isLocked,
    required double progress,
  }) {
    // 1. Radar Pulse Ring
    final pulseScale = (progress * 4) % 1.0;
    final pulsePaint = Paint()
      ..color = color.withValues(alpha: (1.0 - pulseScale).clamp(0.0, 0.6))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(pos, 8 + pulseScale * 14, pulsePaint);

    // 2. Solar Panel Wings Visual
    final wingPaint = Paint()
      ..color = const Color(0xFF00C6FF)
      ..style = PaintingStyle.fill;
    final bodyPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Left & Right Solar Panels
    canvas.drawRect(Rect.fromCenter(center: Offset(pos.dx - 8, pos.dy), width: 7, height: 3.5), wingPaint);
    canvas.drawRect(Rect.fromCenter(center: Offset(pos.dx + 8, pos.dy), width: 7, height: 3.5), wingPaint);

    // Main Satellite Core
    canvas.drawCircle(pos, 4.0, bodyPaint);

    // Glowing Halo
    final haloPaint = Paint()
      ..color = color.withValues(alpha: 0.65)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(pos, 5.0, haloPaint);

    // 3. Tactical Label Badge
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          fontSize: 8.5,
          fontWeight: FontWeight.bold,
          color: color,
          fontFamily: 'monospace',
          shadows: const [
            Shadow(color: Colors.black, blurRadius: 4),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(canvas, Offset(pos.dx + 10, pos.dy - 6));

    if (isLocked) {
      // Crosshairs LOCK tag
      final lockPainter = TextPainter(
        text: const TextSpan(
          text: 'TARGET LOCK: NATUNA',
          style: TextStyle(
            fontSize: 7.5,
            fontWeight: FontWeight.w900,
            color: AppColors.merahVibrant,
            fontFamily: 'monospace',
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      lockPainter.paint(canvas, Offset(pos.dx + 10, pos.dy + 6));
    }
  }

  @override
  bool shouldRepaint(covariant TacticalGlobePainter oldDelegate) {
    return oldDelegate.orbitProgress != orbitProgress ||
        oldDelegate.globeRotation != globeRotation ||
        oldDelegate.showFootprintCone != showFootprintCone ||
        oldDelegate.showOrbits != showOrbits;
  }
}
