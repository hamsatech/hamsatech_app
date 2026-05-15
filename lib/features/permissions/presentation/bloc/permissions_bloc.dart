import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

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
    emit(
      state.copyWith(
        bluetoothLoading: true,
        bluetoothGranted: false,
      ),
    );

    await Future<void>.delayed(Duration.zero);

    final result = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();

    final granted = result.values.every((status) => status.isGranted);

    emit(
      state.copyWith(
        bluetoothLoading: false,
        bluetoothGranted: granted,
      ),
    );
  }

  Future<void> _onNotificationsTapped(
    OnNotificationsTapped event,
    Emitter<PermissionsState> emit,
  ) async {
    emit(
      state.copyWith(
        notificationsLoading: true,
        notificationsGranted: false,
      ),
    );

    await Future<void>.delayed(Duration.zero);

    final status = await Permission.notification.request();

    emit(
      state.copyWith(
        notificationsLoading: false,
        notificationsGranted: status.isGranted,
      ),
    );
  }

  Future<void> _onMicrophoneTapped(
    OnMicrophoneTapped event,
    Emitter<PermissionsState> emit,
  ) async {
    emit(
      state.copyWith(
        microphoneLoading: true,
        microphoneGranted: false,
      ),
    );

    await Future<void>.delayed(Duration.zero);

    final status = await Permission.microphone.request();

    emit(
      state.copyWith(
        microphoneLoading: false,
        microphoneGranted: status.isGranted,
      ),
    );
  }

  Future<void> _onContinuePressed(
    OnContinuePressed event,
    Emitter<PermissionsState> emit,
  ) async {
    emit(
      state.copyWith(
        status: PermissionsStatus.loading,
      ),
    );

    await Future<void>.delayed(
      const Duration(milliseconds: 300),
    );

    emit(
      state.copyWith(
        status: PermissionsStatus.success,
      ),
    );
  }
}
