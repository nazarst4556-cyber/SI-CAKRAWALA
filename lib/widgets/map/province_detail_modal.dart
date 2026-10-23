import 'package:flutter/material.dart';
import '../../models/province_node.dart';
import '../../core/theme/app_colors.dart';
import '../common/tactical_badge.dart';

class ProvinceDetailModal extends StatelessWidget {
  final ProvinceNode node;
  final VoidCallback? onFocusNode;

  const ProvinceDetailModal({
    super.key,
    required this.node,
    this.onFocusNode,
  });

  static void show(BuildContext context, ProvinceNode node, {VoidCallback? onFocus}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ProvinceDetailModal(node: node, onFocusNode: onFocus),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      constraints: const BoxConstraints(maxWidth: 680),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: node.statusColor.withValues(alpha: 0.6), width: 1.8),
        boxShadow: [
          BoxShadow(
            color: node.statusColor.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          const BoxShadow(
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
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    node.statusColor.withValues(alpha: 0.15),
                    const Color(0x050072FF),
                  ],
                ),
                border: Border(
                  bottom: BorderSide(color: AppColors.glassBorder.withValues(alpha: 0.3), width: 1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: node.statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: node.statusColor, width: 1.2),
                    ),
                    child: Icon(
                      node.isStrategicBorder ? Icons.security_rounded : Icons.hub_rounded,
                      color: node.statusColor,
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
                              node.name.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                                letterSpacing: 0.8,
                              ),
                            ),
                            if (node.isStrategicBorder) ...[
                              const SizedBox(width: 8),
                              const TacticalBadge(label: 'POS PAMTAS', type: BadgeType.warning),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${node.commandUnit} • Ibu Kota: ${node.capital}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  TacticalBadge(
                    label: node.statusLabel,
                    type: node.threatLevel == NodeThreatLevel.critical
                        ? BadgeType.critical
                        : node.threatLevel == NodeThreatLevel.warning
                            ? BadgeType.warning
                            : BadgeType.live,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: AppColors.textSecondary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Modal Body Grid
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Row 1: Key Telemetry
                  Row(
                    children: [
                      Expanded(child: _buildMetricTile('KORDINAT MILITER', '${node.latitude.toStringAsFixed(4)}°, ${node.longitude.toStringAsFixed(4)}°', Icons.pin_drop_outlined, AppColors.cyberCyanDeep)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildMetricTile('ALAMAT IP GATEWAY', node.ipAddress, Icons.dns_outlined, AppColors.goldInsignia)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildMetricTile('LATENSI SATCOM', node.ping, Icons.network_check_rounded, node.statusColor)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Row 2: Bandwidth & Personnel
                  Row(
                    children: [
                      Expanded(child: _buildMetricTile('BANDWIDTH ENKRIPSI', node.bandwidth, Icons.speed_rounded, AppColors.tniGreenMid)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildMetricTile('SATGAS SIBER AKTIF', '${node.personnel} Operator', Icons.groups_rounded, AppColors.textPrimary)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildMetricTile('ANCAMAN TERDETEKSI', '${node.activeThreats} Insiden', Icons.warning_rounded, node.activeThreats > 10 ? AppColors.merahVibrant : AppColors.warningAmber)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Encryption & Security Box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.35), width: 1.2),
                      boxShadow: const [
                        BoxShadow(color: Color(0x0A0F1B2D), blurRadius: 6, offset: Offset(0, 2)),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lock_rounded, color: AppColors.merahVibrant, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'STANDAR KEAMANAN KRIPTOGRAFI NODE:',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                              ),
                              Text(
                                node.encryption,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontFamily: 'monospace'),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.tniGreenMid.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'VALIDASI 100%',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.tniGreenMid),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Action Buttons
                  Row(
                    children: [
                      if (onFocusNode != null) ...[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              onFocusNode?.call();
                            },
                            icon: const Icon(Icons.center_focus_strong_rounded, size: 16),
                            label: const Text('FOKUSKAN KAMERA PETA'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.cyberCyanDeep,
                              side: const BorderSide(color: AppColors.cyberCyanDeep, width: 1.2),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Perintah mitigasi siber dikirim ke ${node.commandUnit}.'),
                                backgroundColor: AppColors.tniGreenMid,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.shield_outlined, size: 16, color: Colors.white),
                          label: const Text('PERKUAT PERTAHANAN KODAM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.merahVibrant,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.35), width: 1),
        boxShadow: const [
          BoxShadow(color: Color(0x060F1B2D), blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontFamily: 'monospace'),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
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
