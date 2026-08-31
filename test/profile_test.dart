import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paktradex/features/profile/presentation/profile_screen.dart';
import 'package:paktradex/features/trading/providers/trading_provider.dart';

void main() {
  group('Profile, Security & Reset Wallet Tests', () {
    test('TradingNotifier resetDemo resets wallet cash and clears holdings', () {
      final notifier = TradingNotifier();
      expect(notifier.state.holdings.isNotEmpty, isTrue);

      notifier.resetDemo();
      expect(notifier.state.availableCash, equals(1000000.0));
      expect(notifier.state.holdings, isEmpty);
      expect(notifier.state.orders, isEmpty);
    });

    testWidgets('ProfileScreen renders user profile and shortcuts', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );

      // Verify Shortcut header exists on the profile screen
      expect(find.text('Shortcut'), findsOneWidget);
    });
  });
}
