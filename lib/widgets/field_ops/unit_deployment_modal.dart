import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/mobile_unit.dart';

class UnitDeploymentModal extends StatefulWidget {
  final MobileUnit unit;
  final ValueChanged<MobileUnit>? onUnitUpdated;

  const UnitDeploymentModal({
    super.key,
    required this.unit,
    this.onUnitUpdated,
  });

  @override
  State<UnitDeploymentModal> createState() => _UnitDeploymentModalState();
}

class _UnitDeploymentModalState extends State<UnitDeploymentModal> {
  late MobileUnit _currentUnit;
  String _statusNotification = '';

  @override
  void initState() {
    super.initState();
    _currentUnit = widget.unit;
  }

  void _triggerAction(String actionName, MobileUnitStatus newStatus, String message) {
    setState(() {
      _currentUnit = _currentUnit.copyWith(status: newStatus);
      _statusNotification = message;
    });
    if (widget.onUnitUpdated != null) {
      widget.onUnitUpdated!(_currentUnit);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: 720,
        constraints: const BoxConstraints(maxHeight: 700),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cyberCyan.withValues(alpha: 0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.cyberCyan.withValues(alpha: 0.18),
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                border: Border(
                  bottom: BorderSide(color: AppColors.glassBorder.withValues(alpha: 0.4)),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.cyberCyan.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.cyberCyan.withValues(alpha: 0.4)),
                    ),
                    child: const Icon(Icons.shield_outlined, color: AppColors.cyberCyanDeep, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _currentUnit.code,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                                fontFamily: 'monospace',
                              ),
                            ),
                            const SizedBox(width: 10),
                            _buildStatusBadge(_currentUnit.status),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          "${_currentUnit.name} • ${_currentUnit.location}",
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
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
                    // Notification banner if action triggered
                    if (_statusNotification.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.cyberCyan.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.cyberCyan),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline, color: AppColors.cyberCyanDeep, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _statusNotification,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.cyberCyanDeep,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Telemetry Quick Stats
                    Row(
                      children: [
                        Expanded(
                          child: _buildTelemetryBox(
                            icon: Icons.battery_charging_full_rounded,
                            label: "BATERAI C2",
                            value: "${(_currentUnit.batteryLevel * 100).toInt()}%",
                            color: _currentUnit.batteryLevel > 0.4 ? AppColors.tniGreenMid : AppColors.merahVibrant,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTelemetryBox(
                            icon: Icons.wifi_tethering,
                            label: "SINYAL RF",
                            value: "${_currentUnit.signalBars}/5 (${_currentUnit.signalDbm})",
                            color: AppColors.cyberCyanDeep,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTelemetryBox(
                            icon: Icons.satellite_alt,
                            label: "UPLINK SATELIT",
                            value: _currentUnit.satcomUplink,
                            color: AppColors.tniGreenMid,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Mission Parameters
                    _buildSectionTitle("PARAMETER MISI AKTIF", Icons.flag_outlined),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.35)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Instruksi Taktis: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textPrimary)),
                              Expanded(
                                child: Text(
                                  _currentUnit.task,
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 16, color: Color(0x1F0072FF)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "GPS: ${_currentUnit.coordinates}",
                                style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: AppColors.cyberCyanDeep, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "Enkripsi: ${_currentUnit.encryptionStandard}",
                                style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: AppColors.tniGreenMid, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Personnel Roster
                    _buildSectionTitle("DAFTAR PERSONEL OPERATOR (${_currentUnit.personnelList.length} OPERATOR)", Icons.group_outlined),
                    const SizedBox(height: 8),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _currentUnit.personnelList.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final person = _currentUnit.personnelList[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.25)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: AppColors.tniGreenMid.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.tniGreenMid.withValues(alpha: 0.3)),
                                ),
                                child: Center(
                                  child: Text(
                                    person.rank.substring(0, 2).toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                      color: AppColors.tniGreenMid,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${person.rank} ${person.name}",
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textPrimary),
                                    ),
                                    Text(
                                      person.role,
                                      style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0x1100C6FF),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppColors.cyberCyan.withValues(alpha: 0.4)),
                                ),
                                child: Text(
                                  "CALLSIGN: ${person.callsign}",
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.cyberCyanDeep,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Command Actions
                    _buildSectionTitle("AKSI KOMANDO TAKTIS", Icons.touch_app_outlined),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.cyberCyanDeep,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.navigation_outlined, size: 16),
                            label: const Text("REDEPLOY UNIT", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
                            onPressed: () {
                              _triggerAction(
                                "REDEPLOY",
                                MobileUnitStatus.redeploying,
                                "Instruksi redeploy dikirim ke ${_currentUnit.code}. Unit dalam perjalanan koordinat baru.",
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.merahVibrant,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.replay_rounded, size: 16),
                            label: const Text("PERINTAHKAN RECALL", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
                            onPressed: () {
                              _triggerAction(
                                "RECALL",
                                MobileUnitStatus.standby,
                                "Perintah recall dikeluarkan. ${_currentUnit.code} diarahkan kembali ke Pangkalan Utama.",
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.tniGreenMid,
                              side: const BorderSide(color: AppColors.tniGreenMid, width: 1.2),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: const Icon(Icons.send_to_mobile_rounded, size: 16),
                            label: const Text("KIRIM PAYLOAD", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
                            onPressed: () {
                              _triggerAction(
                                "PAYLOAD",
                                _currentUnit.status,
                                "Payload enkripsi baru dan hash patch ditransmisikan via Satcom Cakrawala-3A.",
                              );
                            },
                          ),
                        ),
                      ],
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

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.cyberCyanDeep),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTelemetryBox({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontFamily: 'monospace',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(MobileUnitStatus status) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case MobileUnitStatus.deployed:
        bg = const Color(0x1F1CB96B);
        fg = AppColors.tniGreenNeon;
        label = "DEPLOYED";
        break;
      case MobileUnitStatus.redeploying:
        bg = const Color(0x1F00C6FF);
        fg = AppColors.cyberCyanDeep;
        label = "REDEPLOYING";
        break;
      case MobileUnitStatus.standby:
        bg = const Color(0x1FFF8F00);
        fg = AppColors.warningAmber;
        label = "STANDBY";
        break;
      case MobileUnitStatus.emergency:
        bg = const Color(0x1FE8001A);
        fg = AppColors.merahVibrant;
        label = "EMERGENCY";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: fg.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: fg, letterSpacing: 0.6),
      ),
    );
  }
}
