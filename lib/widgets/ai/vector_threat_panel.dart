import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../common/tactical_badge.dart';

class ThreatVectorDetail {
  final String title;
  final double score;
  final Color scoreColor;
  final String targetNode;
  final String originIp;
  final String geolocation;
  final String payloadHex;
  final String payloadAscii;
  final String mitigationLog;
  final String actionTaken;

  const ThreatVectorDetail({
    required this.title,
    required this.score,
    required this.scoreColor,
    required this.targetNode,
    required this.originIp,
    required this.geolocation,
    required this.payloadHex,
    required this.payloadAscii,
    required this.mitigationLog,
    required this.actionTaken,
  });
}

class VectorThreatPanel extends StatefulWidget {
  const VectorThreatPanel({super.key});

  @override
  State<VectorThreatPanel> createState() => _VectorThreatPanelState();
}

class _VectorThreatPanelState extends State<VectorThreatPanel> {
  int? _expandedIndex = 0; // Default open first threat

  static const List<ThreatVectorDetail> threats = [
    ThreatVectorDetail(
      title: "Brute-force SSH Gateway",
      score: 0.92,
      scoreColor: Color(0xFFDC2626),
      targetNode: "Kodam VI/Mulawarman (Gateway Sektor Timur)",
      originIp: "185.220.101.4",
      geolocation: "Tor Exit Node (Saint Petersburg, RU)",
      payloadHex: "0x4150543239205353482D322E302D4F70656E535348",
      payloadAscii: "SSH-2.0-OpenSSH_8.2p1 [CUSTOM DICTIONARY]",
      mitigationLog: "1.420 percobaan injeksi diblokir otomatis dalam 24 jam terakhir. Zero packet breach.",
      actionTaken: "IP diisolasi permanen di seluruh Kodam via eBPF XDP Filter.",
    ),
    ThreatVectorDetail(
      title: "Anomali DNS Taktis",
      score: 0.78,
      scoreColor: AppColors.merahVibrant,
      targetNode: "Pos Terdepan Natuna (Satgas Pamtas Laut)",
      originIp: "103.251.167.22",
      geolocation: "Fast-Flux Bulletproof Hosting (Hong Kong)",
      payloadHex: "0x7175657279207478742E6170742E63322E6E6574",
      payloadAscii: "query TXT apt.c2.net [BASE64 EXFILTRATION]",
      mitigationLog: "890 kueri mencurigakan di-sinkhole oleh AI DNS Firewall.",
      actionTaken: "Enkripsi DNS-over-HTTPS Post-Quantum diaktifkan paksa.",
    ),
    ThreatVectorDetail(
      title: "Malware Polymorphic Payload",
      score: 0.64,
      scoreColor: AppColors.cyberCyanDeep,
      targetNode: "Kodam XVII/Cenderawasih (Bunker Jayapura)",
      originIp: "45.154.255.89",
      geolocation: "Cloud Proxy (Frankfurt, DE)",
      payloadHex: "0x4D5A90000300000004000000FFFF0000B8000000",
      payloadAscii: "MZ... Obfuscated PE32 DLL Injector",
      mitigationLog: "AI Sandbox mendeteksi kemiripan AST 96.4% dengan signature APT-41.",
      actionTaken: "Payload dikarantina dan dianalisa reverse-engineering.",
    ),
    ThreatVectorDetail(
      title: "Protokol Routing BGP Hijack",
      score: 0.34,
      scoreColor: AppColors.warningAmber,
      targetNode: "Mabes Satber AD (Backbone Jakarta)",
      originIp: "AS4837 (Prefix 103.12.0.0/24)",
      geolocation: "Tier-1 Upstream Provider",
      payloadHex: "0x0202001E02060104A0B0C0D0",
      payloadAscii: "BGP UPDATE AS-Path Prepend Spoofing",
      mitigationLog: "Filter RPKI ROA menolak 14 pengumuman rute ilegal.",
      actionTaken: "BGP session di-switch otomatis ke link cadangan satelit.",
    ),
    ThreatVectorDetail(
      title: "Eksfiltrasi Data Satelit SAR",
      score: 0.18,
      scoreColor: AppColors.tniGreenMid,
      targetNode: "Stasiun Bumi Satkom Natuna (CAKRAWALA-3A)",
      originIp: "198.51.100.44",
      geolocation: "Intersepsi Frekuensi Gelombang Mikro",
      payloadHex: "0x5341525F454F5F444154415F4348554E4B",
      payloadAscii: "SAR_EO_DATA_CHUNK_UNENCRYPTED_PROBE",
      mitigationLog: "Upaya demodulasi gagal karena enkripsi Post-Quantum Kyber-1024 aktif.",
      actionTaken: "Frekuensi downlink digeser via frequency-hopping.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(threats.length, (index) {
        final threat = threats[index];
        final isExpanded = _expandedIndex == index;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isExpanded ? threat.scoreColor : AppColors.glassBorder.withValues(alpha: 0.35),
                width: isExpanded ? 1.5 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: isExpanded ? threat.scoreColor.withValues(alpha: 0.12) : const Color(0x080F1B2D),
                  blurRadius: isExpanded ? 10 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Column(
                children: [
                  // Header Row (Clickable)
                  InkWell(
                    onTap: () {
                      setState(() {
                        _expandedIndex = isExpanded ? null : index;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: threat.scoreColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  threat.title,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              Text(
                                "${(threat.score * 100).toInt()}%",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: threat.scoreColor,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: threat.score,
                              backgroundColor: const Color(0x1F0072FF),
                              valueColor: AlwaysStoppedAnimation(threat.scoreColor),
                              minHeight: 5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Expanded Tactical Forensic Drill-Down
                  if (isExpanded)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: threat.scoreColor.withValues(alpha: 0.04),
                        border: Border(
                          top: BorderSide(color: threat.scoreColor.withValues(alpha: 0.2), width: 1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow("SASARAN NODE", threat.targetNode, Icons.gps_fixed),
                          const SizedBox(height: 6),
                          _buildDetailRow("ORIGIN IP", "${threat.originIp} (${threat.geolocation})", Icons.public),
                          const SizedBox(height: 8),

                          // Payload Hex Box
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.35)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.code, size: 13, color: AppColors.merahVibrant),
                                    const SizedBox(width: 6),
                                    const Text("PAYLOAD HEX INTERSEPT:", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                                    const Spacer(),
                                    TacticalBadge(label: "SIGNATURE MATCH", type: threat.score > 0.7 ? BadgeType.critical : BadgeType.warning),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  threat.payloadHex,
                                  style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppColors.cyberCyanDeep, fontFamily: 'monospace'),
                                ),
                                Text(
                                  "ASCII: ${threat.payloadAscii}",
                                  style: const TextStyle(fontSize: 9, color: AppColors.textSecondary, fontFamily: 'monospace'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Mitigation History Log
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.tniGreenMid.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.tniGreenMid.withValues(alpha: 0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("STATUS MITIGASI OTOMATIS AI:", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.tniGreenMid)),
                                const SizedBox(height: 2),
                                Text(threat.mitigationLog, style: const TextStyle(fontSize: 10, color: AppColors.textPrimary)),
                                const SizedBox(height: 2),
                                Text("Aksi: ${threat.actionTaken}", style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: AppColors.merahVibrant)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text("$label: ", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
