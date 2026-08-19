import 'package:flutter_test/flutter_test.dart';
import 'package:paktradex/features/auth/models/auth_state.dart';
import 'package:paktradex/features/auth/providers/auth_provider.dart';

void main() {
  group('AuthNotifier State Tests', () {
    late AuthNotifier notifier;

    setUp(() {
      notifier = AuthNotifier();
    });

    test('Initial state is initial', () {
      expect(notifier.state.status, AuthStatus.initial);
      expect(notifier.state.isAuthenticated, false);
    });

    test('Guest login sets status to guest', () {
      notifier.loginAsGuest();
      expect(notifier.state.status, AuthStatus.guest);
      expect(notifier.state.isAuthenticated, true);
      expect(notifier.state.user?.fullName, 'Guest Trader');
    });

    test('Login triggers OTP pending state', () async {
      await notifier.login('trader@psx.com', 'password123');
      expect(notifier.state.status, AuthStatus.otpPending);
      expect(notifier.state.pendingEmailOrPhone, 'trader@psx.com');
    });

    test('Valid 6-digit OTP verification authenticates user', () async {
      await notifier.login('trader@psx.com', 'password123');
      final result = await notifier.verifyOtp('123456');
      expect(result, true);
      expect(notifier.state.status, AuthStatus.authenticated);
      expect(notifier.state.isAuthenticated, true);
    });

    test('Invalid OTP fails verification', () async {
      await notifier.login('trader@psx.com', 'password123');
      final result = await notifier.verifyOtp('123');
      expect(result, false);
      expect(notifier.state.status, AuthStatus.unauthenticated);
      expect(notifier.state.isAuthenticated, false);
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
