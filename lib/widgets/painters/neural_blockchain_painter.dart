import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Immutable model representing an individual AI Neural or Blockchain Node
class NeuralNetworkNode {
  final double baseX;
  final double baseY;
  final double driftAmpX;
  final double driftAmpY;
  final double freqX;
  final double freqY;
  final double freqX2;
  final double freqY2;
  final double phaseX;
  final double phaseY;
  final double pulseFreq;
  final double pulsePhase;
  final double radius;
  final Color color;
  final double signalCycles;
  final double signalPhase;
  final double blockPhase;
  final bool isBlockchain;
  final int layer; // 0=Input, 1=Hidden AI, 2=Bridge, 3=Blockchain Mesh
  final double depthPlane; // 0.6 = background, 1.0 = mid, 1.4 = foreground for parallax

  const NeuralNetworkNode({
    required this.baseX,
    required this.baseY,
    required this.driftAmpX,
    required this.driftAmpY,
    required this.freqX,
    required this.freqY,
    required this.freqX2,
    required this.freqY2,
    required this.phaseX,
    required this.phaseY,
    required this.pulseFreq,
    required this.pulsePhase,
    required this.radius,
    required this.color,
    required this.signalCycles,
    required this.signalPhase,
    required this.blockPhase,
    required this.isBlockchain,
    required this.layer,
    this.depthPlane = 1.0,
  });
}

/// Backward compatibility typedef for existing usages
typedef NeuralBlockchainPainter = NeuralBlockchainBackgroundPainter;

/// Ultra-high performance, direction-oriented Neural-Blockchain Background CustomPainter.
///
/// Visual Philosophy & Directional Architecture:
/// 1. Unified Tensor Flow (Left & Center AI Stream):
///    - Information propagates strictly forward (Layer 0 -> Layer 3) and downward (Top -> Bottom).
///    - Synaptic edges feature microscopic directional arrow chevrons along axon vectors.
///    - Data packets have streamlined forward-oriented photon heads with tapered trailing comet wakes.
/// 2. Sequential Blockchain Verification Chain (Right Mesh):
///    - Hex nodes form an ordered cryptographic ledger chain.
///    - Verification beams travel sequentially along verified block hashes with proof-of-work confirmation pulses.
///    - Concentric expanding hexagonal consensus proof waves.
/// 3. Readability & Contrast Shield:
///    - Calmed opacity corridor in screen center to guarantee 100% text and card legibility.
class NeuralBlockchainBackgroundPainter extends CustomPainter {
  final double t; // 0.0 to 1.0 continuous animation phase
  final Offset parallaxOffset; // Normalized mouse parallax offset (-1.0 to 1.0)
  final List<NeuralNetworkNode> nodes;

  // Mathematical constants for aperiodic, organic motion
  static const double _phi = 1.6180339887; // Golden ratio
  static const double _e = 2.7182818284; // Euler's number
  static const double _tau = 2 * math.pi;

  // Curated color palette tailored for vibrant contrast on light-mode canvas
  static const Color colorCyan = Color(0xFF00F0FF);
  static const Color colorEmerald = Color(0xFF06D6A0);
  static const Color colorAmber = Color(0xFFF59E0B);
  static const Color colorTechBlue = Color(0xFF38BDF8);
  static const Color colorDeepBlue = Color(0xFF1D4ED8);

  const NeuralBlockchainBackgroundPainter({
    required this.t,
    this.parallaxOffset = Offset.zero,
    required this.nodes,
  });

  /// Factory generating deterministic, perfectly distributed node positions
  static List<NeuralNetworkNode> generateNodes() {
    final rng = math.Random(1945); // Deterministic seed (Independence Year)

    // 4 Distinct Architectural Columns:
    // Layer 0: AI Sensor Inputs (Leftmost Edge)
    // Layer 1: Deep Tensor Processing (Center-Left)
    // Layer 2: Hybrid Verification Bridge (Center-Right)
    // Layer 3: Blockchain Cryptographic Mesh (Rightmost Flank)
    const layerConfigs = [
      (8, 0.08, false, colorCyan),
      (10, 0.28, false, colorEmerald),
      (9, 0.72, true, colorTechBlue),
      (9, 0.90, true, colorAmber),
    ];

    // Incommensurable irrational base frequencies
    const freqs = [0.43, 0.53, 0.67, 0.79, 0.89, 0.97, 1.13, 1.27, 1.39, 1.51];

    final generated = <NeuralNetworkNode>[];

    for (int li = 0; li < layerConfigs.length; li++) {
      final (count, centreX, isBC, baseColor) = layerConfigs[li];

      for (int ni = 0; ni < count; ni++) {
        // Distribute top-to-bottom with gentle organic spacing
        final baseY = 0.07 + (ni + 0.5) / count * 0.86;
        final jX = (rng.nextDouble() - 0.5) * 0.05;
        final jY = (rng.nextDouble() - 0.5) * 0.035;

        final fX = freqs[rng.nextInt(freqs.length)];
        final fY = freqs[rng.nextInt(freqs.length)];

        // Calibrated drift amplitudes: calm enough to not distract, organic enough to feel alive
        final depth = 0.70 + rng.nextDouble() * 0.60;

        generated.add(NeuralNetworkNode(
          baseX: (centreX + jX).clamp(0.03, 0.97),
          baseY: (baseY + jY).clamp(0.04, 0.96),
          driftAmpX: 0.005 + rng.nextDouble() * 0.009,
          driftAmpY: 0.007 + rng.nextDouble() * 0.011,
          freqX: fX,
          freqY: fY,
          freqX2: fX * _phi,
          freqY2: fY * _e,
          phaseX: rng.nextDouble() * _tau,
          phaseY: rng.nextDouble() * _tau,
          pulseFreq: 0.75 + rng.nextDouble() * 1.25,
          pulsePhase: rng.nextDouble() * _tau,
          radius: 3.2 + rng.nextDouble() * 2.0,
          color: baseColor,
          signalCycles: 1.1 + rng.nextDouble() * 1.5,
          signalPhase: rng.nextDouble(),
          blockPhase: rng.nextDouble() * 4.2,
          isBlockchain: isBC || (li == 1 && rng.nextDouble() > 0.85),
          layer: li,
          depthPlane: depth,
        ));
      }
    }

    return generated;
  }

  /// Calculates the screen position of node [i] factoring time drift and mouse parallax
  Offset _getNodePosition(int i, Size size) {
    final n = nodes[i];

    // Dual-frequency sinusoidal drift
    final driftX = n.driftAmpX * math.sin(t * _tau * n.freqX + n.phaseX) +
        n.driftAmpX * 0.35 * math.cos(t * _tau * n.freqX2 + n.phaseY);
    final driftY = n.driftAmpY * math.cos(t * _tau * n.freqY + n.phaseY) +
        n.driftAmpY * 0.35 * math.sin(t * _tau * n.freqY2 + n.phaseX);

    // Subtle parallax displacement based on depth plane
    final parallaxX = (parallaxOffset.dx * 14.0 * n.depthPlane) / size.width;
    final parallaxY = (parallaxOffset.dy * 14.0 * n.depthPlane) / size.height;

    final normX = (n.baseX + driftX + parallaxX).clamp(0.02, 0.98);
    final normY = (n.baseY + driftY + parallaxY).clamp(0.03, 0.97);

    return Offset(normX * size.width, normY * size.height);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0 || nodes.isEmpty) return;

    // 1. Calculate positions
    final positions = List<Offset>.generate(
      nodes.length,
      (i) => _getNodePosition(i, size),
      growable: false,
    );

    // 2. Build directional adjacent edges:
    // Every edge (i, j) is strictly sorted such that i is the SOURCE and j is the TARGET.
    // Flow rules:
    //  a) Lower layer -> higher layer (feed-forward tensor flow)
    //  b) Same layer -> top to bottom (vertical cascade)
    const maxDistance = 250.0;
    final edges = <(int, int)>[];

    for (int i = 0; i < nodes.length; i++) {
      for (int j = i + 1; j < nodes.length; j++) {
        final layerDiff = (nodes[i].layer - nodes[j].layer).abs();
        if (layerDiff > 1) continue;

        final d = (positions[i] - positions[j]).distance;
        if (d < maxDistance) {
          // Enforce strict directional ordering: source -> target
          if (nodes[i].layer < nodes[j].layer) {
            edges.add((i, j));
          } else if (nodes[i].layer > nodes[j].layer) {
            edges.add((j, i));
          } else {
            // Same layer: top-to-bottom flow
            if (positions[i].dy <= positions[j].dy) {
              edges.add((i, j));
            } else {
              edges.add((j, i));
            }
          }
        }
      }
    }

    // ── Layered Rendering (Strictly disciplined, high-tech & non-intrusive) ──
    _drawDriftingHexLattice(canvas, size);
    _drawSequentialConsensusChain(canvas, positions);
    _drawDirectionalSynapses(canvas, positions, edges, maxDistance, size);
    _drawDirectionalDataPhotons(canvas, positions, edges);
    _drawBlockchainHexNodes(canvas, positions);
    _drawNeuralNodes(canvas, positions, size);
  }

  /// Sublayer 1: Drifting geometric hex lattice across right side
  void _drawDriftingHexLattice(Canvas canvas, Size size) {
    final hexPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.55
      ..color = colorDeepBlue.withValues(alpha: 0.032);

    const hexRadius = 46.0;
    const dX = hexRadius * 1.5;
    const dY = hexRadius * 1.7320508; // sqrt(3) * R

    final offX = ((t * 0.15 % 1.0) * dX * 2) + (parallaxOffset.dx * 5.0);
    final offY = ((t * 0.09 % 1.0) * dY) + (parallaxOffset.dy * 5.0);

    final startX = size.width * 0.45;

    for (double col = startX - dX + (offX % (dX * 2));
        col < size.width + dX;
        col += dX) {
      final isOdd = (((col - offX) / dX).round()).isOdd;
      for (double row = -dY + (isOdd ? dY / 2 : 0) + (offY % dY);
          row < size.height + dY;
          row += dY) {
        final path = Path();
        for (int k = 0; k < 6; k++) {
          final a = math.pi / 3 * k;
          final px = col + hexRadius * math.cos(a);
          final py = row + hexRadius * math.sin(a);
          k == 0 ? path.moveTo(px, py) : path.lineTo(px, py);
        }
        path.close();
        canvas.drawPath(path, hexPaint);
      }
    }
  }

  /// Sublayer 2: Sequential Ledger Verification Chain (Ordered block consensus validation)
  void _drawSequentialConsensusChain(Canvas canvas, List<Offset> positions) {
    final bcIndices = <int>[];
    for (int i = 0; i < nodes.length; i++) {
      if (nodes[i].isBlockchain && nodes[i].layer == 3) {
        bcIndices.add(i);
      }
    }

    if (bcIndices.length < 2) return;

    // Sort blockchain nodes in strict top-to-bottom sequence
    bcIndices.sort((a, b) => positions[a].dy.compareTo(positions[b].dy));

    final chainPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw chronological ledger links between sequential blocks
    for (int k = 0; k < bcIndices.length - 1; k++) {
      final p1 = positions[bcIndices[k]];
      final p2 = positions[bcIndices[k + 1]];

      // Delicate cryptographic chain trace
      chainPaint
        ..strokeWidth = 0.9
        ..color = colorAmber.withValues(alpha: 0.14);
      canvas.drawLine(p1, p2, chainPaint);
    }

    // Directional consensus laser pulse traveling sequentially down the chain
    final totalSteps = bcIndices.length - 1;
    final sweepProgress = (t * 1.8) % 1.0;
    final currentStep = (sweepProgress * totalSteps).floor().clamp(0, totalSteps - 1);
    final stepFraction = (sweepProgress * totalSteps) - currentStep;

    final pSource = positions[bcIndices[currentStep]];
    final pTarget = positions[bcIndices[currentStep + 1]];

    // Laser verification beam
    final beamProgressPos = Offset.lerp(pSource, pTarget, stepFraction)!;

    chainPaint
      ..strokeWidth = 2.0
      ..color = colorAmber.withValues(alpha: 0.35);
    canvas.drawLine(
      Offset.lerp(pSource, pTarget, (stepFraction - 0.25).clamp(0.0, 1.0))!,
      beamProgressPos,
      chainPaint,
    );

    // Traveling block consensus photon
    final photonPaint = Paint()..style = PaintingStyle.fill;
    photonPaint.color = colorAmber.withValues(alpha: 0.25);
    canvas.drawCircle(beamProgressPos, 6.0, photonPaint);
    photonPaint.color = Colors.white.withValues(alpha: 0.92);
    canvas.drawCircle(beamProgressPos, 1.8, photonPaint);
  }

  /// Sublayer 3: Directional Synaptic Axons with Direction Chevrons & Center-Calm Protection
  void _drawDirectionalSynapses(
    Canvas canvas,
    List<Offset> positions,
    List<(int, int)> edges,
    double maxDistance,
    Size size,
  ) {
    final linePaint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final chevronPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;

    for (final (fromIdx, toIdx) in edges) {
      final p1 = positions[fromIdx];
      final p2 = positions[toIdx];
      final dist = (p1 - p2).distance;
      final distFactor = (1.0 - (dist / maxDistance)).clamp(0.0, 1.0);

      // Determine color theme based on network section
      final Color connectionColor;
      if (nodes[fromIdx].isBlockchain && nodes[toIdx].isBlockchain) {
        connectionColor = colorAmber;
      } else if (nodes[fromIdx].layer == 0) {
        connectionColor = colorCyan;
      } else if (nodes[toIdx].isBlockchain) {
        connectionColor = colorTechBlue;
      } else {
        connectionColor = colorEmerald;
      }

      // Readability protection: calm intensity in the central hero corridor
      final midX = (p1.dx + p2.dx) / 2.0;
      final centerProximity = (1.0 - ((midX / size.width) - 0.5).abs() * 2.2).clamp(0.0, 1.0);
      final centerDamp = 1.0 - (centerProximity * 0.45); // Soften by up to 45% in center

      // Delicate organic breathing
      final breath = math.sin(t * _tau * 0.75 + (fromIdx * 3 + toIdx * 7) * 0.2);
      final alpha = (0.10 + 0.05 * breath) * distFactor * centerDamp;

      // 1. Sleek hairline axon
      linePaint
        ..strokeWidth = 0.95
        ..color = connectionColor.withValues(alpha: alpha);
      canvas.drawLine(p1, p2, linePaint);

      // 2. Directional Chevron Pip (Disciplined flow indicator)
      // Placed at 55% along the path pointing towards target
      if (dist > 70.0) {
        final chevronPos = Offset.lerp(p1, p2, 0.55)!;
        final angle = math.atan2(p2.dy - p1.dy, p2.dx - p1.dx);

        const wingLen = 3.8;
        const wingAngle = 0.52; // ~30 degrees

        final chevronPath = Path()
          ..moveTo(
            chevronPos.dx - wingLen * math.cos(angle - wingAngle),
            chevronPos.dy - wingLen * math.sin(angle - wingAngle),
          )
          ..lineTo(chevronPos.dx, chevronPos.dy)
          ..lineTo(
            chevronPos.dx - wingLen * math.cos(angle + wingAngle),
            chevronPos.dy - wingLen * math.sin(angle + wingAngle),
          );

        chevronPaint.color = connectionColor.withValues(alpha: (alpha * 1.5).clamp(0.0, 0.35));
        canvas.drawPath(chevronPath, chevronPaint);
      }
    }
  }

  /// Sublayer 4: Directional AI Tensor Inference Photons with Streamlined Comet Tails
  void _drawDirectionalDataPhotons(
    Canvas canvas,
    List<Offset> positions,
    List<(int, int)> edges,
  ) {
    final fillPaint = Paint()..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int ei = 0; ei < edges.length; ei++) {
      final (fromIdx, toIdx) = edges[ei];
      final from = positions[fromIdx];
      final to = positions[toIdx];
      final nodeRef = nodes[fromIdx];

      final isBC = nodes[fromIdx].isBlockchain || nodes[toIdx].isBlockchain;
      final Color photonColor = isBC ? colorAmber : (nodeRef.layer == 0 ? colorCyan : colorEmerald);

      final angle = math.atan2(to.dy - from.dy, to.dx - from.dx);

      // Staggered directional propagation
      final rawProg = t * (nodeRef.signalCycles * 0.9) + nodeRef.signalPhase + (ei * 0.61803);
      final prog = rawProg % 1.0;

      final currentPos = Offset.lerp(from, to, prog)!;

      // 1. Streamlined Directional Comet Tail (Aligned perfectly against travel vector)
      const tailLength = 18.0;
      final tailEndPos = Offset(
        currentPos.dx - tailLength * math.cos(angle),
        currentPos.dy - tailLength * math.sin(angle),
      );

      strokePaint
        ..strokeWidth = 1.4
        ..shader = LinearGradient(
          colors: [
            Colors.transparent,
            photonColor.withValues(alpha: 0.25),
            photonColor.withValues(alpha: 0.70),
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(Rect.fromPoints(tailEndPos, currentPos));

      canvas.drawLine(tailEndPos, currentPos, strokePaint);

      // 2. Focused Photon Head (Small, crisp, non-distracting)
      fillPaint.shader = null;
      // Outer subtle halo
      fillPaint.color = photonColor.withValues(alpha: 0.18);
      canvas.drawCircle(currentPos, 4.5, fillPaint);

      // Intense white core photon
      fillPaint.color = Colors.white.withValues(alpha: 0.95);
      canvas.drawCircle(currentPos, 1.6, fillPaint);
    }
  }

  /// Sublayer 5: Directional Hexagonal Blockchain Nodes with Rotating Security Markers
  void _drawBlockchainHexNodes(Canvas canvas, List<Offset> positions) {
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final fillPaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < nodes.length; i++) {
      if (!nodes[i].isBlockchain) continue;

      final n = nodes[i];
      final pos = positions[i];

      // Smooth phased lifecycle
      final phase = (t * 0.14 + n.blockPhase) % 4.0;
      double lifeAlpha = 1.0;
      if (phase < 0.3) {
        lifeAlpha = phase / 0.3;
      } else if (phase > 3.6) {
        lifeAlpha = (4.0 - phase) / 0.4;
      }

      if (lifeAlpha < 0.04) continue;

      // Hexagon Geometry
      const hexR = 11.5;
      final hexPath = Path();
      for (int k = 0; k < 6; k++) {
        final a = (math.pi / 3 * k) - (math.pi / 6);
        final hx = pos.dx + hexR * math.cos(a);
        final hy = pos.dy + hexR * math.sin(a);
        k == 0 ? hexPath.moveTo(hx, hy) : hexPath.lineTo(hx, hy);
      }
      hexPath.close();

      // Soft translucent fill
      fillPaint.color = colorAmber.withValues(alpha: 0.06 * lifeAlpha);
      canvas.drawPath(hexPath, fillPaint);

      // Outer crisp boundary
      strokePaint
        ..strokeWidth = 1.1
        ..color = colorAmber.withValues(alpha: 0.50 * lifeAlpha);
      canvas.drawPath(hexPath, strokePaint);

      // Rotating Cryptographic Verification Arcs (Disciplined directional clockwise rotation)
      final rot = t * _tau * 0.40;
      strokePaint
        ..strokeWidth = 1.3
        ..color = colorAmber.withValues(alpha: 0.70 * lifeAlpha);
      canvas.drawArc(
        Rect.fromCircle(center: pos, radius: 5.5),
        rot,
        math.pi * 0.9,
        false,
        strokePaint,
      );
      canvas.drawArc(
        Rect.fromCircle(center: pos, radius: 5.5),
        rot + math.pi,
        math.pi * 0.9,
        false,
        strokePaint,
      );

      // Expanding Hexagonal Proof-of-Consensus Confirmation Ripple
      if (phase > 0.8 && phase < 3.2) {
        final ringProg = ((phase - 0.8) / 0.85) % 1.0;
        final rippleR = hexR + ringProg * 22.0;

        final ripplePath = Path();
        for (int k = 0; k < 6; k++) {
          final a = (math.pi / 3 * k) - (math.pi / 6);
          final rx = pos.dx + rippleR * math.cos(a);
          final ry = pos.dy + rippleR * math.sin(a);
          k == 0 ? ripplePath.moveTo(rx, ry) : ripplePath.lineTo(rx, ry);
        }
        ripplePath.close();

        strokePaint
          ..strokeWidth = 0.85
          ..color = colorTechBlue.withValues(alpha: (1.0 - ringProg) * 0.22 * lifeAlpha);
        canvas.drawPath(ripplePath, strokePaint);
      }
    }
  }

  /// Sublayer 6: AI Neural Nodes with Dual-Frequency Organic Pulsing & Specular Core
  void _drawNeuralNodes(Canvas canvas, List<Offset> positions, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < nodes.length; i++) {
      final n = nodes[i];
      final pos = positions[i];

      // Readability protection: calm intensity in the central hero corridor
      final centerProximity = (1.0 - ((pos.dx / size.width) - 0.5).abs() * 2.2).clamp(0.0, 1.0);
      final centerDamp = 1.0 - (centerProximity * 0.40);

      // Dual-frequency gentle pulsation
      final p1 = math.sin(t * _tau * n.pulseFreq + n.pulsePhase);
      final p2 = math.sin(t * _tau * n.pulseFreq * _phi + n.pulsePhase + 1.2);
      final pulse = (((p1 + p2 * 0.4) / 1.4) + 1.0) / 2.0;

      // 1. Soft Neon Diffuse Aura (Restrained so it never blurs or clutters foreground)
      paint.color = n.color.withValues(alpha: (0.08 + 0.05 * pulse) * centerDamp);
      canvas.drawCircle(pos, n.radius * 2.5 + pulse * 2.0, paint);

      // 2. High-Tech Concentric Ring
      paint.color = n.color.withValues(alpha: (0.22 + 0.10 * pulse) * centerDamp);
      canvas.drawCircle(pos, n.radius * 1.5, paint);

      // 3. Dense Core
      paint.color = n.color.withValues(alpha: (0.65 + 0.15 * pulse) * centerDamp);
      canvas.drawCircle(pos, n.radius * 0.85, paint);

      // 4. White Center Specular Dot
      paint.color = Colors.white.withValues(alpha: 0.90 * centerDamp);
      canvas.drawCircle(pos, n.radius * 0.32, paint);
    }
  }

  @override
  bool shouldRepaint(covariant NeuralBlockchainBackgroundPainter oldDelegate) {
    return oldDelegate.t != t || oldDelegate.parallaxOffset != parallaxOffset;
  }
}
