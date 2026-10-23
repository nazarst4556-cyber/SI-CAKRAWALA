import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/theme/app_colors.dart';
import '../../data/indonesia_nodes_data.dart';
import '../../models/province_node.dart';
import 'province_detail_modal.dart';

class NusantaraMapWidget extends StatefulWidget {
  final Function(ProvinceNode)? onNodeSelected;
  final bool isFullScreen;
  final VoidCallback? onToggleFullScreen;

  const NusantaraMapWidget({
    super.key,
    this.onNodeSelected,
    this.isFullScreen = false,
    this.onToggleFullScreen,
  });

  @override
  State<NusantaraMapWidget> createState() => _NusantaraMapWidgetState();
}

class _NusantaraMapWidgetState extends State<NusantaraMapWidget> {
  late final MapController _mapController;
  String _selectedRegion = 'Seluruh Nusantara';
  bool _showMeshLines = true;
  bool _showLabels = true;
  ProvinceNode? _selectedNode;

  static const LatLng _jakartaHub = LatLng(-6.1751, 106.8650);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  void _zoomToRegion(String region) {
    setState(() => _selectedRegion = region);

    LatLng center;
    double zoom;

    switch (region) {
      case 'Sumatera':
        center = const LatLng(0.5, 101.5);
        zoom = 6.0;
        break;
      case 'Jawa':
        center = const LatLng(-7.2, 110.0);
        zoom = 7.0;
        break;
      case 'Bali & Nusa Tenggara':
        center = const LatLng(-8.8, 119.5);
        zoom = 6.8;
        break;
      case 'Kalimantan':
        center = const LatLng(-0.5, 114.5);
        zoom = 6.0;
        break;
      case 'Sulawesi':
        center = const LatLng(-1.5, 121.5);
        zoom = 6.2;
        break;
      case 'Maluku':
        center = const LatLng(-2.5, 128.5);
        zoom = 6.5;
        break;
      case 'Papua':
        center = const LatLng(-3.5, 137.5);
        zoom = 5.8;
        break;
      case 'Seluruh Nusantara':
      default:
        center = const LatLng(-0.7893, 118.9213);
        zoom = 4.7;
        break;
    }

    _mapController.move(center, zoom);
  }

  void _focusOnNode(ProvinceNode node) {
    setState(() => _selectedNode = node);
    _mapController.move(LatLng(node.latitude, node.longitude), 8.5);
    widget.onNodeSelected?.call(node);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Map Canvas
        FlutterMap(
          mapController: _mapController,
          options: const MapOptions(
            initialCenter: LatLng(-0.7893, 118.9213),
            initialZoom: 4.7,
            minZoom: 3.5,
            maxZoom: 18.0,
          ),
          children: [
            // Base Tile Layer (CartoDB Positron / OSM tiles for crisp high-tech look)
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'id.mil.tniad.sicakrawala',
              maxZoom: 19,
            ),

            // Encrypted Polyline Mesh Layer
            if (_showMeshLines)
              PolylineLayer(
                polylines: IndonesiaNodesData.allProvinces.map((node) {
                  final target = LatLng(node.latitude, node.longitude);
                  final isCritical = node.threatLevel == NodeThreatLevel.critical;

                  return Polyline(
                    points: [_jakartaHub, target],
                    strokeWidth: isCritical ? 2.2 : 1.4,
                    color: isCritical
                        ? AppColors.merahVibrant.withValues(alpha: 0.7)
                        : node.threatLevel == NodeThreatLevel.warning
                            ? AppColors.warningAmber.withValues(alpha: 0.6)
                            : AppColors.cyberCyanDeep.withValues(alpha: 0.4),
                  );
                }).toList(),
              ),

            // Marker Layer for 38 Provinces + Border Nodes
            MarkerLayer(
              markers: IndonesiaNodesData.allProvinces.map((node) {
                final isSelected = _selectedNode?.id == node.id;
                final isCritical = node.threatLevel == NodeThreatLevel.critical;

                return Marker(
                  point: LatLng(node.latitude, node.longitude),
                  width: _showLabels ? 130 : 36,
                  height: 48,
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: () {
                      _focusOnNode(node);
                      ProvinceDetailModal.show(
                        context,
                        node,
                        onFocus: () => _focusOnNode(node),
                      );
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Tactical Node Badge
                        Container(
                          width: isSelected ? 22 : 18,
                          height: isSelected ? 22 : 18,
                          decoration: BoxDecoration(
                            color: node.statusColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: isSelected ? 2.5 : 2.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: node.statusColor.withValues(alpha: 0.6),
                                blurRadius: isCritical || isSelected ? 10 : 6,
                                spreadRadius: isSelected ? 3 : 1,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              node.isStrategicBorder ? Icons.star : Icons.shield,
                              size: isSelected ? 11 : 9,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        if (_showLabels) ...[
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.merahVibrant
                                    : node.statusColor.withValues(alpha: 0.5),
                                width: isSelected ? 1.5 : 0.8,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x140F1B2D),
                                  blurRadius: 4,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Text(
                              node.isStrategicBorder
                                  ? '★ ${node.name.split(" ").last}'
                                  : node.name,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                                color: isSelected ? AppColors.merahVibrant : AppColors.textPrimary,
                                fontFamily: 'monospace',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),

        // HUD Top Controls Bar
        Positioned(
          top: 12,
          left: 12,
          right: 12,
          child: Row(
            children: [
              // Region Selector Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.4), width: 1.2),
                  boxShadow: const [
                    BoxShadow(color: Color(0x0F0F1B2D), blurRadius: 8, offset: Offset(0, 2)),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedRegion,
                    icon: const Icon(Icons.arrow_drop_down, color: AppColors.cyberCyanDeep, size: 20),
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    items: IndonesiaNodesData.regions.map((String reg) {
                      return DropdownMenuItem<String>(
                        value: reg,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.map_rounded, size: 14, color: AppColors.merahVibrant),
                            const SizedBox(width: 6),
                            Text(reg),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) _zoomToRegion(val);
                    },
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Filter Toggles
              _buildControlButton(
                icon: Icons.alt_route_rounded,
                label: 'Jaring Enkripsi',
                isActive: _showMeshLines,
                onTap: () => setState(() => _showMeshLines = !_showMeshLines),
              ),
              const SizedBox(width: 8),
              _buildControlButton(
                icon: Icons.label_rounded,
                label: 'Label Node',
                isActive: _showLabels,
                onTap: () => setState(() => _showLabels = !_showLabels),
              ),

              const Spacer(),

              // Fullscreen Toggle Button
              if (widget.onToggleFullScreen != null)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.merahVibrant, width: 1.2),
                    boxShadow: const [
                      BoxShadow(color: Color(0x0F0F1B2D), blurRadius: 8, offset: Offset(0, 2)),
                    ],
                  ),
                  child: IconButton(
                    tooltip: widget.isFullScreen ? 'Tutup Layar Penuh' : 'Perluas Peta Layar Penuh',
                    icon: Icon(
                      widget.isFullScreen ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded,
                      color: AppColors.merahVibrant,
                      size: 22,
                    ),
                    onPressed: widget.onToggleFullScreen,
                  ),
                ),
            ],
          ),
        ),

        // HUD Bottom Right Navigation Buttons (Zoom +, Zoom -, Reset)
        Positioned(
          bottom: 16,
          right: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFloatingZoomButton(
                icon: Icons.add,
                tooltip: 'Perbesar Peta (Zoom In)',
                onTap: () {
                  final cur = _mapController.camera.zoom;
                  _mapController.move(_mapController.camera.center, cur + 1.0);
                },
              ),
              const SizedBox(height: 6),
              _buildFloatingZoomButton(
                icon: Icons.remove,
                tooltip: 'Perkecil Peta (Zoom Out)',
                onTap: () {
                  final cur = _mapController.camera.zoom;
                  _mapController.move(_mapController.camera.center, cur - 1.0);
                },
              ),
              const SizedBox(height: 6),
              _buildFloatingZoomButton(
                icon: Icons.my_location_rounded,
                tooltip: 'Pusatkan Seluruh Nusantara',
                onTap: () => _zoomToRegion('Seluruh Nusantara'),
              ),
            ],
          ),
        ),

        // HUD Bottom Left Legend
        Positioned(
          bottom: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.35), width: 1),
              boxShadow: const [
                BoxShadow(color: Color(0x0A0F1B2D), blurRadius: 6, offset: Offset(0, 2)),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLegendItem('Aman (31)', AppColors.tniGreenMid),
                const SizedBox(width: 8),
                _buildLegendItem('Waspada (5)', AppColors.warningAmber),
                const SizedBox(width: 8),
                _buildLegendItem('Serangan (3)', AppColors.merahVibrant),
                const SizedBox(width: 8),
                _buildLegendItem('Pamtas (★)', AppColors.goldInsignia),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? AppColors.merahVibrant.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? AppColors.merahVibrant : AppColors.glassBorder.withValues(alpha: 0.35),
            width: 1.2,
          ),
          boxShadow: const [
            BoxShadow(color: Color(0x0A0F1B2D), blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive ? AppColors.merahVibrant : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                color: isActive ? AppColors.merahVibrant : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingZoomButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.35), width: 1.2),
        boxShadow: const [
          BoxShadow(color: Color(0x0F0F1B2D), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: IconButton(
        tooltip: tooltip,
        icon: Icon(icon, size: 18, color: AppColors.textPrimary),
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        padding: EdgeInsets.zero,
        onPressed: onTap,
      ),
    );
  }
}
