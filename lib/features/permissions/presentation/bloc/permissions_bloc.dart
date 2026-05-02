import 'package:flutter_bloc/flutter_bloc.dart';

import 'permissions_event.dart';
import 'permissions_state.dart';

class PermissionsBloc extends Bloc<PermissionsEvent, PermissionsState> {
  PermissionsBloc() : super(const PermissionsState()) {
    on<OnBluetoothTapped>(_onBluetoothTapped);
    on<OnNotificationsTapped>(_onNotificationsTapped);
    on<OnMicrophoneTapped>(_onMicrophoneTapped);
    on<OnContinuePressed>(_onContinuePressed);
  }

  Future<void> _onBluetoothTapped(
    OnBluetoothTapped event,
    Emitter<PermissionsState> emit,
  ) async {
    // Ignore tap when already loading or granted
    if (state.bluetooth != PermissionStatus.initial) return;
    emit(state.copyWith(bluetooth: PermissionStatus.loading, clearError: true));
    await Future.delayed(const Duration(seconds: 1));
    emit(state.copyWith(bluetooth: PermissionStatus.granted));
  }

  Future<void> _onNotificationsTapped(
    OnNotificationsTapped event,
    Emitter<PermissionsState> emit,
  ) async {
    if (state.notifications != PermissionStatus.initial) return;
    emit(state.copyWith(
      notifications: PermissionStatus.loading,
      clearError: true,
    ));
    await Future.delayed(const Duration(seconds: 1));
    emit(state.copyWith(notifications: PermissionStatus.granted));
  }

  Future<void> _onMicrophoneTapped(
    OnMicrophoneTapped event,
    Emitter<PermissionsState> emit,
  ) async {
    if (state.microphone != PermissionStatus.initial) return;
    emit(state.copyWith(
      microphone: PermissionStatus.loading,
      clearError: true,
    ));
    await Future.delayed(const Duration(seconds: 1));
    emit(state.copyWith(microphone: PermissionStatus.granted));
  }

  Future<void> _onContinuePressed(
    OnContinuePressed event,
    Emitter<PermissionsState> emit,
  ) async {
    if (!state.canContinue) {
      emit(state.copyWith(
        errorMessage: 'Grant Bluetooth and Notifications to continue',
      ));
      return;
    }
    emit(state.copyWith(
      formStatus: PermissionsFormStatus.submitting,
      clearError: true,
    ));
    await Future.delayed(const Duration(milliseconds: 600));
    emit(state.copyWith(formStatus: PermissionsFormStatus.success));
  }
}
