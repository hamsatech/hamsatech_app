import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';
import '../widgets/showcase_helpers.dart';

class OtpShowcaseScreen extends StatelessWidget {
  const OtpShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcaseBody(
      sections: [
        ShowcaseSection(
          title: '4-DIGIT',
          description: 'Default length for PIN / OTP',
          children: [
            ShowcaseCard(
              code: "DSOtpInput(\n  length: 4,\n  label: 'Verification code',\n  isRequired: true,\n  onCompleted: (otp) {},\n)",
              child: DSOtpInput(length: 4, label: 'Verification code', isRequired: true, showInfoIcon: true, helperText: 'Enter the 4-digit code sent to your phone', onCompleted: (_) {}),
            ),
          ],
        ),
        ShowcaseSection(
          title: '6-DIGIT',
          children: [
            ShowcaseCard(
              code: "DSOtpInput(length: 6, label: 'Auth code', isRequired: true)",
              child: DSOtpInput(length: 6, label: 'Auth code', isRequired: true, helperText: 'Agree Terms and Conditions', onCompleted: (_) {}),
            ),
          ],
        ),
        ShowcaseSection(
          title: '6-DIGIT WITH SEPARATOR',
          description: 'Dot separator after index 2 (0-based)',
          children: [
            ShowcaseCard(
              code: "DSOtpInput(length: 6, separatorAfter: 2, label: 'Newsletter code', isRequired: true)",
              child: DSOtpInput(length: 6, separatorAfter: 2, label: 'Newsletter code', isRequired: true, showInfoIcon: true, helperText: 'Agree Terms and Conditions', onCompleted: (_) {}),
            ),
          ],
        ),
        ShowcaseSection(
          title: 'ERROR STATE',
          children: [
            ShowcaseCard(
              code: "DSOtpInput(length: 4, errorText: 'Invalid code. Please try again.')",
              child: DSOtpInput(length: 4, label: 'Verification', isRequired: true, showInfoIcon: true, errorText: 'Invalid code. Please try again.', onCompleted: (_) {}),
            ),
          ],
        ),
        ShowcaseSection(
          title: 'DISABLED STATE',
          children: [
            ShowcaseCard(
              code: "DSOtpInput(length: 4, isDisabled: true)",
              child: DSOtpInput(length: 4, label: 'Disabled', isRequired: true, isDisabled: true, onCompleted: (_) {}),
            ),
          ],
        ),
        ShowcaseSection(
          title: 'CELL SIZE VARIANTS',
          description: 'Control cell size with the cellSize property',
          children: [
            ShowcaseCard(label: 'Small (36px)', code: "DSOtpInput(length: 4, cellSize: 36)", child: DSOtpInput(length: 4, cellSize: 36, onCompleted: (_) {})),
            ShowcaseCard(label: 'Default (52px)', code: "DSOtpInput(length: 4)", child: DSOtpInput(length: 4, onCompleted: (_) {})),
            ShowcaseCard(label: 'Large (64px)', code: "DSOtpInput(length: 4, cellSize: 64)", child: DSOtpInput(length: 4, cellSize: 64, onCompleted: (_) {})),
          ],
        ),
      ],
    );
  }
}
