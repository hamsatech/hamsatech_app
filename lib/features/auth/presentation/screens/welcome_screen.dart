import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

import '../../../../core/widgets/astra_logo.dart';
import '../../data/repositories/login_repository_impl.dart';
import '../../domain/entities/onboarding_slide_entity.dart';
import '../bloc/welcome_bloc.dart';
import '../bloc/welcome_event.dart';
import '../bloc/welcome_state.dart';
import '../viewmodels/welcome_view_model.dart';
import '../widgets/page_indicator.dart';

// ── Palette (matches Figma "login -v2" frame) ─────────────────────────────────
const _kBrand = DSColors.brand;

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
        if (state.status == WelcomeStatus.comingSoon) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Coming soon!',
                style: DSTypography.bodyMd.copyWith(color: Colors.white),
              ),
              backgroundColor: DSColors.gray700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DSRadius.md)),
            ),
          );
          return;
        }
        HapticFeedback.lightImpact();
        if (state.status == WelcomeStatus.navigateToSignUp) {
          context.go('/signup');
        } else {
          context.go('/login');
        }
      },
      child: Scaffold(
        backgroundColor: DSColors.appBackground,
        body: SafeArea(
          child: BlocBuilder<WelcomeBloc, WelcomeState>(
            builder: (context, state) {
              return SingleChildScrollView(
                child: Column(
                  spacing: DSSpacing.xs,
                  children: [
                    const SizedBox(height: 28),
                    const _Header(),
                    const SizedBox(height: 20),
                    _Carousel(
                      slides: state.slides,
                      pageController: _pageController,
                      onPageChanged: (page) => context
                          .read<WelcomeBloc>()
                          .add(WelcomePageChanged(page)),
                    ),
                    const SizedBox(height: 20),
                    _Caption(slide: state.currentSlide),
                    const SizedBox(height: 14),
                    PageIndicator(
                      count: state.slides.length,
                      currentIndex: state.currentPage,
                      activeColor: _kBrand,
                      inactiveColor: const Color(0xFFB0D8E0),
                    ),
                    const SizedBox(height: 28),
                    _ActionButtons(
                      onSignUp: () => context
                          .read<WelcomeBloc>()
                          .add(const WelcomeSignUpTapped()),
                      onLogIn: () => context
                          .read<WelcomeBloc>()
                          .add(const WelcomeLogInTapped()),
                      onGoogle: () => context
                          .read<WelcomeBloc>()
                          .add(const WelcomeGoogleTapped()),
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
    return Column(
      children: [
        const AstraLogo(
          size: 80,
          wordmarkColor: Color(0xFF000F12),
        ),
        const SizedBox(height: 10),
        Text(
          WelcomeViewModel.headerSubtitle,
          textAlign: TextAlign.center,
          style: DSTypography.onboardingSubheader,
        ),
      ],
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
    [Color(0xFF2F7E8F), Color(0xFF1D6070)],
    [Color(0xFF26707F), Color(0xFF1D6070)],
    [Color(0xFF1D6070), Color(0xFF164F5E)],
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
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: slide.hasImage
                  ? _SlideIllustration(imagePath: slide.imageAssetPath!)
                  : _Placeholder(colors: colors, icon: icon),
            ),
          ),
          if (slide.comingSoon)
            const Positioned(
              top: 16,
              right: 16,
              child: _ComingSoonBadge(),
            ),
        ],
      ),
    );
  }
}

// ── Slide illustration ────────────────────────────────────────────────────────

class _SlideIllustration extends StatelessWidget {
  const _SlideIllustration({required this.imagePath});
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.30),
                  blurRadius: 24,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Placeholder (no image) ────────────────────────────────────────────────────

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

// ── Coming Soon Badge ─────────────────────────────────────────────────────────

class _ComingSoonBadge extends StatelessWidget {
  const _ComingSoonBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF2F7E8F),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Coming Soon',
        style: DSTypography.bodySm.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
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
              child: Column(
                children: [
                  Text(
                    slide!.title,
                    textAlign: TextAlign.center,
                    style: DSTypography.onboardingCaption,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    slide!.description,
                    textAlign: TextAlign.center,
                    style: DSTypography.bodyMd.copyWith(
                      color: const Color(0x99000F12),
                      height: 1.5,
                    ),
                  ),
                ],
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
    required this.onGoogle,
  });

  final VoidCallback onSignUp;
  final VoidCallback onLogIn;
  final VoidCallback onGoogle;

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
            textStyle: DSTypography.headingMd.copyWith(
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 14),
          DSSecondaryTextButton(
            label: WelcomeViewModel.loginLabel,
            onPressed: onLogIn,
            color: _kBrand,
            textStyle: DSTypography.headingSm.copyWith(color: _kBrand),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
