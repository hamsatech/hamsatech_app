import 'package:flutter_test/flutter_test.dart';
import 'package:hamsatech/main.dart';

/// Regression coverage for the cold-start auth desync bug: the JWT is saved
/// to secure storage unconditionally on login (AuthRepositoryImpl.verifyOtp),
/// independent of whether the best-effort athlete_id sync that follows it
/// succeeds. Restoring the token into the mobile-auth interceptor on the
/// next cold start must never be gated on athlete_id being present.
void main() {
  group('planSecureSessionRestore', () {
    test(
      'restores the token even when no athlete_id was ever synced '
      '(the exact regression scenario)',
      () {
        final plan = planSecureSessionRestore(
          secureToken: 'jwt-token',
          secureAthleteId: null,
          cachedAthleteId: null,
        );

        expect(plan.shouldSetToken, isTrue);
        expect(plan.shouldBackfillAthleteId, isFalse);
      },
    );

    test(
        'restores the token and backfills athlete_id when both are known '
        'but SharedPreferences was wiped', () {
      final plan = planSecureSessionRestore(
        secureToken: 'jwt-token',
        secureAthleteId: 'ASA001',
        cachedAthleteId: null,
      );

      expect(plan.shouldSetToken, isTrue);
      expect(plan.shouldBackfillAthleteId, isTrue);
    });

    test('does not re-backfill athlete_id when it is already cached', () {
      final plan = planSecureSessionRestore(
        secureToken: 'jwt-token',
        secureAthleteId: 'ASA001',
        cachedAthleteId: 'ASA001',
      );

      expect(plan.shouldSetToken, isTrue);
      expect(plan.shouldBackfillAthleteId, isFalse);
    });

    test('does nothing when there is no token in secure storage', () {
      final plan = planSecureSessionRestore(
        secureToken: null,
        secureAthleteId: 'ASA001',
        cachedAthleteId: null,
      );

      expect(plan.shouldSetToken, isFalse);
      expect(plan.shouldBackfillAthleteId, isFalse);
    });

    test('treats an empty-string token the same as a missing one', () {
      final plan = planSecureSessionRestore(
        secureToken: '',
        secureAthleteId: 'ASA001',
        cachedAthleteId: null,
      );

      expect(plan.shouldSetToken, isFalse);
      expect(plan.shouldBackfillAthleteId, isFalse);
    });
  });
}
