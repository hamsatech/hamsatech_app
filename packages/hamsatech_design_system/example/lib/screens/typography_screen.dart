import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';
import '../widgets/showcase_helpers.dart';

class TypographyScreen extends StatelessWidget {
  const TypographyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark ? DSColors.textMuted : DSColors.gray400;

    Widget row(String token, TextStyle style, String meta) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 110,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(token, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: DSColors.brand, fontFamily: 'monospace')),
                    const SizedBox(height: 2),
                    Text(meta, style: TextStyle(fontSize: 9, color: labelColor, fontFamily: 'monospace')),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text('The quick brown fox', style: style)),
            ],
          ),
        );

    Widget divider() => Divider(height: 1, color: isDark ? DSColors.appBorder : DSColors.gray100);

    return ShowcaseScaffold(
      title: 'Typography',
      sections: [
        ShowcaseSection(
          title: 'DISPLAY',
          description: 'Hero text, splash screens',
          children: [
            ShowcaseCard(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                row('displayLg', DSTypography.displayLg, '48 · w700 · -0.5'),
                divider(),
                row('displayMd', DSTypography.displayMd, '36 · w700 · -0.3'),
                divider(),
                row('displaySm', DSTypography.displaySm, '30 · w600'),
              ]),
            ),
          ],
        ),
        ShowcaseSection(
          title: 'HEADING',
          description: 'Screen titles, card headers',
          children: [
            ShowcaseCard(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                row('headingXl', DSTypography.headingXl, '24 · w700'),
                divider(),
                row('headingLg', DSTypography.headingLg, '20 · w600'),
                divider(),
                row('headingMd', DSTypography.headingMd, '16 · w600'),
                divider(),
                row('headingSm', DSTypography.headingSm, '14 · w600'),
                divider(),
                row('headingXs', DSTypography.headingXs, '13 · w600'),
              ]),
            ),
          ],
        ),
        ShowcaseSection(
          title: 'BODY',
          description: 'Paragraphs, descriptions',
          children: [
            ShowcaseCard(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                row('bodyLg', DSTypography.bodyLg, '16 · w400 · h1.6'),
                divider(),
                row('bodyMd', DSTypography.bodyMd, '14 · w400 · h1.5'),
                divider(),
                row('bodySm', DSTypography.bodySm, '12 · w400 · h1.5'),
                divider(),
                row('bodyXs', DSTypography.bodyXs, '11 · w400 · h1.4'),
              ]),
            ),
          ],
        ),
        ShowcaseSection(
          title: 'LABEL',
          description: 'Buttons, tags, badges',
          children: [
            ShowcaseCard(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                row('labelLg', DSTypography.labelLg, '14 · w500'),
                divider(),
                row('labelMd', DSTypography.labelMd, '13 · w500'),
                divider(),
                row('labelSm', DSTypography.labelSm, '12 · w500'),
                divider(),
                row('labelXs', DSTypography.labelXs, '11 · w500'),
              ]),
            ),
          ],
        ),
        ShowcaseSection(
          title: 'APP-SPECIFIC',
          description: 'Named styles with baked-in colour used in screens',
          children: [
            ShowcaseCard(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                row('displayLarge', DSTypography.displayLarge, '32 · w700 · Primary'),
                divider(),
                row('displayMedium', DSTypography.displayMedium, '26 · w700 · Primary'),
                divider(),
                row('headingLarge', DSTypography.headingLarge, '22 · w600 · Primary'),
                divider(),
                row('headingMedium', DSTypography.headingMedium, '18 · w600 · Primary'),
                divider(),
                row('headingSmall', DSTypography.headingSmall, '16 · w600 · Primary'),
                divider(),
                row('bodyLarge', DSTypography.bodyLarge, '16 · w400 · Primary'),
                divider(),
                row('bodyMedium', DSTypography.bodyMedium, '14 · w400 · Primary'),
                divider(),
                row('bodySmall', DSTypography.bodySmall, '12 · w400 · Secondary'),
                divider(),
                row('labelLarge', DSTypography.labelLarge, '14 · w600 · Primary'),
                divider(),
                row('labelMedium', DSTypography.labelMedium, '12 · w500 · Secondary'),
                divider(),
                row('caption', DSTypography.caption, '11 · w400 · Muted'),
                divider(),
                row('metricValue', DSTypography.metricValue, '28 · w700 · Primary'),
                divider(),
                row('scoreDisplay', DSTypography.scoreDisplay, '48 · w800 · Primary'),
              ]),
            ),
          ],
        ),
        ShowcaseSection(
          title: 'MONO',
          description: 'Code, tokens, hex values',
          children: [
            ShowcaseCard(
              padding: const EdgeInsets.all(16),
              child: row('mono', DSTypography.mono, '13 · w400 · monospace'),
            ),
          ],
        ),
      ],
    );
  }
}
