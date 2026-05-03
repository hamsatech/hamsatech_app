import 'package:equatable/equatable.dart';

enum OnboardingCompletionStatus { initial, loading, success }

// ── Summary row data model ────────────────────────────────────────────────────
// isValueHighlighted → renders the value in an accent colour (e.g. "Not linked")
class SummaryItemModel extends Equatable {
  const SummaryItemModel({
    required this.label,
    required this.value,
    this.isValueHighlighted = false,
  });

  final String label;
  final String value;
  final bool isValueHighlighted;

  @override
  List<Object?> get props => [label, value, isValueHighlighted];
}

// ── State ─────────────────────────────────────────────────────────────────────

class OnboardingCompletionState extends Equatable {
  // ── Status + navigation signal ───────────────────────────────────────────
  final OnboardingCompletionStatus status;
  final bool navigateToHome;

  // ── Personalisation (populated from previous onboarding steps) ───────────
  final String userName;

  // ── Summary rows (swap defaults with real data once API is wired) ─────────
  final List<SummaryItemModel> summaryItems;

  // ── UI strings ────────────────────────────────────────────────────────────
  final String subtitleText;
  final String readyLabel;
  final String goHomeCta;

  const OnboardingCompletionState({
    this.status = OnboardingCompletionStatus.initial,
    this.navigateToHome = false,
    this.userName = 'Alex',
    this.summaryItems = const [
      SummaryItemModel(label: 'Discipline', value: 'Air Pistol'),
      SummaryItemModel(label: 'Goal', value: '560 in 30d'),
      SummaryItemModel(label: 'Resting HR', value: '68 bpm'),
      SummaryItemModel(
        label: 'Coach',
        value: 'Not linked',
        isValueHighlighted: true,
      ),
    ],
    this.subtitleText = "Here's your starting point:",
    this.readyLabel = 'Ready to train',
    this.goHomeCta = 'Go to Home',
  });

  // ── Derived ───────────────────────────────────────────────────────────────

  String get titleText => "You're all set, $userName";

  // ── Copy ──────────────────────────────────────────────────────────────────

  OnboardingCompletionState copyWith({
    OnboardingCompletionStatus? status,
    bool? navigateToHome,
    String? userName,
    List<SummaryItemModel>? summaryItems,
  }) {
    return OnboardingCompletionState(
      status: status ?? this.status,
      navigateToHome: navigateToHome ?? this.navigateToHome,
      userName: userName ?? this.userName,
      summaryItems: summaryItems ?? this.summaryItems,
      subtitleText: subtitleText,
      readyLabel: readyLabel,
      goHomeCta: goHomeCta,
    );
  }

  @override
  List<Object?> get props => [
        status,
        navigateToHome,
        userName,
        summaryItems,
        subtitleText,
        readyLabel,
        goHomeCta,
      ];
}
