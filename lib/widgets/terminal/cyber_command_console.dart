import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../state/command_center_controller.dart';
import 'command_manual_modal.dart';

enum TerminalLogType {
  prompt,
  info,
  success,
  warning,
  critical,
  system,
}

class TerminalLine {
  final String text;
  final TerminalLogType type;
  final DateTime timestamp;

  TerminalLine({
    required this.text,
    this.type = TerminalLogType.info,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class CyberCommandConsole extends StatefulWidget {
  final CommandCenterController controller;
  final double height;
  final bool isFullscreen;
  final VoidCallback? onExitFullscreen;

  const CyberCommandConsole({
    super.key,
    required this.controller,
    this.height = 360,
    this.isFullscreen = false,
    this.onExitFullscreen,
  });

  @override
  State<CyberCommandConsole> createState() => _CyberCommandConsoleState();
}

class _CyberCommandConsoleState extends State<CyberCommandConsole>
    with SingleTickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  late final FocusNode _focusNode;
  final ScrollController _scrollController = ScrollController();

  // Command History Navigation Stack
  final List<String> _history = [];
  int _historyIndex = -1;

  // Auto-complete candidates
  static const List<String> _autocompleteCommands = [
    'status',
    'status --node all',
    'scan',
    'scan --sector natuna',
    'scan --sector papua',
    'isolate',
    'isolate --ip 185.220.101.4',
    'cipher',
    'cipher --rotate',
    'blockchain',
    'blockchain --verify',
    'satellite',
    'satellite --fleet',
    'ai',
    'ai --diagnostics',
    'help',
    'man',
    'man status',
    'man scan',
    'man isolate',
    'man cipher',
    'clear',
  ];

  // Output Buffer
  late List<TerminalLine> _lines;

  // Blinking block cursor
  late AnimationController _cursorBlinkCtrl;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(onKeyEvent: (node, event) {
      if (event is KeyDownEvent) {
        if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
          _navigateHistory(true);
          return KeyEventResult.handled;
        } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
          _navigateHistory(false);
          return KeyEventResult.handled;
        } else if (event.logicalKey == LogicalKeyboardKey.tab) {
          _handleTabCompletion();
          return KeyEventResult.handled;
        }
      }
      return KeyEventResult.ignored;
    });
    _focusNode.addListener(() {
      if (mounted) setState(() {});
    });

    _cursorBlinkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    )..repeat(reverse: true);

    _lines = [
      TerminalLine(
        text: "SI-CAKRAWALA MILITARY LINUX KERNEL v5.14.9-TNI-AD [TOP SECRET // SEC-CLEARANCE 5]",
        type: TerminalLogType.system,
      ),
      TerminalLine(
        text: "Sistem Terhubung: 15 Node Kodam PBFT Konsensus 100% Aktif | Enkripsi: Post-Quantum Kyber-1024",
        type: TerminalLogType.success,
      ),
      TerminalLine(
        text: "Ketik 'help' atau klik [ BUKU PANDUAN PERINTAH ] untuk melihat katalog direktif taktis.",
        type: TerminalLogType.info,
      ),
    ];
  }

  @override
  void dispose() {
    _cursorBlinkCtrl.dispose();
    _inputController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _openCommandManual() {
    showDialog(
      context: context,
      builder: (context) => CommandManualModal(
        onSelectCommand: (cmd) {
          _inputController.text = cmd;
          _focusNode.requestFocus();
        },
      ),
    );
  }

  void _toggleFullscreen() {
    if (widget.isFullscreen) {
      if (widget.onExitFullscreen != null) {
        widget.onExitFullscreen!();
      } else {
        Navigator.of(context).pop();
      }
    } else {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: CyberCommandConsole(
            controller: widget.controller,
            isFullscreen: true,
            height: MediaQuery.of(context).size.height * 0.90,
            onExitFullscreen: () => Navigator.of(context).pop(),
          ),
        ),
      );
    }
  }

  void _handleTabCompletion() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    final match = _autocompleteCommands.firstWhere(
      (c) => c.startsWith(text.toLowerCase()) && c != text.toLowerCase(),
      orElse: () => '',
    );

    if (match.isNotEmpty) {
      setState(() {
        _inputController.text = match;
        _inputController.selection = TextSelection.fromPosition(
          TextPosition(offset: match.length),
        );
      });
    }
  }

  void _navigateHistory(bool previous) {
    if (_history.isEmpty) return;
    setState(() {
      if (previous) {
        if (_historyIndex == -1) {
          _historyIndex = _history.length - 1;
        } else if (_historyIndex > 0) {
          _historyIndex--;
        }
      } else {
        if (_historyIndex != -1) {
          if (_historyIndex < _history.length - 1) {
            _historyIndex++;
          } else {
            _historyIndex = -1;
            _inputController.clear();
            return;
          }
        }
      }
      if (_historyIndex >= 0 && _historyIndex < _history.length) {
        _inputController.text = _history[_historyIndex];
        _inputController.selection = TextSelection.fromPosition(
          TextPosition(offset: _inputController.text.length),
        );
      }
    });
  }



  void _executeCommand(String rawCommand) {
    final cmd = rawCommand.trim();
    if (cmd.isEmpty) return;

    // Add to history
    _history.add(cmd);
    _historyIndex = -1;

    // Print command line
    _lines.add(TerminalLine(
      text: "satsiber@cakrawala-c2-sec5:~\$ $cmd",
      type: TerminalLogType.prompt,
    ));

    final parts = cmd.toLowerCase().split(' ');
    final root = parts[0];

    switch (root) {
      case "help":
        _printHelp();
        break;

      case "clear":
        _lines.clear();
        break;

      case "status":
        _handleStatus(cmd);
        break;

      case "scan":
        _handleScan(cmd);
        break;

      case "isolate":
        _handleIsolate(cmd);
        break;

      case "cipher":
        _handleCipher(cmd);
        break;

      case "blockchain":
        _handleBlockchain(cmd);
        break;

      case "satellite":
        _handleSatellite(cmd);
        break;

      case "ai":
        _handleAi(cmd);
        break;

      case "man":
        _handleMan(parts);
        break;

      default:
        _lines.add(TerminalLine(
          text: "bash: perintah tidak dikenali: '$cmd'. Ketik 'help' atau buka [ BUKU PANDUAN PERINTAH ].",
          type: TerminalLogType.critical,
        ));
    }

    _inputController.clear();
    _scrollToBottom();
    setState(() {});
  }

  void _printHelp() {
    _lines.addAll([
      TerminalLine(text: "╔══════════════════════════════════════════════════════════════════════════╗", type: TerminalLogType.system),
      TerminalLine(text: "║            KATALOG PERINTAH OPERASI SIBER TAKTIS (CHEAT SHEET)          ║", type: TerminalLogType.system),
      TerminalLine(text: "╠══════════════════════════════════════════════════════════════════════════╣", type: TerminalLogType.system),
      TerminalLine(text: "  status [--node all]     : Inspeksi kesehatan 15 Kodam node & latensi", type: TerminalLogType.info),
      TerminalLine(text: "  scan --sector <nama>    : Vulnerability sweep sektor (natuna, papua, dll)", type: TerminalLogType.info),
      TerminalLine(text: "  isolate --ip <address>  : Blokir otonom IP penyerang dengan konsensus BFT", type: TerminalLogType.info),
      TerminalLine(text: "  cipher --rotate         : Rotasi darurat kunci sesi Post-Quantum Kyber-1024", type: TerminalLogType.info),
      TerminalLine(text: "  blockchain --verify     : Validasi integritas cryptographic Merkle tree", type: TerminalLogType.info),
      TerminalLine(text: "  satellite --fleet       : Telemetri armada satelit CAKRAWALA LEO/GEO", type: TerminalLogType.info),
      TerminalLine(text: "  ai --diagnostics        : Diagnostik akurasi neural engine & waktu inferensi", type: TerminalLogType.info),
      TerminalLine(text: "  man <perintah>          : Tampilkan dokumentasi buku panduan perintah", type: TerminalLogType.info),
      TerminalLine(text: "  clear                   : Bersihkan riwayat tampilan konsol", type: TerminalLogType.info),
      TerminalLine(text: "╚══════════════════════════════════════════════════════════════════════════╝", type: TerminalLogType.system),
    ]);
  }

  void _handleStatus(String cmd) {
    if (cmd.contains("--node all")) {
      _lines.addAll([
        TerminalLine(text: "[VERIFIKASI] MEMINDAI 15 KODAM VALIDATOR NODE...", type: TerminalLogType.system),
        TerminalLine(text: "  ✓ KODAM I/BB      (MEDAN)      : ONLINE [Latensi 12ms | Blok #48,274]", type: TerminalLogType.success),
        TerminalLine(text: "  ✓ KODAM II/SWJ    (PALEMBANG)  : ONLINE [Latensi 10ms | Blok #48,274]", type: TerminalLogType.success),
        TerminalLine(text: "  ✓ KODAM JAYA      (JAKARTA)    : ONLINE [Latensi 4ms  | Blok #48,274]", type: TerminalLogType.success),
        TerminalLine(text: "  ✓ KODAM III/SLW   (BANDUNG)    : ONLINE [Latensi 6ms  | Blok #48,274]", type: TerminalLogType.success),
        TerminalLine(text: "  ✓ KODAM IV/DIP    (SEMARANG)   : ONLINE [Latensi 8ms  | Blok #48,274]", type: TerminalLogType.success),
        TerminalLine(text: "  ✓ KODAM V/BRW     (SURABAYA)   : ONLINE [Latensi 9ms  | Blok #48,274]", type: TerminalLogType.success),
        TerminalLine(text: "  ✓ KODAM VI/MLW    (BALIKPAPAN) : ONLINE [Latensi 14ms | Blok #48,274]", type: TerminalLogType.success),
        TerminalLine(text: "  ✓ KODAM IX/UDY    (DENPASAR)   : ONLINE [Latensi 11ms | Blok #48,274]", type: TerminalLogType.success),
        TerminalLine(text: "  ✓ KODAM XII/TPR   (PONTIANAK)  : ONLINE [Latensi 15ms | Blok #48,274]", type: TerminalLogType.success),
        TerminalLine(text: "  ✓ KODAM XIII/MDK  (MANADO)     : ONLINE [Latensi 16ms | Blok #48,274]", type: TerminalLogType.success),
        TerminalLine(text: "  ✓ KODAM XIV/HSN   (MAKASSAR)   : ONLINE [Latensi 13ms | Blok #48,274]", type: TerminalLogType.success),
        TerminalLine(text: "  ✓ KODAM XVI/PTM   (AMBON)      : ONLINE [Latensi 18ms | Blok #48,274]", type: TerminalLogType.success),
        TerminalLine(text: "  ✓ KODAM XVII/CEN  (JAYAPURA)   : ONLINE [Latensi 22ms | Blok #48,274]", type: TerminalLogType.success),
        TerminalLine(text: "  ✓ KODAM XVIII/KSR (MANOKWARI)  : ONLINE [Latensi 24ms | Blok #48,274]", type: TerminalLogType.success),
        TerminalLine(text: "  ✓ PUSKODAL MABES  (CILANGKAP)  : MASTER [Latensi 1ms  | Blok #48,274]", type: TerminalLogType.success),
        TerminalLine(text: "[OK] 15/15 Node Kodam mencapai konsensus PBFT 100%. Tidak ada fork terdeteksi.", type: TerminalLogType.success),
      ]);
    } else {
      _lines.addAll([
        TerminalLine(text: "[SISTEM] GATEWAY CAKRAWALA: NORMAL | STATUS OPERASIONAL: 100% HIJAU", type: TerminalLogType.success),
        TerminalLine(text: "Enkripsi: AES-256-GCM / Kyber-1024 | Throughput Rata-rata: 73.3 Gbps", type: TerminalLogType.info),
        TerminalLine(text: "Node Kodam: 15/15 Sinkron. Gunakan 'status --node all' untuk rincian tiap Kodam.", type: TerminalLogType.info),
      ]);
    }
  }

  void _handleScan(String cmd) {
    final sector = cmd.contains("--sector")
        ? cmd.substring(cmd.indexOf("--sector") + 8).trim()
        : "Seluruh Sektor";

    _lines.addAll([
      TerminalLine(text: ">> MEMULAI DEEP VULNERABILITY SWEEP: [SEKTOR ${sector.toUpperCase()}]...", type: TerminalLogType.system),
      TerminalLine(text: "Memindai 65,535 Port, Gateway Satelit, & Jalur Fiber Laut...", type: TerminalLogType.info),
      TerminalLine(text: "  ✓ Port 22 (SSH Top-Secret): Dilindungi Kyber Session Key", type: TerminalLogType.success),
      TerminalLine(text: "  ✓ Port 443 (Satcom C2 Telemetri): TLS 1.3 Terverifikasi", type: TerminalLogType.success),
      TerminalLine(text: "  ✓ Port 8080 (Blockchain BFT RPC): Dilithium Signature Valid", type: TerminalLogType.success),
      TerminalLine(text: "[SELESAI] 0 Kerentanan Kritis Terdeteksi. Pertahanan Sektor ${sector.toUpperCase()} Kokoh.", type: TerminalLogType.success),
    ]);
  }

  void _handleIsolate(String cmd) {
    final ipMatch = RegExp(r'\b(?:\d{1,3}\.){3}\d{1,3}\b').firstMatch(cmd);
    final targetIp = ipMatch != null ? ipMatch.group(0)! : "185.220.101.4";

    _lines.addAll([
      TerminalLine(text: "!! PROTOKOL ISOLASI ANCAMAN SIBER DIAKTIFKAN !!", type: TerminalLogType.warning),
      TerminalLine(text: "Target IP: $targetIp -> Mengajukan voting konsensus darurat ke 15 Kodam...", type: TerminalLogType.warning),
      TerminalLine(text: "15/15 Kodam Validator menyetujui isolasi seketika (Konsensus 100%).", type: TerminalLogType.success),
      TerminalLine(text: ">> [FIREWALL OTONOM] Rute $targetIp dimasukkan ke tabel DROP Blacklist Nasional.", type: TerminalLogType.critical),
      TerminalLine(text: "[SUKSES] Seluruh paket dari $targetIp telah dinetralkan dan diisolasi.", type: TerminalLogType.success),
    ]);
  }

  void _handleCipher(String cmd) {
    _lines.addAll([
      TerminalLine(text: ">> MEMICU ROTASI DARURAT KUNCI SESI ENKRIPSI KUANTUM...", type: TerminalLogType.system),
      TerminalLine(text: "Membangkitkan pasangan kunci baru: Post-Quantum Kyber-1024 / Dilithium-5...", type: TerminalLogType.info),
      TerminalLine(text: "Hash Sidik Kunci Baru: 0x9f4a8b11c0de7d21... (Tervalidasi NIST PQC)", type: TerminalLogType.system),
      TerminalLine(text: "Mendistribusikan kunci baru ke 15 Kodam via transponder CAKRAWALA-3A...", type: TerminalLogType.info),
      TerminalLine(text: "[SUKSES] Rotasi kunci selesai dalam 124ms. Kanal komunikasi aman 100%.", type: TerminalLogType.success),
    ]);
  }

  void _handleBlockchain(String cmd) {
    _lines.addAll([
      TerminalLine(text: ">> AUDIT INTEGRITAS LEDGER BLOCKCHAIN PBFT...", type: TerminalLogType.system),
      TerminalLine(text: "Tinggi Blok: #48,274 | Transaksi: 1,247,832 TX | Konsensus: 100%", type: TerminalLogType.info),
      TerminalLine(text: "Pohon Merkle Root: 0x88c1e29f0012bb40... [SESUAI]", type: TerminalLogType.success),
      TerminalLine(text: "Dilithium-5 Tanda Tangan Digital Validator: [TERVERIFIKASI ASLI]", type: TerminalLogType.success),
      TerminalLine(text: "[VERIFIED] Buku besar militer tidak mengalami perusakan atau tamper.", type: TerminalLogType.success),
    ]);
  }

  void _handleSatellite(String cmd) {
    _lines.addAll([
      TerminalLine(text: ">> TELEMETRI ARMADA SATELIT CAKRAWALA TNI AD:", type: TerminalLogType.system),
      TerminalLine(text: "  1. CAKRAWALA-3A : LEO-520km (SAR Radar) | STATUS: LOCK NATUNA | RES: 0.3m/px", type: TerminalLogType.critical),
      TerminalLine(text: "  2. MERAH-PUTIH-2: GEO-36,000km (Satcom) | STATUS: LINK OPTIMAL | SNR: 28.4 dB", type: TerminalLogType.success),
      TerminalLine(text: "  3. CAKRAWALA-2B : GEO-35,786km (SIGINT)  | STATUS: ENCRYPTED   | RES: N/A", type: TerminalLogType.info),
      TerminalLine(text: "  4. CAKRAWALA-1C : LEO-610km (Optikal)   | STATUS: SURVEILLANCE| RES: 0.5m/px", type: TerminalLogType.info),
    ]);
  }

  void _handleAi(String cmd) {
    _lines.addAll([
      TerminalLine(text: ">> DIAGNOSTIK AI NEURAL THREAT ENGINE v9.4:", type: TerminalLogType.system),
      TerminalLine(text: "  • Akurasi Klasifikasi Serangan : 98.4%", type: TerminalLogType.success),
      TerminalLine(text: "  • Waktu Inferensi Rata-rata   : 3.8 ms", type: TerminalLogType.success),
      TerminalLine(text: "  • Synaptic Firing Active Nodes: 1,024 Nodes (Loss: 0.0014)", type: TerminalLogType.info),
      TerminalLine(text: "  • Mode Operasional Saat Ini   : AUTONOMOUS MITIGATION", type: TerminalLogType.system),
    ]);
  }

  void _handleMan(List<String> parts) {
    if (parts.length < 2) {
      _lines.add(TerminalLine(
        text: "Gunakan: man <nama_perintah> (Contoh: man isolate, man scan, man status).",
        type: TerminalLogType.warning,
      ));
      return;
    }

    final targetCmd = parts[1];
    switch (targetCmd) {
      case "status":
        _lines.addAll([
          TerminalLine(text: "MANUAL: STATUS(1) — Ringkasan Kondisi Sistem & Node Kodam", type: TerminalLogType.system),
          TerminalLine(text: "SINTAKS: status [--node all | <node_id>]", type: TerminalLogType.info),
          TerminalLine(text: "DESKRIPSI: Memindai kesehatan gateway militer dan status 15 Kodam validator.", type: TerminalLogType.info),
        ]);
        break;
      case "isolate":
        _lines.addAll([
          TerminalLine(text: "MANUAL: ISOLATE(1) — Protokol Karantina Darurat IP Penyerang", type: TerminalLogType.system),
          TerminalLine(text: "SINTAKS: isolate --ip <alamat_ip>", type: TerminalLogType.info),
          TerminalLine(text: "DESKRIPSI: Memicu pemungutan suara BFT konsensus untuk memblokir IP musuh.", type: TerminalLogType.info),
        ]);
        break;
      case "scan":
        _lines.addAll([
          TerminalLine(text: "MANUAL: SCAN(1) — Vulnerability Sweep Pertahanan Siber", type: TerminalLogType.system),
          TerminalLine(text: "SINTAKS: scan --sector <nama_sektor>", type: TerminalLogType.info),
          TerminalLine(text: "DESKRIPSI: Memindai kerentanan port dan transmisi satelit pada sektor target.", type: TerminalLogType.info),
        ]);
        break;
      case "cipher":
        _lines.addAll([
          TerminalLine(text: "MANUAL: CIPHER(1) — Manajemen Kunci Post-Quantum Kyber-1024", type: TerminalLogType.system),
          TerminalLine(text: "SINTAKS: cipher --rotate", type: TerminalLogType.info),
          TerminalLine(text: "DESKRIPSI: Memperbarui pasangan kunci kriptografi sesi di seluruh terminal.", type: TerminalLogType.info),
        ]);
        break;
      default:
        _lines.add(TerminalLine(
          text: "Halaman manual untuk '$targetCmd' tidak ditemukan. Klik tombol [ BUKU PANDUAN PERINTAH ] untuk katalog lengkap.",
          type: TerminalLogType.warning,
        ));
    }
  }

  Color _getLineColor(TerminalLogType type) {
    switch (type) {
      case TerminalLogType.prompt:
        return AppColors.goldInsignia;
      case TerminalLogType.success:
        return const Color(0xFF06D6A0); // Emerald Green
      case TerminalLogType.warning:
        return const Color(0xFFFFD166); // Amber
      case TerminalLogType.critical:
        return const Color(0xFFD90429); // Critical Red
      case TerminalLogType.system:
        return const Color(0xFF00F0FF); // Cyan
      case TerminalLogType.info:
        return const Color(0xFFE2E8F0); // Off-White
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF030712), // Dark military terminal background
        borderRadius: BorderRadius.circular(widget.isFullscreen ? 16 : 12),
        border: Border.all(
          color: widget.isFullscreen ? AppColors.cyberCyan : AppColors.glassBorder.withValues(alpha: 0.5),
          width: widget.isFullscreen ? 1.8 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.isFullscreen ? const Color(0x4400C6FF) : const Color(0x1F00C6FF),
            blurRadius: widget.isFullscreen ? 32 : 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.isFullscreen ? 15 : 11),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Terminal Header Bar ─────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                border: Border(bottom: BorderSide(color: AppColors.glassBorder.withValues(alpha: 0.3))),
              ),
              child: Row(
                children: [
                  // Window dots
                  Row(
                    children: [
                      Container(width: 10, height: 10, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFF5F56))),
                      const SizedBox(width: 6),
                      Container(width: 10, height: 10, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFFBD2E))),
                      const SizedBox(width: 6),
                      Container(width: 10, height: 10, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF27C93F))),
                    ],
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.terminal_rounded, size: 16, color: AppColors.cyberCyan),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.isFullscreen
                          ? "KONSOL KOMANDO SIBER [FULLSCREEN C2 OPERATIONAL VIEW] — bash v5.2"
                          : "KONSOL KOMANDO SIBER — bash v5.2",
                      style: GoogleFonts.orbitron(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.8,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Integrated Manual Handbook Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      foregroundColor: AppColors.cyberCyan,
                      side: BorderSide(color: AppColors.cyberCyan.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      minimumSize: Size.zero,
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.menu_book_rounded, size: 13),
                    label: const Text(
                      "PANDUAN",
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                    ),
                    onPressed: _openCommandManual,
                  ),
                  const SizedBox(width: 8),

                  // Tab Autocomplete hint button
                  InkWell(
                    onTap: _handleTabCompletion,
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Text(
                        "TAB ⇥ AUTO",
                        style: TextStyle(fontSize: 9, fontFamily: 'monospace', color: Colors.white70),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Maximize / Fullscreen Toggle Button
                  Tooltip(
                    message: widget.isFullscreen ? "Perkecil (Restore Layout)" : "Layar Penuh (Maximize Terminal)",
                    child: InkWell(
                      onTap: _toggleFullscreen,
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: widget.isFullscreen ? AppColors.cyberCyan.withValues(alpha: 0.2) : Colors.black45,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: widget.isFullscreen ? AppColors.cyberCyan : Colors.white24),
                        ),
                        child: Icon(
                          widget.isFullscreen ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded,
                          size: 16,
                          color: widget.isFullscreen ? AppColors.cyberCyan : Colors.white70,
                        ),
                      ),
                    ),
                  ),
                  if (widget.isFullscreen) ...[
                    const SizedBox(width: 6),
                    Tooltip(
                      message: "Tutup Layar Penuh",
                      child: InkWell(
                        onTap: () {
                          if (widget.onExitFullscreen != null) {
                            widget.onExitFullscreen!();
                          } else {
                            Navigator.of(context).pop();
                          }
                        },
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: AppColors.merahVibrant.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.merahVibrant),
                          ),
                          child: const Icon(Icons.close_rounded, size: 16, color: AppColors.merahVibrant),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // ── Scrollable Terminal Output Screen ────────────────────────────
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: _lines.length,
                itemBuilder: (context, index) {
                  final line = _lines[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      line.text,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: widget.isFullscreen ? 13 : 11.5,
                        fontWeight: FontWeight.w600,
                        color: _getLineColor(line.type),
                        height: 1.45,
                        letterSpacing: 0.3,
                      ),
                    ),
                  );
                },
              ),
            ),

            // ── Cyberpunk Military Tactical Input Bar ───────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFF040810),
                border: Border(
                  top: BorderSide(
                    color: const Color(0xFF00F0FF).withValues(alpha: 0.25),
                    width: 1.0,
                  ),
                ),
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF070F18), // Deep semi-transparent dark tactical container
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: _focusNode.hasFocus
                        ? const Color(0xFF00F0FF) // Intensified Cyber Cyan border on focus
                        : const Color(0xFF00F0FF).withValues(alpha: 0.35),
                    width: _focusNode.hasFocus ? 1.5 : 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _focusNode.hasFocus
                          ? const Color(0x4D00F0FF) // Glowing soft shadow on focus
                          : const Color(0x1400F0FF),
                      blurRadius: _focusNode.hasFocus ? 14 : 6,
                      spreadRadius: _focusNode.hasFocus ? 1 : 0,
                    ),
                    if (_focusNode.hasFocus)
                      const BoxShadow(
                        color: Color(0x2406D6A0),
                        blurRadius: 18,
                        spreadRadius: 1,
                      ),
                  ],
                ),
                child: Row(
                  children: [
                    // Tactical Terminal Prompt Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF06D6A0).withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: const Color(0xFF06D6A0).withValues(alpha: 0.40),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.terminal_rounded, size: 12, color: Color(0xFF06D6A0)),
                          const SizedBox(width: 4),
                          Text(
                            "satsiber@c2:~\$",
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF06D6A0),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // High-Visibility Monospace Text Field
                    Expanded(
                      child: TextField(
                        controller: _inputController,
                        focusNode: _focusNode,
                        autofocus: widget.isFullscreen,
                        cursorColor: const Color(0xFF00F0FF), // Glowing Cyber Cyan cursor
                        cursorWidth: 2.2,
                        cursorRadius: const Radius.circular(1),
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF00F0FF), // Ultra-high visibility Cyber Cyan text
                          letterSpacing: 0.6,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          filled: false,
                          fillColor: Colors.transparent,
                          contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          hintText: "ketik perintah (help, status, scan, isolate)...",
                          hintStyle: GoogleFonts.jetBrainsMono(
                            color: const Color(0xFF475569), // Muted legible tone on dark background
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                        ),
                        onSubmitted: _executeCommand,
                      ),
                    ),
                    // Blinking Block Cursor Indicator
                    AnimatedBuilder(
                      animation: _cursorBlinkCtrl,
                      builder: (context, _) => Container(
                        width: 8,
                        height: 16,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          color: _cursorBlinkCtrl.value > 0.45
                              ? const Color(0xFF00F0FF)
                              : Colors.transparent,
                          boxShadow: _cursorBlinkCtrl.value > 0.45
                              ? [
                                  const BoxShadow(
                                    color: Color(0x9900F0FF),
                                    blurRadius: 5,
                                    spreadRadius: 1,
                                  )
                                ]
                              : [],
                        ),
                      ),
                    ),
                    // Integrated Tactical Send Button (">")
                    _TacticalSendButton(
                      onPressed: () => _executeCommand(_inputController.text),
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

/// Cyberpunk Tactical Send Button with neon glow, hover scaling, and ripple effect
class _TacticalSendButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _TacticalSendButton({required this.onPressed});

  @override
  State<_TacticalSendButton> createState() => _TacticalSendButtonState();
}

class _TacticalSendButtonState extends State<_TacticalSendButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: "Eksekusi Perintah (Enter)",
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            widget.onPressed();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedScale(
            scale: _isPressed ? 0.92 : (_isHovered ? 1.08 : 1.0),
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _isHovered
                    ? const Color(0xFF00F0FF).withValues(alpha: 0.28)
                    : const Color(0xFF00F0FF).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _isHovered
                      ? const Color(0xFF00F0FF)
                      : const Color(0xFF00F0FF).withValues(alpha: 0.5),
                  width: _isHovered ? 1.5 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isHovered
                        ? const Color(0x6600F0FF)
                        : const Color(0x2000F0FF),
                    blurRadius: _isHovered ? 10 : 4,
                    spreadRadius: _isHovered ? 1 : 0,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    ">",
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: _isHovered ? Colors.white : const Color(0xFF00F0FF),
                      shadows: _isHovered
                          ? [
                              const Shadow(
                                color: Color(0xFF00F0FF),
                                blurRadius: 8,
                              )
                            ]
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
