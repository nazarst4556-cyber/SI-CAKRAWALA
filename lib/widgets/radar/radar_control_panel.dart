import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../common/liquid_glass_card.dart';
import '../common/tactical_badge.dart';
import 'tactical_radar_widget.dart';

class RadarControlPanel extends StatefulWidget {
  const RadarControlPanel({super.key});

  @override
  State<RadarControlPanel> createState() => _RadarControlPanelState();
}

class _RadarControlPanelState extends State<RadarControlPanel> {
  RadarSpectrumMode _spectrumMode = RadarSpectrumMode.allSpectrum;
  RadarBlip? _selectedBlip;
  RadarBlip? _lockedBlip;

  Color get _themeColor {
    switch (_spectrumMode) {
      case RadarSpectrumMode.hfVhf:
        return const Color(0xFF00F0FF);
      case RadarSpectrumMode.satcomScan:
        return const Color(0xFFFFD166);
      case RadarSpectrumMode.allSpectrum:
        return const Color(0xFF06D6A0);
    }
  }

  void _onBlipTapped(RadarBlip blip) {
    setState(() {
      _selectedBlip = blip;
    });
  }

  void _lockTarget(RadarBlip blip) {
    setState(() {
      _lockedBlip = blip;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("RADAR LOCK TERPASANG: [${blip.callsign}] ${blip.ip} • Sektor ${blip.sector}"),
        backgroundColor: blip.color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LiquidGlassCard(
          title: 'RADAR SIBER TAKTIS (EARLY WARNING SYSTEM)',
          icon: Icons.radar,
          trailing: TacticalBadge(
            label: _lockedBlip != null ? 'TARGET LOCK' : '● AKTIF',
            type: _lockedBlip != null ? BadgeType.critical : BadgeType.live,
          ),
          child: Column(
            children: [
              // ── Spectrum Mode Switcher ────────────────────────────────────
              _buildSpectrumSelector(),
              const SizedBox(height: 10),

              // ── Interactive Radar Canvas ──────────────────────────────────
              Stack(
                alignment: Alignment.center,
                children: [
                  TacticalRadarWidget(
                    size: 200,
                    spectrumMode: _spectrumMode,
                    lockedBlip: _lockedBlip,
                    onBlipSelected: _onBlipTapped,
                  ),
                  // Tap hint overlay if no blip selected
                  if (_selectedBlip == null)
                    Positioned(
                      bottom: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          "KETUK BLIP UNTUK INSPEKSI",
                          style: TextStyle(
                            fontSize: 8.5,
                            fontFamily: 'monospace',
                            color: Colors.white70,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 10),

              // ── Target Inspection Card (Opens on Blip Tap) ────────────────
              if (_selectedBlip != null) ...[
                _buildTargetInspectionCard(_selectedBlip!),
                const SizedBox(height: 10),
              ],

              // ── Synchronized Live Stats Display ───────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0x0A0072FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0x180072FF)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatPill('Jangkauan', '2.500 km', Icons.straighten_rounded),
                    Container(height: 20, width: 1, color: AppColors.glassBorder.withValues(alpha: 0.3)),
                    _buildStatPill('Kecepatan', '360°/4s', Icons.sync_rounded),
                    Container(height: 20, width: 1, color: AppColors.glassBorder.withValues(alpha: 0.3)),
                    _buildStatPill('Target Aktif', '12 Blip', Icons.adjust_rounded),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // ── Defense Efficiency Performance Cards ────────────────────────────
        Row(
          children: [
            Expanded(child: _buildEfficiencyCard('PERTAHANAN', '98.7%', Icons.shield_outlined, AppColors.tniGreenNeon)),
            const SizedBox(width: 8),
            Expanded(child: _buildEfficiencyCard('DETEKSI', '0.3s', Icons.search_rounded, AppColors.cyberCyan)),
            const SizedBox(width: 8),
            Expanded(child: _buildEfficiencyCard('RESPONS', '1.2s', Icons.bolt_rounded, AppColors.goldInsignia)),
          ],
        ),
      ],
    );
  }

  // ── Spectrum Selector Bar ─────────────────────────────────────────────────
  Widget _buildSpectrumSelector() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _themeColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          _buildSpectrumTab("ALL SPECTRUM", RadarSpectrumMode.allSpectrum, const Color(0xFF06D6A0)),
          const SizedBox(width: 4),
          _buildSpectrumTab("HF/VHF SCAN", RadarSpectrumMode.hfVhf, const Color(0xFF00F0FF)),
          const SizedBox(width: 4),
          _buildSpectrumTab("SATCOM SCAN", RadarSpectrumMode.satcomScan, const Color(0xFFFFD166)),
        ],
      ),
    );
  }

  Widget _buildSpectrumTab(String label, RadarSpectrumMode mode, Color color) {
    final isSelected = _spectrumMode == mode;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _spectrumMode = mode),
        borderRadius: BorderRadius.circular(6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: isSelected ? color : Colors.white60,
              fontFamily: 'monospace',
              letterSpacing: 0.4,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  // ── Floating Target Inspection Card ───────────────────────────────────────
  Widget _buildTargetInspectionCard(RadarBlip blip) {
    final isLocked = _lockedBlip?.id == blip.id;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: blip.color, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: blip.color.withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: blip.color),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    blip.callsign,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: blip.color,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: blip.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  blip.severity,
                  style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: blip.color, fontFamily: 'monospace'),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 14, color: Colors.white60),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => setState(() => _selectedBlip = null),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("IP: ${blip.ip}", style: const TextStyle(fontSize: 10, color: Colors.white, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
              Text("Sektor: ${blip.sector}", style: const TextStyle(fontSize: 10, color: AppColors.cyberCyan, fontFamily: 'monospace')),
            ],
          ),
          const SizedBox(height: 2),
          Text("Vektor: ${blip.vector}", style: const TextStyle(fontSize: 9.5, color: Colors.white70)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLocked ? AppColors.merahVibrant : const Color(0xFF1E293B),
                    foregroundColor: Colors.white,
                    side: BorderSide(color: blip.color),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    elevation: 0,
                  ),
                  icon: Icon(isLocked ? Icons.lock_rounded : Icons.radar_rounded, size: 13),
                  label: Text(
                    isLocked ? "TARGET TERKUNCI" : "KUNCI SASARAN [LOCK]",
                    style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                  ),
                  onPressed: () => _lockTarget(blip),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 13, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 8.5, color: AppColors.textSecondary)),
            Text(
              value,
              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontFamily: 'monospace'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEfficiencyCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.10), blurRadius: 8)],
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.6),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
