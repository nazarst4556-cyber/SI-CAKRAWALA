import 'package:flutter/material.dart';
import '../state/command_center_controller.dart';
import '../core/theme/app_colors.dart';
import '../widgets/common/liquid_glass_card.dart';
import '../widgets/common/tactical_badge.dart';
import '../widgets/satellite/realistic_globe_widget.dart';

class SatelliteView extends StatelessWidget {
  final CommandCenterController controller;

  const SatelliteView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 960;

            final leftScanFeed = LiquidGlassCard(
              title: "MATA SATELIT — 3D REAL EARTH & SATELLITE ORBIT (INTERAKTIF)",
              icon: Icons.satellite_alt_outlined,
              trailing: const TacticalBadge(label: "● REAL EARTH LIVE", type: BadgeType.live),
              child: RealisticGlobeWidget(
                height: isMobile ? 420 : 560,
              ),
            );

            final rightSatellites = Column(
              children: [
                LiquidGlassCard(
                  title: "ARMADA SATELIT TNI",
                  icon: Icons.view_list,
                  trailing: TacticalBadge(
                    label: "${controller.satellites.length} ORBIT AKTIF",
                    type: BadgeType.security,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.satellites.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, idx) {
                      final sat = controller.satellites[idx];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.88),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.35), width: 1),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0A0F1B2D),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.cyberCyan.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.satellite_outlined, color: AppColors.cyberCyanDeep, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(sat.code, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
                                  const SizedBox(height: 2),
                                  Text("${sat.type} • ${sat.altitude}", style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                  Text("Resolusi: ${sat.resolution}", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.tniGreenMid)),
                                ],
                              ),
                            ),
                            TacticalBadge(label: sat.status, type: BadgeType.live),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Telemetry Downlink Card
                LiquidGlassCard(
                  title: "TELEMETRI DOWNLINK & SENSOR SAR",
                  icon: Icons.cell_tower,
                  trailing: const TacticalBadge(label: "LOCK NATUNA", type: BadgeType.warning),
                  child: Column(
                    children: [
                      _buildDownlinkRow("Frekuensi Downlink", "8.245 GHz (X-Band Militer)", AppColors.cyberCyanDeep),
                      const Divider(color: Color(0x1F0072FF), height: 14),
                      _buildDownlinkRow("Kanal Transmisi", "Post-Quantum Kyber-1024", AppColors.merahVibrant),
                      const Divider(color: Color(0x1F0072FF), height: 14),
                      _buildDownlinkRow("Modus Sensor", "Stripmap SAR + IR Multi-Spektral", AppColors.tniGreenMid),
                      const Divider(color: Color(0x1F0072FF), height: 14),
                      _buildDownlinkRow("Signal-to-Noise (SNR)", "28.4 dB [Sangat Baik]", AppColors.textPrimary),
                    ],
                  ),
                ),
              ],
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: isMobile
                  ? Column(
                      children: [
                        leftScanFeed,
                        const SizedBox(height: 16),
                        rightSatellites,
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 7, child: leftScanFeed),
                        const SizedBox(width: 16),
                        Expanded(flex: 5, child: rightSatellites),
                      ],
                    ),
            );
          },
        );
      },
    );
  }

  Widget _buildDownlinkRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color, fontFamily: 'monospace'),
        ),
      ],
    );
  }
}
