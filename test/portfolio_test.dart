import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paktradex/features/portfolio/presentation/portfolio_screen.dart';
import 'package:paktradex/features/portfolio/presentation/widgets/deposit_cash_modal.dart';
import 'package:paktradex/features/portfolio/presentation/widgets/holdings_list.dart';
import 'package:paktradex/features/portfolio/presentation/widgets/order_history_list.dart';
import 'package:paktradex/features/portfolio/presentation/widgets/sector_allocation_pie_chart.dart';
import 'package:paktradex/features/trading/models/trading_models.dart';
import 'package:paktradex/features/trading/providers/trading_provider.dart';

void main() {
  group('Portfolio Feature & Deposit Simulation Tests', () {
    test('TradingNotifier depositCash and withdrawCash calculate balances correctly', () {
      final notifier = TradingNotifier();
      final initialCash = notifier.state.availableCash;

      notifier.depositCash(50000);
      expect(notifier.state.availableCash, equals(initialCash + 50000));

      final withdrawErr = notifier.withdrawCash(20000);
      expect(withdrawErr, isNull);
      expect(notifier.state.availableCash, equals(initialCash + 30000));

      final excessiveWithdrawErr = notifier.withdrawCash(99999999);
      expect(excessiveWithdrawErr, isNotNull);
      expect(excessiveWithdrawErr, contains('Insufficient'));
    });

    testWidgets('HoldingsList renders holding position metrics', (tester) async {
      const sampleHoldings = [
        HoldingPosition(
          symbol: 'SYS',
          name: 'Systems Limited',
          sector: 'Technology',
          shares: 200,
          avgBuyPrice: 400.0,
          currentPrice: 450.0,
        ),
      ];

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: HoldingsList(holdings: sampleHoldings),
            ),
          ),
        ),
      );

      expect(find.text('SYS'), findsOneWidget);
      expect(find.text('Systems Limited'), findsOneWidget);
      expect(find.text('Technology'), findsOneWidget);
      expect(find.textContaining('200 shares'), findsOneWidget);
    });

    testWidgets('OrderHistoryList displays empty state and list items correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OrderHistoryList(orders: []),
          ),
        ),
      );

      expect(find.text('No Trade Orders Yet'), findsOneWidget);

      final sampleOrders = [
        TradeOrder(
          id: 'ord-1',
          symbol: 'MCB',
          stockName: 'MCB Bank Limited',
          side: OrderSide.buy,
          type: OrderType.market,
          quantity: 100,
          price: 320.0,
          totalValue: 32000.0,
          fee: 48.0,
          status: OrderStatus.executed,
          createdAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: OrderHistoryList(orders: sampleOrders),
            ),
          ),
        ),
      );

      expect(find.text('MCB'), findsOneWidget);
      expect(find.text('BUY'), findsOneWidget);
    });
  });
}
