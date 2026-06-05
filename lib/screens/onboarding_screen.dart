import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';
import '../state/app_state_provider.dart';
import '../widgets/onboarding_modal.dart';
import '../widgets/profile_panel.dart';
import 'login_screen.dart';
import 'partners_screen.dart';
import 'client_tracking_screen.dart';

/// Dikey scroll onboarding ekranı (güncellenmiş versiyon).
///
/// Bölümler:
///   1. Hero       — tam ekran, web header + grid/glow + slogan
///   2. Adımlar    — 3 operasyonel adım kartı
///   3. Çözümler   — "KARMAŞAYI BİTİREN ÇÖZÜMLER" + 3 kart + 4 metrik
///   4. CTA        — "Hemen Başla" → [LoginScreen]
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollCtrl = ScrollController();

  // GlobalKey'ler — sayfa içi scroll navigasyonu için
  final GlobalKey _stepsKey    = GlobalKey();
  final GlobalKey _solutionsKey = GlobalKey();
  final GlobalKey _ctaKey      = GlobalKey();

  late AnimationController _heroAnimCtrl;
  late Animation<double> _heroFade;
  late Animation<Offset> _heroSlide;

  late List<AnimationController> _stepCtrls;
  late List<Animation<double>> _stepFades;
  late List<Animation<Offset>> _stepSlides;

  late List<AnimationController> _cardCtrls;
  late List<Animation<double>> _cardFades;
  late List<Animation<Offset>> _cardSlides;

  bool _stepsTriggered = false;
  bool _cardsTriggered = false;

  @override
  void initState() {
    super.initState();

    _heroAnimCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _heroFade =
        CurvedAnimation(parent: _heroAnimCtrl, curve: Curves.easeOut);
    _heroSlide = Tween<Offset>(
            begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _heroAnimCtrl, curve: Curves.easeOut));
    _heroAnimCtrl.forward();

    _stepCtrls = List.generate(
        3,
        (_) => AnimationController(
            vsync: this, duration: const Duration(milliseconds: 600)));
    _stepFades = _stepCtrls
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut))
        .toList();
    _stepSlides = _stepCtrls
        .map((c) => Tween<Offset>(
                begin: const Offset(0, 0.10), end: Offset.zero)
            .animate(CurvedAnimation(parent: c, curve: Curves.easeOut)))
        .toList();

    _cardCtrls = List.generate(
        3,
        (_) => AnimationController(
            vsync: this, duration: const Duration(milliseconds: 620)));
    _cardFades = _cardCtrls
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut))
        .toList();
    _cardSlides = _cardCtrls
        .map((c) => Tween<Offset>(
                begin: const Offset(0, 0.10), end: Offset.zero)
            .animate(CurvedAnimation(parent: c, curve: Curves.easeOut)))
        .toList();

    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    final offset = _scrollCtrl.offset;
    if (!_stepsTriggered && offset > 200) {
      _stepsTriggered = true;
      for (int i = 0; i < 3; i++) {
        Future.delayed(Duration(milliseconds: i * 160),
            () { if (mounted) _stepCtrls[i].forward(); });
      }
    }
    if (!_cardsTriggered && offset > 700) {
      _cardsTriggered = true;
      for (int i = 0; i < 3; i++) {
        Future.delayed(Duration(milliseconds: i * 180),
            () { if (mounted) _cardCtrls[i].forward(); });
      }
    }
  }

  /// Verilen [key]'e sahip widget'a pürüzsüz animasyonla kaydır.
  void _scrollToSection(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeInOutCubic,
      alignment: 0.0,
    );
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _heroAnimCtrl.dispose();
    for (final c in _stepCtrls) { c.dispose(); }
    for (final c in _cardCtrls) { c.dispose(); }
    super.dispose();
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (ctx, anim, secAnim) => const LoginScreen(),
        transitionsBuilder: (ctx, animation, secAnim, child) => FadeTransition(
          opacity:
              CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _onStartTap() {
    final state = AppStateProvider.read(context);
    if (state.onboardingComplete) {
      showProfilePanel(context);
    } else {
      showOnboardingModal(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      body: SingleChildScrollView(
        controller: _scrollCtrl,
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // 1 ─ HERO
            SizedBox(
              height: screenH,
              child: _HeroSection(
                fadeAnim: _heroFade,
                slideAnim: _heroSlide,
                onLoginTap: _goToLogin,
                onStartTap: _onStartTap,
                onNavFeatures:  () => _scrollToSection(_solutionsKey),
                onNavOperation: () => _scrollToSection(_stepsKey),
                onNavWhyUs:     () => _scrollToSection(_ctaKey),
                onNavDemo:      _goToLogin,
              ),
            ),
            // 2 ─ ADIMLAR
            _StepsSection(
              sectionKey: _stepsKey,
              stepFades: _stepFades,
              stepSlides: _stepSlides,
              onLiveTap: () => _showTrackingModal(context),
            ),
            // 3 ─ ÇÖZÜMLER
            _SolutionsSection(
              sectionKey: _solutionsKey,
              cardFades: _cardFades,
              cardSlides: _cardSlides,
            ),
            // 4 ─ İŞ AKIŞ (KUSURSUZ İŞ AKIŞ)
            const _WorkflowSection(),
            // 5 ─ VİZYON (LOJİSTİĞİ YENİDEN TANIMLIYORUZ)
            const _VisionSection(),
            // 6 ─ İLETİŞİM (BİRLİKTE BÜYÜYELİM)
            const _ContactSection(),
            // 7 ─ CTA
            _CtaSection(sectionKey: _ctaKey, onStartTap: _onStartTap),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// 1. HERO BÖLÜMÜ
// ═════════════════════════════════════════════════════════════════════════════

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.fadeAnim,
    required this.slideAnim,
    required this.onLoginTap,
    required this.onStartTap,
    required this.onNavFeatures,
    required this.onNavOperation,
    required this.onNavWhyUs,
    required this.onNavDemo,
  });

  final Animation<double> fadeAnim;
  final Animation<Offset> slideAnim;
  final VoidCallback onLoginTap;
  final VoidCallback onStartTap;
  final VoidCallback onNavFeatures;
  final VoidCallback onNavOperation;
  final VoidCallback onNavWhyUs;
  final VoidCallback onNavDemo;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: CustomPaint(painter: _GridPainter())),
        const Positioned.fill(child: _GlowLayer()),
        SafeArea(
          child: Column(
            children: [
              _WebHeader(
                onLoginTap: onLoginTap,
                onStartTap: onStartTap,
                onNavFeatures: onNavFeatures,
                onNavOperation: onNavOperation,
                onNavWhyUs: onNavWhyUs,
                onNavDemo: onNavDemo,
              ),
              Expanded(
                child: FadeTransition(
                  opacity: fadeAnim,
                  child: SlideTransition(
                    position: slideAnim,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _BadgePill(),
                        const SizedBox(height: 28),
                        _HeroText(),
                        const SizedBox(height: 24),
                        _DescriptionText(),
                      ],
                    ),
                  ),
                ),
              ),
              const _ScrollHint(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Web sitesi header'ı (mobil uyarlaması)
// Satır 1 : LOOP  [+ Giriş]          [Partnerler]  [HEMEN BAŞLA]
// Satır 2 : Özellikler  Operasyon  Neden Biz?  Demo Talep Et
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────────

class _WebHeader extends StatelessWidget {
  const _WebHeader({
    required this.onLoginTap,
    required this.onStartTap,
    required this.onNavFeatures,
    required this.onNavOperation,
    required this.onNavWhyUs,
    required this.onNavDemo,
  });

  final VoidCallback onLoginTap;
  final VoidCallback onStartTap;
  final VoidCallback onNavFeatures;
  final VoidCallback onNavOperation;
  final VoidCallback onNavWhyUs;
  final VoidCallback onNavDemo;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return Column(
          children: [
            // ── Ana satır: LOOP + Giriş | Partnerler + HEMEN BAŞLA ──────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: Row(
                children: [
                  _LoopLogo(),
                  const SizedBox(width: 8),
                  _GirisBadge(onTap: onLoginTap),
                  const Spacer(),
                  if (!isMobile) ...[
                    _PartnersLink(),
                    const SizedBox(width: 10),
                  ],
                  _HemenBaslaHeaderBtn(onTap: onStartTap),
                ],
              ),
            ),
        // ── Nav linkleri — eşit aralıklı, yatay kaydırmalı ─────────────
        SizedBox(
          height: 38,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                _NavLink(label: 'Özellikler',   onTap: onNavFeatures),
                const SizedBox(width: 28),
                _NavLink(label: 'Operasyon',    onTap: onNavOperation),
                const SizedBox(width: 28),
                _NavLink(label: 'Neden Biz?',   onTap: onNavWhyUs),
                const SizedBox(width: 28),
                _NavLink(label: 'Demo Talep Et', onTap: onNavDemo),
              ],
            ),
          ),
        ),
        // İnce ayırıcı
        Container(
          height: 1,
          margin: const EdgeInsets.symmetric(horizontal: 14),
          color: AppColors.cardBorder,
        ),
          ],
        );
      },
    );
  }
}

// ─── LOOP Logosu ───────────────────────────────────────────────────────────

class _LoopLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1C2E),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Text(
        'LOOP',
        style: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
          letterSpacing: 2,
          height: 1,
        ),
      ),
    );
  }
}

// ─── Turuncu Giriş Badge (hover/press glow) ────────────────────────────────

class _GirisBadge extends StatefulWidget {
  const _GirisBadge({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_GirisBadge> createState() => _GirisBadgeState();
}

class _GirisBadgeState extends State<_GirisBadge> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _pressed = true),
      onExit:  (_) => setState(() => _pressed = false),
      child: GestureDetector(
        onTapDown:   (_) => setState(() => _pressed = true),
        onTapUp:     (_) { setState(() => _pressed = false); widget.onTap(); },
        onTapCancel: ()  => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _pressed
                ? const Color(0xFF5A3A00)
                : const Color(0xFF3D2800),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
                color: const Color(0xFFFFAA00)
                    .withAlpha(_pressed ? 200 : 120),
                width: 1),
            boxShadow: _pressed
                ? [
                    BoxShadow(
                      color: const Color(0xFFFFAA00).withAlpha(80),
                      blurRadius: 14,
                      spreadRadius: 1,
                    )
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pulsing nokta
              _PulsingDot(
                color: _pressed
                    ? const Color(0xFFFFCC44)
                    : const Color(0xFFFFAA00),
                size: 6,
              ),
              const SizedBox(width: 5),
              Text(
                'GİRİŞ',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _pressed
                      ? const Color(0xFFFFCC44)
                      : const Color(0xFFFFAA00),
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Partnerler linki (hover glow) ────────────────────────────────────────

class _PartnersLink extends StatefulWidget {
  @override
  State<_PartnersLink> createState() => _PartnersLinkState();
}

class _PartnersLinkState extends State<_PartnersLink> {
  bool _hovered = false;

  void _navigate(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (ctx, anim, sec) => const PartnersScreen(),
        transitionsBuilder: (ctx, anim, sec, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeInOut)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 320),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = _hovered ? AppColors.textPrimary : AppColors.textSecondary;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap:       () { setState(() => _hovered = false); _navigate(context); },
        onTapDown:   (_) => setState(() => _hovered = true),
        onTapUp:     (_) => setState(() => _hovered = false),
        onTapCancel: ()  => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: AppColors.textAccent.withAlpha(40),
                      blurRadius: 10,
                    )
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.link_rounded, size: 13, color: color),
              const SizedBox(width: 4),
              Text(
                'Partnerler',
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── HEMEN BAŞLA / PROFİLİM butonu (state-aware) ─────────────────────────

class _HemenBaslaHeaderBtn extends StatefulWidget {
  const _HemenBaslaHeaderBtn({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_HemenBaslaHeaderBtn> createState() => _HemenBaslaHeaderBtnState();
}

class _HemenBaslaHeaderBtnState extends State<_HemenBaslaHeaderBtn>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late AnimationController _slideCtrl;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400))
      ..forward();
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final isComplete = state.onboardingComplete;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.15, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: child,
        ),
      ),
      child: isComplete
          // ── Profilim Butonu ───────────────────────────────────────────────
          ? KeyedSubtree(
              key: const ValueKey('profilim'),
              child: MouseRegion(
                onEnter: (_) => setState(() => _pressed = true),
                onExit: (_) => setState(() => _pressed = false),
                child: GestureDetector(
                  onTapDown: (_) => setState(() => _pressed = true),
                  onTapUp: (_) {
                    setState(() => _pressed = false);
                    widget.onTap();
                  },
                  onTapCancel: () => setState(() => _pressed = false),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _pressed
                          ? AppColors.primaryButton.withAlpha(30)
                          : AppColors.primaryButton.withAlpha(18),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.primaryButton.withAlpha(_pressed ? 180 : 100),
                        width: 1,
                      ),
                      boxShadow: _pressed
                          ? [BoxShadow(color: AppColors.primaryButton.withAlpha(60), blurRadius: 12)]
                          : [],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 22, height: 22,
                          decoration: BoxDecoration(
                            color: AppColors.primaryButton,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              state.initials,
                              style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF0D1E30)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          'PROFİLİM',
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryButton,
                              letterSpacing: 0.5),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down_rounded,
                            size: 14, color: AppColors.primaryButton),
                      ],
                    ),
                  ),
                ),
              ),
            )
          // ── Hemen Başla Butonu ────────────────────────────────────────────
          : KeyedSubtree(
              key: const ValueKey('hemenbasla'),
              child: MouseRegion(
                onEnter: (_) => setState(() => _pressed = true),
                onExit: (_) => setState(() => _pressed = false),
                child: GestureDetector(
                  onTapDown: (_) => setState(() => _pressed = true),
                  onTapUp: (_) {
                    setState(() => _pressed = false);
                    widget.onTap();
                  },
                  onTapCancel: () => setState(() => _pressed = false),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: _pressed
                          ? AppColors.primaryButtonHover
                          : AppColors.primaryButton,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryButton.withAlpha(_pressed ? 130 : 70),
                          blurRadius: _pressed ? 20 : 10,
                          spreadRadius: _pressed ? 1 : 0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      'HEMEN BAŞLA',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textOnButton,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

// ─── Nav linki (hover + onTap callback) ───────────────────────────────────

class _NavLink extends StatefulWidget {
  const _NavLink({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown:   (_) => setState(() => _hovered = true),
        onTapCancel: ()  => setState(() => _hovered = false),
        onTapUp:     (_) => setState(() => _hovered = false),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 180),
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: _hovered ? FontWeight.w700 : FontWeight.w500,
            color: _hovered
                ? AppColors.textPrimary
                : AppColors.textSecondary,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(widget.label),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Grid çizici
// ─────────────────────────────────────────────────────────────────────────────

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final lp = Paint()
      ..color = const Color(0xFF1A2B45).withAlpha(80)
      ..strokeWidth = 0.8;
    final dp = Paint()
      ..color = const Color(0xFF2A4060).withAlpha(100)
      ..style = PaintingStyle.fill;
    const step = 40.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), lp);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), lp);
    }
    for (double x = 0; x <= size.width; x += step) {
      for (double y = 0; y <= size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 1.2, dp);
      }
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Işık haleleri
// ─────────────────────────────────────────────────────────────────────────────

class _GlowLayer extends StatelessWidget {
  const _GlowLayer();

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size;
    return Stack(children: [
      _glow(-s.width * .35, -s.height * .08, s.width, s.height * .55,
          const Color(0xFF0D3A6E), 90),
      _glow(null, s.height * .2, s.width * .75, s.height * .45,
          const Color(0xFF4DBFB0), 35,
          right: -s.width * .25),
      _glow(s.width * .1, null, s.width * .8, s.height * .3,
          const Color(0xFF0A2A50), 60,
          bottom: -s.height * .05),
    ]);
  }

  Widget _glow(double? left, double? top, double w, double h, Color c, int a,
      {double? right, double? bottom}) {
    return Positioned(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      child: Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient:
              RadialGradient(colors: [c.withAlpha(a), Colors.transparent]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Rozet · Slogan · Açıklama
// ─────────────────────────────────────────────────────────────────────────────

class _BadgePill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1E32),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        // Pulsing nokta animasyonu
        const _PulsingDot(color: AppColors.textAccent),
        const SizedBox(width: 8),
        Text(
          'YENİ NESİL LOJİSTİK YÖNETİMİ',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 0.8,
          ),
        ),
      ]),
    );
  }
}

/// Sonsuz döngüde yumuşak "nefes alan" nokta animasyonu.
class _PulsingDot extends StatefulWidget {
  const _PulsingDot({
    required this.color,
    this.size = 7.0,
  });
  final Color color;
  final double size;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.7, end: 1.35).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _opacity = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) => Transform.scale(
        scale: _scale.value,
        child: Opacity(
          opacity: _opacity.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withAlpha(
                      (80 * _opacity.value).toInt()),
                  blurRadius: 6 * _scale.value,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 600;
    final fs = isMobile ? math.min(w * 0.12, 48.0) : math.min(w * 0.175, 80.0);
    final base = GoogleFonts.inter(
        fontSize: fs,
        fontWeight: FontWeight.w900,
        height: 1.0,
        letterSpacing: -0.5);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(children: [
        Text('TESLİMATLARI',
            textAlign: TextAlign.center,
            style: base.copyWith(color: AppColors.textPrimary)),
        Text('OTOPİLOTA',
            textAlign: TextAlign.center,
            style: base.copyWith(color: const Color(0xFF4DBFB0))),
        Text('ALIN',
            textAlign: TextAlign.center,
            style: base.copyWith(color: AppColors.textPrimary)),
      ]),
    );
  }
}

class _DescriptionText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Text(
        'Saha operasyonlarınızı kör uçuş olmaktan çıkarın.\n'
        'Maliyetleri düşürün, kuryelerinizi tek ekrandan\n'
        'yönetin ve müşteri memnuniyetini zirveye taşıyın.',
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          fontSize: 14.5,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
          height: 1.65,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KEŞFET scroll göstergesi
// ─────────────────────────────────────────────────────────────────────────────

class _ScrollHint extends StatefulWidget {
  const _ScrollHint();

  @override
  State<_ScrollHint> createState() => _ScrollHintState();
}

class _ScrollHintState extends State<_ScrollHint>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _bounce = Tween<double>(begin: 0, end: 8).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text('KEŞFET',
          style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.textLabel,
              letterSpacing: 2.5)),
      const SizedBox(height: 8),
      AnimatedBuilder(
        animation: _bounce,
        builder: (_, child) =>
            Transform.translate(offset: Offset(0, _bounce.value), child: child),
        child: const Icon(Icons.keyboard_arrow_down_rounded,
            color: AppColors.textLabel, size: 22),
      ),
    ]);
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// 2. ADIMLAR BÖLÜMÜ
// ═════════════════════════════════════════════════════════════════════════════

class _StepsSection extends StatelessWidget {
  const _StepsSection({
    required this.sectionKey,
    required this.stepFades,
    required this.stepSlides,
    required this.onLiveTap,
  });

  final Key sectionKey;
  final List<Animation<double>> stepFades;
  final List<Animation<Offset>> stepSlides;
  final VoidCallback onLiveTap;

  static const _steps = [
    _StepData(
      number: '1',
      title: 'Sipariş Gelir',
      description:
          'Sistem saniyeler içinde en yakın kuryeyi bulur ve görevi otomatik olarak atar.',
      icon: Icons.inbox_rounded,
      accent: Color(0xFF4DBFB0),
    ),
    _StepData(
      number: '2',
      title: 'Rotalar Optimize Edilir',
      description:
          'Gereksiz kilometreler silinir, en hızlı ve en verimli teslimat yolu çizilir.',
      icon: Icons.route_rounded,
      accent: Color(0xFF3ECFCE),
    ),
    _StepData(
      number: '3',
      title: 'Kusursuz Teslimat',
      description:
          'Müşteri zamanında kargosunu alır; siz kârlılığınızı gerçek zamanlı izlersiniz.',
      icon: Icons.verified_rounded,
      accent: Color(0xFF56D9CA),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      key: sectionKey,
      color: AppColors.backgroundDeep,
      child: Column(children: [
        // Başlık
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 56, 24, 8),
          child: Column(children: [
            Text(
              'NASIL ÇALIŞIR?',
              style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textAccent,
                  letterSpacing: 2.5),
            ),
            const SizedBox(height: 10),
            Text(
              'Üç adımda\nmükemmel operasyon',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  height: 1.08),
            ),
          ]),
        ),

        // Kartlar
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: Column(
            children: List.generate(_steps.length, (i) {
              final isLast = i == _steps.length - 1;
              return FadeTransition(
                opacity: stepFades[i],
                child: SlideTransition(
                  position: stepSlides[i],
                  child: Column(children: [
                    _StepCard(data: _steps[i]),
                    if (!isLast) ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 52),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 1.5,
                            height: 32,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  _steps[i].accent.withAlpha(160),
                                  _steps[i].accent.withAlpha(40),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ]),
                ),
              );
            }),
          ),
        ),

        // Alt aksiyonlar
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 36, 20, 48),
          child: Column(children: [
            GestureDetector(
              onTap: onLiveTap,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.inputFocusBorder.withAlpha(80),
                      width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                            color: AppColors.textAccent,
                            shape: BoxShape.circle)),
                    const SizedBox(width: 10),
                    Text('Siparişini Canlı Takip Et',
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded,
                        color: AppColors.textAccent, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: onLiveTap,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Nasıl Kazanacaksınız?',
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary)),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_rounded,
                      color: AppColors.textSecondary, size: 14),
                ],
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _StepData {
  const _StepData({
    required this.number,
    required this.title,
    required this.description,
    required this.icon,
    required this.accent,
  });
  final String number;
  final String title;
  final String description;
  final IconData icon;
  final Color accent;
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.data});
  final _StepData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(60),
              blurRadius: 20,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Numara çemberi
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: data.accent, width: 1.5),
              color: data.accent.withAlpha(20),
            ),
            child: Center(
              child: Text(data.number,
                  style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: data.accent)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(data.icon, color: data.accent, size: 16),
                  const SizedBox(width: 6),
                  Text(data.title,
                      style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                ]),
                const SizedBox(height: 8),
                Text(data.description,
                    style: GoogleFonts.inter(
                        fontSize: 13.5,
                        color: AppColors.textSecondary,
                        height: 1.55)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// 3. ÇÖZÜMLER BÖLÜMÜ
// ═════════════════════════════════════════════════════════════════════════════

class _SolutionsSection extends StatelessWidget {
  const _SolutionsSection({
    required this.sectionKey,
    required this.cardFades,
    required this.cardSlides,
  });

  final Key sectionKey;
  final List<Animation<double>> cardFades;
  final List<Animation<Offset>> cardSlides;

  static const _cards = [
    _SolutionData(
      icon: Icons.shield_outlined,
      iconBg: Color(0xFF0D2A30),
      iconColor: Color(0xFF4DBFB0),
      title: 'Akıllı Rota Optimizasyonu',
      description:
          'Kuryeleriniz artık trafiğe veya uzun yollara takılmasın. '
          'Sistemimiz anlık durumlara göre en verimli güzergahı otomatik '
          'hesaplar. Yakıt ve zaman israfına son verin.',
      badge: 'YAKITTEN TASARRUF',
      badgeColor: Color(0xFF4DBFB0),
      badgeBg: Color(0xFF0D2A30),
    ),
    _SolutionData(
      icon: Icons.bolt_rounded,
      iconBg: Color(0xFF2A1A00),
      iconColor: Color(0xFFFFAA00),
      title: 'Kuşbakışı Filo Yönetimi',
      description:
          'Tüm saha ekibinizi gecikmesiz, tek bir harita üzerinden canlı '
          'izleyin. Neredeler, hangi siparişteler? Operasyonun tam kontrolü '
          'her an elinizin altında olsun.',
      badge: 'TAM KONTROL',
      badgeColor: Color(0xFFFFAA00),
      badgeBg: Color(0xFF2A1A00),
    ),
    _SolutionData(
      icon: Icons.bar_chart_rounded,
      iconBg: Color(0xFF1A1030),
      iconColor: Color(0xFF9B7FFF),
      title: 'Veriye Dayalı Büyüme',
      description:
          'Hangi kurye daha verimli? En yoğun saatler hangileri? '
          'Karmaşık operasyon verilerinizi, tek tıkla okunabilen stratejik '
          'büyüme raporlarına dönüştürün.',
      badge: 'PERFORMANS ARTIŞI',
      badgeColor: Color(0xFF9B7FFF),
      badgeBg: Color(0xFF1A1030),
    ),
  ];

  static const _stats = [
    _StatData(value: '%20', label: 'Ortalama Yakıt\nTasarrufu',
        color: Color(0xFF4DBFB0)),
    _StatData(value: '%35', label: 'Operasyon\nHız Artışı',
        color: Color(0xFFFFAA00)),
    _StatData(value: '7/24', label: 'Kesintisiz\nDenetim',
        color: Color(0xFF4DBFB0)),
    _StatData(value: '10X', label: 'Ölçeklenebilir\nAltyapı',
        color: Color(0xFFFFAA00)),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      key: sectionKey,
      color: const Color(0xFF090F1C),
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bölüm etiketi
          Text(
            'İŞİNİZE SAĞLADIĞI DEĞER',
            style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textAccent,
                letterSpacing: 2),
          ),
          const SizedBox(height: 10),

          // Büyük başlık
          Text(
            'KARMAŞAYI BİTİREN\nÇÖZÜMLER',
            style: GoogleFonts.inter(
                fontSize: 38,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                height: 1.04,
                letterSpacing: -0.3),
          ),
          const SizedBox(height: 12),

          // Alt başlık
          RichText(
            text: TextSpan(
              style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5),
              children: const [
                TextSpan(text: 'Operasyonel yükünüzü '),
                TextSpan(
                    text: 'hafifletirken',
                    style: TextStyle(
                        color: AppColors.textAccent,
                        fontStyle: FontStyle.italic)),
                TextSpan(
                    text:
                        ', kârlılığınızı artırmak için tasarlandı.'),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // 3 çözüm kartı
          ...List.generate(_cards.length, (i) {
            return FadeTransition(
              opacity: cardFades[i],
              child: SlideTransition(
                position: cardSlides[i],
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _SolutionCard(data: _cards[i]),
                ),
              ),
            );
          }),

          const SizedBox(height: 8),

          // 4 metrik satırı
          Container(
            padding: const EdgeInsets.symmetric(
                vertical: 24, horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder, width: 1),
            ),
            child: Row(
              children: List.generate(_stats.length, (i) {
                final isLast = i == _stats.length - 1;
                return Expanded(
                  child: Row(
                    children: [
                      Expanded(child: _StatTile(data: _stats[i])),
                      if (!isLast)
                        Container(
                            width: 1,
                            height: 40,
                            color: AppColors.cardBorder),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _SolutionData {
  const _SolutionData({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.badge,
    required this.badgeColor,
    required this.badgeBg,
  });
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String description;
  final String badge;
  final Color badgeColor;
  final Color badgeBg;
}

class _SolutionCard extends StatelessWidget {
  const _SolutionCard({required this.data});
  final _SolutionData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(70),
              blurRadius: 24,
              offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // İkon
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
                color: data.iconBg,
                borderRadius: BorderRadius.circular(12)),
            child: Icon(data.icon, color: data.iconColor, size: 22),
          ),
          const SizedBox(height: 16),

          // Başlık
          Text(
            data.title,
            style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),

          // Açıklama
          Text(
            data.description,
            style: GoogleFonts.inter(
                fontSize: 13.5,
                color: AppColors.textSecondary,
                height: 1.6),
          ),
          const SizedBox(height: 18),

          // Badge
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: data.badgeBg,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                  color: data.badgeColor.withAlpha(80), width: 1),
            ),
            child: Text(
              data.badge,
              style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: data.badgeColor,
                  letterSpacing: 1),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatData {
  const _StatData(
      {required this.value,
      required this.label,
      required this.color});
  final String value;
  final String label;
  final Color color;
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.data});
  final _StatData data;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(data.value,
          style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: data.color)),
      const SizedBox(height: 4),
      Text(data.label,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
              fontSize: 10,
              color: AppColors.textSecondary,
              height: 1.4)),
    ]);
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// 4. CTA BÖLÜMÜ
// ═════════════════════════════════════════════════════════════════════════════

class _CtaSection extends StatelessWidget {
  const _CtaSection({
    required this.sectionKey,
    required this.onStartTap,
  });
  final Key sectionKey;
  final VoidCallback onStartTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: sectionKey,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF090F1C), Color(0xFF071018)],
        ),
      ),
      child: Stack(children: [
        Positioned.fill(child: CustomPaint(painter: _GridPainter())),
        Center(
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                AppColors.primaryButton.withAlpha(25),
                Colors.transparent
              ]),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 64, 24, 72),
          child: Column(children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryButton.withAlpha(20),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppColors.primaryButton.withAlpha(80),
                    width: 1),
              ),
              child: Text('HEMEN BAŞLAYIN',
                  style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textAccent,
                      letterSpacing: 2)),
            ),
            const SizedBox(height: 20),
            Text(
              'Operasyonunuzu\nzirveye taşıyın.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  height: 1.05,
                  letterSpacing: -0.5),
            ),
            const SizedBox(height: 14),
            Text(
              'Kurumsal yönetim panelinize erişin\nve teslimatlarınızı otopilota alın.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.6),
            ),
            const SizedBox(height: 40),
            _BigCtaButton(onTap: onStartTap),
            const SizedBox(height: 20),
            Text('Ücretsiz demo için iletişime geçin.',
                style: GoogleFonts.inter(
                    fontSize: 12, color: AppColors.textLabel)),
          ]),
        ),
      ]),
    );
  }
}

class _BigCtaButton extends StatefulWidget {
  const _BigCtaButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_BigCtaButton> createState() => _BigCtaButtonState();
}

class _BigCtaButtonState extends State<_BigCtaButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 120),
        lowerBound: 0.96,
        upperBound: 1.0)
      ..value = 1.0;
    _scale =
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _ctrl.reverse(),
        onTapUp: (_) {
          _ctrl.forward();
          widget.onTap();
        },
        onTapCancel: () => _ctrl.forward(),
        child: Container(
          width: double.infinity,
          height: 62,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3ECFCE), Color(0xFF4DBFB0)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: AppColors.primaryButton.withAlpha(100),
                  blurRadius: 28,
                  offset: const Offset(0, 10)),
            ],
          ),
          child: Center(
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text('Hemen Başla',
                  style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textOnButton,
                      letterSpacing: 0.3)),
              const SizedBox(width: 10),
              const Icon(Icons.arrow_forward_rounded,
                  color: AppColors.textOnButton, size: 20),
            ]),
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// 4. KUSURSUZ İŞ AKIŞI — 4 adımlı alternating görsel+metin ızgarası
// ═════════════════════════════════════════════════════════════════════════════

// ═════════════════════════════════════════════════════════════════════════════
// 4. KUSURSUZ İŞ AKIŞI — birleşik kart + float animasyonu
// ═════════════════════════════════════════════════════════════════════════════

/// Her adım için tek bir birleşik kart (metin + yüzen ikon aynı kartta).
class _WorkflowSection extends StatelessWidget {
  const _WorkflowSection();

  static const _items = [
    _WorkflowItem(
      number: '01',
      title: 'Sıfır Karışıklık, Hızlı Atama',
      desc: 'Sipariş sisteme düştüğü an, en müsait ve konuma en yakın kurye '
          'saniyeler içinde belirlenir. Manuel yönlendirme hataları ve zaman '
          'kayıpları tarihe karışır.',
      icon: Icons.inventory_2_rounded,
      iconColor: Color(0xFF4DBFB0),
    ),
    _WorkflowItem(
      number: '02',
      title: 'Zaman Kazandıran Rotalar',
      desc: 'Kuryeler "Nereden gitsem?" diye düşünmez. Sistem, birden fazla '
          'durak noktası olsa bile trafiğe takılmayan, en pürüzsüz rotayı '
          'otomatik olarak çizer.',
      icon: Icons.map_rounded,
      iconColor: Color(0xFFFFAA00),
    ),
    _WorkflowItem(
      number: '03',
      title: 'Müşteriye Şeffaf Deneyim',
      desc: 'Sahadaki tüm kuryelerinizi canlı takip ekranında izlerken, '
          'yaşanabilecek olası sorunlara anında müdahale edebilir, müşteri '
          'şikayetlerini oluşmadan çözebilirsiniz.',
      icon: Icons.wifi_tethering_rounded,
      iconColor: Color(0xFF4DBFB0),
    ),
    _WorkflowItem(
      number: '04',
      title: 'Otomatik Performans Kaydı',
      desc: 'Her teslimatın süresi, rotası ve detayları kalıcı olarak '
          'arşivlenir. Ay sonunda "Hangi personel daha kârlı?" sorusunun '
          'cevabı saniyeler içinde ekranınıza yansır.',
      icon: Icons.storage_rounded,
      iconColor: Color(0xFF9B7FFF),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF060D1A),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 56, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('OPERASYON SÜRECİ',
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textAccent,
                        letterSpacing: 2.5)),
                const SizedBox(height: 10),
                Text('KUSURSUZ\nİŞ AKIŞI',
                    style: GoogleFonts.inter(
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        height: 0.92,
                        letterSpacing: -0.5)),
                const SizedBox(height: 18),
                Text(
                  'Telefon trafiklerini ve WhatsApp gruplarını unutun.\n'
                  'Her şey tek merkezden otomatik yönetilir.',
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.55),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: _items
                  .map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _WorkflowUnifiedCard(item: item),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

class _WorkflowItem {
  const _WorkflowItem({
    required this.number,
    required this.title,
    required this.desc,
    required this.icon,
    required this.iconColor,
  });
  final String number;
  final String title;
  final String desc;
  final IconData icon;
  final Color iconColor;
}

/// Tek kart: üstte metin, altta grid+float ikon — tüm içerik bir arada.
class _WorkflowUnifiedCard extends StatelessWidget {
  const _WorkflowUnifiedCard({required this.item});
  final _WorkflowItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0D1828),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: item.iconColor.withAlpha(12),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withAlpha(60),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Metin alanı ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.number,
                    style: GoogleFonts.inter(
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        color: item.iconColor.withAlpha(30),
                        height: 1)),
                const SizedBox(height: 8),
                Text(item.title,
                    style: GoogleFonts.inter(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.2)),
                const SizedBox(height: 10),
                Text(item.desc,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.65)),
              ],
            ),
          ),
          // ── Görsel alan (ızgara + yüzen ikon) ───────────────────────────
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(19)),
            child: Container(
              height: 150,
              color: const Color(0xFF0A1628),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Soft grid
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _SoftGridPainter(color: item.iconColor),
                    ),
                  ),
                  // Radial glow
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          item.iconColor.withAlpha(22),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  // Float animasyonlu ikon
                  _FloatingIcon(
                    icon: item.icon,
                    color: item.iconColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sonsuz yumuşak "breathe/float" animasyonu.
class _FloatingIcon extends StatefulWidget {
  const _FloatingIcon({required this.icon, required this.color});
  final IconData icon;
  final Color color;

  @override
  State<_FloatingIcon> createState() => _FloatingIconState();
}

class _FloatingIconState extends State<_FloatingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _floatY;
  late Animation<double> _glowOpacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    _floatY = Tween<double>(begin: -7, end: 7).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _glowOpacity = Tween<double>(begin: 0.3, end: 0.8).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _floatY.value),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Dış glow halkası
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color
                    .withAlpha((_glowOpacity.value * 25).toInt()),
              ),
            ),
            // İkon kutusu
            Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                color: widget.color.withAlpha(18),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                    color: widget.color.withAlpha(80), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: widget.color
                        .withAlpha((_glowOpacity.value * 60).toInt()),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(widget.icon, color: widget.color, size: 32),
            ),
          ],
        ),
      ),
    );
  }
}

class _SoftGridPainter extends CustomPainter {
  const _SoftGridPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withAlpha(10)
      ..strokeWidth = 0.5;
    const step = 30.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_SoftGridPainter old) => old.color != color;
}

// ═════════════════════════════════════════════════════════════════════════════
// 6. İLETİŞİM — "BİRLİKTE BÜYÜYELİM" (Form + Info Kartları)
// ═════════════════════════════════════════════════════════════════════════════

class _ContactSection extends StatefulWidget {
  const _ContactSection();

  @override
  State<_ContactSection> createState() => _ContactSectionState();
}

class _ContactSectionState extends State<_ContactSection> {
  final _firstCtrl   = TextEditingController();
  final _lastCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _msgCtrl     = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _emailCtrl.dispose();
    _subjectCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    setState(() => _sending = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    setState(() => _sending = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.textAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        content: Text('Talebiniz iletildi! En kısa sürede dönüş yapacağız.',
            style: GoogleFonts.inter(
                color: const Color(0xFF060D1A),
                fontWeight: FontWeight.w600)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF060D1A),
      padding: const EdgeInsets.fromLTRB(24, 64, 24, 56),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Başlık ────────────────────────────────────────────────────────
          Text('İLETİŞİME GEÇ',
              style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textAccent,
                  letterSpacing: 2.5)),
          const SizedBox(height: 10),
          Text('BİRLİKTE\nBÜYÜYELİM',
              style: GoogleFonts.inter(
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  height: 0.92,
                  letterSpacing: -0.5)),
          const SizedBox(height: 16),
          Text(
            'Sistemi kendi firmanıza uyarlamak, maliyetlerinizi düşürmek '
            'veya canlı demo talep etmek için bize yazın.',
            style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.6),
          ),
          const SizedBox(height: 36),

          // ── Form kartı ────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1828),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.cardBorder, width: 1),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withAlpha(60),
                    blurRadius: 24,
                    offset: const Offset(0, 8)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // AD + SOYAD yan yana
                Row(
                  children: [
                    Expanded(
                      child: _ContactField(
                          ctrl: _firstCtrl,
                          label: 'AD',
                          hint: 'Ahmet'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ContactField(
                          ctrl: _lastCtrl,
                          label: 'SOYAD',
                          hint: 'Yılmaz'),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _ContactField(
                    ctrl: _emailCtrl,
                    label: 'E-POSTA',
                    hint: 'ahmet@firma.com',
                    keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 14),
                _ContactField(
                    ctrl: _subjectCtrl,
                    label: 'KONU',
                    hint: 'Demo talebi / Fiyat bilgisi...'),
                const SizedBox(height: 14),
                _ContactField(
                    ctrl: _msgCtrl,
                    label: 'MESAJ',
                    hint: 'Kaç kuryeniz var? Sistemi nasıl kullanmak istersiniz?',
                    maxLines: 4),
                const SizedBox(height: 20),
                // Gönder butonu
                SizedBox(
                  width: double.infinity,
                  child: _sending
                      ? Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.textAccent.withAlpha(20),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppColors.textAccent.withAlpha(60)),
                          ),
                          alignment: Alignment.center,
                          child: const SizedBox(
                            width: 22, height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.textAccent),
                          ),
                        )
                      : GestureDetector(
                          onTap: _send,
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF4DBFB0),
                                  Color(0xFF2E9E91),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.textAccent.withAlpha(80),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Talep Gönder',
                                    style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF060D1A))),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward_rounded,
                                    color: Color(0xFF060D1A), size: 18),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── İletişim bilgi kartları ────────────────────────────────────────
          _ContactInfoTile(
            icon: Icons.email_outlined,
            label: 'SATIŞ & DESTEK',
            value: 'satis@loop.com.tr',
            color: AppColors.textAccent,
          ),
          const SizedBox(height: 10),
          _ContactInfoTile(
            icon: Icons.access_time_rounded,
            label: 'YANIT SÜRESİ',
            value: 'Genellikle 24 saat içinde',
            color: const Color(0xFF9B7FFF),
          ),
          const SizedBox(height: 10),
          _ContactInfoTile(
            icon: Icons.location_on_outlined,
            label: 'MERKEZ',
            value: 'İstanbul, Türkiye',
            color: const Color(0xFFFFAA00),
          ),
          const SizedBox(height: 36),

          // ── Footer ───────────────────────────────────────────────────────
          Divider(color: AppColors.cardBorder, thickness: 1),
          const SizedBox(height: 20),
          Row(
            children: [
              Text('LOOP',
                  style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      letterSpacing: 1.5)),
              const Spacer(),
              Text('© 2025 Loop Lojistik',
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textLabel)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Form giriş alanı bileşeni.
class _ContactField extends StatefulWidget {
  const _ContactField({
    required this.ctrl,
    required this.label,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });
  final TextEditingController ctrl;
  final String label;
  final String hint;
  final int maxLines;
  final TextInputType keyboardType;

  @override
  State<_ContactField> createState() => _ContactFieldState();
}

class _ContactFieldState extends State<_ContactField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label,
            style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.textLabel,
                letterSpacing: 1.2)),
        const SizedBox(height: 6),
        Focus(
          onFocusChange: (v) => setState(() => _focused = v),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: const Color(0xFF0A1422),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: _focused
                      ? AppColors.textAccent.withAlpha(160)
                      : AppColors.cardBorder,
                  width: _focused ? 1.5 : 1),
              boxShadow: _focused
                  ? [
                      BoxShadow(
                          color: AppColors.textAccent.withAlpha(30),
                          blurRadius: 10,
                          spreadRadius: 0)
                    ]
                  : [],
            ),
            child: TextField(
              controller: widget.ctrl,
              maxLines: widget.maxLines,
              keyboardType: widget.keyboardType,
              style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textLabel),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: widget.maxLines > 1 ? 12 : 14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// İletişim bilgi kartı (satış/yanıt/merkez).
class _ContactInfoTile extends StatelessWidget {
  const _ContactInfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1828),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(40),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withAlpha(14),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withAlpha(50), width: 1),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textLabel,
                      letterSpacing: 1.2)),
              const SizedBox(height: 3),
              Text(value,
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
            ],
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// 5. VİZYON — "LOJİSTİĞİ YENİDEN TANIMLIYORUZ"
// ═════════════════════════════════════════════════════════════════════════════

class _VisionSection extends StatelessWidget {
  const _VisionSection();

  static const _features = [
    _VisionFeature(
      icon: Icons.inventory_2_outlined,
      color: Color(0xFF4DBFB0),
      title: 'Ürün Yönetimi',
      subtitle: 'Şirketinizin ihtiyaçlarını koda döken vizyon.',
    ),
    _VisionFeature(
      icon: Icons.my_location_rounded,
      color: Color(0xFF4DBFB0),
      title: 'Operasyonel Zeka',
      subtitle: 'Coğrafi bilgi sistemleriyle rotaları kısaltan uzmanlık.',
    ),
    _VisionFeature(
      icon: Icons.access_time_rounded,
      color: Color(0xFF9B7FFF),
      title: 'Veri ve Analiz Mimarı',
      subtitle: 'Teslimat verilerinizi büyüme stratejisine çeviren güç.',
    ),
    _VisionFeature(
      icon: Icons.dns_rounded,
      color: Color(0xFF4DBFB0),
      title: 'Kesintisiz Altyapı',
      subtitle: 'İşleriniz durmasın diye 7/24 çalışan bulut sistemleri.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundDeep,
      padding: const EdgeInsets.fromLTRB(24, 64, 24, 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('VİZYONUMUZ',
              style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textAccent,
                  letterSpacing: 2.5)),
          const SizedBox(height: 10),
          Text('LOJİSTİĞİ\nYENİDEN TANIMLIYORUZ',
              style: GoogleFonts.inter(
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  height: 0.92,
                  letterSpacing: -0.5)),
          const SizedBox(height: 36),
          // Vizyon metin bloğu
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1828),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.cardBorder, width: 1),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withAlpha(60),
                    blurRadius: 20,
                    offset: const Offset(0, 6)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(
                        fontSize: 17,
                        color: AppColors.textPrimary,
                        height: 1.5,
                        fontWeight: FontWeight.w600),
                    children: [
                      const TextSpan(
                          text: 'Teslimat süreçlerindeki maliyet kayıplarını'
                              ' ve gecikmeleri, '),
                      TextSpan(
                          text: 'akıllı yazılım mimarisiyle sıfıra indirmek',
                          style: GoogleFonts.inter(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textAccent,
                              fontStyle: FontStyle.italic,
                              height: 1.5)),
                      const TextSpan(text: ' için buradayız.'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Geleneksel kurye yönetiminde firmalar süreci tahminlere bırakır. '
                  'Sipariş alınır, kurye yola çıkar ve sonrası tamamen bir bilinmezliktir. '
                  'Biz bu körlüğü ortadan kaldırdık. Sistemimiz her bir siparişi, rotayı ve '
                  'kuryeyi anlık olarak denetler, verimsizliği anında fark edip optimize eder.',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.65),
                ),
                const SizedBox(height: 14),
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.65),
                    children: [
                      const TextSpan(
                          text: 'Amacımız, şirketlerin büyümesine engel olan '),
                      TextSpan(
                          text: 'operasyonel tıkanıklıkları',
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              height: 1.65)),
                      const TextSpan(
                          text: ' ortadan kaldırarak, lojistiği bir dert olmaktan '
                              'çıkarıp, rekabet avantajına dönüştürmektir.'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Özellik kartları
          Column(
            children: _features
                .map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _VisionFeatureCard(feature: f),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _VisionFeature {
  const _VisionFeature({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
}

class _VisionFeatureCard extends StatelessWidget {
  const _VisionFeatureCard({required this.feature});
  final _VisionFeature feature;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1828),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(40),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: feature.color.withAlpha(14),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: feature.color.withAlpha(50), width: 1),
            ),
            child: Icon(feature.icon, color: feature.color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(feature.title,
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 3),
                Text(feature.subtitle,
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.4)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right_rounded,
              color: AppColors.textLabel, size: 18),
        ],
      ),
    );
  }
}



// �����������������������������������������������������������������������������
// Sipari� Takip Modal� (Image 19 referans al�narak)
// �����������������������������������������������������������������������������

void _showTrackingModal(BuildContext context) {
  final TextEditingController trackingCtrl = TextEditingController();
  showDialog(
    context: context,
    builder: (ctx) {
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFF1B2332),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.cardBorder.withAlpha(40), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(80),
                blurRadius: 40,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(10),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded,
                        color: AppColors.textSecondary, size: 18),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryButton.withAlpha(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryButton.withAlpha(50),
                      blurRadius: 20,
                      spreadRadius: 4,
                    )
                  ],
                ),
                child: const Center(
                  child: Text('??', style: TextStyle(fontSize: 32)),
                ),
              ),
              const SizedBox(height: 24),
              Text('LOOP',
                  style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      letterSpacing: 2)),
              const SizedBox(height: 4),
              Text('Lojistik Sipariş Takip',
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary)),
              const SizedBox(height: 40),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('SİPARİŞ TAKİP NUMARASI',
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.8)),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: trackingCtrl,
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'LOOP- Örn: 1, 2, 3...',
                  hintStyle: GoogleFonts.inter(
                      color: AppColors.textSecondary.withAlpha(150)),
                  filled: true,
                  fillColor: const Color(0xFF263243),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.transparent, width: 0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.primaryButton, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryButton,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 10,
                    shadowColor: AppColors.primaryButton.withAlpha(100),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClientTrackingScreen(trackingNumber: trackingCtrl.text),
                      ),
                    );
                  },
                  child: Text('Siparişi Takip Et',
                      style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textOnButton)),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Takip numaranızı sipariş onay SMS'inizde veya e-postanızda\nbulabilirsiniz.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 10,
                    height: 1.4,
                    color: AppColors.textSecondary.withAlpha(150)),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      );
    },
  );
}
