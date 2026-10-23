import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class CommandDocItem {
  final String command;
  final String syntax;
  final String description;
  final String clearance;
  final List<String> parameters;
  final String example;
  final Color categoryColor;

  const CommandDocItem({
    required this.command,
    required this.syntax,
    required this.description,
    required this.clearance,
    required this.parameters,
    required this.example,
    required this.categoryColor,
  });
}

class CommandManualModal extends StatefulWidget {
  final Function(String command)? onSelectCommand;

  const CommandManualModal({super.key, this.onSelectCommand});

  @override
  State<CommandManualModal> createState() => _CommandManualModalState();
}

class _CommandManualModalState extends State<CommandManualModal> {
  String _selectedCategory = 'SEMUA';
  String _searchFilter = '';

  static const List<CommandDocItem> _commandDocs = [
    // ── STATUS & DIAGNOSTIK SISTEM ──
    CommandDocItem(
      command: "status",
      syntax: "status [--node all | <node_id>]",
      description: "Menampilkan status kesehatan gateway militer, throughput latensi, dan sinkronisasi 15 Node Kodam Validator.",
      clearance: "CONFIDENTIAL / LEVEL-1",
      parameters: [
        "--node all : Memindai seluruh 15 Kodam node secara terinci.",
        "--node <id> : Menginspeksi node spesifik (contoh: --node KODAM-VI).",
      ],
      example: "status --node all",
      categoryColor: AppColors.cyberCyanDeep,
    ),
    CommandDocItem(
      command: "scan",
      syntax: "scan --sector <sektor_name>",
      description: "Melakukan pemindaian kerentanan (vulnerability sweep) dan deteksi anomali pada sektor pertahanan nasional.",
      clearance: "SECRET / SATSIBER",
      parameters: [
        "--sector natuna : Pindai sektor maritim utara Natuna.",
        "--sector papua  : Pindai sektor pamtas timur Skouw.",
        "--sector mabes  : Pindai perisai siber inti Mabes TNI AD.",
      ],
      example: "scan --sector natuna",
      categoryColor: AppColors.merahVibrant,
    ),

    // ── AKSI ISOLASI & PERTAHANAN BFT ──
    CommandDocItem(
      command: "isolate",
      syntax: "isolate --ip <ip_address> [--reason <teks>]",
      description: "Mengeksekusi blokir instan terhadap alamat IP penyerang menggunakan aturan firewall otonom konsensus BFT.",
      clearance: "TOP SECRET / DEFCON-2",
      parameters: [
        "--ip <address> : Alamat IPv4/IPv6 target mitigasi isolasi.",
        "--reason <msg> : Alasan taktis isolasi (opsional).",
      ],
      example: "isolate --ip 185.220.101.4",
      categoryColor: AppColors.merahVibrant,
    ),

    // ── KRIPTOGRAFI KUANTUM & LEDGER ──
    CommandDocItem(
      command: "cipher",
      syntax: "cipher --rotate [--algorithm <kyber|dilithium>]",
      description: "Memicu rotasi darurat kunci sesi Post-Quantum Kyber-1024 dan signature Dilithium-5 ke seluruh terminal.",
      clearance: "TOP SECRET / CRYPTO-OPS",
      parameters: [
        "--rotate : Memicu rotasi kunci enkripsi instan.",
        "--algorithm kyber : Menetapkan algoritma spesifik Post-Quantum.",
      ],
      example: "cipher --rotate",
      categoryColor: AppColors.goldInsignia,
    ),
    CommandDocItem(
      command: "blockchain",
      syntax: "blockchain [--verify | --latest | --blocks <n>]",
      description: "Audit integritas buku besar terdistribusi (ledger) dan verifikasi cryptographic hash pada blok konsensus PBFT.",
      clearance: "CONFIDENTIAL / LEDGER",
      parameters: [
        "--verify : Validasi pohon Merkle & Dilithium signature.",
        "--latest : Menampilkan ringkasan blok tertinggi.",
      ],
      example: "blockchain --verify",
      categoryColor: AppColors.goldInsignia,
    ),

    // ── TELEMETRI SATELIT ──
    CommandDocItem(
      command: "satellite",
      syntax: "satellite [--fleet | --lock <sat_code>]",
      description: "Telemetri armada satelit militer (CAKRAWALA-3A, MERAH-PUTIH-2, CAKRAWALA-2B) dan kunci koordinat radar SAR.",
      clearance: "SECRET / SPACE-C2",
      parameters: [
        "--fleet : Ringkasan orbit LEO/GEO seluruh armada satelit.",
        "--lock <code : Kunci sensor SAR ke satelit spesifik.",
      ],
      example: "satellite --fleet",
      categoryColor: AppColors.cyberCyanDeep,
    ),

    // ── MESIN INTELIJEN AI ──
    CommandDocItem(
      command: "ai",
      syntax: "ai [--diagnostics | --mode <autonomous|assisted|stealth>]",
      description: "Pemeriksaan model AI Transformer neural engine v9.4, akurasi klasifikasi serangan, dan alih mode operasional.",
      clearance: "SECRET / AI-INTEL",
      parameters: [
        "--diagnostics : Uji akurasi, waktu inferensi, dan synaptic loss.",
        "--mode <name> : Mengganti mode kerja AI engine pertahanan.",
      ],
      example: "ai --diagnostics",
      categoryColor: AppColors.tniGreenNeon,
    ),

    // ── MANUAL & DOKUMENTASI SISTEM ──
    CommandDocItem(
      command: "man",
      syntax: "man <nama_perintah>",
      description: "Menampilkan buku petunjuk operasional lengkap dan parameter teknis dari perintah spesifik.",
      clearance: "PUBLIC / MIL-INTERNAL",
      parameters: [
        "<command> : Nama perintah yang ingin diinspeksi (contoh: man isolate).",
      ],
      example: "man isolate",
      categoryColor: AppColors.tniGreenMid,
    ),
    CommandDocItem(
      command: "clear",
      syntax: "clear",
      description: "Membersihkan seluruh layar penyangga konsol terminal.",
      clearance: "PUBLIC / OPERATOR",
      parameters: ["Tidak memerlukan parameter."],
      example: "clear",
      categoryColor: AppColors.textSecondary,
    ),
  ];

  List<CommandDocItem> get _filteredDocs {
    return _commandDocs.where((doc) {
      final matchesCat = _selectedCategory == 'SEMUA' ||
          (_selectedCategory == 'DIAGNOSTIK' && (doc.command == 'status' || doc.command == 'scan')) ||
          (_selectedCategory == 'PERTAHANAN' && (doc.command == 'isolate' || doc.command == 'ai')) ||
          (_selectedCategory == 'KRIPTO' && (doc.command == 'cipher' || doc.command == 'blockchain')) ||
          (_selectedCategory == 'SATELIT' && doc.command == 'satellite');

      final matchesQuery = _searchFilter.isEmpty ||
          doc.command.toLowerCase().contains(_searchFilter.toLowerCase()) ||
          doc.syntax.toLowerCase().contains(_searchFilter.toLowerCase()) ||
          doc.description.toLowerCase().contains(_searchFilter.toLowerCase());

      return matchesCat && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: 760,
        constraints: const BoxConstraints(maxHeight: 700),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cyberCyan.withValues(alpha: 0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.cyberCyan.withValues(alpha: 0.18),
              blurRadius: 32,
              spreadRadius: 2,
            ),
            const BoxShadow(color: Colors.black87, blurRadius: 24),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Modal Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                border: Border(bottom: BorderSide(color: AppColors.glassBorder.withValues(alpha: 0.4))),
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
                    child: const Icon(Icons.menu_book_rounded, color: AppColors.cyberCyan, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "BUKU PANDUAN PERINTAH MILITER (COMMAND MANUAL)",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.8,
                            fontFamily: 'monospace',
                          ),
                        ),
                        Text(
                          "Dokumentasi Perintah Taktis Terminal Konsol Siber TNI AD • Referensi Cepat",
                          style: TextStyle(fontSize: 10, color: Colors.white60),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Search Bar & Category Filter Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: const Color(0xFF131D33),
              child: Column(
                children: [
                  // Search Field
                  SizedBox(
                    height: 36,
                    child: TextField(
                      style: const TextStyle(fontSize: 12, color: Colors.white, fontFamily: 'monospace'),
                      decoration: InputDecoration(
                        hintText: "Cari sintaks perintah (status, isolate, cipher, scan)...",
                        hintStyle: const TextStyle(fontSize: 11, color: Colors.white38),
                        isDense: true,
                        filled: true,
                        fillColor: const Color(0xFF0F172A),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: AppColors.glassBorder.withValues(alpha: 0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: AppColors.cyberCyan),
                        ),
                        prefixIcon: const Icon(Icons.search_rounded, size: 16, color: AppColors.cyberCyan),
                      ),
                      onChanged: (val) => setState(() => _searchFilter = val),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Category Tabs
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterPill("SEMUA"),
                        _buildFilterPill("DIAGNOSTIK"),
                        _buildFilterPill("PERTAHANAN"),
                        _buildFilterPill("KRIPTO"),
                        _buildFilterPill("SATELIT"),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Command Items List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredDocs.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final doc = _filteredDocs[index];
                  return _buildCommandDocCard(doc);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPill(String title) {
    final isSelected = _selectedCategory == title;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: () => setState(() => _selectedCategory = title),
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.cyberCyan.withValues(alpha: 0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isSelected ? AppColors.cyberCyan : Colors.white24,
            ),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
              color: isSelected ? AppColors.cyberCyan : Colors.white70,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCommandDocCard(CommandDocItem doc) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: doc.categoryColor.withValues(alpha: 0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: doc.categoryColor.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Command Name + Syntax + Clearance Pill + Run Button
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: doc.categoryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: doc.categoryColor),
                  ),
                  child: Text(
                    doc.command.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: doc.categoryColor,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    doc.syntax,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Text(
                    doc.clearance,
                    style: const TextStyle(fontSize: 8.5, color: Colors.white70, fontFamily: 'monospace'),
                  ),
                ),
                const SizedBox(width: 8),
                if (widget.onSelectCommand != null)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: doc.categoryColor,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      minimumSize: Size.zero,
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.play_arrow_rounded, size: 14),
                    label: const Text("PAKAI", style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      widget.onSelectCommand!(doc.example);
                      Navigator.of(context).pop();
                    },
                  ),
              ],
            ),

            const SizedBox(height: 8),
            Text(
              doc.description,
              style: const TextStyle(fontSize: 11, color: Color(0xFFCBD5E1), height: 1.4),
            ),

            const SizedBox(height: 10),
            // Parameters list
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "PARAMETER TAKTIS:",
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white54, fontFamily: 'monospace'),
                  ),
                  const SizedBox(height: 4),
                  ...doc.parameters.map((p) => Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          "• $p",
                          style: TextStyle(
                            fontSize: 10,
                            fontFamily: 'monospace',
                            color: doc.categoryColor.withValues(alpha: 0.9),
                          ),
                        ),
                      )),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text(
                        "CONTOH: ",
                        style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.white60, fontFamily: 'monospace'),
                      ),
                      Text(
                        doc.example,
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.cyberCyan, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
