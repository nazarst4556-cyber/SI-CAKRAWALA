import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../common/tactical_badge.dart';
import '../painters/synaptic_neural_painter.dart';

enum AiOperationalMode {
  autonomous,
  assisted,
  stealth,
}

class AiNeuralEngineWidget extends StatefulWidget {
  final Function(String logMessage)? onLogGenerated;

  const AiNeuralEngineWidget({
    super.key,
    this.onLogGenerated,
  });

  @override
  State<AiNeuralEngineWidget> createState() => _AiNeuralEngineWidgetState();
}

class _AiNeuralEngineWidgetState extends State<AiNeuralEngineWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _neuralAnim;
  bool _isSurging = false;
  (int, int)? _selectedNode; // (layer, node)
  AiOperationalMode _currentMode = AiOperationalMode.autonomous;

  double _accuracy = 97.3;
  int _patterns = 2847;

  @override
  void initState() {
    super.initState();
    _neuralAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _neuralAnim.dispose();
    super.dispose();
  }

  void _triggerRetraining() {
    if (_isSurging) return;

    setState(() {
      _isSurging = true;
      _accuracy = double.parse((_accuracy + 0.1).clamp(95.0, 99.8).toStringAsFixed(1));
      _patterns += 18;
    });

    final now = DateTime.now();
    final timeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
    final logMsg = "[$timeStr] Update Bobot: Retraining model transfer learning selesai (Akurasi: $_accuracy%, 12.800 tensor edge Kodam tersinkronisasi)";

    widget.onLogGenerated?.call(logMsg);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Edge-AI Retraining Berhasil! Bobot tensor berhasil diperbarui (+0.1% Akurasi).',
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.merahVibrant,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );

    Timer(const Duration(milliseconds: 2800), () {
      if (mounted) {
        setState(() => _isSurging = false);
      }
    });
  }

  void _handleCanvasTap(Offset localPos, Size size) {
    final layerSpacing = size.width / (SynapticNeuralPainter.layers.length + 1);

    for (int l = 0; l < SynapticNeuralPainter.layers.length; l++) {
      final x = layerSpacing * (l + 1);
      final count = SynapticNeuralPainter.layers[l];
      final spacing = size.height / (count + 1);

      for (int i = 0; i < count; i++) {
        final nodePos = Offset(x, spacing * (i + 1));
        if ((localPos - nodePos).distance < 20) {
          setState(() {
            if (_selectedNode?.$1 == l && _selectedNode?.$2 == i) {
              _selectedNode = null;
            } else {
              _selectedNode = (l, i);
            }
          });
          return;
        }
      }
    }

    setState(() => _selectedNode = null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Mode Selector Bar & Retraining Trigger Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.35), width: 1),
            boxShadow: const [
              BoxShadow(color: Color(0x0A0F1B2D), blurRadius: 6, offset: Offset(0, 2)),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, c) {
              final isCompact = c.maxWidth < 620;

              final modeDropdown = Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _getModeColor().withValues(alpha: 0.6), width: 1.2),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<AiOperationalMode>(
                    value: _currentMode,
                    icon: Icon(Icons.arrow_drop_down, color: _getModeColor(), size: 20),
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _getModeColor()),
                    items: const [
                      DropdownMenuItem(
                        value: AiOperationalMode.autonomous,
                        child: Text("DOKTRIN: AUTONOMOUS MITIGATION (BLOK OTOMATIS)"),
                      ),
                      DropdownMenuItem(
                        value: AiOperationalMode.assisted,
                        child: Text("DOKTRIN: ASSISTED DECISION (REKOMENDASI KOMANDO)"),
                      ),
                      DropdownMenuItem(
                        value: AiOperationalMode.stealth,
                        child: Text("DOKTRIN: STEALTH / PASSIVE SCAN (SENYAP)"),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _currentMode = val);
                        widget.onLogGenerated?.call("[${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}] Doktrin Operasional AI diubah ke: ${val.name.toUpperCase()}");
                      }
                    },
                  ),
                ),
              );

              final retrainingBtn = ElevatedButton.icon(
                onPressed: _triggerRetraining,
                icon: Icon(
                  _isSurging ? Icons.sync : Icons.bolt_rounded,
                  size: 15,
                  color: Colors.white,
                ),
                label: Text(
                  _isSurging ? "RETRAINING AKTIF..." : "TRIGGER EDGE RETRAINING",
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isSurging ? AppColors.goldInsignia : AppColors.merahVibrant,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              );

              if (isCompact) {
                return Column(
                  children: [
                    modeDropdown,
                    const SizedBox(height: 8),
                    retrainingBtn,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: modeDropdown),
                  const SizedBox(width: 12),
                  retrainingBtn,
                ],
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // Neural Canvas Box with Matrix Coordinates and Interactive Tap
        LayoutBuilder(
          builder: (context, constraints) {
            final canvasHeight = constraints.maxWidth < 600 ? 260.0 : 330.0;

            return Stack(
              children: [
                Container(
                  height: canvasHeight,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF020712), // High-tech neural black
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _isSurging
                          ? AppColors.goldInsignia
                          : AppColors.glassBorder.withValues(alpha: 0.4),
                      width: _isSurging ? 1.8 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _isSurging
                            ? AppColors.goldInsignia.withValues(alpha: 0.3)
                            : const Color(0x0F00C6FF),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: GestureDetector(
                      onTapUp: (details) => _handleCanvasTap(details.localPosition, Size(constraints.maxWidth, canvasHeight)),
                      child: AnimatedBuilder(
                        animation: _neuralAnim,
                        builder: (context, _) {
                          return CustomPaint(
                            size: Size(constraints.maxWidth, canvasHeight),
                            painter: SynapticNeuralPainter(
                              animationValue: _neuralAnim.value,
                              isSurging: _isSurging,
                              selectedNode: _selectedNode,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // Floating Tactical Node Inspector Tooltip
                if (_selectedNode != null)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.merahVibrant, width: 1.2),
                        boxShadow: const [
                          BoxShadow(color: Color(0x40CC0001), blurRadius: 8),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.psychology, size: 14, color: AppColors.merahVibrant),
                              const SizedBox(width: 6),
                              Text(
                                "TENSOR NODE: L${_selectedNode!.$1}-N${_selectedNode!.$2}",
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'monospace'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            "Aktivasi: ReLU • Bias: +0.${(_selectedNode!.$1 * 13 + _selectedNode!.$2 * 7) % 89 + 10} • Bobot Σ: 1.${(_selectedNode!.$2 * 41) % 99 + 10}",
                            style: const TextStyle(fontSize: 9, color: AppColors.cyberCyan, fontFamily: 'monospace'),
                          ),
                          const Text(
                            "Status: Synaptic Firing Optimal (Loss: 0.0024)",
                            style: TextStyle(fontSize: 8.5, color: AppColors.tniGreenNeon, fontFamily: 'monospace'),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Top Right HUD Mode Tag
                Positioned(
                  top: 10,
                  right: 10,
                  child: TacticalBadge(
                    label: _isSurging ? "⚡ RETRAINING SURGE" : "● INFERENSI AKTIF",
                    type: _isSurging ? BadgeType.warning : BadgeType.live,
                  ),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 14),

        // Metrics Grid HUD
        Wrap(
          spacing: 12,
          runSpacing: 10,
          alignment: WrapAlignment.spaceAround,
          children: [
            _buildMetricBadge("AKURASI MODEL", "$_accuracy%", AppColors.cyberCyanDeep),
            _buildMetricBadge("WAKTU INFERENSI", "4ms", AppColors.tniGreenMid),
            _buildMetricBadge("POLA TERDETEKSI", "$_patterns", AppColors.goldInsignia),
            _buildMetricBadge("DIBLOKIR OTOMATIS", "1,203", AppColors.merahVibrant),
          ],
        ),
      ],
    );
  }

  Color _getModeColor() {
    switch (_currentMode) {
      case AiOperationalMode.autonomous:
        return AppColors.merahVibrant;
      case AiOperationalMode.assisted:
        return AppColors.goldInsignia;
      case AiOperationalMode.stealth:
        return AppColors.cyberCyanDeep;
    }
  }

  Widget _buildMetricBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.2),
        boxShadow: const [
          BoxShadow(color: Color(0x0A0F1B2D), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: color, fontFamily: 'monospace')),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
