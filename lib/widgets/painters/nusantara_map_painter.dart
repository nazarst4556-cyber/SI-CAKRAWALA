import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/cyber_node.dart';
import '../../core/theme/app_colors.dart';

class NusantaraMapPainter extends CustomPainter {
  final List<CyberNode> nodes;
  final double animationValue;
  final CyberNode? selectedNode;

  NusantaraMapPainter({
    required this.nodes,
    required this.animationValue,
    this.selectedNode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawOcean(canvas, size);
    _drawGrid(canvas, size);
    _drawCoords(canvas, size);
    _drawIslands(canvas, size);
    _drawLinks(canvas, size);
    _drawNodes(canvas, size);
  }

  void _drawOcean(Canvas canvas, Size s) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, s.width, s.height),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFD6EAF8), Color(0xFFC2DFF5), Color(0xFFB0D4F1)],
        ).createShader(Rect.fromLTWH(0, 0, 1000, 1000)),
    );
  }

  void _drawGrid(Canvas canvas, Size s) {
    final p = Paint()..color = const Color(0x1000838F)..strokeWidth = 0.5;
    for (double x = 0; x < s.width; x += 32) {
      canvas.drawLine(Offset(x, 0), Offset(x, s.height), p);
    }
    for (double y = 0; y < s.height; y += 32) {
      canvas.drawLine(Offset(0, y), Offset(s.width, y), p);
    }
  }

  void _drawCoords(Canvas canvas, Size s) {
    final fs = (min(s.width, s.height) * 0.025).clamp(7.0, 11.0);
    final sty = TextStyle(color: const Color(0x66006D7A), fontSize: fs, fontFamily: 'monospace');
    final longs = ['95\u00b0E', '105\u00b0E', '115\u00b0E', '125\u00b0E', '135\u00b0E', '141\u00b0E'];
    for (int i = 0; i < longs.length; i++) {
      final x = s.width * (i / (longs.length - 1));
      final tp = TextPainter(text: TextSpan(text: longs[i], style: sty), textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, s.height - tp.height - 2));
    }
    final lats = ['6\u00b0N', '0\u00b0', '6\u00b0S', '11\u00b0S'];
    for (int i = 0; i < lats.length; i++) {
      final y = s.height * (i / (lats.length - 1));
      final tp = TextPainter(text: TextSpan(text: lats[i], style: sty), textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(2, y - tp.height / 2));
    }
  }

  void _drawIslands(Canvas canvas, Size s) {
    final fill = Paint()..color = const Color(0xFF9DBD8F)..style = PaintingStyle.fill;
    final stroke = Paint()..color = const Color(0xFF4A8B5A)..style = PaintingStyle.stroke..strokeWidth = 1.0;
    final sf = Paint()..color = const Color(0xFFA4C98C)..style = PaintingStyle.fill;
    final ss = Paint()..color = const Color(0xFF4A8B5A)..style = PaintingStyle.stroke..strokeWidth = 0.8;

    // Sumatera
    _poly(canvas, s, fill, stroke, [
      [0.025,0.18],[0.035,0.12],[0.062,0.14],[0.085,0.18],[0.100,0.22],[0.115,0.30],
      [0.130,0.39],[0.145,0.47],[0.162,0.56],[0.174,0.64],[0.180,0.72],[0.175,0.74],
      [0.162,0.72],[0.148,0.66],[0.132,0.58],[0.117,0.52],[0.102,0.46],[0.088,0.40],
      [0.073,0.34],[0.055,0.26],[0.038,0.20],
    ]);

    // Jawa
    _poly(canvas, s, fill, stroke, [
      [0.174,0.65],[0.198,0.62],[0.224,0.62],[0.253,0.63],[0.284,0.63],[0.310,0.65],
      [0.322,0.68],[0.310,0.72],[0.280,0.73],[0.250,0.73],[0.218,0.73],[0.190,0.71],
    ]);

    // Kalimantan
    _poly(canvas, s, fill, stroke, [
      [0.280,0.27],[0.300,0.19],[0.323,0.16],[0.348,0.16],[0.372,0.18],[0.396,0.22],
      [0.410,0.27],[0.418,0.34],[0.420,0.42],[0.416,0.50],[0.405,0.57],[0.388,0.62],
      [0.362,0.64],[0.335,0.63],[0.310,0.60],[0.292,0.56],[0.280,0.50],[0.273,0.42],
      [0.276,0.34],
    ]);

    // Sulawesi body
    _poly(canvas, s, fill, stroke, [
      [0.452,0.28],[0.468,0.24],[0.480,0.25],[0.488,0.32],[0.488,0.42],[0.486,0.50],
      [0.480,0.54],[0.470,0.56],[0.458,0.54],[0.448,0.48],[0.445,0.40],[0.447,0.33],
    ]);
    // Sulawesi north arm
    _poly(canvas, s, fill, stroke, [
      [0.468,0.28],[0.480,0.22],[0.496,0.20],[0.512,0.21],[0.520,0.24],[0.514,0.27],
      [0.498,0.30],[0.483,0.31],
    ]);
    // Sulawesi east arm
    _poly(canvas, s, fill, stroke, [
      [0.484,0.42],[0.500,0.39],[0.516,0.41],[0.526,0.46],[0.528,0.52],[0.520,0.57],
      [0.508,0.57],[0.496,0.53],[0.488,0.47],
    ]);
    // Sulawesi SE arm
    _poly(canvas, s, fill, stroke, [
      [0.466,0.52],[0.474,0.57],[0.480,0.63],[0.480,0.70],[0.474,0.74],[0.464,0.74],
      [0.458,0.68],[0.458,0.62],[0.462,0.56],
    ]);

    // Papua bird head
    _poly(canvas, s, fill, stroke, [
      [0.640,0.36],[0.648,0.27],[0.662,0.23],[0.680,0.20],[0.700,0.20],[0.718,0.22],
      [0.725,0.27],[0.720,0.33],[0.708,0.40],[0.694,0.46],[0.676,0.48],[0.660,0.46],
      [0.648,0.42],
    ]);
    // Papua body
    _poly(canvas, s, fill, stroke, [
      [0.700,0.40],[0.722,0.36],[0.748,0.35],[0.780,0.34],[0.815,0.34],[0.848,0.36],
      [0.878,0.39],[0.905,0.43],[0.928,0.48],[0.946,0.55],[0.956,0.62],[0.960,0.68],
      [0.955,0.76],[0.944,0.84],[0.928,0.88],[0.908,0.88],[0.886,0.85],[0.858,0.80],
      [0.826,0.75],[0.796,0.70],[0.770,0.65],[0.748,0.60],[0.728,0.56],[0.712,0.52],
      [0.700,0.48],[0.695,0.44],
    ]);

    // Small islands
    void oval(double cx, double cy, double rx, double ry) {
      canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2), sf);
      canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2), ss);
    }
    oval(s.width*0.335, s.height*0.68, s.width*0.022, s.height*0.033); // Bali
    oval(s.width*0.358, s.height*0.69, s.width*0.022, s.height*0.028); // Lombok
    oval(s.width*0.383, s.height*0.70, s.width*0.028, s.height*0.026); // Sumbawa
    oval(s.width*0.413, s.height*0.72, s.width*0.030, s.height*0.022); // Flores
    oval(s.width*0.448, s.height*0.77, s.width*0.036, s.height*0.020); // Timor
    oval(s.width*0.200, s.height*0.60, s.width*0.022, s.height*0.032); // Bangka
    oval(s.width*0.222, s.height*0.61, s.width*0.016, s.height*0.026); // Belitung
    oval(s.width*0.310, s.height*0.22, s.width*0.016, s.height*0.024); // Natuna
    oval(s.width*0.562, s.height*0.27, s.width*0.014, s.height*0.020); // Ternate
    oval(s.width*0.583, s.height*0.31, s.width*0.018, s.height*0.044); // Halmahera
    oval(s.width*0.610, s.height*0.52, s.width*0.018, s.height*0.026); // Ambon
    oval(s.width*0.630, s.height*0.48, s.width*0.030, s.height*0.018); // Seram
    oval(s.width*0.316, s.height*0.62, s.width*0.022, s.height*0.014); // Madura

    // Sea and island labels
    _sea(canvas, 'LAUT JAWA', s.width*0.268, s.height*0.50, s);
    _sea(canvas, 'SELAT MALAKA', s.width*0.096, s.height*0.36, s);
    _sea(canvas, 'LAUT CINA\nSELATAN', s.width*0.218, s.height*0.26, s);
    _sea(canvas, 'LAUT\nSULAWESI', s.width*0.440, s.height*0.22, s);
    _sea(canvas, 'LAUT BANDA', s.width*0.568, s.height*0.61, s);
    _sea(canvas, 'SAMUDRA\nPASIFIK', s.width*0.815, s.height*0.20, s);
    _sea(canvas, 'SAMUDRA HINDIA', s.width*0.200, s.height*0.88, s);
    _sea(canvas, 'LAUT MALUKU', s.width*0.554, s.height*0.40, s);

    _isle(canvas, 'SUMATERA', s.width*0.092, s.height*0.44, s);
    _isle(canvas, 'JAWA', s.width*0.242, s.height*0.76, s);
    _isle(canvas, 'KALIMANTAN', s.width*0.344, s.height*0.40, s);
    _isle(canvas, 'SULAWESI', s.width*0.474, s.height*0.42, s);
    _isle(canvas, 'PAPUA', s.width*0.800, s.height*0.58, s);
    _isle(canvas, 'Bali', s.width*0.335, s.height*0.73, s, small: true);
    _isle(canvas, 'Natuna', s.width*0.310, s.height*0.16, s, small: true);
    _isle(canvas, 'Ambon', s.width*0.608, s.height*0.58, s, small: true);
    _isle(canvas, 'Nusa Tenggara', s.width*0.395, s.height*0.78, s, small: true);
    _isle(canvas, 'Timor', s.width*0.450, s.height*0.83, s, small: true);
  }

  void _poly(Canvas canvas, Size s, Paint fill, Paint stroke, List<List<double>> pts) {
    if (pts.length < 3) return;
    final path = Path();
    path.moveTo(s.width * pts[0][0], s.height * pts[0][1]);
    for (int i = 1; i < pts.length - 1; i++) {
      final mx = s.width * (pts[i][0] + pts[i+1][0]) / 2;
      final my = s.height * (pts[i][1] + pts[i+1][1]) / 2;
      path.quadraticBezierTo(s.width * pts[i][0], s.height * pts[i][1], mx, my);
    }
    path.close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  void _sea(Canvas canvas, String text, double cx, double cy, Size s) {
    final fs = (min(s.width, s.height) * 0.018).clamp(6.0, 10.0);
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: const Color(0x44006699), fontSize: fs, fontFamily: 'monospace')),
      textDirection: TextDirection.ltr, textAlign: TextAlign.center,
    )..layout(maxWidth: s.width * 0.18);
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  void _isle(Canvas canvas, String text, double cx, double cy, Size s, {bool small = false}) {
    final fs = small
        ? (min(s.width, s.height) * 0.019).clamp(6.0, 10.0)
        : (min(s.width, s.height) * 0.024).clamp(7.0, 12.0);
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(
        color: const Color(0x991A3A28), fontSize: fs,
        fontFamily: 'monospace', fontWeight: FontWeight.w700, letterSpacing: small ? 0.5 : 1.0,
      )),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  void _drawLinks(Canvas canvas, Size s) {
    for (int i = 0; i < nodes.length; i++) {
      for (int j = i + 1; j < nodes.length; j++) {
        final p1 = Offset(nodes[i].relativeX * s.width, nodes[i].relativeY * s.height);
        final p2 = Offset(nodes[j].relativeX * s.width, nodes[j].relativeY * s.height);
        if ((p1 - p2).distance < s.width * 0.32) {
          final alpha = 0.10 + 0.06 * sin(animationValue * 2 * pi + i.toDouble());
          canvas.drawLine(p1, p2, Paint()..color = Color.fromRGBO(0, 150, 200, alpha)..strokeWidth = 0.8);
          // Animated data packet
          final t = (animationValue + i * 0.15 + j * 0.07) % 1.0;
          canvas.drawCircle(
            Offset(p1.dx + (p2.dx - p1.dx) * t, p1.dy + (p2.dy - p1.dy) * t),
            1.8, Paint()..color = const Color(0xCC00C6FF),
          );
        }
      }
    }
  }

  void _drawNodes(Canvas canvas, Size s) {
    for (final node in nodes) {
      final c = Offset(node.relativeX * s.width, node.relativeY * s.height);
      final col = node.statusColor;
      final sel = selectedNode?.name == node.name;

      // Pulse rings
      if (node.status != NodeSecurityStatus.safe || sel) {
        final pr = (sel ? 13.0 : 9.0) + (sin(animationValue * 2 * pi) + 1.0) * (sel ? 7.0 : 4.0);
        canvas.drawCircle(c, pr,
          Paint()..color = (sel ? AppColors.cyberCyan : col).withValues(alpha: 0.25)
            ..style = PaintingStyle.stroke..strokeWidth = 1.5);
        canvas.drawCircle(c, pr * 1.7,
          Paint()..color = (sel ? AppColors.cyberCyan : col).withValues(alpha: 0.10)
            ..style = PaintingStyle.stroke..strokeWidth = 0.8);
      }

      // Glow
      canvas.drawCircle(c, sel ? 10 : 7,
        Paint()..color = col.withValues(alpha: sel ? 0.55 : 0.30)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));

      // White ring
      canvas.drawCircle(c, sel ? 9.5 : 6.5, Paint()..color = Colors.white.withValues(alpha: 0.95));
      // Core
      canvas.drawCircle(c, sel ? 7.5 : 5.0, Paint()..color = col);

      // X for danger
      if (node.status == NodeSecurityStatus.danger) {
        final xp = Paint()..color = Colors.white..strokeWidth = 1.5..style = PaintingStyle.stroke;
        canvas.drawLine(c.translate(-2.5, -2.5), c.translate(2.5, 2.5), xp);
        canvas.drawLine(c.translate(2.5, -2.5), c.translate(-2.5, 2.5), xp);
      }

      // Label
      final parts = node.name.split(' - ');
      final label = parts.length >= 2 ? '${parts[0]}\n${parts[1]}' : node.name;
      final fs = (min(s.width, s.height) * 0.026).clamp(8.0, 10.0);
      final tp = TextPainter(
        text: TextSpan(text: label, style: TextStyle(
          color: sel ? AppColors.cyberCyanDeep : AppColors.textPrimary,
          fontSize: sel ? fs + 0.5 : fs,
          fontFamily: 'monospace', fontWeight: sel ? FontWeight.w800 : FontWeight.w600, height: 1.25,
        )),
        textDirection: TextDirection.ltr,
      )..layout();

      final lp = Offset(c.dx + 9, c.dy - 4);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(lp.dx - 3, lp.dy - 2, tp.width + 6, tp.height + 4), const Radius.circular(3)),
        Paint()..color = Colors.white.withValues(alpha: sel ? 0.96 : 0.88),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(lp.dx - 3, lp.dy - 2, tp.width + 6, tp.height + 4), const Radius.circular(3)),
        Paint()..color = (sel ? AppColors.cyberCyan : col).withValues(alpha: 0.50)
          ..style = PaintingStyle.stroke..strokeWidth = 0.8,
      );
      tp.paint(canvas, lp);
    }
  }

  @override
  bool shouldRepaint(covariant NusantaraMapPainter old) =>
      old.animationValue != animationValue || old.selectedNode != selectedNode;
}
