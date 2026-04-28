import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';
import 'screens/button_showcase_screen.dart';
import 'screens/checkbox_screen.dart';
import 'screens/colors_screen.dart';
import 'screens/inputs_screen.dart';
import 'screens/list_select_screen.dart';
import 'screens/misc_screen.dart';
import 'screens/otp_showcase_screen.dart';
import 'screens/typography_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key, required this.onToggleTheme, required this.themeMode});
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _selectedIndex = 0;

  static const _items = [
    _NavItem(icon: Icons.palette_outlined, label: 'Colors', group: 'FOUNDATION'),
    _NavItem(icon: Icons.text_fields_rounded, label: 'Typography'),
    _NavItem(icon: Icons.smart_button_outlined, label: 'Buttons', group: 'COMPONENTS'),
    _NavItem(icon: Icons.input_rounded, label: 'Inputs'),
    _NavItem(icon: Icons.dialpad_rounded, label: 'OTP Input'),
    _NavItem(icon: Icons.check_box_outlined, label: 'Checkbox'),
    _NavItem(icon: Icons.list_alt_rounded, label: 'List / Select'),
    _NavItem(icon: Icons.widgets_outlined, label: 'Misc'),
  ];

  static const _colors = [
    DSColors.brand, Color(0xFF8B5CF6),
    DSColors.brand, DSColors.info, DSColors.success, DSColors.info, DSColors.warning, DSColors.error,
  ];

  // IndexedStack preserves stateful widget state across tab switches
  static final _screens = [
    const ColorsScreen(),
    const TypographyScreen(),
    const ButtonShowcaseScreen(),
    const InputsScreen(),
    const OtpShowcaseScreen(),
    const CheckboxScreen(),
    const ListSelectScreen(),
    const MiscScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            _Sidebar(
              items: _items,
              colors: _colors,
              selectedIndex: _selectedIndex,
              isDark: isDark,
              themeMode: widget.themeMode,
              onToggleTheme: widget.onToggleTheme,
              onSelect: (i) => setState(() => _selectedIndex = i),
            ),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: isDark ? DSColors.appBorder : DSColors.gray200,
            ),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: _screens,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sidebar
// ---------------------------------------------------------------------------

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.items,
    required this.colors,
    required this.selectedIndex,
    required this.isDark,
    required this.themeMode,
    required this.onToggleTheme,
    required this.onSelect,
  });

  final List<_NavItem> items;
  final List<Color> colors;
  final int selectedIndex;
  final bool isDark;
  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? DSColors.appSurface : const Color(0xFFF9FAFB);
    final activeBg = isDark ? DSColors.appCard : DSColors.white;
    final textActive = isDark ? DSColors.textPrimary : DSColors.gray900;
    final textIdle = isDark ? DSColors.textSecondary : DSColors.gray500;
    final groupColor = isDark ? DSColors.textMuted : DSColors.gray400;

    return Container(
      width: 192,
      color: bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Logo header ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 16, 8, 16),
            child: Row(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [DSColors.brand, DSColors.brandPressed], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.design_services_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('HamsaTech', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: textActive, height: 1.2)),
                      Text('Design System', style: TextStyle(fontSize: 10, color: textIdle, height: 1.2)),
                    ],
                  ),
                ),
                // Theme toggle
                GestureDetector(
                  onTap: onToggleTheme,
                  child: Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: isDark ? DSColors.appCard : DSColors.white,
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: isDark ? DSColors.appBorder : DSColors.gray200),
                    ),
                    child: Icon(
                      themeMode == ThemeMode.dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                      size: 14,
                      color: isDark ? DSColors.textSecondary : DSColors.gray500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: isDark ? DSColors.appBorder : DSColors.gray200),
          // ── Nav items ────────────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final item = items[i];
                final isActive = i == selectedIndex;
                final color = colors[i];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section group header
                    if (item.group != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 10, 8, 4),
                        child: Text(
                          item.group!,
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: groupColor),
                        ),
                      ),
                    // Nav row
                    GestureDetector(
                      onTap: () => onSelect(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.only(bottom: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                        decoration: BoxDecoration(
                          color: isActive ? activeBg : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: isActive
                              ? Border.all(color: isDark ? DSColors.appBorder : DSColors.gray200)
                              : Border.all(color: Colors.transparent),
                        ),
                        child: Row(
                          children: [
                            // Icon dot / icon
                            Container(
                              width: 26, height: 26,
                              decoration: BoxDecoration(
                                color: isActive ? color.withValues(alpha: 0.12) : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(item.icon, size: 15, color: isActive ? color : textIdle),
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                item.label,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                                  color: isActive ? textActive : textIdle,
                                ),
                              ),
                            ),
                            if (isActive)
                              Container(
                                width: 4, height: 4,
                                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          // ── Footer version tag ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
            child: Text('v1.0.0 · ${isDark ? "Dark" : "Light"}', style: TextStyle(fontSize: 10, color: groupColor, fontFamily: 'monospace')),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.icon, required this.label, this.group});
  final IconData icon;
  final String label;
  final String? group;
}
