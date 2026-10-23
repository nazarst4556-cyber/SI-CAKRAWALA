import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Full-screen diagnostic modal for a single sensor node.
/// Shows voltage/temperature curves, power log stream, and control actions.
class SensorDiagnosticsModal extends StatefulWidget {
  final String sensorName;
  final String sensorDetail;
  final String status;
  final IconData icon;
  final Color accentColor;

  const SensorDiagnosticsModal({
    super.key,
    required this.sensorName,
    required this.sensorDetail,
    required this.status,
    required this.icon,
    required this.accentColor,
  });

  @override
  State<SensorDiagnosticsModal> createState() => _SensorDiagnosticsModalState();
}

class _SensorDiagnosticsModalState extends State<SensorDiagnosticsModal>
    with TickerProviderStateMixin {
  final Random _rng = Random();
  late AnimationController _pulseCtrl;
  late List<String> _logs;
  late List<double> _voltHistory;
  late List<double> _tempHistory;
  String _actionStatus = '';

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _voltHistory = List.generate(30, (_) => 395 + _rng.nextDouble() * 10);
    _tempHistory = List.generate(30, (_) => 19 + _rng.nextDouble() * 4);

    _logs = [
      '[${_ts()}] SISTEM SENSOR DIINISIALISASI',
      '[${_ts()}] PROTOKOL ENKRIPSI AES-256 AKTIF',
      '[${_ts()}] SELF-DIAGNOSTIC SELESAI — TIDAK ADA KESALAHAN',
      '[${_ts()}] ${widget.sensorName}: ${widget.status}',
      '[${_ts()}] LAPORAN KESEHATAN DIKIRIM KE MABES SATSIBER',
    ];
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  String _ts() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  }

  void _addLog(String msg) {
    setState(() {
      _logs.add('[${_ts()}] $msg');
      if (_logs.length > 50) _logs.removeAt(0);
    });
  }

  void _rebootUnit() {
    setState(() => _actionStatus = 'REBOOT DIMULAI…');
    _addLog('!! UNIT KONTROL REBOOT DIINISIASI OLEH OPERATOR');
    _addLog('MENGHENTIKAN PROSES AKTIF…');
    Future.delayed(const Duration(seconds: 1), () {
      _addLog('PROSES DIHENTIKAN. MEMULAI URUTAN BOOT…');
    });
    Future.delayed(const Duration(seconds: 2), () {
      _addLog('UNIT KONTROL ONLINE KEMBALI. STATUS: ${widget.status}');
      setState(() => _actionStatus = '');
    });
  }

  void _switchBackupPower() {
    setState(() => _actionStatus = 'BERALIH KE DAYA CADANGAN…');
    _addLog('!! SWITCHING KE UPS-2 BACKUP POWER');
    _addLog('MEMVALIDASI TEGANGAN UPS-2: 399.8V ✓');
    Future.delayed(const Duration(seconds: 2), () {
      _addLog('DAYA CADANGAN AKTIF. TEGANGAN: 400.0V 3-Phase STABIL');
      setState(() => _actionStatus = '');
    });
  }

  void _runDiagnostic() {
    _addLog('>> MENJALANKAN DIAGNOSTIK MENDALAM…');
    Future.delayed(const Duration(milliseconds: 600), () {
      _addLog('[SCAN] CPU: OK | RAM: OK | STORAGE: OK');
      _addLog('[SCAN] ENKRIPSI: AES-256-GCM AKTIF');
      _addLog('[SCAN] JARINGAN: LATENSI 8ms — NORMAL');
      _addLog('[OK] DIAGNOSTIK SELESAI — TIDAK ADA ANCAMAN TERDETEKSI');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: 780,
        constraints: const BoxConstraints(maxHeight: 680),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5F9FF), Color(0xFFE8F4FF)],
          ),
          border: Border.all(color: widget.accentColor.withValues(alpha: 0.4), width: 1.5),
          boxShadow: [
            BoxShadow(color: widget.accentColor.withValues(alpha: 0.20), blurRadius: 40, spreadRadius: 4),
            const BoxShadow(color: Color(0x1A000000), blurRadius: 20),
          ],
        ),
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                gradient: LinearGradient(
                  colors: [widget.accentColor.withValues(alpha: 0.15), widget.accentColor.withValues(alpha: 0.05)],
                ),
                border: Border(bottom: BorderSide(color: widget.accentColor.withValues(alpha: 0.3))),
              ),
              child: Row(
                children: [
                  AnimatedBuilder(
                    animation: _pulseCtrl,
                    builder: (_, _) => Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: widget.accentColor.withValues(alpha: 0.1 + _pulseCtrl.value * 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: widget.accentColor.withValues(alpha: 0.4)),
                        boxShadow: [BoxShadow(color: widget.accentColor.withValues(alpha: _pulseCtrl.value * 0.4), blurRadius: 12)],
                      ),
                      child: Icon(widget.icon, color: widget.accentColor, size: 22),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DIAGNOSTIK SENSOR',
                          style: TextStyle(fontSize: 9, color: widget.accentColor, letterSpacing: 1.5, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.sensorName,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                  _StatusChip(status: widget.status, color: widget.accentColor),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    color: AppColors.textSecondary,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // ── Body ──────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info tiles
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: widget.sensorDetail
                          .split('•')
                          .map((s) => _InfoChip(label: s.trim(), color: widget.accentColor))
                          .toList(),
                    ),

                    const SizedBox(height: 18),

                    // Charts row
                    Row(
                      children: [
                        Expanded(
                          child: _MiniChart(
                            title: 'TEGANGAN (V)',
                            data: _voltHistory,
                            color: widget.accentColor,
                            unit: 'V',
                            minRange: 390,
                            maxRange: 410,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _MiniChart(
                            title: 'SUHU UNIT (°C)',
                            data: _tempHistory,
                            color: const Color(0xFFFF8F00),
                            unit: '°C',
                            minRange: 15,
                            maxRange: 30,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Action buttons
                    if (_actionStatus.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF8F00).withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFF8F00).withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 14, height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF8F00)),
                            ),
                            const SizedBox(width: 10),
                            Text(_actionStatus, style: const TextStyle(fontSize: 11, color: Color(0xFFFF8F00), fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),

                    Row(
                      children: [
                        _ActionButton(
                          label: 'REBOOT KONTROL UNIT',
                          icon: Icons.restart_alt,
                          color: const Color(0xFFFF2A37),
                          onTap: _rebootUnit,
                        ),
                        const SizedBox(width: 10),
                        _ActionButton(
                          label: 'SWITCH BACKUP POWER',
                          icon: Icons.bolt,
                          color: const Color(0xFFFF8F00),
                          onTap: _switchBackupPower,
                        ),
                        const SizedBox(width: 10),
                        _ActionButton(
                          label: 'JALANKAN DIAGNOSTIK',
                          icon: Icons.search,
                          color: widget.accentColor,
                          onTap: _runDiagnostic,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Log stream
                    _SectionLabel(label: 'LOG SISTEM REAL-TIME', color: widget.accentColor),
                    const SizedBox(height: 8),
                    Container(
                      height: 160,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A0E1A),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: widget.accentColor.withValues(alpha: 0.25)),
                      ),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(10),
                        itemCount: _logs.length,
                        reverse: true,
                        itemBuilder: (_, i) {
                          final log = _logs[_logs.length - 1 - i];
                          final isWarning = log.contains('!!');
                          return Text(
                            log,
                            style: TextStyle(
                              fontSize: 9.5,
                              fontFamily: 'monospace',
                              color: isWarning ? const Color(0xFFFF8F00) : const Color(0xFF00C6FF).withValues(alpha: 0.85),
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
}

// ── Mini chart widget ────────────────────────────────────────────────────────
class _MiniChart extends StatelessWidget {
  final String title;
  final List<double> data;
  final Color color;
  final String unit;
  final double minRange;
  final double maxRange;

  const _MiniChart({
    required this.title,
    required this.data,
    required this.color,
    required this.unit,
    required this.minRange,
    required this.maxRange,
  });

  @override
  Widget build(BuildContext context) {
    final latest = data.isNotEmpty ? data.last : 0.0;
    return Container(
      height: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: color, letterSpacing: 0.8)),
              const Spacer(),
              Text(
                '${latest.toStringAsFixed(1)} $unit',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color, fontFamily: 'monospace'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: CustomPaint(
              painter: _SimpleSparkline(data: data, color: color, min: minRange, max: maxRange),
              size: Size.infinite,
            ),
          ),
        ],
      ),
    );
  }
}

class _SimpleSparkline extends CustomPainter {
  final List<double> data;
  final Color color;
  final double min;
  final double max;

  const _SimpleSparkline({required this.data, required this.color, required this.min, required this.max});

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
      final p = pts[i - 1];
      final c = pts[i];
      path.cubicTo((p.dx + c.dx) / 2, p.dy, (p.dx + c.dx) / 2, c.dy, c.dx, c.dy);
    }
    canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 1.5..strokeCap = StrokeCap.round);
    // Fill
    final fill = Path.from(path)
      ..lineTo(pts.last.dx, size.height)
      ..lineTo(pts.first.dx, size.height)
      ..close();
    canvas.drawPath(fill, Paint()..shader = LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [color.withValues(alpha: 0.25), color.withValues(alpha: 0)],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(_SimpleSparkline old) => old.data != data;
}

// ── Helper widgets ───────────────────────────────────────────────────────────
class _StatusChip extends StatelessWidget {
  final String status;
  final Color color;
  const _StatusChip({required this.status, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
      );
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;
  const _InfoChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Text(label, style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
      );
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: color.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  colors: [color.withValues(alpha: 0.10), color.withValues(alpha: 0.04)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Icon(icon, color: color, size: 18),
                  const SizedBox(height: 4),
                  Text(label, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color, letterSpacing: 0.5), textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ),
      );
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _SectionLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(width: 3, height: 14, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color, letterSpacing: 1.0)),
        ],
      );
}
