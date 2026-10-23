import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/cyber_node.dart';
import '../models/threat_incident.dart';
import '../models/satellite_fleet.dart';
import '../models/blockchain_block.dart';
import '../models/telemetry_metric.dart';

class CommandCenterController extends ChangeNotifier {
  int _selectedTabIndex = 0;
  int get selectedTabIndex => _selectedTabIndex;

  int _threatLevel = 3; // 1-5 (1: Low, 5: Critical)
  int get threatLevel => _threatLevel;

  Timer? _simulationTimer;
  final Random _rng = Random();

  // Terminal Console Lines
  final List<String> _consoleLogs = [
    "SI-CAKRAWALA [Kernel v4.7.2-TNI-AD/FLUTTER]",
    "Otentikasi: KOL. NAZARUL QUDRI - CLEARANCE TOP SECRET",
    "Sistem Beroperasi: 15 Node Kodam Terkoneksi Aman.",
    "Ketik 'help' untuk melihat perintah militer tersedia."
  ];
  List<String> get consoleLogs => List.unmodifiable(_consoleLogs);

  // Nodes Data
  late List<CyberNode> _nodes;
  List<CyberNode> get nodes => _nodes;

  // Timeline Data
  late List<ThreatIncident> _incidents;
  List<ThreatIncident> get incidents => _incidents;

  // Satellite Fleet
  late List<SatelliteFleet> _satellites;
  List<SatelliteFleet> get satellites => _satellites;

  // Blockchain Blocks
  late List<BlockchainBlock> _blocks;
  List<BlockchainBlock> get blocks => _blocks;

  // Telemetry Metrics
  late List<TelemetryMetric> _metrics;
  List<TelemetryMetric> get metrics => _metrics;

  // Traffic series
  List<double> inboundTraffic = List.generate(24, (_) => 45.0);
  List<double> attackTraffic = List.generate(24, (_) => 12.0);
  List<double> blockedTraffic = List.generate(24, (_) => 11.5);

  CommandCenterController() {
    _initData();
    _startSimulation();
  }

  void _initData() {
    _nodes = [
      const CyberNode(name: "SABANG - POS ALFA", relativeX: 0.12, relativeY: 0.32, status: NodeSecurityStatus.warning, ipAddress: "10.1.0.1"),
      const CyberNode(name: "MEDAN - KODAM I/BB", relativeX: 0.18, relativeY: 0.40, status: NodeSecurityStatus.safe, ipAddress: "10.1.1.5"),
      const CyberNode(name: "NATUNA - POS DEPAN", relativeX: 0.33, relativeY: 0.28, status: NodeSecurityStatus.danger, ipAddress: "10.2.7.9"),
      const CyberNode(name: "BATAM - HUB SIBER", relativeX: 0.24, relativeY: 0.45, status: NodeSecurityStatus.safe, ipAddress: "10.1.4.12"),
      const CyberNode(name: "JAKARTA - MABES SATSIBER", relativeX: 0.30, relativeY: 0.72, status: NodeSecurityStatus.safe, ipAddress: "10.0.0.1"),
      const CyberNode(name: "SURABAYA - KODAM V/BRW", relativeX: 0.44, relativeY: 0.78, status: NodeSecurityStatus.warning, ipAddress: "10.5.0.2"),
      const CyberNode(name: "BALIKPAPAN - KODAM VI/MLW", relativeX: 0.48, relativeY: 0.52, status: NodeSecurityStatus.safe, ipAddress: "10.6.1.1"),
      const CyberNode(name: "TARAKAN - SEKTOR BRAVO", relativeX: 0.52, relativeY: 0.35, status: NodeSecurityStatus.danger, ipAddress: "10.6.9.14"),
      const CyberNode(name: "MAKASSAR - KODAM XIV/HSN", relativeX: 0.56, relativeY: 0.65, status: NodeSecurityStatus.safe, ipAddress: "10.14.0.1"),
      const CyberNode(name: "MANADO - KODAM XIII/MDK", relativeX: 0.63, relativeY: 0.38, status: NodeSecurityStatus.warning, ipAddress: "10.13.0.3"),
      const CyberNode(name: "AMBON - KODAM XVI/PTM", relativeX: 0.74, relativeY: 0.62, status: NodeSecurityStatus.safe, ipAddress: "10.16.0.7"),
      const CyberNode(name: "JAYAPURA - KODAM XVII/CEN", relativeX: 0.88, relativeY: 0.58, status: NodeSecurityStatus.danger, ipAddress: "10.17.0.1"),
      const CyberNode(name: "MERAUKE - SEKTOR DELTA", relativeX: 0.89, relativeY: 0.80, status: NodeSecurityStatus.safe, ipAddress: "10.17.8.2"),
    ];

    _incidents = [
      const ThreatIncident(
        id: "INC-901",
        title: "Brute-force SSH Attack",
        description: "Penetrasi berulang pada gateway Kodam XVII/Cen dari IP 185.220.101.4",
        timestamp: "15:28:14 WIB",
        severity: ThreatSeverity.critical,
        sourceIp: "185.220.101.4",
        targetSector: "Jayapura",
      ),
      const ThreatIncident(
        id: "INC-902",
        title: "Anomali Port Sweep",
        description: "Pemindaian port radar di Natuna Frontline Node",
        timestamp: "15:26:02 WIB",
        severity: ThreatSeverity.high,
        sourceIp: "103.22.201.8",
        targetSector: "Natuna",
      ),
      const ThreatIncident(
        id: "INC-903",
        title: "Blockchain Blok #48,271 Tervalidasi",
        description: "15 Node Kodam mencapai konsensus BFT 100%",
        timestamp: "15:23:45 WIB",
        severity: ThreatSeverity.low,
        sourceIp: "Internal Network",
        targetSector: "Nasional",
      ),
    ];

    _satellites = [
      const SatelliteFleet(code: "CAKRAWALA-3A", type: "SAR (Radar)", altitude: "520 km LEO", inclination: "97.4°", resolution: "0.3m/px", status: "LOCK / ONLINE", health: 0.99),
      const SatelliteFleet(code: "CAKRAWALA-2B", type: "SIGINT / Elint", altitude: "35,786 km GEO", inclination: "0.1°", resolution: "N/A", status: "ENCRYPTED", health: 0.98),
      const SatelliteFleet(code: "CAKRAWALA-1C", type: "Optical High-Res", altitude: "610 km LEO", inclination: "98.2°", resolution: "0.5m/px", status: "SURVEILLANCE", health: 0.94),
      const SatelliteFleet(code: "MERAH-PUTIH-2", type: "Tactical SATCOM", altitude: "36,000 km GEO", inclination: "0.0°", resolution: "Band C/Ku", status: "LINK OPTIMAL", health: 1.0),
    ];

    _blocks = [
      const BlockchainBlock(height: 48271, hash: "0x9f4a8b11c0de7d21", prevHash: "0x88c1e29f0012bb40", transactionsCount: 42, validator: "MABES-AD-VAL-01", timestamp: "15:23:45"),
      const BlockchainBlock(height: 48270, hash: "0x88c1e29f0012bb40", prevHash: "0x3f4a9b1288cc110a", transactionsCount: 38, validator: "KODAM-VI-VAL-03", timestamp: "15:23:42"),
      const BlockchainBlock(height: 48269, hash: "0x3f4a9b1288cc110a", prevHash: "0x12e9cc887711aa90", transactionsCount: 51, validator: "KODAM-XVII-VAL-05", timestamp: "15:23:40"),
    ];

    _metrics = [
      TelemetryMetric(
        name: "CPU CLUSTER", value: 44.5, unit: "%", status: "NORMAL",
        history: List.generate(60, (i) => 30 + _rng.nextDouble() * 30),
      ),
      TelemetryMetric(
        name: "GPU NEURAL ENGINE", value: 78.2, unit: "%", status: "ACTIVE INFERENCE",
        history: List.generate(60, (i) => 60 + _rng.nextDouble() * 30),
      ),
      TelemetryMetric(
        name: "RAM TERENKRIPSI", value: 64.0, unit: "%", status: "NORMAL",
        history: List.generate(60, (i) => 50 + _rng.nextDouble() * 25),
      ),
      TelemetryMetric(
        name: "SATCOM BANDWIDTH", value: 89.1, unit: "%", status: "OPTIMAL",
        history: List.generate(60, (i) => 70 + _rng.nextDouble() * 25),
      ),
    ];
  }

  void _startSimulation() {
    _simulationTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      // Traffic shift
      inboundTraffic.removeAt(0);
      inboundTraffic.add(40 + _rng.nextDouble() * 35);

      attackTraffic.removeAt(0);
      attackTraffic.add(_rng.nextDouble() > 0.7 ? (20 + _rng.nextDouble() * 15) : (5 + _rng.nextDouble() * 8));

      blockedTraffic.removeAt(0);
      blockedTraffic.add(attackTraffic.last * 0.94);

      // Block generator occasionally
      if (_rng.nextDouble() > 0.6) {
        final lastHeight = _blocks.first.height;
        final newBlock = BlockchainBlock(
          height: lastHeight + 1,
          hash: "0x${_rng.nextInt(0xFFFFFF).toRadixString(16)}${_rng.nextInt(0xFFFFFF).toRadixString(16)}",
          prevHash: _blocks.first.hash,
          transactionsCount: 20 + _rng.nextInt(50),
          validator: "KODAM-NODE-${_rng.nextInt(15) + 1}",
          timestamp: "${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}",
        );
        _blocks.insert(0, newBlock);
        if (_blocks.length > 8) _blocks.removeLast();
      }

      // Telemetry metrics live simulation
      final newValues = [
        (30 + _rng.nextDouble() * 55).clamp(0.0, 100.0),   // CPU
        (55 + _rng.nextDouble() * 40).clamp(0.0, 100.0),   // GPU
        (55 + _rng.nextDouble() * 30).clamp(0.0, 100.0),   // RAM
        (70 + _rng.nextDouble() * 28).clamp(0.0, 100.0),   // SATCOM
      ];
      for (int i = 0; i < _metrics.length; i++) {
        final v = newValues[i];
        final newHistory = List<double>.from(_metrics[i].history);
        newHistory.removeAt(0);
        newHistory.add(v);
        final st = v >= 90 ? 'KRITIS' : v >= 70 ? 'TINGGI' : _metrics[i].status;
        _metrics[i] = _metrics[i].copyWith(value: v, history: newHistory, status: st);
      }

      notifyListeners();
    });
  }

  void selectTab(int index) {
    if (_selectedTabIndex != index) {
      _selectedTabIndex = index;
      notifyListeners();
    }
  }

  void executeCommand(String command) {
    final cmd = command.trim().toLowerCase();
    _consoleLogs.add("ROOT@SICAKRAWALA:~\$ $command");

    switch (cmd) {
      case "help":
        _consoleLogs.add("DAFTAR PERINTAH TAKTIS:");
        _consoleLogs.add("  status     - Status ringkas koneksi & enkripsi");
        _consoleLogs.add("  scan       - Vulnerability scan 16 sektor pertahanan");
        _consoleLogs.add("  satellite  - Telemetri armada CAKRAWALA SAR/IR");
        _consoleLogs.add("  ai         - Diagnostik AI Engine (Akurasi & Waktu Inferensi)");
        _consoleLogs.add("  blockchain - Audit ledger blok konsensus BFT");
        _consoleLogs.add("  defend     - Aktifkan mode isolasi darurat");
        _consoleLogs.add("  clear      - Bersihkan log terminal");
        break;
      case "status":
        _consoleLogs.add("[OK] Gateway: NORMAL | Enkripsi: AES-256-GCM / Kyber-1024");
        _consoleLogs.add("[OK] Node Aktif: 1,247/1,250 | Rata-rata Latensi: 11ms");
        break;
      case "scan":
        _consoleLogs.add(">> Memulai deep vulnerability scan seluruh sektor pertahanan...");
        _consoleLogs.add("[VERIFIED] 15 Kodam terhubung aman tanpa anomali struktural.");
        break;
      case "satellite":
        _consoleLogs.add(">> CAKRAWALA-3A: ALT 520km SAR | STATUS LOCK | RES 0.3m/px");
        break;
      case "ai":
        _consoleLogs.add(">> Model Transformer v9.4 | Akurasi 97.3% | Waktu Inferensi 4ms");
        break;
      case "blockchain":
        _consoleLogs.add(">> Blok Terkini: #${_blocks.first.height} | Konsensus BFT 100%");
        break;
      case "defend":
        _threatLevel = 5;
        _consoleLogs.add("!! PERINGATAN: PROTOKOL PERISAI CYBER DARURAT DIAKTIFKAN !!");
        _consoleLogs.add("Seluruh port publik non-militer dikarantina seketika.");
        break;
      case "clear":
        _consoleLogs.clear();
        break;
      default:
        _consoleLogs.add("Perintah tidak dikenali: '$command'. Ketik 'help'.");
    }

    if (_consoleLogs.length > 30) {
      _consoleLogs.removeRange(0, _consoleLogs.length - 30);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }
}
