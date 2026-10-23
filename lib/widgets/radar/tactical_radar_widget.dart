import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum RadarSpectrumMode {
  allSpectrum,
  hfVhf,
  satcomScan,
}

class RadarBlip {
  final String id;
  final String callsign;
  final String ip;
  final String vector;
  final double normalizedDist; // 0.0 (center) to 1.0 (perimeter)
  final double angle; // in radians
  final Color color;
  final String severity; // SECURE, WARNING, CRITICAL
  final double speedMbps;
  final bool isBreaching;
  final String sector;

  const RadarBlip({
    required this.id,
    required this.callsign,
    required this.ip,
    required this.vector,
    required this.normalizedDist,
    required this.angle,
    required this.color,
    required this.severity,
    required this.speedMbps,
    this.isBreaching = false,
    required this.sector,
  });
}

/// Advanced interactive Tactical Radar Canvas with smooth 360° sweep,
/// hit-tested target blips, ghost velocity motion trails, and perimeter breach pulse.
class TacticalRadarWidget extends StatefulWidget {
  final double size;
  final RadarSpectrumMode spectrumMode;
  final ValueChanged<RadarBlip>? onBlipSelected;
  final RadarBlip? lockedBlip;

  const TacticalRadarWidget({
    super.key,
    this.size = 220,
    this.spectrumMode = RadarSpectrumMode.allSpectrum,
    this.onBlipSelected,
    this.lockedBlip,
  });

  @override
  State<TacticalRadarWidget> createState() => _TacticalRadarWidgetState();
}

class _TacticalRadarWidgetState extends State<TacticalRadarWidget>
    with TickerProviderStateMixin {
  late AnimationController _sweepController;
  late AnimationController _pulseController;

  // 12 Tactical targets distributed across sectors
  static const List<RadarBlip> _blips = [
    // Red Hostile Threats
    RadarBlip(
      id: "TGT-01",
      callsign: "INTRUDER-ALPHA",
      ip: "185.220.101.4",
      vector: "SSH Port Sweep & Brute Force",
      normalizedDist: 0.38, // Inside perimeter breach!
      angle: 0.85,
      color: Color(0xFFD90429),
      severity: "CRITICAL BREACH",
      speedMbps: 42.5,
      isBreaching: true,
      sector: "Natuna Barat",
    ),
    RadarBlip(
      id: "TGT-02",
      callsign: "ANOMALY-X",
      ip: "103.22.201.88",
      vector: "SYN-Flood DDoS Amplification",
      normalizedDist: 0.72,
      angle: 2.15,
      color: Color(0xFFD90429),
      severity: "CRITICAL ATTACK",
      speedMbps: 88.0,
      sector: "Selat Malaka",
    ),
    RadarBlip(
      id: "TGT-03",
      callsign: "BOTNET-NODE-9",
      ip: "45.154.255.12",
      vector: "Malware Beaconing / C2 Probe",
      normalizedDist: 0.44, // Breaching!
      angle: 4.60,
      color: Color(0xFFD90429),
      severity: "CRITICAL INTRUSION",
      speedMbps: 18.2,
      isBreaching: true,
      sector: "Tarakan Pamtas",
    ),

    // Orange Warning Targets
    RadarBlip(
      id: "TGT-04",
      callsign: "JAMMER-PROBE",
      ip: "194.26.29.112",
      vector: "RF Microwave Noise Injection",
      normalizedDist: 0.65,
      angle: 3.40,
      color: Color(0xFFFFD166),
      severity: "WARNING PROBE",
      speedMbps: 9.4,
      sector: "Ambalat",
    ),
    RadarBlip(
      id: "TGT-05",
      callsign: "UNREGISTERED-UPLINK",
      ip: "91.240.118.6",
      vector: "Satcom Transponder Scan",
      normalizedDist: 0.82,
      angle: 1.45,
      color: Color(0xFFFFD166),
      severity: "WARNING SCAN",
      speedMbps: 14.1,
      sector: "Pasifik Utara",
    ),
    RadarBlip(
      id: "TGT-06",
      callsign: "VPN-GATEWAY-UNAUTH",
      ip: "185.190.141.2",
      vector: "Bypass Tunnel Attempt",
      normalizedDist: 0.58,
      angle: 5.75,
      color: Color(0xFFFFD166),
      severity: "WARNING SUSPICIOUS",
      speedMbps: 6.8,
      sector: "Skouw Papua",
    ),

    // Green Friendly Patrol / Verified Nodes
    RadarBlip(
      id: "TGT-07",
      callsign: "PATROL-KODAM-VI",
      ip: "10.6.1.1",
      vector: "Verified Kodam VI Validator Node",
      normalizedDist: 0.52,
      angle: 0.25,
      color: Color(0xFF06D6A0),
      severity: "SECURE NODE",
      speedMbps: 120.0,
      sector: "Balikpapan C2",
    ),
    RadarBlip(
      id: "TGT-08",
      callsign: "SATGAS-SIBER-01",
      ip: "10.2.7.9",
      vector: "Mobile C2 Pamtas Natuna",
      normalizedDist: 0.35,
      angle: 1.10,
      color: Color(0xFF06D6A0),
      severity: "SECURE PATROL",
      speedMbps: 54.0,
      sector: "Natuna Ranai",
    ),
    RadarBlip(
      id: "TGT-09",
      callsign: "MABES-SATBER-HUB",
      ip: "10.0.0.1",
      vector: "Master Backbone Cilangkap",
      normalizedDist: 0.20,
      angle: 3.80,
      color: Color(0xFF06D6A0),
      severity: "SECURE MASTER",
      speedMbps: 450.0,
      sector: "Jakarta Mabes",
    ),
    RadarBlip(
      id: "TGT-10",
      callsign: "CAKRAWALA-3A-LEO",
      ip: "10.88.3.1",
      vector: "SAR Radar Downlink Transceiver",
      normalizedDist: 0.76,
      angle: 2.80,
      color: Color(0xFF06D6A0),
      severity: "SECURE SATELLITE",
      speedMbps: 850.0,
      sector: "LEO 520km",
    ),
    RadarBlip(
      id: "TGT-11",
      callsign: "KODAM-XVII-GATE",
      ip: "10.17.0.1",
      vector: "Kodam XVII Jayapura Defense Relay",
      normalizedDist: 0.68,
      angle: 4.15,
      color: Color(0xFF06D6A0),
      severity: "SECURE NODE",
      speedMbps: 95.0,
      sector: "Jayapura",
    ),
    RadarBlip(
      id: "TGT-12",
      callsign: "TIM-TRC-JAKARTA",
      ip: "10.1.4.12",
      vector: "Tim Respon Cepat Siaga Nasional",
      normalizedDist: 0.28,
      angle: 5.10,
      color: Color(0xFF06D6A0),
      severity: "SECURE UNIT",
      speedMbps: 210.0,
      sector: "Jakarta",
    ),
  ];

  @override
  void initState() {
    super.initState();
    // 360 degrees sweep every 4.0 seconds as required
    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _sweepController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Color get _themeColor {
    switch (widget.spectrumMode) {
      case RadarSpectrumMode.hfVhf:
        return const Color(0xFF00F0FF); // Cyber Cyan
      case RadarSpectrumMode.satcomScan:
        return const Color(0xFFFFD166); // Amber
      case RadarSpectrumMode.allSpectrum:
        return const Color(0xFF06D6A0); // Emerald Green
    }
  }

  void _handleTap(TapUpDetails details, Size canvasSize) {
    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    final radius = min(canvasSize.width, canvasSize.height) / 2 - 8;
    final tapPos = details.localPosition;

    // Hit-test blips within 16px touch radius
    for (final blip in _blips) {
      final bx = center.dx + cos(blip.angle) * (radius * blip.normalizedDist);
      final by = center.dy + sin(blip.angle) * (radius * blip.normalizedDist);
      final dist = (tapPos - Offset(bx, by)).distance;

      if (dist <= 18.0) {
        if (widget.onBlipSelected != null) {
          widget.onBlipSelected!(blip);
        }
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final s = Size(constraints.maxWidth, constraints.maxHeight);

          return GestureDetector(
            onTapUp: (details) => _handleTap(details, s),
            child: AnimatedBuilder(
              animation: Listenable.merge([_sweepController, _pulseController]),
              builder: (context, child) {
                return CustomPaint(
                  size: s,
                  painter: _AdvancedRadarCanvasPainter(
                    sweepAngle: _sweepController.value * 2 * pi,
                    pulseValue: _pulseController.value,
                    themeColor: _themeColor,
                    blips: _blips,
                    lockedBlipId: widget.lockedBlip?.id,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _AdvancedRadarCanvasPainter extends CustomPainter {
  final double sweepAngle;
  final double pulseValue;
  final Color themeColor;
  final List<RadarBlip> blips;
  final String? lockedBlipId;

  _AdvancedRadarCanvasPainter({
    required this.sweepAngle,
    required this.pulseValue,
    required this.themeColor,
    required this.blips,
    this.lockedBlipId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 8;

    // 1. Dark radar backdrop circle
    final bgPaint = Paint()
      ..color = const Color(0xF2020D08)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // 2. Concentric Range Rings (4 rings: 500km, 1000km, 1800km, 2500km)
    final ringPaint = Paint()
      ..color = themeColor.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 1; i <= 4; i++) {
      canvas.drawCircle(center, (radius / 4) * i, ringPaint);
    }

    // 3. Inner Perimeter Breach Alert Ring (at 50% radius)
    // Pulses red when threats are breaching inside
    final hasBreachingThreats = blips.any((b) => b.isBreaching);
    if (hasBreachingThreats) {
      final breachRadius = radius * 0.48;
      final breachPaint = Paint()
        ..color = const Color(0xFFD90429).withValues(alpha: 0.3 + pulseValue * 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8;
      canvas.drawCircle(center, breachRadius, breachPaint);

      final breachFill = Paint()
        ..color = const Color(0xFFD90429).withValues(alpha: 0.06 * pulseValue)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, breachRadius, breachFill);
    }

    // 4. Crosshairs & Radial Azimuth Degree Guides
    final crossPaint = Paint()
      ..color = themeColor.withValues(alpha: 0.20)
      ..strokeWidth = 0.9;

    canvas.drawLine(Offset(center.dx - radius, center.dy), Offset(center.dx + radius, center.dy), crossPaint);
    canvas.drawLine(Offset(center.dx, center.dy - radius), Offset(center.dx, center.dy + radius), crossPaint);

    // Diagonal ticks
    final diag1Start = Offset(center.dx + cos(pi / 4) * (radius * 0.8), center.dy + sin(pi / 4) * (radius * 0.8));
    final diag1End = Offset(center.dx + cos(pi / 4) * radius, center.dy + sin(pi / 4) * radius);
    canvas.drawLine(diag1Start, diag1End, crossPaint);

    // 5. Radar Sweep Gradient Wedge
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        startAngle: sweepAngle - 0.75,
        endAngle: sweepAngle,
        colors: [
          Colors.transparent,
          themeColor.withValues(alpha: 0.02),
          themeColor.withValues(alpha: 0.35),
        ],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, sweepPaint);

    // 6. Active Sweep Leading Line
    final lineEnd = Offset(
      center.dx + cos(sweepAngle) * radius,
      center.dy + sin(sweepAngle) * radius,
    );
    final sweepLinePaint = Paint()
      ..color = themeColor
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, lineEnd, sweepLinePaint);

    // 7. Outer Compass Dial Border
    final outerRing = Paint()
      ..color = themeColor.withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius, outerRing);

    // 8. Render Target Blips with Ghost Velocity Trails & Lock Reticles
    for (final blip in blips) {
      final bx = center.dx + cos(blip.angle) * (radius * blip.normalizedDist);
      final by = center.dy + sin(blip.angle) * (radius * blip.normalizedDist);
      final bPos = Offset(bx, by);

      // Ghost Velocity Motion Trail Line (indicates speed & intrusion angle)
      final trailLength = (blip.speedMbps / 100.0) * 16.0 + 6.0;
      final trailEnd = Offset(
        bx - cos(blip.angle) * trailLength,
        by - sin(blip.angle) * trailLength,
      );
      final trailPaint = Paint()
        ..shader = LinearGradient(
          colors: [blip.color.withValues(alpha: 0.6), Colors.transparent],
        ).createShader(Rect.fromPoints(bPos, trailEnd))
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(bPos, trailEnd, trailPaint);

      // Target Blip Glow
      final glowPaint = Paint()
        ..color = blip.color.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);
      canvas.drawCircle(bPos, 5.5, glowPaint);

      // Target Blip Center Solid Dot
      final dotPaint = Paint()..color = blip.color;
      canvas.drawCircle(bPos, 3.2, dotPaint);

      // Special Reticle if Locked
      if (blip.id == lockedBlipId) {
        final lockRing = Paint()
          ..color = AppColors.merahVibrant
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4;
        final lockRadius = 8.0 + pulseValue * 4.0;
        canvas.drawCircle(bPos, lockRadius, lockRing);

        // Corner lock brackets
        final bracketPaint = Paint()
          ..color = AppColors.merahVibrant
          ..strokeWidth = 1.5;
        canvas.drawLine(Offset(bx - 12, by - 12), Offset(bx - 6, by - 12), bracketPaint);
        canvas.drawLine(Offset(bx - 12, by - 12), Offset(bx - 12, by - 6), bracketPaint);
        canvas.drawLine(Offset(bx + 12, by + 12), Offset(bx + 6, by + 12), bracketPaint);
        canvas.drawLine(Offset(bx + 12, by + 12), Offset(bx + 12, by + 6), bracketPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _AdvancedRadarCanvasPainter oldDelegate) => true;
}
