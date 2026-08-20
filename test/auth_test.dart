import 'package:flutter_test/flutter_test.dart';
import 'package:paktradex/features/auth/models/auth_state.dart';
import 'package:paktradex/features/auth/providers/auth_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthNotifier State Tests', () {
    late AuthNotifier notifier;

    setUp(() {
      notifier = AuthNotifier();
    });

    test('Initial state is initial or unauthenticated', () {
      expect(notifier.state.isAuthenticated, false);
    });

    test('Guest login sets status to guest', () {
      notifier.loginAsGuest();
      expect(notifier.state.status, AuthStatus.guest);
      expect(notifier.state.isAuthenticated, true);
      expect(notifier.state.user?.fullName, 'Guest Trader');
      expect(notifier.state.user?.pakTradeId, isNotEmpty);
    });

    test('Logout clears session', () {
      notifier.loginAsGuest();
      expect(notifier.state.isAuthenticated, true);
      notifier.logout();
      expect(notifier.state.status, AuthStatus.unauthenticated);
      expect(notifier.state.isAuthenticated, false);
    });
  });
}
