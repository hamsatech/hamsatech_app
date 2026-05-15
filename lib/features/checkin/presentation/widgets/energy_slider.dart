import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

class EnergySlider extends StatelessWidget {
  const EnergySlider({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final int value;
  final ValueChanged<int> onChanged;

  static const _teal = Color(0xFF2F7E8F);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: _teal,
            inactiveTrackColor: DSColors.appBorder,
            thumbColor: Colors.white,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            overlayColor: _teal.withValues(alpha: 0.15),
            trackHeight: 4,
          ),
          child: Slider(
            value: value.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Low',
                style:
                    DSTypography.bodyMd.copyWith(color: DSColors.textSecondary),
              ),
              Text(
                '$value',
                style: DSTypography.headingXl.copyWith(color: _teal),
              ),
              Text(
                'High',
                style:
                    DSTypography.bodyMd.copyWith(color: DSColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
