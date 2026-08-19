import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paktradex/app/app.dart';

void main() {
  testWidgets('PakTradeX App launches with Splash and transitions to Onboarding', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: PakTradeXApp(),
      ),
    );

    // Advance splash delay
    await tester.pumpAndSettle();

    // Verify Onboarding carousel header loaded
    expect(find.textContaining('Invest in Pakistan'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });
}
