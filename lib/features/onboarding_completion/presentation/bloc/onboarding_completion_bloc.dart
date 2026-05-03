import 'package:flutter_bloc/flutter_bloc.dart';

import 'onboarding_completion_event.dart';
import 'onboarding_completion_state.dart';

class OnboardingCompletionBloc
    extends Bloc<OnboardingCompletionEvent, OnboardingCompletionState> {
  OnboardingCompletionBloc({
    // Accept optional overrides so real data from previous steps can be
    // injected later without changing the BLoC's internal structure.
    String? userName,
    String? discipline,
    String? goal,
    String? restingHr,
  }) : super(
          OnboardingCompletionState(
            userName: userName ?? 'Alex',
            summaryItems: [
              SummaryItemModel(
                label: 'Discipline',
                value: discipline ?? 'Air Pistol',
              ),
              SummaryItemModel(
                label: 'Goal',
                value: goal ?? '560 in 30d',
              ),
              SummaryItemModel(
                label: 'Resting HR',
                value: restingHr ?? '68 bpm',
              ),
              const SummaryItemModel(
                label: 'Coach',
                value: 'Not linked',
                isValueHighlighted: true,
              ),
            ],
          ),
        ) {
    on<OnGoHomePressed>(_onGoHomePressed);
  }

  void _onGoHomePressed(
    OnGoHomePressed event,
    Emitter<OnboardingCompletionState> emit,
  ) {
    emit(state.copyWith(navigateToHome: true));
  }
}
