import 'package:flutter_bloc/flutter_bloc.dart';
import '../viewmodels/welcome_view_model.dart';
import 'welcome_event.dart';
import 'welcome_state.dart';

class WelcomeBloc extends Bloc<WelcomeEvent, WelcomeState> {
  WelcomeBloc(this._viewModel)
      : super(WelcomeState(slides: _viewModel.slides)) {
    on<WelcomePageChanged>(_onPageChanged);
    on<WelcomeSignUpTapped>(_onSignUpTapped);
    on<WelcomeLogInTapped>(_onLogInTapped);
    on<WelcomeGoogleTapped>(_onGoogleTapped);
  }

  final WelcomeViewModel _viewModel;

  void _onPageChanged(WelcomePageChanged event, Emitter<WelcomeState> emit) {
    emit(state.copyWith(
      currentPage: event.page,
      status: WelcomeStatus.idle,
    ));
  }

  Future<void> _onSignUpTapped(
    WelcomeSignUpTapped event,
    Emitter<WelcomeState> emit,
  ) async {
    await _viewModel.initiateSignUp();
    emit(state.copyWith(status: WelcomeStatus.navigateToSignUp));
  }

  Future<void> _onLogInTapped(
    WelcomeLogInTapped event,
    Emitter<WelcomeState> emit,
  ) async {
    await _viewModel.initiateLogin();
    emit(state.copyWith(status: WelcomeStatus.navigateToLogin));
  }

  void _onGoogleTapped(WelcomeGoogleTapped event, Emitter<WelcomeState> emit) {
    emit(state.copyWith(status: WelcomeStatus.comingSoon));
  }
}
