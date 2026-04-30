import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

import '../../data/repositories/login_repository_impl.dart';
import '../../domain/entities/onboarding_slide_entity.dart';
import '../bloc/welcome_bloc.dart';
import '../bloc/welcome_event.dart';
import '../bloc/welcome_state.dart';
import '../viewmodels/welcome_view_model.dart';
import '../widgets/page_indicator.dart';

// ── Palette (matches Figma "login -v2" frame) ─────────────────────────────────
const _kBrand     = DSColors.terracotta;  // #C94B2A
const _kBodyMuted = Color(0xFF6B7280);   // subtitle text

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WelcomeBloc(
        WelcomeViewModel(const MockLoginRepository()),
      ),
      child: const _WelcomeView(),
    );
  }
}

// ── View ──────────────────────────────────────────────────────────────────────

class _WelcomeView extends StatefulWidget {
  const _WelcomeView();

  @override
  State<_WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<_WelcomeView> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.82);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WelcomeBloc, WelcomeState>(
      listenWhen: (prev, curr) =>
          curr.status != WelcomeStatus.idle && curr.status != prev.status,
      listener: (context, state) {
        HapticFeedback.lightImpact();
        context.push('/login');
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: BlocBuilder<WelcomeBloc, WelcomeState>(
            builder: (context, state) {
              return SingleChildScrollView(
                child: Column(spacing: DSSpacing.xs, 
                  children: [
                    const SizedBox(height: 28),
                    const _Header(),
                    const SizedBox(height: 20),
                    _Carousel(
                      slides: state.slides,
                      pageController: _pageController,
                      onPageChanged: (page) =>
                          context.read<WelcomeBloc>().add(WelcomePageChanged(page)),
                    ),
                    const SizedBox(height: 20),
                    _Caption(slide: state.currentSlide),
                    const SizedBox(height: 14),
                    PageIndicator(
                      count: state.slides.length,
                      currentIndex: state.currentPage,
                      activeColor: _kBrand,
                      inactiveColor: const Color(0xFFD6D3D1),
                    ),
                    const SizedBox(height: 28),
                    _ActionButtons(
                      onSignUp: () =>
                          context.read<WelcomeBloc>().add(const WelcomeSignUpTapped()),
                      onLogIn: () =>
                          context.read<WelcomeBloc>().add(const WelcomeLogInTapped()),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            WelcomeViewModel.headerSubtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _kBodyMuted,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            WelcomeViewModel.headerTitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: _kBrand,
              letterSpacing: -0.5,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Carousel ──────────────────────────────────────────────────────────────────

class _Carousel extends StatelessWidget {
  const _Carousel({
    required this.slides,
    required this.pageController,
    required this.onPageChanged,
  });

  final List<OnboardingSlideEntity> slides;
  final PageController pageController;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final cardHeight = MediaQuery.of(context).size.height * 0.44;

    return SizedBox(
      height: cardHeight,
      child: PageView.builder(
        controller: pageController,
        itemCount: slides.length,
        onPageChanged: onPageChanged,
        itemBuilder: (context, index) =>
            _SlideCard(slide: slides[index], index: index),
      ),
    );
  }
}

// ── Slide Card ────────────────────────────────────────────────────────────────

class _SlideCard extends StatelessWidget {
  const _SlideCard({required this.slide, required this.index});

  final OnboardingSlideEntity slide;
  final int index;

  static const _gradients = [
    [Color(0xFF6B2E0F), Color(0xFF9B3A20)],
    [Color(0xFF3D1A0A), Color(0xFF7A2E14)],
    [Color(0xFF1A0D05), Color(0xFF6B2810)],
  ];

  static const _icons = [
    Icons.track_changes_rounded,
    Icons.psychology_rounded,
    Icons.emoji_events_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final colors = _gradients[index % _gradients.length];
    final icon = _icons[index % _icons.length];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: slide.imageNetworkUrl != null
            ? Image.network(
                slide.imageNetworkUrl!,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : _Placeholder(colors: colors, icon: icon),
                errorBuilder: (_, __, ___) =>
                    _Placeholder(colors: colors, icon: icon),
              )
            : slide.imageAssetPath != null
                ? Image.asset(
                    slide.imageAssetPath!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _Placeholder(colors: colors, icon: icon),
                  )
                : _Placeholder(colors: colors, icon: icon),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.colors, required this.icon});

  final List<Color> colors;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (final size in [260.0, 190.0, 120.0])
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.07),
                  width: 1,
                ),
              ),
            ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.22),
                width: 1.5,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 38),
          ),
        ],
      ),
    );
  }
}

// ── Caption ───────────────────────────────────────────────────────────────────

class _Caption extends StatelessWidget {
  const _Caption({required this.slide});

  final OnboardingSlideEntity? slide;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.06),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: slide == null
          ? const SizedBox.shrink()
          : Padding(
              key: ValueKey(slide!.id),
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: Text(
                slide!.caption,
                textAlign: TextAlign.center,
                style: GoogleFonts.ptSerif(
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF212529),
                  height: 32 / 28, // 32px line-height from Figma
                  letterSpacing: 0,
                ),
              ),
            ),
    );
  }
}

// ── Action Buttons ────────────────────────────────────────────────────────────

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.onSignUp,
    required this.onLogIn,
  });

  final VoidCallback onSignUp;
  final VoidCallback onLogIn;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          DSPrimaryButton(
            label: WelcomeViewModel.signUpLabel,
            onPressed: onSignUp,
            color: _kBrand,
            textStyle: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 14),
          DSSecondaryTextButton(
            label: WelcomeViewModel.loginLabel,
            onPressed: onLogIn,
            color: _kBrand,
            textStyle: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _kBrand,
            ),
          ),
        ],
      ),
    );
  }
}
