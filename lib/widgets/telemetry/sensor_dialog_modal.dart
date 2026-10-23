import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Reusable diagnostic popup for deep hardware and sensor inspection.
class SensorDialogModal extends StatefulWidget {
  final String sensorName;
  final String sensorDetail;
  final String status;
  final IconData icon;
  final Color accentColor;

  const SensorDialogModal({
    super.key,
    required this.sensorName,
    required this.sensorDetail,
    required this.status,
    required this.icon,
    this.accentColor = AppColors.cyberCyanDeep,
  });

  @override
  State<SensorDialogModal> createState() => _SensorDialogModalState();
}

class _SensorDialogModalState extends State<SensorDialogModal>
    with SingleTickerProviderStateMixin {
  final Random _rng = Random();
  late AnimationController _pulseController;
  late List<String> _systemLogs;
  late List<double> _voltagePoints;
  late List<double> _temperaturePoints;
  String _operationalActionStatus = '';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _voltagePoints = List.generate(32, (_) => 396.0 + _rng.nextDouble() * 8.0);
    _temperaturePoints = List.generate(32, (_) => 20.0 + _rng.nextDouble() * 4.5);

    _systemLogs = [
      "[${_currentTime()}] INTI MODUL SENSOR DIINISIALISASI SECARA PENUH",
      "[${_currentTime()}] SALURAN TELEMETRI TERENKRIPSI: AES-256-GCM / KYBER-1024",
      "[${_currentTime()}] KALIBRASI SENSOR TINGKAT PRESISI SELESAI — LOSS 0.00%",
      "[${_currentTime()}] STATUS SENSOR: ${widget.sensorName} -> ${widget.status}",
      "[${_currentTime()}] MONITORING STABILITAS TEGANGAN 3-PHASE AKTIF",
    ];
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _currentTime() {
    final now = DateTime.now();
    return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
  }

  void _pushLog(String msg) {
    setState(() {
      _systemLogs.add("[${_currentTime()}] $msg");
      if (_systemLogs.length > 50) _systemLogs.removeAt(0);
    });
  }

  void _rebootUnit() {
    setState(() => _operationalActionStatus = "MEMULAI PROSEDUR REBOOT KONTROL UNIT...");
    _pushLog("!! INSTRUKSI REBOOT DITERIMA DARI OPERATOR KONSOL");
    _pushLog("MENONAKTIFKAN SUB-SISTEM SENSOR SEMENTARA...");

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        _pushLog("MEMUAT ULANG FIRMWARE MILITER V4.9...");
      }
    });

    Future.delayed(const Duration(milliseconds: 2400), () {
      if (mounted) {
        _pushLog("UNIT SENSOR KEMBALI ONLINE DENGAN SUKSES. STATUS: NORMAL.");
        setState(() => _operationalActionStatus = "");
      }
    });
  }

  void _switchBackupPower() {
    setState(() => _operationalActionStatus = "BERALIH KE CATU DAYA CADANGAN (UPS-2)...");
    _pushLog("!! OVERRIDE SAKELAR DAYA: BERALIH DARI JALA-JALA UTAMA KE UPS-2");
    _pushLog("MEMERIKSA TEGANGAN RELAY CADANGAN: 400.2V STABIL ✓");

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        _pushLog("DAYA CADANGAN AKTIF PENUH. EFISIENSI INVERTER: 99.4%.");
        setState(() => _operationalActionStatus = "");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: 760,
        constraints: const BoxConstraints(maxHeight: 680),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: widget.accentColor.withValues(alpha: 0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: widget.accentColor.withValues(alpha: 0.2),
              blurRadius: 32,
              spreadRadius: 2,
            ),
            const BoxShadow(
              color: Color(0x18000000),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Modal Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                border: Border(bottom: BorderSide(color: AppColors.glassBorder.withValues(alpha: 0.4))),
              ),
              child: Row(
                children: [
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: widget.accentColor.withValues(alpha: 0.12 + _pulseController.value * 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: widget.accentColor.withValues(alpha: 0.4)),
                        ),
                        child: Icon(widget.icon, color: widget.accentColor, size: 22),
                      );
                    },
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.sensorName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 10),
                            _buildStatusPill(widget.status, widget.accentColor),
                          ],
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          "Pusat Pemantauan Fisik & Sensor Bunker Satber TNI AD",
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Modal Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sensor Parameters
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: widget.sensorDetail
                          .split('•')
                          .map((detail) => _buildDetailChip(detail.trim(), widget.accentColor))
                          .toList(),
                    ),

                    const SizedBox(height: 18),

                    // Telemetry Visualizer: Voltage & Temperature Charts
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricGraphBox(
                            title: "STABILITAS TEGANGAN (V)",
                            currentValue: "${_voltagePoints.last.toStringAsFixed(1)} V",
                            data: _voltagePoints,
                            color: widget.accentColor,
                            minVal: 390.0,
                            maxVal: 410.0,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildMetricGraphBox(
                            title: "SUHU INTI SENSOR (°C)",
                            currentValue: "${_temperaturePoints.last.toStringAsFixed(1)} °C",
                            data: _temperaturePoints,
                            color: const Color(0xFFFF8F00),
                            minVal: 15.0,
                            maxVal: 35.0,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Operational Action Banner
                    if (_operationalActionStatus.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF8F00).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFF8F00)),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF8F00)),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _operationalActionStatus,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF8F00),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Emergency Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.merahVibrant,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: 1,
                            ),
                            icon: const Icon(Icons.restart_alt_rounded, size: 16),
                            label: const Text(
                              "REBOOT KONTROL UNIT",
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.6),
                            ),
                            onPressed: _rebootUnit,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF8F00),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: 1,
                            ),
                            icon: const Icon(Icons.bolt_rounded, size: 16),
                            label: const Text(
                              "SWITCH BACKUP POWER",
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.6),
                            ),
                            onPressed: _switchBackupPower,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Real-time System Log
                    const Text(
                      "LOG SISTEM REAL-TIME (SECURE SHELTER CONSOLE)",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary, letterSpacing: 0.6),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 140,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.4)),
                      ),
                      child: ListView.builder(
                        itemCount: _systemLogs.length,
                        reverse: true,
                        itemBuilder: (context, index) {
                          final log = _systemLogs[_systemLogs.length - 1 - index];
                          final isWarn = log.contains("!!");
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              log,
                              style: TextStyle(
                                fontSize: 10,
                                fontFamily: 'monospace',
                                color: isWarn ? const Color(0xFFFF8F00) : const Color(0xFF00C6FF),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.35)),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildMetricGraphBox({
    required String title,
    required String currentValue,
    required List<double> data,
    required Color color,
    required double minVal,
    required double maxVal,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
              ),
              Text(
                currentValue,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color, fontFamily: 'monospace'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 54,
            child: CustomPaint(
              painter: _MiniSparklinePainter(data: data, color: color, min: minVal, max: maxVal),
              size: Size.infinite,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _MiniSparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;
  final double min;
  final double max;

  const _MiniSparklinePainter({
    required this.data,
    required this.color,
    required this.min,
    required this.max,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;
    final range = (max - min).clamp(1.0, double.infinity);
    final pts = <Offset>[];

    for (int i = 0; i < data.length; i++) {
      final x = i / (data.length - 1) * size.width;
      final y = size.height - ((data[i] - min) / range * size.height).clamp(0, size.height);
      pts.add(Offset(x, y));
    }

    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      final prev = pts[i - 1];
      final curr = pts[i];
      path.cubicTo((prev.dx + curr.dx) / 2, prev.dy, (prev.dx + curr.dx) / 2, curr.dy, curr.dx, curr.dy);
    }

    // Line
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, paint);

    // Gradient Fill
    final fillPath = Path.from(path)
      ..lineTo(pts.last.dx, size.height)
      ..lineTo(pts.first.dx, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(_MiniSparklinePainter oldDelegate) => oldDelegate.data != data;
}
