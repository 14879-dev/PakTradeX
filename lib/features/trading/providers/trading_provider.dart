import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_client.dart';
import '../models/trading_models.dart';

class TradingPortfolioState {
  final double availableCash;
  final List<HoldingPosition> holdings;
  final List<TradeOrder> orders;

  const TradingPortfolioState({
    required this.availableCash,
    required this.holdings,
    required this.orders,
  });

  double get totalPortfolioValue {
    final holdingsValue = holdings.fold<double>(0.0, (sum, h) => sum + h.totalCurrentValue);
    return availableCash + holdingsValue;
  }

  double get totalInvested {
    return holdings.fold<double>(0.0, (sum, h) => sum + h.totalInvested);
  }

  double get totalUnrealizedPnl {
    return holdings.fold<double>(0.0, (sum, h) => sum + h.unrealizedPnl);
  }

  double get totalPnlPercent {
    return totalInvested > 0 ? (totalUnrealizedPnl / totalInvested) * 100 : 0.0;
  }
}

class TradingNotifier extends StateNotifier<TradingPortfolioState> {
  TradingNotifier({bool autoSync = false})
      : super(
          const TradingPortfolioState(
            availableCash: 274300.00,
            holdings: [
              HoldingPosition(
                symbol: 'MCB',
                name: 'MCB Bank Limited',
                sector: 'Commercial Banks',
                shares: 1200,
                avgBuyPrice: 290.00,
                currentPrice: 322.40,
              ),
              HoldingPosition(
                symbol: 'ENGRO',
                name: 'Engro Corporation',
                sector: 'Fertilizer',
                shares: 800,
                avgBuyPrice: 440.00,
                currentPrice: 481.20,
              ),
              HoldingPosition(
                symbol: 'OGDC',
                name: 'Oil & Gas Development Co.',
                sector: 'Oil & Gas',
                shares: 1500,
                avgBuyPrice: 295.00,
                currentPrice: 287.50,
              ),
              HoldingPosition(
                symbol: 'SYS',
                name: 'Systems Limited',
                sector: 'Technology',
                shares: 350,
                avgBuyPrice: 420.00,
                currentPrice: 462.90,
              ),
            ],
            orders: [],
          ),
        ) {
    if (autoSync) {
      syncWithBackend();
    }
  }

  /// Syncs state with FastAPI backend if reachable
  Future<void> syncWithBackend() async {
    try {
      final res = await apiClient.get('/trading/portfolio');
      if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
        final data = res.data as Map<String, dynamic>;
        final cash = (data['available_cash'] as num?)?.toDouble() ?? state.availableCash;
        final rawHoldings = data['holdings'] as List<dynamic>? ?? [];
        final rawOrders = data['orders'] as List<dynamic>? ?? [];

        final holdings = rawHoldings.map((h) {
          final hm = h as Map<String, dynamic>;
          return HoldingPosition(
            symbol: hm['symbol'] as String? ?? '',
            name: hm['name'] as String? ?? '',
            sector: hm['sector'] as String? ?? '',
            shares: (hm['shares'] as num?)?.toInt() ?? 0,
            avgBuyPrice: (hm['avg_buy_price'] as num?)?.toDouble() ?? 0.0,
            currentPrice: (hm['current_price'] as num?)?.toDouble() ?? 0.0,
          );
        }).toList();

        final orders = rawOrders.map((o) {
          final om = o as Map<String, dynamic>;
          return TradeOrder(
            id: om['id'] as String? ?? '',
            symbol: om['symbol'] as String? ?? '',
            stockName: om['stock_name'] as String? ?? '',
            side: om['side'] == 'buy' ? OrderSide.buy : OrderSide.sell,
            type: OrderType.market,
            quantity: (om['quantity'] as num?)?.toInt() ?? 0,
            price: (om['price'] as num?)?.toDouble() ?? 0.0,
            totalValue: (om['total_value'] as num?)?.toDouble() ?? 0.0,
            fee: (om['fee'] as num?)?.toDouble() ?? 0.0,
            status: OrderStatus.executed,
            createdAt: DateTime.tryParse(om['created_at'] as String? ?? '') ?? DateTime.now(),
          );
        }).toList();

        state = TradingPortfolioState(
          availableCash: cash,
          holdings: holdings.isNotEmpty ? holdings : state.holdings,
          orders: orders,
        );
      }
    } catch (_) {
      // Backend not running or offline; local state maintained
    }
  }

  /// Places a Buy order with backend sync & optimistic update
  Future<String?> placeBuyOrder({
    required String symbol,
    required String stockName,
    required String sector,
    required int quantity,
    required double price,
    required OrderType orderType,
  }) async {
    if (quantity <= 0) return 'Quantity must be at least 1 share.';

    final totalCost = quantity * price;
    final fee = (totalCost * 0.0015).clamp(25.0, 500.0); // 0.15% brokerage fee, min 25 PKR
    final grandTotal = totalCost + fee;

    if (grandTotal > state.availableCash) {
      return 'Insufficient cash balance. You need Rs. ${grandTotal.toStringAsFixed(2)} but have Rs. ${state.availableCash.toStringAsFixed(2)}.';
    }

    final newOrder = TradeOrder(
      id: 'ord-${DateTime.now().millisecondsSinceEpoch}',
      symbol: symbol,
      stockName: stockName,
      side: OrderSide.buy,
      type: orderType,
      quantity: quantity,
      price: price,
      totalValue: totalCost,
      fee: fee,
      status: OrderStatus.executed,
      createdAt: DateTime.now(),
    );

    // Update holdings
    final existingIndex = state.holdings.indexWhere((h) => h.symbol == symbol);
    List<HoldingPosition> updatedHoldings = List.from(state.holdings);

    if (existingIndex >= 0) {
      final existing = state.holdings[existingIndex];
      final newShares = existing.shares + quantity;
      final newAvgBuy = ((existing.shares * existing.avgBuyPrice) + (quantity * price)) / newShares;

      updatedHoldings[existingIndex] = existing.copyWith(
        shares: newShares,
        avgBuyPrice: newAvgBuy,
        currentPrice: price,
      );
    } else {
      updatedHoldings.add(
        HoldingPosition(
          symbol: symbol,
          name: stockName,
          sector: sector,
          shares: quantity,
          avgBuyPrice: price,
          currentPrice: price,
        ),
      );
    }

    state = TradingPortfolioState(
      availableCash: state.availableCash - grandTotal,
      holdings: updatedHoldings,
      orders: [newOrder, ...state.orders],
    );

    // Async backend notify
    apiClient.post('/trading/orders', data: {
      'symbol': symbol,
      'stock_name': stockName,
      'sector': sector,
      'side': 'buy',
      'type': 'market',
      'quantity': quantity,
      'price': price,
    }).catchError((_) => Response(requestOptions: RequestOptions()));

    return null; // Success
  }

  /// Places a Sell order with backend sync & optimistic update
  Future<String?> placeSellOrder({
    required String symbol,
    required int quantity,
    required double price,
    required OrderType orderType,
  }) async {
    if (quantity <= 0) return 'Quantity must be at least 1 share.';

    final existingIndex = state.holdings.indexWhere((h) => h.symbol == symbol);
    if (existingIndex < 0 || state.holdings[existingIndex].shares < quantity) {
      final owned = existingIndex >= 0 ? state.holdings[existingIndex].shares : 0;
      return 'Insufficient shares. You only own $owned shares of $symbol.';
    }

    final totalProceeds = quantity * price;
    final fee = (totalProceeds * 0.0015).clamp(25.0, 500.0);
    final netProceeds = totalProceeds - fee;

    final existing = state.holdings[existingIndex];
    final remainingShares = existing.shares - quantity;

    List<HoldingPosition> updatedHoldings = List.from(state.holdings);
    if (remainingShares > 0) {
      updatedHoldings[existingIndex] = existing.copyWith(
        shares: remainingShares,
        currentPrice: price,
      );
    } else {
      updatedHoldings.removeAt(existingIndex);
    }

    final newOrder = TradeOrder(
      id: 'ord-${DateTime.now().millisecondsSinceEpoch}',
      symbol: symbol,
      stockName: existing.name,
      side: OrderSide.sell,
      type: orderType,
      quantity: quantity,
      price: price,
      totalValue: totalProceeds,
      fee: fee,
      status: OrderStatus.executed,
      createdAt: DateTime.now(),
    );

    state = TradingPortfolioState(
      availableCash: state.availableCash + netProceeds,
      holdings: updatedHoldings,
      orders: [newOrder, ...state.orders],
    );

    // Async backend notify
    apiClient.post('/trading/orders', data: {
      'symbol': symbol,
      'stock_name': existing.name,
      'side': 'sell',
      'type': 'market',
      'quantity': quantity,
      'price': price,
    }).catchError((_) => Response(requestOptions: RequestOptions()));

    return null; // Success
  }

  /// Adds simulated demo cash to the wallet balance and syncs backend
  void depositCash(double amount) {
    if (amount <= 0) return;
    state = TradingPortfolioState(
      availableCash: state.availableCash + amount,
      holdings: state.holdings,
      orders: state.orders,
    );

    apiClient.post('/trading/deposit', queryParameters: {'amount': amount})
        .catchError((_) => Response(requestOptions: RequestOptions()));
  }

  /// Withdraws simulated demo cash from available balance
  String? withdrawCash(double amount) {
    if (amount <= 0) return 'Withdrawal amount must be greater than zero.';
    if (amount > state.availableCash) return 'Insufficient available cash to withdraw.';
    state = TradingPortfolioState(
      availableCash: state.availableCash - amount,
      holdings: state.holdings,
      orders: state.orders,
    );
    return null;
  }

  /// Resets demo balance to 1M PKR and clears orders
  void resetDemo() {
    state = const TradingPortfolioState(
      availableCash: 1000000.0,
      holdings: [],
      orders: [],
    );

    apiClient.post('/trading/reset')
        .catchError((_) => Response(requestOptions: RequestOptions()));
  }
}

final tradingProvider = StateNotifierProvider<TradingNotifier, TradingPortfolioState>((ref) {
  return TradingNotifier();
});
