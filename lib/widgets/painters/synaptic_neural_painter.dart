import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SynapticNeuralPainter extends CustomPainter {
  final double animationValue;
  final bool isSurging;
  final (int, int)? selectedNode; // (layerIndex, nodeIndex)

  static final List<int> layers = [4, 7, 8, 6, 3];

  SynapticNeuralPainter({
    required this.animationValue,
    this.isSurging = false,
    this.selectedNode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background matrix grid lines
    _drawBackgroundGrid(canvas, size);

    // Calculate node coordinates per layer
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

    // 1. Draw Synaptic Connections & Traveling Data Pulses
    _drawSynapsesAndPulses(canvas, nodePositions);

    // 2. Draw Neurons with Dynamic Halos
    _drawNeurons(canvas, nodePositions);

    // 3. Draw Layer Header Labels (INPUT, DENSE, OUTPUT)
    _drawLayerLabels(canvas, nodePositions, size);
  }

  void _drawBackgroundGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF00C6FF).withValues(alpha: 0.04)
      ..strokeWidth = 1.0;

    for (double x = 0; x < size.width; x += 32) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 32) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  void _drawSynapsesAndPulses(Canvas canvas, List<List<Offset>> nodePositions) {
    final rand = Random(1337);

    for (int l = 0; l < nodePositions.length - 1; l++) {
      final fromLayer = nodePositions[l];
      final toLayer = nodePositions[l + 1];

      for (int i = 0; i < fromLayer.length; i++) {
        final n1 = fromLayer[i];

        for (int j = 0; j < toLayer.length; j++) {
          final n2 = toLayer[j];
          final isConnectedToSelected = selectedNode != null &&
              ((selectedNode!.$1 == l && selectedNode!.$2 == i) ||
                  (selectedNode!.$1 == l + 1 && selectedNode!.$2 == j));

          // Base Axon Line
          double opacity = isSurging ? 0.45 : 0.08;
          double width = isSurging ? 1.5 : 0.8;
          Color lineColor = isSurging ? AppColors.goldInsignia : const Color(0xFF00C6FF);

          if (selectedNode != null) {
            if (isConnectedToSelected) {
              opacity = 0.70;
              width = 2.0;
              lineColor = AppColors.cyberCyanDeep;
            } else {
              opacity = 0.03;
            }
          }

          final axonPaint = Paint()
            ..color = lineColor.withValues(alpha: opacity)
            ..strokeWidth = width;

          canvas.drawLine(n1, n2, axonPaint);

          // Traveling Synaptic Pulses (Data Packets)
          final pulsePhase = rand.nextDouble();
          final speedFactor = isSurging ? 3.0 : 1.0;
          final t = ((animationValue * speedFactor) + pulsePhase) % 1.0;

          // Packet Position along line
          final packetPos = Offset.lerp(n1, n2, t)!;

          final pulseColor = isSurging
              ? (t > 0.5 ? AppColors.merahVibrant : AppColors.goldInsignia)
              : (isConnectedToSelected ? AppColors.merahVibrant : AppColors.cyberCyan);

          final packetPaint = Paint()
            ..color = pulseColor.withValues(alpha: isSurging ? 0.95 : (isConnectedToSelected ? 0.9 : 0.65))
            ..style = PaintingStyle.fill;

          canvas.drawCircle(packetPos, isSurging ? 3.0 : 1.8, packetPaint);

          if (isSurging || isConnectedToSelected) {
            final haloPaint = Paint()
              ..color = pulseColor.withValues(alpha: 0.4)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
            canvas.drawCircle(packetPos, 4.5, haloPaint);
          }
        }
      }
    }
  }

  void _drawNeurons(Canvas canvas, List<List<Offset>> nodePositions) {
    for (int l = 0; l < nodePositions.length; l++) {
      final isInput = l == 0;
      final isOutput = l == nodePositions.length - 1;

      for (int i = 0; i < nodePositions[l].length; i++) {
        final pos = nodePositions[l][i];
        final isSelected = selectedNode != null && selectedNode!.$1 == l && selectedNode!.$2 == i;

        final pulse = sin(animationValue * 2 * pi * (isSurging ? 3.0 : 1.0) + l * 0.8 + i);
        final baseRadius = isSelected ? 8.0 : (isOutput ? 6.5 : (isInput ? 5.5 : 4.5));

        Color neuronColor;
        if (isInput) {
          neuronColor = AppColors.tniGreenMid;
        } else if (isOutput) {
          if (i == 0) {
            neuronColor = AppColors.tniGreenMid; // Benign
          } else if (i == 1) {
            neuronColor = AppColors.warningAmber; // Suspicious
          } else {
            neuronColor = AppColors.merahVibrant; // Critical Attack
          }
        } else {
          neuronColor = isSurging ? AppColors.goldInsignia : AppColors.cyberCyanDeep;
        }

        if (isSelected) {
          neuronColor = AppColors.merahVibrant;
        }

        // 1. Outer Glowing Halo
        final haloPaint = Paint()
          ..color = neuronColor.withValues(alpha: isSurging ? 0.7 : 0.35)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, isSelected ? 12.0 : 6.0);
        canvas.drawCircle(pos, baseRadius + 3.0 + pulse * 1.5, haloPaint);

        // 2. Outer Ring Border
        final ringPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = isSelected ? 2.0 : 1.2;
        canvas.drawCircle(pos, baseRadius + 1.0, ringPaint);

        // 3. Inner Solid Nucleus
        final corePaint = Paint()
          ..color = neuronColor
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pos, baseRadius, corePaint);

        // Highlight center dot
        canvas.drawCircle(pos, baseRadius * 0.4, Paint()..color = Colors.white.withValues(alpha: 0.85));
      }
    }
  }

  void _drawLayerLabels(Canvas canvas, List<List<Offset>> nodePositions, Size size) {
    const labels = ['INPUT', 'DENSE-1', 'DENSE-2', 'FEATURE', 'OUTPUT'];

    for (int l = 0; l < nodePositions.length; l++) {
      final x = nodePositions[l].first.dx;
      final text = labels[l];

      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
            letterSpacing: 0.8,
            fontFamily: 'monospace',
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(canvas, Offset(x - textPainter.width / 2, 10));
    }
  }

  @override
  bool shouldRepaint(covariant SynapticNeuralPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.isSurging != isSurging ||
        oldDelegate.selectedNode != selectedNode;
  }
}
