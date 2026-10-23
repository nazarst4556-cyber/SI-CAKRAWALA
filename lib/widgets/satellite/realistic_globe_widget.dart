// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../common/tactical_badge.dart';

class GeospatialLocation {
  final String name;
  final String category; // 'strategic', 'ocean', 'continent', 'country'
  final double lat;
  final double lon;
  final double zoom;
  final String description;
  final Color badgeColor;

  const GeospatialLocation({
    required this.name,
    required this.category,
    required this.lat,
    required this.lon,
    required this.zoom,
    required this.description,
    required this.badgeColor,
  });
}

/// Interactive 3D Real Earth Globe with Hierarchical Geospatial Indexing,
/// Level-Of-Detail (LOD) zoom rendering, and Search & Fly-To controller.
class RealisticGlobeWidget extends StatefulWidget {
  final double height;
  final VoidCallback? onExpand;

  const RealisticGlobeWidget({
    super.key,
    this.height = 560,
    this.onExpand,
  });

  @override
  State<RealisticGlobeWidget> createState() => _RealisticGlobeWidgetState();
}

class _RealisticGlobeWidgetState extends State<RealisticGlobeWidget> {
  static const String _viewTypeId = 'tactical-3d-globe-view';
  static bool _isRegistered = false;

  bool _showFootprint = true;
  bool _showOrbits = true;
  bool _showLabels = true;
  double _speedMultiplier = 1.0;

  // Search & Fly-To State
  String _selectedCategory = 'SEMUA';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  GeospatialLocation? _activeTargetLocation;

  // Comprehensive Geospatial Index Database
  static const List<GeospatialLocation> _locations = [
    // ── ZONA STRATEGIS & PERTAHANAN INDONESIA ──
    GeospatialLocation(
      name: "KEP. NATUNA (PAMTAS UTARA)",
      category: "strategic",
      lat: 3.9,
      lon: 108.3,
      zoom: 12.0,
      description: "Pamtas Laut Natuna Utara • Wilayah Yurisdiksi Gas Alam & ZEE",
      badgeColor: AppColors.merahVibrant,
    ),
    GeospatialLocation(
      name: "IKN NUSANTARA (PUSAT C2)",
      category: "strategic",
      lat: -0.97,
      lon: 116.7,
      zoom: 12.0,
      description: "Pusat Komando Strategis Ibukota Nusantara • Kodam VI/MLW",
      badgeColor: AppColors.cyberCyanDeep,
    ),
    GeospatialLocation(
      name: "BLOK AMBALAT (SEKTOR LAUT)",
      category: "strategic",
      lat: 4.2,
      lon: 118.5,
      zoom: 12.0,
      description: "Sektor Patroli Maritim Bersama Laut Sulawesi • Pamtas RI-MY",
      badgeColor: AppColors.merahVibrant,
    ),
    GeospatialLocation(
      name: "SELAT MAKASSAR (ALKI II)",
      category: "strategic",
      lat: -1.5,
      lon: 118.5,
      zoom: 13.0,
      description: "Alur Laut Kepulauan Indonesia II • Koridor Kapal Selam Strategis",
      badgeColor: AppColors.cyberCyanDeep,
    ),
    GeospatialLocation(
      name: "SABANG (POS ALFA TITIK NOL)",
      category: "strategic",
      lat: 5.9,
      lon: 95.3,
      zoom: 12.5,
      description: "Pos Pengamatan Terdepan Samudra Hindia & Pintu Barat Selat Malaka",
      badgeColor: AppColors.warningAmber,
    ),
    GeospatialLocation(
      name: "MERAUKE (SEKTOR DELTA)",
      category: "strategic",
      lat: -8.5,
      lon: 140.4,
      zoom: 12.5,
      description: "Pamtas Darat & Rawa Sektor Timur • Perbatasan RI-Papua Nugini",
      badgeColor: AppColors.warningAmber,
    ),
    GeospatialLocation(
      name: "BIAK NUMFOR (PANGKALAN UDARA)",
      category: "strategic",
      lat: -1.0,
      lon: 136.0,
      zoom: 12.5,
      description: "Pangkalan Udara Terpadu Satelit & Pengawasan Pasifik Utara",
      badgeColor: AppColors.cyberCyanDeep,
    ),
    GeospatialLocation(
      name: "MABES SATBER AD (JAKARTA)",
      category: "strategic",
      lat: -6.2,
      lon: 106.85,
      zoom: 12.0,
      description: "Pusat Komando Operasi Siber & Pengendalian Jaringan Pertahanan",
      badgeColor: AppColors.merahVibrant,
    ),
    GeospatialLocation(
      name: "TARAKAN (KODAM VI)",
      category: "strategic",
      lat: 3.3,
      lon: 117.6,
      zoom: 12.5,
      description: "Pangkalan Depan Sektor Utara Kalimantan & Pengamanan Alur Laut",
      badgeColor: AppColors.warningAmber,
    ),
    GeospatialLocation(
      name: "BATAM (HUB SIBER KABEL LAUT)",
      category: "strategic",
      lat: 1.1,
      lon: 104.0,
      zoom: 12.5,
      description: "Landing Station Kabel Serat Optik Bawah Laut & Gate Telekomunikasi",
      badgeColor: AppColors.cyberCyanDeep,
    ),

    // ── SAMUDRA & LAUT UTAMA (HYDROGRAPHY) ──
    GeospatialLocation(
      name: "SAMUDRA PASIFIK",
      category: "ocean",
      lat: 5.0,
      lon: 165.0,
      zoom: 19.5,
      description: "Samudra Terluas Dunia • Koridor Maritim Asia-Pasifik",
      badgeColor: AppColors.cyberCyan,
    ),
    GeospatialLocation(
      name: "SAMUDRA HINDIA",
      category: "ocean",
      lat: -15.0,
      lon: 80.0,
      zoom: 19.5,
      description: "Samudra Selatan Nusantara • Jalur Energi & Perdagangan Global",
      badgeColor: AppColors.cyberCyan,
    ),
    GeospatialLocation(
      name: "SAMUDRA ATLANTIK",
      category: "ocean",
      lat: 18.0,
      lon: -35.0,
      zoom: 20.0,
      description: "Samudra Atlantik Penghubung Eurasia & Benua Amerika",
      badgeColor: AppColors.cyberCyan,
    ),
    GeospatialLocation(
      name: "SAMUDRA ARKTIK",
      category: "ocean",
      lat: 82.0,
      lon: 0.0,
      zoom: 20.0,
      description: "Wilayah Kutub Utara • Lapisan Es & Rute Navigasi Arktik",
      badgeColor: AppColors.cyberCyan,
    ),
    GeospatialLocation(
      name: "LAUT CINA SELATAN",
      category: "ocean",
      lat: 13.0,
      lon: 114.0,
      zoom: 15.0,
      description: "Perairan Strategis Internasional • Wilayah Klaim Tumpang Tindih",
      badgeColor: AppColors.cyberCyanDeep,
    ),
    GeospatialLocation(
      name: "SELAT MALAKA",
      category: "ocean",
      lat: 2.8,
      lon: 101.5,
      zoom: 14.0,
      description: "Chokepoint Pelayaran Global Terpadat Dunia (100.000+ Kapal/Tahun)",
      badgeColor: AppColors.cyberCyanDeep,
    ),
    GeospatialLocation(
      name: "LAUT JAWA",
      category: "ocean",
      lat: -5.5,
      lon: 112.0,
      zoom: 14.5,
      description: "Perairan Pedalaman Nusantara Penghubung Jawa, Sumatera & Kalimantan",
      badgeColor: AppColors.cyberCyanDeep,
    ),
    GeospatialLocation(
      name: "LAUT BANDA",
      category: "ocean",
      lat: -5.0,
      lon: 127.5,
      zoom: 14.5,
      description: "Cekungan Laut Dalam Kepulauan Maluku • Wilayah Seismik Aktif",
      badgeColor: AppColors.cyberCyanDeep,
    ),

    // ── BENUA (TOPOGRAPHY MACRO) ──
    GeospatialLocation(
      name: "BENUA ASIA",
      category: "continent",
      lat: 34.0,
      lon: 100.0,
      zoom: 20.0,
      description: "Benua Terbesar Dunia • Pusat Kekuatan Geopolitik Eurasia",
      badgeColor: AppColors.goldInsignia,
    ),
    GeospatialLocation(
      name: "BENUA EROPA",
      category: "continent",
      lat: 54.0,
      lon: 18.0,
      zoom: 20.0,
      description: "Kawasan Regional Eropa & Aliansi Pertahanan Atlantik",
      badgeColor: AppColors.goldInsignia,
    ),
    GeospatialLocation(
      name: "BENUA AFRIKA",
      category: "continent",
      lat: 2.0,
      lon: 20.0,
      zoom: 20.0,
      description: "Kawasan Benua Afrika • Jalur Terusan Suez & Tanduk Afrika",
      badgeColor: AppColors.goldInsignia,
    ),
    GeospatialLocation(
      name: "BENUA AUSTRALIA & OSEANIA",
      category: "continent",
      lat: -25.0,
      lon: 135.0,
      zoom: 20.0,
      description: "Tetangga Selatan Indonesia • Kawasan Pasifik Barat Daya",
      badgeColor: AppColors.goldInsignia,
    ),
    GeospatialLocation(
      name: "BENUA AMERIKA UTARA",
      category: "continent",
      lat: 45.0,
      lon: -100.0,
      zoom: 20.0,
      description: "Kawasan Amerika Utara (AS, Kanada, Meksiko)",
      badgeColor: AppColors.goldInsignia,
    ),
    GeospatialLocation(
      name: "BENUA AMERIKA SELATAN",
      category: "continent",
      lat: -15.0,
      lon: -60.0,
      zoom: 20.0,
      description: "Kawasan Amerika Latin & Cekungan Amazon",
      badgeColor: AppColors.goldInsignia,
    ),

    // ── NEGARA MITRA & REGIONAL ASEAN ──
    GeospatialLocation(
      name: "INDONESIA [JAKARTA]",
      category: "country",
      lat: -6.2,
      lon: 106.8,
      zoom: 13.5,
      description: "Negara Kepulauan Terbesar Dunia • 17.508 Pulau • Mabes TNI AD",
      badgeColor: AppColors.tniGreenNeon,
    ),
    GeospatialLocation(
      name: "MALAYSIA [KUALA LUMPUR]",
      category: "country",
      lat: 3.1,
      lon: 101.7,
      zoom: 14.0,
      description: "Mitra Perbatasan Pamtas Kalimantan & Selat Malaka",
      badgeColor: AppColors.tniGreenMid,
    ),
    GeospatialLocation(
      name: "SINGAPURA",
      category: "country",
      lat: 1.35,
      lon: 103.8,
      zoom: 13.5,
      description: "Hub Finansial & Keamanan Maritim Selat Singapura",
      badgeColor: AppColors.tniGreenMid,
    ),
    GeospatialLocation(
      name: "FILIPINA [MANILA]",
      category: "country",
      lat: 14.6,
      lon: 121.0,
      zoom: 14.5,
      description: "Mitra Perjanjian Trilateral Patroli Laut Sulu-Sulawesi",
      badgeColor: AppColors.tniGreenMid,
    ),
    GeospatialLocation(
      name: "VIETNAM [HANOI]",
      category: "country",
      lat: 21.0,
      lon: 105.8,
      zoom: 14.5,
      description: "Mitra Perbatasan Landas Kontinen ZEE Laut Natuna Utara",
      badgeColor: AppColors.tniGreenMid,
    ),
    GeospatialLocation(
      name: "TIONGKOK [BEIJING]",
      category: "country",
      lat: 39.9,
      lon: 116.4,
      zoom: 16.0,
      description: "Kawasan Asia Timur • Pemantauan Aktivitas Radar Satelit",
      badgeColor: AppColors.tniGreenMid,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _registerViewFactory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _registerViewFactory() {
    if (!_isRegistered) {
      ui_web.platformViewRegistry.registerViewFactory(_viewTypeId, (int viewId) {
        final container = html.DivElement()
          ..id = 'tactical-globe-container-$viewId'
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.backgroundColor = '#020712'
          ..style.cursor = 'grab'
          ..style.userSelect = 'none';

        html.window.requestAnimationFrame((_) {
          try {
            if (js.context.hasProperty('initTacticalGlobe')) {
              js.context.callMethod('initTacticalGlobe', [container.id]);
            }
          } catch (e) {
            debugPrint("Tactical 3D Globe WebGL Init Error: $e");
          }
        });

        return container;
      });
      _isRegistered = true;
    }
  }

  void _flyTo(GeospatialLocation loc) {
    setState(() {
      _activeTargetLocation = loc;
    });

    try {
      if (js.context.hasProperty('flyToTacticalLocation')) {
        js.context.callMethod('flyToTacticalLocation', [loc.lat, loc.lon, loc.zoom]);
      }
    } catch (_) {}
  }

  void _resetToNatuna() {
    final natuna = _locations.firstWhere((l) => l.name.contains("NATUNA"));
    _flyTo(natuna);
  }

  void _zoom(double delta) {
    try {
      if (js.context.hasProperty('zoomTacticalGlobe')) {
        js.context.callMethod('zoomTacticalGlobe', [delta]);
      }
    } catch (_) {}
  }

  void _setSpeed(double speed) {
    setState(() {
      _speedMultiplier = speed;
    });
    try {
      if (js.context.hasProperty('setTacticalGlobeSpeed')) {
        js.context.callMethod('setTacticalGlobeSpeed', [speed]);
      }
    } catch (_) {}
  }

  void _toggleOrbits() {
    setState(() {
      _showOrbits = !_showOrbits;
    });
    try {
      if (js.context.hasProperty('toggleTacticalGlobeOrbits')) {
        js.context.callMethod('toggleTacticalGlobeOrbits', [_showOrbits]);
      }
    } catch (_) {}
  }

  void _toggleFootprint() {
    setState(() {
      _showFootprint = !_showFootprint;
    });
    try {
      if (js.context.hasProperty('toggleTacticalGlobeFootprint')) {
        js.context.callMethod('toggleTacticalGlobeFootprint', [_showFootprint]);
      }
    } catch (_) {}
  }

  void _toggleLabels() {
    setState(() {
      _showLabels = !_showLabels;
    });
    try {
      if (js.context.hasProperty('toggleTacticalGlobeLabels')) {
        js.context.callMethod('toggleTacticalGlobeLabels', [_showLabels]);
      }
    } catch (_) {}
  }

  List<GeospatialLocation> get _filteredLocations {
    return _locations.where((l) {
      final matchesCategory = _selectedCategory == 'SEMUA' ||
          (_selectedCategory == 'ZONA STRATEGIS NKRI' && l.category == 'strategic') ||
          (_selectedCategory == 'SAMUDRA & LAUT' && l.category == 'ocean') ||
          (_selectedCategory == 'BENUA' && l.category == 'continent') ||
          (_selectedCategory == 'NEGARA ASEAN' && l.category == 'country');

      final matchesQuery = _searchQuery.isEmpty ||
          l.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          l.description.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesCategory && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF020712),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.4), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F00C6FF),
            blurRadius: 18,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // ── Real Earth 3D WebGL Canvas via HtmlElementView ──────────────
            const Positioned.fill(
              child: HtmlElementView(viewType: _viewTypeId),
            ),

            // ── Top-Center: Interactive Search & Fly-To Controller ──────────
            Positioned(
              top: 14,
              left: 14,
              right: 14,
              child: _buildSearchAndFlyToBar(),
            ),

            // ── Active Target Lock Notification Banner ──────────────────────
            if (_activeTargetLocation != null)
              Positioned(
                top: 76,
                left: 14,
                child: _buildTargetLocationBanner(_activeTargetLocation!),
              ),

            // ── Floating Zoom & Reset Natuna Controls (Right-side HUD) ──────
            Positioned(
              top: 135,
              right: 14,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.82),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.cyberCyan.withValues(alpha: 0.45)),
                  boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 8)],
                ),
                child: Column(
                  children: [
                    _buildZoomBtn(Icons.add, "Perbesar (Zoom In / LOD Micro)", () => _zoom(-2.0)),
                    Container(width: 24, height: 1, color: Colors.white24),
                    _buildZoomBtn(Icons.remove, "Perkecil (Zoom Out / LOD Macro)", () => _zoom(2.0)),
                    Container(width: 24, height: 1, color: Colors.white24),
                    _buildZoomBtn(Icons.my_location, "Reset Fokus Natuna", _resetToNatuna),
                    Container(width: 24, height: 1, color: Colors.white24),
                    _buildZoomBtn(
                      _showLabels ? Icons.label_rounded : Icons.label_off_rounded,
                      "Toggle Label Geospatial (LOD)",
                      _toggleLabels,
                      color: _showLabels ? AppColors.tniGreenNeon : Colors.white60,
                    ),
                  ],
                ),
              ),
            ),

            // ── Bottom-Left: LOD Status & Orbit Fleet ───────────────────────
            Positioned(
              bottom: 14,
              left: 14,
              child: Row(
                children: const [
                  TacticalBadge(label: '● 4 SATELIT LEO/GEO', type: BadgeType.live),
                  SizedBox(width: 8),
                  TacticalBadge(label: 'LOD MULTI-LAYER AKTIF', type: BadgeType.security),
                  SizedBox(width: 8),
                  TacticalBadge(label: 'GEOSPATIAL INDEX 3D', type: BadgeType.warning),
                ],
              ),
            ),

            // ── Bottom-Right Controls Panel (HUD Interactive Toggles) ───────
            Positioned(
              bottom: 14,
              right: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.80),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.cyberCyan.withValues(alpha: 0.4), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildToggleBtn(
                      icon: Icons.alt_route_rounded,
                      tooltip: 'Toggle Lintasan Orbit Satelit',
                      isActive: _showOrbits,
                      onTap: _toggleOrbits,
                    ),
                    const SizedBox(width: 6),
                    _buildToggleBtn(
                      icon: Icons.radar_rounded,
                      tooltip: 'Toggle Kerucut Sensor SAR Natuna',
                      isActive: _showFootprint,
                      onTap: _toggleFootprint,
                    ),
                    const SizedBox(width: 10),
                    Container(height: 18, width: 1, color: Colors.white24),
                    const SizedBox(width: 10),
                    // Speed Selector
                    _buildSpeedChip('1x', 1.0),
                    const SizedBox(width: 4),
                    _buildSpeedChip('2x', 2.0),
                    const SizedBox(width: 4),
                    _buildSpeedChip('4x', 4.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Search & Fly-To Navigation Header Bar ─────────────────────────────────
  Widget _buildSearchAndFlyToBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cyberCyan.withValues(alpha: 0.45)),
        boxShadow: const [
          BoxShadow(color: Color(0x3300C6FF), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.travel_explore_rounded, color: AppColors.cyberCyan, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 32,
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(fontSize: 11.5, color: Colors.white, fontFamily: 'monospace'),
                    decoration: InputDecoration(
                      hintText: "Cari Sektor Pertahanan (Natuna, IKN, Ambalat, Samudra Pasifik, Asia)...",
                      hintStyle: const TextStyle(fontSize: 11, color: Colors.white54),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: AppColors.cyberCyan.withValues(alpha: 0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: AppColors.cyberCyan),
                      ),
                      prefixIcon: const Icon(Icons.search_rounded, size: 16, color: AppColors.cyberCyan),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close, size: 14, color: Colors.white60),
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                    ),
                    onChanged: (val) {
                      setState(() => _searchQuery = val);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Dropdown Quick Selector
              _buildQuickIndexDropdown(),
            ],
          ),

          const SizedBox(height: 6),

          // Category Filter Pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryPill("SEMUA"),
                _buildCategoryPill("ZONA STRATEGIS NKRI"),
                _buildCategoryPill("SAMUDRA & LAUT"),
                _buildCategoryPill("BENUA"),
                _buildCategoryPill("NEGARA ASEAN"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPill(String category) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: () => setState(() => _selectedCategory = category),
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.cyberCyan.withValues(alpha: 0.25) : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isSelected ? AppColors.cyberCyan : Colors.white24,
              width: 1,
            ),
          ),
          child: Text(
            category,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: isSelected ? AppColors.cyberCyan : Colors.white70,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickIndexDropdown() {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.cyberCyan.withValues(alpha: 0.4)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<GeospatialLocation>(
          hint: const Text(
            "FLY-TO SEKTOR ▶",
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.cyberCyan, fontFamily: 'monospace'),
          ),
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.cyberCyan, size: 18),
          dropdownColor: const Color(0xFF0B132B),
          items: _filteredLocations.map((loc) {
            return DropdownMenuItem<GeospatialLocation>(
              value: loc,
              child: Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: loc.badgeColor),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    loc.name,
                    style: const TextStyle(fontSize: 11, color: Colors.white, fontFamily: 'monospace'),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (loc) {
            if (loc != null) _flyTo(loc);
          },
        ),
      ),
    );
  }

  Widget _buildTargetLocationBanner(GeospatialLocation loc) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: loc.badgeColor.withValues(alpha: 0.7), width: 1.2),
        boxShadow: [
          BoxShadow(color: loc.badgeColor.withValues(alpha: 0.2), blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.radar_rounded, color: loc.badgeColor, size: 18),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    "TERKUNCI KE: ${loc.name}",
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: loc.badgeColor,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "[${loc.lat.toStringAsFixed(2)}°, ${loc.lon.toStringAsFixed(2)}°]",
                    style: const TextStyle(fontSize: 9.5, color: Colors.white70, fontFamily: 'monospace'),
                  ),
                ],
              ),
              Text(
                loc.description,
                style: const TextStyle(fontSize: 9, color: Colors.white60),
              ),
            ],
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: () => setState(() => _activeTargetLocation = null),
            child: const Icon(Icons.close, size: 14, color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildZoomBtn(IconData icon, String tooltip, VoidCallback onTap, {Color? color}) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Icon(icon, size: 16, color: color ?? AppColors.cyberCyan),
        ),
      ),
    );
  }

  Widget _buildToggleBtn({
    required IconData icon,
    required String tooltip,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isActive ? AppColors.cyberCyan.withValues(alpha: 0.25) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isActive ? AppColors.cyberCyan : Colors.white24,
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 16,
            color: isActive ? AppColors.cyberCyan : Colors.white70,
          ),
        ),
      ),
    );
  }

  Widget _buildSpeedChip(String label, double speed) {
    final isSel = _speedMultiplier == speed;
    return InkWell(
      onTap: () => _setSpeed(speed),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: isSel ? AppColors.merahVibrant : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSel ? AppColors.merahVibrant : Colors.white24,
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.bold,
            color: isSel ? Colors.white : Colors.white70,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }
}
