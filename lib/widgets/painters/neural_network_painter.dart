import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class NeuralNetworkPainter extends CustomPainter {
  final double animationValue;

  NeuralNetworkPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final layers = [4, 7, 9, 6, 3];
    final layerSpacing = size.width / (layers.length + 1);
    final List<List<Offset>> nodePositions = [];

    for (int l = 0; l < layers.length; l++) {
      final x = layerSpacing * (l + 1);
      final count = layers[l];
      final spacing = size.height / (count + 1);
      final List<Offset> layerNodes = [];
      for (int i = 0; i < count; i++) {
        layerNodes.add(Offset(x, spacing * (i + 1)));
      }
      nodePositions.add(layerNodes);
    }

    // Synapses
    final synapsePaint = Paint()
      ..color = const Color(0x1F00E5FF)
      ..strokeWidth = 1.0;

    for (int l = 0; l < nodePositions.length - 1; l++) {
      for (final n1 in nodePositions[l]) {
        for (final n2 in nodePositions[l + 1]) {
          canvas.drawLine(n1, n2, synapsePaint);
        }
      }
    }

    // Neurons
    for (int l = 0; l < nodePositions.length; l++) {
      for (int i = 0; i < nodePositions[l].length; i++) {
        final pos = nodePositions[l][i];
        final pulse = sin(animationValue * 2 * pi + l + i);
        Color color = AppColors.cyberCyan;
        if (l == 0) color = AppColors.tniGreenNeon;
        if (l == nodePositions.length - 1) color = AppColors.merahNeon;

        canvas.drawCircle(pos, 3.5 + pulse * 1.2, Paint()..color = color);
      }
    }
  }

  @override
  bool shouldRepaint(covariant NeuralNetworkPainter oldDelegate) => true;
}
