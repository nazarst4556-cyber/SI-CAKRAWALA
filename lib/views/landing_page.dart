import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../main.dart' show CommandCenterScreen;
import '../widgets/landing/animated_landing_background.dart';
import 'login_view.dart';
import 'register_view.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  late final AnimationController _bgController;
  late final AnimationController _pulseController;
  late final AnimationController _textController;

  // Staggered entrance animations
  late final Animation<double> _badgeFade;
  late final Animation<Offset> _badgeSlide;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _descFade;
  late final Animation<Offset> _descSlide;
  late final Animation<double> _ctaFade;
  late final Animation<Offset> _ctaSlide;

  @override
  void initState() {
    super.initState();

    // 1. Continuous rotation controller for hero insignia crest & radar sweep
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // 2. Continuous pulsing glow on typography & badges (2.5 seconds)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    // 3. Staggered entrance timeline (1.4 seconds)
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();

    _badgeFade = CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );
    _badgeSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(_badgeFade);

    _titleFade = CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.2, 0.65, curve: Curves.easeOut),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(_titleFade);

    _descFade = CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.4, 0.85, curve: Curves.easeOut),
    );
    _descSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(_descFade);

    _ctaFade = CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    );
    _ctaSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(_ctaFade);
  }

  @override
  void dispose() {
    _bgController.dispose();
    _pulseController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _goLogin() {
    Navigator.push(context, _fadeRoute(const LoginView()));
  }

  void _goRegister() {
    Navigator.push(context, _fadeRoute(const RegisterView()));
  }

  void _goDashboardDirect() {
    Navigator.push(context, _fadeRoute(const CommandCenterScreen()));
  }

  Route _fadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
      transitionDuration: const Duration(milliseconds: 500),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: AnimatedLandingBackground(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _buildTopBar(size),
              _buildHeroSection(size),
              _buildMetricsRow(size),
              _buildCapabilitiesGrid(size),
              _buildStrategicMissionSection(size),
              _buildFooter(size),
            ],
          ),
        ),
      ),
    );
  }

  // ── 1. Top Navigation Bar ───────────────────────────────────────────────────
  Widget _buildTopBar(Size size) {
    final isMobile = size.width < 760;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 36,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.78),
            border: Border(
              bottom: BorderSide(
                color: AppColors.cyberCyan.withValues(alpha: 0.25),
                width: 1.2,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00C6FF).withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Tactical Insignia Logo
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.goldInsignia.withValues(alpha: 0.6),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.goldInsignia.withValues(alpha: 0.25),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/sicakrawala_logo.png',
                  width: 44,
                  height: 44,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 12),

              // Title Brand
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        'SI-CAKRAWALA',
                        style: GoogleFonts.orbitron(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppColors.merahIndonesia,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _PulsingStatusDot(
                        pulseController: _pulseController,
                        color: const Color(0xFF06D6A0),
                      ),
                    ],
                  ),
                  Text(
                    'SATSIBER TNI AD // PUSKODAL',
                    style: GoogleFonts.exo2(
                      fontSize: 9.5,
                      color: AppColors.textSecondary,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Indonesia Emas & Security Badges (Desktop only)
              if (!isMobile) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD4AF37), Color(0xFFF5D060)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.goldInsignia.withValues(alpha: 0.35),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🌟', style: TextStyle(fontSize: 11)),
                      const SizedBox(width: 5),
                      Text(
                        'INDONESIA EMAS 2045',
                        style: GoogleFonts.orbitron(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF4A3200),
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFF00F0FF).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.shield_rounded, size: 12, color: Color(0xFF00F0FF)),
                      const SizedBox(width: 5),
                      Text(
                        'POST-QUANTUM KYBER-1024',
                        style: GoogleFonts.orbitron(
                          fontSize: 8.5,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF00F0FF),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
              ],

              // Navigation Actions
              _TopNavButton(
                label: 'Masuk',
                icon: Icons.login_rounded,
                onTap: _goLogin,
              ),
              const SizedBox(width: 10),
              _TopNavButton(
                label: 'Daftar',
                icon: Icons.person_add_alt_1_rounded,
                filled: true,
                onTap: _goRegister,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── 2. Hero Section with Staggered Entrance & Pulsing Glow ─────────────────
  Widget _buildHeroSection(Size size) {
    final isSmall = size.width < 700;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 20 : size.width * 0.08,
        vertical: isSmall ? 40 : 64,
      ),
      child: Column(
        children: [
          // Rotating Insignia Crest with sweeping gradient ring
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, _) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Outer radar sweep ring
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.cyberCyan.withValues(alpha: 0.35),
                        width: 1.5,
                      ),
                    ),
                  ),
                  // Sweeping multi-color gradient border
                  Transform.rotate(
                    angle: _bgController.value * 2 * math.pi,
                    child: Container(
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          colors: [
                            AppColors.merahIndonesia,
                            AppColors.goldInsignia,
                            AppColors.tniGreenAccent,
                            AppColors.cyberCyan,
                            AppColors.merahIndonesia,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.cyberCyan.withValues(alpha: 0.35),
                            blurRadius: 28,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Insignia Emblem (Pure Transparent Background)
                  SizedBox(
                    width: 94,
                    height: 94,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Image.asset(
                        'assets/images/sicakrawala_logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 28),

          // Security Status Badge (Staggered Entrance 1)
          FadeTransition(
            opacity: _badgeFade,
            child: SlideTransition(
              position: _badgeSlide,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.merahIndonesia.withValues(alpha: 0.35),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.merahIndonesia.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _PulsingStatusDot(
                      pulseController: _pulseController,
                      color: AppColors.merahIndonesia,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'DOKTRIN PERTAHANAN SIBER NASIONAL // SEC-CLEARANCE 5',
                      style: GoogleFonts.orbitron(
                        fontSize: isSmall ? 8.5 : 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.merahIndonesia,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Hero Title with Staggered Entrance & Pulsing Glow (Staggered Entrance 2)
          FadeTransition(
            opacity: _titleFade,
            child: SlideTransition(
              position: _titleSlide,
              child: Column(
                children: [
                  // ── Matrix Scramble Decoder: Hero Title ──────────────────
                  _ScrambledTextDecoder(
                    text: 'NANGGROE CAKRAWALA SHIELD',
                    style: GoogleFonts.orbitron(
                      fontSize: isSmall ? 22 : 38,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: isSmall ? 2 : 4,
                      height: 1.2,
                    ),
                    glowColor: const Color(0xFF00C6FF),
                    glowColor2: const Color(0xFFCC0001),
                    useShaderMask: true,
                    gradient: AppColors.heroGradient,
                    textAlign: TextAlign.center,
                    startDelayMs: 300,
                    totalDurationMs: 1800,
                  ),
                  const SizedBox(height: 10),
                  // ── Matrix Scramble Decoder: Hero Subtitle ───────────────
                  _ScrambledTextDecoder(
                    text: 'SI-CAKRAWALA // CYBER COMMAND CENTER',
                    style: GoogleFonts.orbitron(
                      fontSize: isSmall ? 12 : 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.cyberCyanDeep,
                      letterSpacing: isSmall ? 4 : 8,
                    ),
                    glowColor: AppColors.cyberCyanDeep,
                    textAlign: TextAlign.center,
                    startDelayMs: 900,
                    totalDurationMs: 1400,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Description Card (Staggered Entrance 3)
          FadeTransition(
            opacity: _descFade,
            child: SlideTransition(
              position: _descSlide,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 860),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.82),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.glassBorder.withValues(alpha: 0.5),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cyberCyan.withValues(alpha: 0.06),
                      blurRadius: 24,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Text(
                  'Pusat Komando Operasi Siber Terpadu (Cyber Operation Command Dashboard) TNI AD untuk mendukung situational awareness kedaulatan wilayah NKRI secara real-time. Mengintegrasikan Penginderaan Jauh (Mata Satelit 3D), Intelijen Kecerdasan Buatan (AI), Konsensus Blockchain 15 Kodam, Radar Taktis, serta Kriptografi Pasca-Kuantum Kyber-1024.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.exo2(
                    fontSize: isSmall ? 12.5 : 14.5,
                    color: AppColors.textSecondary,
                    height: 1.85,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 36),

          // CTA Action Buttons (Staggered Entrance 4)
          FadeTransition(
            opacity: _ctaFade,
            child: SlideTransition(
              position: _ctaSlide,
              child: Wrap(
                spacing: 16,
                runSpacing: 14,
                alignment: WrapAlignment.center,
                children: [
                  _TacticalHeroButton(
                    label: 'AKSES DASHBOARD',
                    sublabel: 'Login Operasional C2',
                    icon: Icons.shield_rounded,
                    gradient: AppColors.redGradient,
                    glowColor: AppColors.merahIndonesia,
                    onTap: _goLogin,
                  ),
                  _TacticalHeroButton(
                    label: 'DAFTAR PERSONEL',
                    sublabel: 'Registrasi Operator',
                    icon: Icons.person_add_alt_1_rounded,
                    gradient: AppColors.greenGradient,
                    glowColor: AppColors.tniGreenAccent,
                    onTap: _goRegister,
                  ),
                  _TacticalHeroButton(
                    label: 'LANGSUNG KE PUSAT KOMANDO',
                    sublabel: 'Akses Instan Demo C2',
                    icon: Icons.rocket_launch_rounded,
                    gradient: AppColors.cyberGradient,
                    glowColor: AppColors.cyberCyan,
                    onTap: _goDashboardDirect,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 3. Live Operational Metrics Row (5 Interactive Cards) ───────────────────
  Widget _buildMetricsRow(Size size) {
    final metrics = [
      _MetricItem('🛰️', '247', 'Satelit Aktif', 'Orbit LEO/GEO', AppColors.cyberCyanDeep),
      _MetricItem('⚡', '99.97%', 'Uptime Sistem', 'Non-Stop Siaga', AppColors.tniGreenAccent),
      _MetricItem('🔐', '2.4M+', 'Data Terenkripsi', 'Kyber-1024', AppColors.goldInsignia),
      _MetricItem('🗺️', '38', 'Provinsi Terpantau', 'Pos Pamtas TNI', AppColors.merahIndonesia),
      _MetricItem('🏛️', '15', 'Kodam Validator', 'PBFT 100% Sync', const Color(0xFF6366F1)),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width < 700 ? 16 : size.width * 0.06,
        vertical: 18,
      ),
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          final isNarrow = constraints.maxWidth < 650;
          return Wrap(
            spacing: 14,
            runSpacing: 14,
            alignment: WrapAlignment.center,
            children: metrics
                .map((m) => _MetricCard(data: m, isNarrow: isNarrow))
                .toList(),
          );
        },
      ),
    );
  }

  // ── 4. Capabilities Grid (8 Tactical Defense Modules) ────────────────────────
  Widget _buildCapabilitiesGrid(Size size) {
    final modules = [
      _CapabilityData(
        '🛰️',
        'Mata Satelit 3D',
        'Penginderaan Jauh Real Earth',
        'Visualisasi globe 3D WebGL dengan tekstur NASA, atmosfer rim glow, dan pelacakan orbit satelit CAKRAWALA LEO/GEO.',
        AppColors.cyberGradient,
      ),
      _CapabilityData(
        '🤖',
        'Intelijen AI Taktis',
        'Synaptic Threat Neural Engine',
        'Deteksi anomali transmisi, klasifikasi serangan DDoS/APT dengan akurasi 98.4%, dan inferensi otonom 3.8ms.',
        AppColors.greenGradient,
      ),
      _CapabilityData(
        '🔗',
        'Blockchain Kodam',
        'PBFT Distributed Ledger',
        'Buku besar militer terdistribusi di 15 Kodam tanpa titik kegagalan tunggal dengan tanda tangan digital Dilithium-5.',
        AppColors.redGradient,
      ),
      _CapabilityData(
        '📡',
        'Telemetri & Sensor',
        'Real-time Hardware Telemetry',
        'Monitoring komprehensif GPU cluster, pendingin HVAC cair shelter, sensor array seismik, dan radiasi nuklir.',
        const LinearGradient(colors: [Color(0xFFD4AF37), Color(0xFFF59E0B)]),
      ),
      _CapabilityData(
        '🎯',
        'Radar Siber Taktis',
        '360° Threat Sweep Engine',
        'Sapuan radar multi-spektrum (HF/VHF, Satcom) dengan penanda blip interaktif dan locking perimeter breach darurat.',
        const LinearGradient(colors: [Color(0xFF06D6A0), Color(0xFF00B4D8)]),
      ),
      _CapabilityData(
        '📻',
        'Operasi Lapangan C2',
        'Mobile Tactical Comms',
        'Pemantauan posisi pasukan Satgas Siber-01, telemetri daya ransel, dan frekuensi radio taktis hopping terenkripsi.',
        const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)]),
      ),
      _CapabilityData(
        '💻',
        'Konsol Komando Siber',
        'Linux Terminal Engine C2',
        'Terminal interaktif prompt satsiber dengan Tab auto-complete, buku panduan manual, dan mode fullscreen operasional.',
        const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF334155)]),
      ),
      _CapabilityData(
        '🔒',
        'Kriptografi Kuantum',
        'Kyber-1024 & Dilithium-5',
        'Standar enkripsi pasca-kuantum NIST untuk menangkal dekripsi superkomputer kuantum masa depan demi Indonesia Emas 2045.',
        const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)]),
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width < 700 ? 16 : size.width * 0.06,
        vertical: 36,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 32, height: 2, color: AppColors.merahIndonesia),
              const SizedBox(width: 10),
              _ScrambledTextDecoder(
                text: '8 PILAR KAPABILITAS TAKTIS',
                style: GoogleFonts.orbitron(
                  fontSize: size.width < 600 ? 15 : 19,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: 2.5,
                ),
                glowColor: AppColors.merahIndonesia,
                startDelayMs: 500,
                totalDurationMs: 1200,
              ),
              const SizedBox(width: 10),
              Container(width: 32, height: 2, color: AppColors.merahIndonesia),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Sistem komando multi-domain terintegrasi untuk supremasi pertahanan kedaulatan digital Indonesia',
            textAlign: TextAlign.center,
            style: GoogleFonts.exo2(
              fontSize: 12.5,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 28),

          LayoutBuilder(
            builder: (ctx, constraints) {
              int cols = 4;
              if (constraints.maxWidth < 650) {
                cols = 1;
              } else if (constraints.maxWidth < 1050) {
                cols = 2;
              }

              final itemWidth =
                  (constraints.maxWidth - (cols - 1) * 16) / cols;

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: modules
                    .map((m) => SizedBox(
                          width: itemWidth,
                          child: _InteractiveCapabilityCard(data: m),
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── 5. Strategic Mission Section ────────────────────────────────────────────
  Widget _buildStrategicMissionSection(Size size) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: size.width < 700 ? 16 : size.width * 0.06,
        vertical: 24,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AppColors.cyberCyan.withValues(alpha: 0.3),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.cyberCyan.withValues(alpha: 0.08),
                  blurRadius: 36,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (ctx, c) {
                final isWide = c.maxWidth > 720;
                return isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildAboutText()),
                          const SizedBox(width: 36),
                          Expanded(child: _buildMissionList()),
                        ],
                      )
                    : Column(
                        children: [
                          _buildAboutText(),
                          const SizedBox(height: 28),
                          _buildMissionList(),
                        ],
                      );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAboutText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                gradient: AppColors.redGradient,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            _ScrambledTextDecoder(
              text: 'TENTANG SI-CAKRAWALA',
              style: GoogleFonts.orbitron(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: 1.5,
              ),
              glowColor: AppColors.merahIndonesia,
              startDelayMs: 600,
              totalDurationMs: 1000,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'NANGGROE CAKRAWALA SHIELD (SI-CAKRAWALA) dibangun sebagai garda terdepan pertahanan digital Angkatan Darat dalam mengamankan ruang siber dan kedaulatan teritorial dari Sabang sampai Merauke. Sistem ini menggabungkan kecerdasan buatan, telemetri IoT militer, dan konsensus blockchain untuk menjamin ketahanan informasi tanpa kompromi.',
          style: GoogleFonts.exo2(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.8,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFD4AF37), Color(0xFFF5D060)],
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: AppColors.goldInsignia.withValues(alpha: 0.3),
                blurRadius: 8,
              ),
            ],
          ),
          child: Text(
            '🌟 VISI INDONESIA EMAS 2045: KEDAULATAN SIBER & KEMANDIRIAN TEKNOLOGI',
            style: GoogleFonts.rajdhani(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF4A3200),
              letterSpacing: 0.8,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMissionList() {
    final missions = [
      ('🛡️', 'Pertahanan Siber Multi-Domain', 'Deteksi dan mitigasi serangan cyber-physical lintas sektor strategis secara otonom.'),
      ('🛰️', 'Pengawasan Orbital & Pos Pamtas', 'Sinkronisasi telemetri 38 provinsi dan pengawasan batas perbatasan negara.'),
      ('🔐', 'Arsitektur Kriptografi Zero-Trust', 'Validasi otorisasi bertingkat dengan algoritma pasca-kuantum Kyber-1024.'),
      ('🤝', 'Interoperabilitas Tri-Matra TNI', 'Kesiapan koordinasi data intelijen bersama AD, AL, dan AU dalam satu komando.'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                gradient: AppColors.greenGradient,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            _ScrambledTextDecoder(
              text: '4 MISI OPERASIONAL UTAMA',
              style: GoogleFonts.orbitron(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: 1.5,
              ),
              glowColor: AppColors.tniGreenAccent,
              startDelayMs: 700,
              totalDurationMs: 1000,
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...missions.map((m) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.cyberCyan.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Center(
                      child: Text(m.$1, style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.$2,
                          style: GoogleFonts.rajdhani(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          m.$3,
                          style: GoogleFonts.exo2(
                            fontSize: 11.5,
                            color: AppColors.textMuted,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  // ── 6. Anchored Military Security Metadata Footer ───────────────────────────
  Widget _buildFooter(Size size) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 28),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A), // Dark military tactical anchor footer
        border: Border(
          top: BorderSide(
            color: Color(0xFF1E293B),
            width: 1.5,
          ),
        ),
      ),
      child: Column(
        children: [
          // Security Status Badges Row
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _FooterStatusBadge(
                label: 'RAHASIA / TOP SECRET',
                color: AppColors.merahIndonesia,
                icon: Icons.lock_rounded,
              ),
              _FooterStatusBadge(
                label: 'AES-256-GCM / KYBER-1024',
                color: const Color(0xFF00F0FF),
                icon: Icons.enhanced_encryption_rounded,
              ),
              _FooterStatusBadge(
                label: 'INDONESIA EMAS 2045',
                color: AppColors.goldInsignia,
                icon: Icons.star_rounded,
              ),
              _FooterStatusBadge(
                label: '15 KODAM PBFT ACTIVE',
                color: const Color(0xFF06D6A0),
                icon: Icons.cloud_done_rounded,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Logo & Attribution
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/sicakrawala_logo.png',
                width: 34,
                height: 34,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SI-CAKRAWALA | NANGGROE CAKRAWALA SHIELD',
                    style: GoogleFonts.orbitron(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    'SATUAN SIBER PUSKODAL TNI ANGKATAN DARAT',
                    style: GoogleFonts.exo2(
                      fontSize: 8.5,
                      color: const Color(0xFF94A3B8),
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),

          Container(
            height: 1,
            color: const Color(0xFF1E293B),
            margin: const EdgeInsets.symmetric(horizontal: 40),
          ),
          const SizedBox(height: 16),

          Text(
            '© 2045 NANGGROE CAKRAWALA SHIELD • Karya: NAZARUL QUDRI • REPUBLIK INDONESIA',
            textAlign: TextAlign.center,
            style: GoogleFonts.exo2(
              fontSize: 10,
              color: const Color(0xFF94A3B8),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Sistem ini dilindungi Undang-Undang Pertahanan Negara & Doktrin Operasi Siber Militer Nasional RI',
            textAlign: TextAlign.center,
            style: GoogleFonts.exo2(
              fontSize: 9,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// BACKGROUND VISUALIZATION ENGINE:
// High-performance Neural-Blockchain background animation engine is cleanly
// encapsulated in `AnimatedLandingBackground` & `NeuralBlockchainBackgroundPainter`.
// ════════════════════════════════════════════════════════════════════════════

// ── INTERACTIVE HELPER WIDGETS ───────────────────────────────────────────────

/// Pulsing status dot indicator
class _PulsingStatusDot extends StatelessWidget {
  final AnimationController pulseController;
  final Color color;

  const _PulsingStatusDot({
    required this.pulseController,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseController,
      builder: (context, _) {
        final pulse = pulseController.value;
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4 + 0.4 * pulse),
                blurRadius: 4 + 6 * pulse,
                spreadRadius: 1 + 2 * pulse,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Top navigation button with hover styling
class _TopNavButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  const _TopNavButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  @override
  State<_TopNavButton> createState() => _TopNavButtonState();
}

class _TopNavButtonState extends State<_TopNavButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _hovered ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 140),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: widget.filled
                  ? AppColors.redGradient
                  : (_hovered
                      ? LinearGradient(colors: [
                          const Color(0xFF00C6FF).withValues(alpha: 0.12),
                          const Color(0xFF0072FF).withValues(alpha: 0.06),
                        ])
                      : null),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: widget.filled
                    ? AppColors.merahIndonesia
                    : (_hovered ? AppColors.cyberCyan : AppColors.glassBorder),
                width: 1.2,
              ),
              boxShadow: widget.filled
                  ? [
                      BoxShadow(
                        color: AppColors.merahIndonesia.withValues(alpha: 0.3),
                        blurRadius: _hovered ? 14 : 8,
                      )
                    ]
                  : (_hovered
                      ? [
                          BoxShadow(
                            color: AppColors.cyberCyan.withValues(alpha: 0.2),
                            blurRadius: 10,
                          )
                        ]
                      : null),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.icon,
                  size: 14,
                  color: widget.filled ? Colors.white : AppColors.textPrimary,
                ),
                const SizedBox(width: 6),
                Text(
                  widget.label,
                  style: GoogleFonts.orbitron(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: widget.filled ? Colors.white : AppColors.textPrimary,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tactical CTA Button with smooth scale-on-hover & neon glow
class _TacticalHeroButton extends StatefulWidget {
  final String label;
  final String sublabel;
  final IconData icon;
  final Gradient gradient;
  final Color glowColor;
  final VoidCallback onTap;

  const _TacticalHeroButton({
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.gradient,
    required this.glowColor,
    required this.onTap,
  });

  @override
  State<_TacticalHeroButton> createState() => _TacticalHeroButtonState();
}

class _TacticalHeroButtonState extends State<_TacticalHeroButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.94 : (_hovered ? 1.06 : 1.0),
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            decoration: BoxDecoration(
              gradient: widget.gradient,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _hovered ? Colors.white : Colors.white24,
                width: _hovered ? 1.5 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.glowColor.withValues(alpha: _hovered ? 0.45 : 0.22),
                  blurRadius: _hovered ? 24 : 12,
                  spreadRadius: _hovered ? 2 : 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.label,
                      style: GoogleFonts.orbitron(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      widget.sublabel,
                      style: GoogleFonts.exo2(
                        fontSize: 9.5,
                        color: Colors.white.withValues(alpha: 0.85),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                const Text(
                  '>',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Metric Card model
class _MetricItem {
  final String icon;
  final String value;
  final String label;
  final String sublabel;
  final Color color;

  _MetricItem(this.icon, this.value, this.label, this.sublabel, this.color);
}

/// Interactive Metric Card
class _MetricCard extends StatefulWidget {
  final _MetricItem data;
  final bool isNarrow;

  const _MetricCard({required this.data, required this.isNarrow});

  @override
  State<_MetricCard> createState() => _MetricCardState();
}

class _MetricCardState extends State<_MetricCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.04 : 1.0,
        duration: const Duration(milliseconds: 160),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.isNarrow ? 150 : 180,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: _hovered ? 0.95 : 0.80),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _hovered
                  ? widget.data.color
                  : widget.data.color.withValues(alpha: 0.3),
              width: _hovered ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.data.color.withValues(alpha: _hovered ? 0.22 : 0.08),
                blurRadius: _hovered ? 18 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.data.icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 6),
              Text(
                widget.data.value,
                style: GoogleFonts.orbitron(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: widget.data.color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.data.label,
                textAlign: TextAlign.center,
                style: GoogleFonts.rajdhani(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                widget.data.sublabel,
                textAlign: TextAlign.center,
                style: GoogleFonts.exo2(
                  fontSize: 9.5,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Capability Card model
class _CapabilityData {
  final String icon;
  final String title;
  final String subtitle;
  final String desc;
  final Gradient gradient;

  _CapabilityData(
    this.icon,
    this.title,
    this.subtitle,
    this.desc,
    this.gradient,
  );
}

/// Interactive Capability Card with hover elevation & border transition
class _InteractiveCapabilityCard extends StatefulWidget {
  final _CapabilityData data;

  const _InteractiveCapabilityCard({required this.data});

  @override
  State<_InteractiveCapabilityCard> createState() =>
      _InteractiveCapabilityCardState();
}

class _InteractiveCapabilityCardState
    extends State<_InteractiveCapabilityCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        transform: _hovered
            ? Matrix4.translationValues(0.0, -8.0, 0.0)
            : Matrix4.identity(),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: _hovered ? 0.95 : 0.82),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _hovered
                ? AppColors.cyberCyan
                : AppColors.glassBorder.withValues(alpha: 0.5),
            width: _hovered ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: _hovered
                  ? AppColors.cyberCyan.withValues(alpha: 0.20)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: _hovered ? 28 : 10,
              offset: Offset(0, _hovered ? 8 : 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Badge
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: widget.data.gradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  widget.data.icon,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Title
            Text(
              widget.data.title,
              style: GoogleFonts.orbitron(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: 0.6,
              ),
            ),
            Text(
              widget.data.subtitle,
              style: GoogleFonts.rajdhani(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.cyberCyanDeep,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),

            // Description
            Text(
              widget.data.desc,
              style: GoogleFonts.exo2(
                fontSize: 11.5,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Footer status badge
class _FooterStatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _FooterStatusBadge({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.orbitron(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// MATRIX SCRAMBLE DECODER WIDGET
// Professional military-grade text entrance animation:
// Characters start as random ASCII glyphs that rapidly scramble, then lock
// into their final characters from left to right with a neon glow ripple.
// ════════════════════════════════════════════════════════════════════════════
class _ScrambledTextDecoder extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Color glowColor;
  final Color? glowColor2;
  final bool useShaderMask;
  final Gradient? gradient;
  final TextAlign textAlign;
  final int startDelayMs;
  final int totalDurationMs;

  const _ScrambledTextDecoder({
    required this.text,
    required this.style,
    required this.glowColor,
    this.glowColor2,
    this.useShaderMask = false,
    this.gradient,
    this.textAlign = TextAlign.start,
    this.startDelayMs = 0,
    this.totalDurationMs = 1200,
  });

  @override
  State<_ScrambledTextDecoder> createState() => _ScrambledTextDecoderState();
}

class _ScrambledTextDecoderState extends State<_ScrambledTextDecoder>
    with SingleTickerProviderStateMixin {
  // Glyphs used for the scramble effect (military/tactical feel)
  static const String _glyphs =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#\$%&*!?<>[]{}|/\\^~+-=';

  late final math.Random _rand;
  late final List<String> _displayChars;
  late final List<bool> _locked;
  late AnimationController _glowController;
  Timer? _scrambleTimer;
  Timer? _startDelayTimer;
  bool _started = false;
  int _lockedCount = 0;

  @override
  void initState() {
    super.initState();
    _rand = math.Random();
    _displayChars = List.filled(widget.text.length, ' ');
    _locked = List.filled(widget.text.length, false);

    // Glow pulse on the decoder cursor position
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..repeat(reverse: true);

    // Start after optional delay
    _startDelayTimer = Timer(
      Duration(milliseconds: widget.startDelayMs),
      _beginScramble,
    );
  }

  void _beginScramble() {
    if (!mounted) return;
    _started = true;

    final totalChars = widget.text.length;
    // Time per character lock: spread evenly over the total duration
    final msPerChar = (widget.totalDurationMs / totalChars).round();
    // Scramble tick rate: fast random flips
    const tickMs = 38;

    int tickCount = 0;

    _scrambleTimer = Timer.periodic(Duration(milliseconds: tickMs), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      tickCount++;

      // How many chars should be locked by now
      final shouldBeLocked = (tickCount * tickMs / msPerChar).floor();
      final newlyLocked = shouldBeLocked.clamp(0, totalChars);

      setState(() {
        // Lock characters from left to right
        for (int i = 0; i < totalChars; i++) {
          if (i < newlyLocked && !_locked[i]) {
            _locked[i] = true;
            _lockedCount = i + 1;
            _displayChars[i] = widget.text[i];
          } else if (!_locked[i]) {
            // Scramble unlocked characters with random glyphs
            if (widget.text[i] == ' ' || widget.text[i] == '/') {
              _displayChars[i] = widget.text[i];
            } else {
              _displayChars[i] = _glyphs[_rand.nextInt(_glyphs.length)];
            }
          }
        }
      });

      // All locked → finish
      if (newlyLocked >= totalChars) {
        timer.cancel();
        if (mounted) {
          setState(() {
            for (int i = 0; i < totalChars; i++) {
              _displayChars[i] = widget.text[i];
              _locked[i] = true;
            }
          });
          _glowController.stop();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrambleTimer?.cancel();
    _startDelayTimer?.cancel();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_started) {
      // Show invisible placeholder to prevent layout jump
      return Opacity(
        opacity: 0.0,
        child: Text(widget.text, style: widget.style, textAlign: widget.textAlign),
      );
    }

    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, _) {
        final glow = _glowController.value;
        final builtText = _buildSpannedText(glow);

        Widget textWidget = RichText(
          text: builtText,
          textAlign: widget.textAlign,
        );

        // Wrap with ShaderMask for gradient text effect (hero title)
        if (widget.useShaderMask && widget.gradient != null) {
          textWidget = ShaderMask(
            shaderCallback: (bounds) =>
                widget.gradient!.createShader(bounds),
            child: textWidget,
          );
        }

        return textWidget;
      },
    );
  }

  TextSpan _buildSpannedText(double glow) {
    final children = <TextSpan>[];

    for (int i = 0; i < _displayChars.length; i++) {
      final char = _displayChars[i];
      final isLocked = _locked[i];
      // The character right after the last locked one is the "cursor"
      final isCursor = !isLocked && i == _lockedCount;

      TextStyle charStyle;

      if (isLocked) {
        // Locked character: final style with subtle permanent glow
        charStyle = widget.style.copyWith(
          shadows: [
            Shadow(
              color: widget.glowColor.withValues(alpha: 0.30),
              blurRadius: 8,
            ),
            if (widget.glowColor2 != null)
              Shadow(
                color: widget.glowColor2!.withValues(alpha: 0.18),
                blurRadius: 14,
              ),
          ],
        );
      } else if (isCursor) {
        // Cursor (active decode position): bright neon glow pulse
        charStyle = widget.style.copyWith(
          color: widget.glowColor,
          shadows: [
            Shadow(
              color: widget.glowColor.withValues(alpha: 0.85 + 0.15 * glow),
              blurRadius: 10 + 12 * glow,
            ),
            Shadow(
              color: widget.glowColor.withValues(alpha: 0.50),
              blurRadius: 24,
            ),
          ],
        );
      } else {
        // Scrambling character ahead: dim cyan
        charStyle = widget.style.copyWith(
          color: widget.glowColor.withValues(alpha: 0.35 + 0.25 * glow),
          shadows: [
            Shadow(
              color: widget.glowColor.withValues(alpha: 0.20),
              blurRadius: 4,
            ),
          ],
        );
      }

      children.add(TextSpan(text: char, style: charStyle));
    }

    return TextSpan(children: children);
  }
}
