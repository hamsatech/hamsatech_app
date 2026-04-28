import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';
import '../widgets/showcase_helpers.dart';

class CheckboxScreen extends StatefulWidget {
  const CheckboxScreen({super.key});
  @override
  State<CheckboxScreen> createState() => _CheckboxScreenState();
}

class _CheckboxScreenState extends State<CheckboxScreen> {
  bool _checked = true;
  bool _unchecked = false;

  Set<String> _flat = {'updates', 'invitations'};
  Set<String> _card = {'updates'};
  Set<String> _tree = {'general', 'auto-save', 'dark-mode', 'allow-collaborators', 'add-comments', 'edit-access', 'comment-access'};

  final _flatItems = const [
    DSCheckboxGroupItem(id: 'updates', label: 'Receive Updates'),
    DSCheckboxGroupItem(id: 'offers', label: 'Promotional Offers'),
    DSCheckboxGroupItem(id: 'beta', label: 'Beta Access'),
    DSCheckboxGroupItem(id: 'invitations', label: 'Event Invitations'),
    DSCheckboxGroupItem(id: 'feedback', label: 'Feedback Requests'),
  ];

  final _cardItems = const [
    DSCheckboxGroupItem(id: 'updates', label: 'Receive Updates', description: 'Get product news and updates.', badge: 'New'),
    DSCheckboxGroupItem(id: 'offers', label: 'Promotional Offers', description: 'Receive exclusive discounts and offers.'),
    DSCheckboxGroupItem(id: 'beta', label: 'Beta Access', description: 'Try new features early.'),
    DSCheckboxGroupItem(id: 'invitations', label: 'Event Invitations', description: 'Join upcoming webinars and events.', badge: 'New'),
    DSCheckboxGroupItem(id: 'feedback', label: 'Feedback Requests', description: 'Help improve by sharing feedback.', isDisabled: true),
  ];

  final _treeNodes = const [
    DSCheckboxNode(
      id: 'project-settings',
      label: 'Project Settings',
      children: [
        DSCheckboxNode(
          id: 'general',
          label: 'General Settings',
          children: [
            DSCheckboxNode(id: 'enable-notifications', label: 'Enable Notifications', isDisabled: true),
            DSCheckboxNode(id: 'auto-save', label: 'Auto-Save Changes'),
            DSCheckboxNode(id: 'dark-mode', label: 'Dark Mode'),
          ],
        ),
        DSCheckboxNode(
          id: 'collaboration',
          label: 'Collaboration',
          children: [
            DSCheckboxNode(id: 'allow-collaborators', label: 'Allow Collaborators'),
            DSCheckboxNode(id: 'restrict-editing', label: 'Restrict Editing'),
            DSCheckboxNode(id: 'add-comments', label: 'Add Comments'),
          ],
        ),
      ],
    ),
    DSCheckboxNode(
      id: 'user-permissions',
      label: 'User Permissions',
      children: [
        DSCheckboxNode(
          id: 'access-levels',
          label: 'Access Levels',
          children: [
            DSCheckboxNode(id: 'view-only', label: 'View-Only Access'),
            DSCheckboxNode(id: 'edit-access', label: 'Edit Access'),
            DSCheckboxNode(id: 'comment-access', label: 'Comment Access'),
            DSCheckboxNode(id: 'admin-access', label: 'Admin Access'),
          ],
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ShowcaseScaffold(
      title: 'Checkbox',
      sections: [
        // ── DSCheckbox States ───────────────────────────────────────────────
        ShowcaseSection(
          title: 'DSCHECKBOX · STATES',
          description: 'checked · unchecked · indeterminate · disabled',
          children: [
            ShowcaseCard(
              code: "DSCheckbox(value: true, onChanged: (v) => setState(() => _v = v))",
              child: Column(children: [
                Row(children: [
                  DSCheckbox(value: true, size: DSCheckboxSize.sm, onChanged: (_) {}),
                  const SizedBox(width: 12),
                  DSCheckbox(value: true, size: DSCheckboxSize.md, onChanged: (_) {}),
                  const SizedBox(width: 12),
                  DSCheckbox(value: true, size: DSCheckboxSize.lg, onChanged: (_) {}),
                  const SizedBox(width: 20),
                  const Text('Checked (SM · MD · LG)', style: TextStyle(fontSize: 12)),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  DSCheckbox(value: null, size: DSCheckboxSize.sm, onChanged: (_) {}),
                  const SizedBox(width: 12),
                  DSCheckbox(value: null, size: DSCheckboxSize.md, onChanged: (_) {}),
                  const SizedBox(width: 12),
                  DSCheckbox(value: null, size: DSCheckboxSize.lg, onChanged: (_) {}),
                  const SizedBox(width: 20),
                  const Text('Indeterminate', style: TextStyle(fontSize: 12)),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  DSCheckbox(value: false, size: DSCheckboxSize.sm, onChanged: (_) {}),
                  const SizedBox(width: 12),
                  DSCheckbox(value: false, size: DSCheckboxSize.md, onChanged: (_) {}),
                  const SizedBox(width: 12),
                  DSCheckbox(value: false, size: DSCheckboxSize.lg, onChanged: (_) {}),
                  const SizedBox(width: 20),
                  const Text('Unchecked', style: TextStyle(fontSize: 12)),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  DSCheckbox(value: false, size: DSCheckboxSize.sm, isDisabled: true, onChanged: (_) {}),
                  const SizedBox(width: 12),
                  DSCheckbox(value: false, size: DSCheckboxSize.md, isDisabled: true, onChanged: (_) {}),
                  const SizedBox(width: 12),
                  DSCheckbox(value: false, size: DSCheckboxSize.lg, isDisabled: true, onChanged: (_) {}),
                  const SizedBox(width: 20),
                  const Text('Disabled', style: TextStyle(fontSize: 12)),
                ]),
              ]),
            ),
          ],
        ),
        // ── With label ──────────────────────────────────────────────────────
        ShowcaseSection(
          title: 'DSCHECKBOX · LABEL + DESCRIPTION + BADGE',
          children: [
            ShowcaseCard(
              code: "DSCheckbox(\n  value: _v,\n  label: 'Receive Updates',\n  description: 'Get product news and updates.',\n  badge: 'New',\n  onChanged: (v) => setState(() => _v = v),\n)",
              child: Column(children: [
                DSCheckbox(value: _checked, label: 'Receive Updates', description: 'Get product news and updates.', badge: 'New', onChanged: (v) => setState(() => _checked = v)),
                const SizedBox(height: 12),
                DSCheckbox(value: null, label: 'Indeterminate', description: 'Some children selected.', onChanged: (_) {}),
                const SizedBox(height: 12),
                DSCheckbox(value: _unchecked, label: 'Unchecked item', description: 'Tap to select this option.', onChanged: (v) => setState(() => _unchecked = v)),
                const SizedBox(height: 12),
                DSCheckbox(value: true, label: 'Disabled checked', description: 'Cannot be changed.', isDisabled: true, onChanged: (_) {}),
                const SizedBox(height: 12),
                DSCheckbox(value: false, label: 'Disabled unchecked', description: 'Cannot be changed.', isDisabled: true, onChanged: (_) {}),
              ]),
            ),
          ],
        ),
        // ── DSCheckboxGroup flat ─────────────────────────────────────────────
        ShowcaseSection(
          title: 'DSCHECKBOXGROUP · VERTICAL',
          children: [
            ShowcaseCard(
              code: "DSCheckboxGroup(\n  items: items,\n  values: _values,\n  onChanged: (v) => setState(() => _values = v),\n)",
              child: DSCheckboxGroup(
                items: _flatItems,
                values: _flat,
                onChanged: (v) => setState(() => _flat = v),
              ),
            ),
          ],
        ),
        ShowcaseSection(
          title: 'DSCHECKBOXGROUP · HORIZONTAL',
          children: [
            ShowcaseCard(
              code: "DSCheckboxGroup(\n  items: items,\n  values: _values,\n  direction: Axis.horizontal,\n  onChanged: (v) => setState(() => _values = v),\n)",
              child: DSCheckboxGroup(
                items: _flatItems.take(3).toList(),
                values: _flat,
                direction: Axis.horizontal,
                onChanged: (v) => setState(() => _flat = v),
              ),
            ),
          ],
        ),
        // ── DSCheckboxCardGroup ──────────────────────────────────────────────
        ShowcaseSection(
          title: 'DSCHECKBOXCARDGROUP',
          description: 'Each option in a bordered card with animated brand highlight',
          children: [
            ShowcaseCard(
              code: "DSCheckboxCardGroup(\n  items: items,\n  values: _values,\n  onChanged: (v) => setState(() => _values = v),\n)",
              child: DSCheckboxCardGroup(
                items: _cardItems,
                values: _card,
                onChanged: (v) => setState(() => _card = v),
              ),
            ),
          ],
        ),
        // ── DSCheckboxTree ───────────────────────────────────────────────────
        ShowcaseSection(
          title: 'DSCHECKBOXTREE',
          description: 'Nested tree — parent auto-resolves indeterminate state',
          children: [
            ShowcaseCard(
              code: "DSCheckboxTree(\n  nodes: nodes,\n  values: _values,\n  onChanged: (v) => setState(() => _values = v),\n)",
              child: DSCheckboxTree(
                nodes: _treeNodes,
                values: _tree,
                onChanged: (v) => setState(() => _tree = v),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
