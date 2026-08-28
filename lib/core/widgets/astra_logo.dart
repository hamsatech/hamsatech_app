import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

const _kSvgAsset = 'assets/logos/astra_logo.svg';
const _kPngAsset = 'assets/logos/astra_logo.png';

// ── Colour constant (used by AstraGlow) ──────────────────────────────────────
const _kTealMid = Color(0xFF2F7E8F);

/// Semantic size presets for [AstraLogo].
enum AstraLogoSize {
  small(60),
  medium(100),
  large(140);

  const AstraLogoSize(this.symbolWidth);
  final double symbolWidth;
}

/// Full ASTRA lockup: official PNG symbol + wordmark, sized to [size] in width.
///
/// [wordmarkColor] = Colors.white  → dark backgrounds (splash)
/// [wordmarkColor] = Color(0xFF000F12) → light backgrounds (welcome, onboarding)
class AstraLogo extends StatelessWidget {
  const AstraLogo({
    this.size = 120,
    this.wordmarkColor = Colors.white,
    this.showWordmark = true,
    super.key,
  });

  /// Convenience constructor using semantic size presets.
  factory AstraLogo.preset(
    AstraLogoSize preset, {
    Color wordmarkColor = Colors.white,
    bool showWordmark = true,
    Key? key,
  }) =>
      AstraLogo(
        size: preset.symbolWidth,
        wordmarkColor: wordmarkColor,
        showWordmark: showWordmark,
        key: key,
      );

  /// Width of the symbol. Height derives from the logo's 100×85 aspect ratio.
  final double size;

  /// Colour of the "ASTRA" text wordmark below the symbol.
  final Color wordmarkColor;

  /// Whether to render the text wordmark beneath the symbol.
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          _kPngAsset,
          width: size,
          height: size * 0.85,
          fit: BoxFit.contain,
          semanticLabel: 'ASTRA logo',
        ),
        if (showWordmark) ...[
          SizedBox(height: size * 0.18),
          _AstraWordmark(color: wordmarkColor, size: size),
        ],
      ],
    );
  }
}

/// Just the logo symbol — SVG for crisp tinted rendering at any size.
class AstraSymbol extends StatelessWidget {
  const AstraSymbol({
    this.size = 80,
    this.color,
    super.key,
  });

  final double size;

  /// Optional tint applied via [ColorFilter]. Null = full-colour gradient.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      _kSvgAsset,
      width: size,
      height: size * 0.85,
      colorFilter:
          color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
      semanticsLabel: 'ASTRA symbol',
    );
  }
}

/// Compact branded mark for headers — PNG symbol + "ASTRA" wordmark in a row.
class AstraLogoCompact extends StatelessWidget {
  const AstraLogoCompact({
    this.symbolSize = 28,
    this.textColor = const Color(0xFF000F12),
    super.key,
  });

  final double symbolSize;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          _kPngAsset,
          width: symbolSize,
          height: symbolSize * 0.85,
          fit: BoxFit.contain,
          semanticLabel: 'ASTRA symbol',
        ),
        SizedBox(width: symbolSize * 0.3),
        Text(
          'ASTRA',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: symbolSize * 0.58,
            fontWeight: FontWeight.w700,
            color: textColor,
            letterSpacing: symbolSize * 0.10,
            height: 1,
          ),
        ),
      ],
    );
  }
}

// ── Wordmark text ─────────────────────────────────────────────────────────────

class _AstraWordmark extends StatelessWidget {
  const _AstraWordmark({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(
      'ASTRA',
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: size * 0.32,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: size * 0.065,
        height: 1,
      ),
    );
  }
}

// ── Dark gradient splash background ──────────────────────────────────────────

/// Full-screen branded splash background matching the logo's dark teal gradient.
class AstraSplashBackground extends StatelessWidget {
  const AstraSplashBackground({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.25),
          radius: 1.4,
          colors: [
            Color(0xFF0E3D4A),
            Color(0xFF061E26),
            Color(0xFF020E13),
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: child,
    );
  }
}

// ── Ambient glow helper ───────────────────────────────────────────────────────

/// Subtle radial glow to place behind the ASTRA logo on dark backgrounds.
class AstraGlow extends StatelessWidget {
  const AstraGlow({required this.radius, super.key});

  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            _kTealMid.withValues(alpha: 0.25),
            _kTealMid.withValues(alpha: 0.08),
            Colors.transparent,
          ],
          stops: const [0.0, 0.45, 1.0],
        ),
      ),
    );
  }
}
