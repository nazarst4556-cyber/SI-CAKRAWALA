import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/radio_transmission.dart';

class TacticalRadioFeed extends StatefulWidget {
  final List<RadioTransmission> initialTransmissions;

  const TacticalRadioFeed({
    super.key,
    required this.initialTransmissions,
  });

  @override
  State<TacticalRadioFeed> createState() => _TacticalRadioFeedState();
}

class _TacticalRadioFeedState extends State<TacticalRadioFeed>
    with SingleTickerProviderStateMixin {
  RadioChannel _activeChannel = RadioChannel.secure;
  late List<RadioTransmission> _transmissions;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _msgInputController = TextEditingController();

  Timer? _hoppingTimer;
  Timer? _transmissionSimTimer;
  final Random _rng = Random();

  double _currentMhz = 142.850;
  int _currentHopIndex = 38;
  late AnimationController _pulseController;

  final List<String> _simulatedMessages = [
    "Sinyal carrier terenkripsi sinkron pada transponder CAKRAWALA-3A.",
    "Laporan Pamtas: Tidak ada interferensi RF tak dikenal terdeteksi pada band VHF/UHF.",
    "Rotasi kunci sesi kuantum Kyber-1024 sukses di seluruh 4 pos mobile.",
    "Gateway Kodam VI mendeteksi anomali probe; mitigasi AI isolasi IP diterapkan.",
    "Paket telemetri SATGAS-02 diterima 100% tanpa paket hilang (Packet Loss 0%).",
    "Uplink radar kuadran barat siaga penuh; kanal taktis standby.",
  ];

  final List<String> _simulatedCallsigns = [
    "SATGAS-01 (NATUNA)",
    "SATGAS-02 (TARAKAN)",
    "SATGAS-03 (JAYAPURA)",
    "TRC-MABES (JAKARTA)",
    "PUSKODAL MABES AD",
  ];

  @override
  void initState() {
    super.initState();
    _transmissions = List.from(widget.initialTransmissions);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    // Frequency Hopping simulator timer
    _hoppingTimer = Timer.periodic(const Duration(milliseconds: 2400), (timer) {
      if (mounted) {
        setState(() {
          _currentMhz = 138.0 + _rng.nextDouble() * 120.0;
          _currentHopIndex = (_currentHopIndex + 1) % 99;
        });
      }
    });

    // Incoming transmission simulation timer
    _transmissionSimTimer = Timer.periodic(const Duration(seconds: 7), (timer) {
      if (mounted) {
        _simulateIncomingTransmission();
      }
    });
  }

  @override
  void dispose() {
    _hoppingTimer?.cancel();
    _transmissionSimTimer?.cancel();
    _pulseController.dispose();
    _scrollController.dispose();
    _msgInputController.dispose();
    super.dispose();
  }

  void _simulateIncomingTransmission() {
    final now = DateTime.now();
    final timeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} WIB";
    final callsign = _simulatedCallsigns[_rng.nextInt(_simulatedCallsigns.length)];
    final text = _simulatedMessages[_rng.nextInt(_simulatedMessages.length)];

    final newTx = RadioTransmission(
      id: "TX-${DateTime.now().millisecondsSinceEpoch}",
      channel: _activeChannel,
      callsign: callsign,
      time: timeStr,
      frequency: "${_currentMhz.toStringAsFixed(3)} MHz [HOP-$_currentHopIndex]",
      message: text,
      isEncrypted: true,
      cipherAlgorithm: 'KYBER-1024',
    );

    setState(() {
      _transmissions.insert(0, newTx);
      if (_transmissions.length > 25) {
        _transmissions.removeLast();
      }
    });
  }

  void _sendManualTransmission() {
    final text = _msgInputController.text.trim();
    if (text.isEmpty) return;

    final now = DateTime.now();
    final timeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} WIB";

    final newTx = RadioTransmission(
      id: "TX-CMD-${DateTime.now().millisecondsSinceEpoch}",
      channel: _activeChannel,
      callsign: "PUSKODAL (COMMANDER)",
      time: timeStr,
      frequency: "${_currentMhz.toStringAsFixed(3)} MHz [HOP-$_currentHopIndex]",
      message: text,
      isEncrypted: true,
      cipherAlgorithm: 'KYBER-1024',
      isEmergency: text.toUpperCase().contains("DARURAT") || text.toUpperCase().contains("DEFCON"),
    );

    setState(() {
      _transmissions.insert(0, newTx);
      _msgInputController.clear();
    });
  }

  List<RadioTransmission> get _filteredTransmissions {
    if (_activeChannel == RadioChannel.freqHopping) {
      return _transmissions;
    }
    return _transmissions.where((tx) => tx.channel == _activeChannel || tx.callsign.contains("PUSKODAL")).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F1B2D),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
              border: Border(bottom: BorderSide(color: AppColors.glassBorder.withValues(alpha: 0.35))),
            ),
            child: Row(
              children: [
                const Icon(Icons.cell_tower_rounded, color: AppColors.cyberCyanDeep, size: 20),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    "KOMUNIKASI TAKTIS TERENKRIPSI (RADIO COMMS)",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                // Live Hopping Pill
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.cyberCyan.withValues(alpha: 0.12 + _pulseController.value * 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.cyberCyanDeep.withValues(alpha: 0.6)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.cyberCyanDeep,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "HOP: ${_currentMhz.toStringAsFixed(2)} MHz",
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              color: AppColors.cyberCyanDeep,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Channel Tabs Selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              border: Border(bottom: BorderSide(color: AppColors.glassBorder.withValues(alpha: 0.2))),
            ),
            child: Row(
              children: [
                _buildChannelTab("CH-01 SECURE", RadioChannel.secure),
                const SizedBox(width: 8),
                _buildChannelTab("CH-02 BROADCAST", RadioChannel.broadcast),
                const SizedBox(width: 8),
                _buildChannelTab("FREQ HOPPING ACTIVE", RadioChannel.freqHopping),
              ],
            ),
          ),

          // Transmissions List
          Container(
            height: 380,
            color: const Color(0xFF0F172A),
            child: _filteredTransmissions.isEmpty
                ? const Center(
                    child: Text(
                      "MENUNGGU TRANSMISI RADIO...",
                      style: TextStyle(color: Colors.white54, fontSize: 11, fontFamily: 'monospace'),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: _filteredTransmissions.length,
                    itemBuilder: (context, index) {
                      final tx = _filteredTransmissions[index];
                      return _buildTransmissionItem(tx);
                    },
                  ),
          ),

          // Manual Direct Transmission Console Input
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(11)),
              border: Border(top: BorderSide(color: AppColors.glassBorder.withValues(alpha: 0.35))),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.cyberCyan.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.cyberCyan.withValues(alpha: 0.4)),
                  ),
                  child: const Text(
                    "TX:",
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: AppColors.cyberCyanDeep,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _msgInputController,
                    style: const TextStyle(fontSize: 11.5, fontFamily: 'monospace', color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      hintText: "Ketik perintah transmisi taktis ke armada...",
                      hintStyle: TextStyle(fontSize: 11, color: AppColors.textMuted),
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    ),
                    onSubmitted: (_) => _sendManualTransmission(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: AppColors.cyberCyanDeep, size: 20),
                  onPressed: _sendManualTransmission,
                  tooltip: "Kirim Transmisi Radio",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChannelTab(String label, RadioChannel channel) {
    final isActive = _activeChannel == channel;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _activeChannel = channel),
        borderRadius: BorderRadius.circular(6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isActive ? AppColors.cyberCyanDeep : Colors.transparent,
              width: 1.2,
            ),
            boxShadow: isActive
                ? const [
                    BoxShadow(
                      color: Color(0x100F1B2D),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    )
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: isActive ? AppColors.cyberCyanDeep : AppColors.textSecondary,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransmissionItem(RadioTransmission tx) {
    final isCommander = tx.callsign.contains("PUSKODAL");
    final borderColor = tx.isEmergency
        ? AppColors.merahVibrant
        : isCommander
            ? AppColors.cyberCyan
            : AppColors.tniGreenNeon;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(6)),
        border: Border(
          left: BorderSide(color: borderColor, width: 3.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    tx.callsign,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: borderColor,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      tx.cipherAlgorithm,
                      style: const TextStyle(
                        fontSize: 8,
                        color: Colors.white70,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    tx.frequency,
                    style: const TextStyle(
                      fontSize: 9,
                      color: Colors.white38,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    tx.time,
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            tx.message,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFFE2E8F0),
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
