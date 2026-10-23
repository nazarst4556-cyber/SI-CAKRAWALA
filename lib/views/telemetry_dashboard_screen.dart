import 'package:flutter/material.dart';
import '../state/command_center_controller.dart';
import '../core/theme/app_colors.dart';
import '../widgets/telemetry/telemetry_metric_card.dart';
import '../widgets/telemetry/sensor_dialog_modal.dart';
import '../widgets/telemetry/power_cooling_control_panel.dart';
import '../models/telemetry_metric.dart';
import '../widgets/common/tactical_badge.dart';

/// Production-ready Telemetry & Hardware Infrastructure screen for SI-CAKRAWALA.
class TelemetryDashboardScreen extends StatefulWidget {
  final CommandCenterController controller;

  const TelemetryDashboardScreen({super.key, required this.controller});

  @override
  State<TelemetryDashboardScreen> createState() => _TelemetryDashboardScreenState();
}

class _TelemetryDashboardScreenState extends State<TelemetryDashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _criticalAlertCtrl;

  static const _metricIcons = [
    Icons.memory_rounded,
    Icons.developer_board_rounded,
    Icons.storage_rounded,
    Icons.satellite_alt_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _criticalAlertCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _criticalAlertCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final metrics = widget.controller.metrics;
        final hasCriticalMetric = metrics.any((m) => (m.value / m.maxValue) >= 0.90);
        final criticalMetric = metrics.firstWhere(
          (m) => (m.value / m.maxValue) >= 0.90,
          orElse: () => metrics.last,
        );

        return LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 920;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Critical Pulsing Alert Banner if any metric > 90% ────────
                  if (hasCriticalMetric) ...[
                    _buildCriticalWarningBanner(criticalMetric),
                    const SizedBox(height: 14),
                  ],

                  // ── Section Title ──────────────────────────────────────────
                  _buildSectionHeader(),
                  const SizedBox(height: 12),

                  // ── Dynamic Hardware Telemetry Cards Grid ──────────────────
                  if (isMobile)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: metrics.length,
                      itemBuilder: (_, i) => TelemetryMetricCard(
                        metric: metrics[i],
                        icon: _metricIcons[i % _metricIcons.length],
                      ),
                    )
                  else
                    Row(
                      children: List.generate(metrics.length, (i) {
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: i < metrics.length - 1 ? 12 : 0),
                            child: TelemetryMetricCard(
                              metric: metrics[i],
                              icon: _metricIcons[i % _metricIcons.length],
                            ),
                          ),
                        );
                      }),
                    ),

                  const SizedBox(height: 20),

                  // ── Sensor Array & Power/Cooling Matrix (Responsive) ───────
                  if (isMobile)
                    Column(
                      children: const [
                        _SensorArrayListView(),
                        SizedBox(height: 16),
                        PowerCoolingControlPanel(),
                      ],
                    )
                  else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Expanded(flex: 5, child: _SensorArrayListView()),
                        SizedBox(width: 16),
                        Expanded(flex: 5, child: PowerCoolingControlPanel()),
                      ],
                    ),

                  const SizedBox(height: 20),

                  // ── Network I/O Matrix Grid ─────────────────────────────────
                  _NetworkIOMatrix(controller: widget.controller),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCriticalWarningBanner(TelemetryMetric metric) {
    return AnimatedBuilder(
      animation: _criticalAlertCtrl,
      builder: (context, child) {
        final alertOpacity = 0.85 + _criticalAlertCtrl.value * 0.15;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0F2),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.merahVibrant.withValues(alpha: alertOpacity),
              width: 1.6,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.merahVibrant.withValues(alpha: 0.2 * _criticalAlertCtrl.value),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.merahVibrant.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber_rounded, color: AppColors.merahVibrant, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          "PERINGATAN AMBANG KRITIS TELEMETRI HARDWARE",
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.merahVibrant,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.merahVibrant,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            "${metric.name}: ${metric.value.toStringAsFixed(1)}${metric.unit}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      "Kapasitas melewati 90.0%. Sistem merekomendasikan kompresi kuantum & failover transponder satelit cadangan.",
                      style: TextStyle(fontSize: 10.5, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.merahVibrant,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  elevation: 0,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Protokol mitigasi kompresi otomatis diaktifkan untuk transponder satelit."),
                      backgroundColor: AppColors.merahVibrant,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: const Text("MITIGASI FAILOVER", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.cyberCyan.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.cyberCyan.withValues(alpha: 0.4)),
          ),
          child: const Icon(Icons.monitor_heart_rounded, color: AppColors.cyberCyanDeep, size: 20),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "MONITOR SUMBER DAYA & INFRASTRUKTUR TAKTIS",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.6,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              "Telemetri komputasi real-time, sensor shelter bunker, matriks daya & I/O jaringan 60 detik",
              style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Sensor Array List View ──────────────────────────────────────────────────
class _SensorArrayListView extends StatelessWidget {
  const _SensorArrayListView();

  static const List<_SensorItemData> _sensorList = [
    _SensorItemData(
      name: "SHELTER BUNKER SERVER UTAMA",
      detail: "Suhu: 21.2°C • Kelembapan: 48% RH • Daya UPS-1: 100%",
      status: "OPTIMAL",
      icon: Icons.dns_rounded,
      color: AppColors.tniGreenNeon,
    ),
    _SensorItemData(
      name: "GENSET CADANGAN TAKTIS",
      detail: "Tegangan: 400V 3-Phase • Frekuensi: 50.0Hz • Solar: 94%",
      status: "STANDBY",
      icon: Icons.bolt_rounded,
      color: AppColors.cyberCyan,
    ),
    _SensorItemData(
      name: "DETEKTOR INTERFERENSI FREKUENSI (JAMMING)",
      detail: "Spektrum HF/VHF/UHF • Tidak ada sinyal liar",
      status: "TERLINDUNGI",
      icon: Icons.wifi_tethering_error_rounded,
      color: AppColors.tniGreenNeon,
    ),
    _SensorItemData(
      name: "SENSOR KELEMBAPAN & SUHU RUANGAN",
      detail: "Suhu: 22.1°C • Kelembapan: 46% RH • CO₂: 412 ppm",
      status: "NORMAL",
      icon: Icons.thermostat_rounded,
      color: AppColors.cyberCyan,
    ),
    _SensorItemData(
      name: "KONTROL AKSES FISIK BIOMETRIK",
      detail: "Sidik Jari: AKTIF • Retina Scanner: ONLINE • Pintu: TERKUNCI",
      status: "AMAN",
      icon: Icons.fingerprint_rounded,
      color: AppColors.tniGreenNeon,
    ),
    _SensorItemData(
      name: "SENSOR SMOKE & FIRE SUPPRESSION",
      detail: "Detektor Asap: NORMAL • Sistem Halon: SIAP • Sprinkler: SIAP",
      status: "SIAP",
      icon: Icons.local_fire_department_rounded,
      color: AppColors.tniGreenNeon,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F1B2D),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              border: Border(bottom: BorderSide(color: AppColors.glassBorder.withValues(alpha: 0.35))),
            ),
            child: Row(
              children: const [
                Icon(Icons.sensors_rounded, color: AppColors.cyberCyanDeep, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "ARRAY SENSOR PERTAHANAN & SHELTER SERVER",
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                TacticalBadge(label: "SEMUA NORMAL", type: BadgeType.live),
              ],
            ),
          ),

          // Sensor Items List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            itemCount: _sensorList.length,
            separatorBuilder: (context, index) => Divider(
              color: AppColors.glassBorder.withValues(alpha: 0.3),
              height: 14,
            ),
            itemBuilder: (context, index) {
              final sensor = _sensorList[index];
              return _SensorTileItem(sensor: sensor);
            },
          ),
        ],
      ),
    );
  }
}

class _SensorTileItem extends StatefulWidget {
  final _SensorItemData sensor;
  const _SensorTileItem({required this.sensor});

  @override
  State<_SensorTileItem> createState() => _SensorTileItemState();
}

class _SensorTileItemState extends State<_SensorTileItem> {
  bool _isHovered = false;

  void _openDiagnostics(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SensorDialogModal(
        sensorName: widget.sensor.name,
        sensorDetail: widget.sensor.detail,
        status: widget.sensor.status,
        icon: widget.sensor.icon,
        accentColor: widget.sensor.color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sensor = widget.sensor;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _openDiagnostics(context),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: _isHovered ? sensor.color.withValues(alpha: 0.08) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _isHovered ? sensor.color.withValues(alpha: 0.4) : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: sensor.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: sensor.color.withValues(alpha: 0.3)),
                  ),
                  child: Icon(sensor.icon, color: sensor.color, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sensor.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sensor.detail,
                        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TacticalBadge(label: sensor.status, type: BadgeType.live),
                    if (_isHovered) ...[
                      const SizedBox(height: 4),
                      Text(
                        "INSPEKSI ▶",
                        style: TextStyle(fontSize: 8, color: sensor.color, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Network I/O Matrix Grid ─────────────────────────────────────────────────
class _NetworkIOMatrix extends StatelessWidget {
  final CommandCenterController controller;

  const _NetworkIOMatrix({required this.controller});

  @override
  Widget build(BuildContext context) {
    // Current dynamic values or tactical defaults
    final inbound = controller.inboundTraffic.last;
    final attack = controller.attackTraffic.last;
    final blocked = controller.blockedTraffic.last;

    final trafficCards = [
      _NetworkTrafficMetric(
        label: "INBOUND TRAFFIC",
        value: "${inbound.toStringAsFixed(1)} Gbps",
        progress: (inbound / 100.0).clamp(0.0, 1.0),
        color: AppColors.cyberCyanDeep,
        icon: Icons.cloud_download_rounded,
      ),
      _NetworkTrafficMetric(
        label: "ATTACK TRAFFIC",
        value: "${attack.toStringAsFixed(1)} Gbps",
        progress: (attack / 50.0).clamp(0.0, 1.0),
        color: AppColors.merahVibrant,
        icon: Icons.shield_outlined,
      ),
      _NetworkTrafficMetric(
        label: "BLOCKED / MITIGATED",
        value: "${blocked.toStringAsFixed(1)} Gbps",
        progress: (blocked / 50.0).clamp(0.0, 1.0),
        color: AppColors.tniGreenNeon,
        icon: Icons.verified_user_rounded,
      ),
      _NetworkTrafficMetric(
        label: "LATENCY AVG",
        value: "11.2 ms",
        progress: 0.112,
        color: AppColors.goldInsignia,
        icon: Icons.speed_rounded,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F1B2D),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              border: Border(bottom: BorderSide(color: AppColors.glassBorder.withValues(alpha: 0.35))),
            ),
            child: Row(
              children: const [
                Icon(Icons.network_check_rounded, color: AppColors.cyberCyanDeep, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "MATRIKS I/O JARINGAN SATSIBER (HIGH-THROUGHPUT BANDWIDTH)",
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  "ENKRIPSI: AES-256-GCM / Post-Quantum Kyber-1024",
                  style: TextStyle(fontSize: 9.5, fontFamily: 'monospace', color: AppColors.tniGreenMid, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 720;
                if (isNarrow) {
                  return Column(
                    children: trafficCards.map((card) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildTrafficBox(card),
                    )).toList(),
                  );
                }
                return Row(
                  children: trafficCards.map((card) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: card == trafficCards.last ? 0 : 12),
                      child: _buildTrafficBox(card),
                    ),
                  )).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrafficBox(_NetworkTrafficMetric metric) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: metric.color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: metric.color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(metric.icon, color: metric.color, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  metric.label,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: metric.color,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            metric.value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: metric.color,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: metric.progress,
              backgroundColor: metric.color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation(metric.color),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }
}

class _NetworkTrafficMetric {
  final String label;
  final String value;
  final double progress;
  final Color color;
  final IconData icon;

  const _NetworkTrafficMetric({
    required this.label,
    required this.value,
    required this.progress,
    required this.color,
    required this.icon,
  });
}

class _SensorItemData {
  final String name;
  final String detail;
  final String status;
  final IconData icon;
  final Color color;

  const _SensorItemData({
    required this.name,
    required this.detail,
    required this.status,
    required this.icon,
    required this.color,
  });
}
