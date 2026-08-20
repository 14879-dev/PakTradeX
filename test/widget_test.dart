import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paktradex/app/app.dart';

void main() {
  testWidgets('PakTradeX App launches with Splash and transitions smoothly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: PakTradeXApp(),
      ),
    );

    // Initial render shows Splash screen with PX logo
    expect(find.text('PX'), findsOneWidget);

    // Advance splash delay
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();

    // Verify main app tree is mounted and rendered
    expect(find.byType(PakTradeXApp), findsOneWidget);
  });
}
