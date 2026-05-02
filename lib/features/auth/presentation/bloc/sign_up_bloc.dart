import 'package:flutter_bloc/flutter_bloc.dart';

import '../viewmodels/sign_up_view_model.dart';
import 'sign_up_event.dart';
import 'sign_up_state.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  SignUpBloc(this._viewModel) : super(const SignUpState()) {
    on<SignUpContinueTapped>(_onContinue);
    on<SignUpGoogleTapped>(_onGoogle);
    on<SignUpAppleTapped>(_onApple);
  }

  final SignUpViewModel _viewModel;

  void _onContinue(SignUpContinueTapped _, Emitter<SignUpState> emit) {
    emit(state.copyWith(status: SignUpStatus.navigateToPhone));
  }

  Future<void> _onGoogle(
    SignUpGoogleTapped _,
    Emitter<SignUpState> emit,
  ) async {
    emit(state.copyWith(status: SignUpStatus.loading));
    try {
      await _viewModel.signUpWithGoogle();
      emit(state.copyWith(status: SignUpStatus.comingSoon));
    } catch (e) {
      emit(state.copyWith(
        status: SignUpStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onApple(
    SignUpAppleTapped _,
    Emitter<SignUpState> emit,
  ) async {
    emit(state.copyWith(status: SignUpStatus.loading));
    try {
      await _viewModel.signUpWithApple();
      emit(state.copyWith(status: SignUpStatus.comingSoon));
    } catch (e) {
      emit(state.copyWith(
        status: SignUpStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
