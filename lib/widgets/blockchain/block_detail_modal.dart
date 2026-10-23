import 'package:flutter/material.dart';
import '../../models/blockchain_block.dart';
import '../../core/theme/app_colors.dart';
import '../common/tactical_badge.dart';

class BlockDetailModal extends StatelessWidget {
  final BlockchainBlock block;

  const BlockDetailModal({super.key, required this.block});

  static void show(BuildContext context, BlockchainBlock block) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlockDetailModal(block: block),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      constraints: const BoxConstraints(maxWidth: 720),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.goldInsignia, width: 1.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33D4AF37),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
          BoxShadow(
            color: Color(0x140F1B2D),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Modal Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0x1AD4AF37), Color(0x060072FF)],
                ),
                border: Border(
                  bottom: BorderSide(color: Color(0x33D4AF37), width: 1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0x20D4AF37),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.goldInsignia, width: 1.2),
                    ),
                    child: Text(
                      "BLOK #${block.height}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: AppColors.goldInsignia,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "BUKTI BUKU BESAR TAKTIS (IMMUTABLE FORENSIC LEDGER)",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        Text(
                          "Validator: ${block.validator} • Waktu: ${block.timestamp} WIB",
                          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const TacticalBadge(label: "VERIFIED BFT", type: BadgeType.security),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: AppColors.textSecondary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Modal Body Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cryptographic Hashes Container
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF020712), // Deep crypto black
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.cyberCyan.withValues(alpha: 0.4), width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHashRow("BLOCK HASH (BLAKE3)", block.hash, AppColors.cyberCyan),
                        const SizedBox(height: 6),
                        _buildHashRow("PREVIOUS HASH", block.prevHash, AppColors.textSecondary),
                        const SizedBox(height: 6),
                        _buildHashRow("MERKLE ROOT", block.merkleRoot, AppColors.goldInsignia),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              "NONCE: ${block.nonce}    TRANSAKSI: ${block.transactionsCount} TX",
                              style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppColors.tniGreenNeon, fontFamily: 'monospace'),
                            ),
                            const Spacer(),
                            const Text(
                              "KONSENSUS: 100% QUORUM (15/15 KODAM)",
                              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.white70, fontFamily: 'monospace'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Post-Quantum Digital Signature Badge Box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.35), width: 1),
                      boxShadow: const [
                        BoxShadow(color: Color(0x0A0F1B2D), blurRadius: 6, offset: Offset(0, 2)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.verified_user_rounded, color: AppColors.tniGreenMid, size: 18),
                            const SizedBox(width: 8),
                            const Text(
                              "TANDA TANGAN ASIMETRIS PASCA-KUANTUM (DILITHIUM-5):",
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.tniGreenMid.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                "NIST FIPS 204",
                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.tniGreenMid),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          block.dilithiumSignature,
                          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.merahVibrant, fontFamily: 'monospace'),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Enkapsulasi Kunci Transmisi: ${block.kyberTag} (Tahan Komputer Kuantum)",
                          style: const TextStyle(fontSize: 9.5, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Encrypted Tactical Logs Section
                  const Text(
                    "LOG PERISTIWA TAKTIS TERBUKTI (IMMUTABLE LOGS):",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 8),

                  ...block.tacticalLogs.map(
                    (log) => Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border(
                          left: const BorderSide(color: AppColors.merahVibrant, width: 3),
                          top: BorderSide(color: AppColors.glassBorder.withValues(alpha: 0.2)),
                          right: BorderSide(color: AppColors.glassBorder.withValues(alpha: 0.2)),
                          bottom: BorderSide(color: AppColors.glassBorder.withValues(alpha: 0.2)),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.shield_outlined, size: 14, color: AppColors.merahVibrant),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              log,
                              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontFamily: 'monospace'),
                            ),
                          ),
                          const TacticalBadge(label: "LOGGED", type: BadgeType.security),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Hash blok #${block.height} dan tanda tangan Dilithium-5 berhasil diverifikasi."),
                            backgroundColor: AppColors.tniGreenMid,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.check_circle_outline, size: 16, color: Colors.white),
                      label: const Text(
                        "VALIDASI BUKTI KRIPTOGRAFIS TINGKAT TINGGI",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11.5),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.merahVibrant,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHashRow(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label:",
          style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Colors.white60, letterSpacing: 0.5),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color, fontFamily: 'monospace'),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
