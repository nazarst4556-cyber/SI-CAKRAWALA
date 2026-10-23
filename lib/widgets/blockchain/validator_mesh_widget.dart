import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../common/tactical_badge.dart';

class ValidatorNodeInfo {
  final String name;
  final String region;
  final double uptime;
  final int blocksValidated;

  const ValidatorNodeInfo(this.name, this.region, this.uptime, this.blocksValidated);
}

class ValidatorMeshWidget extends StatefulWidget {
  const ValidatorMeshWidget({super.key});

  @override
  State<ValidatorMeshWidget> createState() => _ValidatorMeshWidgetState();
}

class _ValidatorMeshWidgetState extends State<ValidatorMeshWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  int? _hoveredNodeIndex;

  static const List<ValidatorNodeInfo> validators = [
    ValidatorNodeInfo("MABES SATBER AD", "Jakarta Pusat (Leader Node)", 99.99, 12840),
    ValidatorNodeInfo("KODAM I / BB", "Medan (Sumut-Aceh)", 99.98, 8420),
    ValidatorNodeInfo("KODAM II / SWJ", "Palembang (Sumsel)", 99.96, 7890),
    ValidatorNodeInfo("KODAM III / SLW", "Bandung (Jabar)", 99.99, 9120),
    ValidatorNodeInfo("KODAM IV / DIP", "Semarang (Jateng-DIY)", 99.97, 8640),
    ValidatorNodeInfo("KODAM V / BRW", "Surabaya (Jatim)", 99.98, 9450),
    ValidatorNodeInfo("KODAM VI / MLW", "Balikpapan (Kaltim-IKN)", 99.95, 7920),
    ValidatorNodeInfo("KODAM IX / UDY", "Denpasar (Bali-Nusa Tenggara)", 99.96, 6840),
    ValidatorNodeInfo("KODAM XII / TPR", "Pontianak (Kalbar)", 99.94, 6210),
    ValidatorNodeInfo("KODAM XIII / MDK", "Manado (Sulut-Gorontalo)", 99.96, 7150),
    ValidatorNodeInfo("KODAM XIV / HSN", "Makassar (Sulsel-Sultra)", 99.98, 8310),
    ValidatorNodeInfo("KODAM XV / PTM", "Ambon (Maluku-Malut)", 99.92, 5940),
    ValidatorNodeInfo("KODAM XVII / CEN", "Jayapura (Papua Raya)", 99.93, 7640),
    ValidatorNodeInfo("KODAM XVIII / KSR", "Manokwari (Papua Barat)", 99.91, 5420),
    ValidatorNodeInfo("KODAM JAYA", "Jakarta Raya (Metropolitan)", 99.99, 11200),
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.35), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F1B2D),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.hub_rounded, size: 18, color: AppColors.tniGreenMid),
              const SizedBox(width: 8),
              const Text(
                "TOPOLOGI MESH P2P VALIDATOR KODAM (KONSENSUS PBFT 100%)",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary, letterSpacing: 0.5),
              ),
              const Spacer(),
              const TacticalBadge(label: "15/15 QUORUM AKTIF", type: BadgeType.security),
            ],
          ),
          const SizedBox(height: 12),

          // Mesh Canvas
          SizedBox(
            height: 220,
            width: double.infinity,
            child: AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (context, _) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: _MeshPainter(
                    animationProgress: _pulseCtrl.value,
                    hoveredIndex: _hoveredNodeIndex,
                    validatorsCount: validators.length,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // Hovered / Active Validator Info Strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_outlined, size: 16, color: AppColors.tniGreenMid),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _hoveredNodeIndex != null
                        ? "${validators[_hoveredNodeIndex!].name} • ${validators[_hoveredNodeIndex!].region} • Uptime: ${validators[_hoveredNodeIndex!].uptime}% (${validators[_hoveredNodeIndex!].blocksValidated} Blok)"
                        : "PBFT Consensus Quorum: 15 Node Kodam tersinkronisasi toleransi gangguan 4 node kompromi (BFT 33%).",
                    style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.tniGreenMid.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text("BFT QUORUM", style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: AppColors.tniGreenMid)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MeshPainter extends CustomPainter {
  final double animationProgress;
  final int? hoveredIndex;
  final int validatorsCount;

  _MeshPainter({
    required this.animationProgress,
    required this.hoveredIndex,
    required this.validatorsCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final ringRadius = min(size.width, size.height) * 0.40;

    // Calculate 15 perimeter nodes + 1 center node (Mabes Satber)
    final List<Offset> nodePositions = [];

    // Center node (Mabes Satber AD)
    nodePositions.add(center);

    // 14 outer Kodam nodes distributed in circle
    for (int i = 0; i < validatorsCount - 1; i++) {
      final angle = (i * 2 * pi / (validatorsCount - 1)) + (animationProgress * 0.2);
      nodePositions.add(Offset(
        center.dx + ringRadius * cos(angle),
        center.dy + ringRadius * sin(angle),
      ));
    }

    // Draw P2P Connection Mesh Edges
    final edgePaint = Paint()
      ..color = const Color(0xFF0072FF).withValues(alpha: 0.15)
      ..strokeWidth = 1.0;

    for (int i = 0; i < nodePositions.length; i++) {
      for (int j = i + 1; j < nodePositions.length; j++) {
        // Connect to center and nearest neighbors
        if (i == 0 || (j - i) <= 2 || (j - i) == nodePositions.length - 2) {
          canvas.drawLine(nodePositions[i], nodePositions[j], edgePaint);
        }
      }
    }

    // Draw Traveling Consensus Verification Pulses
    final pulsePaint = Paint()
      ..color = AppColors.tniGreenMid.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    for (int i = 1; i < nodePositions.length; i++) {
      final t = (animationProgress * 2 + i * 0.12) % 1.0;
      final pulsePos = Offset.lerp(nodePositions[0], nodePositions[i], t)!;
      canvas.drawCircle(pulsePos, 2.2, pulsePaint);
    }

    // Draw Validator Nodes
    for (int i = 0; i < nodePositions.length; i++) {
      final pos = nodePositions[i];
      final isCenter = i == 0;
      final nodeColor = isCenter ? AppColors.merahVibrant : AppColors.goldInsignia;

      // Glow Halo
      final haloPaint = Paint()
        ..color = nodeColor.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(pos, isCenter ? 12 : 8, haloPaint);

      // Node Circle
      canvas.drawCircle(
        pos,
        isCenter ? 8 : 5.5,
        Paint()..color = nodeColor,
      );

      // White Center Dot
      canvas.drawCircle(
        pos,
        isCenter ? 3.5 : 2.2,
        Paint()..color = Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MeshPainter oldDelegate) => true;
}
