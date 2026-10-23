import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/telemetry_metric.dart';
import 'sparkline_painter.dart';

/// Advanced telemetry metric card with animated sparkline, threshold color shift,
/// radial progress arc, and live pulse indicator.
class TelemetryMetricCard extends StatefulWidget {
  final TelemetryMetric metric;
  final IconData icon;

  const TelemetryMetricCard({
    super.key,
    required this.metric,
    required this.icon,
  });

  @override
  State<TelemetryMetricCard> createState() => _TelemetryMetricCardState();
}

class _TelemetryMetricCardState extends State<TelemetryMetricCard>
    with TickerProviderStateMixin {
  late AnimationController _scanCtrl;
  late Animation<double> _scanAnim;
  late AnimationController _flashCtrl;

  @override
  void initState() {
    super.initState();
    _scanCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _scanAnim = Tween<double>(begin: 0.0, end: 1.0).animate(_scanCtrl);

    _flashCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanCtrl.dispose();
    _flashCtrl.dispose();
    super.dispose();
  }

  Color _getLineColor(double pct) {
    if (pct >= 0.90) return const Color(0xFFFF2A37);
    if (pct >= 0.70) return const Color(0xFFFF8F00);
    return AppColors.cyberCyan;
  }

  Color _getStatusColor(double pct) {
    if (pct >= 0.90) return const Color(0xFFFF2A37);
    if (pct >= 0.70) return const Color(0xFFFF8F00);
    return AppColors.tniGreenNeon;
  }

  String _getStatusLabel(double pct, String original) {
    if (pct >= 0.90) return 'KRITIS';
    if (pct >= 0.70) return 'TINGGI';
    return original;
  }

  @override
  Widget build(BuildContext context) {
    final pct = (widget.metric.value / widget.metric.maxValue).clamp(0.0, 1.0);
    final lineColor = _getLineColor(pct);
    final statusColor = _getStatusColor(pct);
    final statusLabel = _getStatusLabel(pct, widget.metric.status);

    final isCritical = pct >= 0.90;

    return AnimatedBuilder(
      animation: Listenable.merge([_scanAnim, _flashCtrl]),
      builder: (context, _) {
        final borderPulseColor = isCritical
            ? lineColor.withValues(alpha: 0.4 + _flashCtrl.value * 0.6)
            : lineColor.withValues(alpha: 0.45);
        final glowPulseOpacity = isCritical
            ? (0.2 + _flashCtrl.value * 0.3)
            : 0.15;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.92),
                isCritical
                    ? const Color(0xFFFFF0F2).withValues(alpha: 0.9)
                    : AppColors.glassSurfaceDeep.withValues(alpha: 0.80),
              ],
            ),
            border: Border.all(
              color: borderPulseColor,
              width: isCritical ? 1.8 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: lineColor.withValues(alpha: glowPulseOpacity),
                blurRadius: isCritical ? 24 : 20,
                spreadRadius: isCritical ? 2 : 1,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header row ──────────────────────────────────────────
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: lineColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: lineColor.withValues(alpha: 0.3)),
                      ),
                      child: Icon(widget.icon, color: lineColor, size: 16),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        widget.metric.name,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.9,
                        ),
                      ),
                    ),
                    // Live pulse dot
                    _PulseDot(color: statusColor),
                  ],
                ),

                const SizedBox(height: 10),

                // ── Value + Arc ──────────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Radial arc
                    SizedBox(
                      width: 52,
                      height: 52,
                      child: CustomPaint(
                        painter: _ArcPainter(pct: pct, color: lineColor),
                        child: Center(
                          child: Text(
                            pct >= 0.995 ? '100' : (pct * 100).toStringAsFixed(0),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: lineColor,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Value text
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: widget.metric.value.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: lineColor,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              TextSpan(
                                text: widget.metric.unit,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: statusColor.withValues(alpha: 0.35)),
                          ),
                          child: Text(
                            statusLabel,
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // ── Sparkline ────────────────────────────────────────────
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.textPrimary.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: widget.metric.history.isNotEmpty
                        ? CustomPaint(
                            painter: SparklinePainter(
                              data: widget.metric.history,
                              lineColor: lineColor,
                              fillColorTop: lineColor,
                              criticalThreshold: 0.90,
                              animValue: _scanAnim.value,
                            ),
                          )
                        : Center(
                            child: Text(
                              'MEMUAT DATA...',
                              style: TextStyle(fontSize: 8, color: AppColors.textMuted),
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 6),

                // ── Linear bar ──────────────────────────────────────────
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: lineColor.withValues(alpha: 0.10),
                    valueColor: AlwaysStoppedAnimation(lineColor),
                    minHeight: 3,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Radial arc painter ──────────────────────────────────────────────────────
class _ArcPainter extends CustomPainter {
  final double pct;
  final Color color;

  const _ArcPainter({required this.pct, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const double strokeW = 5.0;
    final rect = Rect.fromLTWH(strokeW / 2, strokeW / 2,
        size.width - strokeW, size.height - strokeW);

    // Background track
    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 2.35, 4.71, false, bgPaint);

    // Value arc
    final fgGlow = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW + 4
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5.0);
    canvas.drawArc(rect, 2.35, pct * 4.71, false, fgGlow);

    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 2.35, pct * 4.71, false, fgPaint);
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.pct != pct || old.color != color;
}

// ── Pulse dot ───────────────────────────────────────────────────────────────
class _PulseDot extends StatefulWidget {
  final Color color;
  const _PulseDot({required this.color});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, _) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color.withValues(alpha: _anim.value),
          boxShadow: [
            BoxShadow(color: widget.color.withValues(alpha: _anim.value * 0.6), blurRadius: 6, spreadRadius: 1),
          ],
        ),
      ),
    );
  }
}
