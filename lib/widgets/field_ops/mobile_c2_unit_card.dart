import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/mobile_unit.dart';
import 'unit_deployment_modal.dart';

class MobileC2UnitCard extends StatefulWidget {
  final MobileUnit unit;
  final ValueChanged<MobileUnit>? onUnitUpdated;

  const MobileC2UnitCard({
    super.key,
    required this.unit,
    this.onUnitUpdated,
  });

  @override
  State<MobileC2UnitCard> createState() => _MobileC2UnitCardState();
}

class _MobileC2UnitCardState extends State<MobileC2UnitCard> {
  bool _isHovered = false;

  void _openDetails() {
    showDialog(
      context: context,
      builder: (context) => UnitDeploymentModal(
        unit: widget.unit,
        onUnitUpdated: widget.onUnitUpdated,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unit = widget.unit;
    final isBatteryLow = unit.batteryLevel < 0.3;
    final batteryColor = isBatteryLow ? AppColors.merahVibrant : AppColors.tniGreenMid;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: _isHovered ? 0.98 : 0.88),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _isHovered ? AppColors.cyberCyanDeep : AppColors.glassBorder.withValues(alpha: 0.35),
            width: _isHovered ? 1.4 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered ? AppColors.cyberCyan.withValues(alpha: 0.2) : const Color(0x0A0F1B2D),
              blurRadius: _isHovered ? 12 : 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: _openDetails,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Icon + Code + Location + Status Badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _isHovered ? AppColors.cyberCyan.withValues(alpha: 0.15) : AppColors.tniGreenMid.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _isHovered ? AppColors.cyberCyan.withValues(alpha: 0.5) : AppColors.tniGreenMid.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Icon(
                          Icons.security_rounded,
                          color: _isHovered ? AppColors.cyberCyanDeep : AppColors.tniGreenMid,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  unit.code,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: AppColors.cyberCyanDeep,
                                    fontFamily: 'monospace',
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "(${unit.personnelCount} Operator)",
                                  style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              unit.location,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                      ),
                      _buildStatusPill(unit.status),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Mission Task
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0x060072FF),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0x120072FF)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.radar_rounded, size: 14, color: AppColors.cyberCyanDeep),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            unit.task,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Bottom Telemetry Bar: GPS, Battery, Signal, Detail CTA
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // GPS Coordinates
                      Row(
                        children: [
                          const Icon(Icons.place_outlined, size: 13, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            unit.coordinates,
                            style: const TextStyle(
                              fontSize: 10,
                              fontFamily: 'monospace',
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),

                      // Battery & Signal
                      Row(
                        children: [
                          Icon(Icons.battery_std_rounded, size: 14, color: batteryColor),
                          const SizedBox(width: 3),
                          Text(
                            "${(unit.batteryLevel * 100).toInt()}%",
                            style: TextStyle(
                              fontSize: 10,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              color: batteryColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(Icons.signal_cellular_alt_rounded, size: 14, color: AppColors.cyberCyanDeep),
                          const SizedBox(width: 3),
                          Text(
                            "${unit.signalBars}/5",
                            style: const TextStyle(
                              fontSize: 10,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              color: AppColors.cyberCyanDeep,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Tap indicator
                          Row(
                            children: [
                              Text(
                                "DETAIL",
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  color: _isHovered ? AppColors.cyberCyanDeep : AppColors.textMuted,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                size: 14,
                                color: _isHovered ? AppColors.cyberCyanDeep : AppColors.textMuted,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusPill(MobileUnitStatus status) {
    Color bg;
    Color fg;
    String text;

    switch (status) {
      case MobileUnitStatus.deployed:
        bg = const Color(0x1F1CB96B);
        fg = AppColors.tniGreenNeon;
        text = "DEPLOYED";
        break;
      case MobileUnitStatus.redeploying:
        bg = const Color(0x1F00C6FF);
        fg = AppColors.cyberCyanDeep;
        text = "REDEPLOYING";
        break;
      case MobileUnitStatus.standby:
        bg = const Color(0x1FFF8F00);
        fg = AppColors.warningAmber;
        text = "STANDBY";
        break;
      case MobileUnitStatus.emergency:
        bg = const Color(0x1FE8001A);
        fg = AppColors.merahVibrant;
        text = "EMERGENCY";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: fg.withValues(alpha: 0.4)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: fg,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
