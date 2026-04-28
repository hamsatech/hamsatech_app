import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';
import '../widgets/showcase_helpers.dart';

class ListSelectScreen extends StatefulWidget {
  const ListSelectScreen({super.key});
  @override
  State<ListSelectScreen> createState() => _ListSelectScreenState();
}

class _ListSelectScreenState extends State<ListSelectScreen> {
  String? _singleCheck;
  final Map<String, bool> _toggles = {
    'ai': true, 'agency': false, 'architecture': false, 'booking': true,
    'cafe': false, 'cars': false, 'music': false, 'books': true,
  };
  final Set<String> _checkboxes = {'ai', 'booking'};

  final _statusToggles = {
    'completed': true,
    'inprogress': false,
    'pending': false,
    'delayed': true,
    'cancelled': false,
    'onhold': false,
  };

  static const _categoryItems = [
    ('ai', Icons.psychology_outlined, 'AI'),
    ('agency', Icons.business_outlined, 'Agency'),
    ('architecture', Icons.architecture_outlined, 'Architecture'),
    ('booking', Icons.book_outlined, 'Booking'),
    ('cafe', Icons.local_cafe_outlined, 'Café'),
    ('cars', Icons.directions_car_outlined, 'Cars'),
    ('music', Icons.music_note_outlined, 'Music'),
    ('books', Icons.menu_book_outlined, 'Books'),
  ];

  static const _people = [
    ('gf', 'Grace Foster', '@gracefoster', Color(0xFF6366F1)),
    ('ec', 'Ethan Cole', '@ethancole', Color(0xFF10B981)),
    ('ob', 'Owen Brooks', '@owenbrooks', Color(0xFFF59E0B)),
    ('le', 'Luke Evans', '@lukeevans', Color(0xFF3B82F6)),
    ('zc', 'Zoe Carter', '@zoecarter', Color(0xFFEF4444)),
    ('ej', 'Ella James', '@ellajames', Color(0xFF8B5CF6)),
  ];

  static final _statuses = [
    ('completed', 'Completed', DSColors.success),
    ('inprogress', 'In progress', DSColors.brand),
    ('pending', 'Pending', DSColors.warning),
    ('delayed', 'Delayed', DSColors.error),
    ('cancelled', 'Cancelled', DSColors.gray500),
    ('onhold', 'On hold', DSColors.info),
  ];

  @override
  Widget build(BuildContext context) {
    return ShowcaseBody(
            sections: [
        // ── Check trailing ──────────────────────────────────────────────────
        ShowcaseSection(
          title: 'SINGLE-SELECT · CHECKMARK',
          description: 'Checkmark appears on right when selected',
          children: [
            ShowcaseCard(
              code: "DSSelectItem(\n  label: 'AI',\n  leading: DSItemIcon(icon: Icons.psychology_outlined),\n  isSelected: _value == 'ai',\n  trailing: DSSelectItemTrailing.check,\n  onTap: () => setState(() => _value = 'ai'),\n)",
              padding: EdgeInsets.zero,
              child: DSSelectList(
                children: _categoryItems.map((c) => DSSelectItem(
                  label: c.$3,
                  leading: DSItemIcon(icon: c.$2),
                  isSelected: _singleCheck == c.$1,
                  trailing: DSSelectItemTrailing.check,
                  onTap: () => setState(() => _singleCheck = _singleCheck == c.$1 ? null : c.$1),
                )).toList(),
              ),
            ),
          ],
        ),
        // ── Toggle trailing ─────────────────────────────────────────────────
        ShowcaseSection(
          title: 'TOGGLE SWITCH',
          description: 'Orange = on, gray = off',
          children: [
            ShowcaseCard(
              code: "DSSelectItem(\n  label: 'Booking',\n  leading: DSItemIcon(icon: Icons.book_outlined),\n  isSelected: _toggles['booking']!,\n  trailing: DSSelectItemTrailing.toggle,\n  onToggle: (v) => setState(() => _toggles['booking'] = v),\n)",
              padding: EdgeInsets.zero,
              child: DSSelectList(
                children: _categoryItems.map((c) => DSSelectItem(
                  label: c.$3,
                  leading: DSItemIcon(icon: c.$2),
                  isSelected: _toggles[c.$1]!,
                  trailing: DSSelectItemTrailing.toggle,
                  onToggle: (v) => setState(() => _toggles[c.$1] = v),
                )).toList(),
              ),
            ),
          ],
        ),
        // ── Checkbox trailing ────────────────────────────────────────────────
        ShowcaseSection(
          title: 'MULTI-SELECT · CHECKBOX',
          description: 'Checkbox on left side of leading widget',
          children: [
            ShowcaseCard(
              code: "DSSelectItem(\n  label: 'AI',\n  leading: DSItemIcon(icon: Icons.psychology_outlined),\n  isSelected: _checked.contains('ai'),\n  trailing: DSSelectItemTrailing.checkbox,\n  onToggle: (v) => setState(() { if (v) _checked.add('ai'); else _checked.remove('ai'); }),\n)",
              padding: EdgeInsets.zero,
              child: DSSelectList(
                children: _categoryItems.map((c) => DSSelectItem(
                  label: c.$3,
                  leading: DSItemIcon(icon: c.$2),
                  isSelected: _checkboxes.contains(c.$1),
                  trailing: DSSelectItemTrailing.checkbox,
                  onToggle: (v) => setState(() {
                    if (v) { _checkboxes.add(c.$1); } else { _checkboxes.remove(c.$1); }
                  }),
                )).toList(),
              ),
            ),
          ],
        ),
        // ── User avatar rows ─────────────────────────────────────────────────
        ShowcaseSection(
          title: 'USER ROWS · AVATAR / INITIALS',
          description: 'DSItemInitials as leading with name + @handle',
          children: [
            ShowcaseCard(
              code: "DSSelectItem(\n  label: 'Grace Foster',\n  subtitle: '@gracefoster',\n  leading: DSItemInitials(initials: 'GF', color: Colors.indigo),\n  isSelected: _selected == 'gf',\n  trailing: DSSelectItemTrailing.check,\n  onTap: () {},\n)",
              padding: EdgeInsets.zero,
              child: DSSelectList(
                children: _people.map((p) => DSSelectItem(
                  label: p.$2,
                  subtitle: p.$3,
                  leading: DSItemInitials(initials: p.$1.toUpperCase(), color: p.$4),
                  isSelected: _singleCheck == p.$1,
                  trailing: DSSelectItemTrailing.check,
                  onTap: () => setState(() => _singleCheck = _singleCheck == p.$1 ? null : p.$1),
                )).toList(),
              ),
            ),
          ],
        ),
        // ── Status rows ──────────────────────────────────────────────────────
        ShowcaseSection(
          title: 'STATUS ROWS · COLOR DOT',
          description: 'DSItemColorDot as leading — toggle switches',
          children: [
            ShowcaseCard(
              code: "DSSelectItem(\n  label: 'Completed',\n  leading: DSItemColorDot(color: DSColors.success),\n  isSelected: _toggles['completed']!,\n  trailing: DSSelectItemTrailing.toggle,\n  onToggle: (v) => setState(() => _toggles['completed'] = v),\n)",
              padding: EdgeInsets.zero,
              child: DSSelectList(
                children: _statuses.map((s) => DSSelectItem(
                  label: s.$2,
                  leading: DSItemColorDot(color: s.$3, size: 10),
                  isSelected: _statusToggles[s.$1]!,
                  trailing: DSSelectItemTrailing.toggle,
                  onToggle: (v) => setState(() => _statusToggles[s.$1] = v),
                )).toList(),
              ),
            ),
          ],
        ),
        // ── Disabled ─────────────────────────────────────────────────────────
        ShowcaseSection(
          title: 'DISABLED STATE',
          children: [
            ShowcaseCard(
              code: "DSSelectItem(label: 'Disabled item', isDisabled: true, trailing: DSSelectItemTrailing.toggle)",
              padding: EdgeInsets.zero,
              child: DSSelectList(
                children: [
                  DSSelectItem(label: 'Active item', leading: const DSItemIcon(icon: Icons.check_circle_outline), isSelected: true, trailing: DSSelectItemTrailing.toggle, onToggle: (_) {}),
                  DSSelectItem(label: 'Disabled off', leading: const DSItemIcon(icon: Icons.block_outlined), isSelected: false, isDisabled: true, trailing: DSSelectItemTrailing.toggle),
                  DSSelectItem(label: 'Disabled on', leading: const DSItemIcon(icon: Icons.lock_outline_rounded), isSelected: true, isDisabled: true, trailing: DSSelectItemTrailing.toggle),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
