import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ThreatLevelMeter extends StatelessWidget {
  final int level; // 1 to 5

  const ThreatLevelMeter({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final colors = [
      AppColors.tniGreenMid,
      const Color(0xFF65A30D),
      AppColors.warningAmber,
      const Color(0xFFEA580C),
      AppColors.merahVibrant,
    ];

    String statusText;
    switch (level) {
      case 1: statusText = "RENDAH (NORMAL)"; break;
      case 2: statusText = "GUARDED"; break;
      case 3: statusText = "ELEVATED (SIAGA)"; break;
      case 4: statusText = "TINGGI (HIGH)"; break;
      case 5: statusText = "DARURAT (CRITICAL)"; break;
      default: statusText = "ELEVATED";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.4), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0F1B2D),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "TINGKAT ANCAMAN NASIONAL",
            style: TextStyle(
              fontSize: 9.5,
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (index) {
              final isActive = (index + 1) <= level;
              return Container(
                width: 22,
                height: 7,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: isActive ? colors[index] : const Color(0x1F0072FF),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: colors[index].withValues(alpha: 0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 1),
                          )
                        ]
                      : null,
                ),
              );
            }),
          ),
          const SizedBox(height: 5),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: colors[(level - 1).clamp(0, 4)],
              letterSpacing: 1.0,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
