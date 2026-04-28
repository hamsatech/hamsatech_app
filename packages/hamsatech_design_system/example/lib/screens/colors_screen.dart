import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';
import '../widgets/showcase_helpers.dart';

class ColorsScreen extends StatelessWidget {
  const ColorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcaseBody(
      sections: [
        ShowcaseSection(
          title: 'BRAND & SEMANTIC',
          description: 'Core palette used across all components',
          children: [
            ShowcaseCard(child: _SwatchGrid(swatches: _brand)),
          ],
        ),
        ShowcaseSection(
          title: 'GRAY SCALE',
          description: 'From white to black',
          children: [
            ShowcaseCard(child: _SwatchGrid(swatches: _grays)),
          ],
        ),
        ShowcaseSection(
          title: 'APP SURFACES',
          description: 'Dark-theme surface tokens',
          children: [
            ShowcaseCard(child: _SwatchGrid(swatches: _surfaces)),
          ],
        ),
        ShowcaseSection(
          title: 'TEXT',
          description: 'Text colour tokens',
          children: [
            ShowcaseCard(child: _SwatchGrid(swatches: _text)),
          ],
        ),
      ],
    );
  }
}

const _brand = [
  _Swatch('Brand', DSColors.brand, '0xFFF97316'),
  _Swatch('Brand Hover', DSColors.brandHover, '0xFFEA6C10'),
  _Swatch('Brand Pressed', DSColors.brandPressed, '0xFFD35F0A'),
  _Swatch('Error', DSColors.error, '0xFFEF4444'),
  _Swatch('Success', DSColors.success, '0xFF10B981'),
  _Swatch('Warning', DSColors.warning, '0xFFF59E0B'),
  _Swatch('Info', DSColors.info, '0xFF3B82F6'),
  _Swatch('White', DSColors.white, '0xFFFFFFFF', dark: true),
  _Swatch('Black', DSColors.black, '0xFF09090B'),
];

const _grays = [
  _Swatch('Gray 50', DSColors.gray50, '0xFFF9FAFB', dark: true),
  _Swatch('Gray 100', DSColors.gray100, '0xFFF3F4F6', dark: true),
  _Swatch('Gray 200', DSColors.gray200, '0xFFE4E4E7', dark: true),
  _Swatch('Gray 300', DSColors.gray300, '0xFFD1D5DB', dark: true),
  _Swatch('Gray 400', DSColors.gray400, '0xFF9CA3AF'),
  _Swatch('Gray 500', DSColors.gray500, '0xFF6B7280'),
  _Swatch('Gray 600', DSColors.gray600, '0xFF4B5563'),
  _Swatch('Gray 700', DSColors.gray700, '0xFF374151'),
  _Swatch('Gray 800', DSColors.gray800, '0xFF1F2937'),
  _Swatch('Gray 900', DSColors.gray900, '0xFF111827'),
];

const _surfaces = [
  _Swatch('Background', DSColors.appBackground, '0xFF0A0E1A'),
  _Swatch('Surface', DSColors.appSurface, '0xFF131929'),
  _Swatch('Card', DSColors.appCard, '0xFF1A2235'),
  _Swatch('Card Elevated', DSColors.appCardElevated, '0xFF1F2940'),
  _Swatch('Border', DSColors.appBorder, '0xFF2D3748'),
  _Swatch('Divider', DSColors.appDivider, '0xFF1E293B'),
];

const _text = [
  _Swatch('Text Primary', DSColors.textPrimary, '0xFFF8FAFC', dark: true),
  _Swatch('Text Secondary', DSColors.textSecondary, '0xFF94A3B8'),
  _Swatch('Text Muted', DSColors.textMuted, '0xFF475569'),
];

class _Swatch {
  const _Swatch(this.name, this.color, this.hex, {this.dark = false});
  final String name;
  final Color color;
  final String hex;
  final bool dark;
}

class _SwatchGrid extends StatelessWidget {
  const _SwatchGrid({required this.swatches});
  final List<_Swatch> swatches;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: swatches.map((s) => _SwatchTile(swatch: s)).toList(),
    );
  }
}

class _SwatchTile extends StatelessWidget {
  const _SwatchTile({required this.swatch});
  final _Swatch swatch;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: swatch.hex));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Copied ${swatch.hex}'), duration: const Duration(seconds: 1)),
        );
      },
      child: SizedBox(
        width: 80,
        child: Column(
          children: [
            Container(
              height: 52,
              decoration: BoxDecoration(
                color: swatch.color,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
              ),
              child: Center(child: Icon(Icons.copy_rounded, size: 14, color: swatch.dark ? Colors.black45 : Colors.white60)),
            ),
            const SizedBox(height: 5),
            Text(swatch.name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600), textAlign: TextAlign.center, maxLines: 2),
            Text(swatch.hex.replaceAll('0xFF', '#'), style: TextStyle(fontSize: 9, color: Colors.grey[500], fontFamily: 'monospace'), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
