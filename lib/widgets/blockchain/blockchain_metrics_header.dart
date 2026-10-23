import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class BlockchainMetricsHeader extends StatelessWidget {
  final int totalBlocks;
  final int totalTx;
  final int activeValidators;
  final double blockTimeSeconds;

  const BlockchainMetricsHeader({
    super.key,
    required this.totalBlocks,
    this.totalTx = 1247832,
    this.activeValidators = 15,
    this.blockTimeSeconds = 2.3,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;

        final stat1 = _buildBlockStat(
          "TOTAL BLOK",
          "#$totalBlocks",
          Icons.token,
          AppColors.tniGreenMid,
        );
        final stat2 = _buildBlockStat(
          "TRANSAKSI TAKTIS",
          "1,247,832",
          Icons.receipt_long,
          AppColors.cyberCyanDeep,
        );
        final stat3 = _buildBlockStat(
          "VALIDATOR KODAM",
          "$activeValidators Node (100% Quorum)",
          Icons.verified_user,
          AppColors.goldInsignia,
        );
        final stat4 = _buildBlockStat(
          "WAKTU BLOK BFT",
          "${blockTimeSeconds}s Finalitas",
          Icons.timer,
          AppColors.merahVibrant,
        );

        if (isMobile) {
          return Column(
            children: [
              Row(children: [Expanded(child: stat1), const SizedBox(width: 10), Expanded(child: stat2)]),
              const SizedBox(height: 10),
              Row(children: [Expanded(child: stat3), const SizedBox(width: 10), Expanded(child: stat4)]),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: stat1),
            const SizedBox(width: 12),
            Expanded(child: stat2),
            const SizedBox(width: 12),
            Expanded(child: stat3),
            const SizedBox(width: 12),
            Expanded(child: stat4),
          ],
        );
      },
    );
  }

  Widget _buildBlockStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontFamily: 'monospace',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
