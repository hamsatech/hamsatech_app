import 'package:flutter_bloc/flutter_bloc.dart';

import 'permissions_event.dart';
import 'permissions_state.dart';

class PermissionsBloc extends Bloc<PermissionsEvent, PermissionsState> {
  PermissionsBloc() : super(const PermissionsState()) {
    on<OnBluetoothTapped>(_onPermissionTapped);
    on<OnNotificationsTapped>(_onPermissionTapped);
    on<OnMicrophoneTapped>(_onPermissionTapped);
    on<OnContinuePressed>(_onContinuePressed);
  }

  void _onPermissionTapped(
    PermissionsEvent event,
    Emitter<PermissionsState> emit,
  ) {
    emit(const PermissionsState(status: PermissionsStatus.idle));
  }

  Future<void> _onContinuePressed(
    OnContinuePressed event,
    Emitter<PermissionsState> emit,
  ) async {
    emit(const PermissionsState(status: PermissionsStatus.loading));
    await Future<void>.delayed(const Duration(milliseconds: 300));
    emit(const PermissionsState(status: PermissionsStatus.success));
  }
}
