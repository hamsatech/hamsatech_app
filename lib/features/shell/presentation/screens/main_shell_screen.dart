import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';
import 'package:go_router/go_router.dart';

class MainShellScreen extends StatelessWidget {
  const MainShellScreen({super.key, required this.shell});

  final StatefulNavigationShell shell;

  static const _tabs = [
    _TabItem(icon: Icons.home_rounded, label: 'Home', path: '/home'),
    _TabItem(
        icon: Icons.gps_fixed_rounded, label: 'Sessions', path: '/sessions'),
    _TabItem(icon: Icons.insights_rounded, label: 'Insight', path: '/insight'),
    _TabItem(icon: Icons.person_rounded, label: 'Profile', path: '/profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Allow the system back gesture/button to bubble up only when already
      // on the home tab — at that point there is nothing to go back to and
      // the platform handles it (minimises the app).
      canPop: shell.currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          // Back pressed on a non-home tab → return to home tab.
          shell.goBranch(0);
        }
      },
      child: Scaffold(
        body: shell,
        bottomNavigationBar: _BottomNav(shell: shell, tabs: _tabs),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.shell, required this.tabs});

  final StatefulNavigationShell shell;
  final List<_TabItem> tabs;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DSColors.appSurface,
        border: Border(
          top: BorderSide(color: DSColors.appBorder.withValues(alpha: 0.6)),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 68,
          child: Row(
            children: tabs.asMap().entries.map((entry) {
              final i = entry.key;
              final tab = entry.value;
              final isActive = shell.currentIndex == i;
              return Expanded(
                child: InkWell(
                  onTap: () => shell.goBranch(i,
                      initialLocation: i == shell.currentIndex),
                  splashColor: DSColors.brandMuted,
                  highlightColor: Colors.transparent,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: isActive
                                ? DSColors.brandMuted
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            tab.icon,
                            size: 22,
                            color:
                                isActive ? DSColors.brand : DSColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tab.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight:
                                isActive ? FontWeight.w600 : FontWeight.w400,
                            color:
                                isActive ? DSColors.brand : DSColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  const _TabItem({
    required this.icon,
    required this.label,
    required this.path,
  });

  final IconData icon;
  final String label;
  final String path;
}
