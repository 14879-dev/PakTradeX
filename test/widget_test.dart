import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paktradex/app/app.dart';

void main() {
  testWidgets('PakTradeX App launches with Splash and Brand title', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: PakTradeXApp(),
      ),
    );

    // Let splash timer elapse and route to HomeScreen
    await tester.pumpAndSettle();

    // Verify Home Screen Header loaded
    expect(find.text('Market Overview'), findsOneWidget);
    expect(find.text('AI Intelligence'), findsOneWidget);
  });
}
