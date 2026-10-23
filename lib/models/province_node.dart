import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

enum NodeThreatLevel { active, warning, critical }

class ProvinceNode {
  final String id;
  final String name;
  final String capital;
  final String islandGroup;
  final double latitude;
  final double longitude;
  final String commandUnit;
  final NodeThreatLevel threatLevel;
  final String ipAddress;
  final int activeThreats;
  final String encryption;
  final int personnel;
  final String bandwidth;
  final String ping;
  final bool isStrategicBorder;

  const ProvinceNode({
    required this.id,
    required this.name,
    required this.capital,
    required this.islandGroup,
    required this.latitude,
    required this.longitude,
    required this.commandUnit,
    this.threatLevel = NodeThreatLevel.active,
    required this.ipAddress,
    this.activeThreats = 0,
    this.encryption = 'AES-256-GCM / Post-Quantum Kyber-1024',
    required this.personnel,
    required this.bandwidth,
    required this.ping,
    this.isStrategicBorder = false,
  });

  Color get statusColor {
    switch (threatLevel) {
      case NodeThreatLevel.active:
        return AppColors.tniGreenMid;
      case NodeThreatLevel.warning:
        return AppColors.warningAmber;
      case NodeThreatLevel.critical:
        return AppColors.merahVibrant;
    }
  }

  String get statusLabel {
    switch (threatLevel) {
      case NodeThreatLevel.active:
        return 'AMAN / TERLINDUNGI';
      case NodeThreatLevel.warning:
        return 'WASPADA / ELEVATED';
      case NodeThreatLevel.critical:
        return 'DARURAT / SERANGAN AKTIF';
    }
  }
}
