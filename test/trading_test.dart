import 'package:flutter_test/flutter_test.dart';
import 'package:paktradex/features/trading/models/trading_models.dart';
import 'package:paktradex/features/trading/providers/trading_provider.dart';

void main() {
  group('TradingNotifier Simulation Engine Tests', () {
    late TradingNotifier tradingNotifier;

    setUp(() {
      tradingNotifier = TradingNotifier();
    });

    test('Initial portfolio state has initial cash and positions', () {
      final state = tradingNotifier.state;
      expect(state.availableCash, equals(274300.0));
      expect(state.holdings.length, equals(4));
      expect(state.orders, isEmpty);
      expect(state.totalPortfolioValue, greaterThan(1000000.0));
    });

    test('Buy order with sufficient cash succeeds and updates cash, holdings, and orders', () async {
      final initialCash = tradingNotifier.state.availableCash;
      const buyPrice = 200.0;
      const buyQty = 50;
      const totalTradeValue = buyPrice * buyQty; // 10,000
      final fee = (totalTradeValue * 0.0015).clamp(25.0, 500.0); // 25.0

      final error = await tradingNotifier.placeBuyOrder(
        symbol: 'SYS',
        stockName: 'Systems Limited',
        sector: 'Technology',
        quantity: buyQty,
        price: buyPrice,
        orderType: OrderType.market,
      );

      expect(error, isNull);
      final newState = tradingNotifier.state;
      expect(newState.availableCash, equals(initialCash - (totalTradeValue + fee)));
      expect(newState.orders.length, equals(1));
      expect(newState.orders.first.side, equals(OrderSide.buy));
      expect(newState.orders.first.status, equals(OrderStatus.executed));

      final sysHolding = newState.holdings.firstWhere((h) => h.symbol == 'SYS');
      expect(sysHolding.shares, equals(350 + buyQty)); // 350 + 50 = 400
    });

    test('Buy order with insufficient funds returns error message', () async {
      final error = await tradingNotifier.placeBuyOrder(
        symbol: 'ENGRO',
        stockName: 'Engro Corporation',
        sector: 'Fertilizer',
        quantity: 100000,
        price: 480.0,
        orderType: OrderType.market,
      );

      expect(error, isNotNull);
      expect(error, contains('Insufficient cash'));
    });

    test('Sell order of owned stock succeeds and credits cash', () async {
      final initialCash = tradingNotifier.state.availableCash;
      const sellPrice = 330.0;
      const sellQty = 200;
      const totalTradeValue = sellPrice * sellQty; // 66,000
      final fee = (totalTradeValue * 0.0015).clamp(25.0, 500.0); // 99.0

      final error = await tradingNotifier.placeSellOrder(
        symbol: 'MCB',
        quantity: sellQty,
        price: sellPrice,
        orderType: OrderType.market,
      );

      expect(error, isNull);
      final newState = tradingNotifier.state;
      expect(newState.availableCash, equals(initialCash + (totalTradeValue - fee)));
      final mcbHolding = newState.holdings.firstWhere((h) => h.symbol == 'MCB');
      expect(mcbHolding.shares, equals(1200 - sellQty)); // 1200 - 200 = 1000
    });

    test('Sell order exceeding owned quantity returns error', () async {
      final error = await tradingNotifier.placeSellOrder(
        symbol: 'MCB',
        quantity: 9999,
        price: 320.0,
        orderType: OrderType.market,
      );

      expect(error, isNotNull);
      expect(error, contains('Insufficient shares'));
    });
  });
}
