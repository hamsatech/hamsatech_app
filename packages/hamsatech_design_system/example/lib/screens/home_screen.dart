import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';
import 'button_showcase_screen.dart';
import 'checkbox_screen.dart';
import 'colors_screen.dart';
import 'inputs_screen.dart';
import 'list_select_screen.dart';
import 'misc_screen.dart';
import 'otp_showcase_screen.dart';
import 'typography_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onToggleTheme, required this.themeMode});

  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('HamsaTech DS', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        actions: [
          IconButton(
            icon: Icon(themeMode == ThemeMode.dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
            onPressed: onToggleTheme,
            tooltip: 'Toggle theme',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
        children: [
          _Banner(isDark: isDark),
          const SizedBox(height: 28),
          _GroupLabel(label: 'FOUNDATION', isDark: isDark),
          const SizedBox(height: 10),
          _NavCard(icon: Icons.palette_outlined, color: const Color(0xFF14B8A6), title: 'Colors', subtitle: 'Full palette · brand · semantic · surfaces · text', isDark: isDark, screen: const ColorsScreen()),
          _NavCard(icon: Icons.text_fields_rounded, color: const Color(0xFF8B5CF6), title: 'Typography', subtitle: 'Display · heading · body · label · app-specific · mono', isDark: isDark, screen: const TypographyScreen()),
          const SizedBox(height: 24),
          _GroupLabel(label: 'COMPONENTS', isDark: isDark),
          const SizedBox(height: 10),
          _NavCard(icon: Icons.smart_button_outlined, color: const Color(0xFF14B8A6), title: 'Buttons', subtitle: 'DSButton · DSIconButton · DSSegmentedControl · DSButtonGroup', isDark: isDark, screen: const ButtonShowcaseScreen()),
          _NavCard(icon: Icons.input_rounded, color: const Color(0xFF3B82F6), title: 'Inputs', subtitle: 'Text · Search · URL · Phone · Amount · Tags · Password · Date · Area · Group · Combobox', isDark: isDark, screen: const InputsScreen()),
          _NavCard(icon: Icons.dialpad_rounded, color: const Color(0xFF10B981), title: 'OTP Input', subtitle: '4-digit · 6-digit · separator · error · disabled · cell sizes', isDark: isDark, screen: const OtpShowcaseScreen()),
          _NavCard(icon: Icons.check_box_outlined, color: const Color(0xFF06B6D4), title: 'Checkbox', subtitle: 'DSCheckbox · Group · Card Group · Tree (indeterminate parent)', isDark: isDark, screen: const CheckboxScreen()),
          _NavCard(icon: Icons.list_alt_rounded, color: const Color(0xFFF59E0B), title: 'List / Select Item', subtitle: 'Check · Toggle · Checkbox · Icon · Avatar · Initials · Color dot', isDark: isDark, screen: const ListSelectScreen()),
          _NavCard(icon: Icons.widgets_outlined, color: const Color(0xFFEF4444), title: 'Misc', subtitle: 'DSScoreRing — animated arc score widget', isDark: isDark, screen: const MiscScreen()),
          const SizedBox(height: 28),
          _TokenPreview(isDark: isDark),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _Banner extends StatelessWidget {
  const _Banner({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF14B8A6), Color(0xFF0F766E)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.design_services_rounded, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('HamsaTech Design System', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 3),
                Text('2 foundations · 6 component groups', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel({required this.label, required this.isDark});
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1, color: isDark ? DSColors.textMuted : DSColors.gray400));
  }
}

class _NavCard extends StatelessWidget {
  const _NavCard({required this.icon, required this.color, required this.title, required this.subtitle, required this.isDark, required this.screen});

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool isDark;
  final Widget screen;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF1A2235) : Colors.white;
    final border = isDark ? const Color(0xFF2D3748) : const Color(0xFFE2E8F0);
    final arrowColor = isDark ? const Color(0xFF374151) : const Color(0xFFD1D5DB);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => screen)),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(9)),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(subtitle, style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF475569) : const Color(0xFF9CA3AF))),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios_rounded, size: 13, color: arrowColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TokenPreview extends StatelessWidget {
  const _TokenPreview({required this.isDark});
  final bool isDark;

  static const _swatches = [
    (DSColors.brand, 'Brand'),
    (DSColors.error, 'Error'),
    (DSColors.success, 'Success'),
    (DSColors.warning, 'Warning'),
    (DSColors.info, 'Info'),
    (DSColors.gray900, 'Gray 900'),
    (DSColors.gray500, 'Gray 500'),
    (DSColors.gray200, 'Gray 200'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GroupLabel(label: 'COLOR TOKENS', isDark: isDark),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _swatches.map((s) => Tooltip(
            message: s.$2,
            child: Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: s.$1,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.07) : Colors.black.withValues(alpha: 0.06)),
              ),
            ),
          )).toList(),
        ),
        const SizedBox(height: 20),
        _GroupLabel(label: 'TYPE SCALE PREVIEW', isDark: isDark),
        const SizedBox(height: 10),
        Text('Display Large', style: DSTypography.displayLarge.copyWith(fontSize: 22)),
        Text('Heading Medium', style: DSTypography.headingMedium),
        Text('Body medium — the quick brown fox jumps over the lazy dog.', style: DSTypography.bodyMedium),
        Text('Caption · small · muted', style: DSTypography.caption),
      ],
    );
  }
}
