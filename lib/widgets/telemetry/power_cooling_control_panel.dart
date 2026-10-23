import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Cooling & Power Matrix Controller with 3 operational modes.
class PowerCoolingControlPanel extends StatefulWidget {
  const PowerCoolingControlPanel({super.key});

  @override
  State<PowerCoolingControlPanel> createState() => _PowerCoolingControlPanelState();
}

class _PowerCoolingControlPanelState extends State<PowerCoolingControlPanel>
    with TickerProviderStateMixin {
  int _selectedMode = 0; // 0=STANDARD, 1=MAX CRYO-FLOW, 2=EMERGENCY POWER SAVE
  late AnimationController _pulseCtrl;
  late AnimationController _rotateCtrl;

  final List<_CoolingMode> _modes = [
    _CoolingMode(
      label: 'STANDARD',
      icon: Icons.ac_unit,
      color: AppColors.cyberCyan,
      description: 'Pendingin beroperasi normal. Daya teroptimasi 65%.',
      stats: {'FAN RPM': '3,200', 'COOLANT FLOW': '12 L/min', 'DAYA': '65%', 'SUHU TARGET': '22°C'},
    ),
    _CoolingMode(
      label: 'MAX CRYO-FLOW',
      icon: Icons.severe_cold,
      color: const Color(0xFF00F0FF),
      description: 'Mode pendinginan maksimum. Semua pompa aktif penuh.',
      stats: {'FAN RPM': '6,800', 'COOLANT FLOW': '28 L/min', 'DAYA': '100%', 'SUHU TARGET': '16°C'},
    ),
    _CoolingMode(
      label: 'EMERGENCY POWER SAVE',
      icon: Icons.emergency,
      color: const Color(0xFFFF8F00),
      description: 'Mode hemat darurat. Hanya sistem kritikal aktif.',
      stats: {'FAN RPM': '1,800', 'COOLANT FLOW': '6 L/min', 'DAYA': '30%', 'SUHU TARGET': '28°C'},
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _rotateCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _rotateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mode = _modes[_selectedMode];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white.withValues(alpha: 0.92), AppColors.glassSurfaceDeep.withValues(alpha: 0.80)],
        ),
        border: Border.all(color: mode.color.withValues(alpha: 0.4), width: 1.2),
        boxShadow: [BoxShadow(color: mode.color.withValues(alpha: 0.12), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              gradient: LinearGradient(
                colors: [mode.color.withValues(alpha: 0.12), mode.color.withValues(alpha: 0.04)],
              ),
              border: Border(bottom: BorderSide(color: mode.color.withValues(alpha: 0.25))),
            ),
            child: Row(
              children: [
                AnimatedBuilder(
                  animation: _rotateCtrl,
                  builder: (_, child) => Transform.rotate(
                    angle: _rotateCtrl.value * 2 * 3.14159,
                    child: child,
                  ),
                  child: Icon(Icons.settings, color: mode.color, size: 20),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'COOLING & POWER MATRIX CONTROLLER',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary, letterSpacing: 0.8),
                  ),
                ),
                AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder: (_, _) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: mode.color.withValues(alpha: 0.1 + _pulseCtrl.value * 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: mode.color.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      'MODE AKTIF: ${mode.label}',
                      style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: mode.color, letterSpacing: 0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Mode selector buttons ────────────────────────────
                Row(
                  children: List.generate(_modes.length, (i) {
                    final m = _modes[i];
                    final isSelected = i == _selectedMode;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: i < _modes.length - 1 ? 8 : 0),
                        child: _ModeButton(
                          label: m.label,
                          icon: m.icon,
                          color: m.color,
                          isSelected: isSelected,
                          onTap: () => setState(() => _selectedMode = i),
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 14),

                // ── Description ──────────────────────────────────────
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    key: ValueKey(_selectedMode),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: mode.color.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: mode.color.withValues(alpha: 0.25)),
                    ),
                    child: Text(
                      mode.description,
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // ── Stats grid ───────────────────────────────────────
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Wrap(
                    key: ValueKey('stats_$_selectedMode'),
                    spacing: 10,
                    runSpacing: 10,
                    children: mode.stats.entries.map((e) => _StatTile(
                      label: e.key,
                      value: e.value,
                      color: mode.color,
                    )).toList(),
                  ),
                ),

                const SizedBox(height: 14),

                // ── Power bars ───────────────────────────────────────
                _PowerBar(label: 'UPS-1 PRIMER', pct: 1.00, color: AppColors.tniGreenNeon),
                const SizedBox(height: 8),
                _PowerBar(label: 'UPS-2 CADANGAN', pct: 0.94, color: AppColors.cyberCyan),
                const SizedBox(height: 8),
                _PowerBar(
                  label: 'GENSET DARURAT',
                  pct: _selectedMode == 2 ? 1.0 : 0.0,
                  color: const Color(0xFFFF8F00),
                  labelRight: _selectedMode == 2 ? 'AKTIF' : 'STANDBY',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mode button ──────────────────────────────────────────────────────────────
class _ModeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: isSelected
                ? LinearGradient(colors: [color.withValues(alpha: 0.20), color.withValues(alpha: 0.08)])
                : null,
            color: isSelected ? null : Colors.transparent,
            border: Border.all(
              color: isSelected ? color : AppColors.glassBorder.withValues(alpha: 0.4),
              width: isSelected ? 1.5 : 1.0,
            ),
            boxShadow: isSelected
                ? [BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 12)]
                : [],
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? color : AppColors.textMuted, size: 18),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? color : AppColors.textMuted,
                  letterSpacing: 0.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Stat tile ────────────────────────────────────────────────────────────────
class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatTile({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        width: 120,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 8, color: AppColors.textMuted, letterSpacing: 0.5)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color, fontFamily: 'monospace')),
          ],
        ),
      );
}

// ── Power bar ────────────────────────────────────────────────────────────────
class _PowerBar extends StatelessWidget {
  final String label;
  final double pct;
  final Color color;
  final String labelRight;

  const _PowerBar({required this.label, required this.pct, required this.color, this.labelRight = ''});

  @override
  Widget build(BuildContext context) {
    final display = labelRight.isNotEmpty ? labelRight : '${(pct * 100).toInt()}%';
    return Row(
      children: [
        SizedBox(
          width: 130,
          child: Text(label, style: const TextStyle(fontSize: 9.5, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 50,
          child: Text(
            display,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color, fontFamily: 'monospace'),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

// ── Data model ───────────────────────────────────────────────────────────────
class _CoolingMode {
  final String label;
  final IconData icon;
  final Color color;
  final String description;
  final Map<String, String> stats;

  const _CoolingMode({
    required this.label,
    required this.icon,
    required this.color,
    required this.description,
    required this.stats,
  });
}
