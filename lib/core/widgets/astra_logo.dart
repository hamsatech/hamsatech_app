import 'package:flutter/material.dart';

// ── Colour constants (brand palette) ─────────────────────────────────────────
const _kCyanHigh  = Color(0xFFBEF8FF); // top-edge highlight
const _kCyanMid   = Color(0xFF4FD8EC); // mid illuminated face
const _kTealMid   = Color(0xFF2F7E8F); // brand teal
const _kTealDeep  = Color(0xFF1D6070); // shadow face
const _kTealDark  = Color(0xFF0D3A45); // deepest shadow

/// Full ASTRA lockup: symbol + wordmark, sized to [size] in width.
/// Use [wordmarkColor] = Colors.white for dark backgrounds,
/// [wordmarkColor] = const Color(0xFF000F12) for light backgrounds.
class AstraLogo extends StatelessWidget {
  const AstraLogo({
    this.size = 120,
    this.wordmarkColor = Colors.white,
    this.showWordmark = true,
    super.key,
  });

  final double size;
  final Color wordmarkColor;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    final symbolSize = size;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: symbolSize,
          height: symbolSize * 0.85,
          child: CustomPaint(painter: _AstraSymbolPainter()),
        ),
        if (showWordmark) ...[
          SizedBox(height: symbolSize * 0.18),
          _AstraWordmark(color: wordmarkColor, size: size),
        ],
      ],
    );
  }
}

/// Just the triangular ASTRA symbol, no wordmark.
class AstraSymbol extends StatelessWidget {
  const AstraSymbol({this.size = 80, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.85,
      child: CustomPaint(painter: _AstraSymbolPainter()),
    );
  }
}

// ── Symbol painter ────────────────────────────────────────────────────────────

class _AstraSymbolPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── Left arm ──────────────────────────────────────────────────────────────
    // Outer left edge: from (50%,0%) arcs down to (0%, 100%)
    // Inner left edge: from (50%, 22%) arcs down to (18%, 100%)
    final leftArm = Path()
      ..moveTo(w * 0.50, 0)
      ..cubicTo(w * 0.40, h * 0.08, w * 0.20, h * 0.40, w * 0.02, h)
      ..lineTo(w * 0.20, h)
      ..cubicTo(w * 0.30, h * 0.46, w * 0.46, h * 0.18, w * 0.50, h * 0.22)
      ..close();

    _drawArm(canvas, leftArm, w, h,
        light: Alignment.topCenter, dark: Alignment.bottomLeft,
        lightColor: _kCyanHigh, darkColor: _kTealDeep);

    // ── Right arm ─────────────────────────────────────────────────────────────
    final rightArm = Path()
      ..moveTo(w * 0.50, 0)
      ..cubicTo(w * 0.60, h * 0.08, w * 0.80, h * 0.40, w * 0.98, h)
      ..lineTo(w * 0.80, h)
      ..cubicTo(w * 0.70, h * 0.46, w * 0.54, h * 0.18, w * 0.50, h * 0.22)
      ..close();

    _drawArm(canvas, rightArm, w, h,
        light: Alignment.topCenter, dark: Alignment.bottomRight,
        lightColor: _kCyanMid, darkColor: _kTealDark);

    // ── Bottom crossbar (the horizontal bar of "A") ───────────────────────────
    // Sits at roughly 55%–75% vertical, connecting left to right inner edges
    final barY1 = h * 0.55;
    final barY2 = h * 0.72;

    final leftOuterAtBar1 = _pointOnCubic(
        Offset(w * 0.50, 0),
        Offset(w * 0.40, h * 0.08),
        Offset(w * 0.20, h * 0.40),
        Offset(w * 0.02, h),
        barY1 / h);

    final leftInnerAtBar2 = _pointOnCubic(
        Offset(w * 0.50, h * 0.22),
        Offset(w * 0.30, h * 0.46),
        Offset(w * 0.20, h),
        Offset(w * 0.20, h),
        barY2 / h);

    // Mirror for right side
    final rightOuterAtBar1 = Offset(w - leftOuterAtBar1.dx + w * 0.04, leftOuterAtBar1.dy);
    final rightInnerAtBar2 = Offset(w - leftInnerAtBar2.dx, leftInnerAtBar2.dy);

    final crossbar = Path()
      ..moveTo(leftOuterAtBar1.dx, leftOuterAtBar1.dy)
      ..lineTo(rightOuterAtBar1.dx, rightOuterAtBar1.dy)
      ..lineTo(rightInnerAtBar2.dx, rightInnerAtBar2.dy)
      ..lineTo(leftInnerAtBar2.dx, leftInnerAtBar2.dy)
      ..close();

    final barRect = Rect.fromLTWH(0, barY1, w, barY2 - barY1 + h * 0.06);
    final barPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [_kCyanMid, _kTealMid, _kTealDeep],
      ).createShader(barRect)
      ..style = PaintingStyle.fill;
    canvas.drawPath(crossbar, barPaint);

    // ── Top highlight edge ────────────────────────────────────────────────────
    final highlightPaint = Paint()
      ..color = _kCyanHigh.withValues(alpha: 0.55)
      ..strokeWidth = w * 0.012
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final highlightPath = Path()
      ..moveTo(w * 0.50, 0)
      ..cubicTo(w * 0.40, h * 0.08, w * 0.20, h * 0.40, w * 0.02, h);
    canvas.drawPath(highlightPath, highlightPaint);

    final highlightPathR = Path()
      ..moveTo(w * 0.50, 0)
      ..cubicTo(w * 0.60, h * 0.08, w * 0.80, h * 0.40, w * 0.98, h);
    canvas.drawPath(highlightPathR, highlightPaint);

    // ── Top apex glow ────────────────────────────────────────────────────────
    final apexGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          _kCyanHigh.withValues(alpha: 0.8),
          _kCyanHigh.withValues(alpha: 0),
        ],
        radius: 0.5,
      ).createShader(Rect.fromCircle(center: Offset(w * 0.5, 0), radius: w * 0.18));
    canvas.drawCircle(Offset(w * 0.5, 0), w * 0.18, apexGlow);
  }

  void _drawArm(Canvas canvas, Path path, double w, double h,
      {required Alignment light,
      required Alignment dark,
      required Color lightColor,
      required Color darkColor}) {
    final rect = Rect.fromLTWH(0, 0, w, h);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: light,
        end: dark,
        colors: [lightColor, _kTealMid, darkColor],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(rect)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
  }

  // Approximate a point at fraction t along a cubic bezier.
  Offset _pointOnCubic(Offset p0, Offset c1, Offset c2, Offset p1, double t) {
    final mt = 1 - t;
    return Offset(
      mt * mt * mt * p0.dx +
          3 * mt * mt * t * c1.dx +
          3 * mt * t * t * c2.dx +
          t * t * t * p1.dx,
      mt * mt * mt * p0.dy +
          3 * mt * mt * t * c1.dy +
          3 * mt * t * t * c2.dy +
          t * t * t * p1.dy,
    );
  }

  @override
  bool shouldRepaint(_AstraSymbolPainter oldDelegate) => false;
}

// ── Wordmark ──────────────────────────────────────────────────────────────────

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
            Color(0xFF0E3D4A), // lighter teal center
            Color(0xFF061E26), // dark teal mid
            Color(0xFF020E13), // near-black edge
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: child,
    );
  }
}

// ── Ambient glow helper ───────────────────────────────────────────────────────

/// Adds a subtle radial glow behind the ASTRA logo.
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
            const Color(0xFF2F7E8F).withValues(alpha: 0.25),
            const Color(0xFF2F7E8F).withValues(alpha: 0.08),
            Colors.transparent,
          ],
          stops: const [0.0, 0.45, 1.0],
        ),
      ),
    );
  }
}

// ── Small logo chip (nav / header use) ───────────────────────────────────────

/// Compact branded mark for headers and nav bars — symbol only with
/// the ASTRA text beside it on a single row.
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
        SizedBox(
          width: symbolSize,
          height: symbolSize * 0.85,
          child: CustomPaint(painter: _AstraSymbolPainter()),
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
