import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';
import 'package:go_router/go_router.dart';


class MainShellScreen extends StatelessWidget {
  const MainShellScreen({super.key, required this.shell});

  final StatefulNavigationShell shell;

  static const _tabs = [
    _TabItem(icon: Icons.dashboard_rounded, label: 'Home', path: '/home'),
    _TabItem(icon: Icons.timer_rounded, label: 'Sessions', path: '/sessions'),
    _TabItem(icon: Icons.auto_stories_rounded, label: 'Journal', path: '/journal'),
    _TabItem(icon: Icons.person_rounded, label: 'Profile', path: '/profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: DSColors.appSurface,
          border: Border(top: BorderSide(color: DSColors.appDivider)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Row(
              children: _tabs.asMap().entries.map((entry) {
                final i = entry.key;
                final tab = entry.value;
                final isActive = shell.currentIndex == i;
                return Expanded(
                  child: InkWell(
                    onTap: () => shell.goBranch(
                      i,
                      initialLocation: i == shell.currentIndex,
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: isActive ? 36 : 0,
                            height: 3,
                            decoration: BoxDecoration(
                              color: DSColors.brand,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Icon(
                            tab.icon,
                            size: 22,
                            color: isActive
                                ? DSColors.brand
                                : DSColors.textMuted,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            tab.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isActive
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isActive
                                  ? DSColors.brand
                                  : DSColors.textMuted,
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
