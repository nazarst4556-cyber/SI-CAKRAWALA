import 'package:flutter/material.dart';
import '../models/cyber_node.dart';
import '../models/threat_incident.dart';
import '../state/command_center_controller.dart';
import '../core/theme/app_colors.dart';
import '../widgets/common/liquid_glass_card.dart';
import '../widgets/common/tactical_badge.dart';
import '../widgets/painters/nusantara_map_painter.dart';
import '../widgets/map/nusantara_map_widget.dart';
import '../widgets/terminal/cyber_command_console.dart';
import '../widgets/radar/radar_control_panel.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardView extends StatefulWidget {
  final CommandCenterController controller;
  const DashboardView({super.key, required this.controller});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final TextEditingController _cmdInput = TextEditingController();
  CyberNode? _selectedNode;
  bool _useGisMap = true;

  void _openFullscreenMap(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog.fullscreen(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 1,
            leading: IconButton(
              icon: const Icon(Icons.close, color: AppColors.textPrimary),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.merahVibrant.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.map_rounded, color: AppColors.merahVibrant, size: 20),
                ),
                const SizedBox(width: 10),
                const Text(
                  'PETA TAKTIS NUSANTARA — 38 PROVINSI & POS PAMTAS RI (MODE LAYAR PENUH)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          body: NusantaraMapWidget(
            isFullScreen: true,
            onToggleFullScreen: () => Navigator.of(ctx).pop(),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    _cmdInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([widget.controller, _animController]),
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 900;
            final medium = constraints.maxWidth >= 600;
            return SingleChildScrollView(
              padding: EdgeInsets.all(wide ? 16 : medium ? 12 : 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── MAP + RADAR ROW ─────────────────────────────────────────
                  _buildMapAndRadarRow(context, wide, medium),
                  SizedBox(height: wide ? 16 : 10),
                  // ── SELECTED NODE DETAIL PANEL ─────────────────────────────
                  if (_selectedNode != null)
                    _buildNodeDetailPanel(_selectedNode!, wide),
                  if (_selectedNode != null) SizedBox(height: wide ? 16 : 10),
                  // ── BOTTOM ROW ─────────────────────────────────────────────
                  _buildBottomRow(context, wide, medium),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // MAP + RADAR
  Widget _buildMapAndRadarRow(BuildContext ctx, bool wide, bool medium) {
    final mapCard = _buildMapCard(ctx, wide);
    final radarCard = _buildRadarColumn();

    if (wide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 7, child: mapCard),
          const SizedBox(width: 16),
          Expanded(flex: 4, child: radarCard),
        ],
      );
    }
    return Column(children: [mapCard, const SizedBox(height: 10), radarCard]);
  }

  // ── MAP CARD ────────────────────────────────────────────────────────────
  Widget _buildMapCard(BuildContext ctx, bool wide) {
    return LiquidGlassCard(
      title: _useGisMap
          ? 'PETA TAKTIS 38 PROVINSI & POS PAMTAS'
          : 'PETA OPERASIONAL SIBER — NUSANTARA',
      icon: Icons.map_outlined,
      trailing: Wrap(
        spacing: 6,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Mode Toggle Button
          InkWell(
            onTap: () => setState(() => _useGisMap = !_useGisMap),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _useGisMap
                    ? AppColors.merahVibrant.withValues(alpha: 0.12)
                    : AppColors.cyberCyanDeep.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _useGisMap ? AppColors.merahVibrant : AppColors.cyberCyanDeep,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _useGisMap ? Icons.layers_rounded : Icons.gesture_rounded,
                    size: 13,
                    color: _useGisMap ? AppColors.merahVibrant : AppColors.cyberCyanDeep,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _useGisMap ? 'PETA SATELIT' : 'VEKTOR RADAR',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: _useGisMap ? AppColors.merahVibrant : AppColors.cyberCyanDeep,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Fullscreen expand button
          IconButton(
            tooltip: 'Buka Peta Layar Penuh (Zoom Desa & Kota)',
            icon: const Icon(Icons.fullscreen_rounded, color: AppColors.textPrimary, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            onPressed: () => _openFullscreenMap(ctx),
          ),
          const TacticalBadge(label: '● 38 PROV', type: BadgeType.live),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_useGisMap)
            SizedBox(
              height: wide ? 460 : 380,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: NusantaraMapWidget(
                  onToggleFullScreen: () => _openFullscreenMap(ctx),
                ),
              ),
            )
          else ...[
            // Map canvas — responsive height
            LayoutBuilder(builder: (ctx, c) {
              final h = (c.maxWidth * 0.55).clamp(200.0, 440.0);
              return SizedBox(
                height: h,
                child: GestureDetector(
                  onTapUp: (details) => _handleMapTap(details.localPosition, c.maxWidth, h),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedBuilder(
                      animation: _animController,
                      builder: (_, _) => CustomPaint(
                        size: Size.infinite,
                        painter: NusantaraMapPainter(
                          nodes: widget.controller.nodes,
                          animationValue: _animController.value,
                          selectedNode: _selectedNode,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 10),
            _buildMapLegend(),
            const SizedBox(height: 8),
            _buildNodeQuickList(),
          ],
        ],
      ),
    );
  }

  void _handleMapTap(Offset tapPos, double canvasW, double canvasH) {
    for (final node in widget.controller.nodes) {
      final nodePos = Offset(node.relativeX * canvasW, node.relativeY * canvasH);
      if ((tapPos - nodePos).distance < 22) {
        setState(() {
          _selectedNode = (_selectedNode?.name == node.name) ? null : node;
        });
        return;
      }
    }
    setState(() => _selectedNode = null);
  }

  Widget _buildMapLegend() {
    return Wrap(
      spacing: 16, runSpacing: 6,
      children: [
        _legendItem(AppColors.tniGreenNeon, 'AMAN'),
        _legendItem(AppColors.warningAmber, 'WASPADA'),
        _legendItem(AppColors.merahNeon, 'BAHAYA'),
        _legendItem(AppColors.cyberCyan, 'DIPILIH', dashed: true),
      ],
    );
  }

  Widget _legendItem(Color color, String label, {bool dashed = false}) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 12, height: 12,
        decoration: BoxDecoration(
          color: dashed ? Colors.transparent : color,
          shape: BoxShape.circle,
          border: Border.all(color: color, width: dashed ? 2 : 0),
        ),
      ),
      const SizedBox(width: 5),
      Text(label, style: GoogleFonts.orbitron(fontSize: 9, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
    ]);
  }

  Widget _buildNodeQuickList() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: widget.controller.nodes.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (ctx, i) {
          final node = widget.controller.nodes[i];
          final isSel = _selectedNode?.name == node.name;
          return Semantics(
            label: '${node.name}, Status: ${_statusLabel(node.status)}',
            button: true,
            child: GestureDetector(
              onTap: () => setState(() => _selectedNode = isSel ? null : node),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isSel ? AppColors.cyberCyan.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSel ? AppColors.cyberCyan : node.statusColor.withValues(alpha: 0.5),
                    width: isSel ? 1.5 : 1.0,
                  ),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 7, height: 7,
                    decoration: BoxDecoration(color: node.statusColor, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    node.name.split(' - ').first,
                    style: GoogleFonts.orbitron(
                      fontSize: 8.5,
                      color: isSel ? AppColors.cyberCyanDeep : AppColors.textPrimary,
                      fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ]),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── NODE DETAIL PANEL ───────────────────────────────────────────────────
  Widget _buildNodeDetailPanel(CyberNode node, bool wide) {
    return Semantics(
      label: 'Detail node: ${node.name}',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.cyberCyan.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cyberCyan.withValues(alpha: 0.4), width: 1.2),
            boxShadow: [BoxShadow(color: AppColors.cyberCyan.withValues(alpha: 0.08), blurRadius: 12)],
          ),
          child: LayoutBuilder(builder: (_, c) {
            final cols = c.maxWidth > 600 ? 4 : 2;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: node.statusColor, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      node.name,
                      style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: 1),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _selectedNode = null),
                    child: const Icon(Icons.close_rounded, size: 18, color: AppColors.textMuted),
                  ),
                ]),
                const SizedBox(height: 10),
                GridView.count(
                  crossAxisCount: cols,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: cols > 2 ? 2.8 : 2.0,
                  mainAxisSpacing: 8, crossAxisSpacing: 8,
                  children: [
                    _detailTile('IP ADDRESS', node.ipAddress, Icons.router_outlined, AppColors.cyberCyan),
                    _detailTile('STATUS', _statusLabel(node.status), Icons.shield_outlined, node.statusColor),
                    _detailTile('SEKTOR', node.name.split(' - ').last, Icons.location_on_outlined, AppColors.tniGreenNeon),
                    _detailTile('KOORDINAT', '${(node.relativeX * 46 + 95).toStringAsFixed(1)}°E\n${(-(node.relativeY * 17 - 6)).toStringAsFixed(1)}°', Icons.my_location, AppColors.goldInsignia),
                  ],
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _detailTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text(label, style: GoogleFonts.orbitron(fontSize: 7.5, color: AppColors.textMuted, letterSpacing: 0.5)),
            Text(value, style: GoogleFonts.shareTechMono(fontSize: 10, color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
          ]),
        ),
      ]),
    );
  }

  String _statusLabel(NodeSecurityStatus s) {
    switch (s) {
      case NodeSecurityStatus.safe: return 'AMAN';
      case NodeSecurityStatus.warning: return 'WASPADA';
      case NodeSecurityStatus.danger: return 'BAHAYA';
    }
  }

  // ── RADAR + KPI ─────────────────────────────────────────────────────────
  Widget _buildRadarColumn() {
    return const RadarControlPanel();
  }



  // ── BOTTOM ROW ───────────────────────────────────────────────────────────
  Widget _buildBottomRow(BuildContext ctx, bool wide, bool medium) {
    final timeline = _buildTimelineCard();
    final threats = _buildThreatsCard();
    final console = _buildConsoleCard();

    if (wide) {
      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(flex: 4, child: timeline),
        const SizedBox(width: 12),
        Expanded(flex: 4, child: threats),
        const SizedBox(width: 12),
        Expanded(flex: 4, child: console),
      ]);
    }
    if (medium) {
      return Column(children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: timeline),
          const SizedBox(width: 12),
          Expanded(child: threats),
        ]),
        const SizedBox(height: 10),
        console,
      ]);
    }
    return Column(children: [
      timeline,
      const SizedBox(height: 10),
      threats,
      const SizedBox(height: 10),
      console,
    ]);
  }

  Widget _buildTimelineCard() {
    return LiquidGlassCard(
      title: 'TIMELINE INSIDEN SIBER',
      icon: Icons.timeline,
      trailing: const TacticalBadge(label: 'REAL-TIME', type: BadgeType.live),
      child: SizedBox(
        height: 230,
        child: ListView.separated(
          itemCount: widget.controller.incidents.length,
          separatorBuilder: (_, _) => const Divider(color: Color(0x1A64748B), height: 12),
          itemBuilder: (_, idx) {
            final inc = widget.controller.incidents[idx];
            return Semantics(
              label: '${inc.severity.name.toUpperCase()} — ${inc.title}: ${inc.description}',
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  margin: const EdgeInsets.only(top: 4, right: 10),
                  width: 9, height: 9,
                  decoration: BoxDecoration(
                    color: inc.severity == ThreatSeverity.critical
                        ? AppColors.merahNeon
                        : inc.severity == ThreatSeverity.high
                            ? AppColors.warningAmber
                            : AppColors.tniGreenNeon,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(
                      color: (inc.severity == ThreatSeverity.critical ? AppColors.merahNeon : AppColors.warningAmber).withValues(alpha: 0.4),
                      blurRadius: 4,
                    )],
                  ),
                ),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    '${inc.timestamp} — ${inc.title}',
                    style: GoogleFonts.orbitron(fontSize: 9.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(inc.description, style: GoogleFonts.exo2(fontSize: 10, color: AppColors.textSecondary, height: 1.3)),
                ])),
              ]),
            );
          },
        ),
      ),
    );
  }

  Widget _buildThreatsCard() {
    return LiquidGlassCard(
      title: 'ANCAMAN AKTIF PRIORITAS',
      icon: Icons.warning_amber_rounded,
      trailing: const TacticalBadge(label: 'PRIORITAS', type: BadgeType.critical),
      child: SizedBox(
        height: 230,
        child: Column(children: [
          _threatTile('APT-29 LATERAL MOVEMENT', 94, 'Sasaran: Database Taktis Kodam VI | Status: Diblokir AI'),
          const SizedBox(height: 8),
          _threatTile('SYN-FLOOD DDOS ATTACK', 82, 'Sasaran: Relay Server Tarakan | Status: Mitigasi Otomatis'),
          const SizedBox(height: 8),
          _threatTile('ZERO-DAY EXPLOIT ATTEMPT', 76, 'Sasaran: Radio Gateway UHF | Status: Karantina Sandbox'),
        ]),
      ),
    );
  }

  Widget _threatTile(String title, int score, String meta) {
    final scoreColor = score >= 90 ? AppColors.merahNeon : score >= 75 ? AppColors.warningAmber : AppColors.tniGreenNeon;
    return Semantics(
      label: '$title, Skor risiko $score dari 100. $meta',
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.merahIndonesia.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.merahIndonesia.withValues(alpha: 0.35), width: 0.8),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
              child: Text(title,
                style: GoogleFonts.orbitron(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.merahIndonesia),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: scoreColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
              child: Text('$score/100', style: GoogleFonts.shareTechMono(fontSize: 9, color: scoreColor, fontWeight: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: 4),
          // Score bar
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: score / 100,
              minHeight: 3,
              backgroundColor: AppColors.backgroundShade,
              valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
            ),
          ),
          const SizedBox(height: 5),
          Text(meta, style: GoogleFonts.exo2(fontSize: 9, color: AppColors.textSecondary, height: 1.3)),
        ]),
      ),
    );
  }

  Widget _buildConsoleCard() {
    return CyberCommandConsole(
      controller: widget.controller,
      height: 290,
    );
  }
}
