import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

class PlannedShotsSelector extends StatelessWidget {
  const PlannedShotsSelector({
    required this.value,
    required this.quickSelectValues,
    required this.onChanged,
    this.min = 1,
    this.max = 300,
    super.key,
  });

  final int value;
  final List<int> quickSelectValues;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Counter row ──────────────────────────────────────────────────────
        Container(
          height: 58,
          decoration: BoxDecoration(
            color: DSColors.appCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: DSColors.appBorder),
          ),
          child: Row(
            children: [
              _CounterButton(
                icon: Icons.remove_rounded,
                onTap: value > min ? () => onChanged(value - 1) : null,
              ),
              Expanded(
                child: Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: DSTypography.headingXl.copyWith(
                    color: DSColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 32,
                  ),
                ),
              ),
              _CounterButton(
                icon: Icons.add_rounded,
                onTap: value < max ? () => onChanged(value + 1) : null,
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // ── Quick-select chips ───────────────────────────────────────────────
        Row(
          children: quickSelectValues.asMap().entries.map((entry) {
            final i = entry.key;
            final shots = entry.value;
            final isActive = shots == value;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: i == 0 ? 0 : 6),
                child: _QuickChip(
                  label: '$shots',
                  isActive: isActive,
                  onTap: () => onChanged(shots),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _CounterButton extends StatelessWidget {
  const _CounterButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 56,
        height: double.infinity,
        child: Icon(
          icon,
          size: 22,
          color: onTap != null ? DSColors.textPrimary : DSColors.textMuted,
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  static const _teal = Color(0xFF2F7E8F);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? _teal : DSColors.appCard,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isActive ? _teal : DSColors.appBorder,
          ),
        ),
        child: Text(
          label,
          style: DSTypography.labelSm.copyWith(
            color: isActive ? Colors.white : DSColors.textSecondary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
