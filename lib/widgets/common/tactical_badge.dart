import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum BadgeType { live, security, warning, critical }

class TacticalBadge extends StatelessWidget {
  final String label;
  final BadgeType type;

  const TacticalBadge({
    super.key,
    required this.label,
    this.type = BadgeType.live,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    Color text;

    switch (type) {
      case BadgeType.live:
        bg = const Color(0x2639FF14);
        border = const Color(0x6639FF14);
        text = AppColors.tniGreenNeon;
        break;
      case BadgeType.security:
        bg = const Color(0x26D4AF37);
        border = const Color(0x66D4AF37);
        text = AppColors.goldInsignia;
        break;
      case BadgeType.warning:
        bg = const Color(0x26FFB300);
        border = const Color(0x66FFB300);
        text = AppColors.warningAmber;
        break;
      case BadgeType.critical:
        bg = const Color(0x33CC0001);
        border = const Color(0x80CC0001);
        text = const Color(0xFFFF4D4D);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: border, width: 0.8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: text,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}
