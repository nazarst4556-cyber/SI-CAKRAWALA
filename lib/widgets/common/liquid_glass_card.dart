import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class LiquidGlassCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final IconData? icon;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final double? width;

  const LiquidGlassCard({
    super.key,
    required this.child,
    this.title,
    this.icon,
    this.trailing,
    this.padding,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F1B2D),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
          BoxShadow(
            color: Color(0x0A00C6FF),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.glassSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.35), width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0x1200C6FF), Color(0x060072FF)],
                      ),
                      border: Border(
                        bottom: BorderSide(color: Color(0x2400C6FF), width: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        if (icon != null) ...[
                          Icon(icon, size: 16, color: AppColors.merahVibrant),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            title!,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: 0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        ?trailing,
                      ],
                    ),
                  ),
                Padding(
                  padding: padding ?? const EdgeInsets.all(12),
                  child: child,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
