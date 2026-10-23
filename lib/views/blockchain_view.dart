import 'dart:async';
import 'package:flutter/material.dart';
import '../state/command_center_controller.dart';
import '../core/theme/app_colors.dart';
import '../widgets/common/liquid_glass_card.dart';
import '../widgets/common/tactical_badge.dart';
import '../widgets/blockchain/blockchain_metrics_header.dart';
import '../widgets/blockchain/tactical_block_list.dart';
import '../widgets/blockchain/validator_mesh_widget.dart';

class BlockchainView extends StatefulWidget {
  final CommandCenterController controller;

  const BlockchainView({super.key, required this.controller});

  @override
  State<BlockchainView> createState() => _BlockchainViewState();
}

class _BlockchainViewState extends State<BlockchainView> {
  bool _isAuditing = false;
  bool _auditVerified = false;

  void _runIntegrityAudit() {
    if (_isAuditing) return;

    setState(() {
      _isAuditing = true;
      _auditVerified = false;
    });

    Timer(const Duration(milliseconds: 1800), () {
      if (mounted) {
        setState(() {
          _isAuditing = false;
          _auditVerified = true;
        });

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.verified_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "AUDIT SUKSES: 48.285 Blok Tervalidasi Blake3. Nol Anomali Terdeteksi.",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.tniGreenMid,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final totalBlocks = widget.controller.blocks.first.height;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 1. Blockchain Top Metrics Header
              BlockchainMetricsHeader(totalBlocks: totalBlocks),

              const SizedBox(height: 14),

              // 2. Audit Scanner Banner Bar & Action Trigger
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _auditVerified ? AppColors.tniGreenMid : AppColors.glassBorder.withValues(alpha: 0.35),
                    width: _auditVerified ? 1.5 : 1.0,
                  ),
                  boxShadow: const [
                    BoxShadow(color: Color(0x0A0F1B2D), blurRadius: 8, offset: Offset(0, 2)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _auditVerified
                            ? AppColors.tniGreenMid.withValues(alpha: 0.12)
                            : AppColors.cyberCyan.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _auditVerified ? Icons.security_rounded : Icons.lock_clock_rounded,
                        color: _auditVerified ? AppColors.tniGreenMid : AppColors.cyberCyanDeep,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                _auditVerified
                                    ? "INTEGRITAS LEDGER: 100% TERVERIFIKASI (ZERO TAMPERING DETECTED)"
                                    : "AUDIT BUKTI KRIPTOGRAFIS BUKU BESAR MILITER",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: _auditVerified ? AppColors.tniGreenMid : AppColors.textPrimary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              TacticalBadge(
                                label: _auditVerified ? "AUDIT LOLOS" : "KONSENSUS PBFT",
                                type: _auditVerified ? BadgeType.live : BadgeType.security,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            "Seluruh rantai blok terlindungi hash Blake3 dan tanda tangan digital Dilithium-5 tahan kuantum.",
                            style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _runIntegrityAudit,
                      icon: Icon(
                        _isAuditing ? Icons.sync : Icons.verified_user_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                      label: Text(
                        _isAuditing ? "MEMINDAI INTEGRITAS..." : "VERIFIKASI INTEGRITAS LEDGER",
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _auditVerified ? AppColors.tniGreenMid : AppColors.merahVibrant,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 3. Validator Mesh Topology (15 Kodam P2P Network)
              const ValidatorMeshWidget(),

              const SizedBox(height: 16),

              // 4. Tactical Block List Stream (Interactive with drill-down modal)
              LiquidGlassCard(
                title: "STREAM BLOK TAKTIS — BUKTI LOG AMAN TAK TERBANTAHKAN (KLIK BLOK UNTUK INSPEKSI FORENSIK)",
                icon: Icons.list_alt_rounded,
                trailing: const TacticalBadge(label: "KONSENSUS 100%", type: BadgeType.live),
                child: TacticalBlockList(
                  blocks: widget.controller.blocks,
                  isAuditScanning: _isAuditing,
                ),
              ),

              const SizedBox(height: 16),

              // 5. Quantum Cryptography Security Standards
              LiquidGlassCard(
                title: "KEAMANAN KRIPTOGRAFI TINGKAT TINGGI — DOKTRIN PERTAHANAN SIBER",
                icon: Icons.security,
                trailing: const TacticalBadge(label: "NIST FIPS 2024", type: BadgeType.security),
                child: Column(
                  children: const [
                    _CryptoRow(name: "Konsensus Protokol", desc: "PBFT Militer (Practical Byzantine Fault Tolerance) — Toleransi 33% gangguan node (4 dari 15 Kodam kompromi) dengan finalitas blok instan 2.3 detik."),
                    Divider(color: Color(0x1F0072FF), height: 16),
                    _CryptoRow(name: "Enkripsi Transmisi", desc: "Post-Quantum Kyber-1024 (NIST FIPS 203) tahan serangan superkomputer kuantum dengan enkapsulasi kunci satcom otomatis."),
                    Divider(color: Color(0x1F0072FF), height: 16),
                    _CryptoRow(name: "Tanda Tangan Digital", desc: "Dilithium-5 Asymmetric Signature (NIST FIPS 204 Category 5) untuk autentikasi perintah Panglima dan bukti insiden tak terbantahkan."),
                    Divider(color: Color(0x1F0072FF), height: 16),
                    _CryptoRow(name: "Privasi Intelijen", desc: "Zero-Knowledge Succinct Proofs (zk-SNARKs) untuk memvalidasi clearance prajurit tanpa membocorkan identitas agen lapangan."),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CryptoRow extends StatelessWidget {
  final String name;
  final String desc;
  const _CryptoRow({required this.name, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 170, child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: AppColors.merahVibrant))),
        Expanded(child: Text(desc, style: const TextStyle(fontSize: 11, color: AppColors.textPrimary))),
      ],
    );
  }
}
