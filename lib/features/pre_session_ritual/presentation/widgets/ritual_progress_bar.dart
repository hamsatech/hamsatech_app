import 'package:flutter/material.dart';

class RitualProgressBar extends StatelessWidget {
  const RitualProgressBar({
    required this.totalSteps,
    required this.currentStep,
    super.key,
  });

  final int totalSteps;
  final int currentStep; // 0-indexed

  static const _active = Color(0xFF2F7E8F);
  static const _inactive = Color(0xFFCAE8EE);
  static const _height = 3.0;
  static const _gap = 6.0;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (i) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(left: i == 0 ? 0 : _gap),
            height: _height,
            decoration: BoxDecoration(
              color: i <= currentStep ? _active : _inactive,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
