import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../painters/neural_blockchain_painter.dart';

/// Interactive high-performance animated background wrapper for the SI-CAKRAWALA Landing Page.
///
/// Encapsulates:
/// 1. Smooth 60 FPS continuous animation loop with aperiodic drift
/// 2. Interactive mouse-parallax sensor with smooth physics-based interpolation
/// 3. Ambient moving light gradient mesh canvas
/// 4. Isolate background rendering using `RepaintBoundary` to prevent scroll repaints
/// 5. Top child slot for glassmorphic cards and tactical navigation
class AnimatedLandingBackground extends StatefulWidget {
  final Widget? child;
  final bool enableParallax;
  final Duration duration;
  final List<NeuralNetworkNode>? customNodes;

  const AnimatedLandingBackground({
    super.key,
    this.child,
    this.enableParallax = true,
    this.duration = const Duration(seconds: 30),
    this.customNodes,
  });

  @override
  State<AnimatedLandingBackground> createState() =>
      _AnimatedLandingBackgroundState();
}

class _AnimatedLandingBackgroundState extends State<AnimatedLandingBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<NeuralNetworkNode> _nodes;

  // Parallax offsets
  Offset _targetParallax = Offset.zero;
  Offset _currentParallax = Offset.zero;

  @override
  void initState() {
    super.initState();

    _nodes = widget.customNodes ?? NeuralBlockchainBackgroundPainter.generateNodes();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();

    // Smoothly damp mouse parallax on each tick
    _controller.addListener(_updateParallax);
  }

  void _updateParallax() {
    if (!widget.enableParallax) return;
    if ((_targetParallax - _currentParallax).distance > 0.001) {
      setState(() {
        _currentParallax = Offset.lerp(_currentParallax, _targetParallax, 0.06)!;
      });
    }
  }

  void _onPointerHover(PointerHoverEvent event, Size size) {
    if (!widget.enableParallax || size.width == 0 || size.height == 0) return;

    // Normalize cursor position around screen center: [-1.0, 1.0]
    final double nx = ((event.position.dx / size.width) - 0.5) * 2.0;
    final double ny = ((event.position.dy / size.height) - 0.5) * 2.0;

    _targetParallax = Offset(nx.clamp(-1.0, 1.0), ny.clamp(-1.0, 1.0));
  }

  void _onPointerExit(PointerExitEvent event) {
    _targetParallax = Offset.zero;
  }

  @override
  void dispose() {
    _controller.removeListener(_updateParallax);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return MouseRegion(
      onHover: (e) => _onPointerHover(e, size),
      onExit: _onPointerExit,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Layer 1: Ambient Light-Mode Gradient Canvas ────────────────────
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF8FAFC), // Clean slate base
                    Color(0xFFF1F5F9),
                    Color(0xFFEFF6FF), // Soft aerospace blue tint
                  ],
                  stops: [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),

          // ── Layer 2: Moving Ambient Energy Orbs ─────────────────────────────
          Positioned.fill(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => CustomPaint(
                  painter: _AmbientOrbsPainter(
                    t: _controller.value,
                    parallaxOffset: _currentParallax,
                  ),
                ),
              ),
            ),
          ),

          // ── Layer 3: Neural-Blockchain Engine Canvas ───────────────────────
          Positioned.fill(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => CustomPaint(
                  painter: NeuralBlockchainBackgroundPainter(
                    t: _controller.value,
                    parallaxOffset: _currentParallax,
                    nodes: _nodes,
                  ),
                ),
              ),
            ),
          ),

          // ── Layer 4: Foreground Glassmorphic Content Slot ───────────────────
          if (widget.child != null)
            Positioned.fill(
              child: widget.child!,
            ),
        ],
      ),
    );
  }
}

/// Dynamic ambient light orbs providing soft atmospheric depth
class _AmbientOrbsPainter extends CustomPainter {
  final double t;
  final Offset parallaxOffset;

  static const double _tau = 2 * math.pi;

  const _AmbientOrbsPainter({
    required this.t,
    required this.parallaxOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // Orb 1 — Vibrant Cyber Cyan (Top Left AI flow)
    final cx1 = size.width * 0.15 + 40 * math.cos(t * _tau * 0.85) + parallaxOffset.dx * 8;
    final cy1 = size.height * 0.22 + 35 * math.sin(t * _tau * 0.85) + parallaxOffset.dy * 8;
    _drawRadialHaze(canvas, Offset(cx1, cy1), 320, const Color(0xFF00F0FF), 0.08);

    // Orb 2 — Emerald Tensor Glow (Center Left)
    final cx2 = size.width * 0.38 + 50 * math.sin(t * _tau * 0.72) + parallaxOffset.dx * 12;
    final cy2 = size.height * 0.60 + 40 * math.cos(t * _tau * 0.72) + parallaxOffset.dy * 12;
    _drawRadialHaze(canvas, Offset(cx2, cy2), 380, const Color(0xFF06D6A0), 0.07);

    // Orb 3 — Amber Cryptographic Haze (Upper Right Blockchain)
    final cx3 = size.width * 0.82 + 45 * math.cos(t * _tau * 0.65) + parallaxOffset.dx * 10;
    final cy3 = size.height * 0.28 + 35 * math.sin(t * _tau * 0.65) + parallaxOffset.dy * 10;
    _drawRadialHaze(canvas, Offset(cx3, cy3), 360, const Color(0xFFF59E0B), 0.08);

    // Orb 4 — Soft Tech Blue (Bottom Right Mesh)
    final cx4 = size.width * 0.75 + 40 * math.sin(t * _tau * 0.92) + parallaxOffset.dx * 14;
    final cy4 = size.height * 0.78 + 30 * math.cos(t * _tau * 0.92) + parallaxOffset.dy * 14;
    _drawRadialHaze(canvas, Offset(cx4, cy4), 340, const Color(0xFF38BDF8), 0.09);
  }

  void _drawRadialHaze(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
    double maxOpacity,
  ) {
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: maxOpacity),
          color.withValues(alpha: maxOpacity * 0.28),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(rect);

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _AmbientOrbsPainter oldDelegate) {
    return oldDelegate.t != t || oldDelegate.parallaxOffset != parallaxOffset;
  }
}
