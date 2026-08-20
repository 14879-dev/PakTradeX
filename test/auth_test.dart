import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paktradex/features/auth/providers/auth_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'read') return null;
      if (methodCall.method == 'write') return true;
      if (methodCall.method == 'delete') return true;
      if (methodCall.method == 'deleteAll') return true;
      return null;
    });
  });

  group('AuthNotifier State Tests', () {
    late AuthNotifier notifier;

    setUp(() {
      notifier = AuthNotifier();
    });

    test('Initial state is unauthenticated without valid token', () {
      expect(notifier.state.isAuthenticated, false);
    });

    test('Logout ensures unauthenticated state', () async {
      await notifier.logout();
      expect(notifier.state.isAuthenticated, false);
    });
  });
}
