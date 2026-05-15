import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

import '../../../../core/services/storage_service.dart';

class BasicProfileScreen extends StatefulWidget {
  const BasicProfileScreen({super.key});

  @override
  State<BasicProfileScreen> createState() => _BasicProfileScreenState();
}

class _BasicProfileScreenState extends State<BasicProfileScreen> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _selectedDiscipline;
  bool _saving = false;

  static const _disciplines = [
    ('Pistol', Icons.ads_click_rounded),
    ('Rifle', Icons.track_changes_rounded),
    ('Shotgun', Icons.blur_circular_rounded),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDiscipline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select your discipline'),
          backgroundColor: DSColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    HapticFeedback.lightImpact();
    setState(() => _saving = true);
    await StorageService.saveUserProfile({
      'name': _nameController.text.trim(),
      'discipline': _selectedDiscipline,
    });
    await StorageService.setProfileSetupComplete(true);
    if (mounted) context.go('/questions');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColors.appBackground,
      body: Stack(
        children: [
          _BackgroundGlow(),
          SafeArea(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 40),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 48),
                      _StepBadge(),
                      const SizedBox(height: 24),
                      Text(
                        'Tell us about\nyourself',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: DSColors.textPrimary,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This helps us personalise your experience',
                        style: TextStyle(
                          fontSize: 14,
                          color: DSColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 40),
                      _SectionLabel(label: 'FULL NAME'),
                      const SizedBox(height: 10),
                      _NameField(controller: _nameController),
                      const SizedBox(height: 32),
                      _SectionLabel(label: 'SHOOTING DISCIPLINE'),
                      const SizedBox(height: 12),
                      ..._disciplines.map((d) => _DisciplineCard(
                            label: d.$1,
                            icon: d.$2,
                            selected: _selectedDiscipline == d.$1,
                            onTap: () =>
                                setState(() => _selectedDiscipline = d.$1),
                          )),
                      const SizedBox(height: 40),
                      _LetsGoButton(
                        onPressed: _save,
                        isLoading: _saving,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundGlow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -140,
      left: -100,
      child: Container(
        width: 380,
        height: 380,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              DSColors.brand.withValues(alpha: 0.10),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

class _StepBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: DSColors.brandMuted,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: DSColors.brand.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_outline_rounded, size: 14, color: DSColors.brand),
          const SizedBox(width: 6),
          Text(
            'BASIC PROFILE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: DSColors.brand,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: DSColors.textMuted,
        letterSpacing: 2,
      ),
    );
  }
}

class _NameField extends StatelessWidget {
  const _NameField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DSColors.appCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DSColors.appBorder),
      ),
      child: TextFormField(
        controller: controller,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.done,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: DSColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Your full name',
          hintStyle: TextStyle(
            fontSize: 18,
            color: DSColors.textMuted,
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        validator: (v) {
          if (v == null || v.trim().isEmpty) {
            return 'Please enter your name';
          }
          return null;
        },
      ),
    );
  }
}

class _DisciplineCard extends StatelessWidget {
  const _DisciplineCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? DSColors.brandMuted : DSColors.appCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? DSColors.brand : DSColors.appBorder,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected
                    ? DSColors.brand.withValues(alpha: 0.2)
                    : DSColors.appCardElevated,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 20,
                color: selected ? DSColors.brand : DSColors.textMuted,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? DSColors.textPrimary : DSColors.textSecondary,
              ),
            ),
            const Spacer(),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? DSColors.brand : Colors.transparent,
                border: Border.all(
                  color: selected ? DSColors.brand : DSColors.appBorder,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check_rounded,
                      size: 13, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _LetsGoButton extends StatelessWidget {
  const _LetsGoButton({required this.onPressed, required this.isLoading});
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: DSColors.brand,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Let\'s go',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
      ),
    );
  }
}
