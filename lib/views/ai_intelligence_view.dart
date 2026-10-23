import 'package:flutter/material.dart';
import '../state/command_center_controller.dart';
import '../core/theme/app_colors.dart';
import '../widgets/common/liquid_glass_card.dart';
import '../widgets/common/tactical_badge.dart';
import '../widgets/ai/ai_neural_engine_widget.dart';
import '../widgets/ai/vector_threat_panel.dart';

class AiIntelligenceView extends StatefulWidget {
  final CommandCenterController controller;

  const AiIntelligenceView({super.key, required this.controller});

  @override
  State<AiIntelligenceView> createState() => _AiIntelligenceViewState();
}

class _AiIntelligenceViewState extends State<AiIntelligenceView> {
  final List<(String, String, Color)> _logEntries = [
    ("[17:34:20]", "Inferensi #9102: Pola APT-29 terdeteksi pada IP 185.220.101.4 (Probabilitas 94.2%)", AppColors.cyberCyanDeep),
    ("[17:33:55]", "Aksi Otomatis: Rule firewall diterapkan di Kodam VI/Mlw dalam 1.2ms (Zero Packet Loss)", AppColors.tniGreenMid),
    ("[17:31:10]", "Update Bobot: Retraining model transfer learning selesai (Akurasi: 97.3%, +0.4%)", AppColors.goldInsignia),
    ("[17:29:45]", "Intersepsi DNS: 890 kueri anomali di-sinkhole dari Sektor Laut Natuna", AppColors.merahVibrant),
  ];

  void _addLog(String fullMsg) {
    setState(() {
      final parts = fullMsg.split("] ");
      if (parts.length > 1) {
        final timeTag = "${parts[0]}]";
        final text = parts[1];
        _logEntries.insert(0, (timeTag, text, AppColors.goldInsignia));
      } else {
        _logEntries.insert(0, ("[LOG]", fullMsg, AppColors.cyberCyanDeep));
      }
      if (_logEntries.length > 15) {
        _logEntries.removeLast();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 960;

            final leftBrainCard = LiquidGlassCard(
              title: "ENGINE KECERDASAN BUATAN — SYNAPTIC NEURAL NETWORK",
              icon: Icons.psychology_outlined,
              trailing: const TacticalBadge(label: "● DEEP INFERENCE", type: BadgeType.live),
              child: AiNeuralEngineWidget(
                onLogGenerated: _addLog,
              ),
            );

            final rightThreatVectors = LiquidGlassCard(
              title: "ANALISA AI — VEKTOR ANCAMAN (EXPANDABLE FORENSIC)",
              icon: Icons.biotech_outlined,
              trailing: const TacticalBadge(label: "REAL-TIME FORENSIC", type: BadgeType.security),
              child: const VectorThreatPanel(),
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (isMobile) ...[
                    leftBrainCard,
                    const SizedBox(height: 16),
                    rightThreatVectors,
                  ] else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 7, child: leftBrainCard),
                        const SizedBox(width: 16),
                        Expanded(flex: 5, child: rightThreatVectors),
                      ],
                    ),

                  const SizedBox(height: 16),

                  // AI Decision Log Stream
                  LiquidGlassCard(
                    title: "LOG KEPUTUSAN OTOMATIS & RETRAINING AI (REAL-TIME STREAM)",
                    icon: Icons.assignment_outlined,
                    trailing: const TacticalBadge(label: "LIVE AUDIT", type: BadgeType.security),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _logEntries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _buildLogItem(entry.$1, entry.$2, entry.$3),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLogItem(String time, String message, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            time,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: accent,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
