import 'package:flutter/material.dart';

enum NodeSecurityStatus { safe, warning, danger }

class CyberNode {
  final String name;
  final double relativeX;
  final double relativeY;
  final NodeSecurityStatus status;
  final String ipAddress;

  const CyberNode({
    required this.name,
    required this.relativeX,
    required this.relativeY,
    required this.status,
    required this.ipAddress,
  });

  Color get statusColor {
    switch (status) {
      case NodeSecurityStatus.safe:
        return const Color(0xFF39FF14);
      case NodeSecurityStatus.warning:
        return const Color(0xFFFFB300);
      case NodeSecurityStatus.danger:
        return const Color(0xFFFF2A37);
    }
  }
}
