import 'package:flutter/material.dart';
import '../state/command_center_controller.dart';
import '../core/theme/app_colors.dart';
import '../models/mobile_unit.dart';
import '../models/radio_transmission.dart';
import '../widgets/common/liquid_glass_card.dart';
import '../widgets/common/tactical_badge.dart';
import '../widgets/field_ops/mobile_c2_unit_card.dart';
import '../widgets/field_ops/tactical_radio_feed.dart';
import '../widgets/field_ops/emergency_dispatch_modal.dart';

class FieldOperationsView extends StatefulWidget {
  final CommandCenterController controller;

  const FieldOperationsView({super.key, required this.controller});

  @override
  State<FieldOperationsView> createState() => _FieldOperationsViewState();
}

class _FieldOperationsViewState extends State<FieldOperationsView> {
  late List<MobileUnit> _units;
  late List<RadioTransmission> _initialTransmissions;
  String? _lastBroadcastAlert;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    _units = [
      const MobileUnit(
        id: "UNIT-01",
        code: "SATGAS SIBER-01",
        name: "Satgas Siber Pamtas Laut Natuna",
        location: "Perbatasan Natuna Utara",
        coordinates: "03°54'N, 108°23'E",
        personnelCount: 6,
        personnelList: [
          UnitPersonnel(name: "Lettu Chb Rendy Pratama", rank: "Lettu", role: "Komandan Tim & SIGINT", callsign: "NAGA-01"),
          UnitPersonnel(name: "Serka Dwi Santoso", rank: "Serka", role: "Spesialis Intersepsi Frekuensi", callsign: "NAGA-02"),
          UnitPersonnel(name: "Sertu Aris Munandar", rank: "Sertu", role: "Analis Enkripsi Kuantum", callsign: "NAGA-03"),
          UnitPersonnel(name: "Praka Teguh Prasetyo", rank: "Praka", role: "Teknisi Uplink Satelit LEO", callsign: "NAGA-04"),
        ],
        task: "Pemantauan Jalur Komunikasi Bawah Laut & Radar Maritim",
        batteryLevel: 0.88,
        signalBars: 5,
        signalDbm: "-54 dBm",
        status: MobileUnitStatus.deployed,
        satcomUplink: "CAKRAWALA-3A [LOCK]",
      ),
      const MobileUnit(
        id: "UNIT-02",
        code: "SATGAS SIBER-02",
        name: "Satgas Siber Kodam VI/Mulawarman",
        location: "Bunker Komando Tarakan",
        coordinates: "03°20'N, 117°35'E",
        personnelCount: 4,
        personnelList: [
          UnitPersonnel(name: "Kapten Chb Fajar Nugroho", rank: "Kapten", role: "Koordinator Pertahanan Siber", callsign: "ELANG-01"),
          UnitPersonnel(name: "Serma Hendra Kusuma", rank: "Serma", role: "Firewall & Gateway Engineer", callsign: "ELANG-02"),
          UnitPersonnel(name: "Sertu Budi Wibowo", rank: "Sertu", role: "Intrusion Detection Operator", callsign: "ELANG-03"),
        ],
        task: "Hardening Firewall Gateway Sektor Timur & Counter-Malware",
        batteryLevel: 0.74,
        signalBars: 4,
        signalDbm: "-62 dBm",
        status: MobileUnitStatus.deployed,
        satcomUplink: "CAKRAWALA-2B [LOCK]",
      ),
      const MobileUnit(
        id: "UNIT-03",
        code: "SATGAS SIBER-03",
        name: "Satgas Pamtas Darat Jayapura",
        location: "Skouw - Sektor Timur Papua",
        coordinates: "02°36'S, 140°51'E",
        personnelCount: 8,
        personnelList: [
          UnitPersonnel(name: "Mayor Chb Ilham Syahputra", rank: "Mayor", role: "Dansatgas Siber Terpadu", callsign: "GARUDA-01"),
          UnitPersonnel(name: "Lettu Chb Anton Wijaya", rank: "Lettu", role: "Spesialis Radio Jammer & Triangulasi", callsign: "GARUDA-02"),
          UnitPersonnel(name: "Serka Rahmat Hidayat", rank: "Serka", role: "Forensik Perangkat Bergerak", callsign: "GARUDA-03"),
          UnitPersonnel(name: "Serda Agus Setiawan", rank: "Serda", role: "Operator Drone C2 Siber", callsign: "GARUDA-04"),
        ],
        task: "SIGINT, Intersepsi Radio Taktis Liar, & Monitoring Spektrum",
        batteryLevel: 0.62,
        signalBars: 4,
        signalDbm: "-68 dBm",
        status: MobileUnitStatus.deployed,
        satcomUplink: "MERAH-PUTIH-2 [LOCK]",
      ),
      const MobileUnit(
        id: "UNIT-04",
        code: "TIM RESPON CEPAT",
        name: "Tim Tanggap Insiden Siber Mabes TNI AD",
        location: "Mabes Satber AD Jakarta",
        coordinates: "06°10'S, 106°49'E",
        personnelCount: 12,
        personnelList: [
          UnitPersonnel(name: "Letkol Chb Dani Firmansyah", rank: "Letkol", role: "Kepala Tim Tanggap Darurat", callsign: "KOMANDO-01"),
          UnitPersonnel(name: "Mayor Chb Wahyu Pratomo", rank: "Mayor", role: "Lead Threat Hunter", callsign: "KOMANDO-02"),
          UnitPersonnel(name: "Kapten Chb Dian Permana", rank: "Kapten", role: "Reverse Malware Specialist", callsign: "KOMANDO-03"),
        ],
        task: "Triase Insiden Siber Nasional & Dukungan C2 Kontinjensi",
        batteryLevel: 0.96,
        signalBars: 5,
        signalDbm: "-42 dBm",
        status: MobileUnitStatus.standby,
        satcomUplink: "FIBER OPTIC HIGH-BW",
      ),
    ];

    _initialTransmissions = [
      const RadioTransmission(
        id: "TX-01",
        channel: RadioChannel.secure,
        callsign: "SATGAS-01 (NATUNA)",
        time: "15:28 WIB",
        frequency: "142.850 MHz [HOP-38]",
        message: "Koneksi uplink satelit LEO stabil. Sinyal radar SAR bebas noise gelombang mikro.",
        isEncrypted: true,
      ),
      const RadioTransmission(
        id: "TX-02",
        channel: RadioChannel.secure,
        callsign: "KODAM-XVII (PAPUA)",
        time: "15:26 WIB",
        frequency: "148.125 MHz [HOP-39]",
        message: "Firewall mengidentifikasi injeksi paket tak dikenal. AI triage berhasil memblokir seketika.",
        isEncrypted: true,
      ),
      const RadioTransmission(
        id: "TX-03",
        channel: RadioChannel.broadcast,
        callsign: "PUSKODAL MABES AD",
        time: "15:24 WIB",
        frequency: "156.400 MHz [BROADCAST]",
        message: "Seluruh jajaran: Tingkatkan status waspada ke level ELEVATED. Siapkan kontrameasur frekuensi.",
        isEncrypted: true,
        isEmergency: true,
      ),
    ];
  }

  void _openEmergencyDispatch() {
    showDialog(
      context: context,
      builder: (context) => EmergencyDispatchModal(
        units: _units,
        onDispatchSent: (target, directive, message) {
          setState(() {
            _lastBroadcastAlert = "PERINTAH TERKIRIM KE $target: $directive";
          });
        },
      ),
    );
  }

  void _handleUnitUpdated(MobileUnit updatedUnit) {
    setState(() {
      final index = _units.indexWhere((u) => u.id == updatedUnit.id);
      if (index != -1) {
        _units[index] = updatedUnit;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 980;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Top Emergency Tactical Dispatch Action Banner ────────────────
              _buildEmergencyDispatchBanner(),

              const SizedBox(height: 16),

              // ── Quick Telemetry Summary KPIs ─────────────────────────────────
              _buildTacticalSummaryKPIs(isMobile),

              const SizedBox(height: 16),

              // ── Main Content: Units Column + Radio Feed Column ───────────────
              if (isMobile) ...[
                _buildFieldUnitsPanel(),
                const SizedBox(height: 16),
                TacticalRadioFeed(initialTransmissions: _initialTransmissions),
              ] else ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 6,
                      child: _buildFieldUnitsPanel(),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 6,
                      child: TacticalRadioFeed(initialTransmissions: _initialTransmissions),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmergencyDispatchBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.merahVibrant.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.merahVibrant.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.merahVibrant.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.warning_amber_rounded, color: AppColors.merahVibrant, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      "PUSAT KOMANDO OPERASI LAPANGAN (MOBILE C2)",
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.merahVibrant.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        "DEFCON-2",
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppColors.merahVibrant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _lastBroadcastAlert ?? "Sistem radio taktis terenkripsi aktif. 4 Mobile C2 Units siap menerima transmisi perintah kilat.",
                  style: TextStyle(
                    fontSize: 11,
                    color: _lastBroadcastAlert != null ? AppColors.merahVibrant : AppColors.textSecondary,
                    fontWeight: _lastBroadcastAlert != null ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.merahVibrant,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 2,
            ),
            icon: const Icon(Icons.flash_on_rounded, size: 16),
            label: const Text(
              "KIRIM PERINTAH DARURAT",
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8),
            ),
            onPressed: _openEmergencyDispatch,
          ),
        ],
      ),
    );
  }

  Widget _buildTacticalSummaryKPIs(bool isMobile) {
    final activePersonnel = _units.fold<int>(0, (sum, u) => sum + u.personnelCount);
    final deployedUnits = _units.where((u) => u.status == MobileUnitStatus.deployed).length;

    final items = [
      _buildKpiCard("UNIT SIBER AKTIF", "$deployedUnits / ${_units.length} TIM", Icons.military_tech_rounded, AppColors.tniGreenMid),
      _buildKpiCard("TOTAL OPERATOR", "$activePersonnel PERSONEL", Icons.groups_rounded, AppColors.cyberCyanDeep),
      _buildKpiCard("PROTOKOL RADIO", "FREQ HOPPING", Icons.sync_alt_rounded, AppColors.cyberCyanDeep),
      _buildKpiCard("STATUS JARINGAN", "TERENKRIPSI 100%", Icons.lock_outline_rounded, AppColors.tniGreenNeon),
    ];

    if (isMobile) {
      return GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 2.2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: items,
      );
    }

    return Row(
      children: items.map((card) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: card))).toList(),
    );
  }

  Widget _buildKpiCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
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

  Widget _buildFieldUnitsPanel() {
    return LiquidGlassCard(
      title: "UNIT SIBER LAPANGAN AKTIF (MOBILE C2)",
      icon: Icons.groups_outlined,
      trailing: TacticalBadge(
        label: "${_units.length} TIM TERSEBAR",
        type: BadgeType.live,
      ),
      child: Column(
        children: [
          ..._units.map((unit) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: MobileC2UnitCard(
                unit: unit,
                onUnitUpdated: _handleUnitUpdated,
              ),
            );
          }),
        ],
      ),
    );
  }
}
