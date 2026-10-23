import 'package:flutter/material.dart';
import '../state/command_center_controller.dart';
import 'field_operations_view.dart';

/// Production-ready wrapper for FieldOperationsScreen matching the architectural naming specification.
class FieldOperationsScreen extends StatelessWidget {
  final CommandCenterController controller;

  const FieldOperationsScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return FieldOperationsView(controller: controller);
  }
}
