import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ---------------------------------------------------------------------------
// Reusable showcase primitives shared across all screens
// ---------------------------------------------------------------------------

class ShowcaseSection extends StatelessWidget {
  const ShowcaseSection({super.key, required this.title, required this.children, this.description});
  final String title;
  final String? description;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), letterSpacing: 0.8)),
        if (description != null) ...[
          const SizedBox(height: 4),
          Text(description!, style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8))),
        ],
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}

class ShowcaseCard extends StatelessWidget {
  const ShowcaseCard({super.key, required this.child, this.label, this.code, this.padding});
  final Widget child;
  final String? label;
  final String? code;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1A2235) : Colors.white;
    final border = isDark ? const Color(0xFF2D3748) : const Color(0xFFE2E8F0);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: Text(label!, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8), letterSpacing: 0.3)),
            ),
          Padding(padding: padding ?? const EdgeInsets.all(16), child: child),
          if (code != null) _CodeBlock(code: code!),
        ],
      ),
    );
  }
}

class _CodeBlock extends StatelessWidget {
  const _CodeBlock({required this.code});
  final String code;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D1117) : const Color(0xFFF8FAFC),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
        border: Border(top: BorderSide(color: isDark ? const Color(0xFF2D3748) : const Color(0xFFE2E8F0))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(code, style: TextStyle(fontSize: 11, fontFamily: 'monospace', color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569), height: 1.6)),
          ),
          GestureDetector(
            onTap: () => Clipboard.setData(ClipboardData(text: code)),
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Icon(Icons.copy_rounded, size: 14, color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8)),
            ),
          ),
        ],
      ),
    );
  }
}

class ShowcaseRow extends StatelessWidget {
  const ShowcaseRow({super.key, required this.children, this.label, this.wrap = false});
  final List<Widget> children;
  final String? label;
  final bool wrap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(label!, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8))),
          ),
        wrap
            ? Wrap(spacing: 8, runSpacing: 8, children: children)
            : SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: children.expand((c) => [c, const SizedBox(width: 8)]).toList()..removeLast())),
      ],
    );
  }
}

class ShowcaseDivider extends StatelessWidget {
  const ShowcaseDivider({super.key});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Divider(color: isDark ? const Color(0xFF2D3748) : const Color(0xFFE2E8F0), height: 1),
    );
  }
}

class ShowcaseScaffold extends StatelessWidget {
  const ShowcaseScaffold({super.key, required this.title, required this.sections});
  final String title;
  final List<Widget> sections;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
        children: sections.expand((s) => [s, const ShowcaseDivider()]).toList()..removeLast(),
      ),
    );
  }
}
