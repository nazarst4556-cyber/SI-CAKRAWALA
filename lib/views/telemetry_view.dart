import 'package:flutter/material.dart';
import '../state/command_center_controller.dart';
import 'telemetry_dashboard_screen.dart';

export 'telemetry_dashboard_screen.dart';

/// TelemetryView wrapping TelemetryDashboardScreen for unified navigation.
class TelemetryView extends StatelessWidget {
  final CommandCenterController controller;

  const TelemetryView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TelemetryDashboardScreen(controller: controller);
  }
}
