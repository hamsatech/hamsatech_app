import 'package:equatable/equatable.dart';

// Per-card permission lifecycle
enum PermissionStatus { initial, loading, granted }

// Overall form/submit lifecycle
enum PermissionsFormStatus { idle, submitting, success }

class PermissionsState extends Equatable {
  // ── Per-card state ───────────────────────────────────────────────────────
  final PermissionStatus bluetooth;
  final PermissionStatus notifications;
  final PermissionStatus microphone;

  // ── Form submit state ────────────────────────────────────────────────────
  final PermissionsFormStatus formStatus;
  final String? errorMessage;

  // ── UI strings (zero hardcoded text in the view) ─────────────────────────
  final String headerTitle;
  final String headerSubtitle;
  final String dividerLabel;
  final String bluetoothTitle;
  final String bluetoothSubtitle;
  final String notificationsTitle;
  final String notificationsSubtitle;
  final String microphoneTitle;
  final String microphoneSubtitle;
  final String microphoneOptionalBadge;
  final String ctaLabel;
  final String secondaryLabel;

  const PermissionsState({
    this.bluetooth = PermissionStatus.initial,
    this.notifications = PermissionStatus.initial,
    this.microphone = PermissionStatus.initial,
    this.formStatus = PermissionsFormStatus.idle,
    this.errorMessage,
    this.headerTitle = 'Your heart tells the truth',
    this.headerSubtitle =
        'We use your Polar device to measure stress, focus, and recovery '
            '— so we can show you exactly when your mind affects your shot.',
    this.dividerLabel = 'To continue, we need',
    this.bluetoothTitle = 'Bluetooth',
    this.bluetoothSubtitle = 'To connect to Polar',
    this.notificationsTitle = 'Notifications',
    this.notificationsSubtitle = 'For session reminders',
    this.microphoneTitle = 'Microphone',
    this.microphoneSubtitle = 'For session reminders',
    this.microphoneOptionalBadge = 'Optional',
    this.ctaLabel = 'Continue & Allow',
    this.secondaryLabel = "I don't have a polar yet",
  });

  // ── Derived helpers ───────────────────────────────────────────────────────

  // Bluetooth + Notifications required; Microphone is optional
  bool get canContinue =>
      bluetooth == PermissionStatus.granted &&
      notifications == PermissionStatus.granted;

  bool get isContinueLoading => formStatus == PermissionsFormStatus.submitting;
  bool get isContinueSuccess => formStatus == PermissionsFormStatus.success;

  // ── Copy ──────────────────────────────────────────────────────────────────

  PermissionsState copyWith({
    PermissionStatus? bluetooth,
    PermissionStatus? notifications,
    PermissionStatus? microphone,
    PermissionsFormStatus? formStatus,
    String? errorMessage,
    // Pass true to explicitly clear the error message
    bool clearError = false,
  }) {
    return PermissionsState(
      bluetooth: bluetooth ?? this.bluetooth,
      notifications: notifications ?? this.notifications,
      microphone: microphone ?? this.microphone,
      formStatus: formStatus ?? this.formStatus,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      headerTitle: headerTitle,
      headerSubtitle: headerSubtitle,
      dividerLabel: dividerLabel,
      bluetoothTitle: bluetoothTitle,
      bluetoothSubtitle: bluetoothSubtitle,
      notificationsTitle: notificationsTitle,
      notificationsSubtitle: notificationsSubtitle,
      microphoneTitle: microphoneTitle,
      microphoneSubtitle: microphoneSubtitle,
      microphoneOptionalBadge: microphoneOptionalBadge,
      ctaLabel: ctaLabel,
      secondaryLabel: secondaryLabel,
    );
  }

  @override
  List<Object?> get props => [
        bluetooth,
        notifications,
        microphone,
        formStatus,
        errorMessage,
        headerTitle,
        headerSubtitle,
        dividerLabel,
        bluetoothTitle,
        bluetoothSubtitle,
        notificationsTitle,
        notificationsSubtitle,
        microphoneTitle,
        microphoneSubtitle,
        microphoneOptionalBadge,
        ctaLabel,
        secondaryLabel,
      ];
}
