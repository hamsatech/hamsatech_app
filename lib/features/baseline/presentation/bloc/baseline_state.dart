import 'package:equatable/equatable.dart';

enum BaselineStatus { instruction, capturing, success }

class BaselineState extends Equatable {
  // ── Phase status ─────────────────────────────────────────────────────────
  final BaselineStatus status;

  // ── Capturing / result data ──────────────────────────────────────────────
  final int bpm;
  final int remainingSeconds;
  final double progress; // 0.0 → 1.0

  // ── Navigation signal (listened to by BlocConsumer in the view) ──────────
  final bool navigateToNext;

  // ── Phase 1 UI strings ───────────────────────────────────────────────────
  final String headerTitle;
  final String headerSubtitle;
  final String card1Title;
  final String card2Title;
  final String card3Title;
  final String ctaLabel;

  // ── Phase 2 UI strings ───────────────────────────────────────────────────
  final String capturingLabel;
  final String bpmLabel;
  final String timerSuffix;
  final String footerText;

  // ── Phase 3 UI strings ───────────────────────────────────────────────────
  final String successTitle;
  final String infoCardTitle;
  final String infoCardBody;
  final String continueCta;

  const BaselineState({
    this.status = BaselineStatus.instruction,
    this.bpm = 70,
    this.remainingSeconds = 60,
    this.progress = 0.0,
    this.navigateToNext = false,
    this.headerTitle = "Let's measure your baseline",
    this.headerSubtitle =
        "We need to know your resting heart rate. This helps us tell when "
            "you're calm vs. stressed during a session.",
    this.card1Title = 'Sit comfortably',
    this.card2Title = 'Breathe normally',
    this.card3Title = "Don't move",
    this.ctaLabel = 'Start - 60 sec',
    this.capturingLabel = 'Capturing baseline...',
    this.bpmLabel = 'BPM',
    this.timerSuffix = 'remaining',
    this.footerText = 'Stay still - movement affects accuracy',
    this.successTitle = 'Your resting heart rate is',
    this.infoCardTitle = 'Baseline saved',
    this.infoCardBody =
        "This is your personal baseline. We'll use it to detect when stress "
            'affects your performance during competition and training.',
    this.continueCta = 'Continue',
  });

  // ── Derived helpers ───────────────────────────────────────────────────────

  String get timerText {
    final m = remainingSeconds ~/ 60;
    final s = remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  bool get isCapturing => status == BaselineStatus.capturing;
  bool get isSuccess => status == BaselineStatus.success;

  // ── Copy ──────────────────────────────────────────────────────────────────

  BaselineState copyWith({
    BaselineStatus? status,
    int? bpm,
    int? remainingSeconds,
    double? progress,
    bool? navigateToNext,
  }) {
    return BaselineState(
      status: status ?? this.status,
      bpm: bpm ?? this.bpm,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      progress: progress ?? this.progress,
      navigateToNext: navigateToNext ?? this.navigateToNext,
      headerTitle: headerTitle,
      headerSubtitle: headerSubtitle,
      card1Title: card1Title,
      card2Title: card2Title,
      card3Title: card3Title,
      ctaLabel: ctaLabel,
      capturingLabel: capturingLabel,
      bpmLabel: bpmLabel,
      timerSuffix: timerSuffix,
      footerText: footerText,
      successTitle: successTitle,
      infoCardTitle: infoCardTitle,
      infoCardBody: infoCardBody,
      continueCta: continueCta,
    );
  }

  @override
  List<Object?> get props => [
        status,
        bpm,
        remainingSeconds,
        progress,
        navigateToNext,
        headerTitle,
        headerSubtitle,
        card1Title,
        card2Title,
        card3Title,
        ctaLabel,
        capturingLabel,
        bpmLabel,
        timerSuffix,
        footerText,
        successTitle,
        infoCardTitle,
        infoCardBody,
        continueCta,
      ];
}
