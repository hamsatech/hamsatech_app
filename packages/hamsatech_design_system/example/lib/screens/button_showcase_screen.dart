import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';
import '../widgets/showcase_helpers.dart';

class ButtonShowcaseScreen extends StatefulWidget {
  const ButtonShowcaseScreen({super.key});

  @override
  State<ButtonShowcaseScreen> createState() => _ButtonShowcaseScreenState();
}

class _ButtonShowcaseScreenState extends State<ButtonShowcaseScreen> {
  String _segSelected = 'all';
  int? _groupSelected = 0;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return ShowcaseBody(
            sections: [
        ShowcaseSection(
          title: 'DSBUTTON · VARIANTS',
          description: 'All 9 variants in medium size',
          children: [
            ShowcaseCard(
              code: "DSButton(label: 'Brand', variant: DSButtonVariant.brand, onPressed: () {})",
              child: Wrap(spacing: 8, runSpacing: 8, children: [
                DSButton(label: 'Brand', variant: DSButtonVariant.brand, onPressed: () {}),
                DSButton(label: 'Black', variant: DSButtonVariant.black, onPressed: () {}),
                DSButton(label: 'Outline', variant: DSButtonVariant.outline, onPressed: () {}),
                DSButton(label: 'Gray', variant: DSButtonVariant.gray, onPressed: () {}),
                DSButton(label: 'White', variant: DSButtonVariant.white, onPressed: () {}),
                DSButton(label: 'Ghost', variant: DSButtonVariant.ghost, onPressed: () {}),
                DSButton(label: 'Link Sec', variant: DSButtonVariant.linkSecondary, onPressed: () {}),
                DSButton(label: 'Link', variant: DSButtonVariant.link, onPressed: () {}),
                DSButton(label: 'Danger', variant: DSButtonVariant.danger, onPressed: () {}),
              ]),
            ),
          ],
        ),
        ShowcaseSection(
          title: 'DSBUTTON · SIZES',
          description: 'SM · MD · LG',
          children: [
            ShowcaseCard(
              code: "DSButton(label: 'Large', size: DSButtonSize.lg, onPressed: () {})",
              child: Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
                DSButton(label: 'Small', size: DSButtonSize.sm, onPressed: () {}),
                DSButton(label: 'Medium', size: DSButtonSize.md, onPressed: () {}),
                DSButton(label: 'Large', size: DSButtonSize.lg, onPressed: () {}),
              ]),
            ),
          ],
        ),
        ShowcaseSection(
          title: 'DSBUTTON · ADD-ONS',
          description: 'Icons · shortcut · loading · disabled · full-width',
          children: [
            ShowcaseCard(
              label: 'Icons & shortcut',
              code: "DSButton(label: 'Save', leadingIcon: Icon(Icons.save_rounded), shortcut: '⌘S', onPressed: () {})",
              child: Wrap(spacing: 8, runSpacing: 8, children: [
                DSButton(label: 'Leading', leadingIcon: const Icon(Icons.add_rounded), onPressed: () {}),
                DSButton(label: 'Trailing', trailingIcon: const Icon(Icons.chevron_right_rounded), onPressed: () {}),
                DSButton(label: 'Both', leadingIcon: const Icon(Icons.save_rounded), trailingIcon: const Icon(Icons.chevron_right_rounded), onPressed: () {}),
                DSButton(label: 'Shortcut', shortcut: '⌘S', onPressed: () {}),
              ]),
            ),
            ShowcaseCard(
              label: 'States',
              code: "DSButton(label: 'Loading…', isLoading: true, onPressed: null)",
              child: Wrap(spacing: 8, runSpacing: 8, children: [
                DSButton(
                  label: _loading ? 'Saving…' : 'Tap to load',
                  isLoading: _loading,
                  onPressed: () async {
                    setState(() => _loading = true);
                    await Future<void>.delayed(const Duration(seconds: 2));
                    if (mounted) setState(() => _loading = false);
                  },
                ),
                DSButton(label: 'Disabled', onPressed: null),
                DSButton(label: 'Danger Disabled', variant: DSButtonVariant.danger, onPressed: null),
              ]),
            ),
            ShowcaseCard(
              label: 'Full width',
              code: "DSButton(label: 'Continue', isFullWidth: true, onPressed: () {})",
              child: Column(children: [
                DSButton(label: 'Full Width', leadingIcon: const Icon(Icons.arrow_forward_rounded), isFullWidth: true, onPressed: () {}),
                const SizedBox(height: 8),
                DSButton(label: 'Full Width Outline', variant: DSButtonVariant.outline, isFullWidth: true, onPressed: () {}),
              ]),
            ),
          ],
        ),
        ShowcaseSection(
          title: 'DSICONBUTTON',
          description: 'Icon-only square button — all variants & 3 sizes',
          children: [
            ShowcaseCard(
              label: 'Variants (MD)',
              code: "DSIconButton(icon: Icon(Icons.add), variant: DSButtonVariant.brand, onPressed: () {})",
              child: Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
                DSIconButton(icon: const Icon(Icons.add), variant: DSButtonVariant.brand, onPressed: () {}),
                DSIconButton(icon: const Icon(Icons.add), variant: DSButtonVariant.black, onPressed: () {}),
                DSIconButton(icon: const Icon(Icons.add), variant: DSButtonVariant.outline, onPressed: () {}),
                DSIconButton(icon: const Icon(Icons.add), variant: DSButtonVariant.gray, onPressed: () {}),
                DSIconButton(icon: const Icon(Icons.add), variant: DSButtonVariant.ghost, onPressed: () {}),
                DSIconButton(icon: const Icon(Icons.delete_outline_rounded), variant: DSButtonVariant.danger, onPressed: () {}),
                DSIconButton(icon: const Icon(Icons.add), onPressed: null),
              ]),
            ),
            ShowcaseCard(
              label: 'Sizes — SM / MD / LG',
              code: "DSIconButton(icon: Icon(Icons.arrow_forward_ios_rounded), size: DSButtonSize.lg, onPressed: () {})",
              child: Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
                DSIconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), size: DSButtonSize.sm, variant: DSButtonVariant.outline, onPressed: () {}),
                DSIconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), size: DSButtonSize.md, variant: DSButtonVariant.outline, onPressed: () {}),
                DSIconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), size: DSButtonSize.lg, variant: DSButtonVariant.outline, onPressed: () {}),
                DSIconButton(icon: const Icon(Icons.arrow_forward_ios_rounded), size: DSButtonSize.sm, onPressed: () {}),
                DSIconButton(icon: const Icon(Icons.arrow_forward_ios_rounded), size: DSButtonSize.md, onPressed: () {}),
                DSIconButton(icon: const Icon(Icons.arrow_forward_ios_rounded), size: DSButtonSize.lg, onPressed: () {}),
              ]),
            ),
          ],
        ),
        ShowcaseSection(
          title: 'DSSEGMENTEDCONTROL',
          description: 'One-active pill tab selector — SM / MD / LG',
          children: [
            ShowcaseCard(
              code: "DSSegmentedControl<String>(\n  items: [DSSegmentedItem(value: 'all', label: 'All'), …],\n  selected: _tab,\n  onChanged: (v) => setState(() => _tab = v),\n)",
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                DSSegmentedControl<String>(
                  size: DSSegmentedSize.sm,
                  items: const [
                    DSSegmentedItem(value: 'all', label: 'All'),
                    DSSegmentedItem(value: 'active', label: 'Active'),
                    DSSegmentedItem(value: 'done', label: 'Done'),
                  ],
                  selected: _segSelected,
                  onChanged: (v) => setState(() => _segSelected = v),
                ),
                const SizedBox(height: 10),
                DSSegmentedControl<String>(
                  items: const [
                    DSSegmentedItem(value: 'all', label: 'All'),
                    DSSegmentedItem(value: 'active', label: 'Active'),
                    DSSegmentedItem(value: 'done', label: 'Done'),
                  ],
                  selected: _segSelected,
                  onChanged: (v) => setState(() => _segSelected = v),
                ),
                const SizedBox(height: 10),
                DSSegmentedControl<String>(
                  size: DSSegmentedSize.lg,
                  items: const [
                    DSSegmentedItem(value: 'all', label: 'All'),
                    DSSegmentedItem(value: 'active', label: 'Active'),
                    DSSegmentedItem(value: 'done', label: 'Done'),
                  ],
                  selected: _segSelected,
                  onChanged: (v) => setState(() => _segSelected = v),
                ),
              ]),
            ),
          ],
        ),
        ShowcaseSection(
          title: 'DSBUTTONGROUP',
          description: 'Joined button strip with optional trailing + action',
          children: [
            ShowcaseCard(
              code: "DSButtonGroup(\n  items: [\n    DSButtonGroupItem(label: 'Create'),\n    DSButtonGroupItem(label: 'Add'),\n  ],\n  selectedIndex: 0,\n  trailingAction: () {},\n)",
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                DSButtonGroup(
                  selectedIndex: _groupSelected,
                  items: [
                    DSButtonGroupItem(label: 'Create', onPressed: () => setState(() => _groupSelected = 0)),
                  ],
                  trailingAction: () {},
                ),
                const SizedBox(height: 10),
                DSButtonGroup(
                  selectedIndex: _groupSelected,
                  items: [
                    DSButtonGroupItem(label: 'Create', onPressed: () => setState(() => _groupSelected = 0)),
                    DSButtonGroupItem(label: 'Add', onPressed: () => setState(() => _groupSelected = 1)),
                  ],
                  trailingAction: () {},
                ),
                const SizedBox(height: 10),
                DSButtonGroup(
                  selectedIndex: _groupSelected,
                  items: [
                    DSButtonGroupItem(label: 'Create', onPressed: () => setState(() => _groupSelected = 0)),
                    DSButtonGroupItem(label: 'Add', onPressed: () => setState(() => _groupSelected = 1)),
                    DSButtonGroupItem(label: 'Label', onPressed: () => setState(() => _groupSelected = 2)),
                  ],
                  trailingAction: () {},
                ),
              ]),
            ),
          ],
        ),
      ],
    );
  }
}
