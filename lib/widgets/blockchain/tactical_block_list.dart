import 'package:flutter/material.dart';
import '../../models/blockchain_block.dart';
import '../../core/theme/app_colors.dart';
import '../common/tactical_badge.dart';
import 'block_detail_modal.dart';

class TacticalBlockList extends StatelessWidget {
  final List<BlockchainBlock> blocks;
  final bool isAuditScanning;

  const TacticalBlockList({
    super.key,
    required this.blocks,
    this.isAuditScanning = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: blocks.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, idx) {
        final block = blocks[idx];

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => BlockDetailModal.show(context, block),
            borderRadius: BorderRadius.circular(10),
            hoverColor: AppColors.cyberCyan.withValues(alpha: 0.06),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isAuditScanning
                      ? AppColors.tniGreenMid
                      : AppColors.glassBorder.withValues(alpha: 0.35),
                  width: isAuditScanning ? 1.8 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isAuditScanning
                        ? AppColors.tniGreenMid.withValues(alpha: 0.25)
                        : const Color(0x0A0F1B2D),
                    blurRadius: isAuditScanning ? 12 : 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Block Height Chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0x1AD4AF37),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.goldInsignia, width: 1.2),
                    ),
                    child: Text(
                      "BLOK #${block.height}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AppColors.goldInsignia,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Block Hash & Validator Meta
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              "HASH: ",
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                            ),
                            Expanded(
                              child: Text(
                                block.hash,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.cyberCyanDeep,
                                  fontFamily: 'monospace',
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          "VALIDATOR: ${block.validator} • WAKTU: ${block.timestamp} WIB",
                          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Tx count
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.tniGreenMid.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "${block.transactionsCount} TX Taktis",
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.tniGreenMid,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Verified Status Badge
                  const TacticalBadge(label: "VERIFIED BFT", type: BadgeType.security),

                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
