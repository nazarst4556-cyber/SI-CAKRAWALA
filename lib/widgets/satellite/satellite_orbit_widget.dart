import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../common/tactical_badge.dart';
import '../painters/tactical_globe_painter.dart';

class SatelliteOrbitWidget extends StatefulWidget {
  final double height;
  final VoidCallback? onExpand;

  const SatelliteOrbitWidget({
    super.key,
    this.height = 520,
    this.onExpand,
  });

  @override
  State<SatelliteOrbitWidget> createState() => _SatelliteOrbitWidgetState();
}

class _SatelliteOrbitWidgetState extends State<SatelliteOrbitWidget>
    with TickerProviderStateMixin {
  late AnimationController _orbitController;
  late AnimationController _globeController;

  bool _showFootprint = true;
  bool _showOrbits = true;
  double _speedMultiplier = 1.0;

  @override
  void initState() {
    super.initState();

    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();

    _globeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 32),
    )..repeat();
  }

  @override
  void dispose() {
    _orbitController.dispose();
    _globeController.dispose();
    super.dispose();
  }

  void _setSpeed(double speed) {
    setState(() {
      _speedMultiplier = speed;
      _orbitController.duration = Duration(milliseconds: (14000 / speed).round());
      _globeController.duration = Duration(milliseconds: (32000 / speed).round());
      _orbitController.repeat();
      _globeController.repeat();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF020712), // Deep-space background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.4), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F00C6FF),
            blurRadius: 18,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Core 3D Tactical Globe & Orbit Canvas
            Positioned.fill(
              child: AnimatedBuilder(
                animation: Listenable.merge([_orbitController, _globeController]),
                builder: (context, _) {
                  return CustomPaint(
                    size: Size.infinite,
                    painter: TacticalGlobePainter(
                      orbitProgress: _orbitController.value,
                      globeRotation: _globeController.value,
                      showFootprintCone: _showFootprint,
                      showOrbits: _showOrbits,
                    ),
                  );
                },
              ),
            ),

            // Top-Left Tactical HUD Box (Specs & Sensor Telemetry)
            Positioned(
              top: 14,
              left: 14,
              child: _buildHudBox(
                title: 'CAKRAWALA-3A // LEO-520',
                lines: const [
                  'ORBIT: Sun-Synchronous (520 km)',
                  'INKLINASI: 97.4° Polar Sweep',
                  'SENSOR: SAR + IR + Multi-EO',
                  'STATUS: SCAN PERBATASAN AKTIF',
                ],
                accentColor: AppColors.merahVibrant,
              ),
            ),

            // Top-Right Tactical HUD Box (Ground Footprint & Latency)
            Positioned(
              top: 14,
              right: 14,
              child: _buildHudBox(
                title: 'GROUND FOOTPRINT RADAR',
                lines: const [
                  'TARGET: KEPULAUAN NATUNA',
                  'RESOLUSI: 0.3 m/pixel (Sub-meter)',
                  'SATCOM UPLINK: 24 ms [STABIL]',
                  'INTEGRITAS CITRA: 99.8% BFT',
                ],
                accentColor: AppColors.cyberCyan,
              ),
            ),

            // Floating Center Radar LOCK Crosshairs
            Center(
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.merahVibrant.withValues(alpha: 0.45),
                    width: 1.2,
                  ),
                  borderRadius: BorderRadius.circular(45),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.merahVibrant,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const Positioned(
                      top: 4,
                      child: Text(
                        'NATUNA LOCK',
                        style: TextStyle(
                          fontSize: 7.5,
                          fontWeight: FontWeight.w900,
                          color: AppColors.merahVibrant,
                          fontFamily: 'monospace',
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom-Left Status Badges
            Positioned(
              bottom: 14,
              left: 14,
              child: Row(
                children: const [
                  TacticalBadge(label: '● 4 SATELIT ORBIT', type: BadgeType.live),
                  SizedBox(width: 8),
                  TacticalBadge(label: 'SAR SWEEP AKTIF', type: BadgeType.security),
                ],
              ),
            ),

            // Bottom-Right Controls Panel (HUD Interactive Toggles)
            Positioned(
              bottom: 14,
              right: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.cyberCyan.withValues(alpha: 0.4), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildToggleBtn(
                      icon: Icons.alt_route_rounded,
                      tooltip: 'Toggle Lintasan Orbit',
                      isActive: _showOrbits,
                      onTap: () => setState(() => _showOrbits = !_showOrbits),
                    ),
                    const SizedBox(width: 6),
                    _buildToggleBtn(
                      icon: Icons.radar_rounded,
                      tooltip: 'Toggle Kerucut Sensor SAR',
                      isActive: _showFootprint,
                      onTap: () => setState(() => _showFootprint = !_showFootprint),
                    ),
                    const SizedBox(width: 10),
                    Container(height: 18, width: 1, color: Colors.white24),
                    const SizedBox(width: 10),
                    // Speed Selector
                    _buildSpeedChip('1x', 1.0),
                    const SizedBox(width: 4),
                    _buildSpeedChip('2x', 2.0),
                    const SizedBox(width: 4),
                    _buildSpeedChip('4x', 4.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHudBox({
    required String title,
    required List<String> lines,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accentColor.withValues(alpha: 0.55), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
              color: accentColor,
              letterSpacing: 0.8,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 5),
          ...lines.map(
            (l) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                l,
                style: const TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFE2EAF1),
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleBtn({
    required IconData icon,
    required String tooltip,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isActive ? AppColors.cyberCyan.withValues(alpha: 0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isActive ? AppColors.cyberCyan : Colors.white24,
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 16,
            color: isActive ? AppColors.cyberCyan : Colors.white70,
          ),
        ),
      ),
    );
  }

  Widget _buildSpeedChip(String label, double speed) {
    final isSel = _speedMultiplier == speed;
    return InkWell(
      onTap: () => _setSpeed(speed),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: isSel ? AppColors.merahVibrant : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSel ? AppColors.merahVibrant : Colors.white24,
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.bold,
            color: isSel ? Colors.white : Colors.white70,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }
}
