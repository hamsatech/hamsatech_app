import 'package:equatable/equatable.dart';

abstract class WelcomeEvent extends Equatable {
  const WelcomeEvent();
  @override
  List<Object?> get props => [];
}

/// User swiped or auto-advanced to a new carousel page.
class WelcomePageChanged extends WelcomeEvent {
  const WelcomePageChanged(this.page);
  final int page;
  @override
  List<Object?> get props => [page];
}

/// User tapped "Sign Up Now".
class WelcomeSignUpTapped extends WelcomeEvent {
  const WelcomeSignUpTapped();
}

/// User tapped "Log In Here".
class WelcomeLogInTapped extends WelcomeEvent {
  const WelcomeLogInTapped();
}

/// User tapped "Continue with Google".
class WelcomeGoogleTapped extends WelcomeEvent {
  const WelcomeGoogleTapped();
}
