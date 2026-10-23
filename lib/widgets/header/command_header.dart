import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import 'threat_level_meter.dart';

class CommandHeader extends StatelessWidget {
  final int threatLevel;

  const CommandHeader({super.key, required this.threatLevel});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    const days = ["MINGGU", "SENIN", "SELASA", "RABU", "KAMIS", "JUMAT", "SABTU"];
    const months = ["JAN", "FEB", "MAR", "APR", "MEI", "JUN", "JUL", "AGU", "SEP", "OKT", "NOV", "DES"];
    final dateStr = "${days[now.weekday % 7]}, ${now.day.toString().padLeft(2, '0')} ${months[now.month - 1]} ${now.year}";
    final timeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        border: Border(
          bottom: BorderSide(color: AppColors.glassBorder.withValues(alpha: 0.4), width: 1.5),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0F1B2D),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 1024;
          final isVeryCompact = constraints.maxWidth < 768;

          return Row(
            children: [
              // Left: Insignia + Brand
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(color: AppColors.goldGlow, blurRadius: 10),
                  ],
                ),
                child: Image.asset(
                  'assets/images/sicakrawala_logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.shield,
                    color: AppColors.goldInsignia,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.tniGreenMid.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                      border: const Border(
                        left: BorderSide(color: AppColors.tniGreenMid, width: 2.5),
                      ),
                    ),
                    child: const Text(
                      AppConstants.militaryUnit,
                      style: TextStyle(
                        fontSize: 9,
                        color: AppColors.tniGreenMid,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Text(
                        AppConstants.appName,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "| ${AppConstants.appFullName}",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.merahVibrant,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  if (!isVeryCompact)
                    const Text(
                      AppConstants.tagLine,
                      style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                    ),
                ],
              ),

              const Spacer(),

              // Center: Threat Meter (hide on very narrow screens)
              if (!isCompact) ...[
                ThreatLevelMeter(level: threatLevel),
                const Spacer(),
              ],

              // Right: Real-time Stats & User Profile
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isCompact) ...[
                    _buildStatItem("NODE AKTIF", "1,247", AppColors.cyberCyanDeep),
                    const SizedBox(width: 14),
                    _buildStatItem("ANCAMAN", "38", AppColors.merahVibrant),
                    const SizedBox(width: 14),
                    _buildStatItem("SATELIT", "7/9", AppColors.tniGreenMid),
                    const SizedBox(width: 16),
                    Container(height: 28, width: 1, color: const Color(0x260F1B2D)),
                    const SizedBox(width: 16),
                  ],
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        dateStr.toUpperCase(),
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                      ),
                      Text(
                        timeStr,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.merahVibrant,
                          letterSpacing: 1.0,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const Text(
                        "WIB — UTC+7",
                        style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: AppColors.tniGreenMid),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  // Commander avatar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.goldInsignia, width: 1.2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x140F1B2D),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0x20D4AF37),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(Icons.military_tech, color: AppColors.goldInsignia, size: 20),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              "KOL. NAZARUL QUDRI",
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            Text(
                              "KOMANDAN SATSIBER AD",
                              style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: AppColors.tniGreenMid),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color,
            fontFamily: 'monospace',
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
