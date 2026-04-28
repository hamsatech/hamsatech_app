import 'package:flutter/material.dart';
import '../../tokens/ds_spacing.dart';
import 'ds_checkbox.dart';

/// A recursive tree of checkboxes where a parent is indeterminate when
/// only some of its children are selected, and fully checked when all are.
class DSCheckboxTree extends StatelessWidget {
  const DSCheckboxTree({
    super.key,
    required this.nodes,
    required this.values,
    required this.onChanged,
    this.size = DSCheckboxSize.md,
    this.indent = 20,
  });

  final List<DSCheckboxNode> nodes;
  final Set<String> values;
  final ValueChanged<Set<String>> onChanged;
  final DSCheckboxSize size;
  final double indent;

  @override
  Widget build(BuildContext context) {
    return _TreeLevel(
      nodes: nodes,
      values: values,
      onChanged: onChanged,
      size: size,
      indent: indent,
      depth: 0,
    );
  }
}

class _TreeLevel extends StatelessWidget {
  const _TreeLevel({
    required this.nodes,
    required this.values,
    required this.onChanged,
    required this.size,
    required this.indent,
    required this.depth,
  });

  final List<DSCheckboxNode> nodes;
  final Set<String> values;
  final ValueChanged<Set<String>> onChanged;
  final DSCheckboxSize size;
  final double indent;
  final int depth;

  Set<String> _allLeafIds(DSCheckboxNode node) {
    if (node.children.isEmpty) return {node.id};
    return node.children.expand(_allLeafIds).toSet();
  }

  bool? _nodeValue(DSCheckboxNode node) {
    if (node.children.isEmpty) return values.contains(node.id);
    final leafIds = _allLeafIds(node);
    final checkedCount = leafIds.where(values.contains).length;
    if (checkedCount == 0) return false;
    if (checkedCount == leafIds.length) return true;
    return null; // indeterminate
  }

  void _toggle(DSCheckboxNode node) {
    final next = Set<String>.from(values);
    final leafIds = _allLeafIds(node);
    final allChecked = leafIds.every(next.contains);
    if (allChecked) {
      next.removeAll(leafIds);
    } else {
      next.addAll(leafIds);
    }
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: nodes.map((node) {
        final nodeVal = _nodeValue(node);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(left: depth * indent, bottom: DSSpacing.sm),
              child: DSCheckbox(
                value: nodeVal,
                onChanged: node.isDisabled ? null : (_) => _toggle(node),
                size: size,
                label: node.label,
                description: node.description,
                badge: node.badge,
                isDisabled: node.isDisabled,
              ),
            ),
            if (node.children.isNotEmpty)
              _TreeLevel(
                nodes: node.children,
                values: values,
                onChanged: onChanged,
                size: size,
                indent: indent,
                depth: depth + 1,
              ),
          ],
        );
      }).toList(),
    );
  }
}

class DSCheckboxNode {
  const DSCheckboxNode({
    required this.id,
    required this.label,
    this.description,
    this.badge,
    this.isDisabled = false,
    this.children = const [],
  });

  final String id;
  final String label;
  final String? description;
  final String? badge;
  final bool isDisabled;
  final List<DSCheckboxNode> children;
}
