import 'package:flutter_test/flutter_test.dart';
import 'package:hamsatech/features/live_training/data/services/hr_telemetry_service.dart';
import 'package:hamsatech/features/polar/data/services/polar_ble_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('flushNow() is a no-op when nothing is pending', () async {
    final service = HrTelemetryService(PolarBleService());
    addTearDown(service.dispose);

    expect(service.pendingCount, 0);

    // Must return promptly without attempting any network call — there is
    // nothing buffered, so this must not throw or hang.
    await service.flushNow();

    expect(service.pendingCount, 0);
    expect(service.bufferLength, 0);
  });
}
